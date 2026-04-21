# 03 — Architecture

Ulak OS is a **prompt operating system**: a disciplined stack of text files that your AI coding CLI loads as context. This chapter explains how the pieces assemble, why they are organized this way, and what the protocol produces on every run.

## Layer map

At runtime, five layers load in order.

```
CLAUDE.md                                      ← Layer 0: startup memory (3 lines)
  └── @prompts/core/ulak-os-core-contract-2.0.0.md   ← Layer 1: vendor-neutral core
        ├── @docs/runtime/*.md                 ← Layer 2: runtime rules + rule packs
        ├── @docs/governance/*.md              ← Layer 3: governance contracts
        └── @docs/adapters/*.md                ← Layer 4: vendor adapter

.claude/                                       ← Layer 5: operator surface
  ├── agents/*.md                              ← 27 specialist + persona agents
  ├── commands/*.md                            ← 9 slash commands
  ├── skills/<name>/SKILL.md                   ← 8 skills
  └── settings.json                            ← permissions + hooks

templates/saas-starter/                        ← scaffolder templates
evals/                                         ← golden prompts + assertion library
scripts/                                       ← validators + installer
reports/current/                               ← artefact output (created per run)
```

Mermaid-native diagrams with more detail live at [`../../architecture/overview.md`](../../architecture/overview.md) and [`../../architecture/director-protocol.md`](../../architecture/director-protocol.md).

## How the @-import chain works

`CLAUDE.md` is the entry file. Claude Code (and equivalents in Codex / Gemini adapters) treat lines that start with `@` followed by a path as **inline-include** directives. The file at that path is read and its contents are spliced into the context at load time. That file can itself contain `@`-imports, and so on. The chain is validated at install time by `scripts/validate-imports.sh`, which detects cycles and reports missing targets.

A minimal consuming `CLAUDE.md` is three lines:

```markdown
# My project

@/absolute/path/to/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
```

That one import pulls the entire core contract, which in turn pulls the runtime rules, governance docs, and adapter docs. At session start your CLI sees all of it as a single flat context.

### Cycle detection

`validate-imports.sh` walks every `@`-import from a given root and errors out if `A → B → C → A`. Unbounded context growth is the failure mode the validator prevents. See [chapter 08](./08-troubleshooting.md) § `validate-imports.sh` reports cycle for how to break a cycle.

## Public runtime surface vs hidden core

Ulak OS uses a documented **surface split** (see [`docs/governance/surface-split.md`](../../governance/surface-split.md)). Every file in the pack belongs to one of three layers.

| Layer | Location | Who reads it | Example |
|---|---|---|---|
| **Layer 1 — public runtime surface** | `prompts/core/*`, `docs/runtime/*`, `docs/governance/*`, `docs/adapters/*`, `.claude/**` | End users (both operator and AI coding CLI) | The router decision YAML, the finding schema, the director protocol |
| **Layer 2 — hidden core** | `docs/archive/`, historical internal version notes | Maintainers during governance decisions | Version-diff notes, archived internal releases |
| **Layer 3 — maintainer surface** | Internal templates, prompt supply-chain audits | The project owner | Not loaded into user sessions |

The core contract explicitly says: "Historical/version-diff notes do not enter the public runtime surface; they belong to hidden core." This keeps your session context focused on what the AI coding CLI needs to act, not on the project's internal history.

## The Phase 0 → 5 director protocol

The centerpiece of Ulak OS is the `/director` command, which dispatches the `autonomous-program-director` subagent. That agent runs a strict six-phase program. Every phase writes a mandated artefact under `reports/current/`. Every phase has a gate that rejects shallow or single-source output.

```
Phase 0 — Environment lock         →  runtime-manifest.md, assumptions.md, active-variables.yaml
Phase 1 — Deep inventory           →  inventory.md (file:line citations)
Phase 2 — Parallel specialist      →  evidence-register.md, deep-scan-report.md, specialists/*.md
           evidence
Phase 3 — Did-you-know             →  did-you-know.md (non-obvious findings, mandatory)
Phase 4 — Synthesis                →  analysis-findings.md, target-state.md,
                                      execution-roadmap.md, validation-plan.md,
                                      pack-gap-register.md
Phase 4.5 — Live probes            →  live-probe-results.md  (conditional)
           (conditional-mandatory)
Phase 5 — Manager verdict          →  manager-verdict.md, validation-result.yaml
```

Each gate has teeth. Examples:

- **Phase 1 gate** rejects "ls of the top-level folders". An inventory must cite `path/to/file.ts:42-91` entries, not folder summaries.
- **Phase 2 gate** rejects evidence produced by a single generalist agent. At least two specialists must run in parallel, each producing its own section in `evidence-register.md`.
- **Phase 3 gate** rejects an empty or trivial `did-you-know.md`. The non-obvious findings layer is mandatory, not optional.
- **Phase 5 gate** rejects `signoff_status: ready` when the validation plan has unresolved Critical findings.

Full phase-by-phase flow with gate rejection criteria: [`docs/architecture/director-protocol.md`](../../architecture/director-protocol.md).

## Fifteen artefact types

The full artefact chain across Phase 0 through Phase 5 produces 15 canonical files.

