# Localization Governance

This document defines which files MUST be bilingual (TR + EN), which MUST stay single-language, and who owns the enforcement. It is the policy layer above `docs/runtime/localization-strategy.md` (which is the strategy/motor) and above `/ulak-locale` (which is the runtime toggle).

Bu doküman hangi dosyaların bilingual (TR + EN) olması zorunlu olduğunu, hangilerinin tek dilli kalması gerektiğini ve enforcement sahibini tanımlar. `docs/runtime/localization-strategy.md` strateji/motor katmanıdır; `/ulak-locale` runtime toggle'dır; bu dosya policy katmanıdır.

## Scope

- Applies to: all files committed under `C:\Users\osrt91\desktop\proje\ulak.os\`
- Excludes: `node_modules/`, `dist/`, `reports/`, `.git/`, generated artefacts
- Enforcement: `scripts/validate-bilingual.sh` (PASS/FAIL CI gate)
- Override authority: operator-only; agents may not unilaterally drop a bilingual pair

## Rule 1 — User-facing docs MUST be bilingual

**Target surface:** content a human reader (operator, evaluator, community contributor, end customer) will read directly.

**Required bilingual pairs:**

| TR file | EN file |
|---|---|
| `README.md` | `README.en.md` |
| `AGENTS.md` | `AGENTS.en.md` |
| `CLAUDE.md` | `CLAUDE.en.md` |
| `GEMINI.md` | `GEMINI.en.md` |
| `docs/user-manual/tr/*.md` | `docs/user-manual/en/<paired-name>.md` |
| `docs/runbooks/*.md` | `docs/runbooks/*.md` (with `lang:` frontmatter) OR paired `*.en.md` |

**Missing pair = FAIL** in `validate-bilingual.sh`.

## Rule 2 — Machine-read runtime rules are EN-primary, TR-secondary

**Target surface:** files loaded by the model at runtime (runtime rules, governance, schemas).

**Rationale:** Claude's training distribution is dominated by English technical content. EN source gives the strongest semantic grip; a TR mirror is allowed but not required.

**Applies to:**
- `docs/runtime/*.md`
- `docs/governance/*.md`
- `docs/adr/*.md`
- `prompts/core/*.md`
- `schemas/*.yaml` / `schemas/*.json`

**Rule:** EN content is canonical. TR mirror optional. If TR mirror exists, it MUST carry `translation_of: <en-path>` frontmatter so drift is detectable.

## Rule 3 — Code + templates are EN-only

**Target surface:** TypeScript, bash, PowerShell, YAML, Dockerfile, template scaffolder output.

**Rationale:** IDE tooling, autocompletion, linter messages, and downstream developer ergonomics assume EN identifiers.

**Applies to:**
- `src/**/*.ts`, `src/**/*.js`
- `scripts/**/*.sh`, `scripts/**/*.ps1`
- `templates/**`
- `tests/**`
- `bin/**`

**Forbidden in code:** TR identifiers, TR comments in public APIs, TR log messages shipped to users.
**Allowed in code:** TR error messages surfaced to a TR-locale end-user, but only via i18n lookup, not hardcoded.

## Rule 4 — Slash command frontmatter: TR primary, EN secondary

**Target surface:** `.claude/commands/*.md`

**Required frontmatter shape:**

```yaml
---
name: <command-id>
description: <Turkish description — primary, operator-facing>
description_en: <English description — secondary, required for EN-locale operators>
agent: <agent-id>
allowed-tools: Read, Write, ...
argument-hint: "<TR hint>"
model: claude-opus-4-7
---
```

**Validator check:** every slash command file under `.claude/commands/` MUST have a non-empty `description` field. `description_en` is strongly recommended but currently a warning rather than a hard FAIL, to preserve backward compatibility with older commands. New commands created after v1.1.0 MUST include both.

## Rule 5 — CHANGELOG + semver history are EN-only

**Target surface:** `CHANGELOG.md`, release notes (`RELEASE_NOTES_*.md`), `VERSIONING.md`, `VERSION_DISTRIBUTION_MATRIX.md`.

**Rationale:** CHANGELOG is machine-parsed (Keep a Changelog spec), consumed by tooling (GitHub releases, npm), and by a predominantly English-speaking ecosystem.

**Rule:** EN only. A TR translation is NOT maintained. Contributors writing in TR must translate the entry before commit.

## Rule 6 — Locale state has a single source of truth

**File:** `.claude/state/locale.txt`
**Values:** `tr` or `en` (single line, UTF-8, no BOM)
**Read by:** `/ulak-locale show`, `scripts/validate-bilingual.sh`, any surface that renders "current locale"
**Written by:** `/ulak-locale tr`, `/ulak-locale en` only
**Default when missing:** `tr` (project origin is Turkey)
**Committed:** YES — not `.gitignore`d, so operator transitions are visible in history

**Anti-pattern:** Reading locale from `$LANG` env, `navigator.language`, or CLAUDE.md frontmatter. These are forbidden as primary locale sources for Ulak OS runtime.

## Enforcement chain

1. **Local:** developer runs `scripts/validate-bilingual.sh` before commit
2. **CI:** script runs on every PR; FAIL blocks merge
3. **Release:** `/director komple` Phase 4 validation-plan includes a bilingual-parity check item
4. **Audit:** quarterly governance review (owner: `architecture-lead`) re-reads this file against reality

## Change control

This file is Layer 1 (public runtime surface). Changes require:
- ADR referencing the modification
- migration plan for any newly-required bilingual pair
- validator update in the same PR

## Related

- `docs/runtime/localization-strategy.md` — the strategy motor
- `docs/runtime/turkish-normalization.md` — Turkish-specific char/Unicode rules
- `.claude/commands/ulak-locale.md` — the runtime toggle
- `scripts/validate-bilingual.sh` — the automated policy check
