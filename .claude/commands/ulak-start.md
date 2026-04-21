---
description: 5 fazlı, 27 soruluk interaktif SaaS sihirbazı. Kullanıcı prompt yazmaz; faz başına 4-7 soru, her birinde sensible default, [enter] ile hızlı geçiş. İki mod: [t] teknik (default, dev-kitle) veya [b] basit (ilk kez SaaS yapan için gündelik dil + inline terim açıklaması, `docs/runtime/beginner-glossary.md`'den beslenir). Cevaplar Ulak OS'un 24 sector pack + 8 rule pack + 22 governance + 79 anti-pattern katmanına bağlanır; onayla /ulak-scaffold otomatik dispatch edilir.
description_en: 5-phase, 27-question interactive SaaS wizard. User writes no prompts; 4-7 questions per phase, sensible default on each, [enter] to skip. Two modes: [t] technical (default, for devs) or [b] beginner (plain language + inline term glossary for first-time SaaS builders, sourced from `docs/runtime/beginner-glossary.md`). Answers map to Ulak OS's 24 sector packs + 8 rule packs + 22 governance docs + 79 anti-patterns, then /ulak-scaffold auto-dispatches on confirm.
phases_run: [0]
---

# /ulak-start

> **TR** — "Prompt yazmasın" vizyonunun derin hali. 5 faz, 27 soru, her birinde default. İki mod: teknik [t] ve basit [b].
> **EN** — The deep form of the "no-prompt" vision. 5 phases, 27 questions, default on each. Two modes: technical [t] and beginner [b].

## Amaç / Purpose

**TR**: Ulak OS'un gerçek derinliği (24 sector pack × 4 eksen overlay + 8 rule pack + 22 governance
+ 79 anti-pattern + persona dispatch matrisi) 6 soruya sığmıyor. Bu komut, kullanıcı hiç prompt
yazmadan 5 faz boyunca 25-30 kısa cevabı toplar, her biri default'a sahip, [enter] ile hızlıca
geçer, sonunda `/ulak-scaffold`'a doğru flag seti ile geçer.

**EN**: Ulak OS's true depth (24 sector packs × 4 axes + 8 rule packs + 22 governance docs + 79
anti-patterns + persona dispatch matrix) cannot fit into 6 questions. This command walks the user
through 25-30 short answers across 5 phases, each with a default, each skippable with [enter],
and dispatches `/ulak-scaffold` with the right flag set at the end.

## Ne yapmaz / What it does NOT do

- Gerçek dosya yazmaz; yalnızca sorar, özetler, onay alır, sonra dispatch eder.
- Portfolio / müşteri proje adlarına (`bayi*`, `ajans*`, `trend*`, `cevap*` vb.) asla referans vermez.
- Gerçek API key / secret / token sormaz; tüm değerler placeholder olarak akar.

## Genel komutlar / Global commands

Faz içinde herhangi bir anda:

- `/skip`  → bu faz için kalan tüm soruları default'a alır, bir sonraki faza geçer.
- `/back`  → bir önceki soruya döner (önceki cevap düzenlenebilir).
- `/restart` → Phase 1 Q1.1'e döner (tüm cevaplar sıfırlanır, onay ister).
- `/mode <t|b>` → herhangi bir anda teknik (t) ve basit (b) modu arasında geçiş yapar.
- Boş `[enter]` → sorunun default'unu kabul eder.

---

## Phase 0 — Mod seçimi / Mode selection (1 soru, en başta)

> **TR**: Bu soru wizard'ın EN BAŞINDA gelir. Her diğer soru bu cevaba göre render edilir.
> **EN**: This question comes FIRST. Every other question renders based on this answer.

### Q0 — Wizard modu / Wizard mode

```
  Ulak OS seni iki şekilde yönlendirebilir:

   [t] Teknik mod — Next.js, Supabase, SSO, Traefik gibi terimlerle
                    hızlı ve net. Önceki tecrübe varsa bunu seç.
                    (default)

   [b] Basit mod  — "sitenin motoru" (stack), "giriş yöntemi" (auth),
                    "senin sunucun mu / hazır bir yerde mi" (deploy)
                    gibi basitleştirilmiş sorularla. İlk kez site
                    yapıyorsan bunu seç.

  Ulak OS can guide you in two ways:

   [t] Technical mode — Fast and precise, using terms like Next.js,
                        Supabase, SSO, Traefik. Pick this if you
                        have prior experience. (default)

   [b] Beginner mode  — Plain language like "site's engine" (stack),
                        "login method" (auth), "your own server vs
                        managed" (deploy). Pick this if this is
                        your first SaaS.

  Seçim / Choice: _
```

- **Default**: `t` (technical) — `[enter]` ile default seçilir; mevcut kullanıcı için davranış aynı kalır
- Cevap `wizard_mode` state değişkenine kaydedilir (`docs/runtime/wizard-defaults.md` §wizard_mode)
- `t` → sonraki 27 soru sadece teknik blok ile render edilir (mevcut davranış)
- `b` → sonraki 27 soru **dual-render** protokolüne göre basit blok + "Ne seçmeliyim?" rehberi + post-answer `[Anlamı]` gloss ile render edilir (bkz. §Dual-render protokolü)

---

## Dual-render protokolü / Dual-render protocol

Q0 = `b` (basit mod) seçildiğinde Phase 1'den Phase 5'e tüm 27 soru bu protokole göre render edilir:

### Render şablonu / Render template

```
Qx.y: <teknik başlık> / <basit başlık>

  [Teknik mod]                 ← referans için gösterilir (dev terimi öğrenmesi için)
    [1] <teknik seçenek 1>
    [2] <teknik seçenek 2>
    ...

  [Basit mod]                  ← kullanıcı bu bloktaki seçenekle karar verir
    [1] <gündelik dil seçenek 1>  — <1-cümle açıklama>
    [2] <gündelik dil seçenek 2>  — <1-cümle açıklama>
    ...

  Ne seçmeliyim? / Which one?
    - <senaryo 1>: [N]
    - <senaryo 2>: [M]
    - Emin değilsen: [default]

  Seçim / Choice: _
```

