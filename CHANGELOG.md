# Changelog

## [2.2.1] — 2026-04-21 — Security hardening + scaffolder build-break close + misc polish

### Context

Post-v2.2.0 test pass (3 specialist agents) surfaced 42 security findings + 1 P0 cartography gap (missing component templates breaking post-scaffold `pnpm build`). This patch closes the 4 Critical + 9 High-impact security findings AND the build-break. Remaining 17 Medium + 6 Low security items carried to v2.2.2.

### Security fixes (SEC-V22-C-01..04 + high-impact H series)

**Critical (24h gate) — 4 closed:**

- **SEC-V22-C-01** Iyzico signature compare non-constant-time → switched to `crypto.timingSafeEqual` + length precheck. Timing-leak (~280k samples) vector closed.
- **SEC-V22-C-02** Iyzico canonical string excluded body → switched default to V3 HMAC-SHA256 over raw body. Classic SHA1-over-3-fields path kept behind `IYZICO_LEGACY_CLASSIC_SIG=1` deprecation flag for merchants not yet migrated. Attacker can no longer swap `subscriptionReferenceCode`/`status`/`price`/`currency` after capturing a sig.
- **SEC-V22-C-03** Iyzico synthetic event_id fallback → `iyziPaymentId` now required as idempotency anchor; synthetic fallback removed; events without paymentId are dead-lettered (200 ACK) rather than replayed. Silent-ACK on sig failure now emits structured metric line for detection.
- **SEC-V22-C-04** Bot↔API HMAC no timestamp/nonce + shared secret → new `sign_outbound()` returns `{signature, timestamp, nonce, body_hash}`. Canonical string includes `METHOD\n PATH\n TIMESTAMP\n NONCE\n SHA256(BODY)\n`. Verifier enforces ±60s timestamp window + nonce-once-only via `NonceStore` protocol (Redis `SETNX` in prod). HMAC secret is now DISTINCT from Bearer identity token.

**High — 9 closed (6 highlighted in summary):**

- **SEC-V22-H-02** FastAPI JWT RS256 pinned (HS256 allowed only in non-prod with explicit secret)
- **SEC-V22-H-04** Bot api_client email URL-encoded via `urllib.parse.quote`
- **SEC-V22-H-06** SAML `wantAuthnRequestsSigned: true` + STE signing order
- **SEC-V22-H-07** OIDC `resolveSecret` enforces `OIDC_CLIENT_SECRET_` prefix allowlist (blocks admin env-var exfiltration)
- **SEC-V22-H-11** member-gated `posts` RLS now joins through thread tier gate (BOLA closed)
- **SEC-V22-H-12** Google LLM API key moved from URL query to `x-goog-api-key` header
- **SEC-V22-H-13** Cost-cap TOCTOU → atomic `ai_relay_reserve_budget` RPC with `SELECT ... FOR UPDATE` + `reserved_cents` increment + reservation_id release
- **SEC-V22-H-14** Traefik CSP drops `unsafe-eval`, adds `base-uri 'self' form-action 'self' object-src 'none'`
- **SEC-V22-H-15** Compatibility matrix now enforced at code level via `docs/runtime/sectors-compat.yaml` + Phase 0 refusal with `exit 65`

### Cartography P0 (build-break close)

v1.1 page templates under `app/(auth|customer|admin|partner)/*` imported from component directories that did not exist on disk, breaking `pnpm build`. 26 new component templates close the gap:

- `components/admin/*` (7) — stat-tile + system-health-card shims, user-row-actions, audit-log-filters, tenant-stats-card, sidebar + top-bar role shims
- `components/customer/*` (9) — sidebar + top-bar + mobile-sidebar-trigger; welcome-card, quick-actions-grid, recent-activity-list; 5 settings forms (profile, account, preferences, billing, team)
- `components/partner/*` (3) — commission-chart, sub-users-table, payout-status-card
- `components/dashboard/*` (2) — stat-tile primitive, system-health-card primitive
- `components/shared/*` (2) — empty-state re-export, confirm-dialog with type-to-confirm pattern
- `components/ui/alert.tsx` — cva-variant Alert/AlertTitle/AlertDescription

### Other polish (from tasks 45-47)

- **saas-starter Dockerfile.template** — multi-stage build (deps → builder → runner) with non-root nextjs user + healthcheck. Previously only a comment reference in docker-compose.
- **SEC-B-10 deploy rollback** — COMMIT argument strict regex validation; `.next/` cleanup on all three deploy code paths (fresh / health-fail rollback / sha-mismatch rollback)
- **SEC-B-12 install-hooks HMAC** — `preflight-bypass:` token is now `reason|timestamp|hex-hmac` with auto-generated per-clone secret (gitignored), 24h expiry, audit logged. `scripts/mint-preflight-bypass.sh.template` helper ships.

### Package metadata

- `package.json` / `prompts/pack.json` / `.claude-plugin/plugin.json` — all three 2.2.0 → 2.2.1

### Deferred to v2.2.2

- Stripe webhook metric emission (H-01) — non-critical given other fixes
- FastAPI JWKS no-size-cap + circuit breaker (H-03)
- FastAPI `/internal/` webhook timestamp replay guard (H-05) — same shape as C-04
- PHI DEK hex-stringify weak KDF (H-08)
- `decryptPhi` audit contract not structural (H-09)
- Break-glass 4h expiry mutable via UPDATE (H-10)
- 17 Medium findings (Stripe PII in dead-letter, rate-limit in-memory, CSRF, AML bypass, dashboard IP allowlist, etc.)
- 6 Low findings
- Server actions at `app/(customer)/settings/actions.ts.template`
- `app/(partner)/_components/` co-located partner page components

## [2.2.0] — 2026-04-21 — Phase E: 14 sector overlay kits (81 templates, 12800+ LOC)

### Context

Sector packs are no longer just governance rules — they ship as template overlays that the scaffolder merges onto the base saas-starter when `--sector <name>` is passed. Closes the "tüm sektörleri de düşün" operator directive from the v2.2 roadmap.

Scaffolder now supports full hybrid-monorepo-sector invocations:

```
/ulak-scaffold my-platform \
  --sector ecommerce \
  --hybrid-backend fastapi \
  --has-mobile \
  --deploy k8s \
  --payment stripe \
  --compliance gdpr,coppa
```

Output: a pnpm-workspaces monorepo with web + api + mobile + ecommerce-specific schemas + checkout flow + k8s manifests + compliance runbooks — all from commit 1.

### 14 sectors materialized (81 files, 12847 LOC)

**Batch 1 (23 files)** — education + fintech + ecommerce + marketplace

- **education** — LMS with courses + lessons + quizzes + COPPA `enforce_coppa_consent` trigger for under-13
- **fintech** — wallet + KYC 3-step flow + AML queue + MASAK/CBRT/OFAC compliance reports; Sumsub/Onfido adapters; balance invariant via `apply_transaction_to_balance` trigger; `transactions.idempotency_key` UNIQUE
- **ecommerce** — catalog + PDP + cart + Stripe Element checkout; AP-EC-02 stock oversell prevention via `reserve_stock_on_order_item` `SELECT FOR UPDATE` trigger
- **marketplace** — two-sided seller + buyer + dispute 5-state FSM + payout FSM; AP-MP-01 commission-rate immutability enforced at DB layer

**Batch 2 (22 files)** — enterprise-b2b + media-content + health-sensitive + ai-copilot

- **enterprise-b2b** — SAML (samlify) + OIDC (openid-client) SSO; teams-within-tenant; bulk user provisioning; AP-SSO-01: IdP attestation never grants session without local `user_role_assignments`
- **media-content** — MDX article CMS + publishing FSM (draft→review→scheduled→published→archived→rejected); comment moderation; revision history trigger
- **health-sensitive** — PHI envelope encryption (KEK in KMS, wrapped DEK per-tenant, 5-min pod cache); granular consent manager (6 data types); break-glass with 2nd admin approval + 4h expiry; data-residency RLS (EU/TR/US isolation)
- **ai-copilot** — streaming chat + thread resume; LLM relay with provider abstraction (anthropic/openai/google); two-level cost-cap; stream-tee token counting

**Batch 3 (20 files)** — pwa-desktop + admin-cms-hardening + ai-relay-cost-control + member-gated-community

- **pwa-desktop** — versioned-cache SW with per-user scope hash (AP-PWA-01 cache-poison prevention via `MessageChannel`); 4-shortcut manifest; background-sync queue with `x-replay-id` idempotency
- **admin-cms-hardening** — impersonation with four-eyes DB constraint + 1h window; feature flags with append-only audit; bulk-actions with soft-100/hard-1000 DB cap
- **ai-relay-cost-control** — cost-cap middleware with 402 short-circuit + `retry-after`; fallback chain per-tenant; attribution by user + feature + conversation; admin dashboard with Recharts
- **member-gated-community** — tier-ranked RLS + AP-COM-01 sitemap CHECK constraint (`required_tier='free' OR is_indexable=false`); privacy-respecting directory; nested-reply threads; unique-solution-per-thread index

**Batch 4 (16 files)** — self-hosted-supabase + regulated-saas + container-k8s

- **self-hosted-supabase** — full docker-compose stack (kong + gotrue/rest/realtime/storage/meta/pgbouncer/studio/postgres) with healthcheck-gated boot order; backup runbook with `pg_dump -Fc` + rsync + continuous WAL shipping + S3 object-lock; upgrade playbook with postgres-first ordering
- **regulated-saas** — SOC 2 Type II readiness (5 TSCs); GDPR + KVKK Madde 9 runbook with DSAR flow + 72h breach notification; 3-layer data-residency enforcement (CHECK + edge 451 + ArgoCD region pinning); `compliance_audit_log` PHI-aware channel with BEFORE INSERT trigger rejecting forbidden keys
- **container-k8s** — RollingUpdate web-deployment + HPA (70% CPU) + PDB (minAvailable 50%); OrderedReady api-statefulset with per-pod PVC; ArgoCD Application (`selfHeal: true` + `prune: true` + PreSync alembic migrate); namespace-per-tenant-env with ResourceQuota + LimitRange defaults + default-deny NetworkPolicy + `pod-security.kubernetes.io/enforce: restricted`

### Skill orchestration (E.3)

`.claude/skills/saas-scaffolder/SKILL.md` v2.2 adds:

- **Input → overlay directory mapping** table (8 input flags mapped to 8 template subdirectories)
- **Merge order** — deterministic 10-step sequence from monorepo-root → base → hybrid-backend → mobile → bot → shared-packages → sector → compliance → deploy target → scaffold-log
- **Override pattern** — `.override.template` suffix supersedes base path; merge log records supersessions
- **Compatibility matrix** — 14 sectors × refuses/allowed/recommended pairings (e.g., ecommerce + health-sensitive refused; ai-copilot + ai-relay-cost-control recommended)
- **Sector-specific anti-patterns** — 14 APs enforced by DB triggers or CHECK constraints; scaffolded projects prevent these by construction

### Anti-patterns enforced by construction (v2.2)

14 new APs across sectors, each enforced at the DB layer:

- AP-EC-02 (ecommerce oversell), AP-SSO-01 (IdP-trust without DB), AP-PHI-01 (unencrypted PHI), AP-PWA-01 (cache poison), AP-COM-01 (gated content in sitemap), AP-AI-01/02/03 (cost-cap, token counting, fallback chain), AP-ADM-01/02 (impersonation audit, bulk cap), AP-REG-01 (PHI in standard audit), AP-MP-01/02/03 (commission/payout/dispute FSM), AP-SHS-01/02 (backup, kong rate limit), AP-K8S-01/02 (resource limits, PDB), AP-COPPA (under-13 consent)

## [2.1.0] — 2026-04-21 — Phase D: community ecosystem integration (6 new commands + 2 new skills)

### Context

Brings superpowers workflow disciplines into first-class Ulak OS citizens, plus governance skills for community pack management. Closes the "web'teki kod mühendisleri için verilmiş acayi büyük komutlar + skill + plugin'ler fetch edilsin ve Ulak OS'a entegre edilsin" operator directive.

### 6 new commands

- `/ulak-audit-deep` — 14-dimension quality scorecard (wraps fourteen-dimension-audit skill with A-F grade + gap-analysis output)
- `/ulak-brainstorm` — pre-implementation ideation (wraps superpowers:brainstorming with spec-file persistence under docs/superpowers/specs/)
- `/ulak-subagent-dispatch` — parallel-subagent coordination (wraps superpowers:dispatching-parallel-agents + subagent-driven-development with orchestrator discipline: redaction sweep + validator pass + commit series)
- `/ulak-test-driven` — Red-Green-Refactor workflow (wraps superpowers:test-driven-development with Ulak evals integration)
- `/ulak-pattern-extract` — cross-project pattern absorption (T1/T2 evidence + pattern-import-ledger entry + native rule-pack/sector-pack/anti-pattern output; redaction-enforced)
- `/ulak-mcp-discover` — MCP server discovery (reads community registries; trust-tier classified; operator-gated allowlist proposal; never auto-installs)

### 2 new skills

- `mcp-governance-auto` — drift detector between `docs/governance/mcp-governance.md` + `.mcp.json` + `settings.local.json`; produces PR-ready reconciliation diff; operator-gated
- `awesome-packs-index` — read-only catalog of community packs from `awesome-claude-code` + MCP registry + GitHub topic scans; license + trust-tier + activity filters; surfaces Ulak OS gaps

### Distribution

- `docs/distribution/community-packs-catalog.md` (new) — curated reference list of community packs (superpowers, awesome-design-md, MCP registry) with classification rubric + integration workflow + reciprocal-submission plan
- `.claude-plugin/plugin.json` — capability counts updated: commands 9 → 15, skills 8 → 10, scaffolder_templates 27 → 175, new field `sector_overlays: 17`. flagship_commands + flagship_skills arrays expanded.

## [2.0.0] — 2026-04-21 — Phase C: hybrid-systems scaffolding (monorepo + FastAPI + Expo + Telegram + Traefik)

### Context

Single-stack to multi-service. v1.1 shipped a Next.js+Supabase SaaS; v2.0 turns `/ulak-scaffold` into a hybrid-monorepo generator. When an operator passes `--hybrid-backend fastapi`, `--has-mobile`, `--has-bot telegram`, or `--deploy docker-compose-traefik`, the scaffolder stops writing a flat Next.js project and instead materializes a pnpm-workspaces monorepo with up to four deployable services + three shared packages + a production-ready edge proxy.

