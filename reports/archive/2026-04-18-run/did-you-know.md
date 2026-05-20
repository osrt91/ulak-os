# Did-You-Know — Non-obvious findings on Ulak OS

**Date**: 2026-04-18
**Run id**: director-komple-ulakos-self-audit

This is the MANDATORY Phase 3 surprise layer. Items below are non-obvious: they are NOT flagged in the ajanscan-pattern-extraction.md (39 patterns) AND NOT captured by the 8 specialists in the Phase 2 evidence-register. They were surfaced by the director's cross-cutting read of the repo after the specialist evidence was merged.

All items follow `docs/governance/finding-schema.md` with the `surprise: true` tag.

---

## DY-01 — `scripts/validate-imports.sh` only checks existence, not acyclicity

```yaml
id: DY-01
area: prompt
surprise: true
title: "@import validator verifies file presence but NOT absence of cycles"
problem: |
  `scripts/validate-imports.sh:12-27` walks every .md file, extracts `^@(.+\.md)$` lines, and verifies the
  target exists. It does NOT build a directed graph and does NOT check for cycles. If someone introduces
  `docs/runtime/router.md` → `@docs/runtime/program-phases.md` → `@docs/runtime/router.md`, the validator
  passes but the runtime could loop (depending on how Claude Code resolves repeated @-imports — potentially
  infinite context expansion or just first-hit).
evidence: "scripts/validate-imports.sh:12-27 (grep logic + existence check, no graph construction)"
evidence_source: "Direct read of the script"
evidence_trust: T1
completeness_risk: low
contradiction_status: none
impact: |
  Low today because no cycles exist (FIND-CG-02 confirmed). But this is a latent CI gap. A future
  refactor that moves content across runtime docs could introduce a cycle and ship.
severity: Low
priority: P2
recommended_fix: |
  Extend validate-imports.sh to build a graph (bash associative arrays, or rewrite in Python) and detect
  strongly-connected components of size >1. Fail on any cycle. Also emit a dot-file on success for
  documentation.
validation: "Inject a synthetic cycle into a test copy, run the script, expect exit 1."
owner: qa-validation-commander
depends_on: []
tags: [quick-win, ci-gap, latent]
```

## DY-02 — `scripts/validate-schemas.sh` validates JSON parseability but NOT the declared $schema

```yaml
id: DY-02
area: prompt
surprise: true
title: "Schema validator is a JSON/TOML parse check, not a schema conformance check"
problem: |
  `.claude/settings.json:1` declares `"$schema": "https://json.schemastore.org/claude-code-settings.json"`.
  `scripts/validate-schemas.sh:32-44` runs `python -m json.tool` on `.claude/settings.json` and `.mcp.json`
  — which only verifies the file is valid JSON. It does NOT fetch the $schema URL and validate conformance.
  A malformed permission entry (e.g., `"allow": "Bash(git status)"` as a string instead of an array) would
  parse fine but be functionally invalid.
evidence: "scripts/validate-schemas.sh:32-44 + .claude/settings.json:1 ($schema declaration)"
evidence_source: "Direct read of script + settings"
evidence_trust: T1
completeness_risk: low
contradiction_status: partial
impact: |
  A future contributor introducing a subtle settings.json shape bug (wrong type, unknown key) escapes
  CI. This is a "lint looks green but the config is wrong" failure mode — the same pattern as ajanscan
  AP-03 (non-blocking CI gate) in miniature.
severity: Medium
priority: P2
recommended_fix: |
  Either (a) install `check-jsonschema` via pip and run `check-jsonschema --schemafile <url> file.json`
  in CI, or (b) cache the schema locally and validate offline. Option (b) is more reproducible and doesn't
  depend on json.schemastore.org uptime. Also: add validation for `$schema`-declaring files that don't have a
  schema handler yet (warn rather than silent-skip).
validation: "Inject a malformed permission entry (string instead of array), run validate-schemas.sh, expect exit 1."
owner: qa-validation-commander
depends_on: []
tags: [foundational, ci-gap, false-green]
```

## DY-03 — Gemini CLI has `.gemini/commands/*.toml` but parity-with-Claude-commands is unchecked

