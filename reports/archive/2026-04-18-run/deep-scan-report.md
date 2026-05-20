# Deep Scan Report — Ulak OS self-audit (merged, severity-ranked)

**Date**: 2026-04-18
**Run id**: director-komple-ulakos-self-audit
**Merge method**: specialist + persona overlap boost per `docs/governance/finding-schema.md` §Merge rule; consensus across ≥2 specialists promotes T-tier by one level (T2→T1).

**Total merged findings**: 75 (39 inherited from ajanscan extraction + 36 fresh on Ulak OS itself).

This report is the **ranked narrative view**. Raw per-specialist bullets live in `evidence-register.md`.

---

## §1 — Critical band (hardstop; must close in v2.1.3)

No Critical-severity findings on Ulak OS itself. **BUT** the following High-severity items are effectively P0 blockers for v2.1.3 readiness and would be Critical in a production SaaS context:

### M-01 — Self-inflicted settings leak (FIND-SEC-01 + FIND-SEC-02 merged)
**Evidence**: `.gitignore:1-28` does not exempt `.claude/settings.local.json`; the file is currently tracked and modified with operator-local absolute paths to a sibling project (`C:/Users/osrt91/desktop/proje/oguzhansert.dev/`).
**Trust**: T1 (direct git status + file read).
**Impact**: Operator-local grants and absolute paths are committed to the public repo. Anyone cloning inherits cross-project permissions. This is the ajanscan G-04 gap realized on Ulak itself.
**Fix sequence**:
1. Add `.claude/settings.local.json` to `.gitignore` (1-line diff).
2. `git rm --cached .claude/settings.local.json` (untrack, keep local).
3. Ship `.claude/settings.local.example.json` (safe template).
4. Write `docs/governance/settings-permissions-governance.md` (the pending G-04).
**Severity (merged)**: High, P0 — this is the only "already-broken" item on Ulak OS today.
**Time sensitivity**: no fixed deadline, but the file is modified-uncommitted right now; next `git add -A` makes it worse.

### M-02 — Phase numbering contradiction (FIND-AL-01 + FIND-AL-02 merged, cross-cutting 11+ docs)
**Evidence**: Numbering A (Phase 5 = manager-verdict) lives in 11+ docs including all adapters, the director agent, artefact-contract, validation-result-schema, finding-schema, live-probe-contract, handoff-plan-contract, and the output-profiles. Numbering B (Phase 5 = pack-gen, Phase 8 = verdict) lives only in `program-phases.md` but is cross-referenced from `toolchain-precheck.md:9,108`.
**Trust**: T1 (grep + file reads).
**Impact**: Coherence failure. A future codex-cli or gemini-cli reader following the import tree reaches program-phases.md and runs a different protocol than the adapter front-door doc promised. CI scripts that encode phase numbers break. Specialists confuse "Phase 4.5" position.
**Fix**: Adopt Numbering A. Refactor program-phases.md. Move Phase 5 pack-gen into a PACK_GENERATION_PROFILE sub-phase. Move Phase 6 execution and Phase 7 validate into sibling docs (or collapse validate into Phase 5 gate + Phase 5.5 if needed).
**Severity (merged)**: High, P0.

### M-03 — Persona agents shipped but persona-dispatch-pattern.md says "Pack Gap" (FIND-PG-02)
**Evidence**: `.claude/agents/{customer,admin,bayi,security-redteam,support,developer,compliance}-persona.md` all exist (commit c21204b per CHANGELOG:64). But `docs/runtime/persona-dispatch-pattern.md:164` says "NOT yet shipped in Ulak OS 2.1.x".
**Trust**: T1.
**Impact**: Users relying on persona-dispatch-pattern.md believe persona dispatch is unusable. They won't invoke `dispatch=persona` or `dispatch=both`.
**Fix**: 2-line edit in persona-dispatch-pattern.md:164-165.
**Severity (merged)**: High, P0 — adoption blocker for a shipped feature.

### M-04 — Validation-plan template missing §6 (FIND-QA-01)
**Evidence**: `live-probe-contract.md:9` makes Phase 4.5 conditional on "validation-plan.md §6 has ≥1 live probe". No canonical template for validation-plan.md exists. Specialists inventing it produce inconsistent section numbering; Phase 4.5 trigger becomes unreliable.
**Trust**: T1.
**Impact**: Phase 4.5 gate cannot be enforced deterministically.
**Fix**: Ship `docs/examples/sample-validation-plan.md` with §6 Live-probes section; reference from live-probe-contract.md.
**Severity (merged)**: High, P1.

