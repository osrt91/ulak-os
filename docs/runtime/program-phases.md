# Program Phases

## Why phases matter

A phase is a guarantee about state. At the end of Phase 0, the runtime manifest and assumptions exist. At the end of Phase 1, the deep inventory exists. At the end of Phase 2, the evidence register exists and specialists have run in parallel. Without phases, the director can claim "done" while key guarantees are missing. With phases, "done" is checkable.

The director may loop within a phase if evidence is weak, but the user must see forward movement — not repeated restarts from Phase 0.

## Canonical numbering

Ulak OS uses **six named phases** (0–5) plus one conditional interstitial (4.5). Phase 5 is the **terminal phase** — every run ends by writing `manager-verdict.md` inside Phase 5. Optional activities (pack materialization, execution, validation-gate running) that used to live as standalone Phases 5/6/7/8 in earlier drafts are **sub-sections of Phase 5** (§5a, §5b, §5c, §5d). This keeps the phase count stable across profiles and makes the "Phase 5 = final verdict" contract unambiguous.

| Phase | Name | Required? |
|---|---|---|
| 0 | Environment lock | always |
| 1 | Deep inventory | always |
| 2 | Parallel specialist evidence | always |
| 3 | Non-obvious findings (did-you-know) | always |
| 4 | Synthesis | always |
| 4.5 | Live probe | conditional (see §Phase 4.5 below) |
| 5 | Finalize & verdict | always (with §5c + §5d always; §5a + §5b profile-gated) |

## Phase 0 — Environment lock

**Purpose**: Capture the ground truth of the environment so later phases don't drift.

**What the director does**:
- Detect project root (regardless of the current working directory when invoked)
- Record git branch, last commit, uncommitted files
- Record package manager, build tool, runtime versions
- Record env var presence (not values — presence only)
- Run the router (see `docs/runtime/router.md`) and emit the router decision YAML
- Populate the active variable contract (see `docs/runtime/active-variable-contract.md`)

**Artefacts written**:
- `reports/current/runtime-manifest.md`
- `reports/current/assumptions.md`
- `reports/current/active-variables.yaml` (or block inside runtime-manifest.md)

**Phase gate**: runtime-manifest exists and router decision is committed. No later phase runs until this is true.

## Phase 1 — Deep inventory

**Purpose**: Build a full, file-level map of the project. This is cartographer-level work.

**What the director does**:
- Dispatch the cartographer subagent (or run the walk directly if no cartographer is available)
- Walk every directory inside the project root that is not gitignored
- For each surface that exists, list file paths with line ranges where meaningful: routes, pages, components, API endpoints, env schemas, migrations, models, queries, deploy scripts, CI workflows, Dockerfiles, reverse proxy configs, i18n / locale files (each locale, each key), style tokens, design system entry points, dependency graph, dead code candidates, docs, ADRs, runbooks

**Artefacts written**:
- `reports/current/intake.md` — user intent, scope, constraints
- `reports/current/inventory.md` — the deep map

**Phase gate**: inventory.md is non-trivial. A top-level `ls` output is not an inventory. If the file lacks file:line citations for most claims, the phase is rejected and re-run.

## Phase 2 — Parallel specialist evidence

**Purpose**: Get cross-cutting findings in parallel, not sequential, so that security, SEO, i18n, infra, design-system, data, privacy, and release-readiness all contribute at the same time.

**What the director does**:
- Decide which specialists apply to this project (see the office roster in `docs/runtime/office-roster.md`)
- Dispatch all relevant specialists in a **single parallel batch** (one message, multiple subagent calls). Never serialize.
- Each specialist must return claims conforming to `docs/governance/finding-schema.md` with evidence trust tiers.
- If a specialist returns shallow or uncited output, re-dispatch.

**Artefacts written**:
- `reports/current/evidence-register.md` — raw per-specialist bullets
- `reports/current/deep-scan-report.md` — merged narrative, ranked by severity + priority
- `reports/current/research-notes.md` — if live research was required

**Phase gate**: evidence-register.md contains findings from multiple specialists AND every finding has a trust tier. Single-agent evidence is rejected.

## Phase 3 — Non-obvious findings (surprise layer, MANDATORY)

**Purpose**: Surface the things the user did not ask about and likely does not already know. This is the "did the system actually look deep?" gate.

**What the director does**:
- From the merged evidence, extract findings the user likely did NOT ask about
- Target examples: unused imports inflating bundle size, missing keys between locale files, RLS on one table absent on a sibling, cert auto-renew without fallback, N+1 query risk, dead dependencies, hardcoded strings bypassing i18n, admin endpoints without rate limit / CSRF, deploy scripts missing rollback, Dockerfiles copying secrets
- Write to `did-you-know.md` with the same finding schema + a `surprise: true` tag

