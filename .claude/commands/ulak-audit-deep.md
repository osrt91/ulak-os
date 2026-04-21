---
name: ulak-audit-deep
description: Mevcut repo üzerinde 14-dimension audit scorecard çalıştır. /director komple'den daha derin kalite-barı yüzeyler için (Architecture, Testing, Secrets, Observability, CI/CD, Duplication, Dependencies, Type Safety, Plugins, API Design, Infrastructure, Frontend, Data Validation, Documentation). Dimension başına 0-100 skor + A-F grade + target-state + gap analysis üretir. Proje baseline'ları, modernization sonrası doğrulama, quarterly health report veya /director komple'nin signoff_status: ready çıktısına ikinci görüş scorecard gerektiğinde kullan.
description_en: Run the 14-dimension audit scorecard against the current repo. Deeper than /director komple for quality-bar surfaces (Architecture, Testing, Secrets, Observability, CI/CD, Duplication, Dependencies, Type Safety, Plugins, API Design, Infrastructure, Frontend, Data Validation, Documentation). Produces per-dimension 0-100 scores + A-F grade + target-state + gap analysis. Use for project baselines, post-modernization verification, quarterly health reports, or when /director komple's signoff_status: ready needs a second-opinion scorecard.
agent: autonomous-program-director
allowed-tools: Read, Grep, Glob, Bash
---

# /ulak-audit-deep — 14-dimension scorecard with target-state + gap analysis

## When to use

- **Quarterly health check**: repo score drifts slowly; run every 90 days to catch regression
- **Post-modernization verification**: after a major refactor, quantify improvement vs baseline
- **Pre-investment audit**: before greenlighting a large migration, quantify where the leverage actually is
- **Complement to /director komple**: director assesses THIS task; this command assesses THIS codebase across 14 orthogonal dimensions

## How it differs from /director komple

| | /director komple | /ulak-audit-deep |
|---|---|---|
| **Scope** | Single program (route → intake → evidence → synthesis → verdict) | Cross-dimensional quality scorecard |
| **Output** | 15 artefacts including manager-verdict | 14 per-dimension scores + A-F grade + gap matrix |
| **Depth** | Director-level synthesis | Specialist-level per-dimension depth (14 agents in parallel, each scoring one dimension) |
| **Prerequisite** | Can be first command in new repo | Assumes inventory exists (runs deeper) |

## Dispatch protocol

Invokes the `fourteen-dimension-audit` skill which coordinates 14 specialist passes:

1. Architecture (god-modules, layering, coupling, SSOT)
2. Testing (coverage per-type, flakiness, golden-set discipline)
3. Secrets (rotation, leakage surface, supply-chain)
4. Observability (log volume, trace sampling, alert quality, SLO definitions)
5. CI/CD (blocking vs warn, gate coverage, flaky-workflow rate)
6. Duplication (copy-paste code, forked patterns, drift between siblings)
7. Dependencies (age, CVE exposure, transitive bloat, license hygiene)
8. Type Safety (TS strict, `any` count, unchecked external boundaries)
9. Plugins (pack-gap coverage, skill discoverability, command duplication)
10. API Design (surface split, error shape, versioning, idempotency)
11. Infrastructure (deploy pattern, rollback, blast radius, resource limits)
12. Frontend (design-token conformance, component reuse, performance)
13. Data Validation (zod/pydantic coverage, edge validation, DB constraint enforcement)
14. Documentation (README freshness, ADR count, runbook coverage)

Each dimension scored 0-100 with 4 sub-criteria (25 points each). Weights configurable per project via `.claude/audit-weights.yaml`.

## Output artefacts

- `reports/current/14-dim-scorecard.md` — per-dimension score + 4 sub-criteria + target-state + gap
- `reports/current/14-dim-grade.yaml` — composite grade A-F + headline summary
- `reports/current/14-dim-action-plan.md` — prioritized list of top-10 gaps by leverage (impact × effort)

## Example verdict

```
Composite grade: B-  (67 / 100)
Passing dimensions (>=75): Architecture, Testing, Type Safety, CI/CD, Plugins, API Design
At-risk dimensions (50-74): Observability, Documentation, Infrastructure, Frontend, Duplication
Blocking dimensions (<50): Secrets (42), Dependencies (38), Data Validation (45)
```

## Safety

- Read-only by design (no writes outside `reports/current/`)
- Runs in parallel — long operation (10-20 minutes depending on repo size)
- Does NOT replace operator judgment; the grade is a starting point, not a verdict

## Related

- `.claude/skills/fourteen-dimension-audit/SKILL.md` — skill definition
- `/director komple` — program-level audit (broader scope, less dimension-specific depth)
- `docs/runtime/audit-scoring-framework.md` — canonical scoring rubric per dimension
