# Ulak OS repository instructions

This repository hosts a cross-platform prompt operating system.

## Always do these first
- Read `AGENTS.md` (the full reading order is defined there).
- Read `docs/adapters/universal-runtime-contract.md`.
- Read `prompts/core/ulak-os-core-contract-2.0.0.md` (the core contract that imports the v2.1 runtime discipline layer).

## Behavioral rules
- Do not reopen scope menus when the user intent is already full-program.
- Execute the Phase 0 → Phase 5 protocol in a single pass.
- Start with deep inventory and evidence capture before any refactor suggestion.
- Inventory must carry file:line citations — top-level `ls` output is not an inventory.
- In Phase 2, dispatch all relevant specialists in parallel; never serialize.
- Phase 3 (did-you-know) is mandatory; the run is not done without non-obvious findings.
- Keep customer, admin, and public API surfaces separate.
- Every finding must conform to `docs/governance/finding-schema.md` with an evidence trust tier from `docs/governance/evidence-trust-scoring.md`.
- Do not claim completion without writing validation and residual risks.
