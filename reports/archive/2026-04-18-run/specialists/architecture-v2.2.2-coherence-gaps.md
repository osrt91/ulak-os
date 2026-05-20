# Architecture — Ulak OS v2.2.1 Coherence + v1.0 Showcase Readiness

**Specialist:** architecture-lead

**Date:** 2026-04-20

**Scope:** Architectural coherence of the prompt-OS surface + release-readiness for an eventual "v1.0 showcase" public drop.

**Method:** File-level walk of import tree, vendor adapters, src/ CLI, docs/, tests/, evals/, governance/runtime layering. Evidence cited by `file:line` where meaningful. Trust tier = T1 for direct file reads of the repo under review.

---

## Executive summary (evidence-first)

Ulak OS v2.2.1 is a serious, disciplined, well-layered prompt-OS repo at the doc/runtime tier (104 markdown files under `docs/`, 79 anti-patterns, 23 sector packs, 8 rule-packs, 26 specialist agents, CI with import-cycle detection + vendor parity + secret scan). The core contract + runtime + governance triangle is coherent and enforced by scripts, not just asserted in prose.

However, a prospective **external reviewer** (new user or contributor) opening the repo today would hit six high-impact frictions, three of which are v1.0-showcase blockers:

1. **Versioning is incoherent across surfaces** — `package.json` says `2.2.1`, `src/cli/index.ts` hardcodes `2.0.0`, `README.md` says `2.0.0 (CLI Console...)`, `VERSIONING.md` stops at `2.0.0`, `docs/history/version-lineage.md` stops at `2.1.0`, CHANGELOG goes to `2.2.1`, and ROADMAP.md's "v2.1 plan" is stale (v2.1.0..2.2.1 already shipped).

2. **`tests/unit/` and `tests/e2e/` are empty** (0 files) while `package.json` ships a `"test"` script and `CONTRIBUTING.md`/ROADMAP promise a test/eval harness. For a repo that teaches "validation koşmadan done deme", shipping zero unit tests is the single biggest credibility gap.

3. **ADR directory has one ADR** (`ADR-000-pack-foundation.md`, 22 lines, "V10.3 pack") — no ADRs capture any v2.x decision (three-layer surface split, rule-pack subsystem, finding-schema, waves-pattern, trust model, vendor-adapter subprocess boundary, phase numbering change to 0..5 with 4.5 interstitial).

4. **CLI <-> contract ambition gap** — `ulak run director` pipes `/director komple` into `claude --print "..."` via `exec`, parses `# artefact-name` headers from the output, writes to disk. This is a thin integration shim, not the "runtime" the doc narrative describes. `ulak upgrade` is a **documented stub** (`src/pack/upgrader.ts:27-61`: "stub — returns success: false").

5. **No architecture diagram** — `docs/architecture/README.md` is 3 lines. 104 docs, zero diagrams. An external reviewer cannot visually grasp the phase flow, surface split, or three-vendor topology without drawing it themselves.

6. **"v1.0 showcase" vs public release line is undefined** — v1.0.0 already shipped on 2026-04-07 per `docs/history/version-lineage.md:30`. The user's "prep v1.0 showcase" intent has no place in the versioning story.

The rest (rule-pack implementation coherence, vendor parity, surface split discipline) is in reasonable shape — the repo demonstrably invests in its own rules.

---

## Evidence baseline

**Repo scale (counted):**

- `docs/**/*.md` = 104 files

- `src/**/*.ts` = 23 files (4 adapters, 8 CLI commands, 4 core, 3 memory, 3 pack, 2 infra)

- `tests/unit/*` + `tests/e2e/*` = **0 files**

- `.claude/agents/*.md` = 26 specialists + 1 director

- `.claude/commands/*.md` = 8

- `.gemini/commands/*` = 8 (7 TOML + 1 subdir TOML)

- `.codex/` = **does not exist**

- `docs/runtime/rule-packs/` = 8 rule packs

- `evals/golden/` = 5 golden examples, `evals/assertions/` = 2 files

- `docs/adr/` = 2 files (README + ADR-000)

- `docs/architecture/` = 1 file (README only)

- `CHANGELOG.md` = 672 lines, 107 H2 headers

- Git tags = v1.0.0, v2.0.0, v2.1.0, v2.1.1, v2.1.4, v2.2.0, v2.2.1 (note: no v2.1.2, no v2.1.3 — 2.1.3 appears in CHANGELOG at line 209 but was never tagged)

**CI enforcement (T1 from `.github/workflows/ci-validation.yml`):**

- `validate-imports.sh` — file existence + DFS cycle detection (good)

- `validate-schemas.sh` — JSON/TOML schema conformance

- Brand residue check — "Claude Ulak" allowlist

- `AGENTS.md` artefact-chain entry count ≥14

- version-lineage.md must contain "1.0.0 Ulak OS"

- `validate-vendor-parity.sh` — union of claude/gemini/codex commands with exemption file

- Gitleaks secret scan (baseline + config)

- Eval smoke (warn-only per design comment `evals/run.sh:9-10`)

## Findings

### ARCH-01 — Version number drift across six surfaces

- id: ARCH-01

- area: versioning

- title: Version number drift across package.json, CLI binary, README, VERSIONING, version-lineage, ROADMAP

- problem: package.json declares 2.2.1 (line 3); src/cli/index.ts:18 hardcodes .version 2.0.0; README.md:5 says Surum 2.0.0; VERSIONING.md Public release line section stops at 2.0.0; docs/history/version-lineage.md public release line stops at 2.1.0 (line 28) though CHANGELOG has 2.1.1, 2.1.3, 2.1.4, 2.2.0, 2.2.1; ROADMAP.md v2.1 Plan section at line 31 is stale (v2.1 already shipped twice over).

