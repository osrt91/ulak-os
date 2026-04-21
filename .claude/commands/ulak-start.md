---
description: Interaktif soru-cevap SaaS oluşturma sihirbazı. Kullanıcı uzun flag yazmadan 6 kısa soruya cevaplar; Ulak OS doğru parametrelerle /ulak-scaffold komutunu çağırır. "Prompt yazmasın" vizyonunun operasyonel karşılığı.
description_en: Interactive Q&A SaaS creation wizard. Instead of a long-flag command, the user answers 6 short questions; Ulak OS dispatches /ulak-scaffold with the correct parameters. The operational embodiment of the "user should not write prompts" vision.
phases_run: [0]
---

# /ulak-start

> **TR** — Yeni SaaS projesi başlatmanın en kısa yolu. Soru sor, cevap topla, scaffold et.
> **EN** — The shortest path to start a new SaaS project. Ask, collect, scaffold.

## Amaç / Purpose

**TR**: `/ulak-scaffold product_name=foo --sector=education --stack=nextjs-supabase --payment=iyzico --has-mobile --has-bot=telegram` gibi 10+ flag'li komutu ezberlemek kullanıcıyı "prompt yazar" konumuna düşürür. Bu komut, 6 kısa soru ile aynı bilgiyi toplar ve `/ulak-scaffold`'ı doğru şekilde çağırır.

**EN**: Memorising a command like `/ulak-scaffold product_name=foo --sector=education --stack=nextjs-supabase --payment=iyzico --has-mobile --has-bot=telegram` turns the user into a prompt author. This command collects the same information via 6 short questions and dispatches `/ulak-scaffold` correctly.

## Ne yapmaz / What it does NOT do

- Gerçek dosya yazmaz; sadece soruları sorar, özet gösterir, kullanıcının onayını aldıktan sonra `/ulak-scaffold`'ı devreye sokar.
- Does not touch disk. It only asks, summarises, waits for confirmation, then dispatches `/ulak-scaffold`.

## Akış / Flow

Bu komut tek oturumluk bir Q&A wizard'ıdır. Sorular sırayla sorulur; kullanıcı boş bırakırsa `docs/runtime/wizard-defaults.md` dosyasındaki sector varsayılanı uygulanır. Her soru aşağıdaki şablonda sunulur:

- TR prompt
- EN prompt
- Seçenek listesi veya `[e]vet/[h]ayır`
- Varsayılan işareti (`(default=...)`)

---

### SORU 1 — Ne tür proje? / What kind of project?

**TR**: Hangi sektör / domain? Bu cevap, hangi sector pack'in aktifleşeceğini belirler.
**EN**: Which sector / domain? This answer decides which sector pack activates.

```
  [1]  Minimal SaaS               — Next.js + Supabase, tek kullanıcı tipi
                                   (Next.js + Supabase, single user tier)
  [2]  E-ticaret / Ecommerce     — ürün katalog + cart + checkout
                                   (catalog + cart + checkout)
  [3]  Eğitim / LMS              — kurs + ders + quiz
                                   (course + lesson + quiz)
  [4]  Fintech                   — KYC + AML + compliance overlay
                                   (KYC + AML + compliance overlay)
  [5]  Marketplace               — 2-sided, buyer + seller
                                   (2-sided, buyer + seller)
  [6]  Enterprise B2B            — SSO + teams + admin-hardening
                                   (SSO + teams + admin-hardening)
  [7]  Medya / CMS               — blog + moderation
                                   (blog + moderation)
  [8]  Sağlık / PHI              — HIPAA/KVKK sağlık uyumlu
                                   (HIPAA/KVKK health sensitive)
  [9]  AI Copilot                — chat + LLM relay pattern
                                   (chat + LLM relay pattern)
  [10] PWA Desktop               — offline-first progressive web
                                   (offline-first progressive web)
  [11] Admin / CMS hardening     — internal tooling, no public surface
                                   (internal tooling, no public surface)
  [12] AI-relay cost control     — LLM token cap + per-tenant quota
                                   (LLM token cap + per-tenant quota)
  [13] Member-gated community    — paid-tier community + feed
                                   (paid-tier community + feed)
  [14] Self-hosted Supabase      — operator owns the DB infra
                                   (operator owns the DB infra)
  [15] Regulated SaaS            — GDPR/SOC2 overlay
                                   (GDPR/SOC2 overlay)
  [16] Container / k8s deploy    — Kubernetes + ArgoCD yolculuğu
                                   (Kubernetes + ArgoCD trail)
  [0]  Diğer / Other             — manuel flag'lerle /ulak-scaffold öneririz
                                   (we will recommend manual flags)
```

