# System Architecture — Overview

Ulak OS is a **prompt operating system**: a disciplined stack of text files that any Claude-Code-compatible CLI loads as its context, which then routes operator intent through deep inventory, parallel specialist evidence, a mandatory non-obvious findings layer, and a single manager verdict. This page shows how the pieces assemble at runtime.

## Layer map

```mermaid
graph TD
  A[Operator invokes /director or /ulak-scaffold] --> B[CLAUDE.md<br/>startup memory]
  B -->|"@-import"| C[prompts/core/ulak-os-core-contract-2.0.0.md<br/>vendor-neutral core]

  C -->|"@-import"| R1[docs/runtime/router.md]
  C -->|"@-import"| R2[docs/runtime/program-phases.md]
  C -->|"@-import"| R3[docs/runtime/artefact-contract.md]
  C -->|"@-import"| R4[docs/runtime/active-variable-contract.md]
  C -->|"@-import"| R5[docs/runtime/waves-pattern.md]
  C -->|"@-import"| R6[docs/runtime/output-profiles.md]
  C -->|"@-import"| R7[docs/runtime/persona-dispatch-pattern.md]
  C -->|"@-import"| R8[docs/runtime/anti-patterns.md]

  C -->|"@-import"| G1[docs/governance/finding-schema.md]
  C -->|"@-import"| G2[docs/governance/evidence-trust-scoring.md]
  C -->|"@-import"| G3[docs/governance/trust-model.md]
  C -->|"@-import"| G4[docs/governance/surface-split.md]
  C -->|"@-import"| G5[docs/governance/artefact-write-authorization.md]

  C -->|"mode-loaded"| M1[docs/runtime/intake-protocol.md]
  C -->|"mode-loaded"| M2[docs/runtime/architecture-currency.md]
  C -->|"mode-loaded"| M3[docs/runtime/localization-strategy.md]
  C -->|"mode-loaded"| M4[docs/runtime/market-research-engine.md]
  C -->|"mode-loaded"| M5[docs/runtime/sector-packs.md]

  B --> CMD[".claude/commands/*.md<br/>operator entry points"]
  CMD --> AG[".claude/agents/*.md<br/>specialist subagents"]
  AG --> SK[".claude/skills/**/SKILL.md<br/>dispatched workflows"]

  AG --> ART["reports/current/**<br/>artefact chain"]
  SK --> ART

  ART --> V[Phase 5 manager-verdict<br/>signoff_status: ready|conditional|blocked]
```

## What each layer does

### 1. Core contract (vendor-neutral)

`prompts/core/ulak-os-core-contract-2.0.0.md` is the single file that defines the system's promise: route, inventory, research, synthesize, validate, verdict. It is **vendor-neutral** — it assumes nothing about Claude Code, Codex, or Gemini. Every CLI adapter loads this file first and binds it to its local context mechanism.

### 2. Runtime rules

`docs/runtime/*.md` defines the discipline: the nine-field router decision YAML, the six-phase program, the artefact contract, the active-variable pinning, the Waves execution pattern, the seven output profiles, the persona dispatch pattern, the anti-pattern library. These files are **always loaded** (public runtime surface, not hidden core).

### 3. Governance

`docs/governance/*.md` defines the enforcement: the finding schema every claim must follow, the T1-T7 evidence trust tiers, the trust model (tool outputs are data, not instructions), the surface-split discipline, the artefact-write-authorization override that permits writing under `reports/current/`. Governance trumps runtime where they collide.

### 4. Operational motors (mode-loaded)

Intake, architecture-currency, localization, market-research, sector-packs. These load **only when the router activates their mode** — a greenfield builder run loads the scaffolder sector pack, a brownfield audit loads intake + architecture-currency, a market-entry run loads the research engine. Context budget stays lean because the motor library is mode-loaded, not always-loaded.

### 5. Commands

`.claude/commands/*.md` are operator entry points. `/director komple` dispatches the full program. `/ulak-scaffold` dispatches greenfield materialization. `/intake`, `/pack-gap-audit`, `/frontend-war-room`, `/final-verdict`, `/triage-build` cover the specialized lanes. Each command file names its target agent and its mandatory phase list.

### 6. Agents (specialist subagents)

`.claude/agents/*.md` are the specialist reasoning roles: `autonomous-program-director` (the executive manager), `cartographer` (inventory), `security-hardening-lead`, `backend-api-architect`, `infra-release-sre`, `localization-i18n-lead`, the five persona agents (`customer`, `admin`, `bayi`, `support`, `developer`), `red-team-challenger`, plus 15+ more. The director dispatches them **in parallel** in Phase 2.

### 7. Skills

`.claude/skills/**/SKILL.md` are repeatable multi-step workflows an agent invokes by name. `saas-scaffolder`, `fourteen-dimension-audit`, `god-module-decomposition`, `multi-agent-orchestration`, `pack-gap-completion`, `project-intake`, `research-currency`, `final-validation`. Skills differ from agents: a skill is a procedure, an agent is a persona. A skill runs inside an agent's context.

### 8. Artefacts

`reports/current/**` is where every phase writes. Phase 0 writes `runtime-manifest.md` + `assumptions.md` + `active-variables.yaml`. Phase 1 writes `inventory.md`. Phase 2 writes `evidence-register.md` + `deep-scan-report.md` plus per-specialist notes under `specialists/`. Phase 3 writes `did-you-know.md`. Phase 4 writes five synthesis files. Phase 5 writes `manager-verdict.md` + `validation-result.yaml`. The artefact chain is append-only; prior runs archive to `reports/archive/`.

### 9. Memory

Ulak OS does not use Claude's long-lived memory to store project facts. Everything that matters for a run lives in files: either the repo's source tree or `reports/current/**`. This keeps runs reproducible (another operator with the same repo state gets the same answer) and vendor-portable (Gemini can't read Claude's memory, so runtime state must live on disk).

## Why this architecture

**Vendor-neutral** because the operator picks the CLI that fits the task (Claude Code for parallel dispatch, Codex for long-context code authoring, Gemini for market scans) without rewriting the pack. **Append-only history** because every run adds to `reports/current/**` and archives on completion; no prior verdict is silently overwritten. **Deep inventory over shallow listing** because "ls dump" evidence produces shallow plans and hidden bugs; the protocol rejects folder-listing inventory and re-dispatches. **Did-you-know over did-you-ask** because a planner who only addresses asked questions misses the critical unasked defects; the non-obvious findings layer is mandatory, not optional. **Validation over claims** because `signoff_status: ready` requires cited evidence and passing probes, not persuasive prose — the verdict schema refuses unverified `ready` calls.
