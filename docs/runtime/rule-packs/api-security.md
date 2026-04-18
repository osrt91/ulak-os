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

## Collision rule

Project `.claude/rules/security.md` overrides specific imperatives; unmatched inherit from this pack.