### Kullanıcı cevap verdikten sonra / After user answers

```
  User: 1
  Ulak: ✓ Seçim kaydedildi: <teknik karşılık>
        [Anlamı / Meaning] <1-2 cümle, beginner-glossary.md'den özet>
        [Neden default / Why default] <wizard-defaults.md rationale>
```

### Terim kaynağı / Term source

- Tüm `[Anlamı]` mini-açıklamaları `docs/runtime/beginner-glossary.md`'den gelir — wizard terim icat etmez
- Glossary'de olmayan bir terim kullanılırsa wizard önce glossary'e satır eklemeli (append-only protokol)
- Kullanıcı daha derin açıklama isterse `/ulak-explain <term>` komutu tam 5-alanlı şemayı verir

### Basit mod seçenek isimleri — kısa referans matris

Aşağıdaki matris wizard'ın basit mod'da her soru için hangi gündelik-dil karşılığını kullanacağını belirler. Seçenek SAYILARI (1, 2, 3...) teknik mod ile birebir aynı kalır; sadece **görünür isim + açıklama** değişir — böylece iki mod arasında geçiş (/mode t veya /mode b) cevapları kaybetmez.

| Qx.y  | Teknik başlık            | Basit başlık                         | Örnek seçenek dönüşümü (1 / teknik → basit)                          |
|-------|--------------------------|--------------------------------------|----------------------------------------------------------------------|
| Q1.1  | Proje adı                | Sitenin adı                          | kebab-case notu → "küçük harf + tire, boşluk yok" |
| Q1.2  | Hedef sektör             | Ne tür site yapıyorsun?              | "E-ticaret" → "Ürün satılan site"; "Fintech" → "Para ile ilgili (cüzdan/ödeme)"; "LMS" → "Kurs/ders platformu"; "Marketplace" → "Alıcı-satıcı pazaryeri"; "Enterprise B2B" → "Şirket-içi kullanım (kendi çalışanın için)"; "AI Copilot" → "Yapay zekâ destekli asistan site"; "Health/PHI" → "Sağlık verisi taşıyan site"; "Member-gated" → "Üye aidatı alan topluluk" |
| Q1.3  | Hedef kullanıcı kitlesi   | Kim kullanacak?                       | "solo" → "Sadece ben"; "small-team" → "2-5 kişilik ekip"; "enterprise" → "Büyük şirket (50+ kişi)"; "multi-tenant-saas" → "Pazaryeri/platform (N farklı müşteri şirketi)" |
| Q1.4  | Dil tercihi              | Sitenin dili                          | "bilingual" → "İki dilli (TR + İngilizce)" |
| Q2.1  | Stack                    | Sitenin teknik temeli                 | "Next.js+Supabase" → "Web sitesi + hazır database (önerilen, çoğu SaaS böyle)"; "Hybrid FastAPI" → "+ Python backend (makine öğrenmesi / özel hesaplama)"; "Hybrid mobile" → "+ Mobil uygulama (iOS + Android)"; "Hybrid bot" → "+ Telegram botu"; "Full hybrid" → "Hepsi birden (büyük platform)" |
| Q2.2  | Auth stratejisi           | Giriş yöntemi                         | "email+password" → "Email + şifre (klasik)"; "magic link" → "Şifresiz — email'e tek-kullanımlık link gelsin"; "OAuth google+github" → "Google + GitHub ile tek-tık giriş"; "SSO (SAML/OIDC)" → "Kurumsal tek-giriş (büyük şirketlerin sistemi)"; "all" → "Hepsi bir arada" |
| Q2.3  | Database                  | Veritabanı nerede duracak?            | "Supabase managed" → "Hazır kullanım (Supabase senin yerine yönetir — en kolay)"; "Self-hosted" → "Kendi sunucumda kuracağım (daha fazla kontrol, daha fazla iş)"; "Hybrid" → "İkisinin karışımı (büyük ölçek için)" |
| Q2.4  | Ödeme sağlayıcı           | Para tahsilat yöntemi                 | "Stripe" → "Uluslararası kart (USD/EUR)"; "Iyzico" → "Türkiye kartı (TL tahsilat + 3D Secure)"; "both" → "İkisi birden (TR + yurt dışı)"; "none" → "Ödeme almayacağım (ücretsiz / içeride kullanılacak)" |
| Q2.5  | Storage                   | Dosya/medya depolama                  | "Supabase Storage" → "Hazır (Supabase ile birlikte gelir)"; "S3" → "Amazon'un depolama servisi"; "R2" → "Cloudflare ucuz depolama"; "local" → "Sunucudaki klasör" |
| Q2.6  | Email / Transactional     | Otomatik email gönderme                | "Resend" → "Modern, basit kurulum (önerilen)"; "Postmark" → "Teslim edilebilirlik odaklı"; "SES" → "Amazon'un ucuz emaili"; "SMTP" → "Kendim yöneteceğim"; "none" → "Email göndermeyeceğim" |
| Q3.x  | Sektör-özel               | Sektörüne göre dar soru               | §Phase 3 branch'larında her soru için inline basit karşılık (fintech KYC → "kullanıcı kimlik+selfie doğrulama", marketplace escrow → "ödeme platformda bekletme", enterprise SSO → "şirket hesabıyla tek-tık giriş") |
| Q4.1  | Hosting region            | Veriler hangi ülkede duracak?         | "Turkey" → "Türkiye (KVKK zorunlu olur)"; "EU" → "Avrupa (GDPR zorunlu olur)"; "US" → "Amerika"; "Global" → "Çok bölgeli (tüm yasalara uyumlu)" |
| Q4.2  | Analytics                 | Ziyaretçi analitiği                   | "Plausible" → "Gizlilik-dostu, kendi sunucunda (önerilen)"; "PostHog" → "Detaylı ürün analitiği + feature flag"; "Mixpanel" → "Olay bazlı analitik (ücretli)"; "GA4" → "Ücretsiz Google Analytics"; "none" → "Ziyaretçi takibi istemem" |
| Q4.3  | Error tracking            | Hata takibi                           | "Sentry" → "Standart hata yakalama"; "Logflare" → "Supabase-uyumlu"; "Axiom" → "Modern log + metrik"; "none" → "Production'da körüm (önerilmez)" |
| Q4.4  | Uptime monitor            | Site ayakta mı kontrolü               | "Better Stack" → "Modern + on-call bildirimi"; "Cronitor" → "Cron + uptime beraber"; "Uptime Kuma" → "Kendim kuracağım (VPS'te ücretsiz)"; "none" → "Kontrol yok" |
| Q4.5  | Backup strategy           | Yedekleme                             | "Daily snapshot" → "Günlük yedek (basic)"; "Continuous WAL + PITR" → "Sürekli yedek + geri dönüş (enterprise)"; "none" → "Yedek yok (riskli)" |
| Q5.1  | Takım boyutu              | Kaç kişi kodlayacak?                  | "solo (1)" → "Sadece ben"; "small (2-5)" → "Küçük ekip"; "mid (6-20)" → "Orta ekip"; "large (20+)" → "Büyük ekip" |
| Q5.2  | CI provider               | Kod kalite kontrol sistemi            | "GitHub Actions" → "GitHub'ın kendi sistemi (en yaygın)"; "GitLab CI" → "GitLab kullanıyorsan"; "Custom" → "Kendim kuracağım (Drone/Woodpecker)" |
| Q5.3  | Deploy target             | Site nerede yayınlanacak?             | "VPS+Traefik" → "Senin VPS'inde (kiraladığın sunucu)"; "k8s" → "Büyük ölçek konteyner orkestrasyonu"; "Vercel" → "Hazır hosting (bir tık deploy)"; "Fly.io" → "Global edge hosting"; "docker-only" → "Basit Docker, Traefik yok" |
| Q5.4  | Preview deploy per PR     | Her değişiklik için test URL'i        | "yes" → "Her PR'a otomatik test linki çıksın"; "no" → "Sadece main dalı deploy olsun" |
| Q5.5  | Compliance                | Uyman gereken yasalar                 | "gdpr" → "AB veri koruma"; "kvkk" → "Türk veri koruma"; "coppa" → "Çocuk kullanıcı koruma"; "soc2" → "Kurumsal güven raporu"; "hipaa" → "Sağlık verisi yasası"; "pci-dss" → "Kart verisi standardı"; "none" → "Uyum istemem" |
| Q5.6  | Monitoring dashboard      | Sistem metriklerini görme paneli      | "Grafana" → "Kendim kuracağım (ücretsiz, VPS'te)"; "Datadog" → "Hazır, ücretli"; "none" → "Dashboard yok" |

