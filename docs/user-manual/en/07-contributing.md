# 07 — Contributing

Ulak OS is a **prompt operating system** — most contributions are documentation, prompts, or agent definitions, not executable code. This chapter summarizes how to propose a new unit (sector pack, rule pack, runtime rule, anti-pattern, agent, command, skill, tutorial, walkthrough, or glossary term), the evidence bar, the PR format, the bilingual and vendor-parity disciplines (enforced by CI in v1.6), and how to report security issues.

The full contributor guide lives at [`../../../CONTRIBUTING.md`](../../../CONTRIBUTING.md).

## Before you start

1. Read [chapter 01](./01-introduction.md) to understand what Ulak OS is.
2. Read [`docs/governance/plugin-skill-decision.md`](../../governance/plugin-skill-decision.md) to pick the right unit type.
3. Read [`docs/governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md) to understand the parity commitment you are signing up for.
4. Read [`docs/adr/README.md`](../../adr/README.md) for architectural constraints.
5. Run all four validators to see the baseline:
   ```bash
   bash scripts/validate-imports.sh
   bash scripts/validate-schemas.sh
   bash scripts/validate-vendor-parity.sh
   bash scripts/validate-bilingual.sh
   ```

## Contribution types

### 1. New sector pack

**When.** Domain-specific pattern across **≥2 real projects** not covered by the existing 24 sector packs.

**Where.** Append to [`docs/runtime/sector-packs.md`](../../runtime/sector-packs.md) with `SP-NN` identifier.

**Evidence.** File-path and line-number citations from ≥2 source projects (abstract descriptors for private projects).

### 2. New anti-pattern

**When.** Same defect in ≥2 projects, not already in the library.

**Where.** Append to [`docs/runtime/anti-patterns.md`](../../runtime/anti-patterns.md).

**Evidence.** Same as sector pack + matching entry in `pattern-import-ledger.md` with `trust_tier: T2` or stronger.

### 3. New rule pack

**When.** Stack-specific imperative guardrail set for a stack not yet covered by the existing 8.

**Where.** New file under `docs/runtime/rule-packs/<stack>.md`.

**Constraints:**
- ≤500 bytes body
- Activation line at top
- Collision rule paragraph at bottom
- No project-specific paths

### 4. New runtime rule

**When.** Always-on discipline belonging in the public runtime surface.

**Where.** New file under `docs/runtime/*.md`.

### 5. New agent

**When.** Specialist reasoning role not covered by the 27 existing agents.

**Where.** New file at `.claude/agents/<name>.md`.

**Constraints:** 80–150 lines, frontmatter with `name`, `description`, `tools`, sections for Mandate / Focus / Evidence / Output / Rules / Artefact Write Authorization.

### 6. New command

**When.** Operator-triggered slash command not covered by the 24 existing commands.

**Where.** New file at `.claude/commands/<name>.md`.

**Additional v1.6 requirements — vendor parity:**
- A matching `.gemini/commands/<name>.toml` for Gemini CLI, **or** an exemption entry in `.claude/vendor-parity-exemptions.txt` with rationale.
- An entry in the NL trigger map (`AGENTS.md`) for Codex and Copilot CLIs, **or** an exemption.
- A row in [`docs/governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md).
- Bilingual frontmatter: `description` (TR) + `description_en` (EN).

`scripts/sync-gemini-commands.sh` automates the Gemini `.toml` generation from the Claude `.md` — run it after writing the Claude command and before opening the PR.

### 7. New skill

**When.** Repeatable multi-step workflow agents invoke by name.

**Where.** New directory at `.claude/skills/<name>/` with a `SKILL.md` inside.

### 8. New tutorial (v1.6)

**When.** External service that scaffolder references but cannot automate (account creation, API key retrieval).

**Where.** New file under `docs/tutorials/<service>.md`.

**Constraints:** Beginner-friendly step-by-step; screenshots or directly quotable dashboard paths; bilingual (TR + EN).

### 9. New showcase walkthrough (v1.6)

**When.** A workflow variation that warrants end-to-end annotated coverage.

**Where.** New file under `docs/showcase/<NN-slug>.md`.

**Constraints:** 100–150 lines; fictional operator persona; sample artefact snippets; no real project names.

### 10. New glossary term (v1.6)

**When.** A technical term surfaces in scaffolded projects or commands and is not in the 47-term glossary.

**Where.** Append to `docs/runtime/beginner-glossary.md`.

**Constraints:** 5 fields (Simple / Technical / Analogy / In Ulak / Related); bilingual (TR + EN definitions).

## Evidence bar

All pattern contributions (sector pack, anti-pattern, rule pack) require:

- **≥2 real-project citations** — file path + line range from each
- **T1 or T2 trust tier** per [`docs/governance/evidence-trust-scoring.md`](../../governance/evidence-trust-scoring.md)
- **Abstract descriptors** for private projects — no real project names in public docs

Single-occurrence contributions are rejected as "too speculative".

## Vendor parity discipline (v1.6)

New in v1.6: **every command is a four-vendor commitment** unless explicitly exempt.

When you add a new command, the merge checklist includes:

- [ ] `.claude/commands/<name>.md` — the canonical file
- [ ] `.gemini/commands/<name>.toml` — generated via `sync-gemini-commands.sh` (or exempt)
- [ ] `AGENTS.md` NL trigger map entry — for Codex and Copilot (or exempt)
- [ ] Row in `docs/governance/vendor-capability-matrix.md` with status per vendor
- [ ] Rationale in `.claude/vendor-parity-exemptions.txt` for any exemption

If `scripts/validate-vendor-parity.sh` fails, the PR cannot merge. The script checks that every `.claude/commands/*.md` has a matching `.gemini/commands/*.toml`, a matrix entry, and NL trigger coverage — or a documented exemption.

## Bilingual discipline (v1.6)

Every public-surface file exists in TR and EN. `scripts/validate-bilingual.sh` compares:

- `docs/user-manual/tr/` vs `docs/user-manual/en/` — chapter count + heading count parity
- Frontmatter `description` / `description_en` on every command, skill, agent
- Governance docs, ADRs, runbooks, tutorials: each has both versions or a `<file>.tr.md` + `<file>.en.md` pair
- The README toggle at `.claude/state/locale.txt` drives the default; both are maintained regardless

When updating an existing file, update both languages **in the same PR**. PR template enforces this with a checkbox.

## Opening an issue

- **Questions** — label `question`.
- **Bug reports** — use the bug-report template. Include OS, CLI version, Ulak OS version, repro, expected vs actual.
- **Feature requests** — describe the use case, where it fits in the taxonomy, and whether you have evidence from multiple projects.

Issue templates: `.github/ISSUE_TEMPLATE/`.

## PR format

Use `.github/PULL_REQUEST_TEMPLATE.md`. Checklist:

- [ ] Change is minimal and focused (one concern per PR)
- [ ] All four validation scripts pass locally (`validate-imports.sh`, `validate-schemas.sh`, `validate-vendor-parity.sh`, `validate-bilingual.sh`)
- [ ] `sync-gemini-commands.sh` run if a Claude command was added or modified
- [ ] No real credentials, project names, or PII leak into docs
- [ ] Vendor-capability-matrix updated if a new command / skill / agent
- [ ] Bilingual parity held (TR + EN both updated)
- [ ] Pattern-import-ledger entry added if a new pattern (trust tier ≥ T2, ≥2 projects)
- [ ] ADR added if governance-affecting
- [ ] `CHANGELOG.md` entry in `[Unreleased]`
- [ ] Commit message follows conventional commits

### Commit message format

```
<type>(<scope>): <short description>

<body>

Co-Authored-By: <attribution if applicable>
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`.

## ADR triggers

Write an Architecture Decision Record when:

- Change affects ≥2 modules or surfaces
- Non-trivial alternatives worth documenting
- Decision is hard to reverse later
- Cross-vendor behavior changes

ADRs live under `docs/adr/`. See [`docs/adr/README.md`](../../adr/README.md) for format. v1.6 example: adding the vendor-capability-matrix as governance required a new ADR.

## Code of Conduct

Contributions are subject to [`CODE_OF_CONDUCT.md`](../../../CODE_OF_CONDUCT.md). Treat every contributor with respect, assume good intent. Report conduct issues via the maintainer email in the CoC. Response within 72 hours.

## Security issue reporting

**Do not open a public GitHub issue for security problems.** Email:

> `info@oguzhansert.dev`

Expected response within 72 hours. Coordinated disclosure is the default.

What counts as a security issue:
- A credential / token / secret in a committed file (even historical)
- A pattern that, if widely adopted, would introduce a vulnerability (RLS bypass, IDOR class, webhook replay)
- An injection vector in the prompt supply chain

What counts as a regular bug:
- Validator script wrong
- A governance doc contradicts another
- A command arg parsed wrong

## License

Contributions are licensed under [MIT](../../../LICENSE). By opening a PR you agree your contribution is MIT-licensed.

---

Next: [08 — Troubleshooting](./08-troubleshooting.md)
