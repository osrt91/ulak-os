# QA + Validation Gap Register — v2.2.1 to v1.0 Showcase Readiness

**Specialist:** qa-validation-commander
**Date:** 2026-04-20
**Scope:** test/validation/CI/showcase surface blocking confident wide-release
**Baseline tag:** v2.2.1 on origin/main
**Evidence posture:** All findings T1 (direct filesystem/command inspection). Live probes executed where script exit codes were needed.

---

## Executive summary

Ulak OS v2.2.1 ships an ambitious runtime contract (phases, gates, schemas) but the **execution layer for most of those gates does not exist yet**. The eval harness structurally fails every one of its own golden files, the CLI has ~1,400 lines of TypeScript with zero test files, CI never runs build/lint/test, the validation-plan references an unwritten validate-bilingual-examples.sh script, the vendor-parity validator silently skips Codex because .codex/commands/ does not exist, and the README still says "Surum: 2.0.0".

Before a confident v1.0 public showcase, a minimum of **6 P0 blockers** must close. They cluster in three areas:

1. **Self-incoherent eval harness** — golden assertions cannot be parsed by the runner that claims to enforce them.
2. **Unverified CLI** — src/ compiles and runs with no automated proof.
3. **Stale / contradictory public surface** — README version, missing showcase media, absent Codex vendor, unlinked quickstart claims.

The good news: Phase 0-1 hygiene (import validator, schema validator parse-only path, vendor parity structural walker, gitleaks) is actually wired and exits cleanly. The damage is concentrated in the eval + CLI + showcase layers, each with bounded scope.

---

## Evidence-gathering notes

- Ran `bash scripts/validate-imports.sh` — exit 0 (works).
- Ran `bash scripts/validate-schemas.sh` — exit 0 with warning (jsonschema not installed locally; CI has it).
- Ran `bash scripts/validate-vendor-parity.sh` — exit 0 (but Codex column entirely `-`).
- Ran `bash evals/run.sh` — exit 0 warn-only, **but every golden fails the structural check** and there are bash arithmetic errors on lines 49 + 68.
- Inspected `tests/unit/` and `tests/e2e/` — both empty directories.
- Grepped goldens for machine-readable `- type:` and `target: reports/current/` — zero matches.
- Inspected `src/cli/index.ts` — hardcoded version `2.0.0` (drift against `package.json: 2.2.1`).
- Inspected `README.md` line 5: `**Surum:** 2.0.0`.
- Counted bilingual files: 6 `*.en.md` vs 98 non-en `*.md` under `docs/` (6.1% parity).
- `.codex/commands/` does not exist; parity script codex branch is dormant.

---

## Finding register

Every finding carries: id, area, current state, gap, why-blocks-v1.0, severity, effort, validation command.

---

### QA-001 — Eval harness structurally rejects every golden it ships

- **Area:** prompt regression / eval infrastructure
- **Current state:** `evals/run.sh` lines 47-87 parse goldens looking for `^- type:` and `target:.*reports/current/`. Grep for machine-readable assertion lines across `evals/golden/*.md` returns **zero matches** for all 5 goldens. The runner emits "no target references reports/current/*.md" for every file.
- **Evidence (T1):** `evals/golden/01_full_program_komple.md` uses natural-language bullets ("`reports/current/runtime-manifest.md` exists with the router YAML committed") instead of the YAML shape declared in `evals/assertions/core-assertions.md:13-17`. Confirmed: `bash evals/run.sh` output shows 5/5 fail.
- **Secondary bug:** lines 49 and 68 use `[[ "$assertion_count" -eq 0 ]]` where `assertion_count=$(grep -c ... || echo 0)`. When `grep -c` errors and `|| echo 0` also fires, the var becomes a multi-line string producing `[[: 0
0: syntax error in expression`. Reproduced on every file during live run.
- **Gap:** Either the goldens must be rewritten to canonical YAML shape (matching `core-assertions.md`), OR the runner must parse natural-language claims. There is no documented "canonical assertion shape" migration doc; runner-reformatted goldens do not exist.
- **Why blocks v1.0:** The only automated regression detector for the prompt surface does not function. `prompt_regression: pass` in any manager-verdict is currently unfalsifiable. Shipping v1.0 with an advertised eval harness that rejects 100% of its own fixtures is a credibility blow.
- **Severity:** P0 blocker
- **Effort:** 1-2 sessions. Rewrite 5 goldens to canonical YAML assertion blocks (~2h), fix grep arithmetic bugs on lines 49/68 (~15min), add positive-path test fixture (~30min).
- **Validation command:** `bash evals/run.sh` emits "Passed: 5" without any bash errors.