This release is the "Ulak OS can produce hybrid systems from scratch" capability closing the v1.0.0 red-team Hybrid gap in full.

### What landed (77 new template files)

**Monorepo root (8 files, templates/monorepo-root/)**:

- `package.json` — pnpm workspaces + Turborepo scripts (`dev`, `dev:web`, `dev:api`, `dev:mobile`, `dev:bot`, `build`, `test`, `compose:up`, `compose:prod`, `db:migrate`)
- `pnpm-workspace.yaml` + `turbo.json` — build pipeline with dependency graph
- `.gitignore` — monorepo-aware (AP-16 + AP-19 prevention at every app level)
- `README.md` — structure map + onboarding
- `infrastructure/docker-compose.hybrid.yml` — 5-service dev stack (web + api + bot + postgres + redis + mailhog + traefik), profiles for opt-in services
- `infrastructure/traefik/{traefik,dynamic}.yml` — production-ready edge: HTTPS redirect + HSTS 2y + CSP + X-Frame-Options + Permissions-Policy + rate-limit middleware + Let's Encrypt

**FastAPI backend (24 files, templates/backends/fastapi/)** — for `--hybrid-backend fastapi`:

- `app/main.py` — FastAPI 0.115+ app factory with CORS + request-id + JWT middleware + routers
- `app/auth.py` — Supabase JWKS JWT verify (RS256) with in-process cache + HS256 fallback for tests; role re-read from `user_role_assignments` per request (AP-06 parity with Next.js `getAuthContext({ force_refresh: true })`)
- `app/config.py` — pydantic-settings with `SecretStr` for every credential
- `app/db.py` — SQLAlchemy 2.0 async engine + `get_db()` dependency
- `app/routes/{health,customer,admin,partner,webhooks}.py` — full REST surface; admin routes include `?page&limit&role&q` pagination with max-limit enforcement; tenant isolation via explicit `.where(Model.tenant_id == auth.tenant_id)` in every query
- `app/models/{base,schemas}.py` — read-only SQLAlchemy views matching Supabase schema (tenants, user_role_assignments, subscriptions, payment_events, audit_log, processed_webhook_events)
- `alembic/` — async migrations pinned to same DB as Next.js (additive only; Supabase canonical)
- `tests/conftest.py + test_health + test_customer` — httpx AsyncClient over ASGITransport, transactional rollback per test, JWT mock, tenant-isolation assertions (customer of tenant A cannot see tenant B data)
- `Dockerfile + pyproject.toml` — Python 3.12-slim non-root; deps: fastapi, uvicorn, sqlalchemy[asyncio], asyncpg, alembic, pydantic-settings, python-jose, httpx, pytest, slowapi

**Expo mobile (16 files, templates/apps/mobile-expo/)** — for `--has-mobile`:

- `app/_layout.tsx` — Expo Router v4 root: GestureHandlerRootView + SafeAreaProvider + QueryClientProvider + AuthGate + RootErrorBoundary + Inter font loading
- `app/(auth)/{login,register,forgot-password}.tsx` — email/password + magic-link + Google/Apple OAuth via Supabase; AP-08 forgot-password enumeration prevention
- `app/(tabs)/{index,explore,notifications,profile}.tsx` — Home greeting + pull-to-refresh; Explore search + category chips; Notifications with Swipeable dismiss + Expo Notifications push-token registration; Profile with bottom-sheet editor + theme/locale/push toggles
- `app/+not-found.tsx` — 404 fallback
- `lib/{supabase,auth,api}.ts` — Zustand session store with `hydrated` flag (prevents auth-gate flicker), TanStack Query with 30s staleTime + JWT auto-inject + Zod-parsed responses
- `app.json + eas.json` — Expo config with bundle IDs, permissions, deep-link scheme; EAS build profiles (development/preview/production)

**Telegram bot (15 files, templates/apps/bot-telegram/)** — for `--has-bot telegram`:

- `bot.py` — aiogram 3.x Dispatcher with Memory|Redis storage + polling|webhook mode (HMAC-verified inbound); `aiohttp` app for webhook mode with `secret_token`
- `config.py` — pydantic-settings with `SecretStr` for `BOT_TOKEN` + `API_SERVICE_TOKEN`; `ALLOWED_USERS` CSV parsed into int set
- `handlers/{start,help,settings,link_account,notifications,errors}.py` — 6 routers with FSM flows for locale + account-linking + rate-limited inbound notifications + global error handler with optional Sentry
- `services/{api_client,hmac_auth,i18n}.py` — signed service-to-service calls to FastAPI (HMAC-SHA256 over `METHOD|PATH|BODY`); shared i18n dict
- `keyboards/inline.py + states/user_states.py` — reusable InlineKeyboard builders + FSM `StatesGroup` declarations
- `Dockerfile + pyproject.toml` — Python 3.12-slim non-root; deps: aiogram >=3.3, redis, pydantic-settings, httpx, sentry-sdk

**Shared packages (12 files, templates/shared-packages/)**:

- `shared/` (6 files) — canonical cross-app types (`Role`, `Surface`, `SubscriptionStatus`, `UserProfile`, `Tenant`, `Subscription`, `PaymentEvent`, `AuditLogEntry`, `Notification`, `Paginated<T>`, `ApiError`), Zod schemas for every API payload + query, constants (`LEGAL_TRANSITIONS` FSM, `PLAN_CAPABILITIES`, `API_PATHS`, `RATE_LIMITS`), `tsconfig.json`
- `ui/` (6 files) — `cn()` className merger, Intl formatters (`formatCurrency` / `formatDate` / `formatRelativeTime` / `formatNumber`), design tokens (spacing/typography/motion/z-index), variant label system (`Variant`, `Size`, `VARIANT_SEMANTICS`)
- `config/` (2 files) — shared `tsconfig.base.json` with strict + isolatedModules + noUncheckedIndexedAccess + exactOptionalPropertyTypes

### Anti-patterns prevented by construction (Phase C additions)

- **AP-06** (user_metadata as authz): FastAPI `get_auth_context()` re-reads role from `user_role_assignments` per request, never trusts JWT `role` claim — parity with Next.js `getAuthContext({ force_refresh: true })`
- **AP-08** (user-enumeration): Expo forgot-password, web forgot-password both return generic success regardless of whether email exists in DB
- **AP-10** (schema drift): `@{{product_name}}/shared/types` is SSOT; FastAPI models are read-only views; Supabase migrations are canonical writes
- **AP-11** (multi-layer auth bypass): every FastAPI route uses `Depends(require_role(...))`; every Next.js server component uses `getAuthContext()`; both paths land at the same tenant-scoped query shape
- **AP-16 + AP-19** (.env.local committed): monorepo `.gitignore` covers root + every `apps/*/.env.*` explicitly
- **AP-18** (static HMAC no-body): service-to-service (bot → api) signs `METHOD|PATH|BODY` + timestamp; inbound webhook verification uses `hmac.compare_digest`

### Package metadata

- `package.json` / `prompts/pack.json` / `.claude-plugin/plugin.json` — all three 1.1.0 → 2.0.0

### Deferred to v2.0.1+ / later phases

- **Skill rewrite (C.8)**: scaffolder skill needs to wire `--hybrid-backend`, `--has-mobile`, `--has-bot`, `--deploy` input flags to their overlay directories. Plumbing documented in `saas-scaffolder/SKILL.md` v1.1 determinism contract; implementation lands in v2.0.1.
- **infrastructure/Dockerfile for web** (caller-note from B.1c): missing; apps/web/Dockerfile lands when scaffolder wraps saas-starter into apps/web/ in v2.0.1.
- **Sector overlays** (Phase E, v2.2): 17 sector-specific overlays (education LMS, fintech KYC/AML, ecommerce cart/checkout, marketplace two-sided, enterprise-b2b SSO, health HIPAA, ai-copilot LLM relay, pwa-desktop, admin-cms-hardening, ai-relay-cost-control, member-gated-community, self-hosted-supabase, regulated, container-k8s)
- **Community ecosystem fetch** (Phase D, v2.1): awesome-claude-code + superpowers + MCP registry integration

## [1.1.0] — 2026-04-21 — Phase B: scaffolder completion (Next.js+Supabase SaaS ship-ready)

### Context

The scaffolder is now a **product skeleton**, not just a governance skeleton. A `/ulak-scaffold` run at v1.1 produces a Next.js 16 + Supabase SaaS project with working auth (customer + admin + partner tiers), real payment integration (Stripe + Iyzico), premium UI (shadcn/ui + Tailwind v4 + dark mode + RTL), 100-key bilingual i18n, Docker Compose stack, CI/CD workflows, and admin/audit-log surfaces — all from commit 1. Closes the `UX-HI-03` 14-file gap from v1.0.0 red-team in full.

### What landed (76 new template files)

**Pages (21 files)** — auth / customer / admin / partner / marketing surfaces:

- Auth: `(auth)/{layout,login,register,forgot-password}` — Supabase SSR, magic-link, social auth gated on `{{has_social_auth}}`, tenant creation in signup transaction, AP-08 user-enumeration prevention on forgot-password
- Customer: `(customer)/{layout,dashboard,settings}` — authenticated shell with role-aware sidebar, welcome + recent-activity dashboard, 5-tab settings (profile/account/billing/team/preferences)
- Admin: `(admin)/{layout,page,users,audit-log}` — AP-06 fresh-DB-role-lookup gate, TanStack user CRUD, audit-log with filter/search/CSV export
- Partner: `(partner)/{layout,page,sub-users}` — reseller surface (gated `{{has_reseller_tier}}`), partner-branded nav, privacy-masked sub-user emails
- Marketing: `(marketing)/{about,pricing,blog,blog/[slug],changelog}` — about page, monthly/annual pricing toggle, MDX blog, runtime CHANGELOG reader
- Landing rewrite: `(public)/page.tsx` from minimal → 369-line premium landing (hero + pricing + feature grid + embla testimonials + FAQ + CTA)

**API routes (6 files)**: `public/health`, `customer/me`, `admin/users`, `partner/sub-users`, `webhooks/stripe`, `webhooks/iyzico` — all using `getAuthContext()` SSOT, tenant-scoped `.eq('tenant_id', ...)` belt-and-suspenders, webhook idempotency + dead-letter + FSM transition guard.

**UI components (24 files)**:

- 15 shadcn/ui primitives under `components/ui/` — button, input, form (RHF+Zod), card, dialog, sheet, dropdown-menu, tabs, accordion, avatar, badge, tooltip, separator, skeleton, toast (Sonner), table, data-table (TanStack v8 with sort/filter/pagination)
- Dashboard shells: `dashboard/{sidebar,top-bar,empty-state}` — role-aware nav, cmd-k search placeholder, notifications/avatar/theme/locale dropdowns, reusable empty-state with illustration slot
- Shared chrome: `shared/{header,footer}` — public-surface navigation + 4-column footer + social + language switcher
- Auth form: `auth/login-form` — RHF + Zod wrapper with inline error + social button row
- Theme provider: next-themes system/light/dark with `disableTransitionOnChange` + FOUC prevention
- Design tokens: `lib/design-tokens.ts` — 159L typed exports (spacing, typography, color oklch, radius, shadow, motion, z-index)

**Payment integration (6 files)**:

- `lib/payments/index.ts` — provider-agnostic interface + 6-state FSM (trialing/pending/active/past_due/canceled/incomplete_expired) + `isLegalTransition()` guard
- `lib/payments/stripe.ts` — full Stripe adapter with `stripe.webhooks.constructEvent()` signature verify, `processed_webhook_events` idempotency, FSM-guarded subscription writes, dead-letter on unknown events
- `lib/payments/iyzico.ts` — Iyzico adapter with HMAC-SHA256 webhook verify, Turkey-specific checkout form init, dual-currency (TRY kurus + USD cents)
- `supabase/migrations/00004_payments.sql` — subscriptions + payment_events (append-only) + processed_webhook_events (idempotency gate) with tenant-scoped RLS, partial-unique active-subscription index, FSM check constraint
- `tests/unit/payments/{stripe,iyzico}.test.ts` — Vitest suites covering sandbox detection, signature rejection, idempotency skip, illegal-transition rejection, dead-letter

**i18n expansion (3 files)**:

- `docs/i18n/{tr,en}.json` — 100+ keys each across brand / nav / auth / customer dashboard / admin / partner / payment / errors / actions / time-ago (was 4 keys at v1.0.0)
- `lib/i18n/index.ts` — server-side `t(key, vars)` helper with cookie → Accept-Language → primary-fallback resolution + `{{var}}` interpolation

**Infrastructure (7 files)**:

- `infrastructure/docker-compose.yml` — dev stack (web + postgres + redis + mailhog) with named volumes + healthchecks
- `infrastructure/docker-compose.prod.yml` — production overrides with Traefik labels + Let's Encrypt + rate-limit middleware + resource limits
- `infrastructure/nginx/{default.conf,security-headers.conf}` — vhost + reusable HSTS/CSP/X-Frame-Options/Permissions-Policy snippet
- `infrastructure/.env.example.prod` — every secret with scope + rotation cadence comment
- `.github/workflows/{deploy,secret-scan}.yml` — webhook-triggered deploy + daily gitleaks
- `.github/dependabot.yml` — weekly grouped PRs, major Next/React pinned

**Supporting updates**:

- `package.json.template` — 17 new deps (Radix 8 packages, @tanstack/react-table, embla-carousel-react, next-themes, sonner, lucide-react, cva, clsx, tailwind-merge, @hookform/resolvers, react-hook-form, stripe)
- `tailwind.config.ts.template` — `darkMode: 'class'`, `admin-*` oklch palette (distinct hue from brand), semantic color tokens (success/warning/info/destructive with fg/bg/border triples)
- `lib/auth/index.ts.template` — new `getAuthContext()` wrapper used by every v1.1 server component + API route; optional `force_refresh` for AP-06 admin role re-read
- `lib/utils.ts.template` (new) — `cn()` className merger, `absoluteUrl()`, Turkish-aware `slugify()`, `formatCurrency()`
- `supabase/config.toml.template` + `supabase/migrations/00003_seed_tenants.sql.template` — local dev config + idempotent dev-env-gated seed

### Skill contract update (saas-scaffolder)

Appended a **determinism contract** + **post-scaffold verification matrix** + **template inventory reference** to `SKILL.md`:

