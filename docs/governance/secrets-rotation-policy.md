# Secrets Rotation Policy

## Why this exists

Every production secret has a half-life. An unrotated secret with 3 years of history has a different blast radius than the same secret with 30-day rotation. Teams that don't rotate discover this the hard way — a disgruntled ex-contributor's environment still has the prod JWT secret, or a committed `.env` from 2023 still authorizes to 2026's prod API.

Ulak-family projects inherit a pattern from scanner-project / trend-platform / community-platform: **static JWT_SECRET, static POSTGRES_PASSWORD, static PAYMENT_ENCRYPTION_KEY**. No rotation documented. No schedule. Credential sharing across services means one leak compromises everything.

This doc is the discipline. It answers: which secret rotates how often, who rotates it, what happens when rotation fails mid-flight.

## Rotation cadence matrix

| Secret class | Default cadence | Trigger-based rotation required when |
|---|---|---|
| **JWT signing key** (auth.jwt_secret, kong.yml JWT secret) | 90 days | Any team-member departure; any leak suspicion; any token-theft incident |
| **Database password** (postgres, mysql superuser) | 180 days | VPS access change; DB restore from backup; compromise report |
| **Service-role key** (Supabase `SUPABASE_SERVICE_ROLE_KEY`, admin SDK) | 60 days | Any unauthorized access log entry; any release that changes admin surface |
| **Payment provider API key** (Stripe, Iyzico, Resend) | 90 days for test keys; 30 days for prod if possible | Anything that looks like fraud; vendor's own rotation notice |
| **Cloudflare API token** | 90 days (shorter for zone-write scope) | DNS suspicious activity; scope-escalation request |
| **SMTP / email relay credentials** | 120 days | Bounce-rate spike; deliverability change |
| **Encryption-at-rest key** (PAYMENT_ENCRYPTION_KEY for credentials storage) | 365 days (requires data re-encryption) | Regulatory milestone; compliance audit |
| **CI-only tokens** (deploy webhook HMAC, PAT for release) | 60 days | CI runner change; provider-side role change |
| **SSH private keys** (deploy user) | 180 days for key material; 30 days for passphrase of key | Operator offboarding; key suspected compromised |
| **MCP server PATs** (GitHub, Jira, Notion) | Quarterly | Tool scope change; org-level audit |

## Ownership matrix

| Secret class | Owner | Backup owner | Audit-trail location |
|---|---|---|---|
| JWT / service-role | Tech Lead | Security | `reports/current/secret-rotation-log.md` |
| DB password | DBA / Infra | Tech Lead | Same |
| Payment API | Finance + Tech Lead | Security | Same + finance ticket |
| Cloudflare | Infra | Tech Lead | Same |
| Encryption-at-rest | Tech Lead | Security | Same + customer comms if re-encrypt causes downtime |

Multi-signatory rotations (e.g., payment keys that require Finance + Tech Lead approval) MUST be recorded with both signatures.

## Rotation procedure (canonical)

Every rotation follows the same 9-step protocol:

1. **Pre-rotation check** — verify current secret is present in:
   - runtime env of prod
   - staging env (if exists)
   - CI secrets store
   - operator local `.env.local` (if applicable)
   - all backup retention layers (if secret would be used post-restore)

2. **Generate new value** — from the provider (Supabase dashboard / Stripe / Cloudflare / openssl rand) NOT a hand-crafted string

3. **Stage the new value** — write to prod env, CI secret, operator env *alongside* the old value (rotation in parallel, not swap-in-place)

4. **Dry-run** — force a request path that uses the NEW secret; verify 200 OK

5. **Cut over** — switch canonical lookup from old → new (for JWT, this is the `iss` / `kid` rotation; for DB, connection-string swap)

6. **Verify production traffic** — watch metrics for 10–30 minutes; any 401/403/500 spike triggers rollback

7. **Revoke old value** — from the provider. NOT before step 6 completes. NOT after a calendar wait.

8. **Audit entry** — append to `reports/current/secret-rotation-log.md` (or per-project equivalent):
   ```yaml
   - date: 2026-04-20T14:00:00Z
     secret_class: "jwt_signing_key"
     rotated_by: "operator-identifier"
     reason: "scheduled 90-day rotation"
     old_value_fingerprint: "sha256-first-8-of-old"
     new_value_fingerprint: "sha256-first-8-of-new"
     cutover_time_utc: 2026-04-20T14:12:00Z
     revoked_old_at_utc: 2026-04-20T14:40:00Z
     rollback_used: false
     notes: "zero downtime; dual-issue window 12 min"
   ```

9. **Update rotation-due date** — record next rotation in `active-variables.yaml` under `mcp_authorized_tools` (or equivalent) for scheduled alerting

## Failed rotation handling

If step 4 or 6 fails:

- **Immediately** switch lookup back to OLD value
- Investigate delta between old and new (wrong scope? wrong format?)
- Do NOT leave dual-value state longer than 24 hours (operational risk)
- Record the failed rotation in the log with `rollback_used: true` and reason

If the OLD value cannot be restored (revoked too early):

- This is an incident — not a rotation issue
- Follow the incident response runbook (separate doc)

## Shared-secret hazards

Several projects in the Ulak-family portfolio share secrets across repos:

- **JWT_SECRET reused** across Kong gateway + Supabase auth (oguzhansert.dev finding DIR-005)
- **Cloudflare account credentials** shared across trend-platform + erbilpetshop + others
- **Shared Supabase instance** (schema isolation, but same master credentials)
- **Shared SMTP relay** (one credential serves multiple transactional-email surfaces)

These shared-secret arrangements concentrate blast radius. Each shared secret gets a **multi-project rotation window** — rotating once triggers coordinated update across all consumers. The rotation log records which consumer was updated at which timestamp.

## CI enforcement

- `scripts/check-secret-rotation-due.sh` (v2.2.1 or v2.3) reads `active-variables.yaml` rotation-due fields; any overdue entry fails CI with a warning (after 7 days) or error (after 30 days)
- `release-readiness-auditor` agent reads this doc; flags any deploy attempt where a rotation is > 30 days overdue

## Anti-patterns

- **"We'll rotate when someone leaves"** — by the time someone leaves, the secret has likely been copied to a personal machine
- **"Secrets in committed files"** — AP-11 (scanner-project lineage) — does not live here but cross-references
- **Root `.env.local` in monorepo** — see AP-19 (v2.2.1); one rotation must touch all app-level `.env.local` copies
- **Static encryption-at-rest key** — means re-encrypt migration is impossible; plan rotation path from day 1
- **Rotation without dual-issue window** — cuts over in a single step, any in-flight request fails

## Integration

- `docs/governance/ai-provider-allowlist.md` — AI provider keys use this policy
- `docs/governance/mcp-governance.md` — MCP tool authorization records rotation cadence per server
- `docs/governance/settings-permissions-governance.md` — `.claude/settings.local.json` rotation for operator-scoped tokens
- `docs/runtime/active-variable-contract.md` — `MCP_AUTHORIZED_TOOLS` field carries `rotation_cadence` + `next_rotation_due`
- `docs/runtime/anti-patterns.md` — AP-11 (secrets in files), AP-19 (root env)
- `.claude/agents/security-hardening-lead.md` — runs the rotation runbook

## Canonical footer

Authoritative as of Ulak OS **v2.2.1**. Evidence base: cross-project scan observing static long-lived secrets across scanner-project / trend-platform / plastics-supplier / growth-platform / oguzhansert. No real secret values in this document by policy.
