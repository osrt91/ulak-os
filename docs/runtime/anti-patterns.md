# Strict Anti-Pattern List

## Why this exists

Some mistakes show up repeatedly across projects. Rather than rediscovering them each audit, Ulak OS encodes them as an anti-pattern list the specialists can match against. Anti-patterns are not ironclad rules — context matters — but they're a "stop and explain why this is OK" signal when detected.

Findings that match an anti-pattern automatically carry a tag in the finding schema and are surfaced prominently in `analysis-findings.md`.

## Architectural anti-patterns

- **God files** — one file >2000 lines doing everything for a surface
- **God components / god services** — one class or function orchestrating multiple unrelated concerns
- **Utility hell** — `utils.ts` or equivalent that has become a dumping ground for any function that didn't find a home
- **Random one-off widgets** — components built for a single screen that duplicate behavior already available in the design system
- **Token drift** — design tokens defined in multiple places with slightly different values
- **Schema drift** — API responses or database fields documented in one place and implemented differently in another
- **Permission drift** — RBAC rules that contradict each other across services
- **DTO duplication** — the same entity shape defined in three forms (API DTO, internal model, frontend type) with no single source of truth
- **Dead flags** — feature flags that have been on 100% for six months and nobody removes them
- **Dead code** — unreachable branches, unused exports, commented-out sections left "for later"
- **Giant prompts with no modularization** — one CLAUDE.md or prompt doc trying to encode everything
- **Plugin / skill / command sprawl** — dozens of entries with no trigger discipline or maintenance

## Frontend / UX anti-patterns

- **Generic AI-slop layout** — the default Tailwind + shadcn look with no brand decisions
- **Random cards everywhere** — every section is a card with no hierarchy
- **Random shadows** — inconsistent elevation, shadow blur, shadow color
- **Random radii** — inconsistent border-radius across components
- **Weak typography** — too many font sizes, no scale, poor contrast
- **Weak spacing rhythm** — arbitrary margins/paddings with no system
- **Poor hierarchy** — everything visually equal, user can't tell what's primary
- **Dashboard clutter** — a dashboard with 20 metrics and no story
- **Cheap gradients** — gradients used as decoration without intent
- **Cluttered home / dashboard** — the first screen tries to show everything
- **Underdesigned analytics** — charts without context, numbers without comparison
- **Weak leaderboard ceremony** — leaderboards that feel flat instead of celebratory
- **Poor answer reveal UX** — (education) answer reveal that buries the explanation
- **Poor filters / search** — filters that reload the page, search that doesn't return results fast
- **Fake-premium visuals** — trying to look premium by adding blur and gradients instead of by restraint and hierarchy
- **Bad dark mode parity** — dark mode implemented as "invert colors" without thought
- **Childish edtech styling** — cartoonish UI on a product marketed to serious learners
- **Android patterns used badly on iOS** — Material Design Floating Action Button on an iOS-first app
- **Inconsistent iconography** — three icon sets in one app

## Backend / API anti-patterns

- **Broken auth assumptions** — "if there's a session, trust it" without verifying scope
- **Mass assignment** — API accepts a full object and writes all fields without filtering
- **IDOR / BOLA** — `/api/users/:id` without checking that the caller has access to that id
- **BFLA** — role check at menu level but not at endpoint level
- **Unauthenticated open API** — endpoints exposed publicly without documentation or intent
- **No rate limiting** — public endpoints without any throttle
- **Schema drift** — API responses differ from the documented contract
- **Error leakage** — stack traces or internal paths returned in production errors
- **Undocumented endpoints** — endpoints that exist in code but not in any docs
- **Missing audit trail on dangerous actions** — admin deletes with no log

## Security anti-patterns

- **Secrets in committed files** — API keys in `.env`, `.mcp.json`, or source
- **Secrets in Dockerfile layers** — `COPY .env .env` or similar
- **SSRF via integrations** — fetching user-supplied URLs without allowlist
- **XSS via unsanitized HTML rendering**
- **CSRF on state-changing endpoints with only cookie auth**
- **CORS wildcard on authenticated endpoints**
- **Weak password recovery** — reset link with no expiration or reuse protection
- **Brute-force friendly login** — no lockout, no rate limit, no captcha
- **Credential stuffing exposure** — no detection of high-velocity login attempts

