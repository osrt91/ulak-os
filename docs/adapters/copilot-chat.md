# GitHub Copilot Chat adapter (VS Code, stable)

Bu dosya **GitHub Copilot Chat**'in Ulak OS çekirdeğine nasıl bağlandığını tanımlar. Kardeş dosyalar:
- `docs/adapters/claude-code.md` — Claude Code (slash komut + paralel subagent dispatch destekli)
- `docs/adapters/codex-cli.md` — Codex / GitHub Copilot CLI (reading-order talimat tabanlı)
- `docs/adapters/universal-runtime-contract.md` — platformdan bağımsız davranış sözleşmesi

## Scope ve kapsam dışı

- **Kapsam içi**: GitHub Copilot Chat, VS Code 1.90+ stable release'de. `.github/copilot-instructions.md` otomatik okunması destekli.
- **Kapsam dışı**: GitHub Copilot Workspace (preview). Workspace'in artefakt/taskflow davranışı burada iddia edilmez; destek olgunlaşınca ayrı bir adapter dosyası açılır.
- **Kapsam dışı**: `gh copilot` CLI. O `docs/adapters/codex-cli.md` kapsamında ele alınır.

## Copilot Chat'in Ulak OS'a mal ettiği fark

| Boyut | Claude Code | Copilot Chat |
|---|---|---|
| Slash komut dispatch | Native (`.claude/commands/*.md` slash olarak çağrılır) | **Yok** — komutlar ancak natural-language trigger ile simüle edilir |
| `@`-import chain | Native (CLAUDE.md'den zincirleme yükler) | Yok — `.github/copilot-instructions.md` düz okur, `AGENTS.md`'deki reading-order'ı kendi yürütür |
| Paralel subagent dispatch | Native (tek mesajda çoklu Task call) | **Yok** — tek-agent; specialist'ler sıralı yürür |
| Artefakt yazımı | Otomatik `reports/current/**` altına | Director protokolü altında aynı; diğer durumlarda inline-only, operator onayı gerekir |
| Terminal execute | Native bash | VS Code terminal — komut önerilir, kullanıcı yapıştırır/onaylar |
| Workspace scope | Repo kökünden cwd otomatik | `@workspace` prefix önerilen; `#file:<path>` dar sorgu için |

## Önerilen kullanım akışı

1. VS Code'u Ulak OS kurulu repo kökünden aç.
2. `.github/copilot-instructions.md` ve `AGENTS.md` workspace'de **bulunmak zorundadır**. Yoksa Copilot Chat, Natural-Language Trigger Map'i yükleyemez ve davranış tahmini olmaz.
3. İlk prompt olarak **workspace-scoped** bir trigger kullan:
   ```
   @workspace selam ulak
   ```
   veya tam denetim için:
   ```
   @workspace bu projeyi audit et, Phase 0 → Phase 5 protokolünü uygula
   ```
4. Copilot, `.github/copilot-instructions.md` içindeki trigger map ile eşleştirir, hangi slash komutun simüle edildiğini söyler, kaynak `.claude/commands/<name>.md` dosyasını okuyup flow'u inline render eder.

## VS Code integration noktaları

- **`@workspace`** — Copilot'un repo geneline indexed erişimi. `AGENTS.md`'deki reading-order'ı doğru toparlayabilmesi için bu prefix'i önerin.
- **`#file:<path>`** — tek-dosya scope. Ulak OS'ta tek bir template veya runbook'u sorgularken kullanışlı; ama director protokolünü buradan başlatma — repo genişliği kaybolur.
- **VS Code terminal** (`Ctrl+` / `Cmd+\``) — Copilot Chat komut yürütemez; üretilen shell komutları kullanıcı tarafından terminal'e yapıştırılır. Bu, adapter'ın doğrudan kısıtıdır.
- **Inline suggestions** — bu yüzey (kod içi tek-satır öneri) Ulak OS Natural-Language trigger'larını yakalamaz; her Ulak OS etkileşimi Chat paneli üzerinden geçer.

## Natural-Language Trigger Map — otorite

Slash-komut yokluğunu telafi eden **tek otorite**: `.github/copilot-instructions.md` içindeki "Ulak OS — Natural-Language Trigger Map" bölümü. O dosya 60+ trigger'ı 24 Ulak OS kapasitesine eşler (onboarding, scaffolding, term lookup, service setup, audit, routing, multi-agent, TDD, i18n toggle).

Bu adapter dosyası tekrar listelemez; okuyucuyu `.github/copilot-instructions.md`'ye yönlendirir. Trigger eklemek/çıkarmak isteyenler o dosyayı düzenler.

## File-scoped vs workspace-scoped davranış

| Operatör niyeti | Önerilen prefix | Gerekçe |
|---|---|---|
| Yeni SaaS scaffold | `@workspace yeni saas` | Wizard tüm sektör + rule pack'lerini görmeli |
| Tek terim açıklaması | `rls nedir` (prefix gerekmez) | `/ulak-explain` `beginner-glossary.md`'yi okur — tek dosya yeter |
| Audit / director / pack-gap | `@workspace` zorunlu | Phase 0 → 5 repo genelini gerektirir |
| Walkthrough okuma | `#file:docs/walkthrough/01-first-saas-end-to-end-copilot.md` | Lineer okuma, tek dosya scope'u optimal |
| Tutorial yürütme | `@workspace supabase nasıl` | Tutorial + scaffold edilmiş `.env.local` cross-reference'ı gerekir |

## v2.1 protokol özet — Copilot Chat için

Copilot Chat, Claude Code'un autonomous-program-director'ünün eşdeğerini doğrudan çalıştırmaz. Ama aynı 8-phase artefakt zincirine uymak **zorundadır** — sadece execution modeli farklıdır:

| Phase | Üretilecek artefakt | Copilot Chat'te kabul kriteri |
|---|---|---|
| 0 — Environment lock | runtime-manifest.md, assumptions.md, active-variables.yaml | Router decision committed; `@workspace` tekrar doğrulandı |
| 1 — Deep inventory | intake.md, inventory.md (file:line) | Copilot dosya:satır citation'ı üretir; `ls` özeti reddedilir |
| 2 — Specialist evidence | evidence-register.md, specialists/*.md | Paralel yok; specialist geçişleri **sıralı** (security → infra → design-system → data → compliance). Her biri kendi `reports/current/specialists/<role>.md` dosyasına yazılır |
| 3 — Did-you-know | did-you-know.md | Non-obvious findings zorunlu; boş/trivial reddedilir |
| 4 — Synthesis | analysis-findings.md, target-state.md, execution-roadmap.md, validation-plan.md, pack-gap-register.md | Beşi de var |
| 5 — Manager verdict | manager-verdict.md, validation-result.yaml | signoff_status açık; residual risk yazılı |

**Önemli**: Bu run'da disk-yazımı `docs/governance/artefact-write-authorization.md` kapsamında **yetkilendirilmiştir** — director protokolü aktif olduğu sürece Copilot `reports/current/**` altına inline döndürmeden yazar. Default "planning doc yazma" kuralı bu yüzeyde geçersizdir.

## Slash-command yokluğu + NL compensation

Copilot Chat'in slash-command desteklemeyişi, Ulak OS için bir dezavantaj değil; **natural-language layer**'a zorlayan bir tasarım kısıtıdır. Kullanıcı:
- Plugin aramaz (kapasite zaten yüklü).
- Komut ismini hatırlamaz (doğal dil tetikler).
- Prompt yazımında engineer'lik yapmaz (Ulak'a "ne istediğini" söyler).

Bu, `/ulak-ask` ve `/ulak-search` gibi NL routing komutlarının zaten var olan vizyonunun doğal uzantısıdır. Copilot adapter'ı, bu NL-first UX'i **zorunlu** kılar.

## Güvenli mod önerisi

- **İlk koşu**: okuma + plan (analysis-only). `@workspace` ile `/intake` simüle et.
- **İkinci koşu**: küçük, kontrollü edit. VS Code'un "Accept" butonuyla diff-by-diff onay ver.
- **Üçüncü koşu**: validation + residual risk — `/final-verdict` simülasyonu.

## Şemalar (her run'da uygulanır)

- `docs/runtime/router.md` — 9-field router decision YAML
- `docs/runtime/output-profiles.md` — 7 output profile
- `docs/governance/finding-schema.md` — canonical finding YAML
- `docs/governance/evidence-trust-scoring.md` — T1-T7 trust tier zorunlu
- `docs/runtime/active-variable-contract.md` — Phase 0 pinned runtime state
- `docs/runtime/validation-result-schema.md` — Phase 5 signoff

## Tipik sorunlar + çözüm

| Sorun | Belirti | Çözüm |
|---|---|---|
| Copilot `selam ulak`'a tour yerine generic cevap veriyor | `.github/copilot-instructions.md` workspace'de yok veya Copilot okumuyor | Workspace root'ta dosyanın var olduğunu doğrula; VS Code'u restart et; `@workspace` prefix kullan |
| Slash komut yazdım çalışmadı | `/director komple` yazdın, Copilot "slash yok" cevabı döndü | Natural-language eşdeğeri yaz: "bu projeyi audit et" veya "director komple koş" |
| Paralel specialist dispatch istedim, tek tek yürüyor | Beklenen davranış | Copilot Chat tek-agent. Sıralı specialist geçişi 5-phase integrity'yi bozmaz |
| Terminal komutu çalıştırmıyor | Copilot komut önerdi ama yürütmedi | Beklenen — VS Code terminal'ini `Ctrl+\`` ile aç, komutu yapıştır, `Enter` |
| Artefakt yazmıyor | `reports/current/**` boş | Eğer director protokolü aktif değilse inline-only beklenen; director protokolü açıksa `.github/copilot-instructions.md` §Limits'i oku |

## Not

Copilot Chat tek seferde büyülü dönüşüm vaat etmez; ama Ulak OS governance yığını + 60+ NL trigger + workspace indexing üçlüsü, Claude Code'la **semantik parite** sağlar. UI chat turn'ları ile ilerler; **davranış** slash komut variant'ı ile birebir aynıdır.
