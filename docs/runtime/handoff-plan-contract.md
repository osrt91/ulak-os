# Handoff Plan Contract

## Why this exists

A `/director komple` run produces ~15 artefacts under `reports/current/`. But the session that reads those artefacts **next** — whether a future Claude Code session, a different operator, or a subsequent director run on the same project — has a discovery problem: which file is the entry point? Which artefact says "start here"? What context from the previous session is load-bearing vs. what can be ignored?

Manager-verdict is the **closer** for the current session. Handoff-plan is the **opener** for the next session. They are different artefacts with different audiences.

This pattern was observed in the session (2026-04-11), which produced a `ulak-handoff-plan.md` designed as an explicit entry point for a future director run. The handoff-plan told the next Ulak OS operator:

1. Which files to read for context
2. What state the project is in (mode, critical findings, blockers)
3. Which phases can be skipped (e.g., `skip_phase_1=true` if inventory is fresh)
4. How to dispatch the next workstreams
5. What NEVER to mark `ready` (critical gates that must hold)

## When it's produced

Handoff-plan is **conditional-mandatory** when:

- The current session produces a manager-verdict with `signoff_status: blocked` or `conditional`
- The roadmap contains more work than this session can execute
- The project is live in production and the next session will run on the same state
- Live-probe results changed the T-tier of existing findings (the next session needs to know the updated confidence)
- Multi-sprint execution is planned and only the first N sprints ran this session

Handoff-plan is **optional** when:

- The manager-verdict is `signoff_status: ready` and no follow-up is expected
- The project is short-lived or experimental
- The session was intake-only (no execution, no verdict needed)

## Artefact location

`reports/current/ulak-handoff-plan.md` — lives alongside the other current artefacts. It is the **last file the current session writes** and the **first file the next session reads**.

## Required sections

A conformant handoff-plan contains these sections in order:

### 1. Nasıl kullanılır (How to use)
One-paragraph instruction for the next operator: "Give this file to Ulak OS (Claude Code / Codex / Gemini CLI), then run `/director komple mode=<mode> entry=<this-file>`." Include the exact command.

### 2. Executive summary
What the project is, what state it's in, what the last session accomplished. 1-3 paragraphs. Include branch, last commit SHA, prod URL if live, test pass rates, key architectural facts.

### 3. Context files to read (Phase 0 pre-load)
A table of files the next director MUST read before starting its own Phase 0. Typically:
- `CLAUDE.md` or project-native memory
- `reports/current/runtime-manifest.md`
- `reports/current/assumptions.md`
- `reports/current/inventory.md`
- Key findings files (`evidence-register.md`, `specialists/<critical>.md`)
- Any project-native governance docs the session referenced

### 4. Critical issues — blockers (first sprint scope)
The Critical and High findings that must be addressed next. Include per-finding:
- Finding ID (DIR-001, SEC-B1, etc.)
- File:line evidence
- Blast radius
- Fix summary
- Sprint assignment
- Deadline (if time-sensitive — see `docs/governance/finding-schema.md` time_sensitivity field)

Separate SECURITY BLOCKERS from BUSINESS BLOCKERS if the project has both. Security blockers get their own "HEMEN, 24 SAAT İÇİNDE FIX" or equivalent deadline header.

### 5. HIGH severity issues (second sprint scope)
The next tier of findings, grouped by persona or surface. Typically shorter than section 4.

### 6. Workstream breakdown (sprint logic)
Group the roadmap items into **workstreams** — business-layer groupings that can be executed independently. See `docs/runtime/waves-pattern.md` for the execution-layer grouping (waves within a workstream).

Each workstream has:
- `name` (W1, W2,...)
- `owner` (which specialist agent lane)
- `scope` (which findings this workstream resolves)
- `definition_of_done` (the concrete criteria for the workstream to be marked complete)

### 7. Ulak OS dispatch recommendations
What the next director should do in Phase 2 — which specialists to dispatch in parallel, which phases to skip, which overlays to activate. This is the "operator-friendly" version of the router decision.

### 8. Phase skip recommendations
Explicit per-phase recommendations:
- Phase 1 (deep inventory): `skip` if already present and fresh, `re-run` if stale
- Phase 2 (specialists): which specialists to re-dispatch, which to reuse from the prior run
- Phase 3 (did-you-know): always re-run (low cost, high value)
- Phase 4 (synthesis): re-run to produce a fresh roadmap with the next sprint's scope
- Phase 4.5 (live probe): re-run if more than N hours elapsed since last probe
- Phase 5 (verdict): always produce a fresh verdict

### 9. Estimated effort
Per workstream: days of work for single developer vs. parallel agent dispatch.

### 10. Constraints and assumptions
- Single developer or team?
- Prod state (live / staging only / dev only)
- Test coverage boundary (new work requires new tests?)
- i18n / locale requirements
- Time-sensitive deadlines

### 11. Success metrics
What "done" looks like for the next session. Grep-able assertions preferred:
- "Test customer can checkout → success page"
- "Admin email tab shows real stats + log"
- "Security audit blockers = 0"
- "N findings resolved, rest marked accepted risk or later"

### 12. Next step (explicit command)
The exact bash command the operator should run to continue. E.g.:

```bash
claude
> /director komple mode=RESCUE \
 entry=reports/current/ulak-handoff-plan.md \
 skip_phase_1=true \
 parallel_dispatch=9
```

### 13. Final status
A short "what's the state of this handoff-plan" signoff. When was it last updated, what phases were completed, what session produced it.

## Hard rules

- **Handoff-plan is NOT a replacement for manager-verdict.** Manager-verdict closes the current session; handoff-plan opens the next. Both artefacts exist when both are needed.
- **Handoff-plan does NOT duplicate inventory.** It references the inventory file; it does not copy the content.
- **The operator's "Nasıl kullanılır" instruction must be executable as-is.** Copy-paste into a terminal, run, get the expected behavior. No placeholders.
- **Critical issues with deadlines get explicit deadline headers.** Don't bury a 24-hour fix in a bullet list.
- **Phase skip recommendations must be justified.** "Skip Phase 1" is not enough — say *why* the existing inventory is still valid.
- **The "never ready" gates must be listed explicitly.** If a finding must block signoff until resolved, say so in the handoff-plan so the next director cannot accidentally clear it.

## Integration

- `docs/runtime/program-phases.md` — Phase 5 is updated to emit `ulak-handoff-plan.md` as conditional-mandatory when the verdict is blocked/conditional
- `docs/runtime/artefact-contract.md` — handoff-plan is listed as a Phase 5 optional-mandatory artefact
- `docs/runtime/persona-dispatch-pattern.md` — handoff-plan's workstream breakdown integrates with persona-based execution
- `.claude/commands/director.md` — the `entry=<file>` argument supports handoff-plan as the input to a resumption run
- `docs/governance/finding-schema.md` — `time_sensitivity` field feeds the deadline headers in section 4

## Origin

This pattern was observed in the 2026-04-11 session. The session director realized that the 12-15 standard artefacts were good but hard to navigate for a future session, and wrote `ulak-handoff-plan.md` as an explicit entry point. The next Ulak OS director run would be expected to start by reading the handoff-plan and skipping phases whose input is already fresh.

The session used the command form:

```bash
/director komple mode=RESCUE entry=reports/current/ulak-handoff-plan.md skip_phase_1=true parallel_dispatch=9
```

This surfaced the need for four new director command arguments: `mode=`, `entry=`, `skip_phase_1=`, `parallel_dispatch=N`. See `.claude/commands/director.md` for their specification.