- Template-first, synthesis-second: skill substitutes existing `.template` files verbatim; synthesis allowed only when no template exists AND sector pack marks path `synthesizable: true`; every synthesized file logged with `source: synthesized`
- Idempotency: rerun detects existing output, diffs against fresh template, writes `scaffold-rerun-report.md`, never overwrites operator-modified files without `--force`
- Post-scaffold contract: `pnpm install && pnpm lint && pnpm typecheck && pnpm test && pnpm build && pnpm dev && pnpm preflight` — every gate must pass

### Package metadata

- `package.json` / `prompts/pack.json` / `.claude-plugin/plugin.json` — all three 1.0.1 → 1.1.0.

### Deferred to v1.2+

- **B.5** (more test coverage): E2E auth flow, RLS isolation test, admin role-elevation regression test — scaffolder template-tests baseline landed; expansion to full suites deferred
- **B.6** (SEO + meta): sitemap.ts, robots.ts, manifest.ts, OG image generation — follow-up polish
- **SEC-B-08** (middleware /api/public matcher integration test): scaffolder-template polish, minor surface
- **SEC-B-10** (deploy rollback cleanup + COMMIT validation): scaffolder-template polish

### Anti-patterns prevented by construction (v1.1 additions)

- **AP-06** (user_metadata as authz source) — `getAuthContext({ force_refresh: true })` required for admin surfaces; role always re-read from DB, never from JWT claims
- **AP-08** (user enumeration) — forgot-password flow never reveals whether email exists
- **AP-11** (multi-layer auth bypass) — every server component + API route calls `getAuthContext()` directly; middleware is NOT trusted as the only gate
- **AP-13** (server-only installed but never imported) — `lib/auth/index.ts` + `lib/payments/stripe.ts` + `lib/payments/iyzico.ts` all begin with `import 'server-only'` load-bearing line
- **AP-19** (root .env.local in monorepo) — per-app env files ready for v2.0 monorepo phase

## [1.0.1] — 2026-04-21 — Phase A polish: security deferred items + agent stubs + governance closure

### Context

First patch release after v1.0.0 public-GA. Closes the P1/P2 deferred items from the v1.0.0 red-team + cartography passes; expands the remaining 8 thin specialist agents to full production specs. No breaking changes; purely additive + governance polish.

### Security hardening (deferred items from v1.0.0 red-team)

- **SEC-B-05** — Install one-liner now has a published SHA256 verification path. `README.md` + `README.en.md` Quickstart show Method 1b (curl + sha256sum -c + run). `docs/runbooks/install-methods.md` §Method 1b adds the full walkthrough for POSIX + PowerShell. SHA256 files ship with each tagged GitHub Release.
- **SEC-B-09** — `scripts/validate-schemas.sh` now reads local vendored schemas first (from `schemas/<slug>.json`), then falls back to network fetch, then to parse-only. New `--strict` flag forbids network and parse-only fallback; recommended for CI. `schemas/README.md` explains the vendor policy. Closes the silent-fail-on-network-error surface flagged in v1.0.0 red-team.
- **SEC-B-11** — New `scripts/check-secret-rotation-due.sh` parses `active-variables.yaml` rotation-due dates; warns on 7d+ overdue, errors on 30d+ overdue. Closes the docs-promise-vs-reality gap where `secrets-rotation-policy.md:104` referenced a non-existent script.

### Agent expansions (A.3 — 8 remaining thin stubs → production specs)

Every one of the following was 31L at v1.0.0 GA and is now 90-99L with the canonical structure (role + when-to-dispatch + 8 focus areas + evidence rules + sample YAML finding + hard rules + artefact-write-authorization + deliverable shape):

- `localization-i18n-lead.md` — 95L
- `release-readiness-auditor.md` — 95L
- `privacy-compliance-counsel.md` — 99L
- `seo-aso-growth-strategist.md` — 96L
- `product-business-strategist.md` — 90L
- `support-ops-orchestrator.md` — 93L
- `market-researcher.md` — 93L
- `educational-ux-specialist.md` — 94L

Front-matter `tools:` lists preserved verbatim. Every sample YAML finding conforms to `docs/governance/finding-schema.md`. Total agents at production depth: 10 → 18; stubs remaining: 0 (excluding the persona family which follows a distinct shorter contract).

### Governance stub closure (cartography residuals CART-003/004/006)

- **`docs/governance/rule-collision-matrix.md`** — 12L stub → 81L with 5 worked collision examples covering security-vs-UX, reversibility-vs-pack-quality, evidence-vs-validation, security-vs-reversibility, pack-vs-UX. Resolution protocol documented; every finding with `contradiction_status: direct` now has a canonical process.
- **`docs/governance/autonomy-pressure-layer.md`** — 10L stub → 48L with when-applies / when-not-applies / 6 rules / integration with other governance + anti-patterns.
- **`docs/governance/hidden-maintainer-surface-template.md`** — 11L stub → 70L with what-belongs matrix + authoring conventions + skeleton template. Clarifies the Layer 1 (public runtime) vs Layer 2 (hidden maintainer) split.
- **`tests/README.md`** — new orientation doc explaining why `tests/` is empty at the repo root (prompt regression lives under `evals/`; scaffolder tests live in `templates/saas-starter/tests/`). Closes cartography finding CART-004.

### Package metadata

- `package.json` version: 1.0.0 → 1.0.1
- `prompts/pack.json` version: 1.0.0 → 1.0.1
- `.claude-plugin/plugin.json` version: 1.0.0 → 1.0.1

### Deferred to v1.0.2+

- **SEC-B-08** (middleware /api/public integration test) — scaffolder-template polish; ships with v1.1 scaffolder completion
- **SEC-B-10** (deploy rollback .next/ cleanup + COMMIT validation) — scaffolder-template polish; v1.1
- **SEC-B-12** (install-hooks HMAC bypass token) — v1.0.2 or later
- **SEC-B-14** (MCP allowlist load-time gate) — v1.0.2 or later
- **CART-005** (3 near-orphan docs) — still low-priority; decide in v1.0.2 whether to expand cross-links or accept as "README-only reachable"

## [1.0.0] — 2026-04-21 — Public General Availability (semantic reset from internal v2.4.0)

### Context

v1.0.0 is a **semantic reset**. The internal v1.x → v2.x lineage described in `docs/history/version-lineage.md` was operator-controlled; no external audience was expected to clone and depend on it. v1.0.0 (public GA) is the first release where:

- MIT license is explicit across every package manifest
- README is bilingual (TR + EN) and written for a stranger with five minutes
- Community files (CONTRIBUTING, CODE_OF_CONDUCT, issue/PR templates) are in place
- Installer scripts (POSIX + PowerShell) provide a one-liner install path
- Full showcase + architecture + runbooks + FAQ exist for self-serve adoption
- 8 specialist agent stubs were expanded to production 80–110-line specs
- Plugin marketplace submission prep (CATEGORIES, RATIONALE, screenshots dir) is complete
- awesome-claude-code PR draft ready for upstream submission
- 5-agent adversarial final-test pass (QA, security, release-readiness, cartography, customer-persona) verified the repo against shipping criteria

The version number reset (2.4.0 → 1.0.0) is **intentional**. It follows the same "fresh release under a new distribution context" pattern as the 1.9.1 → 1.0.0 brand-rebrand in 2026-04-07. It is not a regression in capability.

### Tag collision note

The legacy `v1.0.0` tag at commit `39b88e9` (2026-04-07 brand-rename release) is preserved on `origin` for historical reference. This public-GA release ships as `1.0.0` in package manifests; the annotated git tag for public-GA is placed at the public-GA HEAD. See `docs/history/version-lineage.md` for the complete rationale.

### What's in this GA (delta from v2.4.0)

The following content lived on `main` between the v2.4.0 tag and this GA commit, never tagged as independent intermediate releases:

- **Architecture** — 5 mermaid diagrams (overview, director-protocol, scaffolder-flow, vendor-adapters) + index README
- **Showcase** — 4 abstract walkthroughs (audit, scaffold, persona dispatch, cross-project pattern absorption) + video script + index README
- **Installers** — `scripts/install.sh` (POSIX) + `scripts/install.ps1` (PowerShell) + `bin/ulak` wrapper with `doctor` / `init` / `update` / `where` subcommands
- **Runbooks** — first-hour-with-ulak-os, upgrading-from-v2.x, install-methods, troubleshooting
- **FAQ** — `docs/FAQ.md`, 18+ Q&A including "what Ulak OS is NOT"
- **Agent expansions** — 8 previously-31-line stubs expanded to 80–110-line production specs (backend-api-architect, data-database-governor, qa-validation-commander, red-team-challenger, design-system-architect, frontend-ios-flutter-director, prompt-skill-plugin-governor, security-hardening-lead polish)
- **Plugin marketplace prep** — `.claude-plugin/CATEGORIES.md`, `.claude-plugin/RATIONALE.md`, `.claude-plugin/screenshots/README.md` placeholder
- **Distribution** — `docs/distribution/awesome-claude-code-pr.md` ready-to-copy upstream PR draft
- **History** — `docs/history/version-lineage.md` extended through v2.4.0 and documenting the v1.0.0 public-GA semantic reset
- **Release notes** — `docs/release/v1.0.0-release-notes.md`

### Security hardening in GA commit

The red-team adversarial pass surfaced 2 critical + 4 high findings. Code-level fixes landed in this release:

- `scripts/install.sh` — removed `eval` entirely; every command dispatches through argv; `ULAK_*` env vars validated against strict regex allowlists before use; rollback `rm -rf` refuses to delete unless `ULAK_HOME` matches `$HOME/.ulak-os` or `$HOME/.ulak-os-*` pattern
- `templates/saas-starter/supabase/migrations/00002_rls_policies.sql.template` — `role_admin_write` and `role_admin_update` policies now tenant-scoped (binding `NEW.tenant_id = caller.tenant_id`); blocks cross-tenant admin privilege escalation
- `templates/saas-starter/.claude/settings.json.template` — `Bash(docker compose:*)` wildcard split into explicit verbs (ps/up/down/logs/build/restart); `docker run` / `docker exec` / `find -exec` added to deny list; `disableSkillShellExecution: true`
- `scripts/fetch-design-references.sh` — prompt-injection sigil scan before writing third-party upstream content into `reports/current/design-references/`; size sanity check
- `.claude/settings.json` — `Bash(find *)` narrowed to `-name` / `-type` / `-maxdepth`; `find -exec` added to deny; `settings.local.json` read/write denied
- `SECURITY.md` added at repo root with responsible-disclosure policy
- `docs/security/incidents/2026-04-21-v2.1.4-tag-credential-leak.md` — documents SEC-B-01 (Resend + Cloudflare keys recoverable from public v2.1.4 tag); operator rotation required before public push

### Polish landed in GA commit

- README Quickstart surfaces the one-liner installer (curl/iwr) directly (was buried in runbooks drill-down)
- Both READMEs have a new "Yardım + daha fazla okuma" / "Help + further reading" section linking FAQ + runbooks + showcase + architecture + history
- "coming in v2.4.1" stubs replaced with direct links to existing content
- `docs/FAQ.md` broken internal link paths fixed (`./LICENSE` → `../LICENSE` etc.)
- Anti-pattern count corrected to accurately describe 98 bullets / 19 numbered AP-NN
- `.github/vendor-parity-exemptions.txt` — `gemini:ulak-scaffold` exemption documented
- `scripts/validate-imports.sh` — skips `docs/runbooks/` + `docs/user-manual/` and fenced code blocks (prevents false-positive on pedagogical `@`-import examples)
- Retroactive annotated tags for `v2.1.2` and `v2.1.3` (previously CHANGELOG-referenced but missing from git)
- Maintainer section added to both READMEs
- Author and version metadata consistent across package.json, prompts/pack.json, .claude-plugin/plugin.json

### Package metadata

- `package.json` — version: 2.4.0 → 1.0.0; added `bugs` URL + `homepage`; expanded keywords (added claude-code, gemini-cli, codex-cli, audit, scaffolder, governance)
- `prompts/pack.json` — version: 2.4.0 → 1.0.0; corrected skills count 9 → 8; replaced stale `anti_patterns: 79` with `anti_pattern_bullets: 98` + `anti_pattern_numbered: 19`; `compatibility.cli` bumped to `>=1.0.0`
- `.claude-plugin/plugin.json` — version: 2.4.0 → 1.0.0; corrected skills 9 → 8; corrected `scaffolder_templates: 15` → 27; installer one-liners added to `install_notes`; `compatibility.claude_code` bumped to `>=1.0.0`

### Known residual risks (tracked, non-blocking for GA)

- **SEC-B-01** (SECURITY-INCIDENT-2026-04-21) — operator rotation of Resend + Cloudflare keys required before v1.0.0 tag is pushed to origin. Documented in `docs/security/incidents/`.
- **CLI `src/` — empty** — `src/` directory scaffold exists but has no implementation. `ulak` is a shell wrapper. Node/Python CLI rewrite tracked for v1.1.
- **`tests/` — empty** — no unit tests. `evals/` provides golden-set regression coverage. Unit tests tracked for v1.1.
- **Screenshots — placeholder** — operator capture ships in v1.0.1.
- **Plugin marketplace submission** — prep docs ready; actual submission when Claude Code marketplace opens.
- **awesome-claude-code PR** — draft ready; operator submits upstream when v1.0.0 tag is public.

### Forward versioning

- v1.0.1 — patch (screenshots, small polish, deferred security items SEC-B-05/08/09/10/11/12/14)
- v1.1.0 — first post-GA minor (CLI rewrite, unit tests, additional sector packs)
- v2.0.0 — next post-GA major (alternative stack templates, LightRAG memory upgrade, Firecrawl MCP)

The internal v1.x → v2.x lineage is **not** the same as the post-GA v2.0.0 that will eventually follow this v1.0.0. See `docs/history/version-lineage.md` for the complete disambiguation.

## [2.4.0] — 2026-04-21 — Public-launch baseline (Phase 3.0-A): MIT · bilingual README · community files · redaction pass 2

### Context

v2.3.0 closed the v1.0-showcase-readiness pass (plugin packaging + full scaffolder + ADRs). v2.4.0 is the first of the five v3.0 public-launch sub-releases (see `docs/runbooks/` and the v3.0 plan): it removes the legal and onboarding blockers that prevented a stranger from adopting Ulak OS. No new capabilities; this is the **legitimacy + redaction layer** that every subsequent phase depends on.

