# Golden Prompt 02 — Greenfield New Product

## User request

> "Sıfırdan 2026 seviyesinde eğitim ürünü kur. Mimariyi, pack yapısını, araştırmayı ve ilk release planını çıkar."

## Expected router decision

```yaml
router:
  task_type: creation
  active_mode: builder
  project_state: greenfield
  intervention_mode: CREATE
  scope_level: multi-surface-full-system
  live_research_need: required
  artefact_program: full
  output_type: markdown-artifact-set
  output_profile: GREENFIELD_BUILDER_PROFILE
  required_overlays:
    - market-research-engine
    - localization-strategy
    - architecture-currency
  required_sector_packs:
    - education
  blocked_paths: []
  validation_depth: standard
  max_parallel_agents: 6
  rationale: "Greenfield creation with explicit research + release planning. Market research is required because this is a new product entering a market."
```

## Expected active agent map

- cartographer (light — mostly empty repo)
- product-business-strategist
- market-researcher (T1 + T5 sources)
- architecture-lead
- design-system-architect
- educational-ux-specialist
- backend-api-architect
- data-database-governor
- infra-release-sre
- localization-i18n-lead (for locale baseline)
- privacy-compliance-counsel
- release-readiness-auditor
- seo-aso-growth-strategist

## Must include (assertions)

- Router decision shows `project_state: greenfield` and `intervention_mode: CREATE`
- Router decision shows `live_research_need: required`
- Output profile is `GREENFIELD_BUILDER_PROFILE`
- All GREENFIELD_BUILDER_PROFILE required sections present:
  - product assumptions
  - first release slice
  - architecture baseline
  - design system baseline
  - folder topology
  - analytics plan
  - testing baseline
  - release plan
- `reports/current/market-summary.md` exists (research was required, so this must run)
- `reports/current/competitor-map.md` exists with at least 3 competitors at T1 or T5 trust
- `reports/current/language-opportunity-map.md` exists with ADD_NOW / ADD_NEXT_WAVE labels
- `reports/current/target-state.md` includes architecture recommendation cards with labels (CURRENT_RECOMMENDED etc.)
- Architecture recommendations carry `upstream_source` and `upstream_trust` fields
- A pack plan is present (`CLAUDE.md`, `.claude/` structure, commands, agents) even though the project is greenfield

## Must NOT include

- An architecture recommendation without an upstream source citation
- "Popular framework X is recommended" without trust-tiered evidence
- A release plan that assumes the store without checking Apple / Google / compliance gates
- Language recommendations without a language-opportunity-map
- A design system baseline that copies a competitor without transformation
- Assumptions about current best practice from memory when live research is required

## Validation criteria

- `correct_mode`: greenfield + CREATE
- `correct_output_profile`: GREENFIELD_BUILDER_PROFILE
- `live_research_triggered`: market-researcher ran and produced T1/T5 evidence
- `architecture_currency_applied`: recommendations carry currency labels
- `localization_strategy_activated`: language-opportunity-map exists
- `pack_plan_present`: even greenfield outputs a pack plan

## Regression signals

- Producing architecture recommendations without any upstream citation
- Skipping the market-researcher because "the category is well-known"
- Proposing an SDK version from memory without the currency check
- Emitting only a technical plan without product assumptions or release plan
