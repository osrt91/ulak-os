# Pattern Import Ledger

## Why this exists

When a team operates multiple projects, patterns migrate between them. reuses CMS, blog, site-settings, and integration-panel patterns from. Those patterns arrived via copy-paste; once arrived, they lose their provenance. A bug fixed in the original doesn't propagate to the copy. A security patch in the source might not reach the consumers. Developers reading can't easily tell "where did this come from" — the answer is in someone's head.

A **pattern import ledger** is a lightweight YAML file in the consuming project that records every imported pattern: source repo, source commit, import date, local divergence notes. It makes multi-project operators honest, makes upstream bug-fixes propagable, and gives architecture-lead a checkable audit trail.

## File location and shape

Every project that imports patterns from sibling projects maintains:

- `docs/governance/pattern-import-ledger.yaml` — machine-readable ledger
- (optional) `docs/governance/pattern-import-ledger.md` — human-readable narrative version

### Ledger entry shape

```yaml
imports:
 - id: IL-001
 pattern_name: "CMS + blog + site-settings surface"
 source_project: source_repo: "/home/osrt91/desktop/proje/" # or a git URL
 source_commit: "e4a7c21" # commit SHA at time of import
 source_files:
 - "app/admin/cms/page.tsx"
 - "app/api/cms/route.ts"
 - "lib/cms-client.ts"
 target_files:
 - "app/admin_business.py" # consumer of the pattern
 - "app/routers/content.py"
 - "app/integrations_store.py"
 imported_on: 2025-11-04
 imported_by: osrt91
 divergence_notes: |
 - stores content in Supabase JSONB; uses Postgres rows.
 - has i18n keys for Turkish; was English-only at import time.
 - Authorization is DB-role-based in ; uses user_metadata (which is why
 AP-06 drift exists in the import).
 upstream_fixes_pending:
 - id: UF-01
 description: "commit f82b3a1 added XSS sanitization; copy does not have it"
 severity: high
 scheduled_for: v2.1.4

 - id: IL-002
 pattern_name: "Docker-proxy introspection sidecar"
 source_project: (operator's internal pattern library)
 source_repo: -
 source_commit: -
 source_files: []
 target_files:
 - "docker-compose.yml (service: docker-proxy)"
 imported_on: 2025-08-12
 imported_by: osrt91
 divergence_notes: |
 Initially used socket-proxy:0.1; upgraded to 0.3 on 2026-01-20 for CVE-2025-xxxx.
 upstream_fixes_pending: []
```

## Authoring discipline

Every ledger entry MUST have:

1. **`id`** — stable identifier (`IL-NNN`); does not change if the entry is later updated
2. **`pattern_name`** — short human-readable title
3. **`source_project`** — name of the source repo (or `(operator's internal pattern library)` if no single-source)
4. **`source_commit`** — commit SHA at time of import (empty string if unknown — flag as T7 in findings)
5. **`source_files`** — enumerated files, with line ranges if the pattern is a subset
6. **`target_files`** — where the pattern lives in the consumer
7. **`imported_on`** and **`imported_by`** — date + operator (immutable once set)
8. **`divergence_notes`** — every intentional difference from the source. NOT "we didn't read carefully" — actual design choices
9. **`upstream_fixes_pending`** — bugs fixed in source after import date that have NOT yet been backported

## Architecture-lead audit cadence

At every Phase 2 specialist dispatch, architecture-lead:

1. Reads the ledger
2. For each entry with `source_commit`, runs `git log source_commit..HEAD --oneline` in the source repo
3. For each new commit in the source, assesses whether the change is relevant to the imported pattern (bugfix, security, breaking change)
4. If yes, files a pending-backport finding

This converts "I should remember to sync with " into "the system surfaces the delta every audit".

## When to create an entry

Create an entry when:

- You copy-paste code from another repo you operate
- You generalize a pattern from one project to another (even with rewrites — "inspired by X" is still an import)
- You adopt a convention (directory layout, test structure, config shape) from another repo

Do NOT create an entry for:

- Open-source library dependencies (those are `package.json` / `requirements.txt`)
- One-off tactical copies (a single function; this is noise)
- Pattern shared via blog post or Stack Overflow (no upstream-fix source exists)