### Legal

- **`LICENSE`** — new file, MIT license, copyright `2026 Oğuzhan Sert <info@oguzhansert.dev>`. The repo was previously `UNLICENSED`, which legally prevented third-party adoption. MIT chosen for maximum reuse, attribution respect, and ecosystem norm (superpowers, anthropics/skills, everything-claude-code all MIT or equivalent).
- **`package.json` · `prompts/pack.json` · `.claude-plugin/plugin.json`** — all three bumped to `"license": "MIT"` and `"version": "2.4.0"`.

### Documentation

- **`README.md`** — full rewrite targeting a foreign developer who clones the repo and has five minutes. TR remains primary. Dropped operator jargon; added "what it is · 3 things it does · quickstart · architecture link · supported stacks · contribute · license."
- **`README.en.md`** — new, EN parity with the TR rewrite. Same structure, same sections, same quickstart commands.
- **`CONTRIBUTING.md`** — full rewrite. Workflow (issue → discussion → PR), commit message format, redaction discipline with good/bad examples, ADR triggers, test expectations.
- **`CODE_OF_CONDUCT.md`** — new, adopts Contributor Covenant v2.1 with operator contact.
- **`.github/ISSUE_TEMPLATE/{bug_report, feature_request, pattern_contribution}.md`** — three structured templates covering the pack-unit-type decision matrix.
- **`.github/PULL_REQUEST_TEMPLATE.md`** — governance checklist (surface split, redaction, validation scripts, CHANGELOG discipline).

### Governance: project-name redaction pass 2

A Python redaction script processed **90 files** with **3658 replacements**, removing every occurrence of the operator's real portfolio project names from public docs. Baseline discipline was first established in commit `f2228a0`; this pass closes the residual matches that survived the first pass.

Manual follow-ups after the script:

- `docs/governance/secrets-rotation-policy.md:93` — "Ulak-family portfolio" rewritten to generic shared-secret hazards.
- `docs/adr/ADR-003-product-surface-split-vs-runtime.md` · `docs/adr/ADR-004-pattern-import-ledger.md` — removed concrete portfolio-project name references; now cite abstract "v2.1.3 pattern-extraction pass."
- `CONTRIBUTING.md:120` — removed orphan portfolio-name fragment; replaced with good/bad example pairs that show the expected abstraction level.
- `CHANGELOG.md` v2.2.1 entry — out-of-band note rewritten to avoid naming the scanned candidate project.

**Verification**: repo-wide grep for the seven banned operator portfolio names returns **0 matches**. The only remaining matches for the operator's name are the legitimate author fields in `LICENSE` and `package.json`.

### Governance: operator session reports untracked

- `reports/sessions/2026-04-11-oguzhansert-dev-sprint-0-1/` — previously git-tracked (7 files). Most severe exposure because the operator's real project name was in the directory path itself. `git rm --cached -r` applied; local copies retained for operator reference.
- `.gitignore` — added `reports/sessions/` entry so future session notes stay local-only by construction.

### Package metadata

- `package.json` version: 2.3.0 → 2.4.0 · license: `UNLICENSED` → `MIT`
- `prompts/pack.json` version: 2.3.0 → 2.4.0 · license added: `MIT`
- `.claude-plugin/plugin.json` version: 2.3.0 → 2.4.0 · license: `UNLICENSED` → `MIT`

### Out of scope (deferred to later v3.0 sub-releases)

- Architecture diagrams + showcase walkthroughs → **v2.4.1 (Phase 3.0-B)**
- 8 thin agent expansion + plugin marketplace prep → **v2.5.0 (Phase 3.0-C)**
- `install.sh` / `install.ps1` + runbooks + FAQ → **v2.5.1 (Phase 3.0-D)**
- `awesome-claude-code` PR draft + version-lineage backfill + v3.0.0 release notes → **v3.0.0 (Phase 3.0-E)**

## [2.3.0] — 2026-04-20 — Plugin packaging + full scaffolder templates + ADRs + thin agent polish

### Context

v2.2.3 completed 15 core scaffolder templates. v2.3.0 finishes the v1.0-showcase-readiness pass: plugin packaging manifest + 12 more scaffolder templates (tsconfig, next.config, tailwind, layout, landing, supabase clients, tests, settings) + 5 ADRs for v2.x architectural decisions + 3 expanded thin agents.

### New

- **`.claude-plugin/plugin.json`** — Claude Code marketplace manifest (capabilities, flagship commands + skills, vendor compat)
- **`.claude-plugin/README.md`** — 4 install methods (clone, plugin install, submodule, via scaffolder) + verify + uninstall
- **12 scaffolder templates** in `templates/saas-starter/` — tsconfig.json, next.config.ts, tailwind.config.ts, lib/supabase/{client,server,admin}.ts, app/{layout,globals.css,(public)/page}.tsx, tests/unit/lib.test.ts, tests/e2e/landing.spec.ts,.claude/settings.json
- **5 ADRs** in `docs/adr/` — ADR-001 rule packs 7th unit type · ADR-002 Phase 5 terminal · ADR-003 product vs runtime surface split · ADR-004 pattern import ledger · ADR-005 SaaS scaffolder
- **`docs/adr/README.md`** — ADR index + format + write-when guide
- **3 thin agent expansions** — `cartographer` (31L→90L), `architecture-lead` (31L→95L), `infra-release-sre` (31L→110L) — each with focus areas, evidence rules, finding-schema YAML, hard rules

### Pack counts delta (v2.2.3 → v2.3.0)

- Scaffolder templates: 15 → 27
- ADRs: 1 → 6
- Thin agents expanded: 0 → 3 (15 remaining deferred)
- Plugin manifest: new `.claude-plugin/`

### Deferred to v2.3.x / v3.0

- 15 remaining thin agents
- Showcase UI / GitHub Pages landing
- Firecrawl MCP integration
- LightRAG memory upgrade
- Alternative stack templates (Remix, SvelteKit, FastAPI)

### Package metadata

- `package.json` version: 2.2.3 → 2.3.0
- `prompts/pack.json` version: 2.2.3 → 2.3.0
- `.claude-plugin/plugin.json` version: 2.3.0 (new)

## [2.2.3] — 2026-04-20 — Scaffolder templates complete + awesome-design-md integration

### Context

v2.2.2 shipped the scaffolder infrastructure (command + skill + sector pack) + 5 seed templates. The remaining templates (middleware, auth helper, RLS migrations, CI workflow, deploy script, VPS hardening, preflight) were still in the "skill generates dynamically" mode, which produces inconsistent output. v2.2.3 materializes these as static templates so scaffolded projects are **deterministic from commit 1**.

Also: per operator direction, `VoltAgent/awesome-design-md` (59 brand design-system references) is now cloneable locally via the extended `scripts/fetch-design-references.sh --all` + documented in `docs/references/brand-design-index.md` + integrated into the scaffolder's new `DESIGN.md.template`.

### New template files (10 additions)

Under `templates/saas-starter/`:

- **`DESIGN.md.template`** — project design system starter with `{{design_reference}}` brand substitution; explains inherit-discipline-not-assets principle; Master + per-page override contract baked in
- **`middleware.ts.template`** — Next.js middleware with Supabase SSR session rehydration + dispatch to single auth helper (no inline auth logic — AP-11 prevention by construction)
- **`lib/auth/index.ts.template`** — canonical auth helper used by every entry point; DB-sourced role (AP-06 prevention); `import 'server-only'` on line 1 (AP-13 prevention); surface-gated authz dispatch table covers public / customer / admin / partner
- **`supabase/migrations/00001_initial_schema.sql.template`** — tenants + user_role_assignments + audit_log + webhook_events with `tenant_id` FK, `touch_updated_at` trigger, idempotency-safe DDL
- **`supabase/migrations/00002_rls_policies.sql.template`** — RLS enabled on every user-facing table with tenant-scoped read + admin-only write + append-only audit + service_role bypass documented; cross-tenant verification protocol referenced
- **`.github/workflows/ci-validation.yml.template`** — 3 jobs (validate + gitleaks + e2e); all blocking (no `continue-on-error`); concurrency group cancels in-progress runs
- **`scripts/preflight.sh.template`** — fast mode (~20s, lint + typecheck only) + full mode (mirror CI 1-for-1)
- **`scripts/install-hooks.sh.template`** — installs `.githooks/pre-push`; bypass policy via `preflight-bypass:` commit-message token
- **`infrastructure/deploy.sh.template`** — webhook-triggered; single-flight flock guard; post-deploy health probe with SHA verification (proves NEW code is running, not warm port); automated rollback on failure
- **`infrastructure/kale-kapisi.sh.template`** — VPS hardening (SSH port 2244, key-only, root disabled, UFW, fail2ban); dual-session safety rule enforced via interactive prompt

### Scripts

- **`scripts/fetch-design-references.sh`** rewritten — now supports 4 modes:
 - `<brand>` — fetch one brand into `reports/current/design-references/<brand>/`
 - `--all` — clone full `VoltAgent/awesome-design-md` into `vendor/awesome-design-md/` (gitignored)
 - `--list` — enumerate locally-available brands (requires `--all` first)
 - `--update` — git pull the mirror
 - Offline path: if `vendor/awesome-design-md/` exists, single-brand fetch copies from local mirror instead of hitting the network

### Docs

- **`docs/references/brand-design-index.md`** (new) — committed index of all 59 brand references with category tagging (AI / dev tools / SaaS / fintech / automotive / etc.) + domain→brand suggestions table + update cadence
- **`.gitignore`** extended with `vendor/` block — external references cloned for local reference, not committed

### Scaffolder inputs (extended)

`/ulak-scaffold` now accepts `design_reference=<brand>`. Valid values enumerated in `docs/references/brand-design-index.md`. When provided, the scaffolder writes `DESIGN.md` in the new project citing the chosen brand + inherited discipline.

### Anti-patterns prevented by construction (commit 1 of scaffolded project)

The new templates make these impossible:

- **AP-06 `user_metadata` as authz source** — `lib/auth/index.ts.template` `loadRoleFromDb` reads from `user_role_assignments`, never `user_metadata`
- **AP-10 Multi-file schema drift** — single canonical SQL in `00001_initial_schema.sql.template`; TypeScript types generated from DB (comment notes the generation step)
- **AP-11 Multi-layer auth bypass** — middleware.ts dispatches to `lib/auth`; routes import from `lib/auth`; zero inline cookie checks
- **AP-12 Fake rollback deploy** — `deploy.sh.template` has mandatory health probe + SHA-verification + automated rollback
- **AP-13 `server-only` installed but not imported** — `lib/auth/index.ts.template` line 1 is `import 'server-only'`
- **AP-16 `.env.local` committed** — `.gitignore.template` blocks it
- **AP-18 Static HMAC empty body** — deploy script signs per-deploy `$DEPLOY_ID` + commit SHA, never empty body
- **AP-19 Root `.env.local` in monorepo** — scaffolder documents per-app env file pattern (to be enforced when `has_mobile=true`)

### Pack counts delta (v2.2.2 → v2.2.3)

- Templates in `templates/saas-starter/`: 5 → 15 (10 new)
- Scripts: +0 (updated existing `fetch-design-references.sh`)
- Governance docs: 22 → 22 (no new)
- `vendor/awesome-design-md/` cloned locally (59 brand references; gitignored)

### Deferred to v2.3

- Plugin packaging (`.claude-plugin/` + npm publish)
- Showcase UI / GitHub Pages landing
- Firecrawl MCP integration
- LightRAG memory upgrade
- ADRs for v2.x decisions
- 18 thin specialist agent expansion
- Remaining ~15 scaffolder templates (tsconfig, next.config, tailwind.config, layout.tsx, login page, supabase clients, docker-compose, settings.json, tests,.gitleaks.toml)

### Package metadata

- `package.json` version: 2.2.2 → 2.2.3
- `prompts/pack.json` version: 2.2.2 → 2.2.3

## [2.2.2] — 2026-04-20 — SaaS scaffolder: "Ulak OS produces full-stack SaaS from commit 1"

### Context

v2.2.1 shipped rich governance + 23 sector packs + 8 rule packs + 79 anti-patterns. Capability was **audit / plan / govern**. Missing: **produce**. A user cloning the repo could check their projects but not start a new one with Ulak governance baked in from day 1.

v2.2.2 closes that gap. `/ulak-scaffold` command + `saas-scaffolder` skill + `greenfield-saas-starter` (SP-14) sector pack + `templates/saas-starter/` templates materialize a full-stack SaaS starter directory where every discipline Ulak OS teaches is enforced from commit 1 — not as a retrofit later.

This is the **v1.0 showcase promise**: someone cloning ulak-os from GitHub can produce a full-stack SaaS.

### New command

- **`/ulak-scaffold`** (`.claude/commands/ulak-scaffold.md`) — greenfield SaaS scaffolder. Prompts for product name, domain, stack, locale, payment provider, reseller tier, mobile workspace, hosting. Dispatches the `saas-scaffolder` skill which materializes a complete target directory.

### New skill

- **`saas-scaffolder`** (`.claude/skills/saas-scaffolder/SKILL.md`) — materializes the target tree from inputs. Writes Next.js 16 + TypeScript 5 strict + Tailwind v4 frontend, Supabase SSR + DB + storage backend, optional payment (Stripe / Iyzico / both), i18n SSOT, product-surface-split (customer / admin / optional partner-reseller / public), RLS templates, CI workflows (validate-imports + validate-schemas + gitleaks + dependabot + eval-smoke), pre-push parity scripts, webhook-triggered deploy with health probe + cron-poll fallback, tests (vitest + playwright stubs), `.gitignore` with Ulak's full discipline, `.env.example` with placeholders only, `.claude/` tree with Ulak OS core contract import. Refuses to run if `output_path` exists or if inputs contain real secrets.

### New sector pack

- **SP-14 `greenfield-saas-starter`** — the sector pack that activates when `intervention_mode: CREATE` + `project_state: GREENFIELD` + a SaaS domain match. Documents all the anti-patterns the scaffolder actively prevents by construction (AP-11, AP-12, AP-13, AP-16, AP-17, AP-18, AP-19) and the disciplines it imports from commit 1.

### New runtime dimension

