# Ulak OS User Manual (English)

Welcome to the English user manual for **Ulak OS v1.6.0** — a vendor-neutral prompt operating system for AI coding CLIs (Claude Code, Codex, Copilot, Gemini).

This manual is written for **English-speaking developers** evaluating Ulak OS or adopting it into a new or existing project. It assumes you know how to use a terminal and have installed at least one of the supported AI coding CLIs. It does not assume prior knowledge of the project's internal history.

Türkçe eşdeğeri: [`../tr/README.md`](../tr/README.md).

## What's new in v1.6

- **24 commands** (up from 9 in v1.0) including the new onboarding + discovery layer
- **Four vendors** supported (Claude Code, Codex, Copilot, Gemini) — up from one
- `hi ulak` natural-language entry — no need to memorize slash commands
- Four external-service tutorials (Supabase, Vercel, GitHub, Resend)
- Three showcase walkthroughs (audit, scaffold, persona) + video script
- 47-term beginner glossary fueling `/ulak-explain`
- Seven ADRs (up from four) + governance documents for vendor-capability-matrix and localization
- Cross-vendor adapter layer with NL trigger map for Codex and Copilot

See [chapter 01 § What changed in v1.6?](./01-introduction.md#what-changed-in-v16) for the full summary.

## How long does it take to read?

About **45 minutes** cover-to-cover. Each chapter is self-contained — jump to the one that matches your situation.

## Prerequisites

- **One** AI coding CLI installed:
  - [Claude Code](https://claude.com/claude-code) (primary — full feature support)
  - Codex CLI (supported via `AGENTS.md` + NL trigger map)
  - Copilot CLI (supported via `AGENTS.md` + NL trigger map)
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli) (supported via `.gemini/commands/*.toml`)
- `git` on your PATH.
- Any one of macOS, Linux, or Windows 10+ (PowerShell 5.1 or newer on Windows).

No compiler, no runtime beyond what your CLI already needs. Ulak OS is prompts and markdown, not a compiled tool.

## Chapters

1. [**01 — Introduction**](./01-introduction.md) — What Ulak OS is in v1.6, three core capabilities, the new vision layer, four-vendor framing, who it is for, what it is not.
2. [**02 — Installation**](./02-installation.md) — One-liner installer, manual clone, submodule integration, per-vendor setup (5 methods × 4 vendors), `hi ulak` natural greeting, `ulak init`, verification, uninstall.
3. [**03 — Architecture**](./03-architecture.md) — The `@`-import chain, layer map, v1.6 pack taxonomy (15 sector overlays / 22 governance / 7 ADRs / 4 runbooks / 4 tutorials / 3 walkthroughs / 47-term glossary), public runtime vs hidden core, Phase 0 → 5 protocol, vendor adapter layer with NL trigger map.
4. [**04 — Commands**](./04-commands.md) — All 24 slash commands in three categories (onboarding + discovery, project lifecycle, meta / governance) with per-vendor support matrix (Claude / Codex / Copilot / Gemini).
5. [**05 — Workflows**](./05-workflows.md) — Five canonical workflows: first-time SaaS (beginner path with `hi ulak`), existing-project audit, learn-a-service, pack expansion, cross-project pattern lift.
6. [**06 — Governance**](./06-governance.md) — 22 governance docs + vendor-capability-matrix, 7 ADRs, 4 runbooks, 4 tutorials, 3 walkthroughs, beginner-glossary, localization-governance, surface split, trust tiers, pattern-import ledger.
7. [**07 — Contributing**](./07-contributing.md) — Ten contribution types, vendor-parity discipline (`sync-gemini-commands.sh`), bilingual discipline (`validate-bilingual.sh`), ADR triggers, security reporting.
8. [**08 — Troubleshooting**](./08-troubleshooting.md) — Core troubleshooting + new beginner / service-setup section (Supabase auth, Vercel env, GitHub push protection, Resend domain verify) + self-serve problem solving via `/ulak-ask` and `/ulak-explain`.
9. [**09 — FAQ**](./09-faq.md) — Five manual-specific questions (how to read, TR vs EN, offline usage, upgrade path, fallback adapter). Canonical FAQ at [`docs/FAQ.md`](../../FAQ.md).

## Where to start

- **Brand new? Want the shortest path?** Install per [02 — Installation](./02-installation.md), then type `hi ulak` in your CLI. Or: [05 — Workflow 1](./05-workflows.md#workflow-1--first-time-saas-beginner-path).
- **Just want to audit an existing project?** [05 — Workflow 2](./05-workflows.md#workflow-2--existing-project-audit).
- **Starting a new SaaS?** [05 — Workflow 1](./05-workflows.md#workflow-1--first-time-saas-beginner-path) (beginner path) or run `/ulak-start` directly.
- **Learning a specific service?** [`../../tutorials/`](../../tutorials/README.md) — Supabase, Vercel, GitHub, Resend.
- **Looking up a technical term?** `/ulak-explain <term>` or [`../../runtime/beginner-glossary.md`](../../runtime/beginner-glossary.md).
- **Want to see an actual run?** [`../../showcase/README.md`](../../showcase/README.md) — three annotated walkthroughs.
- **Something broken?** [08 — Troubleshooting](./08-troubleshooting.md), then [`../../runbooks/troubleshooting.md`](../../runbooks/troubleshooting.md).
- **Evaluating vs alternatives?** [09 — FAQ](./09-faq.md) plus [`../../FAQ.md`](../../FAQ.md).

## Also useful

- Top-level English README: [`../../../README.en.md`](../../../README.en.md)
- Runbooks (4): install, troubleshooting, first-hour, upgrading — [`../../runbooks/`](../../runbooks/)
- Tutorials (4): Supabase, Vercel, GitHub, Resend — [`../../tutorials/`](../../tutorials/README.md)
- Showcase walkthroughs (3) + video script — [`../../showcase/README.md`](../../showcase/README.md)
- ADRs (7) — [`../../adr/`](../../adr/)
- Architecture diagrams — [`../../architecture/overview.md`](../../architecture/overview.md)
- Version history — [`../../history/version-lineage.md`](../../history/version-lineage.md)
- Vendor capability matrix — [`../../governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md)

## Feedback

This manual is versioned with the code. If something is unclear, open an issue at `github.com/osrt91/ulak-os` or email the maintainer (see [07 — Contributing](./07-contributing.md) § Security).

## Conventions used in this manual

- **Code blocks** show commands you type. Shell commands assume bash or zsh on POSIX systems; PowerShell equivalents are called out where the syntax differs.
- **Relative paths** (`./`, `../`, `../../`) point at files inside this repository.
- **Angle brackets** (`<like-this>`) indicate a placeholder you replace with your own value.
- **File paths** in prose use backticks, for example `reports/current/manager-verdict.md`.
- **Abstract examples** (ExampleCorp, AcmeBuilder, BetaStore, "a Turkish-primary SaaS") stand in for real operator projects — this is the project's [redaction discipline](../../../CONTRIBUTING.md).
- **Vendor-support legend.** ✓ = full support. 🟡 = partial (serial fallback, NL trigger, reduced scope). ❌ = exempt / unsupported.

---

Next: [01 — Introduction](./01-introduction.md)
