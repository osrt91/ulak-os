<!--
Thanks for contributing to Ulak OS. Fill every section. Blank sections slow triage.

If this PR exposes operator/portfolio project names, secrets, or paths, STOP and revise
before pushing. Public docs must use abstract descriptors (see CONTRIBUTING.md §redaction).
-->

## Summary

<!-- 1-3 sentences: what this PR changes and why. -->

## Type of change

- [ ] New pack unit (command / skill / agent / hook / sector pack / rule pack / runtime rule / governance / template)
- [ ] Fix / patch (bug, redaction, link, schema)
- [ ] Expansion of existing unit (thin → full)
- [ ] ADR (architectural decision record)
- [ ] Docs-only (README, runbook, showcase, FAQ)
- [ ] Release (version bump + CHANGELOG + tag)

## Linked issue / ADR

<!-- #NN or docs/adr/ADR-NNN-....md -->

## What changed (file-level)

<!-- Bullet list. Group by directory. -->

## Validation

Ran locally:

- [ ] `bash scripts/validate-imports.sh` — passes
- [ ] `bash scripts/validate-schemas.sh` — passes
- [ ] `bash scripts/validate-vendor-parity.sh` — passes (or exemption documented)
- [ ] Touched agent / skill / command files still parse (front-matter intact)
- [ ] No new cycle / unresolved `@`-import

## Governance checklist

- [ ] Public runtime surface changes documented (`docs/governance/surface-split.md` respected)
- [ ] Customer / admin / public API separation preserved
- [ ] No real project names, portfolio URLs, or operator-internal paths leaked in public docs
- [ ] No secrets / API keys / tokens in any file (incl. examples — use `REDACTED_*` placeholders)
- [ ] `.gitignore` covers any new local-only files produced by this change
- [ ] If a new pack unit: `pack-gap-register` or `plugin.json` updated if surfaces the unit publicly
- [ ] Turkish orthography preserved if Turkish content is touched (diacritics intact)

## CHANGELOG

- [ ] `CHANGELOG.md` entry added under the right version (or `[Unreleased]`)
- [ ] Version bump synchronized across `package.json`, `prompts/pack.json`, `.claude-plugin/plugin.json` (if this is a release PR)
- [ ] Release notes drafted in `docs/release/` (if this is a major or minor)

## Out of scope

<!-- What this PR deliberately does NOT do. Link follow-up issues if needed. -->

## Screenshots / artefact samples (optional)

<!-- Attach manager-verdict snippets, scaffolder tree output, or before/after diffs. Redact project-specific names. -->
