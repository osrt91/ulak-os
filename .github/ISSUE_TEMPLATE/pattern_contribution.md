---
name: Pattern contribution
about: Propose a cross-project pattern for absorption into Ulak OS (sector pack, rule pack, anti-pattern, or runtime rule)
title: "[pattern] "
labels: pattern-contribution, needs-triage
assignees: ''
---

## Pattern name

<!-- Short descriptive name. Examples: "webhook-ci-deploy", "turkish-locale-normalization", "shared-supabase-rotation". -->

## Classification

- [ ] **Sector pack** — domain-specific bundle (e.g., `admin-cms-hardening`, `payment-integrated-saas`)
- [ ] **Rule pack** — orthogonal technical constraint layer (e.g., `typescript-nextjs`, `turkish-locale`)
- [ ] **Runtime rule** — new mandatory discipline (e.g., `live-probe-contract`)
- [ ] **Anti-pattern** — shape to be flagged and refused (append to `docs/runtime/anti-patterns.md`)
- [ ] **ADR** — architectural decision record
- [ ] Extension to an existing unit (specify)

## Source evidence

How many independent projects exhibit this pattern?

- Projects / codebases observed (abstract descriptors, NO real project names — see `CONTRIBUTING.md` redaction discipline):
  - e.g., "a multi-app Next.js monorepo with shared CMS"
  - e.g., "a Turkish-first SaaS with 11 locales"
- Trust tier per `docs/governance/evidence-trust-scoring.md`:
  - [ ] T1 — direct file:line citations
  - [ ] T2 — cross-verified by a second specialist agent
  - [ ] T3+ — lower confidence

Minimum bar for inclusion: **two independent sources** with **T1 or T2** evidence.

## Pattern shape

<!-- Abstract description of the shape. What does the surface look like? What inputs, outputs, side effects? -->

## Why it matters

<!-- What breaks or gets worse in projects that do NOT apply this pattern? Cite real examples abstractly. -->

## Proposed absorption

**Target file**:

**New section / new file**:

**Imports / cross-references required**:

## Governance checklist

- [ ] No real project names in the proposal (operator/portfolio names are banned in public docs)
- [ ] No secrets, tokens, or credentials pasted (even partially)
- [ ] `pattern-import-ledger.md` entry drafted (if importing from an external source)
- [ ] Anti-pattern variants documented (if this pattern has a known failure mode)

## Validation plan

<!-- How will we evaluate the pattern against the golden set / evals? What assertion catches regressions? -->
