# awesome-claude-code PR draft

This file is a ready-to-copy submission to [`hesreallyhim/awesome-claude-code`](https://github.com/hesreallyhim/awesome-claude-code). Operator opens the upstream PR manually; this document is not itself a PR.

## Why submit

Ulak OS is a vendor-neutral **prompt operating system** for Claude Code / Codex / Gemini CLI. It delivers deterministic audit (`/director komple`), deterministic scaffolding (`/ulak-scaffold`), and a governance layer (7-type pack-unit taxonomy, Phase 0→5 director protocol, evidence trust scoring, validation gates). It is larger in scope than a single skill bundle or a single scaffolder — but every piece is opt-in and individually reusable.

`awesome-claude-code` lists Claude-specific tools, skills, commands, agents, and plugins. Ulak OS belongs under **Agent Orchestrators** (the director) and **Scaffolders** (the SaaS starter). It is also legitimately a candidate for a **Prompt Operating Systems** sub-heading if the curator wants to introduce that bucket.

## Suggested placement

### Option A — under an existing category

Under `## Agent Orchestrators`:

> - **[Ulak OS](https://github.com/osrt91/ulak-os)** — vendor-neutral prompt OS with a Phase 0→5 director protocol, 18 specialist agents, parallel-dispatched deep audit, and a 7-type pack-unit taxonomy (commands · skills · agents · hooks · sector packs · rule packs · runtime rules · governance). Works across Claude Code, Codex/Copilot CLI, and Gemini CLI. MIT. Turkish- and English-first.

Under `## Scaffolders`:

> - **[Ulak OS `ulak-scaffold`](https://github.com/osrt91/ulak-os#scaffold)** — `ulak-scaffold <project> --sector payment-integrated-saas --stack nextjs-supabase` produces a Next.js + Supabase + TypeScript + Tailwind + Playwright project with RLS enabled, audit log, tenant isolation, CI gate, preflight hook, webhook-triggered deploy, and VPS hardening templates — deterministic from commit 1.

### Option B — propose a new category

> ## Prompt Operating Systems
>
> Vendor-neutral meta-tools that orchestrate commands + agents + governance across multiple LLM CLIs.
>
> - **[Ulak OS](https://github.com/osrt91/ulak-os)** — … (as above)

## PR checklist (maintainer expectations)

Most `awesome-*` lists enforce:

- One-line entry per project with link + description (Ulak OS entry above is ~40 words; within typical norms)
- Alphabetical order within category
- Link resolves; README is informative; license is permissive (Ulak OS = MIT ✅)
- Project is active (Ulak OS shipped within the last 30 days of PR submission ✅)
- No self-promotion beyond the factual entry

## Submission steps (operator)

1. Fork `hesreallyhim/awesome-claude-code`
2. Create branch `add-ulak-os`
3. Edit `README.md` — insert the entry/entries above in alphabetical order within the chosen category
4. Open PR with title: `Add Ulak OS — vendor-neutral prompt OS (audit + scaffold + governance)`
5. PR body: link to Ulak OS README, note "shipped as v1.0.0 public GA on 2026-04-21", note MIT license, note multi-vendor adapter (Claude / Codex / Gemini)
6. Respond to maintainer feedback; shorten or rephrase the entry if asked

## Timing

Submit **after** `v1.0.0` tag is pushed to `origin` and the README renders as expected on github.com. Do not submit before the repo is ready for a cold-clone by a stranger.

## Alternative lists to consider

- `awesome-agentic-ai` — agent-framework-oriented
- `awesome-developer-tools` — generic dev-tool lists
- `awesome-nextjs` (for `ulak-scaffold` Next.js starter)
- `awesome-supabase` (same reason)

Operator decides whether to submit to each; this document only drafts the primary `awesome-claude-code` entry.
