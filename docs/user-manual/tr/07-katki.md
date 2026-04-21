# 07 — Katkı

> **v1.6 güncellemesi:** Yeni komut eklenirken **4 vendor parity disiplini** + **`sync-gemini-commands.sh` senkron adımı** + **`validate-bilingual.sh` enforcement'ı** zorunlu hale geldi. Beginner-glossary entry'leri de bilingual parity kapsamındadır.

Ulak OS MIT lisanslı, açık bir pakettir ve katkıya açıktır. Bu bölüm yeni bir sector pack, rule pack, runtime rule, anti-pattern, agent, command, skill veya governance dosyası önerirken uymanız gereken süreci özetler. Tam detay: [CONTRIBUTING.md](../../../CONTRIBUTING.md).

## Hangi katkı türüne açık?

| Katkı türü | Gereksinimler | Örnek |
|---|---|---|
| **Sector pack** | ≥2 proje kanıtı + T2 tier + pattern-import-ledger kaydı + bilingual | `saas`, `ecommerce`, `fintech`, `content-ops`, `lms` |
| **Sector overlay** | Bir sector pack üstüne yan-domain, ≥2 proje kanıtı | `multi-tenant` × `saas`, `turkish-locale` × `ecommerce` |
| **Rule pack** | ≥2 proje kanıtı + T2 tier + bilingual doc | `typescript-nextjs`, `python-fastapi`, `react-native-expo`, `api-security` |
| **Runtime rule** | Core contract ile uyumlu + ADR gerekiyorsa | `live-probe-contract`, `waves-pattern`, `transactional-fsm-payment` |
| **Anti-pattern** | ≥2 proje'de görülmüş + T2 tier + remediation yazılı | AP-NN numaralı giriş |
| **Agent** | Net persona + dispatch örneği + sorumluluk sınırı | `security-hardening-lead`, `cartographer` |
| **Command** | Net senaryo + phase mapping + 4 vendor parity checklist | `/director`, `/ulak-scaffold`, `/ulak-start` |
| **Skill** | Tekrarlanabilir prosedür + agent context içinde çalışır | `saas-scaffolder`, `pack-gap-completion` |
| **Governance doc** | Core contract ile çakışma kontrolü | `vendor-capability-matrix`, `localization-governance`, `hook-governance` |
| **Tutorial** | Tek servis derin anlatım + bilingual + screenshot-free, copy-paste | `supabase.md`, `vercel.md`, `github.md`, `resend.md` |
| **Walkthrough** | Uçtan uca senaryo + ≥4 servis + bilingual + vendor variant'ları | `01-first-saas-end-to-end.md` (+ Codex + Copilot) |
| **Beginner-glossary entry** | 5 alanlı şema + TR/EN alias + bilingual | `rls`, `supabase`, `jwt` gibi 47 mevcut term |

Yeni bir katkı türü önermek istiyorsanız önce issue açın — "Feature proposal: <başlık>" etiketi ile.

## Yeni komut eklerken — 4 vendor parity disiplini

v1.6 ile Ulak OS 4 vendor'a (Claude / Gemini / Codex / Copilot) parity disiplinini CI'da zorlar. Yeni bir `/ulak-<command>` komutu eklerken:

### 1) Claude Code native dosyası

```bash
.claude/commands/<new-command>.md
```

Frontmatter: `name`, `description`, `argument-hint` (opsiyonel). Body: talimat metni.

### 2) Gemini senkronu

```bash
bash scripts/sync-gemini-commands.sh
```

Bu script `.claude/commands/*.md`'den `.gemini/commands/*.toml` türevlerini üretir. Her yeni komut eklendiğinde koşturulmalı; koşmazsa Gemini'de komut MISS görünür ve `validate-vendor-parity.sh` CI'da red eder.

### 3) Codex + Copilot NL trigger map

Yeni komut Codex/Copilot'ta native slash ile değil, NL trigger map üzerinden çağrılır. Adapter dosyalarına ekleyin:

- [docs/adapters/codex-cli.md](../../adapters/codex-cli.md) → "NL trigger map" bölümüne NL fraz ↔ komut eşlemesi
- [docs/adapters/copilot-chat.md](../../adapters/copilot-chat.md) → aynı

Eğer komut Codex veya Copilot'ta desteklenmeyecekse (ör. MCP bağımlı):

- `.github/vendor-parity-exemptions.txt`'e `<vendor>:<command>` satırı + gerekçe (naming drift, MCP dependency, v1.x deferred)
- [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md) Tablo B.1'e ilgili hücreyi `MISSING` yap + gerekçe kolonunu doldur

### 4) `validate-vendor-parity.sh`

```bash
bash scripts/validate-vendor-parity.sh
```

OK dönmeli. Exemption olmayan gap CI'ı kırar (DY-03 vendor-parity silent-drift finding).

### 5) Tabloya ekle