**Artefacts written**:
- `reports/current/did-you-know.md`

**Phase gate**: did-you-know.md is non-empty AND non-trivial. If it only restates obvious issues already surfaced in Phase 2, the phase is rejected and Phase 2 re-runs with wider scope.

**Optional enhancement — dual-path validation**: for high-stakes runs, Phase 3 can run in dual-path mode (Path A = director, Path B = independent reviewer) with a merge step that promotes overlapping findings to T1 consensus and flags contradictions as probe candidates. See `docs/runtime/dual-path-validation.md`.

## Phase 4 — Synthesis

**Purpose**: Turn evidence into a plan. Merge findings, write the target state, order the roadmap, design the validation plan.

**What the director does**:
- Merge overlapping findings across specialists (see merge rule in `docs/governance/finding-schema.md`)
- Write target-state for each surface
- Write the execution roadmap — quick-wins → foundational → strategic, with tags
- Write the validation plan — how each item will be verified
- Write the pack-gap register — missing commands, skills, agents, hooks, MCP, docs, evals

**Artefacts written**:
- `reports/current/analysis-findings.md`
- `reports/current/target-state.md`
- `reports/current/execution-roadmap.md`
- `reports/current/validation-plan.md`
- `reports/current/pack-gap-register.md`

**Phase gate**: All five artefacts exist. Each non-empty.

## Phase 4.5 — Live probe (conditional-mandatory)

**Purpose**: Convert T2/T3 claims from the static analysis into T1/T0 evidence by running read-only probes against live targets (VPS, production DB, HTTP endpoints, file permissions). Surface new findings that pure static analysis could not see.

**Required when**:
- `validation-plan.md §6` (or equivalent) lists ≥1 live probe
- The manager-verdict would cite any T2 or T3 evidence as blocking
- The execution-roadmap contains destructive actions against a remote target
- Any Critical finding depends on a claim that cannot be verified from the repo alone

**Optional when**:
- All evidence is T1/T2 from the repo itself
- No production deploy exists
- The operator explicitly requested a static-only audit

**What the director does**:
- Collect credentials (SSH config, API tokens, DB connection strings) — if missing, PAUSE and request from operator
- Execute each probe from `validation-plan.md §6` in dependency order
- Probes are **read-only** by default — no write, no destructive operations (per `docs/runtime/live-probe-contract.md`)
- Each probe has a timeout (default 30s)
- Raw probe output is saved to log files, not inlined into artefacts
- T-tier promotions are applied to `evidence-register.md`
- New findings from probing are added to `did-you-know.md` as NF-* entries

**Artefacts written**:
- `reports/current/live-probe-results.md` — one entry per probe with result, T-tier upgrade, log reference
- Updates to `reports/current/evidence-register.md` — trust tier promotions
- Updates to `reports/current/did-you-know.md` — new findings from probing (NF-* section)

**Phase gate**: Phase 5 cannot set `signoff_status: ready` with unresolved probes. `blocked-by-credentials` counts as unresolved. Destructive Sprint items without matching pre-check probes cannot be scheduled.

See `docs/runtime/live-probe-contract.md` for the full protocol and `docs/examples/sample-validation-plan.md` for a worked §6 example.

## Phase 5 — Finalize & verdict (terminal phase)

**Purpose**: Close the run. Optionally materialize the pack. Optionally execute edits. Always run validation gates. Always write the manager verdict.

Phase 5 has four sub-sections. §5a and §5b are profile-gated; §5c and §5d always run.

### §5a — Pack materialization (optional, profile-gated)

**When active**: `output_profile == PACK_GENERATION_PROFILE`, OR the execution mode explicitly allows pack materialization (typical: greenfield builder runs, repackage runs).

