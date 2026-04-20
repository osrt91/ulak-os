# Ulak OS

> **Vendor-neutral prompt operating system** — plan, audit, govern, and **scaffold full-stack SaaS** with Claude Code, Codex, and Gemini CLI.

**Sürüm:** 2.2.2 (SaaS scaffolder + cross-project absorption + CI hardening)
**GitHub:** https://github.com/osrt91/ulak-os
**Tags:** v2.1.3 · v2.1.4 · v2.2.0 · v2.2.1 · v2.2.2

## Ulak OS nedir?

Ulak OS, AI coding CLI'larının (Claude Code / Codex / Gemini) üstüne oturan bir **prompt işletim sistemi**. Tek bir çekirdek, üç vendor adaptörü, şu anda 24 sector pack + 8 rule pack + 79 anti-pattern + 22 governance doc + 27 specialist agent + 9 slash-command + 8 skill içerir.

Üç şey yapar:
1. **Audit** — mevcut projeyi 15-dim scorecard + 79 anti-pattern + Phase 0→5 director protokolü ile değerlendirir
2. **Govern** — multi-project portfolyoda rule packs + pattern-import-ledger + secrets-rotation-policy ile disiplin uygular
3. **Scaffold** — `/ulak-scaffold` ile full-stack SaaS'ı commit 1'de ship-ready üretir (v2.2.2 yeni)

## 5 dakikada başlangıç

### 1. Bu repo'yu al

```bash
git clone https://github.com/osrt91/ulak-os.git
cd ulak-os
```

### 2. İki yol var

**Yol A — Mevcut projeni audit et:**
```bash
cd /path/to/your-project
# CLAUDE.md'de Ulak OS core contract'ını import et:
echo "@/path/to/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md" >> CLAUDE.md
# Claude Code'u aç, şu komutu yaz:
/director komple
```

Director Phase 0→5 çalışır: runtime-manifest → inventory (deep) → 8 specialist parallel dispatch → did-you-know → synthesis (analysis-findings + target-state + execution-roadmap + validation-plan + pack-gap-register) → manager-verdict.

**Yol B — Yeni SaaS scaffold et:**
```bash
# Ulak OS repo dizininde Claude Code'u aç:
/ulak-scaffold product_name=my-saas product_domain=saas locale_primary=tr payment_provider=iyzico
```

Bu komut sana şunları soracak (boş bıraktıklarını), sonra sibling dizinde tam bir Next.js + Supabase + Stripe/Iyzico + i18n + CI + tests + Traefik deploy projesi oluşturacak. Commit 1'de Ulak OS governance'ın hepsi bağlı: single auth helper, DB-sourced role, RLS templates, webhook-deploy + health probe, gitleaks baseline, dependabot, pre-push parity.

### 3. Doğrulama

```bash
# Ulak OS kendi içinde:
bash scripts/validate-imports.sh
bash scripts/validate-schemas.sh
bash scripts/validate-vendor-parity.sh
bash evals/run.sh   # warn-only
```

Hepsi yeşil ise pack sağlıklı. Kendi projende aynı script'leri bekle — scaffolder bunları otomatik kuruyor.

## Mimari özet

```
CLAUDE.md (3-line)
   └── @prompts/core/ulak-os-core-contract-2.0.0.md
           ├── @docs/runtime/*.md          ← 33 runtime rule + 8 rule pack
           ├── @docs/governance/*.md       ← 22 governance doc
           └── @docs/adapters/*.md         ← claude-code / codex-cli / gemini-cli

.claude/
   ├── agents/          ← 27 specialist + persona agents
   ├── commands/        ← 9 slash commands (director, intake, scaffold, ...)
   ├── skills/          ← 8 skills (saas-scaffolder, fourteen-dim-audit, ...)
   └── settings.json    ← hooks + deny list (settings.local.json gitignored)

src/                    ← CLI implementation (ulak command)
templates/saas-starter/ ← SaaS scaffolder templates (v2.2.2)
evals/                  ← golden prompts + assertion library
scripts/                ← validators + CI helpers
```

## Ne yapıyor (kompakt liste)

### Her session
- **Phase 0**: router decision + runtime-manifest + assumptions
- **Phase 1**: deep inventory (file:line citations, cartographer-grade)
- **Phase 2**: 4-13 specialist agent paralel dispatch + evidence merge
- **Phase 3**: did-you-know (non-obvious findings, MANDATORY)
- **Phase 4**: analysis + target-state + execution-roadmap + validation-plan + pack-gap-register
- **Phase 4.5**: live-probe (conditional — if validation-plan §6 has probes)
- **Phase 5**: manager-verdict + validation-result

