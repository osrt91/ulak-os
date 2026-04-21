# 09 — Sıkça Sorulan Sorular

> **v1.6 güncellemesi:** Bu manuel-özel FAQ sadece **user-manual'a özgü 5 Q&A** eklendi (aşağıdaki "User manual özelinde" bölümü). Genel FAQ (376 satır, Ulak OS geneli için) [docs/FAQ.md](../../FAQ.md) altında; iki doküman çakışmaz, link ile birbirini tamamlar.

## User manual özelinde (v1.6)

### Bu manual nasıl okunur?

Üç okuma modu mevcuttur:

1. **Baştan sona — full context (~60 dakika v1.6'da).** 01 → 09 sırası, her bölüm 4-10 dakika. Hiçbir şey atlama. Stranger okur, Ulak OS'un tamamını anlar.
2. **Hızlı tarama (~10 dakika).** Sadece giriş bölümü (01) + 04-Komutlar tablosu + 05-İş akışları özet karar ağacı. Ne olduğunu bilen, ne yapabileceğini görmek isteyen için.
3. **Referans — ihtiyaç anında.** 08-Sorun giderme sizi buldu, 06-Yönetişim bir şema arıyorsunuz, 07-Katkı PR açıyorsunuz. Her bölüm bağımsız yazıldı.

Kuruluma hemen başlamak isterseniz: [02-Kurulum](./02-kurulum.md) (5 dakika).

### TR mi EN mi okuyayım?

Her iki dilde de tam parity vardır (`validate-bilingual.sh` enforce eder). Seçim kriteriniz:

- **Türkçe'yi tercih ediyorsanız** → buradasınız (TR). `docs/user-manual/tr/`.
- **İngilizce daha rahatsa** → [docs/user-manual/en/](../en/README.md).
- **Takımınızda iki dilli operatör varsa** → README-first locale selection ile (`.claude/state/locale.txt` + `/ulak-locale`) projenizde hangi dil ana, hangisi alternatif seçin.

Komut çıktıları iki dilde de üretilebilir — `/director komple output_language=tr` veya `output_language=en`. Runtime rule dosyalarında bazı imperative'ler Türkçe bırakılmıştır (operatöre değil agent'a yönelik — ör. "validation olmadan done deme"); bunlar semantik olarak dile bağlı değildir.

### Offline / çevrimdışı kullanabilir miyim?

Kısmen:

- **Manuel okuma** → tamamen offline. Tüm dosyalar repo kopyanızda yaşar.
- **Ulak OS kurulumu** → ilk kez `git clone` network ister. Sonra offline.
- **Ulak OS çalıştırma** → Ulak OS kendisi network call yapmaz. Ama AI CLI'nızın (Claude / Gemini / Codex / Copilot) sağlayıcısına bağlantı gerekir. AI CLI'nız offline modda çalışabiliyorsa (ör. local model) Ulak OS da öyle çalışır.
- **MCP connector'lar** → GitHub, Jira, Figma gibi remote MCP'ler network-bound. Env var yoksa sessizce skip edilir.

Hermetic audit ihtiyacı explicit olarak desteklenir — `docs/runtime/toolchain-precheck.md` offline-marked run'da network call deneyen agent'ı flagler.

### Ulak OS güncelleme yolu nedir?

Sürüm serileri ve upgrade yolu:

| Sürüm | Ne değişti (özet) |
|---|---|
| **v1.0** | İlk GA. 9 komut + tek vendor (Claude Code). |
| **v1.6 (bu manual)** | 24 komut, 4 vendor (Claude / Gemini / Codex / Copilot), walkthrough + tutorial + beginner-glossary, vendor-capability-matrix + localization-governance eklendi. |
| **v2.x / v3.x** | İç dinamikler (archive'da); public operatöre etkisi yok. |

**Güncelleme komutları (kurulum yöntemine göre):**

```bash
# Yöntem 1 (one-liner):
ulak upgrade

# Yöntem 2 (git clone):
cd ~/tools/ulak-os && git pull

# Yöntem 3 (submodule):
cd .ulak-os && git fetch --tags && git checkout v1.6.0 && cd ..
git add .ulak-os && git commit -m "chore: bump Ulak OS to v1.6.0"
```

Her güncelleme sonrası `ulak doctor` + 4 validator (`validate-imports`, `validate-schemas`, `validate-vendor-parity`, `validate-bilingual`) koşturun. Breaking change varsa `docs/runbooks/upgrading-from-v2.x.md` gibi upgrade runbook eşlik eder.

Kanonik kaynak: [CHANGELOG.md](../../../CHANGELOG.md) + [VERSIONING.md](../../../VERSIONING.md) + `git log`.

### Fallback adapter çalışmazsa ne yapayım?

Hedef vendor'da bir komut beklendiği gibi çalışmıyor. Seçenekler (önerilen sıra):

1. **NL trigger yerine slash dene** → Claude Code'da açık olup olmadığı kontrol et.
2. **Sync script koş** → Gemini için `bash scripts/sync-gemini-commands.sh`; Codex için `bash scripts/init-codex.sh` yenile.
3. **Vendor-capability-matrix'e bak** → [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md) Tablo B.1'de o komutun o vendor'da `OK` / `PART` / `MISS` statüsünü gör. `MISS` ise exemption rationale'ı var; alternatif vendor öner.
4. **Başka vendor'a geç** → `ulak init . --vendor=<diğer>` ile ek vendor bağla. Tüm 4 vendor aynı anda aynı projede yaşayabilir.
5. **Serial fallback'i kabul et** → Özellikle Codex/Copilot'ta paralel dispatch yoksa /director daha uzun sürer; ama aynı artefakt zinciri üretilir.

Örneğin: `/ulak-design-ref` Copilot'ta MISS. Bu komut için Claude Code'a geç, `/ulak-design-ref stripe` koş, `DESIGN.md`'yi al; sonra Copilot'a dön, dosyayı commit et ve `/frontend-war-room` davranışını NL ile tetikle.

## Genel sorular

(Aşağıdaki Q&A'lar genel Ulak OS kullanımıyla ilgili; daha detaylı EN FAQ için [docs/FAQ.md](../../FAQ.md).)

### Ulak OS nedir?

AI destekli kod yazma CLI'larının (Claude Code, Gemini CLI, Codex CLI, Copilot Chat) üzerinde çalışan **vendor-neutral prompt operating system** paketidir. Tek bir core contract dosyası ve dört satıcıya uygun adapter ile gelir. Üç temel kapasite: **audit** (derin denetim), **govern** (yönetişim), **scaffold** (sıfırdan SaaS iskeleti).

### Kimler için?

Dört tipik persona:

1. **Solo geliştirici** yeni bir SaaS başlatıyor → `/ulak-start` + `/ulak-scaffold` + `/ulak-next-steps`
2. **Küçük takım** brownfield devraldı → `/director komple` + opsiyonel `/ulak-audit-deep`
3. **Ajans** birden fazla müşteri projesi yönetiyor → pattern-import-ledger + `/ulak-pattern-extract`
4. **Brownfield rescue lead** legacy monolit modernize ediyor → `god-module-decomposition` + Strangler Fig

### Superpowers ile farkı nedir?

`superpowers` bir **skill bundle**'dır (brainstorming, systematic-debugging, writing-plans). Ulak OS bir katman üstüdür: tam bir prompt OS (Phase 0→5 protokolü, 22 governance docs, greenfield scaffolder, 4-vendor adapter). İki paket birbirini destekler — `/ulak-brainstorm` superpowers:brainstorming skill'ini Ulak governance ile sarar; `/ulak-test-driven` aynısı test-driven-development için.

### Claude Code olmadan kullanabilir miyim?

Evet — 4 vendor desteklenir. Tam parity tablosu: [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md). Codex CLI ve Copilot Chat'te slash primitive yok, NL trigger map kullanılır (`selam ulak` → `/ulak-hello`). Audit + scaffold + governance iş akışları dört CLI'da da çalışır; sadece paralel dispatch Claude-first (diğerlerinde serial fallback).

### Production için güvenli mi?

Evet, bir kaveat ile: Ulak OS kendi başına production'a kod göndermez — prompt katmanıdır. Garantiler:

- Her finding T1–T7 trust tier taşır
- Validation gate, live probe'lar fail olduğunda "ready" demeyi reddeder
- Scaffolder 8 anti-pattern'i construction-time'da engeller
- Tüm artefaktlar sizin repo'nuzda kalır

Production riski sizin riskiniz kalır — Ulak OS tabanı yükseltir, tavanı kaldırmaz.

### Veri gizliliği / telemetry?

Hayır, Ulak OS statik bir prompt paketidir. Phone-home yok, telemetry yok. Tek network aktivitesi: (a) kurulum sırasındaki git clone, (b) AI CLI'nızın sağlayıcısı ile kendi trafiği. O trafikten Ulak OS sorumlu değil.

### Windows / macOS / Linux desteği

Üçü de birinci sınıf. Detay: [02-Kurulum](./02-kurulum.md).

### Hangi LLM modelleri destekleniyor?

- **Claude Code** → Claude family (Opus, Sonnet, Haiku) — FULL
- **Gemini CLI** → Gemini family — FULL-MINUS
- **Codex CLI** → GPT family — CORE
- **Copilot Chat** → GPT family (Copilot-routed) — LIMITED

Director protokolü en iyi paralel subagent dispatch'li modellerde çalışır; paralel tool use'suz modellerde serial fallback.

### Lisans?

[MIT](../../../LICENSE). Fork edin, adapte edin. Attribution yeterli.

### Ücretsiz mi?

Evet, MIT açık kaynak. AI CLI'nızın sağlayıcı maliyetleri ayrıdır.

### Türkçe konuşmayan biri için sorun olur mu?

Hayır — full EN parity vardır. [docs/user-manual/en/](../en/README.md) + [README.en.md](../../../README.en.md).

### `Ulak` ne demek?

Türkçede "haberci / kurye". Proje sizin niyetinizle AI CLI'nız arasındaki haberci rolünü oynar.

### Ulak OS ne DEĞİLDİR?

IDE değil, model değil, linter değil, CI platformu değil, runtime değil, kod okumanın yerine geçmez.

### Ne kadar sıklıkla güncelleniyor?

v1.x serisi boyunca yaklaşık 1-2 haftada bir. Kanonik: [CHANGELOG.md](../../../CHANGELOG.md). Tag'ler [semantic versioning](../../../VERSIONING.md) izler.

### Demo nerede görebilirim?

- Walkthrough'lar (3 vendor variant) → [docs/walkthrough/](../../walkthrough/)
- Showcase → [docs/showcase/](../../showcase/) (audit/scaffold/persona/cross-project)
- `/ulak-demo` → 3 örnek SaaS projesi inline tanıtımı
- Text-based tour → [first-hour-with-ulak-os](../../runbooks/first-hour-with-ulak-os.md)

### Mevcut CI ve workflow'uma müdahale eder mi?

Hayır. Scaffolder **oluşturur** `.github/workflows/` dosyalarını (greenfield için); director **okur** ve findings raporlar. Mevcut CI değişikliği için director roadmap içinde diff önerir — siz uygularsınız.

### Nasıl kaldırırım?

[02-Kurulum § Uninstall](./02-kurulum.md) bölümüne bakın. Kısa: `rm -rf ~/.ulak-os ~/bin/ulak` + entry dosyalarından (CLAUDE.md / GEMINI.md / AGENTS.md / copilot-instructions.md) `@`-import veya NL map satırını sil.

### Daha fazla soru?

[docs/FAQ.md](../../FAQ.md) — İngilizce tam FAQ (376 satır; daha detaylı sürüm).

## Daha fazla bilgi

- [docs/FAQ.md](../../FAQ.md) — Ulak OS geneli detaylı FAQ
- [docs/history/version-lineage.md](../../history/version-lineage.md) — sürüm soyağacı
- [CHANGELOG.md](../../../CHANGELOG.md) — her sürümün değişiklik listesi
- [docs/ecosystem/related-work.md](../../ecosystem/related-work.md) — ilgili projeler
- [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md) — 4 vendor × 24 komut
- [docs/runtime/beginner-glossary.md](../../runtime/beginner-glossary.md) — 47 temel terim

---

Kılavuzun sonuna geldiniz. Başa dönmek için: [README](./README.md).
