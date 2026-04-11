# Sector Pack Architecture

## Why this exists

"Cover every sector" is a trap. If Ulak OS tries to encode education, fintech, ecommerce, marketplace, enterprise B2B, media, healthcare, and AI copilot knowledge into one always-loaded core, the core becomes unreadable and the context budget collapses. Sector packs solve this by **isolating domain-specific knowledge into overlays that load only when the router activates them**.

A sector pack is not a complete prompt. It's a set of **domain-specific expectations, risk patterns, UX conventions, pricing norms, compliance concerns, and anti-patterns** that the core runtime uses to refine its analysis for a specific industry.

## Core kernel (always loaded)

These are part of the public runtime surface and load every session regardless of sector:

- Router decision contract
- Context budget rules
- Evidence rules (trust scoring, finding schema, trust model)
- Output profiles
- Validation principles
- Claude Code runtime topology
- Language / locale strategy motor
- Architecture currency protocol
- Market research engine (rules for how to use it)
- Intervention modes and project state
- Artefact chain and program phases

The core kernel is **sector-agnostic**. It does not know whether the project is edtech or fintech.

## Optional sector packs

These load only when the router explicitly activates them via `router.required_sector_packs`:

### `education`
Focus areas:
- Study flow continuity (session entry, question reading, answer reveal, explanation, retry, summary, return-later)
- Explanation UX (hierarchy, readability, confidence-building)
- Confidence language (avoid shame, encourage retry)
- Retention without pressure
- Minors sensitivity (data handling, parental controls, COPPA/KVKK minor rules)
- Question-solving UX (iOS-first premium calmness)
- Progress visualization
- Leaderboard ceremony without cheap gamification

### `saas`
Focus areas:
- Onboarding and activation flow
- Role separation (admin / operator / viewer / end-user)
- Settings ergonomics
- Subscription management
- Admin vs customer split rigor
- Analytics taxonomy
- Multi-tenant isolation

### `fintech`
Focus areas:
- KYC / AML flow
- Consent and disclosure hygiene
- Step-up authentication
- Audit trail completeness
- Storage and privacy for financial data
- Regulatory reporting surfaces
- Operational risk (4-eyes principle on dangerous actions)
- PCI scope minimization

### `ecommerce`
Focus areas:
- Discovery (search, filter, sort, faceted browse)
- PDP (product detail page) hierarchy
- Cart continuity across devices
- Checkout simplicity
- Returns / trust signals
- Search relevance and ranking
- Fraud prevention
- Inventory vs availability surface

### `marketplace`
Focus areas:
- Buyer / seller / admin permission split
- Fraud and abuse patterns (fake listings, chargebacks, credential stuffing)
- Moderation workflows
- Dispute resolution
- Search ranking fairness
- Trust and safety signals
- Payout surfaces

### `enterprise-b2b`
Focus areas:
- SSO / SAML / OIDC
- SCIM provisioning
- Tenant / workspace isolation
- Audit logs with retention
- Approval workflows
- Access review cadence
- Data residency
- Legal review surfaces

### `media-content`
Focus areas:
- Content discovery
- Subscription / paywall models
- Ad surfaces vs subscriber surfaces
- Recommendation quality
- Moderation (user-generated vs editorial)
- DMCA / takedown workflows
- Caching and CDN strategy

### `health-sensitive`
Focus areas:
- PII / PHI handling
- Consent and disclosure
- Minors sensitivity
- Medical disclaimers
- Regulatory jurisdiction (HIPAA / GDPR / KVKK)
- Data retention / deletion
- Access audit

### `ai-copilot`
Focus areas:
- Prompt UX (clarity, examples, undo)
- Grounding (where is the model's answer coming from)
- Hallucination handling (confidence display, verification prompts)
- Tool transparency (show tool calls or summarize)
- Memory boundaries (what persists, what doesn't)
- Refusal design (when and how to say no)
- Training data provenance disclosures

### `pwa-desktop`
Focus areas:
- Install flow
- Offline support
- File system access
- Keyboard / mouse / trackpad ergonomics
- Multi-window behavior
- Desktop-like command surfaces
- Multi-pane layouts

## Activation rules

A sector pack loads only when **ALL** of these are true:

1. The user's request, project content, or router decision clearly implicates the sector
2. The router assigns the pack to `required_sector_packs`
3. The context budget permits the additional load (see `docs/runtime/context-budget.md`)

If the pack's domain is only loosely relevant, do **not** load it. Use the core kernel's general rules.

Examples:
- "Help me redesign this education app" → load `education`
- "Build a subscription SaaS onboarding" → load `saas`
- "This is a marketplace with sellers and buyers" → load `marketplace`
- "General code review of a utility library" → load NONE (core kernel is enough)

## Multi-pack activation

A project can activate multiple packs when it genuinely spans sectors. Examples:

- An education SaaS → `education` + `saas`
- A fintech marketplace → `fintech` + `marketplace`
- A B2B ecommerce → `ecommerce` + `enterprise-b2b`

When multiple packs apply, the rules do NOT conflict by default — they stack. If two packs actually contradict (e.g., one says "minimize onboarding friction", another says "require KYC"), the router must record the conflict and pick the precedence based on the rule collision matrix.

## Hard rules

- **Never load all packs at once.** The router picks.
- **Never treat a pack as a complete prompt.** Packs enrich the core; they do not replace it.
- **Never activate a pack on weak signal.** If the user says "build something for schools", that might be education — but confirm the actual product first.
- **Never hardcode sector assumptions into the core kernel.** If a rule belongs only to fintech, it belongs in the fintech pack.
- **Never let packs duplicate each other.** If two packs have the same rule, promote it to the core kernel.

## Integration

- `docs/runtime/router.md` — router picks which packs to activate
- `docs/runtime/context-budget.md` — packs are Layer 7 (sector packs)
- `docs/runtime/output-profiles.md` — some profiles imply specific packs (LOCALIZATION_REPAIR_PROFILE + `education` pack = study-focused localization review)
