# 03 — Mimari

> **v1.6 güncellemesi:** Pack taksonomisi **15 sector overlay + 24 sector pack + 8 rule pack + 22 governance + 7 ADR + 4 runbook + 4 tutorial + 3 walkthrough + 47-term beginner-glossary** olarak genişledi. Vendor adapter katmanı 3 → **4 vendor** (Copilot Chat eklendi) ve NL trigger map katmanı (Codex + Copilot için) devreye girdi.

Ulak OS'un çalışma biçimini anlamak için dört katmanı ayırt edin: **startup memory** (başlangıç belleği), **core contract** (çekirdek sözleşme), **runtime rules + governance + motors** (çalışma-zamanı kuralları + yönetişim + motorlar), ve **commands + agents + skills** (komutlar + temsilciler + yetenekler). Bir `/director` veya `/ulak-scaffold` çağrısı bu katmanlardan aşağı doğru akar ve `reports/current/**` altına artefakt zinciri yazar.

## Yüklenme zinciri

Her oturum böyle başlar:

1. **Operatör slash-komut veya NL trigger çağırır** (`/director komple`, `/ulak-scaffold`, `selam ulak`, vb.)
2. **Vendor CLI entry dosyasını yükler** — Claude Code: `CLAUDE.md`; Gemini: `GEMINI.md`; Codex: `AGENTS.md`; Copilot: `.github/copilot-instructions.md`.
3. Entry dosyası içindeki `@`-import (Claude) veya reading-order (Codex/Copilot) **core contract**'ı yükler (`prompts/core/ulak-os-core-contract-2.0.0.md`).
4. Core contract **runtime rules**'ı (`docs/runtime/*.md`) ve **governance docs**'u (`docs/governance/*.md`) sırayla import eder.
5. Mode-loaded **operational motors** (intake, localization, market-research vb.) router kararına göre yüklenir.
6. `.claude/commands/*.md` veya `.gemini/commands/*.toml` içindeki komut çalışır; gerekli agent ve skill'leri tetikler. Codex/Copilot'ta NL trigger map'in ilgili satırı uygulanır.

Bu zincirin tam diyagramı: [docs/architecture/overview.md](../../architecture/overview.md).

## `@`-import mekanizması

Claude Code'un `@file.md` söz dizimi bir dosyayı prompt context'e (bağlama) dahil etmenin yoludur. Ulak OS bu mekanizmayı disiplinle kullanır:

```markdown
# Bir CLAUDE.md örneği

## Project identity
...

@prompts/core/ulak-os-core-contract-2.0.0.md
@docs/adapters/universal-runtime-contract.md
@docs/adapters/claude-code.md
```

Core contract da kendisi içinde `@`-import koleksiyonu barındırır:

```markdown
# Runtime rules
@docs/runtime/router.md
@docs/runtime/program-phases.md
@docs/runtime/artefact-contract.md
...

# Governance
@docs/governance/finding-schema.md
@docs/governance/evidence-trust-scoring.md
@docs/governance/vendor-capability-matrix.md
@docs/governance/localization-governance.md
...
```

Bu zincir `validate-imports.sh` ile doğrulanır: döngü (cycle) yok, kırık referans yok, hidden-core dosyası Layer 1'e sızmamış. `validate-bilingual.sh` TR/EN doküman parity'sini enforce eder.

**Gemini CLI:** `@`-import desteklemez — `.gemini/commands/*.toml` dosyaları `sync-gemini-commands.sh` ile Claude `.md` kaynağından türetilir, inline prompt olarak gönderilir.

**Codex / Copilot:** `@`-import desteklemez — reading-order listesi + NL trigger map vendor entry dosyasında. Aynı Layer 1 yüzeyi her oturumda okunur, kasıtlı sıralama `docs/adapters/codex-cli.md` ve `docs/adapters/copilot-chat.md` içindedir.

## Layer 1 (public runtime surface) vs Layer 2 (hidden core)

Ulak OS iki yüzeyli bir paket olarak tasarlandı (bkz. [docs/governance/surface-split.md](../../governance/surface-split.md)):

### Layer 1 — Public runtime surface

Her oturumda yüklenen, operatörlerin görebileceği ve okumaya teşvik edildiği içerik:

- Core contract
- Runtime rules (35+ dosya: router, phases, budget, output profiles, waves, anti-patterns, beginner-glossary, persona-dispatch, live-probe, dual-path-validation...)
- Governance docs (22 dosya — v1.6'da eklenenler: `vendor-capability-matrix.md`, `localization-governance.md`)
- Operational motors (mode-loaded: intake, architecture-currency, localization, market-research, sector-packs, turkish-normalization)
- Commands (24), agents (27), skills (10), rule packs (8), sector packs (24), sector overlay (15)
- Tutorials (4: Supabase / Vercel / GitHub / Resend)
- Walkthrough (3 sürüm: Claude / Codex / Copilot variant)
- Bilingual (TR/EN) README, user-manual, örnek çıktılar

### Layer 2 — Hidden maintainer surface

Sürüm arşivleri, paket geliştiricilerine yönelik historical notlar, maintainer sadece şablonlar:

- `docs/archive/internal-releases/*` — eski sürümlerin iç notları
- `docs/history/*` — version lineage, recon notes
- `docs/governance/hidden-maintainer-surface-template.md`

Ayrım önemlidir: **public runtime surface** her oturumda context'e yüklenir; **hidden core** yüklenmez. Bir operatör olarak "Ulak OS'un disiplinini nasıl uyguluyor?" sorusunu sormak isterseniz cevap Layer 1'dedir. "Pack bu noktaya nasıl geldi?" sorusunu sormak isterseniz cevap Layer 2'dedir.

## Phase 0 → Phase 5 director protokolü

`/director komple` çağrıldığında autonomous-program-director subagent'ı altı fazlı bir program koşturur. Her faz zorunlu bir artefakt üretir ve bir gate (kapı) geçmelidir.

| Faz | Artefakt | Gate ret koşulu |
|---|---|---|
| **0 — Environment lock** | `runtime-manifest.md`, `assumptions.md`, `active-variables.yaml` | 9-alan router kararı YAML'da pinli değilse ret |
| **1 — Deep inventory** | `inventory.md` (dosya+satır alıntılarıyla) | Folder dump (klasör listesi) ise ret |
| **2 — Parallel specialist evidence** | `evidence-register.md`, `deep-scan-report.md`, `specialists/*.md` | Tek generalist agent ise ret, paralel dispatch zorunlu |
| **3 — Did-you-know** | `did-you-know.md` | Boş / trivial ise ret (non-obvious finding zorunlu) |
| **4 — Synthesis** | `analysis-findings.md`, `target-state.md`, `execution-roadmap.md`, `validation-plan.md`, `pack-gap-register.md` | Beş dosyanın hepsi yoksa ret |
| **4.5 — Live probe (koşullu-zorunlu)** | `live-probe-results.md` | Validation-plan §6'da ≥1 probe varsa çalıştırılmalı |
| **5 — Manager verdict** | `manager-verdict.md`, `validation-result.yaml` | `signoff_status: ready` ama Critical finding çözülmemişse ret |

Toplam 15 ana artefakt (live-probe dahil) zorunludur. Artefakt chain (zincir) append-only'dir: her yeni çalışma `reports/current/**` altına yazar; önceki çalışmalar `reports/archive/` altına taşınır.

Detaylı protokol: [docs/architecture/director-protocol.md](../../architecture/director-protocol.md).

## Cross-vendor adapter layer

Ulak OS'un core contract dosyası saf metindir. Dört adapter bu çekirdeği kendi CLI ortamına bağlar:

### Claude Code adapter — FULL

Dosya: [docs/adapters/claude-code.md](../../adapters/claude-code.md)

- `CLAUDE.md` → başlangıç belleği
- `.claude/commands/` → 24 slash-komutu
- `.claude/agents/` → 27 agent, Phase 2'de paralel dispatch
- `.claude/skills/` → 10 skill, agent bağlamında çağrılır
- Paralel subagent dispatch tam destekli (Phase 2'nin temeli)

### Gemini CLI adapter — FULL-MINUS

Dosya: [docs/adapters/gemini-cli.md](../../adapters/gemini-cli.md)

- `GEMINI.md` → başlangıç belleği (CLAUDE.md ikizi)
- `.gemini/commands/*.toml` → 24 Claude komutu + 2 Gemini-only (`market-scan`, `frontend/war-room` alias)
- Uzun context window avantajı, market research flow için ideal
- Paralel dispatch MISSING → serial fallback; bazı komutlar NL + serial

### Codex CLI adapter — CORE

Dosya: [docs/adapters/codex-cli.md](../../adapters/codex-cli.md)

- `AGENTS.md` → başlangıç belleği + reading-order listesi + **NL trigger map**
- Native slash primitive yok → `selam ulak`, "run the director protocol" gibi doğal dil tetiklemeleri map edilir
- 22 komut PARTIAL (NL trigger), 4 komut OK (inline-only: `ulak-hello`, `ulak-next-steps`, `ulak-explain`, `ulak-demo`, `ulak-packs`)
- Artefakt zinciri reproducible ama serial

### Copilot Chat (VS Code) adapter — LIMITED

Dosya: [docs/adapters/copilot-chat.md](../../adapters/copilot-chat.md)

- `.github/copilot-instructions.md` → NL trigger map
- VS Code chat scope'u; terminal-suggest fallback Bash için
- MCP MISSING → `/ulak-design-ref` ve `/ulak-mcp-discover` desteklenmez
- Read-heavy komutlar (`/intake`, `/ulak-explain`, `/ulak-packs`) çalışır; write-heavy (`/ulak-scaffold`) apply-action fallback

Tam matris: [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md).

## NL trigger map katmanı

Codex ve Copilot slash primitive'i olmadığı için Ulak OS bir **NL trigger map** katmanı ekler. Bu map vendor entry dosyasında yaşar ve doğal dil frazları Ulak komutlarına bağlar:

| NL fraz (TR/EN) | Tetiklenen komut | Vendor |
|---|---|---|
| `selam ulak` / `hi ulak` | `/ulak-hello` | Codex, Copilot, Claude, Gemini |
| `new saas` / `start wizard` / `ulak başlat` | `/ulak-start` | tüm 4 |
| `scaffold` / `generate my saas` | `/ulak-scaffold` | tüm 4 |
| `audit this repo` / `run director` | `/director komple` | tüm 4 |
| `what can ulak do` / `ulak neler yapabilir` | `/ulak-packs` | tüm 4 |
| `explain <term>` / `<term> nedir` | `/ulak-explain` | tüm 4 |
| `plan next steps` / `şimdi ne yapayım` | `/ulak-next-steps` | tüm 4 |
| `search <keyword>` / `ara <kelime>` | `/ulak-search` | tüm 4 |
| `show demo` / `örnek göster` | `/ulak-demo` | tüm 4 |
| `switch language` / `dil değiştir` | `/ulak-locale` | tüm 4 |

Map'in kanonik kaynağı: [docs/adapters/codex-cli.md](../../adapters/codex-cli.md) ve [docs/adapters/copilot-chat.md](../../adapters/copilot-chat.md). Claude ve Gemini'de zaten `/ulak-ask` doğal dil yönlendirmesi aynı işi görür.

## Pack-unit dizini

Her unit tip için diskte nerede yaşadıklarının hızlı referansı:

```
ulak-os/
├── CLAUDE.md                              # Startup memory (Claude)
├── GEMINI.md                              # Startup memory (Gemini)
├── AGENTS.md                              # Startup memory + NL trigger map (Codex)
├── prompts/core/ulak-os-core-contract-2.0.0.md
├── .claude/
│   ├── commands/*.md                      # 24 slash-command (v1.6)
│   ├── agents/*.md                        # 27 uzman persona
│   └── skills/**/SKILL.md                 # 10 skill
├── .gemini/
│   └── commands/*.toml                    # Gemini native (sync-gemini-commands.sh ile türetilir)
├── .github/
│   └── copilot-instructions.md            # Copilot Chat NL trigger map
├── docs/
│   ├── runtime/*.md                       # Runtime rules (35+ dosya)
│   ├── runtime/rule-packs/*.md            # 8 rule pack
│   ├── runtime/sector-packs.md            # 24 sector pack + 15 overlay indeksi
│   ├── runtime/beginner-glossary.md       # 47-term operatör sözlüğü (v1.6)
│   ├── governance/*.md                    # 22 governance (vendor-capability-matrix + localization-governance v1.6)
│   ├── adapters/*.md                      # 4 adapter dosyası (claude / gemini / codex / copilot)
│   ├── tutorials/*.md                     # 4 tutorial (supabase, vercel, github, resend)
│   ├── walkthrough/*.md                   # 3 walkthrough (first-saas × Claude/Codex/Copilot)
│   ├── runbooks/*.md                      # 4 runbook
│   ├── adr/*.md                           # 7 ADR (000 → 005 + newer)
│   ├── architecture/*.md                  # Mimari belgeler
│   └── user-manual/{tr,en}/               # Bu kılavuzun iki dili
├── scripts/
│   ├── install.sh, install.ps1
│   ├── init-claude.sh / .ps1
│   ├── init-gemini.sh / .ps1
│   ├── init-codex.sh / .ps1
│   ├── sync-gemini-commands.sh            # Claude → Gemini komut senkronu
│   ├── validate-imports.sh
│   ├── validate-schemas.sh
│   ├── validate-vendor-parity.sh
│   └── validate-bilingual.sh              # TR/EN parity enforcement (v1.6)
└── reports/current/                       # Runtime artefakt çıktısı
    ├── runtime-manifest.md
    ├── inventory.md
    ├── evidence-register.md
    ├── did-you-know.md
    ├── analysis-findings.md
    ├── target-state.md
    ├── execution-roadmap.md
    ├── validation-plan.md
    ├── live-probe-results.md              # Phase 4.5 conditional
    ├── pack-gap-register.md
    ├── manager-verdict.md
    └── validation-result.yaml
```

## Artefakt chain — neden önemli?

Ulak OS'un sattığı değer, **append-only artefakt zinciri** fikriyle bağlıdır:

1. Her iddia (claim) bir file:line veya URL citation ve T1–T7 trust tier taşır.
2. Her Critical / High bulgusu validation-plan içinde bir method (yöntem) ile eşlenir.
3. Manager-verdict, bir Critical finding çözülmedikçe `signoff_status: ready` diyemez — şema gereği.
4. Tüm artefaktlar sizin repo'nuzda kalır (`reports/current/`). Network'e çıkış, telemetri, üçüncü tarafa veri paylaşımı yok.

Bu zincir denetim ve hesap verebilirlik sağlar: bir başka operatör aynı repo durumunu açıp aynı artefaktları okuyabilir.

## Çalışma-zamanı disiplin dosyaları

En önemli altı runtime dosyası:

| Dosya | Ne tanımlar |
|---|---|
| [`docs/runtime/router.md`](../../runtime/router.md) | 9-alan router decision YAML — her run'ın başında pinlenir |
| [`docs/runtime/program-phases.md`](../../runtime/program-phases.md) | Phase 0→5 protokolünün kanonik tanımı |
| [`docs/runtime/artefact-contract.md`](../../runtime/artefact-contract.md) | Artefakt dosya adları, sıralaması, şartları |
| [`docs/runtime/output-profiles.md`](../../runtime/output-profiles.md) | 7 output profile (AUDIT, GREENFIELD_BUILDER vb.) |
| [`docs/runtime/waves-pattern.md`](../../runtime/waves-pattern.md) | Phase 6'da paralel execute edilecek wave'lerin kuralları |
| [`docs/runtime/beginner-glossary.md`](../../runtime/beginner-glossary.md) | 47 temel terim — `/ulak-explain` lookup kaynağı (v1.6) |

## Governance dosyaları

En önemli yedi governance dosyası:

| Dosya | Ne tanımlar |
|---|---|
| [`docs/governance/finding-schema.md`](../../governance/finding-schema.md) | Her claim için kanonik YAML şeması |
| [`docs/governance/evidence-trust-scoring.md`](../../governance/evidence-trust-scoring.md) | T1–T7 trust tier tanımları |
| [`docs/governance/surface-split.md`](../../governance/surface-split.md) | Public runtime vs hidden maintainer surface |
| [`docs/governance/artefact-write-authorization.md`](../../governance/artefact-write-authorization.md) | Director protokolünün `reports/current/**` altına yazma yetkisi |
| [`docs/governance/pattern-import-ledger.md`](../../governance/pattern-import-ledger.md) | Cross-project pattern absorbe kayıtları |
| [`docs/governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md) | 4 vendor × 24 komut destek matrisi (v1.6) |
| [`docs/governance/localization-governance.md`](../../governance/localization-governance.md) | TR/EN bilingual parity kuralları (v1.6) |

Tüm 22 governance dosyasının kategorili özeti için: [06-Yönetişim](./06-yonetisim.md).

## Mermaid diyagram referansları

Görsel diyagramlar şu dosyalarda:

- [docs/architecture/overview.md](../../architecture/overview.md) — sistem katmanları
- [docs/architecture/director-protocol.md](../../architecture/director-protocol.md) — Phase 0→5 flowchart
- [docs/architecture/scaffolder-flow.md](../../architecture/scaffolder-flow.md) — greenfield scaffold akışı
- [docs/architecture/vendor-adapters.md](../../architecture/vendor-adapters.md) — 4-vendor adapter akışı

## Mini sözlük

- **Artefakt** — bir phase'in diske yazdığı markdown veya YAML dosyası (`reports/current/*`)
- **Gate** — bir phase'in tamamlanmış sayılması için geçmesi gereken koşul
- **Dispatch** — bir agent veya skill'in çalıştırılması (genelde paralel bir batch içinde)
- **Trust tier** — bir iddianın kanıt seviyesi (T1 = direct verified, T7 = speculation)
- **Override block** — default Claude Code kuralının bir artefakt için askıya alındığını belirten disclaimer
- **Probe** — bir iddiayı canlı sistemde doğrulayan komut (grep, curl, DB query)
- **NL trigger map** — Codex/Copilot'ta slash yerine doğal dil fraz ↔ komut eşlemesi (v1.6)
- **Sector overlay** — aktif sector pack'in üzerine kesişim olarak binen bir yan-domain (ör. `multi-tenant` × `saas`)

Daha fazla terim için: `/ulak-explain <term>` veya doğrudan [docs/runtime/beginner-glossary.md](../../runtime/beginner-glossary.md).

Sonraki bölüm: [04 — Komutlar](./04-komutlar.md)
