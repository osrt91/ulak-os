# Research Notes — Ulak OS v2.1.3 audit

**Date**: 2026-04-18
**Run id**: director-komple-ulakos-self-audit
**Status**: not-required-but-non-empty

## Scope decision

Router decision `live_probe_required: false` and `active_sector_packs: []` — this audit does not require market research, competitor scan, or architecture-currency probing. All evidence is file-local.

The only memory-sourced claims in the audit are flagged explicitly as T3:
- G-02 (AI-provider-allowlist) — relies on memory of ajanscan's Gemini-only constraint
- G-03 (pattern-import-ledger) — relies on memory of TrendOfTrend → ajanscan pattern inheritance
- R-05 (cron-poll deploy resilience) — classified T2 in the original extraction, flagged for verification
- AG-EXT-01 (design-system Master+override) — design judgment, not empirical superiority claim

## Market signals

n/a (Ulak OS is a meta-system, not a market product — no competitor scan in this run)

## Architecture currency

Covered indirectly by ajanscan R-03 (audit-scoring-framework, 14 dimensions). The 14-dimension framework when applied to Ulak OS would score:
- Plugin System: ~80/100 (6 units + rule-pack coming in v2.1.3 = 7)
- Documentation: ~75/100 (rich but with coherence defects — FIND-AL-01)
- Type Safety: n/a (prompt pack, not application code)
- Observability: ~40/100 (logging hooks only; no metrics, no traces)
- CI/CD: ~60/100 (schema + import validators exist; schema is parse-only per DY-02)
- Dependencies: ~70/100 (small, purposeful; no dependabot per FIND-INF-03)

These scores are T3 (judgment) — flagged for formal v2.2 self-scoring pass.

## Language opportunities

Captured in FIND-LOC-01 (output_language field missing in output-profiles). Ulak ships Turkish-primary defaults with English parity (README.en.md, CLAUDE.en.md pairs) but:
- `docs/i18n/en/` and `docs/i18n/tr/` are empty (FIND-AL-05)
- Output language field not part of active-variable-contract

## Open questions

Six open questions from ajanscan Phase A are resolved in `target-state.md` §Open-question decisions. No new open questions surfaced in Phase 2/3.

Residual research-class questions:
- Should Ulak OS self-apply the 14-dimension audit and publish scores in docs/distribution/? (candidate v2.2 item)
- Does `docs/distribution/release-parity-policy.md` already govern vendor parity (DY-03) or does a new policy slot need creation? (R2 residual risk)
- Is TrendOfTrend inheritance claim (G-03) verifiable without scanning TrendOfTrend itself? (R4 residual risk)
