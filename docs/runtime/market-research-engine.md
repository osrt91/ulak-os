# Market Research Engine

## Why this exists

"Position this product" and "price this feature" and "should we add German?" are questions the model cannot answer from memory. They require live market data: current competitor pricing, current store reviews, current language opportunity, current feature expectations. Without a market research engine, the director hallucinates positioning and the user gets a plan built on 2023 assumptions.

The market research engine defines *when* live research is required, *what* sources to trust, and *what outputs* it must produce.

## When it's required

Live market research is **required** (not optional) when the task involves:

- New product positioning
- Entering a new sector
- Entering a new country or locale (add a market, not just a language)
- Pricing or packaging decisions (paywall, tiers, subscription vs one-time)
- Competitor positioning (how does X compare to Y)
- Landing or store listing copy for a new audience
- Subscription / conversion funnel design
- Feature prioritization for a new audience

Live market research is **helpful** when the task involves:

- Refining copy for an existing audience
- Updating store screenshots
- Benchmarking Core Web Vitals or app metrics against category norms

Live market research is **not needed** when the task is purely internal: refactoring, test coverage, security hardening of existing code, infra migration with no user-facing changes.

The router picks the correct `live_research_need` value in Phase 0. See `docs/runtime/router.md`.

## Sources to consult (in trust order)

### T1 — official primary sources
- The competitor's own product pages
- The competitor's own store listings (App Store, Google Play, web store)
- The competitor's own pricing pages
- Platform-official category data (App Store / Play category rankings, Google Trends)
- Government / regulatory sources for compliance-relevant data

### T3 — production telemetry (if accessible)
- Analytics dashboards for the product being positioned
- Existing A/B test results
- Internal conversion / retention data

### T5 — reputable secondary sources
- Well-known industry reports (Gartner, Forrester, IDC, Statista)
- Published research papers
- Vendor white papers from credible sources
- Conference talks with data

### T6 — community / reviews / forums
- App store reviews (read as signal about pain points, not truth about product)
- Reddit, Hacker News, forum threads
- G2, Capterra, TrustRadius (with bias awareness)
- Social media discussions

Do not use T6 as sole evidence for a positioning claim. T6 is great for pain-point extraction, terrible for feature comparison.

## Mandatory questions

For any serious market research pass, answer:

1. **What is the user searching for?** (primary jobs-to-be-done)
2. **What are the top 3-5 competitors doing well?** With specific examples and citations.
3. **What are they doing badly?** With pain-point clusters from reviews.
4. **What language / locale are they operating in?** Which markets are underserved?
5. **What are the trust signals in this category?** (certifications, testimonials, security badges, case studies)
6. **How do they price?** Tier structure, anchor price, free tier, trial length.
7. **Which features are must-have vs differentiators vs nice-to-have?**
8. **Which markets have which locale / cultural expectations?**

## Required output artefacts

A market research pass produces at least these, under `reports/current/`:

### `market-summary.md`
High-level overview of the category, tier-by-tier competitor breakdown, major trends, T1 and T5 citations.

### `competitor-map.md`
One block per competitor:

```yaml
- name: ""
 tier: leader|challenger|niche|emerging
 pricing: ""
 target_audience: ""
 strongest_features: []
 weakest_features: []
 review_sentiment: "" # from T6 with bias note
 source_list:
 - url: ""
 trust: T1|T5|T6
```

### `pricing-map.md`
Side-by-side pricing table, anchor prices, regional variations, free tier shapes.

### `feature-expectation-map.md`
Categorized list of features the market treats as must-have, as differentiators, as optional, as legacy.

### `review-pain-point-clusters.md`
From T6 reviews, clustered pain points. Each cluster carries a trust note (T6) and a count of mentions. Do NOT treat counts as statistics — they're signal, not proof.

### `language-opportunity-map.md`
See `docs/runtime/localization-strategy.md` Phase 3 — labels each candidate locale ADD_NOW / ADD_NEXT_WAVE / PILOT_ONLY / DO_NOT_ADD_YET.

### `positioning-gaps.md`
Where the project could differentiate — feature gaps, pricing gaps, trust gaps, language gaps, ecosystem gaps.

### `market-current-recommendations.md`
Concrete recommendations tied to the research, each with:
- recommendation
- supporting evidence (with trust tiers)
- risk if wrong
- validation step

## Hard rules

- **Do not reduce market research to a list of competitors.** A list is a starting point, not the output.
- **Do not use T6 evidence for factual product claims.** Use it for pain-point signal.
- **Do not cite "users say" without linking to specific sources.**
- **Do not recommend a pricing strategy without a pricing-map.**
- **Do not recommend a locale without a language-opportunity-map.**
- **Do not claim "the market is moving toward X" without T1 or T5 evidence.**
- **Do not copy competitor claims uncritically.** Competitors lie on their own product pages.

## Integration

- `docs/runtime/router.md` — Phase 0 decides whether live research is required
- `docs/runtime/output-profiles.md` — MARKET_ENTRY_PROFILE required sections
- `.claude/agents/market-researcher.md` — the specialist that runs this motor
- `docs/governance/evidence-trust-scoring.md` — trust tiers for every source