### Governance disiplinleri (22 doc)
- product-surface-split (customer/admin/public/partner — AP-11 prevention)
- rule-pack-governance (7th unit type beyond command/agent/skill/hook/MCP/plugin)
- secrets-rotation-policy (90d JWT, 60d service-role, 30d prod payment)
- observability-baseline (3 pillars — structured logs + RED metrics + error tracking)
- pattern-import-ledger (cross-project pattern provenance — IL-001 live)
- settings-permissions-governance (no Bash(*) / Delete(*) — explicit deny list required)
- lock-file-hygiene (TTL + pid liveness + audit trail)
- ai-provider-allowlist (which AI vendor may this project call — drift detection)

### Anti-patterns actively gated (79 total)
- AP-01 in-memory state | AP-02 token in URL | AP-03 non-blocking CI gate | AP-04 unvalidated JSONB | AP-05 raw docker.sock | AP-06 user_metadata as authz | AP-07 DDL at router import | AP-08 payment sandbox hardcoded | AP-09 copy-paste service logic | AP-10 multi-file schema drift | AP-11 multi-layer auth bypass | AP-12 fake rollback deploy | AP-13 server-only not imported | AP-14 dead admin CRUD | AP-15 drag-drop without conflict resolution | AP-16 .env.local committed | AP-17 no DB backup | AP-18 static HMAC empty body | AP-19 root .env.local in monorepo | + ~60 classical (IDOR, BOLA, N+1, RLS asymmetry, etc.)

## Vendor adapter matrix

| Vendor | Status | Commands | Reading order |
|---|---|---|---|
| Claude Code | primary | 9 slash commands | CLAUDE.md @-imports |
| Codex / Copilot | supported | AGENTS.md plain-text | AGENTS.md |
| Gemini CLI | supported | 8 .toml commands | docs/adapters/gemini-cli.md |

## Release history

- **v2.2.2** (2026-04-20): SaaS scaffolder (`/ulak-scaffold`) + sector pack SP-14 + 5 starter templates + version sync + README rewrite + Performance dimension
- **v2.2.1** (2026-04-20): Deep-infra absorption — AP-17/18/19, SP-12/13, cross-tenant-rls-verification, transactional-fsm-payment, secrets-rotation-policy, observability-baseline, webhook health-probe contract
- **v2.2.0** (2026-04-20): Cross-project absorption Eksen A — 5 sector packs + 4 rule packs + 2 runtime rules + 7 anti-patterns + IL-001 pattern-import-ledger
- **v2.1.4** (2026-04-20): CI hardening — cycle detection, $schema conformance, vendor parity, eval runner, gitleaks, dependabot, log rotation
- **v2.1.3** (2026-04-18): First cross-project absorption — 39 patterns → 4 rule packs + 6 governance + 3 skills + 3 agent extensions + triage-build command + Phase 5 terminal refactor

## Contribution + governance

- New sector pack: open an issue with proposed pack + ≥2 project evidence base
- New anti-pattern: needs cross-project evidence (≥2 projects showing same defect)
- New runtime rule: needs ≥1 session of actual usage before promotion
- New agent: follow `docs/governance/plugin-skill-decision.md` unit-picking order
- Cross-project patterns: record in `docs/governance/pattern-import-ledger.md` with T1 source evidence

## Supported stacks (for `/ulak-scaffold`)

- **Frontend**: Next.js 16 (primary), Remix, SvelteKit (experimental)
- **Backend**: Supabase (primary), FastAPI + Node hybrid
- **Payment**: Stripe, Iyzico, both, none
- **i18n**: tr + en (default), multi-locale via `localization-ssot` rule pack
- **Mobile**: Expo 55+ (optional via `react-native-expo` rule pack)
- **Hosting**: self-managed VPS + Traefik (primary), Vercel/Fly/Railway (experimental)

## License

UNLICENSED (private operator toolkit). If you need a commercial license, open an issue.

## Canonical footer

Authoritative as of Ulak OS **v2.2.2**. Build metadata in `prompts/pack.json`. Latest governance imports in `prompts/core/ulak-os-core-contract-2.0.0.md`.