[04-Komutlar](./04-komutlar.md) tabloları + [docs/catalog.md](../../catalog.md) (`/ulak-packs` kaynağı) güncellenmeli.

### 6) Bilingual parity

Komut açıklamasının TR ve EN karşılıkları olmalı. `docs/user-manual/tr/04-komutlar.md` ve `docs/user-manual/en/04-commands.md` aynı PR'da güncellenir. `bash scripts/validate-bilingual.sh` geçmeli.

## Pattern contribution kuralı

Her cross-project pattern lift aşağıdaki zorunlulukları taşır:

1. **≥2 gerçek proje kanıtı.** Eğer projeler private ise abstract descriptor'lar (ör. "Türkçe-birincil bir SaaS", "bir e-ticaret platformu") kullanılabilir; dosya yolu ve satır numaraları gerçek olmalı.
2. **Trust tier ≥ T2.** T3 (inferred) veya altı kabul edilmez.
3. **`docs/governance/pattern-import-ledger.md`'ye entry.** YAML format:

```yaml
- id: AP-NN
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

4. **Bilingual doc.** TR + EN sürümler aynı PR'da; `validate-bilingual.sh` geçmeli.
5. **Schema validation geçer.** `bash scripts/validate-schemas.sh` yeşil olmalı.

`/ulak-pattern-extract` komutu bu adımları interaktif yürütebilir — sonuçta hâlâ manuel review + commit gerekir.

## Bilingual parity disiplini — `validate-bilingual.sh`

v1.6 ile bilingual parity CI'da zorlanır. Kontrol kapsamı:

- TR ve EN user-manual dosyaları 1-1 eşleşir (01-giris.md ↔ 01-intro.md gibi)
- Heading yapısı iki tarafta da paralel (`# 01 — Giris` ↔ `# 01 — Intro`)
- Cross-link'ler iki yönde de çalışır
- Line-count delta'sı makul aralıkta (±30%)

Yeni bir user-manual/walkthrough/tutorial/runbook/glossary entry eklenince her iki dil için dosya hazırlamadan PR merge edilmez.

