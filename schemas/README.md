# schemas/ — vendored JSON schemas

This directory holds local copies of the JSON schemas that Ulak OS JSON files declare via `$schema`. Vendoring removes the CI-time network dependency and closes two security surfaces:

1. **Supply-chain**: a compromised upstream schema host could return malicious validation rules (or equivalent: no rules) without any local signal. Pinning + hash-checking prevents that.
2. **Silent-fail on network error**: before vendoring, `scripts/validate-schemas.sh` would print `WARN: could not fetch <url>` and continue with `exit 0` (parse-only fallback). That masked a real validation gap. With vendored schemas the fallback is explicit.

See [`docs/governance/prompt-supply-chain.md`](../docs/governance/prompt-supply-chain.md) for the broader policy. This directory is the JSON-schema subset.

## What's vendored

| Local file | Source URL | Consumed by |
|---|---|---|
| `claude-code-settings.json` | `https://json.schemastore.org/claude-code-settings.json` | `.claude/settings.json` + `.claude/settings.local.example.json` + `templates/saas-starter/.claude/settings.json.template` |
| `claude-code-plugin.json` | `https://json.schemastore.org/claude-code-plugin.json` | `.claude-plugin/plugin.json` |

Add a new row whenever a new `$schema`-declaring JSON file lands.

## How to refresh

When the upstream schema updates and Ulak OS needs the new rules:

```bash
cd schemas/
curl -fsSL https://json.schemastore.org/claude-code-settings.json -o claude-code-settings.json
# Diff against prior version, review, commit with a message like:
#   chore(schemas): refresh claude-code-settings.json (json.schemastore.org 2026-NN-NN)
```

Do NOT refresh blindly; the upstream schema change may introduce a rule Ulak OS's settings violate. Run `bash scripts/validate-schemas.sh --strict` after refresh; if it fails, decide whether to update the settings to conform OR pin to an older schema commit.

## Validator behavior

`scripts/validate-schemas.sh` (v1.0.1+):

- **Default mode**: tries local `schemas/<slug>.json` first; falls back to network fetch if local is missing; falls back to parse-only with a `WARN:` if network also fails.
- **Strict mode** (`--strict` flag): local-only; fails if any vendored schema is missing. Recommended for CI pipelines.

Slug derivation from URL: take the filename of the `$schema` URL (e.g., `claude-code-settings.json`).

## When NOT to vendor

- Schemas with a live spec (e.g., OpenAPI generated per build) that change every commit — those get generated and consumed in-place, not vendored here.
- Schemas used only during development (pre-commit hooks, editor integration) — those are local-dev tooling, not CI surface.

## Canonical footer

Authoritative as of Ulak OS **v1.0.1** (SEC-B-09 resolution). Schema files added as operator curates them; pull-requests welcome if a new `$schema` URL lands in tracked JSON.
