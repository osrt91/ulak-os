# 07 — Katkı

Ulak OS MIT lisanslı, açık bir pakettir ve katkıya açıktır. Bu bölüm yeni bir sector pack, rule pack, runtime rule, anti-pattern, agent, command veya skill önerirken uymanız gereken süreci özetler. Tam detay: [CONTRIBUTING.md](../../../CONTRIBUTING.md).

## Hangi katkı türüne açık?

| Katkı türü | Gereksinimler | Örnek |
|---|---|---|
| **Sector pack** | ≥2 proje kanıtı + T2 tier + pattern-import-ledger kaydı | `saas`, `ecommerce`, `fintech`, `content-ops` |
| **Rule pack** | ≥2 proje kanıtı + T2 tier + bilingual doc | `nextjs-app-router`, `react-native-expo`, `api-security` |
| **Runtime rule** | Core contract ile uyumlu + ADR gerekiyorsa | `live-probe-contract`, `waves-pattern` |
| **Anti-pattern** | ≥2 proje'de görülmüş + T2 tier + remediation yazılı | AP-NN numaralı giriş |
| **Agent** | Net persona + dispatch örneği + sorumluluk sınırı | `security-hardening-lead`, `cartographer` |
| **Command** | Net senaryo + phase mapping + vendor-parity checklist | `/director`, `/ulak-scaffold` |
| **Skill** | Tekrarlanabilir prosedür + agent context içinde çalışır | `saas-scaffolder`, `pack-gap-completion` |
| **Governance doc** | Core contract ile çakışma kontrolü | `hook-governance`, `mcp-governance` |

Yeni bir katkı türü önermek istiyorsanız önce issue açın — "Feature proposal: <başlık>" etiketi ile.

## Pattern contribution kuralı

Her cross-project pattern lift aşağıdaki zorunlulukları taşır:

1. **≥2 gerçek proje kanıtı.** Eğer projeler private ise abstract descriptor'lar (ör. "Türkçe-birincil bir SaaS", "bir e-ticaret platformu") kullanılabilir; dosya yolu ve satır numaraları gerçek olmalı.
2. **Trust tier ≥ T2.** T3 (inferred) veya altı kabul edilmez.
3. **`docs/governance/pattern-import-ledger.md`'ye entry.** YAML format:

```yaml
- id: AP-NN                    # anti-pattern veya SP-NN sector-pack için
  source_projects:
    - descriptor: "abstract project type 1"
    - descriptor: "abstract project type 2"
  source_files:
    - path/to/file1.ts:45-67
    - path/to/file2.py:120-150
  trust_tier: T2
  rationale: |
    Pattern neyi çözüyor? Neden ≥2 projede aynı şekilde çıkmış?
  abstracted_to: docs/runtime/anti-patterns.md
```

4. **Bilingual doc.** Türkçe ve İngilizce sürümler aynı PR içinde olmalı.
5. **Schema validation geçer.** `bash scripts/validate-schemas.sh` yeşil olmalı.

## PR süreci

### 1. Issue açın

Repo: https://github.com/osrt91/ulak-os

PR'ı doğrudan açmadan önce bir tracking issue açmanız tercih edilir. Issue şablonları:

- **Feature proposal** — yeni bir unit type veya ciddi değişiklik
- **Pattern contribution** — bir sector/rule pack veya anti-pattern ekleme
- **Bug fix** — mevcut davranıştaki hata
- **Docs improvement** — dokümantasyon düzeltmesi

Issue içinde belirtin:
- Amaç (bir cümle)
- Kanıt (proje sayısı, dosya yolu ile)
- Tahmini PR büyüklüğü (küçük / orta / büyük)

### 2. Fork + branch + değişiklik

```bash
# Fork Ulak OS reposunu Github'da
git clone https://github.com/<your-user>/ulak-os.git
cd ulak-os
git checkout -b feat/<descriptive-slug>

# Değişikliğinizi yapın
# ...

# Validator'ları koşturun
bash scripts/validate-imports.sh
bash scripts/validate-schemas.sh
bash scripts/validate-vendor-parity.sh
```

### 3. Commit disiplin

Commit mesajları conventional commits formatında:

```
feat(rule-pack): add next-app-router rule pack (AP-15)

- Evidence from 2 SaaS projects
- Trust tier T2
- Bilingual doc
```

```
fix(governance): correct broken @-import in finding-schema.md
```

```
chore(docs): update user-manual EN section 04
```

### 4. PR açın

PR template'i otomatik yüklenir. Doldurulması gereken başlıklar:

- **Summary** — 1-2 cümle
- **Evidence** — hangi proje(ler)den, hangi dosyalardan alındı
- **Trust tier** — T1 / T2 / ...
- **Bilingual parity** — TR + EN ikisi de güncellendi mi?
- **CI green** — tüm validator'lar yeşil mi?
- **ADR gerekli mi?** — eğer contract-level bir değişiklikse ADR dosyası eklenmeli

