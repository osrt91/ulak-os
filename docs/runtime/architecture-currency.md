# Architecture Currency Protocol

## Why this exists

The model's training data has a cutoff. The project's stack is what it is today. When the director recommends "use hooks like this" or "structure your API like that", the recommendation must reflect the *current* upstream reality, not a snapshot from two years ago. Without an architecture currency check, the director confidently hands out advice that was true in 2023 but is misleading in 2026.

## When it runs

- Automatically in Phase 0 when `router.live_research_need` is `required` or `helpful`
- On demand when a specialist is about to recommend a pattern, library version, or framework feature
- In Phase 4 (synthesis) when writing `target-state.md` — before committing to a direction

## The question stack

Before making a serious architectural recommendation, answer:

1. **What stack is actually in use?**
 Read from the repo (T2), not from assumptions. Package manifests, lockfiles, build configs, imports.

2. **What does the official source currently say?**
 Consult upstream docs at T1 priority:
 - Anthropic / Claude Code docs for Claude runtime
 - Apple HIG / SwiftUI / UIKit docs
 - Android Developers docs / adaptive quality guide
 - Flutter docs (including Cupertino for iOS fidelity)
 - Framework / language upstream docs (React, Next.js, Python, Rust, Go...)
 - Platform store guidelines (App Store, Google Play)
 - Security and privacy upstream sources (OWASP, RFCs, NIST)

3. **Is the recommended pattern stable or experimental?**
 Unstable APIs get a label. Never present an experimental feature as "the way".

4. **Is there a deprecated surface involved?**
 If the project uses a deprecated feature, the target state must mention the migration path.

5. **What's the migration cost?**
 "Upgrade to the new way" is cheap when it's a flag. It's expensive when it's a rewrite. Record the cost.

6. **Does the team / product scale match the recommendation?**
 A 3-person team does not need the pattern that scales to 300 engineers. Match the advice to the ship.

## Labels

When emitting an architecture recommendation, attach one of these labels:

- **CURRENT_RECOMMENDED** — upstream's current best practice, stable, documented
- **CURRENT_BUT_CONDITIONAL** — upstream recommends it, but only under specific conditions (scale, stack, team)
- **LEGACY_STILL_VALID** — older approach that still works and has no concrete reason to migrate
- **OUTDATED_AVOID** — officially discouraged or superseded; flag migration
- **EXPERIMENTAL_NOT_DEFAULT** — new, documented, but not yet the default recommendation

A recommendation without a label is rejected in review.

## Architecture recommendation card

Every serious architecture recommendation (in `target-state.md` or a specialist's output) must carry this shape:

```yaml
- id: "ARCH-001"
 area: "" # frontend|backend|data|infra|security|mobile|...
 recommendation: ""
 label: CURRENT_RECOMMENDED|CURRENT_BUT_CONDITIONAL|LEGACY_STILL_VALID|OUTDATED_AVOID|EXPERIMENTAL_NOT_DEFAULT
 why_now: "" # 1-3 sentences
 upstream_source: "" # URL or doc reference
 upstream_trust: T1|T5 # T1 for official, T5 for reputable secondary
 constraints: [] # e.g. requires Node 20+, requires specific DB version
 tradeoffs: [] # what gets worse to make this better
 migration_impact: low|medium|high|critical
 migration_steps_summary: ""
 localization_impact: "" # does this affect i18n or locale handling?
 validation_plan: "" # how to verify the migration or adoption succeeded
```

## Hard rules

- **Never recommend a framework or version from memory when live research is needed.** Say "I need to verify the current X before committing to this". The user is OK with a short pause.
- **Never recommend something just because it's popular.** Popularity is T6 evidence.
- **Never recommend something just because it's new.** New defaults replace old ones only after careful reason.
- **Never recommend a migration without a migration step summary.** "Migrate to X" is not a plan.
- **Never claim "upstream recommends X" without citing the upstream source.** T1 evidence means an actual doc, not vibes.
- **When the stack conflicts with the recommendation, the stack wins unless migration is explicitly in scope.** Recommending a Vue pattern to a React project is a misread.

## Deploy resilience (R-05)

Every production deployment topology must declare a **CI-independent fallback path** — a way to deploy when the primary CI runner is unavailable (quota exhausted, provider outage, weekend/holiday incident). A CI-only deploy path is flagged as residual risk at Phase 4.

### Acceptable fallback patterns

- **Cron-poll on target host** — `infrastructure/deploy-poll.sh` runs every N minutes on the VPS, `git fetch`, diffs HEAD SHA against deployed SHA, rebuilds affected services, smoke-checks `/health`. Must be flock-guarded (`flock -n /tmp/deploy-poll.lock`) to prevent concurrent runs. Idempotent — re-running after a success is a no-op.
- **Manual SSH deploy script** — documented `deploy.sh` the operator can run from a dev machine when CI is down. Must produce the SAME result as CI (same steps, same order, same build flags).
- **Webhook-triggered alternative runner** — a secondary CI on a different provider (e.g. GitLab CI as fallback for GitHub Actions).

### Not acceptable

- "I'll SSH in and run `git pull && docker compose up -d`" — manual, unreproducible, no lock, no smoke check
- "We have a staging CI" — that's a redundancy in primary path, not a fallback
- "We don't deploy when CI is down" — the ship doesn't stop because the ferry is broken

### Smoke check discipline

Any fallback path must run the SAME smoke checks as CI after deploy:

- `/health` endpoint returns 200
- A sample read endpoint returns expected shape
- Critical dependencies (DB, Redis, queue) reachable

Fallback paths without smoke checks are incomplete.

### Evidence tier

Cron-poll fallback existence is a T1 observation (file exists, executable, has flock). Its effectiveness under a real primary outage is T2 (inferred — often not truly tested). Projects should run a quarterly "fallback drill" where the primary CI is artificially disabled and the fallback is exercised.

sh:1-69` (flock-guarded, 2-minute polling, rebuild + smoke-check).

## Integration

- `docs/governance/evidence-trust-scoring.md` — upstream_trust field
- `docs/runtime/market-research-engine.md` — live research integration when currency check is required
- `target-state.md` — architecture recommendation cards go here
- `validation-plan.md` — the validation_plan field feeds into this artefact
- `docs/runtime/sector-packs.md` §`vps-nginx-compose-topology` includes deploy resilience requirements
- `docs/governance/ai-provider-allowlist.md` — provider drift scan runs during architecture currency checks