Mapping (soru cevabı → `--sector=`):

| Cevap | --sector value |
|---|---|
| 1 | `saas` |
| 2 | `ecommerce` |
| 3 | `education` |
| 4 | `fintech` |
| 5 | `marketplace` |
| 6 | `saas,admin-cms-hardening` (enterprise B2B = saas + admin overlay) |
| 7 | `media-content` |
| 8 | `health-sensitive` |
| 9 | `ai-copilot` |
| 10 | `pwa-desktop` |
| 11 | `admin-cms-hardening` |
| 12 | `ai-relay-cost-control` |
| 13 | `member-gated-community-platform` |
| 14 | `self-hosted-supabase-orchestration` |
| 15 | `regulated-saas` |
| 16 | `container-orchestrating-app` |
| 0 | ask user for a free-text sector hint; fall back to `saas` |

---

### SORU 2 — Ödeme var mı? / Payment?

**TR**: Ödeme akışı olacak mı? `[e]vet / [h]ayır` (default=e)
**EN**: Will the product take payments? `[y]es / [n]o` (default=y)

Eğer evet ise alt soru:

```
  [1] Stripe            — global kart + SCA (default for EN-primary)
  [2] Iyzico            — TR pazarı, 3DS, bankalar
  [3] İkisi de / both   — çok bölgeli SaaS (default for TR+EN)
```

Mapping: `--payment=<stripe|iyzico|both|none>`

Default (varsayılan): `both` — Türkiye ağırlıklı kullanıcı tabanında Iyzico + global için Stripe standart kombinasyon.

---

### SORU 3 — Hibrit sistem mi? / Hybrid surfaces?

**TR**: Web dışında mobil uygulama veya bot olacak mı? `[e]vet / [h]ayır` (default=h)
**EN**: Will there be mobile app or bot surfaces beyond web? `[y]es / [n]o` (default=n)

Eğer evet ise çoklu seçim:

```
  [a] has-mobile        — Expo + React Native workspace açılır
  [b] has-bot=telegram  — SP-09 telegram-bot pack aktifleşir
  [c] fastapi-backend   — stack=hybrid, Python servisi workspace'e eklenir
```

Mapping:
- `[a]` → `--has-mobile`
- `[b]` → `--has-bot=telegram`
- `[c]` → `--stack=nextjs-supabase-hybrid` (yerine `nextjs-supabase` olan default değişir)

Çoklu seçim virgüllü kabul edilir (`a,b` gibi).

---

### SORU 4 — Deploy hedefi? / Deploy target?

**TR**: Nereye deploy edeceksin?
**EN**: Where will you deploy?

```
  [1] VPS + Docker Compose + Traefik    — default; SP-06 + SP-13 aktif
                                          (default; activates SP-06 + SP-13)
  [2] Kubernetes + ArgoCD               — SP-02 container-orchestrating-app
                                          (activates SP-02)
  [3] Deploy henüz belirsiz, sadece Docker  — no deploy pattern seeded
                                              (no deploy pattern seeded)
```

Mapping: `--deploy=<traefik|k8s|docker-only>`

Default: `traefik`

---

### SORU 5 — Compliance? / Compliance?

**TR**: Hangi regülasyonlar? Çoklu seçim (virgüllü).
**EN**: Which regulations? Multi-select (comma-separated).

```
  [1] Yok / None (default)
  [2] GDPR                — AB veri koruma
  [3] KVKK                — Türk veri koruma
  [4] COPPA               — çocuk kullanıcılar
  [5] SOC 2               — enterprise trust
  [6] HIPAA               — sağlık/PHI (sektör 8 seçildiyse otomatik)
```

Mapping: `--compliance=<csv>` → `gdpr`, `kvkk`, `coppa`, `soc2`, `hipaa`

Boş ya da `1` → flag yazılmaz.

---

### SORU 6 — Proje adı? / Product name?

**TR**: Proje için kebab-case bir isim ver. Boş bırakırsan `ulak-saas-<YYYYMMDD>` otomatik üretilir.
**EN**: Give the project a kebab-case name. Empty defaults to `ulak-saas-<YYYYMMDD>`.

Mapping: `product_name=<value>`

Validasyon:
- Sadece `[a-z0-9-]`, başı/sonu alfanümerik
- Maks 40 karakter
- İhlal ederse tekrar sor; 3 deneme sonra otomatik default'a düş

