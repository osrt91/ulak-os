# Multi-Agent Merge Sequence

## Why this exists

When four or more specialist agents work in parallel on the same codebase, their writes conflict unless they merge in a deliberate order. Without a sequence, merges produce:

- Backend writes a new endpoint; frontend writes a caller for it; they merge simultaneously; the caller expects field `foo_id`, the endpoint returns `foo`. Broken at integration.
- Infra changes the Docker compose network; backend writes code assuming the old network. Service can't reach DB.
- Tests get written against interim state that no single branch reaches. Tests pass locally, fail on merge.

The Strangler Fig protocol gave the security scanner project's audit a 70% conflict reduction by enforcing a merge order: **infrastructure → backend → frontend → tests**. This doc generalizes that rule.

## The ordering principle

Merges happen **by dependency depth**. A change that everything else depends on merges first. A change that depends on everything else merges last.

| Depth | Layer | What merges here | Why first / last |
|---|---|---|---|
| 0 | Infrastructure | Docker, CI, Redis, network, env vars, deployment | Everything depends on this; nothing depends on app code yet |
| 1 | Backend / domain logic | API endpoints, services, migrations, business logic | Depends on infra; frontend + tests depend on it |
| 2 | Frontend / presentation | UI components, client data fetching, routing | Depends on backend contract; doesn't dictate backend |
| 3+ | Tests / validation | Integration tests, E2E, contract tests | Depends on all above being stable |

A Wave may skip layers it doesn't touch — a docs-only Wave has no infra or backend changes, so depth 0+1 are no-ops. But when layers are touched, the order holds.

## When to apply

Apply this merge sequence when **≥4 specialist agents** are dispatched in parallel on tasks that touch **≥2 of the depth layers above**.

Do NOT apply when:

- Only one layer is touched (e.g., all 6 agents work on docs only — layer 3+ doesn't even exist)
- Changes are in completely independent files (no shared dependency graph)
- The work is sequential by nature (one agent explicitly waits on another's output)

## Per-Wave protocol

Each Wave follows the same six steps:

1. **Conflict map** — before dispatching agents, build a matrix of "who writes file X". Any cell with ≥2 agents halts the Wave. Split into sub-Waves.
2. **Dispatch** — all agents in a single parallel batch (one message, multiple Task calls). No serialization.
3. **Collect** — gather each agent's output; verify each produced the expected artefact
4. **Merge in depth order** — infrastructure first, backend second, frontend third, tests last. Apply merges in order; run validation gate between each depth.
5. **Validation gate between depths** — typecheck + lint + build + commit. A depth merge that fails its gate blocks the following depths until the failure is resolved.
6. **Close the Wave** — a passing validation gate after depth N closes the Wave. Next Wave begins.

## Depth-specific merge rules

### Depth 0 — Infrastructure

Merge order within depth 0 (if multiple infra changes):

1. Network / service topology changes (compose files, nginx config)
2. Build / image changes (Dockerfiles, requirements, package.json)
3. CI / hooks changes (`.github/workflows/`, pre-commit)
4. Env var / secret changes (`.env.example`, secret manager declarations)

Each step's validation gate is a green CI run on main.

### Depth 1 — Backend

Merge order within depth 1:

1. Database migrations (schema changes — reversible preferred)
2. Data layer (repositories, ORM models)
3. Service layer (business logic)
4. API layer (routes, controllers, handlers)
5. Contract publication (OpenAPI / GraphQL schema update)

Contract publication last in depth 1 ensures frontend (depth 2) sees a stable contract.

### Depth 2 — Frontend

Merge order within depth 2:

1. Type definitions generated from backend contract
2. Data fetching layer (API clients, hooks)
3. UI components (consuming the hooks)
4. Routing / navigation (consuming the components)

### Depth 3+ — Tests / validation

Merge order within tests:

1. Unit tests for moved functions
2. Integration tests for service + repository
3. Contract tests for API surface
4. E2E tests for critical user flows
5. Visual regression tests (lowest priority; often flaky)

## File ownership discipline

Every file has a **single owning agent** during a Wave. Shared files require orchestrator approval:

| File | Typical owner | Shared with |
|---|---|---|
| `docker-compose.yml` | Infra | Backend (proposes via PR, Infra reviews) |
| `requirements.txt` / `package.json` | Backend | Infra (reviews for security / size) |
| `schema.sql` / migrations | Backend | Infra (reviews for locking / downtime) |
| `openapi.yaml` / contract | Backend | Frontend (consumer; no write) |
| `types/*.ts` (generated) | Build tool | All (read-only — regenerate on contract change) |

If two agents need to touch the same file in the same Wave, the Wave is split into sub-Waves. Do not allow parallel edits of the same file.

## Anti-patterns this protocol replaces

- **Simultaneous merges across all depths** — infra + backend + frontend + tests all commit at the same timestamp, breakage guaranteed
- **Tests merged before the backend they test** — CI green on tests that pass against a state no branch reaches
- **Frontend merged before backend contract is stable** — frontend expects old field name, backend ships new one, integration broken
- **Orchestrator as single point of failure** — if the orchestrator is absent, Waves halt. Protocol is documented here so any operator can run it.

## Orchestration signals

The autonomous-program-director agent uses this protocol in Phase 5 §5b (execution) when multiple agent dispatch is active. It:

- Builds the conflict map before each Wave
- Rejects a Wave where the conflict map shows a cell with ≥2 agents
- Dispatches agents in a single parallel Task batch
- Runs the validation gate between depths
- Emits `reports/current/conflict-matrix-wave-N.md` as audit trail

## Integration

- `docs/runtime/waves-pattern.md` — the outer Wave pattern this protocol refines
- `docs/runtime/strangler-fig-protocol.md` — backend decomposition uses this merge order
- `docs/runtime/program-phases.md` — Phase 5 §5b execution consumes this protocol
- `.claude/agents/autonomous-program-director.md` — runs this protocol
- `.claude/skills/multi-agent-orchestration/` — skill-form that executes a Wave (v2.1.3 Wave 4)

## Canonical footer

Authoritative as of Ulak OS **v2.1.3**. Evidence base: a security scanner project `_project_audit/06_multi_agent/agent-topology.md:250-305` and `orchestrator-rules.md:109-130`.
