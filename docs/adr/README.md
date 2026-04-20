# Architecture Decision Records (ADRs)

This directory captures major technical and process decisions. One file per decision; never retroactively edit after acceptance (amend via a new ADR that supersedes).

## Format

Each ADR follows this structure:

- **Title** (ADR-NNN — Short description)
- **Status** (Proposed · Accepted · Deprecated · Superseded-by-ADR-MMM)
- **Date** (ISO YYYY-MM-DD)
- **Release** (which Ulak OS release this ADR was accepted in)
- **Context** (why this decision is being made now)
- **Decision** (what was decided)
- **Alternatives considered** (what was rejected and why)
- **Consequences** (positive, negative, migration)
- **References** (cross-links to docs, CHANGELOG, specs)

## Current ADRs

| ID | Title | Status | Release |
|---|---|---|---|
| [ADR-000](./ADR-000-pack-foundation.md) | Pack foundation | Accepted | v1.0.0 |
| [ADR-001](./ADR-001-rule-packs-seventh-unit-type.md) | Rule packs as 7th unit type | Accepted | v2.1.3 |
| [ADR-002](./ADR-002-phase-5-terminal.md) | Phase 5 as terminal phase (Numbering A) | Accepted | v2.1.3 |
| [ADR-003](./ADR-003-product-surface-split-vs-runtime.md) | Product surface split distinct from runtime | Accepted | v2.1.3 |
| [ADR-004](./ADR-004-pattern-import-ledger.md) | Pattern import ledger for cross-project governance | Accepted | v2.2.0 |
| [ADR-005](./ADR-005-saas-scaffolder.md) | SaaS scaffolder produces full-stack SaaS from commit 1 | Accepted | v2.2.2 |

## When to write an ADR

Write an ADR when the decision:

- Affects more than one file / module / surface
- Has non-trivial alternatives that a future maintainer might want to revisit
- Is hard to reverse (governance additions, schema changes, phase numbering)
- Changes cross-vendor (claude / codex / gemini) behavior
- Introduces a new concept (new unit type, new surface, new phase)

Do NOT write an ADR for:

- Routine bug fixes
- Dependency updates
- Single-file documentation improvements
- Trivially reversible choices (CI job order, script naming)

## Integration

- `docs/governance/prompt-supply-chain.md` — version discipline that ADRs feed
- `CHANGELOG.md` — each ADR-accepted release's changelog entry links to the ADR
- `docs/history/version-lineage.md` — major ADRs cross-referenced in version lineage
