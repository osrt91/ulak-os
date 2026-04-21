# FAQ

Frequently-asked questions about Ulak OS — what it is, who it is for, how it differs from adjacent tools, and what it is honestly **not**.

---

## What is Ulak OS?

Ulak OS is a **vendor-neutral prompt operating system** that sits on top of AI coding CLIs (Claude Code, Codex / Copilot, Gemini CLI). One core contract, three vendor adapters. It does three things in a single pack: **audit** (the `/director` protocol — 27 specialist agents, 15-dimension scorecard, ~100-entry anti-pattern catalog with 19 numbered AP-NN items), **govern** (22 governance docs + 24 sector packs + 8 rule packs loaded every session), and **scaffold** (`/ulak-scaffold` produces a shippable full-stack SaaS at commit 1).

## Who is it for?

Four personas, roughly in order of how much value they extract in week 1:

1. **Solo developer starting a new SaaS.** Runs `/ulak-scaffold` once and ships a Next.js + Supabase + payment + i18n + CI + deploy project with 8 anti-patterns already gated by construction.
2. **Small team inheriting a brownfield.** Runs `/director komple` for a deep audit — inventory, evidence register, persona-split findings, target state, execution roadmap, validation plan, manager verdict.
3. **Agency running multiple client projects.** Uses the pattern-import ledger and sector packs as institutional memory; every project inherits the same governance baseline.
4. **Incumbent-refactor lead** modernizing a legacy monolith. Uses god-module-decomposition, Strangler Fig protocol, and the Waves pattern to sequence risky refactors.

## How is it different from `superpowers`?

`superpowers` is a **skill bundle** — a collection of sharp, narrow skills (brainstorming, systematic-debugging, writing-plans) that you opt into. Ulak OS is the layer above that: a **full prompt OS** with a protocol (Phase 0 → Phase 5 director), governance surface (22 docs that gate decisions), a scaffolder, and multi-vendor adapters. The two are complementary — Ulak OS happily invokes `superpowers:brainstorming` during Phase 2 when a domain design decision needs it.

## How is it different from `everything-claude-code`?

`everything-claude-code` is a **command/skill bundle** — a convenience pack of slash commands and skills. Ulak OS adds three layers on top: (a) a manager-verdict validation gate that refuses premature "done", (b) a governance surface (trust tiers, pattern-import ledger, artefact-write authorization), and (c) a greenfield scaffolder. If you want "more commands", use the former; if you want "a protocol that refuses to let you ship premature work", use Ulak OS.

## How is it different from `cartographer`?

`cartographer` is **one agent** that produces a deep system map. Ulak OS **absorbs that capability** as Phase 1 of the director protocol and runs it in parallel with 12+ other specialists. If all you need is a file-and-line inventory of an unfamiliar codebase, cartographer is lighter; if you want the inventory plus evidence, findings, target state, roadmap, and signoff, Ulak OS is the superset.

## Can I use it without Claude Code?

Yes. The core contract is vendor-neutral — the same `@`-import chain loads under Claude Code, Codex/Copilot (via `AGENTS.md`), and Gemini CLI (via `.gemini/commands/*.toml`). Some commands are Claude-first (e.g., `/frontend-war-room` depends on specific Claude Code agent dispatch semantics); those appear in `vendor-parity-exemptions.txt` with a rationale. The audit and scaffold flows work on all three.

## Is it safe for production use?

Yes, with one caveat: Ulak OS never ships code to production on its own — it is a prompt layer. What it does guarantee:

- Every finding carries a trust tier (T1–T7, see `docs/governance/evidence-trust-scoring.md`).
- The validation gate refuses "ready" when live probes fail.
- The scaffolder gates 8 anti-patterns by construction (single auth helper, server-only guards, DB-sourced role, RLS symmetry, `.gitignore` discipline, gitleaks baseline, health-probe webhook, VPS hardening).
- All artefacts land in your repo under `reports/current/` — auditable after the fact.

Production risk is **your** risk on your code — Ulak OS raises the floor but does not remove the ceiling.

## Does it work on Windows?

Yes. Tested on Windows 11 with PowerShell 5.1+. Installer: `scripts/install.ps1`. The `ulak` command ships as `ulak.cmd` that dispatches to `bin/ulak.ps1`.

## Does it work on macOS?

Yes. Tested on macOS with zsh (default) and bash. Installer: `scripts/install.sh`. The `ulak` command ships as a POSIX shell wrapper under `~/bin/ulak`.

## Does it work on Linux?

Yes. Tested on Ubuntu 22.04 / 24.04 and Fedora. Installer: `scripts/install.sh`. Same POSIX wrapper as macOS.

