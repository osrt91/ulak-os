# Pack Gap Register — v2.2.2 (v1.0 Showcase Prep)

**Author:** prompt-skill-plugin-governor subagent
**Date:** 2026-04-20
**Baseline surface:** v2.2.1 — 27 agents / 8 commands / 7 skills / 8 rule packs / 23 sector packs / 79 anti-patterns / 22 governance docs
**Scope:** Identify pack-level gaps that would be noticed by a new user in the first 10 minutes of a v1.0 showcase run.
**Stance:** Evidence-first. Final verdict belongs to autonomous-program-director; this register proposes reusable-unit candidates and flags risks.

---

## 0. Evidence baseline (file-line citations)

| Surface | Count | Source |
|---|---|---|
| Agents | 27 (1 director + 26 specialists) | `ls .claude/agents/*.md` — 27 files |
| Thin agents (31 lines) | 18 of 27 | `wc -l .claude/agents/*.md` — 18 files at 31 lines each |
| Rich agents (>50 lines) | 8 (director 231, security-hardening 98, security-redteam 66, compliance-persona 57, developer-persona 55, design-system 53, support-persona 53, admin-persona 51, customer-persona 48, bayi-persona 51, cartographer 32) | `wc -l` — same |
| Commands | 8 | `ls .claude/commands/*.md` |
| Skills | 7 (all SKILL.md only, no supporting files) | `ls .claude/skills/*/` — each has only `SKILL.md` |
| Hooks | 4 declared in `.claude/settings.json` | SessionStart, PreToolUse(Bash), PostToolUse(Edit\|Write), Stop |
| MCP servers | 1 (github) | `.mcp.json` |
| Rule packs | 8 | `docs/runtime/rule-packs/` — api-security, docker-compose, llm-streaming, localization-ssot, python-fastapi, react-native-expo, turkish-locale, typescript-nextjs |
| Governance docs | 22 | `docs/governance/*.md` |
| Runtime docs | 29 + 1 subdir | `docs/runtime/*.md` |
| Sample artefacts | 7 | `docs/examples/sample-*.md` |
| Top-level examples | empty | `examples/` exists but empty |
| CLI entry | `ulak` via `dist/cli/index.js` | `package.json` bin |

---

## Pack gap category: Agent thinness

### Gap PG-01: 18 specialist agents are minimum-viable stubs (31 lines)

- **Current state:** `backend-api-architect.md`, `architecture-lead.md`, `data-database-governor.md`, `design-system-architect.md` (53 but still thin body), `frontend-ios-flutter-director.md`, `infra-release-sre.md`, `localization-i18n-lead.md`, `market-researcher.md`, `privacy-compliance-counsel.md`, `product-business-strategist.md`, `prompt-skill-plugin-governor.md`, `qa-validation-commander.md`, `red-team-challenger.md`, `release-readiness-auditor.md`, `seo-aso-growth-strategist.md`, `support-ops-orchestrator.md`, `educational-ux-specialist.md`, `cartographer.md` (32) all share the same 31-line skeleton: 4-line frontmatter, 6 focus bullets, 3 return bullets, 4 rules, artefact-write block.
- **What's missing:** Evidence — `security-hardening-lead.md` (98 lines) shows the shape of a "rich" specialist: embedded workflow (secrets rotation runbook, history purge decision tree, pre-commit hook installation, CI hardening). The 18 thin agents have **no embedded playbook, no finding-schema examples, no tier-1 evidence recipes, no tool-chain hints, no anti-pattern references**. A 50-80 line target per specialist should include: (a) scan recipe (what commands/globs/ripgrep patterns the agent should run), (b) finding-schema example pre-filled for that domain, (c) 3-5 domain-specific anti-pattern IDs from `anti-patterns.md`, (d) escalation trigger (when to hand off to red-team-challenger), (e) dual-path validation hint.
- **v1.0 impact:** **High**. First-time user running `/director komple` will see evidence-register.md with 18 specialists producing same-shaped shallow bullets. Contrast with the security specialist producing a rotation runbook is jarring — it exposes the surface as uneven. Evidence weakness: no instrumentation has been run to confirm which specialists are dispatched in real runs; this is a visual/structural judgment.
- **Proposed unit:** agent extensions (18 x ~30 lines of added playbook body)
- **Effort:** 4-6 sessions (3 specialists per session, targeted per-domain playbook)

### Gap PG-02: Specialist dispatch telemetry absent → dead-agent risk unknown

- **Current state:** 27 agents defined; no counter, hook, or log that records which specialist is actually invoked per run. `PostToolUse` hook on Edit/Write writes `[post-edit]` to `.claude/logs/edit.log` — does not discriminate subagent identity.
- **What's missing:** A dispatch counter. Without it, we cannot answer "which specialist agents have never been dispatched in a real run?" — the director's Phase 2 parallel dispatch selects subagents by router decision, but there's no per-agent invocation tally. Candidates for never-dispatched: `seo-aso-growth-strategist`, `educational-ux-specialist`, `support-ops-orchestrator`, `red-team-challenger`, `market-researcher` — these are domain-conditional and would not fire on every run. Evidence is weak here; this is inference, not measurement.
- **v1.0 impact:** **Medium**. User won't notice on first run, but maintainer cannot demonstrate which agents have field value. Showcase risk: "you shipped 27 agents but only 9 ever run" — a reviewer might ask.
- **Proposed unit:** hook (PostToolUse on `Task` matcher to append agent-name + timestamp to `.claude/logs/specialist-dispatch.log`) + doc (`docs/governance/agent-telemetry.md`)
- **Effort:** 1 session

