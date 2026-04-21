# 01 — Introduction

## What is Ulak OS?

Ulak OS is a **vendor-neutral prompt operating system** that sits on top of any modern AI coding CLI (Claude Code, Codex / Copilot, Gemini CLI). One core contract, three vendor adapters. It is a disciplined stack of markdown files that your AI coding tool loads as context, which then routes your intent through a defined protocol: deep inventory, parallel specialist evidence, a mandatory non-obvious findings layer, and a single manager verdict at the end.

In plain terms, Ulak OS does not replace your IDE, your linter, or your CI. It sits between your intent ("audit this repo", "scaffold a new SaaS", "investigate this bug") and the AI coding CLI that executes the work. It gives the CLI a protocol to follow, a governance surface to respect, and a validation gate it cannot skip. The output is a chain of artefacts written to your repository — not just a chat transcript.

The word *Ulak* is Turkish for "messenger" or "courier". The project carries governance, context, and validation discipline across the gap between you and your AI coding CLI.

## Three core capabilities

Ulak OS does three things in a single pack.

### 1. Audit

The `/director komple` command dispatches a six-phase protocol (Phase 0 through Phase 5). It produces a **deep inventory** with file-and-line citations, then runs **multiple specialist subagents in parallel** (security, infrastructure, data, architecture, localization, and more), then surfaces **non-obvious findings** (the "did-you-know" layer), then synthesizes findings into a target state, an execution roadmap, a validation plan, and a pack-gap register. The final step is a **manager verdict** that refuses to say "ready" if any gate is unmet. See [chapter 04](./04-commands.md) for the command, [chapter 05](./05-workflows.md) for the workflow.

### 2. Govern

Ulak OS ships **22 governance documents**, **24 sector packs**, **8 rule packs**, and roughly 100 anti-pattern entries. Once you import the core contract in your project's `CLAUDE.md`, all of this governance loads automatically at the start of every session. Surface-split discipline (customer vs admin vs public API vs partner), evidence trust scoring (T1 through T7), the finding schema, the artefact-write authorization override, hook governance, MCP allowlist enforcement — all of it becomes active context for your AI coding CLI. See [chapter 06](./06-governance.md).

### 3. Scaffold

The `/ulak-scaffold` command generates a **full-stack SaaS starter** at commit 1: Next.js 16 + TypeScript + Tailwind CSS 4 + Supabase + a payment provider + i18n + CI + RLS policies + a VPS deploy pattern + gitleaks baseline. All 22 governance docs are pre-wired into the generated project's `CLAUDE.md`. Eight anti-patterns are gated by construction (single auth helper, server-only guards, DB-sourced role, `.gitignore` discipline, health-probe webhook, VPS hardening, and more). See [chapter 05](./05-workflows.md) § Workflow 2.

## Vendor-neutral framing

Ulak OS is not a Claude-only tool, even though Claude Code is the primary adapter.

- **Claude Code** — full feature support. All 9 slash commands, 27 agents, 8 skills, parallel subagent dispatch.
- **Codex / Copilot** — supported via a plain-text `AGENTS.md` at the repo root. Slash-command semantics differ; governance loads identically.
- **Gemini CLI** — supported via `.gemini/commands/*.toml`. Command parity covers the audit and scaffold flows; some Claude-native commands are documented as exemptions.

The vendor adapter layer is described in [chapter 03](./03-architecture.md) § Vendor adapters and in [`docs/adapters/`](../../adapters/).

## Pack-unit taxonomy

Ulak OS uses seven types of reusable units, plus a governance layer. Each type has a distinct role, lifecycle, and contribution contract.

| # | Unit type | Location | Role |
|---|---|---|---|
| 1 | **Commands** | `.claude/commands/*.md`, `.gemini/commands/*.toml` | Operator entry points — the slash commands you type (`/director`, `/ulak-scaffold`, etc.) |
| 2 | **Skills** | `.claude/skills/<name>/SKILL.md` | Repeatable multi-step workflows agents invoke by name |
| 3 | **Agents** | `.claude/agents/*.md` | Specialist reasoning roles (cartographer, security-hardening-lead, persona agents, and more) |
| 4 | **Hooks** | `.claude/settings.json` (PreToolUse, PostToolUse, etc.) | Harness-level gates that block or observe tool calls |
| 5 | **Sector packs** | `docs/runtime/sector-packs.md` § SP-NN entries | Domain-specific bundles (SaaS, e-commerce, fintech, multi-tenant, and more) |
| 6 | **Rule packs** | `docs/runtime/rule-packs/*.md` | Stack-specific imperative guardrails that load when the stack is detected (TypeScript + Next.js, Python + FastAPI, Docker Compose, etc.) |
| 7 | **Runtime rules** | `docs/runtime/*.md` | Always-loaded discipline (router, program-phases, artefact-contract, output-profiles, and more) |

On top of those seven unit types, **22 governance documents** in `docs/governance/` define the enforcement contracts (finding schema, trust tiers, artefact-write authorization, surface split, and more). Governance trumps runtime where the two collide.

The decision of which unit type fits a new proposal is documented in [`docs/governance/plugin-skill-decision.md`](../../governance/plugin-skill-decision.md).

