# 07 — Contributing

Ulak OS is a **prompt operating system** — most contributions are documentation, prompts, or agent definitions, not executable code. This chapter summarizes how to propose a new unit (sector pack, rule pack, runtime rule, anti-pattern, agent, command, or skill), the evidence bar, the PR format, and how to report security issues.

The full contributor guide lives at [`../../../CONTRIBUTING.md`](../../../CONTRIBUTING.md). This chapter is the short version for English-speaking contributors.

## Before you start

1. Read [chapter 01](./01-introduction.md) to understand what Ulak OS is.
2. Read [`docs/governance/plugin-skill-decision.md`](../../governance/plugin-skill-decision.md) to pick the right unit type for your proposal.
3. Read [`docs/adr/README.md`](../../adr/README.md) to see which architectural decisions constrain new proposals.
4. Run the validators to see the baseline:
   ```bash
   bash scripts/validate-imports.sh
   bash scripts/validate-schemas.sh
   bash scripts/validate-vendor-parity.sh
   ```

## Seven contribution types

### 1. New sector pack

**When.** You observed a domain-specific pattern across **≥2 real projects** that is not covered by the 24 existing sector packs.

**Where.** Append a new section to [`docs/runtime/sector-packs.md`](../../runtime/sector-packs.md) with a `SP-NN` identifier.

**Evidence.** File-path and line-number citations from ≥2 source projects. Use abstract descriptors if the projects are private (e.g., "a B2B SaaS with multi-locale"). **No real project names in public docs.**

### 2. New anti-pattern

**When.** You saw the same defect in ≥2 projects and it is not already in the anti-pattern library.

**Where.** Append to [`docs/runtime/anti-patterns.md`](../../runtime/anti-patterns.md) under the relevant category (architectural, frontend, backend, security, data, infra, localization, prompt).

**Evidence.** Same as sector pack — ≥2 project citations, abstract descriptors. Add a matching entry to the [pattern-import ledger](../../governance/pattern-import-ledger.md) with `trust_tier: T2` or stronger.

**Template:**
```markdown
- **AP-NN <short title>** — <what goes wrong in 1-2 sentences>. Fix: <1-2 sentence correction>.
```

### 3. New rule pack

**When.** A stack-specific imperative guardrail set that should load at Phase 0 when the stack is detected.

**Where.** New file under `docs/runtime/rule-packs/<stack>.md`.

**Constraints:**
- ≤500 bytes body (imperatives only)
- Activation line at the top declaring the trigger stack
- Collision rule paragraph at the bottom
- No project-specific paths — pure generic

Full contract: [`docs/governance/rule-pack-governance.md`](../../governance/rule-pack-governance.md).

### 4. New runtime rule

**When.** A piece of always-on discipline that is not stack-specific and belongs in the public runtime surface.

**Where.** New file under `docs/runtime/*.md`.

**Constraints:**
- Must be imported by `prompts/core/ulak-os-core-contract-2.0.0.md`
- Must not duplicate or contradict an existing rule (check the collision matrix)
- Must carry a finding-schema-compliant example if it introduces a new claim shape

### 5. New agent

**When.** A specialist reasoning role that does not fit the 27 existing agents.

**Where.** New file at `.claude/agents/<name>.md`.

**Template.** See [`.claude/agents/cartographer.md`](../../../.claude/agents/cartographer.md) for the expanded v2.3.0 format.

**Constraints:**
- 80–150 lines
- Frontmatter: `name`, `description`, `tools`
- Sections: Mandate, Focus areas, Evidence rules, Output contract, Rules, Artefact Write Authorization
- Must cite `docs/governance/finding-schema.md` for the finding YAML shape

### 6. New command

**When.** An operator-triggered slash command not covered by the 9 existing commands.

**Where.** New file at `.claude/commands/<name>.md`, plus (for vendor parity) a `.gemini/commands/<name>.toml` Gemini adapter or an exemption entry in `.claude/vendor-parity-exemptions.txt`.

**Template.** See [`.claude/commands/ulak-scaffold.md`](../../../.claude/commands/ulak-scaffold.md).

