# Walkthrough 01 — `/director komple` on a brownfield ExampleCorp SaaS

A fictional operator runs `/director komple` against **ExampleCorp Suite**, a brownfield Next.js + Supabase SaaS that has been in production for 14 months. The project is a multi-locale (tr / en / de) content-ops platform used by internal editors plus partner agencies. This walkthrough shows every phase of the protocol end-to-end.

## Operator intent

```
> /director komple brownfield audit mode=REPAIR
```

The operator opens the Claude Code session in the ExampleCorp Suite repo root and invokes the director with a `REPAIR` intervention mode hint. No scope menu opens — intent is clear.

## Phase 0 — Environment lock

The director writes `reports/current/runtime-manifest.md` and `active-variables.yaml`:

```yaml
# reports/current/active-variables.yaml
project_state: BROWNFIELD
intervention_mode: REPAIR
output_profile: AUDIT_PROFILE
output_language: tr
scope: whole-repo
live_probe_required: true           # Supabase + VPS reachable from operator workstation
dispatch_mode: specialist
validation_depth: standard
persona_set: []                     # not a persona run

rule_packs_loaded:
  - typescript-nextjs
  - docker-compose
  - api-security
  - turkish-locale
  - localization-ssot

sector_packs_activated:
  - saas
  - content-ops
  - multi-tenant-supabase
  - vps-nginx-compose-topology

broken_locks: []
worktree_health: clean
```

`assumptions.md` records: repo is checked out at `main`, last commit is 4 days old, `.env.local` is git-ignored correctly, `pnpm-lock.yaml` is up to date, Supabase CLI is installed locally.

## Phase 1 — Deep inventory

The `cartographer` specialist walks the repo. `inventory.md` is 380 lines with file:line citations. A sampled excerpt:

```
### Application surfaces

Customer surface (app/(customer)/)
- app/(customer)/dashboard/page.tsx:1-82         — server component, renders KPIs
- app/(customer)/dashboard/[workspaceId]/page.tsx:1-140 — workspace detail
- app/(customer)/billing/page.tsx:1-96           — Iyzico invoice list
- app/(customer)/settings/profile/page.tsx:12-145 — profile form (client)

Admin surface (app/(admin)/admin/)
- app/(admin)/admin/users/page.tsx:1-119         — tenant user list
- app/(admin)/admin/audit-log/page.tsx:1-76      — audit trail viewer
- app/(admin)/admin/export/page.tsx:1-52         — full-export tooling

API routes
- app/api/customer/workspace/route.ts:1-88       — GET+POST, RLS enforced
- app/api/admin/users/route.ts:1-104             — admin-only, uses requireAdmin()
- app/api/public/health/route.ts:1-18            — unauthenticated health
- app/api/webhooks/iyzico/route.ts:1-142         — payment callback

Data layer
- supabase/migrations/00001_initial.sql          — 6 tables, RLS on 5 of them
- supabase/migrations/00004_add_audit_log.sql    — audit_log table, RLS absent
- supabase/migrations/00007_workspace_sharing.sql — sharing table, RLS present
...
```

The inventory notes **RLS absent on `audit_log`** — this will matter in Phase 3.

## Phase 2 — Parallel specialist evidence

The director dispatches three specialists in a single parallel batch: `security-hardening-lead`, `data-database-governor`, `architecture-lead`. Each returns a per-specialist artefact under `reports/current/specialists/`.

Merged highlights in `evidence-register.md`:

**Security (`security-hardening-lead`)**
- `F-SEC-01 [Critical T1]` — `app/api/webhooks/iyzico/route.ts:34` verifies HMAC on empty body when payload parse fails; AP-18 pattern. File:line cited. Fix: sign full body + timestamp + nonce before parse.
- `F-SEC-02 [High T1]` — `app/api/admin/export/route.ts:1-67` has no rate limit on a bulk-export endpoint that returns full tenant data.
- `F-SEC-03 [Medium T2]` — `.env.example:22` lists `SUPABASE_SERVICE_ROLE_KEY` alongside client-side env vars; risk of accidental client exposure if a developer pastes one into the wrong scope.

**Data (`data-database-governor`)**
- `F-DATA-01 [Critical T1]` — `supabase/migrations/00004_add_audit_log.sql` creates `audit_log` but never issues `ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY`. Every tenant can query every other tenant's audit entries.
- `F-DATA-02 [High T1]` — `00007_workspace_sharing.sql:23` policy uses `auth.uid()` but the workspace foreign key isn't indexed; sharing-list queries scan the full table.
- `F-DATA-03 [Medium T2]` — No database backup script committed; `scripts/` lacks `backup-db.sh`. AP-17.

**Architecture (`architecture-lead`)**
- `F-ARCH-01 [High T1]` — `lib/auth/index.ts` coexists with `lib/auth/requireAdmin.ts` and `middleware.ts` each reading `user.role` via separate paths. Three-way auth resolution is AP-11 risk.
- `F-ARCH-02 [Medium T2]` — `components/` has both `components/ui/` and `components/shared/` with visually similar primitives; design system drift.

## Phase 3 — Did-you-know

The director extracts five non-obvious findings into `did-you-know.md`:

