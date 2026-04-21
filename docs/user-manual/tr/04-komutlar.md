# 04 — Komutlar

> **v1.6 rewrite:** Ulak OS v1.6 ile komut sayısı **9 → 24**'e çıktı. Yeni onboarding + keşif katmanı (`/ulak-hello`, `/ulak-ask`, `/ulak-start`, `/ulak-packs`, `/ulak-search`, `/ulak-demo`, `/ulak-explain`, `/ulak-next-steps`, `/ulak-locale`) ve genişletilmiş yaşam-döngüsü katmanı (`/ulak-audit-deep`, `/ulak-brainstorm`, `/ulak-test-driven`, `/ulak-pattern-extract`, `/ulak-subagent-dispatch`, `/ulak-mcp-discover`) eklendi.

Ulak OS v1.6 yirmi dört native slash-command ile gelir. Hepsi Claude Code'da `.claude/commands/*.md` olarak yaşar. Gemini CLI için `.gemini/commands/*.toml` türevleri `sync-gemini-commands.sh` ile otomatik tutulur. Codex CLI ve Copilot Chat slash primitive'ini desteklemez; o iki vendor'da komutlar **natural-language (NL) trigger map** üzerinden çağrılır — davranış reproducible ama dispatch doğal dille olur.

Genel kural: **komut çağırın veya doğal dilde niyetinizi söyleyin.** `selam ulak` yazmak `/ulak-hello` davranışını tetikler; `hi ulak` aynı şeyi yapar.

## Komut dizini (24 komut)

Komutlar üç katmana ayrılır: **onboarding + keşif** (6), **proje yaşam döngüsü** (17), **meta / governance** (1). Vendor desteği kolonlarında `OK` native, `PART` NL/serial fallback, `MISS` desteklenmez anlamına gelir. Tam matris: [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md).

### A) Onboarding + keşif katmanı

