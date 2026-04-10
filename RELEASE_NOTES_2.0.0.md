# Ulak OS 2.0.0 — CLI Console + Memory + Vendor Adapters

**Release date:** 2026-04-09
**Author:** Oğuzhan Sert <info@oguzhansert.dev>

## Overview

Ulak OS 2.0.0 adds a TypeScript CLI orchestration layer, a persistent project memory system, and a vendor adapter abstraction on top of the v1.0.0 prompt pack. The prompt operating system can now be invoked as a standalone `ulak` binary in addition to being used as a prompt pack inside Claude Code, Codex/Copilot, or Gemini CLI.

## What's new

- **CLI orchestration**: `ulak` command with 8 subcommands — `init`, `run`, `status`, `validate`, `memory`, `config`, `upgrade`, `export`
- **Project memory**: SQLite + FTS5 persistent store (`.ulak/memory.db`) with cross-session learning extraction
- **Vendor adapters**: Subprocess-based auto-detection and routing for Claude Code, Codex/Copilot, and Gemini CLI
- **Pack system**: `prompts/pack.json` manifest with loader, validator, and upgrade scaffolding
- **TypeScript infrastructure**: 18 source files under `src/`, compiled to `dist/`, strict `tsconfig.json`
- **Platform command parity**: Claude and Gemini now each have 8 commands (was 7 and 5)
- **Core contract v2.0.0**: Adds CLI orchestration, memory, and adapter sections to the vendor-agnostic contract
- **Full EN translation coverage**: 17 new `.en.md` files across docs/ subdirectories

## Migration from 1.0.0

1. Run `npm install` to install new dependencies (`better-sqlite3`, `commander`, `chalk`, `ora`, `cli-table3`)
2. Run `npm run build` to compile TypeScript
3. Run `ulak init` to create `ulak.config.json` and `.ulak/` runtime directory
4. Existing prompt pack, agents, commands, and skills are fully backward-compatible

The core contract logic is a superset of v1.0.0 — all v1.0.0 artefact chains, intervention modes, and governance rules are preserved.

## Known limitations (deferred to v2.1+)

- `ulak upgrade` command is a stub (no npm/git source checking yet)
- Unit and E2E test coverage is initial (router, learning-extractor, artefact-manager, pack-loader, pack-validator)
- Eval/golden prompt regression suite has no automated test harness
- `.ulak/sessions/` JSON session storage not yet implemented (memory uses SQLite only)
- MCP servers for Jira and Figma are placeholders (require env var configuration)
- Codex/Copilot has no vendor-specific command files (uses AGENTS.md + copilot-instructions.md only)

See `ROADMAP.md` for the full v2.1+ plan.
