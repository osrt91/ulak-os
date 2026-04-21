# Ulak OS User Manual (English)

Welcome to the English user manual for **Ulak OS v1.0.0** — a vendor-neutral prompt operating system for AI coding CLIs (Claude Code, Codex / Copilot, Gemini CLI).

This manual is written for **English-speaking developers** evaluating Ulak OS or adopting it into a new or existing project. It assumes you know how to use a terminal and have installed at least one of the supported AI coding CLIs. It does not assume prior knowledge of the project's internal history.

Türkçe eşdeğeri: [`../tr/README.md`](../tr/README.md).

## How long does it take to read?

About **45 minutes** cover-to-cover. Each chapter is self-contained — jump to the one that matches your situation.

## Prerequisites

- **One** AI coding CLI installed:
  - [Claude Code](https://claude.com/claude-code) (primary — full feature support)
  - Codex / Copilot CLI (supported via `AGENTS.md`)
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli) (supported via `.gemini/commands/*.toml`)
- `git` on your PATH.
- Any one of macOS, Linux, or Windows 10+ (PowerShell 5.1 or newer on Windows).

No compiler, no runtime beyond what your CLI already needs. Ulak OS is prompts and markdown, not a compiled tool.

## Chapters

1. [**01 — Introduction**](./01-introduction.md) — What Ulak OS is, its three core capabilities, who it is for, and what it is not.
2. [**02 — Installation**](./02-installation.md) — One-liner installer, manual clone, submodule integration, `ulak init`, verification, uninstall.
3. [**03 — Architecture**](./03-architecture.md) — The `@`-import chain, public runtime surface vs hidden core, the Phase 0 → 5 director protocol, artefact chain, vendor adapter layer.
4. [**04 — Commands**](./04-commands.md) — All 9 slash commands: what each does, when to use it, arguments, example invocation, expected output.
5. [**05 — Workflows**](./05-workflows.md) — Five end-to-end workflows: brownfield audit, greenfield scaffold, multi-persona audit, cross-project pattern import, re-audit.
6. [**06 — Governance**](./06-governance.md) — The 22 governance docs, surface split, evidence trust tiers, finding schema, hook governance, MCP allowlist, secrets rotation, pattern-import ledger.
7. [**07 — Contributing**](./07-contributing.md) — How to propose a new sector pack, rule pack, runtime rule, anti-pattern, agent, command, or skill. PR format. ADR triggers. Code of Conduct. Security reporting.
8. [**08 — Troubleshooting**](./08-troubleshooting.md) — Ten common failure modes with symptom, diagnosis, and fix. Links to the full troubleshooting runbook.
9. [**09 — FAQ**](./09-faq.md) — Frequently asked questions about Ulak OS. Comparisons with adjacent tools. Platform support. Licensing. Turkish-language clarifications.

## Where to start

- **Brand new to Ulak OS?** Read [01 — Introduction](./01-introduction.md), skim [03 — Architecture](./03-architecture.md), then install per [02 — Installation](./02-installation.md).
- **Just want to audit an existing project?** Jump to [05 — Workflows](./05-workflows.md) § Workflow 1.
- **Starting a new SaaS?** Jump to [05 — Workflows](./05-workflows.md) § Workflow 2.
- **Something broken?** Start with [08 — Troubleshooting](./08-troubleshooting.md), fall back to [runbooks/troubleshooting](../../runbooks/troubleshooting.md).
- **Evaluating vs alternatives?** Read [09 — FAQ](./09-faq.md).

## Also useful

- Top-level English README: [`../../../README.en.md`](../../../README.en.md)
- Runbooks: [install methods](../../runbooks/install-methods.md), [troubleshooting](../../runbooks/troubleshooting.md), [first hour](../../runbooks/first-hour-with-ulak-os.md)
- Showcase walkthroughs: [`../../showcase/README.md`](../../showcase/README.md)
- Architecture diagrams: [`../../architecture/overview.md`](../../architecture/overview.md)
- Version history: [`../../history/version-lineage.md`](../../history/version-lineage.md)

## Feedback

This manual is versioned with the code. If something is unclear, open an issue at `github.com/osrt91/ulak-os` or email the maintainer (see [07 — Contributing](./07-contributing.md) § Security).

## Conventions used in this manual

- **Code blocks** show commands you type. Shell commands assume bash or zsh on POSIX systems; PowerShell equivalents are called out where the syntax differs.
- **Relative paths** (`./`, `../`, `../../`) point at files inside this repository.
- **Angle brackets** (`<like-this>`) indicate a placeholder you replace with your own value.
- **File paths** in prose use backticks, for example `reports/current/manager-verdict.md`.
- **Abstract examples** (ExampleCorp, AcmeBuilder, BetaStore, "a Turkish-primary SaaS") stand in for real operator projects — this is the project's [redaction discipline](../../../CONTRIBUTING.md).

---

Next: [01 — Introduction](./01-introduction.md)
