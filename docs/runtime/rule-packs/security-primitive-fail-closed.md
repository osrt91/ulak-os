# Rule Pack — Security Primitive Fail-Closed Discipline

Activated when runtime-manifest detects ANY of: CAPTCHA / bot-protection lib (`@cloudflare/turnstile`, `react-google-recaptcha`, `hcaptcha`), CSRF middleware, HMAC webhook verification, JWT verification, rate-limit middleware, file-upload endpoints, or auth-protected API routes. Sibling to `api-security.md` (baseline API hardening) — this pack governs the **fail-mode contract** of every security primitive specifically.

Pattern source: `docs/governance/pattern-import-ledger.md` IL-029 (Next.js 16 + Expo React Native + self-hosted Supabase community/event platform with Turnstile bot-protection, T1 evidence — 11 fail-open compounding primitives observed in same audit including Turnstile lib + contact-form gate + middleware Origin check + CSP self-defeat + open-redirect + SVG upload + audit-log enumeration oracle + tests-against-prod).

## Core principle

**Every security primitive fails CLOSED, never OPEN.**

A "fail-open" primitive returns "pass / allow / true / continue" when its dependency (env var, secret, token, header) is missing or malformed. The intent is graceful degradation; the effect is silent disabling. In production with active attackers, the difference between a misconfigured deploy and a compromised one is often zero — both look identical in logs.

A "fail-closed" primitive throws / rejects / returns "fail" when its dependency is missing. The deploy refuses to start, the request returns 503, the form rejects submission. The user sees an error; the operator sees a paged alert. Hostile traffic gets blocked, not bypassed.

This pack codifies fail-closed discipline across all security surfaces.

## Imperatives

### Verify primitives — fail closed on missing config

A `verify*()` function (CAPTCHA / Turnstile / reCAPTCHA / HMAC signature / JWT) MUST return `false` (or throw a typed error) when:

- Required environment variable is unset (`TURNSTILE_SECRET_KEY` missing → reject)
- Required secret is empty string (typo / config drift → reject)
- Required header is absent (`X-Hub-Signature-256` missing on webhook → reject)
- Token argument is empty / `null` / `undefined` (caller passed empty → reject)
- Verification API call fails (network error / 5xx → reject, NOT optimistically pass)

**Banned pattern**:
```ts
// ❌ FAIL-OPEN — silently disables CAPTCHA on misconfigured deploy
export async function verifyTurnstile(token: string) {
  if (!process.env.TURNSTILE_SECRET_KEY) return true;  // ← fatal flaw
  // ...
}
```

**Required pattern**:
```ts
// ✅ FAIL-CLOSED — refuses to operate without secret
export async function verifyTurnstile(token: string) {
  const secret = process.env.TURNSTILE_SECRET_KEY;
  if (!secret) throw new Error('TURNSTILE_SECRET_KEY required');
  if (!token) return false;
  const r = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    body: new URLSearchParams({ secret, response: token }),
  });
  if (!r.ok) return false;  // ← fail closed on Cloudflare brownout
  const data = await r.json();
  return Boolean(data.success);
}
```

### Call sites — never bypass on falsy token

Call sites MUST treat empty / missing token as an explicit reject, not a skip:

**Banned**:
```ts
// ❌ Empty token literally bypasses gate
if (turnstileToken) {
  const ok = await verifyTurnstile(turnstileToken);
  if (!ok) return reject();
}
// caller proceeds without verification
```

**Required**:
```ts
// ✅ Missing token = reject
const ok = await verifyTurnstile(turnstileToken ?? '');
if (!ok) return reject('Bot protection failed');
```

### Origin / CSRF check — present-and-allowlisted, not present-or-pass

Middleware Origin check MUST verify presence AND allowlist:

**Banned**:
```ts
// ❌ Missing Origin = pass (server-to-server, internal tools, attacks all bypass)
if (!origin) return true;
return allowedOrigins.includes(origin);
```

**Required**:
```ts
// ✅ Missing Origin = reject for state-changing methods
const stateChanging = ['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method);
if (stateChanging && !origin) return false;  // server-to-server uses webhook signing, not Origin
if (origin && !allowedOrigins.includes(origin)) return false;
return true;
```

