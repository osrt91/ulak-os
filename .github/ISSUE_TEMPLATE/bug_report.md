---
name: Bug report
about: Something in Ulak OS does not work as described (command, skill, agent, hook, template, or doc)
title: "[bug] "
labels: bug, needs-triage
assignees: ''
---

## Summary

<!-- One sentence describing what is broken. -->

## Environment

- Ulak OS version (tag or commit): `v…` / `git rev-parse HEAD`
- Claude Code / Codex / Gemini CLI version:
- OS + shell:
- Installation method: clone · submodule · plugin · scaffolder
- Target project type (if applicable): greenfield · brownfield · hybrid

## Repro steps

1.
2.
3.

## Expected

<!-- What the core contract, command doc, agent spec, or runbook says should happen. Cite file:line. -->

## Actual

<!-- What you observed. Paste artefact snippets (manager-verdict.md, evidence-register.md, …) if relevant. Redact secrets and project-specific names. -->

## Artefact scope (check if director run)

- [ ] `reports/current/runtime-manifest.md`
- [ ] `reports/current/intake.md`
- [ ] `reports/current/inventory.md`
- [ ] `reports/current/evidence-register.md`
- [ ] `reports/current/did-you-know.md`
- [ ] `reports/current/validation-plan.md`
- [ ] `reports/current/manager-verdict.md`

## Governance flags

- [ ] Bug touches the **public runtime surface** (core contract / runtime rules / governance)
- [ ] Bug touches only **hidden maintainer surface** (internal release notes / archive)
- [ ] Bug exposes **project-name or secret leak** — if yes, STOP and email **info@oguzhansert.dev** directly instead of filing this issue

## Additional context

<!-- Related ADRs, prior issues, pattern-import ledger entries, or links. -->
