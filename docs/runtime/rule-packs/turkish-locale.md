# Rule Pack — Turkish Locale

Activated when runtime-manifest detects Turkish as the product language (CLAUDE.md / package.json / i18n folders mention `tr` or `tr-TR`) OR when the operator locale is Turkish.

## Imperatives

- Never `.toLowerCase` / `.toUpperCase` — always pass locale: `.toLocaleLowerCase('tr')` / `.toLocaleUpperCase('tr')`. `i` ↔ `I`, `ı` ↔ `I`, `i` ↔ `İ` require locale awareness.
- Normalize for **search** using `.localeCompare(other, 'tr', { sensitivity: 'base' })`; keep display form separate (display keeps ç ğ ı ö ş ü).
- JSON responses: serialize with `ensure_ascii=False` (Python) or default (Node) — never fold `ğ` → `g` on wire
- HTML `lang="tr"` required on `<html>`; missing lang breaks screen readers + search engines
- Collation in DB: use `tr_TR.UTF-8` or ICU collation `tr-x-icu` for ORDER BY on user-visible text
- Hardcoded Turkish strings in source code → move to i18n file; treat as `tr-TR` key, not "default"
- Turkish month names, weekday names: use `Intl.DateTimeFormat('tr-TR',...)` not hardcoded arrays
- Turkish number formatting: `1.234,56` (thousands = `.`, decimal = `,`) — use `Intl.NumberFormat('tr-TR')`

## Collision rule

Project `.claude/rules/turkish.md` overrides specific imperatives; unmatched inherit. Cross-language products (e.g. tr + en) also load `localization-ssot` rule pack.
