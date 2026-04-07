# Ulak OS Roadmap

## v1.0.0 (2026-04-07) — First Stable Public Release

**Status:** ✅ Released

- Brand transition Claude Ulak → Ulak OS
- Three-vendor adapter parity (Claude Code / Codex / Gemini CLI)
- Cross-platform bootstrap scripts (sh + ps1, 6 files)
- CI validation gates (schema, @import, brand, secrets)
- Public skill integration (superpowers mapping + /ulak-intake PoC wrapper)
- Multi-language: TR + EN parallel
- Sample artefacts (intake, inventory, manager-verdict in TR + EN)
- awesome-design-md integration (/ulak-design-ref wrapper + fetch script)
- Ecosystem related-work doc

## v1.1 Plan (research candidates)

### TOP PRIORITY — Plugin marketplace publication
Reference architectural pattern: `akin-ozer/devops-skills-plugin` (cross-vendor manifest pattern with shared `skills/` directory).

- Add `ulak-os/.claude-plugin/plugin.json` (minimal Claude Code marketplace metadata)
- Add `ulak-os/.codex-plugin/plugin.json` (rich Codex Desktop metadata: displayName, brandColor, screenshots, defaultPrompt, capabilities)
- Document the vendor-specific manifest + shared content pattern in `docs/distribution/plugin-manifests.md`
- Submit to Claude Code plugin marketplace
- Submit to Codex Desktop marketplace (when available)

### Skill / agent expansions
- 5 additional superpowers wrapper commands: `/ulak-roadmap`, `/ulak-validate`, `/ulak-evidence`, `/ulak-pack-gap`, `/ulak-final`
- Vendor-equivalent wrapper commands for Codex and Gemini
- Subagent inventory expansion based on `msitarzewski/agency-agents` patterns
- Performance tuning insights from `affaan-m/everything-claude-code`

### Public plugin integrations (high-value picks from osrt91 starred repos and installed marketplaces)

**trailofbits marketplace (security & quality):**
- `spec-to-code-compliance` — DIRECT match for Ulak OS spec-driven flow; integrate as quality gate
- `audit-context-building` — strengthen `intake`/`inventory` artefacts
- `ask-questions-if-underspecified` — wrap into `/ulak-intake` flow
- `skill-improver` — meta-skill for refining Ulak's own native skills
- `workflow-skill-design` — methodology for designing new wrapper commands

**claude-plugins-official (Anthropic):**
- `claude-md-management` — automate CLAUDE.md upkeep across the three adapters
- `pr-review-toolkit` — formalize the existing `requesting-code-review`/`receiving-code-review` mapping
- `feature-dev` — alternative path for the `EXTEND` intervention mode
- `commit-commands` — refine the two-commit strategy with native conventions

**MCP connectors (claude-plugins-official/external_plugins):**
- `github`, `gitlab` — extend `.mcp.json` (replace placeholder env-var setup with real MCP servers)
- `linear` — for issue tracking integration in `manager-verdict` artefacts
- `slack` — for `manager-verdict` notification flow
- `playwright` — for `/frontend-war-room` smoke tests
- `serena`, `supabase`, `terraform` — domain-specific connector zoo

### Multi-language expansion
- 🇫🇷 Français (FR)
- 🇩🇪 Deutsch (DE)
- 🇪🇸 Español (ES)
- 🇸🇦 العربية (AR)
- 🇯🇵 日本語 (JA)
- 🇨🇳 中文 (ZH)
- Quality-first translation discipline (no machine-only translations)

### Ecosystem deep integrations (research)

Each candidate requires its own brainstorming + spec + plan cycle in v1.1:

| Candidate | Purpose | Integration shape |
|---|---|---|
| **firecrawl/firecrawl** | Web scraping API | Enhances `research-currency` skill with structured web data |
| **HKUDS/LightRAG** | RAG knowledge base | Adds project memory layer; ingestion + retrieval pipeline |
| **googleapis/genai-toolbox** | MCP database server | Extends `.mcp.json` with Postgres/MySQL connectors |
| **magicuidesign/magicui** | UI component library | `/frontend-war-room` references concrete components |
| **agentscope-ai/agentscope** | Agent framework | Possible substrate layer; architectural review needed |
| **nextlevelbuilder/ui-ux-pro-max-skill** | UI/UX skill | Add to superpowers mapping; complement design-system-architect |
| **anthropics/skills** | Skill upstream | Direct skill imports + version tracking |

### Quality / testing
- Eval / golden prompt regression suite (`evals/`)
- Smoke test matrix (3 vendor × 5 commands) in GitHub Actions
- Real example projects under `examples/` (3 runnable demos, one per vendor)
- Rule collision matrix → deterministic hook (currently doc-only)

### Distribution / community
- Plugin marketplace publication (Claude Code plugin format)
- CODEOWNERS + issue/PR templates + GitHub Discussions
- CONTRIBUTING expansion + code of conduct
- Sponsor / donation setup if applicable

### Release semantics
- v1.0.x: bug fixes, doc fixes, no new features
- v1.1.0: first feature release after v1.0.0 — pick 2-3 from above
- v1.x.0: each feature release adds 2-3 candidates with stability gates
- v2.0.0: major architectural shift (e.g., agentscope substrate adoption, RAG layer)

## Decision principles

1. **Evidence before features** — every new candidate needs a brainstorming + spec + plan cycle before code
2. **Vendor parity** — anything added must work for all three vendors (or document why not)
3. **Quality > quantity** — better to ship 2 polished features than 8 half-baked ones
4. **YAGNI ruthlessly** — defer until real users ask for it
5. **i18n discipline** — TR + EN minimum, never machine translation only