**Not**: Teknik mod'da seçilen bir cevap basit mod'a geçildiğinde (`/mode b`) o cevap **kaybolmaz**; yalnızca ekrandaki gösterim basit karşılığa döner. Tersi de geçerli (`/mode t`).

---

## Phase 1 — Proje kimliği / Project identity (4 soru)

### Q1.1 — Proje adı / Project name

**TR**: Proje için kebab-case bir ad ver.
**EN**: Give the project a kebab-case name.

```
  Sadece [a-z0-9-] kullan, başı/sonu alfanümerik, maks 40 karakter.
  Use only [a-z0-9-], alphanumeric head/tail, max 40 chars.
```

- Default: `ulak-saas-<YYYYMMDD>` (bugünün tarihi ile)
- Ulak'ta hazır: saas-scaffolder skill / `docs/runtime/sector-packs.md`

### Q1.2 — Hedef sektör / Target sector

**TR**: Hangi sektör / domain? Aktif sector pack'i belirler.
**EN**: Which sector / domain? Decides which sector pack activates.

```
  [1]  Minimal SaaS               — Next.js + Supabase, tek kullanıcı tipi
  [2]  E-ticaret / Ecommerce     — katalog + cart + checkout
  [3]  Eğitim / LMS              — kurs + ders + quiz
  [4]  Fintech                   — KYC + AML + compliance overlay
  [5]  Marketplace               — 2-sided, buyer + seller
  [6]  Enterprise B2B            — SSO + teams + admin-hardening
  [7]  Medya / CMS               — blog + moderation
  [8]  Sağlık / PHI              — HIPAA/KVKK sağlık uyumlu
  [9]  AI Copilot                — chat + LLM relay
  [10] PWA Desktop               — offline-first progressive web
  [11] Admin / CMS hardening     — internal tooling, no public surface
  [12] AI-relay cost control     — LLM token cap + per-tenant quota
  [13] Member-gated community    — paid-tier community + feed
  [14] Self-hosted Supabase      — operator owns the DB infra
  [15] Regulated SaaS            — GDPR/SOC2 overlay
  [16] Container / k8s deploy    — Kubernetes + ArgoCD yolculuğu
  [0]  Diğer / Other             — free-text hint, fallback=saas
```

- Default: `1` → `--sector=saas`
- Ulak'ta hazır: 16 sector overlay — `docs/runtime/sector-packs.md`

### Q1.3 — Hedef kullanıcı kitlesi / Target audience

**TR**: Kimin için? Admin-hardening + SSO kararlarını etkiler.
**EN**: For whom? Shapes admin-hardening and SSO decisions.

```
  [1] solo              — tek kurucu, admin = user (no role split)
  [2] small-team        — 2-5 kişi, basic role split, single tenant
  [3] smb               — 6-50 kişi, multi-role, opsiyonel teams
  [4] enterprise        — 50+, SSO/SAML + SCIM + audit cadence
  [5] multi-tenant-saas — platform, N tenant, isolation zorunlu
```

- Default: `2` (small-team) — çoğu greenfield projenin baseline'ı
- Ulak'ta hazır: SP-07 admin-cms-hardening, SP-01 multi-tenant-supabase, AP-11/AP-13/AP-14