## Ledger as supply-chain artefact

The ledger is part of the **prompt supply chain** family (`docs/governance/prompt-supply-chain.md`). Just as the prompt supply chain tracks where operating rules come from, the pattern-import ledger tracks where code patterns come from. Both answer the question "if the source changes, what do we need to review?"

## Initial population

For existing projects (not greenfield), a baseline ledger pass is recommended:

1. Architecture-lead (or cartographer) identifies obvious imports from sibling projects
2. User confirms / annotates each candidate
3. Baseline ledger is committed as `IL-001`... `IL-NNN`

Missing entries are findings, not blockers — the ledger builds over time.

## Integration

- `docs/governance/prompt-supply-chain.md` — sibling supply-chain doc
- `docs/runtime/architecture-currency.md` — drift scan cadence includes ledger check
- `.claude/agents/architecture-lead.md` — the agent that runs the ledger audit
- `docs/runtime/anti-patterns.md` — "Schema drift" and "Dead code" anti-patterns sometimes trace back to ledger entries with stale divergence

## Canonical ledger (live)

### IL-001: → (CMS + blog + site-settings + integration-definitions)

```yaml
id: IL-001
pattern_name: "CMS + blog + site-settings + integration-definitions surface"
source_project: source_repo: "C:\\Users\\osrt91\\desktop\\proje\\\\"
source_commit: "(pre-2026-04-20 snapshot; exact SHA to be backfilled when is audited)"
source_files:
 - "apps/admin/src/app/(dashboard)/blog/page.tsx:1-404"
 - "apps/admin/src/app/api/settings/route.ts:1-49"
 - "supabase/migrations/00011_site_settings.sql"
 - "supabase/migrations/00036_homepage_sections.sql"
 - "apps/master/src/lib/integration-definitions.ts:1-150+"
target_files:
 - "frontend/app/blog/page.tsx:1-60"
 - "frontend/components/admin/ContentManager.tsx (line 16)"
 - "frontend/app/admin/page.tsx:19 (IntegrationStatus)"
 - "app/routers/tenant-integrations/route.ts"
imported_on: 2025-11-04 # approximate; refine when git log is cross-referenced
imported_by: osrt91
divergence_notes: |
 - Database isolation: uses tenant-scoped rows with tenant_id FK;
 stores per scan_id (different domain, both use schema isolation)
 - Internationalization: blog is bilingual TR/EN at schema level;
 blog is trilingual (TR/EN/AR) with i18n context
 - Authorization: uses Supabase RLS policies on settings;
 uses server-side verifyAdmin check
 - Scope: integrations are a configuration surface (B2B SaaS
 enabling partners); integrations are a scanning capability surface
 - Drag-drop builder (homepage_sections) NOT ported to upstream_fixes_pending: []
v213_r4_status: UPHELD # T3 memory claim confirmed with T1 evidence on 2026-04-20
```

### Verification metadata

Verified via Phase A cross-project Explore agent on 2026-04-20 (v2.2.0 planning pass). T3→T1 tier upgrade applied. R4 residual-risk from v2.1.3 self-audit is **closed** as of v2.2.0.

Future entries append below IL-001 with incremented id (IL-002, IL-003,...).

### IL-002: 11-locale security/QA scanner SaaS → AP-21 locale-blind case conversion

