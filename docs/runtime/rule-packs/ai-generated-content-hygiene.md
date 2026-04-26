# Rule Pack — AI-Generated Content Hygiene

Activated when runtime-manifest detects (a) public-facing content surfaces (`docs/marketing/blog/`, `content/`, `cms/`, MDX collections), (b) JSON-LD schema markup in shipped HTML, OR (c) any AI assistant in the operator's known toolchain (Claude / Gemini / GPT / Groq) used to draft content. Sibling to `localization-ssot.md` and `multi-locale-eleven-rtl.md` — content quality is a localization concern when shipped per-locale.

Pattern source: `docs/governance/pattern-import-ledger.md` IL-012 (security/QA scanner SaaS, T1 evidence — 5 blog posts had Gemini conversational artefacts and broken Schema.org JSON-LD shipped to production).

## Why this exists

AI tools (Claude, Gemini, GPT) leak two categories of artefact into shipped content when humans do not strictly post-process:

1. **Conversational artefacts** — the AI's own framing speech ("Of course!", "Here is your...", "I hope this helps", "Let me know if you need adjustments", chain-of-thought asides, "as an AI language model", "Certainly! Below is..."). These are visible to readers, signal AI authorship, hurt trust + SEO.
2. **Structured-data corruption** — AI-generated JSON-LD / Schema.org / OpenGraph blocks with invalid syntax (trailing commas, mismatched quotes, hallucinated `@type` values, missing required fields). These break Google Rich Results, AI citation engines, and validators silently.

Both categories shipped to production = a finding. This pack codifies the detection + cleanup contract.

## Imperatives

### Conversational artefact detection

CI must scan all shipped content (`docs/marketing/blog/**/*.md`, `content/**/*.mdx`, `cms/**` rendered output) for the following phrases — case-insensitive, word-boundary:

#### English markers
- `Of course!` / `Of course,` / `Certainly!` / `Certainly,` (sentence-initial)
- `Here is` / `Here's the` / `Here you go` (when followed by content noun)
- `I hope this helps` / `Hope this helps` / `Let me know if`
- `as an AI` / `as a language model` / `I am an AI`
- `Below is` / `Below you'll find` (sentence-initial, except in deliberate doc style)
- `Sure!` / `Absolutely!` (sentence-initial)
- `[your X here]` / `[insert X]` / `<your-x>` (placeholder leakage)
- `Note:` followed by AI-tone justification ("Note: this is a generic template, please adapt")

#### Turkish markers
- `Tabii ki` / `Elbette` (cümle başı, AI kibar tonunda)
- `İşte size` / `İşte aşağıda` (içerik sunum kalıbı)
- `Umarım yardımcı olur` / `Yardımcı olduğumu umarım`
- `Bir AI olarak` / `Bir dil modeli olarak`
- `Aşağıda bulabilirsiniz` (cümle başı, AI tonu)
- `Lütfen ihtiyacınıza göre uyarlayın` (template warning leak)
- `[buraya X]` / `<X-buraya>` (placeholder leak)

#### Other locales
For each locale in `SUPPORTED_LOCALES`, maintain a per-locale marker list at `config/ai-content-markers/<locale>.json`. New locales must seed this list before publishing AI-assisted content.

### Schema.org / JSON-LD validation

Every page shipping JSON-LD MUST:

- Pass `schema.org` validator (online or via `npx structured-data-testing-tool`) in CI
- Use known `@type` values only — AI hallucinates types like `BlogPostingArticle`, `RecipeGuide`, `ProductReviewBlog` that don't exist
- Include all REQUIRED fields per `@type` (Article requires `headline` + `author` + `datePublished`; Product requires `name` + `image` + `offers` etc.)
- No trailing commas in inline JSON-LD `<script type="application/ld+json">` (browsers tolerate, validators reject)
- Match the rendered content — `headline` in JSON-LD must equal `<h1>` text; mismatched JSON-LD = adversarial Schema spam, Google penalty risk

CI gate: `scripts/validate-schema-jsonld.sh` parses every `<script type="application/ld+json">` block, validates against schema.org definitions, fails the build on:
- JSON parse error
- Unknown `@type`
- Missing required fields
- `headline` ≠ rendered `<h1>` (with locale-aware normalize)