```yaml
id: DY-03
area: prompt
surprise: true
title: "Gemini commands exist but cross-vendor command parity has no CI gate"
problem: |
  `.gemini/commands/` contains `director.toml`, `final-verdict.toml`, `intake.toml`, `market-scan.toml`,
  `frontend/` (and more). Claude Code has `.claude/commands/{director, final-verdict, frontend-war-room,
  intake, pack-gap-audit, ulak-design-ref, ulak-intake}.md`. The sets diverge: Claude has
  `pack-gap-audit`, `ulak-design-ref`, `ulak-intake`, `frontend-war-room` (but Gemini has a `frontend/`
  folder instead of a single command); Gemini has `market-scan.toml` (not in Claude). No CI check enforces
  that commands documented for one vendor exist for the other(s).
evidence: ".claude/commands/ (7 md files) vs .gemini/commands/ (TOML files + frontend/) — inventory §7"
evidence_source: "ls of both command directories"
evidence_trust: T1
completeness_risk: low
contradiction_status: partial
impact: |
  `docs/distribution/release-parity-policy.md` (not deep-read this run — flag residual) likely covers this,
  but the enforcement is absent. A Claude-only user may rely on `/pack-gap-audit` which doesn't exist in
  Gemini; a Gemini user may find `market-scan` and assume it exists in Claude.
severity: Medium
priority: P2
recommended_fix: |
  Add `scripts/validate-vendor-parity.sh` that lists all commands per vendor and emits a cross-vendor
  matrix. CI fails if a command is missing on >1 vendor without an explicit exception marker (e.g.,
  a `.claude-only` flag in the command front-matter). Ties to R-04 (pre-push parity) from ajanscan.
validation: "The parity script emits a matrix; CI fails when a Claude command is added without its Gemini counterpart (or the exception marker)."
owner: architecture-lead
depends_on: []
tags: [foundational, vendor-parity, ajanscan-aligned]
```

## DY-04 — `REQUIRED_PACKS` vs `required_sector_packs` field-name drift in two runtime docs

```yaml
id: DY-04
area: prompt
surprise: true
title: "active-variable-contract says REQUIRED_PACKS, router.md + sector-packs.md say required_sector_packs"
problem: |
  `docs/runtime/active-variable-contract.md:60` writes the YAML field as `REQUIRED_PACKS: []`.
  `docs/runtime/router.md:87` says `required_sector_packs: []` (snake_case).
  `docs/runtime/sector-packs.md:29,140` says `router.required_sector_packs`.
  Two different names for the same field. A specialist reading active-variable-contract and populating
  `REQUIRED_PACKS` produces YAML the router reader can't parse. This is parallel to FIND-AL-01 (Phase
  numbering drift) at a smaller scale.
evidence: "active-variable-contract.md:60 vs router.md:87 vs sector-packs.md:29,140"
evidence_source: "Grep cross-doc"
evidence_trust: T1
completeness_risk: low
contradiction_status: direct
impact: "Runtime YAML inconsistency. Any specialist or tool reading active-variables.yaml looking for the sector-pack list needs to check both names."
severity: Medium
priority: P1
recommended_fix: |
  Pick one. `required_sector_packs` is longer but explicit and matches router.md's field naming
  convention (all snake_case). Rename active-variable-contract.md:60 to `required_sector_packs: []`.
  Update the comment to make the relationship to router.md explicit.
  While at it: active-variable-contract.md uses SCREAMING_SNAKE for most fields (REQUEST,
  PROJECT_CONTEXT, CAN_EDIT_FILES). That convention is inconsistent with router.md's snake_case.
  Decide one convention for all runtime YAML — strong vote for snake_case (more modern, matches most
  tooling).
validation: "grep -r REQUIRED_PACKS docs/ returns 0 matches in active runtime files."
owner: architecture-lead
depends_on: [FIND-AL-01]
tags: [foundational, field-drift]
```

## DY-05 — `docs/examples/` serves as hidden contract for what finished artefacts should look like — but they aren't flagged as contract

