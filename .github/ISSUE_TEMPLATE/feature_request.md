---
name: Feature request
about: Propose a new command, skill, agent, hook, sector pack, rule pack, runtime rule, or governance doc
title: "[feat] "
labels: enhancement, needs-triage
assignees: ''
---

## One-line pitch

<!-- "Add X so that Y." No more than 25 words. -->

## Proposed pack unit

Which of the seven pack unit types best fits this request?

- [ ] Command (`.claude/commands/`)
- [ ] Skill (`.claude/skills/`)
- [ ] Agent (`.claude/agents/`)
- [ ] Hook (`.claude/settings.json`)
- [ ] Sector pack (`docs/runtime/sector-packs.md`)
- [ ] Rule pack (`docs/runtime/rule-packs/`)
- [ ] Runtime rule (`docs/runtime/`)
- [ ] Governance doc (`docs/governance/`)
- [ ] Scaffolder template (`templates/`)
- [ ] Other (explain)

See `docs/governance/plugin-skill-decision.md` for unit-type selection guidance.

## Problem

<!-- What shortcoming in current Ulak OS does this address? Cite examples from real audits, build runs, or patterns observed across projects. Abstract project names per CONTRIBUTING.md redaction discipline. -->

## Proposed design

<!-- What files change, what the new unit declares, how it interacts with existing units. -->

## Impact surface

- [ ] Customer-facing
- [ ] Admin-facing
- [ ] Public API
- [ ] Research / execution separation affected
- [ ] Public runtime surface (Layer 1 — breaking if removed)
- [ ] Hidden maintainer surface (Layer 2 — internal only)

## Validation plan

<!-- How will we know this works? Golden-set entry, eval assertion, live-probe, manual replay scenario. -->

## Out of scope

<!-- What this request deliberately does NOT cover, so reviewers don't scope-creep it. -->

## Alternatives considered

<!-- Existing units, superpowers skills, or commands that could do this today. Why are they insufficient? -->

## Would you submit a PR?

- [ ] Yes — I plan to implement this
- [ ] Maybe — need design feedback first
- [ ] No — proposing for maintainers
