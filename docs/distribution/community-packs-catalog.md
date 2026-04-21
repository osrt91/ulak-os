# Community Packs Catalog

> Curated reference list of community Claude Code / Codex / Gemini CLI packs that Ulak OS operators can learn from, adopt, or compose with. This is a **read-only reference**; the runtime equivalent is the [`awesome-packs-index`](../../.claude/skills/awesome-packs-index/SKILL.md) skill, which produces a fresh catalog per run.
>
> **Updated**: 2026-04-21 · **Next refresh**: quarterly (every 90 days) per Ulak OS cadence.

## Classification rubric

Each pack carries four fields:

- **Type**: command · skill · agent · plugin · MCP server · rule-pack reference
- **Trust tier** (per `docs/governance/evidence-trust-scoring.md`): T1 Anthropic-maintained · T2 well-known maintainer · T3 community · T4 user-submitted / ephemeral
- **License gate**: MIT / Apache-2.0 / BSD = ✓ adopt-ready; GPL = ⚠ review; proprietary = ✗ refuse
- **Ulak overlap**: does Ulak OS already solve this? (none / partial / full)

## Canonical registries (source of truth)

| Registry | URL | Curator | Trust |
|---|---|---|---|
| **awesome-claude-code** | `github.com/hesreallyhim/awesome-claude-code` | Community-curated, maintainer-vetted | T2 |
| **anthropics/superpowers** | `github.com/anthropics/superpowers` | Anthropic official | T1 |
| **anthropics/skills** | `github.com/anthropics/skills` | Anthropic official | T1 |
| **modelcontextprotocol/servers** | `github.com/modelcontextprotocol/servers` | MCP Protocol working group + Anthropic | T1 |
| **VoltAgent/awesome-design-md** | `github.com/VoltAgent/awesome-design-md` | VoltAgent (58-brand design references) | T2 |

## Shortlist (recommend for Ulak OS consumers)

### Skills worth adopting / learning from

- **`superpowers:brainstorming`** · T1 · MIT · Ulak overlap: **full** — Ulak wraps this with `/ulak-brainstorm` command + `docs/superpowers/specs/` persistence. Use the underlying skill for any non-trivial feature ideation.
- **`superpowers:test-driven-development`** · T1 · MIT · overlap: **full** — Ulak wraps this with `/ulak-test-driven` that integrates evals/golden/ promotion.
- **`superpowers:dispatching-parallel-agents`** · T1 · MIT · overlap: **full** — wrapped by `/ulak-subagent-dispatch`.
- **`superpowers:subagent-driven-development`** · T1 · MIT · overlap: **partial** — used by `/ulak-subagent-dispatch`; Ulak adds orchestrator redaction-sweep + validator-pass + commit-series after dispatch.
- **`superpowers:systematic-debugging`** · T1 · MIT · overlap: **none** — complements `/triage-build`; consider invoking for any unexplained failure before writing fix.
- **`superpowers:verification-before-completion`** · T1 · MIT · overlap: **partial** — Ulak's validator scripts enforce this for `/director komple` signoff; the skill adds general discipline.
- **`frontend-design:frontend-design`** · T2 · MIT · overlap: **partial** — Ulak's v1.1 scaffolder covers baseline design; this skill adds distinctive non-generic frontend generation. Worth invoking for hero / marketing surfaces.
- **`skill-creator:skill-creator`** · T2 · MIT · overlap: **none** — use when extending Ulak OS itself with a new skill via `/ulak-pattern-extract` + skill authoring.

### MCP servers (see `docs/governance/mcp-governance.md` for allowlist policy)

- **`modelcontextprotocol/server-github`** · T1 · MIT — issue + PR management; used by Ulak OS plugin marketplace prep + upstream submissions.
- **`modelcontextprotocol/server-google-drive`** · T1 · MIT — document ingest for knowledge-base-style audit inputs.
- **`modelcontextprotocol/server-postgres`** · T1 · MIT — direct Postgres access for schema drift detection, RLS policy audit, cross-tenant verification probes.
- **`context7/context7` MCP** · T2 · Commercial-use-OK — live library documentation fetcher; recommended during Phase 0 runtime manifest + toolchain precheck.
- **`hugginface/hf-mcp-server`** · T1 · Apache-2.0 — Hugging Face model + paper lookup; useful for AI-sector audits + research-currency skill.

