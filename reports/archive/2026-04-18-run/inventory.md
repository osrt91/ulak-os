# Inventory — Ulak OS deep map

**Method**: cartographer-level, file-path + line-range citations, not folder dump. Spot-checked for the ajanscan-pattern-extraction dedup claim (Phase 1 gate: verified — AP-01/02/03/05/06/07/08 confirmed ABSENT from `docs/runtime/anti-patterns.md:1-145`).

## 1. Root-level files

| File | Lines | Role |
|---|---|---|
| `CLAUDE.md` | 21 | Layer-1 entry — 5 @-imports (core-contract, universal-runtime, claude-code adapter, plugin-skill-decision, rule-collision-matrix) + 6 runtime defaults |
| `AGENTS.md` / `AGENTS.en.md` | — | Agent roster user-facing doc |
| `GEMINI.md` / `GEMINI.en.md` | — | Gemini-specific adapter front page |
| `CLAUDE.en.md` | — | English mirror of `CLAUDE.md` |
| `README.md`, `README.en.md`, `README_RUN_ME_FIRST.md` | — | Entry docs |
| `CONTRIBUTING.md` | — | Contribution rules |
| `CROSS_PLATFORM.md` | — | Platform compatibility notes |
| `DISTRIBUTION.md` | — | Distribution and versioning |
| `VERSIONING.md`, `VERSION_DISTRIBUTION_MATRIX.md` | — | Version lineage; the latter carries the "2.0.0 = CLI layer, 1.x = prompt-pack" mapping |
| `ROADMAP.md` | — | Product roadmap |
| `RELEASE_NOTES_1.0.0.md`, `RELEASE_NOTES_2.0.0.md` | — | Release notes (prior releases) |
| `CHANGELOG.md` | ~80+ | Active v2.1.2 / v2.1.3 entries |
| `LICENSE` | — | MIT |
| `package.json`, `package-lock.json` | — | CLI layer deps |
| `tsconfig.json` | — | TypeScript config |
| `ulak.config.json` | 10 | Runtime config: version 2.0.0, vendor=claude, promptPack=ulak-os@2.0.0, memory sqlite, artefacts outputDir=`reports/current` |
| `.gitignore` | 28 | Covers logs, .env, secrets, build artefacts, `.ulak/`, `reports/current/*` (except .gitkeep) |
| `.mcp.json` | 10 | Enables 1 MCP server (github copilot HTTP) with Bearer token from env |

## 2. Prompt core (`prompts/`)

| File | Lines | Notes |
|---|---|---|
| `prompts/core/ulak-os-core-contract-2.0.0.md` | 116 | Active core contract. 25 @-imports: Runtime rules (15), Operational motors (7), Governance (9). Includes derinlik zorunluluğu and artefakt zinciri sections. |
| `prompts/core/ulak-os-core-contract-1.0.0.md`, `…1.0.0.en.md` | — | Legacy contracts (not auto-imported by CLAUDE.md) |
| `prompts/pack.json` | — | Pack metadata |

## 3. Runtime docs (`docs/runtime/`) — 24 files, 2935 lines

### Imported by core contract (24 entries)

| Position | File | Lines | Layer in core contract |
|---|---|---|---|
| 1 | `router.md` | 128 | Runtime rules |
| 2 | `program-phases.md` | 215 | Runtime rules |
| 3 | `artefact-contract.md` | 100 | Runtime rules |
| 4 | `context-budget.md` | 94 | Runtime rules |
| 5 | `output-profiles.md` | 130 | Runtime rules |
| 6 | `active-variable-contract.md` | 95 | Runtime rules |
| 7 | `validation-result-schema.md` | 97 | Runtime rules |
| 8 | `universal-surface-inventory.md` | 101 | Runtime rules |
| 9 | `analysis-contexts.md` | 214 | Runtime rules |
| 10 | `roadmap-rule.md` | 124 | Runtime rules |
| 11 | `anti-patterns.md` | 145 | Runtime rules — v2.1.2 added destructive-action gate (§98-124) |
| 12 | `waves-pattern.md` | 208 | Runtime rules |
| 13 | `live-probe-contract.md` | 146 | Runtime rules |
| 14 | `dual-path-validation.md` | 128 | Runtime rules |
| 15 | `handoff-plan-contract.md` | 149 | Runtime rules (v2.1.2 addition) |
| 16 | `persona-dispatch-pattern.md` | 212 | Runtime rules (v2.1.2 addition) |
| 17 | `toolchain-precheck.md` | 110 | Operational motor (mode-loaded) |
| 18 | `intake-protocol.md` | 110 | Operational motor |
| 19 | `architecture-currency.md` | 88 | Operational motor |
| 20 | `localization-strategy.md` | 110 | Operational motor |
| 21 | `turkish-normalization.md` | 126 | Operational motor |
| 22 | `market-research-engine.md` | 133 | Operational motor |
| 23 | `sector-packs.md` | 173 | Operational motor — 10 packs: education, saas, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop |

