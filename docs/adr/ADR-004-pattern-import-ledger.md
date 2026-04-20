# ADR-004 — Pattern Import Ledger for Cross-Project Governance

**Status**: Accepted · **Date**: 2026-04-20 · **Release**: v2.2.0 · **First live entry**: v2.2.0 IL-001

## Context

Operators running ≥2 products in parallel inevitably copy patterns between projects (a CMS shape from project A to project B, a docker-proxy sidecar from template library to project C). Without a record, three drifts emerge:

1. **Provenance loss** — developer reading the consuming project can't tell "where did this come from"
2. **Upstream drift** — a bug fixed in the source project isn't backported to consumers; a security patch in the source doesn't reach the copies
3. **Divergence erosion** — intentional project-specific differences (A uses JSONB, B uses Postgres rows) get forgotten; later maintainers "fix" them back to the source shape, losing the intent

The v2.1.3 scanner-project-pattern-extraction pass observed this shape directly: a security scanner project had imported CMS + blog + site-settings + integration-definitions patterns from a monorepo e-commerce project, but with zero provenance markers. A verification scan in v2.2.0 confirmed T1 evidence of the imports but found no ledger tracking them.

## Decision

Introduce `docs/governance/pattern-import-ledger.md` (the governance doc) + `docs/governance/pattern-import-ledger.yaml` (the per-project data file).

Each consuming project maintains a `pattern-import-ledger.yaml` with entries like:

```yaml
imports:
  - id: IL-001
    pattern_name: "CMS + blog + site-settings surface"
    source_project: "..."
    source_commit: "<sha>"
    source_files: ["..."]
    target_files: ["..."]
    imported_on: "YYYY-MM-DD"
    divergence_notes: "..."
    upstream_fixes_pending: []
```

Architecture-lead dispatches read the ledger at every Phase 2 sweep and run `git log source_commit..HEAD` on the source repo to detect new upstream commits that might be relevant bugfixes/security patches. Those become backport findings.

## Alternatives considered

1. **Git submodule for shared patterns** — rejected because patterns diverge intentionally after import; submodule forces lockstep, which isn't the shape
2. **Monorepo with shared `packages/` directory** — rejected because the operator runs separate repos per product (different deploy cadences, different teams, different compliance profiles)
3. **No ledger; rely on developer memory** — rejected because that's the current broken state
4. **Embed provenance in source code comments** — rejected because code comments rot; structured YAML is queryable and lintable

## Consequences

**Positive**:
- Cross-project drift becomes a detectable finding (not a silent failure)
- Upstream bugfixes propagate via the architecture-lead audit cadence
- Intentional divergence is documented, not accidental
- The ledger doubles as supply-chain documentation (same family as `prompt-supply-chain.md`)

**Negative**:
- Operators must remember to add ledger entries when copying patterns (first offense easily forgotten; mitigated by v2.2.x adding ledger-entry reminder to greenfield-saas-starter scaffolder)
- Source-project git history can be large; running `git log source_commit..HEAD` on every audit is slow for decade-old repos (mitigated by limiting to last 90 days + explicit relevance review)

**Migration**:
- v2.1.3 introduced the governance doc + pattern
- v2.2.0 added first live entry (IL-001) with T1 evidence, closing R4 residual risk from the v2.1.3 self-audit
- v2.2.2 greenfield-saas-starter scaffolder seeds an empty `pattern-import-ledger.yaml` in every new project so the discipline starts at commit 1

## References

- `docs/governance/pattern-import-ledger.md` — governance doc
- `CHANGELOG.md §[2.2.0]` — IL-001 first live entry
- v2.1.3 residual risk R4 — closed in v2.2.0
- `docs/governance/prompt-supply-chain.md` — sibling supply-chain concept