- evidence:

  - package.json:3 version 2.2.1

  - src/cli/index.ts:18 .version 2.0.0

  - README.md:5 Surum 2.0.0

  - VERSIONING.md:5-8 stops at 2.0.0

  - docs/history/version-lineage.md:28-30 stops at 2.1.0

  - CHANGELOG.md:3, 67, 150, 209 entries for 2.2.1, 2.2.0, 2.1.4, 2.1.3

- evidence_trust: T1

- severity: Critical

- v1_blocker: yes

- recommended_fix: Add scripts/sync-version.sh (or npm version hook) that writes the same version into package.json, src/cli/index.ts, README.md, VERSIONING.md, version-lineage.md. Add a version_consistency check to CI.

- effort: 2 hours

- validation: ulak --version returns the current package.json version.

### ARCH-02 — Empty test directories while docs claim validation discipline

- id: ARCH-02

- area: cli, production

- title: tests/unit and tests/e2e are empty while package.json ships test script

- problem: package.json:15 declares test as vitest run; tests/unit/ and tests/e2e/ exist but contain zero files. CONTRIBUTING.md and ROADMAP promise a test/eval harness. A repo whose core doctrine is never say done without validation ships with an untested TypeScript CLI. Pre-publish hook prepublishOnly runs npm run build then npm test; it will either fail or pass vacuously, the latter being worse because it silently green-washes a missing gate.

- evidence:

  - package.json:15 test vitest run

  - package.json:19 prepublishOnly npm run build and npm test

  - tests/unit is an empty directory

  - tests/e2e is an empty directory

  - src has 23 TypeScript source files and 0 .test.ts siblings

- evidence_trust: T1

- severity: Critical

- v1_blocker: yes

- recommended_fix: Add unit tests for the load-bearing parsers: src/core/artefact-manager.ts parseArtefacts, src/core/learning-extractor.ts, src/adapters/base.ts detectVendor, src/memory/store.ts schema migration, src/pack/validator.ts. Add one e2e smoke test invoking the CLI via execa in a temp fixture repo covering init then status then validate without requiring a real vendor CLI. Tighten prepublishOnly to fail when coverage is below a minimum threshold. Set vitest to error on no-test-files-found.

- effort: 1 session (8-12h) for a minimally credible suite

- validation: npm test executes at least 10 unit tests, all green, with measurable coverage; CI workflow includes a test job that fails on regressions.

### ARCH-03 — ADR directory present but empty of v2.x decisions

- id: ARCH-03

- area: adr

- title: ADR directory contains one legacy ADR; no rationale captured for any v2.x design choice

- problem: docs/adr/ has README.md (3 lines) and ADR-000-pack-foundation.md (22 lines, V10.3 era). Zero ADRs capture the three-layer surface split; rule-pack subsystem introduction; phase numbering collapse (earlier 8-phase consolidated into 6 phase plus 4.5 interstitial); finding-schema and evidence-trust-scoring adoption; trust-model firewall and prompt-supply-chain; waves-pattern for execution; subprocess-based vendor adapter boundary (not SDK, not MCP, not LSP); memory backend choice (SQLite + FTS5); reset from 1.9.1 to 1.0.0 (explained in prose only). An external contributor cannot answer why-did-you-do-it-this-way from any canonical source.

- evidence:

  - docs/adr/README.md has 3 lines

  - docs/adr/ADR-000-pack-foundation.md has 22 lines from the V10.3 era

  - docs/runtime has 38 files recording decisions in prose but not indexed as ADRs

- evidence_trust: T1

- severity: High

- v1_blocker: yes

- recommended_fix: Retrofit 8-10 core decisions as ADRs (ADR-001 through ADR-008) in MADR or Nygard format. Suggested titles: three-layer surface split; vendor adapter equals subprocess shell; phase numbering 0 to 5 plus 4.5 interstitial; rule-pack subsystem as 7th unit type; finding schema plus evidence trust scoring; waves pattern for execution; memory backend SQLite plus FTS5 in-process; artefact-chain on disk under reports/current. Add docs/adr/README.md index table with Number, Title, Status, Date. Add a CI assertion that every accepted ADR has a Status field.

- effort: 1 session (3-5h retrofit, 1h for the index)

- validation: docs/adr/README.md is a status table with 8 or more entries; each ADR has Status, Context, Decision, Consequences headers; CI check blocks merge on malformed ADRs.

### ARCH-04 — CLI binary undersells the doctrine; upgrade and export are stubs

- id: ARCH-04

- area: cli

- title: CLI implementation is a thin wrapper; claimed capabilities exceed what src/ ships

- problem: The doctrine claims runtime plus memory plus vendor adapter abstraction. Reality of src: ulak run target does exec of claude --print prompt then regex-parses hash-artefact-name headers from stdout (src/core/artefact-manager.ts:87-147). No phase enforcement, no router check, no context-budget respect, no artefact-write-authorization propagation. The vendor CLI does all the work; src is a shell. ulak upgrade is a documented stub (src/pack/upgrader.ts:27-41 returns available false; line 50-61 always returns success false). The artefact chain constant in src/core/artefact-manager.ts:4-17 lists 12 artefacts but DOES NOT match the canonical list in CLAUDE.md and the core contract (missing deep-scan-report, did-you-know, live-probe-results, specialists per-role, validation-result.yaml). Code drift vs doctrine. The subprocess boundary escapes with a naive regex quote-escape which breaks on Windows cmd.exe quoting and any prompt containing backticks or shell-meta (src/adapters/claude.ts:42, codex.ts:71, gemini.ts:39).

- evidence:

  - src/cli/index.ts:18 version hardcoded 2.0.0 (matches ARCH-01)

  - src/cli/commands/run.ts:48-54 prompt construction is minimal

  - src/core/artefact-manager.ts:4-17 ARTEFACT_CHAIN has 12 entries, missing 4 or more canonical

  - src/pack/upgrader.ts:27-41 and 50-61 stub implementation

  - src/adapters/claude.ts:42 naive shell-escape

