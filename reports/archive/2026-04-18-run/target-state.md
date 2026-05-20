# Target State — Ulak OS v2.1.3

**Date**: 2026-04-18
**Run id**: director-komple-ulakos-self-audit
**Scope**: docs + governance + agent prompts. No CLI source changes. No runtime breaking changes.

## v2.1.3 definition

Docs-focused release integrating ajanscan pattern extraction (39 patterns) + self-audit coherence fixes (36 fresh findings) + Phase 3 surprise layer (10 did-you-know items).

Scope is additive to v2.1.2 surface. No existing runtime contract field is renamed or removed except the Phase-numbering refactor (FIND-AL-01, which consolidates contradictory numbering into one system).

## Target architecture

### Layer 1 — Public runtime surface (changes)

**Runtime rules** (docs/runtime/):
- anti-patterns.md extended with 9 new entries (AP-01..AP-09)
- sector-packs.md extended with 6 new packs + 1 extension (SP-01..06 + SP-EXT-01)
- rule-packs/ NEW directory + 4 starter files (typescript-nextjs, python-fastapi, docker-compose, api-security)
- program-phases.md refactored: Numbering A adopted (Phase 5 = final verdict)
- persona-dispatch-pattern.md:164-165 updated (personas ARE shipped)
- office-roster.md now imported by core contract
- output-profiles.md extended with `output_language: auto|tr|en` field per profile
- NEW docs/runtime/strangler-fig-protocol.md (R-01)
- NEW docs/runtime/multi-agent-merge-sequence.md (R-02)
- NEW docs/runtime/audit-scoring-framework.md (R-03)
- toolchain-precheck.md extended with pre-push parity + VPS baseline (R-04)
- architecture-currency.md extended with deploy resilience section (R-05)
- NEW docs/runtime/runtime-constants.md — single source of truth (resolves DY-10 + DY-04)

**Governance** (docs/governance/):
- NEW rule-pack-governance.md (G-01)
- NEW ai-provider-allowlist.md (G-02)
- NEW pattern-import-ledger.md (G-03)
- NEW settings-permissions-governance.md (G-04) — closes FIND-SEC-01+02
- NEW lock-file-hygiene.md (G-05)
- NEW product-surface-split.md (G-06)
- plugin-skill-decision.md extended to 7 unit types (rule-pack added)
- rule-collision-matrix.md extended with worked examples (~60-80 lines)
- mcp-governance.md extended with audit-trail + PAT rotation runbook
- memory-hygiene.md extended with worktree cleanup policy
- prompt-supply-chain.md cross-linked to G-03
- artefact-write-authorization.md scope widened to all artefact-contract.md paths (FIND-RT-01)

**Core contract** (prompts/core/ulak-os-core-contract-2.0.0.md):
- Add @docs/runtime/office-roster.md to Runtime rules layer
- Move @docs/governance/plugin-skill-decision.md and @docs/governance/rule-collision-matrix.md from CLAUDE.md into core contract Governance block
- Add @docs/governance/settings-permissions-governance.md (G-04)
- Add @docs/governance/product-surface-split.md (G-06)
- Add R-01/R-02/R-03 imports in Runtime rules layer
- Relabel "Operational motors" as honest "always-on motors" (v2.2 implements conditional loader)

**CLAUDE.md**: Remove the two governance @-imports now moved to core contract.

### Agent surface (changes)

- autonomous-program-director — rule-pack loader in Phase 0, propagate live-probe-enabled flag, propagate output_language (AG-EXT-02)
- design-system-architect — Master + per-page output contract (AG-EXT-01)
- security-hardening-lead — secrets rotation + history purge workflow (AG-EXT-03)
- 18 31-line specialist agents — enhanced to ~50-80 lines each (FIND-PG-01, can phase to v2.2 if capacity constrained — NOT a v2.1.3 blocker)

### Command + skill surface (changes)

- NEW .claude/commands/triage-build.md (C-01)
- NEW .claude/skills/god-module-decomposition/SKILL.md (SK-01)
- NEW .claude/skills/fourteen-dimension-audit/SKILL.md (SK-02)
- NEW .claude/skills/multi-agent-orchestration/SKILL.md (SK-03)
- 4 light commands (pack-gap-audit, intake, final-verdict, frontend-war-room) — add "Phase subset" frontmatter stating which phases they run (FIND-PG-03)
- Cross-reference skills in commands where they belong (FIND-PG-04)

### CI + release surface (changes)

- .gitignore — add `.claude/settings.local.json`
- `git rm --cached .claude/settings.local.json`
- NEW .claude/settings.local.example.json — safe template
- ci-validation.yml — raise artefact count threshold 12→14; move brand allowlist to .github/brand-allowlist.txt; add evals-smoke job (warn-only in v2.1.3, blocking in v2.2)
- NEW .gitleaks.toml + .gitleaks.baseline
- NEW .github/dependabot.yml
- CHANGELOG.md — consolidate two [Unreleased] blocks; cut v2.1.3 release
- package.json — 2.0.0 → 2.1.3
- NEW evals/run.sh — runnable evals
- NEW scripts/validate-vendor-parity.sh — Claude/Gemini command parity
- scripts/validate-schemas.sh — upgrade from parse-only to $schema conformance
- scripts/validate-imports.sh — add cycle detection

## Target UX / system behavior

