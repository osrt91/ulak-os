# Ulak OS

> **Tek cümle:** Ulak OS, AI coding CLI'larının (Claude Code / Codex / Gemini) üstüne oturan bir **prompt işletim sistemi**; projeni okur, eksikleri söyler, gerekirse sıfırdan tam yığın SaaS üretir.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE) [![Version](https://img.shields.io/badge/version-1.0.0--public--GA-blue.svg)](./CHANGELOG.md) [![Vendor](https://img.shields.io/badge/vendor-claude%20%7C%20codex%20%7C%20gemini-orange.svg)](./docs/adapters/)

**Türkçe (bu dosya)** · **[English README](./README.en.md)**

---

## İlk ekran — 3 komut

```bash
/ulak-hello          # 30 saniyelik tour — Ulak OS nedir, nasıl denenir?
/director komple     # mevcut projeyi baştan sona audit et (Phase 0-5)
/ulak-start          # yeni SaaS başlat (6 soruluk wizard)
```

İlk defa görüyorsan **`/ulak-hello`** ile başla. Ne olduğunu 30 saniyede göreceksin, sonra istediğin yola sap.

---

## Kurulum 30 saniye

**Tek satır installer** (önerilen — macOS / Linux):

```bash
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh
```

**Windows PowerShell 5.1+**:

```powershell
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex
```

**Manuel klon** (vendor-lock-in olmadan inceleme için):

```bash
git clone https://github.com/osrt91/ulak-os.git
cd ulak-os
```

**Sonra ne yap?** Claude Code'u aç, `/ulak-hello` yaz, `enter`. Gerisi seçim menüsünden.

> Checksum doğrulamalı güvenli yükleme + alternatif yollar: [docs/runbooks/install-methods.md](./docs/runbooks/install-methods.md).
> Doğrulama: `ulak doctor` — tüm validator'ları sırayla çalıştırır. Hepsi yeşil ise pack sağlıklı.

---

## Ne yapabilirim?

Yeni kullanıcı için 6 somut senaryo. Her biri tek komut ile başlıyor; çıktıyı Ulak OS üretiyor.

> **Hızlı başlangıç**: `selam ulak` ya da `hi ulak` yaz → `/ulak-hello` otomatik başlar. Hiç komut ezberlemene gerek yok.
>
> **Tam yolu gör**: [docs/walkthrough/01-first-saas-end-to-end.md](docs/walkthrough/01-first-saas-end-to-end.md) — 75 dakikalık uçtan uca senaryo (marketplace + Supabase + GitHub + Vercel + Resend + Iyzico).

### 1. Yeni SaaS başlat (5-10 dakika)

```bash
/ulak-start
```

6 kısa soru: ürün adı, sektör, stack, payment, i18n, mobile. Ulak OS doğru parametrelerle `/ulak-scaffold`'ı çağırır; sibling dizinde (`../my-saas/`) tam bir Next.js + Supabase + Stripe + i18n + CI + tests + deploy projesi üretir. Commit 1'de RLS template, auth helper, webhook deploy, `.gitignore` discipline, gitleaks baseline. Ezber flag yok.

### 2. Mevcut projeyi audit et (45-90 dakika)

```bash
cd /path/to/your-project
echo "@/absolute/path/to/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md" >> CLAUDE.md
# Claude Code aç:
/director komple
```

Director çalışır: runtime-manifest → deep inventory (dosya+satır) → 4-13 specialist paralel dispatch → did-you-know findings → target-state + execution-roadmap + validation-plan + pack-gap-register → manager-verdict. 27 agent'tan hangileri projene uyuyorsa hepsi aynı anda devreye girer.

### 3. Doğal dille sor

```bash
/ulak-ask "turkish locale ekle"
/ulak-ask "rls asimetrisi var mı kontrol et"
/ulak-ask "pack-gap tara"
```

Plugin aramadan, flag ezberlemeden, ne istediğini söyle. Ulak OS anahtar kelime + niyet eşlemesi ile uygun komutu çağırır; belirsizse "bunu mu demek istedin?" diye doğrular.

### 4. Paket + kapasite ara

```bash
/ulak-packs          # tüm kapasiteleri özet tablo olarak göster
/pack-gap-audit      # mevcut pack'te eksik ne var raporla
/ulak-mcp-discover   # public MCP registry'sinden yeni server öner
```

### 5. Onboarding tour'u tekrar başlat

```bash
/ulak-hello
```

