# Runtime Router

## Purpose

Decide how the system should engage **before any deep work begins**. The router is the first phase of every serious run and its output gates everything downstream: which specialists are dispatched, which overlays load, which output profile applies, and how deep the validation gate goes.

## The router must always run

When the user intent is clearly full, complete, or end-to-end, do not restart with menu loops — **but do still run the router internally**. The router can complete in one pass from clear intent. It just must not ask the user to pick from a menu when the decision is already evident from the request.

## Decision questions

The router answers these questions before emitting its decision:

### 1. Task type
Pick one:

- `audit` — discover and classify issues on an existing system
- `creation` — build something new
- `intervention` — repair, extend, or harden something existing
- `redesign` — visual / UX rework
- `hardening` — security, abuse resistance, API protection
- `migration` — move from one stack / pattern / data model to another
- `release-readiness` — verify ship-ability
- `pack-generation` — produce a reusable pack (commands, skills, agents)
- `prompt-governance` — maintain or extend the prompt OS itself
- `research-only` — market scan, architecture currency, no execution
- `execution-hybrid` — analysis + controlled edits in one run

### 2. Project state
- `greenfield` — no system or very early stage
- `brownfield` — running or partially running system with existing debt
- `hybrid` — some surfaces new, some legacy

### 3. Intervention mode
- `CREATE` | `REPAIR` | `EXTEND` | `REFACTOR` | `MIGRATE` | `RESCUE` | `REPACKAGE`

### 4. Scope level
- `single-screen` | `single-endpoint` | `single-flow` | `module` | `product` | `multi-surface-full-system`

### 5. Live research need
- `required` — cannot proceed without live data (market entry, architecture currency, recent upstream changes)
- `helpful` — would improve the output but not strictly necessary
- `not-needed` — the repo and user inputs are sufficient

### 6. Artefact program
- `none` — answer inline, no files written
- `report-only` — markdown artefacts under reports/current/
- `pack-only` — pack files under .claude/ and prompts/
- `full` — report + pack + validation artefacts

### 7. Final output type
- `audit-report` | `roadmap` | `repo-pack` | `markdown-artifact-set` | `structured-json` | `hybrid`

### 8. Output profile
See `docs/runtime/output-profiles.md`. Pick one:

- `AUDIT_PROFILE`
- `GREENFIELD_BUILDER_PROFILE`
- `BROWNFIELD_INTERVENTION_PROFILE`
- `LOCALIZATION_REPAIR_PROFILE`
- `MARKET_ENTRY_PROFILE`
- `PACK_GENERATION_PROFILE`
- `RELEASE_READINESS_PROFILE`

### 9. Validation depth
- `light` — spot checks, lint + build only
- `standard` — full engineering gates
- `deep` — engineering + security + localization + release + prompt-regression

## Router decision template (YAML)

The router emits this block and the director pins it for the whole run:

```yaml
router:
  task_type: ""                         # see question 1
  active_mode: ""                       # task_type mapped to execution vocabulary
  project_state: greenfield|brownfield|hybrid
  intervention_mode: CREATE|REPAIR|EXTEND|REFACTOR|MIGRATE|RESCUE|REPACKAGE
  scope_level: single-screen|single-endpoint|single-flow|module|product|multi-surface-full-system
  live_research_need: required|helpful|not-needed
  artefact_program: none|report-only|pack-only|full
  output_type: audit-report|roadmap|repo-pack|markdown-artifact-set|structured-json|hybrid
  output_profile: ""                    # one of the 7 profiles
  required_overlays: []                 # e.g. turkish-normalization, localization-strategy
  required_sector_packs: []             # e.g. education, fintech
  blocked_paths: []                     # paths the director must not read/write
  validation_depth: light|standard|deep
  max_parallel_agents: 6                # phase 2 dispatch cap
  rationale: ""                         # 1-3 sentences why these choices
```

This block goes into `reports/current/runtime-manifest.md`.

## Surfaces to consider

The router should be surface-aware. Typical surfaces to inventory before locking decisions:

- customer (end-user web / app)
- admin / operator panel
- public API
- internal API
- backend services
- database
- infra / deploy pipeline
- mobile (iOS / Android / Flutter)
- marketing / landing / blog
- payments / billing
- localization / i18n
- compliance / legal surfaces

The router does not need to scan each surface at this phase — that's the cartographer's job in Phase 1. But it must know which surfaces *exist* so it can pick the right specialists.

## Hard rules

- **Router decision is mandatory.** No phase 1 work without a committed router decision.
- **Do not load all overlays.** Only load what the router names in `required_overlays` and `required_sector_packs`.
- **Do not skip the router just because the user's intent sounds simple.** A "just a quick fix" request may still need brownfield + REPAIR + BROWNFIELD_INTERVENTION_PROFILE.
- **Router output is data for downstream phases, but the choices themselves are decisions — pin them, do not let Phase 2 specialists re-open them.**
- **When intent is clear, do not restart with menu loops.** Complete the router from the request and start Phase 1 immediately.

## Integration

- `docs/runtime/context-budget.md` — context is loaded based on router choices
- `docs/runtime/output-profiles.md` — the profile the router picks gates the final output
- `docs/runtime/active-variable-contract.md` — router output populates the active variable YAML
- `.claude/agents/autonomous-program-director.md` — the director is the agent that runs the router
