---
name: ulak-demo
description: Ulak OS ile yapılabilecek 3 örnek SaaS projesi tanıtır (Minimal SaaS, Marketplace, LMS). Her örnek için gerçek scaffold komutu, üretilen dosya sayısı (disk'ten ölçülmüş), aktive olan sector+rule pack'ler ve "Ulak'sız kaç gün alırdı" tahmini verir. Beginner "çalıştırmadan önce göreyim" dediğinde kullanılır.
description_en: Introduces 3 example SaaS projects buildable with Ulak OS (Minimal SaaS, Marketplace, LMS). For each example: real scaffold command, generated file count (measured on disk), activated sector + rule packs, and a "how many days would this take without Ulak" estimate. Used when a beginner says "show me before I run anything".
agent: autonomous-program-director
allowed-tools: Read, Grep, Glob
argument-hint: "(boş) veya 1 / 2 / 3 — hangi demoyu detayına bakmak istersen"
model: claude-opus-4-7
---

# /ulak-demo — örnek projeler turu

## Vizyon

Yeni kullanıcı `/ulak-scaffold`'ı görür, ama ne çıkacağını hayal edemez. "Minimal SaaS mi, marketplace mi, LMS mi?" seçeneklerinin her biri aslında ne? Kaç dosya üretiyor? Hangi rule pack'ler aktive oluyor? "Ben Ulak olmadan yapsaydım kaç gün alırdı?"

`/ulak-demo` bu soruyu cevaplar: **çalıştırmadan** 3 somut örneği gösterir. Her örnekte:
- **Gerçek** scaffold komutu (copy-paste'lik)
- **Ölçülmüş** dosya sayısı (`find templates/... -type f | wc -l` çıktısı, tahmin değil)
- **Aktive olan** sector overlay + rule pack + anti-pattern sayısı
- **Dev süre tahmini** — "böyle bir projeyi sıfırdan kurmak geleneksel yolla kaç gün alır"

Komut **çalıştırmaz**. Sadece anlatır. Kullanıcı beğenirse `/ulak-start` veya `/ulak-scaffold` ile devam eder.

## When to use

- Kullanıcı "Ulak OS ne yapıyor?" diyor, `/ulak-hello` yetmez, somut örnek istiyor
- Karar vermek istiyor: "hangi örnek benim işime uyar?"
- Demo yaparken — ekranda göstermek için "işte üç tür proje"
- `/ulak-start` wizard'ından önce — "hangi sector seçsem?" diye bakarken

## When NOT to use

- Kullanıcı hazır scaffold'a — direkt `/ulak-start` veya `/ulak-scaffold`
- Dosya dump'ı için — `/ulak-packs` tüm kapasiteleri gösterir
- Catalog için — `/ulak-search` veya `docs/catalog.md`

## Akış

### 1. Argüman yoksa: 3 örneği listele + menü

Çıktı template'i:

```
═══════════════════════════════════════════════════════════════════
 Ulak OS ile yapılabilecek 3 örnek proje
═══════════════════════════════════════════════════════════════════

 [1] Minimal SaaS — Tek kullanıcı tipli basit ürün
     Stack      : Next.js 15 + TypeScript + Supabase
     Dosya      : ~124 template (`templates/saas-starter/`)
     Pack'ler   : 3 rule pack (typescript-nextjs, localization-ssot,
                  api-security) + 0 sector overlay
     Örnekler   : notlar uygulaması, kanban board, habit tracker
     Dev süresi : Ulak ile ~1-2 saatte skeleton, Ulak'sız: 3-5 gün

 [2] E-ticaret Marketplace — 2 taraflı alıcı/satıcı
     Stack      : Next.js + Supabase + Iyzico/Stripe (+ Expo mobile opt.)
     Dosya      : ~124 base + 5 marketplace overlay = ~129 template
     Pack'ler   : 4 rule pack (yukarıdaki 3 + payment-integrated-saas)
                  + marketplace sector overlay + SP-11 sector pack
     Özellikler : seller panel, buyer search, admin disputes, commission
     Örnekler   : el-yapımı pazar yeri, hizmet sağlayıcı platformu
     Dev süresi : Ulak ile ~2-3 saat, Ulak'sız: 8-14 gün

 [3] Eğitim Platformu (LMS) — kurs + ders + enrollment
     Stack      : Next.js + Supabase + Iyzico (video-ready)
     Dosya      : ~124 base + 6 education overlay = ~130 template
     Pack'ler   : 4 rule pack + education sector overlay + SP
                  (education, regulated-saas opt. KVKK/COPPA)
     Özellikler : course catalog, lesson player, admin enrollments
     Örnekler   : online kurs sitesi, çocuk eğitim platformu
     Dev süresi : Ulak ile ~2-3 saat, Ulak'sız: 7-12 gün

 Detay için bir seçim yap: /ulak-demo 1  |  /ulak-demo 2  |  /ulak-demo 3
 Hemen başlamak için       : /ulak-start (wizard) veya /ulak-scaffold
═══════════════════════════════════════════════════════════════════
```

### 2. `/ulak-demo 1` — Minimal SaaS detayı

```
═══════════════════════════════════════════════════════════════════
 [1] Minimal SaaS — tek kullanıcı tipli basit ürün
═══════════════════════════════════════════════════════════════════

 Ne demek?
   Tek rol: "kullanıcı". Admin ayrımı minimal. Tipik "bir kişi giriş
   yapar, kendi verilerini yönetir, çıkış yapar" akışı.

 Scaffold komutu:
   /ulak-scaffold --name notlar-app --sector saas-starter --locale tr

 Üretilen dosya sayısı:
   templates/saas-starter/ altında 124 template dosyası.
   Her `.template` uzantılı dosya placeholder substitution ile
   gerçek dosyaya dönüşür. Tipik sonuç: ~150 dosyalık Next.js projesi.

 Dosya yolu kaynağı (kanıt):
   find templates/saas-starter/ -name "*.template" -type f | wc -l
   → 124

 Aktive olan pack'ler:
   Rule packs (3):
     • typescript-nextjs   — Next.js + TS best practices
     • localization-ssot   — çoklu locale disiplini (≥2 locale zorunlu)
     • api-security        — auth + CSRF + rate-limit baseline

   Sector overlay: 0 (minimal; ek overlay yok)
   Anti-patterns gate'lenen: 8 (tüm scaffold'larda zorunlu 8 AP)

 Gelen yapı (özet):
   app/                      — Next.js App Router sayfa ağacı
   components/ui/            — shadcn-vari primitive'ler
   lib/auth/                 — TEK auth helper (AP-01)
   lib/supabase/             — server.ts + client.ts ayrımı
   supabase/migrations/      — RLS aktif initial migration'lar
   tests/                    — Playwright + Vitest seed
   .github/workflows/        — CI (typecheck + test + build)
   docker-compose.yml        — local dev stack
   middleware.ts             — auth guard

 Örnek ürün fikirleri:
   • Notlar uygulaması      — kullanıcı kendi notlarını yazar
   • Kanban board           — tek kullanıcılı task manager
   • Habit tracker          — günlük alışkanlık işaretleme
   • Bookmark manager       — kişisel link kütüphanesi

 Dev süre karşılaştırması:
   Ulak OS ile          : ~1-2 saatte çalışan skeleton (scaffold + env)
   Sıfırdan geleneksel  : 3-5 gün (auth + RLS + i18n + CI + tests)
   → Kaynak: `/ulak-scaffold` konfigürasyonu günlük rutinleri
     (auth helper, RLS policy, i18n key'leri, CI pipeline) kod yazımı
     yerine template replacement'a indirir.

 Sonraki adım:
   /ulak-start              — wizard ile başla (önerilir)
   /ulak-scaffold --help    — flag'lere bak
   /ulak-next-steps         — scaffold sonrası ilk 10 adım
═══════════════════════════════════════════════════════════════════
```

### 3. `/ulak-demo 2` — Marketplace detayı

```
═══════════════════════════════════════════════════════════════════
 [2] E-ticaret Marketplace — 2 taraflı (alıcı + satıcı)
═══════════════════════════════════════════════════════════════════

 Ne demek?
   İki kullanıcı rolü: alıcı (buyer) + satıcı (seller) + admin.
   Satıcı ürün listeler, alıcı satın alır, platform komisyon alır,
   şikayet varsa admin dispute çözer.

 Scaffold komutu:
   /ulak-scaffold --name pazar-app --sector marketplace \
                  --payment iyzico --locale tr

 Üretilen dosya sayısı:
   Base saas-starter       : 124 template
   marketplace overlay     :   5 template
   ─────────────────────────────
   Toplam                  : ~129 template

 Dosya yolu kaynağı (kanıt):
   find templates/saas-starter/ -name "*.template" | wc -l   → 124
   find templates/sectors/marketplace/ -type f | wc -l        →   5

   Overlay dosyaları:
     templates/sectors/marketplace/app/(admin)/disputes/page.tsx.template
     templates/sectors/marketplace/app/(buyer)/search/page.tsx.template
     templates/sectors/marketplace/app/(seller)/layout.tsx.template
     templates/sectors/marketplace/app/(seller)/listings/page.tsx.template
     templates/sectors/marketplace/supabase/migrations/00005_marketplace_schema.sql.template

 Aktive olan pack'ler:
   Rule packs (4):
     • typescript-nextjs
     • localization-ssot
     • api-security
     • payment-integrated-saas  ← iyzico/stripe FSM + webhook

   Sector overlay: marketplace/   (templates/sectors/marketplace/)
   Sector pack (opsiyonel):
     SP-11 multi-app-nextjs-expo-monorepo (mobile istersen)
   Anti-patterns: 8 base + payment-special (AP-12, AP-13)

 Özellikler:
   • Seller panel           — ürün/ilan yönetimi
   • Buyer search           — katalog + filtre
   • Commission akışı       — platform kesintisi (FSM)
   • Dispute resolution     — admin çözüm paneli
   • Iyzico 3DS entegrasyonu (TR kullanıcı için)

 Örnek ürün fikirleri:
   • El-yapımı pazar yeri       — üreticiler ürünlerini satar
   • Hizmet sağlayıcı platformu — freelance/ustalar + müşteri
   • İkinci el eşya marketplace

 Dev süre karşılaştırması:
   Ulak OS ile          : ~2-3 saatte çalışan skeleton + payment stub
   Sıfırdan geleneksel  : 8-14 gün (yukarıdaki + seller panel + payment
                         FSM + 3DS + commission + dispute + admin)
   → Kaynak: payment FSM (`transactional-fsm-payment.md`) ve seller
     panel sector overlay kod yazımını azaltır; webhook idempotency +
     RLS simetrisi en çok "unuttum" dediğin yerlerdir — Ulak kapatır.

 Sonraki adım:
   /ulak-start                                  — wizard
   /ulak-explain iyzico                         — iyzico'yu anla
   /ulak-scaffold --sector marketplace --help   — tüm flag'ler
═══════════════════════════════════════════════════════════════════
```

### 4. `/ulak-demo 3` — Eğitim platformu (LMS) detayı

```
═══════════════════════════════════════════════════════════════════
 [3] Eğitim Platformu (LMS) — kurs + ders + enrollment
═══════════════════════════════════════════════════════════════════

 Ne demek?
   Üç rol: öğrenci, eğitmen/admin, platform yöneticisi. Öğrenci
   kursa kayıt olur, video/quiz takip eder, ilerleme kaydı tutulur.

 Scaffold komutu:
   /ulak-scaffold --name okul-app --sector education \
                  --payment iyzico --locale tr

 Üretilen dosya sayısı:
   Base saas-starter      : 124 template
   education overlay      :   6 template
   ─────────────────────────────
   Toplam                 : ~130 template

 Dosya yolu kaynağı (kanıt):
   find templates/saas-starter/ -name "*.template" | wc -l     → 124
   find templates/sectors/education/ -type f | wc -l            →   6

   Overlay dosyaları:
     templates/sectors/education/app/(admin)/courses/page.tsx.template
     templates/sectors/education/app/(admin)/enrollments/page.tsx.template
     templates/sectors/education/app/(customer)/courses/page.tsx.template
     templates/sectors/education/app/(customer)/courses/[id]/page.tsx.template
     templates/sectors/education/app/(customer)/lessons/[id]/page.tsx.template
     templates/sectors/education/supabase/migrations/00005_lms_schema.sql.template

 Aktive olan pack'ler:
   Rule packs (4):
     • typescript-nextjs
     • localization-ssot
     • api-security
     • payment-integrated-saas  (kurs satışı)

   Sector overlay: education/
   Opsiyonel: regulated-saas overlay (KVKK + çocuk verisi için COPPA)
   Educational UX agent devreye alınabilir (study-continuity, motivation)

 Özellikler:
   • Course catalog              — kurs listesi + arama
   • Lesson player               — video-ready sayfa iskeleti
   • Enrollment flow             — kayıt + payment
   • Admin course editor         — ders yönetimi
   • Student progress tracking   — ilerleme kaydı

 Örnek ürün fikirleri:
   • Online kurs sitesi              — yetişkin eğitim
   • Çocuk eğitim platformu          — KVKK+COPPA compliant
   • Profesyonel sertifika platformu — certification

 Dev süre karşılaştırması:
   Ulak OS ile          : ~2-3 saatte çalışan skeleton
   Sıfırdan geleneksel  : 7-12 gün (auth + enrollment + payment +
                         progress + admin + RLS + i18n)
   → Kaynak: LMS-specific schema (`00005_lms_schema.sql`) ve
     student/teacher/admin persona ayrımı kurulu gelir; ilerleme
     tracking + RLS policy manuel yazımı saatler alır normalde.

 Sonraki adım:
   /ulak-start                               — wizard
   /ulak-explain kvkk                        — çocuk eğitim için
   /ulak-scaffold --sector education --help  — flag'ler
═══════════════════════════════════════════════════════════════════
```

## Rules

- **Çalıştırmaz**. Sadece anlatır. Scaffold başlatmaz.
- **Gerçek sayılar**. Dosya sayıları `find ... | wc -l` çıktısı ile doğrulanır; uydurulmaz.
- **Dev süre tahminleri referanslı**. "3-5 gün" gibi bir sayı verilirse, hangi iş kalemlerinin kapsamında olduğu (auth + RLS + i18n + CI + tests) mutlaka belirtilir. "10-15 gün" gibi tek sayı yasak — aralık + gerekçe.
- **Portfolio isim yasak**. Gerçek müşteri proje adları kullanılmaz; örnekler generic ("notlar uygulaması", "el-yapımı pazar yeri") olmak zorunda.
- **Secrets yok**. Hiçbir örnek komutta gerçek anahtar/secret yer almaz.
- **Diske yazmaz**. `/ulak-explain` ve `/ulak-ask` gibi inline döner; default "diske yaz" kuralının istisnası (CLAUDE.md §Working rule kapsam dışı).

## Yasaklar

- Uydurma sector — sadece gerçekte var olan 15 sector overlay'den örnek verilir.
- Uydurma rule pack — sadece 8 rule pack'ten seçim yapılır.
- Çalıştırılabilir `rm -rf` veya destructive komut içermez.
- Rakip ürünler hakkında subjective yargı yok ("Ulak daha iyi" gibi bir iddia, data olmadan).

## Kaynak dosyalar (evidence)

- `templates/saas-starter/` — 124 template (base)
- `templates/sectors/marketplace/` — 5 overlay dosyası
- `templates/sectors/education/` — 6 overlay dosyası
- `templates/sectors/ecommerce/` — 5 overlay dosyası (alternatif referans)
- `docs/catalog.md` — 15 sector overlay, 24 sector pack, 8 rule pack listesi
- `docs/runtime/sector-packs.md` — sector pack tanımları
- `docs/runtime/rule-packs/` — rule pack dosyaları

## Integration

- `/ulak-hello` → 4. seçenek "kapasiteleri gör" yerine 5. seçenek "örnek gör" olabilir (`/ulak-demo`)
- `/ulak-start` → wizard açılmadan "önce demo göreyim" çıkışı verir
- `/ulak-ask "örnek göster"` → `/ulak-demo` önerir
- `/ulak-next-steps` → scaffold sonrası komşu komut

## EN quick note

`/ulak-demo` shows 3 example SaaS projects you can build with Ulak OS (Minimal SaaS, Marketplace, LMS). For each: real scaffold command, measured file counts (`find ... | wc -l`), activated sector overlays + rule packs + anti-pattern count, and a ranged dev-day comparison ("Ulak: 2-3 hours vs traditional: 8-14 days") with itemized rationale. Does not execute anything — read-only tour. Args: no arg (list of 3) or `1`/`2`/`3` (detailed view).

ARGUMENTS:
$ARGUMENTS
