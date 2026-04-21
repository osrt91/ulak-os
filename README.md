# Ulak OS

> **Vendor-neutral prompt operating system** — plan, audit, govern, and **scaffold full-stack SaaS** with Claude Code, Codex, or Gemini CLI.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE) [![Version](https://img.shields.io/badge/version-1.0.0--public--GA-blue.svg)](./CHANGELOG.md) [![Vendor](https://img.shields.io/badge/vendor-claude%20%7C%20codex%20%7C%20gemini-orange.svg)](./docs/adapters/)

**[English](./README.en.md)** · **Türkçe (bu dosya)**

## Ulak OS nedir?

AI coding CLI'larının (Claude Code / Codex / Gemini) üstüne oturan bir **prompt işletim sistemi**. Tek bir çekirdek, üç vendor adaptörü. Ayrı ayrı bir audit framework, bir governance katmanı ve bir SaaS scaffolder değil — **üçünü birden** yapan tek bir pack.

### Üç şey yapar

| | Komut | Ne üretir |
|---|---|---|
| **Audit** | `/director komple` | Phase 0→5 director protokolü: 27 specialist agent paralel dispatch, 15-boyut scorecard, 79 anti-pattern tarama, 13 artefakt |
| **Govern** | `@prompts/core/ulak-os-core-contract-2.0.0.md` | Core contract'ı CLAUDE.md'ye import et → 22 governance doc + 24 sector pack + 8 rule pack her session aktif |
| **Scaffold** | `/ulak-scaffold` | Full-stack SaaS (Next.js + Supabase + payment + i18n + CI + deploy) commit 1'de — 27 template dosyası + 8 anti-pattern construction'da gated |

## Quickstart (3 adım, 5 dakika)

### 1. Yükle

**Tek satır installer** (önerilen):

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh
```

```powershell
# Windows PowerShell 5.1+
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex
```

Installer `$HOME/.ulak-os/` altına indirir + PATH'e `ulak` komutu ekler. `sudo` istemez. Dry-run için `--dry-run` / `-DryRun` switch'i var. Alternatifler için [docs/runbooks/install-methods.md](./docs/runbooks/install-methods.md).

**Manuel klon** (vendor lock-in olmadan inceleme için):

```bash
git clone https://github.com/osrt91/ulak-os.git
cd ulak-os
```

### 2. Doğrula

```bash
ulak doctor # cross-platform: tüm validator'ları sırayla çalıştırır
```

Eğer manuel klonladıysanız, POSIX sistemlerde doğrudan script'ler:

```bash
bash scripts/validate-imports.sh # @-import zinciri + cycle detection
bash scripts/validate-schemas.sh # JSON schema conformance
bash scripts/validate-vendor-parity.sh # claude/gemini/codex command parity
```

Hepsi yeşil ise pack sağlıklı.

### 3. İki yol var

**Yol A — Mevcut bir projeyi audit et:**

```bash
cd /path/to/your-project
echo "@/absolute/path/to/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md" >> CLAUDE.md
# Claude Code aç:
/director komple
```

Director çalışır: runtime-manifest → deep inventory → 4-13 specialist paralel dispatch → did-you-know findings → target-state + execution-roadmap + validation-plan + pack-gap-register → manager-verdict.

**Yol B — Yeni bir SaaS oluştur:**

```bash
# Ulak OS repo'da Claude Code aç:
/ulak-scaffold product_name=my-saas product_domain=saas locale_primary=tr payment_provider=stripe
```

Sibling dizinde (`../my-saas/`) tam bir Next.js + Supabase + Stripe + i18n + CI + tests + deploy projesi üretir. Commit 1'de:
- Single auth helper (AP-11 prevention)
- `server-only` guards (AP-13)
- DB-sourced role, never `user_metadata` (AP-06)
- RLS templates
- Webhook deploy + health probe (AP-12 + AP-18 prevention)
- `.gitignore` full discipline (AP-16)
- Gitleaks baseline + dependabot
- VPS hardening script (SSH port + key-only + UFW + fail2ban)

Detaylı örnekler: [Showcase walkthroughs](./docs/showcase/) — 4 abstract senaryo (audit, scaffold, persona dispatch, cross-project pattern absorption) + video scripti.

## Mimari

```
CLAUDE.md (3-line entry)
 └── @prompts/core/ulak-os-core-contract-2.0.0.md
 ├── @docs/runtime/*.md ← 33 runtime rule + 8 rule pack
 ├── @docs/governance/*.md ← 22 governance doc
 └── @docs/adapters/*.md ← claude-code / codex-cli / gemini-cli.claude/
 ├── agents/*.md ← 27 specialist + persona agent
 ├── commands/*.md ← 9 slash command
 ├── skills/*/SKILL.md ← 9 skill
 └── settings.json ← scoped permissions + hooks

templates/saas-starter/ ← 27 scaffolder template
evals/ ← golden prompts + assertion library
scripts/ ← validators + install + fetch-design-references
```

Detaylı mimari diagram'ları (mermaid, GitHub-native render): [docs/architecture/](./docs/architecture/) — overview · director-protocol · scaffolder-flow · vendor-adapters.

## İçerik (v1.0.0 public GA)

- **24 sector pack** — education, saas, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop, multi-tenant-supabase, container-orchestrating-app, payment-integrated-saas, regulated-saas, reseller-enabled-saas, vps-nginx-compose-topology, admin-cms-hardening, ai-relay-cost-control, telegram-bot, member-gated-community-platform, multi-app-nextjs-expo-monorepo, self-hosted-supabase-orchestration, multi-project-traefik-edge, greenfield-saas-starter
- **8 rule pack** — typescript-nextjs, python-fastapi, docker-compose, api-security, turkish-locale, localization-ssot, llm-streaming-context-aware, react-native-expo
- **~100 anti-pattern bullet** — 19 numaralı AP-NN (AP-01..AP-19) + klasik (IDOR, BOLA, N+1, RLS asymmetry, dead code, vs.)
- **22 governance doc** — product-surface-split, rule-pack-governance, secrets-rotation-policy, observability-baseline, pattern-import-ledger, settings-permissions-governance, lock-file-hygiene, ai-provider-allowlist, mcp-governance, memory-hygiene, prompt-supply-chain, artefact-write-authorization, ve daha fazlası
- **33 runtime rule** — router, program-phases (Phase 0→5), artefact-contract, context-budget, output-profiles, active-variable-contract, waves-pattern, live-probe-contract, dual-path-validation, persona-dispatch-pattern, strangler-fig-protocol, multi-agent-merge-sequence, audit-scoring-framework, cross-tenant-rls-verification, transactional-fsm-payment, webhook-ci-deploy-pattern, interactive-map-privacy, toolchain-precheck, architecture-currency, ve daha fazlası
- **27 agent** — 19 specialist + 1 autonomous-program-director + 7 persona (admin, customer, bayi, developer, support, compliance, security-redteam)
- **9 command** — director, final-verdict, frontend-war-room, intake, pack-gap-audit, triage-build, ulak-design-ref, ulak-intake, ulak-scaffold
- **8 skill** — saas-scaffolder, god-module-decomposition, fourteen-dimension-audit, multi-agent-orchestration, final-validation, pack-gap-completion, project-intake, research-currency
- **27 scaffolder template** — `templates/saas-starter/`: Next.js 16 + TS 5 strict + Tailwind v4 + Supabase SSR + auth helper + RLS + CI + tests + deploy + VPS hardening + 59-brand design reference

## Desteklenen stack'ler (`/ulak-scaffold` için)

| Katman | Primary | Experimental |
|---|---|---|
| Frontend | Next.js 16 | Remix, SvelteKit (v4.0) |
| Backend | Supabase SSR | FastAPI + Node hybrid (v4.0) |
| Payment | Stripe, Iyzico, both, none | — |
| Mobile | Expo 55+ (opsiyonel) | — |
| Hosting | Self-managed VPS + Traefik | Vercel, Fly.io, Railway |
| i18n | tr + en baseline | localization-ssot rule pack ile ≥2 locale |

## Vendor adapter matrisi

| Vendor | Durum | Komut dosyası | Reading order |
|---|---|---|---|
| Claude Code | primary | 9 slash command | `CLAUDE.md` @-imports |
| Codex / Copilot | supported | `AGENTS.md` plain-text | `AGENTS.md` |
| Gemini CLI | supported | 8 `.toml` komut | `docs/adapters/gemini-cli.md` |

## Release history

- **v2.4.0** (2026-04-20) — Public launch prep Phase A: LICENSE (MIT), README bilingual rewrite, CONTRIBUTING, CODE_OF_CONDUCT, issue/PR templates
- **v2.3.0** (2026-04-20) — Plugin packaging + 27 scaffolder templates + 6 ADRs + 3 agent expansion
- **v2.2.3** (2026-04-20) — 10 scaffolder templates core + awesome-design-md integration (59 brand references)
- **v2.2.2** (2026-04-20) — SaaS scaffolder command + skill + sector pack (greenfield-saas-starter) + 5 seed templates
- **v2.2.1** (2026-04-20) — Deep-infra absorption: AP-17/18/19 + SP-12/13 + cross-tenant-rls + transactional-fsm-payment + observability-baseline + secrets-rotation-policy
- **v2.2.0** (2026-04-20) — Cross-project absorption (5 sector packs + 4 rule packs + 2 runtime rules + 7 anti-patterns + pattern-import-ledger T1 entry)
- **v2.1.4** (2026-04-20) — CI hardening (cycle detection, $schema conformance, vendor parity, eval runner, gitleaks, dependabot)
- **v2.1.3** (2026-04-18) — First cross-project pattern absorption (39 patterns)

Tam release notes: [CHANGELOG.md](./CHANGELOG.md) · [docs/release/](./docs/release/)

## Yardım + daha fazla okuma

- **Sık sorulan sorular:** [docs/FAQ.md](./docs/FAQ.md) — Ulak OS vs superpowers / everything-claude-code / cartographer · Windows/macOS/Linux desteği · offline kullanım · model desteği
- **İlk saat:** [docs/runbooks/first-hour-with-ulak-os.md](./docs/runbooks/first-hour-with-ulak-os.md) — klon → ilk audit → ilk scaffold → ilk commit (60 dk)
- **Sorun giderme:** [docs/runbooks/troubleshooting.md](./docs/runbooks/troubleshooting.md) — 16 yaygın hata + tanı + fix
- **Yükseltme:** [docs/runbooks/upgrading-from-v2.x.md](./docs/runbooks/upgrading-from-v2.x.md) — mevcut Ulak kullanıcıları için
- **Yükleme yöntemleri:** [docs/runbooks/install-methods.md](./docs/runbooks/install-methods.md) — 5 farklı yol + pros/cons
- **Mimari:** [docs/architecture/](./docs/architecture/) — 4 mermaid diagram + prose
- **Showcase:** [docs/showcase/](./docs/showcase/) — 4 walkthrough + video script
- **Release geçmişi:** [CHANGELOG.md](./CHANGELOG.md) · [docs/history/version-lineage.md](./docs/history/version-lineage.md)
- **Yönetişim kararları:** [docs/adr/](./docs/adr/) (6 ADR)

## Katkı + governance

Yeni sector pack, rule pack, anti-pattern, veya agent önermek için: [CONTRIBUTING.md](./CONTRIBUTING.md).

Code of Conduct: [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

Güvenlik sorunu bildirmek için GitHub issue AÇMAYIN — doğrudan `info@oguzhansert.dev` adresine mail atın (CODE_OF_CONDUCT.md §Reporting).

Governance kararları: [docs/adr/](./docs/adr/) (6 ADR — rule packs, Phase 5 terminal, product surface split, pattern-import ledger, SaaS scaffolder).

## License

[MIT](./LICENSE) — yaygın + permissive. Fork et, uyarla, kendi operasyonuna uygula. Attribution yeterli.

## Maintainer

**Oğuzhan Sert** — [`@osrt91`](https://github.com/osrt91) · `info@oguzhansert.dev`
Bug report: [`.github/ISSUE_TEMPLATE/bug_report.md`](./.github/ISSUE_TEMPLATE/bug_report.md) · Güvenlik: [`SECURITY.md`](./SECURITY.md).

## Canonical footer

Authoritative as of Ulak OS **v1.0.0 (public GA)**. Build metadata: [`prompts/pack.json`](./prompts/pack.json). Core contract: [`prompts/core/ulak-os-core-contract-2.0.0.md`](./prompts/core/ulak-os-core-contract-2.0.0.md). Release notes: [`docs/release/v1.0.0-release-notes.md`](./docs/release/v1.0.0-release-notes.md).
