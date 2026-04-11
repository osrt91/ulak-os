# Golden Prompt 01 — Full Program (Komple)

## User request

> "Komple. Projeye ortadan gir, her şeyi tara, eksikleri bul, gerekli ajanları aç, markdown artefaktları yaz ve sonunda tek verdict ver."

## Expected router decision

```yaml
router:
  task_type: intervention
  active_mode: full-program
  project_state: brownfield
  intervention_mode: RESCUE
  scope_level: multi-surface-full-system
  live_research_need: helpful
  artefact_program: full
  output_type: markdown-artifact-set
  output_profile: BROWNFIELD_INTERVENTION_PROFILE
  required_overlays: []
  required_sector_packs: []
  validation_depth: standard
  max_parallel_agents: 6
  rationale: "Intent is explicit 'full / komple'. No menu loop; router completes from phrasing alone."
```

## Expected active agent map

All phase-2 specialists run in parallel (one batch):

- cartographer
- architecture-lead
- backend-api-architect
- data-database-governor
- design-system-architect
- educational-ux-specialist (if education domain detected)
- frontend-ios-flutter-director (if mobile detected)
- infra-release-sre
- localization-i18n-lead
- privacy-compliance-counsel
- qa-validation-commander
- red-team-challenger
- release-readiness-auditor
- security-hardening-lead
- seo-aso-growth-strategist
- support-ops-orchestrator

## Must include (assertions)

- `reports/current/runtime-manifest.md` exists with the router YAML committed
- `reports/current/assumptions.md` exists with every assumption labeled
- `reports/current/inventory.md` exists and contains file:line citations (not a folder dump)
- `reports/current/evidence-register.md` has findings from ≥5 specialists
- `reports/current/deep-scan-report.md` ranks findings by severity + priority
- `reports/current/did-you-know.md` exists AND is non-trivial (contains surprise findings)
- `reports/current/analysis-findings.md` uses finding-schema.md format
- `reports/current/target-state.md` exists
- `reports/current/execution-roadmap.md` has tagged items (quick-win | foundational | strategic)
- `reports/current/validation-plan.md` exists
- `reports/current/pack-gap-register.md` exists
- `reports/current/manager-verdict.md` exists with phase status, top-3 did-you-know highlights, residual risks
- `validation-result.yaml` or equivalent block is present
- The director returns exactly ONE manager verdict (not multiple)

## Must NOT include

- A menu asking the user to confirm scope after the word "komple"
- An inventory that is only a top-level `ls` output
- Evidence from a single generalist agent (must be parallel specialists)
- An empty or trivial did-you-know.md
- A verdict that claims "done" without a validation-result
- Repeating the Phase 0 router decision after Phase 1 has started
- Historical version-lineage notes leaking into the user-facing output

## Validation criteria

- `correct_mode`: brownfield + RESCUE (or similar — as long as brownfield is picked)
- `correct_output_profile`: BROWNFIELD_INTERVENTION_PROFILE (or AUDIT_PROFILE as a valid alternative)
- `parallel_dispatch_confirmed`: Phase 2 specialist calls must be in a single parallel batch
- `depth_gate_passed`: inventory carries file:line citations
- `did_you_know_non_trivial`: surprise section has ≥3 non-obvious findings
- `single_verdict`: exactly one manager-verdict.md

## Regression signals

- "Which scope do you want to focus on?" (menu loop after explicit full intent)
- "I'll start with a high-level inventory" followed by a top-level directory listing
- "Security checks not run — you may want to run them separately" (specialist not dispatched)
- "Everything looks good" without validation evidence
