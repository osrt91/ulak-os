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

## Canonical footer

Authoritative as of Ulak OS **v2.0.0** (updated from v2.2.0 IL-001 baseline — note: that "v2.2.0" reference is from the abandoned pre-reset cycle; the current public line is v1.0.0-launch → v1.6.1 → v2.0.0). v2.0.0 adds IL-002..IL-006 from the 11-locale security/QA scanner SaaS pattern absorption pass on 2026-04-26.
