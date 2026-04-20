# Changelog

## [2.2.1] — 2026-04-20 — Deep-infrastructure absorption (post-v2.2 second scan)

### Context

After v2.2.0 shipped, a user-directed second-pass deep-infrastructure scan ran across plastics-supplier.com, growth-platform.com, trend-platform.com, erbilpetshop.com, oguzhansert.dev, telegram.bot, recipe-platform.xyz. Three parallel Explore agents, with explicit "no real credentials in output" discipline, surfaced 10 infrastructure patterns that v2.2.0 did NOT cover — most notably the database-backup gap, monorepo root-env leak, static HMAC deploy webhook, cross-tenant RLS verification absence, and baseline observability gap across the entire portfolio.

### Security fix (backported to tag HEAD)

- **`.gitleaks.toml` scrubbed** — v2.1.4 shipped with real credential VALUES inline in the allowlist (full Resend key + partial Cloudflare token + real VPS IP). Previous commit `d1d05d6` removed them from HEAD. v2.1.4 tag history still has them. **Operator must rotate the Resend API key** — it was in public GitHub for ~2 hours between v2.1.4 push and v2.2.0 security fix.

### New anti-patterns (3, AP-17..AP-19)

- **AP-17 No database backup / disaster recovery plan** — Docker volumes alone are not a backup; no off-host dump, no retention, no tested restore. Cross-project finding in kismet + growth-platform.
- **AP-18 Static HMAC over empty body in deploy webhook** — `openssl dgst -sha256 -hmac $SECRET` over `""`/`"{}"` produces constant signature; infinite replay. Cross-project finding in trend-platform + oguzhansert.
- **AP-19 Root `.env.local` in monorepo** — Turbo/Next.js/Vite inheritance means root `.env.local` compromise leaks across every app. Finding from trend-platform.

### New sector packs (2, SP-12..SP-13)

- **SP-12 `self-hosted-supabase-orchestration`** — 9-service compose (postgres + gotrue + postgrest + realtime + storage + postgres-meta + kong + studio + reverse-proxy), dependency-gated startup, cross-tenant RLS verification required, backup discipline required. Evidence: kismet + dipten + telegram.bot.
- **SP-13 `multi-project-traefik-edge`** — Single Traefik fronting N project compose files, shared `edge` network, Let's Encrypt automation, 127.0.0.1 app binding, TLS-terminated-at-edge, cross-project blast radius control. Evidence: 4+ projects on single VPS.

### New runtime rules (2)

- **`docs/runtime/cross-tenant-rls-verification.md`** — 7-step protocol for verifying Row-Level Security actually isolates tenants sharing a Postgres instance. Includes anon probe, authenticated-cross-tenant probe, service-role escape test, write-probe, automated runner spec. Closes a gap shared by trend-platform + erbilpetshop + kismet + dipten.
- **`docs/runtime/transactional-fsm-payment.md`** — Finite state machine for multi-rail payment (Stripe + Iyzico + Telegram Stars + crypto) with explicit timeout + rollback at every transition, `external_id` idempotency, append-only transition audit log. Evidence: telegram.bot TON handler (reserve → connect → send → confirm + timeout rollback).

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
- **game-platform.com audit finding**: `eni_terminal.py` contains prompt-injection payload (identified by Explore agent 3 during v2.2.1 scan). No patterns extracted from game-platform per operator direction. Separate investigation recommended if source is unknown.

## [2.2.0] — 2026-04-20 — Cross-project pattern absorption (Eksen A)

### Context

v2.1.3 absorbed 39 patterns from scanner-project.com. This release does a second absorption pass across 10+ other projects in the user's portfolio (growth-platform.com, erbilpetshop.com, game-platform.com, plastics-supplier.com, maliyet.app, oguzhansert.dev, oshiaz.com, recipe-platform.xyz, telegram.bot, trend-platform.com, community-platform.com). 3 parallel Explore agents surfaced 18 cross-project-reusable patterns; this release lands them.

Scope is **Eksen A only** of the v2.2 plan. Eksen B (Wave 5 polish, 18 items) and Eksen C (ulak-design-intelligence-mcp, mode-loading conditional loader, eval warn→blocking) are deferred to subsequent patch releases.

