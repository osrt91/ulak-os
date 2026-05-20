# Pack Gap Register — Ulak OS v2.1.3

**Date**: 2026-04-18
**Run id**: director-komple-ulakos-self-audit
**Source**: merged from ajanscan-pattern-extraction.md Bucket 2/3/4/5/6/7 + Phase 2 FIND-PG-* + Phase 3 DY-* discoveries
**Owner**: prompt-skill-plugin-governor (Phase 4 author)

Schema: each gap is a reusable unit recommended for the pack. Unit types per `docs/governance/plugin-skill-decision.md` (7 types after v2.1.3 rule-pack addition): command, agent, skill, hook, MCP, plugin, **rule-pack**.

## Missing reusable units (grouped by type)

### 1. Rule-packs (NEW unit type — 4 starter packs)

| ID | Path | Purpose | Trust | Owner |
|---|---|---|---|---|
| PG-RP-01 | `docs/runtime/rule-packs/typescript-nextjs.md` | Always-on TypeScript + Next.js guardrails (<500B): strict mode, no `any`, no `console.log`, Server Components default, `next/image` required | T2 (synthesized) | prompt-skill-plugin-governor |
| PG-RP-02 | `docs/runtime/rule-packs/python-fastapi.md` | Python 3.12+, Pydantic models, async-first, type hints required, requirements.txt hygiene | T2 | prompt-skill-plugin-governor |
| PG-RP-03 | `docs/runtime/rule-packs/docker-compose.md` | non-root USER, healthcheck required, mem_limit, dev/prod parity, no raw docker.sock bind-mount (uses docker-socket-proxy pattern from AP-05) | T1 (ajanscan evidence) | infra-release-sre |
| PG-RP-04 | `docs/runtime/rule-packs/api-security.md` | .env hygiene, rate limiting required, audit log on dangerous actions, CVSS v4.0 for vulnerability scoring | T2 | security-hardening-lead |

**Priority**: P1 (W2.1, blocking for v2.1.3)

### 2. Skills (3 new)

| ID | Path | Purpose | Inputs | Outputs | Trust | Owner |
|---|---|---|---|---|---|---|
| PG-SK-01 | `.claude/skills/god-module-decomposition/` | Strangler Fig executor for single-file monolith decomposition; staged extraction A→B→C→D with commit per step | file path, target package, extraction plan | new package tree + shim of original + per-step commits + updated imports | T1 (ajanscan R-01) | architecture-lead |
| PG-SK-02 | `.claude/skills/fourteen-dimension-audit/` | 14-dim audit scoring (R-03) for baseline + target state | repo path, scoring rubric | per-dim scorecard, target state, gap matrix, A-F grade | T1 (ajanscan methodology) | architecture-lead |
| PG-SK-03 | `.claude/skills/multi-agent-orchestration/` | Sprint assignment with dependency graph + file-ownership matrix + merge sequence | backlog JSON, sprint length, num agents, merge rules | sprint assignment, dependency graph, conflict matrix, daily standup template | T1 (ajanscan R-02) | autonomous-program-director |

**Priority**: P2 (W4.7, high-value but not v2.1.3 blocking)

### 3. Commands (1 new)

| ID | Path | Purpose | Trust | Owner |
|---|---|---|---|---|
| PG-C-01 | `.claude/commands/triage-build.md` | Generic build-failure triage: section per stack (frontend/backend/container/mobile), diagnostic commands, toolchain-precheck integration | T2 (ajanscan generalization) | infra-release-sre |

**Priority**: P2 (W4.4)

### 4. Agent enhancements (not new agents)

