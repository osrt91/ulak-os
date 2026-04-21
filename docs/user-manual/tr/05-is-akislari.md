# 05 — İş akışları

Bu bölüm Ulak OS'un en çok kullanılan beş iş akışını (workflow) kapsar. Her iş akışı için: **kullanım senaryosu**, **komut dizisi**, **beklenen çıktı**, ve **bu iş akışının yetmediği durumlar** verilir. Örnekler abstract (soyut) proje tiplerine dayanır — kendi kodunuzda aynı pattern'i uygulayın.

## İş akışı 1 — Brownfield audit (devralınmış proje denetimi)

**Senaryo:** Üç sene önce başka bir takım tarafından yazılmış, son iki sene yarım-bakımlı bırakılmış bir SaaS uygulamasını devraldınız. Neyi atabileceğinizi, neyi düzeltmeniz gerektiğini, production'a çıkmadan önce hangi kırmızı çizgilerin yakalanacağını bilmiyorsunuz. Amacınız: bir günlük disiplinli denetim raporu + şu an çözülmesi gerekenler sıralaması.

**Komut dizisi:**

```bash
# 1. Ulak OS'u projeye bağla
cd /path/to/inherited-project
ulak init .

# 2. Claude Code'u projede aç
claude

# 3. Tam denetim
/director komple output_language=tr
```

Opsiyonel: belirli bir persona setini zorlamak isterseniz:

```
/director komple persona=customer,admin,partner output_language=tr
```

**Beklenen çıktı:**

`reports/current/` altında 15 artefakt. En kritik üçü:

- `inventory.md` — her API route, env var, migration, i18n key, config dosyası file:line bazlı listeli
- `did-you-know.md` — non-obvious findings: unused import, RLS asimetrisi, kırık i18n, N+1 risk, deploy rollback yokluğu vb.
- `manager-verdict.md` — üç durumdan biri: `ready` / `conditional` / `blocked`; top 3 did-you-know, residual risks, next execution lane

Tipik süre: 20-40 dakika (repo boyutuna göre).

**Bu iş akışı yetmez eğer:**
- Repo 100k+ LOC ve tek `/director` context budget'ı aşıyor — o zaman submodule bazlı parçalı denetim kullanın (her submodule için ayrı run).
- İstediğiniz şey sadece CI'nin yeşillenmesi — o zaman `/triage-build` yeterli.
- Production'a çıkmak istemiyor, sadece "okumak" istiyorsanız — `/intake` daha hafif.

Gerçek bir walkthrough: [docs/showcase/01-audit-walkthrough.md](../../showcase/01-audit-walkthrough.md).

## İş akışı 2 — Greenfield scaffold (sıfırdan ürün başlatma)

**Senaryo:** Yeni bir SaaS ürününe başlıyorsunuz. Next.js + Supabase + payment + i18n + CI yazmak için hafta vermek istemiyorsunuz. Günün sonunda `localhost:3000`'de çalışan, staging'e push edilebilecek, 8 anti-pattern construction-time'da engellenmiş bir iskelet istiyorsunuz.

**Komut dizisi:**

```bash
# 1. Ulak OS kurulumu (daha önce yaptıysanız atlayın)
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh

# 2. Kaynak dizinde Claude Code aç
cd ~/projects
claude

# 3. Scaffold
/ulak-scaffold product_name="example-saas" product_domain="saas" payment_provider="stripe" locales_supported=["en","tr"]
```

Etkileşimli mode: boş argüman bırakın, komut sorular sorar.

**Beklenen çıktı:**

`../example-saas/` altında shippable bir proje:

```
example-saas/
├── src/app/              # Next.js 16 App Router
├── src/components/       # UI bileşenleri
├── src/lib/              # server-only helpers
├── supabase/
│   ├── migrations/       # RLS policies dahil
│   └── seed.sql
├── .github/workflows/
│   ├── validate.yml
│   ├── gitleaks.yml
│   └── eval-smoke.yml
├── infrastructure/
│   ├── docker-compose.yml
│   ├── docker-compose.prod.yml
│   └── kale-kapisi.sh
├── .env.example
├── .gitignore            # Ulak governance patterns pre-wired
├── .claude/
│   ├── settings.json     # deny-list eklenmiş
│   └── settings.local.example.json
├── CLAUDE.md             # Ulak OS core contract @-import
├── docs/
│   ├── SETUP.md
│   └── pattern-import-ledger.yaml
├── tests/
│   ├── unit/
│   └── e2e/
└── scripts/
    ├── preflight.sh
    └── install-hooks.sh
```