## What's the license?

[MIT](../LICENSE). Fork it, adapt it, apply it to your own operations. Attribution is enough.

## How do I contribute?

Read [CONTRIBUTING.md](../CONTRIBUTING.md). The short version: new sector packs / anti-patterns / rule packs all require **file:line citations from ≥2 real projects** (abstract descriptors if the projects are private). Every cross-project pattern lift gets an entry in `docs/governance/pattern-import-ledger.md` with a trust tier ≥ T2.

## How do I report a security issue?

Do **not** open a public GitHub issue for security problems. Email the maintainer directly (address listed in `CODE_OF_CONDUCT.md`). Expect a response within 72 hours.

## Does it store my code anywhere?

No. Ulak OS is a static prompt pack. All audit artefacts are written to `reports/current/` **inside your own repo**. Nothing phones home. No telemetry. The only network activity is (a) the one-time `git clone` during install and (b) whatever your AI coding CLI does with its own provider.

## Which LLM models does it support?

- **Primary:** Claude (any model available to Claude Code — Opus, Sonnet, Haiku).
- **Supported via adapter:** Gemini (via Gemini CLI), GPT family (via Codex / Copilot).
- **Model-agnostic in principle:** the core contract is plain markdown. Any agent that respects `@`-imports and can dispatch subagents will work, with varying fidelity.

The director protocol works best when the model supports parallel subagent dispatch. On models without parallel tool use, the director falls back to serial dispatch with a context-budget warning.

## Can I run it offline?

**Partially.**

- Install: requires network (git clone).
- Audit / scaffold: offline-capable as long as your AI coding CLI can run offline. Ulak OS itself makes no network calls.
- MCP connectors: anything that talks to a remote MCP (GitHub, Jira, Figma) is network-bound; those connectors are optional and skipped when env vars are absent.

Hermetic audits are explicitly supported — `docs/runtime/toolchain-precheck.md` flags any agent that tries to make a network call during a marked-offline run.

## Does it support non-Turkish locales?

