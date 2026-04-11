---
artefact: ulak-os-improvements
session: oguzhansert-dev-sprint-0-1
date: 2026-04-11
---

# Ulak OS 2.2 — Core Protocol + Runtime Contract Adjustments

Proposed changes to the Ulak OS core (not just pack additions).
These are contract-level adjustments to the runtime. Each entry has
a target file in `C:/Users/osrt91/desktop/proje/ulak.os/docs/` and
a concrete diff sketch.

---

## UOI-01 — Add Phase 4.5 "Live Probe" to artefact chain

**Target:** `prompts/core/ulak-os-core-contract-2.0.0.md` §
"Artefakt zinciri"

**Current:**
```
- runtime-manifest
- assumptions
- intake
- inventory (deep — dosya+satır bazlı)
- evidence-register (paralel uzman bulguları)
- deep-scan-report
- did-you-know
- research-notes
- analysis-findings
- target-state
- execution-roadmap
- validation-plan
- pack-gap-register
- manager-verdict
```

**Proposed:**
```
...
- validation-plan
- pack-gap-register
- **live-probe-results** (NEW — mandatory if validation-plan §6 has ≥1 probe)
- manager-verdict
```

**Rationale:** validates that live-probe results are a first-class
artefact, not a post-hoc runbook item. Manager-verdict cannot set
`signoff_status: ready` without live-probe-results.md if one was
required.

---

## UOI-02 — Introduce the "Waves" dispatch pattern in runtime docs

**Target:** NEW file `docs/runtime/waves-pattern.md`

**Content sketch:**

```markdown
# Waves Pattern — Parallel Within, Serial Between

## When to use
- Sprint execution with ≥3 independent items
- Items have a dependency DAG (some depend on others)
- Pure parallel would cause file conflicts
- Pure serial wastes wall-clock time

## Pattern

1. **Group items into Waves** based on dependency edges:
   - Wave 1: items with no deps
   - Wave 2: items depending only on Wave 1
   - ...

2. **Within a Wave, dispatch all items in parallel** via Task tool
   (one message, N tool calls).

3. **Between Waves, gate on**: all Wave N agents return → validate
   → commit → start Wave N+1.

4. **Sub-wave shape**: Wave N may itself have Sub-wave A (parallel)
   and Sub-wave B (sequential after A). Used when some items in a
   single wave share file surface.

## Example from this session

Sprint 1 was executed as:
- Wave 1: 9 parallel agents (disjoint file scopes)
- Wave 2A: 2 parallel agents (G4A + G4C disjoint)
- Wave 2B: 1 sequential agent (G4B, files overlap with G4A)
- Wave 3: orchestrator-direct VPS ops

## Validation gate

Each Wave must end with:
- `pnpm tsc --noEmit` = 0
- `pnpm lint` = 0 errors (warnings may stay)
- `pnpm build` = green
- `git commit` with Wave ID in message

## Anti-patterns
- Dispatching parallel agents without a pre-flight conflict map
- Skipping the validation gate between Waves
- Running a sequential "cleanup" pass after all Waves instead of
  between Waves
```

---

## UOI-03 — Trust-tier promotion mechanism

**Target:** `docs/governance/evidence-trust-scoring.md`

**Current:** the document defines T1-T7 tiers but doesn't describe
*how a claim moves between tiers* as new evidence arrives.

**Proposed addition:**

```markdown
## Tier promotion

A claim's trust tier can only go DOWN (weaker) without new
evidence. To go UP (stronger), new evidence must be collected:

| from | to | trigger |
|---|---|---|
| T3 (inference) | T2 (grep match) | new file found via Glob/Grep |
| T2 (grep) | T1 (direct read) | the file was read |
| T2/T1 | T0 (runtime observed) | a live probe confirmed/refuted |

Live-probe results (Phase 4.5) are the ONLY way to reach T0.

## Tier regressions

A claim can drop from Tx to Tx+1 if:
- New evidence contradicts it
- The file it cites was deleted/moved
- The live state diverged (probing found a new reality)

Regressions must be logged in the evidence-register with a timestamp
and a link to the superseding evidence.
```