### New sector packs (5)

- **SP-07 `admin-cms-hardening`** — Single auth helper reused at every admin entry point (AP-11 prevention); DB-sourced role with TTL cache (not `user_metadata`); CSRF on all mutations including multipart; rate limit on CRUD; per-mutation audit log; `server-only` guards on service-role clients (AP-13 prevention); upload magic-byte sniffing; Origin allowlist; dead-CRUD detection (AP-14). Evidence: oguzhansert.dev 13-specialist consensus + telegram.bot + community-platform.com.

- **SP-08 `ai-relay-cost-control`** — Input length cap, explicit `maxOutputTokens`, per-user + per-session rate limit, streaming-first (SSE/ReadableStream), injection-resistant prompt construction, cost observability (token count + model + user_id to metrics), prompt-log privacy-scoped with TTL, (prompt, context) caching for deterministic queries, AI provider allowlist enforcement, graceful degradation on provider outage. Evidence: oguzhansert.dev + growth-platform.com + recipe-platform.xyz.

- **SP-09 `telegram-bot`** — aiogram FSM with StatesGroup per domain; MemoryStorage vs RedisStorage decision (ephemeral OK if truly discardable, durable must DB); callback-query-driven navigation with stateless callback data; webhook for prod / long-polling for dev; i18n per-user-language in DB + `t()` per-message; Telegram Stars / TON Connect / Stripe / crypto payments; admin commands namespaced; never trust `message.from_user.id` alone for authz. Evidence: telegram.bot (aiogram 3.15 + Supabase + TON + multi-language catalog).

- **SP-10 `member-gated-community-platform`** — Member-gated routes (public / member / admin); event model (event → RSVP → attendance → post-event artifacts); calendar + map discovery (see `docs/runtime/interactive-map-privacy.md`); gallery upload with moderation queue; notification subscriptions per member per type; club-branded email (Resend/SES/Postmark) with respected unsubscribe; role hierarchy audit-logged; RLS enforced at DB level; single-tenant by default. Evidence: community-platform.com.

- **SP-11 `multi-app-nextjs-expo-monorepo`** — apps/admin, apps/web, apps/master, apps/mobile, apps/landing layout; pnpm/Turborepo/Nx workspace; shared packages for ui/schemas/lib; per-app independent deploy; shared auth session across apps via shared apex domain; apps communicate via shared DB schema or event bus (never inter-app HTTP). Evidence: trend-platform.com (5-app workspace).

### New rule packs (4) — `docs/runtime/rule-packs/`

- **`turkish-locale.md`** — `.toLocaleLowerCase('tr')` always; normalize for search separately from display; JSON `ensure_ascii:false`; HTML `lang="tr"`; DB collation `tr_TR.UTF-8`; `Intl.*` for dates/numbers. Activated by Turkish product language or operator locale.

- **`localization-ssot.md`** — SSOT locale file (code + display + RTL + fallback); CI-gated missing-key enforcement; RTL handling with CSS logical properties; JSONB translation columns; machine-translation tagging; email/push/legal are locale-gated. Activated at ≥2 locales.

- **`llm-streaming-context-aware.md`** — Context injection at request (route/session state); token cap server-side; input length cap; SSE/ReadableStream (never buffer); cost observability; rate limit per user AND per session; injection-resistant prompt construction; prompt-log TTL'd; (prompt, context) caching. Activated by LLM SDK + streaming API detection.

- **`react-native-expo.md`** — Expo SDK ≥55, React Native ≥0.83; EAS profiles; shared auth with web; deep links + AASA + asset links; `expo-secure-store` for tokens; `expo-image` not RN Image; `expo-file-system` paths; OTA updates with channel per EAS profile; privacy manifests (iOS 17+). Activated by `app.json` + `eas.json` presence.

### New runtime rules (2)

- **`docs/runtime/webhook-ci-deploy-pattern.md`** — GitHub Actions → deploy webhook discipline: 202 async response with `X-Deploy-Id`; flock-guarded idempotent deploy script; post-deploy `/health` smoke check; CI polls `/deploy-status/<id>` until complete or timeout; CI fails on `failed`/`rolled-back`; 90-day log retention. Evidence: growth-platform.com `.github/workflows/deploy.yml` + scanner-project/community-platform deploys.

