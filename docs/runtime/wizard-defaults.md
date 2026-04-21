# Wizard Defaults — /ulak-start Sector Presets

> **TR**: `/ulak-start` interactive wizard'ında kullanıcı bir soruyu boş bıraktığında bu tablodan okunur. v3.0'da wizard 25-30 soruya / 5 faza genişledi; bu dosya **tüm boyutlar için** sensible default kaynağıdır.
>
> **EN**: When the user leaves a question blank in the `/ulak-start` wizard, the answer is resolved from this table. v3.0 expanded the wizard to 25-30 questions across 5 phases; this file is the authoritative default source for **every axis**.

## Sözleşme / Contract

- Bu dosya `/ulak-start` için authoritative default kaynağıdır.
- Her sector için satır eksikse wizard `saas` satırını fallback olarak kullanır.
- Ekleme / değişiklik yaparken `docs/runtime/sector-packs.md` içindeki sector ID'leri ile birebir eşleşmeli.
- `compliance` alanı CSV; `none` yazıldığında `--compliance` flag'i hiç yazılmaz.
- `hybrid` kolonu virgüllü: `has-mobile`, `has-bot=telegram`, `fastapi-backend`, `none`.
- Boş bırakılamaz: bir boyut için default yoksa **`none`** yazılır — implicit boşluk yasaktır.
- Operator TR context (bu repo operatörü TR) → `language` ve `region` default `tr`; opsiyonel değiştirilir.

## Faz 1 — Temel matrix (payment × hybrid × deploy × compliance)

| Sector ID                              | Soru 1 # | payment default | hybrid default           | deploy default | compliance default | Notes |
|----------------------------------------|----------|-----------------|--------------------------|----------------|--------------------|-------|
| `saas`                                 | 1        | `both`          | `none`                   | `traefik`      | `none`             | Minimal baseline; operatör isterse compliance ekler. |
| `ecommerce`                            | 2        | `stripe`        | `has-mobile`             | `traefik`      | `gdpr`             | Katalog + cart + checkout; EU ticaret için GDPR zorunlu. |
| `education`                            | 3        | `iyzico`        | `has-mobile`             | `traefik`      | `kvkk,coppa`       | LMS / kurs platformu; minor kullanıcılar COPPA + TR pazarı KVKK. |
| `fintech`                              | 4        | `iyzico`        | `none`                   | `traefik`      | `kvkk,gdpr`        | TR odaklı ödeme + düzenleyici. Hybrid default kapalı — önce web regulated hattı. |
| `marketplace`                          | 5        | `both`          | `has-mobile`             | `traefik`      | `gdpr,kvkk`        | 2-sided pazaryeri; mobile alıcı deneyimi standart. |
| `saas,admin-cms-hardening`             | 6        | `stripe`        | `none`                   | `traefik`      | `soc2,gdpr`        | Enterprise B2B; SSO + ekip yönetimi + SOC 2 baseline. |
| `media-content`                        | 7        | `stripe`        | `none`                   | `traefik`      | `gdpr`             | Blog + moderation; düşük compliance yükü. |
| `health-sensitive`                     | 8        | `stripe`        | `has-mobile`             | `k8s`          | `hipaa,gdpr,kvkk`  | PHI taşır; HIPAA overlay zorunlu + k8s izole kontrol. |
| `ai-copilot`                           | 9        | `stripe`        | `none`                   | `traefik`      | `gdpr`             | LLM relay + quota; AI-relay-cost-control overlay otomatik bundle. |
| `pwa-desktop`                          | 10       | `stripe`        | `has-mobile`             | `traefik`      | `none`             | Offline-first; mobile workspace PWA implementasyonunu paylaşır. |
| `admin-cms-hardening`                  | 11       | `none`          | `none`                   | `traefik`      | `soc2`             | Internal tooling; public surface yok, SOC 2 erişim kontrolü. |
| `ai-relay-cost-control`                | 12       | `stripe`        | `none`                   | `traefik`      | `gdpr`             | Token cap + per-tenant quota; ai-copilot ile kombinlenebilir. |
| `member-gated-community-platform`      | 13       | `both`          | `has-mobile,has-bot=telegram` | `traefik` | `gdpr,kvkk`        | Paid tier community; bot + mobile default açık. |
| `self-hosted-supabase-orchestration`   | 14       | `none`          | `none`                   | `docker-only`  | `none`             | Operatör kendi DB infra'sını işletir; payment + deploy pattern ayrı seçilir. |
| `regulated-saas`                       | 15       | `stripe`        | `none`                   | `k8s`          | `gdpr,soc2`        | GDPR + SOC 2 overlay baseline; k8s izolasyon. |
| `container-orchestrating-app`          | 16       | `stripe`        | `none`                   | `k8s`          | `gdpr`             | K8s + ArgoCD yolculuğu için doğmuş. |

