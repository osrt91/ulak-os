# Pattern Import Ledger

## Why this exists

When a team operates multiple projects, patterns migrate between them. scanner-project.com reuses CMS, blog, site-settings, and integration-panel patterns from Trend-Platform. Those patterns arrived via copy-paste; once arrived, they lose their provenance. A bug fixed in the Trend-Platform original doesn't propagate to the scanner-project copy. A security patch in the source might not reach the consumers. Developers reading scanner-project can't easily tell "where did this come from" — the answer is in someone's head.

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
    source_project: trend-platform.com
    source_repo: "/home/osrt91/desktop/proje/trend-platform.com"  # or a git URL
    source_commit: "e4a7c21"  # commit SHA at time of import
    source_files:
      - "app/admin/cms/page.tsx"
      - "app/api/cms/route.ts"
      - "lib/cms-client.ts"
    target_files:
      - "app/admin_business.py"          # scanner-project consumer of the pattern
      - "app/routers/content.py"
      - "app/integrations_store.py"
    imported_on: 2025-11-04
    imported_by: osrt91
    divergence_notes: |
      - Scanner-project stores content in Supabase JSONB; Trend-Platform uses Postgres rows.
      - Scanner-project has i18n keys for Turkish; Trend-Platform was English-only at import time.
      - Authorization is DB-role-based in scanner-project; Trend-Platform uses user_metadata (which is why
        AP-06 drift exists in the import).
    upstream_fixes_pending:
      - id: UF-01
        description: "Trend-Platform commit f82b3a1 added XSS sanitization; scanner-project copy does not have it"
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

This converts "I should remember to sync with Trend-Platform" into "the system surfaces the delta every audit".

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
3. Baseline ledger is committed as `IL-001` ... `IL-NNN`

Missing entries are findings, not blockers — the ledger builds over time.

## Integration

- `docs/governance/prompt-supply-chain.md` — sibling supply-chain doc
- `docs/runtime/architecture-currency.md` — drift scan cadence includes ledger check
- `.claude/agents/architecture-lead.md` — the agent that runs the ledger audit
- `docs/runtime/anti-patterns.md` — "Schema drift" and "Dead code" anti-patterns sometimes trace back to ledger entries with stale divergence

## Canonical ledger (live)

### IL-001: Trend-Platform → scanner-project.com (CMS + blog + site-settings + integration-definitions)

```yaml
id: IL-001
pattern_name: "CMS + blog + site-settings + integration-definitions surface"
source_project: trend-platform.com
source_repo: "C:\\Users\\osrt91\\desktop\\proje\\trend-platform.com\\"
source_commit: "(pre-2026-04-20 snapshot; exact SHA to be backfilled when Trend-Platform is audited)"
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
imported_on: 2025-11-04  # approximate; refine when Trend-Platform git log is cross-referenced
imported_by: osrt91
divergence_notes: |
  - Database isolation: Trend-Platform uses tenant-scoped rows with tenant_id FK;
    scanner-project stores per scan_id (different domain, both use schema isolation)
  - Internationalization: Trend-Platform blog is bilingual TR/EN at schema level;
    scanner-project blog is trilingual (TR/EN/AR) with i18n context
  - Authorization: Trend-Platform uses Supabase RLS policies on settings;
    scanner-project uses server-side verifyAdmin() check
  - Scope: Trend-Platform's integrations are a configuration surface (B2B SaaS
    enabling partners); scanner-project's integrations are a scanning capability surface
  - Drag-drop builder (trend-platform homepage_sections) NOT ported to scanner-project
upstream_fixes_pending: []
v213_r4_status: UPHELD  # T3 memory claim confirmed with T1 evidence on 2026-04-20
```

### Verification metadata

Verified via Phase A cross-project Explore agent on 2026-04-20 (v2.2.0 planning pass). T3→T1 tier upgrade applied. R4 residual-risk from v2.1.3 self-audit is **closed** as of v2.2.0.

Future entries append below IL-001 with incremented id (IL-002, IL-003, ...).

## Canonical footer

Authoritative as of Ulak OS **v2.2.0** (updated from v2.1.3 G-03 pattern introduction). Initial ledger entry IL-001 verified 2026-04-20.
