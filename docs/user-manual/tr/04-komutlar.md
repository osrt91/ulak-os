# 04 — Komutlar

Ulak OS v1.0.0 dokuz slash-command ile gelir. Hepsi Claude Code'da `.claude/commands/*.md` olarak yaşar. Codex ve Gemini CLI adapter'ları komutların çoğunu destekler; istisnalar `vendor-parity-exemptions.txt` dosyasında listelenir ve aşağıdaki tablolarda da not düşülür.

Genel kural: **komut çağırın, argüman iletişimi doğal dilde olur.** Örn. `/director komple` ya da `/director komple output_language=tr` geçerlidir.

## Komutların özet listesi

| Komut | Ne yapar | Phase(ler) | Claude | Codex | Gemini |
|---|---|---|---|---|---|
| `/director` | Tam denetim programı (Phase 0→5) | 0,1,2,3,4,4.5,5 | tam | serial-fallback | serial-fallback |
| `/final-verdict` | Mevcut artefaktları yeniden değerlendir | 4.5, 5 | tam | tam | tam |
| `/frontend-war-room` | Frontend/mobil premium redesign | 2, 3, 4 | tam | kısmi | kısmi |
| `/intake` | Proje intake + inventory | 0, 1, 2 | tam | tam | tam |
| `/pack-gap-audit` | Eksik command/skill/agent/hook raporu | 4 | tam | tam | tam |
| `/triage-build` | Kırık build için stack-agnostic triage | 0 | tam | tam | tam |
| `/ulak-design-ref` | Public marka design referansı indir | — | tam | yok | yok |
| `/ulak-intake` | Ulak OS'a özel intake (superpowers'ı isteğe bağlı çağırır) | 0 | tam | yok | yok |
| `/ulak-scaffold` | Greenfield full-stack SaaS iskelet | 0, 4, 5 | tam | tam | tam |

## `/director`

**Ne yapar:** Autonomous-program-director subagent'ını tetikler ve Phase 0'dan Phase 5'e kadar tam programı koşturur. Deep inventory, paralel specialist evidence, mandatory did-you-know layer ve tek manager-verdict üretir.

**Ne zaman kullanılır:**
- "Bu repo'ya baştan bakıp bana ne yapmam gerektiğini söyle" dediğinizde
- Brownfield bir projeyi devraldığınızda
- Bir ürünün release-readiness (yayına hazırlık) skorunu çıkarmak istediğinizde
- Kapsamlı, end-to-end bir denetim talep ettiğinizde

**Argümanlar (tümü opsiyonel, slash prompt sonrasında doğal dilde):**
- `komple` — tam program anlamına gelir (varsayılan)
- `agents=security,seo,i18n,...` — Phase 2'de hangi uzmanların dispatch edileceğini listeler
- `persona=customer,admin,partner` — hangi personaların audit edileceğini belirler
- `output_language=tr|en` — çıktı dili
- `skip_phase_1=true|false` — sadece re-audit için; varsayılan false

**Örnek çağrı:**

```
/director komple output_language=tr
```

**Beklenen çıktı:**

`reports/current/` altında 15 artefakt, sonunda:

```
reports/current/manager-verdict.md — signoff_status: ready | conditional | blocked
reports/current/validation-result.yaml — strukturel signoff
```

Detay: [docs/architecture/director-protocol.md](../../architecture/director-protocol.md).

## `/final-verdict`

**Ne yapar:** Mevcut `reports/current/**` artefaktlarını re-evaluate eder, qa-validation-commander + release-readiness-auditor + red-team-challenger agent'larını sırayla koşturur, tek birleştirilmiş manager verdict üretir.

**Ne zaman kullanılır:**
- Bir önceki director run'ın artefaktları var ama ortam değişti (yeni commit, yeni probe sonucu)
- Bloke edilmiş bir run'ı re-check etmek istediğinizde
- Validation-plan §6 probe'larını elle koşturduktan sonra signoff güncellemek istediğinizde

**Argümanlar:** serbest metin, direktive iletilir (`/final-verdict tüm probe'lar koşuldu, yeniden değerlendir`).

**Beklenen çıktı:**

```
reports/current/validation-plan.md — güncellenmiş
reports/current/manager-verdict.md — yeni signoff
```

## `/frontend-war-room`

**Ne yapar:** frontend-ios-flutter-director + design-system-architect + educational-ux-specialist agent'larını tetikler. Premium redesign'a odaklanan bir "war room" (savaş odası) oturumu açar: visual system temizliği, implementation sırası, design-system master + per-page override artefaktları üretir.

