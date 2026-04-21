# Ulak OS — Kapasite Kataloğu / Capability Catalog

> **TR** — Ulak OS'un tüm kapasiteleri tek sayfada. Plugin aramaya gerek yok — ne lazımsa buradan seç.
> **EN** — Every Ulak OS capability on one page. No plugin hunting — pick what you need from here.

**Versiyon / Version**: v2.3.0+ · **Son güncelleme / Last updated**: 2026-04-21
**Aramak için / To search**: `/ulak-search <keyword>` · **Hepsini inline görmek için / To see everything inline**: `/ulak-packs`

---

## Özet / Summary

| Kategori / Category | Adet / Count | Kaynak / Source |
|---|---|---|
| Komutlar / Commands | 21 [^1] | `.claude/commands/*.md` |
| Skill'ler / Skills | 10 | `.claude/skills/*/SKILL.md` |
| Ajanlar / Agents | 27 (20 specialist + 7 persona) | `.claude/agents/*.md` |
| Sector overlay kitleri / Sector overlay kits | 15 | `templates/sectors/*/` |
| Sector pack tanımları / Sector pack definitions | 24 | `docs/runtime/sector-packs.md` |
| Rule pack'leri / Rule packs | 8 | `docs/runtime/rule-packs/*.md` |
| Governance dokümanları / Governance docs | 22 | `docs/governance/*.md` |
| ADR'ler / ADRs | 6 | `docs/adr/ADR-*.md` |
| Runbook'lar / Runbooks | 4 | `docs/runbooks/*.md` |
| Scaffolder template'leri / Scaffolder templates | 284 | `templates/` (tüm alt dizinler) |

**Toplam entry / Total entries**: 137 (21+10+27+15+24+8+22+6+4)

