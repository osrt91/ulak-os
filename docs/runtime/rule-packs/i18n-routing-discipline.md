# Rule Pack — i18n Routing Discipline

Activated when runtime-manifest detects (a) i18n routing middleware (`next-intl`, `react-i18next` with router integration, `vue-i18n-routing`, Astro `astro-i18next`), AND (b) ≥2 locales in the locale registry, AND (c) public-facing surfaces (not admin-only). Sibling to `multi-locale-eleven-rtl.md` (script-family + scale governance) and `localization-ssot.md` (translation SSOT) — this pack governs the **routing + URL + metadata + crawler** surface specifically.

Pattern source: `docs/governance/pattern-import-ledger.md` IL-021 (Next.js 16 + self-hosted Supabase content/portfolio site with multi-locale i18n + OTP admin CMS, T1 evidence — locale-prefix loss via raw `<a>`, missing per-locale metadata on aliased URLs, OG/SEO description drift across sources).

## Imperatives

### Locale-prefix routing — never lose it

- **Banned**: raw HTML `<a href="/...">` in app code for internal navigation. Every internal link uses the framework's locale-aware helper:
  - Next.js + next-intl: `Link` from `next-intl/navigation` (NOT `next/link`)
  - Next.js App Router + custom: a project-wide `IntlLink` wrapper that injects `${locale}/` prefix
  - React Router + i18next: `<Link to>` with locale-aware basename
  - Vue + vue-i18n-routing: `<NuxtLink>` / `<RouterLink>` with `useLocaleRoute`
  - Astro: `astro:i18n` `getRelativeLocaleUrl()`
- **Allowed exceptions** (and only these): `<a>` tags inside `<head>` for `rel="canonical"` / `rel="alternate"` / `rel="me"` (these intentionally bypass routing); external URLs to other domains.
- **Detection**: ESLint custom rule banning JSX `<a>` outside `<head>` import scope; CI grep `grep -rE 'href="/[^/"]+' src/components/ src/app/` flags any candidate.
- **Symptom of leak**: clicking an internal link triggers full-page reload, drops locale prefix, middleware re-detects locale and 307-redirects. Crawl-budget waste; weakened hreflang signal; broken SPA navigation.

### Per-locale URL aliases — hreflang + canonical mandatory

- A page with locale-aliased URLs (`/gizlilik` for TR, `/privacy` for EN, `/datenschutz` for DE) MUST have:
  - `generateMetadata` (Next.js) / per-locale `<Head>` (Vue/Nuxt) / Astro frontmatter `<title>` + meta — emitting per-locale title/description
  - `<link rel="canonical" href="/${locale}/${alias}">` — canonical URL is the locale-prefixed alias, not the base form
  - `<link rel="alternate" hreflang="${otherLocale}" href="/${otherLocale}/${otherAlias}">` for every sibling locale
  - `<link rel="alternate" hreflang="x-default" href="/${defaultLocale}/${defaultAlias}">` for the default fallback
  - Sitemap entry per `<locale, slug>` pair OR one entry per page with `<xhtml:link>` siblings
- **Banned**: locale-aliased pages without `generateMetadata` — Google indexes whichever form it crawls first, often without language signal.
- **CI gate**: `scripts/validate-i18n-route-metadata.sh` walks `src/app/[locale]/**/page.tsx` (or framework equivalent), fails if any page lacks `generateMetadata` AND lacks an explicit `metadata` export.

### Sitemap per-locale or per-page-with-alternates

- Choose ONE strategy, document it, enforce it:
  - **Strategy A — per-locale sitemap**: `/sitemap-tr.xml` + `/sitemap-en.xml` + ... linked from `/sitemap.xml` index
  - **Strategy B — single sitemap with alternates**: one `<url>` per page, with `<xhtml:link rel="alternate" hreflang="..." href="...">` siblings for every other locale's version
- Strategy B is preferred for ≤20 locales (smaller, more crawl-efficient, Google-recommended); Strategy A is preferred for >20 locales OR when locale rollout is staggered (some locales launch later)
- Either way: every public page in every shipped locale appears in some sitemap entry
- CI gate: `scripts/validate-sitemap-coverage.sh` — for each `<route, locale>` combo in the routing manifest, assert it appears in the sitemap

### SEO single source of truth per page

- A page's title, description, OG card text, and JSON-LD description MUST come from ONE canonical source, not be re-typed in 4 places.
- Pattern: a `seo.ts` config object per route (or a CMS `page_meta` record) exporting:
  ```ts
  export const seo = {
    title: t('blog.meta.title'),
    description: t('blog.meta.description'),
    ogTitle: t('blog.og.title') ?? t('blog.meta.title'),
    ogDescription: t('blog.og.description') ?? t('blog.meta.description'),
    jsonLdDescription: t('blog.meta.description'),
    ogImageAlt: t('blog.og.imageAlt'),
  } as const;
  ```
- `generateMetadata`, OG image generator, and JSON-LD emitter all import from this module — drift is impossible because there's only one source.
- **Banned**: hard-coded English description in OG image generator while i18n message file has the translated one. This produces the "two sources, two stories" failure (`anti-patterns.md` AP-37).
- CI gate: `scripts/validate-seo-source-of-truth.sh` — per page route, parse rendered HTML + OG image text + JSON-LD; assert pairwise equality (or whitelisted divergence with documented reason).

### OG image generator must respect i18n