- **`docs/runtime/interactive-map-privacy.md`** — No unsolicited `navigator.geolocation` on page load (explicit consent button only); marker clustering at ≥20 points; city-level zoom default + min-zoom to prevent world-zoom; tile provider declared in privacy policy; coordinates stored as PostGIS `geography`; event coordinates deleted N days after event; keyboard-navigable + non-map fallback for screen readers. Evidence: community-platform.com Leaflet event map.

### New anti-patterns (7, AP-10..AP-16) — `docs/runtime/anti-patterns.md`

- **AP-10 Multi-file schema drift** — same entity in SQL + ORM + Zod + TS type with divergent fields (oguzhansert.dev DIR-003)
- **AP-11 Multi-layer auth bypass** — middleware + page + lib + route all independently flawed; compromised cookie walks through (oguzhansert.dev DIR-001)
- **AP-12 Fake rollback deploy** — no pg_dump, no health check, exit code swallowed, CI green on broken state (oguzhansert.dev DIR-006)
- **AP-13 `server-only` installed but never imported** — latent service-role leak (oguzhansert.dev)
- **AP-14 Dead admin CRUD** — admin writes to tables nothing reads; silent contract lie to admin users (oguzhansert.dev DIR-008)
- **AP-15 Drag-drop builder without concurrent-edit conflict resolution** — last-write-wins silent loss (trend-platform.com homepage_sections)
- **AP-16 `.env.local` committed to git** — live evidence from community-platform.com 2026-04-20; working tree + history both exposure surfaces

AP-03 "non-blocking CI gate" updated with **Resolved in Ulak OS v2.1.4** note — Ulak OS's own CI no longer ships the anti-pattern it teaches consumers to avoid.

### Extensions

- **`docs/runtime/rule-packs/api-security.md`** — transactional messaging section: multi-SMS provider abstraction with WhatsApp fallback, email-header spoofing prevention (SPF + DKIM + DMARC), unsubscribe mandate, bounce handling, per-recipient rate limit.

- **`docs/governance/pattern-import-ledger.md`** — **IL-001 entry live**: Trend-Platform → scanner-project.com CMS + blog + site-settings + integration-definitions imports. v2.1.3 R4 residual-risk **closed**: T3 memory claim upgraded to T1 via Explore agent verification on 2026-04-20.

- **`docs/runtime/active-variable-contract.md`** — new fields: `OUTPUT_LANGUAGE` (FIND-LOC-01), `RULE_PACKS_LOADED`, `RULE_PACKS_PROJECT_OVERRIDES`, `MCP_AUTHORIZED_TOOLS` (now director agent v2.1.3 AG-EXT-02 citations are real).

### Pack counts delta (v2.1.4 → v2.2.0)

- Sector packs: 16 → 21
- Rule packs: 4 → 8
- Runtime rule files: +2 (webhook-ci-deploy, interactive-map-privacy)
- Anti-patterns: 69 → 76
- Active-variable-contract fields: +4

### Residual risk state

- **R4 (Trend-Platform pattern-import T3 claim)** — **CLOSED** (T1 verified, IL-001 entry live)
- **R1, R3** (CLI src/ + tests/ deep-scanned) — still open, needs v2.3+
- **R6** (mode-loading deferred) — moved to v2.3 per deferred plan

### Deferred to v2.2.1 or later

- **Eksen B (Wave 5 polish, 18 items)**: 18 thin agent expansion, rule-collision-matrix worked examples, persona-dispatch refinements, guardrail hook, output-profiles locale field, PAT rotation runbook, README filler for empty dirs, canonical-as-of-version footers. None are release blockers.
- **Eksen C (W6 deferrals)**: ulak-design-intelligence-mcp scaffolding (MCP SDK integration), mode-loading conditional loader (major runtime mechanism change), eval harness warn→blocking promotion (pending false-positive measurement).

### Out-of-band (not in this release)

- **community-platform.com .env.local key rotation** — flagged in v2.2.0 planning phase as URGENT. Live Supabase service-role key + Cloudflare API token + Resend key currently in working tree. Operator action required separately from Ulak OS repo: rotate all keys, verify gitignore, optionally purge history.

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

