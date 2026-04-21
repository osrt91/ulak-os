# 01 — Giriş

> **Sürüm:** v1.6 (24 komut, 4 vendor, walkthrough + tutorial + beginner-glossary katmanları canlı)
> Bir önceki v1.0.0 GA'da 9 komut + tek vendor (Claude Code) tam destekliydi. v1.6 ile komut sayısı **9 → 24**'e, desteklenen vendor sayısı **1 → 4**'e (Claude Code + Gemini CLI + Codex CLI + Copilot Chat) çıkmıştır. Aşağıdaki açıklamalar bu güncel surface'e göredir.

## Ulak OS nedir?

Ulak OS, AI destekli kod yazma CLI'larının (Claude Code, Gemini CLI, Codex CLI, GitHub Copilot Chat) üzerinde çalışan bir **vendor-neutral prompt operating system** (satıcıdan bağımsız prompt işletim sistemi) kütüphanesidir. Tek bir core contract (çekirdek sözleşme) dosyası ve dört satıcıya uygun adapter (uyumlayıcı) katmanıyla gelir. Amacı: bir AI agent'ına (temsilciye) iş yaptırırken ondan beklediğiniz disiplini, kanıt standardını ve validation (doğrulama) kapılarını metin dosyaları olarak sisteme yüklemektir.

"Ulak" Türkçede "haberci / kurye" anlamına gelir. Proje, sizin niyetiniz ile AI CLI'ınız arasındaki haberci rolünü üstlenir: governance (yönetişim), context (bağlam) ve validation disiplinini aradaki boşluğa taşır. Kod yazmaz, IDE değildir, bir model de değildir — sadece model davranışını şekillendiren, disiplin uygulayan bir prompt paketidir.

## v1.6'nın üç yeni vizyon katmanı

v1.0 "Ulak OS'u bilen operatör" için tasarlanmıştı. v1.6 "Ulak OS'u daha önce duymamış operatör" için üç yeni katman ekler. Bu katmanlar doğal dil giriş + self-serve keşif + guided onboarding etrafında örülür:

1. **Konuşma katmanı** — `/ulak-ask` doğal dil sorusunu en uygun Ulak yeteneğine yönlendirir. `selam ulak` veya `hi ulak` yazmak `/ulak-hello`'yu tetikler (30 saniyelik tour). "Plugin arama, söyle" vizyonunun operasyonel karşılığıdır.
2. **Keşif katmanı** — `/ulak-packs` (24 komut + 10 skill + 27 ajan + pack taxonomy'sinin inline dökümü), `/ulak-search <kelime>` (TR/EN keyword arama), `/ulak-demo` (3 örnek SaaS projesi çalıştırma), `/ulak-explain <term>` (beginner-glossary lookup). Operatör plugin marketplace gezmez; sistem kendi yeteneğini kendi gösterir.
3. **Onboarding katmanı** — `/ulak-start` 5 fazlı, 27 soruluk interaktif wizard; `[t]` teknik / `[b]` basit mod seçimi ile hem developer hem ilk-kez-SaaS-yapan operatörü karşılar. Bitince `/ulak-scaffold` otomatik dispatch edilir. Ardından `/ulak-next-steps` 8-10 somut adımla localhost:3000'e kadar götürür. `/ulak-locale` ile TR/EN toggle kalıcıdır.

Tüm yirmi dört komutun özet listesi ve vendor desteği: [04-Komutlar](./04-komutlar.md).

## Üç temel kapasite

Ulak OS her oturumda aynı üç şeyi yapar:

1. **Audit (denetim)**: `/director` protokolü altında mevcut bir projeyi derinlemesine okur. Phase 0'dan Phase 5'e kadar süren altı fazlı program sayesinde inventory (envanter), evidence (kanıt), findings (bulgular), target-state (hedef durum), roadmap (yol haritası) ve manager-verdict (yönetici kararı) artefaktlarını `reports/current/**` altına yazar. İkinci görüş scorecard için `/ulak-audit-deep` 14-dimension audit üretir.

2. **Govern (yönet)**: 22 governance dosyası, 24 sector pack (sektör paketi), 15 sector overlay, 8 rule pack (kural paketi) ve 79+ anti-pattern (kaçınılması gereken desen) katalogu her oturumda yüklenir. Bu paketler "neyi kabul edilmez sayacağız" kurallarını tanımlar: evidence olmadan iddia yok, validation olmadan "done" yok, customer / admin / public-API ayrımını bozan kod yok.

3. **Scaffold (iskelet kurma)**: `/ulak-scaffold` komutu ile sıfırdan çalışan, ticari üretim kalitesinde bir full-stack SaaS projesinin iskeletini üretir. Next.js + TypeScript + Supabase + payment (ödeme) + auth (kimlik doğrulama) + i18n (çoklu dil) + CI + deploy deseni commit 1'den itibaren yerleşik gelir.

## Vendor-neutral çerçeve — 4 CLI

Ulak OS'un core contract dosyası (`prompts/core/ulak-os-core-contract-2.0.0.md`) satıcıdan bağımsız, saf metindir. Aynı dosya dört farklı CLI tarafından yüklenebilir:

| Vendor | Status | Nasıl bağlanır | Fark |
|---|---|---|---|
| **Claude Code** | FULL | `CLAUDE.md` → `@`-import | Tam destek; paralel subagent dispatch Phase 2'de kullanılır. 24 native slash komutu. |
| **Gemini CLI** | FULL-MINUS | `.gemini/commands/*.toml` | 24 komutun 24'ü çalışır; bazıları NL/serial fallback. Uzun-context senaryolarında güçlü. |
| **Codex CLI** | CORE | `AGENTS.md` reading-order + NL trigger map | Native slash yok; 22 komut NL trigger ile, 4 inline. Artefakt zinciri reproducible. |
| **Copilot Chat (VS Code)** | LIMITED | `.github/copilot-instructions.md` | Read-heavy komutlar OK; 2 MCP-bağımlı komut MISSING (`/ulak-design-ref`, `/ulak-mcp-discover`). |

Tam matris + 8 kapasite kriteri: [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md). Adapter notları: [docs/adapters/claude-code.md](../../adapters/claude-code.md), [codex-cli.md](../../adapters/codex-cli.md), [copilot-chat.md](../../adapters/copilot-chat.md), [gemini-cli.md](../../adapters/gemini-cli.md).

## Pack-unit taksonomisi (7 tip)

Ulak OS'un içindekiler yedi kategoriye ayrılır. Her kategori belirli bir dosya düzeniyle sürer:

| Kategori | Ne yapar | Nerede yaşar |
|---|---|---|
| **Commands** | Operatörün tetiklediği slash-komutları (ör. `/director`, `/ulak-scaffold`, `/ulak-ask`) | `.claude/commands/*.md` (24 dosya) |
| **Skills** | Tekrar kullanılabilir, çok adımlı iş akışları | `.claude/skills/**/SKILL.md` (10 skill) |
| **Agents** | Uzmanlık personaları (security, infra, cartographer vb.) | `.claude/agents/*.md` (27 agent) |
| **Hooks** | CI / git hook'ları ile prompt disiplinini zorlayan scriptler | `.claude/hooks/`, `scripts/` |
| **Sector packs** | Bir sektöre özgü kurallar (e-ticaret, fintech, LMS vb.) | `docs/runtime/sector-packs.md` (24 pack + 15 overlay) |
| **Rule packs** | Bir teknolojiye özgü kural kümeleri (Next.js, FastAPI vb.) | `docs/runtime/rule-packs/*.md` (8 pack) |
| **Runtime rules** | Çekirdek disiplin dosyaları (router, phases, context budget) | `docs/runtime/*.md` |

Bunlara ek olarak **governance docs** (22 dosya — vendor-capability-matrix + localization-governance v1.6'da eklendi), **ADR** (7 adet: ADR-000 → ADR-005 + yeni), **runbook** (4 adet) ve v1.6'da eklenen **tutorial** (4 servis: Supabase, Vercel, GitHub, Resend) + **walkthrough** (3 sürüm: Claude / Codex / Copilot variant'ları) vardır. Governance, runtime ile çakıştığında governance galibiyeti kazanır (bkz. `docs/governance/rule-collision-matrix.md`).

## Kimler için?

Dört tipik persona (kullanıcı profili):

### 1. Solo geliştirici — yeni bir SaaS başlatan

Haftalık 1-2 akşam ayırabilen, tek başına ticari bir ürün inşa eden bir geliştirici. `/ulak-start` ile 27 soruluk wizard'ı çalıştırır (basit moddan başlayabilir), `/ulak-scaffold` ile commit 1'den ticari kalitede iskelet alır: auth, ödeme, i18n, RLS (Row-Level Security) politikaları, CI/CD ve deploy deseni yerleşik gelir. Ardından `/ulak-next-steps` localhost:3000'e kadar götürür. Tipik kazanım: ilk haftayı "boilerplate (temel kalıp) yazmak" yerine ürünü düşünmekle geçirir. Detay: [walkthrough 01](../../walkthrough/01-first-saas-end-to-end.md).

### 2. Küçük takım — devralınmış bir projeyi denetleyen

3-5 kişilik bir takım, eski sahibi ayrılmış veya dışarıdan devralınmış bir kod tabanına bakmak zorunda. `/director komple` ile bir günlük bir derin denetim koşar. Çıktı: envanter (dosya+satır bazlı), persona kırılımlı bulgular, risk sıralaması, yol haritası ve "hazır / şartlı / bloke" şeklinde manager-verdict. İkinci görüş için `/ulak-audit-deep` 14-dimension scorecard üretir.

### 3. Ajans — birden fazla müşteri projesi yöneten

Ajansın governance baseline'ı (taban disiplini) her projede ortak olmalı. Ulak OS'un **pattern-import-ledger** (desen ithal kütüğü) bu institutional memory (kurumsal bellek) işini üstlenir — bir projede öğrenilen bir desen `/ulak-pattern-extract` ile T1/T2 evidence taşıyarak `docs/governance/pattern-import-ledger.md` altına kaydedilir ve sonraki projelere `/ulak-scaffold` üzerinden aktarılır.

### 4. Brownfield rescue lead — monolit modernizasyonu

Bir legacy monolit (tek-parça eski kod tabanı) içinde 1000+ satırlık "god module" (tanrı-modül) dosyaları var. `god-module-decomposition` skill'i Strangler Fig protokolünü uygular: orijinal dosya shim (ince yeniden-dışa-aktarım katmanı) haline getirilir, sorumluluk alt-modüllere dağıtılır, her adım atomik bir commit olur. Waves pattern ile 4+ agent paralel çalışırken merge (birleştirme) sırası korunur.

## Kimler için DEĞİL?

Ulak OS'un ne olmadığını açıkça söylemek de önemli:

- **IDE / editör değil.** Sizin editörünüzün yanında değil, AI CLI'ınızın üstünde oturur.
- **Model değil.** Hiçbir model eğitmez, fine-tune yapmaz.
- **Linter değil.** Anti-pattern'ler AST seviyesinde çalışan kurallar değildir — prompt düzeyinde gate'lerdir.
- **CI platformu değil.** `.github/workflows/` altında örnekler gelir; gerçek CI seçimi size kalmış.
- **Runtime değil.** Uygulamanızı çalıştırmaz.
- **Kod okumanın yerine geçmiyor.** Director evidence üretir; affetme belgesi değil.

## Neyle karıştırmayın?

- **`superpowers`** tekil yetenekler paketidir (brainstorming, systematic-debugging gibi). Ulak OS'un bir katman üstüdür; ikisi birlikte çalışabilir — `/ulak-brainstorm` superpowers:brainstorming skill'ini Ulak governance'ı ile sarar.
- **`everything-claude-code`** slash-komut ve skill topluluğudur. Ulak OS'un sunduğu manager-verdict gate'i, governance yüzeyi, greenfield scaffolder ve 4-vendor parity disiplini o pakette yoktur.
- **`cartographer`** tek bir agent'tır — derin sistem haritası çıkarır. Ulak OS bu yeteneği Phase 1'de absorbe eder ve 12+ diğer uzmanla paralel koşturur.

## Temel kavram: artefakt zinciri

Ulak OS'un diğer "prompt koleksiyonlarından" farkı, bir iş tamamlandığında operatörün elinde **somut belge zinciri** olmasıdır. Her `/director` çalışması aşağıdaki dosyaları `reports/current/` altına yazar:

- `runtime-manifest.md` — hangi git commit'i, hangi stack, hangi rule pack yüklendi
- `intake.md` + `inventory.md` — niyet + dosya/satır bazlı envanter
- `evidence-register.md` + `deep-scan-report.md` — uzman bulgular
- `did-you-know.md` — non-obvious (sorulmamış ama bilinmesi gereken) bulgular
- `analysis-findings.md` + `target-state.md` + `execution-roadmap.md` — sentez katmanı
- `validation-plan.md` + `pack-gap-register.md` — doğrulama + pack eksikleri
- `manager-verdict.md` + `validation-result.yaml` — tek birleştirilmiş karar

Bu zincirin avantajı: bir haftada olmayan operatör dönüp raporu okuyabilir, müşteriye audit trail gösterebilirsiniz, bir başka makinada aynı repo state'iyle aynı sonuca varabilirsiniz.

## Temel kavram: trust tier

Her claim (iddia) bir trust tier taşır — T1 en yüksek güven seviyesi (direct-verified, komut çıktısı ile kanıtlı), T7 en düşük (speculation). Critical severity bir bulgu T2 veya altında trust taşıyorsa validation-plan §6'da bir **live probe** ile doğrulanması zorunludur. "Ready" deyip geçmek için probe geçmeli, probe geçmiyorsa `signoff_status: blocked` kalır. Detay: [docs/governance/evidence-trust-scoring.md](../../governance/evidence-trust-scoring.md).

## Ne zaman Ulak OS seçmemeli?

Honest bir liste:

- **Hızlı bir prototype kırbaçlıyorsanız.** Governance overhead gereksiz — v0.1 shipping zamanınızda `/ulak-scaffold` yerine `create-next-app` daha hafif olabilir.
- **Tek başınasınız ve kimse denetlemeyecek.** Trust tier disiplini, persona split'i, validation gate'i bir kişilik projede faydadan çok yavaşlatıcı olabilir.
- **AI CLI kullanmıyorsanız.** Ulak OS'un tüm değeri AI CLI üzerinden akar; AI kullanmayan workflow'a değer katmaz.

## Öğrenme yolculuğu önerisi

- **Hemen denemek istiyorum** → [02-Kurulum](./02-kurulum.md) (5 dk) → `selam ulak` yazın → `/ulak-hello` tour'unu koşun → `/ulak-start` ile wizard'a girin.
- **Önce nasıl çalıştığını anlamak istiyorum** → [03-Mimari](./03-mimari.md) → [04-Komutlar](./04-komutlar.md) → [05-İş akışları](./05-is-akislari.md).
- **Baştan sona tam senaryo** → [walkthrough 01 — İlk SaaS uçtan uca](../../walkthrough/01-first-saas-end-to-end.md) (75-90 dk).
- **Tek bir servisi öğrenmek istiyorum** → [tutorials/supabase.md](../../tutorials/supabase.md) veya ilgili servis tutorial'ı.
- **Bilmediğim bir terim var** → `/ulak-explain <term>` veya doğrudan [docs/runtime/beginner-glossary.md](../../runtime/beginner-glossary.md).

## Sıradaki adım

Kurulum yapmak için [02-Kurulum](./02-kurulum.md) bölümüne geçin. Önce sistemin nasıl birbirine bağlandığını anlamak isterseniz, kuruluma geçmeden [03-Mimari](./03-mimari.md) bölümünü okumanız da makul bir seçenek — iki bölüm birbirinden bağımsız okunabilir.

Komutların yüzeyini hızlıca taramak isterseniz: [04-Komutlar](./04-komutlar.md). Tipik bir iş akışını hayal etmek isterseniz: [05-İş akışları](./05-is-akislari.md).

Sonraki bölüm: [02 — Kurulum](./02-kurulum.md)
