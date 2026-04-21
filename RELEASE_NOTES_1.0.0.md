# Ulak OS 1.0.0 — First Stable Public Release

**Release date:** 2026-04-07
**Author:** Oğuzhan Sert <info@>

## Overview

Ulak OS 1.0.0 is the first stable public release of the vendor-neutral prompt operating system formerly known internally as **Claude Ulak**. This release closes the internal `1.x` development line (1.0.0–1.9.1) and reopens versioning under the public `Ulak OS` brand starting at 1.0.0.

## What changed from Claude Ulak 1.9.1

- **Brand**: "Claude Ulak" → "Ulak OS" across all user-facing documentation
- **Repository name**: `ulak-os` (formerly `claude-ulak`)
- **Core contract file**: `ulak-os-core-contract-1.0.0.md` (formerly `claude-ulak-core-contract-1.9.0.md`)
- **Three-adapter pattern preserved**: Claude Code, Codex/Copilot, Gemini CLI
- **CI quality gates added**: schema validation, @import chain check, brand consistency, secret scanning (gitleaks)
- **Cross-platform bootstrap scripts**: `.sh` + `.ps1` for each vendor
- **Public skill integration**: `docs/skills-integration/superpowers-mapping.md` + PoC `/ulak-intake` wrapper command
- **Multi-language**: TR (primary) + EN parallel for README, adapters, core contract, examples, mapping
- **Sample artifacts**: `docs/examples/sample-{intake,inventory,manager-verdict}.md` for onboarding clarity
- **Artefact chain consistency**: AGENTS.md previously listed only 8 required artefacts while the core contract listed 12; both now consistently specify the full 12-artefact chain
- **Quality fixes**: `.gitkeep` for `reports/current/`, `.gitattributes` for line endings, MCP env var documentation in README, troubleshooting section in README
- **Ecosystem integration**: awesome-design-md fetch script + `/ulak-design-ref` wrapper, ecosystem related-work doc

## Why 1.0.0?

The internal `1.x` series (1.0.0–1.9.1) reconstructed and consolidated the V6→V10 prompt operating system evolution. With the brand change to vendor-neutral "Ulak OS" and the addition of CI quality gates, the project now meets first-stable-public-release criteria:

- Single canonical repo
- CI validates every commit
- Cross-platform installation
- Multi-language documentation (TR + EN)
- Three-vendor adapter parity

## Migration from Claude Ulak 1.9.1

For users of the previous internal version, see `docs/history/version-lineage.md` for the full version map and migration notes. The core contract logic is unchanged; only the brand and packaging differ.

## Known limitations (deferred to v1.1+)

- 5 additional superpowers wrapper commands (only `/ulak-intake` PoC included)
- Translations to FR, DE, ES, AR, JA, ZH (TR + EN only in 1.0.0)
- Smoke test matrix (3 vendor × 5 commands)
- Plugin marketplace publication
- Eval/golden prompt regression suite
- Executable demo projects under `examples/`

See `ROADMAP.md` for the full v1.1+ list.
