# Universal Surface Inventory

## Why this exists

A system is not one thing. It's a collection of surfaces: frontend, backend, API, admin panel, mobile app, marketing site, email templates, store listings, infrastructure, analytics, legal docs. A good audit identifies every relevant surface, notes which exist, which are missing, which are critical, and which are risky. Without a surface inventory, specialists work in overlapping and sometimes orthogonal views and nothing ties together.

This doc defines the canonical surface taxonomy. The cartographer uses it at Phase 1 to produce `inventory.md`.

## Product surfaces

Things the end user sees or interacts with:

- **public web / landing** — marketing site, blog, docs, homepage
- **customer panel** — authenticated end-user UI
- **admin panel** — operator / internal tool UI
- **iOS app** — native or cross-platform iOS
- **Android app** — native or cross-platform Android
- **cross-platform shared layer** — Flutter / React Native / Kotlin Multiplatform
- **desktop app / PWA** — installable web or native desktop
- **support / help / legal surfaces** — help center, contact, privacy policy, terms, about
- **store / distribution surfaces** — App Store listing, Google Play listing, web store

## System surfaces

Things that run behind the product:

- **frontend** — web app bundles, SPA routes, static assets
- **backend services** — API servers, microservices, background workers
- **authenticated API** — endpoints used by the customer panel or app
- **admin / internal API** — endpoints used by the admin panel or internal tools
- **public / open API** — endpoints documented as public surface, including webhooks received from integrations
- **webhooks / callbacks** — outbound and inbound callback endpoints
- **databases** — primary DB, analytics DB, read replicas, search indexes
- **search** — full-text search, vector search, autocomplete
- **queues / jobs** — background job runners, cron tasks
- **file storage** — S3 / blob / local storage
- **auth / session / identity** — SSO, OAuth, session store
- **billing / subscription / payments** — Stripe, payment gateway integration
- **notifications** — push, email, SMS, in-app
- **caching layer** — CDN, Redis, in-process cache

## Operational surfaces

Things the team uses to build, ship, run, and observe:

- **CI / CD** — GitHub Actions, GitLab CI, Jenkins, build pipelines
- **environments** — dev, staging, prod, preview
- **feature flags** — LaunchDarkly, Split, Unleash, in-house
- **observability** — logs, metrics, traces, crash reports
- **analytics** — product analytics, marketing analytics, BI warehouses
- **release / distribution workflows** — signing, store submission, rollback
- **incident / runbook / on-call** — incident response, runbooks, on-call rotation
- **privacy / compliance** — data processing agreements, DPIA, privacy reviews
- **prompt / agent / tooling governance** — how the team decides what to ship in `CLAUDE.md`, `.claude/commands/`, `.claude/agents/`, `.claude/skills/`, `.mcp.json`

## Per-surface questions (the inventory lens)

For each surface the director identifies, answer:

- **Does it exist?**
- **Is it critical to the user-facing product?**
- **Is it currently risky or broken?**
- **Is it missing but should exist?**
- **Which languages / locales does it ship in?**
- **Which markets does it touch?**
- **Who owns it? (team, role, lane)**
- **What's the last-known health signal?**

These answers go into `reports/current/inventory.md` with file:line citations where they can.

## Broken-surface map (RESCUE mode must include)

When the intervention mode is REPAIR, RESCUE, or REFACTOR, the inventory must also produce a broken-surface map:

- Broken links (internal, external, store, legal)
- Dead routes (defined but unreachable, 404 in prod)
- Dead CTAs (buttons that do nothing or go to wrong place)
- Dead filters (filter UI that doesn't actually filter)
- Orphan menu items (menu entries pointing to removed pages)
- Invalid deep links (universal link / app link that don't resolve)
- Broken callbacks (webhook endpoints returning non-200 silently)
- Broken endpoints (documented but not implemented, or implemented but broken)
- Stale search indexes
- Broken store or legal URLs

Each entry carries a file:line or URL and a trust tier.

## Hard rules

- **Do not claim "we looked at all surfaces" without listing them.** Explicit enumeration beats implicit coverage.
- **Do not skip broken-surface map in RESCUE mode.** Rescue without broken-surface map is shallow.
- **Do not collapse customer panel and admin panel into "the web UI".** They are different surfaces with different risk profiles.
- **Do not skip store / legal / help surfaces for mobile products.** They are release-blocking.
- **Do not claim a surface is missing without a validation that it would be needed.** "Should exist" requires a reason.

## Integration

- `docs/runtime/program-phases.md` — Phase 1 (deep inventory) uses this taxonomy
- `docs/runtime/analysis-contexts.md` — contexts map to surfaces
- `docs/runtime/artefact-contract.md` — `inventory.md` is the home for the inventory output
- `.claude/agents/cartographer.md` — the specialist that walks surfaces
