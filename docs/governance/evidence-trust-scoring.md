# Evidence Trust Scoring

## Why this exists

Not all evidence is equal. A line in a vendor marketing page, a line in the repo source, and a line in a user review deserve different confidence levels. Without tiering, the system can make high-confidence claims on low-trust evidence, which corrodes the manager-verdict and turns did-you-know into a guessing game.

## Trust tiers

| Tier | Source | Examples | When to use |
|---|---|---|---|
| **T1** | Official primary source | Anthropic docs, Apple HIG, Flutter docs, RFC, upstream framework docs | Architecture currency, platform compliance, SDK requirements |
| **T2** | Repo source of truth | Source code, config files, migrations, CI workflows, Dockerfiles in the audited project | Anything about *this* project's actual behavior |
| **T3** | Production / staging telemetry | Real logs, crash reports, analytics, APM traces | Performance, error rates, user behavior claims |
| **T4** | Direct user-provided artifact | Screenshots, zip bundles, briefs, tickets the user shared | Intent, constraints, historical context |
| **T5** | Reputable secondary source | Vendor blog posts, maintainer notes on official channels, well-known security advisories | Recent updates, known issues |
| **T6** | Community / forum / reviews | Stack Overflow, GitHub discussions, Reddit, app store reviews | Common pain points, community conventions |
| **T7** | AI-inferred / awaiting validation | Claude's own inference, LLM-generated summaries not yet checked | Hypothesis, needs validation before any hard claim |

## Default ordering rule

When two sources conflict, trust the lower-tier number (T1 beats T2 beats T3 ...). Never use T6 or T7 to override T1-T3.

## Fields every serious finding must carry

When a specialist or the director writes a finding, it must carry at least:

- `evidence_source` — file path, URL, log reference, screenshot name
- `evidence_trust` — T1 through T7
- `completeness_risk` — low | medium | high (how confident are we the evidence is *complete*, not just valid)
- `contradiction_status` — none | partial | direct (is another source disagreeing)

If these fields are missing, the finding is rejected and must be re-derived.

## Hard rules

- **Never claim high certainty from T6 or T7 evidence.** Mark it as hypothesis.
- **Never fold T1 into the same bucket as T5.** A vendor's own docs are not the same as a blog post about them.
- **When repo (T2) contradicts a blog (T5), trust the repo.** Record the contradiction in the finding.
- **When a marketing page (T5) contradicts the upstream RFC (T1), trust the RFC.**
- **AI-generated notes (T7) that survive user validation get promoted to T4**, not to T2 or T3 — they remain provided by a party, not extracted from source.

## Integration with the director

The autonomous-program-director's Phase 2 (parallel specialist deep-scan) must:

1. Require each specialist to emit findings with the trust fields above.
2. Reject or re-run any specialist whose output contains claims without `evidence_trust`.
3. In Phase 5 (manager-verdict), weight residual risks by the lowest trust tier present in the supporting evidence.

## Integration with did-you-know

The did-you-know layer is a surprise surface. It *can* include T5-T7 findings, but each such finding must be labeled as a hypothesis and paired with a validation step. Never present a T7 finding as a confirmed issue.
