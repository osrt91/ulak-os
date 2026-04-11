# Context Budget Manager

## Why this exists

Context is finite. When the system loads every rule, every overlay, every sector pack, and every historical note into every turn, the active reasoning space collapses. Decisions become blurry, the wrong rule fires, and the artefact chain degrades into vague summaries.

The context budget manager says: **load only what the current phase needs, and compress or evict everything else.**

## Context layers

Context is organized in layers. Each layer has different lifecycle rules.

| Layer | What goes here | Lifecycle |
|---|---|---|
| **1. Core runtime rules** | Instruction hierarchy, trust model, non-negotiable rules, router contract, artefact contract | Always loaded. Never evicted. |
| **2. Active task mode** | The selected intervention mode, project state, output profile, scope level | Loaded at Phase 0. Stays pinned through verdict. |
| **3. Project memory** | CLAUDE.md + imports, stable project facts, stack, build/test commands | Loaded at session start. Trimmed, not evicted. |
| **4. Evidence summary** | Phase 2 specialist outputs, compressed to decision-relevant facts | Replaces raw evidence after Phase 3 synthesis. |
| **5. Working assumptions** | What the system is proceeding with absent confirmation | Pinned through verdict; recorded in assumptions.md. |
| **6. Optional overlays** | Design system, Turkish normalization motor, localization strategy, market research engine | Mode-loaded. Evicted if not active. |
| **7. Sector packs** | education / saas / fintech / ecommerce / marketplace / enterprise / media / ai-copilot overlays | Only loaded when router explicitly activates. |

## Always loaded (floor)

Regardless of task, these never leave context:

- instruction hierarchy
- trust model
- router contract
- output profile rules
- context budget rules (this document)
- evidence trust scoring
- final validation principles
- artefact contract

## Mode-loaded

Only load when the router activates the mode:

- localization strategy motor — only for LOCALIZATION_REPAIR or i18n work
- market research engine — only when live research is required
- mobile / Flutter / iOS redesign overlay — only for REDESIGN or frontend-war-room
- open API hardening — only for HARDENING or security work
- release readiness gates — only for RELEASE_READINESS mode
- pack generation — only for REPACKAGE mode or explicit pack output
- Turkish normalization motor — only when text work is in scope

## Eviction rules

The following are evicted from active context when no longer decision-relevant:

- Old conversation detail not referenced by any active artefact
- Historical version-diff notes (V6 → V7 → V9 lineage) unless the current task is governance
- Sector overlays that did not activate
- Repetitive checklists already satisfied
- Low-trust (T6, T7) evidence once a T2 or T3 alternative exists for the same claim

## Pin rules

The following are pinned and never evicted mid-run:

- The user's primary goal
- Critical security risks already surfaced
- Confirmed stack facts (language, runtime, framework, database)
- User-imposed constraints (timeline, compliance, scope boundaries)
- High-trust (T1, T2) evidence supporting an active finding
- Surfaces that must not break (explicitly listed)

## Compression behavior

When evidence piles up, compress in stages:

1. **Raw evidence** — file contents, log lines, full query results
2. **Evidence summary** — bullet points with file:line citations
3. **Decision-relevant facts** — only what a finding or the verdict references
4. **Unresolved conflicts** — where two trust-tiered sources disagree, surfaced to the verdict

Move from raw → summary → facts as phases advance. By Phase 5 (manager-verdict), only decision-relevant facts and unresolved conflicts should still be in context.

## Hard rules

- **Never load all sector packs at once.** The router picks.
- **Never keep Phase 1 raw file listings in context after Phase 3.** Summarize and evict.
- **Never keep T6/T7 evidence as decision-weight after a T2/T3 source is found.** Demote or drop.
- **Never grow context beyond the working budget without recording *why* in the runtime-manifest.** Every expansion is a decision that leaves a trace.
- **The core runtime rules floor is non-negotiable.** If you evict them, you stop being Ulak OS.

## Integration with the director

The autonomous-program-director must:

- Record the active overlays and sector packs in `reports/current/runtime-manifest.md`
- Mark phase boundaries explicitly so compression can run between phases
- Emit a warning in the manager-verdict if context grew past the working budget during the run
