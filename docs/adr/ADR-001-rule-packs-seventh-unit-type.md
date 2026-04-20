# ADR-001 — Rule Packs as the 7th Unit Type

**Status**: Accepted · **Date**: 2026-04-18 · **Release**: v2.1.3

## Context

Prior to v2.1.3, Ulak OS's `docs/governance/plugin-skill-decision.md` named six reusable unit types: command, agent, skill, hook, MCP, plugin. A cross-project pattern extraction pass discovered that every production project carries an `.claude/rules/<stack>.md` pattern — a ≤500-byte, always-on imperative list (no console.log in prod, no `any` types, non-root Docker user, etc.). These rules didn't fit any of the 6 unit types cleanly.

Hooks fire on events; rules need to load into context at session start. Skills are multi-step workflows; rules are single-line imperatives. Commands are operator-triggered; rules are ambient. Agents do reasoning; rules are declarative. MCP is a network bridge; rules are in-repo.

## Decision

Introduce **rule-pack** as the 7th unit type:

- **Canonical location**: `docs/runtime/rule-packs/<stack>.md` (shipped by Ulak OS) + `.claude/rules/<stack>.md` (project-local overrides)
- **Shape**: ≤500-byte imperative list + one "activation line" + one "collision rule" paragraph
- **Load mechanism**: Phase 0 toolchain-precheck detects stacks; matching packs auto-load into `active-variables.yaml` under `rule_packs_loaded`
- **Precedence**: project-local overrides merge selectively with Ulak-shipped packs (unmatched rules inherit)
- **Governance doc**: `docs/governance/rule-pack-governance.md` defines authoring discipline

## Alternatives considered

1. **Treat rules as a subset of skills** — rejected because skills are workflows (multi-step), not imperatives (single-line)
2. **Treat rules as always-on hooks** — rejected because hooks are event-driven; rules are ambient context
3. **Embed rules in the core contract** — rejected because each project needs different rule sets based on stack; core kernel must stay sector-agnostic
4. **Treat rules as an MCP-provided resource** — rejected because network boundary is overkill for ≤500-byte static text
5. **Do nothing; keep rules in agent prompts** — rejected because rules would get duplicated across agents, drift, and lose the "always-on" property

## Consequences

**Positive**:
- Clean separation between doctrine (docs/runtime/*), workflow (skills), gating (hooks), reasoning (agents), and imperative guardrails (rule packs)
- Project-local overrides enable operator customization without editing Ulak OS core
- Stack detection drives automatic activation — rules land at the right moment

**Negative**:
- Adds a 7th concept to the decision matrix; operators must choose the right unit type per need (mitigated by `plugin-skill-decision.md` "picking between units" section)
- Load order matters: rules load after anti-patterns.md but before output-profiles.md in Phase 0

**Migration**: None required — rule packs are additive; existing code continues to work.

## References

- `docs/governance/plugin-skill-decision.md` — decision matrix
- `docs/governance/rule-pack-governance.md` — authoring discipline
- `docs/runtime/rule-packs/` — 8 shipped packs (typescript-nextjs, python-fastapi, docker-compose, api-security, turkish-locale, localization-ssot, llm-streaming-context-aware, react-native-expo)
- `CHANGELOG.md §[2.1.3]` — release notes