### Q1.4 — Dil tercihi / Language preference

**TR**: Birincil dil ve i18n stratejisi.
**EN**: Primary language and i18n strategy.

```
  [1] TR primary                — tr tek dil, turkish-normalization pack aktif
  [2] EN primary                — en tek dil, Turkish pack yok
  [3] Bilingual (tr + en)       — locale SSOT + çift dil testi
  [4] Multi-locale (3+)         — locale SSOT + localization-strategy motor
```

- Default: `3` (bilingual) — Ulak OS'un kanonik tercihi
- Ulak'ta hazır: `docs/runtime/localization-strategy.md`, `docs/runtime/turkish-normalization.md`

---

## Phase 2 — Teknik stack / Technical stack (6 soru)

### Q2.1 — Stack

**TR**: Frontend + backend stack'i.
**EN**: Frontend + backend stack.

```
  [1] Next.js + Supabase                 — kanonik default
  [2] Next.js + Supabase + FastAPI       — hybrid, Python servisi var
  [3] Next.js + Supabase + Expo mobile   — web + mobil workspace
  [4] Next.js + Supabase + aiogram bot   — web + Telegram bot (SP-09)
  [5] Full hybrid: web + mobile + bot    — 3 surface aynı anda
```

- Default: `1` — Next.js + Supabase
- Ulak'ta hazır: SP-11 multi-app-nextjs-expo-monorepo, SP-09 telegram-bot

### Q2.2 — Auth stratejisi / Auth strategy

**TR**: Giriş yöntemleri. Supabase Auth / Auth.js üzerinden bağlanır.
**EN**: Login methods. Wires through Supabase Auth / Auth.js.

```
  [1] email + password           — klasik, minimum friction
  [2] magic link only            — passwordless
  [3] OAuth: google + github     — developer SaaS baseline
  [4] OAuth: google + github + apple — consumer SaaS baseline
  [5] SSO (SAML/OIDC)            — enterprise, Q1.3=enterprise ise auto
  [6] hepsi / all                — email + magic + OAuth + SSO
```

- Default: `1` (solo/small-team) · `5` (enterprise) · `4` (consumer sector 2/5/13)
- Ulak'ta hazır: SP-07 admin-cms-hardening, AP-11 (single-auth-helper), auth-strategy-currency

### Q2.3 — Database

**TR**: Veritabanı konaklaması.
**EN**: Database hosting.

```
  [1] Supabase managed (cloud)   — en hızlı başlangıç
  [2] Self-hosted Supabase       — VPS üstünde, SP-12 aktif
  [3] Hybrid (managed + read replica) — scale için
```

- Default: `1` (managed)
- Ulak'ta hazır: SP-12 self-hosted-supabase-orchestration, SP-01 multi-tenant-supabase

### Q2.4 — Ödeme sağlayıcı / Payment provider

**TR**: Ödeme alınacak mı ve hangi sağlayıcı?
**EN**: Taking payments, and which provider?

```
  [1] Stripe             — global kart + SCA
  [2] Iyzico             — TR pazarı, 3DS, bankalar
  [3] İkisi / both       — çok bölgeli
  [4] Yok / none         — freemium / internal / community-free
```

- Default: `docs/runtime/wizard-defaults.md` → sector'a göre (ör. education=iyzico, saas=both)
- Ulak'ta hazır: SP-03 payment-integrated-saas, AP-08 (sandbox↔live env switch)

### Q2.5 — Storage

**TR**: Dosya/medya depolama.
**EN**: File/media storage.

```
  [1] Supabase Storage            — default, RLS ile entegre
  [2] AWS S3                     — global CDN + enterprise
  [3] Cloudflare R2               — ucuz, global
  [4] Local filesystem            — self-host, küçük ölçek
```

- Default: `1` (Supabase Storage)
- Ulak'ta hazır: SP-12 self-hosted-supabase-orchestration, storage-hardening baseline

### Q2.6 — Email / Transactional

**TR**: Transactional email sağlayıcı.
**EN**: Transactional email provider.

```
  [1] Resend                      — modern default
  [2] Postmark                    — deliverability odaklı
  [3] AWS SES                     — ucuz, enterprise
  [4] SMTP (self-host)            — tam kontrol
  [5] Yok / none                  — email akışı yok
```

- Default: `1` (Resend)
- Ulak'ta hazır: transactional-email template'leri

---

## Phase 3 — Sektör derinliği / Sector depth (3-5 dallı soru, sector'a göre)

> **Not**: Bu faz Q1.2 cevabına göre dallanır. Sector ile eşleşen spesifik sorular çıkar.
> Q1.2 = `0` (Diğer) veya eşleşmeyen bir dal ise bu faz SKIPPED olur.

### Dal: Ecommerce (Q1.2 = 2)

- **Q3.1 Envanter yönetimi / Inventory management?** `[e]vet / [h]ayır` · default=`e`
- **Q3.2 Abonelik ürünleri / Subscription products?** `[e]vet / [h]ayır` · default=`h`
- **Q3.3 Dijital ürünler / Digital goods?** `[e]vet / [h]ayır` · default=`h`
- Ulak'ta hazır: `ecommerce` overlay, PDP/cart/checkout UX rules

### Dal: Education / LMS (Q1.2 = 3)

- **Q3.1 Canlı dersler (video)? / Live lessons (video)?** `[e/h]` · default=`h`
- **Q3.2 Sertifikasyon / Certifications?** `[e/h]` · default=`e`
- **Q3.3 Değerlendirme & quiz / Assessments & quizzes?** `[e/h]` · default=`e`
- **Q3.4 Minor kullanıcılar? / Minors as users?** `[e/h]` · default=`e` (→ COPPA auto)
- Ulak'ta hazır: `education` overlay, COPPA/KVKK minor rules, study-flow continuity

### Dal: Fintech (Q1.2 = 4)

