---
artefact: pack-gap-proposals
session: oguzhansert-dev-sprint-0-1
date: 2026-04-11
---

# Ulak OS 2.2 — Pack Gap Proposals

Concrete additions to the Ulak OS pack based on what this session
needed and didn't have. Each entry has: **type / name / purpose /
session trigger / priority / rough sketch**.

Ordered by priority (Critical → High → Medium → Low). Reference the
existing `reports/current/pack-gap-register.md` from the target
project for additional gaps the session director already surfaced.

---

## PG-01 [CRITICAL / skill] `parallel-dispatch-planner`

**Type:** skill (extends `superpowers:dispatching-parallel-agents`)

**Purpose:** before calling `Task` on N agents in parallel, build an
explicit file-conflict map and refuse the dispatch if conflicts
exist. Output the map as a table the operator can review.

**Session trigger:** Wave 1 needed 9 agents touching 40+ files. The
orchestrator manually built the conflict map. A skill should do this.

**Sketch:**
```markdown
# parallel-dispatch-planner

## Input
- List of agents + their claimed file scopes (own / must-not-touch)

## Process
1. Union all "own" sets. If any file appears in two "own" sets →
   CONFLICT. Report and refuse.
2. Union all "own" with "must-not-touch". If agent A's own ∩ agent
   B's must-not-touch is non-empty → agent B has lied about its
   scope or agent A is violating B's constraint. Flag.
3. For files with line-range scopes (e.g. "ALLOWED_TABLES array
   only"), verify the ranges are disjoint.
4. Emit a conflict matrix + a green-light or red-light.

## Output
- A file `conflict-matrix.md` under the current run's reports dir
- Either GREEN (proceed to dispatch) or RED (refuse, operator
  must split scope)
```

---

## PG-02 [CRITICAL / contract] `docs/runtime/live-probe-contract.md`

**Type:** runtime contract (new file in `docs/runtime/`)

**Purpose:** formalize Phase 4.5 (live probe) as a mandatory phase
when `validation-plan.md §6` contains ≥1 probe. Today it's an
afterthought.

**Session trigger:** FP-04 — live probe saved the session twice
(JWT reuse false alarm + /opt/oguzhansert not-stale). Both catches
would have been missed in a pure static-analysis protocol.

**Sketch:**
```markdown
# Live Probe Contract

## When required
- validation-plan.md §6 lists ≥1 probe
- OR manager-verdict.md lists any T2 or T3 claim as blocking

## Inputs
- Credential surface (SSH config, API tokens, DB connection strings)
- operator authorization to run read-only probes

## Outputs
- reports/current/live-probe-results.md with one entry per probe
- T-tier upgrades applied to evidence-register.md
- "NF-*" (New Findings from probing) entries in did-you-know.md

## Gates
- Cannot set manager-verdict signoff_status = ready with unresolved
  probes
- Cannot schedule destructive Sprint 0/1 items without a matching
  pre-check probe
```

---

## PG-03 [CRITICAL / hook] `director-artefact-write-exempt` hook

**Type:** system hook (pre-tool-use hook on Write)

**Purpose:** exempt director-protocol artefact writes
(`reports/current/*.md` and `reports/current/specialists/*.md`) from
the "don't write report/summary/findings/analysis .md files" rule
that blocked 9 specialist outputs this session.

**Session trigger:** FP-01 — 9 files had to be re-persisted by the
orchestrator because the subagents couldn't write them directly.

**Sketch:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "node .claude/hooks/director-artefact-allow.js",
            "description": "Allow writes under reports/current/ when phase is phase[0-5]"
          }
        ]
      }
    ]
  }
}
```

Or simpler: a rule that explicitly lists the director artefact
filenames as write-allowed, overriding the "no report .md" default.

---

## PG-04 [HIGH / skill] `migration-dry-runner`

**Type:** skill

**Purpose:** before applying any SQL migration against a live DB,
run pre-flight queries derived from the migration's intent
(count duplicates, check column existence, verify FK targets)
and abort if pre-conditions fail.

**Session trigger:** FP-05 — the `idx_skills_name` unique index
crashed because the prod DB had 22 duplicate rows from unaudited
seed runs. The session recovered by ad-hoc dedup, but a
dry-runner would have caught this before the first apply attempt.

**Sketch:**
```markdown
# migration-dry-runner