### User-facing changes
- /director komple unchanged in behavior; phase numbering reflected consistently in all produced artefacts
- /director dispatch=both now has a documented merge rule (FIND-RT-03 fix)
- /director parallel_dispatch=N enforces 2 ≤ N ≤ 10 bounds (clamp with warning outside range, DY-10 fix)
- Output language: director infers from operator last message when output_language: auto; artefacts written in that language; finding YAML keys always English (schema)
- Rule-pack loading: at Phase 0, router detects stack signals and loads applicable rule-packs with project-override merge precedence

### Consumer-facing changes
- Consumers can declare stack-specific <500B guardrails via .claude/rules/<stack>.md
- New sector packs activate on router detection: Supabase → SP-01; payment-integrated → SP-03; regulated (cyber/health/fin) → SP-04; reseller → SP-05; nginx/compose VPS → SP-06
- 6 new anti-patterns catch in consumer audits

## Target security posture

- Operator absolute paths no longer committed (FIND-SEC-01+02 fixed)
- PAT rotation runbook shipped (FIND-SEC-03)
- Skill shell-execution audit hook sample in settings-permissions-governance.md (FIND-RT-05)
- One guardrail hook in .claude/settings.json as reference implementation (FIND-SEC-04)
- Gitleaks baseline reduces false-green risk (FIND-QA-03)
- Regulated-SaaS sector pack (SP-04) ships with compliance-framework-registry pattern

## Target release model

- Package.json version aligned with prompt-pack version (2.1.3). One version; no split
- CHANGELOG has single [Unreleased] block at any time; consolidated on release
- Release-parity-policy enforcement via scripts/validate-vendor-parity.sh in CI
- Release candidate passes: schema validation, @import validation (with cycle detection), brand check (allowlist moved to file), artefact count (14+), version-lineage check, dependabot up to date, gitleaks clean-against-baseline, vendor parity, evals-smoke warn-only

## Open-question decisions (recorded with rationale)

### Q1 — Orchestrator agent split
**Decision**: NO new `orchestrator-coordinator` agent. Extend `autonomous-program-director` (AG-EXT-02).
**Rationale**: File-ownership + conflict-arbitration already belong to director scope per waves-pattern.md:40-55. Splitting fragments the phase 0→5 single-point-of-accountability. Director grows ~20-30 lines; new agent would duplicate context-handling infrastructure.
**Trade-off**: director agent ~220-240 lines. Reconsider in v2.2 if >300 lines.

### Q2 — Secrets specialist split
**Decision**: NO new `security-secrets-auditor`. Extend `security-hardening-lead` with secrets rotation + history purge workflow (AG-EXT-03).
**Rationale**: Rotation and purge are runbooks, not a distinct analytical lens. Splitting creates two agents both scanning for secrets — the duplicate-agents anti-pattern (anti-patterns.md:137).
**Trade-off**: agent file doubles to ~60 lines. Acceptable.

### Q3 — Surface-split naming
**Decision**: KEEP BOTH with clear names. `surface-split.md` stays for runtime/public/hidden/maintainer layer distinction. Add NEW `product-surface-split.md` (G-06) for customer/admin/public/partner API distinction.
**Rationale**: 4+ existing refs to `surface-split.md` across context-budget.md, core-contract, program-phases.md, artefact-write-authorization.md. Renaming = 4-file churn. Adding a differently-named sibling is cheaper.
**Trade-off**: two "surface-split" docs. Mitigated by product- prefix.

### Q4 — payment-integrated-saas vs fintech
**Decision**: NEW PACK `payment-integrated-saas` (SP-03), orthogonal to existing `fintech`.
**Rationale**: `fintech` applies to products that ARE financial services (KYC, AML, PCI scope). Most SaaS accept payments without being fintech. Forcing `fintech` pack on any Stripe-integrated SaaS loads regulatory rules that do not apply.
**Trade-off**: overlap intentional; multi-qualifying products load both.

### Q5 — regulated-saas variants
**Decision**: ONE PACK `regulated-saas` (SP-04) with 3 variant sections (cybersecurity, fintech-regulated, healthcare).
**Rationale**: Framework-registry pattern is identical across variants per ajanscan extraction §72. Only the adapter SET differs (CVSS/MITRE/NIST/ISO/KEV vs SOC2/PCI-DSS vs HIPAA/HITRUST). One pack = less duplication.
**Trade-off**: pack ~250 lines. Split in v2.2 if >400.

### Q6 — Rule-pack precedence
**Decision**: MERGE with project-override precedence. Project `.claude/rules/<stack>.md` overrides specific sections of Ulak-shipped `docs/runtime/rule-packs/<stack>.md`; unmatched sections inherit from Ulak.
**Rationale**: Wholesale override forces project packs to copy Ulak content → drift risk. Merge lets project packs stay minimal (just the divergent rules). Enforced at load time: Ulak pack sections hash-identified; project pack declares overrides via front-matter.
**Trade-off**: merge logic adds complexity. Mitigated by evals/golden/ test case.

## Out of scope for v2.1.3 (deferred to v2.2+)

- Actual mode-loading mechanism for operational motors (v2.1.3 relabels to honest "always-on"; v2.2 implements conditional loader)
- Specialist agent prompt enhancement from 31→60L (FIND-PG-01) — Medium priority, can slip if capacity tight
- `orchestrator-coordinator` split if director agent exceeds 300 lines post-v2.1.3
- `ulak-design-intelligence-mcp` (D-01) — vendor-neutral MCP wrapper of ajanscan ui-ux-pro-max
- `security-secrets-auditor` split if security-hardening-lead exceeds 120 lines
- docs/superpowers/ cleanup (DY-09)
- Validation-plan §6 upgrades based on ajanscan R-04 pre-push parity checks