```yaml
id: IL-002
pattern_name: "Locale-blind case conversion (Turkish-bypass via missing locale arg)"
source_project: "(operator's portfolio — 11-locale multi-tenant security/QA scanner SaaS)"
source_repo: "(abstract descriptor only; redacted per pattern-extract discipline)"
source_commit: "(production HEAD as of 2026-04-26)"
source_files:
  - "frontend/lib/i18n.ts (case-conversion-free dictionary access — pattern is in caller code)"
  - "frontend/components/admin/EmailsTab.tsx (email case-fold lookup)"
  - "frontend/lib/auth-context.tsx (login email normalization)"
  - "app/services/email_service.py (recipient address normalization)"
  - "app/routers/admin_ops.py (search query case-fold)"
target_files:
  - "docs/runtime/anti-patterns.md §Localization anti-patterns AP-21"
  - "docs/runtime/rule-packs/multi-locale-eleven-rtl.md §Number/date/currency formatting (mentions Intl.Collator for locale-aware case via collation)"
  - "docs/runtime/rule-packs/turkish-locale.md (already existed; AP-21 cross-references it)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T2  # disk evidence in source project, abstract descriptor in shipped Ulak OS doc
divergence_notes: |
  - Source project's failure modes (i̇stanbul combining mark, İSİM upper-case mismatch) are documented as concrete examples in AP-21 without naming the source.
  - Ulak OS canonical fix recommends locale arg across 4 stacks (JS / Python / Java-Kotlin / Postgres) — broader than source's single-stack issue.
  - Lint-rule recommendation (ban naked toLowerCase) is a Ulak generalization, not a source convention.
upstream_fixes_pending: []
```

### IL-003: 11-locale security/QA scanner SaaS → AP-22 Turkish slug collision + display leak

```yaml
id: IL-003
pattern_name: "Turkish slug collision unresolved + slug-as-display leak"
source_project: "(operator's portfolio — 11-locale multi-tenant security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26)"
source_files:
  - "frontend/lib/* slug helpers (slugify utility chain)"
  - "frontend/utils/* (URL builders that re-use slug as breadcrumb label)"
  - "app/routers/admin_content.py (slug uniqueness handling)"
target_files:
  - "docs/runtime/anti-patterns.md §Localization anti-patterns AP-22"
  - "docs/runtime/turkish-normalization.md §Display vs search vs slug (already existed; AP-22 cites it)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T2
divergence_notes: |
  - Three-field model (display + search_key + slug) is a Ulak canonical generalization; source project's actual storage model is not enumerated in shipped doc.
  - Collision resolution strategies (numeric suffix vs disambiguation token) presented as alternatives — operator picks.
  - Source project's specific city-name examples (İstanbul / Şişli / Sisli) used in AP-22 as illustration; safe because they are public Turkish placenames, not portfolio identifiers.
upstream_fixes_pending: []
```

### IL-004: 11-locale security/QA scanner SaaS → AP-23 God i18n file

```yaml
id: IL-004
pattern_name: "God i18n file (single >3000 LOC dictionary bundling all locales)"
source_project: "(operator's portfolio — 11-locale multi-tenant security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26 — file at 6583 LOC, 11 locales bundled)"
source_files:
  - "frontend/lib/i18n.ts (single 6583-line module with TR/EN/AR/DE/ES/FR/RU/ZH/JA/KO/PT all bundled)"
target_files:
  - "docs/runtime/anti-patterns.md §Localization anti-patterns AP-23"
  - "docs/runtime/rule-packs/multi-locale-eleven-rtl.md §Lazy-load, never eager-load"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T2
divergence_notes: |
  - Source project's specific 6583 LOC count is referenced in shipped doc as ">3000 LOC threshold" — concrete number redacted.
  - Strangler Fig 4-step migration is a Ulak generalization mapping to existing `docs/runtime/strangler-fig-protocol.md`.
  - Trigger threshold (>1500 LOC OR >4 locales) is a Ulak heuristic; source project's actual threshold was not enforced.
upstream_fixes_pending:
  - id: UF-IL004-01
    description: "Source project should adopt per-locale split + dynamic import; not yet implemented."
    severity: medium
    scheduled_for: "(source-project decision — Ulak OS only ships the pattern recognition)"
```

### IL-005: 11-locale security/QA scanner SaaS → multi-locale-eleven-rtl rule-pack

