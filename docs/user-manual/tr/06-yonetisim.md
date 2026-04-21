# 06 — Yönetişim

> **v1.6 güncellemesi:** Governance katmanı **20 → 22 dosya**'ya (yeni: `vendor-capability-matrix.md`, `localization-governance.md`), ADR **6 → 7** (ADR-000 → ADR-005 + newer), runbook **3 → 4** oldu. Ek olarak Layer 1 yüzeyine **4 tutorial** (Supabase/Vercel/GitHub/Resend) ve **3 walkthrough** (first-SaaS × 3 vendor variant) katmanları eklendi. Beginner-glossary (47 term) artık governance ile paralel disiplin kuralı taşır.

Ulak OS'un "governance" (yönetişim) katmanı 22 dosyadan oluşur ve `docs/governance/` altında yaşar. Bu katman runtime rules ile çakışırsa **governance kazanır** (bkz. [rule-collision-matrix.md](../../governance/rule-collision-matrix.md)). Bu bölüm 22 dosyayı kategori kategori özetler, en sık kullanılan şemaları (trust tiers, finding schema, artefact authorization) açıklar, ve v1.6'da eklenen iki governance dosyasını + beginner-glossary disiplinini anlatır.

## Governance katmanının genişliği (v1.6)

| Kategori | Dosya / öğe |
|---|---|
| Governance docs | 22 (v1.6'da eklenenler: `vendor-capability-matrix.md`, `localization-governance.md`) |
| ADR | 7 (ADR-000 → ADR-005 + newer, bkz. `docs/adr/`) |
| Runbook | 4 (first-hour-with-ulak-os, install-methods, troubleshooting, upgrading-from-v2.x) |
| Tutorial (v1.6) | 4 (Supabase, Vercel, GitHub, Resend — `docs/tutorials/`) |
| Walkthrough (v1.6) | 3 (first-SaaS Claude / Codex / Copilot variant — `docs/walkthrough/`) |
| Beginner-glossary (v1.6) | 47 term (`docs/runtime/beginner-glossary.md`) |

Governance, runtime-rules + sector-packs + rule-packs katmanları üstüne oturur. Bir runtime dosyası governance ile çelişirse governance geçerlidir.

## Kategori 1 — Trust ve finding disiplini (4 dosya)

Bu grup, iddiaların (claim'lerin) nasıl kanıt taşıyacağını ve nasıl sınıflanacağını tanımlar.

- **[trust-model.md](../../governance/trust-model.md)** — Tool çıktıları veri olarak muamele görür, talimat değil. Bir agent'ın web'den okuduğu yazı her zaman "veri"dir.
- **[evidence-trust-scoring.md](../../governance/evidence-trust-scoring.md)** — T1–T7 trust tier'ları:
  - **T1** — Direct verified (komut çıktısı, test pass)
  - **T2** — Configuration-sourced (env var değeri, YAML'dan)
  - **T3** — Inferred from code (static analizden çıkarsama)
  - **T4** — Documented but unverified (README iddiası)
  - **T5** — Third-party claim (vendor docs)
  - **T6** — Experiential (önceki projeden anılan)
  - **T7** — Speculation / heuristic
- **[finding-schema.md](../../governance/finding-schema.md)** — Her claim için YAML şeması (`id`, `severity`, `priority`, `trust`, `surface`, `evidence`, `validation_method`, `remediation`).
- **[rule-collision-matrix.md](../../governance/rule-collision-matrix.md)** — İki dosya aynı konuda farklı şey derse hangisi galibiyeti kazanır tablosu.

**Temel kullanım:** Bir Critical / High finding T2 veya altında trust'sa, validation-plan §6'da o finding için bir **live probe** olmalıdır. Aksi takdirde signoff blocked olur.

## Kategori 2 — Surface split discipline (3 dosya)

Uygulamanın customer / admin / public-API / partner ayrımlarının nasıl korunacağı.

- **[surface-split.md](../../governance/surface-split.md)** — Public runtime surface vs hidden maintainer surface ayrımı (Layer 1 vs Layer 2).
- **[product-surface-split.md](../../governance/product-surface-split.md)** — Ürün içi surface ayrımı: customer UI, admin UI, partner/reseller API, public API.
- **[autonomy-pressure-layer.md](../../governance/autonomy-pressure-layer.md)** — Executive agent'ın alt-agent'lara ne kadar otonomi tanıyacağı.

## Kategori 3 — Artefact ve prompt supply chain (4 dosya)

- **[artefact-write-authorization.md](../../governance/artefact-write-authorization.md)** — Director protokolü `reports/current/**` altına yazma yetkisinin override metni.
- **[prompt-supply-chain.md](../../governance/prompt-supply-chain.md)** — Prompt içeriğinin hangi kaynaklardan gelebileceği, supply-chain saldırısı riski.
- **[memory-hygiene.md](../../governance/memory-hygiene.md)** — Claude'un long-lived memory'sini proje state'i için kullanma — her şey diske yazılır.
- **[hidden-maintainer-surface-template.md](../../governance/hidden-maintainer-surface-template.md)** — Layer 2 dosyaları için şablon.

## Kategori 4 — Secrets, lock files, permissions (4 dosya)

- **[secrets-rotation-policy.md](../../governance/secrets-rotation-policy.md)** — API key, database password, JWT secret rotasyon cadansları.
- **[lock-file-hygiene.md](../../governance/lock-file-hygiene.md)** — package-lock/pnpm/yarn/poetry lock file kural setleri.
- **[settings-permissions-governance.md](../../governance/settings-permissions-governance.md)** — `.claude/settings.json` izin/ret listeleri.
- **[ai-provider-allowlist.md](../../governance/ai-provider-allowlist.md)** — Hangi model sağlayıcılarına hangi surface'de güven.

## Kategori 5 — Hook ve MCP governance (2 dosya)

- **[hook-governance.md](../../governance/hook-governance.md)** — Pre-commit / pre-push / post-commit hook'ların Ulak disiplinini zorlaması, bypass token.
- **[mcp-governance.md](../../governance/mcp-governance.md)** — MCP connector allowlist enforcement (GitHub, Jira, Figma, Context7). Env var yoksa connector sessizce skip edilir.

## Kategori 6 — Observability ve release (2 dosya)

- **[observability-baseline.md](../../governance/observability-baseline.md)** — Her scaffold edilen projeye zorunlu metrics + log + tracing baseline'ı.
- **[rule-pack-governance.md](../../governance/rule-pack-governance.md)** — Rule pack'lerin nasıl üretileceği, bilingual parity, trust tier gereksinimleri.

## Kategori 7 — Pattern import ve plugin/skill decision (3 dosya)

- **[pattern-import-ledger.md](../../governance/pattern-import-ledger.md)** — Cross-project pattern absorbe kayıtları. Her kayıt ≥2 proje kanıtı + trust tier ≥ T2.
- **[plugin-skill-decision.md](../../governance/plugin-skill-decision.md)** — Yeni bir yetenek için command/skill/agent/hook karar ağacı.
- **[README.md](../../governance/README.md)** — Governance klasörünün indeksi.

## Kategori 8 — Vendor parity ve localization (2 dosya, v1.6'da eklendi)

- **[vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md)** — 4 vendor × 24 komut support matrisi. İki tabloyu sabitler: (A) primitive matrix — her vendor'ın sağladığı runtime primitiveler (file ops, bash, grep, subagent dispatch, skill, MCP); (B) command → vendor support matrix — 24 komutun hangi vendor'da `OK` / `PARTIAL` / `MISSING` / `N/A` olduğu + gerekçe. 8 kapasite kriteri ile vendor "FULL / FULL-MINUS / CORE / LIMITED" statüsü atar. `bash scripts/validate-vendor-parity.sh` her CI'da bu matrisi reconcile eder. Exemption olmayan gap CI'ı kırar.
- **[localization-governance.md](../../governance/localization-governance.md)** — TR/EN bilingual parity kuralları. Hangi dosyaların iki dilde de bulunması zorunlu, `/ulak-locale` state dosyasının nasıl davrandığı, README-first locale selection mantığı. `bash scripts/validate-bilingual.sh` her CI'da TR/EN parity'yi zorlar.

## Sık kullanılan şemalar

### Finding YAML şeması

```yaml
id: SEC-CU-03
severity: Critical           # Critical | High | Medium | Low | Cosmetic
priority: P1                 # P1..P4
trust: T2                    # T1..T7
surface: customer            # customer | admin | partner | public-api | infra
evidence:
  - path: src/api/auth.ts
    lines: 45-67
    detail: "JWT secret hardcoded in source"
validation_method:
  type: live-probe
  probe_id: AUTH-P1
remediation: |
  Move JWT_SECRET to env var; add gitleaks pattern;
  rotate existing secret in production.
```

Tam şema: [finding-schema.md](../../governance/finding-schema.md).

### Validation-result YAML şeması

```yaml
# reports/current/validation-result.yaml

run_id: 2026-04-21-director-001
signoff_status: conditional  # ready | conditional | blocked
phases:
  phase_0: { status: complete, artefacts: ["runtime-manifest.md","assumptions.md","active-variables.yaml"] }
  phase_1: { status: complete, artefacts: ["inventory.md"] }
  phase_2: { status: complete, artefacts: ["evidence-register.md","deep-scan-report.md"] }
  phase_3: { status: complete, artefacts: ["did-you-know.md"] }
  phase_4: { status: complete, artefacts: ["analysis-findings.md","target-state.md","execution-roadmap.md","validation-plan.md","pack-gap-register.md"] }
  phase_4_5: { status: partial, artefacts: ["live-probe-results.md"], blocked_probes: ["AUTH-P2"] }
  phase_5: { status: complete, artefacts: ["manager-verdict.md"] }
residual_risks:
  - id: SEC-CU-03
    reason: "live-probe AUTH-P2 credentials missing; operator to re-run"
    severity: Critical
next_action: "operator runs AUTH-P2 probe with production credentials"
```

Tam şema: [validation-result-schema.md](../../runtime/validation-result-schema.md).

### Router decision YAML

```yaml
# Phase 0'da active-variables.yaml içine pinlenir
project_state: BROWNFIELD     # GREENFIELD | BROWNFIELD | HYBRID
intervention_mode: REPAIR     # CREATE | REPAIR | EXTEND | REFACTOR | MIGRATE | RESCUE | REPACKAGE
output_profile: AUDIT         # 7 profilden biri
output_language: tr           # tr | en
scope: full                   # full | focused | smoke
live_probe_required: true
dispatch_mode: parallel       # parallel | serial
validation_depth: deep        # deep | standard | light
persona_set: [customer, admin, partner]
```

Tam şema: [router.md](../../runtime/router.md).

## Hook governance — bypass token

Pre-commit hook'lar Ulak OS disiplinini zorlar. Geçici atlatma gerekiyorsa:

```bash
export ULAK_BYPASS_TOKEN=$(ulak bypass --duration 15m --reason "wip debugging")
git commit -m "wip: ..."
```

Token kullanımı audit log'a düşer. Detay: [hook-governance.md](../../governance/hook-governance.md).

## MCP governance — allowlist enforcement

```yaml
allowed_mcps:
  - github          # zorunlu env: GITHUB_TOKEN
  - jira            # opsiyonel env: JIRA_API_TOKEN
  - figma           # opsiyonel env: FIGMA_TOKEN
  - filesystem      # local, env gerektirmez
  - context7        # docs fetching

blocked_mcps:
  - "*:cloud-shell"
  - "*:db-write"
```

`/ulak-mcp-discover` komutu community MCP server'ları trust tier'a göre sınıflandırır; operatör manuel allowlist güncellemesi yapar.

## Vendor-capability-matrix — 8 kapasite kriteri (v1.6)

Bir vendor "Ulak OS full runtime" sayılabilmesi için şu 8 kapasiteyi sağlamalı:

1. File Read + Grep + Glob
2. File Write veya Edit
3. Bash/shell execute
4. Multi-turn session memory (context file)
5. MCP veya equivalent external service integration
6. Skill/named-capability invocation (veya NL equivalent)
7. Slash command dispatch (veya reading-order NL equivalent)
8. Settings-level permission governance

| Vendor | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | Statü |
|---|---|---|---|---|---|---|---|---|---|
| Claude Code | Y | Y | Y | Y | Y | Y | Y | Y | **FULL** |
| Gemini CLI | Y | Y | P | Y | Y | P | Y | P | **FULL-MINUS** |
| Codex CLI | Y | Y | Y | Y | Y | N | N | N | **CORE** |
| Copilot Chat | Y | P | P | P | N | N | N | N | **LIMITED** |

Exemption olmayan gap CI'ı kırar (DY-03 vendor-parity silent-drift finding). Detay: [vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md).

## Localization-governance — bilingual disiplin (v1.6)

Ulak OS TR-first veya EN-first çalışabilir. `localization-governance.md` aşağıdaki kuralları sabitler:

- **Bilingual zorunluluk:** `docs/user-manual/{tr,en}/`, `docs/walkthrough/`, `docs/tutorials/`, `docs/runbooks/`, README dosyaları TR + EN paritede tutulur.
- **Locale state:** `/ulak-locale` komutu `.claude/state/locale.txt`'yi günceller. README ilk satırı bu dosyaya bakarak TR-first veya EN-first render edilir.
- **CI enforcement:** `bash scripts/validate-bilingual.sh` her PR'da iki dilin line-count delta'sı + heading parity'si + cross-link'leri kontrol eder. Parity kaybında CI red.
- **Beginner-glossary:** 47 term TR + EN kabul eder (alias tablosu); case-insensitive lookup.

## Secrets rotation policy — özet

| Secret kategorisi | Rotation cadansı | Yöntem |
|---|---|---|
| JWT signing secret | 90 gün | key versioning; grace period |
| Database password | 180 gün | rolling credential |
| Third-party API key | 365 gün | vendor-specific rotation |
| SSH deploy key | 180 gün | rolling |
| Gitleaks baseline hash | her yeni release | auto-regenerate in CI |

Detay: [secrets-rotation-policy.md](../../governance/secrets-rotation-policy.md).

## Pattern-import-ledger

Cross-project pattern kayıtları minimum T2 ve ≥2 kaynak kanıtı gerektirir:

```yaml
- id: SP-11
  kind: sector-pack
  source_projects:
    - descriptor: "Türkçe-birincil bir SaaS"
    - descriptor: "bir e-ticaret platformu"
  source_files:
    - project_a/payments/fsm.ts:1-200
    - project_b/checkout/handler.ts:45-150
  trust_tier: T2
  abstracted_to: docs/runtime/rule-packs/transactional-fsm-payment.md
```

Kayıt olmadan anti-pattern veya sector pack eklenemez — CI `validate-schemas.sh` pattern-import-ledger disiplinini uygular.

## Rule-pack governance

Yeni bir rule pack:

1. ≥2 proje kanıtı ile evidence
2. Bilingual (TR + EN) doküman (validate-bilingual.sh geçmeli)
3. Trust tier ≥ T2
4. `docs/runtime/rule-packs/<pack>.md` dosyası
5. `pattern-import-ledger.md`'ye kayıt
6. `validate-schemas.sh` geçer
7. ADR gerekiyorsa `docs/adr/` altında

Detay: [rule-pack-governance.md](../../governance/rule-pack-governance.md).

## Yönetişim — ilk oturumda yapılacaklar

Proje devraldığınızda veya yeni başladığınızda:

1. `docs/governance/README.md` indeksini oku (10 dakika)
2. `surface-split.md` + `product-surface-split.md` — ürününüzün surface'lerini anlayın
3. `finding-schema.md` — denetim raporu okurken hangi alanlara bakacağınızı öğrenin
4. `evidence-trust-scoring.md` — T1–T7 tier'larını ezberleyin
5. `vendor-capability-matrix.md` — hangi vendor'da neyi kullanabileceğinizi bilin
6. `localization-governance.md` — TR/EN parity yönergelerini görün
7. `secrets-rotation-policy.md` — mevcut projenin rotation uyumunu kontrol edin
8. `pattern-import-ledger.md` — zaten hangi pattern'lerin import edildiğini görün

## İlgili belgeler

- [docs/governance/README.md](../../governance/README.md) — 22 dosyalık governance indeksi
- [docs/runtime/validation-result-schema.md](../../runtime/validation-result-schema.md) — Phase 5 signoff şeması
- [docs/runtime/router.md](../../runtime/router.md) — Phase 0 router decision şeması
- [docs/adr/](../../adr/) — 7 ADR (ADR-000 → ADR-005 + newer)
- [docs/runtime/beginner-glossary.md](../../runtime/beginner-glossary.md) — 47 temel terim

Sonraki bölüm: [07 — Katkı](./07-katki.md)