Komutların description'larının TR/EN paritesi `.claude/commands/*.md` frontmatter'larında tutulur; governance bu dosyalara da parity uygular.

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
- Vendor parity planı (yeni komut ise 4 vendor'da ne olacak?)
- Tahmini PR büyüklüğü (küçük / orta / büyük)

### 2. Fork + branch + değişiklik

```bash
git clone https://github.com/<your-user>/ulak-os.git
cd ulak-os
git checkout -b feat/<descriptive-slug>

# Değişikliğinizi yapın
# Yeni komut eklediyseniz:
bash scripts/sync-gemini-commands.sh

# Validator'ları koşturun:
bash scripts/validate-imports.sh
bash scripts/validate-schemas.sh
bash scripts/validate-vendor-parity.sh
bash scripts/validate-bilingual.sh
```

### 3. Commit disiplin

Commit mesajları conventional commits formatında:

```
feat(commands): add /ulak-<new> natural-language entry

- Adds .claude/commands/ulak-new.md
- Syncs .gemini/commands/ulak-new.toml via sync-gemini-commands.sh
- Wires NL trigger map in codex-cli.md + copilot-chat.md
- Updates vendor-capability-matrix.md Table B.1
- Bilingual description parity (TR + EN)
```

```
feat(rule-pack): add typescript-nextjs rule pack (AP-15)

- Evidence from 2 SaaS projects
- Trust tier T2
- Bilingual doc + pattern-import-ledger entry
```

### 4. PR açın

PR template'i otomatik yüklenir. Doldurulması gereken başlıklar:

- **Summary** — 1-2 cümle
- **Evidence** — hangi proje(ler)den, hangi dosyalardan alındı
- **Trust tier** — T1 / T2 / ...
- **Bilingual parity** — TR + EN ikisi de güncellendi mi?
- **Vendor parity** — 4 vendor matrisine ne etki? exemption gerekli mi?
- **CI green** — 4 validator (`validate-imports`, `validate-schemas`, `validate-vendor-parity`, `validate-bilingual`) yeşil mi?
- **ADR gerekli mi?**

### 5. Review

Reviewerların bakacağı başlıklar:

- Pattern-import-ledger entry var mı?
- Trust tier gerçekten T2 veya üstü mü?
- Bilingual doc parity korundu mu?
- Vendor parity matrisi güncellendi mi? (yeni komut ise)
- `sync-gemini-commands.sh` koşuldu mu?
- 4 validator yeşil mi?
- Rule-collision-matrix ile çakışma yok mu?
- Surface-split bozulmadı mı?

## ADR gerektiren değişiklikler

Bazı değişiklikler Architecture Decision Record (mimari karar kaydı) gerektirir:

- Core contract seviyesinde bir promise eklenmesi veya kaldırılması
- Yeni bir phase (Phase 6, Phase 7) eklenmesi
- Bir default davranışın değiştirilmesi (ör. `dispatch_mode: parallel` → `serial`)
- Yeni bir pack-unit tipi (7 → 8)
- Yeni vendor eklenmesi (4 → 5)
- Breaking schema changes (plugin.json, validation-result.yaml)

ADR dosyası `docs/adr/ADR-NNN-<slug>.md` formatında. Şablon: [docs/adr/README.md](../../adr/README.md). Mevcut ADR'lar: ADR-000 (pack-foundation), ADR-001 (rule-packs-seventh-unit-type), ADR-002 (phase-5-terminal), ADR-003 (product-surface-split-vs-runtime), ADR-004 (pattern-import-ledger), ADR-005 (saas-scaffolder).

## Code of conduct

Projenin davranış kuralları `CODE_OF_CONDUCT.md` dosyasındadır. Saygılı olun, teknik tartışmayı kişiselleştirmeyin, issue'larda minimum reproduction isteyin.

Rapor edilmesi gereken bir ihlal durumunda: projenin maintainer'ına e-posta ile yazın. Adres `CODE_OF_CONDUCT.md` içindedir.

## Security issue bildirme

**Güvenlik açığı için public GitHub issue AÇMAYIN.**

Doğru süreç:

1. E-posta ile iletişim: `info@oguzhansert.dev`
2. Subject: `[security] Ulak OS: <kısa başlık>`
3. Body: açığın kısa tanımı + reproduction steps + etkilenen dosyalar + önerilen fix
4. 72 saat içinde yanıt bekleyin

## Katkı örnek senaryoları

### Senaryo A — Yeni bir anti-pattern önermek

İki projede gördüğünüz bir anti-pattern var: "webhook handler sessiz retry yapıyor ama idempotency key yok."

1. Issue aç: "Propose AP-NN: Webhook retry without idempotency"
2. PR'da ekle:
   - `docs/runtime/anti-patterns.md`'ye entry (TR + EN)
   - `docs/governance/pattern-import-ledger.md`'ye kayıt
   - Bilingual doc
3. `validate-bilingual.sh` + `validate-schemas.sh` koştur
4. PR aç

### Senaryo B — Yeni bir rule pack önermek

FastAPI + async SQLAlchemy için kural paketi.

1. Issue aç: "Propose rule pack: fastapi-async"
2. PR'da ekle:
   - `docs/runtime/rule-packs/fastapi-async.md` (+ `.en.md` pair)
   - Pattern-import-ledger entry
   - ≥2 proje kanıtı abstract descriptor
3. ADR gerekiyorsa `docs/adr/ADR-NNN-fastapi-async-rule-pack.md`
4. `validate-bilingual.sh` geçir
5. PR aç

### Senaryo C — Yeni bir komut önermek (`/ulak-<yeni>`)

1. Issue aç: "Propose /ulak-<yeni>: <amaç>"
2. PR'da ekle:
   - `.claude/commands/ulak-<yeni>.md` (frontmatter + body)
   - `bash scripts/sync-gemini-commands.sh` koştur → `.gemini/commands/ulak-<yeni>.toml` auto-generate
   - `docs/adapters/codex-cli.md` + `copilot-chat.md` NL trigger map güncelle
   - `docs/governance/vendor-capability-matrix.md` Tablo B.1'e ekle
   - `docs/catalog.md` inline catalog güncelle
   - `docs/user-manual/tr/04-komutlar.md` + `en/04-commands.md` tablolara ekle
3. 4 validator koştur
4. PR aç

## Katkı yapmadan önce

- Mevcut issue'ları tarayın — benzer bir öneri zaten var mı?
- Mevcut rule pack / sector pack'leri inceleyin — yeniden icat etmiyor olun
- Core contract'ı okuyun (`prompts/core/ulak-os-core-contract-2.0.0.md`) — önerilen değişiklik çekirdeği bozmuyor olmalı
- `/pack-gap-audit` koşturun — belki eksik zaten tespit edilmiş

## İlgili belgeler

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — ana contribution guide
- [CODE_OF_CONDUCT.md](../../../CODE_OF_CONDUCT.md) — davranış kuralları
- [docs/governance/pattern-import-ledger.md](../../governance/pattern-import-ledger.md) — mevcut pattern kayıtları
- [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md) — 4 vendor × 24 komut matrisi
- [docs/governance/localization-governance.md](../../governance/localization-governance.md) — bilingual parity kuralları
- [docs/adr/](../../adr/) — ADR şablonu ve mevcut kararlar (ADR-000 → ADR-005 + newer)
- [docs/governance/rule-pack-governance.md](../../governance/rule-pack-governance.md) — rule pack kuralları

Sonraki bölüm: [08 — Sorun giderme](./08-sorun-giderme.md)