## Who is this for?

Four target personas, roughly in order of how much value they extract in week one.

### 1. Solo developer starting a new SaaS

You have an idea for a new product and you want to ship commit 1 with the right discipline baked in: real auth (not metadata-based roles), proper `.gitignore` hygiene, RLS policy templates, CI validators, a deploy pattern. Run `/ulak-scaffold` once and you have a starter that avoids eight known anti-patterns by construction.

### 2. Small team inheriting a brownfield

You joined a team that inherited a codebase and nobody has a clean mental model of it. Run `/director komple` and get a phase-by-phase artefact chain: deep inventory, specialist evidence, non-obvious findings, target state, execution roadmap. Read the manager verdict, then make decisions based on actual evidence instead of guesses.

### 3. Agency running multiple client projects

You run a portfolio of client projects. The pattern-import ledger (see [chapter 06](./06-governance.md)) lets you lift a pattern from one project, give it a trust tier, and carry it into every future project. Sector packs and rule packs become institutional memory; every new project inherits the same governance baseline.

### 4. Brownfield rescue lead

You are the person brought in to modernize a legacy monolith. Ulak OS gives you the god-module-decomposition skill (Strangler Fig protocol), the Waves pattern for sequencing risky refactors, and a validation gate that refuses to say "done" until live probes pass. You make progress in controlled steps instead of a big-bang rewrite.

## What Ulak OS is NOT

Setting expectations plainly.

- **Not an IDE or editor.** It sits above your AI coding CLI, not beside your editor. You still open VS Code or your editor of choice.
- **Not a model.** It does not train or fine-tune anything. The model choice belongs to your provider; Ulak OS shapes the prompt the model sees.
- **Not a linter.** Anti-patterns are gating prompts and expectations at the review level, not AST-level rules. For AST linting, keep using your stack's native tools (ESLint, ruff, clippy, and so on).
- **Not a CI platform.** Example workflows shipped under `.github/workflows/` in the scaffolder are starter points, not a CI product. Your real CI choice is yours.
- **Not a runtime (the application kind).** It does not execute your application. It orchestrates the prompt your AI coding CLI sends to its backing model.
- **Not a replacement for reading the code.** The director produces evidence, not absolution. Review the artefacts.
- **Not telemetry-emitting.** No data leaves your machine. All artefacts land in your own repo under `reports/current/`.

## Why this design

Three principles explain most of the choices made in Ulak OS.

**Vendor-neutral** because the operator picks the CLI that fits the task (Claude Code for parallel dispatch, Codex for long-context authoring, Gemini for market scans) without rewriting the pack. The core contract is plain markdown. Every adapter loads the same file.

**Append-only artefact history** because every run adds to `reports/current/**`, and prior runs archive to `reports/archive/`. No prior verdict is silently overwritten. This makes audits reproducible and reviewable.

**Deep inventory over shallow listing** because "ls of top-level folders" evidence produces shallow plans and hidden bugs. The protocol rejects folder-listing inventory and re-dispatches with an explicit "cite file paths and line ranges" instruction.

## A note on origins

Ulak OS was built by distilling lessons from a portfolio of production SaaS projects. The first internal release line (branded with codename letters — "V6", "V7", and so on) evolved through nine internal versions before the project was reframed as a vendor-neutral pack anyone could adopt. `v1.0.0` is the first public GA release.

That history shows up in a few ways. The word "Ulak" is Turkish. Some runtime rule files retain their original Turkish imperatives (see the `turkish-normalization.md` runtime rule, which specifically addresses Turkish character handling in i18n code). The localization-SSOT rule pack defaults to bilingual Turkish + English, because that is the baseline every origin-project shipped with.

None of this affects English-only operators. The public surface — README, CLAUDE.md, AGENTS.md, GEMINI.md, this manual, every command file, every agent file — is bilingual. Pick English and you miss nothing material. The Turkish heritage is visible in the project name and in a handful of embedded imperatives; it does not leak into the output your AI coding CLI produces for you.

For full history, see [`docs/history/version-lineage.md`](../../history/version-lineage.md).

## What comes next

Chapter 02 walks through installation — one-liner, manual clone, submodule, verification, uninstall. Chapter 03 explains the architecture in depth: how the `@`-import chain works, what the director protocol produces, and how vendor adapters bridge to each CLI. Chapter 04 is the command reference. Chapter 05 shows five end-to-end workflows. Chapters 06–09 cover governance, contributing, troubleshooting, and the FAQ.

If you already know what you want to do, jump ahead:

- Want to audit an existing repo? → [05 — Workflows](./05-workflows.md) § Workflow 1
- Starting a new SaaS? → [05 — Workflows](./05-workflows.md) § Workflow 2
- Evaluating vs alternatives like `superpowers` or `cartographer`? → [09 — FAQ](./09-faq.md)
- Something broken? → [08 — Troubleshooting](./08-troubleshooting.md)

Everything below references material elsewhere in the manual or in the docs tree. When a cross-link points at a file that does not exist, that is either a bug (please report) or a forward-link to work planned for a later release.

---

Next: [02 — Installation](./02-installation.md)
