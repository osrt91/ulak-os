# Execution Roadmap — Ulak OS v2.1.3

**Date**: 2026-04-18
**Run id**: director-komple-ulakos-self-audit
**Pattern**: Waves per `docs/runtime/waves-pattern.md` — parallel within, serial between. Conflict map before every Wave.
**Input**: analysis-findings.md + target-state.md + ajanscan 6-wave baseline (patterns extraction §156-187) refined by fresh findings.

## Execution mode
- `EXECUTION_MODE: analysis-only` in this run (no writes were performed).
- Wave execution happens in a **subsequent session** (user can invoke `/director komple mode=EXECUTE entry=reports/current/execution-roadmap.md` or equivalent).
- This document is the executable plan: each item carries file path, action verb, acceptance criteria, and trust tier.

## Wave 1 — Blocker fixes + Phase-numbering refactor (same session, parallel)

**Theme**: Fix the blocking issues BEFORE any doc extension lands. Prevents new content from cementing the contradictions.

**Conflict map**:
| Agent lane | Owns (write) | Reads | Must-not-touch |
|---|---|---|---|
| G1 security | .gitignore, .claude/settings.local.example.json, docs/governance/settings-permissions-governance.md | .claude/settings.local.json, .claude/settings.json | docs/runtime/** |
| G2 architecture | docs/runtime/program-phases.md | docs/runtime/*, docs/adapters/* | .claude/**, docs/governance/** |
| G3 prompt-skill | docs/runtime/persona-dispatch-pattern.md (lines 164-165) | .claude/agents/*-persona.md | docs/runtime/program-phases.md |
| G4 qa | docs/examples/sample-validation-plan.md | docs/runtime/live-probe-contract.md | src/**, .claude/** |

Rule: G1 ∩ G2 = ∅, G2 ∩ G3 = ∅ (both touch docs/runtime but different files). Clean.

**Items**:

| ID | Finding | Action | Files | Acceptance |
|---|---|---|---|---|
| W1.1 | FIND-SEC-01+02 | Git hygiene: add `.claude/settings.local.json` to .gitignore, `git rm --cached`, create `.claude/settings.local.example.json` with safe defaults | `.gitignore`, `.claude/settings.local.example.json` | `git ls-files .claude/settings.local.json` returns empty; example exists |
| W1.2 | FIND-AL-01+02 | Refactor program-phases.md to Numbering A (Phase 5 = final verdict). Move old Phase 5/6/7/8 content to sub-phases of Phase 5 or siblings | `docs/runtime/program-phases.md` | grep for "Phase [678]" returns 0 active-runtime hits; all cross-refs updated |
| W1.3 | FIND-PG-02 | Edit persona-dispatch-pattern.md:164-165 to say personas ARE shipped (commit c21204b) | `docs/runtime/persona-dispatch-pattern.md` | grep "NOT yet shipped" in that file returns 0 |
| W1.4 | FIND-QA-01 | Ship `docs/examples/sample-validation-plan.md` with §6 live-probe section | `docs/examples/sample-validation-plan.md`, `docs/runtime/live-probe-contract.md` (add reference) | File exists; §6 header is "## §6 — Live probes (read-only)"; reference from live-probe-contract.md present |

**depends_on**: none (pure Wave 1).
**Validation gate between Wave 1 and Wave 2**: scripts/validate-imports.sh passes; scripts/validate-schemas.sh passes; CI check `brand-consistency` passes; no git uncommitted files except intended ones.

---

## Wave 2 — Rule packs + G-04 + G-06 + core-contract restructuring (parallel)

**Theme**: Land the governance doctrine that backs Wave 1 fixes and enables Wave 3 additions.

**Conflict map**:
| Agent lane | Owns (write) | Reads | Must-not-touch |
|---|---|---|---|
| G5 rule-packs | `docs/governance/rule-pack-governance.md`, `docs/runtime/rule-packs/*.md` (4 files), `docs/governance/plugin-skill-decision.md` | `docs/runtime/router.md`, existing packs | `docs/governance/settings-permissions-governance.md` |
| G6 settings-perms | `docs/governance/settings-permissions-governance.md`, `docs/governance/product-surface-split.md` | `.claude/settings.json`, `.claude/settings.local.json` | `docs/governance/rule-pack-governance.md` |
| G7 core-contract | `prompts/core/ulak-os-core-contract-2.0.0.md`, `CLAUDE.md` | all @-imports already in + new ones from Wave 1/2 | `docs/governance/*.md` (other agents owning) |

Clean.

**Items**:

| ID | Finding | Action | Files | Acceptance |
|---|---|---|---|---|
| W2.1 | FIND-PG-05, ajanscan G-01 | Create `docs/governance/rule-pack-governance.md` + directory `docs/runtime/rule-packs/` + 4 starter packs | `docs/governance/rule-pack-governance.md`, `docs/runtime/rule-packs/{typescript-nextjs,python-fastapi,docker-compose,api-security}.md` | All 5 files exist, each starter ≤500 bytes body; governance doc specifies size cap |
| W2.2 | ajanscan G-EXT-03 | Extend `plugin-skill-decision.md` from 6 → 7 unit types (rule-pack) | `docs/governance/plugin-skill-decision.md` | 7 bullets in the main list |
| W2.3 | FIND-SEC-01+02, ajanscan G-04 | Create `docs/governance/settings-permissions-governance.md` with worked examples from Ulak + ajanscan | `docs/governance/settings-permissions-governance.md` | File exists ≥80 lines; cites Ulak SEC-01/02 as motivator |
| W2.4 | ajanscan G-06 | Create `docs/governance/product-surface-split.md` (customer/admin/public/partner) | `docs/governance/product-surface-split.md` | File exists ≥80 lines; cross-references `surface-split.md` explicitly as a DIFFERENT doc |
| W2.5 | ajanscan G-05 | Create `docs/governance/lock-file-hygiene.md` (TTL/liveness) | `docs/governance/lock-file-hygiene.md` | File exists ≥50 lines |
| W2.6 | FIND-AL-03, FIND-CG-01 | Update core contract: add `@docs/runtime/office-roster.md`; move 2 governance imports from CLAUDE.md; add G-04+G-06 imports | `prompts/core/ulak-os-core-contract-2.0.0.md`, `CLAUDE.md` | CLAUDE.md has only adapters + core-contract imports; core contract has 2 new runtime imports + 2 new governance imports |

**depends_on**: Wave 1 complete (W1.2 phase refactor, so core-contract references stay valid).
**Validation gate**: `scripts/validate-imports.sh` passes with all new @-imports; no broken references.

---

## Wave 3 — Sector packs + anti-patterns + runtime rules (parallel)

**Theme**: Land the content layer — 6 sector packs, 9 anti-patterns, 5 runtime rules (R-01..R-05) + runtime-constants.

**Conflict map**:
| Agent lane | Owns (write) | Reads | Must-not-touch |
|---|---|---|---|
| G8 anti-patterns | `docs/runtime/anti-patterns.md` (append 9 new) | ajanscan-pattern-extraction.md | sector-packs.md |
| G9 sector-packs | `docs/runtime/sector-packs.md` (append 6 new + 1 extension) | existing pack content | anti-patterns.md |
| G10 runtime-rules | `docs/runtime/{strangler-fig-protocol,multi-agent-merge-sequence,audit-scoring-framework,runtime-constants}.md` (4 new files) + extend `toolchain-precheck.md` + `architecture-currency.md` | finding schema | sector-packs.md |
| G11 gov-extensions | `docs/governance/{ai-provider-allowlist,pattern-import-ledger}.md` + extend `mcp-governance.md`, `memory-hygiene.md`, `prompt-supply-chain.md` | existing governance docs | runtime/** |

Clean.

**Items**:

| ID | Finding | Action | Files | Acceptance |
|---|---|---|---|---|
| W3.1 | AP-01..AP-09 | Append 9 new anti-patterns with ajanscan citations | `docs/runtime/anti-patterns.md` | 9 new bullets present; each cites ajanscan file:line |
| W3.2 | SP-01..SP-06 | Append 6 new sector packs; extend `saas` with web-quality-scanner sub-pattern (SP-EXT-01) | `docs/runtime/sector-packs.md` | 6 new sections + 1 extended section |
| W3.3 | R-01 | Create `strangler-fig-protocol.md` | `docs/runtime/strangler-fig-protocol.md` | File ≥100 lines |
| W3.4 | R-02 | Create `multi-agent-merge-sequence.md` | `docs/runtime/multi-agent-merge-sequence.md` | File ≥100 lines |
| W3.5 | R-03 | Create `audit-scoring-framework.md` (14 dimensions) | `docs/runtime/audit-scoring-framework.md` | File ≥100 lines; 14-dim table present |
| W3.6 | R-04 | Extend `toolchain-precheck.md` with pre-push parity + VPS baseline | `docs/runtime/toolchain-precheck.md` | +30-50 lines appended |
| W3.7 | R-05 | Extend `architecture-currency.md` with deploy resilience section | `docs/runtime/architecture-currency.md` | +15-25 lines |
| W3.8 | DY-10, DY-04 | Create `runtime-constants.md` — single source of truth for MAX_PARALLEL_AGENTS, phase numbers, field names | `docs/runtime/runtime-constants.md` | File exists; active-variable-contract.md + router.md + director agent all reference this |
| W3.9 | ajanscan G-02 | Create `ai-provider-allowlist.md` | `docs/governance/ai-provider-allowlist.md` | File ≥80 lines (T3 flag on Gemini-only memory claim) |
| W3.10 | ajanscan G-03 | Create `pattern-import-ledger.md` | `docs/governance/pattern-import-ledger.md` | File ≥80 lines |
| W3.11 | ajanscan G-EXT-01, G-EXT-02, G-EXT-04 | Extend mcp-governance (audit-trail), memory-hygiene (worktree cleanup), prompt-supply-chain (G-03 cross-link) | 3 files | Diff reviewable per file |

**depends_on**: Wave 2 (rule-pack-governance and core-contract imports must exist for Wave 3 cross-references).
**Validation gate**: all new files parse; `scripts/validate-imports.sh` passes; CI brand check passes.

---

## Wave 4 — Agent + command + skill + CI (parallel)

**Theme**: Pack-surface work. Agents, commands, skills, CI hardening.

**Conflict map**:
| Agent lane | Owns | Reads | Must-not-touch |
|---|---|---|---|
| G12 director-ext | `.claude/agents/autonomous-program-director.md` | `docs/runtime/rule-packs/`, active-variable-contract.md | other agent files |
| G13 agent-exts | `.claude/agents/{design-system-architect,security-hardening-lead}.md` | existing content | director agent |
| G14 new-commands | `.claude/commands/triage-build.md` + phase-subset edits on 4 light commands | existing commands | agents/ |
| G15 new-skills | `.claude/skills/{god-module-decomposition,fourteen-dimension-audit,multi-agent-orchestration}/SKILL.md` | R-01..R-03 docs | agents/ |
| G16 ci-hardening | `.github/workflows/ci-validation.yml`, `.github/dependabot.yml`, `.gitleaks.toml`, `.gitleaks.baseline`, `.github/brand-allowlist.txt`, `evals/run.sh`, `scripts/validate-{vendor-parity,schemas,imports}.sh` | CI docs | docs/** |

Clean.

**Items**:

| ID | Finding | Action | Files | Acceptance |
|---|---|---|---|---|
| W4.1 | AG-EXT-02 | Extend director agent: rule-pack loader + live-probe flag propagation + output_language propagation | `.claude/agents/autonomous-program-director.md` | +20-30 lines; grep confirms `rule_packs_loaded` field |
| W4.2 | AG-EXT-01 | Extend design-system-architect with Master + per-page output contract | `.claude/agents/design-system-architect.md` | +20-30 lines |
| W4.3 | AG-EXT-03 | Extend security-hardening-lead with secrets rotation + history purge | `.claude/agents/security-hardening-lead.md` | +30-40 lines |
| W4.4 | C-01 | Create `triage-build.md` command | `.claude/commands/triage-build.md` | File ≥40 lines |
| W4.5 | FIND-PG-03 | Add "Phase subset" frontmatter to 4 light commands | `.claude/commands/{pack-gap-audit,intake,final-verdict,frontend-war-room}.md` | Each has a "phases_run" frontmatter field |
| W4.6 | FIND-PG-04 | Cross-reference skills in commands (final-validation→/final-verdict, pack-gap-completion→/pack-gap-audit, research-currency→/ulak-intake) | 3 command files | Each names its skill |
| W4.7 | SK-01, SK-02, SK-03 | Create 3 new skills | `.claude/skills/god-module-decomposition/SKILL.md`, `.claude/skills/fourteen-dimension-audit/SKILL.md`, `.claude/skills/multi-agent-orchestration/SKILL.md` | 3 new SKILL.md files |
| W4.8 | FIND-INF-02 | Bump package.json version 2.0.0 → 2.1.3 | `package.json` | grep returns "version": "2.1.3" |
| W4.9 | FIND-INF-01, DY-07 | Consolidate 2 [Unreleased] blocks into 1; prepare v2.1.3 release section | `CHANGELOG.md` | grep count [Unreleased] = 1 |
| W4.10 | FIND-QA-04 | Raise ci-validation.yml artefact count 12 → 14 | `.github/workflows/ci-validation.yml` | grep "count.*-lt 14" matches |
| W4.11 | FIND-INF-05 | Move brand allowlist to `.github/brand-allowlist.txt` | Move pattern; update workflow to read from file | Workflow reads from file |
| W4.12 | FIND-INF-03 | Add `.github/dependabot.yml` | New file | File exists with npm + github-actions ecosystems |
| W4.13 | FIND-QA-03 | Add gitleaks baseline + config | `.gitleaks.toml`, `.gitleaks.baseline` | Files exist; CI passes against baseline |
| W4.14 | DY-01 | Extend validate-imports.sh with cycle detection | `scripts/validate-imports.sh` | Synthetic cycle produces exit 1 |
| W4.15 | DY-02 | Upgrade validate-schemas.sh to $schema conformance | `scripts/validate-schemas.sh` | Malformed permission entry produces exit 1 |
| W4.16 | DY-03 | Create scripts/validate-vendor-parity.sh + add CI job | `scripts/validate-vendor-parity.sh`, workflow | Emits Claude/Gemini command matrix |
| W4.17 | FIND-QA-02, DY-08 | Create evals/run.sh + CI job (warn-only) | `evals/run.sh`, workflow | Non-zero exit on synthetic regression; CI warns |
| W4.18 | FIND-INF-04 | Add log-rotation hook on SessionStart | `.claude/settings.json` | Hook declared; .claude/logs/ rotation discipline present |

**depends_on**: Wave 3 (R-01..R-03 docs must exist for SK-01..03 references; runtime-constants.md must exist for director agent citations).
**Validation gate**: CI passes on current tree; `npm run build` + `npm test` still pass (do not regress src/); all skills declare `agent:` bindings.

---

## Wave 5 — Medium-polish workstream (parallel, optional within v2.1.3)

**Theme**: Items that improve quality without blocking release. Can slip to v2.1.4 if capacity tight.

| ID | Finding | Action | Files |
|---|---|---|---|
| W5.1 | FIND-PG-01 | Enhance 18 31-line specialist agents to 50-80 lines | 18 agent files | Each ≥50 lines with specialty focus areas |
| W5.2 | FIND-PG-06 | Add "Red-team lanes" section to persona-dispatch-pattern.md | `docs/runtime/persona-dispatch-pattern.md` | 3-way lane split documented |
| W5.3 | FIND-RT-01 | Widen artefact-write-authorization scope | `docs/governance/artefact-write-authorization.md` | Cover all artefact-contract.md paths |
| W5.4 | FIND-RT-02 | Extend rule-collision-matrix.md with worked examples | `docs/governance/rule-collision-matrix.md` | File ≥60 lines; 5+ examples |
| W5.5 | FIND-RT-03 | Add dispatch=both merge rule to persona-dispatch-pattern.md | Same file | Merge rule subsection |
| W5.6 | FIND-RT-04 | Propagate live-probe-enabled to specialist dispatch prompt (director agent refinement) | autonomous-program-director.md | Dispatch prompt template includes flag |
| W5.7 | FIND-RT-05 | Document Skill audit hook pattern in settings-permissions-governance.md | G-04 file | Section added |
| W5.8 | FIND-SEC-04 | Ship one guardrail hook in .claude/settings.json | `.claude/settings.json` | At least 1 blocking hook |
| W5.9 | FIND-LOC-01 | Add output_language to active-variable-contract.md + all 7 profiles | `docs/runtime/{active-variable-contract,output-profiles}.md` | Field present in every profile |
| W5.10 | FIND-LOC-02 | (Resolved by W3.8 runtime-constants + honest labels) | — | — |
| W5.11 | FIND-SEC-03 | Add PAT rotation runbook to mcp-governance.md | `docs/governance/mcp-governance.md` | Section appended |
| W5.12 | FIND-AL-04 | Decide: delete autonomy-pressure-layer.md OR integrate | Either delete + git rm or expand to full doc + import | grep returns 0 orphan hits |
| W5.13 | FIND-AL-05 | Add README or populate docs/i18n/ | `docs/i18n/README.md` | Declares layer + intent |
| W5.14 | FIND-CG-04 | Populate docs/runtime/README.md + docs/governance/README.md | 2 README files | Each ≥10 lines with ToC |
| W5.15 | FIND-LOC-03 | scripts/validate-bilingual-examples.sh | `scripts/validate-bilingual-examples.sh` | Script + CI job |
| W5.16 | DY-05 | Add "canonical-as-of-version" footer to docs/examples/sample-*.md | 3-6 files | Footer present; reference in artefact-contract.md |
| W5.17 | DY-06 | Document skill `context:` field in plugin-skill-decision.md | Same file | Values enumerated |
| W5.18 | DY-09 | Add README to docs/superpowers/ declaring layer | `docs/superpowers/README.md` | Declares Layer 2 or Layer 3 per surface-split.md |

**depends_on**: Wave 4 complete.

---

## Wave 6 — Deferrals + v2.2 intake

**Theme**: Not shipped in v2.1.3. Captured for next release.

| ID | Item | Why deferred |
|---|---|---|
| W6.1 | D-01 ulak-design-intelligence-mcp | Requires MCP server scaffolding + vendor-agnostic wrapper of ajanscan ui-ux-pro-max. Larger than a doc release. |
| W6.2 | D-02 orchestrator-coordinator agent | Q1 decision says NO for now; revisit if director agent exceeds 300L. |
| W6.3 | D-03 security-secrets-auditor agent | Q2 decision says NO for now; revisit if security-hardening-lead exceeds 120L. |
| W6.4 | Mode-loading mechanism for operational motors | v2.1.3 honest-relabels; v2.2 implements conditional loader. |
| W6.5 | Raise evals-smoke CI job from warn-only to blocking | v2.1.3 ships it warn-only; promote in v2.2 after false-positive rate is measured. |

## Rollback notes

- **W1 rollback**: `git revert` the Phase-numbering commit if downstream breakage (unlikely — all 11+ cross-refs already use Numbering A).
- **W2 rollback**: Delete new governance files; revert core contract imports. Safe because nothing else depends on them yet.
- **W3 rollback**: Append-only content; revert is clean.
- **W4 rollback**: CI changes reversible. Version bump revert requires a new tag (don't untag v2.1.3 after release).
- **W5 rollback**: Each item independent; revert per file.

## Dependencies graph (summary)

```
W1 (no deps)
  └─> W2 (depends on W1.2 Phase refactor so core-contract refs stay valid)
       └─> W3 (depends on W2 governance scaffolding)
            └─> W4 (depends on W3 R-01..R-03 for skill refs)
                 └─> W5 (polish — independent of each other; depends on W4 baseline)
                      └─> W6 (next release intake)
```

## Time/effort estimate (session-units)

- W1: 1 session (4-6 hrs of work distributed across 4 agents in parallel)
- W2: 1 session
- W3: 1-2 sessions (content-heavy)
- W4: 1-2 sessions (many small items)
- W5: 1 session (optional — can slip)
- W6: deferred

Total v2.1.3 critical path: **4-6 sessions**.

## Exit criteria for v2.1.3 signoff

All items in W1-W4 complete. W5 optional. W6 captured for v2.2.

See `validation-plan.md` for the gate specification.