- **15-dimension audit** (was 14) — `docs/runtime/audit-scoring-framework.md` extended with **Performance (web)** dimension. 0-40: no Core Web Vitals tracking; 41-70: CWV tracked in prod, p95 under Google thresholds; 71-100: CWV as SLO + Lighthouse CI per PR with performance budget that blocks regression. Integrates GoogleChrome/web-vitals + lighthouse-ci + harlan-zw/unlighthouse tooling recommendations.

### Template directory

`templates/saas-starter/` seeded with:

- `README.md` — template-directory guide + variable catalog (`{{product_name}}`, `{{locale_primary}}`, etc.)
- `CLAUDE.md.template` — target project's CLAUDE.md importing Ulak OS core contract + listing activated packs
- `.env.example.template` — every env var the activated packs need; placeholders only; zero real secrets
- `.gitignore.template` — full Ulak discipline (`.env.local`, `.claude/settings.local.json`, `.claude/scheduled_tasks.lock`, `.claude/worktrees/`, `reports/current/*`, etc.)
- `package.json.template` — Next 16 + TypeScript 5 + pnpm + vitest + playwright; `postinstall` installs git hooks

### Version synchronization

Multi-surface drift that the QA agent flagged (README said 2.0.0, package.json said 2.2.1, pack.json said 2.0.0, etc.) is now resolved:

- `package.json` → 2.2.2
- `prompts/pack.json` → 2.2.2 (plus updated agent/command/skill counts + new fields: `rule_packs: 8`, `sector_packs: 24`, `anti_patterns: 79`, `governance_docs: 22`, `runtime_rules: 33`; added `scaffold-log` + `scaffold-verdict` to artefacts array)
- `README.md` — full rewrite: quick-start in 5 minutes, two paths (audit existing OR scaffold new), release history current, architecture diagram, governance + anti-pattern list compact

### Pack counts delta (v2.2.1 → v2.2.2)

- Sector packs: 23 → 24 (+SP-14 greenfield-saas-starter)
- Commands: 8 → 9 (+ulak-scaffold)
- Skills: 7 → 8 (+saas-scaffolder)
- Audit dimensions: 14 → 15 (+Performance web)
- Templates directory: NEW (`templates/saas-starter/`)

### First real scaffolder demo (intake produced)

- `reports/current/wording-manager-intake.md` (gitignored, local-only) — operator's "wording manager" idea (content-ops SaaS for brand voice + multi-locale copy + AI tone check) intake'd using the ulak-intake + greenfield-saas-starter discipline. 9-section intake: product thesis, 5 personas, 4 surfaces, technical shape with scaffolder inputs, differentiators vs Contentful/Phrase/Lokalise, 14-day / 10-Wave MVP plan, validation gates, 6 open questions, next action = `/ulak-scaffold` command invocation.

### Deferred (still)

- Plugin packaging (`.claude-plugin/` + npm publish) — v2.3
- Showcase UI / GitHub Pages landing (inspired by ringhyacinth/Star-Office-UI) — v2.3
- Firecrawl MCP integration for market research engine — v2.3
- LightRAG memory upgrade — v2.3
- ADRs for v2.x architectural decisions — v2.2.3 polish
- 18 thin specialist agent expansion — v2.2.3

### Package metadata

- `package.json` version: 2.2.1 → 2.2.2
- `prompts/pack.json` version: 2.0.0 → 2.2.2 (was stale across 4 releases)

## [2.2.1] — 2026-04-20 — Deep-infrastructure absorption (post-v2.2 second scan)

### Context

After v2.2.0 shipped, a user-directed second-pass deep-infrastructure scan ran across , , , , , ,. Three parallel Explore agents, with explicit "no real credentials in output" discipline, surfaced 10 infrastructure patterns that v2.2.0 did NOT cover — most notably the database-backup gap, monorepo root-env leak, static HMAC deploy webhook, cross-tenant RLS verification absence, and baseline observability gap across the entire portfolio.

### Security fix (backported to tag HEAD)

- **`.gitleaks.toml` scrubbed** — v2.1.4 shipped with real credential VALUES inline in the allowlist (full Resend key + partial Cloudflare token + real VPS IP). Previous commit `d1d05d6` removed them from HEAD. v2.1.4 tag history still has them. **Operator must rotate the Resend API key** — it was in public GitHub for ~2 hours between v2.1.4 push and v2.2.0 security fix.

### New anti-patterns (3, AP-17..AP-19)

- **AP-17 No database backup / disaster recovery plan** — Docker volumes alone are not a backup; no off-host dump, no retention, no tested restore. Cross-project finding in +.
- **AP-18 Static HMAC over empty body in deploy webhook** — `openssl dgst -sha256 -hmac $SECRET` over `""`/`"{}"` produces constant signature; infinite replay. Cross-project finding in +.
- **AP-19 Root `.env.local` in monorepo** — Turbo/Next.js/Vite inheritance means root `.env.local` compromise leaks across every app. Finding from.

### New sector packs (2, SP-12..SP-13)

- **SP-12 `self-hosted-supabase-orchestration`** — 9-service compose (postgres + gotrue + postgrest + realtime + storage + postgres-meta + kong + studio + reverse-proxy), dependency-gated startup, cross-tenant RLS verification required, backup discipline required. Evidence: + +.
- **SP-13 `multi-project-traefik-edge`** — Single Traefik fronting N project compose files, shared `edge` network, Let's Encrypt automation, 127.0.0.1 app binding, TLS-terminated-at-edge, cross-project blast radius control. Evidence: 4+ projects on single VPS.

### New runtime rules (2)

- **`docs/runtime/cross-tenant-rls-verification.md`** — 7-step protocol for verifying Row-Level Security actually isolates tenants sharing a Postgres instance. Includes anon probe, authenticated-cross-tenant probe, service-role escape test, write-probe, automated runner spec. Closes a gap shared by + + +.
- **`docs/runtime/transactional-fsm-payment.md`** — Finite state machine for multi-rail payment (Stripe + Iyzico + Telegram Stars + crypto) with explicit timeout + rollback at every transition, `external_id` idempotency, append-only transition audit log. Evidence: TON handler (reserve → connect → send → confirm + timeout rollback).

### New governance docs (2)

- **`docs/governance/secrets-rotation-policy.md`** — Rotation cadence matrix per secret class (JWT 90d, DB 180d, payment 30-90d, Cloudflare 90d, etc.), canonical 9-step rotation procedure, failed-rotation handling, shared-secret hazard tracking, CI enforcement design.
- **`docs/governance/observability-baseline.md`** — Three pillars (structured JSON logs + RED metrics + automated error tracking) with per-stack setup recipes (Next.js/Python/Docker), Phase 5 §5c validation gates (`observability_logging/metrics/errors: pass|fail`), cost discipline, upgrade paths. Closes portfolio-wide "zero observability" gap.

### Extensions

- **`docs/runtime/webhook-ci-deploy-pattern.md`** extended with §6 "Post-deploy health-probe contract" — health endpoint 200 + sample read returns deployed-SHA + dependency liveness + automatic rollback on failure. Closes AP-12 (fake rollback) + AP-18 (static HMAC).

### Core contract import additions

- `@docs/governance/secrets-rotation-policy.md` added
- `@docs/governance/observability-baseline.md` added

### Pack counts delta (v2.2.0 → v2.2.1)

- Sector packs: 21 → 23
- Runtime rule files: +2 (cross-tenant-rls-verification, transactional-fsm-payment)
- Anti-patterns: 76 → 79
- Governance docs: 20 → 22

### Deferred (still)

- Wave 5 polish (18 items from v2.1.3 audit) — v2.2.2
- W6.1 ulak-design-intelligence-mcp — v2.3
- W6.4 mode-loading conditional loader — v2.3
- W6.5 eval harness warn→blocking — after false-positive measurement
- `cross-tenant-rls-verifier` agent implementation — v2.3 (spec in this release, agent file in next)

### Package metadata

- `package.json` version bump: 2.2.0 → 2.2.1

### Out-of-band flags still live

- **Operator action required**: rotate Resend API key (full key was in v2.1.4 tag `.gitleaks.toml` between tag time and `d1d05d6` HEAD cleanup)
- **audit finding**: a scanned candidate project's `eni_terminal.py` contained prompt-injection payload (identified during v2.2.1 scan). No patterns extracted from that source per operator direction. Separate investigation recommended if upstream origin is unknown.

## [2.2.0] — 2026-04-20 — Cross-project pattern absorption (Eksen A)

### Context

v2.1.3 absorbed 39 patterns from. This release does a second absorption pass across 10+ other projects in practice (, , , , , , , , , , ). 3 parallel Explore agents surfaced 18 cross-project-reusable patterns; this release lands them.

Scope is **Eksen A only** of the v2.2 plan. Eksen B (Wave 5 polish, 18 items) and Eksen C (ulak-design-intelligence-mcp, mode-loading conditional loader, eval warn→blocking) are deferred to subsequent patch releases.

### New sector packs (5)

- **SP-07 `admin-cms-hardening`** — Single auth helper reused at every admin entry point (AP-11 prevention); DB-sourced role with TTL cache (not `user_metadata`); CSRF on all mutations including multipart; rate limit on CRUD; per-mutation audit log; `server-only` guards on service-role clients (AP-13 prevention); upload magic-byte sniffing; Origin allowlist; dead-CRUD detection (AP-14). Evidence: 13-specialist consensus + +.

- **SP-08 `ai-relay-cost-control`** — Input length cap, explicit `maxOutputTokens`, per-user + per-session rate limit, streaming-first (SSE/ReadableStream), injection-resistant prompt construction, cost observability (token count + model + user_id to metrics), prompt-log privacy-scoped with TTL, (prompt, context) caching for deterministic queries, AI provider allowlist enforcement, graceful degradation on provider outage. Evidence: + +.

- **SP-09 `telegram-bot`** — aiogram FSM with StatesGroup per domain; MemoryStorage vs RedisStorage decision (ephemeral OK if truly discardable, durable must DB); callback-query-driven navigation with stateless callback data; webhook for prod / long-polling for dev; i18n per-user-language in DB + `t` per-message; Telegram Stars / TON Connect / Stripe / crypto payments; admin commands namespaced; never trust `message.from_user.id` alone for authz. Evidence: (aiogram 3.15 + Supabase + TON + multi-language catalog).

- **SP-10 `member-gated-community-platform`** — Member-gated routes (public / member / admin); event model (event → RSVP → attendance → post-event artifacts); calendar + map discovery (see `docs/runtime/interactive-map-privacy.md`); gallery upload with moderation queue; notification subscriptions per member per type; club-branded email (Resend/SES/Postmark) with respected unsubscribe; role hierarchy audit-logged; RLS enforced at DB level; single-tenant by default. Evidence:.

- **SP-11 `multi-app-nextjs-expo-monorepo`** — apps/admin, apps/web, apps/master, apps/mobile, apps/landing layout; pnpm/Turborepo/Nx workspace; shared packages for ui/schemas/lib; per-app independent deploy; shared auth session across apps via shared apex domain; apps communicate via shared DB schema or event bus (never inter-app HTTP). Evidence: (5-app workspace).

### New rule packs (4) — `docs/runtime/rule-packs/`

- **`turkish-locale.md`** — `.toLocaleLowerCase('tr')` always; normalize for search separately from display; JSON `ensure_ascii:false`; HTML `lang="tr"`; DB collation `tr_TR.UTF-8`; `Intl.*` for dates/numbers. Activated by Turkish product language or operator locale.

- **`localization-ssot.md`** — SSOT locale file (code + display + RTL + fallback); CI-gated missing-key enforcement; RTL handling with CSS logical properties; JSONB translation columns; machine-translation tagging; email/push/legal are locale-gated. Activated at ≥2 locales.

- **`llm-streaming-context-aware.md`** — Context injection at request (route/session state); token cap server-side; input length cap; SSE/ReadableStream (never buffer); cost observability; rate limit per user AND per session; injection-resistant prompt construction; prompt-log TTL'd; (prompt, context) caching. Activated by LLM SDK + streaming API detection.

- **`react-native-expo.md`** — Expo SDK ≥55, React Native ≥0.83; EAS profiles; shared auth with web; deep links + AASA + asset links; `expo-secure-store` for tokens; `expo-image` not RN Image; `expo-file-system` paths; OTA updates with channel per EAS profile; privacy manifests (iOS 17+). Activated by `app.json` + `eas.json` presence.

### New runtime rules (2)

- **`docs/runtime/webhook-ci-deploy-pattern.md`** — GitHub Actions → deploy webhook discipline: 202 async response with `X-Deploy-Id`; flock-guarded idempotent deploy script; post-deploy `/health` smoke check; CI polls `/deploy-status/<id>` until complete or timeout; CI fails on `failed`/`rolled-back`; 90-day log retention. Evidence: `.github/workflows/deploy.yml` + /deploys.

- **`docs/runtime/interactive-map-privacy.md`** — No unsolicited `navigator.geolocation` on page load (explicit consent button only); marker clustering at ≥20 points; city-level zoom default + min-zoom to prevent world-zoom; tile provider declared in privacy policy; coordinates stored as PostGIS `geography`; event coordinates deleted N days after event; keyboard-navigable + non-map fallback for screen readers. Evidence: Leaflet event map.

### New anti-patterns (7, AP-10..AP-16) — `docs/runtime/anti-patterns.md`

- **AP-10 Multi-file schema drift** — same entity in SQL + ORM + Zod + TS type with divergent fields
- **AP-11 Multi-layer auth bypass** — middleware + page + lib + route all independently flawed; compromised cookie walks through
- **AP-12 Fake rollback deploy** — no pg_dump, no health check, exit code swallowed, CI green on broken state
- **AP-13 `server-only` installed but never imported** — latent service-role leak 
- **AP-14 Dead admin CRUD** — admin writes to tables nothing reads; silent contract lie to admin users
- **AP-15 Drag-drop builder without concurrent-edit conflict resolution** — last-write-wins silent loss (homepage_sections)
- **AP-16 `.env.local` committed to git** — live evidence from 2026-04-20; working tree + history both exposure surfaces

AP-03 "non-blocking CI gate" updated with **Resolved in Ulak OS v2.1.4** note — Ulak OS's own CI no longer ships the anti-pattern it teaches consumers to avoid.

### Extensions

- **`docs/runtime/rule-packs/api-security.md`** — transactional messaging section: multi-SMS provider abstraction with WhatsApp fallback, email-header spoofing prevention (SPF + DKIM + DMARC), unsubscribe mandate, bounce handling, per-recipient rate limit.