---

## UOI-04 — Specialist parallel dispatch overlap is a feature, not a bug

**Target:** `prompts/core/ulak-os-core-contract-2.0.0.md` §
"Derinlik zorunluluğu"

**Current:** "Evidence fazı = ilgili tüm uzman alt agent'ların
paralelde çalıştırılması zorunludur."

**Proposed strengthening:**

```markdown
## Deliberate specialist overlap

Phase 2 specialists MUST overlap on strategic surfaces:

- Admin auth → security + backend-api + red-team
- Schema drift → data-database + architecture + backend-api
- Deploy surface → infra-release + release-readiness + security
- Content/CMS → architecture + product-business + seo

Overlap is a feature:
- 1 specialist says X → T3 inference
- 2 specialists independently say X → T2 confirmation
- 3+ specialists independently say X → T1 consensus

Do NOT deduplicate specialists for "efficiency". The parallel cost
is ~N tool calls per specialist; the confidence gain from overlap
is worth more than the compute saved.
```

---

## UOI-05 — Inventory tiered-depth mode

**Target:** `docs/runtime/program-phases.md` § Phase 1

**Current:** inventory is full-depth by default. This session took
~17 min wall-clock for a medium project.

**Proposed addition:**

```markdown
## Tiered inventory depth

`/director` default: **tiered**.
`/director --full-depth`: the current behavior.

Tiered depth means:
- **Depth 1 (T1-grade, deep read):** routes, API endpoints, auth,
  schemas, migrations, env vars, secrets, config, deploy scripts,
  CI. All receive file:line citations.
- **Depth 2 (T2-grade, grep + header-read):** components, hooks,
  utilities. File paths + export list + one-line responsibility.
- **Depth 3 (T3-grade, tree-listing only):** generated code, shadcn
  internals, node_modules. File paths only, no deep scan.

The director subagent picks depth per-surface based on the intake
mode + sector pack decision. Operator can override via
`--full-depth`.

Expected wall-clock: ~40% of current default at ~90% coverage.
```

---

## UOI-06 — Memory pre-load as a formal intake step

**Target:** `prompts/core/ulak-os-core-contract-2.0.0.md`

**Current:** memory is loaded opportunistically by the main
session when its keywords match. It's not explicit in the intake
protocol.

**Proposed:**

```markdown
## Intake — memory preload step

Before Phase 0 begins, the director MUST:
1. Query memory for entries matching the project root path
2. List all matching memories in runtime-manifest.md under
   "Memory preload"
3. Flag any memory that contradicts the current project state as
   `STALE — needs refresh` and remove from active context
4. Use non-stale memories as invariants the director can rely on
   without re-probing

Memory is T0-tier (runtime observed at time-of-write) but can
regress to T2 (may be stale) with session gap. Live-probe re-
confirms.
```

---

## UOI-07 — Destructive action gate

**Target:** `docs/runtime/anti-patterns.md`

**Proposed addition:**

```markdown
## Anti-pattern: destructive action without live-probe

The director must not schedule ANY of these actions without a
preceding `validation-plan §6` probe that confirms:

- `rm -rf <remote path>` — confirm path is really stale + no live
  references
- `DROP TABLE` / `DROP INDEX` — confirm table/index is not in use
- `REVOKE ALL` — confirm callers are not relying on the grant
- `git reset --hard` — confirm nobody has uncommitted work
- `docker network rm` — confirm no containers attached
- PM2 `delete` — confirm process isn't serving traffic

Each destructive item in the execution-roadmap MUST have a
`pre_check` field citing the live probe that authorizes it.

Example:
```yaml
item_id: NF-03
action: rm -rf /opt/oguzhansert/
pre_check:
  - LP-??: "ls -la /opt/oguzhansert/" returned only README stubs
  - result: BLOCKED — found .env.local (Apr 9), not stale
  - resolution: chmod 0600 instead; operator decision on rm