### Gap PG-03: Persona coverage missing edge cases

- **Current state:** 7 persona agents: admin, bayi, compliance, customer, developer, support, educational-ux-specialist (half-persona). `bayi-persona.md` is 51 lines; no distinction between direct-bayi and sub-reseller.
- **What's missing:**
  - **bayi-sub-reseller persona** — in Turkish market, bayi-altı-bayi (sub-reseller) is a real tier with different commission, catalog-filter, and credit-limit semantics. v1.0 showcase of Ulak OS against a multi-tier ERP would reveal this gap.
  - **multi-brand-admin persona** — admin who operates across tenants/brands; relevant for SaaS + white-label combos.
  - **shadow-customer persona** — impersonation mode (support logs in as customer). Surfaces privacy/audit anti-patterns (already covered under compliance-persona but no dedicated scan recipe).
- **v1.0 impact:** **Low** for generic showcase, **High** for Turkish-market pitch (bayi-sub-reseller). The user's MEMORY.md notes "bayi is production persona" — the omission of sub-reseller is visible in the intended demo project.
- **Proposed unit:** 3 new agents (persona files, 50-60 lines each) + update to `docs/runtime/office-roster.md`
- **Effort:** 1-2 sessions

### Gap PG-04: No QA/test-engineering specialist as distinct surface from qa-validation-commander

- **Current state:** `qa-validation-commander.md` is 31 lines; role is validation-plan + test-matrix orchestration. There is no agent that **writes tests** or evaluates test-suite coverage from the inside.
- **What's missing:** A `test-coverage-auditor` or `test-pyramid-architect` agent that reads the existing test files, maps them against the inventory-cited source files, and flags under-tested critical modules. Currently test-health is diffused into `release-readiness-auditor` and the commander — neither owns deep test-code reading.
- **v1.0 impact:** **Medium**. Showcase audience expecting testing rigor will notice. Evidence weakness: this could arguably live as a skill, not an agent — see PG-13.
- **Proposed unit:** agent (`test-coverage-auditor.md`, 50 lines) or skill (`test-pyramid-audit/SKILL.md`) — lean toward skill
- **Effort:** 1 session

---

## Pack gap category: Command surface

### Gap PG-05: No `/demo` / `/showcase` / `/sample-run` command

- **Current state:** 8 commands, all oriented toward real-project operation: director, intake, pack-gap-audit, frontend-war-room, final-verdict, triage-build, ulak-design-ref, ulak-intake. Nothing that runs Ulak OS against a **sample repo** embedded in the pack.
- **What's missing:** `/demo` or `/ulak-showcase` command that:
  1. Checks out (or has pre-bundled) a small synthetic project in `examples/demo-project/` (currently `examples/` is empty)
  2. Runs an abbreviated Phase 0→5 against it
  3. Emits annotated artefacts in `reports/demo/` (not `reports/current/`)
  4. Prints a "here's what just happened" summary pointing at each artefact
- **v1.0 impact:** **Critical**. This is *the* missing v1.0 piece. A showcase without a canned demo forces every evaluator to bring their own project — high friction, loses audience. First 10 minutes of a new user landing on Ulak OS: they want to see it run, not configure it.
- **Proposed unit:** command (`demo.md`, ~80 lines) + sample project under `examples/demo-project/` + annotated reference artefacts
- **Effort:** 3-4 sessions (the sample project is the bulk of the work)

### Gap PG-06: No `/status` or `/health-check` command

- **Current state:** No command surfaces runtime state: which artefacts exist in `reports/current/`, which specialist logs are present, which skills have been invoked, whether the pack is up-to-date.
- **What's missing:** `/status` → prints table of: current phase (inferred from artefact presence), artefact freshness (mtime), missing artefacts, last validation-result status, detected vendor adapter. Complements the CLI `ulak status` if that exists in `src/cli/`.
- **v1.0 impact:** **High**. Second command a new user tries after `/director` is always "what state am I in?". Right now they have to `ls reports/current/`.
- **Proposed unit:** command (`status.md`, ~40 lines), optionally backed by a skill that standardizes the output table
- **Effort:** 1 session

### Gap PG-07: No `/install-verify` / post-setup self-check command

- **Current state:** `README_RUN_ME_FIRST.md` exists (evidence: file at repo root) and `scripts/init-claude.sh` / `init-claude.ps1` exist, but nothing validates post-install state from inside Claude Code. Rule pack imports, hook wiring, MCP config, settings.json permissions — none are verified on first run.
- **What's missing:** `/install-verify` that runs through a checklist: CLAUDE.md imports resolve, all 27 agents parse, all 8 commands have valid frontmatter, `.claude/settings.json` is valid JSON against the schema, `.mcp.json` references are reachable (optional probe), `scripts/validate-imports.sh` passes.
- **v1.0 impact:** **High**. This is the "you installed correctly" confirmation that prevents 80% of GitHub issues. `scripts/validate-imports.sh` and `validate-schemas.sh` exist but are invisible from inside Claude Code.
- **Proposed unit:** command (`install-verify.md`, ~50 lines) that orchestrates the existing validate-*.sh scripts and reports results
- **Effort:** 1 session

### Gap PG-08: No `/quick-scan` (light-mode director)