## Inputs
- Path to .sql file
- DB connection string

## Process
1. Parse the .sql file AST (or regex) for DDL statements
2. For each CREATE UNIQUE INDEX: run
   `SELECT cols, count(*) FROM table GROUP BY cols HAVING count(*)>1`
3. For each FOREIGN KEY: verify target exists
4. For each REVOKE: check if grantee has other dependencies
5. Emit a dry-run report: PASS / BLOCK with details

## Output
- reports/current/migration-dry-run-<file>.md
- Exit 0 on PASS, non-zero on BLOCK
```

---

## PG-05 [HIGH / agent] `vps-ops-orchestrator`

**Type:** specialized subagent

**Purpose:** execute VPS-side operations (SSH commands, DB queries,
pm2 ops, file permission fixes) as a single coherent agent with
its own narrow tool budget and safety gates.

**Session trigger:** Wave 3 was entirely orchestrator-direct SSH
because no existing subagent cleanly handles VPS ops. The
`autonomous-program-director` has Bash but the safety posture
isn't right for live-DB mutations.

**Sketch:**
```yaml
name: vps-ops-orchestrator
description: Execute VPS-side ops with live-probe gating
tools: [Bash, Read]
safety:
  - no destructive commands without operator confirm
  - no migrations without dry-run pass
  - chmod/chown on secrets files always 0600
  - logs every SSH command + response to a run-log
```

---

## PG-06 [HIGH / skill] `schema-lag-guard`

**Type:** skill

**Purpose:** detect code that writes to DB tables / columns that
don't exist in prod yet, and wrap the writes in a try/catch that
downgrades the error to a warning (once per process).

**Session trigger:** FP-06 — the `audit_log` helper was deployed
before the migration. Fail-soft worked but log spam was ugly.

**Sketch:**
```markdown
# schema-lag-guard

## When to apply
- Helper functions that write to new tables not yet in prod
- Seeders that reference new columns
- Any code that lags the DDL

## Pattern
- Probe table/column existence on first call per process
- Cache the result
- Downgrade subsequent errors to console.warn once
```

---

## PG-07 [HIGH / contract] `docs/runtime/waves-pattern.md`

**Type:** runtime contract

**Purpose:** document the "Waves" pattern that this session
improvised — parallel-within-wave, serial-between-waves.

**Session trigger:** Sprint 1 was 4 waves. The existing
`dispatching-parallel-agents` skill describes pure parallel only.

**Sketch:** see FP-02 for the full pattern description.

---

## PG-08 [MEDIUM / command] `/director resume`

**Type:** slash command extension

**Purpose:** resume a director run from its last-committed state.
Read existing artefacts, detect which items are committed, skip to
the next unfinished item.

**Session trigger:** FP-10 — this session had no crash, but a
future session crashing mid-Sprint-1 would force the operator to
re-run `/director` from scratch.

**Sketch:**
```
/director resume [--from-phase <N>] [--skip-completed]

Reads reports/current/execution-roadmap.md, compares item IDs
against the current git log for commit footprints (e.g. "R-119"
in commit message), and dispatches the next unfinished item.
```

---

## PG-09 [MEDIUM / skill] `.env-secret-governance`

**Type:** skill + lint rule

**Purpose:** enforce that `.env*` files + backup variants always
have mode 0600, and that `.mcp.json` never contains literal token
strings.

**Session trigger:** NF-01 (.env.local.bak was 0644 world-readable)
+ the persistent `.mcp.json` plaintext Hostinger token flagged by
red-team.

**Sketch:**
```markdown
# env-secret-governance

