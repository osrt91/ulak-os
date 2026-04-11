# Turkish Normalization Motor

## Why this exists

Turkish text has six characters that other languages do not: **ç ğ ı İ ö ş ü** (with the dotted / dotless i being the trickiest). Most i18n libraries, URL slug generators, search indexes, and display pipelines were built by developers who don't speak Turkish, and they break subtly. Text gets silently ASCII-folded, ı becomes i, İ becomes I, and suddenly "İstanbul" displays as "Istanbul" in the title bar and "istanbul" in the URL and neither matches the search query. The user reports "our app looks broken in Turkish" and nobody can find it.

This motor encodes the rules that prevent those failures.

## When it runs

- Automatically when `router.required_overlays` contains `turkish-normalization`
- On demand when the localization-i18n-lead detects Turkish (locale codes `tr`, `tr-TR`, `tr-CY`, or string content heuristics)
- In Phase 2 as part of the localization specialist's deep scan

## The six characters that define Turkish text quality

Every Turkish text surface must correctly render, store, and round-trip:

| Character | Description | Common failure |
|---|---|---|
| **ç / Ç** | c with cedilla | ASCII-folded to `c`/`C` |
| **ğ / Ğ** | soft g (no plosive in speech) | ASCII-folded to `g`/`G` |
| **ı** | dotless lowercase i | Folded to `i` — **this is the big one** |
| **İ** | dotted uppercase I | Folded to `I` — **pair with ı** |
| **ö / Ö** | o with umlaut | ASCII-folded to `o`/`O` |
| **ş / Ş** | s with cedilla | ASCII-folded to `s`/`S` |
| **ü / Ü** | u with umlaut | ASCII-folded to `u`/`U` |

## The ı / i / İ / I trap

English has two letters: `i` (lowercase) and `I` (uppercase). They are each other's case pair.

Turkish has FOUR letters: `ı` (dotless lowercase), `i` (dotted lowercase), `I` (dotless uppercase), `İ` (dotted uppercase).

The case pairs are:

- `ı` ↔ `I` (no dots)
- `i` ↔ `İ` (with dots)

This is not the same as English. A naive `toUpperCase("istanbul")` in a non-Turkish locale yields `ISTANBUL` (wrong — should be `İSTANBUL`). A naive `toLowerCase("İSTANBUL")` yields `i̇stanbul` or `istanbul` depending on the locale (also potentially wrong).

Every case conversion in a Turkish context must use a **locale-aware** case function (e.g., `String.toLocaleUpperCase("tr-TR")` in JavaScript, `String#uppercase(Locale("tr"))` in Kotlin, `toupper_l` with Turkish locale in C).

## Display vs search vs slug — three separate layers

A common bug: the team uses one normalized form everywhere. This is wrong. There are three layers and they have different rules.

### 1. Display layer
- Shows text to the user
- Uses the correct Unicode characters: `İstanbul`, `Yağmur`, `Şimdi`
- Never ASCII-folded
- Locale-aware case conversion (tr-TR)
- NFC normalized

### 2. Search / index layer
- Powers full-text search, autocomplete, fuzzy matching
- May use a fold map: `ı→i`, `İ→i`, `ç→c`, `ğ→g`, `ö→o`, `ş→s`, `ü→u` (lowercased, ASCII-folded)
- This fold is controlled and lossy — it's NOT the display representation
- The user can type `istanbul` and match `İstanbul` because both fold to `istanbul`
- NFD + strip diacritics is acceptable for search ONLY
- The search index stores both the folded key AND a pointer to the original display text

### 3. Slug / URL / identifier layer
- Appears in URLs, filenames, database keys
- Uses a separate transliteration: `İ→I`, `ı→i`, `ç→c`, `ğ→g`, `ö→o`, `ş→s`, `ü→u` (case preserved or forced per convention)
- Stable across runs — do not change the slug algorithm after data exists
- Never derived from the search fold, never derived from the display text
- Collisions (`öz` and `oz` both becoming `oz`) must be handled explicitly

These three layers must never leak into each other. If the slug algorithm ends up in the display, Turkish text looks broken. If the display form ends up in search, typing `istanbul` doesn't find `İstanbul`.

## Detection rules for Turkish text issues

When scanning a project for Turkish quality issues, look for:

- **ASCII fold in display** — grep for `.toAscii`, `normalize-to-ascii`, `slugify(display=true)`, and check if the result is rendered to users
- **`.toUpperCase()` / `.toLowerCase()` without a locale argument** in any path that touches Turkish strings
- **Slug functions used for display labels** — slug is a one-way function; if the display text is computed from the slug, Turkish is broken
- **Search query normalized differently from indexed content** — the fold must match on both sides
- **Collation / sort operations without locale** — Turkish sorts `i` before `ı`, not after
- **Hardcoded `en` or default locale** in any case / sort / search call
- **Email / push / SMS templates with hardcoded English variable substitution** — `${name.toUpperCase()}` without locale will break names like `İrem`
- **Filename generation** that folds Turkish characters silently — affects media uploads, exports, receipts

## Correction confidence levels

When proposing a fix, label each recommendation:

- **high_confidence** — the issue is reproducible with test input, the fix is locale-aware, and the library supports it
- **contextual_suggestion** — the fix depends on the layer (display/search/slug) and the team must confirm which layer the code is in
- **suspicious_case_needing_review** — something looks wrong but requires a native speaker or test data to confirm

## Text quality audit (content layer)

Beyond encoding, Turkish content itself can feel machine-translated. Red flags:

- **Machine-translation odor** — sentences that are literal English syntax in Turkish word order
- **Suffix mismatches** — Turkish agglutinates; wrong vowel harmony reveals machine output (`Türkçe'de` vs `Türkçede`)
- **Wrong technical terms** — "dosya" vs "fayl", "tarayıcı" vs "browser", inconsistent per surface
- **English leaks** — stray "Submit", "Loading", "Next" in Turkish UI
- **Unnatural CTAs** — `İleri Git` instead of `Devam Et` or `İleri`
- **Untrustworthy tone** — formal where the product is casual, or vice versa
- **Legal copy boilerplate English** buried in a Turkish flow

These go into `reports/current/turkish-text-audit.md` as findings.

## Artefacts produced

- `reports/current/turkish-text-audit.md` — content quality findings
- `reports/current/character-normalization-issues.md` — encoding + case conversion bugs with file:line citations
- `reports/current/search-indexing-notes.md` — analysis of the display/search/slug split

## Hard rules

- **`toUpperCase()` / `toLowerCase()` without a locale is a bug if Turkish is in scope.** No exceptions.
- **Display text is never ASCII-folded.** No exceptions.
- **Search and display share storage but not format.** Store the original, index the fold, render the original.
- **Slug ≠ display.** Never derive display from slug.
- **Do not collapse `İ` and `I`.** Do not collapse `ı` and `i`. They are different characters.
- **Never claim "Turkish is supported" when only the tr.json file exists.** Check display, search, slug, email, push, legal, store.

## Integration

- `docs/runtime/localization-strategy.md` — activated as a sub-motor when Turkish is in scope
- `.claude/agents/localization-i18n-lead.md` — the specialist that runs this motor
- `docs/runtime/output-profiles.md` — LOCALIZATION_REPAIR_PROFILE requires Turkish audit fields when Turkish is a locale
