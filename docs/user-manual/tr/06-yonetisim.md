# 06 — Yönetişim

Ulak OS'un "governance" (yönetişim) katmanı 22 dosyadan oluşur ve `docs/governance/` altında yaşar. Bu katman runtime rules ile çakışırsa **governance kazanır** (bkz. [rule-collision-matrix.md](../../governance/rule-collision-matrix.md)). Bu bölüm 22 dosyayı kategori kategori özetler, en sık kullanılan şemaları (trust tiers, finding schema, artefact authorization) açıklar.

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

- **[surface-split.md](../../governance/surface-split.md)** — Public runtime surface vs hidden maintainer surface ayrımı (Layer 1 vs Layer 2). Hidden core, public runtime'a sızmamalıdır.
- **[product-surface-split.md](../../governance/product-surface-split.md)** — Ürün içi surface ayrımı: customer UI, admin UI, partner/reseller API, public API. Bir handler birden fazla surface'e bakarsa finding üretilir.
- **[autonomy-pressure-layer.md](../../governance/autonomy-pressure-layer.md)** — Executive agent'ın alt-agent'lara ne kadar otonomi tanıyacağı, hangi durumda operatöre geri dönüleceği.

## Kategori 3 — Artefact ve prompt supply chain (4 dosya)

Agent'ın diske ne zaman yazabileceği, prompt zincirinin nasıl güvence altına alınacağı.

- **[artefact-write-authorization.md](../../governance/artefact-write-authorization.md)** — Default Claude Code prompt kuralı "planning doc yazma" der. Director protokolü `reports/current/**` altına yazma yetkisini override eder. Bu dosya o override'ın metnini taşır; her specialist brief'ine override-block eklenir.
- **[prompt-supply-chain.md](../../governance/prompt-supply-chain.md)** — Prompt içeriğinin hangi kaynaklardan gelebileceği, hangilerinin supply-chain saldırısı riski taşıdığı.
- **[memory-hygiene.md](../../governance/memory-hygiene.md)** — Claude'un long-lived memory'sini proje state'i için kullanma — her şey diske yazılır (reports/current/, repo source tree).
- **[hidden-maintainer-surface-template.md](../../governance/hidden-maintainer-surface-template.md)** — Layer 2 dosyaları için şablon: hangi frontmatter field'ları olacak, hangi uyarılar eklenecek.

## Kategori 4 — Secrets, lock files, permissions (4 dosya)

- **[secrets-rotation-policy.md](../../governance/secrets-rotation-policy.md)** — API key, database password, JWT secret'larının rotasyon cadansı, `.env.example` disiplin'i.
- **[lock-file-hygiene.md](../../governance/lock-file-hygiene.md)** — `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `poetry.lock` kural setleri; kırık lock file auto-detect.
- **[settings-permissions-governance.md](../../governance/settings-permissions-governance.md)** — `.claude/settings.json` için izin / ret listeleri; `settings.local.json` override kuralları.
- **[ai-provider-allowlist.md](../../governance/ai-provider-allowlist.md)** — Hangi model sağlayıcılarına hangi surface'de güven verilir.

## Kategori 5 — Hook ve MCP governance (2 dosya)

- **[hook-governance.md](../../governance/hook-governance.md)** — Pre-commit / pre-push / post-commit hook'ların Ulak OS disiplini nasıl zorladığı, bypass token kullanımı (development sırasında geçici atlatma), token rotation.
- **[mcp-governance.md](../../governance/mcp-governance.md)** — Model Context Protocol connector'larının allowlist enforcement'ı (GitHub, Jira, Figma). Env var yoksa connector sessizce skip edilir; allowlist dışında bir connector hata verir.

## Kategori 6 — Observability ve release (2 dosya)

- **[observability-baseline.md](../../governance/observability-baseline.md)** — Her scaffold edilen projeye zorunlu metrics + log + tracing baseline'ı.
- **[rule-pack-governance.md](../../governance/rule-pack-governance.md)** — Rule pack'lerin (7. unit type) nasıl üretileceği, bilingual parity, trust tier gereksinimleri.

## Kategori 7 — Pattern import ve plugin/skill decision (3 dosya)

- **[pattern-import-ledger.md](../../governance/pattern-import-ledger.md)** — Cross-project pattern absorbe kayıtları. Her kayıt ≥2 proje kanıtı + trust tier ≥ T2 gerektirir.
- **[plugin-skill-decision.md](../../governance/plugin-skill-decision.md)** — Yeni bir yetenek için command mi, skill mi, agent mi, hook mi üretileceği karar ağacı.
- **[README.md](../../governance/README.md)** — Governance klasörünün indeksi.

## Sık kullanılan şemalar

### Finding YAML şeması

```yaml
id: SEC-CU-03
severity: Critical           # Critical | High | Medium | Low | Cosmetic
priority: P1                 # P1..P4 (eyleme geçilme sırası)
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