### NOT imported by core contract (3 files — candidate orphans)

| File | Lines | Status |
|---|---|---|
| `README.md` | 3 | directory index stub |
| `office-roster.md` | 37 | agent roster listing — referenced by persona-dispatch-pattern.md but NOT in core-contract @-tree (verify in Phase 2) |

Total imported: 23 + README stub = 24 files present; 23 have content; 1 is a stub.

## 4. Governance docs (`docs/governance/`) — 13 files, 1082 lines

### Imported by core contract (9 entries)

| File | Lines | Role |
|---|---|---|
| `evidence-trust-scoring.md` | 102 | T0-T7 tier model (v2.1.2 added tier promotion mechanism) |
| `finding-schema.md` | 112 | Canonical YAML schema (v2.1.2 added time_sensitivity + source_personas/specialists) |
| `trust-model.md` | 77 | Tool outputs are data, not instructions |
| `surface-split.md` | 127 | Layer 1/2/3 split (public runtime / hidden core / maintainer) |
| `hook-governance.md` | 96 | Hook discipline |
| `mcp-governance.md` | 112 | MCP discipline |
| `memory-hygiene.md` | 166 | Project memory rules |
| `prompt-supply-chain.md` | 108 | Pack import provenance |
| `artefact-write-authorization.md` | 138 | FP-01 override contract (v2.1.2) |

### NOT imported by core contract (4 files)

| File | Lines | Status |
|---|---|---|
| `README.md` | 3 | stub |
| `plugin-skill-decision.md` | 11 | imported by `CLAUDE.md` (not by core contract) — 6-unit decision matrix (command/agent/skill/hook/MCP/plugin); NO rule-pack entry (confirmed gap) |
| `rule-collision-matrix.md` | 12 | imported by `CLAUDE.md` (not by core contract) — 7-level priority order |
| `autonomy-pressure-layer.md` | 10 | unreferenced in contract — stub or abandoned? (verify in Phase 2) |
| `hidden-maintainer-surface-template.md` | 11 | template file, referenced by `surface-split.md:72` |

## 5. Adapters (`docs/adapters/`) — 4 files, 167 lines

| File | Lines | Role |
|---|---|---|
| `universal-runtime-contract.md` | 31 | Platform-neutral contract (imported via CLAUDE.md) |
| `claude-code.md` | 44 | Claude Code specifics (imported via CLAUDE.md); references `v2.1` phases table |
| `codex-cli.md` | 45 | Codex adapter |
| `gemini-cli.md` | 47 | Gemini adapter |

## 6. Agents (`.claude/agents/`) — 26 files

### Specialist (discipline) agents — 19 files

