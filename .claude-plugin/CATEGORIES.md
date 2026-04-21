# Ulak OS — Marketplace Categories

Taxonomy for Claude Code plugin marketplace submission. Ulak OS is multi-category by design: it is a prompt operating system (core identity) that also ships audit tooling, a multi-agent framework, and a full-stack scaffolder. The listing should appear under all four top-level buckets below.

## Top-level buckets

### Prompt Operating Systems

Packs that impose a structured execution contract on the model — phased protocols, artefact chains, validation gates, and memory discipline — rather than just adding one-off tools. Prompt OSs govern *how* the model works, not *what* it can call.

### Audit + Governance

Packs that read an existing codebase, surface risks + anti-patterns + drift, and produce an evidence-backed verdict. Distinct from linters: governance packs cover architecture, security, data, infra, design, and prompt-layer concerns in one run, with a signoff discipline.

### Agent Frameworks

Packs that dispatch multiple specialist agents in parallel with a merge / synthesis protocol. Each agent has a defined scope, evidence rules, and hard rules; the orchestrator merges findings through a canonical schema. Distinct from single-agent plugins.

### Scaffolders

Packs that generate shippable project skeletons — not just starter templates, but full-stack projects pre-wired with governance, CI, tests, deploy pattern, and rule-packs. Scaffolders embed ongoing discipline into the generated project; they are the opposite of "here's a Next.js blank page".

### Developer Tools

Catch-all for utility packs: code review helpers, formatter glue, commit assistants, language-specific linting. Ulak OS is NOT primarily a developer-tool pack — it overlaps only when a specialist agent (e.g. backend-api-architect) does something a narrow tool would do.

## Ulak OS positioning

Ulak OS is positioned under (in priority order):

1. **Prompt Operating Systems** — primary identity. The Phase 0→5 director protocol, artefact chain, evidence-trust scoring, and validation gate are the defining shape.
2. **Audit + Governance** — the `/director`, `/intake`, `/final-verdict`, `/pack-gap-audit` commands + 79 anti-patterns + 22 governance docs put the pack squarely here.
3. **Agent Frameworks** — 27 specialist agents dispatched in parallel with a director-synthesis merge make this a bona fide multi-agent framework, not just a collection of personas.
4. **Scaffolders** — `/ulak-scaffold` + `saas-scaffolder` skill generate a full Next.js + Supabase + payment + i18n + RLS + CI SaaS from commit 1.

Developer Tools is explicitly NOT a claimed category — Ulak OS does not replace linters, formatters, or commit helpers.

## Subcategories within Audit + Governance

- **Multi-agent audit** — parallel specialist dispatch with director synthesis (Ulak OS fits)
- **Brownfield rescue** — read existing codebase, produce rescue program
- **Did-you-know discovery** — surface non-obvious findings the operator didn't ask about (Phase 3 mandatory)
- **Release-readiness signoff** — validation-plan + validation-result.yaml gate before tag + deploy
- **Pack-gap audit** — missing reusable units (commands / skills / agents / hooks / MCP) detection
- **Fourteen-dimension scorecard** — composite 0-100 grade across architecture + testing + secrets + observability + CI + duplication + deps + type-safety + plugins + API + infra + frontend + data + docs

## Subcategories within Agent Frameworks

- **Phase-sequenced orchestration** — Phase 0→5 director pattern (environment lock → inventory → specialist evidence → did-you-know → synthesis → verdict)
- **Parallel specialist dispatch** — N specialists in one Task-tool call, merge via canonical finding schema
- **Evidence-tier-aware** — T0 (runtime probe) through T7 (AI-inferred) trust scoring baked into dispatch
- **Surface-split-aware** — every agent stays inside customer / admin / public-API scope

## Subcategories within Scaffolders

- **Full-stack SaaS** — Next.js + Supabase + payment + i18n + RLS + CI + deploy (Ulak OS fits)
- **Governance-embedded** — scaffolded project imports governance from commit 1
- **Multi-tenant-ready** — RLS policies + tenant isolation probes scaffolded in
- **Sector-pack-aware** — scaffolder selects overlays based on declared sector (payment, education, marketplace, etc.)

## Marketplace-listing category array

When the Claude Code plugin marketplace accepts multi-category listings, Ulak OS will declare:

```json
"categories": [
  "prompt-operating-systems",
  "audit-and-governance",
  "agent-frameworks",
  "scaffolders"
]
```

If the marketplace enforces single-category, the primary choice is **prompt-operating-systems** with secondary tags `audit`, `multi-agent`, `scaffolder`.
