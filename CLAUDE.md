# CLAUDE.md

@prompts/core/ulak-os-core-contract-2.0.0.md
@docs/adapters/universal-runtime-contract.md
@docs/adapters/claude-code.md
@docs/governance/vendor-capability-matrix.md
@docs/runtime/localization-strategy.md

## Project identity
- Product: Ulak OS
- Purpose: cross-platform prompt operating system and repo runtime
- Platforms: claude code | codex/copilot | gemini cli
- State: hybrid

## Runtime defaults
- intent netse menü döngüsüne geri dönme
- artefakt zincirini erken başlat
- önce harita çıkar, sonra müdahale et
- customer/admin/public api ayrımını koru
- validation koşmadan done deme
- locale aware komutlar: /ulak-locale ile toggle (state `.claude/state/locale.txt`; default `tr`)
- **director protokolü altında `reports/current/**` altındaki artefaktları diske yaz** — default "planning/decision/analysis doc yazma" kuralı bu yüzeyde geçersizdir; inline dönmek protokol ihlalidir (bkz. `docs/governance/artefact-write-authorization.md`)

## Working rule
Bu repo bir örnek ürün olduğu için gerektiğinde önce repo yapısını açıkla, sonra hedef kullanım modunu seç, sonra rapor zincirini başlat.