Commit 1: tüm yukarıdakiler eksiksiz. `pnpm install && pnpm dev` ile proje çalışır.

**Bu iş akışı yetmez eğer:**
- Stack'iniz Next.js dışı bir çerçeve (Rails, Django, Laravel) — şu an scaffolder `nextjs | remix | sveltekit` destekler; başkası için manuel yapı gerekir.
- Frontend stack Next ama backend ayrı bir servis (Python/Go) — `stack_backend=node-fastapi` ile başlayın, monorepo düzenine geçin.
- Mobile-first bir uygulama — `has_mobile=true` scaffolder'da mobile/ workspace ekler ama mobil öncelikli bir ürün için native mobile stack ayrı seçilmeli.

Gerçek bir walkthrough: [docs/showcase/02-scaffold-walkthrough.md](../../showcase/02-scaffold-walkthrough.md).

## İş akışı 3 — Multi-persona audit (persona-split denetim)

**Senaryo:** Ürününüzün üç farklı kullanıcı yüzeyi var: customer (son kullanıcı), admin (yönetici paneli), partner (bayi / reseller API). Hepsi aynı backend'e dokunuyor ama birinin rolü diğerininkini etkilememeli. Denetim sırasında her persona için ayrı findings istiyorsunuz.

**Komut dizisi:**

```bash
cd /path/to/multi-surface-saas
claude

/director komple persona=customer,admin,partner output_language=tr
```

Beş persona (`customer,admin,support,developer,bayi`) dispatch etmek için:

```
/director komple persona=customer,admin,support,developer,bayi output_language=tr
```

**Beklenen çıktı:**

`reports/current/evidence-register.md` persona başlıklarına göre bölünür:

```markdown
## Persona: customer
### Finding CU-01 — ...
### Finding CU-02 — ...

## Persona: admin
### Finding AD-01 — ...
### Finding AD-02 — ...

## Persona: partner
### Finding PA-01 — ...
### Finding PA-02 — ...
```

`analysis-findings.md` aynı persona ayrımını korur. `target-state.md` surface başına (customer / admin / partner) ayrı hedef belirler. `execution-roadmap.md` persona × wave kesişimini yazar.

**Bu iş akışı yetmez eğer:**
- Sadece customer-facing UI'a bakıyorsanız — tek persona için `/director komple persona=customer` yeterli.
- Persona ayrımı zaten net değil (yeni proje, surface birleşik) — önce `/intake` ile surface'leri keşfedin, sonra multi-persona audit koşun.
- Persona sayısı 5'ten fazla — dispatch overhead artar; iki pasta halinde bölün (`persona=customer,admin` + `persona=partner,support,developer`).

Detay: [docs/runtime/persona-dispatch-pattern.md](../../runtime/persona-dispatch-pattern.md). Walkthrough: [docs/showcase/03-persona-audit.md](../../showcase/03-persona-audit.md).

## İş akışı 4 — Pattern import (proje-arası öğrenme transferi)

**Senaryo:** Bir projede karşılaştığınız bir pattern ("ödeme webhook'u retry + idempotency key + database unique constraint üçlüsü") başka projelerde de uygulanmalı. Bu deseni Ulak OS'a kalıcı olarak yüklemek istiyorsunuz ki bir sonraki `/director` veya `/ulak-scaffold` koştuğunuzda otomatik hatırlansın.

**Komut dizisi:**

```bash
# 1. Deseni kaynak projede tespit et (manuel inceleme veya `/director` sonucu)
# 2. Ulak OS repo'suna dön
cd ~/tools/ulak-os    # ya da submodule: cd .ulak-os

# 3. Pattern-import ledger'a ekle
```

`docs/governance/pattern-import-ledger.md` dosyasına yeni entry:

```yaml
- id: AP-42
  source_project: "B2B SaaS with multi-locale"
  source_files:
    - payments/webhook_handler.ts:45-120
    - db/migrations/20260301_payment_idempotency.sql:1-30
  trust_tier: T2
  rationale: |
    Ödeme webhook'u duplike delivery'ye karşı idempotency key + DB unique
    constraint + exponential retry ile koruma sağlıyor. Eş zamanlı iki webhook
    aynı transaction_id'yi alırsa ikinci INSERT constraint violation'a düşer
    ve retry'da handler idempotent sonucu döner.
  abstracted_to: docs/runtime/transactional-fsm-payment.md
```

Eğer pattern bir anti-pattern'se (yapılmaması gereken):

```yaml
- id: AP-NN
  kind: anti-pattern
  source_project: "..."
  source_files: ["..."]
  trust_tier: T2
  rationale: |
    ...
  abstracted_to: docs/runtime/anti-patterns.md
```

