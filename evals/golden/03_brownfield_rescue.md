# Golden Prompt 03 — Brownfield Rescue

## User request

> "Bu proje dağınık, kırık ve release'e yakın. Kurtar."

## Expected router decision

```yaml
router:
  task_type: intervention
  active_mode: rescue
  project_state: brownfield
  intervention_mode: RESCUE
  scope_level: multi-surface-full-system
  live_research_need: not-needed
  artefact_program: full
  output_type: markdown-artifact-set
  output_profile: BROWNFIELD_INTERVENTION_PROFILE
  required_overlays:
    - toolchain-precheck
  required_sector_packs: []
  blocked_paths: []
  validation_depth: deep
  max_parallel_agents: 6
  rationale: "Explicit rescue with near-release timing → deep validation, no time for market research, prioritize stabilization."
```

## Expected active agent map

- cartographer (deep inventory, broken-surface map)
- architecture-lead
- backend-api-architect
- data-database-governor
- security-hardening-lead
- qa-validation-commander
- infra-release-sre
- release-readiness-auditor
- red-team-challenger (adversarial sanity check before release)
- privacy-compliance-counsel

## Must include (assertions)

- Router decision shows `intervention_mode: RESCUE` and `validation_depth: deep`
- `reports/current/inventory.md` contains broken-surface map:
  - broken routes
  - broken links
  - broken callbacks
  - dead CTAs
  - orphan menu items
- `reports/current/evidence-register.md` prioritizes Critical findings at the top
- `reports/current/risk-register.md` (or `analysis-findings.md` at severity: Critical) exists
- `reports/current/execution-roadmap.md` has a stabilization-first ordering:
  - immediate blockers (hours)
  - release blockers (days)
  - post-release (weeks)
- `reports/current/rollback-plan.md` or equivalent exists
- `reports/current/validation-plan.md` includes release gates
- `reports/current/manager-verdict.md` explicitly states `signoff_status: blocked | conditional | ready`
- Residual risks are enumerated with severity
- Rollback readiness is marked `yes | no | partial`

## Must NOT include

- Market research artefacts (not in scope for rescue)
- Design system refactor recommendations (out of scope unless breaking release)
- Feature additions (rescue is stabilize, not extend)
- A verdict claiming `ready` when Critical findings exist
- "Run lint" as the main validation — rescue needs e2e + security + release checks
- Suggestions that require a week of implementation when the timeline says "release'e yakın"

## Validation criteria

- `correct_mode`: brownfield + RESCUE
- `correct_output_profile`: BROWNFIELD_INTERVENTION_PROFILE
- `broken_surface_map_present`: inventory includes broken-* lists
- `stabilization_first_roadmap`: immediate blockers at the top
- `rollback_explicit`: rollback_ready field is populated
- `signoff_status_honest`: `blocked` or `conditional` if Critical findings exist

## Regression signals

- "Let's start with a design refactor" as the first roadmap item
- Skipping broken-link / broken-endpoint checks
- Marking signoff_status: ready while unresolved_risks contains Critical entries
- Recommending a new feature as the rescue solution
- Market research artefacts in the output
