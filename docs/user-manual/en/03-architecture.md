# 03 — Architecture

Ulak OS is a **prompt operating system**: a disciplined stack of text files that your AI coding CLI loads as context. This chapter explains how the pieces assemble, why they are organized this way, and what the protocol produces on every run. The architecture targets v1.6 — four vendors, 24 commands, a curated content layer for beginners, and a cross-vendor capability matrix.

## Layer map

At runtime, six layers load in order.

```
CLAUDE.md / AGENTS.md / GEMINI.md                  ← Layer 0: startup memory (per-vendor)
  └── @prompts/core/ulak-os-core-contract-2.0.0.md         ← Layer 1: vendor-neutral core
        ├── @docs/runtime/*.md                     ← Layer 2: runtime rules + rule packs
        ├── @docs/governance/*.md                  ← Layer 3: governance contracts (22 docs)
        ├── @docs/adapters/*.md                    ← Layer 4: vendor adapters (4 vendors)
        └── @docs/runtime/beginner-glossary.md     ← Layer 4a: 47-term glossary (NEW v1.6)

.claude/                                           ← Layer 5: Claude operator surface
  ├── agents/*.md                                  ← 27 specialist + persona agents
  ├── commands/*.md                                ← 24 slash commands
  ├── skills/<name>/SKILL.md                       ← 10 skills
  └── settings.json                                ← permissions + hooks

.gemini/commands/*.toml                            ← Layer 5: Gemini operator surface
AGENTS.md + NL trigger map                         ← Layer 5: Codex + Copilot operator surface

docs/tutorials/                                    ← Layer 6: curated content (NEW v1.6)
  ├── supabase.md, vercel.md, github.md, resend.md     ← 4 tutorials
docs/showcase/                                     ← Layer 6: walkthroughs (3 + video script)
templates/saas-starter/                            ← scaffolder templates
evals/                                             ← golden prompts + assertion library
scripts/                                           ← validators + installer
reports/current/                                   ← artefact output (created per run)
```

Mermaid-native diagrams with more detail live at [`../../architecture/overview.md`](../../architecture/overview.md) and [`../../architecture/director-protocol.md`](../../architecture/director-protocol.md).

## Pack taxonomy (v1.6 census)

The v1.6 pack contains, on disk:

| Layer | Count | Location |
|---|---|---|
| Commands | **24** | `.claude/commands/` |
| Skills | **10** | `.claude/skills/*/SKILL.md` |
| Agents | **27** | `.claude/agents/` |
| Sector overlays | **15** | `docs/runtime/sector-overlays/` |
| Sector packs | **24** | `docs/runtime/sector-packs.md` (SP-NN entries) |
| Rule packs | **8** | `docs/runtime/rule-packs/` |
| Governance docs | **22** | `docs/governance/` |
| ADRs | **7** | `docs/adr/` (ADR-000 through ADR-005, plus vendor-capability-matrix) |
| Runbooks | **4** | `docs/runbooks/` (install, troubleshooting, first-hour, upgrading) |
| Tutorials | **4** | `docs/tutorials/` (Supabase, Vercel, GitHub, Resend) |
| Showcase walkthroughs | **3** | `docs/showcase/` (audit, scaffold, persona) + video script |
| Beginner glossary | **47 terms** | `docs/runtime/beginner-glossary.md` |
| Anti-patterns | ~100 | `docs/runtime/anti-patterns.md` |

## How the @-import chain works

`CLAUDE.md` (or `AGENTS.md` for Codex/Copilot, or the `.gemini/commands/*.toml` bundle for Gemini) is the entry file. Each vendor treats lines that start with `@` followed by a path as **inline-include** directives. The file at that path is read and its contents are spliced into the context at load time. That file can itself contain `@`-imports, and so on. The chain is validated at install time by `scripts/validate-imports.sh`, which detects cycles and reports missing targets.

A minimal consuming `CLAUDE.md` is three lines:

```markdown
# My project

@/absolute/path/to/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
```

