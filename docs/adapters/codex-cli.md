# Codex / Copilot adapter

## Neden ayrı dosya var?
Codex/Copilot tarafında güvenli ve taşınabilir yol; kök `AGENTS.md` ile repo davranışını yönlendirmek, gerekiyorsa `.github/copilot-instructions.md` ile ek repo talimatı vermektir. Codex ve GitHub Copilot CLI Claude Code'un `@`-import sözdizimini desteklemez, bu yüzden bağlam dosyalarını **reading order** halinde liste olarak sunarız.

## Önerilen kullanım akışı
1. Repo git altında olsun.
2. Önce read-only/suggest tarzı modda repo okunsun.
3. İlk istekte agent'a şu yönlendirmeyi ver:
 ```
 Read AGENTS.md, CLAUDE.md, prompts/core/ulak-os-core-contract-2.0.0.md,
 docs/adapters/codex-cli.md, and docs/adapters/universal-runtime-contract.md.
 Then execute the Phase 0 → Phase 5 protocol for: <görev>
 ```
4. Sonra görev tipi açık yazılsın:
 - greenfield / brownfield / rescue / refactor / release-readiness / localization

## v2.1 protokol özet
Codex/Copilot, Claude Code'un autonomous-program-director'ünün eşdeğerini doğrudan çalıştırmaz, ama aynı 8-phase artefakt zincirini takip etmek **zorundadır**:

| Phase | Üretilecek artefakt | Kabul kriteri |
|---|---|---|
| 0 — Environment lock | runtime-manifest.md, assumptions.md | router decision committed |
| 1 — Deep inventory | intake.md, inventory.md (file:line) | klasör dökümü kabul edilmez |
| 2 — Specialist evidence | evidence-register.md, deep-scan-report.md | birden çok uzman bakışı |
| 3 — Did-you-know | did-you-know.md | non-obvious findings zorunlu |
| 4 — Synthesis | analysis-findings.md, target-state.md, execution-roadmap.md, validation-plan.md, pack-gap-register.md | beşi de var |
| 5 — Manager verdict | manager-verdict.md, validation-result.yaml | signoff_status açık |

Codex'in tek-agent yapısı paralel specialist dispatch'i zor — bu yüzden Phase 2'yi sıralı uzman geçişi olarak yür: önce security, sonra infra, sonra design-system, vb. Her uzman geçişi için ayrı `reports/current/specialists/<role>.md` dosyası üret.

## Şemalar (her run için zorunlu)
- `docs/runtime/router.md` — 9-field router decision YAML
- `docs/runtime/output-profiles.md` — 7 profil (AUDIT / GREENFIELD_BUILDER / BROWNFIELD_INTERVENTION / LOCALIZATION_REPAIR / MARKET_ENTRY / PACK_GENERATION / RELEASE_READINESS)
- `docs/governance/finding-schema.md` — her finding için canonical YAML
- `docs/governance/evidence-trust-scoring.md` — T1-T7 tier zorunlu
- `docs/runtime/validation-result-schema.md` — Phase 5 signoff

## Güvenli mod önerisi
- İlk koşu: okuma + plan (analysis-only mode)
- İkinci koşu: küçük, kontrollü edit (controlled-editing mode)
- Üçüncü koşu: validation ve residual risk

---

## Vendor primitive matrix

Codex'in Claude Code ile birebir eşdeğer olmayan primitif'leri vardır. Aşağıdaki matris bir Ulak OS koşusu sırasında neye dayanabileceğini belirler:

| Primitive | Claude Code | Codex CLI | Gemini CLI | Codex workaround |
|---|---|---|---|---|
| `/slash` dispatch | Evet (native) | **Hayır** | Evet (sınırlı) | NL trigger map — bkz. `AGENTS.md` §"Natural-Language Trigger Map" |
| `@`-import (transitive) | Evet | **Hayır** | Kısmi | Reading order listesi (manuel sequential read) |
| Paralel subagent (Task tool) | Evet | **Hayır** | Hayır | Sıralı uzman geçişi + `reports/current/specialists/<role>.md` dosyaları |
| Hook subsystem (PreToolUse/PostToolUse) | Evet | **Hayır** | Hayır | Operator-gated manual checkpoint |
| Native MCP call | Evet | Kısmi | Evet | Plain Bash + HTTP call veya governance allowlist |
| Long-context (1M) | Evet | **Evet** | Evet | Tam reading order tek oturumda yüklenebilir |
| `Read` / `Write` / `Edit` / `Bash` | Evet | **Evet** | Evet | Birebir eşdeğer — primary artefakt motoru |
| Skill invocation | Evet (`Skill` tool) | **Hayır** | Hayır | Skill'in prompt'unu manuel inline et (`.claude/skills/<name>/SKILL.md` oku, uygula) |
| Persisted state (hooks + session) | Evet | **Hayır** | Hayır | `reports/current/*.md` dosyaları + `.claude/state/*.txt` manual read |