## Faz 2 — Platform boyutları (audience × language × region × team-size)

Bu dört boyut sector'dan büyük ölçüde bağımsızdır; audience ve region'da sector-specific override vardır.

| Sector ID                              | audience default      | language default | region default | team-size default |
|----------------------------------------|-----------------------|------------------|----------------|-------------------|
| `saas`                                 | `multi-tenant-saas`   | `tr`             | `tr`           | `small-team`      |
| `ecommerce`                            | `multi-tenant-saas`   | `tr`             | `tr`           | `small-team`      |
| `education`                            | `small-team`          | `tr`             | `tr`           | `small-team`      |
| `fintech`                              | `small-team`          | `tr`             | `eu`           | `small-team`      |
| `marketplace`                          | `multi-tenant-saas`   | `tr`             | `tr`           | `small-team`      |
| `saas,admin-cms-hardening`             | `multi-tenant-saas`   | `tr`             | `eu`           | `small-team`      |
| `media-content`                        | `small-team`          | `tr`             | `tr`           | `small-team`      |
| `health-sensitive`                     | `small-team`          | `tr`             | `eu`           | `small-team`      |
| `ai-copilot`                           | `small-team`          | `tr`             | `tr`           | `small-team`      |
| `pwa-desktop`                          | `small-team`          | `tr`             | `tr`           | `small-team`      |
| `admin-cms-hardening`                  | `small-team`          | `tr`             | `tr`           | `small-team`      |
| `ai-relay-cost-control`                | `small-team`          | `tr`             | `tr`           | `small-team`      |
| `member-gated-community-platform`      | `small-team`          | `tr`             | `tr`           | `small-team`      |
| `self-hosted-supabase-orchestration`   | `small-team`          | `tr`             | `tr`           | `small-team`      |
| `regulated-saas`                       | `multi-tenant-saas`   | `tr`             | `eu`           | `small-team`      |
| `container-orchestrating-app`          | `small-team`          | `tr`             | `tr`           | `small-team`      |

## Faz 3 — Auth + data + storage + email (stack boyutları)

Bu dört boyut tüm sector'ler için aynı default alır. Operator override'sız varsayım = Supabase-merkezli, TR-friendly stack.

| Sector ID                              | auth default                     | database default      | storage default     | email default |
|----------------------------------------|----------------------------------|-----------------------|---------------------|---------------|
| `saas`                                 | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `ecommerce`                            | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `education`                            | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `fintech`                              | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `marketplace`                          | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `saas,admin-cms-hardening`             | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `media-content`                        | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `health-sensitive`                     | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `ai-copilot`                           | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `pwa-desktop`                          | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `admin-cms-hardening`                  | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `ai-relay-cost-control`                | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `member-gated-community-platform`      | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `self-hosted-supabase-orchestration`   | `email+magic-link+google-oauth`  | `self-hosted-postgres`| `minio`             | `resend`      |
| `regulated-saas`                       | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |
| `container-orchestrating-app`          | `email+magic-link+google-oauth`  | `supabase-managed`    | `supabase-storage`  | `resend`      |

## Faz 4 — Observability + ops (analytics × error × uptime × backup × monitoring)

