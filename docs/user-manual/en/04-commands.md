# 04 — Commands

Ulak OS v1.6 ships with **24 slash commands**. Each command is an operator entry point that dispatches a specific agent (or chain of agents) to produce a defined set of artefacts or to help you discover what the system can do.

Commands are organized into three categories:

1. **Onboarding + discovery** — the v1.6 vision layer. No prior knowledge required.
2. **Project lifecycle** — scaffold, audit, frontend, testing, pattern extraction, gap analysis.
3. **Meta / governance** — locale management and similar system-wide toggles.

All commands live as markdown files under `.claude/commands/` in the pack. For Gemini CLI, equivalent `.toml` files live under `.gemini/commands/`. For Codex and Copilot CLIs, commands are reached via natural-language trigger phrases mapped in `AGENTS.md` (the **NL trigger map**). Vendor-parity notes accompany every command.

## `hi ulak` — the natural-language entry (v1.6)

You do not have to memorize slash-command names. In any AI coding CLI with Ulak OS imported, typing:

```
hi ulak
```

triggers `/ulak-hello`. From there, free-form descriptions of what you want ("scaffold a SaaS", "audit my project", "what does RLS mean?") route through `/ulak-ask` to the matching canonical command. The NL trigger map in `AGENTS.md` provides the same entry for Codex and Copilot CLIs that lack literal slash-command syntax.

## Full command index (24 commands)

Legend: ✓ = full support, 🟡 = partial (serial fallback or via NL trigger), ❌ = exempt / unsupported.

### Category 1 — Onboarding + discovery (9 commands)

