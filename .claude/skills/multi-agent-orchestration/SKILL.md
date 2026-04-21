---
name: multi-agent-orchestration
description: Orchestrate N specialist agents across a multi-sprint backlog using the merge-sequence protocol (infrastructure → backend → frontend → tests). Produces sprint assignments, dependency graph, file-ownership matrix, merge sequence, daily standup template. Use when planning a Waves-pattern execution involving 4+ agents.
context: fork
agent: autonomous-program-director
allowed-tools: Read Grep Glob Write
---

# Multi-Agent Orchestration

## Goal

Turn a raw backlog + agent roster into an executable multi-sprint plan that respects dependencies, prevents file-ownership conflicts, and enforces the merge order from `docs/runtime/multi-agent-merge-sequence.md`.

## When to use

- Planning Phase 5 §5b execution (Waves pattern) with ≥4 specialist agents dispatched
- Rescuing a stalled sprint where conflicts emerged from parallel edits
- Onboarding a new modernization program — translate `execution-roadmap.md` items into Wave groupings

## Inputs

- `backlog` — JSON or YAML array of tasks. Each task:
 - `id` (e.g., W2.1, NF-03)
 - `title` + `description`
 - `effort_estimate` (session-units or hours)
 - `dependencies` (list of prior task ids)
 - `owner_agent` (specialist that should claim it, e.g., "backend-api-architect")
 - `target_files` (absolute paths the task will write)
- `sprint_length_days` (default 14)
- `num_agents_per_sprint` (default 4, clamped to MAX_PARALLEL_AGENTS = 6)
- `agent_capacity_hours_per_day` (default 6; varies by agent — e.g., backend 8, QA 6)

## Outputs

- `reports/current/sprint-plan.md` — per-sprint task assignments
- `reports/current/dependency-graph.md` — topological view with critical path highlighted
- `reports/current/file-ownership-matrix.md` — which agent owns which file in each Wave
- `reports/current/merge-sequence.md` — depth-ordered merge plan (infra → backend → frontend → tests)
- `reports/current/daily-standup-template.md` — what each agent reports each day

## Process

### Step 1 — Topological sort

Build a dependency DAG from `backlog`. Run a topo sort. Find the critical path (longest chain of dependent tasks). Critical-path tasks must NOT be blocked by resource capacity.

### Step 2 — Wave grouping

Group tasks into Waves where:

- All tasks in a Wave have all dependencies satisfied by prior Waves (or are dependency-free)
- No two tasks in the same Wave touch the same file (file-ownership conflict)
- Total agent-hours per Wave ≤ `num_agents_per_sprint * agent_capacity_hours_per_day * sprint_length_days`

If constraints conflict, split into sub-Waves.

### Step 3 — Conflict map per Wave

For each Wave, build a matrix: rows = agents, columns = files. A cell with ≥2 agents = conflict. Split the Wave.

### Step 4 — Merge-sequence assignment

Tag every task with its merge depth:

- Depth 0: Infrastructure (compose, CI, env, network)
- Depth 1: Backend / domain logic (APIs, services, migrations)
- Depth 2: Frontend / presentation (UI, routing, components)
- Depth 3+: Tests / validation

Within a Wave, merges happen in depth order with a validation gate between depths.

### Step 5 — Per-sprint assignment

Assign Waves to sprints respecting `sprint_length_days`. A Wave too large for one sprint is split. A sprint with leftover capacity picks up the next Wave's early tasks (if dependency-free).

### Step 6 — Daily standup template

For each sprint, emit a per-agent daily template:

```markdown
### <agent>: <sprint-day> standup
- Yesterday: <completed task IDs>
- Today: <in-progress task ID + blockers if any>
- Dependencies: <which prior tasks this needs merged>
- File claims: <which files this agent writes today>
- Conflict risk: <yes/no + with whom>
```

## Rules

- Respect MAX_PARALLEL_AGENTS (6) per Wave; hard cap at 10 (see `docs/runtime/runtime-constants.md`)
- Never allow parallel edits of the same file — split into sub-Waves
- Validation gate between depth merges: typecheck + lint + build + commit
- Rollback plan required per Wave (see `docs/runtime/waves-pattern.md`)
- Synchronization points (sprint boundaries) force a full test run — no drift across sprint

## Integration

- `docs/runtime/multi-agent-merge-sequence.md` — the merge-order protocol this skill executes
- `docs/runtime/waves-pattern.md` — the outer Waves protocol
- `docs/runtime/runtime-constants.md` — MAX_PARALLEL_AGENTS source
- `reports/current/execution-roadmap.md` — the input backlog for this skill
- `reports/current/conflict-matrix-wave-<N>.md` — one per Wave, emitted by the director