---

### QA-002 — CLI has ~1,400 lines of TypeScript with zero tests

- **Area:** unit/integration coverage for `src/`
- **Current state:** `tests/unit/` and `tests/e2e/` are **empty directories**. `find src -name "*.test.ts"` returns nothing. `package.json:15` defines `"test": "vitest run"` but there are no test files. `package.json:17` references `vitest.e2e.config.ts` which does not exist.
- **Evidence (T1):** `wc -l src/**/*.ts` = 1,403 production lines; no `.test.ts` or `.spec.ts` files anywhere.
- **Modules with zero coverage:**
  - `src/core/router.ts` (156 lines) — routing logic deciding mode/profile.
  - `src/core/artefact-manager.ts` (182 lines) — writes to `reports/current/`.
  - `src/core/learning-extractor.ts` (158 lines) — feeds project memory.
  - `src/core/session.ts` (116 lines) — lifecycle.
  - `src/adapters/{claude,codex,gemini,base}.ts` (272 lines combined).
  - `src/memory/{store,search}.ts` — SQLite + FTS5 state.
  - `src/pack/{loader,upgrader,validator}.ts` — pack system.
  - 8 CLI commands under `src/cli/commands/`.
- **Gap:** `prepublishOnly` runs `npm test` but test is a no-op. Publishing v1.0 from this state ships entirely unverified code.
- **Why blocks v1.0:** A "prompt operating system" CLI whose own router has zero tests is not a v1.0 candidate. Router correctness is load-bearing — if it picks the wrong profile, every downstream phase is wrong.
- **Severity:** P0 blocker
- **Effort:** 3-4 sessions for baseline coverage:
  - Router table-driven unit tests (5 router decisions from goldens) — 2h.
  - Artefact-manager write-roundtrip tests — 1h.
  - Adapter subprocess-mock tests — 2h.
  - CLI command smoke tests — 3h.
  - Target: >=60% line coverage on `src/core/`, >=40% on `src/adapters/`.
- **Validation command:** `npm test && npx vitest run --coverage`

---

### QA-003 — CI never compiles, lints, or tests the TypeScript source

- **Area:** CI / build verification
- **Current state:** `.github/workflows/ci-validation.yml` has four jobs: schema/import/brand validation, AGENTS.md artefact-count grep, vendor parity, eval-smoke. **None run `npm install`, `npm run build`, `npm run lint`, or `npm test`.** The TypeScript codebase could be broken and CI would still green-check.
- **Evidence (T1):** `grep -n "npm (run )?(build|test)|vitest" .github/workflows/` — zero matches.
- **Gap:** `prepublishOnly` is the only gate, runs locally, not in CI. A malformed `src/` could pass CI and fail `npm publish`.
- **Why blocks v1.0:** Combined with QA-002 means "CI green" proves nothing about the CLI. v1.0 showcase requires CI to be a real contract.
- **Severity:** P0 blocker
- **Effort:** 1 session. Add `cli-build` job: checkout, setup-node 18, `npm ci`, `npm run build`, `npm run lint`, `npm test`. ~45 min + debugging first eslint errors.
- **Validation command:** `gh run list --workflow ci-validation.yml --limit 1` shows build/test/lint steps all success.

---

### QA-004 — Vendor-parity validator silently hides Codex absence

- **Area:** vendor parity / public promise enforcement
- **Current state:** `scripts/validate-vendor-parity.sh:99-104` only flags missing Codex entries **if `.codex/commands/` exists**. That folder does not exist (confirmed). So the parity matrix prints Codex as `-` for every command and exits 0.
- **Evidence (T1):** Live run output shows 10 commands with `codex` column entirely `-` and final line "Vendor parity maintained across all commands."
- **Gap:** `README.md` line 25-29 promises three vendors (Claude Code, Codex / Copilot, Gemini CLI). AGENTS.md exists (Codex/Copilot entrypoint), but `.codex/commands/` does not. The promise is partial: Codex gets a root-level entrypoint but zero slash commands. The parity script does not surface this drift.
- **Why blocks v1.0:** "3 vendor adapters" claim is load-bearing for Ulak OS positioning. Either ship `.codex/commands/`, tighten the README to "2 primary + Codex entrypoint only", OR make parity script explicitly fail when a documented vendor is missing its command folder.
- **Severity:** P1 (P0 if README claim stays as-is)
- **Effort:** Option A (fill Codex): 1-2 sessions to port the 8 Claude commands. Option B (tighten README + parity script): 30 min.
- **Validation command:** Option A: `test -d .codex/commands && bash scripts/validate-vendor-parity.sh`. Option B: extend parity script with `--strict-vendors` flag.