## Data / persistence anti-patterns

- **N+1 queries** — a loop that issues one query per item instead of a join
- **Missing indexes on foreign keys or high-cardinality filters**
- **RLS asymmetry** — row-level security on some tables but not on sibling tables with the same data shape
- **Unbounded queries** — no pagination, no limit
- **Migrations that lock tables for minutes** — on tables hot in production
- **No rollback path on migration** — DDL without a reverse script

## Infra / release anti-patterns

- **No rollback plan** — deploy scripts that can't undo
- **Manual deploy steps** — "ssh in and run this" without CI
- **Cert auto-renew without fallback** — expires and the product dies
- **No observability dashboards** — running blind in prod
- **No crash reporting** — mobile apps shipping without Sentry / Crashlytics
- **Single environment** — no staging, changes go straight to prod
- **No env separation of secrets** — dev keys work in prod

## Localization anti-patterns

- **ASCII fold in display text** — Turkish rendered without special characters
- **`toUpperCase()` / `toLowerCase()` without locale** — any language that has locale-sensitive case
- **Hardcoded strings in source** — strings that should be in i18n files
- **Shared normalization for display and search** — the display form and the search form must differ
- **Claiming locale support when only UI is translated** — email / push / legal / store not covered

## Destructive action without live-probe (gate pattern)

The director must not schedule ANY destructive action against a **remote** target without a preceding `validation-plan.md §6` probe that confirms the action is safe. This applies to:

- `rm -rf <remote path>` — confirm the path is really stale and has no live references
- `DROP TABLE` / `DROP INDEX` / `DROP DATABASE` — confirm the table / index is not in use
- `REVOKE ALL` / `REVOKE <privilege>` — confirm callers are not relying on the grant
- `git reset --hard` on a shared branch — confirm nobody has uncommitted work
- `docker network rm` — confirm no containers are attached
- PM2 `delete` — confirm the process is not serving traffic
- `TRUNCATE` / any mass DELETE — confirm the rows are not referenced by foreign keys, not in backup scope, not pending audit export
- Cloud resource deletion (S3 buckets, IAM roles, VPC, KMS keys) — confirm no dependent resources

Each destructive item in `execution-roadmap.md` MUST have a `pre_check` field naming the live probe that authorized it. Example:

```yaml
item_id: NF-03
action: rm -rf /opt/oguzhansert/
pre_check:
  - LP-09: "ls -la /opt/oguzhansert/" returned only README stubs
  - result: BLOCKED — found .env.local (Apr 9), not stale
  - resolution: chmod 0600 instead; operator decision on rm
```

This pattern was observed as a pivot in the oguzhansert.dev Sprint 0+1 session (2026-04-11, FP-07). The director had scheduled `rm -rf /opt/oguzhansert/` as R-119 because static analysis said the directory was stale. The Wave 3 live probe found an `.env.local` with real secrets. The destructive action was cancelled, the finding was downgraded from a delete to a chmod, and a new finding (NF-03) was issued. Without the pre-check live probe, the director would have blindly deleted secrets.

See `docs/runtime/live-probe-contract.md` for the Phase 4.5 protocol that enforces this gate.

## Prompt / governance anti-patterns

- **Giant one-file everything prompt with no runtime router**
- **Loading all modules on every request**
- **Boiling the ocean — every run tries to cover every topic**
- **Menu loops after explicit full intent**
- **Historical diff notes leaking into user-facing output**
- **Low-trust evidence cited as high-confidence**
- **Sector assumptions in the core kernel**
- **Prompt regression not tested**
- **Commands / skills / agents that duplicate each other**
- **No hidden-core separation — every maintenance note lives in the active runtime**
- **Memory files that grow without pruning**

## Integration

- `docs/governance/finding-schema.md` — findings tagged as anti-pattern matches
- `docs/runtime/analysis-contexts.md` — each context maps to a subset of these anti-patterns
- `.claude/agents/red-team-challenger.md` — the red-team agent actively scans for anti-patterns
- `evals/assertions/core-assertions.md` — regression detection catches anti-patterns creeping back
