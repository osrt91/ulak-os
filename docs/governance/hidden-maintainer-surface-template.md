# Hidden Maintainer Surface — authoring template

## Why this exists

Ulak OS splits documentation into two layers (see `docs/governance/surface-split.md`):

- **Public runtime surface (Layer 1)** — docs that every active run loads via `@`-imports; reachable from `prompts/core/ulak-os-core-contract-*.md`.
- **Hidden maintainer surface (Layer 2)** — docs that describe operator-internal operations, historical context, failed experiments, and deprecation trails. Not auto-loaded. Not shipped to consumers of `/director`, `/ulak-scaffold`, etc.

This template defines **what belongs on the hidden surface** and how to shape files that live there so they remain discoverable to maintainers without leaking into the public runtime surface.

## What belongs here

- **Changelog internals** — per-session notes, amendment rationales, post-mortem summaries that go beyond the user-facing `CHANGELOG.md`
- **Failed experiments** — patterns tried and abandoned, with reason-for-retreat (prevents re-litigating bad ideas)
- **Regression notes** — individual bug reproducers + fixes, cross-referenced from the commit that resolved them
- **Routing heuristics** — internal decision logs for why a command/skill/agent routes as it does (user-facing behavior stable; internal rationale evolves)
- **Deprecation notes** — plans to retire a surface, with migration window and consumer impact analysis
- **Compatibility concerns** — vendor adapter drift notes, CLI version incompatibilities, MCP protocol quirks
- **Operator-only runbooks** — secret rotation procedures with specific vault/dashboard paths, internal contact escalation chains
- **Pattern extraction drafts** — preliminary pattern-import-ledger candidates before they graduate to T1/T2 evidence + canonical rule pack

## What does NOT belong here

- User-facing documentation (even if technical) — that is Layer 1
- Real credentials or secret values (see `docs/governance/secrets-rotation-policy.md` — secrets never go in docs, hidden or not)
- Operator portfolio project names (the project-name redaction discipline applies across both layers)
- Customer data, support-ticket content, or any third-party PII

## Authoring conventions

1. **File naming**: `docs/governance/hidden/<topic>.md` (preferred) or `docs/internal-releases/<version>-<topic>.md` for per-release maintainer notes.
2. **Front-matter**: lead with a single-line "hidden-maintainer-surface" banner so future readers know the layer.
3. **No `@`-imports**: a hidden surface file must never be referenced from `prompts/core/`, `CLAUDE.md`, or any other auto-loaded doc. The import graph is how surface separation is enforced.
4. **Gitignore treatment**: hidden files are committed (operator audit trail) but may be excluded from release tarballs via `.npmignore` / `files` field (post-v1.1 CLI).
5. **Redaction**: same discipline as public — no portfolio names, no secrets, no third-party PII.

## Example skeleton

```markdown
# Hidden: <topic> — maintainer note

**Layer**: hidden maintainer surface (not auto-loaded)
**Created**: YYYY-MM-DD
**Author**: <operator handle>
**Resolves / relates to**: <commit SHA or external ticket>

## Context
<1-2 paragraphs — what happened or what this documents>

## Decision / notes
<prose + bullets>

## Cross-references
- <commit SHA + subject>
- <related public doc>

## Expiry / archive policy
<when this note becomes stale; whether to delete or archive>
```

## Integration

- `docs/governance/surface-split.md` — defines the two layers; this template extends it with hidden-layer authoring.
- `docs/archive/internal-releases/*.md` — the internal-release note trail; consistent with this template's shape.
- `docs/governance/prompt-supply-chain.md` — discusses how Layer 1 contents are audited for supply-chain integrity; hidden layer is excluded from supply-chain scope because it never loads.

## Canonical footer

Authoritative as of Ulak OS **v1.0.1**. Expanded from v1.0.0 stub (11 lines → this doc) per cartography finding CART-006. Future: move under `docs/governance/hidden/` subdirectory when the first real hidden-surface file lands.
