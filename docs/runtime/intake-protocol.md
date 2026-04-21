# Intake Protocol

## Why this exists

The user often drops material on the system: a zip, a repo, a set of screenshots, a CSV of routes, a list of endpoints, loose notes, log snippets, store listings. Without an intake protocol, the director treats these as a single blob and misses conflicts, gaps, and authority signals. With intake protocol, every file is inventoried, every piece of evidence is tiered, every missing-but-critical artefact is named, and every contradiction is recorded.

## When it runs

Phase 1 (deep inventory) includes the intake protocol for any user-provided material that is not already inside the project repo. For material that IS inside the repo, the cartographer walks it as part of the normal inventory. For material that is NOT inside the repo (zips, screenshots, external docs), the intake protocol processes it first and then it joins the evidence-register.

## Step 1 — File intake summary

For each file or batch the user provides, emit:

```yaml
- name: "" # filename or batch label
 type: "" # md|zip|screenshot|log|csv|json|pdf|url|note
 surface: "" # product|admin|api|infra|design|marketing|store|compliance|other
 trust: T1|T2|T3|T4|T5|T6|T7 # see evidence-trust-scoring.md
 use_reason: "" # why this matters for the task
 criticality: high|medium|low
 source: "" # where the user got it
```

This goes into `reports/current/file-intake-summary.md`.

## Step 2 — Evidence map

Group the intake material into categories so specialists know where to look:

```yaml
strategy_brief: [] # product briefs, roadmap docs, pitch decks
design_ui: [] # screenshots, Figma exports, style guides
technical_repo: [] # code, configs, package.json, migrations
routes_screens_endpoints: [] # URL lists, screen inventories, API specs
security_qa_logs: [] # pentest reports, audit findings, log snippets
market_pricing_reviews: [] # competitor decks, pricing pages, app reviews
language_copy_localization: [] # translation files, copy docs, locale exports
release_store_policy: [] # store listings, privacy policies, disclosures
```

This goes into `reports/current/evidence-map.md`.

## Step 3 — Conflict register

When two sources disagree, record it. Do not silently pick one.

```yaml
- conflict_id: "CONF-001"
 conflict_area: "" # e.g. "auth flow"
 conflicting_sources:
 - source: ""
 trust: T1-T7
 claim: ""
 - source: ""
 trust: T1-T7
 claim: ""
 likely_authoritative_source: "" # picked using the trust ordering rule
 resolution_status: open|tentative|resolved
 resolution_rationale: ""
```

This goes into `reports/current/conflict-register.md`. The manager-verdict must reference any unresolved conflicts.

## Step 4 — Missing evidence list

Name every critical artefact that is NOT in scope but should be. This is the intake's gift to the planning phase — it tells the director what to ask for or assume.

Common missing-evidence items:

- auth flow documentation
- route map
- env separation notes (dev/staging/prod)
- analytics event taxonomy
- localization files per locale
- store listing copy
- SSO / tenant docs
- RLS / permission policy
- rollback runbook
- cert auto-renew config
- backup / restore runbook
- observability dashboards
- incident response plan

Record each as:

```yaml
- id: "MISS-001"
 what: "" # the missing artefact
 why_critical: "" # what the director can't conclude without it
 fallback: "" # what the director will assume if not provided
 trust_of_fallback: T4|T5|T6|T7 # usually T6 or T7
```

This goes into `reports/current/missing-evidence.md`.

## Hard rules

- **Do not see the zip, say "got it", and silently integrate.** Emit the intake summary first.
- **Do not stop the run because evidence is missing.** Record the gap, proceed with a labeled assumption, and surface it in the verdict.
- **Do not assume the user's file is T2.** A file the user hand-picks is T4 (direct user-provided artifact) unless it's the literal repo source. Understanding this matters for trust ordering.
- **Do not collapse multiple conflicting sources into "the project says X".** Record the conflict, pick the authoritative source using the trust ordering, explain the pick.
- **Conflict status "resolved" requires a trust-ordered reason, not a vibe.** If you can't explain which source won and why, mark it `tentative`.

## Integration

- Phase 1 (deep inventory) — runs intake protocol on non-repo material
- `docs/governance/evidence-trust-scoring.md` — the trust tiers used here
- `docs/governance/finding-schema.md` — conflicts feed into findings with contradiction_status
- `reports/current/evidence-register.md` — merged output that specialists read in Phase 2
