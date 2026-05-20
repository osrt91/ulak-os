# Wording Manager — Greenfield Intake

**Generated**: 2026-04-20 by Ulak OS (brainstorming + ulak-intake pattern)
**Status**: DRAFT — operator confirms or amends before `/ulak-scaffold` dispatch
**Output profile**: GREENFIELD_BUILDER_PROFILE
**Intervention mode**: CREATE

## Operator context

From session 2026-04-20: operator has had a "wording manager" idea sitting in their notes but hasn't been able to bring it to life. Ulak OS goal is to convert the idea into a ship-ready Wave-by-Wave plan + scaffolded starter project.

## 1. Product thesis (best inference — OPERATOR: confirm or amend)

**Wording Manager**: a **content operations SaaS** that manages brand/marketing/product copy across a portfolio of surfaces (landing pages, emails, push notifications, in-app strings, store listings, ad copy), with multi-locale discipline, version history, reviewer workflows, and AI-assisted tone/consistency checks.

Why this inference fits the operator's portfolio pattern:
- Turkish-first product (per operator locale)
- Multi-locale from day 1 (operator runs projects in tr+en+ar+...)
- Multi-project portfolio (operator runs 10+ products — content-ops SaaS could serve them all)
- AI-integrated (Gemini-only per ai-provider-allowlist) — tone check, translation suggestions, consistency audit
- Likely B2B (other operators / small brand teams as customers)

**If the operator's "wording manager" is actually something else (e.g. a personal Notion-style writing assistant, a word-game SaaS, a WordPress plugin), the entire intake below re-routes. Operator: one-line amend if off-target.**

## 2. Primary user personas

| Persona | Primary job-to-be-done | Access tier |
|---|---|---|
| Content team lead | Define brand voice rules, approve copy variants | admin |
| Copywriter | Draft + submit copy across surfaces + locales | customer |
| Developer | Consume finalized copy via API + webhook | customer (with API key) |
| Reviewer / translator | Review copy in a specific locale, approve or send back | customer (scoped to locale) |
| Agency / external brand team | Manage ≥2 client accounts from one login | partner (reseller tier) |

→ Activates **4 surfaces**: public (marketing site) + customer (team members) + admin (content ops lead) + partner (agencies managing multiple brands).

## 3. Minimum viable surfaces

### Public surface
- Landing page (marketing, TR + EN)
- Pricing page
- Privacy + terms
- Public API docs (for developer tier)

### Customer surface
- Dashboard: "brands" list (if reseller) or single-brand overview
- Copy editor: per-surface (landing, email, push, in-app, store), per-locale side-by-side editor
- Glossary / brand-voice rules (the reusable discipline layer)
- Version history per copy unit
- Tone consistency check (AI-assisted — Gemini)
- Export: JSON / YAML / CSV / webhook
- Team management (invite, role)

### Admin surface
- Organization-wide brand voice rules
- Cross-brand audit log
- Billing + subscription
- Usage metrics (AI-call count, seat count, locale count)
- Feature flag dashboard

### Partner (reseller) surface
- Sub-account management (create brand accounts for clients)
- Commission dashboard
- Co-branded reports
- Per-brand white-label tokens

## 4. Technical shape

### Stack (scaffolder inputs)

```yaml
product_name: "wording-manager"
product_domain: "content-ops"
stack_frontend: "nextjs"
stack_backend: "supabase"
locale_primary: "tr"
locales_supported: ["tr", "en"]
payment_provider: "iyzico"         # TR-first; add Stripe later via dual-rail
has_reseller_tier: true            # agencies managing multiple brands
has_admin_surface: true
has_mobile: false                  # web-first; mobile later via expo workspace
hosting: "self-managed-vps"
output_path: "../wording-manager"
```

### Activated Ulak OS packs

From `saas-scaffolder` skill's derivation:

**Sector packs**:
- `saas` (always)
- `media-content` (closest match for content-ops domain)
- `payment-integrated-saas` (Iyzico)
- `reseller-enabled-saas` (agency tier)
- `multi-tenant-supabase` (per-brand schema isolation)
- `vps-nginx-compose-topology` (self-managed VPS)
- `admin-cms-hardening` (heavy admin surface)
- `ai-relay-cost-control` (AI-assisted tone check = LLM relay)

**Rule packs**:
- `typescript-nextjs`
- `docker-compose`
- `api-security`
- `turkish-locale`
- `localization-ssot` (multi-locale from day 1)
- `llm-streaming-context-aware` (AI tone check is streaming response)

**Anti-patterns enforced from commit 1**:
- AP-06 user_metadata as authz (DB role from day 1)
- AP-08 payment sandbox hardcoded (Iyzico sandbox↔live env toggle)
- AP-10 multi-file schema drift (Zod + SQL + TS types from single SSOT)
- AP-11 multi-layer auth bypass (single auth helper)
- AP-13 server-only not imported (`lib/supabase/admin.ts` has `import 'server-only'`)
- AP-16 .env.local committed
- AP-17 no DB backup (daily pg_dump cron from day 1)
- AP-18 static HMAC empty body (deploy webhook signs full body + timestamp)
- AP-19 root .env.local in monorepo (if later adds mobile/expo)

## 5. Differentiators vs. existing content-ops tools

Most existing content-ops tools (Contentful, Strapi, Storyblok, Phrase, Lokalise) solve CMS + i18n but not **brand voice consistency + AI tone check + per-surface copy orchestration** in one tool. Wording Manager's specific wedge:

1. **Brand-voice-as-code** — rules live in the project, not in a PDF the team forgot about
2. **Per-surface editor** — landing / email / push / in-app strings / store listings / ad copy in a single dashboard (not 5 tools)
3. **AI tone check at write-time** — every copy submission scored against brand rules; failures surface BEFORE approval, not during review
4. **Multi-locale from commit 1** — TR-first portfolio shape; RTL support baseline
5. **Reseller / agency tier built-in** — agencies managing 5-10 client brands get a first-class surface (not "use our enterprise tier + contact sales")
6. **Developer-first API** — JSON / YAML / CSV / webhook export; no CMS vendor lock-in
7. **Turkish-speaking operator's product** — target market is Turkish brand teams first, with English expansion. Most existing tools are US-first + poor Turkish locale support

## 6. MVP Wave plan (14 days / ~30 Waves)

Using Ulak OS `multi-agent-orchestration` skill pattern:

**Wave 0 — Scaffold + Sprint 0 director audit** (1 day)
- `/ulak-scaffold` with inputs above → wording-manager/ directory
- `cd ../wording-manager && /director komple` → v0.1.0 baseline audit
- Commit: green CI, green validate-imports, green validate-schemas, baseline eval pass

**Wave 1 — Auth + surface split** (2 days)
- Customer sign-up / sign-in (Supabase)
- Admin role seed
- Single auth helper at `lib/auth/index.ts` used by every route
- Product-surface-split verified: customer/admin/partner route prefixes

**Wave 2 — Brand + copy data model** (2 days)
- `brands` table (tenant_id = brand_id)
- `copy_units` table (surface, locale, version, status, content, brand_id FK)
- `copy_versions` table (append-only history)
- `brand_voice_rules` table (rules as structured JSON)
- RLS policies: brand members see only their brand's copy units
- Zod + SQL + TS types from one SSOT (AP-10 prevention)

**Wave 3 — Per-surface editor MVP** (3 days)
- Landing copy editor (key-value with preview)
- Email template copy editor
- Push notification copy editor
- Version history drawer
- Side-by-side locale view (tr + en)

**Wave 4 — AI tone check** (2 days)
- Gemini relay at `app/api/ai/tone-check/route.ts` (streaming)
- Input cap + rate limit (AI-relay-cost-control pack)
- Tone-check result per submission; surface before approval

**Wave 5 — Reviewer workflow** (1 day)
- Submit → review → approve states
- Reviewer can scope to one locale

**Wave 6 — Developer export API** (1 day)
- `/api/public/v1/copy/:brand/:surface/:locale` — read-only with API key
- Webhook on copy-approved event
- OpenAPI spec generated from Zod

**Wave 7 — Payment + billing** (2 days)
- Iyzico integration via transactional FSM pattern
- Subscription tiers: Free (1 brand, 100 copy units) / Pro (5 brands, 1000 units) / Agency (unlimited brands, reseller surface)
- Webhook signature verification (AP-08 + AP-18 prevention)
- TRY + USD dual-amount tables

**Wave 8 — Admin dashboard** (1 day)
- Cross-brand audit log
- Usage metrics
- Billing view

**Wave 9 — Reseller tier** (1 day)
- Partner sub-account creation
- Commission dashboard

**Wave 10 — Polish + landing + deploy** (1 day)
- Marketing landing page (TR + EN)
- Pricing page
- `infrastructure/deploy.sh` with health probe
- First prod deploy
- Post-deploy smoke tests

## 7. Validation gates

Every Wave closes only when:

- `pnpm typecheck` green
- `pnpm lint` green
- `pnpm test` green (unit + integration)
- `pnpm test:e2e` green for critical flows
- `bash scripts/preflight.sh` green (pre-push parity)
- CI (`.github/workflows/ci-validation.yml`) green on the commit
- Wave 1+ also: `/director komple` re-run shows no regression in 15-dim scorecard

## 8. Open questions (OPERATOR: decide before Wave 0)

1. **Product name** — is "wording-manager" acceptable or do you want a branded name (e.g. "Sözcük", "CopyDeck", "Marka Ses")?
2. **MVP target locales** — tr + en only, or add Arabic from day 1?
3. **Pricing** — target TRY tiers? (rough: Free / Pro 299 TRY/month / Agency 1499 TRY/month?)
4. **Domain** — existing domain you want to use, or should Wave 0 include registering a new domain?
5. **Competition study depth** — do you want a full `market-research-engine` dispatch (Contentful + Strapi + Phrase + Lokalise pricing + feature comparison) before Wave 1, or MVP-first and study later?
6. **AI tone check scope** — only Gemini (per allowlist), or should we allow a "bring-your-own-key OpenAI" tier for enterprise customers later?

## 9. Next action

**If operator confirms the thesis + stack**: run

```
/ulak-scaffold product_name=wording-manager product_domain=content-ops locale_primary=tr locales_supported=["tr","en"] payment_provider=iyzico has_reseller_tier=true has_admin_surface=true hosting=self-managed-vps output_path=../wording-manager
```

Then:

```
cd ../wording-manager
pnpm install
cp .env.example .env.local   # fill placeholders
pnpm dev
/director komple             # v0.1.0 baseline audit
```

**If operator wants to amend** (product thesis, stack, persona, any of the 6 open questions): edit this file in place and re-run the command with new inputs.

## Canonical footer

This intake is the first real `greenfield-saas-starter` sector pack (SP-14) exercise. Generated by Ulak OS v2.2.2 on 2026-04-20. If the scaffold run succeeds and the first director audit comes back green, this intake becomes evidence that "Ulak OS produces full-stack SaaS from commit 1" — the v1.0 showcase promise.