### 5. Review

Reviewerların bakacağı başlıklar:

- Pattern-import-ledger entry var mı?
- Trust tier gerçekten T2 veya üstü mü?
- Bilingual doc parity korundu mu?
- Validator'lar yeşil mi?
- Rule-collision-matrix ile çakışma yok mu?
- Surface-split bozulmadı mı?

## ADR gerektiren değişiklikler

Bazı değişiklikler Architecture Decision Record (mimari karar kaydı) gerektirir:

- Core contract seviyesinde bir promise eklenmesi veya kaldırılması
- Yeni bir phase (Phase 6, Phase 7 vb.) eklenmesi
- Bir default davranışın değiştirilmesi (ör. `dispatch_mode: parallel` → `serial`)
- Yeni bir pack-unit tipi (7 → 8)
- Breaking schema changes (plugin.json, validation-result.yaml)

ADR dosyası `docs/adr/ADR-NNN-<slug>.md` formatında. Şablon: [docs/adr/README.md](../../adr/README.md).

## Code of conduct

Projenin davranış kuralları `CODE_OF_CONDUCT.md` dosyasındadır (Contributor Covenant 2.1 bazlı). Kısa özet: saygılı olun, teknik tartışmayı kişiselleştirmeyin, issue'larda minimum reproduction isteyin, review sürecinde açık geri bildirim verin.

Rapor edilmesi gereken bir ihlal durumunda: projenin maintainer'ına e-posta ile yazın. Adres `CODE_OF_CONDUCT.md` içindedir.

## Security issue bildirme

**Güvenlik açığı için public GitHub issue AÇMAYIN.**

Doğru süreç:

1. E-posta ile iletişim: `info@oguzhansert.dev` (operator bilgisi)
2. Subject: `[security] Ulak OS: <kısa başlık>`
3. Body:
   - Açığın kısa tanımı
   - Reproduction steps
   - Etkilenen dosya(lar) ve satır(lar)
   - Önerilen fix (varsa)
4. 72 saat içinde yanıt bekleyin

Açığın duyurulması koordineli şekilde yapılır: fix merge olduktan sonra advisory GitHub Security Advisories üzerinden açılır, reporter credit ile.

## Katkı örnek senaryoları

### Senaryo A — Yeni bir anti-pattern önermek

İki projede gördüğünüz bir anti-pattern var: "webhook handler sessiz retry yapıyor ama idempotency key yok, duplicate charge'a düşüyor."

1. Issue aç: "Propose AP-NN: Webhook retry without idempotency"
2. PR'da ekle:
   - `docs/runtime/anti-patterns.md`'ye entry
   - `docs/governance/pattern-import-ledger.md`'ye kayıt
   - Bilingual doc (TR + EN)
3. Validator'ları koştur
4. PR aç

### Senaryo B — Yeni bir rule pack önermek

FastAPI + async SQLAlchemy için kural paketi yazmak istiyorsunuz.

1. Issue aç: "Propose rule pack: fastapi-async"
2. PR'da ekle:
   - `docs/runtime/rule-packs/fastapi-async.md` (+ `.en.md`)
   - Pattern-import-ledger entry
   - ≥2 proje kanıtı abstract descriptor ile
3. ADR gerekiyorsa `docs/adr/ADR-NNN-fastapi-async-rule-pack.md`
4. PR aç

### Senaryo C — Kritik bir hata fix'i

`validate-imports.sh` bir edge case'i yakalamıyor.

1. Issue aç (optional — küçük fix için skip edilebilir)
2. Fix + test ekle
3. Commit: `fix(scripts): validate-imports now catches circular deps at depth 4+`
4. PR aç

## Katkı yapmadan önce

- Mevcut issue'ları tarayın — benzer bir öneri zaten var mı?
- Mevcut rule pack / sector pack'leri inceleyin — yeniden icat etmiyor olun
- Core contract'ı okuyun (`prompts/core/ulak-os-core-contract-2.0.0.md`) — önerilen değişiklik çekirdeği bozmuyor olmalı

## İlgili belgeler

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — ana contribution guide
- [CODE_OF_CONDUCT.md](../../../CODE_OF_CONDUCT.md) — davranış kuralları
- [docs/governance/pattern-import-ledger.md](../../governance/pattern-import-ledger.md) — mevcut pattern kayıtları
- [docs/adr/README.md](../../adr/README.md) — ADR şablonu ve mevcut kararlar
- [docs/governance/rule-pack-governance.md](../../governance/rule-pack-governance.md) — rule pack kuralları

Sonraki bölüm: [08 — Sorun giderme](./08-sorun-giderme.md)
