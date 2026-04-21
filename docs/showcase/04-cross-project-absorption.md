# Walkthrough 04 — Cross-project pattern absorption via the ledger

An ExampleCorp operator runs two fictional products: **AcmeBuilder** (a no-code page builder SaaS) and **BetaStore** (a multi-tenant e-commerce SaaS). Both are Ulak-governed. AcmeBuilder has a webhook-CI-deploy pattern that BetaStore wants to adopt. This walkthrough shows how the pattern flows from one project to the other through the `pattern-import-ledger.yaml`, per [ADR-004](../adr/ADR-004-pattern-import-ledger.md).

## The pattern being imported

AcmeBuilder's `infrastructure/deploy.sh` combines three ideas that work well together:

1. GitHub webhook triggers a poll-based deploy (CI-independent fallback path)
2. The deploy script signs its own request body + timestamp + nonce before trusting the webhook
3. A health probe runs post-deploy; if it fails, rollback to the prior docker-compose snapshot

BetaStore's current deploy is a CI-only push that has no rollback path and no signature check — vulnerable to both AP-12 (fake rollback) and AP-18 (static HMAC). The BetaStore operator decides to adopt AcmeBuilder's pattern.

## Step 1 — Extract the pattern from AcmeBuilder

In the AcmeBuilder repo, the operator runs:

```
> /pack-gap-audit extract-pattern path=infrastructure/deploy.sh
```

The pack-gap-audit command (via the `pack-gap-completion` skill) inspects the file and produces a pattern description artefact at `reports/current/patterns/webhook-ci-deploy-rollback.md`:

```markdown
# Pattern: webhook-ci-deploy-rollback

## Shape
- GitHub webhook on main push triggers VPS-side poll
- Poll checks deploy.sh can execute with signature validation
- Signature = HMAC-SHA256 over (body + timestamp + nonce)
- Deploy pulls new docker-compose image, starts, probes /health
- On probe failure, rollback to previous image tag
- On probe success, commit new tag as "last-good"

## File mapping (AcmeBuilder)
- .github/workflows/deploy.yml:1-34     — webhook-emit side
- infrastructure/deploy.sh:1-142        — VPS-side logic
- infrastructure/deploy-poll.sh:1-67    — CI-independent fallback
- infrastructure/health-probe.sh:1-28   — health probe script

## Dependencies
- docker-compose 2.x
- nginx reverse proxy with shared network
- HMAC secret stored in VPS env var WEBHOOK_SECRET
- last-good tag stored at infrastructure/.last-good-tag

## Anti-patterns avoided
- AP-12 (fake rollback) — genuine rollback path tested on failure
- AP-18 (static HMAC empty body) — signs full body + timestamp + nonce

## Evidence tier
T1 — observed in production; last-good rollback fired 3 times in 14 months without data loss
```

## Step 2 — Register the source in AcmeBuilder's ledger

AcmeBuilder's `docs/governance/pattern-import-ledger.yaml` is **empty for exports** (the file tracks what AcmeBuilder imports, not what it exports). But the extraction writes a companion file `docs/governance/pattern-exports.yaml` that other projects can reference:

```yaml
# AcmeBuilder/docs/governance/pattern-exports.yaml
exported_patterns:
  - id: PE-001
    slug: webhook-ci-deploy-rollback
    extracted_at: 2026-04-21
    extracted_from_commit: a1b2c3d
    spec_file: reports/current/patterns/webhook-ci-deploy-rollback.md
    evidence_tier: T1
    maturity: production-tested-14-months
```

## Step 3 — Import into BetaStore

In the BetaStore repo, the operator runs:

```
> /director dispatch=specialist scope=deploy entry=AcmeBuilder/docs/governance/pattern-exports.yaml
```

The director reads the AcmeBuilder export spec as Phase 0 entry context. During Phase 4 synthesis, it produces a `target-state.md` section describing what BetaStore's deploy surface should look like **after** the pattern is imported, plus an `execution-roadmap.md` item group for the import.

Then the operator writes the ledger entry into BetaStore:

```yaml
# BetaStore/docs/governance/pattern-import-ledger.yaml
imports:
  - id: PI-001
    imported_at: 2026-04-21
    source_project: AcmeBuilder
    source_export_id: PE-001
    source_commit: a1b2c3d
    slug: webhook-ci-deploy-rollback
    evidence_tier_at_source: T1
    evidence_tier_at_destination: T3        # downgraded — not yet observed in BetaStore
    divergence_notes:
      - BetaStore uses postgres + redis as separate containers; health probe must check both
      - BetaStore has a 3-VPS cluster; poll + deploy must be per-node with sequential orchestration
      - WEBHOOK_SECRET must be rotated on import — never reuse source project's secret
    adaptation_owner: operator@examplecorp
    validation_plan:
      - LP-PI-001 simulate webhook with valid HMAC; expect deploy trigger
      - LP-PI-002 simulate webhook with empty body + valid HMAC on old code; expect 400
      - LP-PI-003 induce probe failure; expect rollback to last-good tag
    review_at: 2026-05-21                   # 30-day post-import validation review
```

## Step 4 — Execute the import

The BetaStore operator copies the AcmeBuilder files as starting points, then applies the divergence notes. Concrete diffs:

- `infrastructure/deploy.sh` — AcmeBuilder's 142-line version becomes 178 lines in BetaStore (added redis + postgres probe paths)
- `infrastructure/deploy-poll.sh` — identical in logic; adapted to BetaStore's docker-compose service names
- `.github/workflows/deploy.yml` — sends webhook to three VPS endpoints instead of one, in sequence
- `WEBHOOK_SECRET` — generated fresh via `openssl rand -hex 32`; added to BetaStore's Vault / Supabase secret store

The BetaStore operator commits:

```
feat(deploy): import webhook-ci-deploy-rollback pattern from AcmeBuilder (PI-001)

- imports/ledger entry added
- deploy.sh + deploy-poll.sh + deploy.yml in place
- fresh WEBHOOK_SECRET rotated
- LP-PI-001..003 pending validation

Source: AcmeBuilder@a1b2c3d PE-001
Evidence: T3 (not yet validated in BetaStore)

Co-Authored-By: Ulak OS pattern-import
```

## Step 5 — Validate the import

In the BetaStore repo, the operator runs `/director komple mode=REPAIR scope=deploy` again with `live_probe_required=true`. The three live probes (LP-PI-001, LP-PI-002, LP-PI-003) run. All three pass. The director writes a patch to the ledger entry:

```yaml
# BetaStore/docs/governance/pattern-import-ledger.yaml — updated
imports:
  - id: PI-001
    # ... previous fields unchanged
    validation_results:
      - LP-PI-001: pass (2026-04-23)
      - LP-PI-002: pass (2026-04-23)
      - LP-PI-003: pass (2026-04-23)
    evidence_tier_at_destination: T1        # upgraded from T3; probes confirmed
    post_import_findings:
      - minor: deploy-poll.sh interval can be tuned from 30s to 60s in BetaStore's traffic pattern
```

## What the ledger buys

- **Traceability**: every AcmeBuilder pattern in BetaStore has a line in the ledger pointing to where it came from, at what commit, with what divergence
- **Review cadence**: the `review_at` field triggers a 30-day check-in; operators can validate the imported pattern is still matching source evolution
- **Evidence-tier honesty**: a T1 pattern at source becomes T3 at destination until the destination validates it — no silent trust inflation
- **Divergence documentation**: the `divergence_notes` list captures why the pattern isn't copied verbatim; a new maintainer can read it and understand the constraint
- **Conflict-free cross-project evolution**: when AcmeBuilder's pattern changes (e.g., switches signature algorithm), the ledger entry's `source_commit` field lets BetaStore compare what changed and decide whether to follow

## When NOT to import via the ledger

- If the pattern is in a shipped Ulak OS rule pack already, use the rule pack instead — don't re-invent per project
- If the pattern is a trivial utility (e.g., a log formatter), inline it; the ledger is for non-trivial behavioral patterns
- If the source project is owned by a different team or company, prefer formalizing the pattern as an Ulak OS contribution (via CONTRIBUTING.md) so every project benefits, not just your portfolio

## Related docs

- [`docs/adr/ADR-004-pattern-import-ledger.md`](../adr/ADR-004-pattern-import-ledger.md) — the decision record
- [`docs/governance/pattern-import-ledger.md`](../governance/pattern-import-ledger.md) — the ledger format spec
- [`docs/runtime/analysis-contexts.md`](../runtime/analysis-contexts.md) — cross-project context sharing
- [`.claude/skills/pack-gap-completion/SKILL.md`](../../.claude/skills/pack-gap-completion/SKILL.md) — the extract-pattern skill
