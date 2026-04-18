---
name: god-module-decomposition
description: Extract and decompose a "god module" (single file >1000 LOC with 5+ unrelated responsibilities) using the Strangler Fig protocol. Produces new modules in target package, a thin re-export shim of the original, per-step atomic commits, and updated imports across the codebase. Use for monolithic files blocking modernization.
context: fork
agent: architecture-lead
allowed-tools: Read Grep Glob Edit Write Bash
---

# God Module Decomposition (Strangler Fig Executor)

## Goal

Safely decompose a single-file monolith into a multi-module package without a big-bang rewrite, using the Strangler Fig pattern documented in `docs/runtime/strangler-fig-protocol.md`.

## When to use

Invoke when `inventory.md` or an anti-patterns match flags a "God module (>1000 LOC)" finding. Representative example: scanner-project.com's `scanner-project.py` (146KB, 15+ responsibilities) decomposed to a 73-line shim backed by `app/main.py` + `app/routers/*.py`.

## Inputs

- `source_file` — absolute path to the monolith (e.g., `C:/Users/osrt91/desktop/proje/<project>/scanner-project.py`)
- `target_package` — destination package name (e.g., `app`)
- `extraction_plan` — YAML document listing phases A/B/C/D with:
  - `phase_id` — A / B / C / D
  - `step_id` — A.1 / A.2 / ... within phase
  - `source_line_range` — lines in the monolith to move
  - `target_module` — destination path (e.g., `app/services/scoring.py`)
  - `dependencies` — prior step_ids this depends on
- `test_command` — command to run after each step (e.g., `pytest tests/`)

## Outputs

- New package directory with extracted modules
- Original file rewritten as a thin re-export shim
- Per-step atomic commits with descriptive messages
- Updated imports across the consumer codebase
- Optional: `reports/current/god-module-decomposition-log.md` — step-by-step log

## Process (per step)

For every step in `extraction_plan`, execute six moves in order:

1. **Create** the new module at `target_module` with the extracted code
2. **Move** code from `source_file` (copy, then delete from source)
3. **Run** `test_command` — must pass green
4. **Update** all imports in consumer files (grep for old symbols, replace with new import paths)
5. **Verify** — re-run `test_command`, still green
6. **Commit** atomically with message `extract(<phase>.<step>): <description>`

A failing step ROLLS BACK via `git reset --hard HEAD` — never leave the tree in an intermediate state.

## Phase ordering (Strangler Fig protocol)

- **Phase A — Pure functions**: side-effect-free, framework-independent. Easiest and safest.
- **Phase B — Services**: stateful classes with external deps. Test via integration tests with test doubles.
- **Phase C — Routers**: HTTP handlers one domain at a time. Shim thins here.
- **Phase D — Engine**: app bootstrap (FastAPI/Express/Rails factory). Final extraction; shim becomes a single-line re-export.

## Quality gates

Every extraction step must satisfy:

- No circular imports
- Every moved function/class is typed
- Each target module ≤400 LOC
- No `import *`
- Test coverage after ≥ coverage before

Failed gate → revert step, re-plan.

## Rules

- Never combine extraction with a feature add — review impossible, rollback loses the feature
- Never leave partial extraction without a shim — two sources of truth, drift guaranteed
- Never run multiple extractions in parallel on the same monolith — conflicts guaranteed
- Coordinate with `docs/runtime/multi-agent-merge-sequence.md` if other agents are working concurrently — infra first, then backend (this skill lives here), then frontend, then tests

## Integration

- `docs/runtime/strangler-fig-protocol.md` — the full migration protocol
- `docs/runtime/anti-patterns.md` — God module anti-pattern entry
- `docs/runtime/multi-agent-merge-sequence.md` — merge order if running alongside other agents
- `docs/runtime/audit-scoring-framework.md` — Architecture dimension improves as this skill lands
