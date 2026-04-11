# Memory Hygiene

## Why this exists

Claude Code (and similar tools) use layered memory: enterprise policy, project memory (`CLAUDE.md`), user memory (`~/.claude/CLAUDE.md`), imported memory (`@path`), and subtree-specific memory (when entering a subdirectory). Without discipline, each of these grows into an unsorted pile of rules, examples, stale facts, and historical notes — and every session loads all of it into the active model context, blurring decisions.

Memory hygiene is the set of rules that keeps memory useful: what belongs where, what gets imported vs inlined, how to rotate stale entries, and how memory interacts with the context budget.

## Memory layers

### Enterprise policy memory
- **Audience**: the organization
- **Contains**: non-negotiable rules — security posture, compliance requirements, forbidden paths, mandatory disclosures, legal boilerplate
- **Written by**: platform / security / compliance teams
- **Lifecycle**: stable across projects; changes only with formal review

### Project memory (`./CLAUDE.md`)
- **Audience**: everyone working in this repo
- **Contains**: project identity, stack, build / test / lint commands, non-negotiable rules *specific to this project*, critical architectural decisions, do-not-touch zones, key file paths
- **Written by**: the team; checked in
- **Lifecycle**: updated when the project's ground truth changes (new dependency, new build command, new guardrail)

### User memory (`~/.claude/CLAUDE.md`)
- **Audience**: one developer across all their repos
- **Contains**: personal preferences (reply style, local tooling versions, favorite commands), personal secrets that shouldn't be in projects
- **Written by**: the individual
- **Lifecycle**: lives with the developer

### Imported memory (`@path`)
- **Purpose**: modularize memory — keep CLAUDE.md short by importing topic-specific files
- **When to use**: when a section of memory would push CLAUDE.md beyond ~500 lines, or when the section is relevant only to a subtree
- **How to use**: `@docs/architecture/README.md` — the `@` prefix tells Claude Code to inline the file at load time

### Subtree memory
- **Purpose**: when entering a subdirectory, load additional rules relevant only to that subtree (e.g., `frontend/CLAUDE.md` for the frontend subfolder)
- **Caveat**: subtree memory stacks on top of root memory; be careful about conflicts

## What goes where

| Content type | Layer |
|---|---|
| "Use `pnpm`, not `npm`" | Project memory |
| "I prefer TypeScript over JavaScript" | User memory |
| "All API responses must match schema X" | Project memory |
| "Never commit to main without review" | Enterprise policy |
| "Here's the full design system token list" | Imported (`@docs/design-system.md`) |
| "Past commit messages follow this format" | Project memory (short) or imported (long) |
| "I want responses in Turkish" | User memory |
| "The frontend subtree uses Next.js 16" | Subtree memory (`frontend/CLAUDE.md`) |
| "Legacy route X is deprecated — don't touch" | Project memory |
| "V7 → V8 → V9 migration notes" | Hidden core, NOT memory |

## Hygiene rules

### 1. Stable vs task-specific
- **Stable**: goes into memory
- **Task-specific**: goes into the conversation or into `reports/current/`
- "What we're working on today" is not memory. It's ephemeral.

### 2. Separate standards from commentary
- Memory entry: "All PRs must have tests"
- Commentary (not memory): "We added this rule after the 2026-02 incident when Alice merged without tests"
- The commentary belongs in commit history or ADRs, not in every loaded context

### 3. Import large supporting docs, don't inline
If a section of memory is more than 50 lines, promote it to its own file and import it. This:
- Keeps CLAUDE.md readable
- Allows selective loading (imported files can be skipped if not relevant)
- Makes updates more surgical

### 4. Rotate stale entries
Memory rots. Rules that were true six months ago may not be true now. Every memory review should ask:
- Is this still correct?
- Is this still relevant?
- Is this still actionable?

Stale entries either get updated, moved to an archive, or deleted.

### 5. Maintainer-only notes never go into active memory
Historical notes, A/B test results, failed variations — these belong in hidden core, not in `CLAUDE.md`. Loading them every session poisons the active context.

### 6. Secrets never go into committed memory
Project memory is checked in. Never put API keys, credentials, or secrets in `CLAUDE.md`. Use `.env.local` files that are gitignored and reference them symbolically in memory ("the DB connection string lives in DATABASE_URL").

### 7. One source of truth per fact
If the project's Node version is recorded in `CLAUDE.md`, in `README.md`, in `.nvmrc`, and in `package.json`, the facts will drift. Pick ONE as the source of truth (usually the machine-readable file) and have memory point to it.

## Hard rules

- **CLAUDE.md should fit in one screen.** Everything larger goes into imports.
- **Memory is for standards, not for session state.** The current task is ephemeral.
- **No secrets in committed memory.** Ever.
- **No historical diff notes in active memory.** That's hidden core.
- **Imports are loaded fully.** They count against context budget.
- **Rotate before you add.** Every memory write is a good time to check if something should be deleted.

## Integration

- `docs/runtime/context-budget.md` — memory content counts as Layer 3 (project memory) in the context budget
- `docs/governance/surface-split.md` — memory belongs to the public runtime surface, not hidden core
- `CLAUDE.md` — the project's actual memory file; this governance applies to it
