# Ulak OS Ecosystem & Related Work

[Türkçe](related-work.md) | English

Ulak OS sees itself not as an isolated product but as **part of an ecosystem**. This document lists public projects that directly inspired us, that can be used alongside Ulak OS, or that we consider complementary.

## Public skill / agent frameworks

### [obra/superpowers](https://github.com/obra/superpowers)
Agentic skill framework. Contains 15+ skills including brainstorming, TDD, debugging, plan writing/execution. Directly maps to Ulak OS's artefact chain; see [`docs/skills-integration/superpowers-mapping.md`](../skills-integration/superpowers-mapping.md) for mapping details.

### [anthropics/skills](https://github.com/anthropics/skills)
Anthropic's official Agent Skills public repository. The upstream point of the Claude Code skill ecosystem. Forms the foundation for superpowers and other marketplaces.

### [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
A curated list of Claude Code skills, plugins, agents, and commands. The answer to the question "what else is out there?"

## Spec-driven & meta-prompting systems

### [gsd-build/gsd-2](https://github.com/gsd-build/gsd-2)
Meta-prompting and spec-driven development system. The closest "related work" to Ulak OS's philosophy — both believe in the spec → plan → execute chain. Uses different tool call patterns but solves the same problem space.

### [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates)
Claude Code configuration CLI. An alternative design pattern for our init scripts. A reference for "how others bootstrap Claude Code."

## Design systems

### [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)
DESIGN.md files from 58+ brands (Stripe, Linear, Vercel, Notion, Tesla, etc.). Ulak OS's frontend agents use these files for evidence-based design decisions. Integration details: [`docs/skills-integration/awesome-design-md-integration.md`](../skills-integration/awesome-design-md-integration.md)

## Cross-vendor plugin pattern reference

### [akin-ozer/devops-skills-plugin](https://github.com/akin-ozer/cc-devops-skills)
A plugin that publishes the same `skills/` directory with both `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`. This is the **direct reference** cross-vendor manifest pattern that Ulak OS will use for future plugin marketplace publication.

## Research candidates (future evaluation)

The following projects will be evaluated for future Ulak OS releases; they are not yet shipped but will be tracked:

- **firecrawl/firecrawl** — Web scraping API, for the `research-currency` skill
- **HKUDS/LightRAG** — RAG knowledge base, for project knowledge base
- **googleapis/genai-toolbox** — MCP database server
- **magicuidesign/magicui** — UI component library
- **agentscope-ai/agentscope** — Agent framework substrate layer
- **msitarzewski/agency-agents** — Specialized agents agency patterns
- **nextlevelbuilder/ui-ux-pro-max-skill** — UI/UX skill for the superpowers pattern
- **affaan-m/everything-claude-code** — Agent performance optimization

Detailed roadmap: [`ROADMAP.md`](../../ROADMAP.md)

## Philosophical kinship

Ulak OS **learned the following** from this ecosystem:
- **Skill > prompt** distinction (superpowers, anthropics/skills)
- **Spec → plan → execute** discipline (gsd-2, superpowers/writing-plans)
- **Vendor-neutral adapter** pattern (hybrid core + three wrappers)
- **Public artefact + private execution** (manage-by-evidence)
- **Evidence-based design** (awesome-design-md)
- **Curated reusability** (awesome-claude-code, awesome-design-md)
- **Cross-vendor plugin manifest** pattern (akin-ozer/devops-skills-plugin)

Ulak OS combines these learnings with an **artefact chain** + **rule collision matrix** + **three-vendor adapter**.