| ID | Agent | Enhancement | Trust | Owner |
|---|---|---|---|---|
| PG-AGX-01 | `design-system-architect.md` | Master + per-page output contract: emit `design-system/MASTER.md` + `pages/<page>.md` | T3 (design judgment) | design-system-architect |
| PG-AGX-02 | `autonomous-program-director.md` | Rule-pack loader in Phase 0; propagate live-probe flag + output_language to specialist dispatches; record `rule_packs_loaded` in active-variables.yaml | T1 (coherence finding FIND-AL-01 requires this) | autonomous-program-director |
| PG-AGX-03 | `security-hardening-lead.md` | Secrets rotation + history purge workflow (gitleaks baseline, git-filter-repo runbook, pre-commit hook installation) | T1 (ajanscan SEC findings + FIND-SEC-03) | security-hardening-lead |

**Priority**: PG-AGX-02 is P1 (part of core contract restructuring); PG-AGX-01 and PG-AGX-03 are P2.

### 5. Governance docs (6 new + 4 extensions)

Enumerated in `target-state.md` §Layer 1. Covered by execution roadmap W2.3, W2.4, W2.5, W3.9, W3.10, W3.11.

### 6. Runtime rules (3 new + 2 extensions + 1 constants doc)

| ID | Path | Purpose | Owner |
|---|---|---|---|
| PG-R-01 | `docs/runtime/strangler-fig-protocol.md` | Staged monolith decomposition protocol | architecture-lead |
| PG-R-02 | `docs/runtime/multi-agent-merge-sequence.md` | Dependency-depth merge sequence for 4+ parallel specialists | autonomous-program-director |
| PG-R-03 | `docs/runtime/audit-scoring-framework.md` | 14 universal dimensions for audit baseline + target | architecture-lead |
| PG-R-04-ext | `docs/runtime/toolchain-precheck.md` | + pre-push parity + VPS baseline | infra-release-sre |
| PG-R-05-ext | `docs/runtime/architecture-currency.md` | + deploy resilience | infra-release-sre |
| PG-RC-01 | `docs/runtime/runtime-constants.md` | Single source of truth for MAX_PARALLEL_AGENTS, phase numbers, field names (resolves DY-04, DY-10) | architecture-lead |

### 7. CI + supply-chain units

| ID | Path | Unit type | Purpose |
|---|---|---|---|
| PG-CI-01 | `.github/dependabot.yml` | supply-chain config | Weekly dep updates |
| PG-CI-02 | `.gitleaks.toml` + `.gitleaks.baseline` | security gate config | Baseline-based secret scan |
| PG-CI-03 | `.github/brand-allowlist.txt` | CI data | Brand-check allowlist (moved out of workflow) |
| PG-CI-04 | `scripts/validate-vendor-parity.sh` | validation script | Claude/Gemini command parity matrix |
| PG-CI-05 | `evals/run.sh` | runnable evals | Close FIND-QA-02 + DY-08 |
| PG-CI-06 | `.claude/settings.local.example.json` | template | Safe permission template (closes SEC-01+02) |
| PG-CI-07 | `scripts/validate-bilingual-examples.sh` (W5) | validation script | bilingual drift detection (FIND-LOC-03) |

### 8. Hooks (1 new + 1 upgrade)

| ID | Matcher | Purpose | Owner |
|---|---|---|---|
| PG-HK-01 | `PreToolUse` matcher "Skill" | Audit trail for Skill invocations (FIND-RT-05) | security-hardening-lead |
| PG-HK-02 | `SessionStart` | Log rotation: truncate `.claude/logs/*.log` >14d (FIND-INF-04) | infra-release-sre |
| PG-HK-03 | `PreToolUse` matcher "Write(.env*)" | Guardrail: refuse edits to .env* files (FIND-SEC-04 reference implementation) | security-hardening-lead |

**Priority**: P2 (W4 / W5 surface)

### 9. MCP (deferred)

| ID | Path | Status | Reason |
|---|---|---|---|
| PG-MCP-01 | `ulak-design-intelligence-mcp` | DEFERRED to v2.2 | D-01: ajanscan ui-ux-pro-max skill ships 12 CSVs + Python CLI. Porting as skill violates vendor-agnostic contract. Future: wrap as MCP. Requires MCP server scaffolding + data-retrieval design — larger than a doc release. |

## Why they matter