- evidence_trust: T1

- severity: High

- v1_blocker: partial; stubs must either be implemented or removed from README

- recommended_fix: Decide and document the CLI role explicitly. OPTION A: ulak CLI is a thin orchestrator that triggers vendor CLIs; deep logic lives in the loaded prompt pack; update README and package.json description; mark upgrade and export as roadmap items clearly. OPTION B: invest 2-3 sessions to make ulak run director phase-aware (parse router decision, enforce phase gates, pin context budget, dispatch specialists); high ambition, not v1.0-feasible. Align ARTEFACT_CHAIN with the canonical contract or import from a single SSOT. Replace naive quote escaping with execFile plus argv array (no shell parsing). Either implement upgrade (npm registry check plus diff plus apply) or remove it from the CLI surface and mark in ROADMAP.

- effort: 1-2 sessions (8-16h) depending on OPTION A vs B

- validation: ulak upgrade --help either works or says not implemented see ROADMAP; ARTEFACT_CHAIN parity between src and docs; prompt containing quotes, backticks, Unicode, newlines round-trips correctly.

### ARCH-05 — No architecture diagrams

- id: ARCH-05
- area: docs
- title: Zero architecture / flow / phase diagrams in a repo with 104 markdown docs
- problem: docs/architecture/README.md is 3 lines. No Mermaid diagram, no SVG, no ASCII flow. Core mental models (phase flow 0 to 5 with gate criteria; import tree from CLAUDE.md; three-vendor topology; surface split; artefact chain timeline; specialist dispatch fan-out) are narrated in prose but never shown. A reader must reconstruct the model mentally to follow any run.
- evidence:
  - docs/architecture/README.md has 3 lines
  - grep for mermaid fenced blocks across docs returns few or no hits
- evidence_trust: T1
- severity: High
- v1_blocker: yes
- recommended_fix: Add 5 Mermaid diagrams inline in markdown. Files: phase-flow.md; import-tree.md; three-vendor-topology.md; surface-split-diagram.md; artefact-chain-timeline.md. Link them from README Repo Contents section.
- effort: 4-6 hours (1 session)
- validation: A reader can answer what is Phase 4.5 by looking at one diagram; README links to at least 3 of the 5 diagrams.

### ARCH-06 — v1.0 showcase vs actual 2.x line has no defined relationship

- id: ARCH-06
- area: versioning
- title: User v1.0 showcase goal has no defined relationship to the live 2.x line
- problem: v1.0.0 already shipped 2026-04-07 (docs/history/version-lineage.md:30) as Ulak OS First Stable Public Release. The user now wants to eventually prep v1.0 showcase. Four possible interpretations exist and none is documented: (a) retroactive rebrand calling 2.2.x the real v1.0 (semver regression; avoid); (b) v1.0-showcase as a tag or branch snapshot of 2.x with docs polish; (c) v3.0 polish pass; (d) separate ulak-os-showcase repo. Without a decision, test-coverage and diagram and doc polish work has no target version.
- evidence:
  - docs/history/version-lineage.md:30 1.0.0 Ulak OS First Stable Public Release 2026-04-07
  - package.json:3 version 2.2.1
  - VERSIONING.md:47-50 rules
- evidence_trust: T1
- severity: High
- v1_blocker: yes (conceptually)
- recommended_fix: Write docs/release/v1.0-showcase-contract.md defining what v1.0 showcase IS (a polished public cutoff of 2.x, not a new version); candidate version number; gate criteria; relationship to semver; rollout plan. Then amend VERSIONING.md and version-lineage.md to reference that doc.
- effort: 2-4 hours for the contract
- validation: docs/release/v1.0-showcase-contract.md exists with a defined what-it-IS statement; VERSIONING.md links to it.

### ARCH-07 — Core contract filename is a version lie

- id: ARCH-07
- area: import-tree
- title: Core contract filename frozen at 2.0.0 while runtime has moved to 2.2.x
- problem: Every adapter entry file imports prompts/core/ulak-os-core-contract-2.0.0.md (CLAUDE.md:3, GEMINI.md:3, AGENTS.md:11). The filename says 2.0.0. The repo is actually at 2.2.1. A reader searching for the latest core contract will reasonably look for a non-existent 2.2 file.
- evidence:
  - CLAUDE.md:3 import line
  - AGENTS.md:11 reading-order reference
  - GEMINI.md:3 import line
- evidence_trust: T1
- severity: Medium
- v1_blocker: no
- recommended_fix: OPTION A (preferred): rename to ulak-os-core-contract.md (no version suffix); update all three adapter imports; write version inside file header; CI check keeps header in sync with package.json. OPTION B: bump the filename suffix with each release plus maintain a stable -latest redirect.
- effort: 30 minutes plus rebuild of imports
- validation: scripts/validate-imports.sh passes; in-file header version matches package.json.

### ARCH-08 — README.md tells the wrong version story

- id: ARCH-08
- area: docs
- title: README declares v2.0.0 as current and says v2.1+ is planned
- problem: README.md:5 says Surum 2.0.0. README.md:134 says v2.1+ planlaniyor covering FR, DE, ES, AR, JA, ZH; v2.1 shipped 9 days ago. An external user lands on the repo and concludes this is stale or low-activity. It is actually the opposite: 4 releases in 3 days.
- evidence:
  - README.md:5 Surum 2.0.0
  - README.md:131-134 multi-language section citing v2.1+ planlaniyor
  - CHANGELOG.md:3 entry for 2.2.1 on 2026-04-20
