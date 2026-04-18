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

## Drift detection (a Phase 1 deep-inventory task)

Project memory rots. Facts that were true when the memory was written may no longer be true. "This project has 17 plugins" becomes "this project has 40 plugins" silently — the plugin count grows in the filesystem, nobody updates CLAUDE.md, and the next Ulak OS director run cites the stale count.

Drift is a form of evidence degradation. A T2 fact (claimed in CLAUDE.md) can drop to T7 (unvalidated assumption) when the filesystem contradicts it. Detection is the job of the Phase 1 cartographer, not the writer of CLAUDE.md.

### Drift patterns observed

From the scanner-project.com session (2026-04-11):

- **CLAUDE.md** claimed `scanner-project.py` was **3318 lines**. Reality: 73 lines (a shim file after a refactor). 45x drift.
- **CLAUDE.md** claimed **17 plugins**. Reality: 40. 2.4x drift.
- **CLAUDE.md** claimed **43 Docker services**. Reality: 32. 25% drift downward.

None of these facts were load-bearing for correctness, but every director run that cited them carried false context. The effect compounds: a specialist reading "17 plugins" scans differently than one reading "40 plugins".

### Detection protocol

In Phase 1 (deep inventory), the cartographer compares memory claims to filesystem facts:

1. **Parse CLAUDE.md** (and imported memory files) for numeric claims (file counts, line counts, service counts, dependency counts, route counts)
2. **Query the filesystem** for the actual current count
3. **Diff** — flag any claim that differs from reality by more than 10% or 1 order of magnitude (whichever is smaller)
4. **Write drift findings** into `reports/current/did-you-know.md` or a dedicated `reports/current/memory-drift.md`
5. **Downgrade T-tier** of any finding that cited the stale number from T2 (memory) to T7 (contradicted)

### Drift as a finding

Drift findings use the standard finding-schema with:

```yaml
- id: DRIFT-001
  area: prompt
  title: "CLAUDE.md plugin count out of date"
  problem: "CLAUDE.md:line X claims 17 plugins, filesystem has 40 (src/plugins/)"
  evidence: "CLAUDE.md:42 + ls src/plugins/ | wc -l = 40"
  evidence_trust: T2
  severity: Low
  priority: P2
  tags: [memory-drift, documentation]
  recommended_fix: "Update CLAUDE.md:42 plugin count to 40, or replace literal count with 'see src/plugins/'"
  validation: "grep -c '17 plugin' CLAUDE.md == 0 after fix"
```

### Why drift detection is worth the cost

Drift detection is cheap (one grep + one filesystem query per claim) and prevents downstream specialists from reasoning on stale facts. The cost of a specialist writing a 500-line report based on a stale claim is much higher than the cost of finding the drift early.

### Recommended drift-prone claim types to watch

- File counts ("N source files", "N plugins", "N migrations")
- Line counts of specific files
- Service counts ("N Docker services", "N API endpoints")
- Dependency counts ("N npm packages", "N python packages")
- Test counts ("N pytest tests passing")
- Locale counts ("supports N languages")
- Version numbers of embedded dependencies

### Integration

- `docs/runtime/program-phases.md` — Phase 1 cartographer task includes drift detection as a step
- `docs/governance/finding-schema.md` — DRIFT-* findings use the standard finding schema
- `docs/governance/evidence-trust-scoring.md` — a memory claim contradicted by drift detection drops from T2 to T7 (contradicted)
- `docs/runtime/artefact-contract.md` — `memory-drift.md` is an optional Phase 1 artefact when drift is detected

## Worktree cleanup policy (G-EXT-02)

Claude Code agent sessions can create isolated git worktrees under `.claude/worktrees/agent-<hex>/` for parallel work. These directories persist after the agent session ends. Without a cleanup policy, worktrees accumulate — scanner-project.com's audit found **12 stale worktree directories (~19 days old)** with no policy. Each worktree holds a full checkout, often gigabytes.

### Lifecycle states

| State | Age | Flag |
|---|---|---|
| **Active** | < 24h OR session.pid alive | safe — current work |
| **Recent** | 24h–7d AND session.pid dead | warn — stale, worth checking if anything uncommitted |
| **Stale** | 7–30d | flag in `pack-gap-audit` / memory-drift report |
| **Auto-prune eligible** | > 30d | operator-initiated prune; never silent |

### Cleanup protocol

1. **Detection** — Phase 1 cartographer (and the `pack-gap-audit` command) enumerate `.claude/worktrees/*/` and classify by age
2. **Stale report** — stale + auto-prune-eligible worktrees listed in `reports/current/did-you-know.md` (or dedicated `worktree-health.md`)
3. **Check before prune** — each worktree classified for auto-prune gets a `git status` check. If uncommitted changes exist, the worktree is downgraded to "needs manual review" and NOT auto-pruned
4. **Prune** — `git worktree remove <path>` for worktrees confirmed clean + past auto-prune threshold
5. **Audit trail** — pruned worktrees logged to `.claude/logs/worktree-pruned.log` with timestamp, path, last-commit-sha

### Never silently prune

Silent pruning breaks the operator's mental model. Every prune goes through:

- An artefact listing the candidates (for operator review)
- Explicit confirmation (operator command OR scheduled-task configuration approved by operator)
- A log entry with the last commit SHA so a prune can be partially reversed via `git worktree add` against the SHA

### Git-ignored

`.claude/worktrees/` is gitignored (covered by `docs/governance/settings-permissions-governance.md`). If a worktree directory is committed, that's itself a finding — it leaks agent session state into history.

### Cross-environment concerns

- **PID-based liveness check** needs to handle the case where the owning process is on a different machine (remote worktree); record `hostname` in a per-worktree lockfile (see `docs/governance/lock-file-hygiene.md`)
- **Containerized sessions** — worktrees inside Docker should be bind-mounted, not created fresh per container launch

## Integration

- `docs/runtime/context-budget.md` — memory content counts as Layer 3 (project memory) in the context budget
- `docs/governance/surface-split.md` — memory belongs to the public runtime surface, not hidden core
- `docs/governance/settings-permissions-governance.md` — `.claude/worktrees/` gitignored
- `docs/governance/lock-file-hygiene.md` — per-worktree lock file + pid liveness
- `CLAUDE.md` — the project's actual memory file; this governance applies to it
