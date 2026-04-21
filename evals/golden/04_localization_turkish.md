# Golden Prompt 04 — Localization Turkish Repair

## User request

> "Türkçe karakterleri, locale-aware casing'i ve eksik dilleri düzelt."

## Expected router decision

```yaml
router:
 task_type: intervention
 active_mode: repair
 project_state: brownfield
 intervention_mode: REPAIR
 scope_level: multi-surface-full-system
 live_research_need: not-needed
 artefact_program: full
 output_type: markdown-artifact-set
 output_profile: LOCALIZATION_REPAIR_PROFILE
 required_overlays:
 - localization-strategy
 - turkish-normalization
 required_sector_packs: []
 blocked_paths: []
 validation_depth: standard
 max_parallel_agents: 4
 rationale: "Explicit Turkish + locale + missing languages scope. LOCALIZATION_REPAIR_PROFILE maps directly. Turkish normalization overlay is required."
```

## Expected active agent map

- cartographer (for i18n file inventory)
- localization-i18n-lead (primary)
- backend-api-architect (for search / index impact)
- qa-validation-commander (for locale test gates)
- seo-aso-growth-strategist (for store listing + hreflang)

## Must include (assertions)

- Turkish normalization overlay is active
- localization-i18n-lead runs
- `reports/current/locales-inventory.md` exists listing all current locale files and their surfaces
- `reports/current/locale-coverage-map.md` exists showing key diff between locales
- `reports/current/language-opportunity-map.md` exists with ADD_NOW / ADD_NEXT_WAVE labels for missing languages
- `reports/current/turkish-text-audit.md` exists and covers content quality (not just encoding)
- `reports/current/character-normalization-issues.md` exists with file:line citations for:
 - `.toUpperCase` / `.toLowerCase` calls without a locale argument
 - ASCII-fold in display paths
 - slug functions leaking into display
 - hardcoded English in Turkish surfaces
- `reports/current/search-indexing-notes.md` explains the display / search / slug three-layer split
- The output explicitly distinguishes:
 - display layer (correct Unicode, locale-aware case)
 - search / index layer (controlled fold)
 - slug / URL layer (separate transliteration)
- The four Turkish characters `ı / i / İ / I` are called out by name
- Surface coverage includes email, push, help center, legal, store listings, SEO metadata — not just UI

## Must NOT include

- "Just run translate on the missing keys" as the main recommendation
- Treating locale as UI-only (must cover email/push/legal/store/SEO)
- ASCII-folding the display layer
- Using `toUpperCase` / `toLowerCase` without a locale argument in proposed fixes
- Claiming Turkish is supported when only the tr.json file exists
- Conflating the slug algorithm with the display rendering

## Validation criteria

- `turkish_normalization_activated`: the overlay is loaded and its rules are applied
- `display_search_slug_split`: all three layers are distinguished in the output
- `case_conversion_locale_aware`: proposed fixes use locale-aware case functions
- `surface_coverage_complete`: recommendation spans UI + email + push + legal + store
- `language_opportunity_labeled`: missing languages have ADD_NOW / etc. labels

## Regression signals

- A recommendation to "add tr.json" as the complete fix
- Missing `İ` / `ı` in the analysis
- Recommending `String.toUpperCase` without a locale
- Treating search and display as the same normalization layer
- Skipping store listing / email / push localization