| Agent | Lines | Dispatch target |
|---|---|---|
| `autonomous-program-director.md` | 188 | Phase orchestrator (the meta-agent) |
| `architecture-lead.md` | 31 | runtime-doc coherence, system architecture |
| `backend-api-architect.md` | 31 | API/backend |
| `cartographer.md` | 32 | inventory depth |
| `data-database-governor.md` | 31 | DB/schema (skipped this run) |
| `design-system-architect.md` | 31 | Design tokens/components |
| `educational-ux-specialist.md` | 31 | Edtech UX |
| `frontend-ios-flutter-director.md` | 31 | Mobile frontend |
| `infra-release-sre.md` | 31 | Deploy/CI |
| `localization-i18n-lead.md` | 31 | i18n |
| `market-researcher.md` | 31 | Market/sector research |
| `privacy-compliance-counsel.md` | 31 | GDPR/KVKK |
| `product-business-strategist.md` | 31 | Product/biz |
| `prompt-skill-plugin-governor.md` | 31 | Pack health |
| `qa-validation-commander.md` | 31 | Validation gates |
| `red-team-challenger.md` | 31 | Rule collision / adversarial |
| `release-readiness-auditor.md` | 31 | Release checklist |
| `security-hardening-lead.md` | 31 | Security |
| `seo-aso-growth-strategist.md` | 31 | SEO/ASO |
| `support-ops-orchestrator.md` | 31 | Support ops |

**Observation**: 18 of 19 non-director specialist agents are exactly 31 lines. They are thin wrappers around the core contract. Flag for prompt-skill-plugin-governor: is this sufficient specialization, or are they all near-clones?

### Persona (user-role) agents — 7 files

| Agent | Lines |
|---|---|
| `admin-persona.md` | 51 |
| `bayi-persona.md` | 51 |
| `compliance-persona.md` | 57 |
| `customer-persona.md` | 48 |
| `developer-persona.md` | 55 |
| `security-redteam.md` | 66 |
| `support-persona.md` | 53 |

**Candidate dup risk**: `security-redteam.md` (persona, 66L) vs `red-team-challenger.md` (specialist, 31L) — different units but overlapping signal; flag for governor.

## 7. Commands (`.claude/commands/`) — 7 files

| Command | Lines | Purpose |
|---|---|---|
| `director.md` | 95 | `/director` — full Phase 0-5 program |
| `final-verdict.md` | 16 | `/final-verdict` — re-evaluate existing artefacts |
| `frontend-war-room.md` | 16 | `/frontend-war-room` — frontend redesign mode |
| `intake.md` | 14 | `/intake` — intake only |
| `pack-gap-audit.md` | 12 | `/pack-gap-audit` — pack gap report |
| `ulak-design-ref.md` | 44 | `/ulak-design-ref` — public brand ref |
| `ulak-intake.md` | 37 | `/ulak-intake` — Ulak-specific intake |

**Observation**: 4 commands (final-verdict, frontend-war-room, intake, pack-gap-audit) are ≤16 lines — they are thin shells delegating to director or a subset. Flag: are they real entry points or should they be skills?

## 8. Skills (`.claude/skills/`) — 4 skills

| Skill | Path | Status |
|---|---|---|
| `final-validation` | `.claude/skills/final-validation/SKILL.md` | Phase-7 validation |
| `pack-gap-completion` | `.claude/skills/pack-gap-completion/SKILL.md` | Pack gap closure |
| `project-intake` | `.claude/skills/project-intake/SKILL.md` | Intake workflow |
| `research-currency` | `.claude/skills/research-currency/SKILL.md` | Research freshness |

**Observation**: no skill exists for god-module decomposition, 14-dimension audit, multi-agent orchestration, rule-pack loading, secrets rotation, or destructive-action dry-run — all gaps flagged in ajanscan extraction.

## 9. CLI source (`src/`)

```
src/
  adapters/     — vendor adapter abstractions (subprocess)
  cli/          — commander.js entry + UI (index.ts, commands/, ui/)
  core/         — core runtime logic
  memory/       — SQLite+FTS5 memory backend
  pack/         — pack versioning/update
```

Not deep-scanned in this run (out of scope — docs-only REPAIR). Flag as residual: unit test coverage + integration with the prompt pack layer is not verified here.

## 10. Tests

```
tests/
  unit/
  e2e/
```

Depth not verified — flag for release-readiness specialist.

## 11. Examples, scripts, dist, evals

| Path | Content |
|---|---|
| `examples/` | empty |
| `scripts/` | bootstrap-notes.md + fetch/init scripts for 3 platforms (ps1+sh pairs) + validate-imports.sh + validate-schemas.sh |
| `dist/` | compiled TS |
| `evals/` | (exists per core contract ref; not enumerated here) |