---

### QA-005 — README.md version is stale by two minor versions

- **Area:** showcase readiness / public doc freshness
- **Current state:** `README.md:5` says `**Surum:** 2.0.0 (CLI Console + Memory + Vendor Adapters)`. `package.json:3` says `"version": "2.2.1"`. `src/cli/index.ts:18` says `.version("2.0.0")`. Three separate stale version strings.
- **Evidence (T1):** Grep for `2.0.0` in README.md returns lines 5, 31, 131, 135. Section "v2.1+ planlaniyor" already obsolete.
- **Gap:** Quickstart still refers to v2.0 feature set. User landing on GitHub page sees README contradicting shipping release.
- **Why blocks v1.0:** First-impression credibility. Public showcase where README disagrees with package.json and CHANGELOG signals abandonment.
- **Severity:** P0 blocker
- **Effort:** 30 min — update README version header, refresh feature-table, bump `src/cli/index.ts` to read version from package.json, add CI assertion README version matches package.json.
- **Validation command:** `diff <(grep -oE "2\.[0-9]+\.[0-9]+" README.md | head -1) <(node -p "require('./package.json').version")`


---

### QA-006 â€” Validation plan references unwritten script validate-bilingual-examples.sh

- **Area:** localization validation gate
- **Current state:** reports/current/validation-plan.md line 34 declares the localization gate with command scripts/validate-bilingual-examples.sh "after W5.15". Grep confirms no such file exists.
- **Evidence (T1):** find scripts -name "bilingual" returns empty. W5.15 is deferred per CHANGELOG v2.2.1 Deferred section.
- **Gap:** The validation-plan lists a pass target with non-existent runner. Any localization pass claim is unfalsifiable. Bilingual coverage is mathematically broken: 6 en.md files vs 98 non-en md files (6.1 percent parity). README promises EN version and claims parallel English.
- **Why blocks v1.0:** Either the gate is demoted to not-applicable (softening the EN-parity promise), or the script is written enforcing a pragmatic subset (e.g., every doc under docs/runtime/, docs/governance/, docs/adapters/ must have an en.md sibling).
- **Severity:** P1
- **Effort:** 1 session â€” write validate-bilingual-examples.sh with a scoped allowlist. ~2h.
- **Validation command:** bash scripts/validate-bilingual-examples.sh succeeds and file exists.


---

### QA-007 Validation schema defines 10 test gates; only 3 have real runners

- Area: gate-to-runner wiring
- Current state: docs/runtime/validation-result-schema.md lines 19-29 enumerate 10 test gates.
- Evidence (T1): filesystem grep for each expected runner file; only ci-validation.yml and secret-scan.yml exist.
- Gap: Manager-verdict blocks emitting unit pass or prompt_regression pass cannot cite evidence.
- Why blocks v1.0: The evidence-first self-promise is the core differentiator. Shipping v1.0 with 70 percent of gates unwired is an honesty gap red-team-challenger would flag.
- Severity: P0 (resolves cascadingly as QA-001/002/003/006 close)
- Effort: Rolled into QA-001/002/003/006 plus 30 min schema update for not-applicable notes.
- Validation command: bash scripts/ci-gate-mapping-audit.sh (new script).

Gate mapping:

| Gate | Runner status | Evidence |
|---|---|---|
| unit | vitest configured but no tests | QA-002 |
| integration | vitest.e2e.config.ts missing | package.json line 17 |
| e2e | config missing | - |
| contract | none | - |
| visual_regression | not applicable to CLI | - |
| accessibility | not applicable to CLI | - |
| security_regression | gitleaks wired | ci-validation.yml line 70 |
| localization | script does not exist | QA-006 |
| release_checks | none defined | - |
| prompt_regression | evals/run.sh broken | QA-001 |