**Constraints:**
- Frontmatter: `description`, `phases_run` (which director phases it covers)
- `ARGUMENTS:` block at the bottom
- Dispatches to a specific skill or agent — does not duplicate their logic inline

### 7. New skill

**When.** A repeatable multi-step workflow that agents or operators invoke by name.

**Where.** New directory at `.claude/skills/<name>/` with a `SKILL.md` inside.

**Template.** See [`.claude/skills/saas-scaffolder/SKILL.md`](../../../.claude/skills/saas-scaffolder/SKILL.md).

**Constraints:**
- Frontmatter: `name`, `description`, `context: fork`, `agent`, `allowed-tools`
- Sections: Goal, Inputs, Outputs, Process, Rules
- "When to use" and "When NOT to use" are explicit

## Evidence bar

All pattern contributions (sector pack, anti-pattern, rule pack) require:

- **≥2 real-project citations** — file path + line range from each
- **T1 or T2 trust tier** per [`docs/governance/evidence-trust-scoring.md`](../../governance/evidence-trust-scoring.md)
- **Abstract descriptors** for any private projects — no real project names in public docs

Single-occurrence contributions are rejected as "too speculative". Wait for the pattern to show up in a second project.

## Opening an issue

- **Questions** — label `question`.
- **Bug reports** — use the bug-report issue template. Include your OS, CLI version, Ulak OS version, repro steps, expected vs actual.
- **Feature requests** — describe the use case, show where in the existing unit taxonomy the request would live, note whether you have evidence from multiple projects.

Issue templates live under `.github/ISSUE_TEMPLATE/`.

## PR format

Use the PR template (`.github/PULL_REQUEST_TEMPLATE.md`). The short checklist:

- [ ] Change is minimal and focused (one concern per PR)
- [ ] Validation scripts pass locally (`validate-imports.sh`, `validate-schemas.sh`, `validate-vendor-parity.sh`)
- [ ] No real credentials, project names, or PII leak into docs
- [ ] If a new unit type, the constraints in [CONTRIBUTING.md](../../../CONTRIBUTING.md) are met
- [ ] If governance-affecting, an ADR is added
- [ ] `CHANGELOG.md` entry added in the `[Unreleased]` section
- [ ] Commit message follows conventional commits

### Commit message format

```
<type>(<scope>): <short description>

<body>

Co-Authored-By: <attribution if applicable>
```

Types used in Ulak OS:
- `feat` — new capability (sector pack, rule pack, agent, command, skill)
- `fix` — bug correction
- `docs` — documentation only
- `chore` — release, dependency, CI
- `refactor` — structural change with no behavior change

## ADR triggers

Write an Architecture Decision Record when:

- The change affects ≥2 modules or surfaces.
- There are non-trivial alternatives worth documenting.
- The decision is hard to reverse later.
- Cross-vendor behavior (Claude / Codex / Gemini) changes.

ADRs live under `docs/adr/`. See [`docs/adr/README.md`](../../adr/README.md) for the format and recent examples.

## Code of Conduct

All contributions are subject to the project's [Code of Conduct](../../../CODE_OF_CONDUCT.md). The short version: treat every contributor with respect, assume good intent, keep the tone collaborative. Harassment, personal attacks, and bad-faith engagement are not tolerated.

Reporting conduct issues: use the contact in `CODE_OF_CONDUCT.md` (maintainer email). Response within 72 hours.

## Security issue reporting

**Do not open a public GitHub issue for security problems.** Email the maintainer directly:

> `info@oguzhansert.dev`

Expected response within 72 hours. Coordinated disclosure is the default — if a responsible-disclosure window is negotiated, it is respected.

What counts as a security issue:
- A credential, token, or secret observed in a committed file (even historical commits)
- A pattern that, if widely adopted, would introduce a vulnerability (RLS bypass, IDOR class, webhook replay)
- An injection vector in the prompt supply chain

What counts as a regular bug (not security):
- Validator script wrong
- A governance doc contradicts another
- A command arg parsed wrong

## License

Contributions are licensed under [MIT](../../../LICENSE). By opening a PR, you agree your contribution is MIT-licensed.

---

Next: [08 — Troubleshooting](./08-troubleshooting.md)