- **Q3.1 KYC sağlayıcı / KYC provider?** `[1] Sumsub [2] Onfido [3] Veriff [4] yok` · default=`1`
- **Q3.2 AML akışı / AML flow?** `[e/h]` · default=`e`
- **Q3.3 BaaS / lisanslı banka / BaaS or licensed bank?** `[e/h]` · default=`h`
- **Q3.4 4-eyes principle dangerous actions?** `[e/h]` · default=`e`
- Ulak'ta hazır: `fintech` overlay, SP-04 regulated-saas Variant B, audit-trail

### Dal: Marketplace (Q1.2 = 5)

- **Q3.1 Komisyon oranı / Commission rate (%)?** default=`10`
- **Q3.2 Escrow var mı / Escrow flow?** `[e/h]` · default=`h`
- **Q3.3 Anlaşmazlık akışı / Dispute flow?** `[e/h]` · default=`e`
- Ulak'ta hazır: `marketplace` overlay, fraud/abuse patterns, payout surfaces

### Dal: Enterprise B2B (Q1.2 = 6)

- **Q3.1 SSO sağlayıcı / SSO providers?** çoklu seçim:
  `[a] google-workspace [b] azure-ad [c] okta [d] custom-oidc` · default=`a,b`
- **Q3.2 SCIM provisioning?** `[e/h]` · default=`e`
- **Q3.3 Team roles modeli / Team roles model?** `[1] flat [2] hierarchical [3] custom` · default=`2`
- Ulak'ta hazır: `enterprise-b2b` overlay, SSO/SAML/OIDC + SCIM + access-review

### Dal: Media / CMS (Q1.2 = 7)

- **Q3.1 Abonelik / paywall var mı?** `[e/h]` · default=`h`
- **Q3.2 Reklam yüzeyi / Ad surface?** `[e/h]` · default=`h`
- **Q3.3 Kullanıcı tarafı içerik / UGC?** `[e/h]` · default=`h`
- Ulak'ta hazır: `media-content` overlay, moderation, DMCA/takedown workflow

### Dal: Health / PHI (Q1.2 = 8)

- **Q3.1 PHI encryption at rest?** `[e/h]` · default=`e` (force=`e`)
- **Q3.2 BAA gerekli / BAA required?** `[e/h]` · default=`e`
- **Q3.3 Telemedicine / video consult?** `[e/h]` · default=`h`
- **Q3.4 Minors as patients?** `[e/h]` · default=`h` (→ extra COPPA layer)
- Ulak'ta hazır: `health-sensitive` overlay, SP-04 Variant C, HIPAA auto-compliance

### Dal: AI Copilot (Q1.2 = 9)

- **Q3.1 RAG / vector DB?** `[1] pgvector [2] pinecone [3] qdrant [4] yok` · default=`1`
- **Q3.2 Kullanıcı başı maliyet tavanı / Cost cap per user ($/month)?** default=`5`
- **Q3.3 Fallback model?** `[1] gemini-flash [2] claude-haiku [3] gpt-4o-mini [4] yok` · default=`1`
- **Q3.4 Streaming-first (SSE)?** `[e/h]` · default=`e`
- Ulak'ta hazır: `ai-copilot` + SP-08 ai-relay-cost-control overlay, AI provider allowlist

### Dal: Member-gated community (Q1.2 = 13)

- **Q3.1 Tiered membership / Paid tiers?** `[e/h]` · default=`e`
- **Q3.2 Moderation queue?** `[e/h]` · default=`e`
- **Q3.3 Feed tipi / Feed type?** `[1] chronological [2] algorithmic [3] hybrid` · default=`1`
- Ulak'ta hazır: SP-10 member-gated-community-platform, event model, RSVP, gallery moderation

### Dal: Diğer sector'ler (1, 10, 11, 12, 14, 15, 16) veya 0

- Phase 3 = 0 soru; varsayılan overlay'ler yeterli.

---

## Phase 4 — Operasyonlar / Operations (5 soru)

### Q4.1 — Hosting region

**TR**: Veri ve kullanıcı trafiği hangi bölgede? GDPR/KVKK/residency kararını belirler.
**EN**: Where does data + traffic live? Drives GDPR/KVKK/residency stance.

```
  [1] Turkey (→ KVKK zorunlu)      — TR pazarı birincil
  [2] EU (→ GDPR zorunlu)          — AB pazarı birincil
  [3] US                           — US pazarı birincil
  [4] Global (multi-region)        — hepsi, conservative compliance
```

- Default: Q1.4 `TR primary` → `1`, `EN primary` → `3`, bilingual/multi → `4`
- Ulak'ta hazır: `docs/governance/secrets-rotation-policy.md`, data-residency rules

### Q4.2 — Analytics

**TR**: Ürün analitiği.
**EN**: Product analytics.

```
  [1] Plausible (self-host)        — privacy-first default
  [2] PostHog                      — product analytics + feature flags
  [3] Mixpanel                     — event analytics SaaS
  [4] GA4                          — ücretsiz, Google
  [5] Yok / none                   — tracking istemem
```

- Default: `1` (Plausible self-host)
- Ulak'ta hazır: `docs/governance/observability-baseline.md`

### Q4.3 — Error tracking

**TR**: Hata takibi.
**EN**: Error tracking.

```
  [1] Sentry                       — standart
  [2] Logflare                     — Supabase-native
  [3] Axiom                        — modern log + metrics
  [4] Yok / none                   — production'da kör
```

- Default: `1` (Sentry)
- Ulak'ta hazır: observability-baseline, error-budget thresholds

### Q4.4 — Uptime monitor

**TR**: Uptime / external health probe.
**EN**: Uptime / external health probe.

```
  [1] Better Stack                 — modern + on-call
  [2] Cronitor                     — cron + uptime birlikte
  [3] Self-host (Uptime Kuma)      — VPS'te
  [4] Yok / none                   — probe yok
```

- Default: `3` (Uptime Kuma self-host; VPS zaten var)
- Ulak'ta hazır: SP-06 vps-nginx-compose-topology, deploy-poll fallback

