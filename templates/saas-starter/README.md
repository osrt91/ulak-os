# Ulak OS SaaS Starter Template

This directory contains the reference files that `/ulak-scaffold` (command) + `saas-scaffolder` (skill) use to materialize a greenfield full-stack SaaS project.

## What ships in the generated project

After running `/ulak-scaffold` with your inputs, the target directory contains:

- **Next.js 16 + TypeScript 5 strict** frontend with App Router and Server Components
- **Supabase** auth + DB + storage + realtime (self-hosted or cloud)
- **Payment** (Stripe / Iyzico / both) with transactional FSM pattern — no AP-08 / AP-12 / AP-18
- **Auth**: single `lib/auth/index.ts` helper + DB-sourced role (no `user_metadata` for authz)
- **Product-surface-split** routes: `(public) / (auth) / (customer) / (admin) / (partner)?`
- **RLS policies**: tenant-id isolation templates with cross-tenant verification protocol
- **i18n**: SSOT locale config + rule pack `localization-ssot` baseline (tr + en default)
- **Docker-compose**: base + dev override + prod override (127.0.0.1 binds + security_opt + cap_drop)
- **Traefik edge**: shared network labels for multi-project VPS
- **CI workflows**: validate-imports + validate-schemas + gitleaks + dependabot + eval-smoke (warn-only initially)
- **Pre-push parity**: `scripts/preflight.sh` mirrors CI 1-for-1
- **Deploy**: webhook-triggered + post-deploy health probe + cron-poll fallback (AP-12 prevention)
- **Tests**: vitest unit + playwright E2E stubs (at least one passing test each)
- **`.gitignore`**: Ulak's full discipline — `.env.local`, `.claude/settings.local.json`, `.claude/scheduled_tasks.lock`, `.claude/worktrees/`, `reports/current/*`
- **`.env.example`**: all env var names the activated packs need; placeholders only
- **`.claude/`**: settings.json + settings.local.example.json + CLAUDE.md importing Ulak OS core contract
- **`docs/governance/pattern-import-ledger.yaml`**: seeded empty for cross-project import tracking
- **`infrastructure/kale-kapisi.sh`**: VPS hardening baseline (SSH port, key-only, UFW, fail2ban)

## Template files in this directory

The scaffolder reads these as starting points and substitutes `{{product_name}}`, `{{product_domain}}`, `{{locale_primary}}`, etc.

- `CLAUDE.md.template` — target project's CLAUDE.md (imports Ulak OS core contract)
- `.env.example.template` — all env vars with placeholders
- `.gitignore.template` — full Ulak discipline
- `package.json.template` — Next 16 + pnpm
- `tsconfig.json.template` — strict
- `next.config.ts.template`
- `tailwind.config.ts.template` — v4
- `middleware.ts.template` — SSR session + auth rehydration
- `lib/auth/index.ts.template` — single auth helper
- `lib/supabase/client.ts.template` + `server.ts.template` + `admin.ts.template` (with server-only)
- `app/layout.tsx.template`
- `app/(public)/page.tsx.template` — landing
- `app/(auth)/login/page.tsx.template`
- `supabase/migrations/00001_initial_schema.sql.template`
- `supabase/migrations/00002_rls_policies.sql.template`
- `infrastructure/docker-compose.yml.template` + `.prod.yml.template`
- `infrastructure/deploy.sh.template` — health-probe-gated
- `infrastructure/kale-kapisi.sh.template` — VPS baseline
- `.github/workflows/ci-validation.yml.template`
- `.github/dependabot.yml.template`
- `.gitleaks.toml.template`
- `scripts/preflight.sh.template`
- `scripts/install-hooks.sh.template`
- `tests/unit/lib.test.ts.template` — at least one passing test
- `tests/e2e/landing.spec.ts.template` — smoke E2E
- `.claude/settings.json.template`
- `.claude/settings.local.example.json.template`

## Variables available in templates

Templates use `{{var}}` substitution. Available:

| Variable | Source | Example |
|---|---|---|
| `{{product_name}}` | user input, kebab-case | `wording-manager` |
| `{{product_name_pascal}}` | derived | `WordingManager` |
| `{{product_domain}}` | user input | `content-ops` |
| `{{locale_primary}}` | user input | `tr` |
| `{{locales_json_array}}` | derived from locales_supported | `["tr","en"]` |
| `{{payment_provider}}` | user input | `iyzico` |
| `{{has_reseller_tier}}` | user input (bool) | `false` |
| `{{hosting}}` | user input | `self-managed-vps` |
| `{{year}}` | current year | `2026` |
| `{{ulak_os_version}}` | Ulak OS package.json version | `2.2.2` |
| `{{product_color_primary}}` | derived from domain | `#0066FF` |
| `{{product_color_accent}}` | derived from domain | `#FF6B35` |

## Usage

Templates are consumed by `.claude/skills/saas-scaffolder/SKILL.md`. Do NOT invoke these files directly — run `/ulak-scaffold` command instead, which orchestrates substitution + directory creation + git init.

## Extending

To add a new template:

1. Write the file under `templates/saas-starter/<path>.template` with `{{vars}}` substituted
2. Update `.claude/skills/saas-scaffolder/SKILL.md` target structure section if the file is in a new directory
3. Test by running `/ulak-scaffold` with a throwaway `product_name`
4. Verify the scaffolded output contains the new file with substitutions applied

## Canonical footer

Authoritative as of Ulak OS **v2.2.2**. This directory is the v1.0 showcase promise implementation: "someone with Ulak OS can produce a full-stack SaaS from commit 1".
