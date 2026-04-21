# 09 — FAQ

Frequently asked questions about Ulak OS. Written for an English-speaking developer evaluating or adopting Ulak OS.

For the canonical FAQ (used as the single source of truth for this chapter), see [`../../FAQ.md`](../../FAQ.md). This chapter is the manual-aligned version.

## What is Ulak OS?

Ulak OS is a vendor-neutral prompt operating system that sits on top of AI coding CLIs (Claude Code, Codex / Copilot, Gemini CLI). One core contract, three vendor adapters. It does three things in a single pack: **audit** (the `/director` protocol — parallel specialist subagents, a 15-dimension scorecard, an anti-pattern catalog), **govern** (22 governance docs + 24 sector packs + 8 rule packs loaded every session), and **scaffold** (`/ulak-scaffold` produces a shippable full-stack SaaS at commit 1).

## Who is it for?

Four personas (see [chapter 01](./01-introduction.md) for the detail):

1. **Solo developer starting a new SaaS** — runs `/ulak-scaffold` once and ships commit 1 with governance baked in.
2. **Small team inheriting a brownfield** — runs `/director komple` for a deep audit with file-level evidence.
3. **Agency with a portfolio of client projects** — uses the pattern-import ledger and sector packs as institutional memory.
4. **Brownfield rescue lead** modernizing a legacy monolith — uses god-module decomposition, the Strangler Fig protocol, and the Waves pattern.

## How is it different from `superpowers`?

`superpowers` is a **skill bundle** — a collection of sharp, narrow skills (brainstorming, systematic debugging, writing plans) you opt into one at a time. Ulak OS is the layer above that: a full prompt OS with a protocol (Phase 0 → Phase 5 director), governance surface (22 docs that gate decisions), a scaffolder, and multi-vendor adapters.

The two are **complementary**. Ulak OS happily invokes `superpowers:brainstorming` during Phase 2 when a domain design decision needs it. Use `superpowers` when you want sharp tools; use Ulak OS when you want a disciplined protocol.

## How is it different from `everything-claude-code`?

`everything-claude-code` is a **command / skill bundle** — a convenience pack of slash commands and skills. Ulak OS adds three layers on top:

- A **manager-verdict validation gate** that refuses premature "done".
- A **governance surface** (trust tiers, pattern-import ledger, artefact-write authorization).
- A **greenfield scaffolder** that ships SaaS starters with governance pre-wired.

If you want "more commands", use the former. If you want "a protocol that refuses to let you ship premature work", use Ulak OS.

## How is it different from `cartographer`?

`cartographer` is **one agent** that produces a deep system map. Ulak OS **absorbs that capability** as Phase 1 of the director protocol and runs it alongside 12+ other specialists in parallel. If all you need is a file-and-line inventory, cartographer alone is lighter. If you want inventory plus evidence plus findings plus target state plus roadmap plus signoff, Ulak OS is the superset.

## Can I use it without Claude Code?

Yes. The core contract is vendor-neutral. The same `@`-import chain loads under Claude Code, Codex / Copilot (via `AGENTS.md`), and Gemini CLI (via `.gemini/commands/*.toml`).

Some commands are Claude-first. For example `/frontend-war-room` depends on Claude Code's specific parallel subagent dispatch semantics, and it is listed in `.claude/vendor-parity-exemptions.txt` with a rationale. The audit flow and the scaffold flow work on all three vendors.

## Is it safe for production use?

Yes, with one honest caveat: Ulak OS never ships code to production on its own — it is a prompt layer, not a deploy tool. What it does guarantee:

- Every finding carries a trust tier (T1–T7).
- The validation gate refuses `signoff_status: ready` when live probes fail.
- The scaffolder gates eight anti-patterns by construction (single auth helper, server-only guards, DB-sourced role, RLS symmetry, `.gitignore` discipline, gitleaks baseline, health-probe webhook, VPS hardening).
- All artefacts land in your repo under `reports/current/` — auditable after the fact.

Production risk is **your** risk on your code. Ulak OS raises the floor; it does not remove the ceiling.

## Does it store my code anywhere?

No. Ulak OS is a static prompt pack. All artefacts are written to `reports/current/` **inside your own repo**. Nothing phones home. No telemetry. The only network activity is (a) the one-time `git clone` during install and (b) whatever your AI coding CLI does with its own model provider.

## Does it work on Windows?

Yes. Tested on Windows 11 with PowerShell 5.1+. Installer: `scripts/install.ps1`. The `ulak` command ships as `ulak.cmd` that dispatches to `bin/ulak.ps1`.

## Does it work on macOS?

Yes. Tested on macOS with zsh (default) and bash. Installer: `scripts/install.sh`. The `ulak` command ships as a POSIX shell wrapper under `~/bin/ulak`.

## Does it work on Linux?

Yes. Tested on Ubuntu 22.04 / 24.04 and Fedora. Installer: `scripts/install.sh`. Same POSIX wrapper as macOS.

## Which LLM models does it support?

- **Primary:** Claude (any model available to Claude Code — Opus, Sonnet, Haiku).
- **Supported via adapter:** Gemini (via Gemini CLI), GPT family (via Codex / Copilot).
- **Model-agnostic in principle:** the core contract is plain markdown. Any agent that respects `@`-imports and can dispatch subagents will work, with varying fidelity.

The director protocol works best when the model supports parallel subagent dispatch. On models without parallel tool use, the director falls back to serial dispatch with a context-budget warning.

## Does it work offline?

**Partially.**

