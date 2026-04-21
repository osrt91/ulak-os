# Dual-Path Validation (Phase 3 Enhanced)

## Why this exists

The director's Phase 3 produces `did-you-know.md` — the surprise layer of non-obvious findings. By design, Phase 3 is *one subagent's* interpretation of the evidence register. That produces 15-25 good findings on a typical run, but it has a blind spot: **what would a second independent reviewer catch that this specific subagent missed?**

On the session (2026-04-11), the operator improvised a second path: while the director ran Phase 3, the operator was independently preparing their own non-obvious findings list (stale CLAUDE.md claims, cartographer-flagged inconsistencies). The two lists were then merged. The overlap was **T1 consensus**; the divergence was **new signal**.

Dual-path validation formalizes this pattern as an optional Phase 3 enhancement.

## When to use

- High-stakes runs (production systems, compliance surfaces, security-critical projects)
- Runs where the cost of missing a non-obvious finding is high
- Runs where a second reviewer (human or agent) is available to work in parallel
- Repeat runs where the prior session's `did-you-know.md` can serve as a baseline

**Do not use** dual-path for:

- Fast iteration or exploratory runs
- Runs where only one reviewer is available
- Runs where the context budget is already constrained

## The pattern

### Path A — Director-generated (mandatory)

The standard Phase 3:

1. Subagent reads `evidence-register.md` and the synthesis context
2. Subagent extracts non-obvious findings per the Phase 3 prompt
3. Subagent writes `reports/current/did-you-know.md`

This is the baseline and must always run.

### Path B — Independent reviewer (optional, concurrent)

While Path A runs, a second reviewer (either a parallel subagent with a different prompt, or the operator themselves, or an external specialist) produces their own non-obvious findings list independently.

The Path B reviewer:

- Reads the same `evidence-register.md` (same inputs)
- Does NOT read Path A's output before completing
- Follows a different lens than Path A — e.g., "read the code as if looking for what's missing" vs "read the code as if looking for what's wrong"
- Writes `reports/current/did-you-know-path-b.md` with the same shape as Path A

### Merge — consensus + divergence

After both paths complete, a merge pass produces the final `did-you-know.md`:

| Category | Rule | Tier effect |
|---|---|---|
| **Both paths found it** | Keep in final list | Trust tier **promoted** (T2 → T1, T3 → T2). Two independent observers = consensus. |
| **Only Path A found it** | Keep in final list | Tier unchanged. Mark `source: director` for traceability. |
| **Only Path B found it** | Keep in final list | Tier unchanged. Mark `source: independent-reviewer` for traceability. |
| **Contradictory findings** | Keep BOTH, flag for probe | Neither is promoted. The contradiction itself is a new finding. May trigger Phase 4.5 probe to resolve. |

The merged `did-you-know.md` carries a frontmatter field:

```yaml
dual_path: true
path_a_source: director-phase-3
path_b_source: operator-manual | parallel-subagent-<name>
overlap_count: 7 # findings both paths agreed on
path_a_unique: 12 # findings only Path A found
path_b_unique: 5 # findings only Path B found
contradictions: 2 # conflicts sent to probe
```

## The merged-and-promoted claim

A finding that both paths found gets **tier promotion**:

```yaml
- id: DYK-001
 title: "admin SEO panel writes to a table no generateMetadata reads"
 evidence: "src/app/admin/seo/page.tsx:1-236 + grep(getSeoMetadata) = 1 match (definition only)"
 trust: T1 # promoted from T2 because dual-path consensus
 trust_history:
 - path: A (director)
 tier: T2
 reasoning: "grep found definition, no callers — inferred no consumer"
 - path: B (operator-manual)
 tier: T2
 reasoning: "manually traced the import graph, no generateMetadata reference"
 - merged: T1
 reasoning: "two independent traces confirmed. Consensus promotes to T1."
```

This is a direct application of `docs/governance/evidence-trust-scoring.md` + the UOI-04 principle (specialist overlap is a feature).

## Path B prompt guidance

When Path B is a parallel subagent (not a human), give it a DIFFERENT framing from Path A to maximize divergence. Examples of lens diversity:

| Path A lens | Path B lens |
|---|---|
| "what's broken" | "what's missing" |
| "what violates a rule" | "what the rule itself doesn't cover" |
| "what a normal review would find" | "what a paranoid review would find" |
| "what the code says" | "what the code assumes but doesn't enforce" |
| "what the user asked about" | "what the user did not ask about" |
| "severity-ranked by blast radius" | "severity-ranked by likelihood of occurrence" |

The Path B subagent must not see Path A's output until the merge step.

## Anti-patterns

- **Running both paths with the same prompt** — they will converge and waste compute. The lens must differ.
- **Letting Path B read Path A's output first** — contaminates the independence, collapses dual-path into "confirm bias".
- **Merging without a traceability field** — the merged list loses the information about which path found what, which breaks retroactive debugging.
- **Promoting T6/T7 evidence to T1 via dual-path** — dual-path consensus does NOT magically upgrade community or AI-inferred evidence. It only promotes T2/T3 → T1 on the back of two *direct* traces.
- **Treating contradictions as "average of the two"** — contradictions are new findings, not compromises. Probe them.

## Integration

- `docs/runtime/program-phases.md` — Phase 3 section notes dual-path as an optional enhancement
- `docs/governance/evidence-trust-scoring.md` — dual-path consensus is a defined tier promotion path
- `docs/runtime/output-profiles.md` — audit and rescue profiles may require dual-path for critical surfaces
- `docs/runtime/live-probe-contract.md` — contradictions from dual-path become probe candidates

## Future — `dual-path-phase-3` command

A `/director --dual-path` flag (or a `/dual-path-validate` standalone command) could automate Path B dispatch. Not implemented yet. Until then, dual-path is operator-driven: the operator runs `/director komple` for Path A, and manually (or via a custom prompt) runs Path B in parallel, then merges.

## Origin

This pattern was observed in the 2026-04-11 session. While the director ran Phase 3, the operator was independently preparing a non-obvious findings list. The improvised merge caught 2 findings the director had missed (stale CLAUDE.md claim, cartographer-flagged inconsistencies). Neither path alone would have surfaced both. Dual-path is the formal version of that improvisation.