### M-05 — rule-pack unit type missing from plugin-skill-decision (FIND-PG-05 = ajanscan G-01)
**Evidence**: `docs/governance/plugin-skill-decision.md:1-11` lists 6 units, no rule-pack.
**Trust**: T1 (direct read + ajanscan evidence consensus = T1 promotion).
**Impact**: Consumer projects needing always-on stack-specific rules have no doctrine.
**Fix**: Extend plugin-skill-decision.md to 7 units; create `docs/governance/rule-pack-governance.md`; create `docs/runtime/rule-packs/{typescript-nextjs,python-fastapi,docker-compose,api-security}.md`.
**Severity (merged)**: High, P1.

---

## §2 — High-severity band (ship in v2.1.3)

### Security & governance — new (6 items)
- **SEC-03** — PAT rotation runbook missing in mcp-governance.md (FIND-SEC-03). Medium-promote-to-High via overlap with ajanscan AG-EXT-03 (secrets rotation).
- **SEC-04** — Ulak OS ships only logging hooks, no guardrail example (FIND-SEC-04). Reference implementation doesn't demonstrate what hook-governance.md preaches.
- **G-04 pending** — settings-permissions-governance.md (the doc that would have caught SEC-01/02 if it existed). Inherited from ajanscan Bucket 4.
- **G-05 pending** — lock-file-hygiene.md. Inherited.
- **G-06 pending** — product-surface-split.md (customer/admin/public/partner vs runtime surface-split). Inherited.
- **G-EXT-01** — mcp-governance audit-trail requirement. Inherited.

### Architecture & runtime — new (8 items)
- **AL-03** — office-roster.md referenced but not imported (FIND-AL-03).
- **CG-01** — plugin-skill-decision + rule-collision-matrix imported via CLAUDE.md not via core contract (FIND-CG-01).
- **CG-03** — Operational motors labeled "mode-loaded" but @-imported unconditionally (FIND-CG-03). Consensus with FIND-LOC-02.
- **RT-01** — artefact-write-authorization override scope narrower than artefact-contract.md paths (FIND-RT-01).
- **RT-03** — dispatch=both missing merge-rule doctrine (FIND-RT-03).
- **LOC-01** — output-profiles.md has no language field (FIND-LOC-01).
- **R-01 through R-05** — 5 inherited runtime rules (strangler-fig, multi-agent-merge-sequence, 14-dim audit, pre-push parity, deploy resilience).

### Release & CI — new (3 items)
- **INF-01** — CHANGELOG [Unreleased] for v2.1.2; no release tag (FIND-INF-01).
- **INF-02** — package.json 2.0.0 vs prompt-pack v2.1.x version split (FIND-INF-02).
- **QA-02** — CI doesn't run evals/ golden set (FIND-QA-02).

---

## §3 — Medium-severity band (ship in v2.1.3 if capacity allows)

### Prompt / agent discipline (5 items)
- **PG-01** — 18 specialist agents are 31-line shells (FIND-PG-01).
- **PG-03** — 4 light commands lack phase-subset documentation (FIND-PG-03).
- **PG-06** — red-team-challenger vs security-redteam lane split not documented (FIND-PG-06).
- **RT-02** — rule-collision-matrix has no worked examples (FIND-RT-02).
- **RT-04** — live-probe-enabled flag not propagated to specialists (FIND-RT-04).
- **RT-05** — `disableSkillShellExecution: false` + no Skill audit hook (FIND-RT-05).

### Governance extensions (inherited)
- **G-01 through G-03** — rule-pack-governance, AI-provider-allowlist, pattern-import-ledger.
- **G-EXT-02 through G-EXT-04** — memory-hygiene worktree cleanup, plugin-skill-decision rule-pack entry, prompt-supply-chain cross-link.

### Sector packs (inherited, 7 entries)
- **SP-01** multi-tenant-supabase
- **SP-02** container-orchestrating-app
- **SP-03** payment-integrated-saas (open question: new pack vs fintech sub-pattern — resolved in target-state)
- **SP-04** regulated-saas (open question: one pack with 3 variants vs 3 packs — resolved in target-state)
- **SP-05** reseller-enabled-saas
- **SP-06** vps-nginx-compose-topology
- **SP-EXT-01** saas pack extension: web-quality-scanner sub-pattern

### Anti-patterns (inherited, 9 entries)
- AP-01 through AP-09 from ajanscan bucket 1.