### Q4.5 — Backup strategy

**TR**: Veritabanı yedekleme.
**EN**: Database backup.

```
  [1] Daily snapshot               — basic baseline
  [2] Continuous WAL + PITR        — enterprise, RTO/RPO hedefli
  [3] Yok / none                   — AP-17 risk
```

- Default: Q1.3=enterprise/multi-tenant-saas → `2`, diğer → `1`
- Ulak'ta hazır: AP-17 backup-discipline, SP-12 self-hosted-supabase-orchestration

---

## Phase 5 — Takım, deploy, compliance / Team, deploy, compliance (6 soru)

### Q5.1 — Takım boyutu / Team size

**TR**: Geliştirici takım boyutu. CI cadence + preview deploy kararını şekillendirir.
**EN**: Dev team size. Shapes CI cadence + preview deploy decisions.

```
  [1] solo (1)                    — minimal CI
  [2] small (2-5)                 — preview per PR, branch protection
  [3] mid (6-20)                  — full CI, codeowners, review required
  [4] large (20+)                 — multi-env + release train
```

- Default: Q1.3'ten türer (solo→1, small-team→2, smb→3, enterprise→4, multi-tenant→3)
- Ulak'ta hazır: `docs/governance/settings-permissions-governance.md`, R-04 pre-push parity

### Q5.2 — CI provider

**TR**: Continuous integration platformu.
**EN**: CI platform.

```
  [1] GitHub Actions              — default
  [2] GitLab CI                   — GitLab kullanıyorsan
  [3] Custom (Drone / Woodpecker) — self-host CI
```

- Default: `1` (GitHub Actions)
- Ulak'ta hazır: validate-imports + validate-schemas + gitleaks + eval-smoke workflow'ları

### Q5.3 — Deploy target

**TR**: Nereye deploy?
**EN**: Where does the app ship?

```
  [1] VPS + Traefik + docker-compose  — SP-06 + SP-13
  [2] Kubernetes + ArgoCD             — SP-02 container-orchestrating-app
  [3] Vercel                          — managed, Next.js native
  [4] Fly.io                          — global edge
  [5] Self-hosted docker (single-host, Traefik yok) — basit
```

- Default: Q2.3=self-hosted → `1`, sector=15/16 → `2`, diğer → `1`
- Ulak'ta hazır: SP-06 vps-nginx-compose-topology, SP-13 multi-project-traefik-edge, SP-02 k8s

### Q5.4 — Preview deploy per PR

**TR**: Her PR için ayrı preview ortamı?
**EN**: Preview environment per PR?

```
  [e] evet / yes                  — her PR'da izole URL
  [h] hayır / no                  — sadece main deploy
```

- Default: Q5.1>=2 → `e`, solo → `h`
- Ulak'ta hazır: webhook-triggered deploy + post-deploy health probe

### Q5.5 — Compliance

**TR**: Uyulması gereken regülasyonlar. Çoklu seçim (virgüllü).
**EN**: Regulations that must be honoured. Multi-select (comma-separated).

```
  [1] gdpr                        — AB veri koruma
  [2] kvkk                        — Türk veri koruma
  [3] coppa                       — minor kullanıcılar
  [4] soc2                        — enterprise trust
  [5] hipaa                       — sağlık/PHI
  [6] pci-dss                     — kart verisi direkt dokunuş
  [0] yok / none
```

- Default: Q4.1 + Q1.2 + Q1.3'ten otomatik türer (`docs/runtime/wizard-defaults.md` tablosu).
  Örn: region=TR + sector=education → `kvkk,coppa`; sector=8 → `hipaa` auto-ekler.
- Ulak'ta hazır: SP-04 regulated-saas, compliance-framework-registry

### Q5.6 — Monitoring dashboard

**TR**: Metrik dashboard.
**EN**: Metrics dashboard.

```
  [1] Grafana (self-host)         — VPS'te; Loki + Prometheus birlikte
  [2] Datadog                     — managed, ücretli
  [3] Yok / none                  — dashboard yok
```

- Default: Q5.1>=3 → `1`, diğer → `3`
- Ulak'ta hazır: observability-baseline, SLO thresholds

---

## Cevapları topla → özet → auto-dispatch

Tüm sorular bittiğinde wizard şu özeti basar (TR + EN satır satır):

