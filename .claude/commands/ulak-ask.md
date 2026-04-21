---
name: ulak-ask
description: Doğal dil query'yi mevcut Ulak OS komut/skill/agent'ına yönlendirir. "Konuşur gibi kullan" katmanı — kullanıcı plugin aramaz, prompt yazmaz, ne istediğini söyler. Anahtar kelime + niyet eşlemesi ile en uygun kapasiteyi önerir; belirsizse "did you mean?" disambiguation yapar.
description_en: Natural-language intent router. User states what they want in plain language; Ulak OS routes to the right existing command/skill/agent. Keyword + intent matching with "did you mean?" disambiguation fallback.
agent: autonomous-program-director
allowed-tools: Read, Grep, Glob
argument-hint: "doğal dil query (örn: 'auth'ta bug var ne yapayım', 'yeni SaaS yapacağım', 'build patladı')"
model: claude-opus-4-7
---

# /ulak-ask — doğal dil → komut yönlendirici

## Vizyon

"İnsan plugin aramasın, prompt yazmasın, konuşur gibi kullansın."

Ulak OS'un 15 komut + 10 skill + 27 agent yüzeyi büyüdü. Operatör hepsini ezberlemez, ezberlemesi gerekmez. Bu komut **intent router** katmanıdır: operatör kendi dilinde ne istediğini söyler, `/ulak-ask` bunu tablo eşlemesiyle **mevcut** bir kapasiteye yönlendirir.

## When to use

- Operatör hangi komutu çağıracağından emin değil
- "X yapmam lazım ama hangi slash komutu?" sorusu var
- Çok katmanlı iş (audit + scaffold + pattern extract) — /ulak-ask hangisinden başlanacağını söyler
- Yeni operatör onboarding — komut isimlerini ezberlemeden çalışabilsin

## When NOT to use

- Komut adı zaten net — doğrudan çağır (`/director komple`, `/ulak-scaffold` vb.)
- Tam program lazım — direkt `/director komple` daha hızlı
- Dosya/kod düzeyi soru — `/ulak-ask` **komut önerir**, kod yazmaz

## Routing protokolü

### 1. Query parse
Operatör doğal dil girer. Parser:
- anahtar kelimeleri ayıklar (TR + EN normalize),
- niyet sinyallerini tanır ("audit" / "scaffold" / "bug" / "pattern" / "yeni" / "patladı" / "eksik"),
- proje durumu hakkında ipucu varsa not alır (greenfield / brownfield).

### 2. Intent table lookup
`docs/runtime/intent-router.md` dosyasındaki 100-satırlık eşleme tablosuna bakılır. En yüksek skorlu eşleşme seçilir. Skorlama:
- **exact keyword hit** = 3 puan
- **synonym/stem hit** = 2 puan
- **domain hint hit** = 1 puan

### 3. Ambiguity handling
Eğer iki veya daha fazla kapasite ≥ aynı skoru alırsa:
- **disambiguation kuralı** uygulanır (bkz. `docs/runtime/intent-router.md §Disambiguation`),
- seçim netleşmezse operatöre kısa "did you mean?" listesi sunulur (en fazla 3 aday).

### 4. No-match fallback
Eşleşme skoru 0 ise:
- mevcut komut/skill/agent listesine link verilir,
- `/pack-gap-audit` önerilir: belki gereken kapasite hiç yok, eklenmesi gerekebilir.

### 5. Execute hint
Eşleşme netse çıktı:
```
Intent: <parsed query özet>
Best match: /<command-name>
Rationale: <neden bu>
Next step: çalıştırmak için şu komutu yaz: /<command-name> [varsa argüman]
```

Operatör kabul ederse komutu kendisi tetikler. `/ulak-ask` **komut çalıştırmaz** — sadece yönlendirir. Bu tasarım bilinçlidir: niyet onayı operatörde kalır.

## Example runs

### Örnek 1 — TR, net eşleşme
```
/ulak-ask "yeni bir SaaS başlatacağım"
```
Output:
```
Intent: greenfield SaaS creation
Best match: /ulak-scaffold
Rationale: yeni + SaaS + başlat = greenfield scaffolder
Next step: /ulak-scaffold
```

### Örnek 2 — TR, bug/debug
```
/ulak-ask "auth kısmında garip bir şey oluyor"
```
Output:
```
Intent: bug investigation — auth subsystem
Best match: /ulak-audit-deep (scope: auth dimension)
Secondary: superpowers:systematic-debugging
Rationale: "garip bir şey" = unverified symptom; önce 14-dim scorecard, sonra systematic-debugging
Next step: /ulak-audit-deep
```

### Örnek 3 — TR, build failure
```
/ulak-ask "build patladı"
```
Output:
```
Intent: build triage
Best match: /triage-build
Rationale: "patladı" = failure symptom; triage-build stack-agnostic
Next step: /triage-build
```

