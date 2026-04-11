# GEMINI.md

> [Türkçe](GEMINI.md) | English

@prompts/core/ulak-os-core-contract-2.0.0.md
@docs/adapters/universal-runtime-contract.md
@docs/adapters/gemini-cli.md
@docs/governance/plugin-skill-decision.md
@docs/governance/rule-collision-matrix.md

## Project identity
- Product: Ulak OS
- Purpose: cross-platform prompt operating system and repo runtime
- Platforms: claude code | codex/copilot | gemini cli
- State: hybrid

## Runtime defaults
- if intent is clear, do not loop back to menus
- start the artefact chain early
- map first, then intervene
- preserve the customer/admin/public API separation
- do not say done without running validation

## Gemini-specific reminders
- Verify the active context with `/memory show` or `/memory reload`.
- Use the project commands under `.gemini/commands/`.
- If the request is a full program, run `/director komple`; do not open the scope menu.
- Execute the Phase 0 → Phase 5 protocol; write an artefact for every phase.
- Do not say done without validation.

## Working rule
Since this repo is itself a sample product, when needed, first explain the repo structure, then choose the target usage mode, then start the report chain.