## [2.1.3] — 2026-04-18 — scanner-project-pattern absorption release

### Context

This release integrates 39 patterns extracted from scanner-project.com (a production security/compliance scanner with multi-tenant Supabase + Iyzico payments + reseller surface) into Ulak OS runtime and governance docs. A self-audit via `/director komple` produced 85 findings and resolved 6 open questions. Waves 1–4 of the execution roadmap landed in a single session on 2026-04-18.

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
- **`.claude/agents/design-system-architect.md`** — Master + per-page override output contract (adopted from scanner-project ui-ux-pro-max pattern)
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
- **R4** Pattern-import ledger Trend-Platform claims T3-memory; verify in v2.2
- **R6** Mode-loading mechanism deferred to v2.2
- **W4.18** Log-rotation hook, dependabot, gitleaks CI job, eval runner — Wave 5/6 items carried forward

### Audit trail

- `reports/current/scanner-project-pattern-extraction.md` — Phase A extraction from scanner-project.com (232 lines)
- `reports/current/{runtime-manifest, assumptions, intake, inventory, evidence-register, deep-scan-report, did-you-know, analysis-findings, target-state, execution-roadmap, validation-plan, pack-gap-register, manager-verdict, research-notes}.md` — Phase 0–5 director self-audit artefacts (3,392 lines)

## [Unreleased] — v2.1.2 docs prep continued — FP-01 artefact write authorization fix

### Fix for FP-01 — Subagent Write tool blocked mid-phase

The oguzhansert.dev Sprint 0+1 session (2026-04-11) identified FP-01 as the top priority harness bug: 8 of 13 Phase 2 specialists and 1 of 9 Phase 4 artefacts could not write their `.md` deliverables to disk. They returned content inline and the orchestrator had to re-persist them. The root cause is **not a hook, skill, or settings rule** — it is the default Claude Code system prompt rule against creating planning/decision/analysis documents. The fix must be at the **prompt level**, not the tool level.

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

### Patterns from the scanner-project.com session (2026-04-11)

A second session report came in from scanner-project.com — a security/compliance scanner with 78 HTTP routes, 32 Docker services, 198 pytest + 57 vitest, 4-persona audit producing 92 findings including 4 KATASTROFİK security blockers (SEC-B1 self-escalation to admin, SEC-B2 unauthenticated payment callback, SEC-B3 iyzico webhook signature bypass, SEC-B4 unauth `/config/tools`). Two new patterns were observed and absorbed:

- **`docs/runtime/handoff-plan-contract.md`** — new artefact type. `ulak-handoff-plan.md` is a director-produced file designed as the explicit entry point for a FUTURE session. Different from manager-verdict: manager-verdict closes the current session, handoff-plan opens the next. Conditional-mandatory when verdict is blocked/conditional and more work remains. 13 required sections including exec summary, context files to read, blockers with deadlines, workstream breakdown (business-layer grouping), phase skip recommendations, effort estimate, exact resume command.

- **`docs/runtime/persona-dispatch-pattern.md`** — alternative to discipline-based specialist dispatch. Audits the project as each user role (Customer, Admin, Bayi/Reseller, Security/Red-team, Support, Developer, Compliance) would experience it. Comparison table of specialist vs persona dispatch. When to use each. Dispatch-and-merge protocol with persona overlap as T-tier consensus boost. Output contract per persona (`findings/<persona>-persona.md`). Anti-patterns. The two dispatch modes can coexist — `dispatch=both` in the director command runs both.

### Director command argument surface

- **`.claude/commands/director.md`** — new "Arguments" section documenting:
  - Positional: `komple`, `brownfield audit`, etc.
  - Keyword: `mode=<CREATE|REPAIR|...>`, `entry=<file>`, `skip_phase_1=true`, `skip_phase_2=<comma-list>`, `parallel_dispatch=<N>`, `dispatch=<specialist|persona|both>`, `validation_depth=<light|standard|deep>`, `profile=<AUDIT_PROFILE|...>`
  - Resume form example: `/director komple mode=RESCUE entry=reports/current/ulak-handoff-plan.md skip_phase_1=true parallel_dispatch=9`

### Core contract update (scanner-project patterns)