- **`docs/governance/pattern-import-ledger.md`** — **IL-001 entry live**: → CMS + blog + site-settings + integration-definitions imports. v2.1.3 R4 residual-risk **closed**: T3 memory claim upgraded to T1 via Explore agent verification on 2026-04-20.

- **`docs/runtime/active-variable-contract.md`** — new fields: `OUTPUT_LANGUAGE`, `RULE_PACKS_LOADED`, `RULE_PACKS_PROJECT_OVERRIDES`, `MCP_AUTHORIZED_TOOLS` (now director agent v2.1.3 AG-EXT-02 citations are real).

### Pack counts delta (v2.1.4 → v2.2.0)

- Sector packs: 16 → 21
- Rule packs: 4 → 8
- Runtime rule files: +2 (webhook-ci-deploy, interactive-map-privacy)
- Anti-patterns: 69 → 76
- Active-variable-contract fields: +4

### Residual risk state

- **R4 (pattern-import T3 claim)** — **CLOSED** (T1 verified, IL-001 entry live)
- **R1, R3** (CLI src/ + tests/ deep-scanned) — still open, needs v2.3+
- **R6** (mode-loading deferred) — moved to v2.3 per deferred plan

### Deferred to v2.2.1 or later

- **Eksen B (Wave 5 polish, 18 items)**: 18 thin agent expansion, rule-collision-matrix worked examples, persona-dispatch refinements, guardrail hook, output-profiles locale field, PAT rotation runbook, README filler for empty dirs, canonical-as-of-version footers. None are release blockers.
- **Eksen C (W6 deferrals)**: ulak-design-intelligence-mcp scaffolding (MCP SDK integration), mode-loading conditional loader (major runtime mechanism change), eval harness warn→blocking promotion (pending false-positive measurement).

### Out-of-band (not in this release)

- **.env.local key rotation** — flagged in v2.2.0 planning phase as URGENT. Live Supabase service-role key + Cloudflare API token + Resend key currently in working tree. Operator action required separately from Ulak OS repo: rotate all keys, verify gitignore, optionally purge history.

### Package metadata

- `package.json` version bump: 2.1.4 → 2.2.0

## [2.1.4] — 2026-04-20 — CI hardening (false-green surface closure)

### Context

v2.1.3 self-audit surfaced four "false-green CI" findings (DY-01 no cycle detection in import validator; DY-02 schema validator was parse-only; DY-03 no vendor-parity check; DY-08 eval harness golden set but no runner). v2.1.3 shipped with these deferred to v2.1.4. This release closes them.

### CI hardening

- **W4.14 — `scripts/validate-imports.sh`** extended with DFS-based cycle detection. The validator now builds an @-import adjacency graph across all `.md` files and reports any cycles (file A @-imports B, B @-imports C, C @-imports A). Exit 1 on detection; file-existence check remains as Step 1.

- **W4.15 — `scripts/validate-schemas.sh`** upgraded from parse-only (`python -m json.tool`) to actual `$schema` conformance using the `jsonschema` library. If a JSON file declares `$schema: <url>`, the validator fetches the schema (5s timeout) and validates. Fallback when jsonschema lib is unavailable prints an EXPLICIT WARNING (not silent pass). CI installs jsonschema via `pip install` in the workflow.

- **W4.16 — `scripts/validate-vendor-parity.sh`** (new). Emits a per-command Claude / Gemini / Codex parity matrix. Reports missing commands as failures unless exempted in `.github/vendor-parity-exemptions.txt`. Initial exemptions declared for `frontend-war-room`↔`war-room` naming drift, `market-scan` Gemini-only, `triage-build` not-yet-ported-to-Gemini.

- **W4.17 — `evals/run.sh`** (new) — eval harness runner in warn-only mode. Walks `evals/golden/*.md`, parses assertion blocks, validates structural expectations. v2.1.4 ships warn-only because the golden set was authored before the canonical assertion format was codified; runner surfaces the drift without blocking. v2.2.0 (W6.5) will promote to blocking after false-positive rate is measured.

- **W4.12 — `.github/dependabot.yml`** (new) — weekly npm + github-actions updates with grouped PR limits. Scheduled Monday 09:00 Europe/Istanbul.

- **W4.13 — `.gitleaks.toml` + `.gitleaks.baseline`** (new). Gitleaks config extends default ruleset with allowlist for doc paths (CHANGELOG, sample-validation-plan, etc.) and env-var placeholders like `${GITHUB_PERSONAL_ACCESS_TOKEN}`. Baseline is initially empty (repo was cleaned in v2.1.3).

- **W4.11 — `.github/brand-allowlist.txt`** (new) — the historical-files regex list previously inline in `ci-validation.yml` is extracted. Workflow reads from file. Editable without touching CI YAML.

- **W4.10 — `.github/workflows/ci-validation.yml`** updated:
 - Artefact count threshold: 12 → 14 (AGENTS.md already has 16)
 - Brand check reads from `.github/brand-allowlist.txt`
 - New `gitleaks` job (actions/gitleaks-action@v2) with baseline + config
 - New `eval-smoke` job runs `evals/run.sh` in warn-only mode
 - Vendor-parity step added to main `validate` job
 - Main validate job installs `jsonschema` for $schema conformance

- **W4.18 — `.claude/settings.json`** — SessionStart hook added for log rotation:
 - Rotates any `.claude/logs/*.log` exceeding 1MB into timestamped archive
 - Deletes archives older than 30 days
 - Runs at session start so daily rotation is automatic

### Verification

All four validation scripts pass locally:
- `bash scripts/validate-imports.sh` → ✓ No cycles
- `bash scripts/validate-schemas.sh` → ✓ (parse-only locally; $schema-conforming in CI)
- `bash scripts/validate-vendor-parity.sh` → ✓ with 4 declared exemptions
- `bash evals/run.sh` → warn mode reports golden-set drift (5 goldens need reformat in v2.2)

### Meta-irony resolved

Ulak OS v2.1.3 shipped anti-pattern **AP-03 "non-blocking CI gate"** in its own CI (`validate-schemas.sh` was parse-only, not $schema-conforming — exactly the false-green surface the anti-pattern names). v2.1.4 closes this meta-ironic gap. Ulak OS's own CI now demonstrably enforces the anti-patterns it teaches consumers to avoid.

### Package metadata

- `package.json` version bump: 2.1.3 → 2.1.4

### Deferred to v2.2.0

- W6.5: Promote `evals/run.sh` from warn-only to blocking (after false-positive rate is measured + goldens are reformatted to canonical assertion shape)
- Cross-project pattern absorption (18 patterns from 10+ projects — see `C:\Users\osrt91\.claude\plans\d-edilmeyen-de-i-iklik-yapmam-z-gereken-glimmering-lightning.md`)
- W5.1-W5.18 polish items (18 medium findings from v2.1.3 audit)
- W6.1 ulak-design-intelligence-mcp (scaffolding)
- W6.4 mode-loading conditional loader

## [2.1.3] — 2026-04-18 — -pattern absorption release

### Context

This release integrates 39 patterns extracted from (a production security/compliance scanner with multi-tenant Supabase + Iyzico payments + reseller surface) into Ulak OS runtime and governance docs. A self-audit via `/director komple` produced 85 findings and resolved 6 open questions. Waves 1–4 of the execution roadmap landed in a single session on 2026-04-18.

### New anti-patterns (9) — `docs/runtime/anti-patterns.md`

- **AP-01** In-memory state not durable (rate limits, active jobs lost on restart)
- **AP-02** Token in URL / query parameter (logged, cached, leaked via referrer)
- **AP-03** Non-blocking CI gate (`continue-on-error: true` gives false green) — Ulak OS shipped this in its own `scripts/validate-schemas.sh` pre-v2.1.3 (DY-02)
- **AP-04** Unvalidated JSONB storage (silent data corruption)
- **AP-05** Raw `docker.sock` bind-mount (needs docker-socket-proxy)
- **AP-06** `user_metadata` as authz source (client-writable via SDK)
- **AP-07** DDL at router / module import time (race on first boot)
- **AP-08** Payment provider hardcoded to sandbox or live (needs env toggle)
- **AP-09** Copy-paste service logic (3+ duplicated API clients)

### New sector packs (6) — `docs/runtime/sector-packs.md`

- **SP-01** `multi-tenant-supabase` — shared PG, per-tenant GoTrue + PostgREST
- **SP-02** `container-orchestrating-app` — docker-socket-proxy sidecar pattern
- **SP-03** `payment-integrated-saas` — sandbox↔live env toggle, webhook signature verification
- **SP-04** `regulated-saas` (cybersecurity / fintech-regulated / healthcare variants) — compliance framework-registry
- **SP-05** `reseller-enabled-saas` — 4-surface model with plan-capability gating
- **SP-06** `vps-nginx-compose-topology` — base+dev+prod layering, 127.0.0.1 binds, Kale Kapısı hardening, cron-poll deploy fallback

`saas` pack extended with SP-EXT-01 web-quality-scanner sub-pattern.

### New unit type — Rule Packs

- **`docs/governance/rule-pack-governance.md`** — 7th unit type in the decision matrix (alongside command/agent/skill/hook/MCP/plugin)
- **`docs/governance/plugin-skill-decision.md`** — updated from 6 → 7 unit types
- **4 starter packs** in `docs/runtime/rule-packs/`:
 - `typescript-nextjs.md`
 - `python-fastapi.md`
 - `docker-compose.md`
 - `api-security.md`

### New governance docs (6)

- **`docs/governance/rule-pack-governance.md`** (see above)
- **`docs/governance/settings-permissions-governance.md`** — `.claude/settings.json` + `.local.json` discipline, deny lists, MCP authz, git hygiene. Motivated by Ulak OS's own FIND-SEC-01+02 (settings.local.json was tracked in git with `Bash(*)` + `Delete(*)` wildcards)
- **`docs/governance/product-surface-split.md`** — customer / admin / public / partner-reseller (4-surface product model; NOT to be confused with runtime `surface-split.md` about Public/Hidden/Maintainer layers)
- **`docs/governance/lock-file-hygiene.md`** — TTL + pid liveness + audit trail for `.claude/*.lock`
- **`docs/governance/ai-provider-allowlist.md`** — declared AI provider list + drift detection (Gemini-only constraint across user portfolio)
- **`docs/governance/pattern-import-ledger.md`** — cross-project pattern provenance ledger

### Extended governance docs (4)

- **`docs/governance/mcp-governance.md`** — audit-trail requirement + token rotation runbook
- **`docs/governance/memory-hygiene.md`** — worktree cleanup policy (stale >7d flag, auto-prune eligible >30d)
- **`docs/governance/prompt-supply-chain.md`** — pattern-import-ledger cross-link + AI-provider supply-chain events
- **`docs/governance/artefact-write-authorization.md`** — Phase 5 §5b execution (renamed from old Phase 6 numbering)

### New runtime rules (3 new + 2 extended)

- **`docs/runtime/strangler-fig-protocol.md`** — 4-phase monolith decomposition protocol (A pure → B services → C routers → D engine)
- **`docs/runtime/multi-agent-merge-sequence.md`** — infrastructure → backend → frontend → tests depth-ordered merge protocol
- **`docs/runtime/audit-scoring-framework.md`** — 14-dimension 0-100 scorecard with A-F grade
- **`docs/runtime/runtime-constants.md`** — single source of truth for field names + numeric constants (resolves DY-04 field-name drift `REQUIRED_PACKS` vs `required_sector_packs`)
- **`docs/runtime/toolchain-precheck.md`** — extended with Pre-push parity + VPS baseline sections
- **`docs/runtime/architecture-currency.md`** — extended with Deploy resilience section

### Phase numbering refactor

- **`docs/runtime/program-phases.md`** — Numbering A applied: Phase 5 is terminal; old Phase 5/6/7/8 collapsed into §5a (pack materialization, profile-gated), §5b (execution, permission-gated), §5c (validation gates, always), §5d (manager verdict, always)
- Cross-refs updated in `waves-pattern.md`, `toolchain-precheck.md`, `artefact-write-authorization.md`

### Persona-dispatch accuracy fix

- **`docs/runtime/persona-dispatch-pattern.md:164`** — personas ARE shipped (commit c21204b) — removed the "NOT yet shipped" drift.

### Sample artefact

- **`docs/examples/sample-validation-plan.md`** — §1–§7 worked example with §6 live-probe bank (5 probe examples covering auth bypass, docker.sock mount, reseller plan-capability, webhook HMAC, user_metadata authz). Cross-referenced from `live-probe-contract.md`.

### Agent enhancements (3)

- **`.claude/agents/autonomous-program-director.md`** — rule-pack loader in Phase 0, output_language propagation, live-probe flag propagation, lock-file liveness sweep, worktree health check
- **`.claude/agents/design-system-architect.md`** — Master + per-page override output contract (adopted from ui-ux-pro-max pattern)
- **`.claude/agents/security-hardening-lead.md`** — secrets rotation + history purge runbook, gitleaks baseline setup, pre-commit hook installation, CI hardening cross-link

### New skills (3)

- **`.claude/skills/god-module-decomposition/`** — Strangler Fig executor
- **`.claude/skills/fourteen-dimension-audit/`** — 14-dim scorecard runner
- **`.claude/skills/multi-agent-orchestration/`** — multi-agent Wave planner

### New command

- **`.claude/commands/triage-build.md`** — generic build-failure triage (frontend / backend / container / mobile subsystem sections) with toolchain-precheck gating

### Command frontmatter additions

Added `phases_run` frontmatter + skill cross-references to:
- `pack-gap-audit.md` (Phase 4, + pack-gap-completion skill)
- `intake.md` (Phases 0, 1, 2, + project-intake skill)
- `final-verdict.md` (Phases 4.5, 5, + final-validation skill)
- `frontend-war-room.md` (Phases 2, 3, 4, + design-system Master+page contract)

### Import structure cleanup

- **`CLAUDE.md`** — reduced to adapters + core-contract only (2 governance imports moved to core)
- **`prompts/core/ulak-os-core-contract-2.0.0.md`** — added `@docs/runtime/office-roster.md`, 4 new governance imports (rule-pack, settings-permissions, product-surface-split, lock-file-hygiene), and received `plugin-skill-decision.md` + `rule-collision-matrix.md` from CLAUDE.md

