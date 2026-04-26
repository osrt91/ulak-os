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
- **AP-09 Copy-paste service logic** — the same 100+ LOC service call (API client, email template, logging wrapper) duplicated in 3+ places with minor variations (different error handling, different timeouts, different prompts). Fix: extract `services/<name>.py` with a single client class; replace all call sites with imports. md:35-60`
- **AP-10 Multi-file schema drift** — the same entity defined in 3+ places (SQL DDL + ORM model + Pydantic/Zod request schema + TypeScript type) with divergent field names or types. Migration files layer on top of each other; a later seed SQL tries to `ON CONFLICT` against a column removed by earlier migration → silent half-execution. Fix: one canonical source (usually DDL or ORM); others generated from it (e.g. `drizzle-kit generate`, `prisma generate`). 
- **AP-11 Multi-layer auth bypass** — middleware says "check cookie presence"; page component says "check user role"; lib helper says "verify JWT"; API route says "admin only". Four layers all implement auth, independently, all with different flaws (middleware doesn't verify HMAC, page component trusts DB-read to be cached, lib reads `user_metadata` anyway, route skips because middleware already validated). A compromised cookie walks through all four because each layer trusts a different prior. Fix: single auth helper; every entry point calls it; `server-only` boundary enforced. 
- **AP-14 Dead admin CRUD** — admin panel CRUD writes to database tables that nothing reads. `getSiteSettings` has 0 callers; `getRedirects` is never imported in middleware; `/admin/galeri` CRUD complete but no `page.tsx` file. Admin user edits data thinking it's live; effect is zero. Fix: orphan-export-finder in CI (`grep -r getXxx src/` for every admin read function); if zero hits outside admin module, delete the admin CRUD OR add the missing consumer. 
- **AP-15 Drag-drop builder without concurrent-edit conflict resolution** — CMS-style section builder saves layout as JSON; two admins edit simultaneously, last write wins, earlier admin's changes silently disappear. No version field, no optimistic locking, no conflict UI. Fix: version column on the builder doc; UPDATE WHERE version = $1; on conflict, surface "someone else edited, reload" dialog with 3-way merge option. 
- **AP-16 `.env.local` committed to git** — production secrets (service role keys, API tokens, webhook secrets) live in a file named `.env.local` that is NOT in `.gitignore` for this project. Working tree contains live keys; git history contains historical keys. Fix: (1) immediately `git rm --cached.env.local`, (2) add to `.gitignore`, (3) rotate ALL keys that have ever been committed, (4) optionally `git-filter-repo --replace-text` to purge history (destructive — coordinate with collaborators). 
- **AP-19 Root `.env.local` in monorepo (cross-app leak)** — multi-app workspace (pnpm / Turbo / Nx) where `.env.local` lives at repo root. Turbo / Next.js / Vite environment inheritance means every app in the monorepo reads the same `.env.local`. A compromise of that one file leaks credentials across every app + CI pipeline. Fix: move secrets to per-app `apps/<name>/.env.local`; root `.env.example` only (no real values); Turbo env config gates which env vars propagate to which task. 

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
- **AP-20 Dark mode as second-class citizen** — dark mode ships as an afterthought: inverted colors instead of proper semantic token swap, untested scenes (cards invisible on dark bg, overlays washed out, photos burn retinas, primary accent illegible). Testing matrix is light-only; QA + screenshot tests never cover dark. Fix: (1) both modes designed in parallel from commit 1, not dark as follow-up; (2) semantic tokens (`color.surface.elevated`, `color.text.primary`, `color.accent`) map to HSL pairs — one source of truth, two render outputs; (3) screenshot CI captures both modes on every PR touching UI; (4) no component shipped without both visuals reviewed; (5) explicit elevation strategy for dark mode (not just darker shadows — luminance hierarchy via layered surface tints).
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
- **AP-08 Payment provider hardcoded to sandbox or live** — sandbox↔live selection is not a pure env-var switch, webhook signature not cryptographically verified, or the same code path is not exercised in both modes (sandbox tests don't cover live). Fix: `PAYMENT_BASE_URL` env-toggled; HMAC/signature verification on every webhook; TRY+USD dual-amount tables covered by tests. py:35-43, 717-742`

