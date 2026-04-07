# Ulak OS ↔ Superpowers Skill Eşleştirmesi

Türkçe | [English](superpowers-mapping.en.md)

Bu doküman, public [superpowers marketplace](https://github.com/obra/superpowers) skill'lerinin Ulak OS artefakt zincirine nasıl eşlendiğini gösterir. Superpowers yüklü değilse Ulak OS yine kendi native skill'leriyle çalışır; bu mapping zenginleştirme katmanıdır, zorunlu bağımlılık değildir.

## Eşleştirme tablosu

| Ulak artefaktı | Eşdeğer superpowers skill | Hangi modlarda |
|---|---|---|
| `intake` | `superpowers:brainstorming` | GREENFIELD, EXTEND |
| `evidence-register` | `superpowers:systematic-debugging` | REPAIR, RESCUE |
| `execution-roadmap` | `superpowers:writing-plans` | Tüm modlar |
| `execution` | `superpowers:executing-plans` + `superpowers:test-driven-development` | Execution fazı |
| `validation-plan` | `superpowers:verification-before-completion` | Tüm modlar (zorunlu) |
| `manager-verdict` | `superpowers:finishing-a-development-branch` | Tüm modlar (kapanış) |
| (paralel iş) | `superpowers:dispatching-parallel-agents` | Bağımsız task grupları |
| (kod review) | `superpowers:requesting-code-review` + `receiving-code-review` | Execution sonrası |

## Nasıl kullanılır?

### 1. Sadece eşleştirme rehberi olarak (varsayılan)
Superpowers yüklüyse, Ulak OS komutlarını çalıştırırken **manuel olarak** ilgili skill'i de tetikleyebilirsin. Örnek:

```
> /intake brownfield audit
[Ulak OS native intake akışı çalışır]

> /skill superpowers:brainstorming
[Brainstorming skill ekstra niyet keşfi yapar]
```

İki çıktıyı Ulak OS sentezleyip `reports/current/intake.md`'ye yazar.

### 2. Wrapper komutları üzerinden (PoC: /ulak-intake)
Ulak OS v1.0.0 bir tane proof-of-concept wrapper komut içerir: `/ulak-intake`. Bu komut superpowers yüklüyse otomatik tetikler.

```
> /ulak-intake
[Eğer superpowers:brainstorming yüklüyse onu çağırır]
[Sonra Ulak intake formatında reports/current/intake.md yazar]
```

Diğer wrapper'lar (`/ulak-roadmap`, `/ulak-validate`, `/ulak-evidence`, vb.) v1.1+ sürümlerde gelecek.

## Lisans ve bağımlılık notu

Superpowers içeriği bu repoya kopyalanmamıştır. Bu sadece mapping rehberidir. Superpowers'ın kendi kurulumu ve lisansı için: https://github.com/obra/superpowers

## v1.1+ planı

- Kalan 5 wrapper komut (`/ulak-roadmap`, `/ulak-validate`, `/ulak-evidence`, `/ulak-pack-gap`, `/ulak-final`)
- Codex/Gemini için eşdeğer entegrasyon (vendor-spesifik komut formatlarında)
- Superpowers olmadığında graceful fallback testleri
