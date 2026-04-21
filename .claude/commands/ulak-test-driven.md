---
name: ulak-test-driven
description: Belirli bir feature veya bugfix için TDD workflow. Önce kırık testi yazar, geçirecek şekilde uygular, sonra refactor eder — superpowers:test-driven-development disiplini ile zorunlu tutulur. Ulak OS evals entegrasyonu ile sarar (cross-project-relevant ise test golden set'e eklenir). Ship edilecek herhangi bir feature implementation veya bug fix için kullan; atılabilir deneyler için değil.
description_en: TDD workflow for a specific feature or bugfix. Writes the failing test first, implements to make it pass, then refactors — enforced via superpowers:test-driven-development discipline. Wraps with Ulak OS evals integration (test added to golden set if cross-project-relevant). Use for any feature implementation or bug fix that will ship; not for throwaway experiments.
agent: autonomous-program-director
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# /ulak-test-driven — Red-Green-Refactor with Ulak OS integration

## When to use

- Implementing a new feature that will ship to users
- Fixing a bug that has reproduced (freeze the repro as a test before fixing)
- Any change to a surface that has existing tests (don't let coverage regress)
- Payment / auth / RLS / webhook surfaces (regression risk is high)

## When NOT to use

- Pure refactor where behavior is strictly preserved (tests already guard it)
- Exploratory spike where the interface is not yet known (use `/ulak-brainstorm` first)
- Documentation-only changes

## Dispatch protocol

Invokes `superpowers:test-driven-development` with the Ulak OS extensions:

### Red phase

1. Identify the smallest test that would demonstrate the feature / repro the bug
2. Write it in the appropriate suite (`tests/unit/`, `tests/integration/`, `evals/`)
3. Run it — must fail
4. Commit the red test with message `test: red — <description>`

### Green phase

5. Implement the minimum change that makes the test pass
6. Run the full test suite — the red test must now pass, no other test may regress
7. Commit the green implementation with message `feat: green — <description>` or `fix: green — <description>`

### Refactor phase

8. With green tests as safety net, refactor for clarity / performance / deduplication
9. Run tests after every refactor step; never lose green
10. Commit refactors as `refactor: <description>`

### Integration phase

11. If the test is cross-project-relevant (bug-pattern observable elsewhere, common anti-pattern being caught), promote to `evals/golden/` as a regression gate for future Ulak OS runs
12. Update `docs/runtime/anti-patterns.md` if a new AP surfaces

## Output shape

- Commits: red → green → refactor in order
- `evals/golden/<new-test>.md` if promoted (cross-project)
- `docs/runtime/anti-patterns.md` AP-NN entry if bug-class is generic
- `reports/current/tdd-log.md` — per-cycle summary

## Integration

- `superpowers:test-driven-development` — the skill
- `evals/run.sh` — golden-set runner (currently warn-only; will block in v1.2+)
- `scripts/validate-schemas.sh --strict` — runs before every green commit
- `.claude/agents/qa-validation-commander.md` — specialist that audits TDD discipline in `/director komple`

## Hard rules

- Never commit a feature without a test
- Never skip red (implementing first then "adding tests" is retrofit, not TDD)
- Never refactor while tests are red
- Never stack multiple features into one red→green cycle

## Example

```
/ulak-test-driven feature="Stripe webhook idempotency via event_id"
```

Produces:
1. Commit: `test: red — Stripe duplicate event_id should be no-op`
2. Commit: `feat: green — processed_webhook_events insert with ON CONFLICT DO NOTHING`
3. Commit: `refactor: extract idempotency check into shared payments/dedup.ts`
