---
name: fourteen-dimension-audit
description: Run a 14-dimension audit scorecard on any repo (Architecture, Testing, Secrets, Observability, CI/CD, Duplication, Dependencies, Type Safety, Plugins, API Design, Infrastructure, Frontend, Data Validation, Documentation). Produces per-dimension 0-100 scores, target state, gap analysis, and A-F grade. Use for project baselines, post-modernization verification, or quarterly health reports.
context: fork
agent: architecture-lead
allowed-tools: Read Grep Glob Bash
---

# 14-Dimension Codebase Audit

## Goal

Turn a narrative audit into a numeric, comparable scorecard. Every run produces the same 14 dimensions; runs separated by time become deltas. Projects become comparable.

## When to use

- **Baseline** — before starting a modernization program
- **Target setting** — when defining the roadmap (what's the B-grade target?)
- **Progress check** — monthly during a program (track deltas)
- **Release gate** — at each major version (was this release a regression in any dimension?)

Do NOT invoke mid-sprint (noise > signal) or on <2 weeks of changes (too few commits to move a dimension).

## Inputs

- `repo_path` — absolute path to repo root
- `rubric_file` (optional) — JSON or YAML rubric overriding default thresholds; falls back to built-in per-dimension rubric from `docs/runtime/audit-scoring-framework.md`
- `weight_override` (optional) — JSON mapping dimension name → weight (default: equal weights for all 14)

## Outputs

- `reports/current/audit-scorecard.md` — per-dimension 0-100 scores + narrative
- `reports/current/audit-scorecard.yaml` — machine-readable scores for delta comparison
- Target column (per dimension) + gap analysis + A-F grade
- Recommended priority order for closing gaps

## The 14 dimensions

1. Architecture — layering, coupling, Strangler-Fig-migratability
2. Testing — coverage %, test types (unit/integration/E2E), flake rate
3. Secret management — key handling, rotation, pre-commit gitleaks
4. Observability — structured logs, metrics, tracing, dashboards, alerts
5. CI/CD quality — gates, rollback, reproducibility
6. Code duplication — DRY enforcement, cross-module reuse
7. Dependency hygiene — pin strategy, audit cadence, SBOM presence
8. Type safety — strict mode, `any` count, typed boundaries
9. Plugin/extension system — BasePlugin contract, discoverability
10. API design — OpenAPI, versioning, contract tests
11. Infrastructure — containers, compose layering, security hardening
12. Frontend — design system, tokens, per-page discipline
13. Data validation — schema at boundaries, DB check constraints
14. Documentation — README, setup, ADRs, runbooks, changelogs

## Scoring rubric (condensed)

Per dimension:

- **0–40 (F range)**: structural gaps, no discipline, active risk
- **41–70 (C/D range)**: some discipline, inconsistent application, known gaps with roadmap
- **71–100 (A/B range)**: systematic discipline, minor polish gaps

Full rubric in `docs/runtime/audit-scoring-framework.md` §The 14 dimensions.

## Grade mapping

| Average | Grade |
|---|---|
| 90–100 | A |
| 80–89 | B |
| 70–79 | C |
| 60–69 | D |
| <60 | F |

## Process

1. Read `runtime-manifest.md` to understand stack (inferred dimensions differ by stack)
2. For each dimension, collect evidence:
 - Query the filesystem (file counts, test counts, coverage report, dependency file contents)
 - Query git history (commit cadence, bug-vs-feature ratio, dependency drift)
 - Cross-reference findings from other specialists (evidence-register.md hits per dimension lower the score)
3. Apply the rubric to score 0-100 per dimension
4. Compute weighted average + grade
5. For each dimension below 70, propose a gap-closing roadmap item with effort estimate

## Example output shape

```yaml
audit:
 date: 2026-04-18
 repo: stack: [python, fastapi, nextjs, docker]
 dimensions:
 architecture: { current: 20, target: 75, delta_needed: 55 }
 testing: { current: 15, target: 70, delta_needed: 55 }
 #... 12 more
 average: 37.5
 target_average: 77.9
 grade: F
 target_grade: B-
 priority_dimensions: [architecture, testing, secret_management, observability]
```

## Rules

- Use T1/T2 evidence (file reads, commands) for scoring — avoid T7 (guessing)
- Do NOT score a dimension if evidence is too sparse — mark as `insufficient_evidence`
- Weight overrides must be justified in the output (e.g. "data pipeline weights Data Validation 2x")
- Delta runs require the previous scorecard's YAML for comparison
- Consumer of this skill (director or operator) decides which gaps enter the roadmap

## Integration

- `docs/runtime/audit-scoring-framework.md` — the full per-dimension rubric
- `docs/runtime/anti-patterns.md` — anti-pattern hits lower the relevant dimension's score
- `reports/current/analysis-findings.md` — findings feed into dimension scores
- `reports/current/execution-roadmap.md` — gap-closing items come from here
