---
name: ulak-locale
description: Ulak OS aktif locale'ini yönetir (TR/EN toggle). "show" mevcut dili gösterir, "tr" veya "en" kalıcı olarak siteyi günceller. Locale state `.claude/state/locale.txt` dosyasında saklanır; README + kullanıcı yüzeyi bu dosyaya göre TR-first veya EN-first seçer.
description_en: Manage Ulak OS active locale (TR/EN toggle). "show" prints current locale, "tr" or "en" switches persistently. Locale state lives at `.claude/state/locale.txt`; README + user surface picks TR-first or EN-first based on that file.
agent: autonomous-program-director
allowed-tools: Read, Write, Bash, Glob
argument-hint: "tr | en | show"
model: claude-opus-4-7
---

# /ulak-locale — TR/EN aktif dil anahtarı

## Vizyon

Repo bilingualdır (TR + EN paralel dosyalar). Fakat runtime'da hangi dilin **aktif** olduğu tanımsızsa, kullanıcı "şu an TR'de miyim EN'de miyim" sorusunu yanıtlayamaz. `/ulak-locale` bu belirsizliği bitirir: tek satırlık state dosyası + üç komut alt-yüzey.

## When to use

- Kullanıcı "TR'ye geç" veya "İngilizce'ye al" dediğinde
- Yeni operatör onboarding — mevcut dili öğrenmek için `show`
- CI/CD pipeline — deploy öncesi aktif locale'i assert etmek için
- Documentation preview — README-TR mi README-EN mi render edilecek kararı

## When NOT to use

- Tek bir dosyayı dillendirmek için (onu doğrudan yazarsın)
- Translation memory / TMX yönetimi için (bu komut sadece toggle)
- Çoklu locale aktivasyonu için (bu komut binary: tr VEYA en)

## Sub-commands

### `/ulak-locale show`

**Davranış:**
1. `.claude/state/locale.txt` var mı bak.
2. Varsa dosyayı oku, tek satırı döndür.
3. Yoksa default olarak `tr` gösterir ve "state dosyası yok; default TR" notu eklenir.
4. Ek olarak:
   - state dosyasının tam yolu
   - hangi README'yi render edeceği (`README.md` → TR, `README.en.md` → EN)
   - slash komut frontmatter'ında hangi `description` alanının primary olduğu

### `/ulak-locale tr`

**Davranış:**
1. `.claude/state/` dizini yoksa oluştur.
2. `.claude/state/locale.txt` içine tek satır `tr` yaz (terminal newline olmadan veya olarak; POSIX geleneği ile LF+newline).
3. Confirmation mesajı: "Aktif locale: TR. README.md primary; komut frontmatter'ı `description` primary."

### `/ulak-locale en`

**Davranış:**
1. `.claude/state/` dizini yoksa oluştur.
2. `.claude/state/locale.txt` içine tek satır `en` yaz.
3. Confirmation mesajı: "Active locale: EN. README.en.md primary; slash command frontmatter `description_en` primary."

## State dosyası kontratı

**Path:** `.claude/state/locale.txt`

**Format:**
- tek satır (LF terminated OK, CRLF OK Windows'ta)
- sadece iki geçerli değer: `tr` veya `en`
- başka değer → validator reject eder
- UTF-8, BOM yok

**Lifecycle:**
- dosya yoksa → default `tr` (proje Türkiye kaynaklı)
- dosya varsa → içeriği wins
- `.gitignore`'da DEĞİLDİR (commit edilir ki operator geçişleri takip edebilsin)

## Governance bağı

Bu komut `docs/governance/localization-governance.md` kurallarıyla çalışır:

- Kural 1 (user-facing docs bilingual) → bu komut dili değiştirse bile her iki dosya kopyası da varlığını korur.
- Kural 4 (slash command description TR primary) → `/ulak-locale en` çağrılsa bile komut dosyalarının `description` alanı TR kalır; sadece "render edilen" taraf EN olur.
- Kural 6 (state file single source of truth) → locale state **yalnızca** `.claude/state/locale.txt`'den okunur; başka kaynak yetkisizdir.

## Anti-patterns

- ENV variable ile locale belirlemek (reproducibility bozulur)
- CLAUDE.md içine `locale: en` yazmak (CLAUDE.md runtime-state değil, runtime-contract'tır)
- iki locale'i aynı anda "aktif" saymak (binary toggle, stack değil)
- state dosyasını `.gitignore`'a atmak (operator visibility kaybolur)

## Integration

- `docs/runtime/localization-strategy.md` — neden bilingual, hangi yüzey hangi dil
- `docs/runtime/turkish-normalization.md` — TR karakter handling (aktif locale = tr olduğunda zorunlu)
- `docs/governance/localization-governance.md` — hangi dosyalar bilingual zorunlu
- `scripts/validate-bilingual.sh` — bilingual policy validator; `/ulak-locale` ile beraber CI'da koşar

## Örnek akışlar

### Yeni operatör onboarding
```
/ulak-locale show
→ "Aktif locale: TR (default, state dosyası yok)"
```

### Uluslararası demo öncesi geçiş
```
/ulak-locale en
→ "Active locale: EN. README.en.md primary."
git add .claude/state/locale.txt
git commit -m "chore: switch active locale to EN for demo"
```

### Tekrar TR'ye dönüş
```
/ulak-locale tr
→ "Aktif locale: TR. README.md primary."
```