- OG image generators (Next.js `opengraph-image.tsx`, Astro `astro-og-canvas`, Cloudflare Workers OG) MUST:
  - Accept `locale` parameter (from URL segment / route params)
  - Render with the locale's font stack (Latin / Arabic-RTL / CJK — see `multi-locale-eleven-rtl.md §CJK governance`)
  - Source title/description from the SEO SSOT module (above)
  - Fall back gracefully on missing-locale to default-locale rendering
- Concrete failure mode: an OG generator hardcodes 7-8 hex colors + a non-design-system font, ignores the SSOT module, and renders English even on TR pages. Fix: enforce `import { seo } from './seo'; import { tokens } from '@/design-system/tokens'` in every OG generator.

### Locale-detection precedence (server-side)

(Cross-reference with `multi-locale-eleven-rtl.md §Locale detection precedence` — same protocol)

1. URL prefix (`/tr/`, `/en/`) — highest signal
2. Cookie (`NEXT_LOCALE`, `i18n_locale`) — user-chosen, persists
3. `Accept-Language` header — best-match against `SUPPORTED_LOCALES`
4. IP geolocation — fallback ONLY; privacy-aware (disclose in privacy notice)
5. Default — never English-by-default for a Turkish-first / Arabic-first product

Server-side detection only — `navigator.language` is not visible to crawlers; relying on client-side detection breaks SEO entirely.

### Robots + AI crawlers per-locale

- `robots.txt` does NOT block any locale prefix (a "block /tr/" line is a self-DoS on the Turkish market)
- `robots.txt` MAY block locale-detection redirect endpoints (`/api/i18n/redirect`, `/api/locale-set`) — these have no SEO value
- AI crawler stance (`GPTBot`, `Claude-Web`, `PerplexityBot`, `Google-Extended`) declared per locale only if the policy differs (rare — usually a single policy applies across locales)
- `/llms.txt` content (if shipped) is locale-specific OR a single English summary covering all locales; NOT a TR-only summary if the site has English content too

### Internal redirect chains — zero tolerance

- Locale-mismatched click should NOT produce a 307/308 chain longer than 1 hop. Pattern observed: raw `<a>` → middleware redirect (1) → trailing-slash normalization (2) → locale-prefix injection (3) — a 3-hop chain on every click.
- Fix: `<Link>`/`IntlLink` everywhere, plus a one-time middleware that handles locale + slash + canonical in a single 308.
- CI gate: `scripts/validate-redirect-chain-length.sh` — Playwright crawl of every internal link, assert response chain ≤1 redirect.

### Default-locale fallback rendering

- Pages missing translation in active locale fall back to the default locale (NOT to a 404, NOT to a partial English-leaked page)
- Fallback metadata: `<link rel="alternate" hreflang="${activeLocale}" href="(default-locale URL)">` with logged warning to translator queue
- Banned: "Page not yet translated" stub displayed to user — that's a noindex page leaking into search

## Validator rules (CI-blocking)

- `scripts/validate-no-raw-anchor-internal.sh` — ESLint + grep, no raw `<a href="/...">` in app code
- `scripts/validate-i18n-route-metadata.sh` — every `[locale]/**/page.tsx` exports `generateMetadata` (or static `metadata`)
- `scripts/validate-sitemap-coverage.sh` — every `<route, locale>` is in some sitemap entry
- `scripts/validate-seo-source-of-truth.sh` — title/description across HTML/OG/JSON-LD match per route
- `scripts/validate-redirect-chain-length.sh` — Playwright crawl, ≤1 redirect per internal link
- `scripts/validate-og-locale-rendering.sh` — OG image generators receive locale param + use SSOT module

## Collision rule

Project `.claude/rules/i18n-routing.md` overrides specific imperatives (a project may have a documented reason for raw `<a>` in a specific surface — e.g., legal third-party redirect); unmatched inherit. This pack does NOT replace `multi-locale-eleven-rtl.md` or `localization-ssot.md` — it layers atop them on the routing/URL/SEO surface specifically.

## Integration

- `docs/runtime/rule-packs/multi-locale-eleven-rtl.md` — script-family governance; this pack assumes locale registry already exists
- `docs/runtime/rule-packs/localization-ssot.md` — translation SSOT; this pack assumes message keys flow through it
- `docs/runtime/rule-packs/turkish-locale.md` — TR-specific char rules
- `docs/runtime/rule-packs/kvkk-gdpr-compliance.md` — privacy notice routing per jurisdiction (often a locale-aliased URL: `/gizlilik` vs `/privacy` vs `/datenschutz`)
- `docs/runtime/anti-patterns.md` — AP-34 (raw `<a>` in i18n app), AP-35 (i18n route without metadata/sitemap), AP-37 (OG/SEO description drift)
- `docs/governance/pattern-import-ledger.md` — IL-021 source provenance

## Canonical footer

Authoritative as of Ulak OS **v1.8.0**. Imported from a Next.js 16 + self-hosted Supabase content/portfolio site with multi-locale i18n + OTP admin CMS observed 2026-04-25 director run (locale-prefix loss via raw `<a>` in dock navbar; locale-aliased TR-only `/gizlilik` lacked `generateMetadata` + sitemap entry; OG image generator had English-only description while message file had localized one). The combined locale-routing + per-locale metadata + SSOT-SEO contract is the load-bearing contribution; products with single-locale or admin-only i18n do not need this pack.