## Security anti-patterns

- **Secrets in committed files** — API keys in `.env`, `.mcp.json`, or source
- **Secrets in Dockerfile layers** — `COPY.env.env` or similar
- **SSRF via integrations** — fetching user-supplied URLs without allowlist
- **XSS via unsanitized HTML rendering**
- **CSRF on state-changing endpoints with only cookie auth**
- **CORS wildcard on authenticated endpoints**
- **Weak password recovery** — reset link with no expiration or reuse protection
- **Brute-force friendly login** — no lockout, no rate limit, no captcha
- **Credential stuffing exposure** — no detection of high-velocity login attempts
- **AP-02 Token in URL / query parameter** — JWT or auth token passed as URL query string or WebSocket path fragment. Logged by nginx access logs, cached by CDN, exposed in browser history, leaked via Referrer header. Fix: Use a ticket system (exchange JWT for 30s-TTL ticket via REST, then connect with ticket); or accept token in first WebSocket frame. md:216-244`
- **AP-06 `user_metadata` as authorization source** — on Supabase/GoTrue (and analogous identity providers), `user_metadata` is client-writable via the SDK. Using it to check "is admin" or "has permission" is an authorization bypass. Fix: canonical source is a server-side DB row (e.g. `user_role_assignments`), cached with TTL invalidation on role changes. py:37-73`

## Data / persistence anti-patterns