---

## Cevapları topla → özet → onay

Tüm cevaplar toplandıktan sonra wizard aşağıdaki özeti gösterir (TR + EN):

```
===============================================
 ULAK OS — SAAS SCAFFOLD ÖZETİ / SCAFFOLD SUMMARY
===============================================
 Proje adı / Name     : <product_name>
 Sektör / Sector      : <--sector=...>
 Ödeme / Payment      : <--payment=...>
 Hibrit / Hybrid      : <flags veya "yok/none">
 Deploy               : <--deploy=...>
 Compliance           : <--compliance=... veya "yok/none">

 Çalıştırılacak komut / Command to dispatch:

   /ulak-scaffold \
     product_name=<name> \
     --sector=<sector> \
     --stack=<stack> \
     --payment=<payment> \
     --deploy=<deploy> \
     [--compliance=<csv>] \
     [--has-mobile] [--has-bot=telegram]

 Onay: [e]vet çalıştır  /  [h]ayır iptal  /  [d]üzenle
 Confirm: [y]es run      /  [n]o cancel     /  [e]dit
===============================================
```

- `e / y` → `/ulak-scaffold` komutunu üretilen flag seti ile dispatch et.
- `h / n` → iptal, artefakt yazma, `reports/current/` altına hiçbir şey bırakma.
- `d / e` → hangi soruyu düzenlemek istediğini sor (`1..6`), o soruyu tekrar çalıştır, özete geri dön.

---

## Defaults referansı / Defaults reference

Her sector için `--payment`, hibrit, deploy, compliance varsayılanları `docs/runtime/wizard-defaults.md` dosyasında tutulur. Kullanıcı boş bırakırsa wizard o tablodan okur.

## Yasaklar / Forbidden

- Gerçek API key / token / secret sorulmaz, kaydedilmez.
- Portfolio / müşteri proje isimlerine referans verilmez (örn: `bayi*`, `ajans*`, `trend*`, `cevap*` varyantları).
- Mevcut olmayan flag uydurulmaz. Geçerli flag listesi `.claude/commands/ulak-scaffold.md` §Inputs bölümünden gelir.

## Hata modu / Failure modes

| Durum / Case | Davranış / Behavior |
|---|---|
| Kullanıcı Q1'de geçersiz sayı verir | Tekrar sor, 3. hatada `[0] Diğer` dalına düş |
| Q6 isim validasyonu 3 kez fail eder | `ulak-saas-<YYYYMMDD>` default'a düş, bildir |
| Sector 8 (sağlık) seçildi ama Q5 HIPAA seçilmedi | Wizard uyarır, HIPAA otomatik ekler |
| Q2 `both` ama locale_primary `tr` değil | Wizard uyarır, `stripe` default'a iner |
| `/ulak-scaffold` dispatch başarısız | Özet + komut string'ini kullanıcıya kopyalanabilir formda göster |

## Post-dispatch

`/ulak-scaffold` bittikten sonra wizard şunları önerir:

1. `cd <product_name>`
2. `pnpm install`
3. `cp .env.example .env.local` (gerçek değerleri el ile doldur)
4. Opsiyonel: Ulak OS üstünden `/director komple` çalıştırarak yeni projenin baseline sağlık skorunu al.

## Integration points

- `.claude/commands/ulak-scaffold.md` — hedef komut; flag seti buradan doğrulanır
- `docs/runtime/wizard-defaults.md` — sector başına varsayılanlar (bu dosyayla birlikte gelir)
- `docs/runtime/sector-packs.md` — sector ID'leri, overlay seçimi
- `docs/runtime/output-profiles.md` — GREENFIELD_BUILDER_PROFILE tetiklenir

## Relationship to /ulak-intake

`/ulak-intake` **mevcut bir repo'yu okur**. `/ulak-start` **yeni repo oluşturur**. İki akış birbirinin yerine geçmez:

- Elinde boş dizin var, yeni SaaS kuruyorsun → `/ulak-start`
- Elinde mevcut kod var, onu anlamak/rescue etmek istiyorsun → `/ulak-intake`

## Vizyon metriği / Vision metric

Bu komut "kullanıcı prompt yazmasın" hedefini %15'ten %85'e taşımak için eklendi. Başarı ölçütü: Kullanıcı 6 cevapla (ortalama < 60 saniye) production-ready scaffold üretebilmeli.

ARGUMENTS:
$ARGUMENTS
