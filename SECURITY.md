# Security Policy

## Reporting a vulnerability

**Do not open a public GitHub issue for security-sensitive problems.** Public disclosure before a fix can put downstream users at risk.

Instead, email the maintainer directly:

- **Primary contact:** `info@oguzhansert.dev`
- **Response SLA:** first acknowledgement within 72 hours; initial triage within 5 business days; patch timeline depends on severity

## What counts as a security issue

Email rather than file a public issue if your report includes any of:

- Credential, token, or secret exposure in the repo, git history, CI logs, or generated artefacts
- Auth bypass, privilege escalation, injection (SQL / command / LLM-prompt), SSRF, webhook signature bypass, or multi-tenant escape in the scaffolder templates or any pack-included skill
- Supply-chain or dependency vulnerability (malicious upstream, typo-squatting, compromised pin)
- Hook or MCP surface that executes unreviewed user-controlled input
- Proof-of-concept that makes the `/director` or `/ulak-scaffold` protocol produce false signoffs under adversarial prompts

## What to include

- Affected Ulak OS version or commit SHA
- Affected file path(s) and line numbers, or adversarial input that triggers the issue
- Minimal reproduction (command sequence, input file, expected vs actual)
- Your assessment of severity and blast radius
- Whether you're open to coordinated disclosure and the timeline you prefer

## What to expect back

- Acknowledgement (within 72 hours)
- Triage verdict (affected surface, severity, fix path)
- Coordinated-disclosure timeline (typical: 14–90 days depending on severity and upstream dependencies)
- Credit in the advisory + CHANGELOG unless you request anonymity

## Scope

**In scope:**

- This repository's runtime contract, commands, skills, agents, hooks, templates, and scripts
- Installer scripts (`scripts/install.sh`, `scripts/install.ps1`, `bin/ulak`)
- Governance + pack-unit defaults that ship in a cold clone

**Out of scope:**

- Vulnerabilities in third-party LLM providers (Anthropic, OpenAI, Google) — report to the respective vendors
- Vulnerabilities in Claude Code / Codex / Gemini CLI themselves — report to the respective vendors
- Vulnerabilities in a scaffolded project after the operator runs `/ulak-scaffold` — those are in the operator's own repo, not this one (though if a scaffolder template is to blame, that IS in scope)
- Social-engineering or operator-misconfiguration scenarios

## Known acknowledged incidents

- [SEC-INCIDENT-2026-04-21 — v2.1.4 tag credential leak](./docs/security/incidents/2026-04-21-v2.1.4-tag-credential-leak.md) — Resend + Cloudflare keys were recoverable from public v2.1.4 tag. **RESOLVED** via local git-filter-repo history rewrite (2026-04-21 evening). Force-push to origin pending operator approval. Key rotation still recommended (defense-in-depth).

## Hall of fame

Accepted reports will be credited here unless anonymity is requested.

— *(none yet — first report goes here)*
