# Intake — Ulak OS self-audit (v2.1.3 patch)

## Request summary

Run the full Phase 0–5 director protocol on the Ulak OS repository **itself** (`C:\Users\osrt91\desktop\proje\ulak.os\`) to:

1. Verify the pre-collected ajanscan pattern extraction (`reports/current/ajanscan-pattern-extraction.md`) against Ulak OS current state (spot-check dedup claim).
2. Do a full Ulak OS inventory for things the ajanscan extraction could NOT cover.
3. Dispatch specialist agents in parallel to deep-scan Ulak OS itself.
4. Produce a non-obvious findings layer for Ulak OS that neither ajanscan extraction nor specialists caught.
5. Synthesize Ulak OS **v2.1.3** target-state, execution roadmap, validation plan, pack-gap register.
6. Issue a single merged manager-verdict on Ulak OS v2.1.3 readiness.

The run stops at Phase 5 verdict + executable roadmap. Wave execution (actual file edits) is a future session.

## Known context (verified)

### Project state
- **Platform**: cross-platform prompt operating system (Claude Code + Codex/Copilot + Gemini CLI adapters)
- **State**: HYBRID (runtime docs + agent roster exist; `reports/current/` populated for the first time in this run)
- **Public version**: 2.0.0 (CLI+memory layer per `package.json:3`; prompt-pack content is on v2.1.x track per CHANGELOG)
- **Last commit**: `4f57d22 chore(docs): v1.x stale reference cleanup across active docs`
- **Uncommitted**: `.claude/settings.local.json`, `.mcp.json`

### Content surface sizes
- Runtime docs (`docs/runtime/*.md`): 24 files, 2935 lines
- Governance docs (`docs/governance/*.md`): 13 files, 1082 lines (2 README stubs)
- Adapters (`docs/adapters/*.md`): 4 files, 167 lines
- Specialist agents (`.claude/agents/*.md`): 26 files, ~1200 lines (disciplines + 7 personas)
- Commands (`.claude/commands/*.md`): 7 files, 234 lines
- Skills (`.claude/skills/<name>/SKILL.md`): 4 skills
- Prompt core (`prompts/core/*.md`): 3 files (1.0 tr, 1.0 en, 2.0 tr)
- CLI source (`src/`): adapters / cli / core / memory / pack

### Primary evidence bundle (high-trust, inherited T1-T3)
- `reports/current/ajanscan-pattern-extraction.md` — 39 patterns, 7 target surfaces, pre-deduplicated, handoff from Phase A

### Supply-chain / config
- `.mcp.json` — 1 server enabled (github copilot mcp)
- `.claude/settings.json` — restrictive: git/ls/cat/find bash only, denies `.env` reads, hooks for tool logging
- `.claude/settings.local.json` — operator-local allow list (WebFetch docs.claude.com, context7 MCP, project-to-project copy grants)
- `.gitignore` — covers secrets, build artefacts, reports content (but `.gitkeep` preserved)

### Package & tooling
- Node ≥18 required (running on v25.9.0)
- Deps: better-sqlite3, chalk, cli-table3, commander, ora — small and purposeful
- Test: vitest (unit + e2e)
- Build: tsc → `dist/`
- No CI workflow visible at `.github/workflows/` (not enumerated — flag for release-readiness specialist)

## Missing context (to resolve in Phase 2)

| Gap | Which specialist |
|---|---|
| `.github/workflows/` presence + CI discipline | infra-release-sre |
| `reports/current/` git tracking policy (gitignored OR tracked?) — contents excluded per `.gitignore:31`, but artefacts per-run written here — is this the intended contract? | architecture-lead + prompt-skill-plugin-governor |
| Are all 24 `docs/runtime/*.md` files actually referenced by `prompts/core/ulak-os-core-contract-2.0.0.md`? (3 are stubs: office-roster.md 37L, README.md 3L) | cartographer |
| Persona dispatch pattern vs specialist dispatch pattern — overlap/conflict? | architecture-lead + red-team-challenger |
| Does `settings.local.json` contain wildcards that would trip the settings-permissions-governance doc we're about to write? | security-hardening-lead |
| Are the 4 skills referenced anywhere in agents/commands (trigger surface)? | prompt-skill-plugin-governor |
| Is `security-redteam.md` (persona agent, 66L) a near-duplicate of `red-team-challenger.md` (specialist agent, 31L)? | prompt-skill-plugin-governor + red-team-challenger |
| Does `docs/runtime/office-roster.md` (37L) actually enumerate all 26 agents? | cartographer |
| Are v1.x release notes still imported anywhere? (last commit claims cleanup) | cartographer + release-readiness |
| Is the `autonomy-pressure-layer.md` governance doc (10L — stub?) a live rule or a placeholder? | architecture-lead |

## Initial decomposition (how this run is structured)

**Phase 0** — environment lock (done: runtime-manifest, assumptions, this intake).

**Phase 1** — deep inventory (next — file+line map of what exists).

**Phase 2** — dispatch 8 specialists in parallel:
- prompt-skill-plugin-governor (pack health, trigger discipline)
- architecture-lead (runtime doc coherence, layer discipline)
- cartographer (@-import dependency graph)
- red-team-challenger (rule collisions, ambiguous directives)
- qa-validation-commander (phase-gate enforceability, validation coverage)
- localization-i18n-lead (Turkish + locale in Ulak output profiles)
- security-hardening-lead (settings.json, MCP allowlist, secrets in docs)
- infra-release-sre (CHANGELOG, version pins, CI, hook health)

Explicit skip: `data-database-governor` (no DB in Ulak OS — it's the meta-system).

**Phase 3** — did-you-know layer (non-obvious findings beyond ajanscan + specialist coverage).

**Phase 4** — synthesis of 5 artefacts (analysis-findings, target-state, execution-roadmap, validation-plan, pack-gap-register).

**Phase 5** — manager verdict with v2.1.3 readiness signoff.

## Constraints

- Profile: `AUDIT_PROFILE` (operator-pinned).
- Validation depth: standard.
- No live probes (all evidence file-local; router `live_probe_required: false`).
- No writes to Ulak OS runtime code (REPAIR in docs scope only).
- `ajanscan-pattern-extraction.md` is read-only.
- Other `reports/current/*.md` are empty templates (confirmed by Read) and are being populated now.

## Six open questions from Phase A (to be resolved in target-state.md / analysis-findings.md, not escalated to operator)

1. `orchestrator-coordinator` new agent vs extend `autonomous-program-director`?
2. `security-secrets-auditor` new agent vs extend `security-hardening-lead`?
3. `runtime-surface-split` rename + new `product-surface-split` OR both with clear names?
4. `payment-integrated-saas` new pack vs sub-pattern of `fintech`?
5. `regulated-saas` one pack with 3 variants OR 3 separate packs?
6. Rule-pack precedence: project-local overrides wholesale OR merges?