### Blocker-class gaps (if absent, v2.1.3 cannot be called a coherent release)
- **PG-RP-01..04 (rule-packs)** — target-state doc (product-surface-split, settings-permissions-governance) implies rule-pack infrastructure; shipping G-01 doc without the rule-packs/ directory is empty doctrine.
- **PG-CI-06 (settings.local.example.json)** — direct close of FIND-SEC-01+02 which is the single P0 blocker.
- **PG-AGX-02 (director agent rule-pack loader)** — runtime behavior mismatch if rule-packs ship without the loader.
- **PG-RC-01 (runtime-constants.md)** — DY-04 + DY-10 drift closure.

### High-value gaps (v2.1.3 scope)
- PG-SK-01..03, PG-C-01: enable practical consumer workflows (god-module decomp, 14-dim audit, multi-agent orchestration, build triage)
- PG-AGX-01, PG-AGX-03: improve agent coverage in design and security
- PG-CI-01..05, PG-CI-07: CI hardening + false-green closure
- PG-HK-01..03: hook-governance reference implementation

### Deferred (v2.2)
- PG-MCP-01 (ulak-design-intelligence-mcp)

## Owner mapping

| Owner | Gaps owned |
|---|---|
| prompt-skill-plugin-governor | PG-RP-01, PG-RP-02 (could be delegated to stack leads), governance doc authoring |
| architecture-lead | PG-RP-03 (partial), PG-SK-01/02, PG-AGX-02, PG-R-01/03, PG-RC-01 |
| infra-release-sre | PG-C-01, PG-R-04-ext, PG-R-05-ext, PG-CI-01..07, PG-HK-02 |
| security-hardening-lead | PG-RP-04, PG-AGX-03, PG-HK-01, PG-HK-03 |
| design-system-architect | PG-AGX-01 |
| autonomous-program-director | PG-SK-03, PG-AGX-02, PG-R-02 |

## Priority summary

- **P0 (v2.1.3 blocker)**: PG-CI-06, PG-AGX-02, PG-RC-01, PG-RP-01..04 (but starter packs can be minimal, ≤500B each), G-04 doc, rule-pack-governance.md (G-01)
- **P1 (v2.1.3 high)**: PG-R-01..03, PG-R-04-ext, PG-R-05-ext, PG-AGX-01, PG-AGX-03, ajanscan G-02/03, PG-CI-04/05
- **P2 (v2.1.3 if capacity)**: PG-SK-01..03, PG-C-01, PG-CI-01..03, PG-CI-07, PG-HK-01..03
- **Deferred v2.2**: PG-MCP-01, any P2 items that slip

## Recommended path

1. **Wave 1 (already blocking)**: land SEC-01+02 fix → close the self-inflicted leak first
2. **Wave 2**: land rule-pack infrastructure (governance + starter packs + CLAUDE.md restructure)
3. **Wave 3**: land content (anti-patterns, sector packs, runtime rules) — high volume, low risk
4. **Wave 4**: land agent extensions + commands + skills + CI hardening
5. **Wave 5 (optional)**: polish items
6. **Wave 6 (deferred)**: MCP + agent splits if triggered by post-v2.1.3 measurements

Rationale: Wave ordering lets each wave's output be the input for the next. No wave depends on a later wave. Merged from ajanscan §156-187 baseline + coherence-first reordering.

## Notes

- **PG-MCP-01** is the only MCP gap. The prompt-pack pattern cannot absorb it without code scaffolding.
- **Hook gaps** (PG-HK-*) are low-code but important for the reference-implementation story (FIND-SEC-04).
- The **31-line specialist agent** gap (FIND-PG-01) is NOT a pack gap — it's a content depth gap on existing units. Captured in target-state as a W5 polish item; not a new reusable unit.
- **docs/i18n/ empty** (FIND-AL-05) is NOT a pack gap — it's a surface hygiene item. Captured in W5.13.
- **docs/superpowers/ layer undefined** (DY-09) is NOT a pack gap — it's a surface-split clarification. Captured in W5.18.
