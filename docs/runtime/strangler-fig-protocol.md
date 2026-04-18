# Strangler Fig Protocol

## Why this exists

When a codebase has a single file over ~1,000 LOC doing five or more unrelated things, the instinct is "rewrite it from scratch". That instinct is almost always wrong. Big-bang rewrites fail because they try to hold the entire semantics of the old system in memory while producing a new one with no production signal.

The **Strangler Fig** pattern (named after the strangler fig tree that grows around its host tree until the host is gone) is the safer migration: extract responsibilities one at a time, keep the old file as a thin re-export shim, verify each extraction with tests, commit atomically. The old file "dies" when the last responsibility is moved; no production outage, no big-bang weekend.

Scanner-project.com's backend went through this: `scanner-project.py` was a 146KB monolith holding FastAPI app, middleware, Pydantic models, scoring engine, HTML report templates, email sending, AI chat, 15 API routes, WebSocket handler, SSR dashboard. It is now a 73-line shim; the real orchestration lives in `app/main.py` + `app/routers/*.py`.

## When to apply

Apply Strangler Fig when **any** of these are true:

- A single file exceeds 1,000 LOC with 5+ unrelated responsibilities
- A file is touched in >40% of PRs (high merge conflict rate)
- Cyclomatic complexity in one file exceeds 100
- IDE indexing lags or test runs are slow because one file dominates the dependency graph
- New team members take >1 day to understand "what's in this file"

Do NOT apply Strangler Fig when:

- The monolith file is <400 LOC (split is unnecessary)
- Responsibilities are genuinely coupled (e.g., a tight state machine — splitting adds indirection without benefit)
- The project is about to be archived (invested effort wasted)

## The four phases

Extraction happens in a fixed order: **A → B → C → D**. Each phase extracts a layer; the following phase depends on the previous layer's exports.

### Phase A — Pure functions

Move functions with no side effects and no framework dependencies. These are the easiest to test and the safest to move.

Examples from scanner-project: `config.py` (env var parsing), `models/schemas.py` (Pydantic request/response shapes), `services/scoring.py` (scoring math), `services/utils.py` (helpers).

Acceptance: every moved function has a test; the original call sites import from the new module.

### Phase B — Services

Move stateful service classes with external dependencies (API clients, email senders, cache wrappers). These are harder to test than pure functions but still isolated.

Examples: `services/ai_service.py` (AI API wrapper), `services/email_service.py`, `services/report_service.py`, `services/scan_state.py`, `services/rate_limit.py`.

Acceptance: every service has an integration test using test doubles (not mocks of the service itself — mocks of its external dependencies).

### Phase C — Routers

Move HTTP route handlers one domain at a time. This is where the shim starts to thin.

Examples from scanner-project: `routers/health.py`, `routers/scan.py`, `routers/admin.py`, `routers/reseller.py`, `routers/content.py`, `routers/config_routes.py`.

Acceptance: each router file is <400 LOC; each endpoint has a contract test; the original file imports `include_router(<new_router>)` instead of defining routes directly.

### Phase D — Engine

Move the application bootstrap (FastAPI / Express / Fastify / Rails app factory). This is the last extraction and it collapses the monolith to a shim.

Examples: `app/main.py` (app factory), `app/phase_registry.py`, `app/scanner.py`.

Acceptance: the original file is <100 LOC and does nothing but `from app.main import app`.

## Per-step discipline

Every extraction step (regardless of phase) follows the same six moves:

1. **Create** the new module in its target location
2. **Move** the code from the original file (copy, then delete from source)
3. **Run** the test suite — must pass green
4. **Update** all imports in the codebase to point at the new module
5. **Verify** with a fresh test run — still green
6. **Commit** atomically with a message naming the extraction step

A failed step rolls back via `git reset --hard HEAD` (no mid-extraction "fix later" state).

## Quality gates

Every extraction must satisfy:

- No circular imports introduced
- Every moved function/class is typed
- Each target module is ≤400 LOC
- No `import *` anywhere (explicit imports only)
- Test coverage after extraction ≥ coverage before

If a quality gate fails, revert and re-plan — do not merge "we'll fix it in the next PR".

## Merge order with other agents

If Strangler Fig runs concurrently with other migrations, the merge order rule from `docs/runtime/multi-agent-merge-sequence.md` applies: infrastructure (depth 0) → backend (depth 1, Strangler Fig lives here) → frontend (depth 2) → tests (depth N).

## Skill-form executor

The extractor can be codified as a skill: input = file path + target package + extraction plan (JSON of phases, deps, line ranges); output = new package + shim + per-step commits + updated imports. See SK-01 in `.claude/skills/god-module-decomposition/` (shipped in v2.1.3 Wave 4).

## Anti-patterns this protocol replaces

- **Big-bang rewrite**: "let's rewrite scanner-project.py as app/v2/" — 4 weeks of invisible work, two unrelated bugs, merge hell
- **Mid-session refactor**: splitting in the same commit as a feature add — review impossible, rollback loses the feature
- **Partial extraction without shim**: imports from the original path still work because the original file still has the code AND the new file has it too — two sources of truth, drift guaranteed

## Integration

- `docs/runtime/anti-patterns.md` — God module (AP-entry, derived from scanner-project critical-findings) is the primary motivator
- `docs/runtime/multi-agent-merge-sequence.md` — merge order when multiple agents run
- `docs/runtime/waves-pattern.md` — Strangler Fig extractions fit into waves, not ad-hoc PRs
- `.claude/skills/god-module-decomposition/` — the executable skill form (v2.1.3)
- `docs/runtime/audit-scoring-framework.md` — the "Architecture" dimension improves as Strangler Fig lands

## Canonical footer

Authoritative as of Ulak OS **v2.1.3**. Evidence base: scanner-project.com `_project_audit/04_modernization/backend-modernization.md` (the real-world executed example) + `final-executive-report.md:86-114`.
