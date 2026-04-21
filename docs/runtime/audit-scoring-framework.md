# Audit Scoring Framework — 15 Dimensions

## Why this exists

When the director runs `/director komple` on a project, the output is rich but narrative — 85 findings, 7 themes, 5 P0 blockers. That's actionable but not comparable. Question: "Is this project healthier than it was three months ago?" Answer: narrative can't tell you.

A **14-dimension scorecard** adds numeric comparability. Each dimension gets a score 0–100, aggregated into a grade A–F. Runs separated by time produce deltas ("Architecture went 45 → 72, Testing still stuck at 30"). Projects can be compared ("this codebase is at grade C+; target grade B by end of quarter"). The framework was the baseline for modernization (47.5 → 85 target across 18 weeks).

## The 14 dimensions

Each dimension is scored 0–100. Scoring rubric per dimension lives in `scripts/audit-scoring/<dimension>.rubric.md` (shipped in Wave 4). A summary of the rubric for each:

| # | Dimension | 0–40 | 41–70 | 71–100 |
|---|---|---|---|---|
| 1 | **Architecture** | Monolith, no layering, high coupling | Some layering, inconsistent boundaries | Clean layers, clear boundaries, Strangler-Fig-migratable |
| 2 | **Testing** | <5% coverage, brittle tests | 20–50% coverage, some integration | ≥80% coverage, E2E for critical flows, fast suite |
| 3 | **Secret management** | Keys in code / committed files | Env vars with some discipline | Secret manager, rotation documented, pre-commit gitleaks |
| 4 | **Observability** | Print statements, no structured logs | JSON logs, some metrics | Structured logs + metrics + tracing, dashboards, alerts |
| 5 | **CI/CD quality** | Manual deploys, no gates | CI present but non-blocking gates | CI blocking, rollback automated, deploys reproducible |
| 6 | **Code duplication** | Obvious duplication >5 places | Some duplication in edge cases | DRY enforced by convention, cross-module reuse |
| 7 | **Dependency hygiene** | Unpinned versions, unused deps | Pinned but no audit cadence | Pinned + dependabot + audit + SBOM |
| 8 | **Type safety** | Untyped or `any`-heavy | Mostly typed, some escape hatches | Strict mode, no `any`, typed boundaries |
| 9 | **Plugin / extension system** | Monolith, no extension point | Hardcoded plugin registry | Discoverable plugins, BasePlugin contract, tested in isolation |
| 10 | **API design** | Inconsistent endpoints, undocumented | OpenAPI spec exists, mostly matches | Contract-tested, versioned, discoverable via schema |
| 11 | **Infrastructure** | No containers, manual ops | Docker + compose, some hardening | Compose + prod layering + security_opt + mem_limit + healthchecks |
| 12 | **Frontend** | Unstyled, no components, no system | Components but no design system | Design system + tokens + per-page overrides |
| 13 | **Data validation** | No schema at any boundary | Schema at API, no DB constraint | Pydantic/zod at API + DB check constraints + contract tests |
| 14 | **Documentation** | README only, stale | README + setup + some runbooks | README + setup + ADRs + runbooks + changelogs |
| 15 | **Performance (web)** | No Core Web Vitals tracking; Lighthouse never run | CWV tracked in prod; p95 LCP/INP/CLS under Google thresholds | CWV as SLO + Lighthouse CI on every PR (harlan-zw/unlighthouse / GoogleChrome/lighthouse-ci); performance budget blocks regression |

## Aggregation

Total score = average of 14 dimensions (equal weights by default; dimension-specific weights allowed if a project is intentionally skewed — e.g. a data pipeline weights Data Validation higher).

Grade mapping:

| Score | Grade | Meaning |
|---|---|---|
| 90–100 | A | Exemplary; project is a reference for other teams |
| 80–89 | B | Good; minor gaps, safe to scale |
| 70–79 | C | Acceptable; known gaps, roadmap to fix |
| 60–69 | D | At risk; major gaps, immediate action needed |
| <60 | F | Failing; structural issues blocking further growth |

## When to run scoring

- **Baseline** — before starting a modernization program (set the "current" snapshot)
- **Target** — when defining the roadmap (what's the B-grade target?)
- **Progress** — monthly during the program (track deltas)
- **Release** — at each major version (was this release a regression in any dimension?)

Do NOT run scoring:

- Mid-sprint (noise > signal)
- On <2 weeks of changes (too few commits to move a dimension)

## Worked example — baseline

Scores at Sprint 0 (the director audit baseline):

| Dimension | Current | Target |
|---|---|---|
| Architecture | 20 | 75 |
| Testing | 15 | 70 |
| Secret mgmt | 10 | 85 |
| Observability | 10 | 60 |
| CI/CD | 25 | 80 |
| Code duplication | 30 | 70 |
| Dependency hygiene | 40 | 75 |
| Type safety | 65 | 90 |
| Plugin system | 55 | 80 |
| API design | 50 | 80 |
| Infrastructure | 60 | 85 |
| Frontend | 70 | 85 |
| Data validation | 30 | 80 |
| Documentation | 45 | 75 |
| **Average** | **37.5** | **77.9** |
| **Grade** | **F** | **B-** |

The 85-item roadmap closed the gap wave by wave; the "before/after" column in final-executive-report.md tracks the move.

## Skill-form executor

`.claude/skills/fourteen-dimension-audit/` (Wave 4) runs the scoring pass automatically: input = repo path + rubric; output = per-dimension JSON + narrative + target column.

## Integration

- `docs/runtime/sector-packs.md` — some sectors weight dimensions differently (fintech weights Secret mgmt + Data validation; media weights Frontend)
- `docs/runtime/anti-patterns.md` — anti-pattern hits pull down the corresponding dimension's score
- `docs/runtime/audit-scoring/<dimension>.rubric.md` — per-dimension scoring detail (stubbed in v2.1.3, detailed in v2.2)
- `reports/current/analysis-findings.md` — findings feed into dimension scores
- `.claude/skills/fourteen-dimension-audit/SKILL.md` — executable skill form

## Canonical footer

Authoritative as of Ulak OS **v2.1.3**. md:107-161` and `final-executive-report.md:22-52`.
