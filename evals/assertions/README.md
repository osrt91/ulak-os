# Assertions

The eval harness uses structured assertions to check director and specialist output against golden examples under `evals/golden/`.

## Files

- [core-assertions.md](./core-assertions.md) — assertion types, resolution values, and regression signals

## Assertion shape

Every assertion carries at least:

- `type` — one of the types defined in `core-assertions.md`
- `target` or `field` — what is being checked
- `expected` — what the right answer looks like
- `description` — human-readable purpose

Golden examples reference assertion types in their "must include / must not include / validation criteria" sections.

## Baseline assertions across every run

Independently of the specific golden example, every director run must satisfy:

1. **No menu loop after explicit full intent.** When the user says "komple" or equivalent, the router completes from phrasing alone.
2. **Immediate artefact creation on clear intent.** Phase 0 artefacts (runtime-manifest, assumptions) must exist before any specialist runs.
3. **One manager verdict per run.** Not two, not zero. Exactly one.
4. **Customer / admin / public API separation when relevant.** When the project has these surfaces, they must be addressed separately.
5. **Evidence-first language.** Every non-trivial claim carries a file:line or URL reference with a trust tier.
6. **Pack-gap register maintained.** Even if nothing is missing, the artefact exists with "no gaps found".
7. **did-you-know non-trivial.** The surprise layer is not optional.
8. **Router decision committed before Phase 1.** No phase-1 work without a pinned router decision.
9. **Trust tier on every finding.** finding-schema.md conformance.
10. **Signoff status honest.** No `ready` with unresolved Critical findings.

## Running the evals

The eval harness implementation (TypeScript CLI under `cli/`) is responsible for:

1. Parsing each golden example
2. Running the director against the user request (or a recorded transcript)
3. Checking each assertion
4. Emitting `evals/results/*.md` with pass / fail / partial / not-applicable per assertion
5. Writing `evals/regressions/*.md` when a regression signal fires

See `core-assertions.md` for the assertion vocabulary.