- evidence_trust: T1
- severity: High
- v1_blocker: yes
- recommended_fix: Replace hardcoded version line with a shields.io badge sourced from package.json. Replace v2.1+ list with v2.2.1 status plus links. Move the language-roadmap into ROADMAP.md. Add a What-is-new-in-2.2.1 callout. Add an animated GIF or asciinema showing init then run director then cat manager-verdict.md.
- effort: 3-4 hours
- validation: README shows current version via badge; v2.1 planlaniyor language is gone; new user can skim to what-it-does in under 30 seconds.

### ARCH-09 — docs/examples has 5 sample artefacts but README does not reference them

- id: ARCH-09
- area: docs
- title: Example artefacts exist but are not promoted on the golden path
- problem: docs/examples/ ships sample-intake, sample-inventory, sample-manager-verdict plus .en.md pairs and sample-validation-plan. These are the best see-the-system-actually-work evidence a new user could want. README.md:118-126 mentions but never links directly.
- evidence:
  - docs/examples/ has 7 files (3 sample artefact pairs plus validation plan)
  - README.md:118-126 mentions but does not link
- evidence_trust: T1
- severity: Medium
- v1_blocker: no
- recommended_fix: Add a What-a-real-run-produces section in README with inline links to each sample. Add a Preview-the-output bullet above the quickstart. Consider adding a reports/sample-run-2.2.1/ directory with a full chain. Empty top-level examples/ dir: either populate or delete.
- effort: 2 hours
- validation: README links to 3 or more sample artefacts; no dead empty dirs.

### ARCH-10 — Vendor parity: Codex is asymmetric

- id: ARCH-10
- area: vendor-parity
- title: Codex surface is second-class; no commands directory, adapter silently falls back to copilot
- problem: .claude/commands has 8 files; .gemini/commands has 8 files; no .codex/commands/ directory exists. Codex users get only AGENTS.md plus docs/adapters/codex-cli.md (reading-order prose, not commands). validate-vendor-parity.sh:98-104 skips codex unless .codex/commands/ exists, so CI passes with codex having zero commands. src/adapters/codex.ts:20-31 tries codex --version then falls back to copilot --version without telling the user which.
- evidence:
  - .codex directory does not exist
  - .claude/commands has 8 .md files
  - .gemini/commands has 8 TOML files
  - scripts/validate-vendor-parity.sh:98-104 skip-codex-if-no-dir
  - src/adapters/codex.ts:20-31 silent fallback
