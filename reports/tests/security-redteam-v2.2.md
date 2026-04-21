# Security Red Team v2.2 — 2026-04-21

**Agent**: security-redteam
**Scope**: v1.1+ surface (payment webhooks, hybrid backends, sector overlays)
**Verdict**: NOT READY for prod with payment+bot+health+ai combined config
**Finding counts**: 4 Critical, 15 High, 17 Medium, 6 Low = 42 total

## 24-hour blockers

- **SEC-V22-C-01** — Iyzico signature compare non-constant-time → timing attack
- **SEC-V22-C-02** — Iyzico canonical doesn't cover body → event retargeting
- **SEC-V22-C-03** — Iyzico synthetic event_id fallback → replay
- **SEC-V22-C-04** — Bot↔API HMAC has no timestamp/nonce → permanent replay
- **SEC-V22-H-01** — Stripe silent-ACK sig failures with no metric → detection gap
- **SEC-V22-H-05** — FastAPI `/internal/{source}` webhook no timestamp replay guard

## Finding index (condensed from agent output)

### Critical (4)

| ID | File | Issue | Fix |
|---|---|---|---|
| SEC-V22-C-01 | `lib/payments/iyzico.ts` / webhooks/iyzico | `expected === received` — timing attack on 28-char base64 | `crypto.timingSafeEqual` with length precheck |
| SEC-V22-C-02 | webhooks/iyzico + iyzico.ts | Canonical covers only `eventType+paymentId+eventTime+secret`; `subscriptionReferenceCode`+`status`+`price`+`currency` unsigned | HMAC-SHA256 over raw body (V3 scheme); remove classic path |
| SEC-V22-C-03 | webhooks/iyzico:105-108 | `eventId = paymentId ?? refCode ?? eventType:eventTime` — attacker changes refCode but keeps paymentId → multiple FSM writes per one sig | Require `iyziPaymentId` not-null; include nonce+timestamp in sig |
| SEC-V22-C-04 | bot-telegram/services/{hmac_auth,api_client} | No timestamp, no nonce; Bearer token == HMAC key (single secret for 2 controls) | Add X-Timestamp ±60s, X-Nonce (Redis 60s TTL); split Bearer from HMAC secret |

### High-impact High findings (15)

- H-01 Stripe silent-ACK sig failures (no metric → detection blind)
- H-02 FastAPI JWT accepts HS256 fallback (alg-confusion vector)
- H-03 JWKS fetch no size cap, no circuit breaker (DOS)
- H-04 api_client URL injection via unquoted email
- H-05 FastAPI /internal/{source} no timestamp replay guard
- H-06 SAML `wantAuthnRequestsSigned: false`
- H-07 OIDC `resolveSecret` reads arbitrary env vars from DB-controlled ref → admin exfiltrates any secret
- H-08 PHI DEK hex-stringified as pgp_sym_encrypt passphrase → weak KDF + CAST5 default
- H-09 `decryptPhi` audit contract is caller-voluntary (not structural)
- H-10 Break-glass 4h expiry is DEFAULT, mutable via UPDATE
- H-11 member-gated `posts` RLS doesn't inherit thread tier gate → BOLA
- H-12 Google LLM API key in URL query string → leaked to every tracer/proxy
- H-13 Cost-cap TOCTOU (no row lock) → 50 parallel reqs see same remaining → 3-50x breach
- H-14 Traefik CSP includes `unsafe-inline 'unsafe-eval'` in prod template
- H-15 SKILL compatibility matrix is doc-only, zero code enforcement → ecommerce+health-sensitive corrupts DB

### Medium (17) + Low (6)

Stripe PII retention in dead-letter, Stripe FSM rollback causing retry-storm, bot allowed_users empty-default ambiguity, bot webhook 0.0.0.0 bind, member_profiles RLS ignores privacy flags, AI token estimator undercounts Unicode, AI chat rate-limit in-memory, impersonation `ends_at` null-bypass, impersonation PATCH no CSRF, Sumsub placeholder HMAC, AML similarityScore bypassable, Traefik dashboard no IP allowlist, dev `--api.insecure=true`, k8s default-deny egress blocks LLM providers, override-template convention ungoverned, ai-chat conversation tenant check missing, AI relay stores assistant output plaintext in health-sensitive tenants, fintech trigger serialization doc-only, marketplace immutability bypassable via DISABLE TRIGGER, kong hide_credentials false, kong key_names default, kong no global rate-limit, fallback chain stale entry.

## Action plan (v2.2.1 patch)

Fix all 4 Critical + H-01, H-05, H-06, H-07, H-08, H-11, H-12, H-13, H-14, H-15 in this patch. Remaining medium/low deferred to v2.2.2 (with issue tracker entries).

## Signoff

`signoff_status: BLOCKED` pending 4 Critical + 6 High-24h-gate resolutions. Orchestrator commits fix batch; re-run red-team after.
