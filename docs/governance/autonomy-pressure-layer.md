# Autonomy Pressure Layer

## Why this exists

Claude Code and adjacent AI coding CLIs default to a "check-in-often" loop: ask a question, wait for confirmation, ask the next, wait again. That default is a **friction tax** when the operator has already given an unambiguous "run the full program" intent (e.g., `/director komple`, `/ulak-scaffold <all required inputs given>`). Progress stalls even though no ambiguity remains.

The **autonomy pressure layer** counteracts the default. It prescribes a forward-only posture during clearly-scoped runs: resolve ambiguity to bounded assumptions, record the assumption, and continue — rather than pausing for confirmation.

## When this layer applies

- Phase 0 → Phase 5 director pass (`/director komple`, `/director brownfield`, persona-dispatch variants)
- Greenfield scaffolder (`/ulak-scaffold` with all required inputs provided)
- Automated fixpoints (retry loops, validation-plan probe execution)
- `auto mode` sessions where the operator explicitly delegates iteration

It does **NOT** apply to:

- Destructive operations (history rewrite, force-push, production mutation, secret rotation)
- Actions that move data outside the repo (push to origin, post to external services)
- Scope expansion beyond the declared run (new commands, new phases)

## Rules

1. **Kill repeated menu loops.** If intent is already pinned at Phase 0, do not re-open the router menu before Phase 5.
2. **Prefer forward-only progress.** When ambiguity surfaces mid-run, convert to a bounded assumption (recorded in `reports/current/assumptions.md`), state it inline, and proceed.
3. **Only stop for irreversible or high-risk blockers.** Examples: secret value about to land in a public commit, force-push that rewrites origin, running a migration without a probe result.
4. **Convert ambiguity into bounded assumptions + record them.** Every runtime assumption gets a YAML entry in `assumptions.md` with: statement, default value used, confidence, reversible-at (which phase the operator can override).
5. **Escalate on contradiction, not on missing detail.** Two sources disagreeing (contradiction-status: direct) blocks the finding; a single unknown with a reasonable default does not block the run.
6. **Respect operator override.** The operator can pause any autonomy pressure by stating "wait" or "ask before …"; log the override in `assumptions.md` and honor it for the remainder of the run.

## Integration with other governance

- `docs/governance/trust-model.md` — data-vs-instructions firewall takes precedence; no autonomy pressure overrides that boundary.
- `docs/governance/artefact-write-authorization.md` — `assumptions.md` is an authorized write target during director Phase 0.
- `docs/governance/hook-governance.md` — autonomy pressure never bypasses blocking hooks; hook denials stop the run.
- `docs/runtime/program-phases.md` — Phase 0 captures baseline assumptions; later phases only add new assumptions, never silently mutate earlier ones.
- `docs/runtime/validation-result-schema.md` — `signoff_status: blocked` overrides autonomy pressure; the run halts at Phase 5.

## Anti-patterns

- **"I should re-ask to be safe"** — re-asking without new information is menu-loop; state the assumption + move.
- **"Let me get operator approval before proceeding"** for reversible local edits — autonomy pressure says proceed; operator reviews the diff after.
- **Silently guessing without recording** — guesses without a record in `assumptions.md` poison the manager-verdict; always record, then act.
- **Skipping the `signoff_status: blocked` gate** — autonomy pressure is not a license to ship unvalidated work.

## Canonical footer

Authoritative as of Ulak OS **v1.0.1**. Expanded from v1.0.0 stub (10 lines → this doc) per cartography finding CART-006.
