# 01 — Giriş

## Ulak OS nedir?

Ulak OS, AI destekli kod yazma CLI'larının (Claude Code, Codex / Copilot, Gemini CLI) üzerinde çalışan bir **vendor-neutral prompt operating system** (satıcıdan bağımsız prompt işletim sistemi) kütüphanesidir. Tek bir core contract (çekirdek sözleşme) dosyası ve üç satıcıya uygun adapter (uyumlayıcı) katmanıyla gelir. Amacı: bir AI agent'ına (temsilciye) iş yaptırırken ondan beklediğiniz disiplini, kanıt standardını ve validation (doğrulama) kapılarını metin dosyaları olarak sisteme yüklemektir.

"Ulak" Türkçede "haberci / kurye" anlamına gelir. Proje, sizin niyetiniz ile AI CLI'ınız arasındaki haberci rolünü üstlenir: governance (yönetişim), context (bağlam) ve validation disiplinini aradaki boşluğa taşır. Kod yazmaz, IDE değildir, bir model de değildir — sadece model davranışını şekillendiren, disiplin uygulayan bir prompt paketidir.

## Üç temel kapasite

Ulak OS her oturumda aynı üç şeyi yapar:

1. **Audit (denetim)**: `/director` protokolü altında mevcut bir projeyi derinlemesine okur. Phase 0'dan Phase 5'e kadar süren altı fazlı program sayesinde inventory (envanter), evidence (kanıt), findings (bulgular), target-state (hedef durum), roadmap (yol haritası) ve manager-verdict (yönetici kararı) artefaktlarını `reports/current/**` altına yazar.

2. **Govern (yönet)**: 22 governance dosyası, 24 sector pack (sektör paketi), 8 rule pack (kural paketi) ve ~100 anti-pattern (kaçınılması gereken desen) katalogu her oturumda yüklenir. Bu paketler "neyi kabul edilmez sayacağız" kurallarını tanımlar: evidence olmadan iddia yok, validation olmadan "done" yok, customer / admin / public-API ayrımını bozan kod yok.

3. **Scaffold (iskelet kurma)**: `/ulak-scaffold` komutu ile sıfırdan çalışan, ticari üretim kalitesinde bir full-stack SaaS projesinin iskeletini üretir. Next.js + TypeScript + Supabase + payment (ödeme) + auth (kimlik doğrulama) + i18n (çoklu dil) + CI + deploy deseni commit 1'den itibaren yerleşik gelir.

## Vendor-neutral çerçeve

Ulak OS'un core contract dosyası (`prompts/core/ulak-os-core-contract-2.0.0.md`) satıcıdan bağımsız, saf metindir. Aynı dosya üç farklı CLI tarafından yüklenebilir:

- **Claude Code**: `CLAUDE.md` içinden `@`-import ile yüklenir. Tüm özellikler tam desteklenir; paralel subagent dispatch (eş zamanlı alt-temsilci sevki) Phase 2'de kullanılır.
- **Codex / Copilot**: `AGENTS.md` üzerinden yüklenir. Bazı komutlar serial fallback (sıralı yedek) ile çalışır.
- **Gemini CLI**: `.gemini/commands/*.toml` dosyaları ile bağlanır. Market research (pazar araştırması) gibi uzun-context senaryolarında güçlüdür.

Satıcı farklılıkları `docs/adapters/*.md` dosyalarında detaylandırılır. Satıcıya özel istisnalar `vendor-parity-exemptions.txt` dosyasında listelenir.

## Pack-unit taksonomisi (7 tip)

Ulak OS'un içindekiler yedi kategoriye ayrılır. Her kategori belirli bir dosya düzeniyle sürer:

| Kategori | Ne yapar | Nerede yaşar |
|---|---|---|
| **Commands** | Operatörün tetiklediği slash-komutları (ör. `/director`, `/ulak-scaffold`) | `.claude/commands/*.md` |
| **Skills** | Tekrar kullanılabilir, çok adımlı iş akışları | `.claude/skills/**/SKILL.md` |
| **Agents** | Uzmanlık personaları (security, infra, cartographer vb.) | `.claude/agents/*.md` |
| **Hooks** | CI / git hook'ları ile prompt disiplinini zorlayan scriptler | `.claude/hooks/`, `scripts/` |
| **Sector packs** | Bir sektöre özgü kurallar (e-ticaret, fintech vb.) | `docs/runtime/sector-packs.md` |
| **Rule packs** | Bir teknolojiye özgü kural kümeleri (Next.js, FastAPI vb.) | `docs/runtime/rule-packs/*.md` |
| **Runtime rules** | Çekirdek disiplin dosyaları (router, phases, context budget) | `docs/runtime/*.md` |

Bunlara ek olarak **governance docs** (22 dosya) vardır: trust scoring, surface-split, artefact authorization, hook governance gibi konular. Governance, runtime ile çakıştığında governance galibiyeti kazanır (bkz. `docs/governance/rule-collision-matrix.md`).

## Kimler için?

Dört tipik persona (kullanıcı profili):

### 1. Solo geliştirici — yeni bir SaaS başlatan

Haftalık 1-2 akşam ayırabilen, tek başına ticari bir ürün inşa eden bir geliştirici. `/ulak-scaffold` ile commit 1'den ticari kalitede iskelet alır: auth, ödeme, i18n, RLS (Row-Level Security) politikaları, CI/CD ve deploy deseni yerleşik gelir. Tipik kazanım: ilk haftayı "boilerplate (temel kalıp) yazmak" yerine ürünü düşünmekle geçirir.

