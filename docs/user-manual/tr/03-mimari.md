# 03 — Mimari

Ulak OS'un çalışma biçimini anlamak için dört katmanı ayırt edin: **startup memory** (başlangıç belleği), **core contract** (çekirdek sözleşme), **runtime rules + governance + motors** (çalışma-zamanı kuralları + yönetişim + motorlar), ve **commands + agents + skills** (komutlar + temsilciler + yetenekler). Bir `/director` veya `/ulak-scaffold` çağrısı bu katmanlardan aşağı doğru akar ve `reports/current/**` altına artefakt zinciri yazar.

## Yüklenme zinciri

Her oturum böyle başlar:

1. **Operatör slash-komut çağırır** (`/director komple`, `/ulak-scaffold`, vb.)
2. **Claude Code `CLAUDE.md`'yi yükler** — projenin başlangıç belleği.
3. `CLAUDE.md` içindeki `@`-import satırı **core contract**'ı yükler (`prompts/core/ulak-os-core-contract-2.0.0.md`).
4. Core contract **runtime rules**'ı (`docs/runtime/*.md`) ve **governance docs**'u (`docs/governance/*.md`) sırayla import eder.
5. Mode-loaded **operational motors** (intake, localization, market-research vb.) router kararına göre yüklenir.
6. `.claude/commands/*.md`'deki ilgili komut çalışır; gerekli agent ve skill'leri tetikler.

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
@docs/governance/trust-model.md
...
```

Bu zincir validate-imports.sh ile doğrulanır: döngü (cycle) yok, kırık referans yok, hidden-core dosyası Layer 1'e sızmamış.

## Layer 1 (public runtime surface) vs Layer 2 (hidden core)

Ulak OS iki yüzeyli bir paket olarak tasarlandı (bkz. [docs/governance/surface-split.md](../../governance/surface-split.md)):

### Layer 1 — Public runtime surface

Her oturumda yüklenen, operatörlerin görebileceği ve okumaya teşvik edildiği içerik:

- Core contract
- Runtime rules (33 dosya: router, phases, budget, output profiles, waves, anti-patterns...)
- Governance docs (22 dosya: trust, finding schema, surface-split, artefact authorization...)
- Operational motors (mode-loaded: intake, architecture-currency, localization, market-research, sector-packs)
- Commands, agents, skills, rule packs, sector packs
- Bilingual (TR/EN) README ve örnek çıktılar

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

## Mermaid diyagram referansları

Görsel diyagramlar şu dosyalarda:

- [docs/architecture/overview.md](../../architecture/overview.md) — sistem katmanları (9-layer graph)
- [docs/architecture/director-protocol.md](../../architecture/director-protocol.md) — Phase 0→5 flowchart
- [docs/architecture/scaffolder-flow.md](../../architecture/scaffolder-flow.md) — greenfield scaffold akışı
- [docs/architecture/vendor-adapters.md](../../architecture/vendor-adapters.md) — Claude / Codex / Gemini adapter'ları

Her diyagram Mermaid sözdizimiyle yazılır; GitHub veya uyumlu bir markdown görüntüleyici ile render edilir.

## Vendor adapter katmanı

Ulak OS'un core contract dosyası saf metindir. Üç adapter bu çekirdeği kendi CLI ortamına bağlar:

### Claude Code adapter

Dosya: [docs/adapters/claude-code.md](../../adapters/claude-code.md)

- `CLAUDE.md` → başlangıç belleği
- `.claude/commands/` → slash-komutları
- `.claude/agents/` → Phase 2'de paralel dispatch edilir
- `.claude/skills/` → agent bağlamında çağrılan iş akışları
- Paralel subagent dispatch tam destekli (Phase 2'nin temeli)

### Codex / Copilot adapter

Dosya: [docs/adapters/codex-cli.md](../../adapters/codex-cli.md)

- `AGENTS.md` → başlangıç belleği (CLAUDE.md karşılığı)
- Paralel dispatch yok, serial fallback
- Long-context code authoring güçlü

### Gemini CLI adapter

Dosya: [docs/adapters/gemini-cli.md](../../adapters/gemini-cli.md)

- `.gemini/commands/*.toml` → komut kayıtları
- Uzun context window avantajı, market research flow için ideal
- Bazı komutlar (`/frontend-war-room` gibi) Claude-first; istisnalar listelenir

## Pack-unit dizini

Her unit tip için diskte nerede yaşadıklarının hızlı referansı:

```
ulak-os/
├── CLAUDE.md                              # Startup memory
├── prompts/core/ulak-os-core-contract-2.0.0.md
├── .claude/
│   ├── commands/*.md                      # 9 slash-command
│   ├── agents/*.md                        # 27 uzman persona
│   └── skills/**/SKILL.md                 # 8 skill
├── docs/
│   ├── runtime/*.md                       # Runtime rules (33 dosya)
│   ├── runtime/rule-packs/*.md            # 8 rule pack
│   ├── runtime/sector-packs.md            # 24 sector pack indeksi
│   ├── governance/*.md                    # 22 governance dosyası
│   ├── adapters/*.md                      # 4 adapter dosyası
│   ├── architecture/*.md                  # Mimari belgeler
│   └── user-manual/{tr,en}/               # Bu kılavuzun ikisi dili
├── scripts/
│   ├── install.sh, install.ps1
│   ├── validate-imports.sh
│   ├── validate-schemas.sh
│   └── validate-vendor-parity.sh
└── reports/current/                       # Runtime artefakt çıktısı
    ├── runtime-manifest.md
    ├── assumptions.md
    ├── inventory.md
    ├── evidence-register.md
    ├── did-you-know.md
    ├── analysis-findings.md
    ├── target-state.md
    ├── execution-roadmap.md
    ├── validation-plan.md
    ├── pack-gap-register.md
    └── manager-verdict.md
```

## Artefakt chain — neden önemli?

Ulak OS'un sattığı değer, **append-only artefakt zinciri** fikriyle bağlıdır:

1. Her iddia (claim) bir file:line veya URL citation ve T1–T7 trust tier taşır.
2. Her Critical / High bulgusu validation-plan içinde bir method (yöntem) ile eşlenir.
3. Manager-verdict, bir Critical finding çözülmedikçe `signoff_status: ready` diyemez — şema gereği.
4. Tüm artefaktlar sizin repo'nuzda kalır (`reports/current/`). Network'e çıkış, telemetri, üçüncü tarafa veri paylaşımı yok.

Bu zincir denetim ve hesap verebilirlik sağlar: bir başka operatör aynı repo durumunu açıp aynı artefaktları okuyabilir; bir müşteri denetim raporunun nasıl üretildiğini rahat gösterebilirsiniz.

## Çalışma-zamanı disiplin dosyaları

En önemli beş runtime dosyası:

| Dosya | Ne tanımlar |
|---|---|
| [`docs/runtime/router.md`](../../runtime/router.md) | 9-alan router decision YAML — her run'ın başında pinlenir |
| [`docs/runtime/program-phases.md`](../../runtime/program-phases.md) | Phase 0→5 protokolünün kanonik tanımı |
| [`docs/runtime/artefact-contract.md`](../../runtime/artefact-contract.md) | Artefakt dosya adları, sıralaması, şartları |
| [`docs/runtime/output-profiles.md`](../../runtime/output-profiles.md) | 7 output profile (AUDIT, GREENFIELD_BUILDER vb.) |
| [`docs/runtime/waves-pattern.md`](../../runtime/waves-pattern.md) | Phase 6'da paralel execute edilecek wave'lerin kuralları |

## Governance dosyaları

En önemli beş governance dosyası:

| Dosya | Ne tanımlar |
|---|---|
| [`docs/governance/finding-schema.md`](../../governance/finding-schema.md) | Her claim için kanonik YAML şeması |
| [`docs/governance/evidence-trust-scoring.md`](../../governance/evidence-trust-scoring.md) | T1–T7 trust tier tanımları |
| [`docs/governance/surface-split.md`](../../governance/surface-split.md) | Public runtime vs hidden maintainer surface |
| [`docs/governance/artefact-write-authorization.md`](../../governance/artefact-write-authorization.md) | Director protokolünün `reports/current/**` altına yazma yetkisi |
| [`docs/governance/pattern-import-ledger.md`](../../governance/pattern-import-ledger.md) | Cross-project pattern absorbe kayıtları |

Tüm 22 governance dosyasının kategorili özeti için: [06-Yönetişim](./06-yonetisim.md).

## Mini sözlük

- **Artefakt** — bir phase'in diske yazdığı markdown veya YAML dosyası (`reports/current/*`)
- **Gate** — bir phase'in tamamlanmış sayılması için geçmesi gereken koşul
- **Dispatch** — bir agent veya skill'in çalıştırılması (genelde paralel bir batch içinde)
- **Trust tier** — bir iddianın kanıt seviyesi (T1 = direct verified, T7 = speculation)
- **Override block** — default Claude Code kuralının bir artefakt için askıya alındığını belirten disclaimer
- **Probe** — bir iddiayı canlı sistemde doğrulayan komut (grep, curl, DB query)

Sonraki bölüm: [04 — Komutlar](./04-komutlar.md)