İlk ekranı tekrar görmek için. 30 saniyede tour, 4 seçenek, doğrudan ilgili komuta yönlenirsin.

### 6. Güncelle + doğrula

```bash
git pull origin main
ulak doctor                          # cross-platform — tüm validator'lar
bash scripts/validate-imports.sh     # @-import zinciri + cycle detection
bash scripts/validate-schemas.sh     # JSON schema conformance
bash scripts/validate-vendor-parity.sh  # claude/gemini/codex parity
```

Mevcut Ulak kullanıcısıysan: [docs/runbooks/upgrading-from-v2.x.md](./docs/runbooks/upgrading-from-v2.x.md).

---

## Kapasite özeti (v1.0.0 public GA)

Tek tablo, gerçek sayılar. Detay için ilgili klasörlere git.

| Yüzey | Sayı | Ne içerir | Referans |
|---|---|---|---|
| **Komutlar** | 15 | `/director`, `/ulak-start`, `/ulak-hello`, `/ulak-scaffold`, `/ulak-ask`, `/final-verdict`, `/intake`, `/frontend-war-room`, `/pack-gap-audit`, `/triage-build`, `/ulak-design-ref`, `/ulak-intake`, `/ulak-audit-deep`, `/ulak-pattern-extract`, `/ulak-mcp-discover` | [`.claude/commands/`](./.claude/commands/) |
| **Skills** | 10 | `saas-scaffolder`, `fourteen-dimension-audit`, `god-module-decomposition`, `multi-agent-orchestration`, `final-validation`, `pack-gap-completion`, `project-intake`, `research-currency`, `awesome-packs-index`, `mcp-governance-auto` | [`.claude/skills/`](./.claude/skills/) |
| **Agents** | 27 | 19 specialist + 1 autonomous-program-director + 7 persona (admin, customer, bayi, developer, support, compliance, security-redteam) | [`.claude/agents/`](./.claude/agents/) |
| **Sector packs** | 14 | education, saas, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop, ai-relay-cost-control, member-gated-community, admin-cms-hardening, self-hosted-supabase | [`templates/sectors/`](./templates/sectors/) + [`docs/runtime/sector-packs.md`](./docs/runtime/sector-packs.md) |
| **Rule packs** | 8 | typescript-nextjs, python-fastapi, docker-compose, api-security, turkish-locale, localization-ssot, llm-streaming-context-aware, react-native-expo | [`docs/runtime/rule-packs/`](./docs/runtime/rule-packs/) |
| **Governance docs** | 22 | product-surface-split, rule-pack-governance, secrets-rotation-policy, observability-baseline, pattern-import-ledger, settings-permissions-governance, lock-file-hygiene, ai-provider-allowlist, mcp-governance, memory-hygiene, prompt-supply-chain, artefact-write-authorization, vd. | [`docs/governance/`](./docs/governance/) |
| **Runtime rules** | 33 | router, program-phases (Phase 0-5), artefact-contract, context-budget, output-profiles, active-variable-contract, waves-pattern, live-probe-contract, dual-path-validation, persona-dispatch-pattern, vd. | [`docs/runtime/`](./docs/runtime/) |
| **Anti-pattern** | ~100 | 19 numaralı AP-NN (AP-01..AP-19) + klasik (IDOR, BOLA, N+1, RLS asymmetry, dead code, vd.) | inline — sector + rule packs |
| **Scaffolder templates** | 27 | `templates/saas-starter/` — Next.js 16 + TS 5 strict + Tailwind v4 + Supabase SSR + auth helper + RLS + CI + tests + deploy + VPS hardening + 59-brand design reference | [`templates/saas-starter/`](./templates/saas-starter/) |

---

## Üç şey yapar (kısa özet)

| | Komut | Ne üretir |
|---|---|---|
| **Audit** | `/director komple` | Phase 0→5 director protokolü: 27 specialist paralel, 15-boyut scorecard, 79 anti-pattern tarama, 13 artefakt |
| **Govern** | `@prompts/core/ulak-os-core-contract-2.0.0.md` | Core contract'ı CLAUDE.md'ye import et → 22 governance doc + 14 sector pack + 8 rule pack her session aktif |
| **Scaffold** | `/ulak-scaffold` veya `/ulak-start` | Full-stack SaaS (Next.js + Supabase + payment + i18n + CI + deploy) commit 1'de — 27 template dosyası + 8 anti-pattern construction'da gated |