### Genel kural
Claude Code tarafında "tek mesajda paralel dispatch" ile yapılan işi, Codex tarafında **sıralı + disk artefaktı** pattern'i olarak sur. Kaybedilen paralelliği hız kaybı olarak kabul et, doğruluk kaybı olarak değil — artefakt zinciri her iki vendor'da da aynı verdict standardına bağlı.

---

## Slash-to-NL conversion principles

`/slash` komutu olmadığı için kullanıcı doğal dil kullanır. Dört prensip:

1. **Intent tanı, komut numarası atama** — Kullanıcı "audit" dediğinde 9 farklı komut (director, intake, audit-deep, vb.) aday olabilir. Keyword + context kombinasyonuyla en doğru olanı seç, belirsizse tek bir disambiguation sorusu sor.
2. **Template aynen render et, uydurma** — `/ulak-hello` için Codex `.claude/commands/ulak-hello.md` dosyasını okur, oradaki template'i **birebir** chat'e yazar. Hiçbir madde uydurulmaz.
3. **Artefakt disk'e yaz, özet chat'e** — Audit tarzı komutlar (`/director komple`, `/ulak-audit-deep`) için artefaktlar `reports/current/**` altına yazılır, chat'te sadece özet gösterilir. "Inline döndüm" protokol ihlali sayılır (bkz. `docs/governance/artefact-write-authorization.md`).
4. **Wizard'ı tek mesajda sıkıştırma, faza böl** — `/ulak-start` wizard'ı 27 soruyu 5 faz'da sorar. Codex tek blokta toplu sormaz — kullanıcının her faz sonunda onay vermesi akışın parçası.

---

## Kullanım örnekleri (3 senaryo)

### Senaryo 1 — İlk kez giren kullanıcı (greenfield)
```
User: selam ulak
Codex: [AGENTS.md §NL Trigger Map okur → /ulak-hello protokolü]
       [.claude/commands/ulak-hello.md template'ini aynen render eder]
       [3 seçim listesini kullanıcıya sorar]

User: 1
Codex: [/ulak-start protokolüne geçer]
       [Q0 mod seçimi sorusu → Phase 1 → ... → özet ekran]
       [Onay sonrası Bash tool ile `ulak scaffold <flags>` çalıştırır]
```

### Senaryo 2 — Brownfield rescue
```
User: mevcut projeyi komple audit et
Codex: [→ /director komple protokolü]
       [Phase 0: runtime-manifest.md + assumptions.md yazar]
       [Phase 1: intake.md + inventory.md — file:line citations]
       [Phase 2: security, infra, design-system, data uzmanlarını
                 SIRALI çalıştırır — her biri reports/current/specialists/ altında]
       [Phase 3: did-you-know.md — non-obvious findings]
       [Phase 4: analysis-findings + target-state + roadmap + validation-plan + pack-gap]
       [Phase 5: manager-verdict.md + validation-result.yaml]
       [Chat'te sadece verdict özeti + residual risk]
```

### Senaryo 3 — Post-scaffold runbook
```
User: scaffold bitti, şimdi ne yapayım
Codex: [→ /ulak-next-steps protokolü]
       [temiz-gunler klasörü için kişisel runbook üretir]
       [12 adım + her adım için tutorial link + env key listesi]
       [docs/tutorials/supabase.md, vercel.md, github.md referansları inline]
```

---

## Not
Bu repo tek seferde büyülü dönüşüm vaat etmez; repo erişimi, doğru izinler ve validation komutları varsa güçlü sonuç üretir. Codex/Copilot'un gücü uzun bağlamı ve kod yazma odaklı kullanım iken Claude Code'un gücü paralel agent dispatch ve native multi-tool orkestrasyon. v2.1 protokolü ikisini de aynı verdict standardına bağlar.

NL trigger map'i kök `AGENTS.md` dosyasında "Natural-Language Trigger Map" bölümünde kanonik olarak tanımlanır. Walkthrough örneği için `docs/walkthrough/01-first-saas-end-to-end-codex.md` dosyasına bak (Claude Code variant ile aynı senaryo, Codex NL akışıyla).
