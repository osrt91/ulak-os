# QA Validation Report — pre-v1.0.0-public-GA

## Summary

QA sweep run on 2026-04-21 against C:/Users/osrt91/desktop/proje/ulak.os/ prior to public GA re-tag. Overall verdict: BLOCKED on 2 P0 + 1 P1 finding; 2 P2 cleanup items. Validators green except vendor-parity (1 unexempted gap). Schema, brand (in tracked tree), artefact-chain coverage, pack-unit representation all pass. Version strings consistent across 3 manifests at 2.4.0 (must bump to 1.0.0 in Phase 4).

## Test results

### 1. Validator scripts

| Script | Exit | Result |
|---|---|---|
| scripts/validate-imports.sh | 0 | PASS — All @import references valid; no import cycles. |
| scripts/validate-schemas.sh | 0 | PASS (with 1 warning — Python jsonschema lib absent; fallback parse-only). 12 JSON/TOML files parsed OK. |
| scripts/validate-vendor-parity.sh | 1 | FAIL — gemini:ulak-scaffold MISSING without exemption entry in .github/vendor-parity-exemptions.txt. |

### 2. Schema conformance

Spot-checked 10 embedded YAML blocks in .claude/agents/ (the files that declare finding schemas):

- architecture-lead.md:62-76 — PASS (template; evidence_trust T1|T2|T3 alternation form is informational — allowed)
- backend-api-architect.md:43-68 — PASS (concrete sample, all required fields present)
- data-database-governor.md:43-73 — PASS (RLS finding, T2, Critical/P0, validation probe cited)
- design-system-architect.md:41-72 — PASS (token drift, T2, Medium/P1)
- frontend-ios-flutter-director.md:42-73 — PASS (MOB-005, T2, iOS HIG cited)
- infra-release-sre.md:80-92 — PASS (template, required fields specified)
- prompt-skill-plugin-governor.md:43-74 — PASS (PACK-003, T2, Medium/P1)
- qa-validation-commander.md:42-71 — PASS (QA-004, T2, High/P0, validation citation)
- red-team-challenger.md:42-79 — PASS (RED-002, T2, Critical/P0, 24h deadline)
- security-hardening-lead.md:43-79 — PASS (SEC-002, T2, Critical/P0, anti-pattern match)

Findings: 0. Trust tier form (T0-T7 allowed per schema) is consistently used. No missing required fields (id|area|title|problem|evidence|evidence_trust|severity|recommended_fix|validation). No invalid area or surface value observed.

### 3. Markdown link integrity

96 internal markdown links checked across 16 representative docs. 3 broken:

- docs/FAQ.md:61 — [MIT](./LICENSE) resolves to docs/LICENSE (file lives at repo root; path should be ../LICENSE)
- docs/FAQ.md:65 — [CONTRIBUTING.md](./CONTRIBUTING.md) resolves to docs/CONTRIBUTING.md (should be ../CONTRIBUTING.md)
- docs/FAQ.md:115 — [semantic versioning](./VERSIONING.md) resolves to docs/VERSIONING.md (should be ../VERSIONING.md)

93/96 pass (97%).

### 4. Version consistency

| Manifest | Version | License |
|---|---|---|
| package.json | 2.4.0 | MIT |
| prompts/pack.json | 2.4.0 | MIT |
| .claude-plugin/plugin.json | 2.4.0 | MIT |

PASS. All three in sync at 2.4.0 + MIT. Phase 4 bump to 1.0.0 must update all three.

### 5. Artefact-chain coverage

15 artefact types from prompts/core/ulak-os-core-contract-2.0.0.md Artefakt zinciri. Reference counts across docs/examples/, docs/adapters/, .claude/agents/:

| Artefact | Ref count | Status |
|---|---|---|
| runtime-manifest | 4 | OK |
| assumptions | 5 | OK |
| intake | 12 | OK |
| inventory | 16 | OK |
| evidence-register | 17 | OK |
| deep-scan-report | 5 | OK |
| did-you-know | 7 | OK |
| research-notes | 4 | OK |
| analysis-findings | 7 | OK |
| target-state | 7 | OK |
| execution-roadmap | 8 | OK |
| validation-plan | 10 | OK |
| pack-gap-register | 9 | OK |
| live-probe-results | 2 | OK |
| manager-verdict | 10 | OK |

All 15 artefacts referenced >=1 time. 0 dead contract entries.

### 6. Redaction check

Case-insensitive grep across repo (excluding .git/, node_modules/, dist/):

| Term | Raw hits | In git-tracked files | Verdict |
|---|---|---|---|
| scanner-project | many | 0 | CLEAN (all hits in gitignored reports/current/* + reports/sessions/) |
| trend-platform | 2 | 0 | CLEAN (gitignored) |
| plastics-supplier | 0 | 0 | CLEAN |
| community-platform | 0 | 0 | CLEAN |
| growth-platform | 0 | 0 | CLEAN |
| recipe-platform | 0 | 0 | CLEAN |
| game-platform | 0 | 0 | CLEAN |
| oguzhansert.dev | 14 | 5 tracked + 1 untracked | LEGITIMATE — tracked: LICENSE, package.json, CHANGELOG.md, CODE_OF_CONDUCT.md, .github/ISSUE_TEMPLATE/bug_report.md; untracked dangling: docs/release/v1.0.0-release-notes.md |
| oguzhansert.com | 0 | 0 | CLEAN |

Gitignored surfaces confirmed via git check-ignore -v:
- reports/current/* matched by .gitignore:39
- reports/sessions/ matched by .gitignore:43
- .claude/settings.local.json matched by .gitignore:13

**Note 1**: docs/release/v1.0.0-release-notes.md is untracked but NOT gitignored. Contains info@oguzhansert.dev (maintainer contact — legitimate) but is a dangling file that will be accidentally committed on next git add .

**Note 2**: All oguzhansert.dev refs in tracked files are the maintainer email info@oguzhansert.dev, not project URLs. Legitimate per spec (operator author fields). Beyond LICENSE and package.json the email also appears in 3 other tracked docs — verify this matches the intended authorship-contact policy for public GA.

### 7. Pack-unit representation

| Pack type | Source | Instance count | Status |
|---|---|---|---|
| commands | .claude/commands/*.md | 9 | OK |
| skills | .claude/skills/*/SKILL.md | **8** | **DRIFT** (plugin.json + pack.json declare 9) |
| agents | .claude/agents/*.md | 27 | OK |
| hooks | .claude/settings.json hooks key | 4 phases (SessionStart, PreToolUse, PostToolUse, Stop) | OK |
| sector-packs | docs/runtime/sector-packs.md top-level sections | 7 | OK (pack.json claims 24 — subsections not audited here) |
| rule-packs | docs/runtime/rule-packs/*.md | 8 | OK |
| runtime-rules | docs/runtime/*.md (top-level) | 33 | OK |

All 7 pack-unit types have >=1 instance. Skill-count manifest drift: ulak-design-ref is listed in plugin.json:flagship_skills but has no SKILL.md — only a command file.

---
## Findings

```yaml
- id: QA-001
  area: release
  title: "vendor-parity gap: gemini:ulak-scaffold missing without exemption"
  problem: |
    scripts/validate-vendor-parity.sh exits 1. ulak-scaffold exists for claude
    (.claude/commands/ulak-scaffold.md) but has no gemini equivalent and no
    entry in .github/vendor-parity-exemptions.txt. This is a NEW gap after
    the exemption file was authored (v2.1.4). Public GA with a red CI gate
    on its own flagship validator is a credibility blocker.
  evidence: |
    scripts/validate-vendor-parity.sh stdout (exit 1): "ulak-scaffold ✓ - - MISSING(gemini)"
    .github/vendor-parity-exemptions.txt:31-38 (exemptions declared but ulak-scaffold not listed)
    .claude/commands/ulak-scaffold.md exists
    .gemini/commands/ulak-scaffold.toml does NOT exist
  evidence_trust: T0
  completeness_risk: low
  contradiction_status: direct
  severity: High
  priority: P0
  recommended_fix: |
    Either: (a) port ulak-scaffold to .gemini/commands/ulak-scaffold.toml
    (preferred — scaffolder is a flagship capability advertised in plugin.json)
    OR (b) add a deliberate exemption to .github/vendor-parity-exemptions.txt
    with justification. Option (a) is correct for v1.0.0 GA since scaffolder
    parity was a v2.3.0+ headline.
  validation: |
    bash scripts/validate-vendor-parity.sh exits 0.
    Grep .github/vendor-parity-exemptions.txt for gemini:ulak-scaffold if (b).
  owner: infra-release-sre
  source_specialists: [qa-validation-commander]
  tags: [release, guardrail, ci]

- id: QA-002
  area: prompt
  title: "plugin.json flagship_skills declares ulak-design-ref with no SKILL.md"
  problem: |
    .claude-plugin/plugin.json:106 lists ulak-design-ref as a flagship_skill
    and declares skills: 9 (line 78); prompts/pack.json:9 also declares
    skills: 9. Only 8 SKILL.md files exist under .claude/skills/. ulak-design-ref
    exists only as a command (.claude/commands/ulak-design-ref.md), not as a
    skill. This is manifest drift — public plugin registries will surface
    a skill that does not exist.
  evidence: |
    .claude-plugin/plugin.json:78 skills: 9
    .claude-plugin/plugin.json:97-107 flagship_skills includes ulak-design-ref
    prompts/pack.json:9 skills: 9
    .claude/skills/ listing: 8 entries (no ulak-design-ref/)
    find .claude/skills/ -name SKILL.md returns 8 files
  evidence_trust: T0
  completeness_risk: low
  contradiction_status: direct
  severity: High
  priority: P0
  recommended_fix: |
    Pick one:
    (a) Author .claude/skills/ulak-design-ref/SKILL.md wrapping the command
        design-retrieval workflow (preferred — it IS skill-shaped per
        docs/governance/plugin-skill-decision.md: context-aware + autonomously
        triggered when design refs needed).
    (b) Drop ulak-design-ref from flagship_skills and decrement skills count
        to 8 in both plugin.json and pack.json.
  validation: |
    ls .claude/skills/*/SKILL.md | wc -l matches plugin.json capabilities.skills
    matches prompts/pack.json skills. Re-run scripts/validate-schemas.sh.
  owner: prompt-skill-plugin-governor
  source_specialists: [qa-validation-commander]
  tags: [release, manifest-drift]
- id: QA-003
  area: release
  title: "docs/FAQ.md has 3 broken internal links (path-prefix wrong)"
  problem: |
    docs/FAQ.md uses ./LICENSE, ./CONTRIBUTING.md, ./VERSIONING.md — but
    FAQ.md lives under docs/, so the relative paths resolve to
    docs/LICENSE, docs/CONTRIBUTING.md, docs/VERSIONING.md which do not
    exist. All three files exist at repo root and require ../ prefix.
  evidence: |
    docs/FAQ.md:61  [MIT](./LICENSE)
    docs/FAQ.md:65  [CONTRIBUTING.md](./CONTRIBUTING.md)
    docs/FAQ.md:115 [semantic versioning](./VERSIONING.md)
    Resolved targets (docs/LICENSE, docs/CONTRIBUTING.md, docs/VERSIONING.md) do not exist.
  evidence_trust: T0
  completeness_risk: low
  contradiction_status: direct
  severity: Medium
  priority: P1
  recommended_fix: |
    sed-replace the 3 lines in docs/FAQ.md to use ../ instead of ./ for LICENSE,
    CONTRIBUTING.md, and VERSIONING.md.
  validation: |
    Re-run the link-integrity sweep; 96/96 internal links pass.
  owner: qa-validation-commander
  source_specialists: [qa-validation-commander]
  tags: [quick-win, release]

- id: QA-004
  area: release
  title: "docs/release/v1.0.0-release-notes.md is untracked and dangling"
  problem: |
    The file exists on disk but is not tracked by git. It is NOT in .gitignore.
    Any untrained git add . committer will ship it inadvertently. It contains
    the maintainer email (legitimate) but should be an intentional tracked
    release note (add + commit explicitly) or removed before the v1.0.0 cut.
  evidence: |
    git status: "Untracked files: docs/release/v1.0.0-release-notes.md"
    git check-ignore -v docs/release/v1.0.0-release-notes.md returns exit 1
    docs/release/ ls shows: v1.0.0-release-notes.md present; README.md + v2.1.0-release-notes.md tracked
  evidence_trust: T0
  completeness_risk: low
  contradiction_status: none
  severity: Low
  priority: P2
  recommended_fix: |
    Decide: (a) git add docs/release/v1.0.0-release-notes.md + commit as part
    of the v1.0.0 cut (correct path — the release notes ARE the v1.0.0
    deliverable), OR (b) git rm -f and regenerate from CHANGELOG on tag.
    Option (a) is almost certainly correct.
  validation: |
    git status clean. git log shows file tracked. git check-ignore returns exit 1.
  owner: release-readiness-auditor
  source_specialists: [qa-validation-commander]
  tags: [release, hygiene]

- id: QA-005
  area: prompt
  title: "validate-schemas.sh falls back to parse-only without jsonschema lib"
  problem: |
    scripts/validate-schemas.sh emits a warning: Python jsonschema library
    not found. Falling back to parse-only validation (NOT schema-conforming).
    Exit is still 0. JSON syntactic validity is checked but actual schema
    conformance (claude-code-plugin.json, claude-code-settings.json) is NOT.
    Public GA implies schema-validated; reality is parse-only in CI that most
    operators run locally.
  evidence: |
    bash scripts/validate-schemas.sh stdout lines 1-3 (warning block)
    No scripts/requirements.txt or pyproject.toml pinning jsonschema
  evidence_trust: T0
  completeness_risk: low
  contradiction_status: partial
  severity: Low
  priority: P2
  recommended_fix: |
    Either (a) add pip install jsonschema preamble to the script with graceful
    fallback (current behaviour), but fail CI with exit 2 on GitHub Actions if
    lib absent. OR (b) switch to Node-based validator (ajv) that does not
    require a Python runtime. Preferred: pin jsonschema in scripts/requirements.txt
    + invoke in .github/workflows/validate.yml so CI is strict, local is lenient.
  validation: |
    GitHub Actions workflow for validate-schemas runs with full conformance.
    Local script still usable without Python dep (fallback preserved).
  owner: infra-release-sre
  source_specialists: [qa-validation-commander]
  tags: [ci, guardrail]
```

## Signoff verdict

```yaml
signoff_status: blocked
blocking_findings: [QA-001, QA-002]
conditional_findings: [QA-003]
cleanup_findings: [QA-004, QA-005]
justification: |
  Two P0 findings must clear before v1.0.0 public GA tag:
  (1) QA-001 — scripts/validate-vendor-parity.sh exits non-zero; public GA
      cannot ship a red CI gate on its own flagship validator.
  (2) QA-002 — plugin.json advertises 9 skills but only 8 exist on disk;
      public plugin registries will surface a broken skill reference.
  QA-003 (FAQ link rot) is one-line fix and should ship with the release.
  QA-004 (untracked release notes) is the release-cut hygiene item — trivial
  but must be resolved deliberately, not accidentally.
  QA-005 (schemas parse-only) is not a blocker but is residual risk — document
  clearly and address in v1.0.1 patch.
autonomous_program_director_note: |
  This verdict is evidence-based from scripts executed locally on 2026-04-21.
  Final ship decision owned by autonomous-program-director per
  specialist-discipline rule. All findings carry file:line citations at
  T0 (runtime observation) trust tier.
```