### Content provenance metadata

Every AI-assisted content file MUST declare provenance in front-matter:

```yaml
---
title: "..."
author: "Editor Name (human reviewer)"
ai_assisted: true
ai_tool: "claude-opus-4.7"     # explicit tool + version
draft_date: 2026-04-24
review_date: 2026-04-26          # human review completion
review_passes: 2                  # number of edit cycles
artefact_scan: passed             # AI-marker scan result
schema_validated: passed          # JSON-LD validator result
---
```

This is **not** "watermark every AI-touched line" theatre — it's audit-trail discipline. When a content quality issue surfaces post-publish, the provenance metadata makes triage immediate (which AI, what version, who reviewed, when).

### Editorial review gate

- AI-drafted content MUST pass at least one human editorial pass before publish — diff must show **substantive** edits (not just typo fixes)
- Editor signs off via the `review_date` field in front-matter — empty `review_date` = blocked from publish
- For high-stakes surfaces (legal, privacy, medical, financial advice): two human reviewers required, second reviewer adds `peer_reviewer:` field

### AI tool prompt templates (operator-side discipline)

When prompting AI tools to draft public content, prefix:
- "Do NOT include conversational framing ('Of course', 'Here is', etc.). Output the content directly."
- "Do NOT include placeholder text like '[your name here]' — leave fields empty if unknown."
- "If generating JSON-LD, validate against the schema.org spec; do not invent `@type` values."
- "Do NOT include 'as an AI' disclaimers."

Operator templates live in `docs/templates/ai-content-prompts/` — reused across content sprints.

### Locale-specific tone

- AI tools default to American English politeness ("I'd love to help!"); when the target locale is Turkish formal business tone, this leaks. Per-locale tone guidelines in `docs/templates/locale-tone/<locale>.md`.
- Machine-translated AI output: layered risk — AI-drafted in English then translated by another AI = double leak. Scan markers in both source AND target language.

### Detection of structural staleness

AI tools sometimes produce dated content silently — "according to recent studies" with no date, "as of 2024" when the AI's training data is older. Quarterly scan:
- `grep -rE "as of (2020|2021|2022|2023|2024)" content/` — flag for review
- "recent studies show" / "in recent years" without explicit citation — manual review
- Pricing claims, market size claims, regulatory deadlines — must have a citation with date

## Validator rules (CI-blocking)

- `scripts/validate-ai-content-markers.sh` — greps every locale-specific marker against shipped content; fails on any hit not in allowlist
- `scripts/validate-schema-jsonld.sh` — parses + validates every JSON-LD block; fails on schema violation
- `scripts/validate-content-provenance.sh` — every file under `content/` / `docs/marketing/blog/` has front-matter with `ai_assisted` field; if `true`, requires `ai_tool` + `review_date`
- `scripts/validate-content-staleness.sh` — quarterly cron job, opens issues for stale claims

## Collision rule

Project `.claude/rules/content-hygiene.md` overrides specific markers (a project may legitimately use "Of course" in conversational FAQ format); unmatched inherit. Per-locale marker lists are extension points, not overrides.

## Integration

- `docs/runtime/rule-packs/multi-locale-eleven-rtl.md` — when content ships per-locale, both packs apply
- `docs/runtime/rule-packs/localization-ssot.md` — content keys flow through SSOT
- `docs/runtime/anti-patterns.md` AP-29 — codifies the AI artefact leak as a numbered anti-pattern with examples
- `docs/governance/ai-provider-allowlist.md` — declares which AI tools may produce content in this project (cross-reference)
- `docs/governance/pattern-import-ledger.md` IL-012 — provenance

## Canonical footer

Authoritative as of Ulak OS **v1.7.0**. Imported from a security/QA scanner SaaS where 5 production blog posts shipped Gemini conversational artefacts and broken Schema.org JSON-LD before detection (2026-04-26 absorption pass #2, commit `e601aaf`-class). The cross-locale marker lists + JSON-LD validation gate is the load-bearing contribution.
