# Rule Pack — Multi-Locale 11+ with RTL & CJK

Activated when runtime-manifest detects an i18n surface with **≥6 locales OR any combination of LTR + RTL + CJK scripts** (e.g., a SUPPORTED_LOCALES array containing `tr/en/ar/de/es/fr/ru/zh/ja/ko/pt` or similar). Inherits all imperatives from `localization-ssot.md` and `turkish-locale.md` (when `tr` is in scope) and adds script-family + scale-aware rules.

Pattern source: `docs/governance/pattern-import-ledger.md` IL-005 (11-locale security/QA scanner SaaS, T2 evidence).

## Imperatives

### Single source of truth — locale registry

- One canonical `SUPPORTED_LOCALES` array enumerates every locale code (BCP-47 form: `tr`, `en`, `ar`, `de`, `es`, `fr`, `ru`, `zh`, `ja`, `ko`, `pt`); never hard-code locale lists in components, middleware, or API routes
- Each locale entry declares: `code`, `nativeName`, `englishName`, `flag`, `direction` (`ltr` / `rtl`), `script` (`latin` / `arabic` / `cyrillic` / `cjk`), `fallback` chain, optional `requiresPrivacyRegime`
- A new locale = add one row + add translation file + run validator; touching ≥3 files is an SSOT failure

### RTL governance (ar / he / fa / ur / ckb)

- `dir="rtl"` on `<html>` when active locale is RTL — set server-side from cookie / URL / `Accept-Language`, NEVER client-side after hydration (causes layout flash)
- CSS uses **logical properties** (`margin-inline-start`, `padding-inline-end`, `border-inline-start`) — physical (`margin-left`, `padding-right`) is a bug
- Icons that imply direction (back arrow, forward chevron, undo) MIRRORED in RTL via CSS `transform: scaleX(-1)` OR a separate RTL asset; non-directional icons (search, settings, user) NOT mirrored
- Form flow + tab order respect `dir`: visual `→` becomes logical `start-to-end`; first input is rightmost in RTL
- Arabic-Indic digit choice is per-locale, not per-direction: `ar-SA` may use `٠١٢٣٤٥٦٧٨٩`; `ar-EG` may prefer Western — driven by `Intl.NumberFormat(locale).format(n)`, never hand-rolled
- Bidirectional mixed text (TR username + Arabic city name) wrapped with **bidi marks** (`‫...‬` for RLE/PDF or Unicode isolates `⁨...⁩`) so `<span>{user.name}, {user.city}</span>` does not visually scramble
- `text-align: start` (not `left`); `float: inline-start` (not `left`)

### CJK governance (zh / ja / ko)

- Font stack includes platform CJK fallbacks: `-apple-system, "PingFang SC", "Hiragino Kaku Gothic ProN", "Noto Sans CJK SC", "Microsoft YaHei", sans-serif` — Latin-only stacks render CJK as Tofu (□)
- `word-break: keep-all` and `line-break: strict` for CJK paragraphs — Latin word-breaking inserts hyphens mid-glyph
- Vertical text (Japanese tategaki, Chinese vertical) gated behind explicit operator request — default is horizontal even for CJK
- Ruby annotations (furigana, pinyin) preserved in HTML via `<ruby>` — stripped to plain text breaks reading aid
- IME composition events handled: `compositionstart` / `compositionupdate` / `compositionend` on text inputs — autocomplete + autosubmit must NOT fire mid-composition (kills IME flow)
- CJK fonts are 2–4× larger than Latin counterparts; lazy-load + subset (only needed glyph ranges) — full Noto CJK is ~24MB per weight
- Line height ≥1.6 for CJK body copy (Latin defaults of 1.4 produce cramped diacritic-free reading)

### Locale detection precedence

Server-side detection order (first match wins, document the ordering):

1. **Explicit URL prefix** — `/tr/`, `/ar/`, `/zh/` (highest signal)
2. **Cookie** — `NEXT_LOCALE=tr` / `i18n_locale=tr` (user-chosen, persists)
3. **`Accept-Language` header** — best match against `SUPPORTED_LOCALES` via `Negotiator` or equivalent
4. **IP geolocation** — fallback ONLY; privacy-aware (no third-party geo lookup without consent disclosed in privacy policy)
5. **Default** — never English-by-default for a Turkish-first / Arabic-first product; default = product's home locale

NEVER trust client-only detection (`navigator.language`) for SEO routing — search engines see no JS.

### Lazy-load, never eager-load

- A 6+-locale app MUST split locale bundles: each locale is its own JSON / chunk, dynamically imported when active
- Initial bundle ships **only the active locale** + locale registry (codes + names) — NOT all 11 dictionaries
- Common pre-load: only the top 1–2 locales by traffic; rest fetched on locale switch
- Server components / SSR: locale loaded server-side, only that locale serialized to client
- A single 5000+-LOC `i18n.ts` bundling all locales is `anti-patterns.md` AP-23 — refactor before adding a 7th locale