**Ne zaman kullanılır:**
- Bir web veya mobil ürünün UI'ı "amatör / yorgun" göründüğünde
- Tasarım sistemini baştan yazmak istediğinizde
- `ulak-design-ref` ile indirdiğiniz bir markanın design diline hizalamak istediğinizde

**Argümanlar:** serbest metin — mevcut tasarım derdinizi anlatın.

**Beklenen çıktı:**

```
reports/current/analysis-findings.md
reports/current/target-state.md
reports/current/execution-roadmap.md
reports/current/design-system/MASTER.md
reports/current/design-system/pages/*.md
```

**Vendor notu:** Claude Code'da tam destek; Codex ve Gemini'de persona dispatch yarı-serial çalışır, design-system-architect artefact formatı korunur.

## `/intake`

**Ne yapar:** Cartographer agent ve `project-intake` skill'ini tetikler. Sadece intake + inventory + evidence-register aşamalarını koşturur; synthesis, roadmap, verdict yazmaz.

**Ne zaman kullanılır:**
- Bir projeyi sadece "okumak" istediğinizde, müdahale planlamadan
- Executive briefing hazırlarken
- Full `/director` çalıştırmadan önce hızlı bir bakış için

**Argümanlar:** serbest metin.

**Beklenen çıktı:**

```
reports/current/intake.md
reports/current/inventory.md
reports/current/evidence-register.md
```

## `/pack-gap-audit`

**Ne yapar:** Prompt-skill-plugin-governor agent ve `pack-gap-completion` skill'ini tetikler. Mevcut Ulak OS pack'ini inceler ve "hangi command, skill, agent, hook, MCP connector, doc veya eval eksik" sorusuna cevap verir.

**Ne zaman kullanılır:**
- Ulak OS pack'ini kendi domain'inize uyarlarken
- Bir sektöre özgü eksikleri görmek istediğinizde
- Yeni bir rule-pack / sector-pack PR'ı öncesi baseline almak için

**Beklenen çıktı:**

```
reports/current/pack-gap-register.md
reports/current/manager-verdict.md
```

## `/triage-build`

**Ne yapar:** Toolchain-precheck'i koşturur (hangi stack'lerin yüklü olduğunu tespit eder), ardından kırık build'in bulunduğu subsystem'e (frontend / backend / container / mobile) diagnostic komutları dispatch eder.

**Ne zaman kullanılır:**
- CI kırmızı ama neden belli değil
- `pnpm build` / `pytest` / `docker compose up` patlıyor
- Bir yeni hire için onboarding sırasında

**Argümanlar:** serbest metin — "hata bu komutta çıkıyor: ..." gibi.

**Beklenen çıktı:** konsola diagnostik komut dizileri ve çözüm önerileri. Artefakt genelde yazılmaz; büyük triaj ise `reports/current/` altında ad-hoc notlar bırakılabilir.

## `/ulak-design-ref`

**Ne yapar:** `VoltAgent/awesome-design-md` reposundan belirtilen markanın `DESIGN.md` dosyasını indirir (renk paleti, tipografi, bileşen stilleri, layout prensipleri) ve `reports/current/design-references/<brand>/DESIGN.md` altına yazar.

**Ne zaman kullanılır:**
- `/frontend-war-room` öncesi hedef design diline referans indirmek için
- Design-system-architect agent'ına input vermek için
- Ajans işlerinde müşterinin talep ettiği "X markası gibi görünsün" referansını yüklemek için

**Argümanlar:**

```
/ulak-design-ref <brand>
```

Örnekler: `/ulak-design-ref stripe`, `/ulak-design-ref linear`, `/ulak-design-ref vercel`, `/ulak-design-ref notion`.

Mevcut markalar: https://github.com/VoltAgent/awesome-design-md

**Beklenen çıktı:**

```
reports/current/design-references/<brand>/DESIGN.md
```

**Vendor notu:** Claude Code'a özgü. Codex ve Gemini adapter'larında yok — script (fetch-design-references.sh / .ps1) manuel koşturulabilir.

## `/ulak-intake`

**Ne yapar:** Ulak OS'un intake artefakt zincirinin ilk halkasını üretir. Eğer `superpowers:brainstorming` skill'i yüklüyse onu da çağırır; yoksa native intake akışı uygulanır.

**Ne zaman kullanılır:**
- Proje niyetinizi net hale getirmek istediğinizde (`superpowers:brainstorming` ile)
- `/director` çalıştırmadan önce intake.md'yi basitçe üretmek için
- PoC aşamasında — Ulak OS'un "hafif" girişi