### Skills / commands / agents (inherited)
- **SK-01/02/03** — god-module-decomposition, fourteen-dimension-audit, multi-agent-orchestration skills.
- **C-01** — triage-build command.
- **AG-EXT-01/02/03** — design-system Master+override contract, autonomous-program-director rule-pack loader, security-hardening-lead secrets-rotation extension.

---

## §4 — Low-severity band (park or backlog)

### Fresh low (11 items)
- **AL-04** autonomy-pressure-layer orphan
- **AL-05** docs/i18n/ empty directories
- **CG-02** no circular imports (positive finding, CI enhancement opportunity)
- **CG-04** README stubs are 3-line navigation placeholders
- **LOC-02** turkish-normalization always loaded (depends on CG-03 fix)
- **LOC-03** bilingual example drift check missing
- **QA-03** gitleaks without baseline
- **QA-04** AGENTS.md artefact count CI floor stale (12 vs real 14)
- **PG-04** skills under-referenced in commands
- **INF-03** no dependabot
- **INF-04** unbounded log growth
- **INF-05** CI brand allowlist hardcoded in workflow

### Inherited low (D-01..D-03)
- D-01 ulak-design-intelligence-mcp (deferred to v2.2)
- D-02 orchestrator-coordinator agent (6 open questions — resolved in target-state)
- D-03 security-secrets-auditor agent (resolved in target-state)

---

## §5 — Cross-cutting themes (meta-findings)

### Theme A — Doc drift outpaced by velocity
FIND-PG-02, FIND-AL-01, FIND-AL-02, FIND-CG-03, FIND-LOC-02, FIND-INF-01, FIND-INF-02 all exhibit the same pattern: the pack shipped features (personas, Phase 4.5, v2.1.2 docs prep, new artefact types) but the integrator docs weren't updated in lock-step. **Root cause**: no automated check for "adding a feature updates its integrator(s)".

### Theme B — Operational motor loading is aspirational
FIND-CG-03 + FIND-LOC-02: the label "mode-loaded" is a documentation cue, not a runtime mechanism. Every Ulak session loads all motors. Cost is acceptable today but will compound as motors grow.

### Theme C — Reference implementation thinness
FIND-PG-01 (agents are 31-line shells), FIND-SEC-04 (hooks are logging-only), FIND-RT-02 (rule-collision has no examples), FIND-CG-04 (README stubs): Ulak OS as a template for consumers underperforms its own governance standards. The prescribed patterns are good; the shipped reference lacks illustration.

### Theme D — Self-inflicted governance gaps
FIND-SEC-01 + FIND-SEC-02 (settings.local.json tracked): Ulak OS ships governance docs about settings.json and MCP, but its own `.gitignore` misses the file the ajanscan extraction flagged. The extracted G-04 would close this; the fact that Ulak failed its own upcoming rule is a signal that v2.1.3 must land G-04 before any other Governance extension.

### Theme E — Inherited ajanscan bundle is dominant
Of 75 merged findings, 39 (52%) are inherited from ajanscan. The v2.1.3 scope is driven by that extraction. Fresh findings on Ulak OS (36, 48%) are mostly doc-drift + reference-thinness, not new architectural directions.

---

## §6 — Severity-priority matrix

|  | P0 (now) | P1 (this release) | P2 (soon) | P3 (backlog) |
|---|---|---|---|---|
| **High** | M-01 SEC-01+02, M-02 AL-01+02, M-03 PG-02 | M-04 QA-01, M-05 PG-05, SEC-03, G-04/05/06 pending, AL-03, CG-03, R-01..R-05, INF-01, INF-02, QA-02, LOC-01 | SEC-04, RT-01 | — |
| **Medium** | — | CG-01, RT-03 | PG-01, PG-03, PG-06, RT-02, RT-04, RT-05, SEC-03, G-01/02/03, G-EXT-01..04, SP-01..06, AP-01..09 | SK-01..03, C-01, AG-EXT-01..03 |
| **Low** | — | — | QA-03, QA-04, INF-03, INF-04, INF-05, PG-04, LOC-03 | AL-04, AL-05, CG-02, CG-04, LOC-02 |

---

## §7 — Entry to Phase 3 (did-you-know)

The findings above are directly derived from evidence (specialist + inherited). Phase 3 surfaces things neither the specialists nor the ajanscan extraction flagged — next-order observations that are real but easily missed. See `did-you-know.md`.