---

### QA-008 secret-scan.yml redundant with gitleaks job in ci-validation.yml

- Area: CI surface hygiene
- Current state: .github/workflows/secret-scan.yml defines a gitleaks job identical in intent to ci-validation.yml lines 70-85. Both run on push/PR, both use gitleaks-action v2, both fetch-depth zero.
- Evidence (T1): Side-by-side read of both YAML files.
- Gap: Double CI minutes, divergent config. If a secret is allowlisted in .gitleaks.baseline, secret-scan.yml still flags it because it skips the baseline path.
- Why blocks v1.0: Not a hard blocker, but showcase audit will question hygiene.
- Severity: P2
- Effort: 15 min to delete secret-scan.yml or consolidate into a reusable workflow.
- Validation command: ls .github/workflows/ | grep -c gitleaks equals 1.

---

### QA-009 Missing showcase media (screenshots, video, demo run)

- Area: v1.0 public launch assets
- Current state: git ls-files grep for screenshot/png/gif/mp4/demo returns nothing. No docs/assets/, no media/, no embedded images in README.
- Evidence (T1): zero binary media tracked in git.
- Gap: v1.0 public showcase benchmarks (Claude Code, Gemini CLI, gsd-build) ship with hero GIFs or screenshots. Ulak OS has zero visual proof.
- Why blocks v1.0: Readers skim README in 10 seconds. No visual means lower conversion and lower trust.
- Severity: P1
- Effort: 1 session for asciinema recording + GIF conversion + two screenshots. ~3h including sample-project prep.
- Validation command: test -f docs/assets/director-run.gif and grep -q docs/assets README.md.

---

### QA-010 No quick-start verifies-clean integration test

- Area: onboarding smoke test
- Current state: README lines 33-66 instruct a quickstart path with no automated verification.
- Evidence (T1): .github/workflows/ contains no job that runs scripts/init-*.sh. No tests/e2e/quickstart.test.ts.
- Gap: Regression in init scripts would silently break new-user onboarding.
- Why blocks v1.0: First-touch failure is unforgiving at launch.
- Severity: P1
- Effort: 1 session to add quickstart-smoke.yml cloning into /tmp/fresh, running init-claude.sh and init-gemini.sh, asserting outputs exist. ~2h.
- Validation command: gh workflow run quickstart-smoke.yml.

---

### QA-011 No link-check / broken-link-in-docs job

- Area: doc-surface freshness
- Current state: No link-check workflow. validate-imports.sh only checks @-prefix imports, not standard markdown links.
- Evidence (T1): scripts/validate-imports.sh line 22 regex is anchored to leading @.
- Gap: README links have no automated existence check. Moving or renaming a doc breaks links silently.
- Why blocks v1.0: Docs-heavy showcase product; cross-links go stale over time.
- Severity: P2 (P1 if many broken links found on first scan)
- Effort: 30 min to add lychee-action to ci-validation.yml.
- Validation command: gh workflow run ci-validation.yml and gh run view log shows lychee pass.

---

### QA-012 Eval harness never executes real director output

- Area: end-to-end regression
- Current state: evals/run.sh lines 54-61 admit v2.2.0 would add real director execution. v2.2.1 is current and this is unfulfilled.
- Evidence (T1): evals/run.sh comments, CHANGELOG v2.2.0 to v2.2.1 has no entry for this, deferred list still contains W6.5.
- Gap: Even if QA-001 is fixed, harness validates assertion-shape, not truth. Could produce garbage artefacts and pass.
- Why blocks v1.0: Prompt regression is the central claim.
- Severity: P1
- Effort: 2-3 sessions to build evals/run-live.ts running director via adapter subprocess and resolving assertions against captured state. 6-8h.
- Validation command: npm run test:eval-live succeeds with results.json present.

---

### QA-013 AGENTS.md artefact-count check is brittle

- Area: contract enforcement
- Current state: ci-validation.yml lines 52-57 asserts count at least 14 reports/current/ entries. Current count is 16. Counts grep matches, not semantic entries.
- Evidence (T1): grep -c "reports/current/" AGENTS.md equals 16.
- Gap: Textual proxy only. Real check would parse artefact-list section and diff against canonical artefact set in core contract.
- Why blocks v1.0: Not a hard blocker. External reviewer notices shallowness.
- Severity: P2
- Effort: 1 session to diff canonical artefact list against AGENTS/CLAUDE/GEMINI. ~2h.
- Validation command: bash scripts/validate-artefact-chain-consistency.sh (new script).

