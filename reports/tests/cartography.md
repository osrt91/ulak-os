# Cartography Report — pre-v1.0.0-public-GA

**Agent**: cartographer
**Date**: 2026-04-21
**Scope**: Full-repo cartography on Ulak OS at HEAD
**Verdict**: `ready-with-residual` — ship GA, fix CART-001 + CART-002 in GA commit; rest → v1.0.1

## 200-word summary

Ulak OS at HEAD is structurally coherent and largely ready for v1.0.0-public-GA. The import graph validates cleanly (0 cycles, 0 invalid refs). Counts match reality on load-bearing dimensions: 27 agents, 8 rule packs, 24 sector-pack sections (10 core kernel + 14 SP-NN IDs), 6 ADRs, 8 skills, 9 commands, 27 scaffolder templates. No dead scripts — every script has ≥ 2 inbound references. All 15 director-protocol artefacts carry ≥ 8 inbound references. Six residual risks: 3 broken FAQ links (CART-001, already fixed in pass 1 commit), "79 anti-pattern" drift vs actual 98/19 (CART-002), rule-collision-matrix stub on hot path (CART-003), empty `tests/` dir (CART-004), 3 near-orphans (CART-005), 2 non-imported governance stubs (CART-006).

## File inventory by surface

| Surface | Count |
|---|---|
| Core contract | 3 |
| Runtime rules (top-level) | 33 |
| Rule packs | 8 |
| Governance | 22 |
| Commands | 9 |
| Agents | 27 |
| Skills | 8 |
| Hooks (inline) | 4 |
| Sector packs | 24 H3 sections (14 SP-NN) |
| Anti-patterns | 98 bullets / 19 AP-NN |
| ADRs | 6 |
| Architecture | 5 |
| Showcase | 6 |
| Runbooks | 4 |
| Distribution | 4 |
| History | 4 |
| Examples | 7 |
| Community | 4 |
| Scripts | 13 (8 .sh + 5 .ps1) |
| CI workflows | 2 |
| Wrappers | 1 (bin/ulak) |
| Scaffolder templates | 27 |
| src/** TypeScript | 24 |
| Evals | 8 |
| tests/ | 0 (empty) |
| Plugin manifest | 4 |

## Findings

### CART-001 (P1) — FAQ.md 3 broken relative links
**Status**: FIXED in commit `e25396f` (pass 1)
- docs/FAQ.md:61 `./LICENSE` → `../LICENSE`
- docs/FAQ.md:65 `./CONTRIBUTING.md` → `../CONTRIBUTING.md`
- docs/FAQ.md:115 `./VERSIONING.md` → `../VERSIONING.md`

### CART-002 (P2) — FAQ "79 anti-pattern sweep" contradicts filesystem
Filesystem has 98 bulleted entries / 19 explicit AP-NN IDs. FAQ:9 must update.

### CART-003 (P3) — `rule-collision-matrix.md` 12-line stub on auto-loaded import path
`prompts/core/ulak-os-core-contract-2.0.0.md:39` imports it. Peer governance docs are 62-373 lines.

### CART-004 (P3) — `tests/` directory empty
0 files. Could confuse contributors (evals/ is the actual test surface).

### CART-005 (P3) — 3 near-orphans
- `docs/showcase/video-script.md` (1 inbound)
- `docs/adr/ADR-001-rule-packs-seventh-unit-type.md` (1 inbound)
- `docs/adr/ADR-002-phase-5-terminal.md` (1 inbound)

### CART-006 (P4) — 2 non-imported governance stubs
- `docs/governance/autonomy-pressure-layer.md` (10L, not in core contract)
- `docs/governance/hidden-maintainer-surface-template.md` (11L, not in core contract)

## Cross-reference integrity

**Clean surfaces (0 broken)**: architecture, showcase, runbooks, distribution, adr, README.md, README.en.md, CONTRIBUTING.md, CHANGELOG.md

## Dead code

All 13 scripts referenced ≥ 2 times. Hooks inline in `.claude/settings.json` — no external hook files. `tests/` exists but empty (dead surface, not dead code).

## Pack count verification

| Claim | Actual | Status |
|---|---|---|
| 24 sector packs (FAQ:9) | 24 H3 sections | PASS |
| 8 rule packs (FAQ:9) | 8 files | PASS |
| 27 agents (FAQ:9) | 27 files | PASS |
| 79 anti-patterns (FAQ:9) | 98 bullets / 19 AP-NN | **CONTRADICTED** |
| 27 templates (FAQ:9) | 27 .template files | PASS |
| 15 director artefacts | all ≥ 8 inbound refs | PASS |

## Signoff

`signoff_status: ready-with-residual` — import graph, artefact integrity, pack counts all green except FAQ:9 "79 anti-pattern" drift. CART-001 already landed; CART-002 is a 2-minute edit → should land in v1.0.0. Rest (CART-003/004/005/006) deferred to v1.0.1 patch.
