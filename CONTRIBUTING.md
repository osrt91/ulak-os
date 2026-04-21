# Contributing to Ulak OS

Thanks for considering a contribution. Ulak OS is a **prompt operating system** — most contributions are doc/prompt/agent changes, not executable code. This guide explains how to contribute effectively.

**English** · **Türkçe** (aynı içerik — birazdan eklenecek)

## Before you start

1. Read the [README](./README.md) to understand what Ulak OS is
2. Read [docs/governance/plugin-skill-decision.md](./docs/governance/plugin-skill-decision.md) — how to pick the right unit type (command / agent / skill / hook / MCP / rule-pack / plugin)
3. Read [docs/adr/README.md](./docs/adr/README.md) — recent architectural decisions that constrain new proposals
4. Run the validation scripts to see the pack health baseline:
 ```bash
 bash scripts/validate-imports.sh
 bash scripts/validate-schemas.sh
 bash scripts/validate-vendor-parity.sh
 ```

## Contribution types

### 1. New sector pack

**When**: You've observed a domain-specific pattern across ≥2 real projects that isn't covered by the existing 24 sector packs.

**Where**: `docs/runtime/sector-packs.md` (append new section with SP-NN identifier)

**Evidence required**: File path + line number citations from ≥2 source projects (abstract descriptors if the projects are private, e.g., "a B2B SaaS with multi-locale"). No real project names in public docs.

**Template**:
```markdown
### `<pack-slug>` (SP-NN)
Focus areas:
- <concrete focus point 1>
- <concrete focus point 2>
-...


```

### 2. New anti-pattern

**When**: You've seen the same defect in ≥2 projects and it's not in the 79-entry list.

**Where**: `docs/runtime/anti-patterns.md` (append to the appropriate category or to architectural/frontend/backend/security/data/infra/localization/prompt)

**Evidence required**: Same as sector pack — ≥2 project citations, abstract descriptors.

**Template**:
```markdown
- **AP-NN <short title>** — <what goes wrong in 1-2 sentences>. Fix: <1-2 sentence correction>. 
```

### 3. New rule pack

**When**: A stack-specific imperative guardrail set that loads at Phase 0 when the stack is detected.

**Where**: New file `docs/runtime/rule-packs/<stack>.md`

**Constraints**:
- ≤500 bytes body (imperatives only)
- Activation line at the top
- Collision rule paragraph at the bottom
- No project-specific paths (pure-generic)

See [`docs/governance/rule-pack-governance.md`](./docs/governance/rule-pack-governance.md) for the full contract.

### 4. New agent

**When**: A specialist reasoning role that doesn't fit existing 27 agents.

**Where**: `.claude/agents/<name>.md`

**Template**: See [`.claude/agents/cartographer.md`](./.claude/agents/cartographer.md) (v2.3.0 expanded format).

**Constraints**:
- 80-150 lines
- Frontmatter: `name`, `description`, `tools`
- Sections: Mandate, Focus areas, Evidence rules, Output contract, Rules, Artefact Write Authorization
- Cite `docs/governance/finding-schema.md` for finding YAML shape

### 5. New skill

**When**: A repeatable multi-step workflow that agents / operators invoke by name.

**Where**: `.claude/skills/<name>/SKILL.md`

**Template**: See [`.claude/skills/saas-scaffolder/SKILL.md`](./.claude/skills/saas-scaffolder/SKILL.md).

**Constraints**:
- Frontmatter: `name`, `description`, `context: fork`, `agent`, `allowed-tools`
- Goal + inputs + outputs + process + rules sections
- Triggering criteria ("when to use" vs "when NOT to use") explicit

### 6. New command

**When**: An operator-triggered slash command not covered by existing 9.

**Where**: `.claude/commands/<name>.md` + `.gemini/commands/<name>.toml` (for vendor parity — check `.github/vendor-parity-exemptions.txt` first)

**Template**: See [`.claude/commands/ulak-scaffold.md`](./.claude/commands/ulak-scaffold.md).

