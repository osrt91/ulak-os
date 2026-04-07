# Codex / Copilot adapter

## Neden ayrı dosya var?
Codex/Copilot tarafında güvenli ve taşınabilir yol; kök `AGENTS.md` ile repo davranışını yönlendirmek, gerekiyorsa `.github/copilot-instructions.md` ile ek repo talimatı vermektir.

## Önerilen kullanım akışı
1. Repo git altında olsun.
2. Önce read-only/suggest tarzı modda repo okunsun.
3. İlk istekte şu yönlendirme verilsin:
   - `Read AGENTS.md, CLAUDE.md, docs/adapters/codex-cli.md and docs/adapters/universal-runtime-contract.md, then choose the correct program mode.`
4. Sonra görev tipi açık yazılsın:
   - greenfield / brownfield / rescue / refactor / release-readiness

## Güvenli mod önerisi
- İlk koşu: okuma + plan
- İkinci koşu: küçük, kontrollü edit
- Üçüncü koşu: validation ve residual risk

## Not
Bu repo tek seferde büyülü dönüşüm vaat etmez; repo erişimi, doğru izinler ve validation komutları varsa güçlü sonuç üretir.