Yes. The default locale is Turkish (the project's origin), but the localization-SSOT rule pack enforces ≥2 locales on any scaffolded project. English is first-class; other locales inherit from the SSOT. Pack docs are bilingual (`README.md` Turkish, `README.en.md` English) — the rest of the runtime is neutral.

## What does "Ulak" mean?

"Ulak" is Turkish for "messenger" / "courier". The project is a messenger between your intent and your AI coding CLI — it carries governance, context, and validation discipline across the gap.

## What Ulak OS is NOT

Honest list:

- **Not an IDE or editor.** It sits above your AI coding CLI, not beside your editor.
- **Not a model.** It does not train or fine-tune anything. Your provider chooses the model; Ulak OS shapes the prompt.
- **Not a linter.** Anti-patterns are gating prompts, not AST-level rules. For AST linting use your stack's native tools.
- **Not a CI platform.** CI jobs shipped under `.github/workflows/` are examples; a real CI choice is yours.
- **Not a runtime (the code kind).** It does not execute your application.
- **Not a replacement for reading the code.** The director produces evidence, not absolution — review the artefacts.
- **Not done.** v3.0 is the first fully-public release; the scaffolder has 24 sector packs today and will grow; persona dispatch has 7 personas and will grow. This is a living pack.

## How often is it updated?

Approximately every 1-2 weeks during the v3.x series. The canonical source of truth is `CHANGELOG.md` + `git log`. Tags follow [semantic versioning](../VERSIONING.md): MAJOR for breaking contract changes, MINOR for append-only additions (the common case), PATCH for fixes.

## Where can I see a demo?

Walkthroughs land in `docs/showcase/` as they are written. Text-based tours (terminal output, artefact samples) are in `docs/runbooks/first-hour-with-ulak-os.md`.

## Do I have to speak Turkish to use it?

No. The project's origin is Turkish (and some runtime rule files retain Turkish imperatives — e.g., "validation olmadan done deme" = "do not say done without validation"), but the user-facing surface is bilingual. Every command accepts English arguments; every artefact is produced in whatever language your AI coding CLI session is running in. If you only read English, stick to `README.en.md` and you miss nothing material.

## How much context does Ulak OS consume?

The core contract is ~33 runtime rule files + 22 governance docs + 8 rule packs + whichever sector pack the router picks — typically 30-60k tokens loaded at session start. That leaves plenty of room on 200k / 1M-context models. If you are on a narrower context window (e.g., 128k), the `output-profiles.md` rule file lets you select a lighter profile (AUDIT vs GREENFIELD_BUILDER etc.) that loads only the relevant runtime rules.

## Will it respect my existing CI and workflow?

Yes. Ulak OS never mutates your CI or workflow files without explicit instruction. The scaffolder **creates** `.github/workflows/` files for greenfield projects; the director **reads** them and reports findings. If you want Ulak OS to propose CI changes for an existing project, it produces a diff in `reports/current/execution-roadmap.md` — you apply it, not the agent.

## How do I uninstall?

Depends on install method — see `docs/runbooks/install-methods.md` §Uninstall for each path. Short answer for the one-liner install:

```bash
rm -rf ~/.ulak-os ~/bin/ulak
```

Your projects' `CLAUDE.md` files still have `@`-imports pointing at the install dir. Either remove those lines or re-run the installer to reconnect.

---

## Beginner — İlk kez site yapacak olanlar

> Bu bölüm ilk hafta operatörleri için. Kod tecrübesi ≤ orta seviyede olanlara yönelik sorular ve cevaplar. Tüm cevaplar TR-primary, repo'daki somut dosya/komutlara referans verir.

### Ulak OS'u kullanmak için kod bilmek gerekir mi?

Kısa cevap: **Kısmen.** Tamamen kod bilmeyen birisi `/ulak-start` ile wizard'ı tamamlayıp `/ulak-scaffold`'u çalıştırabilir; çıktı **çalışan bir proje iskeleti** olur (Next.js + Supabase + auth + i18n + CI). Ama:

- `.env.local` dolduracak — Supabase URL/anahtarı yapıştırabilecek kadar hesap açma
- `pnpm install && pnpm dev` çalıştırabilecek kadar terminal
- Hata mesajı gelince Claude Code'a soracak kadar "durumu anlatma"

bilmek gerekir. "Tek tuşla çıkar" değil — "3 saatte çalışan skeleton" diye düşün.

### `/ulak-start` çalıştırdım, 27 soru soruyor — çok mu?

Hayır, ama hepsine cevap vermek zorunda değilsin. Her soru için `[enter]` = **sensible default**. 27 soru 5 faza bölünmüştür (Product / Stack / Business / Integration / Ops). Tipik operatör 10-12 soruya aktif cevap verir, gerisini enter'lar. Wizard 6-8 dakikada biter.

Eğer 27 soru bile çoksa `/ulak-scaffold` flag'li versiyonunu doğrudan kullan — örn. `/ulak-scaffold --name myapp --sector saas-starter --locale tr`.

### Scaffold sonrası `.env.local` dosyası boş. Ne yazacağım?

Scaffold `.env.local.example` dosyası üretir — şablon. Gerçek `.env.local`'i sen dolduracaksın, çünkü secret'lar senin hesaplarına ait. Adımlar:

1. **Supabase**: `supabase.com` → New project aç → Settings → API → `Project URL` ve `anon key`'i kopyala → `NEXT_PUBLIC_SUPABASE_URL` ve `NEXT_PUBLIC_SUPABASE_ANON_KEY` alanlarına yapıştır.
2. **Iyzico/Stripe** (payment seçtiysen): Iyzico için sandbox → API Keys → `IYZICO_API_KEY` + `IYZICO_SECRET_KEY`. Stripe için dashboard → Developers → API keys.
3. **Resend** (email): `resend.com` → API Keys → `RESEND_API_KEY`.

Detay + linkler için: `/ulak-next-steps` (scaffold sonrası 8-10 adımı kişiselleştirilmiş olarak dökerek verir).

### Supabase nedir, Firebase'in alternatifi mi?

Supabase = açık kaynaklı backend hizmeti. Database (Postgres), auth, storage, realtime bir arada. Firebase'e alternatif olarak doğdu, ama Postgres tabanlı olması + açık kaynak olması + self-host edilebilir olması ile ayrışıyor.

Ulak OS'ta **default backend**. `/ulak-explain supabase` komutu 5 alanlı açıklama verir (basit / teknik / analoji / Ulak'ta / ilgili).

### Iyzico hesabı nasıl açılır?

`iyzico.com` → Üye ol → TR TC/şirket bilgileri → sandbox hesap otomatik açılır (onaylanırken günler sürebilir). Sandbox'ta test kart numarası ile (`5890 0400 0000 0016`) simulate kredi kartı çalışır.

Production'a geçmek için onay gerekir: şirket kimliği + banka hesabı + vergi numarası. TR merkezli iş için Stripe'dan daha uygun. Detay: `/ulak-explain iyzico`.

### localhost:3000 ne demek, canlı site nasıl olur?

`localhost:3000` = senin bilgisayarında çalışan site. İnternet'ten kimse göremez, sadece senin chrome'un açar. Geliştirme için böyle.