```yaml
id: IL-005
pattern_name: "11-locale registry with RTL + CJK + lazy-load + jurisdiction-aware detection"
source_project: "(operator's portfolio — 11-locale multi-tenant security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26)"
source_files:
  - "frontend/lib/i18n.ts:1-100 (SUPPORTED_LOCALES array + locale metadata table)"
  - "frontend/lib/i18n-context.tsx (server-side locale detection + cookie persistence)"
  - "frontend/app/layout.tsx (dir attribute + html lang setup)"
target_files:
  - "docs/runtime/rule-packs/multi-locale-eleven-rtl.md (NEW — full pack)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T2
divergence_notes: |
  - Locale list (tr/en/ar/de/es/fr/ru/zh/ja/ko/pt) is publicly known + matches BCP-47 — safe to reproduce.
  - RTL governance (logical CSS, bidi marks, icon mirroring) is a Ulak generalization; source project's RTL maturity not specified in shipped pack.
  - CJK governance (font fallback, line-break-strict, IME composition) is largely operator-knowledge baseline — source project may not enforce all imperatives yet.
  - Lazy-load imperative is the load-bearing addition (vs. source project's current god-i18n-file pattern, see IL-004).
upstream_fixes_pending: []
```

### IL-006: 11-locale multi-jurisdiction QA SaaS → kvkk-gdpr-compliance rule-pack