```
═════════════════════════════════════════════════════════════════
 /ulak-start — ÖZET + AKTİVE EDİLENLER
 /ulak-start — SUMMARY + ACTIVATED LAYERS
═════════════════════════════════════════════════════════════════

 Proje / Name        : <product_name>
 Sektör / Sector     : <--sector>
 Kullanıcı / Audience: <solo|small-team|smb|enterprise|multi-tenant-saas>
 Dil / Locale        : <tr|en|bilingual|multi>
 Stack               : <Next.js+Supabase[+hybrid][+mobile][+bot]>
 Auth                : <email[+magic][+oauth=...][+sso]>
 DB                  : <managed|self-hosted|hybrid>
 Payment             : <stripe|iyzico|both|none>
 Storage             : <supabase-storage|s3|r2|local>
 Email               : <resend|postmark|ses|smtp|none>
 Region              : <tr|eu|us|global>  → compliance auto: <list>
 Analytics           : <plausible|posthog|mixpanel|ga4|none>
 Error               : <sentry|logflare|axiom|none>
 Uptime              : <better-stack|cronitor|uptime-kuma|none>
 Backup              : <snapshot|wal-pitr|none>
 Team                : <solo|small|mid|large>
 CI                  : <github-actions|gitlab|custom>
 Deploy              : <traefik|k8s|vercel|fly|docker-only>
 Preview-per-PR      : <yes|no>
 Compliance          : <csv>
 Monitoring          : <grafana|datadog|none>

─ Ulak OS bu projeye otomatik aktive etti ──────────────────────
─ Ulak OS auto-activated for this project ─────────────────────

 📦 Sector overlay (15 kitten / from 15 kits)
    → <sector-overlay-name> (<kısa açıklama, örn: "marketplace:
       commission + escrow + dispute flow">)

 📋 Rule pack (8'den aktif N / N of 8 active)
    → <rp-1, örn: multi-tenant-supabase — RLS tenant isolation>
    → <rp-2, örn: transactional-fsm-payment — pending→active FSM>
    → <rp-3, örn: reseller-enabled-saas — 2-sided permission>

 🛡️  Anti-pattern koruması (~100 katalogdan bu projede aktif)
 🛡️  Anti-pattern protection (active here from ~100 catalog)
    → AP-06 admin-role-re-read (fresh-DB role check)
    → AP-08 sandbox ↔ live env switch (payment-aktif ise)
    → AP-11 multi-layer auth bypass (single auth helper)
    → AP-16 .env.local commit block
    → <sector-özel AP'ler, örn: AP-EC-02 oversell-prevention>
    → Toplam / Total: <N> anti-pattern DB trigger + CHECK
      constraint + CI gate olarak ekleniyor.

 🏛️  Governance kuralları (22'den aktif / of 22 active)
 🏛️  Governance rules (of 22 active)
    → <gv-1, örn: KVKK uyum (region=tr cross-rule)>
    → <gv-2, örn: commission-immutability (marketplace sector)>
    → <gv-3, örn: audit-retention: 1-year (team-size≥small)>
    → <gv-N, ...>

 📄 Scaffold edilecek dosyalar (tahmini / estimated)
    → <N> page template (auth + customer [+ seller] [+ admin]
       [+ partner])
    → <N> API route template (webhooks + customer + admin)
    → <N> component template (shadcn + dashboard)
    → <N> SQL migration (initial + RLS [+ sector schema]
       [+ payment])
    → <N> compliance template (<compliance listesi, örn:
       KVKK consent + data export>)

 Otomatik eklenenler / Auto-added:
   - <ör: COPPA (sector=education + minors=yes)>
   - <ör: RLS policies (audience=multi-tenant-saas)>
   - <ör: AP-06 admin role re-read (team>=small)>
   - <ör: SP-08 ai-relay-cost-control bundle (sector=ai-copilot)>

─ Çalıştırılacak komut / Command to dispatch ───────────────────

 /ulak-scaffold product_name=<name> \
                --sector=<sector-csv> \
                --stack=<stack> \
                [--has-mobile] [--has-bot=telegram] \
                --payment=<provider> \
                --storage=<provider> \
                --email=<provider> \
                --region=<region> \
                --compliance=<csv> \
                --team-size=<solo|small|mid|large> \
                --deploy=<target> \
                --analytics=<provider> \
                --error-tracking=<provider> \
                [--preview-per-pr]

─ Sonraki adımlar / What happens next ──────────────────────────

 Scaffold tamamlanır tamamlanmaz `/ulak-next-steps` otomatik
 çalışır — proje nasıl çalıştırılır, hangi env var lazım, ilk
 admin kullanıcı nasıl oluşturulur — 8-10 somut adım.
 As soon as scaffold finishes, `/ulak-next-steps` auto-runs —
 how to start the project, which env vars are needed, how to
 create the first admin user — in 8-10 concrete steps.

─────────────────────────────────────────────────────────────────

 [e] Evet, çalıştır              Enter = e
 [h] Hayır, iptal
 [d <soru-no>] Düzenle (örn: d 4.3, d 2.4)
 [/restart] Baştan başla

 Cevabın / Your answer: _
═════════════════════════════════════════════════════════════════
```

### Aktive edilen katmanlar — kaynak mantığı / Activation layer — source logic

Özet bloğundaki "Ulak OS otomatik aktive etti" paneli dolduran kaynaklar:

| Alan / Field | Kaynak / Source |
|---|---|
| Sector overlay | `templates/sectors/<overlay>/` dizin varlığı + `docs/runtime/sector-packs.md` eşleşmesi |
| Rule pack listesi | `docs/runtime/rule-packs/*.md` + runtime-manifest sinyali (stack/sector/locale/vb.) |
| Anti-pattern listesi | `docs/runtime/anti-patterns.md` + sector-özel AP'ler (`docs/runtime/sector-packs.md`'te sector altında) |
| Governance listesi | `docs/governance/*.md` + rule-collision-matrix (hangi governance hangi cevap ile aktifleşir) |
| Scaffold dosya sayıları | `.claude/skills/saas-scaffolder/SKILL.md` §Templates + sector overlay dosya sayısı |

Sayılar uydurulmaz — runtime-manifest hesaplar. Tahmin sıfırsa o satır özette gösterilmez.

### Onay davranışı / Confirmation behavior

- `[enter]` veya `e` → wizard `/ulak-scaffold` komutunu derlenen flag seti ile **aynı turn içinde
  dispatch eder**. Claude Code üzerinde `/ulak-scaffold ...` satırı slash-komut olarak çağrılır
  (Task tool veya doğrudan slash invocation); başka bir onay beklenmez.
- `h` → iptal. Hiç artefakt yazılmaz. `reports/current/` altına dokunulmaz.
- `d <faz.soru>` (ör. `d 4.3`) → o soruya geri döner, yeni cevap alır, özeti yeniler, onay tekrar
  sorulur.
- `/restart` → Phase 1 Q1.1'e döner; wizard onay ister (`[e]` ile sıfırlama, `[h]` ile mevcut).

### Dispatch chain / Zincir dispatch

Onay davranışı tek bir slash komutunu değil, **iki aşamalı zinciri** tetikler:

```
[e]  →  /ulak-scaffold <flags>   →  /ulak-next-steps <product_path>
        (diske yazar, commit)        (ekrana rehber basar, diske dokunmaz)
```

- `/ulak-scaffold` başarılı biterse (scaffold-log.md SUCCESS) aynı turn içinde `/ulak-next-steps`
  otomatik çağrılır — yeni user input beklenmez.
