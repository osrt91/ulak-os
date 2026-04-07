# Official compatibility notes

Bu repo; Claude Code, Codex/Copilot ve Gemini CLI için ayrı bağlam dosyaları üretir.

## Claude Code
- `CLAUDE.md`, project settings, slash commands, subagents ve MCP yapıları resmi dokümanlarda tanımlıdır.

## Codex / Copilot
- `AGENTS.md` agent instructions dosyaları ve `.github/copilot-instructions.md` repo talimatları GitHub/Copilot dokümantasyonunda tanımlıdır.
- Aynı sayfa, kök dizinde `CLAUDE.md` ve `GEMINI.md` dosyalarının da alternatif olarak kullanılabildiğini belirtir.

## Gemini CLI
- `GEMINI.md` proje bağlamı için resmi dokümante edilmiş dosyadır.
- `.gemini/commands/*.toml` özel komutları resmi Gemini CLI docs üzerinde tanımlıdır.

## Sonuç
Bu yüzden aynı çekirdeği üç farklı adaptör yüzeyiyle dağıtmak mantıklıdır.
