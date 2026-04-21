# FAQ

Frequently-asked questions about Ulak OS — what it is, who it is for, how it differs from adjacent tools, and what it is honestly **not**.

---

## What is Ulak OS?

Ulak OS is a **vendor-neutral prompt operating system** that sits on top of AI coding CLIs (Claude Code, Codex / Copilot, Gemini CLI). One core contract, three vendor adapters. It does three things in a single pack: **audit** (the `/director` protocol — 27 specialist agents, 15-dimension scorecard, 79 anti-pattern sweep), **govern** (22 governance docs + 24 sector packs + 8 rule packs loaded every session), and **scaffold** (`/ulak-scaffold` produces a shippable full-stack SaaS at commit 1).

## Who is it for?

Four personas, roughly in order of how much value they extract in week 1:

1. **Solo developer starting a new SaaS.** Runs `/ulak-scaffold` once and ships a Next.js + Supabase + payment + i18n + CI + deploy project with 8 anti-patterns already gated by construction.
2. **Small team inheriting a brownfield.** Runs `/director komple` for a deep audit — inventory, evidence register, persona-split findings, target state, execution roadmap, validation plan, manager verdict.
3. **Agency running multiple client projects.** Uses the pattern-import ledger and sector packs as institutional memory; every project inherits the same governance baseline.
4. **Incumbent-refactor lead** modernizing a legacy monolith. Uses god-module-decomposition, Strangler Fig protocol, and the Waves pattern to sequence risky refactors.

## How is it different from `superpowers`?

`superpowers` is a **skill bundle** — a collection of sharp, narrow skills (brainstorming, systematic-debugging, writing-plans) that you opt into. Ulak OS is the layer above that: a **full prompt OS** with a protocol (Phase 0 → Phase 5 director), governance surface (22 docs that gate decisions), a scaffolder, and multi-vendor adapters. The two are complementary — Ulak OS happily invokes `superpowers:brainstorming` during Phase 2 when a domain design decision needs it.

## How is it different from `everything-claude-code`?

`everything-claude-code` is a **command/skill bundle** — a convenience pack of slash commands and skills. Ulak OS adds three layers on top: (a) a manager-verdict validation gate that refuses premature "done", (b) a governance surface (trust tiers, pattern-import ledger, artefact-write authorization), and (c) a greenfield scaffolder. If you want "more commands", use the former; if you want "a protocol that refuses to let you ship premature work", use Ulak OS.

## How is it different from `cartographer`?

`cartographer` is **one agent** that produces a deep system map. Ulak OS **absorbs that capability** as Phase 1 of the director protocol and runs it in parallel with 12+ other specialists. If all you need is a file-and-line inventory of an unfamiliar codebase, cartographer is lighter; if you want the inventory plus evidence, findings, target state, roadmap, and signoff, Ulak OS is the superset.

## Can I use it without Claude Code?

Yes. The core contract is vendor-neutral — the same `@`-import chain loads under Claude Code, Codex/Copilot (via `AGENTS.md`), and Gemini CLI (via `.gemini/commands/*.toml`). Some commands are Claude-first (e.g., `/frontend-war-room` depends on specific Claude Code agent dispatch semantics); those appear in `vendor-parity-exemptions.txt` with a rationale. The audit and scaffold flows work on all three.

## Is it safe for production use?

Yes, with one caveat: Ulak OS never ships code to production on its own — it is a prompt layer. What it does guarantee:

- Every finding carries a trust tier (T1–T7, see `docs/governance/evidence-trust-scoring.md`).
- The validation gate refuses "ready" when live probes fail.
- The scaffolder gates 8 anti-patterns by construction (single auth helper, server-only guards, DB-sourced role, RLS symmetry, `.gitignore` discipline, gitleaks baseline, health-probe webhook, VPS hardening).
- All artefacts land in your repo under `reports/current/` — auditable after the fact.

Production risk is **your** risk on your code — Ulak OS raises the floor but does not remove the ceiling.

## Does it work on Windows?

Yes. Tested on Windows 11 with PowerShell 5.1+. Installer: `scripts/install.ps1`. The `ulak` command ships as `ulak.cmd` that dispatches to `bin/ulak.ps1`.

## Does it work on macOS?

Yes. Tested on macOS with zsh (default) and bash. Installer: `scripts/install.sh`. The `ulak` command ships as a POSIX shell wrapper under `~/bin/ulak`.

## Does it work on Linux?

Yes. Tested on Ubuntu 22.04 / 24.04 and Fedora. Installer: `scripts/install.sh`. Same POSIX wrapper as macOS.

## What's the license?

[MIT](./LICENSE). Fork it, adapt it, apply it to your own operations. Attribution is enough.

## How do I contribute?

Read [CONTRIBUTING.md](./CONTRIBUTING.md). The short version: new sector packs / anti-patterns / rule packs all require **file:line citations from ≥2 real projects** (abstract descriptors if the projects are private). Every cross-project pattern lift gets an entry in `docs/governance/pattern-import-ledger.md` with a trust tier ≥ T2.

