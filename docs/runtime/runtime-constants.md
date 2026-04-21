# Runtime Constants — Single Source of Truth

## Why this exists

Field names and magic numbers that appear in multiple always-loaded runtime docs drift. The Ulak OS self-audit (DY-04 in v2.1.3) found `REQUIRED_PACKS` (in `active-variable-contract.md:60`) referring to the same field as `required_sector_packs` (in `router.md:87` and `sector-packs.md:140`). Two names for one concept, in three always-loaded docs. A specialist writing `active-variables.yaml` populates the first name; a router reader looks for the second. Silent no-op.

Similarly, `MAX_PARALLEL_AGENTS` appeared as `6` in the director agent prompt, `parallel_dispatch=6` in the command, and `default 6` in the roadmap rule — three places to update if the default changes.

This doc is the **single source of truth** for named constants and canonical field names. Every other runtime doc references THIS file instead of restating the value.

## Canonical field names

| Canonical name | Context | Older names (now deprecated) |
|---|---|---|
| `required_sector_packs` | Router output field | `REQUIRED_PACKS` |
| `rule_packs_loaded` | Active-variable field | — (new in v2.1.3) |
| `active_sector_packs` | Active-variable field | `ACTIVE_PACKS` |
| `mcp_authorized_tools` | Active-variable field | — (new in v2.1.3) |
| `signoff_status` | Validation-result field | `release_signoff` |
| `project_state` | Router output field | `PROJECT_STATE`, `projectState` |
| `intervention_mode` | Router output field | `INTERVENTION_MODE`, `mode` (ambiguous — prefer full name) |
| `output_profile` | Router output field | `OUTPUT_PROFILE`, `profile` (ambiguous) |
| `validation_depth` | Router output field | `VALIDATION_DEPTH` |
| `live_probe_required` | Router output field | `LIVE_PROBE_REQUIRED`, `LIVE_PROBE` |
| `high_stakes` | Router output field | `HIGH_STAKES` |
| `primary_surface` | Router output field | (new in v2.1.3) |
| `active_overlays` | Router output field | `ACTIVE_OVERLAYS` |
| `source_personas` | Finding field (persona dispatch) | `personas`, `source_persona` (singular form only for one-persona case) |
| `overlap_count` | Finding field (persona / specialist agreement) | `agreement_count` |
| `trust` | Finding field (tier T1–T7) | `evidence_tier`, `trust_tier` |

When a doc updates to canonical names, the old name is removed (not aliased — aliasing perpetuates drift).

## Canonical numeric constants

| Constant | Value | Unit | Used by |
|---|---|---|---|
| `MAX_PARALLEL_AGENTS` | 6 | agents per Wave | waves-pattern.md, director agent, execution-roadmap |
| `MAX_PARALLEL_AGENTS_HARD_CAP` | 10 | agents per Wave | director agent (refuses dispatches over this) |
| `PROBE_DEFAULT_TIMEOUT_SECONDS` | 30 | seconds | live-probe-contract.md, sample-validation-plan.md |
| `PROBE_MAX_TIMEOUT_SECONDS` | 300 | seconds | live-probe-contract.md (long-running probes must declare + get approval) |
| `LOCK_DEFAULT_TTL_SECONDS` | 3600 | seconds | lock-file-hygiene.md |
| `LOCK_MAX_TTL_SECONDS` | 14400 | seconds | lock-file-hygiene.md |
| `CACHE_TTL_ROLE_SECONDS` | 30 | seconds | product-surface-split.md (DB-sourced role cache) |
| `CACHE_TTL_PLAN_CAPABILITY_SECONDS` | 60 | seconds | product-surface-split.md (reseller plan-capability cache) |
| `RULE_PACK_BODY_MAX_BYTES` | 500 | bytes | rule-pack-governance.md |
| `WORKTREE_STALE_FLAG_DAYS` | 7 | days | memory-hygiene.md |
| `WORKTREE_AUTO_PRUNE_DAYS` | 30 | days | memory-hygiene.md |

## Canonical phase numbering

See `docs/runtime/program-phases.md` §Canonical numbering. Six phases (0–5) plus one conditional (4.5). The old Phase 5/6/7/8 numbering is deprecated; any cross-reference using those numbers is a lint finding.

## Canonical trust tiers

See `docs/governance/evidence-trust-scoring.md` for T1–T7 definitions. This file only lists the canonical codes — do not redefine meanings elsewhere:

- **T1** — Observed and verified (direct read of current code / config)
- **T2** — Inferred from current code / config (strong signal, one-step reasoning)
- **T3** — Memory-sourced or user-sourced (accurate at time of capture; may be stale)
- **T4** — External doc / spec (vendor docs, RFCs)
- **T5** — Recent news / third-party research (cite source + date)
- **T6** — Industry norm / heuristic
- **T7** — Model prior / guess (lowest trust; must be marked)

## How to reference a constant

In prose: `MAX_PARALLEL_AGENTS` (6 per Wave, see `docs/runtime/runtime-constants.md`)

In YAML: `max_parallel_agents: 6 # MAX_PARALLEL_AGENTS`

In code: the value should be imported from a config file that this doc declares as the source of truth (v2.2 ships a `config/runtime-constants.yaml` loaded by scripts).

## Drift enforcement

- `scripts/validate-constants.sh` (v2.2) will grep for deprecated names and flag occurrences
- Pull request template asks "Did you change a named constant? If yes, is runtime-constants.md updated?"
- Manager verdict must not cite a deprecated name in any artefact it emits

## Integration

- `docs/runtime/router.md` — canonical output field names
- `docs/runtime/active-variable-contract.md` — canonical active-variables.yaml field names
- `docs/runtime/program-phases.md` — phase numbering source of truth
- `docs/runtime/waves-pattern.md` — MAX_PARALLEL_AGENTS source
- `docs/governance/evidence-trust-scoring.md` — trust tier definitions
- `docs/runtime/live-probe-contract.md` — probe timeouts
- `docs/governance/lock-file-hygiene.md` — lock TTLs
- `docs/governance/rule-pack-governance.md` — rule pack size cap

## Canonical footer

Authoritative as of Ulak OS **v2.1.3**. Motivated by DY-04 (field-name drift) and DY-10 in the v2.1.3 self-audit.