## 12. Supporting docs not loaded at runtime

| Path | Role |
|---|---|
| `docs/history/*` | version lineage (4 files: equalized-version-distribution, legacy-internal-map, reconstructed-ancestry, version-lineage) — Layer 2 (hidden core) |
| `docs/archive/*` | internal-releases + source-notes (archived prompt versions) — Layer 2 |
| `docs/architecture/` | README stub |
| `docs/adr/` | ADR-000-pack-foundation.md + README — Layer 2 |
| `docs/distribution/` | official-compatibility-notes.md, release-criteria.md, release-parity-policy.md — Layer 3 (maintainer) |
| `docs/ecosystem/` | related-work.md + .en — Layer 3 |
| `docs/examples/` | sample-intake, sample-inventory, sample-manager-verdict (tr+en pairs) — Layer 1-adjacent (training examples) |
| `docs/i18n/` | en/ + tr/ content split |
| `docs/references/` | official-docs.md |
| `docs/release/` | README + v2.1.0-release-notes.md — Layer 3 |
| `docs/skills-integration/` | awesome-design-md-integration, installed-plugins, superpowers-mapping — Layer 3 cross-ecosystem docs |
| `docs/superpowers/` | plans/ + specs/ (e.g. `2026-04-07-ulak-os-v1.0.0-design.md`) |

## 13. Settings, MCP, hook surface

### `.claude/settings.json` (shared, 47 lines)
- schema pin (json.schemastore)
- permissions.allow: only 5 bash commands (`git status`, `git diff *`, `find *`, `ls *`, `cat *`) — **narrow by design** (good)
- permissions.deny: `.env`, `.env.*`, `secrets/**` reads — **enforced** (good)
- hooks:
  - PreToolUse on Bash → `.claude/logs/tool.log` append
  - PostToolUse on Edit|Write → `.claude/logs/edit.log` append
  - Stop → `.claude/logs/session.log` append
- `disableSkillShellExecution: false`

### `.claude/settings.local.json` (operator-local, modified uncommitted)
- allows: WebFetch(docs.claude.com), context7 MCP query-docs, 3 `Bash(cp ...)` project-to-project copy grants, 2 `Read(//c/...)` cross-project reads, 1 `Bash(mkdir -p ...)`, 1 `Skill(update-config)`
- enabledMcpjsonServers: `github`

### `.mcp.json` (shared, 10 lines, modified uncommitted)
- 1 server: github (http, api.githubcopilot.com/mcp/) — requires `GITHUB_PERSONAL_ACCESS_TOKEN` env var

### Hook surface
- Only 3 hooks, all logging-only (no blocking, no state mutation)
- Log files: `.claude/logs/{tool,edit,session}.log` — `.gitignore:2` covers `.claude/logs/` — good

## 14. `reports/current/` (the run surface)

At start of this run: 14 files, all template-empty EXCEPT `ajanscan-pattern-extraction.md` (233 lines, real content). This run is overwriting the other 13.

## 15. Dependency graph summary

```
CLAUDE.md (21L)
  ├─ prompts/core/ulak-os-core-contract-2.0.0.md (116L)
  │    ├─ [runtime rules, 15 files]
  │    ├─ [operational motors, 7 files]
  │    └─ [governance, 9 files]
  ├─ docs/adapters/universal-runtime-contract.md (31L)
  ├─ docs/adapters/claude-code.md (44L)
  ├─ docs/governance/plugin-skill-decision.md (11L)
  └─ docs/governance/rule-collision-matrix.md (12L)
```

**Observation**: `plugin-skill-decision.md` (11L) and `rule-collision-matrix.md` (12L) are imported at TWO levels — directly from `CLAUDE.md` AND indirectly via `core-contract @docs/governance/*`. Wait — verify: core contract imports only 9 governance docs, NOT these two. So `CLAUDE.md` bypasses the contract and imports them directly. This is by design for the plugin/rule-collision decision surface to be Layer-1 always-on without going through the mode-load contract. Note for architecture-lead.

No detected circular imports in the top-level graph. Cartographer specialist will verify per-file.