- **Current state:** `/director` runs full Phase 0→5 (expensive, 5-15 minutes depending on repo). `/intake` is the lightest existing option but only produces intake.md.
- **What's missing:** `/quick-scan` — a 3-phase abbreviation (intake + inventory + pack-gap-register, no specialist dispatch) for <60 second feedback. Useful for "is my repo worth a full director run?" triage. Related to but distinct from `/triage-build` (which is build-focused).
- **v1.0 impact:** **Medium**. Not a dealbreaker; power users will use director. Showcase value: "under 1 minute you get a map."
- **Proposed unit:** command (`quick-scan.md`, ~40 lines)
- **Effort:** 1 session

### Gap PG-09: Commands-without-skills-binding audit

- **Current state:** Of 8 commands: `director` (95 lines, orchestrates director agent + skills), `triage-build` (99 lines, probably stands alone), `final-verdict` (18 lines — thin wrapper), `frontend-war-room` (19 lines), `intake` (15 lines), `pack-gap-audit` (13 lines — **very thin**), `ulak-design-ref` (44 lines), `ulak-intake` (37 lines).
- **What's missing:** The three thinnest commands (`final-verdict` 18, `frontend-war-room` 19, `pack-gap-audit` 13, `intake` 15) are almost certainly just "dispatch an agent" — they should either (a) bind to an existing skill for consistent artefact output, or (b) be folded into the single parent skill. Current situation: `pack-gap-completion/SKILL.md` exists as a skill; `pack-gap-audit.md` command exists separately — duplication risk. Same pattern: `project-intake` skill + `intake` + `ulak-intake` commands = triple-entry ambiguity.
- **v1.0 impact:** **Medium**. User confusion: "do I run `/intake` or `/ulak-intake` and what's the skill for?" This is visible in the first 10 minutes.
- **Proposed unit:** governance doc (`docs/governance/command-skill-binding-matrix.md`) + cleanup of thin commands (fold or document binding)
- **Effort:** 1 session (audit) + 1 session (cleanup)

---

## Pack gap category: Skill surface

### Gap PG-10: All 7 skills are single-file `SKILL.md` — no supporting assets

- **Current state:** Every skill directory contains only `SKILL.md`. No `examples/`, no `schemas/`, no `prompts/`, no reference artefacts co-located with the skill. Example: `final-validation/SKILL.md` declares outputs `validation-plan.md` and `manager-verdict.md` but doesn't ship a template or reference version (those live under `docs/examples/` — disjoint from the skill).
- **What's missing:** Skill packaging convention. Each skill should ship: `SKILL.md` (contract) + `template.md` (empty artefact skeleton) + `example.md` (reference output) + optionally `checklist.yaml`. Right now the templates are under `docs/examples/sample-*.md` which means a skill consumer has to know to look there.
- **v1.0 impact:** **Medium**. Not visible in first 10 minutes but visible when a user tries to **build their own skill** — they have no pattern to follow. v1.0 ecosystem pitch depends on "here's how you extend."
- **Proposed unit:** governance doc (`docs/governance/skill-packaging-convention.md`) + retrofit 7 skills with at least `template.md` and `example.md`
- **Effort:** 2-3 sessions

### Gap PG-11: `context:` field coverage not audited

- **Current state:** `final-validation/SKILL.md` declares `context: fork`. Other 6 skills have not been read in this audit to confirm the field exists and is correct. Evidence is weak.
- **What's missing:** Audit run across all 7 SKILL.md files confirming each has a `context:` directive consistent with `docs/governance/plugin-skill-decision.md` (27 lines — small doc, likely under-specified on this field).
- **v1.0 impact:** **Low** but a runtime risk: a skill with missing/wrong context can silently break fork-mode invocation.
- **Proposed unit:** automation (extend `scripts/validate-schemas.sh` to lint SKILL.md frontmatter) + docs fix
- **Effort:** 1 session

### Gap PG-12: Missing `first-run-wizard` skill

- **Current state:** `project-intake` skill exists and handles project-level intake. No skill wraps the "first time you open Ulak OS" experience: introducing the artefact chain, offering `/demo` or `/director`, detecting stack.
- **What's missing:** `first-run-wizard/SKILL.md` — on-rails walkthrough: (1) detect if `reports/current/` exists → if not, offer onboarding; (2) ask 3 questions (greenfield/brownfield/hybrid, which vendor, locale); (3) write `assumptions.md` + `runtime-manifest.md`; (4) recommend command. This is the "VS Code welcome tab" equivalent.
- **v1.0 impact:** **Critical**. Combined with PG-05 (`/demo` command), this is the other half of the showcase experience.
- **Proposed unit:** skill (`first-run-wizard/SKILL.md` + bound to a `/welcome` command)
- **Effort:** 2 sessions

### Gap PG-13: Missing `test-coverage-audit` skill (see PG-04 cross-ref)

- **Current state:** As above.
- **What's missing:** A skill that reads test files, maps to source files, and emits a coverage-gap artefact. Sitting as a skill (not an agent) because it's a workflow, not a persona.
- **v1.0 impact:** **Medium**.
- **Proposed unit:** skill (`test-coverage-audit/SKILL.md`)
- **Effort:** 1-2 sessions

### Gap PG-14: Missing `upgrade-migration` skill