- **N+1 queries** — a loop that issues one query per item instead of a join
- **Missing indexes on foreign keys or high-cardinality filters**
- **RLS asymmetry** — row-level security on some tables but not on sibling tables with the same data shape
- **Unbounded queries** — no pagination, no limit
- **Migrations that lock tables for minutes** — on tables hot in production
- **No rollback path on migration** — DDL without a reverse script
- **AP-01 In-memory state not durable** — application state (rate limits, active jobs, progress tracking, session cache) stored in process memory without a persistence layer. Restart = data loss. Horizontal scaling impossible (each instance has independent state). Rate limits reset on every deploy. Fix: back with Redis (rate limiter: 1-line change to slowapi; job state: TTL-based hash operations). md:182-213`
- **AP-04 Unvalidated JSONB storage** — arbitrary JSON written to a JSONB column without Pydantic/Zod validation before insert and without a DB-level check constraint. Silent data corruption; frontend receives `undefined` for missing fields; historical data inconsistent. Fix: Pydantic model with discriminated union; validate before insertion; add `CHECK jsonb_typeof(col) = 'object'` and per-key assertions at DB level. md:155-178`
- **AP-07 DDL at router / module import time** — `CREATE TABLE IF NOT EXISTS` (or `CREATE INDEX IF NOT EXISTS`) executed as a side effect of `import`. Race conditions on first boot with multiple workers; schema drift across instances; migration failures silently logged. Fix: consolidate into an explicit migration runner with versioned, idempotent migrations. Downgrade to warning if single-node deploy is a documented constraint. py:20-42`

## Infra / release anti-patterns

- **No rollback plan** — deploy scripts that can't undo
- **Manual deploy steps** — "ssh in and run this" without CI
- **Cert auto-renew without fallback** — expires and the product dies
- **No observability dashboards** — running blind in prod
- **No crash reporting** — mobile apps shipping without Sentry / Crashlytics
- **Single environment** — no staging, changes go straight to prod
- **No env separation of secrets** — dev keys work in prod
- **AP-17 No database backup / disaster recovery plan** — production Postgres (or any DB) runs on Docker volumes with no `pg_dump` cron, no off-host replication, no tested restore procedure, no RTO/RPO targets. "The volume persists across restart" is not a backup. Volume corruption, container delete, host SSD failure = total data loss. Fix: cron-scheduled `pg_dump` to off-host (S3 / R2 / remote rsync), retention matrix (daily 7d + weekly 4w + monthly 12m), QUARTERLY restore drill that actually spins up a test instance and runs a schema + row diff. 
- **AP-18 Static HMAC over empty body in deploy webhook** — `.github/workflows/deploy.yml` POSTs to a deploy webhook, computing `HMAC-SHA256` over an empty JSON body (`{}` or `""`). The signature is therefore a constant — anyone who sees it once can replay it indefinitely. Fix: (1) HMAC must be over the actual request body including `commit` SHA + `trigger_source` + timestamp; (2) include a per-request nonce or use the timestamp with a ≤5-minute replay window; (3) deploy webhook rejects requests where the signed body doesn't match the received body. 
- **AP-03 Non-blocking CI gate** — CI job configured with `continue-on-error: true` on secrets / security / test steps, producing "green" runs that hide failures. The gate gives false confidence; teams ignore red in logs. Fix: remove all `continue-on-error: true`; make each gate a `needs:` dependency of the deploy job; initial failure is expected (gradually raise thresholds). md:248-284`. **Meta-ironic case**: Ulak OS itself shipped this anti-pattern in `scripts/validate-schemas.sh` (parse-only, not `$schema`-conforming) until v2.1.3 — DY-02 in self-audit. **Resolved in Ulak OS v2.1.4**: cycle detection + `$schema` conformance + gitleaks + vendor-parity + eval-smoke CI jobs all now blocking.
- **AP-05 Raw `docker.sock` bind-mount in app container** — application container mounts `/var/run/docker.sock` directly, giving root-equivalent access to the Docker daemon. A compromise of the app = full host compromise. Fix: `tecnativa/docker-socket-proxy` sidecar with verb allowlist (`CONTAINERS=1 EXEC=0 POST=0` for read-only introspection), socket mounted read-only on the proxy, `cap_drop: ALL`, `no-new-privileges:true`. App connects via `DOCKER_HOST=tcp://docker-proxy:2375`. yml:103-120`
- **AP-12 Fake rollback deploy** — `infrastructure/deploy.sh` claims to handle rollback but: no `pg_dump` before migration, no `/health` check after deploy, exit codes swallowed by outer wrapper. `.github/workflows/deploy.yml` reports green even when the deploy script silently failed mid-step. Result: a bad migration becomes hours of invisible downtime before someone notices visual breakage. Fix: (1) mandatory pre-deploy DB backup step with retention; (2) post-restart health check that exits non-zero on failure; (3) automated rollback path tested quarterly (not just documented). 
- **AP-13 `server-only` installed but never imported** — `package.json` declares `"server-only": "^0.0.1"` (Next.js helper that throws a build error if imported from client code). But `grep -r "import 'server-only'"` returns 0 hits. Meanwhile `lib/supabase-admin.ts` holds the service-role key AND is in the import graph of client components (via a shared utility). A single bad import day = service role key ends up in the browser bundle with no build warning. Fix: put `import 'server-only'` at the top of every file containing server-role secrets; CI grep check ensures the import exists in the expected files. 

## Localization anti-patterns

- **ASCII fold in display text** — Turkish rendered without special characters
- **`toUpperCase` / `toLowerCase` without locale** — any language that has locale-sensitive case
- **Hardcoded strings in source** — strings that should be in i18n files
- **Shared normalization for display and search** — the display form and the search form must differ
- **Claiming locale support when only UI is translated** — email / push / legal / store not covered
- **AP-21 Locale-blind case conversion** — code calls `.toLowerCase()` / `.toUpperCase()` (or `.lower()` / `.upper()`) anywhere a Turkish (or German `ß`, Greek final-sigma, Lithuanian `i̇`) string can flow through, without the locale argument. Concrete failures: `"İSTANBUL".toLowerCase()` returns `"i̇stanbul"` (combining dot above U+0307) in default locale — does not match `"istanbul"` typed by user; `"isim".toUpperCase()` returns `"ISIM"` not `"İSİM"` (i → I instead of i → İ); login lookup `email.toLowerCase() === input.toLowerCase()` fails when user registered with capital `İ` in domain. Pattern is most dangerous on **search / lookup / dedupe paths**, not just display. Fix: every case operation that touches user-supplied or potentially-Turkish text uses `String#toLocaleLowerCase('tr')` / `'tr-TR'` (JS), `str.lower()` with PyICU `Locale("tr")` (Python), `String#lowercase(Locale.forLanguageTag("tr-TR"))` (Java/Kotlin), `LOWER(col COLLATE "tr-TR-x-icu")` (Postgres). Lint rule: ban naked `.toLowerCase()` / `.toUpperCase()` in any project where `tr` is in `SUPPORTED_LOCALES`. See `docs/runtime/turkish-normalization.md` and `docs/runtime/rule-packs/turkish-locale.md`.
- **AP-22 Turkish slug collision + display leak** — slug generator (`slugify("İstanbul")`) folds Turkish characters to ASCII (`"istanbul"`) without a collision-resolution strategy AND the slug is reused as a display label. Three failure modes layered: (1) information loss — `İstanbul` and `Istanbul` (rare but legal) both slug to `istanbul`; (2) collision unresolved — `Şişli` and `Sisli` (a real city + a possible spelling) both slug to `sisli`, second insert fails or silently overwrites; (3) display-from-slug — UI breadcrumb / page title computed from slug instead of from the original record's display field, so users see `istanbul` instead of `İstanbul`. Fix: keep three separate fields per record — `display` (Unicode-preserved: `İstanbul`), `search_key` (folded for search: `istanbul`), `slug` (URL-safe with collision suffix: `istanbul`, `istanbul-2`, `istanbul-yenisehir-mahallesi`). Slug is one-way: never derive `display` from `slug`. Collision resolution at insert time (numeric suffix or city-disambiguation token) — never rely on database UNIQUE constraint failure to surface this. See `docs/runtime/turkish-normalization.md §Display vs search vs slug`.
- **AP-23 God i18n file** — single `i18n.ts` / `messages.ts` / `translations.py` >3000 LOC bundling every locale's full dictionary into one module. Failure modes: (1) entire file ships in initial JS bundle — 6+ locales × 1000+ keys × ~80 bytes = 500KB+ of strings the user does not need; (2) cannot lazy-load active locale — webpack / vite cannot tree-shake hand-rolled `const X_TRANSLATIONS = { ... }` constants; (3) merge conflicts — every PR that adds a string touches the same file from N branches; (4) translator workflow blocked — translators cannot work on a locale subset without seeing the entire app's strings. Fix: Strangler Fig protocol (`docs/runtime/strangler-fig-protocol.md`) — Step A: split per-locale dictionaries to `messages/<locale>.json`; Step B: dynamic import `messages/${activeLocale}.json` on locale activation; Step C: keep only the locale **registry** (codes + native names + RTL flag) in TS; Step D: per-locale lazy chunks via `import()`. Trigger threshold: file >1500 LOC OR >4 locales bundled together. See `docs/runtime/rule-packs/multi-locale-eleven-rtl.md §Lazy-load`.

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
action: rm -rf /opt//
pre_check:
 - LP-09: "ls -la /opt//" returned only README stubs
 - result: BLOCKED — found.env.local (Apr 9), not stale
 - resolution: chmod 0600 instead; operator decision on rm
```

This pattern was observed as a pivot in the Sprint 0+1 session (2026-04-11, FP-07). The director had scheduled `rm -rf /opt//` as R-119 because static analysis said the directory was stale. The Wave 3 live probe found an `.env.local` with real secrets. The destructive action was cancelled, the finding was downgraded from a delete to a chmod, and a new finding (NF-03) was issued. Without the pre-check live probe, the director would have blindly deleted secrets.

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