## How do I report a security issue?

Do **not** open a public GitHub issue for security problems. Email the maintainer directly (address listed in `CODE_OF_CONDUCT.md`). Expect a response within 72 hours.

## Does it store my code anywhere?

No. Ulak OS is a static prompt pack. All audit artefacts are written to `reports/current/` **inside your own repo**. Nothing phones home. No telemetry. The only network activity is (a) the one-time `git clone` during install and (b) whatever your AI coding CLI does with its own provider.

## Which LLM models does it support?

- **Primary:** Claude (any model available to Claude Code — Opus, Sonnet, Haiku).
- **Supported via adapter:** Gemini (via Gemini CLI), GPT family (via Codex / Copilot).
- **Model-agnostic in principle:** the core contract is plain markdown. Any agent that respects `@`-imports and can dispatch subagents will work, with varying fidelity.

The director protocol works best when the model supports parallel subagent dispatch. On models without parallel tool use, the director falls back to serial dispatch with a context-budget warning.

## Can I run it offline?

**Partially.**

- Install: requires network (git clone).
- Audit / scaffold: offline-capable as long as your AI coding CLI can run offline. Ulak OS itself makes no network calls.
- MCP connectors: anything that talks to a remote MCP (GitHub, Jira, Figma) is network-bound; those connectors are optional and skipped when env vars are absent.

Hermetic audits are explicitly supported — `docs/runtime/toolchain-precheck.md` flags any agent that tries to make a network call during a marked-offline run.

## Does it support non-Turkish locales?

Yes. The default locale is Turkish (the project's origin), but the localization-SSOT rule pack enforces ≥2 locales on any scaffolded project. English is first-class; other locales inherit from the SSOT. Pack docs are bilingual (`README.md` Turkish, `README.en.md` English) — the rest of the runtime is neutral.

## What does "Ulak" mean?

"Ulak" is Turkish for "messenger" / "courier". The project is a messenger between your intent and your AI coding CLI — it carries governance, context, and validation discipline across the gap.

## What Ulak OS is NOT

Honest list:

- **Not an IDE or editor.** It sits above your AI coding CLI, not beside your editor.
- **Not a model.** It does not train or fine-tune anything. Your provider chooses the model; Ulak OS shapes the prompt.
- **Not a linter.** Anti-patterns are gating prompts, not AST-level rules. For AST linting use your stack's native tools.
- **Not a CI platform.** CI jobs shipped under `.github/workflows/` are examples; a real CI choice is yours.
- **Not a runtime (the code kind).** It does not execute your application.
- **Not a replacement for reading the code.** The director produces evidence, not absolution — review the artefacts.
- **Not done.** v3.0 is the first fully-public release; the scaffolder has 24 sector packs today and will grow; persona dispatch has 7 personas and will grow. This is a living pack.

## How often is it updated?

Approximately every 1-2 weeks during the v3.x series. The canonical source of truth is `CHANGELOG.md` + `git log`. Tags follow [semantic versioning](./VERSIONING.md): MAJOR for breaking contract changes, MINOR for append-only additions (the common case), PATCH for fixes.

## Where can I see a demo?

Walkthroughs land in `docs/showcase/` as they are written. Text-based tours (terminal output, artefact samples) are in `docs/runbooks/first-hour-with-ulak-os.md`.

## Do I have to speak Turkish to use it?

No. The project's origin is Turkish (and some runtime rule files retain Turkish imperatives — e.g., "validation olmadan done deme" = "do not say done without validation"), but the user-facing surface is bilingual. Every command accepts English arguments; every artefact is produced in whatever language your AI coding CLI session is running in. If you only read English, stick to `README.en.md` and you miss nothing material.

## How much context does Ulak OS consume?

The core contract is ~33 runtime rule files + 22 governance docs + 8 rule packs + whichever sector pack the router picks — typically 30-60k tokens loaded at session start. That leaves plenty of room on 200k / 1M-context models. If you are on a narrower context window (e.g., 128k), the `output-profiles.md` rule file lets you select a lighter profile (AUDIT vs GREENFIELD_BUILDER etc.) that loads only the relevant runtime rules.

## Will it respect my existing CI and workflow?

Yes. Ulak OS never mutates your CI or workflow files without explicit instruction. The scaffolder **creates** `.github/workflows/` files for greenfield projects; the director **reads** them and reports findings. If you want Ulak OS to propose CI changes for an existing project, it produces a diff in `reports/current/execution-roadmap.md` — you apply it, not the agent.

## How do I uninstall?

Depends on install method — see `docs/runbooks/install-methods.md` §Uninstall for each path. Short answer for the one-liner install:

```bash
rm -rf ~/.ulak-os ~/bin/ulak
```

Your projects' `CLAUDE.md` files still have `@`-imports pointing at the install dir. Either remove those lines or re-run the installer to reconnect.
