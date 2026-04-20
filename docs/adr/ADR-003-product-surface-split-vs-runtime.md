# ADR-003 — Product Surface Split Distinct from Runtime Surface Split

**Status**: Accepted · **Date**: 2026-04-20 · **Release**: v2.1.3

## Context

Ulak OS's core contract (runtime-defaults) has long included the rule "customer/admin/public api ayrımını koru" (maintain customer/admin/public API separation). But there was no dedicated governance doc defining what that rule means in practice.

Separately, `docs/governance/surface-split.md` already existed — but it covered something entirely different: the **runtime surface split** between Public Runtime (Layer 1: what the model loads), Hidden Core (Layer 2: maintainer-only history), and Maintainer (Layer 3: release tooling).

Two unrelated concepts called "surface split" — easy to confuse.

The v2.1.3 scanner-project-pattern-extraction pass surfaced a fourth product surface emerging in mature portfolio products: **partner / reseller / bayi**. This tier has its own authz gate (plan capability, not role), its own data model (parent/child user mapping), and its own branding / white-label story.

## Decision

Create `docs/governance/product-surface-split.md` as a **new, distinct** governance doc. Keep `docs/governance/surface-split.md` as-is (runtime layers). Both names are retained despite the shared term because renaming either would break existing adapter docs and release history.

The new doc documents the **four-surface model**:

| Surface | Auth gate |
|---|---|
| Public | None |
| Customer | Valid JWT |
| Admin | Valid JWT + DB-sourced admin role (NEVER `user_metadata`) |
| Partner / Reseller / Bayi | Valid JWT + plan capability (not role) |

Plus hard rules for separation, authz source discipline, failure handling (401 vs 403), and surface-specific considerations.

## Alternatives considered

1. **Rename `surface-split.md` to `runtime-surface-split.md`** and call the new one `surface-split.md` — rejected because renaming would cascade through CHANGELOG, release notes, adapter docs, and operator mental models. Too much breakage for a cosmetic gain.
2. **Merge both into one document** — rejected because the concerns are orthogonal (runtime layering vs product authz boundaries). Merging would create a 400-line doc that covers two topics poorly.
3. **Live with the collision** (no new doc) — rejected because operators need the discipline captured; "customer/admin/public api ayrımını koru" without backing doc is aspirational, not enforceable.

## Consequences

**Positive**:
- Product-surface rules are now a first-class governance doc that specialists dispatch against
- Admin-persona, customer-persona, bayi-persona agents have a clear doc to cite in findings
- The four-surface model scales to reseller-enabled products without needing a fifth concept

**Negative**:
- Two docs named "surface split" require explicit disambiguation in every cross-reference (mitigated by a prominent note at the top of each file pointing to the other)
- Operators may google "Ulak OS surface split" and need to learn which is which (documented in ADRs + CHANGELOG)

**Migration**:
- `CLAUDE.md` runtime-defaults: "customer/admin/public api ayrımını koru" now has a backing doc
- Core contract imports: added `@docs/governance/product-surface-split.md`
- Every persona agent + security-hardening-lead now references this doc

## References

- `docs/governance/product-surface-split.md` — the new doc
- `docs/governance/surface-split.md` — the runtime-layer doc (unchanged)
- `CHANGELOG.md §[2.1.3]` — G-06 line item under Governance docs
- v2.1.3 open question #3 — "Surface-split naming: KEEP BOTH"