1. **RLS asymmetry between `audit_log` and `sessions`.** `sessions` (migration 00001) has RLS enabled with a tight `user_id = auth.uid()` policy, but `audit_log` (migration 00004) has RLS omitted entirely. Any tenant can `SELECT * FROM audit_log`. The operator did not ask about this; it was never flagged during the original audit. **File:line**: `supabase/migrations/00004_add_audit_log.sql:1-28`.

2. **Locale drift between tr.json and en.json.** 47 keys exist in `docs/i18n/tr.json` that are missing from `en.json`; 12 keys in `en.json` are missing from `tr.json`. English-speaking users see raw keys in several admin forms. **File:line**: `docs/i18n/tr.json:1-312` vs `docs/i18n/en.json:1-277`. Tool: `diff <(jq keys tr.json) <(jq keys en.json)`.

3. **Cert auto-renew has no failure fallback.** `infrastructure/nginx/` uses certbot with a weekly cron, but `scripts/deploy.sh` has no check for cert validity before reload. If certbot fails silently for > 60 days, the deploy reloads nginx with an expired cert and the site returns TLS errors. **File:line**: `infrastructure/nginx/site.conf:12`, `scripts/deploy.sh:45`.

4. **N+1 in workspace dashboard.** `app/(customer)/dashboard/[workspaceId]/page.tsx:67-89` iterates workspaces and fetches collaborators per workspace. With 40 workspaces, the dashboard issues 41 DB round trips. Supabase RPC or a single JOIN would replace it.

5. **Dead dependency.** `package.json:52` still lists `@tanstack/react-query@5.12` but every query hook in `lib/queries/` was migrated to Server Actions three months ago. The package adds 92 kB to the client bundle for zero usage.

None of these was in the operator's original "audit my brownfield" request. All are in the evidence because the specialists looked.

## Phase 4 — Synthesis

Five files written. A condensed summary:

**`analysis-findings.md`**: 11 findings total (3 Critical, 4 High, 4 Medium). Critical are F-SEC-01, F-DATA-01, and a new synthesized finding combining the RLS + no-backup combo.

**`target-state.md`**: audit-log with RLS + tenant-scoped query policy, webhook signing per AP-18 fix, single auth helper + removed duplicates, locale parity enforced in CI, cert validity check in deploy.

**`execution-roadmap.md`**: three Waves.
- Wave 1 (blocking, parallel): fix RLS on audit_log · fix webhook signing · fix admin export rate limit
- Wave 2 (high, sequential): consolidate auth helpers · add locale-parity CI check · add cert validity check · add backup script
- Wave 3 (medium, parallel): remove dead dependency · fix N+1 · design system consolidation

**`validation-plan.md` §6 (live probes)**:
- `LP-01` — query `audit_log` as tenant A; expect zero tenant B rows (pre-fix: fails; post-fix: passes)
- `LP-02` — call `/api/webhooks/iyzico` with empty body + valid HMAC on old code; expect accept (pre-fix, confirms vulnerability); then with fix, expect 400
- `LP-03` — verify cert expiry via `openssl s_client`; expect > 30 days

**`pack-gap-register.md`**: the `/locale-parity-check` command is missing from the pack — it's a recurring need but hasn't been extracted.

## Phase 4.5 — Live probes

Operator supplies Supabase service-role key. The director runs LP-01 read-only; probe confirms F-DATA-01 (tenant isolation broken). LP-01 upgrades from T1 (inferred from migration inspection) to T0 (confirmed by direct query). LP-03 confirms cert has 14 days left — closer to the threshold than expected; this becomes a new finding NF-01 in `did-you-know.md`.

## Phase 5 — Manager verdict

```yaml
# reports/current/validation-result.yaml
signoff_status: conditional
phase_status:
  phase_0: complete
  phase_1: complete
  phase_2: complete
  phase_3: complete
  phase_4: complete
  phase_4_5: complete
  phase_5: complete
critical_findings_open: 2           # F-SEC-01, F-DATA-01 (Wave 1 pending)
high_findings_open: 3
blockers_before_ready:
  - Wave 1 execution must ship
  - LP-02 must confirm webhook fix
  - backup script must land
next_execution_lane: waves
residual_risks:
  - NF-01 cert expiry in 14 days — schedule renewal within 7 days
  - F-ARCH-02 design system drift — defer to next quarter
```

`manager-verdict.md` narrative summary (Turkish per `output_language`): "Üç kritik bulgu var. Wave 1 blocking; yama-deploy pattern'i kullan. Phase 2 specialist'leri paralel çalıştı, did-you-know beş non-obvious finding çıkardı. Signoff conditional — Wave 1 shipten sonra re-validate ederek ready'e geçilecek."

## What the operator got

- `reports/current/` with 12 artefact files totaling ~1200 lines
- Three Critical findings with cited file:line + fix instructions + live-probe validation
- Five non-obvious findings the operator did not ask about but should fix
- A pack gap (`/locale-parity-check`) to extract next release
- A residual risk log that survives into the next director run

Total run time: ~18 minutes wall clock. The operator now has a ship-ready roadmap with no hand-waving.
