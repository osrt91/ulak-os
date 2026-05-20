# Validation Plan — Ulak OS v2.1.3

**Date**: 2026-04-18
**Run id**: director-komple-ulakos-self-audit
**Profile**: AUDIT_PROFILE (standard depth)
**Live probe required**: NO (all evidence file-local; router decision `live_probe_required: false`)

Structured per `docs/runtime/validation-result-schema.md`. Section numbering stable to allow cross-reference from roadmap items.

## §1 — Engineering gates

| Gate | Command | Target | Evidence source | Trust |
|---|---|---|---|---|
| build | `npm run build` | tsc exits 0; dist/ populated | CI artifact | T2 |
| lint | `npm run lint` | eslint exits 0 | CI artifact | T2 |
| typecheck | `tsc --noEmit` | no type errors | CI artifact | T2 |
| schema-validate (JSON) | `bash scripts/validate-schemas.sh` | exits 0 | script output | T1 |
| schema-validate ($schema conformance, after W4.15) | `bash scripts/validate-schemas.sh` (upgraded) | rejects malformed permission entries | script output | T1 |
| import-validate | `bash scripts/validate-imports.sh` | exits 0; no broken @-imports | script output | T1 |
| import-cycle-detect (after W4.14) | Same script with new `--check-cycles` flag | rejects synthetic cycle | script output | T1 |
| brand-consistency | CI workflow step | no "Claude Ulak" outside allowlist | `.github/brand-allowlist.txt` (after W4.11) | T1 |
| artefact-count | CI workflow step | AGENTS.md ≥14 reports/current/ entries | CI output | T1 |

## §2 — Test gates

| Gate | Command | Scope in v2.1.3 |
|---|---|---|
| unit | `npm test` (vitest) | applicable (existing tests) |
| integration | `npm run test:e2e` | applicable |
| contract | `not-applicable` | no external contract in v2.1.3 scope |
| visual_regression | `not-applicable` | no UI |
| accessibility | `not-applicable` | no UI |
| security_regression | gitleaks + (new) secrets-baseline check | applicable (after W4.13) |
| localization | `scripts/validate-bilingual-examples.sh` | applicable (after W5.15) |
| release_checks | see §4 | applicable |
| prompt_regression | `bash evals/run.sh` | warn-only in v2.1.3 (after W4.17); blocking in v2.2 |

## §3 — Surface checks

| Gate | Method | Scope |
|---|---|---|
| broken_links | grep + curl on all docs/ links | applicable (manual or scripted) |
| broken_routes | `not-applicable` | no web routes |
| broken_endpoints | `not-applicable` | no API |
| deep_links | `not-applicable` | — |
| store_listing_urls | `not-applicable` | — |
| @-import resolution | scripts/validate-imports.sh | applicable (blocking) |
| Vendor parity | scripts/validate-vendor-parity.sh | applicable (after W4.16; warn-only initially) |

## §4 — Release gates

| Gate | Method | Pass criteria |
|---|---|---|
| CHANGELOG single [Unreleased] block | grep -c | exactly 1 |
| package.json version matches release | grep | "version": "2.1.3" |
| No tracked settings.local.json | `git ls-files .claude/settings.local.json` | empty output |
| Settings.local.example.json present | `test -f` | exists |
| Dependabot config present | `test -f .github/dependabot.yml` | exists |
| Gitleaks baseline present | `test -f .gitleaks.baseline` | exists |
| No [Unreleased] left after tag | grep post-tag | zero matches |
| Git tag v2.1.3 | `git tag -l v2.1.3` | present |

## §5 — Documentation coherence (Ulak-specific gates)

| Gate | Check | Pass criteria |
|---|---|---|
| Phase numbering consistent | grep "Phase [678]" in active runtime docs | 0 hits |
| office-roster.md imported | grep "@docs/runtime/office-roster" in core contract | 1 match |
| plugin-skill-decision in 7-unit state | count bullets in §"Use:" | 7 |
| Persona-dispatch accurate | grep "NOT yet shipped" in persona-dispatch-pattern.md | 0 matches |
| Rule-pack starter dir populated | `ls docs/runtime/rule-packs/*.md` | ≥4 files |
| New governance docs present | `test -f` on each of: rule-pack-governance, ai-provider-allowlist, pattern-import-ledger, settings-permissions-governance, lock-file-hygiene, product-surface-split | all present |
| CLAUDE.md imports stripped | CLAUDE.md has only 3 @-imports (was 5) | 3 imports (core contract + 2 adapters) |
| Anti-patterns count | grep-count of new AP-01..09 | 9 new entries |
| Sector packs count | grep-count of new ### sections in sector-packs.md | 6 new + 1 extended |