| # | Phase | Artefact | Content summary |
|---|---|---|---|
| 1 | 0 | `runtime-manifest.md` | Git state, runtime versions, detected stacks, rule packs loaded |
| 2 | 0 | `assumptions.md` | What the run treats as given and why |
| 3 | 0 | `active-variables.yaml` | The 9-field router decision pinned for the whole run |
| 4 | 1 | `inventory.md` | Every surface, route, config, env var, migration, CI workflow, Dockerfile — with file:line citations |
| 5 | 2 | `evidence-register.md` | Raw per-specialist bullets keyed by specialist ID |
| 6 | 2 | `deep-scan-report.md` | Merged narrative ranked by severity |
| 7 | 2 | `specialists/<role>.md` | Per-specialist deliverable with finding-schema YAML |
| 8 | 3 | `did-you-know.md` | Non-obvious findings the operator did not ask about |
| 9 | 4 | `analysis-findings.md` | Evidence → findings, severity-classified |
| 10 | 4 | `target-state.md` | Desired future state per surface, anti-pattern, rule pack |
| 11 | 4 | `execution-roadmap.md` | Ordered action list with `depends_on` groups for the Waves pattern |
| 12 | 4 | `validation-plan.md` | Per-item verification method; §6 lists live probes when needed |
| 13 | 4 | `pack-gap-register.md` | Missing commands / skills / agents / hooks / MCP / docs |
| 14 | 4.5 | `live-probe-results.md` | Probe id, target, command, result, T-tier upgrade |
| 15 | 5 | `manager-verdict.md` + `validation-result.yaml` | Structured signoff per `validation-result-schema.md` |

See [`docs/runtime/artefact-contract.md`](../../runtime/artefact-contract.md) for the contract that each artefact file must respect.

## Vendor adapter layer

The core contract is vendor-neutral. Each AI coding CLI is bridged by a small **adapter document** that translates the core to the CLI's local mechanisms.

| Vendor | Adapter doc | Entry file | Command shape |
|---|---|---|---|
| Claude Code | [`docs/adapters/claude-code.md`](../../adapters/claude-code.md) | `CLAUDE.md` | `.claude/commands/*.md` |
| Codex / Copilot | — | `AGENTS.md` | Plain-text `AGENTS.md` block |
| Gemini CLI | [`docs/adapters/gemini-cli.md`](../../adapters/gemini-cli.md) | `GEMINI.md` | `.gemini/commands/*.toml` |

Parity is checked automatically by `scripts/validate-vendor-parity.sh`. When a command is Claude-native (for example `/frontend-war-room`, which depends on Claude's specific parallel subagent dispatch semantics), it is listed in `.claude/vendor-parity-exemptions.txt` with a rationale. Exemptions require review during PR — the list stays short by design.

More on adapters:
- [`docs/adapters/universal-runtime-contract.md`](../../adapters/universal-runtime-contract.md) — the platform-independent behavior contract
- [`docs/architecture/vendor-adapters.md`](../../architecture/vendor-adapters.md) — adapter comparison diagram

## Memory model

Ulak OS does not use Claude's long-lived memory, Codex's memory, or any other proprietary memory store to hold project facts. Everything that matters for a run lives in files: either the repo's source tree or `reports/current/**`.

This has two consequences.

**Reproducibility.** Another operator with the same repo state gets the same answer from the same run. A memory-backed system is not reproducible — two operators with the same repo state but different memory histories see different outputs.

**Vendor portability.** Gemini cannot read Claude's memory. If runtime state lived in a provider's memory store, swapping vendors would silently break the pack. Runtime state on disk means the pack is portable.

The only "memory" is in `reports/archive/` — a record of prior runs. That is treated as historical evidence, not active state.

## Why this architecture

Three design principles explain most of the choices.

**Vendor-neutral** because operators pick the CLI that fits the task. Claude Code for parallel dispatch, Codex for long-context authoring, Gemini for market scans — all without rewriting the pack. The core contract is plain markdown.

**Append-only artefact history** because every run adds to `reports/current/**` and archives on completion. No prior verdict is silently overwritten. Audits are reproducible and reviewable after the fact.

**Deep inventory over shallow listing** because "ls of top-level" evidence produces shallow plans and hides real bugs. The protocol rejects folder-listing inventory and re-dispatches with an explicit "cite file paths and line ranges" instruction.

**Did-you-know over did-you-ask** because a planner who only addresses asked questions misses the critical unasked defects. The non-obvious findings layer is mandatory.

**Validation over claims** because `signoff_status: ready` requires cited evidence and passing probes, not persuasive prose. The verdict schema refuses unverified "ready" calls.

## Related references

- [`../../architecture/overview.md`](../../architecture/overview.md) — mermaid diagram of the layer map
- [`../../architecture/director-protocol.md`](../../architecture/director-protocol.md) — Phase 0 → 5 flow with rejection criteria
- [`../../architecture/scaffolder-flow.md`](../../architecture/scaffolder-flow.md) — `/ulak-scaffold` internal flow
- [`../../architecture/vendor-adapters.md`](../../architecture/vendor-adapters.md) — claude vs codex vs gemini adapter comparison
- [`../../runtime/artefact-contract.md`](../../runtime/artefact-contract.md) — per-artefact file contract
- [`../../runtime/router.md`](../../runtime/router.md) — the 9-field router decision YAML
- [`../../governance/surface-split.md`](../../governance/surface-split.md) — Layer 1 / 2 / 3 definitions

---

Next: [04 — Commands](./04-commands.md)
