# Rule Pack Governance

## What a rule pack is

A **rule pack** is a `<500-byte-body`, imperative-only, always-on guardrail for a specific tech stack or risk surface. It is auto-loaded into hot context during Phase 0 based on detected stack in `runtime-manifest.md`. It is NOT doctrine (those live in `docs/runtime/*.md`), NOT a workflow (those are skills), NOT an agent (those are specialists), NOT a hook (those are deterministic enforcers).

Rule packs fill a category gap that the earlier plugin/skill/agent/command/hook/MCP decision matrix missed: **lightweight, language/stack-specific, always-on guardrails** that every session loads whenever a matching stack is detected.

## Where rule packs live

- **Ulak-shipped packs**: `docs/runtime/rule-packs/<stack>.md` — part of the public runtime surface (Layer 1)
- **Project-local overrides**: `.claude/rules/<stack>.md` — per-project opt-in deviations

## Load order

1. Phase 0 toolchain precheck detects stacks present in the project
2. Director populates `active-variables.yaml` field `rule_packs_loaded: [typescript-nextjs, docker-compose, ...]`
3. Each matched pack is loaded **after** `anti-patterns.md` but **before** `output-profiles.md` in the context-budget ordering
4. If a project-local `.claude/rules/<stack>.md` exists for a matched stack, it is loaded AFTER the Ulak pack for the same stack

## Precedence (merge rule)

Project-local overrides follow **selective merge**:

- Each imperative is treated as a named rule (by intent, not exact wording)
- If the project-local pack redefines an imperative, project-local wins for that rule
- Imperatives in the Ulak pack NOT touched by the project-local pack stay active
- The project-local pack does NOT need to repeat Ulak rules it wants to keep

This resolves Open Question #6 from the v2.1.3 target-state: **MERGE with project override** (not wholesale replace).

## Authoring rules

Every rule pack (Ulak-shipped or project-local) MUST:

1. **Size cap** — body (after title + activation line) is ≤500 bytes for the Ulak-shipped version. Project overrides are not capped but are encouraged to stay small.
2. **Imperatives only** — each bullet is a short command. "Do X. Never Y. Prefer Z." Not narrative.
3. **Activation line** — state when the pack loads, e.g. "Activated when runtime-manifest detects `python` + `fastapi`". This allows toolchain-precheck to select packs automatically.
4. **Collision rule** — a final paragraph saying "project-local `.claude/rules/<stack>.md` overrides specific imperatives; unmatched inherit". This makes precedence unambiguous to every reader.
5. **Cross-references** — anti-patterns or runtime rules referenced by the pack should link by code (e.g. `AP-05`) to `docs/runtime/anti-patterns.md`, not duplicate them.
6. **Pure-generic vs project-specific** — packs shipped in Ulak are generic (no `plugins/base_plugin.py`, no "43 services"). Project-specific paths belong in `.claude/rules/`, not in Ulak packs.

## Precedence with `rule-collision-matrix.md`

If a rule-pack imperative contradicts default behavior, the contradiction is logged in `rule-collision-matrix.md` with the chosen precedence recorded. A pack CANNOT silently override priority 1–4 concerns (security, legal, privacy, evidence quality, reversibility, validation completeness).

## Starter packs (as of v2.1.3)

- `docs/runtime/rule-packs/typescript-nextjs.md`
- `docs/runtime/rule-packs/python-fastapi.md`
- `docs/runtime/rule-packs/docker-compose.md`
- `docs/runtime/rule-packs/api-security.md`

Additions require: (a) detected stack presence in ≥2 real projects, (b) imperatives that are genuinely cross-project, (c) no overlap with existing packs (promote shared rules up to `anti-patterns.md` or a runtime rule).

## Integration

- `docs/governance/plugin-skill-decision.md` — rule-pack is the 7th unit type in the decision matrix
- `docs/runtime/active-variable-contract.md` — `rule_packs_loaded` field records which packs are active
- `docs/runtime/toolchain-precheck.md` — Phase 0 detection drives pack selection
- `docs/runtime/context-budget.md` — packs load after anti-patterns, before output profiles
- `docs/governance/rule-collision-matrix.md` — contradictions recorded there
