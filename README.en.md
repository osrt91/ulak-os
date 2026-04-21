# Ulak OS

> **Vendor-neutral prompt operating system** — plan, audit, govern, and **scaffold full-stack SaaS** with Claude Code, Codex, or Gemini CLI.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE) [![Version](https://img.shields.io/badge/version-1.0.0--public--GA-blue.svg)](./CHANGELOG.md) [![Vendor](https://img.shields.io/badge/vendor-claude%20%7C%20codex%20%7C%20gemini-orange.svg)](./docs/adapters/)

**English (this file)** · **[Türkçe](./README.md)**

## What is Ulak OS?

A **prompt operating system** that sits on top of AI coding CLIs (Claude Code / Codex / Gemini). Single core, three vendor adapters. Not separately an audit framework, a governance layer, and a SaaS scaffolder — **all three** in one pack.

### It does three things

| | Command | Produces |
|---|---|---|
| **Audit** | `/director komple` | Phase 0→5 director protocol: 27 specialist agents dispatched in parallel, 15-dimension scorecard, 79 anti-pattern sweep, 13 artefacts |
| **Govern** | `@prompts/core/ulak-os-core-contract-2.0.0.md` | Import core contract in your `CLAUDE.md` → 22 governance docs + 24 sector packs + 8 rule packs active every session |
| **Scaffold** | `/ulak-scaffold` | Full-stack SaaS (Next.js + Supabase + payment + i18n + CI + deploy) at commit 1 — 27 template files + 8 anti-patterns gated by construction |

## Quickstart (3 steps, 5 minutes)

### 1. Install

**One-liner installer** (recommended):

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh
```

```powershell
# Windows PowerShell 5.1+
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex
```

**Safer path (SHA256 verification)** — prefer this if you don't trust pipe-to-shell:

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh -o /tmp/ulak-install.sh
curl -fsSL https://github.com/osrt91/ulak-os/releases/latest/download/install.sh.sha256 -o /tmp/ulak-install.sh.sha256
(cd /tmp && sha256sum -c ulak-install.sh.sha256) && sh /tmp/ulak-install.sh
```

Installs to `$HOME/.ulak-os/` and adds the `ulak` command to PATH. No `sudo` required. Pass `--dry-run` / `-DryRun` to preview. Alternatives + checksum methods in [docs/runbooks/install-methods.md](./docs/runbooks/install-methods.md).

**Manual clone** (for vendor-lock-free inspection):

```bash
git clone https://github.com/osrt91/ulak-os.git
cd ulak-os
```

### 2. Verify

```bash
ulak doctor # cross-platform — runs all validators in sequence
```

If you manually cloned, POSIX systems can run the scripts directly:

```bash
bash scripts/validate-imports.sh # @-import chain + cycle detection
bash scripts/validate-schemas.sh # JSON schema conformance
bash scripts/validate-vendor-parity.sh # claude/gemini/codex command parity
```

All green → pack is healthy.

### 3. Two paths

**Path A — Audit an existing project:**

```bash
cd /path/to/your-project
echo "@/absolute/path/to/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md" >> CLAUDE.md
# Open Claude Code:
/director komple
```

The director runs: runtime-manifest → deep inventory → 4-13 specialist parallel dispatch → did-you-know findings → target-state + execution-roadmap + validation-plan + pack-gap-register → manager-verdict.

**Path B — Scaffold a new SaaS:**

```bash
# From the Ulak OS repo, open Claude Code:
/ulak-scaffold product_name=my-saas product_domain=saas locale_primary=en payment_provider=stripe
```

Generates a full Next.js + Supabase + Stripe + i18n + CI + tests + deploy project in a sibling directory (`../my-saas/`). At commit 1:
- Single auth helper (AP-11 prevention)
- `server-only` guards (AP-13)
- DB-sourced role, never `user_metadata` (AP-06)
- RLS policy templates
- Webhook deploy + health probe (AP-12 + AP-18 prevention)
- Full `.gitignore` discipline (AP-16)
- Gitleaks baseline + dependabot
- VPS hardening script (SSH port + key-only + UFW + fail2ban)

Details: [Showcase walkthroughs](./docs/showcase/) — 4 abstract walkthroughs (audit, scaffold, persona dispatch, cross-project pattern absorption) + video script.

## Architecture

```
CLAUDE.md (3-line entry)
 └── @prompts/core/ulak-os-core-contract-2.0.0.md
 ├── @docs/runtime/*.md ← 33 runtime rules + 8 rule packs
 ├── @docs/governance/*.md ← 22 governance docs
 └── @docs/adapters/*.md ← claude-code / codex-cli / gemini-cli.claude/
 ├── agents/*.md ← 27 specialist + persona agents
 ├── commands/*.md ← 9 slash commands
 ├── skills/*/SKILL.md ← 9 skills
 └── settings.json ← scoped permissions + hooks

templates/saas-starter/ ← 27 scaffolder templates
evals/ ← golden prompts + assertion library
scripts/ ← validators + install + fetch-design-references
```

Detailed architecture diagrams (mermaid, GitHub-native render): [docs/architecture/](./docs/architecture/) — overview · director-protocol · scaffolder-flow · vendor-adapters.

## What's included (v1.0.0 public GA)

- **24 sector packs** — education, saas, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop, multi-tenant-supabase, container-orchestrating-app, payment-integrated-saas, regulated-saas, reseller-enabled-saas, vps-nginx-compose-topology, admin-cms-hardening, ai-relay-cost-control, telegram-bot, member-gated-community-platform, multi-app-nextjs-expo-monorepo, self-hosted-supabase-orchestration, multi-project-traefik-edge, greenfield-saas-starter
- **8 rule packs** — typescript-nextjs, python-fastapi, docker-compose, api-security, turkish-locale, localization-ssot, llm-streaming-context-aware, react-native-expo
- **~100 anti-pattern bullets** — 19 numbered AP-NN items (AP-01..AP-19) + classics (IDOR, BOLA, N+1, RLS asymmetry, dead code, etc.)
- **22 governance docs** — product-surface-split, rule-pack-governance, secrets-rotation-policy, observability-baseline, pattern-import-ledger, settings-permissions-governance, lock-file-hygiene, ai-provider-allowlist, mcp-governance, memory-hygiene, prompt-supply-chain, artefact-write-authorization, and more
- **33 runtime rules** — router, program-phases (Phase 0→5), artefact-contract, context-budget, output-profiles, active-variable-contract, waves-pattern, live-probe-contract, dual-path-validation, persona-dispatch-pattern, strangler-fig-protocol, multi-agent-merge-sequence, audit-scoring-framework, cross-tenant-rls-verification, transactional-fsm-payment, webhook-ci-deploy-pattern, interactive-map-privacy, toolchain-precheck, architecture-currency, and more
- **27 agents** — 19 specialists + 1 autonomous-program-director + 7 personas (admin, customer, partner, developer, support, compliance, security-redteam)
- **9 commands** — director, final-verdict, frontend-war-room, intake, pack-gap-audit, triage-build, ulak-design-ref, ulak-intake, ulak-scaffold
- **8 skills** — saas-scaffolder, god-module-decomposition, fourteen-dimension-audit, multi-agent-orchestration, final-validation, pack-gap-completion, project-intake, research-currency
- **27 scaffolder templates** — `templates/saas-starter/`: Next.js 16 + TS 5 strict + Tailwind v4 + Supabase SSR + auth helper + RLS + CI + tests + deploy + VPS hardening + 59-brand design reference

## Supported stacks (for `/ulak-scaffold`)

| Layer | Primary | Experimental |
|---|---|---|
| Frontend | Next.js 16 | Remix, SvelteKit (v4.0) |
| Backend | Supabase SSR | FastAPI + Node hybrid (v4.0) |
| Payment | Stripe, Iyzico, both, none | — |
| Mobile | Expo 55+ (optional) | — |
| Hosting | Self-managed VPS + Traefik | Vercel, Fly.io, Railway |
| i18n | en + tr baseline | localization-ssot rule pack for ≥2 locales |

## Vendor adapter matrix

| Vendor | Status | Commands | Reading order |
|---|---|---|---|
| Claude Code | primary | 9 slash commands | `CLAUDE.md` @-imports |
| Codex / Copilot | supported | `AGENTS.md` plain-text | `AGENTS.md` |
| Gemini CLI | supported | 8 `.toml` commands | `docs/adapters/gemini-cli.md` |

## Release history

- **v2.4.0** (2026-04-20) — Public launch prep Phase A: LICENSE (MIT), README bilingual rewrite, CONTRIBUTING, CODE_OF_CONDUCT, issue/PR templates
- **v2.3.0** (2026-04-20) — Plugin packaging + 27 scaffolder templates + 6 ADRs + 3 agent expansion
- **v2.2.3** (2026-04-20) — 10 scaffolder templates core + awesome-design-md integration (59 brand references)
- **v2.2.2** (2026-04-20) — SaaS scaffolder command + skill + sector pack + 5 seed templates
- **v2.2.1** (2026-04-20) — Deep-infra absorption
- **v2.2.0** (2026-04-20) — Cross-project absorption
- **v2.1.4** (2026-04-20) — CI hardening
- **v2.1.3** (2026-04-18) — First cross-project pattern absorption (39 patterns)

Full release notes: [CHANGELOG.md](./CHANGELOG.md) · [docs/release/](./docs/release/)

## Help + further reading

- **Frequently asked:** [docs/FAQ.md](./docs/FAQ.md) — Ulak OS vs superpowers / everything-claude-code / cartographer · Windows/macOS/Linux support · offline use · model support
- **First hour:** [docs/runbooks/first-hour-with-ulak-os.md](./docs/runbooks/first-hour-with-ulak-os.md) — clone → first audit → first scaffold → first commit (60 min)
- **Troubleshooting:** [docs/runbooks/troubleshooting.md](./docs/runbooks/troubleshooting.md) — 16 common errors + diagnosis + fix
- **Upgrade:** [docs/runbooks/upgrading-from-v2.x.md](./docs/runbooks/upgrading-from-v2.x.md) — for existing Ulak OS users
- **Install methods:** [docs/runbooks/install-methods.md](./docs/runbooks/install-methods.md) — 5 paths + pros/cons
- **Architecture:** [docs/architecture/](./docs/architecture/) — 4 mermaid diagrams + prose
- **Showcase:** [docs/showcase/](./docs/showcase/) — 4 walkthroughs + video script
- **Release history:** [CHANGELOG.md](./CHANGELOG.md) · [docs/history/version-lineage.md](./docs/history/version-lineage.md)
- **Governance decisions:** [docs/adr/](./docs/adr/) (6 ADRs)

## Contribution + governance

To propose a new sector pack, rule pack, anti-pattern, or agent: [CONTRIBUTING.md](./CONTRIBUTING.md).

Code of Conduct: [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

**Security issues:** do NOT open a public GitHub issue — email `info@oguzhansert.dev` directly (see CODE_OF_CONDUCT.md §Reporting).

Governance decisions: [docs/adr/](./docs/adr/) (6 ADRs — rule packs, Phase 5 terminal, product surface split, pattern-import ledger, SaaS scaffolder).

## License

[MIT](./LICENSE) — widely used + permissive. Fork it, adapt it, apply it to your own operation. Attribution is sufficient.

## Maintainer

**Oğuzhan Sert** — [`@osrt91`](https://github.com/osrt91) · `info@oguzhansert.dev`
Bug report: [`.github/ISSUE_TEMPLATE/bug_report.md`](./.github/ISSUE_TEMPLATE/bug_report.md) · Security: [`SECURITY.md`](./SECURITY.md).

## Canonical footer

Authoritative as of Ulak OS **v1.0.0 (public GA)**. Build metadata: [`prompts/pack.json`](./prompts/pack.json). Core contract: [`prompts/core/ulak-os-core-contract-2.0.0.md`](./prompts/core/ulak-os-core-contract-2.0.0.md). Release notes: [`docs/release/v1.0.0-release-notes.md`](./docs/release/v1.0.0-release-notes.md).