### Security fixes

- `.claude/settings.local.json` untracked from git (was committed with `Bash(*)` + `Delete(*)` wildcards) — FIND-SEC-01+02 resolved
- `.gitignore` extended: `.claude/settings.local.json`, `.claude/scheduled_tasks.lock`, `.claude/worktrees/`
- `.claude/settings.local.example.json` shipped as the committed contract

### Package metadata

- `package.json` version bump: 2.0.0 → 2.1.3

### Residual risks carried to v2.1.4 / v2.2

- **R1** CLI source (`src/`) not deep-scanned
- **R3** `tests/` not deep-scanned
- **R4** Pattern-import ledger claims T3-memory; verify in v2.2
- **R6** Mode-loading mechanism deferred to v2.2
- **W4.18** Log-rotation hook, dependabot, gitleaks CI job, eval runner — Wave 5/6 items carried forward

### Audit trail

- `reports/current/-pattern-extraction.md` — Phase A extraction from (232 lines)
- `reports/current/{runtime-manifest, assumptions, intake, inventory, evidence-register, deep-scan-report, did-you-know, analysis-findings, target-state, execution-roadmap, validation-plan, pack-gap-register, manager-verdict, research-notes}.md` — Phase 0–5 director self-audit artefacts (3,392 lines)

## [Unreleased] — v2.1.2 docs prep continued — FP-01 artefact write authorization fix

### Fix for FP-01 — Subagent Write tool blocked mid-phase

The Sprint 0+1 session (2026-04-11) identified FP-01 as the top priority harness bug: 8 of 13 Phase 2 specialists and 1 of 9 Phase 4 artefacts could not write their `.md` deliverables to disk. They returned content inline and the orchestrator had to re-persist them. The root cause is **not a hook, skill, or settings rule** — it is the default Claude Code system prompt rule against creating planning/decision/analysis documents. The fix must be at the **prompt level**, not the tool level.

#### New governance doc

- **`docs/governance/artefact-write-authorization.md`** — formal override contract for the director protocol. Explains the collision between the default system prompt and the director protocol's artefact chain. Lists authorized write targets per phase (Phase 0 → Phase 5 + profile-specific artefacts). Propagation rule for specialist dispatch (director includes override block verbatim in every specialist brief). What the override does NOT permit (no new README.md, no scratch files, no bypass of permission boundaries). Detection and enforcement protocol (orchestrator-level diff of expected vs actual `reports/current/` contents).

#### Director agent update

- **`.claude/agents/autonomous-program-director.md`** — prominent "Artefact Write Authorization (OVERRIDES DEFAULT SYSTEM PROMPT)" section added at the top (right after the intro, before "Hard rule: depth before verdict"). Includes the propagation rule telling the director to include the override verbatim in every specialist dispatch prompt.

#### Specialist agent updates (19 files)

Each of the 19 specialist agent files gets a short "Artefact Write Authorization" section after its existing "Rules:" block, telling the specialist:
- The default rule does not apply to director-protocol artefacts under `reports/current/**`
- Write target for the specialist dispatch (`reports/current/specialists/<role>.md`)
- Pointer to the full governance doc

Files updated:
- architecture-lead, backend-api-architect, cartographer, data-database-governor,
- design-system-architect, educational-ux-specialist, frontend-ios-flutter-director,
- infra-release-sre, localization-i18n-lead, market-researcher,
- privacy-compliance-counsel, product-business-strategist, prompt-skill-plugin-governor,
- qa-validation-commander, red-team-challenger, release-readiness-auditor,
- security-hardening-lead, seo-aso-growth-strategist, support-ops-orchestrator

#### Command + core contract + CLAUDE.md reinforcement

- **`.claude/commands/director.md`** — adds an "Artefact Write Authorization (OVERRIDES DEFAULT)" section before the artefact chain listing, plus instruction to include the override in specialist dispatches.
- **`prompts/core/ulak-os-core-contract-2.0.0.md`** — new `@docs/governance/artefact-write-authorization.md` @import added to the Governance layer.
- **`CLAUDE.md`** — new runtime default line referencing the artefact write authorization override.

#### Why prompt-level, not hook-level

A Claude Code hook can block or allow tool calls, but it cannot FORCE a tool call the model decided not to make. The default rule causes the model to decline Write and return inline instead; the Write call is never attempted, so no hook fires. The fix has to be at the prompt level — telling the model that the rule does not apply in this context — not at the tool level.

### Patterns from the session (2026-04-11)

A second session report came in from — a security/compliance scanner with 78 HTTP routes, 32 Docker services, 198 pytest + 57 vitest, 4-persona audit producing 92 findings including 4 KATASTROFİK security blockers (SEC-B1 self-escalation to admin, SEC-B2 unauthenticated payment callback, SEC-B3 iyzico webhook signature bypass, SEC-B4 unauth `/config/tools`). Two new patterns were observed and absorbed:

- **`docs/runtime/handoff-plan-contract.md`** — new artefact type. `ulak-handoff-plan.md` is a director-produced file designed as the explicit entry point for a FUTURE session. Different from manager-verdict: manager-verdict closes the current session, handoff-plan opens the next. Conditional-mandatory when verdict is blocked/conditional and more work remains. 13 required sections including exec summary, context files to read, blockers with deadlines, workstream breakdown (business-layer grouping), phase skip recommendations, effort estimate, exact resume command.

- **`docs/runtime/persona-dispatch-pattern.md`** — alternative to discipline-based specialist dispatch. Audits the project as each user role (Customer, Admin, Bayi/Reseller, Security/Red-team, Support, Developer, Compliance) would experience it. Comparison table of specialist vs persona dispatch. When to use each. Dispatch-and-merge protocol with persona overlap as T-tier consensus boost. Output contract per persona (`findings/<persona>-persona.md`). Anti-patterns. The two dispatch modes can coexist — `dispatch=both` in the director command runs both.

### Director command argument surface

- **`.claude/commands/director.md`** — new "Arguments" section documenting:
 - Positional: `komple`, `brownfield audit`, etc.
 - Keyword: `mode=<CREATE|REPAIR|...>`, `entry=<file>`, `skip_phase_1=true`, `skip_phase_2=<comma-list>`, `parallel_dispatch=<N>`, `dispatch=<specialist|persona|both>`, `validation_depth=<light|standard|deep>`, `profile=<AUDIT_PROFILE|...>`
 - Resume form example: `/director komple mode=RESCUE entry=reports/current/ulak-handoff-plan.md skip_phase_1=true parallel_dispatch=9`

### Core contract update (patterns)

- **`prompts/core/ulak-os-core-contract-2.0.0.md`** — two new @imports for the handoff-plan and persona-dispatch contracts in the Runtime rules layer.

### Persona agent files (7 new agents, c21204b)

Makes `docs/runtime/persona-dispatch-pattern.md` runnable. Each persona follows the specialist agent shape:

- `.claude/agents/customer-persona.md`, `admin-persona.md`, `bayi-persona.md`, `security-redteam.md`, `support-persona.md`, `developer-persona.md`, `compliance-persona.md`
- Office roster (`docs/runtime/office-roster.md`) updated with a "Personas" section listing all 7.

### Schema extensions (a0f0cec — UOI-03 + UOI-07 + time-sensitivity)

- **`docs/runtime/anti-patterns.md`** — new "Destructive action without live-probe (gate pattern)" section. Forbidden destructive actions list, pre_check field requirement on every destructive roadmap item. References R-119 rm cancellation from Sprint 1 Wave 3. This is UOI-07.
- **`docs/governance/evidence-trust-scoring.md`** — new "Tier promotion mechanism" section. T-tier promotion and regression rules, consensus promotion via dual-path / multi-specialist overlap. Hard rule: tier promotion without new evidence is fraud. Live probe is the only path to T0. This is UOI-03.
- **`docs/governance/finding-schema.md`** — schema extended with `time_sensitivity` optional block (deadline + reason + deadline_source), `source_personas`, `source_specialists`, explicit T0 in `evidence_trust`. New "Time sensitivity — a third axis" section: orthogonal to severity and priority. Escalation rule: High+ severity with <24h deadline surfaces at top of manager-verdict next-action. Reference: SEC-B1/SEC-B2.

### What's still NOT in this patch

- **Release tag** — still `[Unreleased]`.
- **PG-01 parallel-dispatch-planner skill** — deferred.
- **PG-04 migration-dry-runner skill** — deferred.
- **Director command argument parser** — args documented but not parsed.
- **Workstream extension to waves-pattern.md** — business-layer vs execution-layer grouping should be documented.
- **Docs drift detection in memory-hygiene.md** — pattern from "CLAUDE.md says 17 plugins, reality is 40".
- **v1.x stale reference cleanup** — still ~10 stale v1.0.0/v1.1+ references in `docs/skills-integration/` and `docs/ecosystem/`.

## [Unreleased — earlier] — v2.1.2 docs prep (v2.2 runtime contract drafts)

### Runtime contract additions from the Sprint 0+1 session (2026-04-11)

The 7-file session report under `reports/sessions/2026-04-11--dev-sprint-0-1/` identified 10 friction points and 15 pack-gap proposals from a real 1h 31m + sprint execution run. This patch addresses the contract-level findings (UOI-01, UOI-02, UOI-04, UOI-11) without shipping the harness hook (PG-03 still pending — needs shell/JS implementation, deferred).

#### New runtime contracts

- **`docs/runtime/waves-pattern.md`** — formalizes the "parallel within a Wave, serial between Waves" execution pattern the session improvised. Covers dependency grouping, pre-dispatch conflict map, validation gate between Waves, sub-waves for partial parallelism, reference example from Sprint 1 (9+2+1+VPS agents, zero file conflicts), anti-patterns.

- **`docs/runtime/live-probe-contract.md`** — formalizes Phase 4.5 as conditional-mandatory when `validation-plan.md §6` has ≥1 probe, or any Critical finding depends on T2/T3 claims, or the roadmap contains destructive remote actions. Read-only-by-default rules, timeouts, credential handling, output artefact (`live-probe-results.md`), T-tier promotion rules, new findings layer (NF-* in did-you-know), gate enforcement. References the LP-07 JWT reuse probe and LP-09 /opt/staleness probe from the session as pivot examples.

- **`docs/runtime/dual-path-validation.md`** — formalizes the dual-path non-obvious findings pattern the operator improvised (manual did-you-know in parallel with director Phase 3, then merge). Path A (director) + Path B (independent reviewer) with a merge step. Consensus promotes T2/T3 → T1. Contradictions become probe candidates. Lens diversity guidance for parallel Path B subagents. Anti-patterns against same-prompt parallel, pre-merge contamination, T6/T7 promotion abuse.

#### Core contract update

- **`prompts/core/ulak-os-core-contract-2.0.0.md`** — three new @imports added to the Runtime rules layer (waves-pattern, live-probe-contract, dual-path-validation). Artefakt zinciri expanded to include `live-probe-results` as conditional-mandatory Phase 4.5, and notes that `execution-roadmap` is executed via Waves pattern and `did-you-know` can be optionally enhanced via dual-path validation.

#### Program phases update

- **`docs/runtime/program-phases.md`** — new Phase 4.5 section with purpose, required-when conditions, director tasks, artefacts, phase gate. Phase 3 section gains a dual-path optional enhancement note. Phase 6 section updated to use the Waves pattern with per-Wave conflict maps and per-Wave validation gates.

#### Director agent update

- **`.claude/agents/autonomous-program-director.md`** — Phase 4 synthesis updated to require `depends_on` fields on roadmap items (for Waves grouping) and live probes in validation-plan §6 when T2/T3 evidence is blocking. New Phase 4.5 section added with the conditional-mandatory protocol. Rules section gains three new directives: Waves pattern for execution, Phase 4.5 conditional-mandatory gate, dual-path validation as optional Phase 3 enhancement.

### What's NOT in this patch

- **PG-03 — `director-artefact-write-exempt` hook** — deferred. Needs shell/JS implementation (.claude/hooks/). FP-01 (Write tool blocked mid-phase) remains unfixed until the hook lands. This patch documents the contracts that will be enforced once the hook exists.
- **Harness-level implementations** — all changes are markdown contract docs. The runtime harness (Claude Code hooks, pre-tool-use rules) still needs code changes to match the new contracts.
- **v2.1.2 release tag** — intentionally not tagged yet. This is `[Unreleased]` until PG-03 lands, at which point v2.1.2 or v2.2.0 will ship as a cohesive release.

### Why "Unreleased" instead of a tagged release

Per session report recommendation: "PG-01, PG-02, PG-03 as Critical (they fix the harness itself)". Shipping contract docs without the matching harness fix would announce the rule without the enforcement. The contract docs land first so the next director run can cite them; the hook lands next as v2.1.2 or v2.2.0.

## [2.1.1] — 2026-04-11

### Vendor parity + version-lineage cleanup

Brings Codex/Copilot and Gemini CLI vendor adapters to v2.1.0 parity with Claude Code, and removes the historical version-lineage leak from active runtime contexts.

#### Vendor parity (Claude == Codex == Gemini at v2.1)

- **GEMINI.md / GEMINI.en.md** — rewritten to mirror CLAUDE.md structure: imports core contract + universal-runtime-contract + gemini-cli adapter + governance docs (plugin-skill-decision, rule-collision-matrix). Added Project identity + Runtime defaults + Working rule blocks for symmetry. Gemini-specific reminders updated to reference Phase 0 → Phase 5 protocol.
- **AGENTS.md / AGENTS.en.md** — rewritten with categorized reading order covering Core (4 entries), Runtime discipline v2.1 (11 entries), Operational motors (7 entries), Governance (10 entries), Run state (1 entry). Required behavior section enforces Phase 0 → Phase 5 protocol, parallel specialist dispatch, did-you-know mandate, finding-schema conformance. Required artefacts list now organized by phase and includes deep-scan-report.md, did-you-know.md, validation-result.yaml.
- **`.github/copilot-instructions.md`** — updated to reference core contract v2.0.0 (which transitively imports v2.1 layer), Phase 0 → Phase 5 protocol, file:line citations, parallel dispatch, did-you-know mandate, finding-schema conformance.

#### Adapter docs (3 files)

