# Validation Result Schema

## Why this exists

"Done" is a claim that must be backed by evidence. A run that ends with "looks good, all set" and no structured validation result is a failure mode — the user can't tell what was verified vs. what was hoped. The validation result schema is the structured YAML the director writes at Phase 5 (manager-verdict) that makes "done" falsifiable.

## The schema

Every manager-verdict must carry or link to this block (typically in `reports/current/validation-result.yaml` or as a YAML section inside `manager-verdict.md`):

```yaml
validation:
  # ----- engineering gates -----
  build: pass|fail|not-run|not-applicable
  lint: pass|fail|not-run|not-applicable
  typecheck: pass|fail|not-run|not-applicable

  # ----- test gates -----
  tests:
    unit: pass|fail|partial|not-run|not-applicable
    integration: pass|fail|partial|not-run|not-applicable
    e2e: pass|fail|partial|not-run|not-applicable
    contract: pass|fail|partial|not-run|not-applicable
    visual_regression: pass|fail|partial|not-run|not-applicable
    accessibility: pass|fail|partial|not-run|not-applicable
    security_regression: pass|fail|partial|not-run|not-applicable
    localization: pass|fail|partial|not-run|not-applicable
    release_checks: pass|fail|partial|not-run|not-applicable
    prompt_regression: pass|fail|partial|not-run|not-applicable

  # ----- surface checks -----
  surfaces:
    broken_links: pass|fail|partial|not-run|not-applicable
    broken_routes: pass|fail|partial|not-run|not-applicable
    broken_endpoints: pass|fail|partial|not-run|not-applicable
    deep_links: pass|fail|partial|not-run|not-applicable
    store_listing_urls: pass|fail|partial|not-run|not-applicable

  # ----- risk state -----
  unresolved_risks: []                    # list of FIND-* ids still open
  residual_risks:                         # things known to remain after this run
    - id: ""
      description: ""
      severity: Critical|High|Medium|Low
      mitigation: ""

  # ----- rollback -----
  rollback_ready: yes|no|partial
  rollback_notes: ""

  # ----- evidence for the gates -----
  evidence:
    - gate: ""                            # e.g. "lint"
      command: ""                         # e.g. "pnpm lint"
      output_reference: ""                # file path or log id
      trust: T1|T2|T3|T4|T5|T6|T7

  # ----- signoff -----
  signoff_status: blocked|conditional|ready
  signoff_reason: ""
```

## Status definitions

- **pass** — the gate ran and passed with T2 or T3 evidence (direct command output or telemetry)
- **fail** — the gate ran and failed; the failure is in `evidence`
- **partial** — the gate ran but not across the full scope (e.g., unit tests ran for frontend but not backend)
- **not-run** — the gate was applicable but was not executed; must be recorded as a residual risk if it would have blocked signoff
- **not-applicable** — the gate does not apply to this project (e.g., `e2e` for a CLI tool)

## Hard rules

- **Never mark a gate `pass` without evidence.** If you didn't actually run the command, it's `not-run`, not `pass`.
- **`not-run` is not a free pass.** If the gate was applicable and skipped, it enters residual risks automatically.
- **`partial` requires scope documentation.** Which part ran, which part didn't, and why.
- **`signoff_status: ready` requires all applicable engineering gates at `pass` and zero unresolved Critical risks.**
- **`signoff_status: conditional` is allowed only if the conditions are explicit, reversible, and documented in `signoff_reason`.**
- **`signoff_status: blocked` means the current run ends here. Do not claim "done" on a blocked signoff.**

## Integration with the director

The autonomous-program-director's Phase 5 (manager-verdict) must:

1. Emit this schema either as `validation-result.yaml` or as a block inside `manager-verdict.md`
2. Cross-reference each gate's evidence with the evidence trust scoring (T1-T7)
3. Compute `signoff_status` from the gates — do not accept user override unless an explicit `conditional` signoff reason is given
4. Record any `not-run` gate as a residual risk entry

## Integration with did-you-know

If a gate surfaces an unexpected failure (something the user didn't ask about), that failure also becomes a did-you-know entry for the next run. The validation result and the did-you-know layer share the same finding-schema.md format.

## Related

- `docs/governance/finding-schema.md` — used for residual risk entries
- `docs/governance/evidence-trust-scoring.md` — the trust field applied to gate evidence
- `docs/runtime/output-profiles.md` — which profiles require which gates
