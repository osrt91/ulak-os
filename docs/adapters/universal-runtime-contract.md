# Universal runtime contract

Bu dosya platformdan bağımsız davranış sözleşmesidir.

## Sistem ne yapmalı?
- projeyi sıfırdan, ortadan veya final aşamasından okuyabilmeli,
- route edebilmeli,
- context bütçesini yönetebilmeli,
- gerekli uzmanlık yüzeylerini aktive edebilmeli,
- artefaktları yazabilmeli,
- gerekli pack/skill/command/MCP eksiklerini söyleyebilmeli,
- validation kapılarını uygulayabilmeli.

## Çekirdek çalışma sırası
1. route
2. intake
3. inventory
4. evidence register
5. research gerekiyorsa research
6. findings
7. target-state
8. roadmap
9. validation plan
10. manager verdict

## Asla yapılmayacaklar
- net intent varken tekrar menü açmak
- kanıtsız büyük iddia üretmek
- customer/admin/public API ayrımını bozmak
- büyük rewrite’ı tek vuruşta dayatmak
- validation olmadan done demek

## Runtime primitive kontratı

Ulak OS bir vendor üzerinde "tam çalışır" sayılabilmek için şu primitiveler desteklenmeli. Vendor-bazlı durum için `docs/governance/vendor-capability-matrix.md` otorite kaynaktır.

### Temel (tüm vendor zorunlu)
- File Read + Grep + Glob (repo okuma)
- File Write / Edit (artefakt zinciri yazma)
- Bash / shell execute (validator + toolchain-precheck çalıştırma)
- Multi-turn session memory (CLAUDE.md / GEMINI.md / AGENTS.md gibi context dosyası)

### Zenginleştirici (eksikse NL fallback yeterli)
- Slash command dispatch → natural-language routing yeterli (Codex/Copilot pattern'i)
- Subagent parallel dispatch → serial workaround yeterli (ama slow, Phase 2 Waves-pattern'e sığar)
- `@`-import syntax → reading-order listesi yeterli (AGENTS.md pattern'i)
- Skill invocation → inline protokol metni yeterli
- MCP servers → manuel API wrapper yeterli (design-ref, github entegrasyonları)
- Hooks + settings-level permissions → CI-level policy yeterli

### Kritik eksik (vendor kullanılamaz)
- File Read yoksa → Ulak OS repo haritasını çıkaramaz
- Bash/shell yoksa → `validate-*.sh` validator'ları koşmaz → Phase 5 signoff blocked
- File Write yoksa → `reports/current/**` artefakt zinciri üretilemez

### Vendor destek statü seviyeleri
- **FULL** — tüm 24 native komut slash-dispatch ile çalışır (Claude Code).
- **FULL-MINUS** — tüm 24 komut çalışır; bazıları NL/serial fallback kullanır (Gemini CLI).
- **CORE** — komutlar NL trigger ile çalışır; artefakt zinciri üretilir (Codex CLI).
- **LIMITED** — read-heavy komutlar OK; write/MCP-heavy kısıtlı (Copilot Chat).

Komut-bazlı kırılım ve exemption protokolü için `docs/governance/vendor-capability-matrix.md`'e bak. Disk gerçekliği `scripts/validate-vendor-parity.sh` ile doğrulanır.