**Argümanlar:** serbest metin (kullanıcının projeyle ilgili niyeti).

**Beklenen çıktı:**

```
reports/current/intake.md
```

İçerik altı başlık: project state (GREENFIELD / BROWNFIELD / HYBRID), intervention mode (CREATE / REPAIR / EXTEND / REFACTOR / MIGRATE / RESCUE / REPACKAGE), user intent, success criteria, constraints, out-of-scope.

**Vendor notu:** Claude Code'a özgü. Codex ve Gemini için `/intake` komutu kullanılmalı (superpowers integrasyonu olmadan).

## `/ulak-scaffold`

**Ne yapar:** Greenfield bir full-stack SaaS projesinin iskeletini üretir. Next.js 16 + TypeScript 5 + Tailwind CSS 4 + Supabase + payment provider + i18n + RLS + CI + deploy deseni ile birlikte gelir. 23 sector pack + 8 rule pack + anti-pattern katalogu commit 1'den itibaren yerleşiktir.

**Ne zaman kullanılır:**
- Yeni bir SaaS ürünü başlatırken (brownfield'a ekleme değil)
- Bir ajansın portföyünde tutarlı bir stack istendiğinde
- Governance baseline'ı sonradan değil baştan istendiğinde

**Argümanlar (tümü opsiyonel, etkileşimli sorular gelir):**

```yaml
product_name: "my-saas-product"           # kebab-case
product_domain: "content-ops"             # saas | ecommerce | edtech | fintech | marketplace | content-ops | community | dev-tools
stack_frontend: "nextjs"                  # nextjs | remix | sveltekit
stack_backend: "supabase"                 # supabase | node-fastapi | hybrid
locale_primary: "tr"                      # tr | en
locales_supported: ["tr", "en"]
payment_provider: "iyzico"                # none | stripe | iyzico | both
has_reseller_tier: false
has_admin_surface: true
has_mobile: false
hosting: "self-managed-vps"               # self-managed-vps | vercel | fly | railway
output_path: "../my-saas-product"
```

**Örnek çağrı:**

```
/ulak-scaffold product_name="example-saas" product_domain="saas" payment_provider="stripe" locales_supported=["en","tr"]
```

**Beklenen çıktı:**

`output_path` altında hazır repo:
- `src/` — Next.js App Router + Server Components
- `supabase/` — migrations + RLS policies
- `.github/workflows/` — validate-imports + validate-schemas + gitleaks + dependabot + eval-smoke
- `.env.example` — placeholder değerlerle
- `.claude/settings.json` + `CLAUDE.md` — Ulak OS governance wired
- `infrastructure/` — docker-compose + Traefik labels + kale-kapisi.sh template
- `tests/` — vitest + e2e stub
- `scripts/preflight.sh`, `scripts/install-hooks.sh`

Akış detayı: [docs/architecture/scaffolder-flow.md](../../architecture/scaffolder-flow.md).

## Vendor-parity istisnaları

Şu anda Codex ve Gemini adapter'larında olmayan komutlar:

- `/ulak-design-ref` — awesome-design-md script'i sadece scripts/ altında, Claude Code command yüzeyine bağlı
- `/ulak-intake` — superpowers integration Claude Code'a özgü; Codex/Gemini operatörleri `/intake` kullanmalı

Tam liste: kökte `vendor-parity-exemptions.txt` (eğer mevcutsa) veya [docs/adapters/claude-code.md](../../adapters/claude-code.md) bakın.

## İpuçları

- **Çıktı dilini sabitle:** `output_language=tr` kullanın veya CLAUDE.md'ye `output_language: tr` ekleyin.
- **Dry-run istiyorsan:** `/intake` ile başlayın, sonra `/director komple` ile tam programa geçin.
- **Run'ı arşivle:** Her `/director` çalışmasından önce `mv reports/current reports/archive/$(date +%Y%m%d-%H%M)` yapın.
- **Artefaktları commit'le:** Denetim trail için `reports/current/` altındakileri git history'ye alın; gitleaks bu dizini secret için tarar.

## İlgili belgeler

- [docs/adapters/claude-code.md](../../adapters/claude-code.md) — Claude Code adapter detayları
- [docs/adapters/codex-cli.md](../../adapters/codex-cli.md) — Codex adapter
- [docs/adapters/gemini-cli.md](../../adapters/gemini-cli.md) — Gemini CLI adapter
- [docs/runbooks/first-hour-with-ulak-os.md](../../runbooks/first-hour-with-ulak-os.md) — komutların ardışık kullanım senaryosu

Sonraki bölüm: [05 — İş akışları](./05-is-akislari.md)
