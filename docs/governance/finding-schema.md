# Canonical Finding Schema

## Why this exists

Findings drift in format across agents and runs. Without a schema, one agent writes "admin panel is vulnerable", another writes "CSRF risk in /admin/users POST", and the manager-verdict has to guess which is the same issue. A canonical schema makes findings mergeable, searchable, and traceable.

## Schema

Every serious finding produced by any specialist or the director must conform to this YAML:

```yaml
id: FIND-001                              # monotonic per run, per project
area: security|ux|frontend|backend|infra|api|seo|store|mobile|analytics|localization|market|prompt|design-system|data|privacy|release
title: ""                                 # one-line, noun phrase
problem: ""                               # what is wrong, 1-3 sentences
evidence: ""                              # file:line or URL or log ref
evidence_source: ""                       # same as above but structured
evidence_trust: T1|T2|T3|T4|T5|T6|T7      # see evidence-trust-scoring.md
completeness_risk: low|medium|high
contradiction_status: none|partial|direct
impact: ""                                # what breaks and for whom
severity: Critical|High|Medium|Low
priority: P0|P1|P2|P3
recommended_fix: ""                       # concrete action
validation: ""                            # how to prove the fix works
owner: ""                                 # which specialist / lane / role
depends_on: []                            # list of FIND-* ids
tags: []                                  # quick-win|foundational|strategic|compliance|release|guardrail|research|localization|pack
```

## Required fields

These are non-optional. A finding missing any of them is rejected:

- `id`
- `area`
- `title`
- `problem`
- `evidence`
- `evidence_trust`
- `severity`
- `recommended_fix`
- `validation`

## Severity vs priority — they are different

- **Severity** — how bad is the thing itself (objective)
- **Priority** — when we should fix it (contextual)

A Critical severity may be P2 priority if it only affects a surface that is being deprecated next week. A Medium severity may be P0 if it's blocking a release. Always think about both.

## ID rule

Use `FIND-001`, `FIND-002`, ... monotonic inside one run. Do not reuse IDs across runs. The director's Phase 4 synthesis pass is responsible for assigning final IDs.

## Merge rule

When two specialists produce findings that are the same underlying issue, the director merges them:

- Keep the lowest severity? **No**. Keep the highest.
- Keep the lowest trust tier? **No**. Keep the highest (lowest number, best evidence).
- Combine `evidence` lists.
- Union `tags`.
- Union `depends_on`.
- Record the original specialists in a `merged_from:` field.

## Output artefacts that use this schema

- `reports/current/evidence-register.md` — raw specialist bullets, already in this schema
- `reports/current/analysis-findings.md` — synthesis pass, merged findings
- `reports/current/deep-scan-report.md` — ranked by severity + priority
- `reports/current/did-you-know.md` — non-obvious findings, same schema + `surprise: true` tag
- `reports/current/manager-verdict.md` — links to top findings by severity

## Hard rules

- No finding without evidence.
- No evidence without a trust tier.
- No severity without a recommended_fix.
- No recommended_fix without a validation step.
- No "Critical" severity on T6 or T7 evidence — the best you can do is "Critical (hypothesis — needs T2 or T3 confirmation)".