[^1]: `scripts/validate-vendor-parity.sh` 23 komut sayar çünkü vendor union'ı ölçer: 21 Claude Code komutu + 2 Gemini-only komut (`market-scan` Claude'daki `market-researcher` ajanına bir sarmalayıcı; `war-room` `frontend-war-room`'un eski adaptör-adı, v2.2 rename ile normalize edilecek — bkz. `.github/vendor-parity-exemptions.txt`). Kullanıcı-yüzlü Claude Code kullanıcıları için gerçek sayı **21**'dir.
      / `scripts/validate-vendor-parity.sh` reports 23 because it measures the vendor union: 21 Claude Code commands + 2 Gemini-only commands (`market-scan` is a wrapper around Claude's `market-researcher` agent; `war-room` is the legacy adapter name for `frontend-war-room`, slated to normalize in v2.2 — see `.github/vendor-parity-exemptions.txt`). For user-facing Claude Code users the real count is **21**.

---

## A) Komutlar (21) / Commands (21)

> Slash komutları — `/komut arg` ile çağrılır. / Invoked as `/command arg`.

| Komut / Command | TR açıklama | EN description | Ne zaman / When |
|---|---|---|---|
| `/director` | Otonom Program Director — tam end-to-end rescue/greenfield/brownfield koşusu | Autonomous Program Director — full end-to-end rescue/greenfield/brownfield run | "komple", tam denetim, rescue |
| `/intake` | Intake + inventory önce — derinlemesine okumadan önce | Intake + inventory first — before deeper work | Proje yeniyse, "oku önce" |
| `/frontend-war-room` | Premium redesign ve görsel sistem temizliği | Premium redesign + visual system cleanup | UI/UX elden geçirme |
| `/pack-gap-audit` | Eksik komut/skill/ajan/hook/MCP raporu | Missing command/skill/agent/hook/MCP report | Kapasite açığı denetimi |
| `/final-verdict` | Final doğrulama + tek birleşik manager verdict | Final validation + single merged manager verdict | Release öncesi kapı |
| `/triage-build` | Kırık build'i toolchain-precheck ile triaj et | Triage broken build via toolchain-precheck | Build/test kırmızı |
| `/ulak-ask <query>` | Doğal dil niyeti mevcut kapasiteye yönlendirir | Natural-language intent router to existing capability | "Konuşur gibi" kullanım |
| `/ulak-start` | İnteraktif SaaS sihirbazı (→ /ulak-scaffold) | Interactive SaaS wizard (→ /ulak-scaffold) | Yeni SaaS, flag ezberlemeden |
| `/ulak-scaffold` | Flag'li tam SaaS scaffolder (Next.js + Supabase + payment) | Full SaaS scaffolder with flags (Next.js + Supabase + payment) | Yeni SaaS, parametrik |
| `/ulak-intake` | Ulak intake artefaktı + opsiyonel brainstorming | Ulak intake artefact + optional brainstorming | Ulak-özgü ilk halka |
| `/ulak-brainstorm` | Kod yazmadan önce yapılandırılmış ideation | Structured ideation before any code | Büyük karar/feature öncesi |
| `/ulak-audit-deep` | 14-dimension scorecard (Arch, Tests, Secrets...) + A-F grade | 14-dimension scorecard + A-F grade | Kalite barı, quarterly health |
| `/ulak-design-ref <brand>` | awesome-design-md'den marka tasarım referansı çek | Pull brand design reference from awesome-design-md | Frontend inspiration |
| `/ulak-pattern-extract` | Başka projeden pattern çıkar, import ledger'a kaydet | Extract pattern from another project, log to import ledger | Portföyde pattern yay |
| `/ulak-mcp-discover` | Public registry'den MCP keşfet, trust tier ile sınıfla | Discover MCP from public registry, classify by trust tier | Yeni MCP değerlendirme |
| `/ulak-subagent-dispatch` | N bağımsız subagent'ı paralel dispatch et | Dispatch N independent subagents in parallel | Büyük paralel iş |
| `/ulak-test-driven` | Red-Green-Refactor TDD + Ulak evals | Red-Green-Refactor TDD + Ulak evals | Ship'lenecek feature/fix |
| `/ulak-locale <tr\|en\|show>` | Aktif locale yönet (TR/EN toggle) | Manage active locale (TR/EN toggle) | Dil değiştirme |
| `/ulak-hello` | 30-saniye onboarding tour | 30-second onboarding tour | İlk kullanıcı, "bu nedir?" |
| `/ulak-packs` | Tüm kapasiteleri inline döker (docs/catalog.md) | Inline dump of all capabilities (docs/catalog.md) | "Her şeyi göster" |
| `/ulak-search <keyword>` | Kapasite kataloğunda TR/EN keyword araması | TR/EN keyword search across capability catalog | "Aradığım şey var mı?" |

---

## B) Skill'ler (10) / Skills (10)

> Subagent fork'ları — ajan + protokol paketi. / Subagent forks — agent + protocol bundle.

| Skill | TR açıklama | EN description | Ne zaman / When |
|---|---|---|---|
| `project-intake` | Intake + inventory + evidence-gathering workflow | Intake + inventory + evidence-gathering workflow | Tam denetim öncesi |
| `research-currency` | Market/rakip/dil sinyali + 2026 barı kontrol | Market/competitor/language signal + 2026 bar check | Currency check |
| `pack-gap-completion` | Eksik reusable unit tespiti (komut/skill/ajan/hook) | Missing reusable unit detection (command/skill/agent/hook) | Kapasite açığı |
| `final-validation` | Release-readiness + residual risk + single verdict | Release-readiness + residual risk + single verdict | Kapanış |
| `fourteen-dimension-audit` | 14-dimension scorecard (0-100/dim + A-F grade) | 14-dimension scorecard (0-100/dim + A-F grade) | Kalite barı |
| `god-module-decomposition` | Strangler Fig protokolüyle 1000+ LOC god module parçala | Strangler Fig decomposition of 1000+ LOC god modules | Monolit dosya |
| `multi-agent-orchestration` | N ajanı merge-sequence ile koordine et (infra→backend→fe→test) | Merge-sequence coordination for N agents (infra→backend→fe→test) | 4+ ajan Waves |
| `saas-scaffolder` | Tam SaaS skeleton + 23 sector pack + 8 rule pack + 79 anti-pattern | Full SaaS skeleton + 23 sector packs + 8 rule packs + 79 anti-patterns | /ulak-scaffold motoru |
| `awesome-packs-index` | Community plugin kataloğu (read-only) + license + trust tier | Community plugin catalog (read-only) + license + trust tier | Plugin düşünme |
| `mcp-governance-auto` | MCP allowlist drift tespiti + reconciliation diff | MCP allowlist drift detection + reconciliation diff | MCP governance |

---

## C) Ajanlar (27) / Agents (27)

### C.1) Specialist / discipline agents (20)

| Ajan / Agent | TR kısa | EN short |
|---|---|---|
| `autonomous-program-director` | Executive manager — tüm programı yönetir | Executive manager — runs the whole program |
| `cartographer` | Repo haritacısı — route/screen/endpoint/config | Repo cartographer — routes/screens/endpoints/configs |
| `architecture-lead` | Principal architect — hedef mimari + migration | Principal architect — target arch + migration |
| `backend-api-architect` | Backend+API specialist — contract, error, integration | Backend+API — contracts, errors, integration |
| `data-database-governor` | Data+DB — schema, migration, integrity, query risk | Data+DB — schema, migration, integrity, query risk |
| `design-system-architect` | Design system — token, spacing, typography, surface | Design system — tokens, spacing, typography, surfaces |
| `frontend-ios-flutter-director` | Premium iOS-first Flutter/mobile redesign | Premium iOS-first Flutter/mobile redesign |
| `educational-ux-specialist` | Eğitim UX — study continuity, motivation, clarity | Education UX — continuity, motivation, clarity |
| `localization-i18n-lead` | i18n/l10n, TR karakterler, locale-aware casing | i18n/l10n, TR characters, locale-aware casing |
| `infra-release-sre` | CI/CD, rollback, release health, observability | CI/CD, rollback, release health, observability |
| `security-hardening-lead` | Auth, authz, admin/customer/public API ayrımı | Auth, authz, admin/customer/public API separation |
| `privacy-compliance-counsel` | Data minimization, disclosure, retention | Data minimization, disclosure, retention |
| `qa-validation-commander` | Test matrix, validation gate, final discipline | Test matrix, validation gate, final discipline |
| `red-team-challenger` | Adversarial reviewer — plan kırar | Adversarial reviewer — breaks the plan |
| `release-readiness-auditor` | Store/distribution/launch quality + blocker | Store/distribution/launch quality + blockers |
| `seo-aso-growth-strategist` | SEO, ASO, analytics, experimentation, growth | SEO, ASO, analytics, experimentation, growth |
| `product-business-strategist` | Product goal, segment, value flow, pricing | Product goal, segment, value flow, pricing |
| `market-researcher` | Rakip, pricing, positioning, kategori beklentisi | Competitor, pricing, positioning, category expectation |
| `support-ops-orchestrator` | Help flow, moderation tooling, deflection | Help flow, moderation tooling, deflection |
| `prompt-skill-plugin-governor` | Command/agent/skill/hook/MCP/plugin/pack-gap | Command/agent/skill/hook/MCP/plugin/pack-gap |

### C.2) Persona-style agents (7)

| Ajan / Agent | TR kısa | EN short |
|---|---|---|
| `customer-persona` | Ödeyen müşteri gözünden onboarding/trust/privacy | Paying customer POV — onboarding/trust/privacy |
| `admin-persona` | İç operatör gözünden permission/audit/bulk ops | Internal operator POV — permission/audit/bulk ops |
| `bayi-persona` | Reseller/partner gözünden white-label/komisyon | Reseller/partner POV — white-label/commission |
| `support-persona` | CS operator gözünden ticket deflection/escalation | CS operator POV — ticket deflection/escalation |
| `developer-persona` | External API consumer gözünden SDK/docs/webhook | External API consumer POV — SDK/docs/webhook |
| `compliance-persona` | Auditor gözünden retention/consent/legal copy | Auditor POV — retention/consent/legal copy |
| `security-redteam` | Saldırgan gözünden bypass/escalation/injection | Attacker POV — bypass/escalation/injection |

---

## D) Sector overlay kitleri (15) / Sector overlay kits (15)

> `templates/sectors/<name>/` — scaffold sırasında seçilen sektöre göre bindirilir. / Overlaid during scaffold based on selected sector.

| Kit | Kime / For | Örnek dosya / Example file |
|---|---|---|
| `admin-cms-hardening` | Admin CMS + moderation | `supabase/migrations/00005_admin_tools_schema.sql` |
| `ai-copilot` | LLM-powered AI asistan ürünleri | `lib/ai/relay.ts` + `lib/ai/cost-cap.ts` |
| `ai-relay-cost-control` | Token bütçe + fallback + attribution | `lib/ai-relay/fallback.ts` + `attribution.ts` |
| `container-k8s` | Kubernetes + ArgoCD deploy | `k8s/base/api-statefulset.yaml` + `argocd-app.yaml` |
| `ecommerce` | E-ticaret + sepet + checkout | `supabase/migrations/00005_ecommerce_schema.sql` |
| `education` | LMS + ödev + quiz | `supabase/migrations/00005_lms_schema.sql` |
| `enterprise-b2b` | SSO (SAML/OIDC) + audit + RBAC | `lib/sso/saml.ts` + `lib/sso/oidc.ts` |
| `fintech` | KYC/AML + ledger + compliance | `lib/compliance/kyc.ts` + `aml.ts` |
| `health-sensitive` | PHI encryption + HIPAA/KVKK sınırı | `lib/phi/encryption.ts` |
| `marketplace` | İki-taraflı marketplace + seller panel | `app/(seller)/layout.tsx` |
| `media-content` | CMS + editorial workflow | `supabase/migrations/00005_cms_schema.sql` |
| `member-gated-community` | Membership + paywall + forum | `supabase/migrations/00005_community_schema.sql` |
| `pwa-desktop` | PWA + offline + install prompt | `lib/pwa/register-sw.ts` + `install-prompt.tsx` |
| `regulated-saas` | GDPR/KVKK + data residency + auto-reports | `docs/compliance/gdpr-kvkk-runbook.md` |
| `self-hosted-supabase` | Kendi sunucunda Supabase orchestration | `docs/runbooks/selfhost-backup-restore.md` |

> **Sector pack tanımları (24)** `docs/runtime/sector-packs.md` içinde: education, saas, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop + SP-01..SP-14 (multi-tenant-supabase, container-orchestrating-app, payment-integrated-saas, regulated-saas, reseller-enabled-saas, vps-nginx-compose-topology, admin-cms-hardening, ai-relay-cost-control, telegram-bot, member-gated-community-platform, multi-app-nextjs-expo-monorepo, self-hosted-supabase-orchestration, multi-project-traefik-edge, greenfield-saas-starter).

---

## E) Rule pack'leri (8) / Rule packs (8)

> Runtime-manifest sinyaline göre otomatik aktive olur. / Auto-activated by runtime-manifest signal.

| Pack | Domain | Tetik / Trigger |
|---|---|---|
| `api-security` | API surface (routes, endpoints, webhooks) | HTTP API varsa |
| `docker-compose` | Docker + Compose | `docker-compose.yml` veya `Dockerfile` varsa |
| `llm-streaming-context-aware` | LLM streaming (SSE/ReadableStream) | LLM SDK + streaming API |
| `localization-ssot` | Çoklu locale SSOT | ≥2 locale varsa |
| `python-fastapi` | Python + FastAPI | `python` + `fastapi` bağımlılığı |
| `react-native-expo` | React Native + Expo mobil | `app.json`/`eas.json` + RN |
| `turkish-locale` | Türkçe locale (i/ı/İ/I + casing) | `tr`/`tr-TR` locale sinyali |
| `typescript-nextjs` | TypeScript + Next.js | `typescript` + `next` |

---

## F) Governance (22) / Governance (22)

> `docs/governance/*.md` — tüm run'larda yüklenen disiplin katmanı. / Discipline layer loaded in every run.

| Doküman / Doc | Özet / Summary |
|---|---|
| `ai-provider-allowlist` | İzinli AI provider listesi + onay kuralları |
| `artefact-write-authorization` | Director protokolünde disk yazma override'ı |
| `autonomy-pressure-layer` | Otonomi baskısı + manager verdict disiplini |
| `evidence-trust-scoring` | T1-T7 trust tier her finding'de zorunlu |
| `finding-schema` | Canonical YAML şeması her finding için |
| `hidden-maintainer-surface-template` | Maintainer-only surface authoring template |
| `hook-governance` | Hook izin, test, rollback kuralları |
| `localization-governance` | Locale SSOT + placeholder + DB column kuralı |
| `lock-file-hygiene` | Lock file commit + drift + denetim |
| `mcp-governance` | MCP allowlist + trust tier + rotation |
| `memory-hygiene` | CLAUDE.md + auto-memory hygiene |
| `observability-baseline` | Logging + metrics + trace min. bar |
| `pattern-import-ledger` | Pattern ithal kaydı + T1/T2 evidence |
| `plugin-skill-decision` | Plugin mi skill mi command mi karar ağacı |
| `product-surface-split` | Customer/admin/public/partner ayrımı |
| `prompt-supply-chain` | Prompt versiyon + denetim zinciri |
| `rule-collision-matrix` | Çakışan iki kural varsa hangisi kazanır |
| `rule-pack-governance` | Rule pack yaşam döngüsü |
| `secrets-rotation-policy` | Secret rotation cadence + revoke |
| `settings-permissions-governance` | settings.json + izin governance |
| `surface-split` | Runtime: public/hidden/maintainer surface |
| `trust-model` | Genel trust model felsefesi |

---

## G) ADR'ler (6) / ADRs (6)

| ADR | Başlık / Title |
|---|---|
| `ADR-000` | Adopt V10.3 Autonomous Program Director Pack |
| `ADR-001` | Rule Packs as the 7th Unit Type |
| `ADR-002` | Phase 5 as the Terminal Phase (Numbering A) |
| `ADR-003` | Product Surface Split Distinct from Runtime Surface Split |
| `ADR-004` | Pattern Import Ledger for Cross-Project Governance |
| `ADR-005` | SaaS Scaffolder: "Ulak OS Produces Full-Stack SaaS from Commit 1" |

---

## H) Runbook'lar (4) / Runbooks (4)

| Runbook | Özet / Summary |
|---|---|
| `first-hour-with-ulak-os` | Kurulumdan 60 dk içinde somut değere — lineer adımlar |
| `install-methods` | 5 farklı kurulum yöntemi (hız/pin/network/team kriteri) |
| `troubleshooting` | Yaygın hatalar + symptom/diagnosis/fix tablosu |
| `upgrading-from-v2.x` | v2.1.3 → v2.4.0+ migration kılavuzu |

---

## Arama / Search

- **Tek keyword ile ara**: `/ulak-search payment` → payment-integrated-saas sector pack + iyzico/stripe template'leri + /ulak-scaffold `--payment` flag
- **Bilingual**: TR veya EN keyword çalışır (`/ulak-search ödeme` = `/ulak-search payment`)
- **Doğal dil niyet**: `/ulak-ask "build patladı"` → /triage-build önerir
- **Hepsini gör**: `/ulak-packs` → bu catalog'ı inline döker

## Dosya yolları / File paths

- Bu katalog / This catalog: `docs/catalog.md`
- Search komutu / Search command: `.claude/commands/ulak-search.md`
- Inline dump komutu / Inline dump command: `.claude/commands/ulak-packs.md`
- Runtime disiplin / Runtime discipline: `prompts/core/ulak-os-core-contract-2.0.0.md`
- Adapter bilgisi / Adapter info: `docs/adapters/claude-code.md`

---

*Last reconciled with disk: 2026-04-21 · Catalog entry source: `.claude/{commands,skills,agents}/`, `templates/sectors/`, `docs/{runtime,governance,adr,runbooks}/`*
