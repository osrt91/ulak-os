# Rule Pack — Localization SSOT

Activated when runtime-manifest detects ≥2 locales in i18n surface (locale files, DB translation columns, content-collections multi-locale).

## Imperatives

- One **single source of truth** file enumerates every supported locale (`src/lib/locales.ts` or equivalent): code, display name, RTL flag, fallback chain
- Never hardcode locale strings in components — always `t(key, locale)` or framework-provided hook
- Missing key in a locale = CI failure (not runtime fallback); use `scripts/validate-i18n.sh` to enforce
- RTL locales (ar, he, fa, ur): `dir="rtl"` on root element; CSS logical properties (`margin-inline-start` not `margin-left`)
- Date / number / currency: `Intl.*` with explicit locale, never `.toLocaleString` without argument
- Translation storage in DB: JSONB column `{ "tr": "...", "en": "..." }` — NOT separate rows per locale (join cost)
- Auto-translation (Google Translate API etc.): tag machine-translated keys with `machine_translated: true` so humans can review
- Email / push / legal / store listings are locale-gated; "UI translated but email English" = AP-* (incomplete locale support)

## Collision rule

Project `.claude/rules/localization.md` overrides specific imperatives; unmatched inherit. Turkish products also load `turkish-locale` pack.
