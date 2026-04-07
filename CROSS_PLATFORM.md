# Cross-platform strategy

## Soru
Aynı promptu Claude, Codex/Copilot ve Gemini’de nasıl problemsiz dağıtırız?

## Cevap
Ayrı ayrı kopyalanmış master promptlar üretmeyiz. Bunun yerine:
- aynı çekirdeği koruruz,
- farklı araçların tanıdığı bağlam dosyalarını üretiriz,
- platforma özel komutları ayrı klasörlerde tutarız.

## Eşleme
- Claude Code → `CLAUDE.md` + `.claude/`
- Codex/Copilot → `AGENTS.md` + `.github/copilot-instructions.md`
- Gemini CLI → `GEMINI.md` + `.gemini/commands/`

## Not
Davranış ve kalite barı aynı kalmalı. Sadece taşıma yüzeyi değişmeli.