- **`prompts/core/ulak-os-core-contract-2.0.0.md`** — two new @imports for the handoff-plan and persona-dispatch contracts in the Runtime rules layer.

### Persona agent files (7 new agents, c21204b)

Makes `docs/runtime/persona-dispatch-pattern.md` runnable. Each persona follows the specialist agent shape:

- `.claude/agents/customer-persona.md`, `admin-persona.md`, `bayi-persona.md`, `security-redteam.md`, `support-persona.md`, `developer-persona.md`, `compliance-persona.md`
- Office roster (`docs/runtime/office-roster.md`) updated with a "Personas" section listing all 7.

### Schema extensions (a0f0cec — UOI-03 + UOI-07 + time-sensitivity)

- **`docs/runtime/anti-patterns.md`** — new "Destructive action without live-probe (gate pattern)" section. Forbidden destructive actions list, pre_check field requirement on every destructive roadmap item. References R-119 rm cancellation from Sprint 1 Wave 3. This is UOI-07.
- **`docs/governance/evidence-trust-scoring.md`** — new "Tier promotion mechanism" section. T-tier promotion and regression rules, consensus promotion via dual-path / multi-specialist overlap. Hard rule: tier promotion without new evidence is fraud. Live probe is the only path to T0. This is UOI-03.
- **`docs/governance/finding-schema.md`** — schema extended with `time_sensitivity` optional block (deadline + reason + deadline_source), `source_personas`, `source_specialists`, explicit T0 in `evidence_trust`. New "Time sensitivity — a third axis" section: orthogonal to severity and priority. Escalation rule: High+ severity with <24h deadline surfaces at top of manager-verdict next-action. Reference: scanner-project SEC-B1/SEC-B2.

### What's still NOT in this patch

- **Release tag** — still `[Unreleased]`.
- **PG-01 parallel-dispatch-planner skill** — deferred.
- **PG-04 migration-dry-runner skill** — deferred.
- **Director command argument parser** — args documented but not parsed.
- **Workstream extension to waves-pattern.md** — business-layer vs execution-layer grouping should be documented.
- **Docs drift detection in memory-hygiene.md** — pattern from scanner-project "CLAUDE.md says 17 plugins, reality is 40".
- **v1.x stale reference cleanup** — still ~10 stale v1.0.0/v1.1+ references in `docs/skills-integration/` and `docs/ecosystem/`.

## [Unreleased — earlier] — v2.1.2 docs prep (v2.2 runtime contract drafts)

### Runtime contract additions from the oguzhansert.dev Sprint 0+1 session (2026-04-11)

The 7-file session report under `reports/sessions/2026-04-11-oguzhansert-dev-sprint-0-1/` identified 10 friction points and 15 pack-gap proposals from a real 1h 31m + sprint execution run. This patch addresses the contract-level findings (UOI-01, UOI-02, UOI-04, UOI-11) without shipping the harness hook (PG-03 still pending — needs shell/JS implementation, deferred).

#### New runtime contracts

- **`docs/runtime/waves-pattern.md`** — formalizes the "parallel within a Wave, serial between Waves" execution pattern the session improvised. Covers dependency grouping, pre-dispatch conflict map, validation gate between Waves, sub-waves for partial parallelism, reference example from oguzhansert.dev Sprint 1 (9+2+1+VPS agents, zero file conflicts), anti-patterns.

- **`docs/runtime/live-probe-contract.md`** — formalizes Phase 4.5 as conditional-mandatory when `validation-plan.md §6` has ≥1 probe, or any Critical finding depends on T2/T3 claims, or the roadmap contains destructive remote actions. Read-only-by-default rules, timeouts, credential handling, output artefact (`live-probe-results.md`), T-tier promotion rules, new findings layer (NF-* in did-you-know), gate enforcement. References the LP-07 JWT reuse probe and LP-09 /opt/oguzhansert staleness probe from the session as pivot examples.

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
- **`docs/adapters/gemini-cli.md`** — expanded from 22-line stub. Added v2.1 protocol table, command table (8 commands matching .gemini/commands/), schemas list, sequential specialist guidance.

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
- LICENSE: MIT, Copyright (c) 2026 Oğuzhan Sert <info@oguzhansert.dev>

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
