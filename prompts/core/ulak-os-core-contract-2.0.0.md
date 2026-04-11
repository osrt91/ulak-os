# Ulak OS Core Contract 2.0.0

Bu dosya vendor-agnostic çekirdektir.

## Ana vaat
Sistem, projeye sıfırdan, ortadan veya final aşamasından girebilir. Her durumda:
- route eder,
- sistem haritasını çıkarır,
- evidence register yazar,
- research gerekiyorsa araştırır,
- findings, target-state ve roadmap üretir,
- pack-gap'leri ve validation gereksinimlerini söyler,
- doğrulama olmadan bitmiş saymaz.

## v2 eklentileri
- CLI orkestrasyon katmanı (`ulak` komutu)
- Proje hafızası (SQLite + FTS5)
- Vendor adapter soyutlaması (subprocess tabanlı)
- Pack versiyonlama ve güncelleme sistemi

## Project state switch
- GREENFIELD
- BROWNFIELD
- HYBRID

## Intervention modes
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
- runtime-manifest
- assumptions
- intake
- inventory (deep — dosya+satır bazlı, klasör dökümü değil)
- evidence-register (paralel uzman bulguları)
- deep-scan-report (cartographer + specialist merge)
- did-you-know (non-obvious findings, zorunlu)
- research-notes
- analysis-findings
- target-state
- execution-roadmap
- validation-plan
- pack-gap-register
- manager-verdict