| Komut | Ne yapar (1 satır) | CC | Gemini | Codex | Copilot |
|---|---|---|---|---|---|
| `/ulak-hello` | 30 saniyelik onboarding tour — Ulak OS'u 3 cümlede anlatır, 3 örnek komut gösterir, "ne yapmak istiyorsun?" sorar | OK | OK | OK (NL) | OK (NL) |
| `/ulak-ask` | Doğal dil sorusunu mevcut Ulak komut/skill/agent'ına yönlendirir; belirsizse "did you mean?" disambiguation yapar | OK | OK | PART (NL) | PART (NL) |
| `/ulak-packs` | Tüm Ulak kapasitelerini (24 komut, 10 skill, 27 ajan, 24 sector + 15 overlay, 8 rule, 22 governance, 6 ADR, 4 runbook) tek yerde inline döker | OK | OK | OK (NL inline) | OK (NL inline) |
| `/ulak-search <keyword>` | Ulak OS kapasite katalogunda TR/EN keyword araması; komut/skill/ajan/sector/rule/governance/ADR/runbook/template sonuçlarını birleşik liste olarak döker | OK | OK | PART (NL + Grep) | PART (NL + Grep) |
| `/ulak-demo` | 3 örnek SaaS projesi tanıtır (Minimal SaaS, Marketplace, LMS); scaffold komutu + üretilen dosya sayısı + aktive olan pack'ler + "Ulak'sız kaç gün alırdı" tahmini | OK | OK | OK (NL + Read) | OK (NL + Read) |
| `/ulak-explain <term>` | Bir teknik terimi beginner-friendly 5 alanlı şemada açıklar (Basit / Teknik / Analoji / Ulak'ta / İlgili); lookup kaynağı `docs/runtime/beginner-glossary.md` | OK | OK | OK (NL lookup) | OK (NL lookup) |

### B) Proje yaşam döngüsü katmanı

| Komut | Ne yapar (1 satır) | CC | Gemini | Codex | Copilot |
|---|---|---|---|---|---|
| `/ulak-start` | 5 fazlı, 27 soruluk interaktif SaaS sihirbazı; `[t]` teknik veya `[b]` basit mod; cevaplar sector+rule+governance+anti-pattern katmanına bağlanır; onayla `/ulak-scaffold` dispatch | OK | OK | PART (NL Q&A) | PART (NL Q&A) |
| `/ulak-scaffold` | Greenfield full-stack SaaS iskeleti: Next.js + Supabase + payment + auth + i18n; CI + RLS + deploy + rule/sector pack'ler commit 1'den bağlı | OK | OK | PART (NL + Write) | PART (NL + apply) |
| `/ulak-next-steps` | Scaffold sonrası 8-10 somut adım: pnpm install, .env.local doldurma, Supabase/Iyzico/Resend hesap linkleri, migration, seed, dev, ilk admin, panele giriş | OK | OK | OK (NL inline) | OK (NL inline) |
| `/director` | Otonom Program Director; Phase 0→5 tam denetim; deep inventory + paralel specialist + non-obvious findings + tek manager verdict | OK | OK | PART (NL + serial) | PART (NL + serial) |
| `/ulak-audit-deep` | 14-dimension audit scorecard (Architecture/Testing/Secrets/Observability/CI/CD/Duplication/Dependencies/Type Safety/Plugins/API/Infrastructure/Frontend/Data/Docs); dimension başına 0-100 + A-F | OK | OK | PART (NL + serial) | PART (NL + serial) |
| `/ulak-brainstorm` | Yeni feature için kod yazmadan önce yapılandırılmış ideation; superpowers:brainstorming + Ulak governance; sonucu `docs/superpowers/specs/` altına yazar | OK | OK | PART (NL) | PART (NL) |
| `/ulak-test-driven` | TDD workflow; önce kırık test + geçirme + refactor; superpowers:test-driven-development disipliniyle Ulak evals golden set entegrasyonu | OK | OK | PART (NL + Bash) | PART (NL + terminal) |
| `/ulak-pattern-extract` | Aday kaynak projeden pattern çıkar + T1/T2 evidence ile pattern-import-ledger'a kaydet; native rule-pack/sector-pack/anti-pattern girişi üretir | OK | OK | PART (NL) | PART (NL) |
| `/ulak-subagent-dispatch` | Sınırlı kapsam için N bağımsız subagent'ı paralel dispatch (N-file content, cross-service refactor); superpowers:dispatching-parallel-agents disiplini | OK | PART | PART (NL serial) | PART (NL serial) |
| `/triage-build` | Kırık build'i stack-agnostic triaj et; toolchain-precheck + frontend/backend/container/mobile subsystem diagnostiği | OK | OK | PART (NL + Bash) | PART (NL + terminal) |
| `/frontend-war-room` | Premium redesign war room — frontend-ios-flutter-director + design-system-architect + educational-ux-specialist; visual system temizliği + uygulama sıralaması | OK | OK | PART (NL) | PART (NL) |
| `/ulak-mcp-discover` | Public registry'den MCP server'ları keşfet + trust tier'a göre sınıflandır + governance kapısıyla allowlist önerisi (otomatik kurmaz) | OK | OK | PART (NL) | MISS |
| `/ulak-design-ref <brand>` | awesome-design-md'den bir markanın DESIGN.md'sini indir (palet + tipografi + bileşen stili); `/frontend-war-room` input'u | OK | OK | PART (NL + Bash) | MISS |
| `/intake` | Hızlı intake + inventory; synthesis/roadmap/verdict yazmaz | OK | OK | PART (NL) | PART (NL) |
| `/ulak-intake` | Ulak-özgü intake (project state + intervention mode + intent + success criteria + constraints + out-of-scope); superpowers:brainstorming opsiyonel | OK | OK | PART (NL) | PART (NL) |
| `/final-verdict` | Mevcut `reports/current/**` artefaktlarını re-evaluate et; qa-validation + release-readiness + red-team koşumu; birleşik signoff | OK | OK | PART (NL) | PART (NL) |
| `/pack-gap-audit` | Mevcut operating pack'te eksik command/skill/agent/hook/MCP connector/doc/eval listesi | OK | OK | PART (NL) | PART (NL) |

### C) Meta / governance katmanı

| Komut | Ne yapar (1 satır) | CC | Gemini | Codex | Copilot |
|---|---|---|---|---|---|
| `/ulak-locale` | Ulak OS aktif locale'ini yönetir (TR/EN toggle); `show` mevcut dili gösterir, `tr` veya `en` kalıcı site dilini değiştirir; state `.claude/state/locale.txt` | OK | OK | PART (NL + Write) | PART (NL + apply) |

---

## Detaylı komut referansı

Aşağıdaki bölümler en sık kullanılan komutların detaylarını verir. Tam liste için yukarıdaki üç tabloya bakın.

### `selam ulak` / `hi ulak` — NL entry point

Doğal dil girişi. Her vendor'da `/ulak-hello` davranışını tetikler — NL trigger map burada canlıdır. Başka NL fraz örnekleri:

- `new saas`, `ulak başlat` → `/ulak-start`
- `scaffold my saas`, `benim saas'ımı kur` → `/ulak-scaffold`
- `audit this repo`, `bu repo'yu denetle` → `/director komple`
- `what can ulak do`, `ulak neler yapabilir` → `/ulak-packs`
- `explain rls`, `rls nedir` → `/ulak-explain rls`

Map'in kanonik kaynağı: [docs/adapters/codex-cli.md](../../adapters/codex-cli.md) ve [docs/adapters/copilot-chat.md](../../adapters/copilot-chat.md).

### `/ulak-hello`

**Ne yapar:** 30 saniyelik onboarding tour. Ulak OS'un ne yaptığını 3 cümlede anlatır, 3 örnek komut gösterir, "ne yapmak istiyorsun?" diye sorar.

**Ne zaman kullanılır:** İlk kez Ulak OS açan operatör için; "bu ne ki" sorusuna karşı ilk ekran. `selam ulak` yazmak aynı davranışı verir.

**Argüman:** yok.

### `/ulak-start`

**Ne yapar:** 5 fazlı, 27 soruluk interaktif SaaS sihirbazı. Prompt yazmaz — faz başına 4-7 soru, her birinde sensible default, `[enter]` ile hızlı geçiş. İki mod: `[t]` teknik (default, dev-kitle) veya `[b]` basit (ilk kez SaaS yapan için gündelik dil + inline terim açıklaması, `docs/runtime/beginner-glossary.md`'den beslenir). Cevaplar Ulak OS'un 24 sector pack + 8 rule pack + 22 governance + 79 anti-pattern katmanına bağlanır; onayla `/ulak-scaffold` otomatik dispatch.

**Ne zaman kullanılır:** Sıfırdan yeni bir SaaS ürünü planlarken. İlk kez SaaS yapan biri için basit mod; dev-kitle için teknik mod.

**Argüman:** yok — wizard etkileşimli sürer.

### `/ulak-scaffold`

**Ne yapar:** Greenfield full-stack SaaS iskeleti üretir. Next.js 16 + TypeScript 5 + Tailwind CSS 4 + Supabase + payment provider + i18n + RLS + CI + deploy deseni. 24 sector pack + 8 rule pack + anti-pattern katalogu commit 1'den yerleşik.

**Argümanlar (tümü opsiyonel, etkileşimli sorular gelir — `/ulak-start` zaten cevapladıysa otomatik geçer):**

```yaml
product_name: "my-saas-product"
product_domain: "content-ops"              # saas | ecommerce | edtech | fintech | marketplace | content-ops | community | dev-tools
stack_frontend: "nextjs"                   # nextjs | remix | sveltekit
stack_backend: "supabase"
locale_primary: "tr"                       # tr | en
locales_supported: ["tr", "en"]
payment_provider: "iyzico"                 # none | stripe | iyzico | both
has_reseller_tier: false
has_admin_surface: true
has_mobile: false
hosting: "self-managed-vps"
output_path: "../my-saas-product"
```

**Beklenen çıktı:** `output_path` altında shippable repo — `src/`, `supabase/`, `.github/workflows/`, `.env.example`, `.claude/`, `CLAUDE.md`, `infrastructure/`, `tests/`, `scripts/`.

### `/ulak-next-steps`

**Ne yapar:** Scaffold tamamlandıktan sonra "şimdi ne yapacağım" sorusunu 8-10 somut adımla cevaplar. Kullanıcının `/ulak-start` seçimlerine göre (sector, payment, deploy, email) kişiselleştirilmiş çalıştırma rehberi: pnpm install, .env.local doldurma, Supabase/Iyzico/Resend hesap açma linkleri, ilk migration, seed, pnpm dev, ilk admin kullanıcı oluşturma, admin paneline giriş.

**Beklenen çıktı:** Beginner bu adımları takip edince localhost:3000 açılır ve giriş yapabilir.

### `/director`

**Ne yapar:** Autonomous-program-director subagent'ını tetikler ve Phase 0'dan Phase 5'e kadar tam programı koşturur. Deep inventory, paralel specialist evidence, mandatory did-you-know layer ve tek manager-verdict üretir.

**Argümanlar:** `komple` (tam program, default), `agents=security,seo,i18n,...`, `persona=customer,admin,partner`, `output_language=tr|en`, `skip_phase_1=true|false`.

**Örnek:** `/director komple output_language=tr`

**Beklenen çıktı:** `reports/current/` altında 15 artefakt + `manager-verdict.md` (`signoff_status: ready | conditional | blocked`) + `validation-result.yaml`.

### `/ulak-audit-deep`

**Ne yapar:** Mevcut repo üzerinde 14-dimension audit scorecard. `/director komple`'den daha derin kalite-barı yüzeyler için (Architecture, Testing, Secrets, Observability, CI/CD, Duplication, Dependencies, Type Safety, Plugins, API Design, Infrastructure, Frontend, Data Validation, Documentation). Dimension başına 0-100 skor + A-F grade + target-state + gap analysis.

**Ne zaman kullanılır:** Proje baseline'ları, modernization sonrası doğrulama, quarterly health report, veya `/director komple`'nin `signoff_status: ready` çıktısına ikinci görüş scorecard gerektiğinde.

### `/ulak-ask`

**Ne yapar:** Doğal dil query'yi mevcut Ulak OS komut/skill/agent'ına yönlendirir. "Konuşur gibi kullan" katmanı — plugin aramaz, prompt yazmaz, ne istediğinizi söyler. Anahtar kelime + niyet eşlemesi ile en uygun kapasiteyi önerir; belirsizse "did you mean?" disambiguation.

**Örnek:** `/ulak-ask mevcut projemin tasarımını Stripe'a benzetmek istiyorum` → `/ulak-design-ref stripe` + `/frontend-war-room` önerir.

### `/ulak-packs`, `/ulak-search`, `/ulak-demo`, `/ulak-explain`

- **`/ulak-packs`** → Tüm Ulak OS kapasitelerini (24 komut + 10 skill + 27 agent + 24 sector + 15 overlay + 8 rule + 22 governance + 6 ADR + 4 runbook + 4 tutorial + 3 walkthrough) inline döker. Kaynak: `docs/catalog.md`.
- **`/ulak-search <keyword>`** → TR/EN keyword search. Örn. `/ulak-search payment` → payment-integrated-saas sector + iyzico template + `/ulak-scaffold payment` flag'ini tek ekranda verir.
- **`/ulak-demo`** → 3 örnek SaaS projesi (Minimal SaaS, Marketplace, LMS) + gerçek scaffold komutu + dosya sayısı + aktive olan pack'ler + "Ulak'sız kaç gün alırdı" tahmini.
- **`/ulak-explain <term>`** → Beginner-friendly 5 alanlı şema (Basit / Teknik / Analoji / Ulak'ta / İlgili). Lookup kaynağı `docs/runtime/beginner-glossary.md`. Örn. `/ulak-explain rls`.

### `/ulak-locale`

**Ne yapar:** Ulak OS aktif locale'ini yönetir. `show` mevcut dili gösterir, `tr` veya `en` kalıcı olarak siteyi günceller. State `.claude/state/locale.txt`'de saklanır; README + kullanıcı yüzeyi bu dosyaya göre TR-first veya EN-first seçer.

### Diğer komutlar (özet)

- **`/ulak-brainstorm`** → Yeni feature/ürün/yüzey için kod yazmadan önce ideation. superpowers:brainstorming + Ulak governance sarmalı. Sonucu `docs/superpowers/specs/<date>-<topic>.md`.
- **`/ulak-test-driven`** → TDD workflow (Red-Green-Refactor) + superpowers:test-driven-development + Ulak evals golden set entegrasyonu.
- **`/ulak-pattern-extract`** → Kaynak projeden pattern + T1/T2 evidence + pattern-import-ledger entry + native rule-pack/sector-pack/anti-pattern üretir.
- **`/ulak-subagent-dispatch`** → N bağımsız subagent paralel dispatch (N-file content, cross-service refactor). superpowers:dispatching-parallel-agents disiplini.
- **`/ulak-mcp-discover`** → Public registry'den MCP keşfet + trust tier + allowlist önerisi (otomatik kurmaz).
- **`/ulak-design-ref <brand>`** → `VoltAgent/awesome-design-md`'den marka tasarım referansı. Örn. `/ulak-design-ref stripe`, `/ulak-design-ref linear`.
- **`/ulak-intake`** → Ulak-özgü intake artefaktı (`reports/current/intake.md`). superpowers:brainstorming yüklüyse çağrılır.
- **`/intake`** → Generic intake + inventory + evidence-register; synthesis yok.
- **`/final-verdict`** → Mevcut artefaktlar re-evaluate; qa-validation + release-readiness + red-team.
- **`/pack-gap-audit`** → Eksik command/skill/agent/hook/MCP connector/doc/eval raporu.
- **`/triage-build`** → Kırık build triaj; toolchain-precheck + frontend/backend/container/mobile.
- **`/frontend-war-room`** → Premium redesign; frontend-ios-flutter-director + design-system-architect + educational-ux-specialist.

## Vendor-parity istisnaları

Codex CLI ve Copilot Chat'te slash primitive'i olmadığı için 24 komutun tümü oralarda NL trigger ile çağrılır (PART statüsü). İki komut Copilot'ta MISS:

- **`/ulak-design-ref`** — MCP/Bash bağımlı; Copilot'ta MCP yok.
- **`/ulak-mcp-discover`** — MCP registry query; Copilot'ta MCP yok.

Gemini'de özel iki komut vardır (Claude'da MISS): `/market-scan`, `/war-room` (namespace alias). Tam liste: `.github/vendor-parity-exemptions.txt` + [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md) Tablo B.1.

## İpuçları

- **NL ile başla:** Komut hatırlamıyorsanız doğal dilde yazın — `/ulak-ask` veya NL trigger map dispatch eder.
- **Sihirbazla başla:** `/ulak-start` 27 soruyla sector + rule + payment + deploy seçimlerini yapar; `/ulak-scaffold` otomatik devreye girer.
- **Çıktı dilini sabitle:** `/ulak-locale tr` koşun veya `/director komple output_language=tr` kullanın.
- **Dry-run:** `/intake` ile başlayın, sonra `/director komple`.
- **Run'ı arşivle:** Her `/director` öncesi `mv reports/current reports/archive/$(date +%Y%m%d-%H%M)`.
- **Artefaktları commit'le:** Denetim trail için `reports/current/` git history'ye.
- **`selam ulak` her zaman çalışır:** 4 vendor'da da bu NL entry point `/ulak-hello` davranışını açar.

## İlgili belgeler

- [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md) — 4 vendor × 24 komut matrisi + exemption listesi
- [docs/adapters/claude-code.md](../../adapters/claude-code.md) — Claude Code adapter
- [docs/adapters/gemini-cli.md](../../adapters/gemini-cli.md) — Gemini CLI adapter
- [docs/adapters/codex-cli.md](../../adapters/codex-cli.md) — Codex CLI adapter + NL trigger map
- [docs/adapters/copilot-chat.md](../../adapters/copilot-chat.md) — Copilot Chat adapter + NL trigger map
- [docs/runbooks/first-hour-with-ulak-os.md](../../runbooks/first-hour-with-ulak-os.md) — komutların ardışık kullanım senaryosu
- [docs/walkthrough/01-first-saas-end-to-end.md](../../walkthrough/01-first-saas-end-to-end.md) — 24 komutun uçtan uca senaryosu
- [docs/catalog.md](../../catalog.md) — `/ulak-packs` için inline dump kaynağı

Sonraki bölüm: [05 — İş akışları](./05-is-akislari.md)
