---
name: saas-scaffolder
description: Materialize a full-stack SaaS project skeleton with Ulak OS governance pre-wired (Next.js + TypeScript + Supabase + optional payment + i18n + RLS + CI + tests + Traefik deploy). Generates a shippable starter that embeds 23 sector packs + 8 rule packs + 79 anti-patterns from commit 1. Use when starting a new SaaS product OR when /ulak-scaffold command dispatches.
context: fork
agent: autonomous-program-director
allowed-tools: Read Grep Glob Edit Write Bash
---

# SaaS Scaffolder — Greenfield Full-Stack Skeleton Generator

## Goal

Produce a ship-ready full-stack SaaS starter directory where every Ulak OS governance discipline is enforced from day 1. The output must pass `/director komple` with zero critical findings on commit 1.

## When to use

Dispatched from `/ulak-scaffold` command, or directly when greenfield SaaS creation is in scope.

## Inputs (required — refuse to start without these)

```yaml
product_name: "<kebab-case-name>" # required; directory name + package.json name
product_domain: "<domain-slug>" # required; must match a known sector pack activator
stack_frontend: "nextjs" # default nextjs; others require manual template work
stack_backend: "supabase" # default supabase; node-fastapi and hybrid supported
locale_primary: "tr" # default tr for Turkish-first portfolio
locales_supported: ["tr"] # at least one
payment_provider: "none" # none | stripe | iyzico | both
has_reseller_tier: false # activates partner-surface templates
has_admin_surface: true # near-universal
has_mobile: false # activates Expo workspace
hosting: "self-managed-vps" # self-managed-vps | vercel | fly | railway
output_path: "<relative or absolute>" # where to create the directory
```

## Outputs

A fully-populated target directory at `output_path` with the structure below, plus:

- `reports/current/scaffold-log.md` — list of created files + their Ulak source templates
- `reports/current/scaffold-verdict.yaml` — post-scaffold validation gate results

## Target structure (Next.js + Supabase default)

```
<product_name>/
├── CLAUDE.md # imports Ulak OS core contract
├── AGENTS.md # Codex plain-text reading order (optional)
├──.gitignore # Ulak's full discipline block
├──.env.example # placeholders only
├── package.json # pnpm, Next 16, TypeScript 5 strict
├── pnpm-lock.yaml # generated on first install
├── tsconfig.json # strict: true, no any
├── next.config.ts
├── tailwind.config.ts # v4
├── postcss.config.mjs
├── middleware.ts # Supabase SSR session rehydration + auth helper entry
│
├── app/ # Next.js App Router
│ ├── (public)/ # landing, pricing, about, privacy, terms
│ ├── (auth)/ # login, register, reset
│ ├── (customer)/ # authenticated customer surface
│ ├── (admin)/admin/ # role-gated admin surface
│ ├── (partner)/partner/ # [if has_reseller_tier]
│ ├── api/
│ │ ├── public/ # unauthenticated; rate-limited
│ │ ├── customer/ # customer surface
│ │ ├── admin/ # admin surface
│ │ ├── partner/ # [if has_reseller_tier]
│ │ └── webhooks/ # payment / provider callbacks with signature verification
│ └── layout.tsx
│
├── components/ # feature-organized, not kitchen-sink
│ ├── ui/ # design system primitives
│ ├── auth/
│ ├── customer/
│ ├── admin/
│ └── shared/
│
├── lib/
│ ├── supabase/ # client, server, admin (with server-only guard)
│ ├── auth/ # single auth helper; used by every surface
│ ├── rate-limit.ts # Redis-backed (AP-01 avoidance)
│ ├── i18n/ # SSOT locale config per rule pack `localization-ssot`
│ └── logger.ts # structured JSON logs per observability-baseline
│
├── supabase/
│ ├── migrations/
│ │ ├── 00001_initial_schema.sql
│ │ ├── 00002_rls_policies.sql # templates for tenant isolation
│ │ └── 00003_seed_admin.sql
│ └── config.toml # for supabase CLI local dev
│
├── infrastructure/
│ ├── docker-compose.yml # dev-friendly defaults
│ ├── docker-compose.prod.yml # 127.0.0.1 binds + security_opt + cap_drop
│ ├── docker-compose.override.yml.example
│ ├── kale-kapisi.sh # VPS hardening per rule pack
│ ├── deploy.sh # webhook-triggered + health probe
│ ├── deploy-poll.sh # CI-independent fallback (architecture-currency)
│ └── nginx/
│ └── <product_name>.conf # reverse proxy with TLS
│
├── scripts/
│ ├── preflight.sh # pre-push parity (R-04)
│ ├── install-hooks.sh # installs.githooks/pre-push
│ ├── validate-imports.sh # from Ulak OS (symlink or copy)
│ └── seed-local-db.sh # local dev convenience
│
├── tests/
│ ├── unit/
│ │ └── lib.test.ts # at least one passing baseline test
│ ├── integration/
│ └── e2e/
│ └── landing.spec.ts # smoke E2E: / loads
│
├──.github/
│ ├── workflows/
│ │ ├── ci-validation.yml # copy of Ulak's; adjusted for target stack
│ │ ├── deploy.yml # webhook deploy + health probe poll
│ │ └── secret-scan.yml # gitleaks
│ ├── dependabot.yml
│ └── vendor-parity-exemptions.txt
│
├──.gitleaks.toml # config per Ulak's v2.1.4 discipline
├──.gitleaks.baseline # empty initially
│
└──.claude/
 ├── settings.json # safe-default allow + deny; hooks per Ulak
 ├── settings.local.example.json
 └── rules/ # project-local rule-pack overrides (optional)

reports/
 └── current/ # gitignored; populated by first director run
docs/
 ├── architecture/ # initial diagrams
 ├── governance/
 │ └── pattern-import-ledger.yaml # seeded empty
 ├── i18n/
 │ ├── tr.json
 │ └── en.json
 └── runbooks/
 ├── deploy.md
 └── first-hours-on-vps.md
```

