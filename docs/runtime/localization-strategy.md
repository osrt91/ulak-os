# Localization / i18n / l10n Strategy Motor

## Why this exists

"Add another language" is a ten-second request that takes six months done right. A real localization pass touches strings, dates, numbers, currencies, pluralization, search normalization, legal text, support tone, store listings, email templates, push notifications, help center, SEO metadata, screenshots, and cultural adjustment. Without a localization strategy motor, the director treats it as "translate strings and ship", which is how you end up with hardcoded ASCII in an i18n app.

## When it runs

- Automatically when `router.output_profile` is `LOCALIZATION_REPAIR_PROFILE`
- On demand when the user mentions language, locale, i18n, l10n, or specific language codes
- In Phase 2 as a specialist lane when the project has any multi-language surface

## Phase 1 — Inventory the current state

Before proposing anything, record what's actually shipping:

- Which locales are present in the code? (look for `messages/`, `locales/`, `i18n/`, `.po`, `.xliff`, `.strings`, `.arb`)
- What locale codes are used? (en, en-US, en-GB, tr, tr-TR, ...)
- Which surfaces are actually translated?
- Which surfaces are untranslated or partially translated?
- Is there a fallback chain? What happens when a key is missing in the active locale?
- Can the user pick a locale? Is there a locale switcher?
- What are the email / push / help center / legal / store / SEO locales?
- Are locale files in the repo, in a service (Phrase, Lokalise, Crowdin), or split?

Emit `reports/current/locales-inventory.md` with these answers before any recommendations.

## Phase 2 — Diff and surface gaps

For each key present in the baseline locale, check every other locale:

- Missing key? → gap
- Present but empty string? → gap
- Present but identical to baseline (untranslated)? → gap
- Present but clearly machine-translated / placeholder? → quality flag

Emit `reports/current/locale-coverage-map.md` with the gap matrix.

## Phase 3 — Opportunity analysis

For each language *not yet supported* but potentially relevant, answer:

- Why this locale?
- Market impact (user base, revenue potential, strategic)
- Operational cost (translation, QA, support, legal review)
- Legal or policy requirement (certain jurisdictions mandate local-language disclosures)
- Store / SEO / ASO value
- Cultural-fit risk (some content doesn't translate cleanly)

Label each candidate:

- **ADD_NOW** — clear value, low risk, low cost
- **ADD_NEXT_WAVE** — valuable but better after current-locale quality is stable
- **PILOT_ONLY** — add to one surface as a test before committing
- **DO_NOT_ADD_YET** — not justified by data

Emit `reports/current/language-opportunity-map.md`.

## Phase 4 — Locale is not just UI

A locale decision touches more than strings. Check each:

- **Dates** — format (DD.MM.YYYY vs MM/DD/YYYY), locale-aware parsing
- **Times** — 12h vs 24h, timezone handling, daylight savings edge cases
- **Numbers** — decimal separator (1,234.56 vs 1.234,56), thousand separator
- **Currency** — symbol position, rounding, multi-currency stores
- **Measurement** — metric vs imperial, paper sizes, clothing sizes
- **Pluralization** — ICU MessageFormat or equivalent; simple `{count} items` breaks in Slavic / Arabic
- **Sorting / collation** — locale-aware sort (Turkish `ı`/`i` vs English)
- **Cultural tone** — formal vs informal address, honorifics
- **Legal copy** — GDPR / KVKK / CCPA wording varies
- **Support hours / contact methods** — what works in one locale may not in another
- **Screenshots and captions** — the app's marketing material needs locale-specific screenshots
- **Right-to-left** — Arabic, Hebrew, Farsi require layout mirroring, not just translated strings

## Phase 5 — Surface coverage

A locale must be checked across every surface the product ships:

- public web / landing
- customer panel
- admin panel
- iOS app
- Android app
- onboarding flows
- email templates (transactional + marketing)
- push notifications
- help center
- legal / privacy / terms
- store listings (App Store + Play)
- SEO metadata (title, description, OG tags, hreflang)
- blog / docs / FAQ

A locale added to the customer panel but missing from emails is not a real locale. Surface this as a finding.

## Hard rules

- **Translation ≠ localization.** A file of translated strings does not make a product localized.
- **Machine translation without review is a quality bug.** Label it, flag it, don't ship it as "we have locale X".
- **Never ship a new locale without checking legal disclosures in that jurisdiction.**
- **Never treat RTL as "just strings".** Layout, icons, animations, and form flow all need review.
- **Never claim a locale is supported when only the UI is translated.** Email / push / help / store count.
- **When Turkish is in scope, load the Turkish normalization motor.** See `docs/runtime/turkish-normalization.md`.

## Integration

- `docs/runtime/turkish-normalization.md` — Turkish-specific character / Unicode rules
- `docs/runtime/output-profiles.md` — LOCALIZATION_REPAIR_PROFILE required sections
- `.claude/agents/localization-i18n-lead.md` — the specialist that runs this motor in Phase 2
- Artefacts: `locales-inventory.md`, `locale-coverage-map.md`, `language-opportunity-map.md`