```yaml
id: DY-05
area: prompt
surprise: true
title: "docs/examples/sample-manager-verdict.md has semi-official structure but no doc says 'contributors, match this'"
problem: |
  `docs/examples/` contains sample-intake, sample-inventory, sample-manager-verdict (in tr+en pairs).
  A specialist writing their first manager-verdict.md likely reads the sample as the source of truth
  for structure. But no contract doc (artefact-contract.md, output-profiles.md, program-phases.md)
  references these samples as canonical templates. They're neither forbidden (part of the active runtime
  surface) nor formalized (no "template: reports/current/manager-verdict.md MUST match docs/examples/...").
evidence: "docs/examples/ contents + grep 'docs/examples' in docs/runtime/*.md + docs/governance/*.md"
evidence_source: "Inventory §12 + grep"
evidence_trust: T2
completeness_risk: low
contradiction_status: partial
impact: |
  Quiet drift risk. A new specialist might match an old sample that predates the latest finding-schema
  fields (time_sensitivity, source_personas). Or they ignore the samples entirely and emit a structure
  that doesn't match, forcing the director to re-persist.
severity: Low
priority: P2
recommended_fix: |
  Either (a) promote docs/examples/ to canonical templates with a statement in artefact-contract.md
  saying "the canonical minimal template for each artefact is docs/examples/sample-<name>.md — it lags
  the schema by at most 1 minor version", or (b) archive them into docs/history/examples/ and replace
  with generated samples (e.g., from the last green eval run).
validation: "Each sample-*.md carries a 'canonical as of version X.Y.Z' footer OR the examples move to docs/history/."
owner: qa-validation-commander
depends_on: []
tags: [quick-win, template-contract]
```

## DY-06 — The 4 skills have `context: fork` but none document what "fork" means in Ulak's adapter semantics

```yaml
id: DY-06
area: prompt
surprise: true
title: "'context: fork' in skill frontmatter is undocumented in Ulak runtime docs"
problem: |
  Every shipping skill (.claude/skills/{final-validation,pack-gap-completion,project-intake,research-currency}/SKILL.md:3)
  has `context: fork`. This is a Claude Code skill keyword, but Ulak OS docs do not explain which values
  are allowed, what `fork` vs (presumably) `inherit` does, and what a skill author should pick. A Gemini-adapter
  author porting these skills to .gemini has no guidance.
evidence: ".claude/skills/*/SKILL.md:3 (all say 'context: fork') + grep 'context:' docs/ (no explanation)"
evidence_source: "Direct read + grep"
evidence_trust: T1
completeness_risk: low
contradiction_status: none
impact: "Cross-vendor skill porting is blocked by undocumented keyword semantics. Also, skill authors can't make an informed choice."
severity: Low
priority: P3
recommended_fix: |
  Add a 'Skill metadata fields' subsection to plugin-skill-decision.md OR to docs/adapters/claude-code.md
  describing the allowed values for `context:` (at minimum: fork, inherit, default) and what each does.
  Cross-reference in .claude/skills/README.md if it exists (or create one).
validation: "grep 'context: fork' docs/ returns at least 1 documentation hit."
owner: prompt-skill-plugin-governor
depends_on: []
tags: [quick-win, skill-semantics]
```

## DY-07 — CHANGELOG has TWO `[Unreleased]` blocks — readers may merge or split incorrectly

```yaml
id: DY-07
area: release
surprise: true
title: "CHANGELOG.md has [Unreleased] and [Unreleased — earlier] — ambiguous for tooling"
problem: |
  `CHANGELOG.md:3` and `CHANGELOG.md:84` both open with `[Unreleased]` headers. Line 3 says "v2.1.2
  docs prep continued — FP-01 artefact write authorization fix", line 84 says "v2.1.2 docs prep (v2.2
  runtime contract drafts)". Release tooling (e.g., changelog-parser, release-drafter) typically expects
  ONE [Unreleased] section that gets promoted to a version at tag time. Two unreleased blocks means
  tooling may auto-merge or pick one arbitrarily.
evidence: "CHANGELOG.md:3, CHANGELOG.md:84"
evidence_source: "Direct read"
evidence_trust: T1
completeness_risk: low
contradiction_status: direct
impact: |
  When v2.1.3 ships (per this audit), a changelog tool consuming CHANGELOG may emit an incorrect release note.
  Human readers understand 'continued' means the two blocks belong to the same release; automation won't.
severity: Medium
priority: P1
recommended_fix: |
  Consolidate into ONE [Unreleased] header. The two current blocks become two subsections under it
  (e.g., "### v2.1.2 — FP-01 fix" and "### v2.1.2 — runtime contract drafts"). At release time, the
  [Unreleased] becomes `## [2.1.3] — 2026-04-XX`. Per FIND-INF-01, this v2.1.3 audit run's output
  becomes a third subsection of the same [Unreleased] block before the version tag.