**What the director does**:
- Produce `CLAUDE.md`, `.claude/settings.json`, `.claude/commands/*.md`, `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, `.mcp.json`
- Produce starter reports and evals destinations
- Follow `docs/governance/plugin-skill-decision.md` — do not over-materialize; use the smallest reusable unit that fits

**Artefacts written**:
- Pack files at their target paths
- `reports/current/pack-generation-log.md` — what was created

**Sub-section gate**: All pack files are syntactically valid and the smallest tree that satisfies the pack plan. Skip gate cleanly when §5a is not active.

### §5b — Execution (optional, permission-gated)

**When active**: `CAN_EDIT_FILES: true` is set in the active variable contract AND the user has explicitly authorized edits (typical: rescue runs with EXECUTE mode, brownfield repair sprints).

**What the director does**:
- Step through the execution roadmap
- Group roadmap items into **Waves** per `docs/runtime/waves-pattern.md` — parallel within a Wave, serial between Waves
- Build a **file conflict map** before dispatching each Wave — reject the Wave if two agents would own the same file
- Dispatch each Wave as a single parallel Task batch (not serialized within the Wave)
- Run validation gate between Waves (typecheck + lint + build + commit)
- Mark risky items and break them into sub-waves if needed
- Apply edits or code generation
- Stop immediately on any failure and escalate

**Artefacts written**:
- `reports/current/execution-log.md` — what was changed, when, with diffs
- `reports/current/conflict-matrix-wave-N.md` — one per Wave, the pre-dispatch file conflict map

**Sub-section gate**: Each Wave ends with a passing validation run (typecheck + lint + build + commit), or the phase halts. Do not batch cleanup at the end — always between Waves. Skip gate cleanly when §5b is not active.

See `docs/runtime/waves-pattern.md` for the full protocol.

### §5c — Validation gates (always runs)

**Purpose**: Fill the validation result schema with real status for every applicable gate. In analysis-only runs, gates report `not-run` with a residual-risk annotation; in execution runs, gates report `pass` / `fail` with evidence.

**What the director does**:
- Run build, lint, typecheck (if §5b ran; otherwise mark `not-run`)
- Run the test suite at the depth the router chose (`light` | `standard` | `deep`)
- Run security regression, localization checks, Turkish normalization checks, release-readiness checks, broken-link checks — based on the active profile
- Emit the validation result schema from `docs/runtime/validation-result-schema.md`

**Artefacts written**:
- `reports/current/validation-result.yaml` (or embedded block inside `manager-verdict.md`)

**Sub-section gate**: Every applicable gate has a status. `not-run` gates are converted to residual risks recorded in the manager-verdict residual register.

### §5d — Manager verdict (always runs — the closure artefact)

**Purpose**: Produce the single manager-verdict that ends the run.

**What the director does**:
- Write the manager-verdict with:
  - runtime decision and intervention mode
  - active agent map (which specialists ran)
  - phase status — each phase `complete` only if its artefact files exist and are non-trivial
  - top 3 did-you-know highlights inline
  - residual risks (including all §5c `not-run` gates)
  - §5a / §5b status (skipped / completed / failed)
  - explicit next execution lane

**Artefacts written**:
- `reports/current/manager-verdict.md`

**Sub-section gate**: manager-verdict.md exists, references each phase's artefact, carries a `signoff_status` from the validation result, and is non-trivial.

### Phase 5 overall gate

Phase 5 is complete only when §5c and §5d gates pass. §5a and §5b are either completed-clean OR explicitly skipped-clean. `signoff_status: ready` cannot be issued if any §5a / §5b sub-section failed mid-execution.

## Hard rules across all phases

- **Forward movement.** The user should see progress, not menu loops. If the director has to loop within a phase, log it in runtime-manifest.md — don't restart from Phase 0.
- **No phase skipping on shallow evidence.** If a phase's artefact is trivial, the phase is rejected, not accepted-with-caveats.
- **Phases are gates, not suggestions.** The director cannot claim completion with a phase gate unmet.
- **Phase 3 (did-you-know) is not optional.** Absence of did-you-know = director not done.
- **Phase 5 §5c (validate) runs even in analysis-only mode.** In analysis-only mode, the gates are "what would we need to verify this", not "here are the green checks". Either way, the schema is filled.
- **Phase 5 is the terminal phase.** No "Phase 6" / "Phase 7" / "Phase 8" — those activities collapse into §5a / §5b / §5c sub-sections.

## Integration

- `docs/runtime/router.md` — Phase 0 router output
- `docs/runtime/artefact-contract.md` — the mandatory artefact chain
- `docs/runtime/context-budget.md` — context compression between phases
- `docs/runtime/validation-result-schema.md` — §5c output
- `docs/runtime/output-profiles.md` — profile gates which §5 sub-sections activate
- `docs/runtime/waves-pattern.md` — §5b Wave protocol
- `docs/runtime/live-probe-contract.md` — Phase 4.5 protocol
- `docs/examples/sample-validation-plan.md` — worked example with §6 live-probe section
- `.claude/agents/autonomous-program-director.md` — the agent that runs these phases
- `.claude/commands/director.md` — the command that enters the phase chain
