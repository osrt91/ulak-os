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

## Tier promotion mechanism

A claim's trust tier can move between tiers **only when new evidence arrives**. There is no "time passes, tier upgrades" rule — a T3 inference does not become a T2 fact without someone actually doing the work.

### Allowed promotions (stronger confidence)

| From | To | Trigger |
|---|---|---|
| T7 (AI-inferred, unvalidated) | T4 (user-provided artifact) | Operator validates the inference and confirms it |
| T6 (community / forum) | T5 (reputable secondary source) | A reputable source independently confirms |
| T5 (reputable secondary) | T1 (official primary) | Upstream vendor docs confirm the claim |
| T3 (production telemetry, indirect) | T2 (repo source of truth) | A grep or read surfaces the explicit code path |
| T3 (inferred from behavior) | T2 (repo source of truth) | The file is read and the mechanism confirmed |
| T2 (repo source of truth) | T1 (official primary) | The mechanism is verified against upstream documentation |
| T2 / T1 | **T0 (runtime observed)** | A Phase 4.5 live probe directly observed the runtime state |

Live-probe results (Phase 4.5) are the **only path to T0**. A T1 claim remains T1 until a probe observes the live state, at which point it upgrades to T0. This is the highest-confidence tier.

### Regressions (weaker confidence)

A claim can drop from Tx to Tx+1 when:

- New evidence **contradicts** it (the file was changed, the upstream doc was updated, the live state diverged)
- The file it cites was **deleted or moved**
- A live probe **refuted** the static claim
- Time has passed AND the claim depends on a live state that may have drifted (T0 → T2 after > 24h without re-probe)

Regressions must be logged in `evidence-register.md` with a timestamp, a link to the superseding evidence, and a note about what the regression means for any downstream finding that cited the old tier.

### Consensus promotions (dual-path)

When two independent observers (e.g., two specialists, or Path A + Path B of dual-path validation per `docs/runtime/dual-path-validation.md`) agree on the same claim via **different evidence traces**, the claim's tier is promoted one level:

- T3 + T3 → T2 (two independent inferences become a confirmed fact)
- T2 + T2 → T1 (two independent repo reads reach consensus)

This promotion is **one level only per run**. It is not transitive — three specialists agreeing does not promote twice. The consensus credit is in the diversity of the evidence paths, not the count.

### Hard rule

**Tier promotion without new evidence is fraud.** Never upgrade a claim's tier because "we've been running it for a while and it seems to work". Either find new evidence or accept the existing tier.

## Integration with Phase 4.5 live probe

The live-probe contract (`docs/runtime/live-probe-contract.md`) enforces this promotion mechanism:

- Every probe that confirms a prior T2/T3 claim promotes it to T1 or T0 (depending on whether the probe was a read of the source or an observation of runtime state)
- Every probe that refutes a prior claim drops its tier to `contradicted` and triggers a finding rewrite
- New findings that only exist because of the probe (NF-* entries) start at T0 (the probe observed them) and can never be demoted without a later contradicting probe
