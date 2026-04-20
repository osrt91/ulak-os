# Product Surface Split — Customer / Admin / Public / Partner

> **Not to be confused with `docs/governance/surface-split.md`.** That doc is about the **runtime** surface split (Public Runtime / Hidden Core / Maintainer) — an internal Ulak OS concept. THIS doc is about the **product** surface split (customer / admin / public API / partner-reseller) — a concern every SaaS product faces. Two different governance layers, both called "surface split" for unfortunate historical reasons.

## Why this exists

Every non-trivial SaaS product has users with different trust levels and different permission sets. Conflating them produces the worst security bugs in the OWASP top 10: IDOR, BOLA, BFLA, mass assignment, privilege escalation via shared endpoints.

Ulak OS's core contract (runtime-defaults line 4) says "customer/admin/public api ayrımını koru" — but v2.1.2 shipped without a dedicated governance doc defining what that rule actually means. This is that doc.

A real-world product (a security scanner project) showed that 3 surfaces isn't always enough: the moment a **partner / reseller / bayi** tier appears, a fourth surface with its own authz gate (plan capability, not role) + its own data model (parent/child user mapping) + its own branding story emerges.

## The four surfaces

| Surface | Audience | Auth gate | Endpoint prefix (convention) | Example capability |
|---|---|---|---|---|
| **Public** | Unauthenticated visitors, search crawlers, marketing pages | None | `/`, `/api/public/**` | Landing page content, pricing page, `/api/public/health` |
| **Customer** | Authenticated end-users of the product | Valid JWT, role=`customer` | `/app/**`, `/api/customer/**`, `/api/scan/**` | User's own data, user-scoped actions, self-service settings |
| **Admin** | Internal operators (support, ops, platform owners) | Valid JWT + DB-sourced admin role (NOT `user_metadata`) | `/admin/**`, `/api/admin/**` | Cross-tenant read, destructive actions, moderation, dangerous operations |
| **Partner / Reseller / Bayi** | Third-party resellers, white-label partners, channel sales | Valid JWT + **plan capability** (not role) | `/reseller/**`, `/partner/**`, `/api/reseller/**` | Sub-account management, branded UX, commission reporting, customer provisioning |

**Not every product needs all four.** A single-user CLI tool has only Public. A standard SaaS has Customer + Admin. Mature / channel-sold SaaS has all four.

## Hard rules

### Separation

- **Different prefix per surface.** No endpoint serves both customer and admin requests conditionally. Use distinct route trees.
- **Different authz mechanism per surface.** Admin uses DB-sourced role (not JWT `user_metadata` — see AP-06). Partner uses plan capability. Customer uses valid session. Public uses nothing.
- **No "admin-lite" role on customer endpoints.** If customer endpoint X needs admin override, the admin uses `/admin/<action-as-user>/<user-id>` or an impersonation ticket, not a conditional branch inside the customer endpoint.
- **Webhook endpoints are Public-surface** but carry their own auth (signature verification). They are NOT customer endpoints even if they deliver customer-related events.

### Authz source discipline

| Surface | Source | Caching |
|---|---|---|
| Public | — | — |
| Customer | JWT claim (valid session, not-expired) | Per-request |
| Admin | **DB row** (`user_role_assignments` or equivalent), NEVER `user_metadata` | TTL cache (30–60s) with explicit invalidation on role change |
| Partner | **DB row** (plan capability table), plus JWT identity | TTL cache per plan-capability lookup |

`user_metadata` is client-mutable via Supabase SDK (and analogous on other identity providers). Using it for authz is anti-pattern AP-06. This rule applies across all surfaces above.

### Failure handling

- Missing JWT on customer endpoint → 401, not 403 (401 = "you need to authenticate", 403 = "you authenticated but you're not allowed"). Get the semantics right.
- Valid JWT but wrong surface (e.g., customer JWT on `/admin/**`) → 403, not 404. Do not hide surface existence from authenticated callers.
- Invalid plan capability on partner endpoint → 403 with `plan-capability-denied` code in body. Not 404. Not a generic 401.

## Surface-specific considerations

### Customer surface

- Rate limit every endpoint (even authenticated ones — compromised accounts DoS)
- Token in URL is forbidden (AP-02). JWT goes in `Authorization: Bearer` header.
- Multi-tenant: every customer query carries tenant_id from JWT, never from query param

### Admin surface

- Every destructive action writes an audit log entry (actor, target, timestamp, diff)
- Impersonation (admin-as-user) MUST produce a log entry with a reason field
- Rate limit applies but thresholds can be higher (admins legitimately run bulk queries)
- 4-eyes principle for the most dangerous actions (e.g. user deletion, key rotation)

### Partner / Reseller surface

- Plan capability is checked at every endpoint, not at menu/navigation level (BFLA avoidance)
- Per-partner branding data is scoped to the partner's own tenant tree, never cross-partner
- Commission / payout calculations have their own audit log
- Sub-user management: partner cannot grant capabilities they don't have themselves

### Public surface

- Assume every request is hostile
- No PII returned, even in error messages
- Versioned endpoints (`/api/v1/public/**`) to allow deprecation

## Detection in audit

During Phase 2 specialist dispatch, the following checks are mandatory if the project has multiple surfaces:

- `security-hardening-lead` verifies separation (no shared endpoint across surfaces)
- `backend-api-architect` verifies authz source discipline per surface
- `red-team-challenger` attempts: IDOR across surfaces, admin action via customer token, partner action via customer token, mass assignment that escalates role
- `security-redteam` (persona) simulates compromised customer, compromised admin, compromised partner

## Integration

- `docs/runtime/anti-patterns.md` — AP-02 (token in URL), AP-06 (user_metadata as authz), plus IDOR / BOLA / BFLA / mass assignment entries all bear on this doc
- `docs/runtime/sector-packs.md` — `reseller-enabled-saas` pack (SP-05) activates partner-surface rules specifically
- `.claude/agents/admin-persona.md`, `customer-persona.md`, `bayi-persona.md`, `developer-persona.md` — persona dispatches per surface
- `docs/governance/surface-split.md` — the OTHER surface split (runtime layers); keep distinct

## Canonical footer

This file is authoritative as of Ulak OS **v2.1.3**. It formalizes the rule previously only stated as a single line in CLAUDE.md runtime-defaults. The 4-surface reality is drawn from a security scanner project's production shape (public + customer + admin + reseller).
