# Cross-Tenant RLS Verification

## Why this exists

When multiple tenants share a single Postgres (or Supabase) instance with schema-level isolation, Row-Level Security policies are the only thing preventing cross-tenant data access. Writing RLS is easy. **Testing that RLS actually isolates** is the missing discipline.

Observed across projects: `NEXT_PUBLIC_SUPABASE_URL` points to a shared Supabase instance; `NEXT_PUBLIC_SUPABASE_SCHEMA` varies per project. Each project declares its own RLS policies. Nobody verifies at runtime that Project A's service-role key cannot read Project B's tables.

This doc is the discipline. RLS intent + tests for RLS intent = isolation guarantee. Without tests, a single missed policy leaks every tenant.

## When to apply

Apply when **all** are true:
- Multi-tenant data plane (≥2 tenants on same Postgres / same Supabase instance)
- RLS is the primary isolation mechanism (not per-tenant database + per-tenant credentials)
- Service-role key OR admin-scope tokens exist (these bypass RLS by design; blast radius depends on scope)

Do NOT apply when:
- Each tenant has its own Postgres instance (isolation is at connection level, not row level)
- RLS is decorative (authorization is enforced at application layer; RLS is backup)

## The verification protocol

Every release that touches RLS, schema, or service-role usage MUST run cross-tenant verification as part of Phase 5 §5c (validation gates).

### Step 1 — enumerate schemas

```sql
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('public', 'pg_catalog', 'information_schema', 'auth', 'storage', 'realtime')
ORDER BY table_schema, table_name;
```

Expected: one row per tenant-scoped table. A schema per tenant (e.g., `tenant_a`, `tenant_b`) is the clean pattern. A shared `public` schema with `tenant_id` column is the alternative — tested differently (see Step 4).

### Step 2 — enumerate policies

```sql
SELECT schemaname, tablename, policyname, cmd, qual, with_check
FROM pg_policies
WHERE schemaname NOT IN ('pg_catalog', 'information_schema');
```

Expected: every user-facing table has a policy. Missing a policy = default-deny (good) OR default-allow (catastrophic — depends on PG version + grant state). Record missing-policy tables as a finding.

### Step 3 — cross-tenant probe (anon)

For every tenant schema, attempt a `SELECT` from an unauthenticated (anon) session:

```sql
SET ROLE anon;
SET search_path TO tenant_a;
SELECT * FROM orders LIMIT 1;
-- Expected: 0 rows OR permission-denied
```

If any tenant schema returns data from `anon` session when it shouldn't → **critical finding** (default-allow, missing RLS).

### Step 4 — cross-tenant probe (authenticated as tenant_a, reading tenant_b)

This is the hard part. An auth'd user in tenant_a should NOT be able to read tenant_b's data.

For shared-schema + tenant_id pattern:

```sql
SET ROLE authenticated;
SET request.jwt.claim.tenant_id = 'tenant_a_uuid';
SELECT * FROM orders WHERE tenant_id = 'tenant_b_uuid' LIMIT 1;
-- Expected: 0 rows (RLS policy filters by jwt.tenant_id)
```

For schema-per-tenant pattern:

```sql
SET ROLE authenticated_tenant_a;
SET search_path TO tenant_b;
SELECT * FROM orders LIMIT 1;
-- Expected: permission denied at schema level (grant revoked)
```

### Step 5 — service-role escape test

Service-role keys bypass RLS by design. Verify that they are scoped to their own schema, not global:

```sql
SET ROLE service_role_tenant_a;
SET search_path TO tenant_b;
SELECT * FROM orders LIMIT 1;
-- Expected: permission denied (service role is per-tenant)
-- OBSERVED IN WILD: many Supabase deployments use a GLOBAL service_role key
-- that can read every schema. Treat this as intentional-but-risky; mitigate with
-- strict ops discipline on where that key lives.
```

If service-role is global, document explicitly in `docs/governance/product-surface-split.md` that service-role is a cross-tenant escape hatch and must NEVER reach client code.

### Step 6 — write-probe

For each schema, verify writes are refused from another tenant's identity:

```sql
SET ROLE authenticated_tenant_a;
SET search_path TO tenant_b;
INSERT INTO orders (...) VALUES (...);
-- Expected: permission denied
```

### Step 7 — result

If all probes return the expected (deny/0-rows) outcomes: `rls_isolation: verified`

If any probe leaks: critical finding logged; next release BLOCKED until fix.

## Automated runner

A script / agent runs the above:

- **`.claude/agents/cross-tenant-rls-verifier.md`** (new in v2.2.1 or v2.3) — dispatched during Phase 5 §5c
- Inputs: Supabase URL, list of tenant schemas/IDs, anon key, authenticated-tenant keys (per test tenant)
- Outputs: `reports/current/rls-verification.yaml` with per-schema, per-probe result

Example output:

```yaml
rls_verification:
 timestamp: 2026-04-20T15:00:00Z
 supabase_url_fingerprint: sha256-first-8 # never the actual URL
 tested_schemas:
 - schema: tenant_a
 anon_select: denied
 cross_tenant_select: denied
 service_role_escape: expected-denied-OR-global
 cross_tenant_insert: denied
 result: verified
 - schema: tenant_b...
 global_service_role_present: true
 global_service_role_locations_checked:
 - CI secrets: present
 - prod env: present
 - operator local: present
 notes: |
 Global service_role bypasses RLS. Confirmed scoped to server-side usage
 only. No client-side imports of supabase-admin.ts.
```

## Integration

- `docs/runtime/sector-packs.md §multi-tenant-supabase` — this verification is a required sub-step
- `docs/governance/product-surface-split.md` — service-role is a product surface concern
- `docs/runtime/anti-patterns.md §AP-06` — `user_metadata` as authz (different but related)
- `docs/runtime/program-phases.md §Phase 5 §5c` — gate runs this verifier when RLS is in scope
- `.claude/agents/data-database-governor.md` — may dispatch this verifier
- `.claude/agents/security-hardening-lead.md` — may dispatch this verifier

## Canonical footer

Authoritative as of Ulak OS **v2.2.1**. 
