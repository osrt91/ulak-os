# Ulak OS Agent Instructions

> [Türkçe](AGENTS.md) | English

This repo is an operating system for auditing, restructuring, packaging, and producing controlled execution plans for large software projects.

## Reading order

### Core (read every session)
1. README.md
2. docs/adapters/universal-runtime-contract.md
3. docs/adapters/codex-cli.md
4. prompts/core/ulak-os-core-contract-2.0.0.md

### Runtime discipline (v2.1) — read deep when relevant
5. docs/runtime/router.md
6. docs/runtime/program-phases.md
7. docs/runtime/artefact-contract.md
8. docs/runtime/output-profiles.md
9. docs/runtime/context-budget.md
10. docs/runtime/active-variable-contract.md
11. docs/runtime/validation-result-schema.md
12. docs/runtime/universal-surface-inventory.md
13. docs/runtime/analysis-contexts.md
14. docs/runtime/roadmap-rule.md
15. docs/runtime/anti-patterns.md

### Operational motors (only when the task requires)
16. docs/runtime/toolchain-precheck.md
17. docs/runtime/intake-protocol.md
18. docs/runtime/architecture-currency.md
19. docs/runtime/localization-strategy.md
20. docs/runtime/turkish-normalization.md
21. docs/runtime/market-research-engine.md
22. docs/runtime/sector-packs.md

### Governance
23. docs/governance/evidence-trust-scoring.md
24. docs/governance/finding-schema.md
25. docs/governance/trust-model.md
26. docs/governance/surface-split.md
27. docs/governance/hook-governance.md
28. docs/governance/mcp-governance.md
29. docs/governance/memory-hygiene.md
30. docs/governance/prompt-supply-chain.md
31. docs/governance/plugin-skill-decision.md
32. docs/governance/rule-collision-matrix.md

### Run state
33. reports/current/* — current session artefacts (if any)

## Required behavior
- If user intent is clearly `komple`, `full`, `complete`, `end-to-end`, `from start`, `set up`, or `fix`, do not repeatedly open the scope menu.
- Execute the Phase 0 → Phase 5 protocol in a single pass; write an artefact for every phase.
- Inventory must not be shallow — file:line citations on every claim.
- In Phase 2, dispatch all relevant specialists in a single parallel batch.
- Phase 3 (did-you-know) is mandatory — without non-obvious findings the run is not done.
- Evaluate customer, admin, and public API surfaces separately.
- Do not conflate quick wins with strategic migrations.
- Every finding must conform to `docs/governance/finding-schema.md` and carry an `docs/governance/evidence-trust-scoring.md` tier.
- Do not consider work done without writing validation and residual risk.

## Required artefacts (full chain — v2.1.0 aligned)

### Phase 0 — Environment lock
- reports/current/runtime-manifest.md
- reports/current/assumptions.md

### Phase 1 — Deep inventory
- reports/current/intake.md
- reports/current/inventory.md

### Phase 2 — Parallel specialist evidence
- reports/current/evidence-register.md
- reports/current/deep-scan-report.md
- reports/current/research-notes.md (if live research is required)

### Phase 3 — Surprise layer (MANDATORY)
- reports/current/did-you-know.md

### Phase 4 — Synthesis
- reports/current/analysis-findings.md
- reports/current/target-state.md
- reports/current/execution-roadmap.md
- reports/current/validation-plan.md
- reports/current/pack-gap-register.md

### Phase 5 — Final verdict
- reports/current/manager-verdict.md
- reports/current/validation-result.yaml (or block inside manager-verdict.md)

## Adapter note
This repo carries the shared core for Claude, Codex/Copilot, and Gemini. Therefore, where possible, stay aligned with the intent in `CLAUDE.md` and `GEMINI.md`.