That one import pulls the entire core contract, which in turn pulls the 22 governance docs, the runtime rules, the adapter docs, and (for v1.6) the beginner glossary. At session start your CLI sees all of it as a single flat context.

### Cycle detection

`validate-imports.sh` walks every `@`-import from a given root and errors out if `A → B → C → A`. Unbounded context growth is the failure mode the validator prevents.

## Public runtime surface vs hidden core

Ulak OS uses a documented **surface split** (see [`docs/governance/surface-split.md`](../../governance/surface-split.md)). Every file in the pack belongs to one of three layers.

| Layer | Location | Who reads it | Example |
|---|---|---|---|
| **Layer 1 — public runtime surface** | `prompts/core/*`, `docs/runtime/*`, `docs/governance/*`, `docs/adapters/*`, `.claude/**`, `.gemini/**`, `docs/tutorials/*`, `docs/showcase/*` | End users (operator and AI coding CLI) | Router decision YAML, finding schema, director protocol, beginner glossary |
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

Each gate has teeth:
- **Phase 1 gate** rejects "ls of the top-level folders". An inventory must cite `path/to/file.ts:42-91` entries.
- **Phase 2 gate** rejects evidence produced by a single generalist agent. At least two specialists must run in parallel.
- **Phase 3 gate** rejects an empty or trivial `did-you-know.md`.
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

See [`docs/runtime/artefact-contract.md`](../../runtime/artefact-contract.md) for the contract each artefact file must respect.

## Vendor adapter layer

The core contract is vendor-neutral. Each AI coding CLI is bridged by a small **adapter document** that translates the core to the CLI's local mechanisms. v1.6 supports four vendors.

| Vendor | Adapter doc | Entry file | Command shape | Parallel dispatch |
|---|---|---|---|---|
| Claude Code | [`docs/adapters/claude-code.md`](../../adapters/claude-code.md) | `CLAUDE.md` | `.claude/commands/*.md` | yes (native) |
| Codex CLI | [`docs/adapters/codex-cli.md`](../../adapters/codex-cli.md) | `AGENTS.md` | `AGENTS.md` + NL trigger map | serial fallback |
| Copilot CLI | [`docs/adapters/copilot-cli.md`](../../adapters/copilot-cli.md) | `AGENTS.md` | `AGENTS.md` + NL trigger map | serial fallback |
| Gemini CLI | [`docs/adapters/gemini-cli.md`](../../adapters/gemini-cli.md) | `GEMINI.md` | `.gemini/commands/*.toml` | partial |

### The NL trigger map (v1.6)

Codex and Copilot CLIs do not support literal slash commands the way Claude Code does. To keep Ulak OS usable on those vendors, a **natural-language trigger map** lives in `AGENTS.md`. Example entries:

- "start a new saas" → `/ulak-start`
- "audit this project" → `/director komple`
- "what can you do?" → `/ulak-packs`
- "what does rls mean?" → `/ulak-explain rls`
- "hi ulak" / "hello ulak" → `/ulak-hello`

The map is the vendor-parity bridge — operators speak naturally, the adapter routes to the canonical command. Parity is enforced automatically by `scripts/validate-vendor-parity.sh` and by [`docs/governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md).

More on adapters:
- [`docs/adapters/universal-runtime-contract.md`](../../adapters/universal-runtime-contract.md) — platform-independent behavior contract
- [`docs/architecture/vendor-adapters.md`](../../architecture/vendor-adapters.md) — adapter comparison diagram

## Vendor capability matrix

[`docs/governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md) is the enforced single source of truth for which command / skill / agent works on which vendor. A summary:

- **24 / 24 commands** on Claude Code (full).
- Parity targets: Gemini CLI covers audit + scaffold + discovery. Codex and Copilot cover audit + scaffold + discovery via NL trigger map.
- **Documented exemptions** for Claude-native dispatch patterns (for example `/frontend-war-room`) are listed with a rationale in `.claude/vendor-parity-exemptions.txt` and the matrix.

Adding a new command requires a parity entry for every vendor, or a rationale for the exemption. The validator fails otherwise.

## Memory model

