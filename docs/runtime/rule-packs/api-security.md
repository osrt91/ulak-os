# Rule Pack — API Security

Activated when runtime-manifest detects any HTTP API surface (routes, endpoints, webhooks).

## Imperatives

- Authentication tokens never appear in URLs, query params, or referrer-visible paths (anti-pattern AP-02)
- WebSocket auth uses a short-TTL ticket exchanged via REST, or token in first frame — not URL query
- Rate limit every public endpoint; durable backend (Redis) not process memory (anti-pattern AP-01)
- Webhook providers: always verify HMAC / signature on every callback (anti-pattern AP-08)
- CVSS v4.0 (not v3.x) for vulnerability scoring in findings
- `.env*` gitignored; `.env.example` committed with key names + safe placeholders only
- Admin-level actions write an audit log entry with actor, target, and diff
- CORS on authenticated endpoints is never `*` — allowlist explicit origins
- Error responses in prod are generic; stack traces + internal paths stay in logs

## Transactional messaging (added v2.2.0)

- SMS: multi-provider abstraction with WhatsApp fallback (e.g. if primary provider returns 5xx, failover to secondary)
- Provider fragmentation is real: Twilio, MessageBird, Vonage have different opt-out / delivery-receipt semantics
- Email (Resend / SES / Postmark): explicit `From:` domain with SPF + DKIM + DMARC all passing
- Prevent email-header spoofing: `From:`, `Reply-To:`, and `Return-Path:` use same verified domain; user-provided `name` sanitized
- Unsubscribe link mandatory in every marketing / transactional email (transactional gets one-click, not full preferences)
- Bounce handling: soft bounces retry with backoff; hard bounces mark address dead in DB
- Rate limit: per-recipient cap per 24h to prevent reputation damage from compromised send-on-behalf accounts

## Collision rule

Project `.claude/rules/security.md` overrides specific imperatives; unmatched inherit from this pack.
