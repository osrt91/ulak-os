# Ulak OS — Marketplace Screenshots

This directory holds screenshot assets for the Claude Code plugin marketplace listing. Screenshots are operator-captured from real runs and will be added post-launch.

## Planned captures

1. **`01-director-phase-0.png`** — `/director komple` invocation, showing Phase 0 environment lock with `runtime-manifest.md`, `assumptions.md`, `active-variables.yaml` produced on disk. Caption: "Every run pins the environment before any intervention."

2. **`02-parallel-specialist-dispatch.png`** — Phase 2 dispatching 8+ specialist agents in parallel (backend-api-architect, data-database-governor, security-hardening-lead, infra-release-sre, design-system-architect, qa-validation-commander, red-team-challenger, prompt-skill-plugin-governor). Caption: "Parallel specialist evidence — not single-generalist opinions."

3. **`03-did-you-know.png`** — Phase 3 did-you-know.md surfacing non-obvious findings the operator didn't ask about (e.g. RLS asymmetry on a forgotten table, unused dependency, stale migration). Caption: "Did-you-know — mandatory non-obvious discovery."

4. **`04-validation-result.png`** — Phase 5 validation-result.yaml with structured signoff (`ready` / `conditional` / `blocked`), live-probe results table, residual-risk ledger. Caption: "Nothing ships until validation signs off."

5. **`05-scaffold-new-saas.png`** — `/ulak-scaffold product_name=my-saas product_domain=saas` producing the full Next.js + Supabase + payment + i18n + RLS + CI + deploy project skeleton with governance pre-wired. Caption: "Commit 1 already has 79 anti-patterns + 8 rule packs + 24 sector packs loaded."

## Capture discipline

- Screenshots must be from REAL runs on operator-owned projects (no mocked terminals, no faked file trees)
- Redact: project names, customer data, API keys, URLs that map to operator's portfolio
- Resolution: 1920×1080 minimum for terminal captures; 2560×1600 for UI / file-tree captures
- Format: PNG with lossless compression; SVG for diagrams
- Filename: `NN-descriptive-slug.png` with zero-padded ordinal

## Linking

The marketplace listing metadata (`.claude-plugin/plugin.json → screenshots[]`) points at relative paths under this directory. When captures land, update the array; if a capture is replaced, keep the filename stable to avoid cache-busting the marketplace thumbnail.

## Status

Currently empty. Captures will land during the v3.0 public launch window. Operator captures when the timing is right; until then, the marketplace listing shows the rendered README + RATIONALE as the primary pitch.
