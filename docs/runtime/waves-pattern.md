# Waves Pattern — Parallel Within, Serial Between

## Why this exists

The `/director komple` protocol's Phase 2 dispatches specialists in parallel. But *execution* (Sprint 0 → Sprint N) has a different shape: some items depend on others, some items touch the same files, and pure-parallel would create file conflicts while pure-serial wastes wall-clock.

The Waves pattern is the formal answer: **parallel within a Wave, serial between Waves**. It was improvised during the oguzhansert.dev Sprint 0+1 session (2026-04-11, FP-02) and is now documented as a first-class runtime contract.

## When to use

- Sprint execution with ≥3 independent items
- Items have a dependency DAG (some depend on others)
- Pure parallel would cause file conflicts
- Pure serial wastes wall-clock time
- Multi-wave execution after a `/director komple` run

**Do not use** the Waves pattern for:
- A single-item fix (just do it)
- Phase 2 of the director protocol (that's specialist dispatch — different mechanism, see `docs/runtime/program-phases.md`)
- A pure sequence where every item depends on the previous (a Wave of one is just a serial task)

## The pattern

### Step 1 — Group items into Waves based on dependency edges

```
Wave 1: items with no deps (can all run in parallel)
Wave 2: items that depend only on Wave 1 items
Wave 3: items that depend on Wave 1 or 2 items
...
Wave N: terminal items (cleanup, verification)
```

Each item's `depends_on` list (per `docs/runtime/roadmap-rule.md` step shape) determines which Wave it belongs to. Topologically sort the roadmap, then group by "distance from the start".

### Step 2 — Build a pre-dispatch conflict map

**Before** calling Task on the Wave, build a conflict matrix:

```
| Agent | Owns files (write) | Reads files (read-only) | Must-not-touch |
|---|---|---|---|
| G1    | src/middleware.ts, src/lib/auth.ts | src/lib/supabase-* | none |
| G2    | src/lib/supabase-admin.ts | src/lib/auth.ts | src/middleware.ts |
| G3    | next.config.mjs, src/app/layout.tsx | - | - |
...
```

Rules:

- **Own ∩ Own = ∅** (no two agents own the same file) — if violated, the Wave is invalid, split or serialize
- **A.own ∩ B.must-not-touch = ∅** (no agent owns a file another agent forbids) — if violated, the constraint is wrong OR one agent is out of scope
- **Line-range scopes allowed** — two agents can own different line ranges of the same file, but the ranges must be explicit and the dispatch prompt must enforce them

If the conflict map is clean, the Wave is green-lit.

### Step 3 — Dispatch the Wave as a single parallel batch

Call `Task` with all N agents in **one message** (multiple tool_use blocks). Never serialize the dispatch within a Wave.

### Step 4 — Wait for all agents in the Wave to return

Do not start Wave N+1 until every agent in Wave N has returned. Validation gate runs between Waves.

### Step 5 — Validation gate between Waves

Each Wave must end with:

- `pnpm tsc --noEmit` (or equivalent typecheck) = 0 errors
- `pnpm lint` (or equivalent) = 0 errors (warnings acceptable)
- `pnpm build` (or equivalent) = green
- `git commit` with Wave ID in the message (e.g. `sprint-1-wave-1: ...`)

If the gate fails, the Wave must be fixed before Wave N+1 starts. Do not "batch the cleanup at the end" — always between Waves.

### Step 6 — Sub-waves for partial parallelism

Sometimes a Wave contains items that *mostly* can run in parallel but one pair conflicts on a file. Split the Wave into sub-waves:

```
Wave 2A: items that can run in parallel
Wave 2B: items that must run after 2A because they share file surface
```

Sub-wave B is serial relative to sub-wave A but still part of "Wave 2" in the roadmap.

## Reference example — oguzhansert.dev Sprint 1

```
Wave 1 (9 agents parallel, ~7 min wall-clock):
  - G1: fail-closed admin auth (src/middleware.ts, src/lib/auth.ts)
  - G2: server-only import (src/lib/supabase-admin.ts)
  - G3: CSP hardening (next.config.mjs, src/app/layout.tsx)
  - G4: upload SVG drop (src/app/api/admin/upload/route.ts)
  - G5: schema drift fix (docs/migrations/...)
  - G6: deploy.sh rewrite (infrastructure/deploy.sh, ecosystem.config.cjs)
  - G7: error boundaries (src/app/error.tsx, global-error.tsx)
  - G8: i18n parity script (scripts/check-i18n-parity.mjs)
  - G9: Turkish normalization helper (src/lib/turkish.ts)

Wave 2A (2 agents parallel):
  - G4A: audit log helper (src/lib/audit-log.ts)
  - G4C: rate limit enforcer (src/lib/rate-limit.ts)

Wave 2B (1 agent sequential after 2A):
  - G4B: admin mutation wrap (src/app/api/admin/[table]/route.ts)
    — overlaps with G4A on audit log import surface

Wave 3 (orchestrator-direct VPS ops):
  - chmod 0600 on .env.local
  - pm2-logrotate install
  - apply 3 SQL migrations to prod DB
  - live smoke probes
```

**Result**: 9 + 2 + 1 + VPS = 12 agents over ~25 min wall-clock, zero file conflicts.

## Anti-patterns

- **Dispatching parallel agents without a pre-flight conflict map** — race conditions, lost writes, validation failures mid-Wave
- **Skipping the validation gate between Waves** — bugs cascade, debugging becomes forensic
- **Running a sequential "cleanup" pass after all Waves** instead of between Waves — the cleanup agent re-reads the entire codebase state the earlier agents already knew
- **One giant parallel dispatch that ignores dependencies** — the agents write to inconsistent intermediate states
- **Serializing a Wave that could have been parallel** — wall-clock waste for no safety gain

## Integration

- `docs/runtime/program-phases.md` — the Waves pattern is the execution model AFTER the director protocol completes (Phase 6 execution onward)
- `docs/runtime/roadmap-rule.md` — roadmap items carry `depends_on` fields that drive Wave grouping
- `docs/governance/finding-schema.md` — items generated from findings inherit the finding's severity + priority
- `docs/runtime/live-probe-contract.md` — VPS operations in a Wave must pass live-probe gates
- `docs/runtime/anti-patterns.md` — the anti-patterns above cross-reference there

## Future — parallel-dispatch-planner skill (PG-01)

A skill that takes a Wave's agent list + claimed file scopes and automatically builds the conflict matrix, emitting GREEN (dispatch) or RED (refuse + reasons). Not implemented yet. Until it exists, the orchestrator builds the matrix manually and records it in `reports/current/conflict-matrix-wave-N.md` before dispatch.