```
```

---

## UOI-08 — Pack-gap register as input to next session

**Target:** `docs/runtime/context-budget.md` + pack versioning

**Proposed:**

Each director run writes `pack-gap-register.md` with missing
tools. Ulak OS 2.2 should read the pack-gap-register of prior runs
at session start and use it to:
- Inform the intake about known weaknesses
- Suggest `ulak pack install <missing>` before Phase 0
- Track gap → implementation via a registry file like
  `ulak.os/pack-gap-tracker.json`

The pack-gap-register of THIS session (at
`C:/Users/osrt91/Desktop/Proje/oguzhansert.dev/reports/current/pack-gap-register.md`)
should be the first input to the Ulak OS 2.2 pack-development
planning.

---

## UOI-09 — Reply-format discipline enforcement

**Target:** `docs/runtime/output-profiles.md`

**Current:** reply format is a convention per specialist prompt.
Not enforced.

**Proposed:**

```markdown
## Reply format contract

Every subagent dispatched from a director protocol phase MUST
return a reply that:
- Is at most the word count stated in its brief (default: 250 words)
- Uses a numbered list matching the brief's "Reply format" section
- Cites file paths with absolute paths
- Does NOT dump file contents (they live in the written artefact)
- Flags any brief requirement it could not meet as "DEFERRED" with
  a one-line reason

A compliant reply can be machine-parsed. The director's Phase 4
synthesis agent should be able to read 13 specialist replies in
under 1500 tokens and build the merged evidence-register from them.

Non-compliant replies are currently the norm (this session had 5
replies that exceeded 1000 words when the brief said ≤250). A
pre-return format lint would catch this.
```

---

## UOI-10 — Default intervention mode is not RESCUE

**Target:** `prompts/core/ulak-os-core-contract-2.0.0.md` § "Intervention modes"

**Current:** 7 modes listed, no default. The director picks one
based on intake.

**Observation from this session:** the operator typed `/director`
with no arguments. The director inferred RESCUE+REFACTOR from the
project state. That inference was correct for this BROWNFIELD
project but would have been wrong for a GREENFIELD one.

**Proposed:**

Add a default decision tree:

```
IF GREENFIELD (no src/, empty git): mode = CREATE
IF BROWNFIELD + build is green + no critical findings: mode = EXTEND
IF BROWNFIELD + build is green + critical findings: mode = REPAIR
IF BROWNFIELD + build is broken + findings: mode = RESCUE
IF BROWNFIELD + architecture mismatch + no critical: mode = REFACTOR
IF prod deploy on different framework: mode = MIGRATE
IF code fine + packaging/release issues: mode = REPACKAGE
```

The director's Phase 0 should run this decision tree and declare
the mode in `assumptions.md` with the inputs that drove the choice.

---

## Priority order for Ulak OS 2.2

1. **UOI-01** (Phase 4.5 live-probe) — resolves FP-04
2. **UOI-02** (Waves pattern docs) — resolves FP-02
3. **UOI-07** (destructive action gate) — resolves FP-07
4. **UOI-03** (trust-tier promotion) — makes the evidence graph auditable
5. **UOI-04** (specialist overlap as feature) — prevents future
   "optimization" that would hurt confidence
6. **UOI-09** (reply-format enforcement) — context budget win
7. **UOI-05** (tiered inventory) — wall-clock win
8. UOI-06, UOI-08, UOI-10 — lower priority, still valuable

Pair these with the pack additions in `pack-gap-proposals.md`:
- Critical pack items: PG-01, PG-02, PG-03
- High pack items: PG-04, PG-05, PG-06, PG-07

A focused 2.2 cut targeting UOI-01 + UOI-02 + UOI-07 + PG-01 + PG-02
+ PG-03 would already address the biggest frictions of this session.
