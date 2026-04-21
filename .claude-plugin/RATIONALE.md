# Why Ulak OS — Positioning vs Alternatives

This document is honest about where Ulak OS fits in the Claude Code plugin ecosystem, what it does that others don't, and when you should NOT use it.

## TL;DR

Ulak OS is a **prompt operating system** — a structured execution contract that governs *how* the model works on your project, not just *what* it can call. If you want a few new slash commands, install a command bundle. If you want a skill library, install a skill bundle. If you want the model to route intake → deep inventory → parallel specialist dispatch → non-obvious findings → synthesis → validation → verdict, with artefacts written to disk at every phase, install Ulak OS.

## Unique contributions

Ulak OS ships the following as a coherent whole, not as a grab-bag:

1. **Seven-type pack-unit taxonomy** — commands, skills, agents, hooks, MCP connectors, sector packs, rule packs, runtime rules — each with an explicit governance doc telling you when to create which (`docs/governance/plugin-skill-decision.md`). Most packs treat these types as interchangeable; they're not.
2. **Phase 0→5 director protocol** — environment lock → deep inventory → parallel specialist evidence → did-you-know → synthesis → manager verdict. Each phase has an artefact contract, a gate, and a rejection condition (`docs/runtime/program-phases.md`).
3. **Deep-inventory discipline** — "ls dump" is rejected. Inventory must cite file:line for every claim. This is a hard gate, not a nudge (`prompts/core/ulak-os-core-contract-2.0.0.md §Derinlik zorunluluğu`).
4. **Did-you-know discovery (Phase 3 mandatory)** — every run must surface non-obvious findings the operator didn't ask about. Empty did-you-know → Phase 3 re-run, not a soft warning.
5. **Validation gate (Phase 4.5 + 5)** — destructive roadmap items require live probes before execution. Validation-plan → validation-result.yaml is a structured contract, not free-form (`docs/runtime/validation-result-schema.md`).
6. **Multi-vendor adapter layer** — the core contract is vendor-agnostic; `docs/adapters/claude-code.md`, `docs/adapters/codex-cli.md`, `docs/adapters/gemini-cli.md` translate to each host. You can test the same audit discipline across three models.
7. **79 anti-patterns + 24 sector packs + 8 rule packs** — cross-project pattern library curated from real production projects, with AP-01..AP-19 covering the nastiest modernization traps (god modules, schema drift, multi-layer auth bypass, fake rollback, static HMAC, `.env.local` in monorepo root, etc.).

## Vs alternatives — honest comparison

### `superpowers` (skill bundle)

A collection of well-designed skills for TDD, brainstorming, code review, parallel dispatch. **Excellent at what it does.** Ulak OS is not trying to replace it — the two compose. Ulak OS's `/ulak-intake` command can explicitly dispatch the `superpowers:brainstorming` skill when the operator wants that mode. If you want skills only, use superpowers. If you want skills + commands + agents + the governance chain, use both.

### `everything-claude-code` (command bundle)

A large slash-command library. **Good for breadth.** Ulak OS overlaps on ~9 commands (`/director`, `/ulak-scaffold`, etc.) but goes deeper: each Ulak command invokes a protocol (Phase 0→5), not a one-shot prompt. If you want many one-shot prompts, use command bundles. If you want a governed protocol behind each command, use Ulak OS.

### `cartographer` (single-purpose)

A focused inventory tool. **Does one thing well.** Ulak OS includes a cartographer-style agent (`.claude/agents/cartographer.md`) as Phase 1 of its director protocol, but cartographer-as-a-plugin is a cleaner choice if inventory is all you need. Ulak OS's cartographer is embedded, not standalone.

### Bare Claude Code (no governance)

Default Claude Code gives you a very capable model and a basic tool surface. **Great for one-off work.** When a project exceeds "fix this one file" scope — when you need phased execution, artefact chains, multi-agent dispatch, validation gates — bare Claude Code gives no structure. Ulak OS imposes the structure.

## When NOT to use Ulak OS

Ulak OS is the wrong choice when:

- **You want a single small task done.** "Fix this one bug" doesn't need the director protocol. Open Claude Code, describe the bug, ship the fix.
- **Your project has <500 LOC.** The governance overhead exceeds the value. Come back when the project grows.
- **You want only one skill or one command.** Install the narrow pack, not Ulak OS.
- **You're hostile to structured protocols.** If "Phase 0 environment lock before the model does anything" sounds like bureaucracy to you, Ulak OS will feel like bureaucracy. That's a values mismatch, not a defect in Ulak OS.
- **Your model or host doesn't support parallel agent dispatch.** Phase 2 depends on it. If the host serializes every Task call, the protocol degrades to single-agent and loses most of its value.
- **You need a framework-switch migration (React→Svelte, etc.).** Ulak OS will refuse to recommend big-bang rewrites by default (`docs/runtime/strangler-fig-protocol.md`). If you want the model to just generate the rewrite, use a less opinionated pack.

## When Ulak OS is the right choice

- **Brownfield rescue** — existing project, unclear health, "where do we even start" is the question.
- **Pre-release signoff** — need a structured verdict: ready / conditional / blocked, with evidence.
- **Multi-tenant SaaS hardening** — RLS + tenant isolation + abuse surface + secrets + payment all need audited together, with live probes.
- **Greenfield SaaS start** — `/ulak-scaffold` generates a shippable project with governance embedded from commit 1.
- **Pack-gap auditing** — you've been writing the same prompt manually for three weeks, you suspect it should be a skill, you want the system to tell you.
- **Cross-project pattern discipline** — you work on N projects and want the same anti-pattern catalog applied to each.

## Compatibility with other packs

Ulak OS is designed to compose. Explicitly tested combinations:

- `superpowers:brainstorming` — invoked by `/ulak-intake` when creative exploration is needed
- `claude-md-management` — Ulak OS's CLAUDE.md structure follows the recommended template
- `context7` MCP — Ulak OS's architecture-lead agent uses it for upstream doc currency checks
- `frontend-design:frontend-design` — compatible with Ulak OS's design-system-architect; the latter frames the system, the former executes component generation

Conflicts: if another pack declares a global hook on `user-prompt-submit`, it may collide with Ulak OS's intake routing. `docs/governance/rule-collision-matrix.md` documents the resolution.

## Governance + updates

- **Versioning**: semver across `plugin.json`, `package.json`, `CHANGELOG.md` (`docs/VERSIONING.md`)
- **Release cadence**: roughly every 2-4 weeks in v2.x, slowing as v3.0 stabilizes
- **Breaking changes**: announced in RELEASE_NOTES_*, major version bump required
- **Support**: GitHub issues at `github.com/osrt91/ulak-os/issues`

## Final note

Ulak OS is opinionated on purpose. If the opinions don't match your work, other packs will serve you better. Use the right tool for the shape of the problem you have.
