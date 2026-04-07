# Distribution

## Karar
Bu sistem tek vendor’a kilitlenmiş halde dağıtılmayacak.

## Doğru dağıtım modeli
1. **Tek çekirdek sözleşme**
2. **Vendor adaptörleri**
3. **Tek sürüm hattı**
4. **Arşivlenmiş iç sürümler**

## Neden?
Çünkü üç ayrı platform için üç ayrı bağımsız prompt yaşatmak zamanla çakışan kurallar, bozuk parity ve bakım kaosu üretir.

## Bu repo ne yapıyor?
- `prompts/core/` altında çekirdeği koruyor.
- `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` ile aynı sistemi farklı çalışma ortamlarına adapte ediyor.
- `.claude/` ve `.gemini/commands/` ile platforma özel otomasyon veriyor.
- `docs/archive/internal-releases/` ile tarihsel izi koruyor.
