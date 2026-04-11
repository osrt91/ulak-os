# Live Probe Contract — Phase 4.5

## Why this exists

A static-only audit produces claims like "the committed JWT signing key in `kong.yml:8` MAY match the prod `JWT_SECRET`" — tier T2 evidence at best. The only way to upgrade that claim to T1 (or refute it entirely) is a **live probe**: SSH into the VPS, read the env var, compare.

Before v2.1.2, live probes lived in `validation-plan.md §6` as TODOs. The director's protocol ended at Phase 5 manager-verdict without a formal step that forced the probes to actually run. The oguzhansert.dev Sprint 0+1 session (2026-04-11, FP-04) caught this: the probes ran only because the operator was "lucky" — SSH config was already in place, credentials were ambient. On a session without that luck, Phase 5 would have issued a verdict on T2 evidence and the operator would never have known.

Phase 4.5 is the formal answer: **if `validation-plan.md §6` has ≥1 live probe, Phase 4.5 is mandatory before Phase 5 can run**.

## When it's required

Phase 4.5 is **mandatory** when any of these are true:

1. `validation-plan.md §6` (or any section with a "live probe" label) lists ≥1 probe
2. The manager-verdict would cite any T2 or T3 evidence as blocking without a live check
3. The execution-roadmap contains any **destructive action** targeting a remote system (per `docs/runtime/anti-patterns.md` destructive action gate)
4. A critical finding depends on a claim that cannot be verified from the repo alone

Phase 4.5 is **optional** when:

- All evidence is T1/T2 from the repo itself (code, config, migrations — no external surface)
- The project has no production deploy
- The audit is intentionally static-only per operator request

## Inputs to Phase 4.5

Before probes can run, the director must collect:

- **Credential surface** — SSH config, API tokens, DB connection strings, cloud account access
- **Operator authorization** — explicit consent to run read-only probes against named targets
- **Probe definitions** — each probe from `validation-plan.md §6` with:
  - `id` (LP-01, LP-02, ...)
  - `question` (what are we testing)
  - `target` (host, endpoint, table, file path)
  - `command` (the actual probe to run)
  - `expected_result` (what "pass" looks like)
  - `failure_action` (what happens if the probe fails)

If credentials are missing, the director must PAUSE and request them from the operator. Never guess or invent credentials.

## Probe execution rules

### Read-only by default

Every probe must be read-only unless explicitly marked otherwise. Read-only probes include:

- `SELECT`, `SHOW`, `\dt` against a database
- `curl -I`, `curl -s`, `HEAD` against an HTTP endpoint
- `ls`, `stat`, `cat`, `head`, `grep`, `pm2 env`, `pm2 info`, `systemctl status`, `docker inspect`
- File permission reads (`ls -la`, `stat -c %a`)

**Never** run write or destructive probes (`INSERT`, `UPDATE`, `DELETE`, `DROP`, `rm`, `chmod`, `pm2 restart`, `systemctl restart`) in Phase 4.5. Those are **execution phase** actions and live behind separate operator approval.

### Timeouts

Every probe has a timeout. Default: 30 seconds. Long-running probes (log tail, network scan) must declare a longer timeout explicitly and get operator approval.

### Isolation

Probes must not leave footprints. Do not create temporary files, do not modify config, do not restart services. If a probe requires a temporary artifact, clean it up in the same probe.

### Credential handling

- Do not log credentials (they go into env vars that the probe command reads)
- Do not echo credentials into the conversation
- Do not persist credentials into any artefact under `reports/current/`
- Mask credential fields if a probe output contains them

## Outputs

### Required artefacts

Phase 4.5 writes:

- `reports/current/live-probe-results.md` — one entry per probe with:
  - probe id, target, command, timestamp
  - result (pass / fail / partial / skipped / blocked-by-credentials)
  - raw output reference (a link to a saved log file, NOT the raw output inline)
  - T-tier upgrade (e.g. "LP-07: JWT reuse — REFUTED. Prod JWT_SECRET differs from kong.yml:8. Evidence upgraded T2 → T1.")

### Evidence register updates

Every probe that confirms or refutes a prior claim triggers an update to `reports/current/evidence-register.md`:

- **Upgrade**: T2 or T3 claim becomes T1 (or T0 — runtime observed)
- **Downgrade**: a previously-held claim is contradicted; the claim drops a tier or is marked `contradicted`

### New findings layer

Live probes often surface **new findings** that weren't in the static pass. These go into `reports/current/did-you-know.md` under a new section:

```markdown
## New findings from live probing (NF-*)

### NF-01 — .env.local.bak has mode 0644 on prod (discovered during LP-05)

**Evidence**: `ls -la /home/deploy/oguzhansert.dev/` returned:
-rw-r--r-- .env.local.bak

**Why non-obvious**: no file in the repo points at the backup; it exists because of a manual cp a week ago. Static scan cannot see VPS files.

**Severity**: High (world-readable secrets on a multi-tenant host)

**Fix**: chmod 0600, add .env*.bak* to .gitignore
```

### Gates

- **Phase 5 verdict cannot set `signoff_status: ready`** with unresolved probes (blocked-by-credentials counts as unresolved)
- **Destructive Sprint items cannot be scheduled** without a matching pre-check probe that authorizes them
- **A failed probe downgrades related findings** and may **escalate** the blast-radius assessment

## Interaction with the destructive action gate

`docs/runtime/anti-patterns.md` § "Destructive action without live-probe" already lists the forbidden actions that require a probe. Phase 4.5 is the step that **runs** those pre-checks. Every destructive item in `execution-roadmap.md` has a `pre_check` field naming its probe; Phase 4.5 executes the probes in dependency order with execution items.

## Example — oguzhansert.dev session

The Sprint 0+1 session had 11 probes. Two were pivotal:

**LP-07 — JWT reuse check**

- `command`: `ssh prod 'pm2 env oguzhansert | grep JWT_SECRET'`
- `question`: "Does prod JWT_SECRET match the HS256 key committed in kong.yml:8?"
- `result`: **REFUTED**. Prod uses a different secret.
- `impact`: DIR-005 severity dropped from Critical ("prod compromise likely") to High ("historical exposure only, rotation advisable")

**LP-09 — /opt/oguzhansert/ staleness**

- `command`: `ssh prod 'ls -la /opt/oguzhansert/'`
- `question`: "Is /opt/oguzhansert/ stale and safe to rm -rf?"
- `result`: **BLOCKED**. Directory contained a second `.env.local` from a prior deploy attempt.
- `impact`: R-119 destructive action cancelled. New finding NF-03 issued: "two .env.local files, chmod needed".

Both probes changed the verdict shape. Neither could have been answered from static analysis.

## Integration

- `prompts/core/ulak-os-core-contract-2.0.0.md` — artefakt zinciri includes `live-probe-results` as Phase 4.5
- `docs/runtime/program-phases.md` — Phase 4.5 protocol entry
- `docs/runtime/artefact-contract.md` — `live-probe-results.md` is a conditional-mandatory artefact
- `docs/runtime/validation-result-schema.md` — gate evidence can cite probe output references
- `docs/runtime/anti-patterns.md` — destructive action gate depends on probes
- `.claude/agents/autonomous-program-director.md` — Phase 4.5 execution is the director's responsibility
- `docs/governance/evidence-trust-scoring.md` — probes are the only path to T0 (runtime observed) tier
