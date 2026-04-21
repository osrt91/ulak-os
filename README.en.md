# Ulak OS

> **One line:** Ulak OS is a **prompt operating system** that sits on top of AI coding CLIs (Claude Code / Codex / Gemini); it reads your project, surfaces what is missing, and — if you need it — scaffolds a full-stack SaaS from scratch.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE) [![Version](https://img.shields.io/badge/version-1.0.0--public--GA-blue.svg)](./CHANGELOG.md) [![Vendor](https://img.shields.io/badge/vendor-claude%20%7C%20codex%20%7C%20gemini-orange.svg)](./docs/adapters/)

**English (this file)** · **[Türkçe README](./README.md)**

---

## First screen — 3 commands

```bash
/ulak-hello          # 30-second tour — what is Ulak OS, how do I try it?
/director komple     # audit an existing project end-to-end (Phase 0-5)
/ulak-start          # start a new SaaS (6-question wizard)
```

If this is your first time, start with **`/ulak-hello`**. In 30 seconds you'll see what this is; then pick your path.

---

## 30-second install

**One-liner** (recommended — macOS / Linux):

```bash
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh
```

**Windows PowerShell 5.1+**:

```powershell
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex
```

**Manual clone** (for vendor-lock-free inspection):

```bash
git clone https://github.com/osrt91/ulak-os.git
cd ulak-os
```

**Then what?** Open Claude Code, type `/ulak-hello`, hit `enter`. The rest is a choice menu.

> Checksum-verified install + alternatives: [docs/runbooks/install-methods.md](./docs/runbooks/install-methods.md).
> Verify: `ulak doctor` runs all validators in sequence. All green = pack is healthy.

---

## What can I do?

Six concrete scenarios for a new user. Each one starts with a single command; Ulak OS produces the output.

### 1. Start a new SaaS (5-10 min)

```bash
/ulak-start
```

6 short questions: product name, sector, stack, payment, i18n, mobile. Ulak OS dispatches `/ulak-scaffold` with the right parameters; it generates a full Next.js + Supabase + Stripe + i18n + CI + tests + deploy project in a sibling directory (`../my-saas/`). At commit 1: RLS templates, auth helper, webhook deploy, `.gitignore` discipline, gitleaks baseline. No flags to memorise.

### 2. Audit an existing project (45-90 min)

```bash
cd /path/to/your-project
echo "@/absolute/path/to/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md" >> CLAUDE.md
# Open Claude Code:
/director komple
```

The director runs: runtime-manifest → deep inventory (file+line) → 4-13 specialist parallel dispatch → did-you-know findings → target-state + execution-roadmap + validation-plan + pack-gap-register → manager-verdict. Whichever of the 27 agents fit your project activate in parallel.

### 3. Ask in natural language

```bash
/ulak-ask "add turkish locale"
/ulak-ask "check for rls asymmetry"
/ulak-ask "scan pack gaps"
```

No plugin search, no flags to memorise — just say what you want. Ulak OS maps keywords + intent to the right command; asks "did you mean this?" when ambiguous.

### 4. Browse packs + capabilities

```bash
/ulak-packs          # summary table of every capability
/pack-gap-audit      # report what's missing in the current pack
/ulak-mcp-discover   # propose new MCP servers from the public registry
```

### 5. Replay the onboarding tour

```bash
/ulak-hello
```

To see the first screen again. 30-second tour, 4 choices, direct handoff to the matching command.

### 6. Upgrade + verify

```bash
git pull origin main
ulak doctor                          # cross-platform — all validators
bash scripts/validate-imports.sh     # @-import chain + cycle detection
bash scripts/validate-schemas.sh     # JSON schema conformance
bash scripts/validate-vendor-parity.sh  # claude/gemini/codex parity
```

Existing Ulak user? See [docs/runbooks/upgrading-from-v2.x.md](./docs/runbooks/upgrading-from-v2.x.md).

---

## Capability summary (v1.0.0 public GA)

One table, real counts. For details, follow the folder links.

| Surface | Count | Contains | Reference |
|---|---|---|---|
| **Commands** | 15 | `/director`, `/ulak-start`, `/ulak-hello`, `/ulak-scaffold`, `/ulak-ask`, `/final-verdict`, `/intake`, `/frontend-war-room`, `/pack-gap-audit`, `/triage-build`, `/ulak-design-ref`, `/ulak-intake`, `/ulak-audit-deep`, `/ulak-pattern-extract`, `/ulak-mcp-discover` | [`.claude/commands/`](./.claude/commands/) |
| **Skills** | 10 | `saas-scaffolder`, `fourteen-dimension-audit`, `god-module-decomposition`, `multi-agent-orchestration`, `final-validation`, `pack-gap-completion`, `project-intake`, `research-currency`, `awesome-packs-index`, `mcp-governance-auto` | [`.claude/skills/`](./.claude/skills/) |
| **Agents** | 27 | 19 specialists + 1 autonomous-program-director + 7 personas (admin, customer, partner, developer, support, compliance, security-redteam) | [`.claude/agents/`](./.claude/agents/) |
| **Sector packs** | 14 | education, saas, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop, ai-relay-cost-control, member-gated-community, admin-cms-hardening, self-hosted-supabase | [`templates/sectors/`](./templates/sectors/) + [`docs/runtime/sector-packs.md`](./docs/runtime/sector-packs.md) |
| **Rule packs** | 8 | typescript-nextjs, python-fastapi, docker-compose, api-security, turkish-locale, localization-ssot, llm-streaming-context-aware, react-native-expo | [`docs/runtime/rule-packs/`](./docs/runtime/rule-packs/) |
| **Governance docs** | 22 | product-surface-split, rule-pack-governance, secrets-rotation-policy, observability-baseline, pattern-import-ledger, settings-permissions-governance, lock-file-hygiene, ai-provider-allowlist, mcp-governance, memory-hygiene, prompt-supply-chain, artefact-write-authorization, more | [`docs/governance/`](./docs/governance/) |
| **Runtime rules** | 33 | router, program-phases (Phase 0-5), artefact-contract, context-budget, output-profiles, active-variable-contract, waves-pattern, live-probe-contract, dual-path-validation, persona-dispatch-pattern, more | [`docs/runtime/`](./docs/runtime/) |
| **Anti-patterns** | ~100 | 19 numbered AP-NN (AP-01..AP-19) + classics (IDOR, BOLA, N+1, RLS asymmetry, dead code, etc.) | inline — sector + rule packs |
| **Scaffolder templates** | 27 | `templates/saas-starter/` — Next.js 16 + TS 5 strict + Tailwind v4 + Supabase SSR + auth helper + RLS + CI + tests + deploy + VPS hardening + 59-brand design reference | [`templates/saas-starter/`](./templates/saas-starter/) |

---

## Three things it does (short)

| | Command | Produces |
|---|---|---|
| **Audit** | `/director komple` | Phase 0→5 director protocol: 27 specialists in parallel, 15-dimension scorecard, 79 anti-pattern sweep, 13 artefacts |
| **Govern** | `@prompts/core/ulak-os-core-contract-2.0.0.md` | Import the core contract in your `CLAUDE.md` → 22 governance docs + 14 sector packs + 8 rule packs active every session |
| **Scaffold** | `/ulak-scaffold` or `/ulak-start` | Full-stack SaaS (Next.js + Supabase + payment + i18n + CI + deploy) at commit 1 — 27 template files + 8 anti-patterns gated by construction |

---

## Architecture

```
CLAUDE.md (3-line entry)
 └── @prompts/core/ulak-os-core-contract-2.0.0.md
      ├── @docs/runtime/*.md          <- 33 runtime rules + 8 rule packs
      ├── @docs/governance/*.md       <- 22 governance docs
      └── @docs/adapters/*.md         <- claude-code / codex-cli / gemini-cli

.claude/
  ├── agents/*.md                     <- 27 specialists + personas
  ├── commands/*.md                   <- 21 slash commands
  ├── skills/*/SKILL.md               <- 10 skills
  └── settings.json                   <- scoped permissions + hooks

templates/
  ├── saas-starter/                   <- 27 scaffolder templates
  └── sectors/                        <- 14 sector packs

evals/     <- golden prompts + assertion library
scripts/   <- validators + install + fetch-design-references
```

Detailed architecture diagrams (mermaid): [docs/architecture/](./docs/architecture/).

---

## Supported stacks (for `/ulak-scaffold`)

| Layer | Primary | Experimental |
|---|---|---|
| Frontend | Next.js 16 | Remix, SvelteKit (v4.0) |
| Backend | Supabase SSR | FastAPI + Node hybrid (v4.0) |
| Payment | Stripe, Iyzico, both, none | — |
| Mobile | Expo 55+ (optional) | — |
| Hosting | Self-managed VPS + Traefik | Vercel, Fly.io, Railway |
| i18n | en + tr baseline | localization-ssot rule pack for ≥2 locales |

---

## Vendor adapter matrix

| Vendor | Status | Commands | Reading order |
|---|---|---|---|
| Claude Code | primary | 21 slash commands | `CLAUDE.md` @-imports |
| Codex / Copilot | supported | `AGENTS.md` plain-text | `AGENTS.md` |
| Gemini CLI | supported | 8 `.toml` commands | `docs/adapters/gemini-cli.md` |

---

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

---

## Help + further reading

- **30-second tour:** `/ulak-hello` — first screen, 4 choices, direct routing
- **Frequently asked:** [docs/FAQ.md](./docs/FAQ.md) — Ulak OS vs alternatives · platform support · offline · model support
- **First hour:** [docs/runbooks/first-hour-with-ulak-os.md](./docs/runbooks/first-hour-with-ulak-os.md) — clone → first audit → first scaffold → first commit (60 min)
- **Troubleshooting:** [docs/runbooks/troubleshooting.md](./docs/runbooks/troubleshooting.md) — 16 common errors + diagnosis + fix
- **Upgrade:** [docs/runbooks/upgrading-from-v2.x.md](./docs/runbooks/upgrading-from-v2.x.md)
- **Install methods:** [docs/runbooks/install-methods.md](./docs/runbooks/install-methods.md) — 5 paths + pros/cons
- **Architecture:** [docs/architecture/](./docs/architecture/) — 4 mermaid diagrams + prose
- **Showcase:** [docs/showcase/](./docs/showcase/) — 4 walkthroughs + video script
- **Governance decisions:** [docs/adr/](./docs/adr/) (6 ADRs)

> Türkçe README: [README.md](./README.md)

---

## Contribution + security

To propose a new sector pack, rule pack, anti-pattern, or agent: [CONTRIBUTING.md](./CONTRIBUTING.md). Code of Conduct: [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

**Security issues:** do NOT open a public GitHub issue — email `info@oguzhansert.dev` directly (see [SECURITY.md](./SECURITY.md)).

---

## License

[MIT](./LICENSE) — permissive. Fork it, adapt it, apply it to your own operation. Attribution is sufficient.

## Maintainer

**Oğuzhan Sert** — [`@osrt91`](https://github.com/osrt91) · `info@oguzhansert.dev`

---

## Canonical footer

Authoritative as of Ulak OS **v1.0.0 (public GA)**. Build metadata: [`prompts/pack.json`](./prompts/pack.json). Core contract: [`prompts/core/ulak-os-core-contract-2.0.0.md`](./prompts/core/ulak-os-core-contract-2.0.0.md). Release notes: [`docs/release/v1.0.0-release-notes.md`](./docs/release/v1.0.0-release-notes.md).
