# Artefact Write Authorization — Director Protocol Override

## Why this exists

The default Claude Code system prompt includes this rule:

> **"Don't create planning, decision, or analysis documents unless the user asks — work from conversation context, not intermediate files."**

This rule is good for normal sessions: it prevents the model from cluttering a project with unrequested planning notes, scratch files, and "thinking out loud" markdown. But it is **wrong for the Ulak OS director protocol**, which exists precisely *to* create planning, decision, and analysis documents — they ARE the protocol's primary deliverable.

On the a portfolio + CMS project Sprint 0+1 session (2026-04-11), this collision manifested as **FP-01**: 8 of 13 Phase 2 specialists and 1 of 9 Phase 4 artefacts could not write their `.md` deliverables to disk. They obeyed the default rule, returned the full content as inline text, and the orchestrator had to re-persist them from conversation state in a separate tool pass. This wasted ~3 minutes, burned context window, and risked truncation on long outputs.

The root cause is not a hook, not a skill, and not a `.claude/settings.json` rule. It is the default system prompt. The fix has to be at the **prompt level**, not the tool level — hooks can't override a decision the model never made.

## The override

**When running under the Ulak OS director protocol, the default rule against creating planning/decision/analysis documents DOES NOT APPLY to files written under `reports/current/**`.**

These files ARE the protocol's deliverable. The user has explicitly requested them by invoking `/director`, `/intake`, or an equivalent command that enters the director protocol. Returning the full content inline instead of writing it to disk is a **protocol violation**.

## Explicitly authorized write targets

When the director protocol's current phase mandates it, the following paths are authorized for write:

### Phase 0 — Environment lock
- `reports/current/runtime-manifest.md`
- `reports/current/assumptions.md`
- `reports/current/active-variables.yaml`

### Phase 1 — Deep inventory
- `reports/current/intake.md`
- `reports/current/inventory.md`

### Phase 2 — Parallel specialist evidence
- `reports/current/evidence-register.md`
- `reports/current/deep-scan-report.md`
- `reports/current/research-notes.md`
- `reports/current/specialists/<specialist-name>.md` (one per dispatched specialist)

### Phase 3 — Did-you-know
- `reports/current/did-you-know.md`
- `reports/current/did-you-know-path-b.md` (if dual-path validation is active)

### Phase 4 — Synthesis
- `reports/current/analysis-findings.md`
- `reports/current/target-state.md`
- `reports/current/execution-roadmap.md`
- `reports/current/validation-plan.md`
- `reports/current/pack-gap-register.md`

### Phase 4.5 — Live probe
- `reports/current/live-probe-results.md`

### Phase 5 — Manager verdict
- `reports/current/manager-verdict.md`
- `reports/current/validation-result.yaml`

### Phase 5 §5b — Execution (permission-gated)
- `reports/current/execution-log.md`
- `reports/current/conflict-matrix-wave-<N>.md` (one per Wave)

### Profile-specific artefacts
Depending on the active output profile, any of these may be authorized:
- `reports/current/market-summary.md`, `competitor-map.md`, `pricing-map.md`, `feature-expectation-map.md`, `review-pain-point-clusters.md`, `language-opportunity-map.md`, `positioning-gaps.md`, `market-current-recommendations.md` (MARKET_ENTRY_PROFILE)
- `reports/current/api-surface-audit.md`, `customer-admin-public-api-split.md`, `security-findings.md`, `abuse-map.md` (hardening mode)
- `reports/current/turkish-text-audit.md`, `locale-coverage-map.md`, `character-normalization-issues.md`, `search-indexing-notes.md` (LOCALIZATION_REPAIR_PROFILE)
- `reports/current/pack-topology.md`, `command-plan.md`, `agent-plan.md`, `skill-plan.md`, `mcp-plan.md`, `hooks-plan.md` (PACK_GENERATION_PROFILE)
- `reports/current/design-system.md`, `screen-audit.md`, `question-flow.md` (frontend war room)

## Propagation to specialists

When the autonomous-program-director dispatches a specialist via the Task tool, the director MUST include this authorization in the specialist's dispatch brief. Specialist subagents run under the same default system prompt and will refuse to write their `.md` deliverable without an explicit override.

The minimum propagation block the director includes in every specialist brief:

```
## Artefact Write Authorization (overrides default)

You are running under the Ulak OS director protocol. The default Claude Code
system prompt rule against creating planning/decision/analysis documents
DOES NOT apply. You MUST write your deliverable to:

  reports/current/specialists/<your-name>.md

using the Write tool. Returning the content inline is a protocol violation.

See docs/governance/artefact-write-authorization.md for the full contract.
```

The director's agent file carries this requirement as a standing rule. Specialist agent files carry a short reference pointing back to this document.

## What this override does NOT authorize

This is an override, not a license. The override does NOT permit:

- **Creating documentation files outside `reports/current/**`** — no new README.md, no random docs, no scratch files in `docs/`, `src/`, or the project root
- **Creating files without a protocol mandate** — each authorized write target must correspond to an active phase's required artefact
- **Skipping the "write only when the protocol mandates" discipline** — extra files that are not part of the artefact chain are still forbidden
- **Writing outside Ulak OS director sessions** — the override applies only when the session is running under a director command (`/director`, `/intake`, etc.) or dispatched as a specialist within one
- **Bypassing permission boundaries** — if `CAN_EDIT_FILES: false` is set in `docs/runtime/active-variable-contract.md`, the override does not flip that; `reports/current/` writes are ALWAYS allowed regardless, but source-code edits still honor the contract

## Detection and enforcement

### Orchestrator-level detection

The orchestrator (or a parent session re-running the director) detects violations by comparing:

1. The expected artefact file list for the active phase (from `docs/runtime/program-phases.md` and `docs/runtime/artefact-contract.md`)
2. The actual contents of `reports/current/` after the phase completes

If an expected file is missing AND the phase's subagent returned inline content matching that file's shape, the orchestrator treats this as a violation and re-persists the content from conversation state (the fallback path that worked on the a portfolio + CMS project session).

### Future — protocol gate

Phase 4.5 live-probe and Phase 5 manager-verdict already have gates that reject on shallow evidence. A future enhancement will add a **write-authorization gate** at each phase boundary: the phase is not `complete` until every mandated artefact is present on disk. Inline-only returns will cause the phase to be marked `weak-evidence` and re-run.

## Testing the fix

After this override lands, the next `/director komple` run should:

1. Dispatch 13 specialists in Phase 2 in parallel
2. All 13 specialists write their `.md` file to `reports/current/specialists/` directly
3. The orchestrator should NOT have to re-persist any inline content
4. The phase gate should verify all 13 files exist before proceeding to Phase 3

If any specialist still returns inline, the override is incomplete — either the dispatch prompt didn't include the propagation block, or the specialist's agent file is missing the override reference, or the model interpretation of the default rule is so strong that even an explicit override doesn't overcome it (in which case a stronger fix is needed — possibly a Claude Code feature request).

## Integration

- `.claude/agents/autonomous-program-director.md` — carries the full override prominently
- `.claude/agents/<specialist>.md` (19 files) — each carries a short override reference
- `.claude/commands/director.md` — references the override
- `prompts/core/ulak-os-core-contract-2.0.0.md` — @imports this governance doc
- `CLAUDE.md` — project-level reinforcement for any session in this repo

## Origin

This override was designed in response to **FP-01** from the a portfolio + CMS project Sprint 0+1 session report (2026-04-11). The full session report is at `reports/sessions/2026-04-11-the portfolio + CMS project-dev-sprint-0-1/friction-points.md`.