| Sector ID                              | analytics default       | error-tracking | uptime default  | backup default        | monitoring default     |
|----------------------------------------|-------------------------|----------------|-----------------|-----------------------|------------------------|
| `saas`                                 | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `ecommerce`                            | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `education`                            | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `fintech`                              | `plausible-self-host`   | `sentry`       | `better-stack`  | `continuous-wal`      | `grafana-self-host`    |
| `marketplace`                          | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `saas,admin-cms-hardening`             | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `media-content`                        | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `health-sensitive`                     | `plausible-self-host`   | `sentry`       | `better-stack`  | `continuous-wal`      | `grafana-managed`      |
| `ai-copilot`                           | `posthog`               | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `pwa-desktop`                          | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `admin-cms-hardening`                  | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `ai-relay-cost-control`                | `posthog`               | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `member-gated-community-platform`      | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `self-hosted-supabase-orchestration`   | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-self-host`    |
| `regulated-saas`                       | `plausible-self-host`   | `sentry`       | `better-stack`  | `continuous-wal`      | `grafana-managed`      |
| `container-orchestrating-app`          | `plausible-self-host`   | `sentry`       | `better-stack`  | `daily-snapshot`      | `grafana-managed`      |

## Faz 5 — CI + deploy pipeline (ci × preview-deploy)

| Sector ID                              | ci default        | preview-deploy default |
|----------------------------------------|-------------------|------------------------|
| `saas`                                 | `github-actions`  | `yes-if-team-gt-1`     |
| `ecommerce`                            | `github-actions`  | `yes-if-team-gt-1`     |
| `education`                            | `github-actions`  | `yes-if-team-gt-1`     |
| `fintech`                              | `github-actions`  | `yes-if-team-gt-1`     |
| `marketplace`                          | `github-actions`  | `yes-if-team-gt-1`     |
| `saas,admin-cms-hardening`             | `github-actions`  | `yes-if-team-gt-1`     |
| `media-content`                        | `github-actions`  | `yes-if-team-gt-1`     |
| `health-sensitive`                     | `github-actions`  | `yes-if-team-gt-1`     |
| `ai-copilot`                           | `github-actions`  | `yes-if-team-gt-1`     |
| `pwa-desktop`                          | `github-actions`  | `yes-if-team-gt-1`     |
| `admin-cms-hardening`                  | `github-actions`  | `yes-if-team-gt-1`     |
| `ai-relay-cost-control`                | `github-actions`  | `yes-if-team-gt-1`     |
| `member-gated-community-platform`      | `github-actions`  | `yes-if-team-gt-1`     |
| `self-hosted-supabase-orchestration`   | `github-actions`  | `yes-if-team-gt-1`     |
| `regulated-saas`                       | `github-actions`  | `yes-if-team-gt-1`     |
| `container-orchestrating-app`          | `github-actions`  | `yes-if-team-gt-1`     |

> `yes-if-team-gt-1` = team-size > 1 ise `yes` force (cross-cutting rule), aksi halde `no`.

## Sector-specific deep defaults (Faz 6)

Her sector için 3 dar boyut. `saas` minimal branch taşımaz; sector-deep boyutu yoktur.

### `education`
| Axis              | Default  | Rationale |
|-------------------|----------|-----------|
| sync-lessons      | `false`  | Video-infra maliyetli; opt-in. |
| certifications    | `true`   | LMS beklentisi; PDF + imza. |
| assessments       | `true`   | Kurs akışının temel bloğu. |

### `fintech`
| Axis              | Default  | Rationale |
|-------------------|----------|-----------|
| kyc-provider      | `sumsub` | TR ticari fit iyi; multi-language. |
| aml               | `true`   | Regülasyon zorunlu. |
| baas-licensed     | `false`  | Çoğu builder lisanssız başlar; API partner ile ilerler. |

### `ecommerce`
| Axis                  | Default  | Rationale |
|-----------------------|----------|-----------|
| inventory             | `true`   | Fiziksel stok takibi standart. |
| subscription-products | `false`  | Opt-in (recurring Stripe komplike). |
| digital-goods         | `false`  | Opt-in (lisans + DRM ayrı layer). |

### `health-sensitive`
| Axis              | Default  | Rationale |
|-------------------|----------|-----------|
| phi-encryption    | `true`   | Force — PHI baseline. |
| baa-required      | `true`   | HIPAA zorunlu; 3rd-party BAA şart. |
| telemedicine      | `false`  | Video + state-licensing ekstra; opt-in. |

### `ai-copilot`
| Axis                  | Default             | Rationale |
|-----------------------|---------------------|-----------|
| rag                   | `true`              | Grounding; hallucination azaltır. |
| cost-cap-per-user     | `10-usd-per-day`    | Abuse guardrail. |
| fallback-model        | `anthropic-haiku`   | Primary down / cost spike → haiku. |

### `marketplace`
| Axis              | Default  | Rationale |
|-------------------|----------|-----------|
| commission-rate   | `0.10`   | 10% pazar standardı. |
| escrow            | `false`  | Çoğu MVP escrow yok; opt-in. |
| dispute-flow      | `true`   | 2-sided için zorunlu. |

### `member-gated-community-platform`
| Axis                  | Default         | Rationale |
|-----------------------|-----------------|-----------|
| tiered-membership     | `true`          | Monetization core. |
| moderation-queue      | `true`          | Topluluk sağlığı. |
| feed-type             | `chronological` | Algorithmic feed daha sonra opt-in. |

### `saas,admin-cms-hardening` (enterprise-b2b)
| Axis            | Default                | Rationale |
|-----------------|------------------------|-----------|
| sso-providers   | `google,azure,okta`    | B2B çoğunluk. |
| scim            | `false`                | Small team skips; opt-in. |
| team-roles      | `admin,member,viewer`  | Minimal RBAC seti. |

### `media-content`
| Axis                  | Default                    | Rationale |
|-----------------------|----------------------------|-----------|
| publishing-workflow   | `draft-review-published`   | Editoryal üç kademe. |
| comment-moderation    | `true`                     | Spam + toxicity guardrail. |
| cdn                   | `cloudflare`               | Ücretsiz tier + TR edge. |

### `saas` (minimal)
| Axis        | Default  | Rationale |
|-------------|----------|-----------|
| sector-deep | `none`   | Branched question yok — base minimal. |

### `pwa-desktop`
| Axis                  | Default  | Rationale |
|-----------------------|----------|-----------|
| offline-first         | `true`   | PWA değer önerisi. |
| background-sync       | `true`   | Conflict-free yazma. |
| push-notifications    | `false`  | iOS PWA kısıt; opt-in. |

### `admin-cms-hardening`
| Axis                  | Default  | Rationale |
|-----------------------|----------|-----------|
| impersonation         | `true`   | Support flow; audit'li. |
| audit-log             | `true`   | SOC 2 baseline. |
| four-eyes-approval    | `false`  | Opt-in; high-risk ops için açılır. |

### `ai-relay-cost-control`
| Axis                  | Default                | Rationale |
|-----------------------|------------------------|-----------|
| per-tenant-quota      | `true`                 | Multi-tenant abuse guardrail. |
| fallback-chain        | `haiku,sonnet,opus`    | Escalate path. |
| billing-integration   | `stripe`               | Default billing; iyzico TR tarafı override. |

### `self-hosted-supabase-orchestration`
| Axis              | Default           | Rationale |
|-------------------|-------------------|-----------|
| supabase-version  | `latest-stable`   | Güvenlik güncellemesi çizgisi. |
| backup-tool       | `pg_dump-cron`    | Minimal + yaygın. |
| upgrade-cadence   | `quarterly`       | Breaking change absorb süresi. |

### `regulated-saas`
| Axis                      | Default      | Rationale |
|---------------------------|--------------|-----------|
| data-residency-enforce    | `true`       | Compliance tabanı. |
| audit-retention           | `7-years`    | SOC 2 + finance typical. |
| compliance-reports        | `quarterly`  | Auditor ritmi. |

### `container-orchestrating-app`
| Axis              | Default       | Rationale |
|-------------------|---------------|-----------|
| orchestrator      | `kubernetes`  | Pattern beklentisi. |
| gitops            | `argocd`      | Declarative deploy. |
| service-mesh      | `none`        | Operatör opt-in; baseline'ı şişirme. |

## Faz 0 — Wizard rendering modu / Wizard rendering mode

`/ulak-start` v3.1+ iki render modu taşır: **teknik** (dev-kitle için, mevcut davranış) ve **basit** (ilk kez SaaS yapan için gündelik dil + inline `[Anlamı]` açıklama). Bu eksen tek bir soruya (Q0) bağlıdır ve sector'dan bağımsızdır — tüm sector'ler için aynı default alır.

| Axis          | Default     | Kabul edilen değerler    | Rationale |
|---------------|-------------|--------------------------|-----------|
| `wizard_mode` | `technical` | `technical` \| `beginner` | `[enter]` ile default seçilebilir olmalı — mevcut dev-kullanıcı için davranış aynı kalır. Beginner açıkça `b` seçerek girer; sessizce değişmez. |

### Mod davranış farkı / Mode behavior diff

| Davranış / Behavior               | `technical`                 | `beginner`                                                    |
|-----------------------------------|-----------------------------|---------------------------------------------------------------|
| Soru başlığı / Question heading   | Sadece teknik TR/EN         | Teknik başlık + gündelik dil karşılığı yan yana               |
| Seçenek render                    | Tek blok (teknik isim)      | İki blok: `[Teknik mod]` + `[Basit mod]` + "Ne seçmeliyim?"   |
| Post-answer feedback              | `✓ Seçim kaydedildi`       | `✓` + `[Anlamı]` mini-açıklama (glossary'den) + `[Neden default]` |
| Terim kaynağı                     | Inline kısa not              | `docs/runtime/beginner-glossary.md` (40+ terim, 5-alanlı şema) |
| Seçenek numaraları                | 1, 2, 3...                   | 1, 2, 3... (değişmez — mod arası geçiş cevabı korur)          |
| Dual-render protokol              | Kapalı                       | `.claude/commands/ulak-start.md` §Dual-render protokolü       |

### Mode-switch davranışı / Mode switch behavior

- `/mode t` veya `/mode b` herhangi bir Q-soru'sunda kullanılabilir
- Mod değişimi **cevapları kaybetmez** — yalnızca ekrandaki gösterim karşılığa döner (seçenek numaraları 1:1 eşleşir)
- Basit mod'da kullanıcı bir terimi derinlemesine anlamak isterse `/ulak-explain <term>` bağımsız komutu ile 5-alanlı tam şema render edilir

### Glossary bağımlılığı / Glossary dependency

- Basit mod'da gösterilen her `[Anlamı]` açıklaması otorite olarak `docs/runtime/beginner-glossary.md`'den gelir
- Glossary'de olmayan bir terim wizard'da görünürse önce glossary'e append-only satır eklenir, sonra wizard'da kullanılır
- 40 terim mevcut seed; `/ulak-start` kullandığı tüm teknik terimler burada olmak zorunda

---

## Cross-cutting rules

Bu kurallar default matrisinin **üstüne** uygulanır; çakışma olursa kural kazanır.

1. **Region `tr`** → `compliance` listesine otomatik `kvkk` ekle (yoksa).
2. **Region `eu`** → `compliance` listesine otomatik `gdpr` ekle (yoksa).
3. **Audience `multi-tenant-saas`** → `admin-cms-hardening` overlay otomatik bundle.
4. **Payment `stripe` + region `tr`** → wizard uyarır: "TR kart kabulü için Iyzico tavsiye edilir; `stripe+iyzico` hybrid değerlendirilsin." Operatör onaylarsa geçer.
5. **Team-size >1** → `preview-deploy` = `yes` force.
6. **Sector `health-sensitive`** → `compliance` = `hipaa` force + `phi-encryption` = `true` force.
7. **Sector `ai-copilot`** → `ai-relay-cost-control` overlay auto-bundle.
8. **Sector `fintech`** → `backup` = `continuous-wal` force + KYC boyutu zorunlu (atlanamaz).
9. **Sector `marketplace`** → `dispute-flow` = `true` force.
10. **Sector `education` + audience içinde minors** → `compliance` listesine `coppa` force.
11. **Deploy `k8s`** → `monitoring` = `grafana-managed` otomatik (self-host operasyonel yük fazla).
12. **Compliance `soc2`** → `audit-retention` min `1-year` force; daha kısa değer reddedilir.
13. **Database `self-hosted-postgres`** → `backup` = `continuous-wal` recommend (warn, zorlamaz).
14. **Auth `SSO` (enterprise)** → `scim` = `true` recommend (warn, zorlamaz).
15. **Sector 9 (`ai-copilot`)** seçildiğinde `ai-relay-cost-control` overlay'i `--sector` listesine silent eklenir (duplicate rule 7 operasyonel).
16. **`payment=both`** fakat `compliance` içinde `gdpr` yoksa wizard uyarır; operatör reddederse kabul eder.
17. **`compliance=coppa`** tek başına yazılmaz; her zaman başka bir compliance ile birlikte (çocuk kullanıcılar için ek katman).

## Extension protocol

Yeni bir sector pack eklendiğinde (`docs/runtime/sector-packs.md`'ye satır geldikten sonra):

1. **Faz 1 matrix**'ine yeni satır ekle (sector ID birebir aynı).
2. **Faz 2-5 matrix'lerine** aynı sector için satır ekle — `audience`, `language`, `region`, `team-size`, `auth`, `database`, `storage`, `email`, `analytics`, `error-tracking`, `uptime`, `backup`, `monitoring`, `ci`, `preview-deploy`. Boş bırakma — fallback `saas` satırıdır ama explicit default yaz.
3. **Sector-specific deep default** (Faz 6) tablosuna 3 boyutlu bölüm ekle. Sector taşımıyorsa `sector-deep: none` tek satır yaz.
4. `Soru 1 #` kolonuna `/ulak-start` menüsündeki numarayı yaz; menü sabit kalsın diye yeni numara sonuna eklenir.
5. **Cross-cutting rules**'a gerekiyorsa satır ekle (force / recommend ayrımına dikkat).
6. `.claude/commands/ulak-start.md` içindeki mapping tablosunu güncelle.
7. Yeni boyut (axis) eklenirse bu dosyaya yeni bir **Faz N** bölümü aç; 16 sector × yeni axis = 16 entry zorunlu.

## Carries

Bu dosya `docs/runtime/` altında tutulur çünkü **runtime davranışını** şekillendirir (wizard kararı). Governance kuralı değildir; bu yüzden `docs/governance/` altında değildir.

v3.0 genişleme notu: `/ulak-start` 6 sorudan 25-30 soruya / 5 faza büyüdüğünde bu dosya tek default otoritesi oldu. Wizard prompt'u bu dosyadan okur; yeni flag eklendiğinde önce burada satır açılır, sonra wizard'a bağlanır.
