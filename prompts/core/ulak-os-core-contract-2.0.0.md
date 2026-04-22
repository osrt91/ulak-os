# Ulak OS Core Contract 2.0.0

Bu dosya vendor-agnostic çekirdek sözleşmesidir. Claude Code, Gemini CLI, Codex CLI ve Copilot Chat oturumlarında `@prompts/core/ulak-os-core-contract-2.0.0.md` yolu ile `CLAUDE.md` / `GEMINI.md` / `AGENTS.md`'ye içe aktarılır. Çözümlendiğinde aşağıdaki 45 `@`-import diskten okunur ve o oturumun çalışma zamanı yüzeyi haline gelir.

**Sürüm bağlamı:** Dosya adındaki `2.0.0` bu sözleşmenin *şema sürümüdür* — repo semver'inden bağımsızdır. Repo şu an **v1.6.1**; sözleşme şeması **v2.0.0** stabil, içeriği **v2.1 disiplin kurallarıyla** güncellenir. Dosya adının bilinçli sabit tutulduğu kayıt altındadır (bkz. `docs/release/v2.1.0-release-notes.md` — *"The core contract filename stays `ulak-os-core-contract-2.0.0.md`"*).

## Çalışma zamanı disiplin katmanı (v2.1)

Bu çekirdeğin operasyonel disiplini aşağıdaki dosyalarda tanımlıdır. Bu dosyalar her aktif run'da yüklenen public runtime surface'in bir parçasıdır:

### Çalışma zamanı kuralları
@docs/runtime/router.md
@docs/runtime/intent-router.md
@docs/runtime/program-phases.md
@docs/runtime/artefact-contract.md
@docs/runtime/context-budget.md
@docs/runtime/output-profiles.md
@docs/runtime/active-variable-contract.md
@docs/runtime/validation-result-schema.md
@docs/runtime/universal-surface-inventory.md
@docs/runtime/analysis-contexts.md
@docs/runtime/roadmap-rule.md
@docs/runtime/anti-patterns.md
@docs/runtime/waves-pattern.md
@docs/runtime/live-probe-contract.md
@docs/runtime/dual-path-validation.md
@docs/runtime/handoff-plan-contract.md
@docs/runtime/persona-dispatch-pattern.md
@docs/runtime/office-roster.md
@docs/runtime/runtime-constants.md

### Operasyonel motorlar (moda göre yüklenir)
@docs/runtime/toolchain-precheck.md
@docs/runtime/intake-protocol.md
@docs/runtime/architecture-currency.md
@docs/runtime/localization-strategy.md
@docs/runtime/turkish-normalization.md
@docs/runtime/market-research-engine.md
@docs/runtime/sector-packs.md

### Yönetişim
@docs/governance/plugin-skill-decision.md
@docs/governance/rule-collision-matrix.md
@docs/governance/evidence-trust-scoring.md
@docs/governance/finding-schema.md
@docs/governance/trust-model.md
@docs/governance/surface-split.md
@docs/governance/product-surface-split.md
@docs/governance/hook-governance.md
@docs/governance/mcp-governance.md
@docs/governance/memory-hygiene.md
@docs/governance/prompt-supply-chain.md
@docs/governance/artefact-write-authorization.md
@docs/governance/rule-pack-governance.md
@docs/governance/settings-permissions-governance.md
@docs/governance/lock-file-hygiene.md
@docs/governance/secrets-rotation-policy.md
@docs/governance/observability-baseline.md
@docs/governance/ai-provider-allowlist.md
@docs/governance/pattern-import-ledger.md

### İçe aktarımlar Layer 1'dir (public runtime surface)
Bu dosyaların tümü `docs/governance/surface-split.md` tanımındaki **public runtime surface**'e aittir. Historical/version-diff notları bu listeye girmez; onlar hidden core'a aittir.

## Ana vaat
Sistem, projeye sıfırdan, ortadan veya final aşamasından girebilir. Her durumda:
- route eder,
- sistem haritasını çıkarır,
- evidence register yazar,
- research gerekiyorsa araştırır,
- findings, target-state ve roadmap üretir,
- pack-gap'leri ve validation gereksinimlerini söyler,
- doğrulama olmadan bitmiş saymaz.

## Çalışma zamanı altyapısı
- CLI orkestrasyon katmanı (`ulak` komutu)
- Proje hafızası (SQLite + FTS5)
- Vendor adapter soyutlaması (subprocess tabanlı)
- Pack versiyonlama ve güncelleme sistemi

## Proje durum seçimi
- GREENFIELD
- BROWNFIELD
- HYBRID

## Müdahale modları
- CREATE
- REPAIR
- EXTEND
- REFACTOR
- MIGRATE
- RESCUE
- REPACKAGE

## Zorunlu ayrımlar
- customer / admin / public API
- research / execution
- public runtime / hidden maintainer surface
- quick wins / foundational refactors / strategic migrations

## Derinlik zorunluluğu (v2.1 kuralı)

Inventory ve evidence fazları yüzeysel listeleme değildir. Bunlar zorunlu derin taramadır:

- **Inventory fazı** = cartographer seviyesinde tam harita. Route, komponent, API endpoint, env var, config, dependency, dead code, migration, secret referansı — hepsi **dosya yolu ve satır aralığıyla** listelenir. "ls dökümü" inventory sayılmaz; üretilirse reddedilir ve yeniden çalıştırılır.

- **Evidence fazı** = ilgili tüm uzman alt agent'ların **paralelde** çalıştırılması zorunludur. Tek bir generalist bakışıyla evidence toplanmaz. Security, SEO, i18n, infra-release, design-system, data-database, privacy-compliance, release-readiness, backend-api, architecture, red-team — hangisi projeye uyuyorsa hepsi aynı anda devreye girer.

- **Did-you-know kuralı**: Evidence-register ve analysis-findings sadece "sorulan" şeyi değil, kullanıcının **bilmediği** non-obvious bulguları da dökmek zorundadır. Örn: kullanılmayan import, eksik i18n key, yanlış cert fallback, N+1 risk, unused dependency, hardcoded string, RLS asimetrisi, eski migration. Bu bölüm boş veya trivial ise findings eksik kabul edilir.

- **Validation kapısı**: Deep scan eksikse manager-verdict "done" diyemez. Inventory yüzeysel ise **residual risk** olarak kaydedilir ve roadmap'e "derin inventory eksik" item'ı eklenir.

Çekirdek prensip: **"Manager katmanı ancak derin evidence üstünde kararlı plan verebilir."**

## Artefakt zinciri

Tüm artefaktların şeması: [`docs/runtime/artefact-contract.md`](../../docs/runtime/artefact-contract.md). Phase bazlı üretim sırası:

### Phase 0 — Ortam kilidi
- `runtime-manifest`
- `assumptions`

### Phase 1 — Derin envanter
- `intake`
- `inventory` (deep — dosya+satır bazlı, klasör dökümü değil)

### Phase 2 — Paralel uzman kanıtı
- `evidence-register`
- `deep-scan-report`

### Phase 3 — Sürpriz katmanı (zorunlu)
- `did-you-know` (opsiyonel dual-path validation ile güçlendirilebilir)

### Phase 4 — Sentez
- `research-notes` (koşullu — market-entry / architecture-currency modlarında)
- `analysis-findings`
- `target-state`
- `execution-roadmap` (Waves pattern ile yürütülür)
- `validation-plan`
- `pack-gap-register`

### Phase 4.5 — Canlı doğrulama (koşullu-zorunlu)
- `live-probe-results` (validation-plan §6'da ≥1 probe varsa zorunlu)

### Phase 5 — Yönetici kararı
- `manager-verdict`
