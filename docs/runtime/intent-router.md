# Intent Router — doğal dil → kapasite eşlemesi

Bu dosya `/ulak-ask` komutunun arkasındaki eşleme tablosudur. Operatör doğal dil yazar; router bu tabloya bakarak en uygun mevcut komut/skill/agent'a yönlendirir.

**Kapsam**: 100 intent örneği (50 Türkçe + 50 English). Kapasite listesi değişirse bu tablo senkron tutulur (`/pack-gap-audit` bu parity'yi denetler).

**Kurallar**:
- Sadece gerçek komut/skill/agent'a yönlendirilir (15 komut + 10 skill + 27 agent listesi).
- Skor eşitse **Disambiguation** bölümündeki öncelik uygulanır.
- Hiçbir eşleşme yoksa `/pack-gap-audit` önerilir.

---

## Türkçe intent tablosu (50)

| # | Intent | Matched Capability | Rationale |
|---|---|---|---|
| 1 | "yeni bir SaaS yapacağım" | `/ulak-scaffold` | greenfield + SaaS = scaffolder sector pack |
| 2 | "sıfırdan proje başlatıyorum" | `/ulak-scaffold` | greenfield, CREATE mode, stack pre-wired |
| 3 | "mevcut projeyi baştan aşağı audit et" | `/director komple` | brownfield + full program + tek verdict |
| 4 | "14 boyutlu skorkart lazım" | `/ulak-audit-deep` | 14-dim skill explicit istek |
| 5 | "kalite puanı ne bu repo'nun" | `/ulak-audit-deep` | A-F grade + per-dim score |
| 6 | "auth'ta bug var" | `/ulak-audit-deep` + `superpowers:systematic-debugging` | auth = güvenlik yüzeyi; scorecard + debug |
| 7 | "build patladı" | `/triage-build` | failure triage, stack-agnostic |
| 8 | "ci kırmızı" | `/triage-build` | CI failure = build triage |
| 9 | "test yazdıkça gitmek istiyorum" | `/ulak-test-driven` | TDD discipline |
| 10 | "önce test sonra kod" | `/ulak-test-driven` | TDD explicit |
| 11 | "yeni pattern çıkarayım" | `/ulak-pattern-extract` | pattern-import-ledger flow |
| 12 | "bu projedeki örüntüyü diğerlerine taşı" | `/ulak-pattern-extract` | cross-project propagation |
| 13 | "yeni mcp server arıyorum" | `/ulak-mcp-discover` | MCP registry tarama |
| 14 | "mcp allowlist'e ekle" | `/ulak-mcp-discover` → sonra `mcp-governance-auto` | governance gate |
| 15 | "tasarım referansı lazım" | `/ulak-design-ref` | awesome-design-md indirici |
| 16 | "benchmark için marka taraması" | `/ulak-design-ref` | public brand design reference |
| 17 | "frontend yeniden yapmam lazım" | `/frontend-war-room` | redesign mode |
| 18 | "ui elden geçirilecek" | `/frontend-war-room` | visual system cleanup |
| 19 | "beyin fırtınası yapalım" | `/ulak-brainstorm` | structured ideation |
| 20 | "hangi payment provider seçsem" | `/ulak-brainstorm` | alternative comparison before code |
| 21 | "intake yap" | `/intake` | intake + inventory |
| 22 | "projeyi baştan oku" | `/ulak-intake` | Ulak-specific intake artefaktı |
| 23 | "son verdict ver" | `/final-verdict` | manager-verdict re-evaluation |
| 24 | "ship hazır mı" | `/final-verdict` | release-readiness signoff |
| 25 | "eksik skill/command var mı" | `/pack-gap-audit` | pack-gap-completion çıktısı |
| 26 | "hangi pack eksik" | `/pack-gap-audit` | explicit pack-gap |
| 27 | "paralel ajanlarla böl" | `/ulak-subagent-dispatch` | N subagent parallel dispatch |
| 28 | "N tane şablon üretmem lazım" | `/ulak-subagent-dispatch` | bulk generation |
| 29 | "kurtarma operasyonu" | `/director komple` (RESCUE mode) | rescue intervention |
| 30 | "legacy sistemi taşıyorum" | `/director komple` (MIGRATE mode) | migration program |
| 31 | "secrets sızmış mı" | `/ulak-audit-deep` (dimension: Secrets) | secrets scorecard |
| 32 | "rls kontrolü lazım" | `/director komple` + `security-hardening-lead` agent | tenant isolation audit |
| 33 | "i18n eksikleri" | `/director komple` + `localization-i18n-lead` agent | localization scan |
| 34 | "seo durumu" | `seo-aso-growth-strategist` agent (via `/director komple`) | growth strategist |
| 35 | "pazar araştırması yap" | `market-researcher` agent + `research-currency` skill | market signals |
| 36 | "rakip analizi" | `market-researcher` agent | competitor scan |
| 37 | "database şema gözden geçir" | `data-database-governor` agent | data governance |
| 38 | "kvkk uyum kontrolü" | `privacy-compliance-counsel` agent | TR privacy compliance |
| 39 | "red team saldırısı" | `red-team-challenger` agent | adversarial review |
| 40 | "mobil uygulama planı" | `frontend-ios-flutter-director` agent | mobile strategy |
| 41 | "müşteri tarafını tasarla" | `design-system-architect` + `customer-persona` | customer surface |
| 42 | "admin paneli tasarımı" | `design-system-architect` + `admin-persona` | admin surface |
| 43 | "bayi ekranı tasarımı" | `design-system-architect` + `bayi-persona` | partner/reseller surface |
| 44 | "destek ekibi süreçleri" | `support-ops-orchestrator` + `support-persona` | support ops |
| 45 | "tek dev'in çalışacağı sürüm" | `developer-persona` (via `/ulak-brainstorm`) | dev-oriented spec |
| 46 | "compliance personası gerek" | `compliance-persona` agent | compliance review |
| 47 | "god-module'ı böl" | `god-module-decomposition` skill | strangler fig protocol |
| 48 | "1000 satırlık dosya var" | `god-module-decomposition` skill | monolith decomposition |
| 49 | "awesome pack listesine bak" | `awesome-packs-index` skill | public pack catalog |
| 50 | "pattern ledger'a ekle" | `/ulak-pattern-extract` | ledger registration |

---

## English intent table (50)

| # | Intent | Matched Capability | Rationale |
|---|---|---|---|
| 51 | "I'm starting a new SaaS" | `/ulak-scaffold` | greenfield creation, scaffolder |
| 52 | "scaffold a full-stack starter" | `/ulak-scaffold` | explicit scaffold keyword |
| 53 | "audit the whole repo" | `/director komple` | full-program audit |
| 54 | "give me an A-F grade on this project" | `/ulak-audit-deep` | 14-dim grade output |
| 55 | "quarterly health check" | `/ulak-audit-deep` | periodic scorecard cadence |
| 56 | "something is off in the auth flow" | `/ulak-audit-deep` + `superpowers:systematic-debugging` | unverified symptom → scorecard + debug |
| 57 | "my build is broken" | `/triage-build` | build failure triage |
| 58 | "ci is red" | `/triage-build` | CI failure triage |
| 59 | "write the test first" | `/ulak-test-driven` | TDD discipline |
| 60 | "I want TDD on this feature" | `/ulak-test-driven` | explicit TDD |
| 61 | "extract a reusable pattern" | `/ulak-pattern-extract` | pattern extraction |
| 62 | "propagate this to other projects" | `/ulak-pattern-extract` | cross-project propagation |
| 63 | "find new MCP servers" | `/ulak-mcp-discover` | MCP registry scan |
| 64 | "add an MCP to the allowlist" | `/ulak-mcp-discover` → `mcp-governance-auto` | governance-gated addition |
| 65 | "I need a design reference" | `/ulak-design-ref` | awesome-design-md fetch |
| 66 | "benchmark a public brand visually" | `/ulak-design-ref` | public brand reference |
| 67 | "redesign the frontend" | `/frontend-war-room` | redesign mode |
| 68 | "clean up the visual system" | `/frontend-war-room` | visual cleanup |
| 69 | "let's brainstorm before coding" | `/ulak-brainstorm` | structured ideation |
| 70 | "compare auth strategies" | `/ulak-brainstorm` | alternatives comparison |
| 71 | "run intake first" | `/intake` | intake phase only |
| 72 | "read the project before you touch it" | `/ulak-intake` | Ulak-specific intake |
| 73 | "final verdict please" | `/final-verdict` | signoff re-evaluation |
| 74 | "is this ready to ship" | `/final-verdict` | release-readiness |
| 75 | "what commands am I missing" | `/pack-gap-audit` | pack-gap detection |
| 76 | "what should the pack have" | `/pack-gap-audit` | pack-gap detection |
| 77 | "dispatch N agents in parallel" | `/ulak-subagent-dispatch` | parallel dispatch |
| 78 | "bulk-generate N templates" | `/ulak-subagent-dispatch` | bulk content generation |
| 79 | "rescue this broken project" | `/director komple` (RESCUE mode) | rescue intervention |
| 80 | "migrate from old stack" | `/director komple` (MIGRATE mode) | migration program |
| 81 | "check for leaked secrets" | `/ulak-audit-deep` (Secrets dim) | secrets dimension |
| 82 | "verify tenant isolation" | `/director komple` + `security-hardening-lead` | RLS/tenant audit |
| 83 | "check i18n coverage" | `/director komple` + `localization-i18n-lead` | locale audit |
| 84 | "SEO baseline" | `seo-aso-growth-strategist` (via `/director komple`) | growth audit |
| 85 | "do market research" | `market-researcher` + `research-currency` skill | market engine |
| 86 | "competitor scan" | `market-researcher` | competitor landscape |
| 87 | "review the database schema" | `data-database-governor` | data governance |
| 88 | "privacy/GDPR compliance review" | `privacy-compliance-counsel` | privacy audit |
| 89 | "red-team this design" | `red-team-challenger` | adversarial critique |
| 90 | "mobile app roadmap" | `frontend-ios-flutter-director` | mobile surface strategy |
| 91 | "design the customer surface" | `design-system-architect` + `customer-persona` | customer UX |
| 92 | "design the admin console" | `design-system-architect` + `admin-persona` | admin UX |
| 93 | "design the partner portal" | `design-system-architect` + `bayi-persona` | partner/reseller UX |
| 94 | "support ops playbook" | `support-ops-orchestrator` + `support-persona` | support process |
| 95 | "single-dev-friendly version" | `developer-persona` (via `/ulak-brainstorm`) | dev-oriented scope |
| 96 | "compliance officer review" | `compliance-persona` | compliance persona |
| 97 | "decompose this god module" | `god-module-decomposition` skill | strangler fig |
| 98 | "this file is 2000 lines" | `god-module-decomposition` skill | monolith decomposition |
| 99 | "browse community packs" | `awesome-packs-index` skill | public pack catalog |
| 100 | "register a new pattern" | `/ulak-pattern-extract` | ledger entry |

---

## Disambiguation

Aynı anahtar kelime iki komutu işaret ettiğinde şu öncelik uygulanır:

### "audit" kelimesi
- **Operatör tam program + tek signoff istiyorsa** → `/director komple`
- **Operatör 14-dim skorkart + A-F grade istiyorsa** → `/ulak-audit-deep`
- **Varsayılan** (ipucu yoksa): `/director komple` (komple kelimesi tabloda daha baskın)

### "intake" kelimesi
- **Operatör hızlı ilk bakış istiyorsa** → `/intake`
- **Operatör Ulak OS'a özgü intake artefaktı istiyorsa** → `/ulak-intake`
- **Varsayılan**: `/ulak-intake` (Ulak-native olduğu için)

### "scaffold" / "yeni proje" kelimeleri
- Her zaman `/ulak-scaffold` (tek adaylı)

### "bug" / "hata" / "patladı" kelimeleri
- **Bilinen build/CI failure** → `/triage-build`
- **Bilinmeyen semptom** ("garip", "bir şey oluyor") → `/ulak-audit-deep` + `superpowers:systematic-debugging`
- **Varsayılan**: `/triage-build` (daha somut triaj akışı)

### "pattern" kelimesi
- **Extract/export** → `/ulak-pattern-extract`
- **Browse/search** → `awesome-packs-index` skill
- **Varsayılan**: `/ulak-pattern-extract` (action-oriented)

### "design" kelimesi
- **Public brand reference** → `/ulak-design-ref`
- **Visual system redesign** → `/frontend-war-room`
- **Persona-specific surface design** → `design-system-architect` agent + ilgili persona
- **Varsayılan**: `/ulak-design-ref` (reference araması en yaygın giriş noktasıdır)

### "ship" / "release" / "hazır mı"
- Her zaman `/final-verdict`

### "eksik" / "gap" / "missing"
- Komut/skill/agent kapsamında ise `/pack-gap-audit`
- Evidence kapsamında ise `/director komple` (phase 2 evidence re-run)
- **Varsayılan**: `/pack-gap-audit` (daha hedefli)

### "mcp" kelimesi
- **Yeni MCP keşfi** → `/ulak-mcp-discover`
- **Allowlist hijyeni** → `mcp-governance-auto` skill
- **Varsayılan**: `/ulak-mcp-discover` (discovery önce, governance sonra)

---

## Skor eşitliği durumu

İki kapasite aynı skoru aldığında ve yukarıdaki disambiguation kurallarından hiçbiri doğrudan eşleşmediğinde:

1. Router "did you mean?" listesi verir (max 3 aday).
2. Her aday için tek satır rationale yazar.
3. Operatör seçer. `/ulak-ask` otomatik tetiklemez.

Örnek çıktı:
```
Ambiguous intent. Did you mean:
  1. /director komple   — full program, single verdict
  2. /ulak-audit-deep   — 14-dim scorecard, A-F grade
  3. /intake            — intake phase only (quick first-look)
```

---

## No-match fallback

Skor 0 ise (hiçbir anahtar kelime yakalanmazsa):

```
No capability matched your intent.
Mevcut 15 komut + 10 skill + 27 agent listesine bakmak için:
  - /pack-gap-audit   (eksik kapasite tespit eder; belki gereken şey ekleyelim)
  - README.md         (tam yüzey envanteri)
```

---

## Tablo bakım kuralı

Yeni bir komut veya skill eklendiğinde:

1. Bu tabloya en az 1 TR + 1 EN satır eklenir.
2. Disambiguation bölümü etkileniyorsa güncellenir.
3. `/pack-gap-audit` bu parity'yi denetler: komut var ama tabloda satır yoksa gap olarak işaretler.

## Integration

- `.claude/commands/ulak-ask.md` — bu tabloyu tüketen operatör komutu
- `docs/runtime/router.md` — üst seviye router decision (bu tablo onun insan-arayüzü)
- `docs/runtime/universal-surface-inventory.md` — gerçek kapasite envanteri (tabloya source-of-truth)
- `.claude/commands/pack-gap-audit.md` — parity denetleyici
