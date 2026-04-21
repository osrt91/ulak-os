---
name: ulak-subagent-dispatch
description: Dispatch N independent subagents in parallel for a bounded scope. Enforces the superpowers:dispatching-parallel-agents + subagent-driven-development discipline: identify truly-independent work, hand each subagent a self-contained brief, collect + reconcile outputs, commit the merged result. Use for large content-generation tasks (N-file template creation, N-agent expansion, cross-service refactor) where serial work would waste hours.
agent: autonomous-program-director
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# /ulak-subagent-dispatch — parallel subagent coordination

## When to use

- **2+ independent tasks** without shared state / sequential dependencies
- Large scope where serial execution would exceed 1-2 session budgets
- Identical pattern applied to many paths (template-per-path, agent-per-domain, etc.)
- Cross-service refactor where each service's change is isolated

## When NOT to use

- Single file change (just do it)
- Tightly-coupled work (changes across 3 files that must land as one diff)
- When subagents would duplicate each other's context (use a single agent instead)

## Dispatch protocol

1. **Scope the work** — enumerate all discrete units of output
2. **Partition into batches** — each batch is 3-5 units, 1 subagent per batch
3. **Check boundaries** — no two batches touch the same file
4. **Write briefs** — each brief is self-contained (subagent has no prior-conversation context)
5. **Dispatch in a single message** — all Agent tool calls in parallel
6. **Wait for completion notifications** — do not poll
7. **Merge + validate** — run validators, scan for conflicts, check redaction
8. **Commit as coherent series** — one commit per logical group, not one-commit-per-file

## Brief template (what each subagent gets)

```markdown
## Stack + context
<1-2 paragraphs about the project enough for a cold start>

## Your deliverables
<file paths + 1-line purpose each>

## Your boundaries
- You own: <paths>
- Sibling agents own: <paths> — do NOT touch
- Read for reference: <paths>

## Templating rules
<placeholders, conditionals, substitution conventions>

## Discipline
<redaction / licensing / AP callouts / verification commands>

## Return
Terse report (<400 words): file list + design decisions + verification confirmation.
Do NOT commit — orchestrator commits.
```

## Post-dispatch orchestrator discipline

After all subagents complete:

1. **Redaction sweep** — grep the new paths for banned identifiers (portfolio names, secret prefixes)
2. **Validator pass** — `bash scripts/validate-imports.sh` + `validate-schemas.sh` + `validate-vendor-parity.sh`
3. **Merge review** — check for cross-agent assumption drift (e.g., agent A assumes function X exists; agent B assumes X is named differently)
4. **Commit series** — logical grouping + descriptive messages
5. **Tag if Phase boundary** — semver bump + annotated tag

## Example

```
/ulak-subagent-dispatch scope="17 sector overlays, 5-6 files per sector" batches=4
```

Dispatches 4 subagents in parallel; each handles 4-5 sectors; orchestrator merges + commits as `feat(sectors): v2.2 — 17 sector overlay kits`.

## Related

- `superpowers:dispatching-parallel-agents` — the underlying skill
- `superpowers:subagent-driven-development` — skill for the entire cycle
- `docs/runtime/multi-agent-merge-sequence.md` — governance for merge order when dependencies exist
