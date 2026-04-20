# ADR-005 — SaaS Scaffolder: "Ulak OS Produces Full-Stack SaaS from Commit 1"

**Status**: Accepted · **Date**: 2026-04-20 · **Release**: v2.2.2 · **Templates complete**: v2.2.3

## Context

By v2.2.1, Ulak OS had strong **audit / plan / govern** capability — 24 sector packs, 8 rule packs, 79 anti-patterns, 22 governance docs. A user cloning the repo could audit existing projects and get a ship-ready roadmap. But they could not **start a new project** with Ulak governance applied from commit 1.

The gap manifested in real operator usage: every new SaaS started the same way — manually setting up Next.js + Supabase + auth + payment + i18n + CI + deploy, and retrofitting Ulak discipline two weeks later via `/director komple`. The audit would find P0 blockers that were preventable if the discipline had been baked in from commit 1.

v1.0 showcase goal requires: "someone clones Ulak OS and produces a full-stack SaaS." Audit-only doesn't meet that bar.

## Decision

Introduce the SaaS scaffolder stack:

1. **Command**: `/ulak-scaffold` — operator-triggered entry point
2. **Skill**: `saas-scaffolder` — the orchestrating skill that materializes the target directory
3. **Sector pack**: SP-14 `greenfield-saas-starter` — activation profile for greenfield SaaS creation
4. **Templates**: `templates/saas-starter/` — 15+ file templates with `{{variable}}` substitution

The scaffolder produces a target directory containing Next.js 16 + TypeScript strict + Supabase + optional Stripe/Iyzico + i18n SSOT + RLS policies + CI workflows + pre-push parity + webhook-deploy with health probe + VPS hardening script + product-surface-split route prefixes + single auth helper + design system reference from awesome-design-md — all with Ulak governance imports baked into CLAUDE.md from commit 1.

## Alternatives considered

1. **Yeoman / cookiecutter / create-next-app style generator** — rejected because those don't embed cross-project governance; they produce starter code but not discipline. Ulak OS scaffolder ships discipline + starter, not just starter.
2. **Fork-a-template-repo approach** (Turbo starter template, T3 Stack, etc.) — rejected because templates drift from Ulak OS versions; the scaffolder as a first-class capability keeps templates in-repo, versioned with the governance they embed
3. **AI-driven one-shot prompt** ("generate me a SaaS") — rejected because non-deterministic output can't guarantee anti-pattern prevention at the file level. Static templates with `{{variable}}` substitution are deterministic.
4. **External tool** (shell script outside Ulak OS) — rejected because that would split governance ownership; keeping it as a command + skill inside the pack ensures every Ulak OS release updates the scaffolder alongside
5. **Commercial or paid tier** — rejected because this is the operator's private toolkit; scaffolder value comes from using it repeatedly across the portfolio

## Consequences

**Positive**:
- v1.0 showcase promise achievable: clone ulak-os → `/ulak-scaffold` → shippable SaaS
- Anti-patterns prevented by construction at commit 1 (AP-06, AP-10, AP-11, AP-12, AP-13, AP-16, AP-18, AP-19)
- Portfolio consistency: every new SaaS inherits the same discipline; no drift across the operator's products
- First director run on the scaffolded project has near-zero critical findings (governance was in from day 1, not retrofitted)
- Design reference integration (awesome-design-md) lets scaffolded projects inherit visual discipline, not just technical discipline

**Negative**:
- Templates must be maintained alongside Ulak OS releases; every sector-pack or anti-pattern change that affects generated code requires a template update
- Opinionated stack choice (Next.js 16 + Supabase + Traefik) — projects with different stacks can't use the scaffolder as-is (mitigated: sector-pack activation switches behavior; future releases will add alternative stack templates)
- First generation requires a `/ulak-scaffold` run + manual `.env.local` filling — not pure "one command and done"

**Migration**: None required (new capability; existing audit/govern workflows unchanged).

## Implementation phases

- **v2.2.2** (2026-04-20) — Infrastructure: command + skill + sector pack + 5 seed templates (README, CLAUDE.md, .env.example, .gitignore, package.json)
- **v2.2.3** (2026-04-20) — Core templates complete: +10 templates (middleware, auth, RLS, CI, deploy, preflight, VPS hardening, DESIGN.md, ...)
- **v2.3.0** — Finalize the starter: +12 templates (tsconfig, next.config, tailwind, layout.tsx, landing, supabase clients, tests, .claude settings, docker-compose, dependabot, .gitleaks.toml)
- **v3.0** — Alternative stack templates (Remix, SvelteKit, FastAPI-backend variants)

## References

- `.claude/commands/ulak-scaffold.md` — command
- `.claude/skills/saas-scaffolder/SKILL.md` — skill
- `docs/runtime/sector-packs.md §SP-14 greenfield-saas-starter` — sector pack
- `templates/saas-starter/` — templates directory
- `docs/references/brand-design-index.md` — 59-brand design reference index
- `CHANGELOG.md §[2.2.2]` + `§[2.2.3]` — release notes
- `reports/current/wording-manager-intake.md` (local) — first operator intake using this capability
