# Analysis Findings — Ulak OS v2.1.3 audit

**Date**: 2026-04-18
**Run id**: director-komple-ulakos-self-audit
**Profile**: AUDIT_PROFILE
**Source**: merged from evidence-register.md (36 fresh + 39 inherited) + did-you-know.md (10 non-obvious)
**Total**: 85 findings (75 Phase 2 merged + 10 Phase 3 surprise)

All findings conform to docs/governance/finding-schema.md. Severity decisions use docs/governance/rule-collision-matrix.md priority 1 (Security/legal/privacy) over priority 6 (UX clarity).

## Critical findings

None on Ulak OS itself. Highest-urgency is FIND-SEC-01+02 merged (self-inflicted settings.local.json leak with operator absolute paths to sibling project), classified High-P0 — blast radius is operator privacy leak, not product security failure.

## High findings (12)

### Blocking for v2.1.3 signoff (P0)
1. FIND-SEC-01+02 — settings.local.json tracked in git with operator-local absolute paths. Evidence: .gitignore:1-28 (no entry) + .claude/settings.local.json:5-10. Fix: gitignore + git rm --cached + ship .settings.local.example.json.
2. FIND-AL-01+02 — Phase numbering contradiction across 11+ docs. Evidence: cross-doc grep. Fix: adopt Numbering A (Phase 5=verdict), refactor program-phases.md.
3. FIND-PG-02 — persona-dispatch-pattern.md:164 says "NOT yet shipped" but 7 persona agents ARE shipped. Fix: 2-line doc edit.
4. FIND-QA-01 — No canonical validation-plan.md template; §6 live-probe section structure is unspecified. Fix: ship docs/examples/sample-validation-plan.md.
5. FIND-PG-05 = ajanscan G-01 — rule-pack unit type missing from plugin-skill-decision.md. Fix: extend to 7 units + create docs/governance/rule-pack-governance.md + docs/runtime/rule-packs/*.md.

### Ship in v2.1.3 (P1)
6. FIND-AL-03 — office-roster.md referenced but not imported by core contract.
7. FIND-CG-03 — operational motors labeled "mode-loaded" but @-imported unconditionally. Depends on FIND-AL-01 choice.
8. FIND-LOC-01 — output-profiles.md has no output-language field.
9. FIND-INF-01 — CHANGELOG [Unreleased] for v2.1.2, no release tag. Consolidate into v2.1.3.
10. FIND-INF-02 — package.json version 2.0.0 vs prompt-pack v2.1.x. Bump to 2.1.3.
11. FIND-QA-02 — CI doesn't run evals/ golden set (prompt_regression gate is unverifiable).
12. FIND-SEC-03 — PAT rotation runbook missing in mcp-governance.md.

## Medium findings (30)

### Governance extensions (13)
- FIND-PG-01 specialist agents are 31-line generic shells
- FIND-PG-03 light commands lack phase-subset docs
- FIND-PG-06 red-team-challenger vs security-redteam lane split undocumented
- FIND-RT-01 artefact-write-authorization override scope narrower than artefact-contract.md paths
- FIND-RT-02 rule-collision-matrix has no worked examples
- FIND-RT-03 dispatch=both merge-rule missing
- FIND-RT-04 live-probe-enabled flag not propagated to specialists
- FIND-RT-05 disableSkillShellExecution: false with no Skill audit hook
- FIND-SEC-04 Ulak ships only logging hooks, no guardrail example
- FIND-CG-01 plugin-skill-decision + rule-collision-matrix bypass core contract
- FIND-LOC-02 turkish-normalization always loaded
- DY-04 REQUIRED_PACKS vs required_sector_packs field name drift
- DY-10 MAX_PARALLEL_AGENTS scattered across 3 docs with unenforced bounds

### Inherited sector packs + governance (6 Medium)
- Ajanscan SP-01/02/03/05/06 + SP-EXT-01; SP-04 regulated-saas is High-P2
- Ajanscan G-02 (AI-provider-allowlist), G-03 (pattern-import-ledger), G-EXT-01/02/04

### Inherited anti-patterns (9)
- AP-01 through AP-09. All are documentation additions, Medium-P2.

### False-green CI surface (3)
- DY-02 schema validator doesnt validate against declared $schema
- DY-03 vendor parity unchecked
- DY-07 CHANGELOG has 2 [Unreleased] blocks

### Misc (2)
- DY-08 evals/ exists but has no runner
- FIND-INF-04 hook logs unbounded

## Low findings (43)

### Fresh low (14)
FIND-AL-04 autonomy-pressure-layer orphan; FIND-AL-05 docs/i18n/ empty; FIND-CG-02 no circular imports (positive + CI enhancement); FIND-CG-04 README stubs; FIND-LOC-03 bilingual example drift check; FIND-QA-03 gitleaks without baseline; FIND-QA-04 AGENTS.md CI floor stale (12→14); FIND-PG-04 skills under-referenced; FIND-INF-03 no dependabot; FIND-INF-05 CI brand allowlist hardcoded; DY-01 import cycle detection missing; DY-05 docs/examples/ uncontracted; DY-06 skill context:fork undocumented; DY-09 docs/superpowers/ layer undefined.

### Inherited low — deferred to v2.2
D-01 ulak-design-intelligence-mcp; D-02 orchestrator-coordinator agent (resolved: NO, extend director); D-03 security-secrets-auditor (resolved: NO, extend security-hardening-lead).

### Inherited low — skills + agent extensions (7)
SK-01/02/03; C-01; AG-EXT-01/02/03.

## Evidence-backed notes

### Trust tier distribution
- T1: ~60 (file:line direct)
- T2: ~18 (consensus / extrapolation)
- T3: 4 (memory-sourced, flagged: G-02, G-03, R-05, AG-EXT-01)
- T4-T7: 0

### Six open questions — resolution summary
1. Orchestrator split: NO. Extend autonomous-program-director.
2. Secrets specialist split: NO. Extend security-hardening-lead (AG-EXT-03).
3. Surface-split naming: KEEP both with clear names. Add product-surface-split.md; keep surface-split.md.
4. payment-integrated-saas vs fintech: NEW PACK (SP-03). Orthogonal to fintech.
5. regulated-saas variants: ONE PACK with 3 variant sections (cybersecurity/fintech/healthcare).
6. Rule-pack precedence: MERGE with project override. .claude/rules/stack.md overrides specific sections; unmatched inherit from Ulak pack.

### Residual risks
- R1 CLI source (src/) not deep-scanned (docs-only REPAIR).
- R2 docs/distribution/release-parity-policy.md not deep-read.
- R3 tests/ not deep-scanned.
- R4 TrendOfTrend-derived memory claims (G-03) are T3 — next run should scan TrendOfTrend directly.
- R5 Supabase-specific ajanscan patterns go into SP-01 multi-tenant-supabase; verify router.md pack activation gates it correctly.