- `/ulak-scaffold` FAILED dönerse next-steps yerine `/triage-build` önerilir.
- Zincirdeki her handoff ekrana bir breadcrumb basar: "✓ scaffold tamam → next-steps gösteriliyor".

---

## Defaults referansı / Defaults reference

- `docs/runtime/wizard-defaults.md` — sector × payment/hybrid/deploy/compliance default matrisi + `wizard_mode` axis.
- `docs/runtime/sector-packs.md` — sector ID'leri (uydurulmuş sector adı yasak).
- `docs/runtime/beginner-glossary.md` — basit mod inline `[Anlamı]` açıklamalarının otorite kaynağı (40+ terim, 5-alanlı şema).
- `.claude/commands/ulak-scaffold.md` §Inputs — geçerli flag seti (hiçbir flag uydurulmaz).

## Yasaklar / Forbidden

- Gerçek API key / token / secret **sorulmaz**, **kaydedilmez**, **loglanmaz**.
- Portfolio / müşteri proje isimlerine referans verilmez (`bayi*`, `ajans*`, `trend*`, `cevap*`
  varyantları tamamen yasak).
- Mevcut olmayan sector ID'si / flag icat edilmez. Sector listesi `docs/runtime/sector-packs.md`,
  flag listesi `.claude/commands/ulak-scaffold.md` §Inputs bölümünden gelir.
- Default'suz soru bırakılmaz. Boş default OLMAYACAK — her soruda `docs/runtime/wizard-defaults.md`
  veya üst fazdan türeyen bir değer bulunur.

## Hata modu / Failure modes

| Durum / Case | Davranış / Behavior |
|---|---|
| Kullanıcı geçersiz sayı verir | Tekrar sor; 3. hatada `/skip` önerilir (default alınır). |
| Q1.1 isim validasyonu 3 kez fail eder | `ulak-saas-<YYYYMMDD>` default'a düş, bildir. |
| Q1.2 sector 8 + Q5.5'te HIPAA yok | Wizard uyarır, HIPAA otomatik ekler. |
| Q1.2 sector 9 | `ai-relay-cost-control` overlay `--sector` listesine sessiz eklenir. |
| Q2.4 `both` + Q4.1 region=TR + Q5.5 GDPR yok | Wizard uyarır; kullanıcı reddederse kabul. |
| Q5.5 `coppa` tek başına | Wizard uyarır; minimum `kvkk` veya `gdpr` ile eşleştirir. |
| `/ulak-scaffold` dispatch başarısız | Özet + komut string'ini kopyalanabilir formda göster; repeat. |

## Post-dispatch

`/ulak-scaffold` başarılı biter bitmez wizard `/ulak-next-steps` komutunu otomatik olarak aynı
turn içinde çağırır. Ekrana 8-10 adımlık kişiselleştirilmiş çalıştırma rehberi basılır:

- `cd <product_name>`
- `pnpm install`
- `.env.local` doldur — hangi değer nereden (Supabase dashboard, Iyzico sandbox, Resend) adım
  adım, link + 3-adım açıklama + dikkat notlarıyla.
- `pnpm supabase:push` + `pnpm seed` + `pnpm dev` → localhost:3000
- İlk admin kullanıcı (Supabase Studio → Authentication → Create user → SQL Editor ile `role='admin'`)
- Admin panele giriş: http://localhost:3000/admin
- Pre-push hook kurulumu (R-04)
- Baseline health score için `/ulak-audit-deep`

Detay: `.claude/commands/ulak-next-steps.md`. Bu komut diske dokunmaz — sadece ekrana rehber basar.

Opsiyonel: Ulak OS üstünden `/director komple` çalıştırarak yeni projenin baseline sağlık skorunu
al (14-dimension audit otomatik koşar).

## Integration points

- `.claude/commands/ulak-scaffold.md` — hedef komut; flag seti burada doğrulanır.
- `docs/runtime/wizard-defaults.md` — sector × eksen default matrisi + `wizard_mode` axis (t|b).
- `docs/runtime/sector-packs.md` — sector ID katalogu + overlay detayları.
- `docs/runtime/beginner-glossary.md` — Q0=b seçildiğinde dual-render `[Anlamı]` açıklamalarının kaynağı; 40+ terim, 5-alanlı şema.
- `docs/runtime/output-profiles.md` — GREENFIELD_BUILDER_PROFILE tetiklenir.
- `docs/runtime/localization-strategy.md` — Q1.4 locale kararı buraya bağlanır.
- `docs/governance/observability-baseline.md` — Q4.2–Q4.5 kararları.
- `docs/governance/settings-permissions-governance.md` — Q5.1 team boyutu → CI policy.
- `.claude/commands/ulak-explain.md` — Wizard sırasında veya sonrasında terimin tam 5-alanlı açıklaması için kullanıcının bağımsız çağırabileceği komut.

## Relationship to /ulak-intake

`/ulak-intake` **mevcut bir repo'yu okur**. `/ulak-start` **yeni repo oluşturur**. İki akış
birbirinin yerine geçmez:

- Elinde boş dizin var, yeni SaaS kuruyorsun → `/ulak-start`
- Elinde mevcut kod var, anlamak/rescue etmek istiyorsun → `/ulak-intake`

## Vizyon metriği / Vision metric

Bu komut "kullanıcı prompt yazmasın" hedefini %15'ten %85'e taşımak için genişletildi. Başarı
ölçütleri:

- Kullanıcı 25-30 cevapla (ortalama < 3 dakika, çoğu [enter] ile geçilerek) production-ready
  scaffold üretebilmeli.
- Her cevap Ulak OS'un 24 sector pack / 8 rule pack / 22 governance / 79 anti-pattern yüzeyinden
  **en az birine** eşlenmeli; hiçbir cevap dead-end olmamalı.
- `/skip` ile faz atlanabilmeli; `/back` ile geri dönülebilmeli; `/restart` ile sıfırlanabilmeli.
- Onay adımında `[enter]` tek tuşla `/ulak-scaffold` dispatch etmeli — ek soru yok.

ARGUMENTS:
$ARGUMENTS