**Constraints**:
- Frontmatter: `description`, `phases_run` (which director phases it covers)
- ARGUMENTS block at bottom
- Dispatches to appropriate skill / agent

### 7. Bug fix / doc correction

Smaller changes don't need ADRs. Open a PR with:
- Clear problem statement
- File path + line of the issue
- Fix rationale

## Governance discipline

### No project names in public docs

Ulak OS absorbs patterns from real projects but **never cites project names in public docs**. Use abstract descriptors:

- ❌ "as seen in acme-scanner.com"
- ✅ "as seen in a production security-scanner SaaS"
- ❌ "from our monorepo CMS"
- ✅ "from a multi-app monorepo with shared CMS"

The `f2228a0` commit established this redaction discipline; every public doc follows it. PRs that cite real project names will be asked to re-abstract before merge.

### No real credentials anywhere

- `.env*` files never committed
- `.gitleaks.toml` allowlist never contains real values (use abstract patterns only)
- Screenshot / demo outputs must have redacted tokens

See [`docs/governance/settings-permissions-governance.md`](./docs/governance/settings-permissions-governance.md).

### Evidence tiers

Every non-trivial claim carries a trust tier per [`docs/governance/evidence-trust-scoring.md`](./docs/governance/evidence-trust-scoring.md):

- **T1** — Observed + verified (direct code read)
- **T2** — Inferred from config
- **T3** — Memory-sourced (treat with suspicion)
- **T4-T7** — Progressively weaker

Write T1 when you can; mark clearly when you can't.

## Commit message format

Conventional commits:

```
<type>(<scope>): <short>

<body>

Co-Authored-By: <attribution if applicable>
```

Types used in Ulak OS:
- `feat` — new capability (sector pack, rule pack, agent, command, skill)
- `fix` — bug correction
- `docs` — documentation only
- `chore` — release, dependency, CI
- `refactor` — structural change with no behavior change

Example:
```
feat(anti-patterns): add AP-20 — payment receipt not verified

Observed in two payment-integrated projects: Stripe / Iyzico webhook
succeeds but local DB doesn't verify the receipt counter-signature,
allowing duplicate delivery to be processed twice.

Fix: verify receipt `sig` field against secondary HMAC before state
transition.

Co-Authored-By: Your Name <your@email>
```

## ADRs (when to write one)

Write an Architecture Decision Record when:
- The change affects ≥2 modules / surfaces
- There are non-trivial alternatives to document
- The decision is hard to reverse
- Cross-vendor (claude / codex / gemini) behavior changes

See [`docs/adr/README.md`](./docs/adr/README.md) for format + examples.

## Testing expectations

Before submitting a PR:

```bash
bash scripts/validate-imports.sh # must pass
bash scripts/validate-schemas.sh # must pass
bash scripts/validate-vendor-parity.sh # must pass
bash evals/run.sh # currently warn-only
```

For `src/` changes (CLI code):
- `npm run typecheck` must pass
- `npm run lint` must pass
- `npm test` must pass (when tests exist)

## PR checklist

Use the template when opening a PR. Short version:

- [ ] Change is minimal + focused (one concern per PR)
- [ ] Validation scripts pass locally
- [ ] No real credentials / project names / PII leaked into docs
- [ ] If new unit type, CONTRIBUTING.md constraints followed
- [ ] If governance-affecting, ADR added
- [ ] CHANGELOG entry added in `[Unreleased]` section
- [ ] Commit message follows conventional commits

## Questions

Open a GitHub issue with the `question` label, OR start a Discussion (if enabled on the repo).

## Code of Conduct

All contributions are subject to the [Code of Conduct](./CODE_OF_CONDUCT.md).

## License

Contributions are licensed under [MIT](./LICENSE).

---

## Canonical footer

Authoritative as of Ulak OS **v2.4.0**. Updated when contribution workflow evolves. See CHANGELOG for history.