Canlı (internetten erişilebilir) hale gelmesi için **deploy** gerekir. Ulak scaffold iki seçenek sunar:
- **Vercel**: `git push` → `vercel.com/new` → GitHub repo bağla → otomatik deploy. Ücretsiz başlar. Önerilen: beginner için.
- **VPS + Traefik**: Kendi sunucunu kiralar, Docker Compose + Traefik edge ile deploy. Kontrol fazla, sorumluluk da fazla. Aylık 5-20 USD VPS + zaman.

`/ulak-explain localhost` ve `/ulak-explain vercel` / `/ulak-explain vps` detay verir.

### Vercel vs VPS — hangisini seçmeliyim?

Kriterler:
- **Beginner + hızlı ship**: Vercel. 10 dakikada canlı.
- **Düşük bütçe + uzun vadeli**: VPS. Aylık 5 USD'a başlayabilir.
- **Trafik tahmin edilemez + hızlı scale**: Vercel (serverless).
- **Tam kontrol (kendi DB, kendi cron, hassas data)**: VPS.
- **TR data residency zorunlu (KVKK)**: TR-based VPS (Hetzner FRA hariç; İstanbul DC arayan için yerli sağlayıcı).

Ulak OS her iki pattern'i de destekler; scaffold sırasında `--deploy vercel` veya `--deploy vps` seçersin.

### Ödeme aldığımda vergi + KDV meselesi?

Ulak OS yazılım katmanıdır — **vergi mevzuatı tavsiyesi vermez**. Gerçek cevap: bir mali müşavire sor. Ama genel bilgi:

- TR'de şahıs şirketi / LTD ŞTİ açman gerekir (ödeme almak için)
- KDV (%20, yazılım/hizmet) + gelir/kurumlar vergisi
- Iyzico/Stripe ödeme alırken fatura kesme yükümlülüğü sende
- e-Fatura / e-Arşiv zorunluluğu belirli ciroda

Ulak scaffold'da `regulated-saas` sector overlay'i KVKK compliance için yardımcıdır (vergi için değil). Mali meseleler operatörün sorumluluğunda.

### Yazılımsız birisi bu projeyi kullanabilir mi?

Sınırlı. Ulak OS operatör-yönlü bir araç — **AI ile konuşan** bir insan lazım. Fakat o insan backend + frontend + DevOps ayrı ayrı bilmek zorunda değil; Claude Code yardımıyla yapabilir.

Pratik eşik: "Bir terminalde komut çalıştırabilirim, hata mesajını Claude'a kopyalayıp yapıştırabilirim" seviyesi yeterli. Hiç terminal görmemiş bir kullanıcı için şu an zor — ileride `/ulak-hello` gibi onboarding surface'ları büyüyecek.

### Ben bitirdim ama tasarım basit. Nasıl güzelleştiririm?

Üç seçenek:
1. `/frontend-war-room` komutu — Ulak OS'un premium redesign akışı. design-system-architect + frontend-ios-flutter-director ajanları paralel çalışır, token/spacing/typography/surface elden geçirir.
2. `/ulak-design-ref <brand>` — `awesome-design-md`'den bir markanın tasarım referansını çeker, frontend ajanlara dayanak verir. Örn: `/ulak-design-ref stripe`.
3. Manuel tasarımcı tutma + Tailwind tweak. Ulak scaffold `shadcn/ui` variant'ı base olarak koyar; üstüne custom theme eklemek standart iş.

---

## Beginner — Terim demistifikasyonu

