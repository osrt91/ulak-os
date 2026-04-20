# Sector Pack Architecture

## Why this exists

"Cover every sector" is a trap. If Ulak OS tries to encode education, fintech, ecommerce, marketplace, enterprise B2B, media, healthcare, and AI copilot knowledge into one always-loaded core, the core becomes unreadable and the context budget collapses. Sector packs solve this by **isolating domain-specific knowledge into overlays that load only when the router activates them**.

A sector pack is not a complete prompt. It's a set of **domain-specific expectations, risk patterns, UX conventions, pricing norms, compliance concerns, and anti-patterns** that the core runtime uses to refine its analysis for a specific industry.

## Core kernel (always loaded)

These are part of the public runtime surface and load every session regardless of sector:

- Router decision contract
- Context budget rules
- Evidence rules (trust scoring, finding schema, trust model)
- Output profiles
- Validation principles
- Claude Code runtime topology
- Language / locale strategy motor
- Architecture currency protocol
- Market research engine (rules for how to use it)
- Intervention modes and project state
- Artefact chain and program phases

The core kernel is **sector-agnostic**. It does not know whether the project is edtech or fintech.

## Optional sector packs

These load only when the router explicitly activates them via `router.required_sector_packs`:

### `education`
Focus areas:
- Study flow continuity (session entry, question reading, answer reveal, explanation, retry, summary, return-later)
- Explanation UX (hierarchy, readability, confidence-building)
- Confidence language (avoid shame, encourage retry)
- Retention without pressure
- Minors sensitivity (data handling, parental controls, COPPA/KVKK minor rules)
- Question-solving UX (iOS-first premium calmness)
- Progress visualization
- Leaderboard ceremony without cheap gamification

### `saas`
Focus areas:
- Onboarding and activation flow
- Role separation (admin / operator / viewer / end-user)
- Settings ergonomics
- Subscription management
- Admin vs customer split rigor
- Analytics taxonomy
- Multi-tenant isolation

**Web-quality-scanner sub-pattern** (SP-EXT-01): SaaS products that scan client websites (security, SEO, accessibility, performance) have a repeatable shape: `BasePlugin` abstract with `run(context)` interface, 9-category weighted scoring engine, multi-format report generation (PDF/HTML/Markdown/JSON), PTES-style phase orchestration (sync or async), result storage validated against Pydantic before DB insertion. Derived from scanner-project.com.

### `fintech`
Focus areas:
- KYC / AML flow
- Consent and disclosure hygiene
- Step-up authentication
- Audit trail completeness
- Storage and privacy for financial data
- Regulatory reporting surfaces
- Operational risk (4-eyes principle on dangerous actions)
- PCI scope minimization

### `ecommerce`
Focus areas:
- Discovery (search, filter, sort, faceted browse)
- PDP (product detail page) hierarchy
- Cart continuity across devices
- Checkout simplicity
- Returns / trust signals
- Search relevance and ranking
- Fraud prevention
- Inventory vs availability surface

### `marketplace`
Focus areas:
- Buyer / seller / admin permission split
- Fraud and abuse patterns (fake listings, chargebacks, credential stuffing)
- Moderation workflows
- Dispute resolution
- Search ranking fairness
- Trust and safety signals
- Payout surfaces

### `enterprise-b2b`
Focus areas:
- SSO / SAML / OIDC
- SCIM provisioning
- Tenant / workspace isolation
- Audit logs with retention
- Approval workflows
- Access review cadence
- Data residency
- Legal review surfaces

### `media-content`
Focus areas:
- Content discovery
- Subscription / paywall models
- Ad surfaces vs subscriber surfaces
- Recommendation quality
- Moderation (user-generated vs editorial)
- DMCA / takedown workflows
- Caching and CDN strategy

### `health-sensitive`
Focus areas:
- PII / PHI handling
- Consent and disclosure
- Minors sensitivity
- Medical disclaimers
- Regulatory jurisdiction (HIPAA / GDPR / KVKK)
- Data retention / deletion
- Access audit