### 2. Küçük takım — devralınmış bir projeyi denetleyen

3-5 kişilik bir takım, eski sahibi ayrılmış veya dışarıdan devralınmış bir kod tabanına bakmak zorunda. `/director komple` ile bir günlük bir derin denetim koşar. Çıktı: envanter (dosya+satır bazlı), persona kırılımlı bulgular, risk sıralaması, yol haritası ve "hazır / şartlı / bloke" şeklinde manager-verdict.

### 3. Ajans — birden fazla müşteri projesi yöneten

Ajansın governance baseline'ı (taban disiplini) her projede ortak olmalı: her projeye aynı sektör paketi, aynı anti-pattern listesi, aynı trust tier'ı uygulansın. Ulak OS'un **pattern-import-ledger** (desen ithal kütüğü) bu institutional memory (kurumsal bellek) işini üstlenir — bir projede öğrenilen bir desen `docs/governance/pattern-import-ledger.md` altına trust tier ≥ T2 olarak kaydedilir ve sonraki projelere aktarılır.

### 4. Brownfield rescue lead — monolit modernizasyonu

Bir legacy monolit (tek-parça eski kod tabanı) içinde 1000+ satırlık "god module" (tanrı-modül) dosyaları var. `god-module-decomposition` skill'i Strangler Fig protokolünü uygular: orijinal dosya shim (ince yeniden-dışa-aktarım katmanı) haline getirilir, sorumluluk alt-modüllere dağıtılır, her adım atomik bir commit olur. Waves pattern ile 4+ agent paralel çalışırken merge (birleştirme) sırası korunur.

## Kimler için DEĞİL?

Ulak OS'un ne olmadığını açıkça söylemek de önemli:

- **IDE / editör değil.** Sizin editörünüzün yanında değil, AI CLI'ınızın üstünde oturur.
- **Model değil.** Hiçbir model eğitmez, fine-tune yapmaz. Modeli CLI'ınızın sağlayıcısı seçer; Ulak OS sadece prompt'u şekillendirir.
- **Linter değil.** Anti-pattern'ler AST (abstract syntax tree) seviyesinde çalışan kurallar değildir — prompt düzeyinde gate'lerdir. Kodunuzu AST seviyesinde denetlemek için ESLint, Pylint, RuboCop gibi araçları kullanın.
- **CI platformu değil.** `.github/workflows/` altında örnekler gelir; gerçek CI seçimi size kalmış.
- **Runtime (kod çalıştırıcı) değil.** Uygulamanızı çalıştırmaz.
- **Kod okumanın yerine geçmiyor.** Director evidence (kanıt) üretir; affetme belgesi değil. Artefaktları gözden geçirmek hâlâ insana ait.

## Neyle karıştırmayın?

- **`superpowers`** tekil yetenekler paketidir (brainstorming, systematic-debugging gibi). Ulak OS'un bir katman üstüdür; ikisi birlikte çalışabilir, Ulak OS gerektiğinde `superpowers:brainstorming` skill'ini çağırabilir.
- **`everything-claude-code`** slash-komut ve skill topluluğudur. Ulak OS'un sunduğu manager-verdict gate'i, governance yüzeyi ve greenfield scaffolder o pakette yoktur.
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

Bu zincirin avantajı: bir haftada olmayan operatör dönüp raporu okuyabilir, müşteriye audit trail gösterebilirsiniz, bir başka makinada aynı repo state'iyle aynı sonuca varabilirsiniz. "Agent yaptı, bitti" yerine "agent yaptı, evidence burada, validation buradan koşuldu, verdict şu" alırsınız.

## Temel kavram: trust tier

Her claim (iddia) bir trust tier taşır — T1 en yüksek güven seviyesi (direct-verified, komut çıktısı ile kanıtlı), T7 en düşük (speculation). Critical severity bir bulgu T2 veya altında trust taşıyorsa validation-plan §6'da bir **live probe** ile doğrulanması zorunludur. Ulak OS bu şemayı cebrileştirir: "ready" deyip geçmek için probe geçmeli, probe geçmiyorsa `signoff_status: blocked` kalır. Detay: [docs/governance/evidence-trust-scoring.md](../../governance/evidence-trust-scoring.md).

## Ne zaman Ulak OS seçmemeli?

Honest bir liste:

- **Hızlı bir prototype kırbaçlıyorsanız.** Governance overhead gereksiz — v0.1 shipping zamanınızda `/ulak-scaffold` yerine `create-next-app` daha hafif.
- **Tek başınasınız ve kimse denetlemeyecek.** Trust tier disiplini, persona split'i, validation gate'i bir kişilik projede faydadan çok yavaşlatıcı olabilir.
- **AI CLI kullanmıyorsanız.** Ulak OS'un tüm değeri AI CLI üzerinden akar; AI kullanmayan workflow'a değer katmaz.

## Sıradaki adım

Kurulum yapmak için [02-Kurulum](./02-kurulum.md) bölümüne geçin. Önce sistemin nasıl birbirine bağlandığını anlamak isterseniz, kuruluma geçmeden [03-Mimari](./03-mimari.md) bölümünü okumanız da makul bir seçenek — iki bölüm birbirinden bağımsız okunabilir.

Komutların yüzeyini hızlıca taramak isterseniz: [04-Komutlar](./04-komutlar.md). Tipik bir iş akışını hayal etmek isterseniz: [05-İş akışları](./05-is-akislari.md).

Sonraki bölüm: [02 — Kurulum](./02-kurulum.md)
