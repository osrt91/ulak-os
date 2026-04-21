# Ulak OS — Türkçe Kullanım Kılavuzu

Bu kılavuz, Ulak OS v1.0.0 public GA sürümünün Türkçe konuşan geliştiriciler için hazırlanmış tam kullanım belgeleridir. Ulak OS'u yeni öğrenenler, mevcut Claude Code / Codex / Gemini CLI kullanıcıları ve bir projeye governance (yönetişim) katmanı eklemek isteyenler için yazıldı.

## Kimler için?

- Tek başına yeni bir SaaS geliştiren solo geliştiriciler
- Mevcut bir "brownfield" (devralınmış, yarım kalmış veya eski) projeyi denetlemek isteyen küçük takımlar
- Birden fazla proje yöneten ajans ve danışmanlar
- Legacy (eski sürüm) monolit uygulamaları modernize etmeye çalışan takım liderleri

## Ön koşullar

- Claude Code, Codex CLI veya Gemini CLI'dan en az biri kurulu
- `git` komut satırı aracı
- macOS, Linux veya Windows (PowerShell 5.1+ ile)
- Temel terminal bilgisi

## Bölümler

| # | Bölüm | Açıklama |
|---|---|---|
| 01 | [Giriş](./01-giris.md) | Ulak OS nedir, ne işe yarar, kimler için tasarlandı |
| 02 | [Kurulum](./02-kurulum.md) | Tek satır installer, git clone, submodule, `ulak init` |
| 03 | [Mimari](./03-mimari.md) | `@`-import zinciri, public runtime vs hidden core, Phase 0→5 |
| 04 | [Komutlar](./04-komutlar.md) | 9 slash-command referansı ve kullanım örnekleri |
| 05 | [İş akışları](./05-is-akislari.md) | Brownfield audit, greenfield scaffold, multi-persona audit |
| 06 | [Yönetişim](./06-yonetisim.md) | 22 governance dosyası, trust scoring, artefact authorization |
| 07 | [Katkı](./07-katki.md) | Sector pack, rule pack, agent ve command önerme |
| 08 | [Sorun giderme](./08-sorun-giderme.md) | 10 yaygın hata ve çözümleri |
| 09 | [SSS](./09-sss.md) | Sıkça sorulan sorular, Ulak OS'un ne olmadığı, lisans |

## Okuma süresi

Tüm kılavuzu baştan sona okumak ortalama **45 dakika** sürer. Sadece kuruluma geçmek istiyorsanız: [02-Kurulum](./02-kurulum.md) (5 dakika).

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

Ardından mevcut bir projenin dizinine geçin ve `ulak init .` koşun. Detay: [02-Kurulum](./02-kurulum.md).

## Kullanılan terimler

Kılavuzda karşılaşacağınız bazı temel terimler:

- **Artefakt** — bir fazın diske yazdığı markdown veya YAML dosyası
- **Phase** — director protokolünün 6 ana aşamasından biri (0→5)
- **Subagent** — belirli bir uzmanlık alanına odaklanmış alt-temsilci
- **Governance** — yönetişim katmanı; disiplin ve denetim kuralları
- **Pack-unit** — Ulak OS'un 7 temel birim tipinden (command, skill, agent, hook, sector pack, rule pack, runtime rule)

Detaylı sözlük: [03-Mimari § Mini sözlük](./03-mimari.md).

## İngilizce sürüm

Bu kılavuzun İngilizce karşılığı: [../en/README.md](../en/README.md).

Türkçe ve İngilizce sürümler paritede tutulur; biri güncellenirse diğeri de aynı PR içinde güncellenir (bkz. [docs/governance/rule-pack-governance.md](../../governance/rule-pack-governance.md)).

## Başka kaynaklar

- Projenin ana [README](../../../README.md) dosyası
- [FAQ](../../FAQ.md) — sıkça sorulan sorular
- [Mimari genel bakış](../../architecture/overview.md)
- [Sürüm günlüğü](../../../CHANGELOG.md)
- [Lisans](../../../LICENSE) (MIT)

Sonraki bölüm: [01 — Giriş](./01-giris.md)