---

### QA-014 No mutation or fuzz testing

- Area: adversarial coverage
- Current state: No mutation testing, no fuzz harness, no prompt-injection regression beyond the single assertion type (with zero goldens using it).
- Evidence (T1): grep for stryker/mutation/fuzz in package.json .github/ scripts/ returns nothing.
- Gap: router.ts (156 lines) makes judgment calls on ambiguous intent. Fuzz harness would catch failure modes humans miss.
- Why blocks v1.0: Nice-to-have for v1.0, mandatory long-term. v1.0 can ship with a roadmap entry.
- Severity: P2 (roadmap item)
- Effort: 2-3 sessions. Defer to v1.1.
- Validation command: npx stryker run mutate src/core/router.ts (future).

---

### QA-015 Release pipeline does not verify regression before tagging

- Area: release-readiness automation
- Current state: No release.yml. prepublishOnly runs locally only.
- Evidence (T1): ls .github/workflows/ shows only ci-validation.yml and secret-scan.yml.
- Gap: Nothing blocks a maintainer from tagging v1.0.0 with broken src/, failing eval harness, or stale README.
- Why blocks v1.0: v1.0 tag is a public commitment and must be gated on all CI green plus version consistency.
- Severity: P1
- Effort: 1 session to add release-gate.yml on tag push. ~2h.
- Validation command: gh run list workflow release-gate.yml shows success after tag push.


---

## Test matrix (customer / admin / public-API split)

Ulak OS is a CLI + prompt runtime, not a SaaS product. Customer means the end user running /director komple. Admin means the maintainer publishing the pack. Public API means the programmatic ulak CLI command surface plus exported TypeScript types.

| Surface | Test type | Current state | Required for v1.0 | Gap id |
|---|---|---|---|---|
| Customer - /director komple on Claude Code | Golden eval | Goldens exist but do not parse | Golden passes, artefact chain produced | QA-001 |
| Customer - /director komple on Gemini CLI | Golden eval | Same goldens, untested on Gemini | Parity validated | QA-001 + parity runner |
| Customer - Init quickstart (macOS / Linux / Windows) | E2E smoke | Manual only | CI-automated quickstart-smoke.yml | QA-010 |
| Admin - npm publish path | prepublishOnly | Runs locally, no CI verification | CI dry-run publish | QA-003 |
| Admin - Pack versioning (v2.2.1 to v2.2.2 upgrade) | Unit test on upgrader.ts | Zero | At least 3 upgrader test cases | QA-002 |
| Admin - .gitleaks.toml + baseline discipline | Two-workflow redundant setup | Single canonical job | - | QA-008 |
| Public API - ulak run CLI | Unit + smoke | Zero | Smoke + unit on router call | QA-002 |
| Public API - ulak validate CLI | Unit | Zero | Unit + CI invocation | QA-002 |
| Public API - ulak memory search | Integration | Zero | Integration with temp SQLite | QA-002 |
| Public API - Exported TypeScript types | Typecheck | tsc runs locally, not CI | CI typecheck + API freeze check | QA-003 |
| Public surface - README.md claims | Manual | Version stale, media missing | Fresh version, one demo GIF, one screenshot | QA-005 + QA-009 |
| Public surface - Bilingual EN parity | Script promised, not written | Enforced on scoped set | - | QA-006 |
| Runtime contract - Validation schema gates | 3 of 10 wired | All 10 wired or explicitly not-applicable | - | QA-007 |

---

## Severity rollup

### Must-fix before v1.0 (P0)

| ID | Title |
|---|---|
| QA-001 | Eval harness structurally rejects every golden it ships |
| QA-002 | CLI has ~1,400 lines of TypeScript with zero tests |
| QA-003 | CI never compiles, lints, or tests TypeScript source |
| QA-005 | README.md version stale (2.0.0 vs 2.2.1) |
| QA-007 | Validation schema defines 10 gates; only 3 have real runners |

Plus QA-004 becomes P0 if the "3 vendor adapters" README claim stays unchanged.

### Should-fix before v1.0 (P1)