### `ai-copilot`
Focus areas:
- Prompt UX (clarity, examples, undo)
- Grounding (where is the model's answer coming from)
- Hallucination handling (confidence display, verification prompts)
- Tool transparency (show tool calls or summarize)
- Memory boundaries (what persists, what doesn't)
- Refusal design (when and how to say no)
- Training data provenance disclosures

### `pwa-desktop`
Focus areas:
- Install flow
- Offline support
- File system access
- Keyboard / mouse / trackpad ergonomics
- Multi-window behavior
- Desktop-like command surfaces
- Multi-pane layouts

### `multi-tenant-supabase` (SP-01)
Focus areas:
- One PostgreSQL cluster hosts N logical databases (or schemas) — never N PostgreSQL instances
- Per-project GoTrue (auth) container, per-project PostgREST (API) container — JWT secrets never cross-signed between tenants
- Deploy scripts precheck tenant's Docker network (`docker network inspect supabase_<tenant>`) before bringing app services up
- RLS enforced per tenant schema; cross-tenant queries require explicit admin-surface routes
- Authorization source is DB-backed role (`user_role_assignments`), never `user_metadata` (anti-pattern AP-06)
- Migrations are per-tenant and tracked with a `tenant_id` column in the migration registry

Derived from scanner-project.com `SUPABASE.md:24-31`, `docker-compose.yml:48`, `deploy.sh:10`.

### `container-orchestrating-app` (SP-02)
Focus areas:
- Apps that introspect or spawn sibling containers (scanner-style products, CI runners, internal PaaS consoles)
- Docker API access via docker-socket-proxy sidecar, NEVER raw `/var/run/docker.sock` mount (anti-pattern AP-05)
- Proxy configured with explicit verb allowlist (`CONTAINERS=1 EXEC=1 POST=1`), socket mounted read-only, `cap_drop: ALL`, `no-new-privileges:true`, `mem_limit` set
- App connects via `DOCKER_HOST=tcp://docker-proxy:2375` on internal network only
- Exec'd commands audit-logged with caller identity

Derived from scanner-project.com `docker-compose.yml:103-120`.

### `payment-integrated-saas` (SP-03)
Focus areas:
- Sandbox↔live is a **pure env-var switch** (`PAYMENT_BASE_URL`, `PAYMENT_KEY`) — no `if ENV == "prod"` branches, no separate modules (anti-pattern AP-08)
- Webhook signature verification is mandatory on every callback (HMAC or provider-specific)
- Raw webhook body capture is env-toggleable (`*_CAPTURE=1`) for incident forensics; capture is NOT on by default
- TRY + USD (or multi-currency) dual-amount tables; yearly-discount invariants covered by tests
- Idempotency keys on payment intents; duplicate webhook deliveries must not double-charge
- Payment provider lock-in audit: if Stripe is primary, Iyzico fallback (or vice versa) should exist for regional compliance

Orthogonal to `fintech` — `fintech` covers the PRODUCT being a financial service; `payment-integrated-saas` covers any SaaS that accepts payments (most do). Activate both when product is fintech AND accepts payments.

Derived from scanner-project.com `payment.py:35-43, 717-742`.

### `regulated-saas` (SP-04)
Focus areas (three variants — activate the relevant variant):

**Variant A — Cybersecurity regulated**:
- Compliance framework-registry: one adapter per framework (CVSS v4.0, MITRE ATT&CK, NIST CSF, ISO 27001, KEV, KVKK-GDPR)
- Each adapter takes `findings[]` and returns `summary` dict with shared shape
- One aggregator produces audit-ready Markdown / PDF report combining all frameworks
- Findings flow through shared `severity → severity_bucket` normalization

**Variant B — Fintech regulated** (overlays `fintech`):
- KYC/AML framework registry (per jurisdiction)
- Transaction reporting hooks (e.g. FinCEN SAR, AB SFTR)
- 4-eyes principle on dangerous actions enforced at code level

**Variant C — Healthcare regulated** (overlays `health-sensitive`):
- HIPAA adapter (or GDPR health-data variant) for audit trail
- Consent artefact generation
- Right-to-be-forgotten operational runbook

When `sector: regulated` is declared, the compliance-framework-registry specialist dispatches to verify at least one adapter per mandated framework and that an aggregator produces a single audit-ready report.

Derived from scanner-project.com `compliance_reporter.py`, `cvss_processor.py`, `mitre_attack.py`, `nist_csf.py`, `iso27001.py`, `kev_checker.py`.

### `reseller-enabled-saas` (SP-05)
Focus areas:
- Fourth product surface beyond public / customer / admin (see `docs/governance/product-surface-split.md`)
- Authorization gate is **plan capability** (not role) — `user.plan.reseller_enabled == true`
- Per-reseller branding data model (logo, color tokens, custom domain) scoped to the reseller's tenant tree
- Sub-user provisioning: reseller can create customer accounts but cannot grant capabilities they don't have themselves
- Commission / payout calculations carry their own audit log surface
- White-label email templates scoped per reseller
- `bayi-persona` agent activated in Phase 2 dispatch (Turkish products especially)

Derived from scanner-project.com `app/routers/reseller.py:17`, `app/models/reseller_branding.py`.

### `vps-nginx-compose-topology` (SP-06)
Focus areas:
- Base compose + dev override + prod override three-file layering
- Prod bindings use `127.0.0.1:<port>`; nginx is the sole public ingress
- Prod compose adds `security_opt: [no-new-privileges:true]`, `cap_drop: ALL`, `mem_limit`
- "Kale Kapısı" VPS hardening baseline: non-default SSH port (e.g. 2244), key-only auth, root disabled, UFW enabled, fail2ban active
- Dual-SSH-session safety rule (open a second session before running anything that could lock you out)
- CI-independent cron-poll deploy fallback (`infrastructure/deploy-poll.sh`) with flock-guarded idempotent runner
- Every deploy topology declares a rollback path

Derived from scanner-project.com `docker-compose.prod.yml:15-23`, `infrastructure/kale-kapisi.sh`, `infrastructure/deploy-poll.sh`.

### `admin-cms-hardening` (SP-07)
Focus areas:
- Single auth helper reused at every admin entry point (middleware + page + lib + API route) — AP-11 prevention
- DB-sourced role check with TTL cache + explicit invalidation on role change (never `user_metadata`)
- CSRF tokens on every mutation endpoint including multipart uploads
- Rate limit extended to admin CRUD (compromised admin account DoS surface)
- Per-mutation audit log row: actor, target, timestamp, diff, reason
- `server-only` guards on service-role clients (AP-13 prevention)
- Upload magic-byte sniffing (reject PDF-shaped .jpg, etc.)
- Origin allowlist on admin endpoints; no wildcard CORS
- Dead admin CRUD detection (AP-14): every admin write has an admin-external reader
- Impersonation (admin-as-user) requires reason field + own audit row

Evidence: oguzhansert.dev 13-specialist consensus + telegram.bot admin panel + community-platform.com admin surface.

### `ai-relay-cost-control` (SP-08)
Focus areas:
- Input length cap before forwarding to model
- Output token cap always set explicitly (no unbounded `maxOutputTokens`)
- Per-user + per-session rate limit on AI endpoints
- Streaming-first: SSE or ReadableStream; never full-response buffering server-side
- Injection resistance: user input quoted/escaped, never templated
- Cost observability: token count + model + user_id logged to metrics channel
- Prompt logging to privacy-scoped table with TTL
- Cache (prompt, context) pairs for deterministic queries
- AI provider allowlist enforced (per `docs/governance/ai-provider-allowlist.md`)
- Graceful degradation on provider outage: queue + retry or visible fallback

Evidence: oguzhansert.dev + growth-platform.com + recipe-platform.xyz (Gemini / OpenAI / Google GenAI relays).

### `telegram-bot` (SP-09)
Focus areas:
- aiogram 3.x (or python-telegram-bot, or Telegraf for Node) FSM for multi-step flows
- `StatesGroup` + `State()` per domain (AddCategory, AddProduct, OnboardUser); each state waits for user message
- `MemoryStorage()` vs `RedisStorage()` decision: ephemeral state is OK in memory IF conversation is truly discardable-on-restart; durable state (identity, preferences, payment status) MUST go to DB
- Callback-query-driven navigation: `@router.callback_query(F.data == "menu:catalog")` with stateless callback data; never store session state in URL
- Long-polling vs webhook: webhook for production (lower latency, lower poll cost); long-polling for dev
- i18n per user: language preference in DB, translation function loads per-message (or cache with TTL)
- Payment providers: Telegram Stars native, TON Connect, Stripe (via web-app), crypto (via invoice)
- Admin commands namespaced under `/admin`, role gated, audit logged
- Never trust `message.from_user.id` alone for authorization — always recheck from DB each sensitive action

Evidence: telegram.bot (aiogram 3.15 + Supabase + TON + multi-language catalog).

### `member-gated-community-platform` (SP-10)
Focus areas:
- Member-gated routes: public (marketing), member (authenticated), admin (role-gated)
- Event model: event → RSVP (yes/no/maybe) → attendance check-in → post-event artifacts (gallery, summary)
- Calendar + map discovery surface (see `docs/runtime/interactive-map-privacy.md`)
- Gallery upload with member attribution, moderation queue for first-time uploaders
- Notification subscriptions: per-member preferences per notification-type (events, announcements, mentions)
- Club-branded email templates (Resend / SES / Postmark) with member unsubscribe respected
- Member role hierarchy: admin / moderator / member / guest; role changes audit-logged
- RLS policies enforced at DB level (not application-level-only)
- Single-tenant by default (one club, not platform-of-clubs); if multi-tenant, activate `saas` pack too

Evidence: community-platform.com (event + blog + gallery + notifications + admin for single club).

### `multi-app-nextjs-expo-monorepo` (SP-11)
Focus areas:
- Monorepo layout: `apps/admin`, `apps/web`, `apps/master`, `apps/mobile`, `apps/landing` (Expo for mobile, Next.js for web)
- Workspace manager: pnpm workspaces OR Turborepo OR Nx
- Shared packages: `packages/ui` (design system), `packages/schemas` (Zod + types), `packages/lib` (utilities)
- Per-app independence: each app has its own `tsconfig.json`, `next.config.ts`, `package.json` scripts
- Single lockfile; dependabot config aware of workspace boundaries
- Deploy independence: each app builds + ships on its own release cycle; no "deploy everything" lockstep
- Shared auth session across apps (same Supabase / auth-provider instance; same cookies on shared apex domain)
- Apps communicate via shared DB schema or event bus — never direct inter-app HTTP calls

Evidence: trend-platform.com (5-app workspace with admin + landing + master + mobile + web).

## Activation rules

A sector pack loads only when **ALL** of these are true:

1. The user's request, project content, or router decision clearly implicates the sector
2. The router assigns the pack to `required_sector_packs`
3. The context budget permits the additional load (see `docs/runtime/context-budget.md`)

If the pack's domain is only loosely relevant, do **not** load it. Use the core kernel's general rules.

Examples:
- "Help me redesign this education app" → load `education`
- "Build a subscription SaaS onboarding" → load `saas`
- "This is a marketplace with sellers and buyers" → load `marketplace`
- "General code review of a utility library" → load NONE (core kernel is enough)

## Multi-pack activation

A project can activate multiple packs when it genuinely spans sectors. Examples:

- An education SaaS → `education` + `saas`
- A fintech marketplace → `fintech` + `marketplace`
- A B2B ecommerce → `ecommerce` + `enterprise-b2b`

When multiple packs apply, the rules do NOT conflict by default — they stack. If two packs actually contradict (e.g., one says "minimize onboarding friction", another says "require KYC"), the router must record the conflict and pick the precedence based on the rule collision matrix.

## Hard rules

- **Never load all packs at once.** The router picks.
- **Never treat a pack as a complete prompt.** Packs enrich the core; they do not replace it.
- **Never activate a pack on weak signal.** If the user says "build something for schools", that might be education — but confirm the actual product first.
- **Never hardcode sector assumptions into the core kernel.** If a rule belongs only to fintech, it belongs in the fintech pack.
- **Never let packs duplicate each other.** If two packs have the same rule, promote it to the core kernel.

## Integration

- `docs/runtime/router.md` — router picks which packs to activate
- `docs/runtime/context-budget.md` — packs are Layer 7 (sector packs)
- `docs/runtime/output-profiles.md` — some profiles imply specific packs (LOCALIZATION_REPAIR_PROFILE + `education` pack = study-focused localization review)
