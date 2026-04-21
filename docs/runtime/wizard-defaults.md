# Wizard Defaults — /ulak-start Sector Presets

> **TR**: `/ulak-start` interactive wizard'ında kullanıcı bir soruyu boş bıraktığında bu tablodan okunur. Her sector için 4 boyutta sensible default tanımlıdır: **payment**, **hybrid surfaces**, **deploy target**, **compliance**.
>
> **EN**: When the user leaves a question blank in the `/ulak-start` wizard, the answer is resolved from this table. Each sector carries sensible defaults for four axes: **payment**, **hybrid surfaces**, **deploy target**, **compliance**.

## Sözleşme / Contract

- Bu dosya `/ulak-start` için authoritative default kaynağıdır.
- Her sector için satır eksikse wizard `saas` satırını fallback olarak kullanır.
- Ekleme / değişiklik yaparken `docs/runtime/sector-packs.md` içindeki sector ID'leri ile birebir eşleşmeli.
- `compliance` alanı CSV; `none` yazıldığında `--compliance` flag'i hiç yazılmaz.
- `hybrid` kolonu virgüllü: `has-mobile`, `has-bot=telegram`, `fastapi-backend`, `none`.

## Default matrix

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

## Cross-cutting rules

- **Sector 8 (`health-sensitive`)** seçildiğinde Q5'te HIPAA yoksa wizard otomatik ekler (data safety önceliği).
- **Sector 9 (`ai-copilot`)** seçildiğinde `ai-relay-cost-control` overlay'i `--sector` listesine silent olarak eklenir.
- **Sector 13 (`member-gated-community-platform`)** default'unda `has-bot=telegram` açık; kullanıcı Q3'te [h]ayır derse bu kısım sessizce kapanır.
- **`deploy=k8s`** seçildiğinde wizard SP-02 + SP-13'ü aynı anda aktive eder (`--deploy=k8s` → scaffold-manifest.md).
- **`payment=both`** fakat `compliance` içinde `gdpr` yoksa wizard uyarır; operatör reddederse kabul eder.
- **`compliance=coppa`** tek başına yazılmaz; her zaman başka bir compliance ile birlikte (çocuk kullanıcılar için ek katman).

## Extension protocol

Yeni bir sector pack eklendiğinde (`docs/runtime/sector-packs.md`'ye satır geldikten sonra):

1. Bu dosyaya yeni satır ekle (sector ID birebir aynı).
2. 4 eksen için sensible default belirle (boş bırakma — fallback `saas` satırıdır).
3. `Soru 1 #` kolonuna `/ulak-start` menüsündeki numarayı yaz; menü sabit kalsın diye yeni numara sonuna eklenir.
4. Cross-cutting rules'a gerekiyorsa satır ekle.
5. `.claude/commands/ulak-start.md` içindeki mapping tablosunu güncelle.

## Carries

Bu dosya `docs/runtime/` altında tutulur çünkü **runtime davranışını** şekillendirir (wizard kararı). Governance kuralı değildir; bu yüzden `docs/governance/` altında değildir.