- **Install:** requires network (git clone).
- **Audit / scaffold:** offline-capable as long as your AI coding CLI can run offline. Ulak OS itself makes no network calls during a run.
- **MCP connectors:** anything that talks to a remote MCP (GitHub, Figma, Jira) is network-bound; those connectors are optional and skipped when env vars are absent.

Hermetic audits are explicitly supported — [`docs/runtime/toolchain-precheck.md`](../../runtime/toolchain-precheck.md) flags any agent that tries to make a network call during a run marked offline.

## What's the license?

[MIT](../../../LICENSE). Fork it, adapt it, apply it to your own operations. Attribution is enough.

## How do I contribute?

Read [chapter 07](./07-contributing.md) or [`../../../CONTRIBUTING.md`](../../../CONTRIBUTING.md). The short version: new sector packs, anti-patterns, or rule packs all require **file-and-line citations from ≥2 real projects** (abstract descriptors if the projects are private). Every cross-project pattern lift gets an entry in `docs/governance/pattern-import-ledger.md` with a trust tier ≥ T2.

## Is it free?

Yes. MIT license. No paid tier, no SaaS backend, no usage metering. You pay whatever your AI coding CLI's provider charges for model calls — that is it. Ulak OS itself is prompts and markdown.

## How much context does it consume?

The core contract is ~33 runtime rule files + 22 governance docs + 8 rule packs + whichever sector pack the router picks — typically 30–60k tokens loaded at session start. That leaves plenty of room on 200k and 1M-context models.

If you are on a narrower context window (for example 128k), the `output-profiles.md` rule file lets you select a lighter profile (AUDIT vs GREENFIELD_BUILDER, etc.) that loads only the relevant runtime rules.

## Will it modify my CI or workflow files?

No — not without explicit instruction. The scaffolder **creates** `.github/workflows/` files for greenfield projects. The director **reads** them in a brownfield project and reports findings. If you want Ulak OS to propose CI changes, it produces a diff in `reports/current/execution-roadmap.md` — you apply it, not the agent.

## How do I uninstall?

Depends on install method — see [chapter 02](./02-installation.md) § Uninstall for each path. Short version for the one-liner install:

```bash
rm -rf ~/.ulak-os ~/bin/ulak
```

Your projects' `CLAUDE.md` files still have `@`-imports pointing at the removed install dir. Either remove those lines or re-run the installer to reconnect.

## I don't speak Turkish — is that OK?

Yes. The project's origin is Turkish (the word "Ulak" means "messenger" / "courier"), and some runtime rule files retain Turkish imperatives. For example you may see `validation olmadan done deme` which means "do not say done without validation". These are embedded commands to the AI coding CLI, not content you need to read.

The user-facing surface is bilingual:
- `README.en.md` and `README.md` (Turkish) are full parity.
- `CLAUDE.en.md` and `CLAUDE.md` are full parity.
- `AGENTS.en.md` and `AGENTS.md` are full parity.
- `GEMINI.en.md` and `GEMINI.md` are full parity.
- This user manual lives in both `docs/user-manual/en/` and `docs/user-manual/tr/`.

Every command accepts English arguments. Every artefact is produced in whatever language your AI coding CLI session is running in. If you only read English, stick to `README.en.md` and the `docs/user-manual/en/` tree — you miss nothing material.

## What does "Ulak" mean?

"Ulak" is Turkish for "messenger" or "courier". The project is a messenger between your intent and your AI coding CLI — it carries governance, context, and validation discipline across the gap.

## How often is it updated?

Approximately every one to two weeks. The canonical source of truth is `CHANGELOG.md` and `git log`. Tags follow [semantic versioning](../../../VERSIONING.md): MAJOR for breaking contract changes, MINOR for append-only additions (the common case), PATCH for fixes.

## Where can I see a demo?

Text-based walkthroughs are in [`../../showcase/`](../../showcase/README.md). There are four:

1. Audit walkthrough (`/director komple` on a fictional brownfield SaaS)
2. Scaffold walkthrough (`/ulak-scaffold` for a greenfield payment-integrated SaaS)
3. Persona audit (`/director dispatch=persona` with four personas)
4. Cross-project pattern import (absorbing a pattern from one fictional project into another)

A video script (for recording a 5-minute demo) is at `docs/showcase/video-script.md`.

## Will my existing `CLAUDE.md` be overwritten?

No. `ulak init` is **append + backup**. If a `CLAUDE.md` exists in the target project, the tool creates `CLAUDE.md.ulak-backup` before modifying anything. You can restore from the backup or from `git checkout HEAD -- CLAUDE.md` if anything goes wrong.

## Can I run multiple versions side by side?

Yes. Use the manual-clone install method (Method 2 in [chapter 02](./02-installation.md)) with different install directories (for example `~/tools/ulak-os-1.0.0` and `~/tools/ulak-os-1.1.0`). Each project's `CLAUDE.md` points at whichever version it wants.

## What is NOT Ulak OS?

Honest list (expanded in [chapter 01](./01-introduction.md)):

- Not an IDE or editor.
- Not a model.
- Not a linter.
- Not a CI platform.
- Not an application runtime.
- Not a replacement for reading the code.
- Not telemetry-emitting.

## Further reading

- Full FAQ (source of truth): [`../../FAQ.md`](../../FAQ.md)
- Top-level English README: [`../../../README.en.md`](../../../README.en.md)
- First hour with Ulak OS: [`../../runbooks/first-hour-with-ulak-os.md`](../../runbooks/first-hour-with-ulak-os.md)
- Version lineage: [`../../history/version-lineage.md`](../../history/version-lineage.md)

---

Next: [README](./README.md)