## §6 — Live probes (read-only)

**None required in this audit run.** All evidence is file-local T1-T2. This section is present per live-probe-contract.md §6 template requirement.

If a future execution session runs destructive actions (e.g., `git rm --cached` against shared-branch remote refs), the pre-check probes would be:

- **LP-01** (candidate, Wave 1): Before `git rm --cached .claude/settings.local.json`, verify `git log --follow .claude/settings.local.json` shows the file was committed (so untrack is meaningful). Read-only. Timeout 10s.
- **LP-02** (candidate, Wave 4): Before `package.json` version bump, verify `npm outdated` doesn't show critical CVEs that would auto-fire on version bump.

No Phase 4.5 gate fires in the current run (no items require live verification).

## §7 — Post-execution probes

When v2.1.3 actually ships (after Waves 1-4 complete), the following validation runs:

- **Full `/director komple` dry-run on current tree** — does the director produce a clean verdict using the refactored Phase numbering and the new governance docs?
- **Consumer smoke test** — a fresh consumer project running `ulak intake` with v2.1.3 produces an intake.md that references at least 3 new docs (e.g., rule-pack-governance, settings-permissions, product-surface-split).
- **Rule-pack merge semantics test** — evals/golden/ test case verifies project override merges correctly.

## §8 — Residual-risk register (will attach to manager-verdict)

| ID | Description | Severity | Mitigation (Wave 6 / v2.2) |
|---|---|---|---|
| R1 | CLI source (src/) not deep-scanned | Medium | Dedicated CLI audit in v2.2 if src/ changes |
| R2 | docs/distribution/release-parity-policy.md not deep-read | Low | Address in Wave 3 cross-check or v2.2 |
| R3 | tests/ not deep-scanned | Medium | Supplementary run if prompt-pack changes break tests |
| R4 | TrendOfTrend memory claims (G-03) T3-flagged | Low | Verify in v2.2 by scanning TrendOfTrend directly |
| R5 | Supabase-specific patterns in SP-01 may over-activate | Low | Verify router.md gates via integration test |
| R6 | Mode-loading mechanism deferred to v2.2 | Medium | Honest-relabel in v2.1.3 avoids contradiction; v2.2 implements |
| R7 | Specialist agent enhancement (FIND-PG-01) may slip | Low | Phases to v2.2; not a blocker |

## Signoff criteria for v2.1.3

- [ ] All §1 engineering gates pass
- [ ] Applicable §2 test gates pass (unit, integration, security_regression, localization, release_checks)
- [ ] prompt_regression warn-only passes (not blocking)
- [ ] All §3 surface checks applicable pass
- [ ] All §4 release gates pass
- [ ] All §5 documentation coherence gates pass
- [ ] §6 live probes: not-applicable (no-op)
- [ ] §7 post-execution probes run and pass
- [ ] Residual risks §8 recorded in manager-verdict
- [ ] `signoff_status: ready` if all above checks pass
- [ ] `signoff_status: conditional` if W5 polish items remain open but W1-W4 green
- [ ] `signoff_status: blocked` if any §1-§5 gate fails or Critical finding un-mitigated

## For this audit run (analysis-only)

This is an **analysis-only** run. The validation plan above describes the gates for the FUTURE execution run that will land v2.1.3. Current run signoff is not claiming gates have run — it's delivering the plan that specifies them.

Current run validation-result.yaml (embedded in manager-verdict.md):
```yaml
validation:
  build: not-run
  lint: not-run
  typecheck: not-run
  tests:
    unit: not-run
    # ... all not-run (analysis-only mode)
  surfaces:
    broken_links: not-run
    @-import resolution: pass (via Phase 1 inventory cartographer evidence — FIND-CG-02)
  unresolved_risks: []    # this run surfaces findings; none are open critical risks
  residual_risks:         # see §8 above
    - id: R1
      severity: Medium
    - id: R2
      severity: Low
    # ... through R7
  rollback_ready: yes     # analysis-only run; nothing to roll back
  rollback_notes: "No writes performed beyond reports/current/ artefacts; rollback is `git clean -f reports/current/`."
  evidence:
    - gate: import-validate
      command: (manual Phase 1 cartographer walk + grep acyclicity check)
      output_reference: reports/current/inventory.md §15
      trust: T2
  signoff_status: conditional
  signoff_reason: |
    Audit is complete and executable plan is produced. v2.1.3 release readiness is CONDITIONAL on
    Wave 1-4 execution (analysis-only run cannot itself ship v2.1.3). See manager-verdict for
    next-action.
```