Ulak OS does not use Claude's long-lived memory, Codex's memory, Copilot's memory, or Gemini's memory to hold project facts. Everything that matters for a run lives in files: either the repo's source tree or `reports/current/**`.

This has two consequences.

**Reproducibility.** Another operator with the same repo state gets the same answer from the same run.

**Vendor portability.** Swapping from Claude to Gemini (or vice versa) does not silently break the pack, because runtime state is on disk, not in a provider's memory store.

The only "memory" is in `reports/archive/` — a record of prior runs. That is historical evidence, not active state.

## The beginner layer (NEW v1.6)

v1.6 added a dedicated layer for operators without deep technical background.

- **`docs/runtime/beginner-glossary.md`** — 47 terms (RLS, JWT, CORS, webhook, idempotency, etc.) each defined in 5 fields: Simple / Technical / Analogy / In Ulak / Related. This file is the lookup source for `/ulak-explain`.
- **`docs/tutorials/`** — four step-by-step external-service tutorials (Supabase, Vercel, GitHub, Resend) that cover the "account signup + API key retrieval" gap that `/ulak-scaffold` cannot fill.
- **Beginner mode in `/ulak-start`** — the interactive SaaS wizard has a `[b]` beginner mode that replaces jargon with plain language and injects inline explanations.

These three artefacts work together: operator runs wizard → wizard explains terms inline or links to glossary → scaffold runs → `/ulak-next-steps` references the tutorials for account setup → localhost:3000 is running and the operator can log in.

## Why this architecture

Five design principles explain most of the choices.

**Vendor-neutral** because operators pick the CLI that fits the task. Claude Code for parallel dispatch, Codex for long-context authoring, Gemini for market scans — all without rewriting the pack.

**Append-only artefact history** because every run adds to `reports/current/**` and archives on completion. No prior verdict is silently overwritten.

**Deep inventory over shallow listing** because "ls of top-level" evidence produces shallow plans and hides real bugs.

**Did-you-know over did-you-ask** because a planner who only addresses asked questions misses the critical unasked defects.

**Discoverability without plugin hunting** (v1.6) because the moment operators need to know "which plugin solves my problem?", the value of an OS-like pack collapses. `/ulak-ask`, `/ulak-packs`, `/ulak-search`, `/ulak-demo`, `/ulak-explain` keep all capability surface reachable from inside the CLI.

## Mini glossary

- **Artefact** — a markdown or YAML file a phase writes under `reports/current/*`
- **Gate** — a condition a phase must meet to be considered complete
- **Dispatch** — the act of running an agent or skill (usually part of a parallel batch)
- **Trust tier** — the evidence level behind a claim (T1 = direct verified, T7 = speculation)
- **Override block** — a disclaimer on an artefact that suspends a default Claude Code rule
- **Probe** — a command that verifies a claim against the live system (grep, curl, DB query)
- **NL trigger map** — the natural-language-to-command mapping used by Codex and Copilot adapters

Full glossary (47 terms, beginner-friendly): [`docs/runtime/beginner-glossary.md`](../../runtime/beginner-glossary.md).

## Related references

- [`../../architecture/overview.md`](../../architecture/overview.md) — mermaid diagram of the layer map
- [`../../architecture/director-protocol.md`](../../architecture/director-protocol.md) — Phase 0 → 5 flow with rejection criteria
- [`../../architecture/scaffolder-flow.md`](../../architecture/scaffolder-flow.md) — `/ulak-scaffold` internal flow
- [`../../architecture/vendor-adapters.md`](../../architecture/vendor-adapters.md) — 4-vendor adapter comparison
- [`../../runtime/artefact-contract.md`](../../runtime/artefact-contract.md) — per-artefact file contract
- [`../../runtime/router.md`](../../runtime/router.md) — the 9-field router decision YAML
- [`../../governance/surface-split.md`](../../governance/surface-split.md) — Layer 1 / 2 / 3 definitions
- [`../../governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md) — 4-vendor capability matrix (NEW v1.6)

---

Next: [04 — Commands](./04-commands.md)