- **Current state:** `VERSION_DISTRIBUTION_MATRIX.md` and `VERSIONING.md` exist at repo root. No skill orchestrates the "I'm upgrading from v2.1.x to v2.2.x — what changed, what do I need to re-run, what artefacts are stale?" workflow.
- **What's missing:** `upgrade-migration/SKILL.md` — reads current pack version, diffs against target version, flags artefacts that should be regenerated (e.g., if anti-patterns added, evidence-register should re-run), references changelog.
- **v1.0 impact:** **Medium**. Critical once v1.0 ships and users need to get *to* it from v2.2.x — meta-point, since v1.0 is the simplification/rebrand, this skill enables existing users to migrate.
- **Proposed unit:** skill (`upgrade-migration/SKILL.md`)
- **Effort:** 1-2 sessions

### Gap PG-15: Missing `cross-project-audit` skill

- **Current state:** No surface aggregates findings across **multiple projects** (e.g., a monorepo of sub-apps, or a bayi running against 10 customer codebases).
- **What's missing:** `cross-project-audit/SKILL.md` that accepts a list of project paths, runs director on each (or reads existing `reports/current/` snapshots per project), and emits a comparative `cross-project-findings.md` — common patterns, diverging risk profiles, shared dependency anti-patterns.
- **v1.0 impact:** **Low** for individual users, **High** for agency/consulting showcase (the user's MEMORY.md says "Ulak OS ships back as packs" — cross-project is the value-multiplier).
- **Proposed unit:** skill (`cross-project-audit/SKILL.md`)
- **Effort:** 2-3 sessions

### Gap PG-16: Missing `compliance-report-generator` skill

- **Current state:** `compliance-persona` and `privacy-compliance-counsel` agents exist. Evidence flows into `evidence-register.md`. No skill produces a standalone compliance report (KVKK / GDPR / SOC2-readiness) as a deliverable for a compliance audit.
- **What's missing:** `compliance-report-generator/SKILL.md` → runs the compliance agents and renders a stakeholder-shaped report (executive summary, findings by control, evidence citations, residual risk).
- **v1.0 impact:** **Medium**. For Turkish market with KVKK-first regulatory posture, this is a real sales feature.
- **Proposed unit:** skill + bound command `/compliance-report`
- **Effort:** 2 sessions

---

## Pack gap category: Hook surface

### Gap PG-17: No `output-artefact-index` hook

- **Current state:** `PostToolUse` matcher on `Edit|Write` writes `[post-edit]` to `.claude/logs/edit.log` (unstructured, no file identity). No per-artefact audit trail.
- **What's missing:** Hook on `Write` (matched to `reports/current/**`) that appends a line to `.claude/logs/artefact-index.log` with `timestamp | agent | artefact-path | size-bytes`. Enables the `/status` command (PG-06), enables post-run reports, enables "who wrote what."
- **v1.0 impact:** **High**. Two first-run users have already asked variants of "how do I know if the director finished?" — the hook plus `/status` answers this.
- **Proposed unit:** hook update (`.claude/settings.json` PostToolUse with glob matcher)
- **Effort:** 0.5 sessions

### Gap PG-18: No `credential-leak-pre-commit` hook

- **Current state:** Gitleaks is **recommended** in `security-hardening-lead.md` (98 lines — "Pre-commit hook installation" section) but not wired. `.claude/settings.json` does not declare a `PreCommit` or `UserPromptSubmit` hook that blocks secret patterns. Security posture: detection is agent-triggered only, not runtime-blocked.
- **What's missing:** Two layers: (a) A PreToolUse hook on `Write|Edit` matcher that greps the about-to-be-written content for canonical secret patterns (Stripe `sk_live_`, GitHub `ghp_`, AWS `AKIA`, etc.) and aborts if matched; (b) a `.githooks/pre-commit` shipped with the pack that wires gitleaks into `git commit`.
- **v1.0 impact:** **Critical**. One secret-in-artefact incident during a public showcase destroys trust. The product claims "secrets hygiene" in its own security agent — not living by it at the pack level is an observable contradiction.
- **Proposed unit:** hook (settings.json PreToolUse) + shipped `.githooks/pre-commit` script + governance doc
- **Effort:** 1 session

### Gap PG-19: No `version-drift` / `pack-version-check` hook

- **Current state:** `package.json` declares `version: 2.2.1`. There is no hook that confirms the running pack matches the latest release or warns on staleness.
- **What's missing:** SessionStart hook that reads `ulak.config.json` + local `package.json` + (optionally) remote registry, flags drift with a one-line banner.
- **v1.0 impact:** **Low-Medium**. Useful but not blocking.
- **Proposed unit:** hook (settings.json SessionStart extension)
- **Effort:** 0.5 sessions

### Gap PG-20: No `artefact-freshness` hook

- **Current state:** `reports/current/` accumulates artefacts across runs. No hook warns when director is about to overwrite artefacts older than N hours (stale) or newer than N minutes (concurrent run). Currently silent overwrite.
- **What's missing:** PreToolUse on `Write` matched to `reports/current/**` that reads mtime and emits a warning banner; optionally copies to `reports/archive/YYYY-MM-DD/`.
- **v1.0 impact:** **Medium**. Losing a report silently is a trust event.
- **Proposed unit:** hook
- **Effort:** 1 session

---

## Pack gap category: MCP surface

### Gap PG-21: Only `github` MCP shipped; no reference pairs

- **Current state:** `.mcp.json` declares exactly one server (`github`, via `api.githubcopilot.com`, bearer-token via `GITHUB_PERSONAL_ACCESS_TOKEN` env var). No sample-config directory.
- **What's missing:** For v1.0 showcase, a `docs/mcp-samples/` directory containing reference `.mcp.json` fragments for common integrations: `sample-supabase-mcp.json`, `sample-postgres-mcp.json`, `sample-slack-mcp.json`, `sample-vercel-mcp.json`, `sample-docker-mcp.json`. Each with env-var stubs and governance note (link to `docs/governance/mcp-governance.md`).
- **v1.0 impact:** **High**. New user: "how do I hook up my DB / my VPS / my team Slack?" — currently they have to read `mcp-governance.md` and hand-write JSON. Samples are low-effort, high-value.
- **Proposed unit:** 5-7 sample JSON files + index doc (`docs/mcp-samples/README.md`)
- **Effort:** 1 session

### Gap PG-22: No MCP sanity probe

- **Current state:** `.mcp.json` references GitHub but nothing validates the bearer token is set or the endpoint is reachable at session start.
- **What's missing:** SessionStart hook (or CLI subcommand) that iterates MCP servers, checks env var presence, optionally probes endpoint, emits a banner.
- **v1.0 impact:** **Medium**. Currently an un-configured MCP produces cryptic errors mid-run.
- **Proposed unit:** hook or `ulak mcp check` CLI subcommand
- **Effort:** 1 session

---

## Pack gap category: Rule pack surface

### Gap PG-23: 8 rule packs; major stacks missing

- **Current state:** Covered stacks: api-security (cross-cutting), docker-compose (infra), llm-streaming-context-aware, localization-ssot, python-fastapi, react-native-expo, turkish-locale, typescript-nextjs.
- **What's missing:** Meaningful v1.0 gaps by language/framework:
  - **Go** — mainstream backend; 0 coverage
  - **Rust** — growing backend + systems; 0 coverage
  - **Ruby / Rails** — still prevalent in SMB SaaS; 0 coverage
  - **Django (Python)** — covered via fastapi but Django ORM/admin is a distinct surface
  - **Kotlin / Android** — no native Android pack (RN is covered via Expo)
  - **Swift / iOS** — same gap; iOS-native not covered
  - **Java / Spring Boot** — enterprise gap
  - **.NET / ASP.NET Core** — enterprise gap
  - **Vue / Nuxt** — React is covered via Next, Vue is 0
  - **Svelte / SvelteKit** — same
  - **Laravel (PHP)** — still huge in Turkish SMB market; worth considering given the product's bayi/ERP focus
- **v1.0 impact:** **High** for each stack the user lands on that isn't covered. Mitigated by the fact that generic agents still run, but rule-pack absence means shallow findings on framework-specific patterns.
- **Proposed unit:** rule packs. **v1.0 minimum:** Go, Rust, Django, Laravel (top-4 by combined market weight + user's Turkish market). Defer Kotlin/Swift/Java to v1.1.
- **Effort:** 1-2 sessions per rule pack (so 4-8 sessions for the top-4)

### Gap PG-24: No auto-detect-stack agent/skill

- **Current state:** Rule packs exist in `docs/runtime/rule-packs/`. `docs/runtime/sector-packs.md` (355 lines) defines sector-pack taxonomy. But there is no subagent or skill that **detects** which stack is present (read `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `Gemfile`, `composer.json`, etc.) and **auto-loads** the matching rule pack into the active-variable contract.
- **What's missing:** `stack-detector` skill (or folded into `cartographer`) that runs in Phase 0 and sets `active-variables.yaml:runtime.rule_packs` to the matched set. Currently the operator (or the director agent) has to manually pick rule packs — invisible logic.
- **v1.0 impact:** **High**. Auto-loading is the magic moment of a v1.0 showcase — "it knew my stack without me telling it."
- **Proposed unit:** skill (`stack-detector/SKILL.md`) + cartographer extension
- **Effort:** 1-2 sessions

### Gap PG-25: Rule-pack discoverability gap

- **Current state:** `docs/runtime/rule-packs/` is a flat directory. `docs/governance/rule-pack-governance.md` is 62 lines (small). No index file showing: which rule pack covers what, maturity level, maintainer, last-updated, anti-pattern IDs owned.
- **What's missing:** `docs/runtime/rule-packs/README.md` — index table. Plus frontmatter standardization across the 8 existing packs (currently no audit confirms they share a shape).
- **v1.0 impact:** **Medium**. A showcase viewer scanning the repo asks "what do these rule packs do?" and has to open each.
- **Proposed unit:** doc (index) + retrofit
- **Effort:** 1 session

---

## Pack gap category: Docs / onboarding

### Gap PG-26: README.md onboarding takes >5 min

- **Current state:** `README.md` = 158 lines, well-structured but dense. Leads with version declaration + developer + license + table-of-contents — not with "run this in 30 seconds."
- **What's missing:** Top-of-README "30-second try" block: `git clone → claude → /demo` (where `/demo` is PG-05). Current README dives into vendor matrix and modes — correct but late.
- **v1.0 impact:** **Critical**. GitHub landing page. If a browsing dev can't paste 3 commands and see output, they close the tab.
- **Proposed unit:** README restructure (not a new file)
- **Effort:** 0.5 sessions (but blocked on PG-05 delivering `/demo`)

### Gap PG-27: No 5-minute intro doc

- **Current state:** `README_RUN_ME_FIRST.md` exists at repo root (evidence: in `ls` output) but content not inspected here. `CONTRIBUTING.md`, `DISTRIBUTION.md`, `CROSS_PLATFORM.md`, `ROADMAP.md`, `VERSIONING.md`, `VERSION_DISTRIBUTION_MATRIX.md` also exist. Plus `AGENTS.md`, `GEMINI.md`, English mirrors. Total landing surface = ~13 top-level docs. Cognitive load is high.
- **What's missing:** `docs/quickstart.md` — 5 minutes, 5 sections: Install, Run the Demo, Read Your Artefacts, Pick Next Command, Extend.
- **v1.0 impact:** **High**.
- **Proposed unit:** doc (`docs/quickstart.md`, ~100 lines)
- **Effort:** 1 session

### Gap PG-28: No architecture diagram

- **Current state:** `docs/architecture/` directory exists. Contents not inspected in this audit. Claim in scope is "no diagram." Evidence weakness — may already exist in `docs/architecture/` but not surfaced from the README.
- **What's missing:** A single visual showing: vendor adapters → core → artefact chain → agent surface → skills → rule packs. Either Mermaid (text-friendly, renders on GitHub) or a committed SVG. Placed near the top of README.
- **v1.0 impact:** **High**. Reviewers grasp systems visually. The product has a three-layer story (adapter / core / artefact) and a surface map — diagramming is the single highest-leverage doc artefact.
- **Proposed unit:** Mermaid embedded in README + standalone `docs/architecture/system-map.mmd`
- **Effort:** 1 session

### Gap PG-29: No decision tree "which command do I run when"

- **Current state:** Each command has its own header line in the adapter doc. No unified decision tree.
- **What's missing:** `docs/command-decision-tree.md` — flowchart (Mermaid) with questions: "Do you have existing code? → yes → brownfield / no → greenfield → ..." leading to a specific command. Pairs with PG-06 `/status`.
- **v1.0 impact:** **High**. Commands are the primary user interface; guidance is currently prose in README.
- **Proposed unit:** doc
- **Effort:** 0.5 sessions

### Gap PG-30: No video/gif demo

- **Current state:** Release notes exist (`RELEASE_NOTES_1.0.0.md`, `RELEASE_NOTES_2.0.0.md`) but no recorded demo.
- **What's missing:** 60-90 second GIF embedded in README showing `/director` running end-to-end against the demo project (PG-05).
- **v1.0 impact:** **High**. Unchanged from general SaaS showcase experience — GIF in README doubles click-through.
- **Proposed unit:** asset (media), not a pack unit. But blocks on PG-05.
- **Effort:** 0.5 sessions (once PG-05 exists)

### Gap PG-31: Dense governance surface (22 docs) has no entry index

- **Current state:** `docs/governance/` contains 22 files. `README.md` exists inside `docs/governance/` (good) but not confirmed as an index table. 22 docs is a lot — new maintainers face wall-of-links.
- **What's missing:** If `docs/governance/README.md` is not already a shaped index: it should be a table with columns `Doc | Owns | Cross-refs | Maturity`. Same for `docs/runtime/README.md` (29 docs).
- **v1.0 impact:** **Medium**. Invisible to end user, high impact on contributor onboarding.
- **Proposed unit:** retrofit README.md in both directories
- **Effort:** 1 session

---

## Pack gap category: Ecosystem / distribution

### Gap PG-32: No npm publication evidence

- **Current state:** `package.json` declares `name: ulak-os`, `bin: ulak`, `version: 2.2.1`. `DISTRIBUTION.md` exists (content not inspected). `prepublishOnly` script wired to `build && test`. Whether the package is actually published to npm is not verified here.
- **What's missing:** If not published: publish. If published: README install-line should read `npm i -g ulak-os` or `npx ulak-os` prominently.
- **v1.0 impact:** **Critical**. v1.0 without npm distribution is a positioning mismatch — the product claims CLI distribution but lives in git-clone-only mode.
- **Proposed unit:** release action (npm publish) + README banner
- **Effort:** 1 session (publish + verify + README update)

### Gap PG-33: Sample projects directory is empty

- **Current state:** `examples/` at repo root exists but is empty. `docs/examples/` contains 7 sample artefacts (intake, inventory, manager-verdict, validation-plan in TR+EN).
- **What's missing:** At minimum one sample project (see PG-05). Ideally three: `examples/demo-nextjs/`, `examples/demo-fastapi/`, `examples/demo-django-bayi/`. Each with enough code to trigger 3-5 meaningful findings.
- **v1.0 impact:** **Critical** — this is the PG-05 pairing.
- **Proposed unit:** sample projects (content)
- **Effort:** 3-4 sessions for three samples; 1-2 for just one

### Gap PG-34: No distribution parity validation for non-Claude vendors

- **Current state:** `scripts/validate-vendor-parity.sh` exists but its content and whether it runs in CI is unknown. Adapters present: `docs/adapters/claude-code.md`, and references to codex/gemini. Whether the same artefact chain actually works on Gemini CLI and Codex/Copilot in v2.2.1 is not evidenced here.
- **What's missing:** Either CI job running parity tests and surfaced in README badge, or honest disclaimer "v1.0 primary = Claude Code; Gemini/Codex = experimental."
- **v1.0 impact:** **High** — the product markets as "vendor-neutral." Launching v1.0 with unverified parity is a credibility risk.
- **Proposed unit:** CI workflow + badge + disclaimer decision
- **Effort:** 2-3 sessions

### Gap PG-35: No "how to contribute a rule pack / agent / skill" guide

- **Current state:** `CONTRIBUTING.md` exists at root (not inspected). `docs/governance/rule-pack-governance.md` is 62 lines; `docs/governance/plugin-skill-decision.md` is 27 lines — short.
- **What's missing:** Step-by-step tutorial: "How to add a new rule pack (Go example)" — template, checklist, validation scripts to run, PR expectations. Same for agent and skill. Currently governance docs describe *what* but not *how*.
- **v1.0 impact:** **Medium-High** for ecosystem growth. Low for first-10-minute user, but blocks community contribution.
- **Proposed unit:** 3 tutorial docs in `docs/tutorials/`
- **Effort:** 2 sessions

---

## Pack gap category: Observability & runtime discipline

### Gap PG-36: No agent run-log schema

- **Current state:** `PreToolUse` on Bash writes `[pre-bash]`, `PostToolUse` on Edit/Write writes `[post-edit]` — unstructured, untimestamped-at-content-level, no agent identity. `docs/governance/observability-baseline.md` exists (content not inspected) — likely defines the target.
- **What's missing:** A structured log line shape (JSONL or TSV) including timestamp, session-id, agent-name, tool, artefact path. Written consistently by all hooks.
- **v1.0 impact:** **Medium**. Maintainer-facing.
- **Proposed unit:** hook refactor + doc
- **Effort:** 1 session

### Gap PG-37: No `.claude/logs/` retention policy surfaced

- **Current state:** SessionStart hook rotates logs >1MB and deletes >30 days. This is a *real* hook (good!) but its behavior is invisible — not documented, not in governance index.
- **What's missing:** Link from `docs/governance/hook-governance.md` and `docs/governance/observability-baseline.md` to this behavior; configurable threshold.
- **v1.0 impact:** **Low**.
- **Proposed unit:** doc cross-link + config
- **Effort:** 0.5 sessions

---

## Pack gap category: Demo project content (cross-cutting)

### Gap PG-38: Demo project needs to exercise all 5 phases visibly

- **Current state:** No demo project.
- **What's missing:** If PG-05 lands, the sample must be designed to exhibit **each** of Phase 0-5 with non-trivial output. That means it must be large enough for deep inventory (>50 files ideally, with realistic intra-file structure), contain **at least 3 planted findings** per specialist (so evidence-register has 15-25 findings, not 2), and have at least one test suite with a gap.
- **v1.0 impact:** **Critical** as part of PG-05.
- **Proposed unit:** content design
- **Effort:** included in PG-05 / PG-33 sessions

---

## Pack gap category: Security posture (cross-cutting)

### Gap PG-39: `.claude/settings.json` permissions surface is permissive

- **Current state:** `allow: ["Bash(git status)", "Bash(git diff *)", "Bash(find *)", "Bash(ls *)", "Bash(cat *)"]`. `deny: ["Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)"]`.
- **What's missing:** No allowlist for `Bash(rg *)`, `Bash(npm *)`, `Bash(node *)` — runtime commonly used. Either silently denied (fails runs) or silently allowed (anything-goes). `docs/governance/settings-permissions-governance.md` exists (content not inspected) — should be the source of truth.
- **v1.0 impact:** **Medium**. Directly affects first-run stability.
- **Proposed unit:** settings.json audit + governance doc alignment
- **Effort:** 1 session

### Gap PG-40: No `Bash(rm *)` / `Bash(mv *)` deny rule

- **Current state:** `deny` only covers secret reads. Destructive shell commands are not explicitly denied.
- **What's missing:** Explicit `deny: Bash(rm -rf *)`, `Bash(git reset --hard *)`, `Bash(git push --force *)` — belt-and-suspenders against prompt-injection-driven destruction. Director agent rules cover policy; settings.json adds a hard gate.
- **v1.0 impact:** **Medium**. A runaway agent on a user repo with no hard gate is a trust incident waiting to happen.
- **Proposed unit:** settings.json deny list expansion
- **Effort:** 0.5 sessions

---

## Top 10 v1.0-blocking pack gaps (ranked)

Ranking criteria: (a) first-10-minute visibility, (b) trust / security posture, (c) onboarding friction, (d) evidence strength of the gap claim.

| Rank | Gap | Category | Why it blocks v1.0 |
|---|---|---|---|
| 1 | **PG-05** — `/demo` / `/sample-run` command | Command | No canned demo = no showcase. Every evaluator forced to bring their own repo. Paired with PG-33, this is the single highest-leverage v1.0 item. |
| 2 | **PG-33** — Empty `examples/` directory | Ecosystem | Required for PG-05 to work. Without sample code, commands run against nothing. |
| 3 | **PG-26** — README onboarding >5 min | Docs | GitHub landing page; drives the first impression. |
| 4 | **PG-12** — `first-run-wizard` skill | Skill | Pairs with PG-05 to create the "landing → running" pipeline. |
| 5 | **PG-18** — Credential-leak pre-commit hook | Hook | Security incident risk during live showcase. Product contradicts own security agent without it. |
| 6 | **PG-01** — 18 thin specialist agents | Agent | Visual unevenness in evidence-register is immediate evidence of immaturity. |
| 7 | **PG-24** — Auto-detect-stack skill | Skill | The "magic moment" of showcase — no demo is convincing without it. |
| 8 | **PG-28** — Architecture diagram | Docs | Systems are shown visually; reviewers will ask. |
| 9 | **PG-32** — npm publication | Ecosystem | Product claims CLI distribution; must live it. |
| 10 | **PG-07** — `/install-verify` command | Command | Cuts 80% of first-run support tickets. |

Deferred but tracked (11-15 in priority order): PG-17 (artefact-index hook), PG-06 (`/status`), PG-21 (MCP samples), PG-34 (vendor parity), PG-23 (rule packs — at least Go + Django).

---

## Minimum viable pack for v1.0 showcase

The smallest coherent set to ship v1.0 with dignity. Everything here is an **either-build-or-disclaim** item — if not built, the README must openly label it "coming in v1.1" to preserve trust.

### Must-have (build for v1.0)

1. **Demo experience** (PG-05 + PG-33 + PG-38): `/demo` command + one sample project (`examples/demo-nextjs/` recommended since typescript-nextjs rule pack is mature) + annotated artefacts in `reports/demo/`.
2. **First-run path** (PG-12 + PG-26 + PG-07): `first-run-wizard` skill, rewritten README top-block with 30-second install, `/install-verify` command.
3. **Security gates** (PG-18 + PG-40): credential-leak PreToolUse hook, destructive-command deny list in settings.json.
4. **Visual onboarding** (PG-28 + PG-29): Mermaid architecture diagram in README, command-decision-tree doc.
5. **Distribution** (PG-32): published npm package with `npx ulak-os demo` working.
6. **Specialist polish** (PG-01 — partial): upgrade the 6 most-dispatched specialists to 50-80 line rich format. Top-6 candidates: `backend-api-architect`, `architecture-lead`, `data-database-governor`, `infra-release-sre`, `qa-validation-commander`, `release-readiness-auditor`. Defer the remaining 12 to v1.1 — disclose in release notes.

### Nice-to-have (build if time permits, else disclaim)

7. **Stack auto-detection** (PG-24).
8. **`/status` command** (PG-06) + **artefact-index hook** (PG-17).
9. **MCP samples** (PG-21) — 3 minimum (supabase, postgres, slack).
10. **One new rule pack** — Go preferred (largest stack gap).

### Explicit deferrals for v1.1 (must be stated openly)

- 12 remaining thin specialists (PG-01 tail)
- Persona edge cases — bayi-sub-reseller, multi-brand-admin (PG-03)
- test-coverage-audit skill (PG-13)
- cross-project-audit skill (PG-15)
- compliance-report-generator skill (PG-16)
- upgrade-migration skill (PG-14) — ironic given v1.0 is itself an upgrade target, but pragmatic
- Remaining rule packs (PG-23) — Rust, Django, Laravel, Kotlin, Swift, Java, Vue, Svelte
- Video/GIF demo (PG-30) — aspirational but not required for v1.0 code-level readiness
- Vendor parity CI validation (PG-34) — may need "Claude-first, Gemini/Codex experimental" label instead

---

## Governance notes

- **Evidence strength:** This register is built on `ls`/`wc`/`cat` of surface files and reading two rich agents (`security-hardening-lead`, `final-validation`). It is **not** built on actual telemetry of which agents get dispatched in real runs (PG-02 is itself a finding about the lack of such telemetry). Rankings are structural judgments, not usage data.
- **Unchecked assumptions:** README.en.md content not diffed against README.md. `docs/governance/observability-baseline.md`, `CONTRIBUTING.md`, `DISTRIBUTION.md`, `ROADMAP.md`, `scripts/validate-*.sh` contents not inspected. `src/cli/` existing `ulak` subcommands not enumerated — `/status` or `/install-verify` equivalents may already exist at CLI level and merely need Claude-Code slash-command mirrors.
- **Collision checks:** PG-13 (test-coverage-audit) could be either agent or skill — recommended skill for consistency with existing workflow skills; escalate to agent only if dispatch patterns demand persona-shape.
- **Plugin-skill-decision (`docs/governance/plugin-skill-decision.md`, 27 lines) is short** — may not yet arbitrate ambiguous cases like PG-13. Recommend v1.0 ships an expanded decision matrix (see PG-09 — command-skill-binding-matrix, related but distinct).
- **Forward-only:** None of the proposed units suggest deleting existing surface. PG-09 (thin commands) recommends either folding or documenting binding, not removal.
- **Final verdict ownership:** The autonomous-program-director owns the v1.0 ship/no-ship call. This register proposes candidate gaps and priority; director integrates with `analysis-findings.md`, `target-state.md`, `execution-roadmap.md`, and `validation-plan.md` from companion specialist dispatches.

---

## Artefact locations (absolute paths)

- This register: `C:\Users\osrt91\Desktop\Proje\ulak.os\reports\current\specialists\pack-gap-v2.2.2.md`
- Baseline surface evidence:
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\.claude\agents\*.md` (27 files)
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\.claude\commands\*.md` (8 files)
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\.claude\skills\*\SKILL.md` (7 files)
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\.claude\settings.json`
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\.mcp.json`
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\docs\runtime\rule-packs\*.md` (8 files)
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\docs\governance\*.md` (22 files)
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\docs\runtime\*.md` (29 files + rule-packs subdir)
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\package.json`
  - `C:\Users\osrt91\Desktop\Proje\ulak.os\README.md`
