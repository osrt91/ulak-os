# Cartography v2.2 — 2026-04-21 (PARTIAL)

**Agent**: cartographer
**Status**: STALLED at 600s watchdog
**Scope**: post-v2.2.0 cartography sweep

## Captured inline finding

> "components/admin and components/customer dirs do NOT exist, even though pages import heavily from them. This is a massive cross-ref integrity gap."

## Cross-ref gap (confirmed by orchestrator read)

Auth / customer / admin / partner page templates (v1.1 B.1a) import from:
- `@/components/ui/*` ✓ exists (15 primitives from B.1c + B.4)
- `@/components/auth/login-form` ✓ exists (B.1c)
- `@/components/shared/{header,footer}` ✓ exists (B.1c)
- `@/components/dashboard/{sidebar,top-bar,empty-state,stat-tile,system-health-card}` ✓ partial (sidebar, top-bar, empty-state from B.4; stat-tile + system-health-card referenced but missing)
- `@/components/admin/*` ✗ **MISSING** (used by admin layout + users + audit-log)
- `@/components/customer/*` ✗ **MISSING** (used by customer layout + dashboard + settings)
- `@/components/partner/*` ✗ **MISSING** (used by partner layout + page + sub-users)
- `@/components/settings/{profile-form,account-form,preferences-form,billing-panel,team-panel}` ✗ **MISSING**

## Impact

Scaffolder run would produce a Next.js project that fails `pnpm typecheck` on every authenticated-surface page. Operator experience: `pnpm dev` works (Next.js is forgiving in dev) but `pnpm build` fails. This is a P0 blocker for the "production-ready at commit 1" claim.

## Action required

Create stub components under:
- `templates/saas-starter/components/admin/*` — at minimum `user-row-actions.tsx`, `audit-log-filters.tsx`, `tenant-stats-card.tsx`
- `templates/saas-starter/components/customer/*` — at minimum `welcome-card.tsx`, `quick-actions-grid.tsx`, `recent-activity-list.tsx`
- `templates/saas-starter/components/partner/*` — at minimum `commission-chart.tsx`, `sub-users-table.tsx`, `payout-status-card.tsx`
- `templates/saas-starter/components/dashboard/{stat-tile,system-health-card}.tsx.template`
- `templates/saas-starter/components/settings/*` — 5 form components

Total: ~15-20 missing component templates.

## Deferred

Full cartography report (file-count per surface, cross-ref matrix, orphan detection, duplication audit, sector overlap matrix, docker/k8s coherence) not produced due to stall. Re-dispatch after missing components land.

## Signoff

`signoff_status: blocked` — missing component templates break post-scaffold `pnpm build`. Must fix before next public scaffold-readiness claim.