| ID | Title |
|---|---|
| QA-004 | Vendor-parity validator silently hides Codex absence |
| QA-006 | validation-plan references unwritten validate-bilingual-examples.sh |
| QA-009 | Missing showcase media |
| QA-010 | No quickstart-verifies-clean integration test |
| QA-011 | No link-check / broken-link-in-docs job |
| QA-012 | Eval harness never executes real director output |
| QA-015 | Release pipeline does not verify regression before tagging |

### Nice-to-have (P2)

| ID | Title |
|---|---|
| QA-008 | secret-scan.yml redundant with ci-validation.yml gitleaks job |
| QA-013 | AGENTS.md artefact-count check is brittle |
| QA-014 | No mutation or fuzz testing |

---

## Validation plan for closing this gap register

Sequential order (each step unblocks the next):

1. QA-005 + QA-008 (30 min + 15 min) - trivial hygiene wins; clears noise.
2. QA-003 (1 session) - add build/lint/test CI job. Unblocks seeing the real state of TypeScript.
3. QA-002 (3-4 sessions) - fill router + artefact-manager + adapter unit tests. Unblocks unit pass gate.
4. QA-001 (1-2 sessions) - fix bash arithmetic bugs + rewrite goldens to canonical YAML. Unblocks prompt_regression warn-pass.
5. QA-006 (1 session) - write validate-bilingual-examples.sh with scoped allowlist.
6. QA-004 decision - either ship .codex/commands/ (1-2 sessions) or tighten README + parity script (30 min).
7. QA-007 - closes cascaded by above; add 30 min schema update for not-applicable entries.
8. QA-009 + QA-010 + QA-015 + QA-011 (showcase + release gate polish) - 1 session each, parallelizable.
9. QA-012 - deferred to v1.0.1 if scope says warn-only regression.
10. QA-013 + QA-014 - roadmap for v1.1.

---

## Completion risks

1. False-green risk from QA-001 fix. If goldens are rewritten to YAML but the runner still only checks assertion-shape (not truth), we regress to false confidence. Pair with QA-012 scope decision up-front.
2. Test-drift-from-router risk for QA-002. Unit tests must be table-driven from the actual 5 goldens, not invented fixtures. Otherwise router tests pass while real user intents fail.
3. Vendor parity decision risk for QA-004. Option A (port commands) vs Option B (tighten claim) is a product-positioning call, not a QA call. Needs autonomous-program-director + product-business-strategist input.
4. Release-gate chicken-and-egg for QA-015. If the release gate runs all the broken gates, first tag after enabling will fail. Must sequence fix P0s, then add release-gate, then tag v1.0.
5. Showcase media drift (QA-009). A GIF captured today ages with every UI change in the vendor CLI. Prefer structural screenshots over session GIFs.
6. Bilingual scope creep (QA-006). Defining which docs need EN parity is a policy question. Without scope-file discipline the script becomes toothless or eternally-failing.

---

## Explicitly out of QA surface

The following items surfaced during scan but are not QA calls:

- README copy and marketing tone (product-business-strategist).
- Which commands to port to Codex (architecture-lead).
- Whether to ship a hosted demo or sandbox for v1.0 (infra-release-sre).
- Trademark and naming vs the historical "Claude Ulak" lineage (privacy-compliance-counsel).

Flagged here in case the director routes them.

---

## Evidence-first language notes

Every finding above is T1 (direct filesystem / command-exit inspection). No inference, no hearsay. Live commands reproduced:

- bash evals/run.sh produces 5 of 5 fail plus bash arithmetic errors.
- bash scripts/validate-vendor-parity.sh reports 0 MISSING because no Codex folder triggers the branch.
- bash scripts/validate-imports.sh exits 0 (works).
- bash scripts/validate-schemas.sh exits 0 with jsonschema-missing warning locally.
- wc -l src/**/*.ts reports 1,403 lines.
- find tests -name *.test.ts returns empty.
- grep Surum README.md shows line 5 says 2.0.0.
- ls .codex/ returns "No such file or directory".

---

## What this report does NOT claim

- I do NOT declare v1.0 ready or blocked. autonomous-program-director owns the final verdict.
- I do NOT rank severity against business impact. That is product-business-strategist scope.
- I do NOT assert these are the only gaps. This is the QA-surface slice. Security, architecture, compliance, release-readiness specialists should run in parallel for a full picture.
- I do NOT confirm effort estimates against capacity. Estimates are lower-bound engineering time; no meeting or review overhead included.

---

End of gap register.
