# Prompt Supply Chain and Version Governance

## Why this exists

A prompt is no longer a single file. Ulak OS is a network of core contract, runtime docs, governance docs, specialist agents, commands, skills, and vendor adapters. Each file has a role, a version, and a state (stable, experimental, deprecated, archived). Without supply chain governance, maintainers lose track of which file is authoritative, users lose track of what version they're on, and regressions creep in without anyone noticing.

Prompt supply chain governance treats the prompt like a software product: canonical sources, version labels, release discipline, compatibility matrix.

## Canonical source identification

For every rule or capability, there must be exactly one canonical source file. If a rule appears in three files, two of them must either delete it or import from the canonical source.

### Identification rules

- **Core contract** — `prompts/core/ulak-os-core-contract-X.Y.Z.md`. The active version is imported from `CLAUDE.md`. Older versions stay in place for reference but are not imported.
- **Runtime rules** — `docs/runtime/*.md`. Each topic (router, context budget, artefacts, phases, output profiles) has exactly one canonical file.
- **Governance** — `docs/governance/*.md`. Trust model, evidence scoring, finding schema, surface split, hooks, MCP, memory — one file per topic.
- **Specialists** — `.claude/agents/*.md`. One file per agent role.
- **Commands** — `.claude/commands/*.md`. One file per command.
- **Skills** — `.claude/skills/<name>/SKILL.md`. One file per skill.
- **Adapters** — `docs/adapters/*.md`. One file per vendor adapter.

### Duplicate detection

When writing a new rule, check:

1. Does this topic already have a canonical file? If yes, extend it.
2. If creating a new file, is the topic sufficiently distinct to merit its own canonical source?
3. If the new rule contradicts an existing canonical source, which wins? Resolve before merging.

## Version labels

Every file in the supply chain carries an implicit or explicit version state:

- **stable** — current, authoritative, loaded by default
- **experimental** — new, under evaluation, may change or be removed
- **deprecated** — still present for compatibility, replaced by a newer canonical source
- **archived** — retained for history, not loaded at runtime

Current state:

- Ulak OS 2.0 files are **stable**
- New additions in v2.1.0 are **experimental** until the first successful user-run signoff, then **stable**
- V6 / V7 / V8 / V9 source material is **archived** (lives in maintainer-visible locations, not loaded at runtime)

## Release discipline

Every release carries a release note block with:

- **What changed** — concrete file list and rule-level summary
- **Why** — motivation (user pain, regression, new capability)
- **Risk** — what could break
- **Regression result** — eval harness pass/fail against the golden set
- **Compatibility note** — which Claude Code / Codex / Gemini versions this requires

Release notes live in:

- `docs/release/*.md` — per-release long form
- `CHANGELOG.md` — short form running log
- GitHub Releases — user-facing summary

## Compatibility matrix

Maintained in `docs/ecosystem/compatibility.md` (or equivalent):

```yaml
ulak_os_2.0.0:
  claude_code: ">= 2.0.0"
  codex: ">= 1.5.0"
  gemini_cli: ">= 1.1.0"
  plugins:
    superpowers: ">= 5.0.0"
    cartographer: "*"
```

Updated on every release. Broken compatibility is a release blocker.

## What belongs in the active supply chain

- Current `prompts/core/ulak-os-core-contract-<latest>.md`
- All `docs/runtime/*.md` currently referenced by the core contract
- All `docs/governance/*.md` currently referenced
- All `.claude/agents/*.md` in the office roster
- All `.claude/commands/*.md` used by docs/adapters
- All `.claude/skills/*/SKILL.md` listed in the skill registry
- Vendor adapters in `docs/adapters/*.md`

## What does NOT belong in the active supply chain

- Archived prompt source material (V6/V7/V8/V9) — keep in `docs/archive/` or equivalent
- Version-delta notes (what changed from V7 to V8) — keep in `docs/history/` or hidden core
- Failed experiments — keep in `docs/governance/hidden-maintainer-surface-template.md` or an experiments archive
- Maintenance commentary about why rules exist — keep in ADRs or commit messages, not in active runtime files

## Hard rules

- **Never inline maintainer commentary into runtime files.** "We removed this in V8 because..." does not belong in `docs/runtime/router.md`.
- **Never have two files claim to be canonical for the same topic.** Pick one.
- **Never ship a release without an eval run.** Regression detection is the safety net.
- **Never bump the core contract version silently.** Version bump = release = release notes.
- **Archive, don't delete.** History is valuable to maintainers even when it's not loaded at runtime.

## Cross-project pattern imports (G-EXT-04)

The supply chain extends **across projects** when the same operator runs multiple repos. Patterns migrate: `CMS + blog + site-settings` moved from the monorepo e-commerce project to the security scanner project; `docker-socket-proxy sidecar` moved from an internal template library to the security scanner project. Without a ledger, provenance vanishes and upstream bugfixes don't propagate.

The companion governance doc is `docs/governance/pattern-import-ledger.md`:

- Every project that imports patterns from sibling projects maintains a `pattern-import-ledger.yaml`
- Each entry records source repo, source commit, import date, local divergence, pending upstream fixes
- Architecture-lead audits the ledger at every Phase 2 sweep and files backport findings for new relevant upstream commits

**The ledger is prompt-supply-chain family** because it answers the same structural question ("if the source changes, what do we need to review?") at the code-pattern level that this doc answers at the rule level.

## Integration

- `docs/history/version-lineage.md` — records version history (hidden core)
- `docs/governance/surface-split.md` — explains why archived content is not loaded
- `docs/governance/pattern-import-ledger.md` — cross-project code-pattern provenance ledger (sibling doc)
- `docs/governance/ai-provider-allowlist.md` — AI provider changes are supply-chain events (log in release notes)
- `docs/ecosystem/*` — ecosystem maps and compatibility matrices
- `evals/` — regression detection runs as part of release discipline
