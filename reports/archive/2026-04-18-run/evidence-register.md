# Evidence Register — Ulak OS self-audit (Phase 2 specialist deep-scan)

**Date**: 2026-04-18
**Run id**: director-komple-ulakos-self-audit
**Specialists dispatched (Phase 2)**: 8 — prompt-skill-plugin-governor, architecture-lead, cartographer, red-team-challenger, qa-validation-commander, localization-i18n-lead, security-hardening-lead, infra-release-sre. Explicit skip: data-database-governor (no DB).
**Plus inherited bundle**: 39 patterns from `reports/current/ajanscan-pattern-extraction.md` (T1-T3 already assigned; treated as inherited specialist evidence from the 2026-04-18 Phase A three-agent extraction).

Schema: each finding follows `docs/governance/finding-schema.md`. T-tier per `docs/governance/evidence-trust-scoring.md`.

---

## Part A — Inherited evidence bundle (ajanscan Phase A, 39 patterns)

Summarized here as links; NOT re-listed (their full text lives in `ajanscan-pattern-extraction.md`). Dedup verified in Phase 1: AP-01, AP-02, AP-03, AP-05, AP-06, AP-07, AP-08 confirmed absent from `docs/runtime/anti-patterns.md:1-145`; SP-01..SP-06 confirmed absent from `docs/runtime/sector-packs.md:29-134`; rule-pack unit confirmed absent from `docs/governance/plugin-skill-decision.md:1-11`.

| Bucket | Count | Carry-through |
|---|---|---|
| Anti-patterns (AP-01 to AP-09) | 9 | all adopted as findings FIND-AP-01..09 |
| Sector packs (SP-01 to SP-06 + SP-EXT-01) | 7 | all adopted as findings FIND-SP-01..06, FIND-SP-EXT-01 |
| Rule-pack unit type + 4 starter packs | 5 | adopted as findings FIND-RP-01..05 |
| Governance docs (G-01 to G-06 + G-EXT-01..04) | 10 | adopted as findings FIND-G-01..06, FIND-G-EXT-01..04 |
| Runtime rules (R-01 to R-05) | 5 | adopted as findings FIND-R-01..05 |
| Skills (SK-01..03) + command (C-01) + agent-ext (AG-EXT-01..03) | 7 | adopted as findings FIND-SK-01..03, FIND-C-01, FIND-AG-EXT-01..03 |
| Deferred (D-01..03) — 6 open questions | 3 | forwarded to target-state for director synthesis (not findings) |

Trust tiers on these: per ajanscan-pattern-extraction.md §198-204:
- T1 for patterns backed by scanned ajanscan files (most of AP-01..09, SP-01..06, R-01..R-04, SK-01..02)
- T2 for cross-project extrapolations
- T3 for memory-sourced claims (explicitly flagged: G-02 AI-provider-allowlist memory for Gemini-only constraint, G-03 pattern-import-ledger for TrendOfTrend inheritance, R-05 cron-poll promotion, AG-EXT-01 design-system Master-override judgment)

---

## Part B — Fresh specialist findings on Ulak OS itself

### Specialist 1: prompt-skill-plugin-governor (pack health, trigger discipline)