## Checks
- All .env* files mode 0600
- All .env*.bak* files mode 0600
- .mcp.json contains no regex `[A-Za-z0-9]{32,}` outside explicit
  `${SECRET_NAME}` references
- .gitignore covers .env*, .mcp.json, .env.local*

## Fixes (operator opt-in)
- chmod 0600 on offenders
- Suggest env var substitution for .mcp.json tokens
```

---

## PG-10 [MEDIUM / skill] `i18n-parity-enforcer`

**Type:** skill (formalizes what G9 wrote ad-hoc)

**Purpose:** a reusable i18n parity check script that lives in the
Ulak OS pack, not in every target project. Auto-install into
`scripts/` when the director sees a next-intl or react-i18next
project.

**Session trigger:** G9 wrote `scripts/check-i18n-parity.mjs` by
hand for this project. Next project will need the same thing.

---

## PG-11 [MEDIUM / agent] `cost-aware-llm-auditor`

**Type:** specialist subagent

**Purpose:** audit LLM-relay endpoints (Gemini, OpenAI, Claude
proxies) for cost amplification risks: missing `maxOutputTokens`,
unbounded user input concatenation, missing per-user quotas.

**Session trigger:** R-010 (cap `ai/route.ts` text to 10k, add
`maxOutputTokens: 2000`) was a band-aid. A dedicated auditor would
catch this pattern in every project that has an LLM relay.

---

## PG-12 [LOW / hook] `commit-msg-item-id-linter`

**Type:** pre-commit hook

**Purpose:** enforce that commit messages on a director-sprint
branch reference at least one roadmap item ID (e.g. `R-107`) so
the `/director resume` command can parse them.

---

## PG-13 [LOW / skill] `non-obvious-findings-enforcer`

**Type:** skill (extends the director Phase 3 mandate)

**Purpose:** programmatically verify that `did-you-know.md` has
≥15 entries, each cites file:line, each has a "why non-obvious"
explanation, and ≥3 are positive findings. Fail the phase if not.

Today the protocol says this in prose. A skill would enforce it.

---

## PG-14 [LOW / docs] `sector-packs/portfolio-cms.md`

**Type:** sector pack

**Purpose:** a "personal portfolio + admin CMS" sector pack that
pre-loads domain-specific checks: unused orphan admin modules,
i18n routing drift, blog-empty counters, template content
leftovers, single-admin auth model validation.

**Session trigger:** this was exactly the project shape. The
generic specialists worked, but a sector pack would have pre-loaded
the "admin CRUD without rendered consumers" pattern as a first-
class finding.

Related sectors to add eventually: e-commerce-storefront, SaaS
marketing-site, agency-portfolio, API-product-docs.

---

## PG-15 [LOW / skill] `rollback-deploy-generator`

**Type:** skill

**Purpose:** auto-generate a rollback-capable `deploy.sh` + PM2
ecosystem config from a project's framework (Next 16, SvelteKit,
Astro, etc.) + hosting target (PM2, systemd, Docker).

**Session trigger:** Wave 1 G6 wrote deploy.sh + ecosystem.config.cjs
by hand. This is a pattern that could be templatized.

---

## Cross-reference

The target project's director already flagged 11 gaps in
`reports/current/pack-gap-register.md`:

| target finding | Ulak OS equivalent here |
|---|---|
| admin-cms-hardening sector pack | PG-14 |
| ai-relay-cost-control sector pack | PG-11 |
| content-collections-wiring-verifier skill | not in this list (too project-specific) |
| supabase-rls-audit agent | could be PG-05 extension |
| i18n parity pre-commit hook | PG-10 + PG-12 |
| next-image-audit hook | could be PG-15 extension |
| schema drift watcher | PG-04 + PG-06 |
| JWT-secret reuse scanner | could be PG-05 extension |
| live VPS probe MCP | PG-05 does this differently |

Combined list for Ulak OS 2.2 planning: start with PG-01, PG-02,
PG-03 as Critical (they fix the harness itself), then PG-04..PG-07
High, then the rest.
