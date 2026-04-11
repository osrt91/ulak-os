---
artefact: friction-points
session: oguzhansert-dev-sprint-0-1
date: 2026-04-11
---

# Friction Points — Where Ulak OS Blocked Itself

Where the harness fought the operator. Each entry is: symptom,
reproducer, root cause guess, proposed fix.

## FP-01 — Subagent `Write` tool blocked mid-phase

**Symptom:** 8 of 13 Phase 2 specialists + 1 of 9 Phase 4 artefacts
(`analysis-findings.md`) could not write their `.md` deliverable to
disk. They returned the full content as inline text and the
orchestrator had to re-persist them from conversation state in a
separate tool pass.

Specialists affected:
- architecture, infra-release, i18n, seo-growth, red-team,
  design-system, privacy-compliance, product-business

**Reproducer:** when a subagent is told "write to
`reports/current/specialists/xxx.md`", some tool-layer hook (possibly
a skill or a claude-md rule or a hook config) replaces the Write
intent with "do not write .md report/summary/findings/analysis
files — return inline". The subagent obeys, producing inline text.

**Root cause (best guess):** a skill or hook somewhere in the
superpowers pack is interpreting "write a report file" as
"planning/decision/analysis document" and blocking it per the
default-system-prompt rule. But the director protocol EXPLICITLY
wants these files. The protocol override isn't reaching the
subagent.

**Cost of the bug:**
- ~3 minutes of orchestrator tool calls to re-persist 8 files
- Risk of truncation if the inline content was longer than the
  reply budget
- Orchestrator burned context window re-reading the inline content

**Proposed fix:**
1. Add an explicit exemption to the "don't write report/summary
   files" rule when the operating context is a director-protocol
   Phase 2/3/4 artefact.
2. OR: invert the default. Allow writes by default, require the
   anti-write rule to be opt-in via an explicit skill.
3. OR: pass a "scope: director-artefact" flag through the Agent
   tool that propagates to the subagent's hook evaluation.

This is the top priority Ulak OS harness bug. Fixing it restores
the parallel-dispatch protocol's determinism.

## FP-02 — `dispatching-parallel-agents` skill has no waves model

**Symptom:** the skill describes "dispatch N agents in parallel"
but doesn't describe what to do when:
- Some agents depend on other agents' output (sequential gate)
- All-parallel would cause file conflicts (need planning pre-pass)
- Agent A edits file X for reason R1, Agent B edits file X for
  reason R2 at a different line — safe in theory but the skill
  doesn't encode the "disjoint line ranges" contract

This session used a Waves pattern:
- Wave 1: 9 agents parallel
- Wave 2A: 2 agents parallel
- Wave 2B: 1 agent sequential
- Wave 3: orchestrator-direct VPS ops

The skill doesn't describe Waves. The orchestrator had to improvise.

**Proposed fix:** extend the skill to describe:
- The **file-conflict pre-dispatch** pass (build a conflict matrix
  before calling Task)
- The **Waves pattern** (parallel-within-wave, serial-between-waves)
- The **line-range overlap** case (two agents can own different
  line ranges of the same file if the ranges are explicit and the
  dispatch prompt enforces them)

See `pack-gap-proposals.md` § PG-02 for a concrete skill update
proposal.

## FP-03 — Inventory phase wall-clock cost

**Symptom:** the cartographer-grade inventory took ~17 minutes of
wall-clock for a medium codebase (~80 TypeScript/TSX files, ~30 SQL
files, ~10 config files). That is ~170 tool calls spread across
one subagent.

**Root cause:** the inventory mandate is literally "for every file,
read it and extract file:line citations". That's O(N) Read + Grep
calls and N is the full project. The scaling is linear in project
size but the constant factor is high.

**Proposed fix options:**
1. **Parallelize inventory** — split the project by directory and
   dispatch N sub-cartographers. But then the inventory output is
   fragmented and needs merging.
2. **Pre-cache** — if the project was inventoried before, reuse the
   prior inventory and only re-inventory changed files (diff vs last
   git SHA). Huge speedup on repeat runs, but needs persistence.
3. **Tiered depth** — mandatory deep scan on 8-10 "strategic surfaces"
   (routes, API, auth, schemas) and quick-scan everything else.
   This session's inventory was ~92% thorough; the other 8% was
   shadcn internals and didn't matter. Tiered would give 90%
   coverage at ~6 min wall-clock.

Recommendation: tiered by default, full depth as opt-in via
`/director --full-depth` flag.

## FP-04 — Live-probe phase is not part of the protocol

**Symptom:** `validation-plan.md §6` listed 11 live probes that
could only be run against the VPS. The manager-verdict correctly
flagged `signoff_status: blocked` pending these probes. But the
director protocol itself doesn't have a "Phase 4.5 — Live probe"
step — the probes just sit there as TODOs until the operator
manually authorizes SSH.

This session was lucky: the operator said "VPS erişimin klasöründe"
and the orchestrator had SSH config already configured. On a
session where VPS access is sourced via a one-off credential hand-
off, the probe phase would not happen and Sprint 1 would proceed on
T2 evidence — unsafe.

