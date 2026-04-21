---
description: 5 fazlı, 27 soruluk interaktif SaaS sihirbazı. Kullanıcı prompt yazmaz; faz başına 4-7 soru, her birinde sensible default, [enter] ile hızlı geçiş. Cevaplar Ulak OS'un 24 sector pack + 8 rule pack + 22 governance + 79 anti-pattern katmanına bağlanır; onayla /ulak-scaffold otomatik dispatch edilir.
description_en: 5-phase, 27-question interactive SaaS wizard. User writes no prompts; 4-7 questions per phase, sensible default on each, [enter] to skip. Answers map to Ulak OS's 24 sector packs + 8 rule packs + 22 governance docs + 79 anti-patterns, then /ulak-scaffold auto-dispatches on confirm.
phases_run: [0]
---

# /ulak-start

> **TR** — "Prompt yazmasın" vizyonunun derin hali. 5 faz, 27 soru, her birinde default.
> **EN** — The deep form of the "no-prompt" vision. 5 phases, 27 questions, default on each.

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
- Boş `[enter]` → sorunun default'unu kabul eder.

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
══════════════════════════════════════════════════════════
 /ulak-start — ÖZET / SUMMARY
══════════════════════════════════════════════════════════

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

 Otomatik eklenenler / Auto-added:
   - <ör: COPPA (sector=education + minors=yes)>
   - <ör: RLS policies (audience=multi-tenant-saas)>
   - <ör: AP-06 admin role re-read (team>=small)>
   - <ör: SP-08 ai-relay-cost-control bundle (sector=ai-copilot)>

──────────────────────────────────────────────────────────

 Çalıştırılacak komut / Command to dispatch:

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

──────────────────────────────────────────────────────────

 [e] Evet, çalıştır              Enter = e
 [h] Hayır, iptal
 [d <soru-no>] Düzenle (örn: d 4.3, d 2.4)
 [/restart] Baştan başla

 Cevabın / Your answer: _
══════════════════════════════════════════════════════════
```

### Onay davranışı / Confirmation behavior

- `[enter]` veya `e` → wizard `/ulak-scaffold` komutunu derlenen flag seti ile **aynı turn içinde
  dispatch eder**. Claude Code üzerinde `/ulak-scaffold ...` satırı slash-komut olarak çağrılır
  (Task tool veya doğrudan slash invocation); başka bir onay beklenmez.
- `h` → iptal. Hiç artefakt yazılmaz. `reports/current/` altına dokunulmaz.
- `d <faz.soru>` (ör. `d 4.3`) → o soruya geri döner, yeni cevap alır, özeti yeniler, onay tekrar
  sorulur.
- `/restart` → Phase 1 Q1.1'e döner; wizard onay ister (`[e]` ile sıfırlama, `[h]` ile mevcut).

---

## Defaults referansı / Defaults reference

- `docs/runtime/wizard-defaults.md` — sector × payment/hybrid/deploy/compliance default matrisi.
- `docs/runtime/sector-packs.md` — sector ID'leri (uydurulmuş sector adı yasak).
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

`/ulak-scaffold` bittikten sonra wizard şunları önerir:

1. `cd <product_name>`
2. `pnpm install`
3. `cp .env.example .env.local` (gerçek değerleri el ile doldur — repo'ya asla commit etme)
4. Opsiyonel: Ulak OS üstünden `/director komple` çalıştırarak yeni projenin baseline sağlık
   skorunu al (14-dimension audit otomatik koşar).

## Integration points

- `.claude/commands/ulak-scaffold.md` — hedef komut; flag seti burada doğrulanır.
- `docs/runtime/wizard-defaults.md` — sector × eksen default matrisi.
- `docs/runtime/sector-packs.md` — sector ID katalogu + overlay detayları.
- `docs/runtime/output-profiles.md` — GREENFIELD_BUILDER_PROFILE tetiklenir.
- `docs/runtime/localization-strategy.md` — Q1.4 locale kararı buraya bağlanır.
- `docs/governance/observability-baseline.md` — Q4.2–Q4.5 kararları.
- `docs/governance/settings-permissions-governance.md` — Q5.1 team boyutu → CI policy.

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