```yaml
- id: FIND-PG-01
  area: prompt
  title: "Specialist agent files are uniformly 31-line generic shells"
  problem: |
    18 of 19 non-director specialist agents are exactly 31 lines. They share a near-identical template
    (focus/return/rules + artefact write authorization) with the specialty only in the frontmatter description
    and 3 "Focus on" bullets. This is below the specialization bar observed in persona agents (48-66 lines
    each) and in the one custom specialist (autonomous-program-director at 188 lines).
  evidence: ".claude/agents/*.md — grep confirms 18 files at exactly 31 lines (architecture-lead, backend-api-architect, cartographer, data-database-governor, design-system-architect, educational-ux-specialist, frontend-ios-flutter-director, infra-release-sre, localization-i18n-lead, market-researcher, privacy-compliance-counsel, product-business-strategist, prompt-skill-plugin-governor, qa-validation-commander, red-team-challenger, release-readiness-auditor, security-hardening-lead, seo-aso-growth-strategist, support-ops-orchestrator)"
  evidence_source: "wc -l .claude/agents/*.md (inventory §6)"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: |
    Dispatched specialists produce lowest-common-denominator output because the framing is too shallow.
    The persona agents outperform specialists in depth partly because they have richer framing. Compare
    security-redteam persona (66L, concrete exploit lens, focus areas list, return shape) to
    red-team-challenger specialist (31L, generic "attack weak assumptions"). Persona dispatch is already
    providing evidence that richer prompts yield richer findings.
  severity: Medium
  priority: P2
  recommended_fix: |
    Enhance each specialist agent to ~50-80 lines with: (1) specialist-specific focus areas list
    (5-10 bullets like security-redteam §21-41), (2) anti-pattern pointers into docs/runtime/anti-patterns.md,
    (3) return-shape sub-fields (not just "findings"), (4) escalation pointers. Grade: P2 because the
    current agents still work; they just under-perform their potential.
  validation: "After enhancement, dispatch the enhanced vs old agent on the same project and compare finding count + T-tier distribution."
  owner: prompt-skill-plugin-governor
  depends_on: []
  tags: [quick-win, pack-enhancement]

- id: FIND-PG-02
  area: prompt
  title: "Persona agents ship in .claude/agents/ but persona-dispatch-pattern.md still calls them a Pack Gap"
  problem: |
    `docs/runtime/persona-dispatch-pattern.md:164` says: "These agents are NOT yet shipped in Ulak OS 2.1.x —
    they're a Pack Gap (see `docs/runtime/handoff-plan-contract.md` integration) for v2.2." But the 7 persona
    agent files ARE present in `.claude/agents/` as of commit c21204b (see CHANGELOG §64-66).
  evidence: "docs/runtime/persona-dispatch-pattern.md:164 vs .claude/agents/{customer-persona,admin-persona,bayi-persona,security-redteam,support-persona,developer-persona,compliance-persona}.md + CHANGELOG.md:64"
  evidence_source: "Direct file read + CHANGELOG cross-reference"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: direct
  impact: "Contributors/users relying on persona-dispatch-pattern.md will believe the persona dispatch mode is unusable in v2.1.x. This blocks adoption of a feature that is already shipped."
  severity: High
  priority: P0
  recommended_fix: "Update `docs/runtime/persona-dispatch-pattern.md:164-165` to: 'These agents are shipped in Ulak OS 2.1.2 (commit c21204b). See `.claude/agents/{customer,admin,bayi,security-redteam,support,developer,compliance}-persona.md`.'"
  validation: "grep -n 'NOT yet shipped' docs/runtime/persona-dispatch-pattern.md returns empty."
  owner: prompt-skill-plugin-governor
  depends_on: []
  tags: [quick-win, doc-drift]

- id: FIND-PG-03
  area: prompt
  title: "Commands pack-gap-audit / intake / final-verdict / frontend-war-room are ≤16-line delegator shells"
  problem: |
    Four commands are thin shells (12-16 lines each) that each name 1-4 agents to dispatch and 2-3 artefact
    targets. They lack router hint, scope guidance, phase skip logic, and argument surface. By contrast
    `/director komple` (95L) and `/ulak-intake` (37L) are full-featured.
  evidence: ".claude/commands/{final-verdict.md:1-16, frontend-war-room.md:1-16, intake.md:1-14, pack-gap-audit.md:1-12}"
  evidence_source: "Direct read (inventory §7)"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: |
    Users running `/intake` miss the runtime-manifest + assumptions + router-decision step that `/director`
    enforces. `/final-verdict` doesn't enforce the validation-result.yaml emission. The commands ARE real
    entry points but they bypass the phase discipline that director establishes. This may have been intentional
    (each command is a light mode) but there's no doc contract saying so.
  severity: Medium
  priority: P2
  recommended_fix: |
    Either (a) document each light command's intended phase subset + what it skips and why, or
    (b) upgrade them to trigger Phase 0 environment lock minimum. Preferred: add a "Phase subset" section
    in each command's frontmatter description and a note "Skips: Phase X, Phase Y (because ...)".
  validation: "Each command's frontmatter explicitly names the phase subset it runs."
  owner: prompt-skill-plugin-governor
  depends_on: [FIND-AL-02]
  tags: [foundational, pack-discipline]

- id: FIND-PG-04
  area: prompt
  title: "4 skills exist but none are referenced as triggers in any command or agent front-matter"
  problem: |
    `.claude/skills/{final-validation,pack-gap-completion,project-intake,research-currency}/SKILL.md` declare
    `agent:` bindings. Reviewing `.claude/commands/*.md`: only `/intake` names `project-intake skill`
    (intake.md:6). `final-validation`, `pack-gap-completion`, `research-currency` are unreferenced by any
    command. They may be invoked via the Skill tool directly, but there is no discovery path for a user.
  evidence: ".claude/skills/{final-validation,pack-gap-completion,project-intake,research-currency}/SKILL.md + grep -r 'skill' .claude/commands/"
  evidence_source: "Inventory §8 + direct grep"
  evidence_trust: T2
  completeness_risk: medium
  contradiction_status: partial
  impact: "Three of four skills are dormant in day-to-day use. Users won't know they exist. The cost of shipping them is low but the discoverability gap matters when a skill is supposed to shortcut a workflow."
  severity: Low
  priority: P3
  recommended_fix: |
    Add skill references into the relevant commands: `/final-verdict` should reference `final-validation`,
    `/pack-gap-audit` should reference `pack-gap-completion`, `/ulak-intake` could reference `research-currency`.
    Or document in AGENTS.md that skills are Skill-tool-invoked not command-invoked.
  validation: "Each skill is named in at least one command OR documented as Skill-tool-invoked in AGENTS.md."
  owner: prompt-skill-plugin-governor
  depends_on: []
  tags: [quick-win, discoverability]

- id: FIND-PG-05
  area: prompt
  title: "plugin-skill-decision.md has 6 unit types but rule-pack is missing (ajanscan G-01)"
  problem: |
    `docs/governance/plugin-skill-decision.md:1-11` lists: command, agent, skill, hook, MCP, plugin. It
    does NOT include rule-pack (always-on <500-byte imperative guardrails). This is the G-01 gap identified
    in ajanscan-pattern-extraction.md Bucket 3.
  evidence: "docs/governance/plugin-skill-decision.md:1-11"
  evidence_source: "Phase 1 spot-check, confirmed"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "Ulak OS has no category for ajanscan-style rules/ guardrails. When a consumer project needs always-on stack-specific rules, there's no guidance on whether to use a hook (deterministic, one-shot), a skill (triggered workflow), or something else. Ajanscan had to invent the pattern itself."
  severity: High
  priority: P1
  recommended_fix: "Extend plugin-skill-decision.md to 7 entries, add `rule-pack → always-on stack-specific imperative guardrails (<500B)`. Create `docs/governance/rule-pack-governance.md` and `docs/runtime/rule-packs/*.md` starter directory. Merges with ajanscan G-01 + G-EXT-03."
  validation: "grep -c '^\\- ' docs/governance/plugin-skill-decision.md returns ≥7; docs/runtime/rule-packs/ directory exists with 4 starter files."
  owner: prompt-skill-plugin-governor
  depends_on: []
  tags: [foundational, governance-gap, ajanscan-inherited]

- id: FIND-PG-06
  area: prompt
  title: "security-redteam persona vs red-team-challenger specialist — no overlap discipline documented"
  problem: |
    Both agents exist. security-redteam (persona, 66L, exploit-scenario lens per .claude/agents/security-redteam.md:1-66)
    and red-team-challenger (specialist, 31L, adversarial-reviewer lens per .claude/agents/red-team-challenger.md:1-31).
    The persona file's §15-19 says "security-hardening-lead catalogs... security-redteam constructs specific exploits" —
    a clean separation. But red-team-challenger is framed more generally, and the overlap between the two red-team
    agents is NOT documented anywhere.
  evidence: ".claude/agents/security-redteam.md:15-19 vs .claude/agents/red-team-challenger.md:9-11"
  evidence_source: "Direct file comparison"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "When the director dispatches both in Phase 2, their findings overlap unpredictably. The persona-dispatch-pattern.md §19 says persona-specialist overlap is a consensus signal, but it doesn't distinguish red-team-challenger from security-redteam — so overlap between these two specifically isn't a signal, it's duplication."
  severity: Medium
  priority: P2
  recommended_fix: "Add a 'Red-team lanes' subsection in `docs/runtime/persona-dispatch-pattern.md` explicitly splitting (a) red-team-challenger = plan/assumption adversary, (b) security-redteam = exploit-scenario constructor, (c) security-hardening-lead = control cataloger. Three distinct lenses."
  validation: "The three agents' descriptions reference this three-way split."
  owner: prompt-skill-plugin-governor
  depends_on: []
  tags: [quick-win, agent-discipline]
```

### Specialist 2: architecture-lead (runtime doc coherence, layer discipline)

```yaml
- id: FIND-AL-01
  area: architecture
  title: "Phase numbering is contradictory across 6+ runtime/governance docs"
  problem: |
    `docs/runtime/program-phases.md` defines phases as 0,1,2,3,4,4.5,5(pack-gen),6(execution),7(validate),8(finalize).
    BUT the rest of the pack ships with Phase 5 = manager-verdict:
    - artefact-contract.md:44 "Phase 5 — Final verdict"
    - validation-result-schema.md:5,82 "Phase 5 (manager-verdict)"
    - autonomous-program-director.md (dispatched agent) runs Phase 0→5 with 5=verdict
    - output-profiles.md:126 says "Phase 4 synthesis ... Phase 5 can finalize the verdict"
    - adapters/claude-code.md:10, gemini-cli.md:16, codex-cli.md:13 all say "Phase 0 → Phase 5"
    - artefact-write-authorization.md:54,58 says Phase 5=verdict, Phase 6=execution
    - finding-schema.md §Phase 5 weights residual risks at verdict
    - handoff-plan-contract.md:89,133-134 says Phase 5=verdict
    - live-probe-contract.md:9,110 says Phase 4.5 runs before Phase 5 verdict.
    Meanwhile program-phases.md:129 says Phase 5=Pack/file generation, Phase 6=Execution, Phase 7=Validate, Phase 8=Finalize.
    The docs are using two incompatible numbering systems.
  evidence: |
    Numbering A (Phase 5 = verdict): artefact-contract.md:44; validation-result-schema.md:5,82;
    output-profiles.md:126; adapters/claude-code.md:10,39; adapters/gemini-cli.md:16,44,47;
    adapters/codex-cli.md:13,37; governance/artefact-write-authorization.md:54,58; governance/finding-schema.md
    (Phase 5 weighting); governance/evidence-trust-scoring.md:48; runtime/live-probe-contract.md:9,110;
    runtime/handoff-plan-contract.md:89,133-134; .claude/agents/autonomous-program-director.md (whole);
    .claude/commands/director.md:16-40 artefact chain.
    Numbering B (Phase 5 = pack-gen, Phase 8 = verdict):
    runtime/program-phases.md:129,144,166,181; runtime/toolchain-precheck.md:9,108 (Phase 7 revalidate).
  evidence_source: "Grep of 'Phase 5|Phase 6|Phase 7|Phase 8' across docs/"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: direct
  impact: |
    CRITICAL COHERENCE FAILURE. Two numbering systems coexist in the v2.1.2 pack. Any specialist or
    adapter implementation that reads program-phases.md will disagree with any reader of the other 11
    docs. CI/validation scripts that rely on phase numbers will break. Dual-platform adapter output
    will drift between claude-code (numbering A) and a future codex reader that goes to program-phases
    (numbering B). Every sentence in program-phases.md §125 "Phase 5 cannot set signoff_status:
    ready" is internally inconsistent — that line uses Numbering A inside Numbering B.
  severity: High
  priority: P0
  recommended_fix: |
    Pick one numbering. Strong recommendation: Numbering A (Phase 5 = manager-verdict) because:
    (1) 11+ docs already use it, including all adapters and the director agent itself;
    (2) "Phase 0 → Phase 5" is the user-facing shape shipped in commands;
    (3) Numbering B only lives in one file (program-phases.md).
    Refactor program-phases.md to:
    - Phase 0 Environment lock (unchanged)
    - Phase 1 Deep inventory
    - Phase 2 Parallel specialist evidence
    - Phase 3 Non-obvious findings
    - Phase 4 Synthesis
    - Phase 4.5 Live probe (conditional-mandatory, unchanged)
    - Phase 5 Final verdict (current line 181's content)
    Move the current "Phase 5 Pack/file generation" content to either (a) a profile-specific Phase 4
    sub-phase when PACK_GENERATION_PROFILE is active, or (b) a named sibling artefact like
    `docs/runtime/pack-generation-protocol.md`. Move "Phase 6 Execution (waves)" content to a sibling
    `docs/runtime/execution-phase-protocol.md` keyed to Waves pattern.
    Move "Phase 7 Validate" content inline into Phase 5 (validate IS part of the verdict gate) OR
    keep as Phase 5.5. But do NOT keep the current Phase 7 number.
  validation: "grep -n 'Phase [678]' docs/ returns zero results for active runtime files."
  owner: architecture-lead
  depends_on: []
  tags: [foundational, coherence-bug, blocker]

- id: FIND-AL-02
  area: architecture
  title: "claude-code adapter Phase table says 'Phase 5 — Final verdict' but program-phases.md says Phase 8"
  problem: |
    Sub-case of FIND-AL-01 but worth a separate entry because it's the user-facing adapter. `docs/adapters/claude-code.md:29-34` ships a table that tells consumers to expect a 6-phase program (0→5). Program-phases.md tells the director to run 9 phases (0→8). The adapter is the front-door doc; it's the one a new Claude Code user would trust first.
  evidence: "docs/adapters/claude-code.md:10,29-34,39 vs docs/runtime/program-phases.md:1-215"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: direct
  impact: "New users following claude-code.md run a different program than the director agent is actually configured to deliver."
  severity: High
  priority: P0
  recommended_fix: "Fix via FIND-AL-01 (pick Numbering A, refactor program-phases.md). After that, claude-code.md is already correct and needs no edit."
  validation: "Adapter phase table matches program-phases.md phase names 1-for-1."
  owner: architecture-lead
  depends_on: [FIND-AL-01]
  tags: [foundational, adapter-coherence]

- id: FIND-AL-03
  area: architecture
  title: "docs/runtime/office-roster.md is referenced by program-phases.md:48 but NOT imported by core contract"
  problem: |
    Core contract (`prompts/core/ulak-os-core-contract-2.0.0.md:10-34`) imports 15 runtime rules + 7 operational motors. `office-roster.md` is NOT in the @-tree. But `program-phases.md:48` (which IS imported) says "see the office roster in `docs/runtime/office-roster.md`". So the core contract depends on office-roster at runtime without importing it, meaning the file is only available to human readers who navigate to it — not to the model context.
  evidence: "prompts/core/ulak-os-core-contract-2.0.0.md:10-34 (no office-roster import) + docs/runtime/program-phases.md:48 (cross-reference)"
  evidence_source: "Import graph analysis"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "The director agent decides which specialists to dispatch based on office-roster.md. If the file isn't loaded, the director has to regenerate the roster from memory — drift risk."
  severity: Medium
  priority: P1
  recommended_fix: "Add `@docs/runtime/office-roster.md` to the core contract's Runtime rules layer (after `@docs/runtime/router.md` or near `@docs/runtime/analysis-contexts.md`)."
  validation: "grep '@docs/runtime/office-roster' prompts/core/ulak-os-core-contract-2.0.0.md returns 1 match."
  owner: architecture-lead
  depends_on: []
  tags: [quick-win, import-graph]

- id: FIND-AL-04
  area: architecture
  title: "autonomy-pressure-layer.md is an orphan (10L stub, unreferenced in active docs)"
  problem: |
    `docs/governance/autonomy-pressure-layer.md` is 10 lines, not imported by the core contract, and only referenced in archived bootstrap scripts (`docs/archive/internal-releases/1.8.0-*.py`). The content ("kill menu loops, prefer forward-only progress") is duplicated inline in CLAUDE.md runtime defaults and in autonomous-program-director agent front-matter.
  evidence: "docs/governance/autonomy-pressure-layer.md:1-10 + grep 'autonomy-pressure-layer' hits only archive"
  evidence_source: "Direct read + grep"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "Doc surface bloat. A governance file exists but nothing loads it. Either retire or integrate."
  severity: Low
  priority: P3
  recommended_fix: "Delete the file OR (preferred) flesh it out to a full governance doc and import it in the core contract. Given the subject (autonomy discipline) is already covered by the 'Hard rules' in program-phases.md and the director agent, deletion is cleaner. Move content to `docs/history/` as a lineage note."
  validation: "grep -r autonomy-pressure-layer docs/ returns 0 or matches only new integration."
  owner: architecture-lead
  depends_on: []
  tags: [quick-win, doc-cleanup]

- id: FIND-AL-05
  area: architecture
  title: "docs/i18n/en/ and docs/i18n/tr/ are empty directories — i18n infra is staged but unpopulated"
  problem: |
    `docs/i18n/` contains empty `en/` and `tr/` subdirectories. The bilingual infrastructure is set up
    (README.en.md / README.md / CLAUDE.en.md / CLAUDE.md / GEMINI.en.md / GEMINI.md / AGENTS.en.md /
    AGENTS.md pairs exist at root) but the i18n/ folder itself never got populated. This is a partial implementation.
  evidence: "ls docs/i18n/en/ docs/i18n/tr/ returns empty + root-level paired files exist (inventory §1)"
  evidence_source: "Direct ls"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "Either docs/i18n/ was a planned content directory that was abandoned, or it's a fallback/override target that's empty by design. Without a README or manifest in those folders, the intent is unclear."
  severity: Low
  priority: P3
  recommended_fix: "Add `docs/i18n/README.md` explaining whether the directory is intentionally empty (reserved for consumer-project translation overlays), OR populate with sample translations, OR remove the empty dirs."
  validation: "docs/i18n/ carries either content or a README documenting the empty-by-design state."
  owner: architecture-lead
  depends_on: []
  tags: [quick-win, doc-cleanup]
```

### Specialist 3: cartographer (@-import dependency graph)

```yaml
- id: FIND-CG-01
  area: architecture
  title: "CLAUDE.md imports plugin-skill-decision.md and rule-collision-matrix.md BUT core-contract does NOT"
  problem: |
    CLAUDE.md:6-7 imports plugin-skill-decision.md and rule-collision-matrix.md directly (Layer 1 always-on).
    Core contract imports 9 governance files but NOT those two. This creates a two-level import where the
    two files are loaded via CLAUDE.md but not advertised as part of the core contract's governance surface.
  evidence: "CLAUDE.md:3-7 vs prompts/core/ulak-os-core-contract-2.0.0.md:37-45"
  evidence_source: "Direct read of both imports"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: |
    It works at runtime (CLAUDE.md is the entry point, so both files load) but the core contract is
    advertised as the "canonical runtime surface" and the doc surface-split.md says "Where it lives:
    docs/governance/*.md (active governance)". The two files ARE active governance, but they're imported
    via a back door. Anyone reading only the core contract will underestimate the runtime governance surface.
  severity: Low
  priority: P2
  recommended_fix: "Move `@docs/governance/plugin-skill-decision.md` and `@docs/governance/rule-collision-matrix.md` into the Governance block of the core contract (prompts/core/ulak-os-core-contract-2.0.0.md:37-45). Remove from CLAUDE.md. Single source of import truth."
  validation: "grep '@docs/governance/plugin-skill-decision' prompts/core/ulak-os-core-contract-2.0.0.md returns 1; grep same in CLAUDE.md returns 0."
  owner: cartographer
  depends_on: []
  tags: [quick-win, import-graph]

- id: FIND-CG-02
  area: architecture
  title: "No circular imports detected in the @-tree"
  problem: "None — this is a clean-graph finding."
  evidence: "CLAUDE.md → core-contract-2.0.0 (imports 25 files but no back-reference to CLAUDE.md or to other imports as parent); core-contract files do not @-import each other (each is a leaf)."
  evidence_source: "Manual graph walk of all 25 imports starting from CLAUDE.md"
  evidence_trust: T2
  completeness_risk: medium
  contradiction_status: none
  impact: "Positive finding. Good architectural hygiene."
  severity: Low
  priority: P3
  recommended_fix: "Add an automated CI check that greps for circular imports (scripts/validate-imports.sh already exists — extend it). The current check may only verify presence; need to verify acyclic."
  validation: "CI check in scripts/validate-imports.sh rejects a synthetic circular import."
  owner: cartographer
  depends_on: []
  tags: [quick-win, ci-enhancement]

- id: FIND-CG-03
  area: architecture
  title: "Core contract imports 25 files totaling ~2800 lines — context budget concern"
  problem: |
    prompts/core/ulak-os-core-contract-2.0.0.md imports 15 runtime rules + 7 operational motors + 9 governance
    files = 25 files (note: the 2 via CLAUDE.md direct are on top). Total line count of imported files:
    15×~140 + 7×~110 + 9×~110 ≈ 3600 lines minimum as always-loaded, per context-budget.md Layer 1. But the
    context-budget.md:38-46 itself defines "Operational motors (mode-loaded)" — so the 7 motors should NOT
    be always-on. Yet the core contract imports them unconditionally.
  evidence: "prompts/core/ulak-os-core-contract-2.0.0.md:27-34 labels them 'Operational motors (mode-loaded)' BUT uses plain @-import syntax = always-on"
  evidence_source: "Direct read of core contract + context-budget.md"
  evidence_trust: T1
  completeness_risk: medium
  contradiction_status: direct
  impact: |
    The core contract tells Claude Code to always-load the 7 operational motors even though context-budget
    says they're mode-loaded. Claude Code's @-import is unconditional. This means either (a) the
    'mode-loaded' labeling is aspirational / a manual discipline cue, or (b) there's a later loader that
    the adapter doesn't have. Today every session loads all 7 motors — budget waste on pure security runs,
    pure architecture runs, etc.
  severity: Medium
  priority: P1
  recommended_fix: |
    Either (a) relabel the 7 motors as 'always-loaded' (honest about current behavior), or (b) implement
    mode-conditional loading via a dispatcher file that chooses based on router decision. Option (b) is
    larger work; Option (a) is a 1-line relabel. For v2.1.3: do (a) + add a Wave 6 deferral item for (b).
    Alternative: move the motors out of the core-contract @-tree and into a mode-loaded overlay that
    the director loads on demand.
  validation: "Either the label matches the loading behavior (always-on), or the loading mechanism is conditional per router decision."
  owner: cartographer
  depends_on: [FIND-AL-01]
  tags: [foundational, context-budget]

- id: FIND-CG-04
  area: architecture
  title: "docs/runtime/README.md (3 lines) and docs/governance/README.md (3 lines) are navigation stubs only"
  problem: "Both README stubs exist but content is empty/trivial. They're not harmful but they're noise in the inventory. Consumers checking 'what's in docs/runtime/' will expect an index."
  evidence: "docs/runtime/README.md (3L), docs/governance/README.md (3L)"
  evidence_source: "wc -l (inventory §3, §4)"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "Low. Cosmetic."
  severity: Low
  priority: P3
  recommended_fix: "Populate each README with a table of contents pointing to siblings. 10-20 lines each."
  validation: "Both README files are ≥10 lines and list all sibling docs."
  owner: cartographer
  depends_on: []
  tags: [quick-win, cosmetic]
```

### Specialist 4: red-team-challenger (rule collisions, ambiguous directives, failure modes)

```yaml
- id: FIND-RT-01
  area: prompt
  title: "Default system prompt override is scoped to reports/current/** only — but artefact-contract lists deeper paths"
  problem: |
    `docs/governance/artefact-write-authorization.md` overrides the default "no planning docs" rule FOR
    `reports/current/**`. But `docs/runtime/artefact-contract.md:84-90` names optional profile-specific
    artefacts like `design-system.md`, `screen-audit.md`, `question-flow.md` — with no directory prefix
    shown. If a specialist infers these go to `reports/current/design-system/` vs `reports/design-system/`,
    the authorization boundary depends on where they end up. A specialist writing to
    `design-system/MASTER.md` at repo root would be blocked by the default rule despite it being a
    director artefact.
  evidence: "docs/governance/artefact-write-authorization.md (override scope) vs docs/runtime/artefact-contract.md:84-90 (implicit paths)"
  evidence_source: "Direct comparison"
  evidence_trust: T2
  completeness_risk: medium
  contradiction_status: partial
  impact: |
    When ajanscan AG-EXT-01 (Master + per-page design-system output) lands in v2.1.3, the emitted files
    will be design-system/MASTER.md + pages/<page>.md — possibly outside reports/current/. The override
    won't cover them.
  severity: Medium
  priority: P1
  recommended_fix: |
    Artefact-write-authorization.md should either (a) extend the override to all artefact-contract.md
    listed files regardless of their path, or (b) artefact-contract.md should explicitly pin every
    profile-specific file to `reports/current/<name>/`. Option (b) is cleaner.
  validation: "Every file path named in artefact-contract.md starts with reports/current/ OR the override doc explicitly lists exceptions."
  owner: red-team-challenger
  depends_on: []
  tags: [foundational, governance-gap]

- id: FIND-RT-02
  area: prompt
  title: "rule-collision-matrix.md has 7 priorities but no example of a collision being resolved"
  problem: |
    `docs/governance/rule-collision-matrix.md:1-12` lists 7 priorities (Security/legal/privacy →
    Aesthetics). It says "If two goals conflict, choose the higher rule and record the trade-off."
    But it gives ZERO worked examples. A new specialist facing a real collision (e.g., "security says
    rate-limit the endpoint; UX says don't error-429 returning users") has to improvise the application.
    There's no precedent, no sample, no test case.
  evidence: "docs/governance/rule-collision-matrix.md:1-12 total content"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "Specialists resolve collisions inconsistently because the rule is too abstract. A design-system-architect and a security-hardening-lead looking at the same finding can reach different verdicts."
  severity: Medium
  priority: P2
  recommended_fix: |
    Extend rule-collision-matrix.md to ~60-80 lines with: (1) 5-10 worked-example collisions drawn from
    ajanscan and oguzhansert.dev cases, (2) decision template ('State goals A,B / Show which priority
    wins / State the trade-off recorded'), (3) anti-patterns ('never silently pick low-priority for
    aesthetic reasons', 'never invoke the matrix to override an evidence-first finding'), (4) escalation
    path when the matrix itself is ambiguous.
  validation: "rule-collision-matrix.md has ≥5 worked examples and each priority level has a test case."
  owner: red-team-challenger
  depends_on: []
  tags: [foundational, governance-thinness]

- id: FIND-RT-03
  area: prompt
  title: "persona-dispatch-pattern §22 says 'dispatch=both' in the director command — but director.md only documents it, with NO merge-rule"
  problem: |
    persona-dispatch-pattern.md:22 says "A single session can run BOTH in Phase 2: specialists in one
    batch + personas in another batch, merged into the evidence register." director.md:77-80 documents
    the `dispatch=both` argument. But NEITHER doc explains HOW to merge the two evidence streams when
    they overlap. The finding-schema.md §source_personas + §source_specialists are orthogonal fields;
    no rule says which takes precedence when they contradict.
  evidence: "docs/runtime/persona-dispatch-pattern.md:22-23 + .claude/commands/director.md:77-80 + docs/governance/finding-schema.md:31-32"
  evidence_source: "Cross-doc read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "When a run invokes `dispatch=both` and a specialist claims X is fine while a persona claims X blocks a user journey, the director has no doctrine for resolution."
  severity: Medium
  priority: P2
  recommended_fix: "Add 'Merge rule for specialist × persona overlap' subsection to persona-dispatch-pattern.md §158-176 with specific rules: (a) persona impact-framing wins on severity; (b) specialist file:line wins on evidence; (c) overlap is a T-tier consensus boost; (d) contradiction triggers a new NF-* entry in did-you-know."
  validation: "persona-dispatch-pattern.md contains a merge-rule subsection with ≥4 bullets."
  owner: red-team-challenger
  depends_on: []
  tags: [quick-win, merge-rule-gap]

- id: FIND-RT-04
  area: prompt
  title: "autonomous-program-director agent has Phase 0-5 mandated but Phase 4.5 is marked 'conditional-mandatory' — specialists don't know when 4.5 fires"
  problem: |
    `.claude/agents/autonomous-program-director.md` lists Phase 4.5 as conditional-mandatory (required
    when validation-plan §6 has ≥1 probe OR Critical finding has T2/T3 evidence OR destructive action
    against remote). But when a specialist writes their findings, they don't know if Phase 4.5 will fire
    — which changes whether their T2/T3 evidence will be promoted or not. The specialist-dispatch prompt
    doesn't carry the "live-probe-enabled" flag.
  evidence: ".claude/agents/autonomous-program-director.md Phase 4.5 section + propagation instructions §22-28"
  evidence_source: "Direct read"
  evidence_trust: T2
  completeness_risk: medium
  contradiction_status: partial
  impact: "Specialists self-censor to T2 when they could claim T1 with probe promotion, OR over-claim T1 without the probe. The flag is not propagated."
  severity: Medium
  priority: P2
  recommended_fix: "Extend the propagation block in autonomous-program-director.md §17-31 to include the live-probe-enabled flag from active-variables.yaml, so specialists know to carry T-tier honestly with 'promote-if-probed' markers."
  validation: "Dispatch prompt to a specialist includes 'live_probe_enabled: true|false' text."
  owner: red-team-challenger
  depends_on: []
  tags: [quick-win, trust-propagation]

- id: FIND-RT-05
  area: prompt
  title: "`disableSkillShellExecution: false` in settings.json allows skills to run arbitrary shell — no audit discipline"
  problem: |
    `.claude/settings.json:47` sets `disableSkillShellExecution: false`. This means any skill with
    `allowed-tools: Bash` gets shell execution. The 4 shipping skills DO declare Bash in allowed-tools
    (e.g., `project-intake/SKILL.md:6`). There's no audit trail of what shells skills actually run,
    no hook matching Skill invocations, no rate limit, no warn-on-first-run.
  evidence: ".claude/settings.json:47 + .claude/skills/project-intake/SKILL.md:6-7"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "If a consumer of Ulak OS installs a malicious skill (supply-chain attack), the skill executes shell freely. Current hook surface only logs Bash and Edit|Write — it doesn't log Skill invocations."
  severity: Medium
  priority: P2
  recommended_fix: |
    (a) Add a hook for Skill invocations (PreToolUse matcher 'Skill') that appends to .claude/logs/skill.log.
    (b) Consider documenting a 'trusted-skill allowlist' in settings-permissions-governance.md (the
    G-04 doc pending from ajanscan).
    (c) When shipping skills that call Bash, pin the bash allowlist explicitly in the skill metadata.
  validation: ".claude/settings.json hooks carry a Skill matcher; log file grows on skill invocation."
  owner: red-team-challenger
  depends_on: [FIND-G-04]
  tags: [foundational, security-gap]
```

### Specialist 5: qa-validation-commander (phase-gate enforceability, validation coverage)

```yaml
- id: FIND-QA-01
  area: api
  title: "validation-result-schema.md gates include 10 test types but validation-plan template has no §6 for live probes"
  problem: |
    `validation-result-schema.md:19-29` enumerates 10 test gate types. `live-probe-contract.md:9` says
    Phase 4.5 is mandatory "if validation-plan.md §6 has ≥1 live probe". But the validation-plan.md
    artefact is currently a template-only file (`reports/current/validation-plan.md` was empty before
    this run). There is NO canonical template for validation-plan.md anywhere in docs/ that shows the
    §6 live-probe block. Specialists authoring validation-plan.md have to invent the section structure.
  evidence: "docs/runtime/live-probe-contract.md:9 (§6 reference) + no canonical template found (grep 'validation-plan.md' docs/ shows only integrations)"
  evidence_source: "Grep + direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "Phase 4.5 cannot be gated correctly if §6 doesn't exist or is named differently in different runs."
  severity: High
  priority: P1
  recommended_fix: |
    Add a canonical validation-plan.md template to docs/examples/ (or docs/runtime/) with numbered sections:
    §1 Engineering gates, §2 Test gates, §3 Surface checks, §4 Release gates, §5 Performance gates,
    §6 Live probes (read-only), §7 Post-execution probes. Reference it from live-probe-contract.md.
  validation: "docs/examples/sample-validation-plan.md exists with §6 live-probe section and is referenced from live-probe-contract.md."
  owner: qa-validation-commander
  depends_on: []
  tags: [foundational, template-gap]

- id: FIND-QA-02
  area: api
  title: "CI (ci-validation.yml) doesn't run prompt-regression or golden-set checks from evals/"
  problem: |
    `.github/workflows/ci-validation.yml` runs: schema validation, @-import validation, Claude Ulak brand
    check, AGENTS.md artefact count, version-lineage check. It does NOT run the `evals/` golden set or
    core-assertions. validation-result-schema.md:28 lists `prompt_regression: pass|fail|...` — but CI
    doesn't produce that signal.
  evidence: ".github/workflows/ci-validation.yml:9-57 + evals/{assertions,golden}/ exist + validation-result-schema.md:28"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "Prompt drift across v2.1.x releases is caught only by manual review. A refactor that breaks the finding-schema emission could ship unnoticed."
  severity: Medium
  priority: P1
  recommended_fix: "Extend ci-validation.yml with an 'evals-smoke' job that runs the 3-5 assertions from evals/assertions/core-assertions.md and the 01_full_program_komple.md golden set as a dry-run check. Non-blocking initially (warn), promotable to blocking in v2.2."
  validation: "CI workflow includes an evals-smoke job."
  owner: qa-validation-commander
  depends_on: []
  tags: [foundational, ci-gap]

- id: FIND-QA-03
  area: api
  title: "secret-scan.yml runs gitleaks but NO baseline file — first scan may produce mass false positives"
  problem: |
    `.github/workflows/secret-scan.yml:17-20` runs gitleaks-action@v2 with no custom config, no
    `.gitleaks.toml`, and no baseline. Any historical secret in git history (even rotated) will flag.
  evidence: ".github/workflows/secret-scan.yml:1-20 + no .gitleaks.toml in repo"
  evidence_source: "Direct read + ls repo root"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "Either the CI never fails (quiet) or fails on any historical noise. Hard to tell without a baseline."
  severity: Low
  priority: P2
  recommended_fix: "Add `.gitleaks.toml` with explicit allowlist for example values in docs and tests; generate a `.gitleaks.baseline` with current state; reference both in the workflow."
  validation: "CI passes with current tree AND fails on a newly-inserted test secret."
  owner: qa-validation-commander
  depends_on: []
  tags: [quick-win, ci-hardening]

- id: FIND-QA-04
  area: api
  title: "AGENTS.md CI check requires '≥12 reports/current/ entries' but inventory says 14 are in the chain"
  problem: |
    `ci-validation.yml:42-47` asserts `grep -c 'reports/current/' AGENTS.md >= 12`. Currently AGENTS.md
    has 16 matches. artefact-contract.md:20-46 lists 12 Phase-0-to-5 artefacts plus optional ones = 14+.
    The magic number 12 in CI is a stale floor from before handoff-plan-contract and live-probe-results
    were added.
  evidence: ".github/workflows/ci-validation.yml:44 + artefact-contract.md:20-46"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "CI can silently pass when the artefact chain degrades by 4 entries. The gate is too lenient."
  severity: Low
  priority: P2
  recommended_fix: "Raise the ci threshold from 12 to 14 (current minimum matching artefact-contract.md §Phase 0-5 mandatory count). Consider computing the expected count from artefact-contract.md itself in CI (dynamic floor)."
  validation: "CI threshold matches artefact-contract.md's enumerated mandatory count."
  owner: qa-validation-commander
  depends_on: []
  tags: [quick-win, ci-drift]
```

### Specialist 6: localization-i18n-lead (Turkish + locale support in Ulak's own output)

```yaml
- id: FIND-LOC-01
  area: localization
  title: "Output profile definitions (AUDIT, GREENFIELD, etc.) have NO locale field — director can't pick Turkish vs English for its own artefacts"
  problem: |
    `docs/runtime/output-profiles.md:24-115` lists required sections for 7 profiles. None of them
    declares an output language field. When the director writes `manager-verdict.md`, should it be
    Turkish or English? The runtime defaults in CLAUDE.md:14-19 are in Turkish but the finding-schema.md
    field values are English. Ajanscan extraction ended up mixing Turkish and English.
  evidence: "docs/runtime/output-profiles.md:24-115 + CLAUDE.md:14-19 + docs/runtime/localization-strategy.md:110L"
  evidence_source: "Cross-doc read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "Inconsistent output language across artefacts and runs. A Turkish operator gets English verdicts with Turkish findings embedded."
  severity: Medium
  priority: P1
  recommended_fix: |
    Add `output_language: auto|tr|en` field to active-variable-contract.md and to each output profile.
    Default 'auto' = infer from the user's last message. When mixed, pin language per artefact (verdict
    in operator language, finding YAML keys in English as a schema).
  validation: "active-variable-contract.md has OUTPUT_LANGUAGE field; 7 profiles each have a language-handling note."
  owner: localization-i18n-lead
  depends_on: []
  tags: [foundational, localization-gap]

- id: FIND-LOC-02
  area: localization
  title: "turkish-normalization.md is imported as operational motor — but loaded unconditionally"
  problem: |
    Related to FIND-CG-03. `docs/runtime/turkish-normalization.md` (126L) is in the 'Operational motors
    (mode-loaded)' block of the core contract but actually loads every session. If a session audits an
    English-only Japanese-market fintech, Turkish normalization rules are still in context.
  evidence: "prompts/core/ulak-os-core-contract-2.0.0.md:32 (unconditional @-import)"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: direct
  impact: "Context budget waste on non-Turkish projects."
  severity: Low
  priority: P2
  recommended_fix: "Part of FIND-CG-03 fix. Mode-load turkish-normalization.md only when output_language includes tr OR project content triggers it."
  validation: "A non-Turkish run's active-variables.yaml shows overlays_loaded NOT containing turkish-normalization."
  owner: localization-i18n-lead
  depends_on: [FIND-CG-03]
  tags: [foundational, mode-loading]

- id: FIND-LOC-03
  area: localization
  title: "docs/examples/sample-*.md ships tr+en pairs but there's no cross-language consistency checker"
  problem: |
    `docs/examples/` has 6 files in tr+en pairs: sample-intake.md, sample-intake.en.md, sample-inventory,
    sample-manager-verdict. No tool verifies the en.md version matches the tr.md version's structure.
    Drift in examples is a silent failure mode.
  evidence: "ls docs/examples/ returns 6 files (sample-*.md + sample-*.en.md)"
  evidence_source: "Inventory §12"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "Examples in English can diverge from Turkish over time. New contributors seeing only one language get an incomplete view."
  severity: Low
  priority: P3
  recommended_fix: "Add a scripts/validate-bilingual-examples.sh that checks each pair has the same section headers (H1/H2 count and order). Run in CI."
  validation: "Script passes on current tree, fails when a section is added to tr version only."
  owner: localization-i18n-lead
  depends_on: []
  tags: [quick-win, ci-enhancement]
```

### Specialist 7: security-hardening-lead (settings.json, MCP allowlist, secrets-in-docs)

```yaml
- id: FIND-SEC-01
  area: security
  title: "settings.local.json is modified+uncommitted BUT .gitignore does NOT exempt it from git tracking"
  problem: |
    `.gitignore` covers `.env`, `.env.*`, secrets/, *.key, *.pem, logs, build artefacts, reports/current/
    contents. It does NOT exempt `.claude/settings.local.json`. This file carries operator-local grants
    (WebFetch domains, specific Bash allowlists, Read paths to sibling projects). If someone runs
    `git add -A` it goes in.
  evidence: ".gitignore:1-28 (no settings.local.json entry) + git status shows 'M .claude/settings.local.json' — NOT untracked"
  evidence_source: "git status + .gitignore read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: |
    Already-tracked file (showing as modified, not untracked) means it has been committed in git history
    at some point. Operator-specific allow-grants are now part of the repo, visible to anyone cloning.
    This is the ajanscan G-04 (settings-permissions-governance) gap realized on Ulak OS itself.
  severity: High
  priority: P0
  recommended_fix: |
    (1) Add `.claude/settings.local.json` to .gitignore.
    (2) `git rm --cached .claude/settings.local.json` to untrack without deleting local copy.
    (3) Ship a `.claude/settings.local.example.json` template so new contributors know the shape.
    (4) Update settings-permissions-governance.md (G-04, pending) with this as a worked example.
  validation: "git ls-files .claude/settings.local.json returns empty; .claude/settings.local.example.json exists."
  owner: security-hardening-lead
  depends_on: []
  tags: [critical, quick-win, self-inflicted]

- id: FIND-SEC-02
  area: security
  title: "settings.local.json grants Bash(cp) and Read(//c/...) permissions to a sibling project (oguzhansert.dev) by absolute path"
  problem: |
    `.claude/settings.local.json:5-10` hardcodes absolute Windows paths to a sibling project:
    'C:/Users/osrt91/desktop/proje/oguzhansert.dev/'. This is an operator-local permission that
    shouldn't be in a shared doc. Related to FIND-SEC-01 (it's tracked anyway).
  evidence: ".claude/settings.local.json:5-10"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "Leak of operator-local project layout. Also: another contributor cloning the repo has these wildcarded grants enabled without knowing."
  severity: High
  priority: P0
  recommended_fix: "Resolved by FIND-SEC-01 (stop tracking the file). Separately: document best practice in the new settings-permissions-governance.md that local absolute paths belong in `.claude/settings.local.json`, never `.claude/settings.json` — the naming convention matters."
  validation: "No absolute operator paths in any tracked config file."
  owner: security-hardening-lead
  depends_on: [FIND-SEC-01]
  tags: [critical, quick-win]

- id: FIND-SEC-03
  area: security
  title: ".mcp.json requires GITHUB_PERSONAL_ACCESS_TOKEN env — acceptable, but no rotation runbook"
  problem: |
    `.mcp.json:4-7` registers the GitHub MCP with `Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}` env expansion.
    This is the correct pattern per mcp-governance.md:55. BUT there's no runbook for PAT rotation,
    no pre-commit hook checking for a literal PAT replacing the env var, no CI detection of the same.
  evidence: ".mcp.json:1-10 + mcp-governance.md (no rotation section)"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "PAT rotation requires manual action. A contributor who expands ${GITHUB_PERSONAL_ACCESS_TOKEN} to a literal token 'just to test' could commit it."
  severity: Medium
  priority: P2
  recommended_fix: "Extend mcp-governance.md with a 'Key rotation rehearsal' section. Add a pre-commit hook in scripts/ that rejects literal bearer tokens in .mcp.json. Related to ajanscan AG-EXT-03 (secrets rotation & history purge)."
  validation: "pre-commit hook rejects staged .mcp.json with a literal bearer token."
  owner: security-hardening-lead
  depends_on: []
  tags: [foundational, ajanscan-extension]

- id: FIND-SEC-04
  area: security
  title: "Hooks in settings.json are logging-only — no actual guardrail enforcement"
  problem: |
    `.claude/settings.json:19-44` declares 3 hooks: PreToolUse(Bash) log, PostToolUse(Edit|Write) log,
    Stop log. None of them block, validate, or gate. The hook-governance.md:27-46 lists 'Guardrails'
    and 'Side effects' as use cases. Ulak OS ships only side-effect hooks. There's no deterministic
    refuse-edit-of-.env hook (even though .env is in the deny list — but that's Read-scoped, not Edit).
  evidence: ".claude/settings.json:19-44 vs hook-governance.md:27-46"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "hook-governance.md preaches guardrails but the reference implementation (Ulak OS itself) doesn't demonstrate one. A consumer cloning Ulak OS as a template inherits only logging hooks."
  severity: Low
  priority: P2
  recommended_fix: "Add a sample guardrail hook: PreToolUse(Edit|Write, matcher:'Write(.env*)' ) that refuses. Or ship a 'hook recipes' doc with 3-5 sample guardrails people can copy."
  validation: ".claude/settings.json has at least 1 blocking hook OR docs/governance/hook-governance.md contains ≥3 copy-paste guardrail recipes."
  owner: security-hardening-lead
  depends_on: []
  tags: [foundational, reference-implementation]
```

### Specialist 8: infra-release-sre (CHANGELOG, version pins, CI, hook health)

```yaml
- id: FIND-INF-01
  area: release
  title: "CHANGELOG is labeled [Unreleased] for v2.1.2 — no release tag issued"
  problem: |
    `CHANGELOG.md:3` opens with "## [Unreleased] — v2.1.2 docs prep continued". All the v2.1.2 content
    is present but no `v2.1.2` release tag in git. Last commit is 4f57d22 "chore(docs): v1.x stale
    reference cleanup". There's no released checkpoint.
  evidence: "CHANGELOG.md:3 + git tag -l (not run but visible from git log)"
  evidence_source: "Direct read"
  evidence_trust: T2
  completeness_risk: low
  contradiction_status: none
  impact: "Consumers cannot install a stable v2.1.2. The 'what's in v2.1.2' story is committed but the distribution state is pre-release forever."
  severity: Medium
  priority: P1
  recommended_fix: |
    After this v2.1.3 audit lands: cut a v2.1.2 tag on the current main (captures the 'docs prep
    complete' checkpoint), then the v2.1.3 work lands on top with a fresh [Unreleased] header.
    OR bundle v2.1.2 content into the v2.1.3 release and document both in one release note.
    Recommend the latter — single release note, cleaner.
  validation: "git tag shows v2.1.2 OR v2.1.3 after release lands; CHANGELOG [Unreleased] header is empty."
  owner: infra-release-sre
  depends_on: []
  tags: [foundational, release-hygiene]

- id: FIND-INF-02
  area: release
  title: "package.json:3 says version 2.0.0 but prompt-pack content is v2.1.x — version split is documented but undiscoverable"
  problem: |
    `package.json:3` = "version": "2.0.0". But CHANGELOG tracks v2.1.0, v2.1.1, v2.1.2, v2.1.3. The
    VERSION_DISTRIBUTION_MATRIX.md:4 explains it ("2.0.0 (Ulak OS) | CLI Console + Memory + Vendor
    Adapters | exact artifact | v1.0.0 prompt pack + TypeScript CLI layer"). But a consumer doing
    `npm info ulak-os` sees 2.0.0 only. The v2.1.x prompt pack content is invisible via the npm surface.
  evidence: "package.json:3 + VERSION_DISTRIBUTION_MATRIX.md:4 + CHANGELOG.md §v2.1.x entries"
  evidence_source: "Direct read of 3 files"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: partial
  impact: "Release signaling is split. Users who install via npm think the product is at 2.0.0. The docs say 2.1.2. After this run ships v2.1.3, the gap grows."
  severity: Medium
  priority: P1
  recommended_fix: |
    Two options:
    (a) Bump package.json to 2.1.3 (treat CLI + prompt-pack as one versioned product). Simpler, more
    truthful, matches most single-repo conventions.
    (b) Keep the split but document at the npm surface via `package.json.keywords` or README that
    "prompt-pack version is in CHANGELOG; npm version tracks CLI only".
    Recommendation: (a) — the split made sense when CLI and pack were separate artefacts; they now
    ship together.
  validation: "package.json version matches the most recent CHANGELOG release header OR README documents the split upfront."
  owner: infra-release-sre
  depends_on: [FIND-INF-01]
  tags: [foundational, versioning]

- id: FIND-INF-03
  area: release
  title: "No dependabot/renovate config — deps pinned at ^major can drift silently"
  problem: |
    `package.json:19-26` pins deps at ^major (better-sqlite3 ^11, chalk ^5.3, commander ^12.1, ora ^8.1,
    vitest ^2.0, typescript ^5.5). No dependabot.yml, no renovate.json. npm will auto-update minors
    during `npm install` on a fresh clone, giving non-reproducible trees. `package-lock.json` helps
    but only if people commit it — which they do, but no CI check verifies the lock is in sync with
    package.json.
  evidence: "package.json:19-26 + no .github/dependabot.yml + no renovate.json"
  evidence_source: "Direct read + ls .github/"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "Reproducibility risk. ajanscan R-04 (pre-push parity) applies: CI should refuse to run if package-lock.json is out of date with package.json."
  severity: Low
  priority: P2
  recommended_fix: |
    (a) Add `.github/dependabot.yml` with weekly updates for npm + github-actions ecosystems.
    (b) Add a CI step `npm ci --dry-run || exit 1` to fail if lock is stale.
    (c) Consider pinning at exact versions in package.json (remove ^) since this is a prompt pack, not
    a library — stability > latest features.
  validation: "CI fails on a synthetic out-of-sync package-lock.json."
  owner: infra-release-sre
  depends_on: []
  tags: [quick-win, supply-chain]

- id: FIND-INF-04
  area: release
  title: "Hooks append to .claude/logs/ — no rotation, no size cap, log files grow unbounded"
  problem: |
    `.claude/settings.json:26,35,42` all do `echo '...' >> .claude/logs/*.log`. No log rotation, no
    size cap, no retention policy. On a long-running dev machine the logs grow forever. Also: logs
    capture potentially-sensitive Bash invocations (which files the model reads). If logs are ever
    shared for debugging, that's a leak surface.
  evidence: ".claude/settings.json:26,35,42"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "Low on disk impact (text logs grow slowly) but non-zero on privacy if logs are shared. Also violates the 'logs must rotate' operational hygiene implied by infra-release-sre discipline."
  severity: Low
  priority: P3
  recommended_fix: |
    Replace each `echo >>` with a small script `scripts/append-log.sh <file> <message>` that does
    size-check-then-rotate (e.g., if log >5MB, rename to log.N and truncate). Or use `logrotate`-compatible
    config. Cheapest fix: add a daily hook on SessionStart that truncates logs older than 14 days.
  validation: "Log file size stays <5MB across 100 synthetic sessions."
  owner: infra-release-sre
  depends_on: []
  tags: [quick-win, hook-hygiene]

- id: FIND-INF-05
  area: release
  title: "CI brand-consistency check on 'Claude Ulak' has long regex allowlist — hard to maintain"
  problem: |
    `.github/workflows/ci-validation.yml:31-39` hardcodes an allowlist of 11 historical file patterns
    where 'Claude Ulak' is permitted. Every time a new historical doc is added, the allowlist needs
    updating. Last commit ('v1.x stale reference cleanup') suggests this was recently exercised.
  evidence: ".github/workflows/ci-validation.yml:31-39"
  evidence_source: "Direct read"
  evidence_trust: T1
  completeness_risk: low
  contradiction_status: none
  impact: "CI surface bloat. Maintenance tax on every release."
  severity: Low
  priority: P3
  recommended_fix: "Move the allowlist into a dedicated file `.github/brand-allowlist.txt` (one regex per line). CI reads the file. Easier to diff-review allowlist changes."
  validation: "ci-validation.yml reads the allowlist from a separate file."
  owner: infra-release-sre
  depends_on: []
  tags: [quick-win, maintainability]
```

---

## Summary — finding counts by specialist

| Specialist | Findings | Critical/High | Medium | Low |
|---|---|---|---|---|
| prompt-skill-plugin-governor | 6 | FIND-PG-02 (High), FIND-PG-05 (High) | 4 | 0 |
| architecture-lead | 5 | FIND-AL-01 (High), FIND-AL-02 (High) | 1 | 2 |
| cartographer | 4 | 0 | 1 | 3 |
| red-team-challenger | 5 | 0 | 5 | 0 |
| qa-validation-commander | 4 | FIND-QA-01 (High) | 1 | 2 |
| localization-i18n-lead | 3 | 0 | 1 | 2 |
| security-hardening-lead | 4 | FIND-SEC-01 (High), FIND-SEC-02 (High) | 2 | 0 |
| infra-release-sre | 5 | 0 | 2 | 3 |
| **Total fresh** | **36** | **7** | **17** | **12** |
| Inherited (ajanscan) | 39 | ~10 critical (flagged in extraction) | — | — |
| **Grand total** | **75** | | | |

Cross-cutting overlap signals (promoting T-tier):
- FIND-AL-01 / FIND-AL-02 / FIND-CG-03 → phase-numbering + context-budget coherence = one root cause
- FIND-SEC-01 / FIND-SEC-02 → settings.local.json tracking = one root cause (critical)
- FIND-PG-05 / FIND-RT-05 / ajanscan G-04 → settings-permissions-governance gap
- FIND-LOC-01 / FIND-LOC-02 / FIND-CG-03 → unconditional motor loading = one root cause
- FIND-INF-01 / FIND-INF-02 → release hygiene
- FIND-RT-03 / FIND-PG-06 → persona vs specialist merge doctrine

All overlaps signal consensus → these findings promote to T1 even if any individual evidence was T2.