validation: "grep -c '## \\[Unreleased\\]' CHANGELOG.md returns 1."
owner: infra-release-sre
depends_on: [FIND-INF-01]
tags: [quick-win, changelog-hygiene]
```

## DY-08 — `evals/` ships assertions and golden sets but NO automated runner

```yaml
id: DY-08
area: prompt
surprise: true
title: "evals/ exists and is consumed by docs but no runner script or CI job runs them"
problem: |
  `evals/assertions/core-assertions.md` and `evals/golden/01_full_program_komple.md` exist. They're
  referenced as the prompt-regression gate in validation-result-schema.md:28 and in the release-criteria.
  But there is NO shell script, CLI command, or CI job that actually executes them. Running them requires
  manually invoking a director session and diffing output by hand.
evidence: "evals/{assertions,golden}/ directories + ci-validation.yml (no evals job) + no evals/run.sh or similar"
evidence_source: "ls + grep 'evals' ci-validation.yml returns nothing"
evidence_trust: T1
completeness_risk: low
contradiction_status: partial
impact: |
  The "prompt regression" validation gate is documented but unrunnable. Any v2.x release that claims
  'prompt regression: pass' is either manual (T2/T3) or false (T7). This is parallel to ajanscan AP-03
  (non-blocking CI gate) — the gate exists but can't actually gate.