- **`docs/adapters/claude-code.md`** — expanded from 19-line stub. Added Phase 0 → Phase 5 protocol table with gates, schemas enforced (router, output-profiles, finding-schema, evidence-trust-scoring, active-variable-contract, validation-result-schema), expected behavior with parallel dispatch.
- **`docs/adapters/codex-cli.md`** — expanded from 21-line stub. Added v2.1 protocol table, schemas list, sequential specialist guidance for Codex's tool model (Phase 2 sequential lanes since Codex cannot parallel-dispatch like Claude Code).
- **`docs/adapters/gemini-cli.md`** — expanded from 22-line stub. Added v2.1 protocol table, command table (8 commands matching.gemini/commands/), schemas list, sequential specialist guidance.

#### Gemini commands parity (.gemini/commands/, 5 updated + 3 new)

- **director.toml** — rewritten as full v2.1 protocol prompt. References router, program-phases, artefact-contract, output-profiles, finding-schema, evidence-trust-scoring. Hard rules: no scope menu, file:line inventory, multi-specialist Phase 2, did-you-know mandatory, signoff_status emit.
- **final-verdict.toml** — rewritten to re-read existing artefacts and produce fresh signoff per validation-result-schema.md. Hard rule: no `ready` with unresolved Critical findings.
- **intake.toml** — rewritten as Phase 0 + Phase 1 only (light pass). Listed all surface types to inventory with file:line requirement. Returns and asks before proceeding to full /director komple.
- **market-scan.toml** — rewritten with mandatory questions, T1-T6 source priority, full required output artefact list per market-research-engine.md.
- **frontend/war-room.toml** — rewritten with active specialists list, screen-audit/design-system/question-flow output structure, red-flag detection scan, currency labels.
- **NEW: pack-gap-audit.toml** — inspects operating pack for missing commands/agents/skills/hooks/MCP/docs/evals. Areas covered: command parity, specialist coverage vs 28 analysis contexts, hook governance, MCP gaps, doc gaps, eval gaps.
- **NEW: ulak-intake.toml** — Ulak-specific intake artefact with file intake summary, evidence map, conflict register, missing evidence list per intake-protocol.md.
- **NEW: ulak-design-ref.toml** — fetches public brand design reference (via awesome-design-md) and extracts patterns for frontend war room consumption with synthesis-not-cloning rule.

#### Version-lineage cleanup (the leak)

`docs/history/version-lineage.md` is hidden core content per `docs/governance/surface-split.md`. It was previously @-imported into 4 active loaders, leaking V6 / V7 / V8 / V9 / V10 / 1.x history into every session context. This release removes those imports:

- **CLAUDE.md** — removed `@docs/history/version-lineage.md`
- **CLAUDE.en.md** — same
- **GEMINI.md** — same (replaced as part of parity rewrite)
- **GEMINI.en.md** — same
- **AGENTS.md** — removed from reading order (replaced as part of parity rewrite)
- **AGENTS.en.md** — same
- **`.github/copilot-instructions.md`** — removed "Check version-lineage for public/internal version mapping" line

The file remains in `docs/history/` for maintainer reference. It is no longer auto-loaded into any active runtime context.

### Not changed

- Core contract filename stays `ulak-os-core-contract-2.0.0.md`. The 2.1.x line continues to be additive parity work.
- v2.1.0 director hardening, runtime discipline layer, and eval harness groundwork unchanged.
- No breaking changes to v2.1.0 runs.

## [2.1.0] — 2026-04-11

### Added — V9 Runtime Discipline Integration

Operational discipline from the internal V7 and V9 lineage, integrated into the 2.0 distributed doc architecture. The core contract file stays at 2.0.0; the delta is the runtime and governance layer the contract now imports.

#### Runtime discipline (docs/runtime/)
- `context-budget.md` — layered context model (1 core → 7 sector packs), eviction rules, pin rules, compression stages
- `output-profiles.md` — seven output profiles (AUDIT, GREENFIELD_BUILDER, BROWNFIELD_INTERVENTION, LOCALIZATION_REPAIR, MARKET_ENTRY, PACK_GENERATION, RELEASE_READINESS) with required sections
- `active-variable-contract.md` — Phase 0 YAML contract with request context, surface map, permission boundaries, output location
- `validation-result-schema.md` — Phase 7 YAML with engineering, test, surface gates and signoff status rules
- `toolchain-precheck.md` — tool detection schema (required / conditional / optional / not-needed / not-recommended)
- `intake-protocol.md` — 4-step protocol for user-provided material (file intake, evidence map, conflict register, missing evidence)
- `architecture-currency.md` — question stack and labels (CURRENT_RECOMMENDED, OUTDATED_AVOID, etc.) for architectural recommendations
- `localization-strategy.md` — 5-phase motor for locale work, ADD_NOW / ADD_NEXT_WAVE labels
- `turkish-normalization.md` — Turkish character handling, ı/i/İ/I case pair rules, display vs search vs slug three-layer split
- `market-research-engine.md` — when live research is required, T1-T6 source priority, mandatory questions, required output artefacts
- `sector-packs.md` — core kernel vs optional sector overlays (education, saas, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop)
- `analysis-contexts.md` — 28 mandatory analysis contexts from product/business through prompt/runtime governance
- `anti-patterns.md` — categorized anti-pattern catalog (architectural, frontend, backend, security, data, infra, localization, prompt)
- `universal-surface-inventory.md` — canonical surface taxonomy with broken-surface map requirement for RESCUE
- `roadmap-rule.md` — 60+ step rule with step shape, tag vocabulary, ordering rules

#### Runtime expansions
- `router.md` expanded from 14-line decision list to full 9-field YAML router decision template with surface list and integration hooks
- `artefact-contract.md` expanded with depth requirement, mandatory chain mapped to phases, profile-specific optional artefacts
- `program-phases.md` expanded from 12 lines to 8-phase protocol with per-phase purpose, director tasks, artefacts written, phase gates

#### Governance (docs/governance/)
- `evidence-trust-scoring.md` — T1-T7 tiers, default ordering, required finding fields, integration hooks
- `finding-schema.md` — canonical YAML schema for all findings, severity vs priority split, merge rule
- `trust-model.md` — instructions vs data firewall, injection patterns, trust boundaries
- `surface-split.md` — public runtime / hidden core / maintainer surface separation
- `hook-governance.md` — when hooks are appropriate, security rules, review checklist
- `mcp-governance.md` — scope rules, approved vs high-risk surfaces, approval workflow
- `memory-hygiene.md` — layered memory model, hygiene rules, what goes where
- `prompt-supply-chain.md` — canonical source identification, version labels, release discipline

#### Eval harness groundwork (evals/)
- `golden/01_full_program_komple.md` through `05_frontend_rebuild.md` — expanded from 9-line stubs to full goldens with router YAML, active agent map, assertions, validation criteria, regression signals
- `assertions/core-assertions.md` — 14 assertion types with resolution values and regression signal catalog
- `assertions/README.md` — baseline assertion contract and pointer to core assertions

#### Director hardening
- `.claude/agents/autonomous-program-director.md` — references all new schemas, enforces trust tiers on every finding, profile selection at Phase 0, overlay discipline
- `.claude/commands/director.md` — lists enforced schemas and hard rules for the full protocol
- `prompts/core/ulak-os-core-contract-2.0.0.md` — imports the entire v2.1 runtime and governance layer via `@` imports

### Changed
- The `/director komple` command now runs deep inventory + parallel specialist dispatch + did-you-know by default. Shallow inventory (folder dump) and single-agent evidence are rejected.
- Router decision is now a 9-field YAML pinned for the whole run, not a 4-bullet mental note.
- Every finding must carry evidence_source, evidence_trust, completeness_risk, contradiction_status.

### Not changed
- Core contract filename stays `ulak-os-core-contract-2.0.0.md`. The 2.1.0 delta is the surrounding layer.
- Vendor adapters (Claude Code, Codex/Copilot, Gemini CLI) continue to work unchanged.
- CLI orchestration (`ulak` command) behavior unchanged.
- SQLite memory layer unchanged.
- No breaking changes to 2.0.0 runs.

## [2.0.0] — 2026-04-09

### Added — CLI Console + Memory + Vendor Adapters

- CLI orchestration layer: `ulak` command with 8 subcommands (init, run, status, validate, memory, config, upgrade, export)
- SQLite + FTS5 project memory layer (`.ulak/memory.db`) for cross-session learning extraction
- Vendor adapter abstraction (subprocess-based): Claude Code, Codex/Copilot, Gemini CLI auto-detection and routing
- Pack versioning and upgrade system (`src/pack/loader.ts`, `upgrader.ts`, `validator.ts`)
- TypeScript project infrastructure: `src/` source tree (18 files), `dist/` compiled output, `tsconfig.json`
- vitest test scaffold with unit and e2e configuration
- Platform command parity: Claude and Gemini now share 8 commands each
- `market-scan` command for Claude (was Gemini-only)
- 3 new Gemini commands: `pack-gap-audit`, `ulak-design-ref`, `ulak-intake`
- Core contract v2.0.0 with CLI orchestration, memory, and adapter sections
- 17 new EN translation files for docs/ subdirectories

### Changed

- Core contract reference: `ulak-os-core-contract-1.0.0.md` → `ulak-os-core-contract-2.0.0.md` in all adapter files
- Command count: 6 → 8 per vendor (full parity)
- `package-lock.json` now tracked for reproducible builds

## [1.0.0] — 2026-04-07

### Added — First Stable Public Release (Ulak OS brand)

- Vendor-neutral brand: Claude Ulak → **Ulak OS**
- Three-adapter parity (Claude Code, Codex/Copilot, Gemini CLI) sharing one core contract
- Cross-platform bootstrap scripts: 6 files (`init-{claude,codex,gemini}.{sh,ps1}`)
- CI validation infrastructure: schema validation, @import chain check, brand consistency, gitleaks secret scan
- Public skill integration: `docs/skills-integration/superpowers-mapping.md` + `/ulak-intake` PoC wrapper
- awesome-design-md integration: fetch script + `/ulak-design-ref` wrapper + integration doc (TR + EN)
- Multi-language: TR (primary) + EN (parallel) for README, adapters, core contract, samples, skill integration docs
- Sample artifacts: filled `intake`, `inventory`, `manager-verdict` in TR + EN
- Ecosystem related-work doc covering superpowers, anthropics/skills, gsd-2, awesome-design-md, akin-ozer/devops-skills-plugin (TR + EN)
- Structured ROADMAP with v1.1 candidates (plugin marketplace publication priority)
- LICENSE: MIT, Copyright (c) 2026 Oğuzhan Sert <info@>

### Changed

- Core contract file: `claude-ulak-core-contract-1.9.0.md` → `ulak-os-core-contract-1.0.0.md`
- AGENTS.md required artefacts list aligned with core contract: 8 → 12 entries
- Version reset: 1.9.1 → 1.0.0 (intentional, per first stable public release semantics)

### Documentation

- README troubleshooting section
- README MCP environment variable documentation
- version-lineage.md brand transition note explaining the version reset

The pre-1.0.0 entries below document the internal "Claude Ulak" development series.

Tüm yayınlar **public release** sürümleriyle kaydedilir. İç kod adları parantez içinde tutulur.

## 1.0.0 — Equalized Version Distribution
- Tüm internal sürümler için `releases/<version>/` klasörleri oluşturuldu (sonradan Ulak OS 1.0.0 final cleanup'ta kaldırıldı; arşiv `claude-ulak_1.9.1_equalized_github_repo/` workspace backup'ında korunmaktadır).
- Kişisel arşiv ve GitHub repo tarafı aynı sürüm yapısına getirildi.
- Exact artifact olmayan erken sürümler `reconstructed` olarak işaretlendi.
- Bu sürüm çekirdeği değil, dağıtım düzenini günceller.


## 1.9.0 — Ulak OS Distribution Candidate
- GitHub’a koyulabilir açıklayıcı repo yapısı hazırlandı.
- Claude Code, Codex/Copilot ve Gemini CLI için ayrı adaptör dosyaları eklendi.
- Tek sürüm hattı `1.x` altında birleştirildi.
- İç sürümlerin arşivi `docs/archive/internal-releases/` altına taşındı.
- Dağıtım, portability ve release stratejisi dokümantasyonu eklendi.
- `.gemini/commands/` tabanlı Gemini özel komutları oluşturuldu.
- `.github/copilot-instructions.md` ve `AGENTS.md` ile Codex/Copilot uyumu iyileştirildi.

## 1.8.0 — Autonomous Program Director (internal: V10.3)
- Tek istekten tam program akışı başlatan yönetici ajan modeli kuruldu.
- Zorunlu artefakt zinciri standardize edildi.
- Tek dosyalı bootstrap üretildi.
- Hibrit ofis yapısı yönetici merkezli hale geldi.

## 1.7.0 — Hybrid Office Front OS (internal: V10.2)
- 20 kişilik hibrit ajan ofisi yaklaşımı tanımlandı.
- “Komple” intent geldiğinde tekrar menü açmama kuralı getirildi.
- Front savaş odası ve agentic long-prompt çalışma biçimi tanımlandı.

## 1.6.0 — Adaptive Runtime Router (internal: V9)
- Runtime router ve context budget manager eklendi.
- Hidden core / public surface / maintainer surface ayrımı getirildi.
- Intervention mode sistemi eklendi.

## 1.5.0 — Language / Market / Architecture Hardening (internal: V8)
- Türkçe karakter, Unicode ve locale-aware text normalization motoru eklendi.
- Market research ve architecture currency katmanları eklendi.
- Language coverage ve localization release gates güçlendirildi.

## 1.4.0 — V7 Consolidation
- Standard, optimized ve comparison bazlı ilk paketleme yapıldı.
- Önceki birikimler ilk kez üç dosyalı bundle’a dönüştürüldü.

## 1.3.0 — V6.6 Execution Pack
- Claude Code execution-first pack kurgusu kuruldu.
- Skills/plugins/subagents/hooks/MCP toplu düşüncesi eklendi.

## 1.2.0 — V6 Prompt Operating System
- Prompt, işletim sistemi olarak ele alınmaya başlandı.
- Coverage matrix, overlays, governance ve release/compliance katmanları büyüdü.

## 1.1.0 — Frontend Modernization Baseline
- Flutter/iOS premium redesign düşüncesi ayrı bir çekirdek haline geldi.
- Screen-by-screen frontend/UX derinliği oluşturuldu.

## 1.0.0 — Master Core Baseline
- Ana mimari, audit, refactor ve modernization omurgası kuruldu.