### Örnek 4 — EN, pattern export
```
/ulak-ask "extract a reusable pattern from this repo"
```
Output:
```
Intent: pattern extraction + ledger registration
Best match: /ulak-pattern-extract
Rationale: "extract" + "reusable pattern" = pattern-import-ledger flow
Next step: /ulak-pattern-extract
```

### Örnek 5 — Ambiguous, disambiguation
```
/ulak-ask "mevcut projeyi baştan aşağı bir bak"
```
Output:
```
Intent: full-repo audit (ambiguous: program vs scorecard)
Candidates:
  1. /director komple  — program-level (tek verdict, 15 artefakt)
  2. /ulak-audit-deep  — scorecard (14-dim, A-F grade)
Disambiguation rule: operatör "rapor + signoff" istiyorsa /director; "puan + gap matrix" istiyorsa /ulak-audit-deep.
"Baştan aşağı" kapsamlı + standart program → varsayılan: /director komple
Next step: /director komple  (yoksa /ulak-audit-deep de)
```

## Routing mantığı kaynağı

Tablonun kendisi burada değil — versiyon kontrolü için ayrı dosyada:

- **`docs/runtime/intent-router.md`** — 100 intent örneği (50 TR + 50 EN), her biri 3 kolon: Intent / Matched Capability / Rationale
- Güncellenmesi: yeni komut veya skill eklendiğinde ilgili satırlar bu tabloya da eklenir (`/pack-gap-audit` bu parity'yi denetler).

## Mevcut kapasite tarayıcısı

Routing yaparken **sadece bu listeyi** referans alır (uydurma komut önermez):

**24 komut**: `/director`, `/ulak-scaffold`, `/ulak-start`, `/ulak-next-steps`, `/ulak-audit-deep`, `/ulak-brainstorm`, `/ulak-subagent-dispatch`, `/ulak-test-driven`, `/ulak-pattern-extract`, `/ulak-mcp-discover`, `/final-verdict`, `/intake`, `/frontend-war-room`, `/pack-gap-audit`, `/triage-build`, `/ulak-design-ref`, `/ulak-intake`, `/ulak-hello`, `/ulak-packs`, `/ulak-search`, `/ulak-locale`, `/ulak-explain`, `/ulak-demo`, `/ulak-ask`

**10 skill** (örn): `saas-scaffolder`, `fourteen-dimension-audit`, `project-intake`, `final-validation`, `pack-gap-completion`, `research-currency`, `multi-agent-orchestration`, `awesome-packs-index`, `mcp-governance-auto`, `god-module-decomposition`

**27 agent** (örn): `autonomous-program-director`, `cartographer`, `architecture-lead`, `security-hardening-lead`, `infra-release-sre`, `design-system-architect`, `localization-i18n-lead`, `market-researcher`, `qa-validation-commander`, `red-team-challenger`, `release-readiness-auditor`, `backend-api-architect`, `data-database-governor`, `privacy-compliance-counsel`, `seo-aso-growth-strategist`, `support-ops-orchestrator`, `prompt-skill-plugin-governor`, `educational-ux-specialist`, `frontend-ios-flutter-director`, `product-business-strategist`, `security-redteam`, `admin-persona`, `bayi-persona`, `compliance-persona`, `customer-persona`, `developer-persona`, `support-persona`

Tablo dışı bir kapasiteye asla yönlendirilmez. "Bu yok ama gerekli" olduğunda çıktı: "öneri: `/pack-gap-audit` çalıştır."

## Rules

- **Komut çalıştırmaz, önerir.** Niyet onayı operatörde kalır.
- **Uydurma yasak.** Sadece yukarıdaki gerçek 15 komut + 10 skill + 27 agent'tan seçim yapar.
- **Secrets/tokens/email yok.** Query'de böyle bir şey geçerse operatöre redact uyarısı verir, routing yapmaz.
- **Did-you-know değil, did-you-mean.** Bu komut non-obvious finding üretmez; sadece intent eşler.
- **Persistent değildir.** `/ulak-ask` artefakt yazmaz; sonucu inline döner. (Bu tek istisna — default "diske yaz" protokolü burada geçerli değildir çünkü router önerisi geçici bir öneridir.)

## Integration

- `docs/runtime/intent-router.md` — 100-satır eşleme tablosu (TR + EN)
- `.claude/commands/pack-gap-audit.md` — kapasite eksiği tespit edilirse yönlendirilir
- `docs/runtime/router.md` — üst seviye router decision (bu komut onun kullanıcı yüzü)
- `docs/adapters/universal-runtime-contract.md` — "asla yapılmayacaklar" listesi uygulanır

## EN quick note

`/ulak-ask` is the natural-language front door. User types intent in plain language (TR or EN), the command maps it to one of the existing 24 commands / 10 skills / 27 agents via `docs/runtime/intent-router.md`. Outputs a suggestion — does not execute. Ambiguous → "did you mean?" list (max 3). No match → suggests `/pack-gap-audit`. Never invents capabilities.

ARGUMENTS:
$ARGUMENTS