---

## Mimari

```
CLAUDE.md (3-line entry)
 └── @prompts/core/ulak-os-core-contract-2.0.0.md
      ├── @docs/runtime/*.md          <- 33 runtime rule + 8 rule pack
      ├── @docs/governance/*.md       <- 22 governance doc
      └── @docs/adapters/*.md         <- claude-code / codex-cli / gemini-cli

.claude/
  ├── agents/*.md                     <- 27 specialist + persona
  ├── commands/*.md                   <- 24 slash command
  ├── skills/*/SKILL.md               <- 10 skill
  └── settings.json                   <- scoped permissions + hooks

templates/
  ├── saas-starter/                   <- 27 scaffolder template
  └── sectors/                        <- 14 sector pack

evals/     <- golden prompts + assertion library
scripts/   <- validators + install + fetch-design-references
```

Detaylı mimari diagram (mermaid): [docs/architecture/](./docs/architecture/).

---

## Desteklenen stack'ler (`/ulak-scaffold` için)

| Katman | Primary | Experimental |
|---|---|---|
| Frontend | Next.js 16 | Remix, SvelteKit (v4.0) |
| Backend | Supabase SSR | FastAPI + Node hybrid (v4.0) |
| Payment | Stripe, Iyzico, both, none | — |
| Mobile | Expo 55+ (opsiyonel) | — |
| Hosting | Self-managed VPS + Traefik | Vercel, Fly.io, Railway |
| i18n | tr + en baseline | localization-ssot rule pack ile ≥2 locale |

---

## Vendor adapter matrisi

| Vendor | Durum | Komut dosyası | Reading order |
|---|---|---|---|
| Claude Code | primary | 24 slash command | `CLAUDE.md` @-imports |
| Codex / Copilot | supported | `AGENTS.md` plain-text | `AGENTS.md` |
| Gemini CLI | supported | 8 `.toml` komut | `docs/adapters/gemini-cli.md` |

---

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

---

## Yardım + daha fazla okuma

- **30 saniyelik tour:** `/ulak-hello` — ilk ekran, 4 seçenek, direkt yönlendirme
- **Sık sorulan sorular:** [docs/FAQ.md](./docs/FAQ.md) — Ulak OS vs alternatifler · platform desteği · offline · model
- **İlk saat:** [docs/runbooks/first-hour-with-ulak-os.md](./docs/runbooks/first-hour-with-ulak-os.md) — klon → ilk audit → ilk scaffold → ilk commit (60 dk)
- **Sorun giderme:** [docs/runbooks/troubleshooting.md](./docs/runbooks/troubleshooting.md) — 16 yaygın hata + tanı + fix
- **Yükseltme:** [docs/runbooks/upgrading-from-v2.x.md](./docs/runbooks/upgrading-from-v2.x.md)
- **Yükleme yöntemleri:** [docs/runbooks/install-methods.md](./docs/runbooks/install-methods.md) — 5 yol + pros/cons
- **Mimari:** [docs/architecture/](./docs/architecture/) — 4 mermaid diagram + prose
- **Showcase:** [docs/showcase/](./docs/showcase/) — 4 walkthrough + video script
- **Yönetişim kararları:** [docs/adr/](./docs/adr/) (6 ADR)

> English README: [README.en.md](./README.en.md)

---

## Katkı + güvenlik

Yeni sector pack, rule pack, anti-pattern, veya agent önermek için: [CONTRIBUTING.md](./CONTRIBUTING.md). Code of Conduct: [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

**Güvenlik sorunu:** GitHub issue AÇMAYIN — doğrudan `info@oguzhansert.dev` adresine mail atın (bkz. [SECURITY.md](./SECURITY.md)).

---

## License

[MIT](./LICENSE) — permissive. Fork et, uyarla, kendi operasyonuna uygula. Attribution yeterli.

## Maintainer

**Oğuzhan Sert** — [`@osrt91`](https://github.com/osrt91) · `info@oguzhansert.dev`

---

## Canonical footer

Authoritative as of Ulak OS **v1.0.0 (public GA)**. Build metadata: [`prompts/pack.json`](./prompts/pack.json). Core contract: [`prompts/core/ulak-os-core-contract-2.0.0.md`](./prompts/core/ulak-os-core-contract-2.0.0.md). Release notes: [`docs/release/v1.0.0-release-notes.md`](./docs/release/v1.0.0-release-notes.md).