Tam şema ve örnekler: [finding-schema.md](../../governance/finding-schema.md).

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

Pre-commit hook'lar Ulak OS disiplinini zorlar: örn. `reports/current/` altındaki finding-schema YAML'ı geçerli değilse commit reddedilir. Bir development oturumunda geçici atlatma gerekiyorsa:

```bash
# 15 dakika süreli bypass token:
export ULAK_BYPASS_TOKEN=$(ulak bypass --duration 15m --reason "wip debugging")
git commit -m "wip: ..."
# Token süresi dolunca hook yine aktif.
```

Token kullanımı audit log'a düşer. Production branch'e merge sırasında bypass sayısı checked olur. Detay: [hook-governance.md](../../governance/hook-governance.md).

## MCP governance — allowlist enforcement

```yaml
# docs/governance/mcp-governance.md içinden alıntı
allowed_mcps:
  - github         # zorunlu env: GITHUB_TOKEN
  - jira           # opsiyonel env: JIRA_API_TOKEN
  - figma          # opsiyonel env: FIGMA_TOKEN
  - filesystem     # local, env gerektirmez
  - context7       # docs fetching

blocked_mcps:
  - "*:cloud-shell"      # rastgele cloud shell'lere bağlanamaz
  - "*:db-write"         # DB write MCP'leri manuel whitelist ister
```

Env var yoksa MCP sessizce skip edilir; allowlist dışı bir MCP çağrısı hata verir.

## Secrets rotation policy — özet

| Secret kategorisi | Rotation cadansı | Yöntem |
|---|---|---|
| JWT signing secret | 90 gün | key versioning; grace period |
| Database password | 180 gün | rolling credential |
| Third-party API key | 365 gün | vendor-specific rotation |
| SSH deploy key | 180 gün | rolling |
| Gitleaks baseline hash | her yeni release | auto-regenerate in CI |

Detay: [secrets-rotation-policy.md](../../governance/secrets-rotation-policy.md).

## Pattern-import-ledger (7. unit type — cross-project absorption)

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

Kayıt olmadan bir anti-pattern veya sector pack eklenemez — CI `validate-schemas.sh` pattern-import-ledger disiplinini uygular. Detay: [pattern-import-ledger.md](../../governance/pattern-import-ledger.md).

## Rule-pack governance (7. unit type)

Rule pack, bir teknolojiye özgü kuralların paketi (Next.js, FastAPI, React Native, API Security vb.). Yeni bir rule pack:

1. ≥2 proje kanıtı ile evidence
2. Bilingual (TR + EN) doküman
3. Trust tier ≥ T2
4. `docs/runtime/rule-packs/<pack>.md` dosyası
5. `pattern-import-ledger.md`'ye kayıt
6. `validate-schemas.sh` geçer
7. ADR (Architecture Decision Record) gerekiyorsa `docs/adr/` altında

Detay: [rule-pack-governance.md](../../governance/rule-pack-governance.md).

## Yönetişim — ilk oturumda yapılacaklar

Proje devraldığınızda veya yeni başladığınızda:

1. `docs/governance/README.md` indeksini oku (10 dakika)
2. `surface-split.md` + `product-surface-split.md` — ürününüzün surface'lerini anlayın
3. `finding-schema.md` — denetim raporu okurken hangi alanlara bakacağınızı öğrenin
4. `evidence-trust-scoring.md` — T1–T7 tier'larını ezberleyin
5. `secrets-rotation-policy.md` — mevcut projenin rotation uyumunu kontrol edin
6. `pattern-import-ledger.md` — zaten hangi pattern'lerin import edildiğini görün

## İlgili belgeler

- [docs/governance/README.md](../../governance/README.md) — 22 dosyalık governance indeksi
- [docs/runtime/validation-result-schema.md](../../runtime/validation-result-schema.md) — Phase 5 signoff şeması
- [docs/runtime/router.md](../../runtime/router.md) — Phase 0 router decision şeması

Sonraki bölüm: [07 — Katkı](./07-katki.md)
