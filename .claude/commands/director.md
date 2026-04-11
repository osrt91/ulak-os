---
description: Run the Autonomous Program Director. Use for complete, end-to-end, rescue, greenfield, brownfield, or "komple" requests. The director auto-routes, runs deep inventory plus parallel specialist scans, surfaces non-obvious findings, and finishes with one manager verdict. Shallow inventory and single-agent evidence are rejected.
---

Use the autonomous-program-director subagent and this pack's runtime docs.

Do not ask repeating scope menus when intent is clear.

The director must run the full depth protocol before producing any verdict. Shallow inventory (folder listing) and single-agent evidence are not acceptable. Each phase is only "done" if its artefact file exists under `reports/current/` AND is non-trivial.

## Mandatory artefact chain

**Phase 0 — Environment lock**
- reports/current/runtime-manifest.md
- reports/current/assumptions.md

**Phase 1 — Deep inventory** (file paths + line ranges, not folder dumps)
- reports/current/inventory.md

**Phase 2 — Parallel specialist deep-scan** (dispatch all relevant specialists in a single parallel batch)
- reports/current/evidence-register.md
- reports/current/deep-scan-report.md

**Phase 3 — Non-obvious findings (MANDATORY surprise layer)**
- reports/current/did-you-know.md

**Phase 4 — Synthesis**
- reports/current/analysis-findings.md
- reports/current/target-state.md
- reports/current/execution-roadmap.md
- reports/current/validation-plan.md
- reports/current/pack-gap-register.md

**Phase 5 — Final verdict**
- reports/current/manager-verdict.md

## Schemas enforced

- Router decision YAML — `docs/runtime/router.md`
- Active variable contract — `docs/runtime/active-variable-contract.md`
- Output profile (7 types) — `docs/runtime/output-profiles.md`
- Context budget discipline — `docs/runtime/context-budget.md`
- Finding schema (all claims) — `docs/governance/finding-schema.md`
- Evidence trust scoring (T1-T7) — `docs/governance/evidence-trust-scoring.md`
- Trust model (data vs instructions) — `docs/governance/trust-model.md`
- Validation result schema — `docs/runtime/validation-result-schema.md`

## Hard rules

- Inventory that is a folder dump is rejected and must be re-run.
- Evidence from a single generalist agent is rejected; Phase 2 must dispatch multiple specialists in parallel.
- did-you-know.md cannot be empty or only restate obvious issues.
- Manager verdict cannot claim completion if any mandatory artefact is missing or trivial.
- No claim without a file:line or URL citation plus a trust tier.
- No overlay or sector pack load without an explicit router decision.
- No `signoff_status: ready` with unresolved Critical findings.

ARGUMENTS:
$ARGUMENTS