```yaml
id: IL-006
pattern_name: "Multi-jurisdiction privacy regime matrix (KVKK + GDPR + APPI + PIPA + PIPL + 152-FZ + PDPL)"
source_project: "(operator's portfolio — 11-locale multi-tenant security/QA scanner SaaS operating across TR + EU + JP + KR + CN + RU + KSA jurisdictions)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26)"
source_files:
  - "docs/marketing/blog/03-kvkk-uyumlu-web-sitesi-checklist.md (KVKK content baseline)"
  - "docs/marketing/blog/01-web-guvenlik-taramasi-rehberi-2026.md (cross-regime scanning context)"
  - "frontend/lib/i18n.ts (privacy notice keys per locale)"
  - "frontend/app/settings/page.tsx (DSR access surface)"
  - "frontend/app/register/page.tsx (consent capture point)"
target_files:
  - "docs/runtime/rule-packs/kvkk-gdpr-compliance.md (NEW — full pack)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T2  # source provides locale + KVKK content baseline; jurisdiction matrix is Ulak operator-knowledge generalization across portfolio
divergence_notes: |
  - The 7-regime matrix (TR/EU/UK/CA/JP/KR/CN/RU/KSA/UAE/BR) is a Ulak canonical aggregation; source project ships a subset of these jurisdictions in production.
  - Retention matrix YAML shape is Ulak-prescribed; source project's current retention discipline is partial.
  - DSR endpoints (`/api/dsr/*`) are a Ulak target-state contract; source project may not yet expose all 7 endpoints.
  - Validator scripts (`validate-privacy-notice-coverage.sh`, `validate-retention-config.sh`, `validate-dsr-endpoints.sh`, `validate-cookie-consent.sh`) are Ulak-shipped CI templates; source project will adopt them as part of v1.7.0 absorption.
upstream_fixes_pending:
  - id: UF-IL006-01
    description: "Source project should map every shipped locale to its regime + ensure DSR endpoints are reachable for non-EU users."
    severity: high
    scheduled_for: "(source-project decision)"
```

### IL-007: Security/QA scanner SaaS → AP-24 + async-python-fastapi rule-pack (sync DB in async)

```yaml
id: IL-007
pattern_name: "Sync DB / HTTP call inside async def handler — event loop saturation"
source_project: "(operator's portfolio — Python 3.12 + FastAPI security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26; absorbed from 2026-04-24 director run finding B-004)"
source_files:
  - "app/routers/admin.py (42 endpoints, multiple async def with sync db._get_conn())"
  - "app/db.py (sync psycopg2 connection wrapper)"
  - "(68 sync db._get_conn() instances inside async def across the codebase, per backend-api specialist count)"
target_files:
  - "docs/runtime/anti-patterns.md AP-24"
  - "docs/runtime/rule-packs/async-python-fastapi.md (NEW — full pack)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1  # specialist file:line evidence in source project audit
divergence_notes: |
  - Stack-specific replacements (psycopg2→asyncpg, requests→httpx, redis-py→redis.asyncio, pymongo→motor, boto3→aioboto3) are Ulak generalizations.
  - Connection pool lifecycle (FastAPI lifespan, app.state.db_pool) is canonical async-FastAPI pattern; source project may not yet implement.
  - Validator script (`validate-no-sync-in-async.sh`) is a Ulak-shipped CI template; source project will adopt as part of v2.0.0 absorption.
upstream_fixes_pending:
  - id: UF-IL007-01
    description: "Source project: migrate 68 sync calls to asyncpg + lifespan-managed pool (Sprint 2-3 XL)"
    severity: critical
    scheduled_for: "(source project Sprint 2-3 per their execution-roadmap)"
```

### IL-008: Security/QA scanner SaaS → AP-25 spec/doc drift from disk

```yaml
id: IL-008
pattern_name: "Spec / doc drift from disk reality (8.5x undercount)"
source_project: "(operator's portfolio — security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26; absorbed from did-you-know #1)"
source_files:
  - "CLAUDE.md §API Endpoint Tablosu (claimed 14 routes + 1 WebSocket)"
  - "app/routers/*.py (16 router files; grep confirmed 119 actual routes)"
target_files:
  - "docs/runtime/anti-patterns.md AP-25"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1
divergence_notes: |
  - 8.5x ratio (14 declared / 119 actual) used in AP-25 as concrete example without naming source.
  - Auto-regeneration prescription (`scripts/regenerate-claude-md.sh`) is Ulak generalization; source project's actual auto-regen tooling not specified.
  - 10% drift threshold for CI gate is a Ulak heuristic.
upstream_fixes_pending: []
```

### IL-009: Security/QA scanner SaaS → AP-26 zombie router

```yaml
id: IL-009
pattern_name: "Zombie router / silent route override via include_router order"
source_project: "(operator's portfolio — FastAPI security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26; absorbed from did-you-know #2)"
source_files:
  - "app/routers/content.py (4 routes for /content/* with cache-invalidation logic)"
  - "app/routers/admin.py (registered first, claims same /content/* paths)"
  - "app/main.py (include_router order)"
target_files:
  - "docs/runtime/anti-patterns.md AP-26"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1
divergence_notes: |
  - FastAPI-specific (include_router) but pattern generalizes to Express (app.use), Next.js (route.ts ordering), Rails (routes.rb).
  - Detection script + integration test prescription are Ulak generalizations.
  - Symptom narrative ("cache sometimes doesn't refresh") is a real reported observation, not synthesized.
upstream_fixes_pending:
  - id: UF-IL009-01
    description: "Source project: remove duplicate /content/* registration; consolidate cache-invalidation logic into single live router"
    severity: high
    scheduled_for: "(source project Sprint 1)"
```

### IL-010: Security/QA scanner SaaS → AP-27 hardcoded production UUIDs in migrations

```yaml
id: IL-010
pattern_name: "Hardcoded production UUIDs in migration committed to public history"
source_project: "(operator's portfolio — security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26; absorbed from did-you-know #6 / D-003 finding)"
source_files:
  - "app/db.py:331-342 (migration step 12 with 3 hardcoded production user UUIDs for role bootstrap)"
target_files:
  - "docs/runtime/anti-patterns.md AP-27"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1
divergence_notes: |
  - Source project has 3 UUIDs hardcoded; AP-27 generalizes to "any literal production identifier in migration".
  - Mitigation strategy (rotate vs git history rewrite) presented as alternatives.
  - The "attacker target list" framing is a Ulak operator-knowledge expansion of the original finding's risk note.
upstream_fixes_pending:
  - id: UF-IL010-01
    description: "Source project: rotate 3 leaked admin/operator/viewer UUIDs (new user creation + soft-delete of leaked); document in v2.0 incident log"
    severity: high
    scheduled_for: "(source project Sprint 0-1)"
```

### IL-011: Security/QA scanner SaaS → AP-28 cosmetic coverage gate

```yaml
id: IL-011
pattern_name: "Cosmetic coverage gate (fail_under declared, --cov never invoked)"
source_project: "(operator's portfolio — security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26; absorbed from did-you-know #9 / Q-002 finding)"
source_files:
  - "pyproject.toml:43 (fail_under = 70 declared)"
  - "scripts/preflight.sh:85 (pytest call without --cov flag)"
  - "9 compliance modules / 6841 LOC / 0 tests (audit verdict's Q-001)"
target_files:
  - "docs/runtime/anti-patterns.md AP-28"
  - "docs/runtime/rule-packs/async-python-fastapi.md §Test discipline (cross-references AP-28)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1
divergence_notes: |
  - Generalizes to JS ecosystems (`coverageThreshold` in jest.config.js + `npm test` without --coverage).
  - Validator script (`validate-coverage-gate.sh`) is Ulak-shipped CI template.
  - Family relationship to AP-03 (non-blocking CI gate) made explicit in cross-reference.
upstream_fixes_pending:
  - id: UF-IL011-01
    description: "Source project: enable `--cov=app --cov-fail-under=70` in preflight; expect first run failure; calibrate threshold to realistic baseline"
    severity: medium
    scheduled_for: "(source project Sprint 1)"
```

### IL-012: Security/QA scanner SaaS → AP-29 + ai-generated-content-hygiene rule-pack

```yaml
id: IL-012
pattern_name: "AI-generated content artefacts shipped to production (Gemini conversational + broken JSON-LD)"
source_project: "(operator's portfolio — security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(absorbed from commit `e601aaf` — chore(blog): 5 yazıdan Gemini sohbet artıkları + bozuk schema temizliği)"
source_files:
  - "docs/marketing/blog/*.md (5 blog posts containing Gemini chat artefacts pre-cleanup)"
  - "(JSON-LD blocks in those posts with hallucinated @type / missing required fields / trailing commas)"
target_files:
  - "docs/runtime/anti-patterns.md AP-29"
  - "docs/runtime/rule-packs/ai-generated-content-hygiene.md (NEW — full pack)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1  # actual git commit cleaning the artefacts is direct evidence
divergence_notes: |
  - Per-locale marker lists (TR, EN, plus 9-locale extension points) are Ulak generalization across portfolio.
  - JSON-LD validator + Schema.org @type allowlist are Ulak-shipped CI templates.
  - Provenance front-matter contract (ai_assisted, ai_tool, review_date, peer_reviewer) is Ulak prescription; source project may not yet adopt.
  - This is the most timely-novel anti-pattern in absorption pass #2 — AI-era content hygiene is a 2026 essential.
upstream_fixes_pending:
  - id: UF-IL012-01
    description: "Source project: install validate-ai-content-markers.sh + validate-schema-jsonld.sh in CI; backfill provenance metadata for existing AI-assisted posts"
    severity: medium
    scheduled_for: "(source project content-ops sprint)"
```

### IL-013: Security/QA scanner SaaS → AP-30 admin self-lockout

```yaml
id: IL-013
pattern_name: "Admin self-deletion / last-admin lockout protection"
source_project: "(operator's portfolio — security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(absorbed from commit `e678a20` — fix(security): admin kendi hesabını silemez (system lockout koruması))"
source_files:
  - "(admin user-management endpoint protected against self-deletion + last-admin demotion in source commit)"
target_files:
  - "docs/runtime/anti-patterns.md AP-30"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1
divergence_notes: |
  - Source project fixed self-deletion specifically; AP-30 generalizes to last-admin demotion + role-uniqueness invariants (last billing-owner, last security-officer, last DPO).
  - Emergency-recovery runbook prescription is Ulak generalization.
upstream_fixes_pending: []
```

### IL-014: Security/QA scanner SaaS → AP-31 cache invalidation timing race

```yaml
id: IL-014
pattern_name: "Cache invalidation timing race (invalidate-after-commit window)"
source_project: "(operator's portfolio — security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(absorbed from commit `dee34ba` — fix(sprint-12.A8 review): cache invalidation timing + audit log)"
source_files:
  - "(cache-invalidate code path that ran after DB commit; race window observable under concurrent writer/reader)"
target_files:
  - "docs/runtime/anti-patterns.md AP-31"
  - "docs/runtime/rule-packs/async-python-fastapi.md §Anti-patterns specifically banned (cross-reference)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1
divergence_notes: |
  - Three remediation strategies (invalidate-before-commit, version column, write-invalidate-write) presented as alternatives.
  - Race-test prescription (concurrent reader/writer load test) is Ulak generalization.
  - Async amplification note specifically connects to async-python-fastapi.md.
upstream_fixes_pending: []
```

### IL-015: Security/QA scanner SaaS → async-python-fastapi rule-pack (full pack provenance)

```yaml
id: IL-015
pattern_name: "Async FastAPI safety pack (consolidated technical contract)"
source_project: "(operator's portfolio — Python 3.12 + FastAPI security/QA scanner SaaS)"
source_repo: "(abstract descriptor only)"
source_commit: "(production HEAD as of 2026-04-26; consolidated from B-002 + B-004 + Q-001 findings + AP-24/26/28/31)"
source_files:
  - "(entire async surface of source project: 119 routes, 16 router files, asyncpg/httpx adoption gaps)"
target_files:
  - "docs/runtime/rule-packs/async-python-fastapi.md (NEW — full pack)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1
divergence_notes: |
  - Pack consolidates 5 anti-patterns (AP-24, AP-26, AP-28, AP-31 plus baseline AP-01/AP-07 references) into a single technical contract.
  - Connection pool sizing heuristic (`(vCPU * 2) + 1`) is general FastAPI lore, not source-specific.
  - Background task discipline (BackgroundTasks vs queue) reflects industry consensus, not unique source-project insight.
  - This pack is the load-bearing addition for any async-Python project; v2.0.0 absorption pass #2 elevates it from operator knowledge to canonical pack.
upstream_fixes_pending: []
```

### IL-016: Security/QA scanner SaaS → ai-generated-content-hygiene rule-pack (full pack provenance)

```yaml
id: IL-016
pattern_name: "AI-generated content hygiene pack (consolidated detection + validation contract)"
source_project: "(operator's portfolio — security/QA scanner SaaS with AI-assisted content pipeline)"
source_repo: "(abstract descriptor only)"
source_commit: "(absorbed from commit `e601aaf` + AP-29 + ongoing AI-era content discipline gap)"
source_files:
  - "docs/marketing/blog/*.md (5 blog posts cleaned of Gemini artefacts + JSON-LD repair)"
  - "(per-locale marker lists synthesized from observed leak patterns)"
target_files:
  - "docs/runtime/rule-packs/ai-generated-content-hygiene.md (NEW — full pack)"
imported_on: 2026-04-26
imported_by: osrt91
trust_tier: T1  # source commit is direct evidence of the artefact-leak phenomenon
divergence_notes: |
  - Per-locale conversational-marker lists (English + Turkish baseline; 9 other locales are extension points) are Ulak operator-knowledge synthesis.
  - JSON-LD validator gate, Schema.org @type allowlist, and content-staleness scanner are Ulak-shipped CI templates.
  - Provenance front-matter contract (ai_assisted, ai_tool, review_date, peer_reviewer) elevates editorial discipline from informal practice to ledger-verifiable.
  - This pack is the most timely-novel addition in absorption pass #2 — AI-era content hygiene was not in any pack pre-v2.0.0.
upstream_fixes_pending:
  - id: UF-IL016-01
    description: "Source project: install full validator chain (markers + JSON-LD + provenance); extend per-locale marker lists for 9 non-TR/EN locales"
    severity: medium
    scheduled_for: "(source project content-ops sprint)"
```

## Canonical footer

Authoritative as of Ulak OS **v2.0.0** (updated from v2.2.0 IL-001 baseline — note: that "v2.2.0" reference is from the abandoned pre-reset cycle; the current public line is v1.0.0-launch → v1.6.1 → v2.0.0). v2.0.0 absorption pass #1 (2026-04-26 morning) added IL-002..IL-006 from the 11-locale security/QA scanner SaaS i18n + privacy regime patterns. v2.0.0 absorption pass #2 (2026-04-26 evening) added IL-007..IL-016 from the same source project's async-FastAPI safety, doc-drift, zombie-router, hardcoded-UUID, cosmetic-coverage, AI-content artefact, admin-lockout, and cache-timing-race patterns plus 2 consolidated rule-packs (async-python-fastapi + ai-generated-content-hygiene).