If a webhook genuinely needs to bypass Origin check (because external service doesn't send Origin), it MUST be path-allowlisted explicitly AND require HMAC signature instead — never a global "no-origin = pass" rule.

### HMAC signature — required on every state-changing webhook

Every inbound webhook (Stripe, Iyzico, Meta/WhatsApp, GitHub, Twilio, Resend) MUST verify HMAC signature against a per-provider secret BEFORE parsing body or writing to DB:

```ts
const sig = req.headers.get('x-hub-signature-256');
if (!sig) return new Response('Missing signature', { status: 401 });
const expected = `sha256=${createHmac('sha256', SECRET).update(body).digest('hex')}`;
if (!timingSafeEqual(Buffer.from(sig), Buffer.from(expected))) return new Response('Invalid signature', { status: 401 });
// only NOW parse body
```

**Banned**: webhook handler that accepts any JSON matching the provider's schema without HMAC check ("we'll add the signature later"). The "later" never comes; the URL leaks; anyone who knows the URL writes to the DB. Concrete observed: WhatsApp webhook with comment "inbound 2-way desteği" (TODO) accepted unsigned writes for 4 sprints.

### JWT verify — never trust `alg=none`, never skip expiry

JWT verification MUST:

- Reject tokens with `alg: none` or `alg: HS256` when the verifier expects asymmetric (RS256/ES256) — algorithm-confusion attack
- Verify expiry (`exp`) — clock-skew tolerance ≤30s
- Verify `iss` (issuer) AND `aud` (audience) match expected values
- Verify signature with correct key for the declared `alg`
- Reject empty token and malformed tokens

**Banned**: `jwt.decode(token)` without verify (decode is parsing, not validating); `jwt.verify(token, secret, { algorithms: ['none', 'HS256'] })` accepting both symmetric and asymmetric (algorithm-confusion vector).

### Rate limiter — fail closed on Redis outage (with circuit-breaker)

Rate-limit middleware MUST:

- Use durable storage (Redis) — process-memory rate-limit fails to scale + bypass on cluster mode (`anti-patterns.md` AP-01 + AP-20 family)
- On Redis outage: choose policy explicitly — fail-closed (reject all requests) for high-stakes endpoints (login, payment, signup), fail-open with reduced TTL for low-stakes (read endpoints) — DOCUMENT the choice
- Circuit breaker: after N failed Redis calls, briefly disable rate-limiter and alert ops, rather than every request retrying Redis and stacking
- Health check on Redis connection at deploy time — refuse to start if Redis unreachable

### Audit log — never store raw enumeration vectors

Audit log entries MUST:

- Hash sensitive identifiers in **failed-attempt** events (`email_hash = sha256(email + salt)` on failed-login, NOT raw email)
- Distinguish "scan-the-table" RLS from "select-by-user-id-for-incident-response" RLS — staff with the latter cannot bulk-export
- Auto-purge failed-attempt entries >90d (privacy-aware retention)
- Include `event_type`, `actor_id`, `target_id`, `result`, `timestamp`, `ip_hash`, `ua_hash` — full context, hashed PII
- Read access logged itself (audit-log access is audit-logged)

See `anti-patterns.md` AP-46 — audit log as account-enumeration oracle.

### File upload — server-side MIME allowlist + execute-resistant serving

File upload endpoints MUST:

- Server-side MIME allowlist enforced at storage layer (Supabase `allowed_mime_types`, S3 bucket policy) AND at API layer — client-side check is a hint, not a gate
- SVG explicitly NOT in allowlist unless sanitized server-side via `dompurify` / `svg-sanitizer` (strips `<script>`, `<foreignObject>`, event handlers)
- Uploaded files served from a **cookieless subdomain** (`uploads.example.com`) — even if executable content slips through, it has no session access
- `Content-Disposition: attachment` on user-uploaded files where inline display is not strictly required
- File extension AND content-type both validated (sniff actual bytes, not just `Content-Type` header)

See `anti-patterns.md` AP-48 — SVG upload stored-XSS.

### Redirect after action — never concatenate, always parse

Post-action redirects MUST validate the destination:

```ts
// ✅ Parse + assert origin
const dest = new URL(nextParam, origin);
if (dest.origin !== origin) return redirect('/');  // reject cross-origin

// ✅ Or strict allowlist for paths
if (!nextParam.startsWith('/') || nextParam.startsWith('//')) {
  return redirect('/');
}
```

Banned: `redirect(`${origin}${next}`)` — protocol-relative `//evil.com` becomes a phishing primitive.

See `anti-patterns.md` AP-47 — open-redirect via protocol-relative URL.

### CSP — strictness over permissiveness

CSP header MUST:

- NOT grant `'unsafe-inline'` AND `'unsafe-eval'` together — combination is functionally no-CSP (`anti-patterns.md` AP-45)
- Use nonces / hashes for legitimate inline scripts (Next.js 13+ provides nonce API)
- Avoid wildcards in `script-src` / `connect-src` — list explicit origins
- Report-only mode for 2 weeks during migration to strict policy
- CI gate fails on `'unsafe-eval'` in production CSP unless explicitly allowlisted with documented reason

### Secret rotation — revoke as part of issue

Rotation runbook MUST be FOUR atomic steps, not three:

1. **Issue** new secret
2. **Deploy** new secret to all consumers
3. **Verify** all consumers are using new secret (logs show new ID, old ID has zero reads)
4. **Revoke** old secret at provider — explicit API call or dashboard click, recorded in audit log

Skipping step 4 = `anti-patterns.md` AP-43 (rotate-without-revoke).

For shared self-hosted secrets across tenants (`anti-patterns.md` AP-42): coordinate rotation across all tenants in step 2; verify all in step 3; revoke after all verified.

### Fail-closed integration testing

Every security primitive has an integration test that asserts fail-closed behavior:

- Send empty token → assert reject
- Send malformed token → assert reject
- Unset env var (in test setup) → assert deploy refuses to start OR every request returns 503
- Webhook with missing signature → assert 401
- Webhook with wrong signature → assert 401
- JWT with `alg: none` → assert reject
- File upload with `image/svg+xml` → assert reject (or asserted-sanitized result)

## Validator rules (CI-blocking)

- `scripts/validate-no-fail-open.sh` — AST walk: every function name matching `verify*` / `validate*` / `check*` MUST NOT return `true` in a `!secret` / `!token` / `!header` branch
- `scripts/validate-csp-no-unsafe.sh` — production CSP header lacks `'unsafe-eval'`; warns on `'unsafe-inline'`
- `scripts/validate-webhook-hmac-coverage.sh` — every `app/api/webhooks/**` route handler imports + invokes a signature-verification function before parsing body
- `scripts/validate-redirect-no-concat.sh` — grep for `redirect(\`\${`)`-style template-literal redirects; flag for review
- `scripts/validate-required-env.sh` — startup-time check: every secret named `*_SECRET` / `*_KEY` / `*_TOKEN` listed in `.env.example` is present in deploy env
- `scripts/validate-test-base-url-not-prod.sh` — `playwright.config.ts` / `cypress.config.ts` `baseURL` default does NOT contain production domain

## Collision rule

Project `.claude/rules/security-fail-mode.md` overrides specific imperatives (e.g., a project may have a documented reason for a specific primitive to fail open in dev mode); unmatched inherit. The fail-closed default is non-negotiable in production builds.

## Integration

- `docs/runtime/rule-packs/api-security.md` — baseline API hardening (this pack extends fail-mode contract)
- `docs/runtime/anti-patterns.md` — AP-41 (verify fail-open), AP-42 (multi-tenant secret coupling), AP-43 (rotate-without-revoke), AP-44 (test against prod), AP-45 (CSP self-defeat), AP-46 (audit log enumeration), AP-47 (open-redirect), AP-48 (SVG upload stored-XSS)
- `docs/governance/secrets-rotation-policy.md` — rotation runbook
- `docs/governance/observability-baseline.md` — security-event logging (audit log entry shape)
- `docs/governance/pattern-import-ledger.md` IL-029 — provenance

## Canonical footer

Authoritative as of Ulak OS **v1.9.0**. Imported from a Next.js 16 + Expo React Native + self-hosted Supabase community/event platform with Turnstile bot-protection, observed 2026-04-26 absorption pass #3. The 11-cluster fail-open compounding pattern (Turnstile lib + Turnstile call site + Origin check + CSP self-defeat + WhatsApp webhook unsigned + audit-log oracle + open-redirect + SVG upload + tests-against-prod + multi-tenant secret coupling + rotate-without-revoke) is the load-bearing concrete evidence — eight independent surfaces all making the same architectural mistake of preferring graceful-degradation over explicit-rejection.