## Process (step-by-step)

### 1. Validate inputs

Refuse to proceed if:
- `product_name` is not kebab-case
- `product_name` directory already exists at `output_path`
- `payment_provider` requires configuration not in inputs
- `locales_supported` is empty

### 2. Derive activations

Based on inputs, compute:
- `sector_packs_activated: [saas, <product_domain>, payment-integrated-saas?, reseller-enabled-saas?, multi-tenant-supabase?, vps-nginx-compose-topology?,...]`
- `rule_packs_loaded: [typescript-nextjs, docker-compose, api-security, turkish-locale?, localization-ssot?, react-native-expo?, llm-streaming-context-aware?]`
- `anti_patterns_relevant: [AP-01..AP-19 with auto-filter based on stack]`

### 3. Create directory tree

Use `mkdir -p` for every directory in the target structure. Walk the tree in topo order (parents first).

### 4. Materialize files

For each file:
- Read the corresponding template from `templates/saas-starter/<path>` (if exists)
- Substitute `{{product_name}}`, `{{product_domain}}`, `{{locale_primary}}`, etc.
- Write to the target path

For files without a template, generate from sector pack + rule pack + anti-pattern guidance. The skill is a Claude-dispatched generator; the templates are starting points.

### 5. Seed governance artefacts

- `docs/governance/pattern-import-ledger.yaml` — empty array
- `docs/i18n/tr.json` + `docs/i18n/en.json` — minimal key set (login, logout, dashboard, settings)
- Supabase RLS policies — template for tenant_id-based isolation
- `.env.example` — all env var names required by the activated packs

### 6. Initialize

```bash
cd <output_path>
git init
git add -A
git commit -m "feat: scaffold from Ulak OS v2.2.2 — <product_name>

Stack: Next.js + Supabase + <payment_provider>
Locales: <locales_supported>
Sector packs: <sector_packs_activated>
Rule packs: <rule_packs_loaded>

Generated by Ulak OS /ulak-scaffold."
```

### 7. Post-scaffold verification

Write `reports/current/scaffold-verdict.yaml` with:

```yaml
scaffold_verdict:
 product_name: "<name>"
 files_created: <count>
 validation:
 structure_valid: true
 no_real_secrets_in_tree: <grep check result>
 rls_templates_present: <check>
 ci_workflows_valid: <actionlint result or not-run>
 pattern_import_ledger_seeded: true
 next_steps:
 - "cd <output_path>"
 - "pnpm install"
 - "cp.env.example.env.local && fill values"
 - "pnpm dev"
 - "./scripts/install-hooks.sh"
 optional_followup:
 - "Run /director komple in the new project for v0.1.0 baseline audit"
```

## Rules

- **No real secrets.** If a template has a placeholder like `YOUR_STRIPE_KEY`, leave it — do not attempt to detect the operator's keys and inject them.
- **No silent deletion.** If `output_path` already exists with files, refuse (do not overwrite).
- **Idempotency.** Re-running with the same inputs in an already-scaffolded directory is a no-op (the skill detects and exits).
- **Locale-aware templates.** If `locale_primary: tr`, generated user-facing strings in landing / auth pages are Turkish; English fallback in `en.json`.
- **Product-surface-split discipline.** Customer + admin + (optional) partner routes must live under different prefixes with different auth gates per `docs/governance/product-surface-split.md`.

## Anti-patterns the scaffolder actively prevents

By design, commit 1 of the generated project cannot contain:

- AP-11 Multi-layer auth bypass (single `lib/auth/index.ts` helper; every surface imports it)
- AP-12 Fake rollback deploy (deploy.sh template has mandatory health probe + rollback path)
- AP-13 `server-only` installed but never imported (every server-role file starts with `import 'server-only'`)
- AP-16 `.env.local` committed (gitignore pattern blocks it)
- AP-17 No database backup (scripts/backup-db.sh stub + reminder in runbook)
- AP-18 Static HMAC empty body (deploy webhook template signs full body + timestamp + nonce)
- AP-19 Root.env.local in monorepo (if has_mobile, per-app env files)

## Integration

- `.claude/commands/ulak-scaffold.md` — the command that dispatches this skill
- `docs/runtime/sector-packs.md §greenfield-saas-starter` (SP-14) — the sector pack
- `templates/saas-starter/` — file templates
- `docs/runtime/output-profiles.md` — GREENFIELD_BUILDER_PROFILE + PACK_GENERATION_PROFILE are compatible with this skill
- `.claude/agents/autonomous-program-director.md` — the dispatching agent

## Canonical footer

Authoritative as of Ulak OS **v2.2.2**. This skill is the primary "Ulak OS produces a SaaS" capability and defines the v1.0 showcase promise.