> "Bu kelimeyi ilk kez duyuyorum" dediğin zaman bak. Her terim için detay: `/ulak-explain <term>` komutunu çalıştır — 5 alanlı açıklama verir (Basit / Teknik / Analoji / Ulak'ta / İlgili).

### JWT nedir?

**JSON Web Token.** Kullanıcı giriş yaptıktan sonra server'ın verdiği dijital kimlik kartı — sonraki her istekte bu kartı gösterirsin, "giriş yapmıştım" diye kanıtlarsın. Ulak'ta Supabase Auth JWT üretir. `/ulak-explain jwt` detaylı.

### RLS nedir?

**Row Level Security** — Postgres'in "bu satırı bu kullanıcı görebilir" kuralı. Database seviyesinde filtre. Ulak OS scaffold'da tenant-specific tablolarda default aktif. `/ulak-explain rls`.

### Tenant nedir?

Aynı uygulamayı paylaşan ama verileri birbirinden izole müşteri. 100 tenant = 100 ayrı şirket, tek uygulama. Ulak'ta multi-tenant disiplin `tenant_id` kolon + RLS policy ile sağlanır. `/ulak-explain tenant`.

### Migration nedir?

Database şemasını değiştirmek için tarihli SQL dosyaları. `supabase/migrations/00001_init.sql` → `00005_lms_schema.sql`. Versiyon kontrolü + rollback için gerekli. `/ulak-explain migration`.

### `i18n` ne?

`internationalization` (18 harf, başı I, sonu N, arada 18 → i18n). Çoklu dil desteği. Ulak'ta localization-ssot rule pack default. ≥2 locale zorunlu. `/ulak-explain i18n`.

### `.env.local` nedir?

Gizli ayarları (şifre, API anahtarı) koda değil bu dosyaya yazdığın yer. `.gitignore` içinde olur, repo'ya commit edilmez. `NEXT_PUBLIC_` prefix'li olanlar client'a açılır. `/ulak-explain env-local`.

### Webhook nedir?

Bir sistemden başka sisteme olay bildiren HTTP callback. Örn. Stripe ödeme tamamlandığında sana POST atar — "ödeme geldi, sipariş onayla". Ulak scaffold'da idempotency + signature verification zorunludur (AP-13). Detay: `docs/runtime/rule-packs/api-security.md`.

### Pnpm nedir, npm'den farkı ne?

`pnpm` = Package Manager, npm/yarn alternatifi. Disk'te daha az yer kaplar (symlink-based), daha hızlı install yapar, monorepo'ya daha uygun. Ulak scaffold default pnpm ile gelir. Alternatif istersen `package.json` stil aynı, komutlar değişir (`pnpm install` vs `npm install`).

### Monorepo ne?

Birden fazla proje/paketin tek bir git repo'da durduğu yapı. Ulak'ta `templates/monorepo-root/` + `templates/shared-packages/` var; örn. web + mobile + shared types tek repo'da. Tekil proje için gereksiz, 2+ paket varsa anlamlı.

### Docker Compose ne?

Birden çok container'ı (örn. web + database + redis) tek `docker-compose.yml` dosyasıyla başlatıp durduran araç. Ulak scaffold local dev için compose dosyası üretir. VPS deploy'da Traefik + compose pattern'i önerilir (bkz. `docs/runtime/rule-packs/vps-nginx-compose-topology.md`).

### CI nedir, neden gerekli?

**Continuous Integration.** Her git push'ta otomatik çalışan testler/linter/typecheck. Ulak scaffold `.github/workflows/ci.yml` ile gelir: typecheck + test + build + (opsiyonel) gitleaks. "Lokalimde çalışıyor" dedirtmez, repo'daki herkese aynı kapıyı kurar.

### OAuth nedir?

"Google ile giriş yap" / "GitHub ile giriş yap" dediğin zaman arkada çalışan protokol. Kullanıcı şifresini sana vermez, Google sana "bu kullanıcı Ali" diye token gönderir. Ulak'ta Supabase Auth OAuth provider'ları (Google, GitHub, Apple) config ile açılır.

### Seed data ne?

Boş bir database'i "çalışır örnek veriyle" dolduran initial insert'ler. `supabase/seed.sql`. Örn: admin kullanıcı, örnek kurs, örnek ürün. Development için zorunlu, production'da opsiyonel.

### Supabase anon key güvenli mi, public'e koyabilir miyim?

`NEXT_PUBLIC_SUPABASE_ANON_KEY` **client'a açılır** — `NEXT_PUBLIC_` prefix'i tam bu yüzden. Kendi başına bir tehlike değil; RLS policy'leri bu anahtarla gelen istekleri kısıtlar. **Ama**: `service_role` key'ini **asla** client'a veya repo'ya koyma — o admin anahtarıdır. `/ulak-explain env-local` + `docs/governance/secrets-rotation-policy.md`.

### KVKK nedir, ben de mi uyacağım?

6698 sayılı Kişisel Verilerin Korunması Kanunu. TR'de kullanıcı verisi işleyen herkes uymak zorunda. Aydınlatma metni, açık rıza, silme hakkı, VERBİS kaydı. Ulak OS'ta `regulated-saas` sector overlay'i KVKK runbook + auto-report üretici içerir. Yasal tavsiye değil — gerçek uyumluluk için avukat/danışman gerekir. `/ulak-explain kvkk`.

### Auth vs Authz farkı?

- **Authentication** (auth) = "Sen kimsin?" (giriş)
- **Authorization** (authz) = "Ne yapabilirsin?" (yetki)

Supabase Auth + RLS, bu iki katmanı birlikte işler. Örn: Ali giriş yaptı (auth), ama admin paneli sadece `role = 'admin'` olanlara açık (authz).

