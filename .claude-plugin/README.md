# Ulak OS — Claude Code Plugin

Packaging metadata for distributing Ulak OS as a Claude Code plugin.

## Install methods

### Method A — Clone (current, most flexible)

```bash
git clone https://github.com/osrt91/ulak-os.git
cd ulak-os
# Open Claude Code in this directory; all commands + skills + agents auto-load
```

### Method B — As a plugin (when Claude Code plugin marketplace supports it)

```bash
claude plugin install osrt91/ulak-os
```

Or by git URL:

```bash
claude plugin install https://github.com/osrt91/ulak-os.git
```

### Method C — As a git submodule in your project

```bash
cd /path/to/your-project
git submodule add https://github.com/osrt91/ulak-os.git .ulak-os
echo "@.ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md" >> CLAUDE.md
```

Then Claude Code in your project directory auto-loads Ulak OS governance.

### Method D — Via `/ulak-scaffold` itself (scaffolded projects get the import automatically)

```bash
# From Ulak OS repo, Claude Code:
/ulak-scaffold product_name=my-saas product_domain=saas

# The scaffolded project's CLAUDE.md imports Ulak OS governance via absolute path.
```

## What the plugin ships

- **9 slash commands** — `/director`, `/ulak-scaffold`, `/final-verdict`, `/intake`, `/frontend-war-room`, `/pack-gap-audit`, `/triage-build`, `/ulak-design-ref`, `/ulak-intake`
- **27 specialist + persona agents** — parallel Phase 2 dispatch
- **9 skills** — saas-scaffolder, fourteen-dimension-audit, god-module-decomposition, multi-agent-orchestration, final-validation, pack-gap-completion, project-intake, research-currency, ulak-design-ref
- **8 rule packs** (always-on guardrails per stack) — typescript-nextjs, python-fastapi, docker-compose, api-security, turkish-locale, localization-ssot, llm-streaming-context-aware, react-native-expo
- **24 sector packs** (domain overlays) — education, saas, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop, multi-tenant-supabase, container-orchestrating-app, payment-integrated-saas, regulated-saas, reseller-enabled-saas, vps-nginx-compose-topology, admin-cms-hardening, ai-relay-cost-control, telegram-bot, member-gated-community-platform, multi-app-nextjs-expo-monorepo, self-hosted-supabase-orchestration, multi-project-traefik-edge, greenfield-saas-starter
- **79 anti-patterns** (gating rules) — including AP-01..AP-19 cross-project patterns + ~60 classical (IDOR, BOLA, N+1, RLS asymmetry, etc.)
- **22 governance docs** + **33 runtime rule files** — always-loaded doctrine
- **15 scaffolder templates** — under `templates/saas-starter/` (middleware, auth helper, RLS, CI, deploy, VPS hardening, preflight, design reference, etc.)
- **59 brand design references** — `VoltAgent/awesome-design-md` curated list via `/ulak-design-ref`

## Verification after install

```bash
cd /path/to/ulak-os
bash scripts/validate-imports.sh      # @-import chain valid + no cycles
bash scripts/validate-schemas.sh      # JSON/TOML schemas valid
bash scripts/validate-vendor-parity.sh # claude / gemini / codex command parity
bash evals/run.sh                     # eval harness (warn-only until v2.3+)
```

All green = pack healthy.

## Uninstall

### If installed via clone

```bash
rm -rf ulak-os
```

### If installed via submodule

```bash
cd /path/to/your-project
git submodule deinit -f .ulak-os
git rm -f .ulak-os
rm -rf .git/modules/.ulak-os
# Remove the @.ulak-os import from CLAUDE.md
```

### If installed via plugin marketplace (future)

```bash
claude plugin uninstall ulak-os
```

## Canonical footer

This directory is the plugin-packaging manifest for Ulak OS. The version declared in `plugin.json` mirrors `package.json`. Update both on release.
