# tests/ — test surface orientation

This directory exists as a placeholder for **unit + integration + e2e tests of the Ulak OS repository itself**. At the time of v1.0.0 public GA it is largely empty; Ulak OS's regression coverage lives under [`evals/`](../evals/) (golden-set prompt replays + assertion catalog).

## Where tests actually live today

| Surface | Location | What it covers |
|---|---|---|
| **Prompt regression** | [`../evals/golden/`](../evals/golden/) | Five golden prompts replayed against `/director komple` each CI run — full-program, greenfield, brownfield, localization, frontend rebuild |
| **Prompt assertions** | [`../evals/assertions/core-assertions.md`](../evals/assertions/core-assertions.md) | Machine-checkable gates that every golden run must satisfy (deep-inventory present, did-you-know non-trivial, validation-plan has ≥1 probe, …) |
| **Eval runner** | [`../evals/run.sh`](../evals/run.sh) | Entry point for CI; currently warn-only pending v1.0.1 promotion to blocking gate |
| **Scaffolded-project tests** | [`../templates/saas-starter/tests/`](../templates/saas-starter/tests/) | Baseline Vitest unit test + Playwright e2e — these ship **inside every scaffolded project**, not against this repo |
| **Validator scripts** | [`../scripts/validate-*.sh`](../scripts/) | Structural checks (import graph, schema conformance, vendor parity) — run by `ulak doctor` + CI |

## Why the `tests/` directory is empty

Ulak OS is a **prompt operating system**, not a library of callable functions. Traditional unit tests (arrange/act/assert against a function) apply only to the narrow `src/` TypeScript CLI surface — and that is tracked separately for the post-GA v1.1 CLI rewrite.

The meaningful regression surface for this repository is:

- **Does `/director komple` still produce the 15 artefact chain with trust-tiered findings?** → evals/
- **Does the @-import graph still parse without cycles?** → `scripts/validate-imports.sh`
- **Do the canonical JSON surfaces still conform to their schemas?** → `scripts/validate-schemas.sh`
- **Do the vendor adapters declare every flagship command?** → `scripts/validate-vendor-parity.sh`
- **Do scaffolded projects still pass their own baseline tests?** → scaffolder templates themselves

None of these belong as classical unit tests in `tests/`. When v1.1 introduces the Node/Python CLI rewrite and real callable functions land in `src/`, this directory populates accordingly with `tests/unit/` and `tests/integration/`.

## When to add a file here

Add to `tests/` only when:

1. A new callable function or class lives in `src/` that warrants a traditional unit test (post-v1.0.1)
2. A cross-cutting integration scenario (e.g., CLI subprocess dispatch to `claude`, `codex`, `gemini`) needs assertion coverage that evals don't give
3. A specific regression (bug reproducer) needs to be frozen as a test before the fix ships

Otherwise, contributions belong under `evals/` (prompt-level regression) or `scripts/validate-*.sh` (structural invariant).

## Not to be confused with

- `../templates/saas-starter/tests/` — tests that ship **inside** a scaffolded project (Vitest unit + Playwright e2e, templated)
- `../evals/` — golden-prompt replay harness (the actual Ulak OS regression surface)

## Canonical footer

Authoritative as of Ulak OS **v1.0.1**. Resolves cartography finding CART-004 (empty `tests/` dir confuses contributors). Re-evaluate when v1.1 CLI rewrite lands.