| Command | What it does | Claude | Codex | Copilot | Gemini |
|---|---|---|---|---|---|
| [`/ulak-hello`](#ulak-hello) | 30-second onboarding tour; explains Ulak OS, shows 3 example commands, asks what you want to do | ✓ | 🟡 | 🟡 | ✓ |
| [`/ulak-ask`](#ulak-ask) | Natural-language router; state intent in plain language, get the right command suggested | ✓ | 🟡 | 🟡 | ✓ |
| [`/ulak-packs`](#ulak-packs) | Dumps full capability catalog (24 commands, 10 skills, 27 agents, packs) inline | ✓ | ✓ | ✓ | ✓ |
| [`/ulak-search`](#ulak-search) | Keyword search (TR or EN) across commands, skills, agents, sectors, rules, governance, ADRs, runbooks, templates | ✓ | ✓ | ✓ | ✓ |
| [`/ulak-demo`](#ulak-demo) | Shows 3 example SaaS projects (Minimal, Marketplace, LMS) with real scaffold commands and file counts | ✓ | ✓ | ✓ | ✓ |
| [`/ulak-explain`](#ulak-explain) | Beginner-friendly 5-field glossary lookup (Simple / Technical / Analogy / In Ulak / Related) | ✓ | ✓ | ✓ | ✓ |
| [`/ulak-design-ref`](#ulak-design-ref) | Download a public brand's design reference (awesome-design-md) and hand it to frontend agents | ✓ | 🟡 | 🟡 | 🟡 |
| [`/ulak-mcp-discover`](#ulak-mcp-discover) | Discover MCP servers from public registry, classify by trust tier, propose allowlist additions (governance-gated) | ✓ | 🟡 | 🟡 | 🟡 |
| [`/ulak-intake`](#ulak-intake) | Produce the Ulak intake artefact (optionally via superpowers:brainstorming) | ✓ | 🟡 | 🟡 | 🟡 |

### Category 2 — Project lifecycle (14 commands)

| Command | What it does | Claude | Codex | Copilot | Gemini |
|---|---|---|---|---|---|
| [`/ulak-start`](#ulak-start) | 5-phase, 27-question interactive SaaS wizard (technical or beginner mode); auto-dispatches `/ulak-scaffold` on confirm | ✓ | 🟡 | 🟡 | ✓ |
| [`/ulak-scaffold`](#ulak-scaffold) | Greenfield full-stack SaaS scaffolder; produces ship-ready Next.js + Supabase + payment + i18n starter with governance pre-wired | ✓ | ✓ | ✓ | ✓ |
| [`/ulak-next-steps`](#ulak-next-steps) | Post-scaffold runbook; 8–10 concrete steps from `pnpm install` to first admin login | ✓ | ✓ | ✓ | ✓ |
| [`/director`](#director) | Full Phase 0 → 5 audit program; the executive director | ✓ | 🟡 | 🟡 | 🟡 |
| [`/ulak-audit-deep`](#ulak-audit-deep) | 14-dimension audit scorecard (Architecture, Testing, Secrets, Observability, CI/CD, etc.); 0-100 per dimension + A-F grade | ✓ | ✓ | ✓ | ✓ |
| [`/ulak-brainstorm`](#ulak-brainstorm) | Pre-implementation ideation for a new feature; wraps superpowers:brainstorming with Ulak governance | ✓ | 🟡 | 🟡 | 🟡 |
| [`/ulak-test-driven`](#ulak-test-driven) | TDD workflow; writes failing test first, implements, refactors; wraps superpowers:test-driven-development | ✓ | 🟡 | 🟡 | 🟡 |
| [`/ulak-pattern-extract`](#ulak-pattern-extract) | Extract reusable pattern from a source project; register in pattern-import-ledger with T1/T2 evidence | ✓ | 🟡 | 🟡 | 🟡 |
| [`/ulak-subagent-dispatch`](#ulak-subagent-dispatch) | Dispatch N independent subagents in parallel for bounded scope (superpowers:dispatching-parallel-agents) | ✓ | ❌ | ❌ | 🟡 |
| [`/triage-build`](#triage-build) | Triage a failing build by stack; toolchain-precheck + subsystem dispatch | ✓ | ✓ | ✓ | ✓ |
| [`/frontend-war-room`](#frontend-war-room) | Premium redesign + visual system cleanup | ✓ | ❌ | ❌ | ❌ |
| [`/intake`](#intake) | Run Phase 0–2 only; intake + inventory + initial evidence | ✓ | ✓ | ✓ | ✓ |
| [`/final-verdict`](#final-verdict) | Re-validate existing artefacts; merged manager verdict | ✓ | ✓ | ✓ | ✓ |
| [`/pack-gap-audit`](#pack-gap-audit) | Inspect current operating pack; list missing commands, skills, agents, hooks, MCP, docs, eval | ✓ | ✓ | ✓ | ✓ |

### Category 3 — Meta / governance (1 command)

| Command | What it does | Claude | Codex | Copilot | Gemini |
|---|---|---|---|---|---|
| [`/ulak-locale`](#ulak-locale) | Manage active Ulak OS locale (TR/EN toggle); persistent state in `.claude/state/locale.txt` | ✓ | ✓ | ✓ | ✓ |

---

## Onboarding + discovery

### /ulak-hello

**Source:** `.claude/commands/ulak-hello.md`

**Does.** 30-second onboarding tour. Explains what Ulak OS does in 3 sentences, shows 3 example commands, and asks "what do you want to do?". Also triggered by typing `hi ulak` in any CLI with Ulak OS loaded.

**When.** First contact. A new user just installed Ulak OS or opened a project for the first time.

**Example.** `/ulak-hello` — no arguments needed.

**Output.** Inline terminal text: 3-sentence intro, 3 example commands with descriptions, open-ended question.

### /ulak-ask

**Source:** `.claude/commands/ulak-ask.md`

**Does.** Natural-language router. You state what you want in plain language; Ulak OS matches keyword + intent to the right existing command/skill/agent and suggests it. If ambiguous, returns a "did you mean?" disambiguation list.

**When.** You know what you want to accomplish but do not know which command to type. The "converse with Ulak instead of memorizing syntax" layer.

**Example.** `/ulak-ask I want to audit my existing SaaS` → suggests `/director komple` plus context.

**Output.** Inline suggestion(s) with rationale.

### /ulak-packs

**Source:** `.claude/commands/ulak-packs.md`

**Does.** Shows all Ulak OS capabilities in one place: 24 commands, 10 skills, 27 agents, 15 sector overlays, 24 sector packs, 8 rule packs, 22 governance docs, 7 ADRs, 4 runbooks. Reads `docs/catalog.md` and dumps it inline.

**When.** Instead of hunting for plugins online. Operational embodiment of the "no plugin hunting" vision.

**Example.** `/ulak-packs` or `/ulak-packs category=agents`.

**Output.** Inline catalog, optionally filtered.

### /ulak-search

**Source:** `.claude/commands/ulak-search.md`

**Does.** Keyword search over the Ulak OS capability catalog. Accepts TR or EN keywords. Returns combined hits across commands, skills, agents, sectors, rules, governance, ADRs, runbooks, templates.

**When.** You remember a concept but not the exact command. For example `/ulak-search payment` surfaces the payment-integrated-saas sector, Iyzico templates, and the `/ulak-scaffold` payment flag on one screen.

**Example.** `/ulak-search rls` or `/ulak-search ödeme`.

**Output.** Ranked match list with type + path.

### /ulak-demo

**Source:** `.claude/commands/ulak-demo.md`

**Does.** Introduces 3 example SaaS projects buildable with Ulak OS (Minimal SaaS, Marketplace, LMS). For each: real scaffold command, generated file count (measured on disk), activated sector + rule packs, "how many days without Ulak" estimate.

**When.** A beginner says "show me what I can build before I run anything".

**Example.** `/ulak-demo` or `/ulak-demo project=marketplace`.

**Output.** Per-example card with scaffold line, file count, pack activation, time saved.

### /ulak-explain

**Source:** `.claude/commands/ulak-explain.md`

**Does.** Explains a technical term in a beginner-friendly 5-field schema: Simple / Technical / Analogy / In Ulak / Related. Lookup source is `docs/runtime/beginner-glossary.md` (47 terms).

**When.** Post-scaffold, operator sees `.env.local` variables or reads RLS / JWT / webhook in a migration file and wants a quick explanation without leaving the CLI.

**Example.** `/ulak-explain rls` → 5-field explanation of Row-Level Security.

**Output.** Inline 5-field entry.

### /ulak-design-ref

**Source:** `.claude/commands/ulak-design-ref.md`

**Does.** Downloads a public brand's design reference from `VoltAgent/awesome-design-md` and writes it to `reports/current/design-references/<brand>/DESIGN.md` so frontend agents can consume it during a redesign.

**When.** Briefing the design-system-architect with an external anchor (stripe, linear, vercel, notion, etc.).

**Example.** `/ulak-design-ref stripe`.

**Output.** `reports/current/design-references/stripe/DESIGN.md`.

### /ulak-mcp-discover

**Source:** `.claude/commands/ulak-mcp-discover.md`

**Does.** Discovers new MCP servers from the public registry, classifies by trust tier, proposes addition to the Ulak OS MCP allowlist via governance gate. Produces a candidate report for operator review; does NOT auto-install.

**When.** Evaluating community MCP servers for integration into an Ulak run or a scaffolded project.

**Example.** `/ulak-mcp-discover keyword=database` → candidate list with trust tiers.

**Output.** `reports/current/mcp-candidates.md`.

### /ulak-intake

**Source:** `.claude/commands/ulak-intake.md`

**Does.** Produces the Ulak intake artefact — structured capture of operator intent, success criteria, constraints. Calls `superpowers:brainstorming` if installed.

**When.** Brand new project; disciplined intent capture before inventory.

**Example.** `/ulak-intake I want to build a B2B SaaS for small retail chains`.

**Output.** `reports/current/intake.md`.

---

## Project lifecycle

### /ulak-start

**Source:** `.claude/commands/ulak-start.md`

**Does.** 5-phase, 27-question interactive SaaS wizard. You write no prompts; 4–7 questions per phase, sensible default on each, `[enter]` to skip. Two modes: `[t]` technical (default, developer audience) and `[b]` beginner (plain language + inline glossary). Answers map to 24 sector packs + 8 rule packs + 22 governance docs + ~100 anti-patterns. On confirmation, `/ulak-scaffold` auto-dispatches.

**When.** Starting a new SaaS from scratch, want a guided path.

**Example.** `/ulak-start` — interactive.

**Output.** Wizard writes `reports/current/scaffold-inputs.yaml`, then dispatches `/ulak-scaffold`.

### /ulak-scaffold

**Source:** `.claude/commands/ulak-scaffold.md`

**Does.** Greenfield full-stack SaaS scaffolder. Produces a ship-ready starter with Ulak OS governance baked in from commit 1: Next.js 16 + TypeScript + Tailwind CSS 4 + Supabase + payment provider + i18n + RLS + CI + deploy pattern. Dispatches the `saas-scaffolder` skill.

**When.** Starting a new SaaS product (greenfield, not brownfield addition).

**Example.**
```
/ulak-scaffold product_name=example-saas product_domain=saas payment_provider=stripe locale_primary=en
```

**Output.** A new directory containing the full project. Post-scaffold checklist: see `/ulak-next-steps`.

### /ulak-next-steps

**Source:** `.claude/commands/ulak-next-steps.md`

**Does.** Answers "what do I do now?" after scaffold completes, with 8–10 concrete steps. Produces a personalized runbook based on your wizard choices (sector, payment, deploy, email): `pnpm install`, `.env.local` fill-in, Supabase / Iyzico / Resend signup links, first migration, seed, `pnpm dev`, first admin user creation, admin panel entry. Following these steps reaches localhost:3000 with a working admin login.

**When.** Immediately after `/ulak-scaffold`. Cross-links to `docs/tutorials/{supabase,vercel,github,resend}.md` for external-service setup.

**Example.** `/ulak-next-steps` — from inside the scaffolded directory.

**Output.** `reports/current/next-steps.md` (personalized) + inline summary.

### /director

**Source:** `.claude/commands/director.md`

**Does.** Dispatches the `autonomous-program-director` subagent to run the complete Phase 0 → 5 protocol. The canonical "read everything, audit everything, give me a verdict" command.

**When.** First pass on a brownfield; rescue mission; periodic health check; pre-release signoff.

**Example.** `/director komple` or `/director komple mode=RESCUE dispatch=persona parallel_dispatch=9`.

**Output.** 15 artefact files under `reports/current/` chained across the six phases.

### /ulak-audit-deep

**Source:** `.claude/commands/ulak-audit-deep.md`

**Does.** 14-dimension audit scorecard (Architecture, Testing, Secrets, Observability, CI/CD, Duplication, Dependencies, Type Safety, Plugins, API Design, Infrastructure, Frontend, Data Validation, Documentation). Produces 0-100 per dimension + target-state + gap analysis + A-F overall grade.

**When.** Project baselines, post-modernization verification, quarterly health report, second-opinion scorecard after `/director`.

**Example.** `/ulak-audit-deep`.

**Output.** `reports/current/14d-audit-scorecard.md` + `reports/current/14d-gap-analysis.md`.

### /ulak-brainstorm

**Source:** `.claude/commands/ulak-brainstorm.md`

**Does.** Pre-implementation ideation for a new feature / surface. Enforces "explore intent + requirements + alternatives BEFORE touching code". Wraps `superpowers:brainstorming` with Ulak governance; writes to `docs/superpowers/specs/<date>-<topic>.md`.

**When.** Starting any non-trivial feature, adding a new user-facing capability, making a design decision that outlives this session.

**Example.** `/ulak-brainstorm topic="subscription-tiering"`.

**Output.** `docs/superpowers/specs/<date>-subscription-tiering.md`.

### /ulak-test-driven

**Source:** `.claude/commands/ulak-test-driven.md`

**Does.** TDD workflow for a specific feature or bugfix. Writes failing test first, implements to pass, then refactors. Enforced via `superpowers:test-driven-development`; adds to golden set if cross-project-relevant.

**When.** Any feature implementation or bug fix that will ship; not for throwaway experiments.

**Example.** `/ulak-test-driven feature="admin-bulk-delete-audit-log"`.

**Output.** Red-green-refactor commit chain plus optional golden-set entry under `evals/`.

### /ulak-pattern-extract

**Source:** `.claude/commands/ulak-pattern-extract.md`

**Does.** Extracts a reusable pattern from a candidate source project; registers it in `pattern-import-ledger.md` with T1/T2 evidence. Produces a native Ulak OS rule-pack / sector-pack / anti-pattern entry.

**When.** You read a real project that exhibits a pattern worth propagating across the portfolio.

**Example.** `/ulak-pattern-extract source=./other-repo pattern="webhook-retry-with-idempotency"`.

**Output.** Pattern-import-ledger entry + (optionally) new rule-pack or anti-pattern file.

### /ulak-subagent-dispatch

**Source:** `.claude/commands/ulak-subagent-dispatch.md`

**Does.** Dispatches N independent subagents in parallel for a bounded scope. Enforces `superpowers:dispatching-parallel-agents` + `subagent-driven-development`: identify truly-independent work, hand each subagent a self-contained brief, collect + reconcile outputs, commit merged result.

**When.** Large content-generation tasks (N-file template creation, N-agent expansion, cross-service refactor) where serial work would waste hours.

**Example.** `/ulak-subagent-dispatch n=6 scope="generate migration files for tenants"`.

**Output.** Per-subagent artefacts merged into a single reconciled output.

### /triage-build

**Source:** `.claude/commands/triage-build.md`

**Does.** Generalized build-triage flow. Runs `toolchain-precheck` first, then dispatches to the matching subsystem (frontend, backend, container, mobile) with standard diagnostic commands.

**When.** Build or test is red and you do not yet know why.

**Example.** `/triage-build` or `/triage-build stack=frontend log=./ci.log`.

**Output.** Terminal narrative plus (if non-trivial) a finding in `reports/current/analysis-findings.md`.

### /frontend-war-room

**Source:** `.claude/commands/frontend-war-room.md`

**Does.** Runs frontend / mobile redesign protocol. Dispatches `frontend-ios-flutter-director`, `design-system-architect`, `educational-ux-specialist`. Produces design-system master + per-page overrides + analysis findings.

**When.** Premium redesign push, visual system cleanup, mobile rework.

**Example.** `/frontend-war-room` or `/frontend-war-room scope=mobile`.

**Output.** `design-system/MASTER.md` + per-page overrides + findings + roadmap.

**Vendor note.** Claude-native. Exempt on Codex, Copilot, Gemini due to parallel subagent dispatch dependency.

### /intake

**Source:** `.claude/commands/intake.md`

**Does.** Runs only Phase 0 through Phase 2. Dispatches `cartographer` + `project-intake` skill. Produces intake + inventory + initial evidence register. Does not synthesize findings or write a verdict.

**When.** Read-only first pass before a full `/director` run.

**Example.** `/intake`.

**Output.** `reports/current/intake.md`, `inventory.md`, `evidence-register.md`.

### /final-verdict

**Source:** `.claude/commands/final-verdict.md`

**Does.** Runs only the validation gate. Dispatches `qa-validation-commander`, `release-readiness-auditor`, `red-team-challenger`, `autonomous-program-director`. Re-evaluates existing `reports/current/**` and produces a merged verdict.

**When.** After executing roadmap from `/director`; want independent challenge; pre-release refresh.

**Example.** `/final-verdict`.

**Output.** Updated `validation-plan.md` + refreshed `manager-verdict.md`.

### /pack-gap-audit

**Source:** `.claude/commands/pack-gap-audit.md`

**Does.** Inspects the current operating pack and lists missing or underdeveloped units: commands, skills, agents, hooks, MCP connectors, docs, eval coverage.

**When.** Maintaining Ulak OS (or a fork); after a run flagged missing skills; periodic governance-surface maintenance.

**Example.** `/pack-gap-audit`.

**Output.** `reports/current/pack-gap-register.md` + `reports/current/manager-verdict.md`.

---

## Meta / governance

### /ulak-locale

**Source:** `.claude/commands/ulak-locale.md`

**Does.** Manages Ulak OS active locale (TR/EN toggle). `show` prints current, `tr` or `en` switches persistently. State lives at `.claude/state/locale.txt`. README and user surface pick TR-first or EN-first based on that file.

**When.** Switching the default language of the entire surface.

**Example.** `/ulak-locale show` / `/ulak-locale en` / `/ulak-locale tr`.

**Output.** Updated `.claude/state/locale.txt` + confirmation message.

---

## Vendor parity

Most commands exist on all four vendors. A handful are Claude-native and carry documented exemptions. The enforced single source of truth is [`docs/governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md).

**Claude-native (exempt on other vendors):**
- `/frontend-war-room` — depends on Claude's parallel subagent dispatch semantics.
- `/ulak-subagent-dispatch` on Codex/Copilot — no native parallel dispatch.

**NL trigger map note.** For Codex and Copilot CLIs, commands that show 🟡 in the matrix are reached via natural-language trigger phrases in `AGENTS.md`. Example: "audit my project" → `/director komple`. "start a new saas" → `/ulak-start`. "what does rls mean?" → `/ulak-explain rls`.

**Exemption discipline.** Each exemption is listed in `.claude/vendor-parity-exemptions.txt` with a rationale. The parity check is enforced by `scripts/validate-vendor-parity.sh`. Adding a command without a matching adapter (or exemption entry) fails the script.

## Related references

- [`../../architecture/director-protocol.md`](../../architecture/director-protocol.md) — canonical phase table
- [`../../runtime/output-profiles.md`](../../runtime/output-profiles.md) — the 7 output profiles the `profile=` argument selects
- [`../../runtime/persona-dispatch-pattern.md`](../../runtime/persona-dispatch-pattern.md) — how `dispatch=persona` works
- [`../../governance/plugin-skill-decision.md`](../../governance/plugin-skill-decision.md) — command vs skill vs agent decision tree
- [`../../governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md) — 4-vendor matrix (enforced)
- [`../../runtime/beginner-glossary.md`](../../runtime/beginner-glossary.md) — 47-term glossary (source for `/ulak-explain`)

---

Next: [05 — Workflows](./05-workflows.md)
