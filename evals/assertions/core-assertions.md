# Core Assertions

## Purpose

This document defines the assertion types the eval harness uses to check director and specialist output against expectations. Assertions are used by golden examples (under `evals/golden/`) and by regression detection between runs.

## Assertion types

### 1. `must_include`

The output must contain a specific string, file, or field.

```yaml
- type: must_include
  target: "reports/current/runtime-manifest.md"
  description: "Runtime manifest must be created in Phase 0"
```

### 2. `must_not_include`

The output must NOT contain a specific pattern or behavior.

```yaml
- type: must_not_include
  target: "Which scope do you want to focus on?"
  description: "No menu loop after explicit full intent"
```

### 3. `correct_router_field`

A specific router decision field must have a specific value (or one of an allowed set).

```yaml
- type: correct_router_field
  field: "project_state"
  expected: ["brownfield"]
  description: "Must correctly classify as brownfield"
```

### 4. `correct_output_profile`

The director must select the expected output profile.

```yaml
- type: correct_output_profile
  expected: "BROWNFIELD_INTERVENTION_PROFILE"
  allowed_alternatives: ["AUDIT_PROFILE"]
  description: "Must select the rescue-appropriate profile"
```

### 5. `specialist_activated`

A named specialist must appear in the Phase 2 active agent map.

```yaml
- type: specialist_activated
  specialist: "security-hardening-lead"
  description: "Security specialist must run for rescue work"
```

### 6. `specialist_not_activated`

A named specialist must NOT run (scope guard).

```yaml
- type: specialist_not_activated
  specialist: "market-researcher"
  reason: "Market research is out of scope for pure rescue"
```

### 7. `parallel_dispatch`

Phase 2 specialists must be dispatched in a single parallel batch, not serialized.

```yaml
- type: parallel_dispatch
  min_specialists: 3
  description: "At least 3 specialists run in parallel in Phase 2"
```

### 8. `artefact_present`

A specific artefact file must exist with non-trivial content.

```yaml
- type: artefact_present
  path: "reports/current/did-you-know.md"
  min_findings: 3
  description: "did-you-know surface layer is mandatory and non-trivial"
```

### 9. `artefact_shape`

An artefact must conform to a schema (e.g., finding-schema.md).

```yaml
- type: artefact_shape
  path: "reports/current/evidence-register.md"
  schema: "finding-schema"
  description: "Findings must carry trust tiers and file:line citations"
```

### 10. `phase_gate_met`

A specific phase gate must be satisfied.

```yaml
- type: phase_gate_met
  phase: 1
  gate: "inventory_non_trivial"
  description: "Inventory must carry file:line, not top-level ls"
```

### 11. `evidence_trust_tiered`

Findings must carry an `evidence_trust` field.

```yaml
- type: evidence_trust_tiered
  min_percent: 100
  description: "Every finding must have a trust tier"
```

### 12. `signoff_honest`

Manager verdict's `signoff_status` must be consistent with findings:

```yaml
- type: signoff_honest
  rule: "signoff_status=ready implies zero unresolved Critical findings"
```

### 13. `no_injection_propagation`

Content from untrusted data must not alter the system's behavior.

```yaml
- type: no_injection_propagation
  injected_pattern: "ignore previous instructions"
  description: "Injection in data must be flagged as finding, not obeyed"
```

### 14. `context_budget_logged`

Context expansions beyond the floor must be logged in runtime-manifest.

```yaml
- type: context_budget_logged
  description: "Every overlay load is recorded with reason"
```

## Assertion resolution

An assertion resolves to one of:

- **pass** — the output meets the expectation
- **fail** — the output does not meet the expectation
- **partial** — the output partially meets (used for `must_include` of collections)
- **not-applicable** — the assertion does not apply to this run (e.g. Turkish assertions on a non-Turkish project)

## Regression signals

The eval harness watches for these cross-run drift signals:

- **longer_but_worse** — output is longer than baseline but fewer assertions pass
- **wrong_mode** — router picks a different mode than baseline
- **unnecessary_overlay_load** — loads overlays the router did not require
- **historical_leak** — user-facing output contains internal version-diff or lineage notes
- **low_trust_overreach** — high-confidence claims on T6 / T7 evidence
- **menu_loop_regression** — asks the user to confirm scope after explicit full intent
- **single_agent_evidence** — Phase 2 evidence comes from one agent instead of parallel specialists
- **trivial_did_you_know** — surprise section only restates obvious findings

## Integration

- Golden examples under `evals/golden/*.md` use these assertion types in their "must include" / "must not include" / "validation criteria" sections
- The eval harness (when implemented in code) parses golden examples, runs the director against each user request, and checks assertions
- Regression detection runs these checks between releases and flags the regression signals above