- evidence_trust: T1
- severity: Medium
- v1_blocker: conditional
- recommended_fix: PATH A (commit to parity): add .codex/commands/*.md with the same 8 commands; surface which binary was resolved in CLI output; remove the skip in validate-vendor-parity.sh. PATH B (downgrade honestly): update README to say Claude plus Gemini first-class; Codex and Copilot secondary; label support level.
- effort: 1 session for Path A; 1 hour for Path B
- validation: either .codex/commands/ exists, or README labels codex support level.

### ARCH-11 — Rule-pack project-local override is spec'd but unproven

- id: ARCH-11
- area: import-tree
- title: Rule-pack selective-merge override mechanism is specified but not demonstrated
- problem: Rule-pack pipeline is well-declared (docs/governance/rule-pack-governance.md 63 lines; 8 Ulak packs under docs/runtime/rule-packs/; loader protocol in director agent; RULE_PACKS_LOADED field in active-variable-contract; toolchain-precheck driver). However the project-local override path (.claude/rules/stack.md selective-merge) has no actual example .claude/rules/ directory; no assertion in evals that tests the merge rule; no mention in any golden example; redefine-by-intent-not-exact-wording is a semantic merge the loader cannot do mechanically. Declared but unimplemented gap.
- evidence:
  - docs/governance/rule-pack-governance.md:19-30 spec
  - docs/runtime/rule-packs/ = 8 Ulak packs
  - .claude/rules/ does not exist
  - evals/golden/*.md have no rule-pack merge assertion
- evidence_trust: T2
- severity: Medium
- v1_blocker: no
- recommended_fix: Add a golden example (evals/golden/06_rule_pack_override.md) that ships a fixture .claude/rules/typescript.md, asserts the merged rule-set in a Phase 0 manifest, verifies Ulak pack imperatives NOT touched are still active. Document the merge as LLM-interpreted (not mechanical) with examples OR reduce the contract to a simpler mechanical rule (bullet-line-exact override) a script could verify.
- effort: 3-4 hours
- validation: One golden example covers the override mechanic; documentation is explicit about mechanical vs LLM-interpreted merge.

### ARCH-12 — Error handling in scripts/ lacks i18n discipline

- id: ARCH-12
- area: production
- title: Shell scripts and CLI emit Turkish + English mixed error messages without locale discipline
- problem: validate-imports.sh emits English; validate-vendor-parity.sh emits English only; CLI commands emit Turkish (src/cli/commands/run.ts:22, 30, 36 -> ulak.config.json bulunamadi, Vendor tespit edilemedi, CLI kurulu degil). The repo has a localization-strategy.md doctrine but does not apply it to its OWN user-facing tooling. For v1.0 showcase aimed at an international audience, all user-facing CLI/script output should at minimum be English, with optional TR mode via LANG/LC_MESSAGES.
- evidence:
  - src/cli/commands/run.ts:22 ulak.config.json bulunamadi
  - src/cli/commands/status.ts:17 similar pattern
  - scripts/validate-*.sh English only
  - docs/runtime/localization-strategy.md doctrine exists
- evidence_trust: T1
- severity: Medium
- v1_blocker: no (unless international audience is a v1.0 goal)
- recommended_fix: Pick default English-first for CLI; TR as opt-in via ULAK_LANG=tr. Centralize strings in src/cli/i18n.ts (tr.json, en.json). Lint rule forbidding inline non-ASCII user-facing strings outside i18n files. Unify shell-script messages (English baseline). Document the choice in localization-strategy.md section Ulak-self-application.
- effort: 1 session (5-8h)
- validation: ULAK_LANG=en ulak status emits English; ULAK_LANG=tr ulak status emits Turkish; default is a documented choice.

### ARCH-13 — No CODEOWNERS, no issue templates, no PR template

- id: ARCH-13
- area: production
- title: GitHub community infrastructure is thin
- problem: ROADMAP.md:99-101 calls out CODEOWNERS plus issue/PR templates plus GitHub Discussions plus CONTRIBUTING expansion plus code of conduct as v2.1 plan items. None appear to be present. CONTRIBUTING.md exists at repo root but is only 762 bytes. For a v1.0 showcase drop, an external contributor first question (how do I open an issue, what should I include) has no template answer.
- evidence:
  - .github/ has workflows, brand-allowlist, vendor-parity-exemptions (no ISSUE_TEMPLATE, PULL_REQUEST_TEMPLATE, CODEOWNERS)
  - CONTRIBUTING.md = 762 bytes
  - ROADMAP.md:99-101 flags as distribution/community item
- evidence_trust: T1
- severity: Medium
- v1_blocker: no (recommended for showcase)
- recommended_fix: Add (in order of impact) ISSUE_TEMPLATE/bug_report.yml, ISSUE_TEMPLATE/feature_request.yml, PULL_REQUEST_TEMPLATE.md, CODEOWNERS, CODE_OF_CONDUCT.md (Contributor Covenant 2.1), SECURITY.md, CONTRIBUTING.md expansion (doc-only PRs vs code PRs, artefact-write etiquette, how to test vendor-parity locally).
- effort: 2-3 hours for all seven
- validation: GitHub Community Standards shows green across all items; opening an issue offers a template.

### ARCH-14 — CHANGELOG is monolithic

- id: ARCH-14
- area: docs
- title: CHANGELOG.md has become a 672-line wall; per-release discovery is hard
- problem: CHANGELOG.md has 107 H2 entries in one file. v2.1.3 section at line 209 is paired with two Unreleased headers at 338 and 419 (a smell). Git tags skip v2.1.2 and v2.1.3 (tags go 2.1.0 to 2.1.1 to 2.1.4), so CHANGELOG and git-release ordering drifted. For a public-showcase audience this file is hostile.
- evidence:
  - wc -l CHANGELOG.md = 672
  - grep count of H2 = 107
  - Tags = v1.0.0, v2.0.0, v2.1.0, v2.1.1, v2.1.4, v2.2.0, v2.2.1 (no 2.1.2, 2.1.3)
  - CHANGELOG lines 338, 419 = two Unreleased headers
  - CHANGELOG line 209 = 2.1.3 never tagged
- evidence_trust: T1
- severity: Low
- v1_blocker: no
- recommended_fix: Split the changelog. CHANGELOG.md = current plus last 3 releases. Archive older series in docs/history/changelog-archive/. Tag v2.1.3 retroactively or mark as CHANGELOG-only. Collapse duplicate Unreleased entries. Adopt keep-a-changelog strictly; CI-enforce section structure.
- effort: 2 hours
- validation: CHANGELOG.md under 200 lines; no duplicate Unreleased headers.

### ARCH-15 — Memory migration is a bare SQL file with no runner

- id: ARCH-15
- area: cli
- title: SQLite memory schema inlined in store.ts; migrations dir has one file but no runner
- problem: src/memory/store.ts:4-47 defines schema inline as MIGRATION_SQL executed on every open. src/memory/migrations/001-initial.sql exists but no runner applies them in order or tracks which have been applied. Any schema change will break existing memory.db files silently or require hand-written migration the product has no framework for.
- evidence:
  - src/memory/store.ts:4-47 inline schema
  - src/memory/migrations/001-initial.sql exists
  - no migrations runner code in src
- evidence_trust: T1
- severity: Low
- v1_blocker: no
- recommended_fix: Move schema to SQL files; add applied-migrations table; apply in order on open; log failures; document in docs/architecture/memory-backend.md.
- effort: 3 hours
- validation: A simulated v2 schema bump applies cleanly on a pre-existing memory.db; unit test covers the migration path.

### ARCH-16 — 26 specialists; dispatch default 6; no core-vs-overlay matrix

- id: ARCH-16
- area: import-tree
- title: Specialist count (26) vs dispatch default (6) relationship is undocumented
- problem: .claude/agents/ has 26 specialist files plus 1 director. Default parallel dispatch is 6 (parallel_dispatch keyword clamp [1,15]). No table says for an AUDIT_PROFILE project these 6 are canonical and these 20 are overlays. A new user cannot predict which specialists will run.
- evidence:
  - .claude/agents = 26 specialists plus autonomous-program-director
  - director agent documents parallel_dispatch default 6
  - docs/runtime/office-roster.md exists (not audited this pass; residual risk)
- evidence_trust: T2
- severity: Low
- v1_blocker: no
- recommended_fix: Audit office-roster.md. Add a Specialist activation by output profile table (rows = 26 specialists; cols = 7 output profiles; cell = default/conditional/off). Reference it from the director agent. Ship a ulak dispatch --preview command printing which specialists would run given a router decision.
- effort: 3 hours
- validation: office-roster.md has a per-profile activation matrix; a new user can answer which specialists will run without running.

### ARCH-17 — docs/adapters is thin compared to docs/governance

- id: ARCH-17
- area: vendor-parity, docs
- title: Governance layer deep (22 docs); adapter docs thin (4 vendor docs, each under 50 lines)
- problem: docs/governance has 22 policy docs; docs/adapters has 4. claude 46 lines; gemini 47; codex 45; universal 34. Given the repo is vendor-neutral and the three-vendor pitch is central, adapter docs should be the same depth as governance docs. A future adapter contributor has no how-to-add-a-vendor guide.
- evidence:
  - docs/governance = 22 .md
  - docs/adapters = 4 .md
  - claude-code.md 46 lines; codex-cli.md 45; gemini-cli.md 47; universal-runtime-contract.md 34
- evidence_trust: T1
- severity: Low
- v1_blocker: no
- recommended_fix: Add docs/adapters/adding-a-new-vendor.md (contract; hooks; CI parity rules; manifest location). Expand each existing adapter doc with known quirks, pitfalls, validation checks, unsupported features plus workarounds. Link from src/adapters/base.ts comments.
- effort: 3-4 hours
- validation: A contributor can add a new adapter class by reading one doc.

### ARCH-18 — dist/ committed

- id: ARCH-18
- area: production
- title: dist/ appears committed while the project has TypeScript plus tsc build
- problem: Root shows dist/ with subdirectories mirroring src. package.json bin points to ./dist/cli/index.js and prepublishOnly runs build plus test. Committing dist/ doubles PR diffs and risks src/dist drift. (.gitignore was not deeply audited; if dist/ is gitignored and local dir is build artifact, this drops to Low.)
- evidence:
  - ls root shows dist/
  - package.json:6-7 bin ./dist/cli/index.js
  - package.json:19 prepublishOnly npm run build plus npm test
  - .gitignore = 526 bytes (short; needs audit)
- evidence_trust: T2
- severity: Low
- v1_blocker: no
- recommended_fix: Verify .gitignore includes /dist/. Add if missing plus git rm -r --cached dist/. Add a files array to package.json. Document build plus publish flow in CONTRIBUTING.md.
- effort: 30 minutes
- validation: git ls-files dist/ returns 0.

### ARCH-19 — Gemini /director TOML diverges from Claude /director argument protocol

- id: ARCH-19
- area: vendor-parity
- title: Gemini /director omits the keyword-argument protocol that Claude /director supports
- problem: .claude/commands/director.md documents a rich argument grammar at lines 62-93 (mode= entry= skip_phase_1= skip_phase_2= parallel_dispatch= dispatch= validation_depth= profile=) plus a resume-form example. .gemini/commands/director.toml (22 lines) has ONLY {{args}} substitution and no equivalent grammar doc. A user running /director komple mode=RESCUE skip_phase_1=true on Gemini will get different behavior than on Claude. The parity script only checks name existence, not behavior.
- evidence:
  - .claude/commands/director.md:62-93 (32 lines of argument grammar)
  - .gemini/commands/director.toml:1-22 ({{args}} substitution only)
  - scripts/validate-vendor-parity.sh:74-107 checks name parity, not content parity
- evidence_trust: T1
- severity: Medium
- v1_blocker: no (but will surface as a support issue)
- recommended_fix: Expand .gemini/commands/director.toml to document the same keyword args inline. Extend validate-vendor-parity.sh to check for structural equivalence markers. Consider generating Gemini TOMLs from Claude .md via a transformer.
- effort: 3 hours
- validation: Gemini /director supports the same 8 keyword args.

### ARCH-20 — src/cli/commands/export.ts depth unreviewed (residual risk)

- id: ARCH-20
- area: cli
- title: export command registered but implementation depth not inspected this pass
- problem: The CLI registers an export subcommand (src/cli/index.ts:11, 27). Its implementation depth (stub vs real) was not reviewed here. If it is another stub like upgrade, ARCH-04 effort grows.
- evidence:
  - src/cli/index.ts:11 import
  - src/cli/index.ts:27 registerExport call
  - src/cli/commands/export.ts (not read this pass)
- evidence_trust: T3
- severity: Low
- v1_blocker: no
- recommended_fix: 15-minute read of export.ts; if real, fine; if stub, fold into ARCH-04.
- effort: 15 minutes audit plus variable fix
- validation: Export command is documented or marked roadmap.

---

## Architecture verdict — is the surface coherent?

### What is coherent (strong)

1. Core contract to runtime to governance import tree is clean and enforced by a cycle-detecting validator (scripts/validate-imports.sh). No circular deps detected; file-existence passes.
2. Surface split (public runtime / hidden core / maintainer) is well-specified in docs/governance/surface-split.md and visibly applied: history in docs/history/, archives in docs/archive/, maintainer tooling in .github/ and scripts/.
3. Finding schema plus evidence-trust scoring are live; every agent file (including this one) conforms.
4. Phase progression is deliberate; six phases plus one conditional interstitial, documented in docs/runtime/program-phases.md, with Phase 5 explicitly marked terminal to prevent phase-count drift.
5. Vendor-parity CI is a real gate, not decorative; it mechanically inspects .claude/commands vs .gemini/commands and enforces exemptions.
6. The prompt-OS layer (agents + commands + rule-packs + sector-packs + anti-patterns) is genuinely ambitious and internally consistent: 26 specialists with persona-dispatch + specialist-dispatch modes, 79 anti-patterns, 23 sector packs, 8 rule-packs, all with live cross-references.

### What is incoherent (weak)

1. Version drift in six places (ARCH-01, ARCH-07, ARCH-08). The repo teaches version discipline to target projects and fails it itself.
2. The TypeScript CLI layer and the prompt-OS layer are at different ambition tiers. The CLI is a subprocess shim with stubs; the prompt-OS is research-grade. README blurs them.
3. ADRs are empty. For a repo whose whole thesis is evidence and rationale over assertions, lacking ADRs for its own architecture is self-contradicting.
4. No diagrams. 104 docs, 0 visual aids; inefficient for reviewer onboarding.
5. Tests are empty. prepublishOnly runs a test command that likely passes vacuously.
6. v1.0 showcase concept is undefined vs existing 1.0.0 plus 2.2.1.

### What is honest about this state

The repo is 3 days old from a burst of release work (tags span 3 days). It is the output of an intensive solo push. What is there is denser than most OSS projects at any age. The gaps are exactly the gaps of a built-fast-by-one-person repo approaching a present-to-strangers threshold: version sync, tests, diagrams, ADRs, community infra. None of the gaps are architecturally deep; they are polish plus validation plus narrative work.

---

## Target architecture (for v1.0 showcase)

### Guiding principle
Do NOT rewrite. The architecture is sound. Fix the coherence seams, close the claim-vs-reality gaps, and improve the on-ramp. Invest effort on the outside of the system (narrative, tests, diagrams, version discipline), not on the inside (rules, agents, phases are fine).

### Target state (after the v1.0 showcase work)

Directory shape at the target version (v2.3.0 or tagged v1.0-showcase on 2.x):

- package.json version synced across all surfaces
- src/cli/index.ts version synced
- README.md with version badge, 60-second demo gif, golden-path links
- tests/unit with 20+ tests covering parsers, adapters, memory, pack
- tests/e2e with 3+ smoke tests for init/status/validate flows
- docs/architecture with 5 Mermaid diagrams
- docs/adr with 8+ ADRs covering v2.x decisions
- docs/release/v1.0-showcase-contract.md defining what showcase IS
- .github/ISSUE_TEMPLATE (bug plus feature)
- .github/PULL_REQUEST_TEMPLATE.md
- .github/CODEOWNERS
- .github/SECURITY.md
- .github/workflows/ci-validation.yml plus version-consistency plus test job
- CODE_OF_CONDUCT.md
- CHANGELOG.md under 200 lines (older releases archived)
- .codex/commands (if Path A chosen in ARCH-10)
- prompts/core/ulak-os-core-contract.md version-less filename, in-file version

### Architecture continuity (unchanged)
- Three-layer surface split (public runtime / hidden core / maintainer)
- Core contract plus @import chain with cycle detection
- Phase 0..5 with 4.5 interstitial
- Artefact chain on disk under reports/current/
- Rule-pack plus sector-pack plus anti-pattern triple
- Evidence trust plus finding schema plus output profiles
- Subprocess-based vendor adapter boundary (harden escape plus argv array)

### Architecture simplification
- Drop empty directories (examples/ at repo root if not populated)
- Consolidate CHANGELOG into current plus archive
- Drop unused or stubbed CLI commands from the user-facing surface (move to coming-soon list)

---

## Migration guidance (no big-bang; sequenced Waves)

Strangler-fig, as docs/runtime/strangler-fig-protocol.md teaches. Three Waves, each independently shippable.

### Wave 1 — Coherence patch (target: v2.2.2, 1-2 sessions)

Theme: stop the bleeding on version drift and empty-test-dir credibility gap.

- Sync all version surfaces via script plus CI gate (ARCH-01, 2h)
- Add initial unit tests for core parsers and adapters (ARCH-02, 1 session)
- Rename core contract file to version-less plus update imports (ARCH-07, 30m)
- Update README version line plus stale v2.1+ planlaniyor text (ARCH-08, 2h)
- Add .github community templates (ARCH-13, 2-3h)
- Verify and gitignore dist/ if needed (ARCH-18, 30m)
- Read and decide on src/cli/commands/export.ts (ARCH-20, 15m plus fix)
- Audit brand-allowlist plus vendor-parity-exemptions currency (30m)

Wave 1 validation gate:
- ulak --version matches package.json
- npm test runs 10+ assertions all green
- README Surum line pulls from a single source
- GitHub Community Standards shows green

### Wave 2 — Narrative patch (target: v2.2.3 or v2.3.0, 2-3 sessions)

Theme: a stranger can understand the repo in 2 minutes.

- Add 5 Mermaid architecture diagrams (ARCH-05, 1 session)
- Write 8 ADRs for v2.x decisions (ARCH-03, 1 session)
- Promote docs/examples from README plus add sample-run report chain (ARCH-09, 2h)
- Split CHANGELOG into current plus archive (ARCH-14, 2h)
- Expand docs/adapters with adding-a-new-vendor plus per-adapter pitfalls (ARCH-17, 3-4h)
- Add specialist-by-profile activation matrix to office-roster.md (ARCH-16, 3h)

Wave 2 validation gate:
- New-user can reach I-understand-the-phase-flow inside README plus 1 diagram click
- Every ADR has Status / Context / Decision / Consequences and is indexed

### Wave 3 — Showcase cut (target: v2.4.0 OR a v1.0-showcase tag on v2.3.x, 1-2 sessions)

Theme: define and land the v1.0 showcase artefact.

- Write docs/release/v1.0-showcase-contract.md defining what it IS (ARCH-06, 2-4h)
- Decide Codex parity direction (Path A or B) plus execute (ARCH-10, 1 session OR 1h)
- Golden example for rule-pack merge plus document semantics (ARCH-11, 3-4h)
- i18n the CLI (English default, TR opt-in) plus unify shell scripts (ARCH-12, 1 session)
- Gemini /director keyword-arg parity (ARCH-19, 3h)
- Memory migration runner plus ADR-007 companion (ARCH-15, 3h)
- Decide CLI ambition (ARCH-04 OPTION A or B), finish or downgrade (1-2 sessions)
- Polish README with demo GIF plus golden-path section (ARCH-08 continued, 2h)
- Create the showcase release plus GitHub release assets (2h)

Wave 3 validation gate:
- A v1.0-showcase tag (or v2.3.0 release) exists with CI all green, test coverage at threshold, zero version drift, diagrams plus ADRs present, README reads like a v1.0 introduction
- External reviewer test: ask someone outside the project to skim for 10 minutes; they must answer what-does-this-do, how-do-I-try-it, why-this-architecture from README plus docs alone.

### What NOT to do

1. Do not merge the CLI and prompt-OS ambitions prematurely. They are two products inside one repo.
2. Do not rebrand. v1.0 showcase is a presentation layer; do not retroactively rename 2.x.
3. Do not ship a showcase without tests.
4. Do not invent new runtime rules during the showcase cut. Freeze features; polish what exists.
5. Do not over-translate the CLI. Pick one default language for showcase (English recommended), put TR behind a flag.

---

## Five most important v1.0 blockers

1. ARCH-01 — Version drift across package.json / CLI / README / VERSIONING / lineage (Critical, 2h). Zero-cost credibility kill; must be fixed before any showcase push.
2. ARCH-02 — Empty test directories while doctrine says validation discipline (Critical, 1 session). The foundation of doctrine credibility.
3. ARCH-03 — ADR directory effectively empty (High, 1 session). A rationale-heavy repo without rationale records is a self-contradiction reviewers will notice immediately.
4. ARCH-05 — No architecture / phase / topology diagrams (High, 1 session). 104 docs plus 0 diagrams equals unreviewable surface for a drive-by.
5. ARCH-06 — v1.0 showcase vs actual 1.0.0 plus 2.2.1 lines is undefined (High, 2-4h). Cannot sensibly prep the showcase without a contract that says what it IS.

## Five would-be-nice-but-not-blockers

1. ARCH-04 — CLI is a thin shim with stubs; ambition mismatch with doctrine (High). Can be resolved by honest README scoping instead of engineering. Investing here would level up the product.
2. ARCH-08 — README version plus currency signal is broken (High; linked to ARCH-01). Fix alongside version-sync.
3. ARCH-13 — No GitHub community infrastructure (Medium, 2-3h). Easy win for a showcase audience.
4. ARCH-10 — Codex is a second-class vendor (Medium). Honest scope statement in README is cheaper than full parity; either works.
5. ARCH-11 — Rule-pack project-local override spec but unproven (Medium). A golden example closes the gap; not a blocker.

---

## Honest opinion — what would an external reviewer say about v2.2.1 today?

A technical reviewer (senior engineer, prospective contributor) opening the repo in the current state would likely react in three stages.

### Stage 1 — first 60 seconds (README plus repo tree scan)

Claim: Vendor-neutral prompt OS for Claude / Codex / Gemini. Version says 2.0.0. Last commit is today. tests/ folders empty. dist/ committed. ADR dir empty. CHANGELOG 672 lines. Is this stale? Or hyperactive? Cannot tell.

Net impression: conflicting signals; cautious interest or bounce.

### Stage 2 — next 5 minutes (poking into docs/)

Oh. These runtime docs are serious. Phase discipline, evidence trust tiers, finding schema, surface split. Rule-pack governance is thoughtful. 26 specialists with persona/specialist dual-dispatch. Anti-patterns are nontrivial and cited. This is not vaporware. But why does the README sell v2.0.0 when CHANGELOG is v2.2.1?

Net impression: real substance under the surface; respect, confusion about packaging.

### Stage 3 — next 15 minutes (trying to use or contribute)

Ran ulak --version 2.0.0. Ran ulak init fine. Ran ulak run director on a test repo; it just shells out to claude --print. So the product is the docs plus the CLI is the orchestrator? Okay. Looked for tests; empty. Looked for ADRs to see why reports/current/ was chosen over stdout streaming; empty. Looked for diagrams to understand Phase 4.5; none. Ran npm test; vacuously green.

Net impression: the doctrine is mature, the engineering seams are not. Solo-built, ambitious, needs the from-one-author-to-the-world polish pass.

### Summary conclusion

The biggest single unlock for external perception is NOT adding more features. It is:

1. Sync the version everywhere.
2. Put diagrams on the doctrine.
3. Put tests on the CLI.
4. Put ADRs on the decisions.
5. Tell a clear story about the v1.0 showcase cut.

These five moves, in 4-6 focused sessions, would take the repo from impressive-but-hard-to-evaluate to impressive-and-evidently-ready.

---

## Residual risk / evidence I did NOT verify in this pass

- src/cli/commands/export.ts depth (ARCH-20 residual)
- docs/runtime/office-roster.md per-profile specialist matrix (ARCH-16 depends)
- docs/superpowers plus docs/skills-integration coherence
- .mcp.json current state vs MCP governance rules
- .gitignore actual contents (ARCH-18 probability depends)
- Whether evals/golden assertion set catches rule-pack override behavior
- docs/governance/prompt-supply-chain.md enforcement in practice
- Hook governance file presence plus active hooks under .claude/hooks/
- Whether validate-schemas.sh runs deep JSON-schema validation or surface checks

These are worth-an-hour-each follow-ups, not v1.0 blockers.

---

## Classification of findings

| Severity | Count | IDs |
|---|---|---|
| Critical | 2 | ARCH-01, ARCH-02 |
| High | 5 | ARCH-03, ARCH-04, ARCH-05, ARCH-06, ARCH-08 |
| Medium | 7 | ARCH-07, ARCH-09, ARCH-10, ARCH-11, ARCH-12, ARCH-13, ARCH-19 |
| Low | 6 | ARCH-14, ARCH-15, ARCH-16, ARCH-17, ARCH-18, ARCH-20 |

Total: 20 findings across 7 evidence areas (import-tree, vendor-parity, cli, docs, versioning, adr, production).

Evidence trust distribution: T1 = 16; T2 = 3 (ARCH-11, ARCH-16, ARCH-18); T3 = 1 (ARCH-20).

---

architecture-lead specialist artefact complete. The autonomous-program-director owns the final verdict. This document identifies architectural and release-readiness gaps; it does not claim they are the only gaps, and it does not declare the repo ready or not ready for v1.0 showcase — that is the director decision after synthesis.