### Rule-pack references (pattern ideas)

- **`dair-ai/Prompt-Engineering-Guide`** · T3 · MIT · overlap: **partial** — pattern catalog that informs Ulak's `anti-patterns.md` + helps authors avoid weak prompt shapes. Not imported; referenced.
- **`VoltAgent/awesome-design-md`** · T2 · MIT · overlap: **partial** — 58+ brand design references; Ulak OS scaffolder's `scripts/fetch-design-references.sh` integrates this; v2.1+ hardened (SEC-B-06) with prompt-injection sigil scan.

### Commands / agents (inspiration, not imported)

Curator's note: the `awesome-claude-code` list evolves rapidly; the runtime `awesome-packs-index` skill captures the current top entries per-invocation. Items below are illustrative as of 2026-04-21:

- Numerous `/audit-*` commands from solo maintainers — good pattern source but often duplicate Ulak OS's `/director komple` surface; adopt only if a specific capability is missing
- `cartographer`-style tools — single-purpose repo-mapping; Ulak absorbs this as Phase 1 of the director protocol
- Various `claude-code-commands` bundles — useful as shape inspiration; extract via `/ulak-pattern-extract` if a specific command has cross-project value

## Integration workflow

If you identify a pack worth adopting into Ulak OS:

1. Run `/ulak-mcp-discover` (for MCPs) or invoke the `awesome-packs-index` skill (for non-MCP packs) to get a fresh audit
2. Run `/ulak-pattern-extract source="<pack>" target="<rule-pack-or-sector-pack>"` to pull the pattern into Ulak OS's canonical shape
3. Operator reviews the pattern-import-ledger entry + governance diff
4. Merge + tag as a minor bump (e.g., `v2.1.1` for a new rule-pack absorption)

## Reciprocal relationships

Ulak OS is itself a candidate for other lists:

- **`hesreallyhim/awesome-claude-code`** — submission draft in `docs/distribution/awesome-claude-code-pr.md`
- **`awesome-agentic-ai`** — candidate for "Agent Orchestrators" category
- **`awesome-nextjs`** — scaffolder fit
- **`awesome-supabase`** — scaffolder fit
- Plugin marketplaces (Claude Code + Cursor + Codex): submission prep in `.claude-plugin/` (CATEGORIES.md + RATIONALE.md + screenshots/)

## Out of scope

- Proprietary / closed-source packs (any non-MIT / non-Apache / non-BSD license flagged in `awesome-packs-index` is reported but never recommended)
- Binary-only distributions (prompt-OS packs must be text-auditable for governance to apply)
- Unmaintained packs (no commit in 180 days → `stagnant` flag; not recommended for adoption)

## Related

- [`.claude/skills/awesome-packs-index/SKILL.md`](../../.claude/skills/awesome-packs-index/SKILL.md) — runtime catalog
- [`.claude/skills/mcp-governance-auto/SKILL.md`](../../.claude/skills/mcp-governance-auto/SKILL.md) — MCP drift detection
- [`.claude/commands/ulak-pattern-extract.md`](../../.claude/commands/ulak-pattern-extract.md) — absorption workflow
- [`.claude/commands/ulak-mcp-discover.md`](../../.claude/commands/ulak-mcp-discover.md) — MCP discovery workflow
- [`docs/governance/mcp-governance.md`](../governance/mcp-governance.md) — MCP allowlist
- [`docs/governance/pattern-import-ledger.md`](../governance/pattern-import-ledger.md) — absorption ledger

## Canonical footer

Authoritative as of Ulak OS **v2.1.0**. Curated reference list refreshed quarterly; runtime catalog available per-session via `awesome-packs-index` skill.
