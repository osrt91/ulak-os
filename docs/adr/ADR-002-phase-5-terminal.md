# ADR-002 — Phase 5 as the Terminal Phase (Numbering A)

**Status**: Accepted · **Date**: 2026-04-20 · **Release**: v2.1.3

## Context

Before v2.1.3, `docs/runtime/program-phases.md` declared 9 phases (Phase 0 through Phase 8 with a conditional Phase 4.5). Various adapter docs, governance docs, and the director agent prompt referenced different phase counts:

- CLAUDE.md adapter claimed "Phase 0 → Phase 5"
- program-phases.md had Phases 0 through 8
- artefact-write-authorization.md listed Phase 6 (execution)
- toolchain-precheck.md referenced "Phase 7 (validate)"
- waves-pattern.md talked about "Phase 6 execution onward"

This numbering drift confused operators ("how many phases are there?") and made cross-referencing unreliable (does "Phase 5" mean pack generation or final verdict?).

## Decision

Adopt **Numbering A**: 6 named phases (0-5) plus one conditional interstitial (4.5).

- **Phase 0** — Environment lock
- **Phase 1** — Deep inventory
- **Phase 2** — Parallel specialist evidence
- **Phase 3** — Non-obvious findings (did-you-know)
- **Phase 4** — Synthesis
- **Phase 4.5** — Live probe (conditional-mandatory)
- **Phase 5** — Finalize & verdict (terminal, always runs)

The old Phases 5/6/7/8 (pack materialization, execution, validate, finalize) collapse into Phase 5 sub-sections:
- §5a — Pack materialization (profile-gated)
- §5b — Execution (permission-gated)
- §5c — Validation gates (always runs)
- §5d — Manager verdict (always runs)

## Alternatives considered

1. **Keep 9 phases** — rejected because the drift pain was real and the 9-phase count created false complexity (most runs only touch 5-6 of the 9)
2. **Rename conflicting phases with prefixes** (P4/P5-exec/P5-verdict) — rejected because adapter docs across vendors would break
3. **Number 0 through ∞ with auto-assigned IDs per profile** — rejected because operators need stable mental model

## Consequences

**Positive**:
- "Phase 5 = final verdict" is unambiguous across every adapter + doc
- Sub-section structure (§5a/§5b/§5c/§5d) captures conditional activities without polluting the phase count
- Cross-references in docs became 1-line mechanical updates (Phase 6 → Phase 5 §5b, Phase 7 → Phase 5 §5c)

**Negative**:
- Historical references in `docs/history/version-lineage.md` to "Phase 6/7/8" are now archaic (kept as hidden-core history per `docs/governance/surface-split.md`)
- Golden set files (`evals/golden/*.md`) that mention old phase numbers need a v2.2.x sweep (deferred to eval harness promotion)

**Migration**:
- `docs/runtime/program-phases.md` rewritten (canonical source)
- `docs/runtime/waves-pattern.md`, `toolchain-precheck.md`, `artefact-write-authorization.md` had cross-refs updated
- Director agent prompt updated to reference new sub-section IDs

## References

- `docs/runtime/program-phases.md` — canonical source of the 6-phase protocol
- `CHANGELOG.md §[2.1.3]` — W1.2 line item
- v2.1.3 self-audit findings FIND-AL-01 + FIND-AL-02 — the P0 blockers this ADR resolved
