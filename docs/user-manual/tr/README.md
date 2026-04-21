# Ulak OS — Türkçe Kullanım Kılavuzu

Bu kılavuz, **Ulak OS v1.6** sürümünün Türkçe konuşan geliştiriciler için hazırlanmış tam kullanım belgeleridir. Ulak OS'u yeni öğrenenler, mevcut Claude Code / Gemini CLI / Codex CLI / GitHub Copilot Chat kullanıcıları ve bir projeye governance (yönetişim) katmanı eklemek isteyenler için yazıldı.

> **v1.6 kısa özet:** 24 slash komutu, 4 vendor (Claude Code / Gemini CLI / Codex CLI / Copilot Chat), 10 skill, 27 ajan, 24 sector pack + 15 sector overlay, 8 rule pack, 22 governance docs, 7 ADR, 4 runbook, **3 walkthrough + 4 tutorial + 47-term beginner-glossary** (yeni Layer 1 katmanları).

## Kimler için?

- Tek başına yeni bir SaaS geliştiren solo geliştiriciler
- Mevcut bir "brownfield" (devralınmış, yarım kalmış veya eski) projeyi denetlemek isteyen küçük takımlar
- Birden fazla proje yöneten ajans ve danışmanlar
- Legacy (eski sürüm) monolit uygulamaları modernize etmeye çalışan takım liderleri
- İlk kez SaaS yapan, `/ulak-start` basit modundan yararlanmak isteyen yeni operatörler (v1.6)

## Ön koşullar

- Claude Code / Gemini CLI / Codex CLI / GitHub Copilot Chat (VS Code) — en az biri kurulu
- `git` komut satırı aracı
- macOS, Linux veya Windows (PowerShell 5.1+ ile)
- Temel terminal bilgisi

## Bölümler (9 bölüm)

| # | Bölüm | 1 satır özet |
|---|---|---|
| 01 | [Giriş](./01-giris.md) | Ulak OS nedir, v1.6 üç yeni vizyon katmanı, 4 vendor desteği, 7 pack-unit tipi, 4 persona ve ne DEĞİLDİR |
| 02 | [Kurulum](./02-kurulum.md) | 5 kurulum yöntemi + `selam ulak` / `hi ulak` NL entry + 4 vendor × kurulum matrisi + validator'lar |
| 03 | [Mimari](./03-mimari.md) | `@`-import zinciri, Layer 1 vs hidden core, Phase 0→5, 4-vendor adapter + NL trigger map katmanı |
| 04 | [Komutlar](./04-komutlar.md) | 24 komutun tam listesi 3 kategoride (onboarding + yaşam döngüsü + meta) + vendor desteği kolonu |
| 05 | [İş akışları](./05-is-akislari.md) | 5 canonical workflow: İlk SaaS, mevcut audit, servis öğrenme, pack genişletme, cross-project pattern |
| 06 | [Yönetişim](./06-yonetisim.md) | 22 governance docs + vendor-capability-matrix + localization-governance + 7 ADR + 4 runbook + 4 tutorial + 3 walkthrough |
| 07 | [Katkı](./07-katki.md) | Sector/rule pack PR süreci + 4 vendor parity disiplini + sync-gemini-commands.sh + validate-bilingual.sh |
| 08 | [Sorun giderme](./08-sorun-giderme.md) | 13 Ulak hatası + 6 beginner service setup sorunu (Supabase / Vercel / GitHub / Resend / pnpm) |
| 09 | [SSS](./09-sss.md) | 5 user-manual-özel Q&A + 13 genel Q&A + docs/FAQ.md'ye link |

## Okuma süresi

Tüm kılavuzu baştan sona okumak ortalama **60 dakika** sürer (v1.6'da genişleyen içerik). Sadece kuruluma geçmek istiyorsanız: [02-Kurulum](./02-kurulum.md) (5 dakika).

## Hızlı başlangıç (3 dakika)

Hemen denemek isteyenler için en kısa yol:

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh

# Windows (PowerShell)
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex

# Doğrula
ulak doctor
```

Ardından mevcut bir projenin dizinine geçin ve `ulak init .` koşun. Sonra AI CLI'nızı açıp:

```
selam ulak
```

`/ulak-hello` 30-saniyelik tour'u açılır. Sonrası [04-Komutlar](./04-komutlar.md) ve [05-İş akışları](./05-is-akislari.md).

Detay: [02-Kurulum](./02-kurulum.md).

## Kullanılan terimler

Kılavuzda karşılaşacağınız bazı temel terimler:

- **Artefakt** — bir fazın diske yazdığı markdown veya YAML dosyası
- **Phase** — director protokolünün 6 ana aşamasından biri (0→5, ayrıca 4.5 koşullu)
- **Subagent** — belirli bir uzmanlık alanına odaklanmış alt-temsilci
- **Governance** — yönetişim katmanı; disiplin ve denetim kuralları
- **Pack-unit** — Ulak OS'un 7 temel birim tipinden (command, skill, agent, hook, sector pack, rule pack, runtime rule)
- **NL trigger map** — doğal dil fraz ↔ komut eşlemesi (Codex + Copilot adapter'larında, v1.6)
- **Trust tier** — T1–T7 kanıt güven seviyesi

Daha fazla: `/ulak-explain <term>` veya [docs/runtime/beginner-glossary.md](../../runtime/beginner-glossary.md) (47 term).

Detaylı sözlük: [03-Mimari § Mini sözlük](./03-mimari.md).

## İngilizce sürüm

Bu kılavuzun İngilizce karşılığı: [../en/README.md](../en/README.md).

Türkçe ve İngilizce sürümler paritede tutulur; `bash scripts/validate-bilingual.sh` her PR'da parity'yi zorlar (bkz. [docs/governance/localization-governance.md](../../governance/localization-governance.md)).

## Cross-linkler — Layer 1 yüzeyinin v1.6 yeni katmanları

Bu manuel'i genişleten üç yeni katman disk'te yaşıyor ve manual bölümleri bunları sıkça referans veriyor:

- **Walkthroughs** — [docs/walkthrough/](../../walkthrough/)
  - [01 — İlk SaaS uçtan uca (Claude Code)](../../walkthrough/01-first-saas-end-to-end.md)
  - [01-codex — Codex CLI variant](../../walkthrough/01-first-saas-end-to-end-codex.md)
  - [01-copilot — Copilot Chat variant](../../walkthrough/01-first-saas-end-to-end-copilot.md)
- **Tutorials** — [docs/tutorials/](../../tutorials/)
  - [Supabase setup](../../tutorials/supabase.md)
  - [Vercel deploy](../../tutorials/vercel.md)
  - [GitHub push + Actions](../../tutorials/github.md)
  - [Resend transactional email](../../tutorials/resend.md)
- **Beginner-glossary** — [docs/runtime/beginner-glossary.md](../../runtime/beginner-glossary.md) (47 term, TR/EN alias)

## Başka kaynaklar

- Projenin ana [README](../../../README.md) dosyası
- [FAQ](../../FAQ.md) — İngilizce tam FAQ (376 satır)
- [Mimari genel bakış](../../architecture/overview.md)
- [Sürüm günlüğü](../../../CHANGELOG.md)
- [Lisans](../../../LICENSE) (MIT)
- [Vendor capability matrix](../../governance/vendor-capability-matrix.md) — 4 vendor × 24 komut
- [Catalog](../../catalog.md) — `/ulak-packs` inline dump kaynağı

Sonraki bölüm: [01 — Giriş](./01-giris.md)
