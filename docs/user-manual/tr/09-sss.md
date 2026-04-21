# 09 — Sıkça Sorulan Sorular

Bu bölüm Ulak OS hakkında sık sorulan soruların kısa cevaplarını içerir. İngilizce detaylı FAQ için: [docs/FAQ.md](../../FAQ.md).

## Ulak OS nedir?

Ulak OS, AI destekli kod yazma CLI'larının (Claude Code, Codex / Copilot, Gemini CLI) üzerinde çalışan **vendor-neutral prompt operating system** (satıcıdan bağımsız prompt işletim sistemi) paketidir. Tek bir core contract dosyası ve üç satıcıya uygun adapter ile gelir. Üç temel kapasitesi vardır: **audit** (derin denetim), **govern** (yönetişim), **scaffold** (sıfırdan SaaS iskeleti). "Ulak" Türkçede "haberci / kurye" anlamına gelir; proje sizin niyetinizle AI CLI'nız arasındaki haberci olarak çalışır.

## Kimler için?

Dört tipik persona:

1. **Solo geliştirici** yeni bir SaaS başlatıyor → `/ulak-scaffold` ile commit 1'den governance'lı iskelet
2. **Küçük takım** brownfield devraldı → `/director komple` ile derin denetim
3. **Ajans** birden fazla müşteri projesi yönetiyor → pattern-import ledger + sector packs kurumsal bellek olarak
4. **Brownfield rescue lead** legacy monolit modernize ediyor → god-module-decomposition + Strangler Fig

## Superpowers ile farkı nedir?

`superpowers` bir **skill bundle**'dır (brainstorming, systematic-debugging, writing-plans gibi bireysel yetenekler). Ulak OS bir katman üstüdür: tam bir prompt OS (Phase 0→5 protokolü, 22 governance docs, greenfield scaffolder, multi-vendor adapter). İki paket birbirini destekler — Ulak OS gerektiğinde `superpowers:brainstorming`'i Phase 2'de çağırabilir.

## Everything-claude-code ile farkı nedir?

`everything-claude-code` bir **command/skill bundle**'dır — slash-komut ve skill topluluğu. Ulak OS üç katman daha ekler: (a) manager-verdict validation gate (erken "done" reddeder), (b) governance surface (trust tiers, pattern-import ledger, artefact-write authorization), (c) greenfield scaffolder. Sadece "daha fazla komut" istiyorsanız o paket; "erken ready demeyi reddeden protokol" istiyorsanız Ulak OS.

## Cartographer ile farkı nedir?

`cartographer` tek bir agent'tır — derin sistem haritası üretir. Ulak OS bu yeteneği Phase 1'in parçası olarak absorbe eder ve 12+ diğer uzmanla paralel çalıştırır. Sadece file-and-line inventory istiyorsanız cartographer hafiftir; inventory + evidence + findings + target-state + roadmap + signoff istiyorsanız Ulak OS superset'tir.

## Claude Code olmadan kullanabilir miyim?

Evet. Core contract vendor-neutral — aynı `@`-import zinciri Claude Code, Codex / Copilot (AGENTS.md üzerinden) ve Gemini CLI (`.gemini/commands/*.toml` üzerinden) altında yüklenir. Bazı komutlar Claude-first (ör. `/frontend-war-room` belirli Claude Code agent dispatch semantiklerine bağlıdır); bunlar `vendor-parity-exemptions.txt` dosyasında gerekçesiyle listelenir. Audit ve scaffold iş akışları üç CLI'da da çalışır.

## Production için güvenli mi?

Evet, bir kaveat ile: Ulak OS kendi başına production'a kod göndermez — bir prompt katmanıdır. Garanti ettikleri:

- Her finding T1–T7 trust tier taşır ([evidence-trust-scoring.md](../../governance/evidence-trust-scoring.md))
- Validation gate, live probe'lar fail olduğunda "ready" demeyi reddeder
- Scaffolder 8 anti-pattern'i construction-time'da engeller (tek auth helper, server-only guards, DB-sourced role, RLS symmetry, `.gitignore` disiplin'i, gitleaks baseline, health-probe webhook, VPS hardening)
- Tüm artefaktlar sizin repo'nuzda kalır (`reports/current/**`) — post-hoc denetim yapılabilir

Production riski **sizin** riskiniz kalır — Ulak OS tabanı yükseltir, tavanı kaldırmaz.

## Veri gizliliği / telemetry?

Hayır, Ulak OS statik bir prompt paketidir. Tüm audit artefaktları sizin kendi repo'nuzda `reports/current/` altına yazılır. Phone-home yok, telemetry yok. Tek network aktivitesi: (a) kurulum sırasındaki tek seferlik `git clone`, (b) AI CLI'nızın sağlayıcısı ile kendi aralarındaki trafik. O trafikten Ulak OS sorumlu değil.

## Windows / macOS / Linux desteği

Üçü de birinci sınıf desteklenir:

- **Windows 11** — PowerShell 5.1+, installer `scripts/install.ps1`, `ulak` komutu `ulak.cmd` olarak gelir
- **macOS** — zsh (default) ve bash test edilir, installer `scripts/install.sh`
- **Linux** — Ubuntu 22.04 / 24.04 ve Fedora test edilir, aynı POSIX wrapper

Ayrıntılar: [docs/runbooks/install-methods.md](../../runbooks/install-methods.md).

## Hangi LLM modelleri destekleniyor?

- **Birincil:** Claude (Claude Code'a bağlı herhangi bir model — Opus, Sonnet, Haiku)
- **Adapter ile:** Gemini (Gemini CLI üzerinden), GPT family (Codex / Copilot üzerinden)
- **Prensip olarak model-agnostic:** Core contract saf markdown. `@`-import'ları anlayan ve subagent dispatch edebilen herhangi bir agent farklı fidelity seviyelerinde çalışır

Director protokolü en iyi paralel subagent dispatch'li modellerde çalışır. Paralel tool use'suz modellerde serial fallback ile koşar, context budget uyarısı verir.

## Çevrimdışı çalışır mı?

Kısmen:

- **Kurulum:** network gerektirir (git clone)
- **Audit / scaffold:** AI CLI'nız offline çalışabiliyorsa Ulak OS da çalışır. Ulak OS kendisi hiçbir network call yapmaz.
- **MCP connector'lar:** GitHub, Jira, Figma gibi remote MCP'ler network-bound; env var yoksa sessizce skip edilir

Hermetic audit'lar explicit olarak desteklenir — `docs/runtime/toolchain-precheck.md` offline-marked bir run'da network call deneyen agent'ı flagler.

## Lisans?

[MIT](../../../LICENSE). Fork edin, adapte edin, kendi operasyonunuza uyarlayın. Attribution yeterli.

## Nasıl katkı verebilirim?

Kısa özet:

1. Issue açın (feature proposal / pattern contribution / bug fix / docs improvement)
2. Fork + branch
3. ≥2 proje kanıtı ile pattern kontribüsyonu için trust tier ≥ T2
4. Bilingual doc parity (TR + EN aynı PR'da)
5. Validator'ları koşturun (`validate-imports`, `validate-schemas`, `validate-vendor-parity`)
6. PR açın, template'i doldurun

Detay: [07-Katkı](./07-katki.md), [CONTRIBUTING.md](../../../CONTRIBUTING.md).

## Ücretsiz mi?

Evet. Ulak OS MIT lisanslı açık kaynak paket. Kullanımı ücretsizdir. AI CLI'nızın (Claude Code, Codex, Gemini) sağlayıcı maliyetleri ayrıdır; onlar size ait.

## Türkçe konuşmayan biri için sorun olur mu?

Hayır — full EN parity vardır. Her komut İngilizce argüman kabul eder; her artefakt AI CLI oturumunun hangi dilde çalıştığına göre üretilir. Sadece İngilizce okuyorsanız `README.en.md` ve `docs/user-manual/en/` okuyarak hiçbir şey kaçırmazsınız. Bazı runtime rule dosyaları Türkçe komut bırakmıştır (ör. "validation olmadan done deme"); ama bunlar operatöre değil agent'a yönelik imperative'lerdir.

## `Ulak` ne demek?

Türkçede "haberci / kurye" anlamındadır. Proje sizin niyetinizle AI CLI'nız arasındaki haberci rolünü oynar — governance, context ve validation disiplinini aradaki boşluğa taşır.

## Ulak OS ne DEĞİLDİR?

- IDE / editör değil
- Model değil (eğitim yok, fine-tune yok)
- Linter değil (anti-pattern'ler prompt-level gate'ler, AST rule değil)
- CI platformu değil (`.github/workflows/` örnekler, CI seçimi size kalmış)
- Runtime değil (uygulamanızı çalıştırmaz)
- Kod okumanın yerine geçmez (director evidence üretir, affetme belgesi değil)
- Tamamlanmış değil (bu v1.0.0 ilk public GA; pack yaşıyor)

## Ne kadar sıklıkla güncelleniyor?

v1.x serisi boyunca yaklaşık 1-2 haftada bir. Kanonik kaynak: `CHANGELOG.md` + `git log`. Tag'ler [semantic versioning](../../../VERSIONING.md) izler: MAJOR contract-breaking değişiklikler için, MINOR append-only eklemeler için (yaygın case), PATCH fix'ler için.

## Demo nerede görebilirim?

Walkthrough'lar yazıldıkça `docs/showcase/` altına eklenir:

- [01-audit-walkthrough.md](../../showcase/01-audit-walkthrough.md)
- [02-scaffold-walkthrough.md](../../showcase/02-scaffold-walkthrough.md)
- [03-persona-audit.md](../../showcase/03-persona-audit.md)
- [04-cross-project-absorption.md](../../showcase/04-cross-project-absorption.md)
- [video-script.md](../../showcase/video-script.md)

Text-based tour için: [first-hour-with-ulak-os](../../runbooks/first-hour-with-ulak-os.md).

## Mevcut CI ve workflow'uma müdahale eder mi?

Hayır. Ulak OS CI veya workflow dosyalarınızı explicit talimat olmadan değiştirmez. Scaffolder **oluşturur** `.github/workflows/` dosyalarını (greenfield için); director **okur** ve findings raporlar. Mevcut bir projenin CI'ında değişiklik istiyorsanız, director `reports/current/execution-roadmap.md` içinde diff üretir — onu siz uygularsınız, agent değil.

## Nasıl kaldırırım?

Detaylı kaldırma talimatları: [02-Kurulum § Uninstall](./02-kurulum.md#uninstall--kaldırma).

Kısa özet (one-liner installer için):

```bash
rm -rf ~/.ulak-os ~/bin/ulak
```

Projelerinizin `CLAUDE.md` dosyalarındaki `@`-import satırını da elle silin ya da installer'ı yeniden koşturun.

## Daha fazla bilgi

- [docs/FAQ.md](../../FAQ.md) — İngilizce tam FAQ (daha detaylı sürümü)
- [docs/history/version-lineage.md](../../history/version-lineage.md) — sürüm soyağacı
- [CHANGELOG.md](../../../CHANGELOG.md) — her sürümün değişiklik listesi
- [docs/ecosystem/related-work.md](../../ecosystem/related-work.md) — ilgili projeler

---

Kılavuzun sonuna geldiniz. Başa dönmek için: [README](./README.md).
