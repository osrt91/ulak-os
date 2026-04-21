# Surface Split — Public Runtime / Hidden Core / Maintainer

## Why this exists

Ulak OS is a product with three audiences:

1. **The active model** — what Claude (or Codex, or Gemini) actually loads and reasons over during a run
2. **The end user** — what the user sees in the response and in `reports/current/`
3. **The maintainer** — what the Ulak OS maintainer needs to track changes, debug regressions, and govern releases

These three audiences have different information needs and different tolerance for noise. Collapsing them into one surface means every run loads historical A/B test notes into the active context, every user response contains internal version-diff commentary, and every maintainer search for "why did we remove X" returns hundreds of user-facing bullet points.

The solution is **surface split**: three layers with clear rules about what goes where.

## Layer 1 — Public Runtime Surface

**Audience**: the active model during a run.

**Purpose**: the canonical, always-loaded operating rules.

**What goes here**:
- Core identity and mission (who the system is)
- Instruction hierarchy
- Trust model
- Router decision contract
- Context budget rules
- Intervention modes list
- Project state switch
- Output profiles
- Non-negotiable rules
- Artefact contract
- Final validation principles
- Active sector pack (only the one the router activated)

**Where it lives**:
- `prompts/core/ulak-os-core-contract-2.0.0.md`
- `docs/runtime/*.md` (all active runtime rules)
- `docs/governance/*.md` (active governance — not history)
- `CLAUDE.md` imports

**Rules**:
- Always clean
- Always authoritative
- No historical commentary
- No "in V6 this was different" notes
- No experimental rules that are not currently active

## Layer 2 — Hidden Core (maintainer, not loaded by default)

**Audience**: the Ulak OS maintainer doing governance work.

**Purpose**: the history and rationale behind current runtime decisions.

**What goes here**:
- Version change notes (V6 → V7 → V8 → V9 → Ulak OS 1.0 → 2.0)
- Prompt tuning experiments
- Failed variations with reasons
- Regression case archive
- Anti-pattern case studies
- Routing heuristic notes
- Maintainability explanations
- "Why was this section moved" notes
- Deprecated or removed modules
- Internal scoring formulas
- A/B prompt test notes
- Eval results history
- Golden example failure archive

**Where it lives**:
- `docs/history/*` — version lineage
- `docs/archive/*` — archived prompts and decisions
- `docs/governance/hidden-maintainer-surface-template.md` — the template for new maintainer notes
- `docs/adr/*` — architecture decision records

**Rules**:
- Never loaded into the active model context by default
- Never surfaced to the user in response output
- Can be read by a maintainer session explicitly asking for it
- Can be consulted by the prompt-skill-plugin-governor agent when deciding whether to retire or revive a pattern

## Layer 3 — Maintainer Surface

**Audience**: the Ulak OS maintainer doing operational work.

**Purpose**: the tooling and status signals for releasing and running Ulak OS.

**What goes here**:
- Changelog
- Compatibility matrix (which version works with which Claude Code version, which plugins)
- Canonical source list (which file is authoritative for what rule)
- Active vs deprecated modules table
- Eval results (latest run)
- Golden set results
- Release criteria and gates
- Pack compatibility table
- Maintainer runbook
- CI status
- Release notes drafts

**Where it lives**:
- `CHANGELOG.md`
- `docs/release/*.md`
- `docs/ecosystem/*.md`
- `reports/*` (non-current runs)
- `.github/*` for CI
- Release notes files at the repo root

**Rules**:
- Accessible to maintainers via git and the repo file tree
- Not auto-loaded into runtime
- Informs release decisions
- Survives releases as the operational log

## Hard rules

- **The user never sees hidden-core notes in their response.** If a response contains "in V7 this was different, now in V9 we...", that's a bleed-through bug.
- **The active model context never loads hidden core by default.** History leaks into reasoning and blurs decisions.
- **Maintainer surface is for humans, not for the model.** The model does not need to know the release criteria table to do a good audit run.
- **The three layers are not hierarchical.** Hidden core is not a "deeper" version of public runtime — it's a different audience.
- **When in doubt, start in hidden core.** Promote to public runtime only when the pattern is proven.

## Integration

- `docs/runtime/context-budget.md` — explains which layer the floor (always-loaded) belongs to (Layer 1)
- `docs/governance/hidden-maintainer-surface-template.md` — template for writing hidden core notes
- `docs/history/version-lineage.md` — resides in hidden core (not loaded at runtime unless explicitly imported)
- `CLAUDE.md` imports only Layer 1 files
