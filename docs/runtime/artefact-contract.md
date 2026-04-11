# Artefact Contract

## Why artefacts matter

The system produces structured markdown artefacts under `reports/current/` as evidence that a run happened, what was found, and what was decided. Without artefacts, every run is ephemeral and findings get lost between sessions. Artefacts are also the seam between the director, specialists, and the user — they turn prompt output into something you can grep, diff, and cite.

## Depth requirement — the hard floor

An artefact is not a folder listing. An artefact is not a three-bullet summary. Every mandatory artefact must carry:

- file-path + line-range citations for every claim it makes
- evidence trust tier (T1-T7) for every piece of supporting data
- fields conforming to `docs/governance/finding-schema.md` where findings are involved

If an artefact is shallow ("the project uses Next.js, has a few components, looks fine"), it is rejected and must be re-run. See `docs/runtime/program-phases.md` for the phase-level depth requirement and `.claude/agents/autonomous-program-director.md` for the enforcement hook.

## Mandatory artefact chain

These are written in phase order. Phases map to `docs/runtime/program-phases.md`.

### Phase 0 — Environment lock
- `runtime-manifest.md` — router decision, active variables, active overlays, branch/commit state
- `assumptions.md` — everything the director is proceeding with absent confirmation

### Phase 1 — Deep inventory
- `intake.md` — user intent, scope, constraints, the user's literal request
- `inventory.md` — deep repo map (not `ls` output): routes, pages, endpoints, components, configs, migrations, dead code, dependencies, env vars, i18n keys, design tokens, deploy scripts, CI workflows — each with file paths and line ranges where meaningful

### Phase 2 — Parallel specialist evidence
- `evidence-register.md` — raw per-specialist bullets (each conforming to finding-schema.md with trust tier)
- `deep-scan-report.md` — merged narrative, findings ranked by severity + priority
- `research-notes.md` — any live research results (T1 or T5 sources, explicitly labeled)

### Phase 3 — Surprise layer (MANDATORY)
- `did-you-know.md` — non-obvious findings the user likely did not ask about and likely does not know. See autonomous-program-director.md Phase 3 for what qualifies. If this file is empty or only restates obvious issues, the director is not finished.

### Phase 4 — Synthesis
- `analysis-findings.md` — merged findings with final IDs (finding-schema.md format)
- `target-state.md` — desired future state per surface
- `execution-roadmap.md` — ordered action list (quick-wins → foundational → strategic), tagged per roadmap rule
- `validation-plan.md` — how each item will be verified
- `pack-gap-register.md` — missing commands / skills / agents / hooks / MCP / docs / evals

### Phase 5 — Final verdict
- `manager-verdict.md` — runtime decision, active agent map, phase status, profile conformance, top 3 did-you-know highlights, residual risks, next execution lane
- `validation-result.yaml` (or inline block in manager-verdict.md) — the schema from `docs/runtime/validation-result-schema.md`

## Optional profile-specific artefacts

The output profile may require additional artefacts. See `docs/runtime/output-profiles.md`.

Common extras:

### Research artefacts (market entry, architecture currency)
- `market-summary.md`
- `competitor-map.md`
- `pricing-map.md`
- `language-opportunity-map.md`
- `architecture-currency-notes.md`

### Security artefacts (hardening mode)
- `api-surface-audit.md`
- `customer-admin-public-api-split.md`
- `security-findings.md`
- `abuse-map.md`

### Localization artefacts (LOCALIZATION_REPAIR_PROFILE)
- `turkish-text-audit.md`
- `locale-coverage-map.md`
- `search-indexing-notes.md`

### Pack artefacts (REPACKAGE / PACK_GENERATION_PROFILE)
- `pack-topology.md`
- `command-plan.md`
- `agent-plan.md`
- `skill-plan.md`
- `mcp-plan.md`
- `hooks-plan.md`

### Design artefacts (redesign / frontend-war-room)
- `design-system.md`
- `screen-audit.md`
- `question-flow.md`

## Rules

- **Create artefacts immediately when intent is clear.** Do not wait for a second round of scope confirmation unless there is a real blocker.
- **An empty artefact is not an artefact.** A file with a title and zero content counts as "not run".
- **Every artefact is regeneratable.** If the user asks "where did you get this?", the artefact must be able to answer — which means citations, trust tiers, and timestamps.
- **No artefact without evidence.** If the supporting evidence is T6 or T7, the artefact says so explicitly. No hidden hypotheses.
- **Do not duplicate content across three files.** Write the content once, link from the others.
- **Reports go under `reports/current/`.** Archived reports go under `reports/archive/<date>/`. Do not write audit output to the project root.

## Integration

- `docs/runtime/program-phases.md` — phases that produce each artefact
- `docs/governance/finding-schema.md` — YAML format for finding entries
- `docs/governance/evidence-trust-scoring.md` — trust tiers for evidence
- `docs/runtime/output-profiles.md` — which profiles require which optional artefacts
- `.claude/commands/director.md` — the command that enforces this chain
