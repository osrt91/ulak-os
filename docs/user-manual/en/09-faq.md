# 09 — FAQ

This chapter answers frequently asked questions **about reading and using this user manual**. The general Ulak OS FAQ is maintained separately as the canonical source of truth: [`../../FAQ.md`](../../FAQ.md) (376 lines).

The manual-specific Q&A below supplements it — read both.

## Q1. How should I read this manual?

Three reading paths depending on your situation:

**Brand new, want to start building.** Read chapter 01 (what is this?), skim chapter 03 (architecture map — skip the deep bits), then jump to [chapter 05 § Workflow 1](./05-workflows.md#workflow-1--first-time-saas-beginner-path). About 20 minutes total before you run `hi ulak`.

**Brand new, want to audit an existing project.** Read chapter 01, install per chapter 02, then jump to [chapter 05 § Workflow 2](./05-workflows.md#workflow-2--existing-project-audit). About 25 minutes before your first `/director komple`.

**Evaluating Ulak OS for a team.** Read chapter 01, chapter 03 in full, [chapter 06](./06-governance.md), and chapter 09 of this manual plus the canonical [`../../FAQ.md`](../../FAQ.md). About 60 minutes. Then read one showcase walkthrough in [`../../showcase/`](../../showcase/README.md) to see actual output.

Every chapter is self-contained. If you only want command syntax, jump straight to [chapter 04](./04-commands.md).

## Q2. Why are there two languages (TR and EN)?

Ulak OS originated in Turkish and the project name is Turkish ("ulak" means "messenger / courier"). The public surface is bilingual:

- `docs/user-manual/tr/` — Turkish version
- `docs/user-manual/en/` — English version (this one)

Both are kept in parity by `scripts/validate-bilingual.sh` — every heading, every chapter count, every command description exists in both. You can safely pick one and miss nothing material.

The default on your system is controlled by `/ulak-locale` (persistent state in `.claude/state/locale.txt`). If you want the README and user surface to default to English, run:

```
/ulak-locale en
```

For Turkish:

```
/ulak-locale tr
```

Some runtime rule files keep Turkish imperatives (for example "validation olmadan done deme" — "do not say done without validation") because they instruct the AI, not the operator. They do not leak into English output.

See [`docs/governance/localization-governance.md`](../../governance/localization-governance.md) for the enforcement contract.

## Q3. Can I use Ulak OS offline?

Partially:

- **Install:** requires network (`git clone`).
- **Reading the manual:** fully offline once cloned — everything is markdown.
- **Running audits / scaffolds:** offline-capable as long as your AI coding CLI has an offline mode. Ulak OS itself makes no network calls during a run.
- **Tutorials in `docs/tutorials/`:** require network because they cover account creation on external services (Supabase, Vercel, GitHub, Resend).
- **MCP connectors that talk to remote systems (GitHub, Figma):** network-bound; skipped when env vars are absent.

Hermetic audits are explicitly supported. `docs/runtime/toolchain-precheck.md` flags any agent that tries to make a network call during a run marked offline.

## Q4. How do I upgrade from an older version?

**From v1.0 – v1.5 (additive).** Just `git pull` or re-run the one-liner installer. The changes are append-only: new commands, new governance docs, new tutorials. Your existing `CLAUDE.md` imports continue to work. No migration needed.

**From v0.x (pre-public).** The core contract path changed. Old `CLAUDE.md` imports pointing at the pre-1.0 path must be updated to `prompts/core/ulak-os-core-contract-2.0.0.md`. See [`docs/runbooks/upgrading-from-v2.x.md`](../../runbooks/upgrading-from-v2.x.md).

**To a future v2.x.** If a major version ships, that runbook will document every breaking change with before/after examples. Until then, stay on v1.x — minor bumps are safe.

**Checking your version:**

```bash
ulak --version
ulak where          # prints install directory + git ref
```

The install dir holds a `git` checkout. If you want to pin to a specific tag:

```bash
cd ~/.ulak-os     # or wherever you installed
git fetch --tags
git checkout v1.6.0
```

## Q5. What if my AI coding CLI is not in the supported-four list?

Ulak OS v1.6 officially supports four adapters: Claude Code, Codex, Copilot, Gemini. If you use a different CLI:

**Fallback adapter path.** Any CLI that:
1. Respects `@`-import directives in a startup memory file, and
2. Can run markdown-defined agents sequentially

can load Ulak OS by importing the core contract:

```markdown
# Your-CLI-startup-file.md
@/absolute/path/to/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
```

You lose parallel subagent dispatch (Phase 2 falls back to serial). Commands that depend on slash-command syntax need to be invoked via natural-language intent matching — the NL trigger map in `AGENTS.md` works as a reference vocabulary.

**File-an-adapter-request.** If your CLI is widely used and a proper adapter would be useful, open an issue with the label `vendor-adapter-request`. Provide:
- CLI name and version
- How the CLI loads context (entry file, import syntax)
- Command dispatch shape (slash commands, NL, keyword trigger)
- Parallel dispatch capability

Adapters are accepted as contributions — see [chapter 07](./07-contributing.md).

**Known non-supported CLIs (as of v1.6).** Cursor, Zed's AI panel, Windsurf — these currently lack the `@`-import semantics Ulak OS relies on. Track adapter progress in the issue tracker.

## Further reading

- Canonical FAQ (376 lines, single source of truth): [`../../FAQ.md`](../../FAQ.md)
- Top-level English README: [`../../../README.en.md`](../../../README.en.md)
- First hour narration: [`../../runbooks/first-hour-with-ulak-os.md`](../../runbooks/first-hour-with-ulak-os.md)
- Version history: [`../../history/version-lineage.md`](../../history/version-lineage.md)
- Showcase walkthroughs: [`../../showcase/README.md`](../../showcase/README.md)
- Tutorials (Supabase, Vercel, GitHub, Resend): [`../../tutorials/README.md`](../../tutorials/README.md)
- Beginner glossary (47 terms): [`../../runtime/beginner-glossary.md`](../../runtime/beginner-glossary.md)

---

Next: [README](./README.md)