Son olarak:

```bash
bash scripts/validate-schemas.sh
git add docs/governance/pattern-import-ledger.md docs/runtime/...
git commit -m "feat(patterns): import AP-42 from B2B SaaS evidence"
git push
```

**Beklenen çıktı:**

- `pattern-import-ledger.md` yeni entry ile güncel
- Pattern referansı `docs/runtime/` altına eklenmiş (anti-pattern'se anti-patterns.md'ye, pozitif pattern'se sector/rule pack'e)
- CI'da pattern-import-ledger schema check geçti
- Bir sonraki `/director` veya `/ulak-scaffold` çalıştığında bu pattern referans edilir

**Bu iş akışı yetmez eğer:**
- Sadece bir projede değil, birden fazla proje'den aynı pattern'i ≥2 kaynakla kanıtlamak isteseydik — single-source pattern T2 altında kalır, governance gereği T2 minimumdur; ikinci bir kaynak ekleyin.
- Pattern generic değil proje-özgü — kaynak repo'da kalsın, Ulak OS'a import etmeyin.

Detay: [docs/governance/pattern-import-ledger.md](../../governance/pattern-import-ledger.md). Walkthrough: [docs/showcase/04-cross-project-absorption.md](../../showcase/04-cross-project-absorption.md).

## İş akışı 5 — Re-audit / follow-up (takip denetimi)

**Senaryo:** İki hafta önce `/director komple` koştunuz, manager-verdict `conditional` çıktı. O zamandan beri iki validation probe'u elle koşturdunuz, üç Critical finding'i fix ettiniz. Şimdi signoff'u güncellemek istiyorsunuz.

**Komut dizisi:**

```bash
cd /path/to/audited-project
claude

# Önceki run'ı arşivden silmeden, yeni verdict istiyorsunuz:
/final-verdict tüm Critical finding'ler kapatıldı, validation-plan §6 probe'ları geçti, yeniden değerlendir
```

Ya da artefaktları tamamen yeniden üretmek için:

```bash
mv reports/current reports/archive/$(date +%Y%m%d)
/director komple output_language=tr
```

**Beklenen çıktı:**

- `validation-plan.md` — probe sonuçları T-tier yükseltmeleriyle güncel
- `manager-verdict.md` — yeni signoff_status
- Bir önceki run'ın artefaktları ya korunmuş ya arşivlenmiş

**Bu iş akışı yetmez eğer:**
- Repo state çok değişti (başka bir takımdan commitler geldi) — `/final-verdict` şaşabilir; full `/director` re-run daha güvenli.
- Probe'lar hala kırmızıysa — signoff blocked kalır, fix edilmeden "ready" diyemezsiniz.

## Özet karar ağacı

```
İhtiyacım ne?
├── Sıfırdan yeni bir SaaS başlatmak        → İş akışı 2 (/ulak-scaffold)
├── Mevcut projeyi derin denetlemek         → İş akışı 1 (/director komple)
├── Persona-özgü findings istiyorum          → İş akışı 3 (persona=...)
├── Bir pattern'i kalıcı yapmak              → İş akışı 4 (pattern-import-ledger)
├── Önceki audit'i güncellemek               → İş akışı 5 (/final-verdict)
├── Sadece intake/inventory istiyorum        → /intake (hafif)
├── CI kırık, nedenini bulacağım             → /triage-build
└── Frontend redesign                         → /frontend-war-room
```

## İpuçları

**Run'ları arşivle.** Her `/director` çalıştırmadan önce mevcut `reports/current/` dizinini `reports/archive/<tarih>/` altına taşı. Trail bozulmaz, diff alabilirsin.

**Persona'yı açıkça belirt.** Multi-surface SaaS'ta `/director komple persona=customer,admin,partner` yazmak zaman kazandırır — yoksa router persona'yı kendi tahmin eder.

**Validation-plan §6'yı okumadan "ready" deme.** Signoff blocked ise neden blocked, validation-plan söyler; re-run etmek yerine fix edip `/final-verdict` koş.

**Sector pack'i zorla.** Router yanlış sektörü seçerse Phase 0 sonrası `active-variables.yaml`'a `sector: fintech` gibi zorlayıcı override ekle.

**Walkthrough'ları oku.** [docs/showcase/](../../showcase/) altında dört yürüyüş senaryosu var (audit, scaffold, persona, cross-project) — ilk koşturmanızdan önce ilgili olanı okuyun.

Sonraki bölüm: [06 — Yönetişim](./06-yonetisim.md)