severity: Medium
priority: P1
recommended_fix: |
  Author `evals/run.sh` that iterates over `evals/assertions/*.md`, parses each assertion block, dispatches
  a test director run (either via `ulak` CLI or a mock), and diffs output against the golden set.
  Add a CI job that runs it. Start with warn-only (non-blocking); promote to blocking in v2.2.
  This overlaps with FIND-QA-02 but is a distinct finding (FIND-QA-02 says CI doesn't invoke the runner;
  DY-08 says the runner itself doesn't exist yet).
validation: "`bash evals/run.sh` exits 0 on the current tree; returns non-zero on a synthetic regression."
owner: qa-validation-commander
depends_on: [FIND-QA-02]
tags: [foundational, evals-gap, false-green]
```

## DY-09 — docs/superpowers/ contains planning docs from v1.0.0 era that are still runtime-resolvable via @-imports

```yaml
id: DY-09
area: prompt
surprise: true
title: "docs/superpowers/plans/archive/2026-04-07-ulak-os-v1.0.0.md is a 3000+ line plan with current-format text"
problem: |
  `docs/superpowers/plans/archive/2026-04-07-ulak-os-v1.0.0.md` is a 3000+ line archived planning doc
  from the v1.0.0 era. It uses `Phase 5 — Skill Integration`, `Phase 6 — Multi-Language`, `Phase 7 —
  Sample Artifacts`, `Phase 8 — Quality Fixes` (per grep). This is a Numbering C — internal to that
  planning doc. While the file IS in `docs/superpowers/plans/archive/`, it's NOT in `docs/archive/`
  (which IS the canonical hidden-core location). If someone's @-import tree walk ever crosses into
  superpowers/, they'll load these stale phase numbers into active context.
evidence: "docs/superpowers/plans/archive/2026-04-07-ulak-os-v1.0.0.md:1529,1744,2022,2322 (Phase 5/6/7/8 headers)"
evidence_source: "Grep for phase numbers"
evidence_trust: T2
completeness_risk: medium
contradiction_status: partial
impact: |
  No active @-import reaches into docs/superpowers/ today (verified in cartographer §CG-02). But the
  surface-split.md §71 says hidden core lives in `docs/history/*` and `docs/archive/*`. docs/superpowers/
  is in NEITHER — it's a third zone. Its status (Layer 1? Layer 2? Layer 3?) is undefined.
severity: Low
priority: P3
recommended_fix: |
  Either (a) move `docs/superpowers/` into `docs/archive/superpowers/` (explicit Layer 2), or
  (b) add a README.md to docs/superpowers/ declaring its layer per surface-split.md, or
  (c) gitignore it (local-scratch only, shouldn't be in the public repo).
  Recommendation: (b) because the folder carries historical design intent that's worth keeping
  reviewable by maintainers, just not by the active model.
validation: "docs/superpowers/README.md exists and names its layer per surface-split.md."
owner: architecture-lead
depends_on: []
tags: [quick-win, hidden-core-hygiene]
```

## DY-10 — `active-variable-contract.md:53` says `MAX_PARALLEL_AGENTS: 6` but director.md:76 says "default 6" and director-agent.md:69 says "Clamp to [1, 15]"

```yaml
id: DY-10
area: prompt
surprise: true
title: "Parallel-dispatch cap appears in 3 places with consistent default but no enforcement doc"
problem: |
  Three docs name the Phase 2 dispatch cap:
  - active-variable-contract.md:53: `MAX_PARALLEL_AGENTS: 6`
  - director.md:76: "default 6"
  - autonomous-program-director.md:69: "Default 6. Clamp to [1, 15]"
  The three are consistent on default=6 but only the director AGENT mentions the upper clamp (15).
  If a user sets `parallel_dispatch=20`, the agent clamps silently. No warning, no doc saying the clamp
  exists. Also: the lower bound "1" allows serial dispatch, which contradicts the Phase 2 hard rule
  "Phase 2 must dispatch all specialists in a single parallel batch" (program-phases.md:50).
evidence: |
  active-variable-contract.md:53 (MAX_PARALLEL_AGENTS: 6);
  .claude/commands/director.md:76 ("override the Phase 2 default dispatch cap (default 6)");
  .claude/agents/autonomous-program-director.md:69 ("Default 6. Clamp to [1, 15]");
  docs/runtime/program-phases.md:50 ("dispatch all relevant specialists in a single parallel batch")
evidence_source: "Cross-doc grep"
evidence_trust: T1
completeness_risk: low
contradiction_status: partial
impact: |
  A user asking for `parallel_dispatch=1` thinks they're getting serial dispatch. The director complies
  (clamp to [1,15] allows it). But serial dispatch violates Phase 2's single-batch rule. The director
  silently accepts an invalid configuration.
  Also: max 15 feels arbitrary. Claude Code's actual parallel Task limit is typically 10; going higher
  invites rate-limit failures. If 15 is a deliberate ceiling based on API limits, it should be documented.
severity: Low
priority: P2
recommended_fix: |
  (a) Add a "parallel dispatch discipline" section in docs/runtime/program-phases.md §Phase 2 pinning:
      lower bound=2 (single agent dispatch violates the parallel rule), upper bound=10 (not 15; matches
      Claude Code recommended concurrency).
  (b) Make clamp explicit in director.md: "Cap: 10. Values >10 are clamped and logged as warning."
  (c) Move the MAX_PARALLEL_AGENTS constant into a single source of truth (e.g., in program-phases.md
      or a new runtime constants doc) and have active-variable-contract.md reference it by link.
validation: "Setting parallel_dispatch=1 results in a warning logged to runtime-manifest.md; parallel_dispatch=20 is clamped to 10 with a warning."
owner: architecture-lead
depends_on: []
tags: [foundational, dispatch-discipline]
```

---

## Summary

10 non-obvious findings, all with file:line citations and T1/T2 evidence. Severity distribution:

| Severity | Count | IDs |
|---|---|---|
| Medium | 5 | DY-02, DY-03, DY-04, DY-07, DY-08 |
| Low | 5 | DY-01, DY-05, DY-06, DY-09, DY-10 |

### Cross-cutting themes surfaced by Phase 3 (not in Phase 2 specialist evidence)

1. **False-green CI** (DY-01, DY-02, DY-08) — Ulak's own CI has the anti-pattern Ulak teaches consumers to avoid (ajanscan AP-03). Three distinct false-green surfaces: import cycles not detected, schema not validated, evals not runnable.
2. **Numbering / naming drift beyond Phase numbers** (DY-04, DY-10, and FIND-AL-01 from Phase 2) — this is a broader pattern. At least 3 runtime constants (MAX_PARALLEL_AGENTS case, REQUIRED_PACKS vs required_sector_packs, Phase 5/6/7/8) have internal inconsistency. Suggests a single runtime-constants doc is needed.
3. **Reference-implementation gaps** (DY-05, DY-06, DY-09) — three under-documented surfaces where Ulak ships something but doesn't declare its status: the examples directory, the skill metadata fields, the superpowers directory. Each contributes to the "is this canonical or legacy?" confusion.
4. **Vendor parity is hope, not enforced** (DY-03) — Gemini commands and Claude commands diverge. The docs preach vendor-neutral but the release discipline does not enforce parity.

These themes, combined with Phase 2 Theme A (doc drift outpaced velocity) and Theme C (reference implementation thinness), suggest v2.1.3 should include **one dedicated workstream on "false-green detection"** alongside the ajanscan-integration waves.