**Proposed fix:** add a formal Phase 4.5 to the protocol:
```
Phase 4.5 — Live probe (mandatory if validation-plan §6 has ≥1 probe)
  - Request credential from operator if not already configured
  - Run probes via SSH / HTTP / DB connection
  - Upgrade T2/T3 claims in evidence-register to T1
  - Surface new findings (the "during probing" layer) as NF-*
  - Block Phase 5 verdict until live-probe results are written
```

See `ulak-os-improvements.md` § UOI-01 for the contract update.

## FP-05 — Migration application lacks a dry-run / safety gate

**Symptom:** `docs/migrations/2026-04-11-unique-indexes.sql`
crashed when applied to prod because the `idx_skills_name` unique
constraint found 22 duplicate rows (prod had run the unaudited
seed script 3 times over its lifetime). The orchestrator had to
write an impromptu dedup SQL before retrying.

The roadmap item R-105 described the desired end state but didn't
encode the pre-flight check (count(*) vs count(distinct) per
natural key).

**Proposed fix:** migration items in the roadmap should include a
`dry_run_query` field that the orchestrator runs before apply.
Example:
```yaml
item_id: R-105
title: Add unique indexes + ON CONFLICT natural keys
dry_run:
  - "SELECT name, count(*) FROM skills GROUP BY name HAVING count(*)>1"
  - "Expected: 0 rows. If >0, apply dedup before the index create."
```

## FP-06 — Audit helper fails soft but spams console.error

**Symptom:** the Wave 2 `logAdminAction` helper writes to
`public.audit_log`. Before that table exists in prod (Wave 3 applied
it), every admin mutation call would log `console.error` from the
helper. Fail-soft is the right behavior — the admin UI keeps
working — but the log spam makes the real errors hard to spot.

**Root cause:** the helper checks `isSupabaseAdminConfigured()` but
not `does the table exist`. A `PGRST205` (not found) or `42P01`
(relation missing) error goes through the generic error path.

**Proposed fix:** add a table-existence probe at first invocation,
cached in-process. If the probe returns "table missing", downgrade
from `console.error` to `console.warn` once per process lifetime
with a clear "apply docs/migrations/xxx.sql" hint.

This is a pattern: **schema-dependent helpers should guard against
"schema lags behind code" states** rather than failing loudly.

## FP-07 — Destructive deletes need a live-probe gate

**Symptom:** director-generated Sprint 0 item R-119 said "Delete
`/opt/oguzhansert/` stale kale-kapisi footprint". If the orchestrator
had blindly run `rm -rf /opt/oguzhansert/` during Wave 3, it would
have deleted a second `.env.local` with real secrets (different
from the main `/home/deploy/oguzhansert.dev/.env.local`).

Live-probe Wave 3 caught it by doing `ls -la` first.

**Proposed fix:** the director's Sprint 0 "pure deletion" phase
must never include remote (VPS) destructive operations without a
preceding live inspection. Codify as: any `rm`, `DROP`, `REVOKE ALL`
or equivalent against a remote target requires a `pre_check`
dry-run in the same item.

## FP-08 — Inline specialist output > 250 words cap silently

**Symptom:** 5 of 13 specialists exceeded the 250-word reply cap
when they returned inline. The caps were SOFT (the prompt said
"≤250 words" but there was no tool-level enforcement).

The soft cap was mostly honored — specialists tried — but the
fallback to inline (when Write was blocked) made 1000+ word
responses common.

**Proposed fix:** the reply cap should have two modes:
- **Hard cap** when the Write to file worked (reply is metadata
  only)
- **Soft extension** when Write was blocked and the reply carries
  the payload (up to some ceiling, e.g. 3000 words, and structured
  per the file template)

## FP-09 — Hostinger API token lives in `.mcp.json` plaintext

**Symptom:** `.mcp.json` contains a plaintext Hostinger API token
that has full VPS control. It IS gitignored so it doesn't leak via
version control, but any process on the local dev machine that
reads `.mcp.json` gets a master key.

The director flagged this (SEC-F in red-team.md) but there's no
clean Ulak OS pattern for "where should MCP credentials live".

**Proposed fix:** add a formal `mcp-governance.md` section covering:
- Where credentials SHOULD live (OS keychain, env vars, secrets
  manager integrations)
- What `.mcp.json` may contain (server names + non-secret args)
- A lint rule that fails CI if `.mcp.json` contains a literal
  token-looking string

## FP-10 — The operator-invoked `/director` has no state resume

**Symptom:** if this session had crashed mid-Sprint-1, the operator
would have had to re-run `/director` from scratch. There's no
"resume from Phase 4" or "continue from Sprint 0 commit".

**Proposed fix:** the director's artefacts (especially
`execution-roadmap.md` + `manager-verdict.md`) should be
*resumption points*. A future `/director --resume` should read them,
figure out which items in the roadmap are already committed (via
git log + signoff_status), and skip to the next unfinished item.
