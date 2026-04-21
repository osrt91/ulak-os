---
name: ulak-packs
description: Tüm Ulak OS kapasitelerini (24 komut, 10 skill, 27 ajan, 15 sector overlay, 24 sector pack, 8 rule pack, 22 governance, 6 ADR, 4 runbook) tek yerde gösterir. Plugin aramak yerine bu komutu çalıştır — `docs/catalog.md` içeriğini inline döker. "İnsanlar internetten plugin aramasın" vizyonunun operasyonel karşılığı.
description_en: Shows all Ulak OS capabilities in one place (24 commands, 10 skills, 27 agents, 15 sector overlays, 24 sector packs, 8 rule packs, 22 governance docs, 6 ADRs, 4 runbooks). Instead of hunting for plugins online, run this command — dumps `docs/catalog.md` inline. Operational embodiment of the "no plugin hunting" vision.
agent: autonomous-program-director
allowed-tools: Read, Grep, Glob, Bash
argument-hint: "[section]  (örn: commands | skills | agents | sectors | rules | governance | adrs | runbooks — boş bırakılırsa hepsi)"
model: claude-opus-4-7
---

# /ulak-packs — Ulak OS kapasite kataloğu / capability catalog

> **TR** — "Ben ne yapabiliyorum?" sorusunun tek-komutluk cevabı.
> **EN** — One-command answer to "what can I do here?"

## Ne zaman kullanılır / When to use

- **Yeni kullanıcı** ("Ulak OS'ta ne var?") — tüm kapasiteleri tek ekranda gör
- **Karar anı** ("bu iş için hangi komut/skill?") — doğru aracı seç
- **Pack gap check** ("bu var mı, yok mu?") — olmayanı `/pack-gap-audit` ile tara
- **Demo / onboarding** — ekibe Ulak OS'u 2 dakikada anlat
- **Dokümantasyon drift** ("README ile gerçek uyuşuyor mu?") — disk üzerindeki gerçek kapasiteyi gör

## Ne yapmaz / What this does NOT do

- Plugin kurmaz, indirmez
- Yeni kapasite üretmez (onun için `/pack-gap-audit` var)
- Kullanıcının projesine dokunmaz

## Akış / Flow

### 1) Argümanı yorumla / Parse argument

```
$ARGUMENTS
```

Eğer argüman varsa, sadece o bölümü dök:

- `commands` → Komutlar (A bölümü)
- `skills` → Skill'ler (B bölümü)
- `agents` → Ajanlar (C bölümü)
- `sectors` → Sector kit + pack (D bölümü)
- `rules` → Rule pack'leri (E bölümü)
- `governance` → Governance (F bölümü)
- `adrs` → ADR'ler (G bölümü)
- `runbooks` → Runbook'lar (H bölümü)
- (boş) → Hepsi

### 2) Kataloğu oku / Read catalog

```bash
cat docs/catalog.md
```

Eğer argüman verilmişse, ilgili bölümü `##` başlığıyla filtrele (örn: `## A) Komutlar` → bir sonraki `## ` başlığına kadar).

### 3) Formatla ve göster / Format and show

- Başlık: **"Ulak OS — 140 kapasite, tek ekranda / 140 capabilities, one screen"**
- Önce özet tablo (kategoriler + adetler)
- Sonra argüman bölümü (veya hepsi)
- Son satır: "Aramak için: `/ulak-search <keyword>` · Dosya: `docs/catalog.md`"

### 4) Disk kontrolü / Disk check (DIFF WARNING)

Kataloğu dökerken şu drift kontrolünü yap:

```bash
ls .claude/commands/ | wc -l
ls .claude/skills/ | wc -l
ls .claude/agents/ | wc -l
ls templates/sectors/ | wc -l
ls docs/runtime/rule-packs/ | wc -l
ls docs/governance/ | grep -v README | wc -l
ls docs/adr/ADR-*.md | wc -l
ls docs/runbooks/ | wc -l
```

Eğer katalogdaki sayılar diskteki sayılarla **eşleşmiyorsa**, son satıra:

> **⚠ DRIFT UYARISI / DRIFT WARNING**: catalog.md `X` diyor, disk `Y` diyor. `docs/catalog.md` güncellenmeli veya `/pack-gap-audit` koşulmalı.

## Örnekler / Examples

### Örnek 1 — Tüm kapasite / All capabilities
```
/ulak-packs
```
→ 500 satır full catalog dump.

### Örnek 2 — Sadece komutlar / Commands only
```
/ulak-packs commands
```
→ A bölümü: 24 komut tablosu.

### Örnek 3 — Sector arıyorum / Looking for sectors
```
/ulak-packs sectors
```
→ D bölümü: 15 sector overlay kit + 24 sector pack tanımı.

### Örnek 4 — Governance review
```
/ulak-packs governance
```
→ F bölümü: 22 governance doc + özet.

## Çıktı formatı / Output format

```
# Ulak OS — 140 kapasite / 140 capabilities

## Özet / Summary
| Kategori | Adet |
|---|---|
| Komutlar | 24 |
| Skill'ler | 10 |
| Ajanlar | 27 |
| ...

## [Filtered section or all]

[catalog content]

---
Aramak için: /ulak-search <keyword>
Dosya: docs/catalog.md
```

## Güncelleme disiplini / Update discipline

Bu komut `docs/catalog.md` dosyasını okur. Dolayısıyla:

1. Yeni komut/skill/ajan eklenince → `docs/catalog.md` güncellenir
2. `/pack-gap-audit` çıktısı yeni item önerdi → önce item scaffold'landı, sonra catalog'a eklendi
3. ADR-NNN kapandı → G bölümüne eklenir

Drift varsa `/ulak-packs` uyarır ama otomatik fix etmez — o `/pack-gap-audit`'in işi.

## Governance gate

Bu komut **read-only**. `reports/current/` altına yazmaz. Director Phase'leri tetiklemez. Artefakt yazma yetkisi gerektirmez.