### Number, date, currency formatting

- `Intl.NumberFormat(locale)` — never `(1234).toLocaleString()` without locale arg (uses browser default, breaks in shared screenshots)
- `Intl.DateTimeFormat(locale, options)` — never `Date.toString()` for user-visible output
- Currency: `Intl.NumberFormat(locale, { style: 'currency', currency: 'TRY' })` — symbol position + grouping vary (`1.234,56 ₺` vs `₺1,234.56` vs `1 234,56 ₺`)
- Relative time: `Intl.RelativeTimeFormat(locale)` — never hand-rolled "5 dakika önce" / "5 minutes ago" — Slavic / Arabic plural rules break naive code
- Pluralization: `Intl.PluralRules(locale)` or ICU MessageFormat — Russian has 4 plural categories, Arabic has 6; English `${count} item${count!==1?'s':''}` breaks
- Sorting / collation: `Intl.Collator(locale)` — Turkish `i/ı` vs English ASCII order, German `ß` vs `ss`, Swedish `å` AFTER `z`

### SEO + canonical surfaces

- `hreflang` link tags on every translated page — pair with `x-default` for the language-router root
- Per-locale OG tags: `og:locale`, `og:locale:alternate` for siblings
- Canonical URL per locale (locale prefix or subdomain) — never `?lang=tr` query param (search engines treat as dup content)
- Sitemap split per locale OR locale-aware `<xhtml:link>` tags inside one sitemap
- Robots: do NOT block locale prefixes; do block locale-detection redirect endpoints (`/api/i18n/*`)

### Surface coverage gate

A locale is shipped only when ALL of these are translated and reviewed by a native speaker:

| Surface | Owner | Gate |
|---|---|---|
| UI strings (panel + landing) | i18n-lead | 100% key coverage, no machine-translated keys flagged for review |
| Email templates (transactional) | i18n-lead | per-locale subject + body + preheader |
| Push notifications | i18n-lead | per-locale title + body within character limit |
| Legal copy (Terms, Privacy, KVKK/GDPR) | privacy-compliance | jurisdiction-fit per `kvkk-gdpr-compliance.md` |
| Store listings (App Store + Play) | release-readiness | per-locale title + description + keywords + screenshots |
| SEO metadata + hreflang | seo-aso-growth | per-locale title + description + OG + canonical |
| Help center / FAQ | support-ops | top-20 articles per locale minimum |
| Error messages (server + client) | localization-i18n-lead | every Error subclass has localized `message` lookup |

UI-only translation = NOT a shipped locale. Add as `pilot` flag, not as `production`.

### Validator rules (CI-blocking)

- `scripts/validate-i18n-coverage.sh` — every key in baseline locale must exist in every other locale (empty string + identical-to-baseline both fail)
- `scripts/validate-i18n-untranslated.sh` — values identical to baseline locale flagged unless explicitly tagged `intentionally_same: true`
- `scripts/validate-i18n-machine-translated.sh` — keys with `machine_translated: true` flag count must trend toward zero per release
- `scripts/validate-rtl-css.sh` — grep for physical CSS properties (`margin-left`, `padding-right`, `text-align: left`) in components that render RTL surfaces
- `scripts/validate-cjk-fonts.sh` — every CJK-active page has CJK font in stack (no plain `font-family: Inter, sans-serif` for `lang="zh"` body)

## Collision rule

Project `.claude/rules/i18n-locales.md` overrides specific imperatives (e.g., a 3-locale subset doesn't need lazy-load); unmatched inherit from this pack. Multi-locale Turkish products also load `turkish-locale` and `localization-ssot` packs (this pack does NOT replace them — they layer).

## Integration

- `docs/runtime/localization-strategy.md` — Phase 1-5 strategy motor (this pack is the technical contract for that motor)
- `docs/runtime/turkish-normalization.md` — TR-specific char rules (loads when `tr` in `SUPPORTED_LOCALES`)
- `docs/runtime/rule-packs/turkish-locale.md` — TR locale-specific imperatives
- `docs/runtime/rule-packs/localization-ssot.md` — base SSOT discipline (this pack extends)
- `docs/runtime/rule-packs/kvkk-gdpr-compliance.md` — privacy regime per locale
- `docs/runtime/anti-patterns.md` — AP-21 (locale-blind case), AP-22 (TR slug), AP-23 (god-i18n-file)
- `docs/governance/pattern-import-ledger.md` — IL-005 source provenance

## Canonical footer

Authoritative as of Ulak OS **v1.7.0**. Imported from a multi-tenant 11-locale security/QA scanner SaaS observed in 2026-Q2. Bidirectional + CJK + privacy-regime composability is the load-bearing contribution.
