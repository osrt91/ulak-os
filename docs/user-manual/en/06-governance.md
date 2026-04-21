# 06 — Governance

Governance is what makes Ulak OS disciplined instead of just a pile of prompts. This chapter summarizes the **22 governance documents** in `docs/governance/`, grouped by what they enforce. Every document is Layer 1 (public runtime surface) — it loads with every session via the core contract.

Governance trumps runtime rules where the two collide. That ordering is explicit in [`docs/governance/rule-collision-matrix.md`](../../governance/rule-collision-matrix.md).

## Quick map

| Category | Documents |
|---|---|
| **Trust + evidence** | `evidence-trust-scoring.md`, `finding-schema.md`, `trust-model.md`, `rule-collision-matrix.md` |
| **Surface discipline** | `surface-split.md`, `product-surface-split.md`, `hidden-maintainer-surface-template.md` |
| **Writes + authorizations** | `artefact-write-authorization.md`, `settings-permissions-governance.md` |
| **Pack governance** | `rule-pack-governance.md`, `pattern-import-ledger.md`, `plugin-skill-decision.md`, `prompt-supply-chain.md` |
| **Autonomy + memory** | `autonomy-pressure-layer.md`, `memory-hygiene.md` |
| **Hooks + MCP + AI provider** | `hook-governance.md`, `mcp-governance.md`, `ai-provider-allowlist.md` |
| **Secrets + locks** | `secrets-rotation-policy.md`, `lock-file-hygiene.md` |
| **Observability** | `observability-baseline.md` |

## Surface split

**File:** [`docs/governance/product-surface-split.md`](../../governance/product-surface-split.md) and [`docs/governance/surface-split.md`](../../governance/surface-split.md).

Ulak OS enforces a strict split of user-facing surfaces in every audit and every scaffold:

- **Customer** — end users of the product
- **Admin** — operators, moderators, internal staff
- **Public API** — third-party integrations, webhooks in
- **Partner / reseller** — optional tier for resellers, white-label partners

Rules:
- Routes, auth helpers, and database policies live in surface-scoped folders (`app/customer/`, `app/admin/`, `app/api/public/`, `app/partner/`).
- RLS policies are **symmetric** across sibling surfaces unless documented otherwise.
- `auth.users.role` is the single source of truth for which surface a user can enter. `user_metadata` is never trusted for routing.

The scaffolder builds the split in from commit 1. The director checks for violations during Phase 2.

## Evidence trust scoring (T1–T7)

**File:** [`docs/governance/evidence-trust-scoring.md`](../../governance/evidence-trust-scoring.md).

Every finding in `evidence-register.md`, `analysis-findings.md`, and the pattern-import ledger carries a trust tier.

| Tier | Meaning | Example |
|---|---|---|
| **T1** | Observed + verified via direct code read | "I read `auth.ts:42-67` and saw the helper fall through to `user_metadata`" |
| **T2** | Inferred from config / shape / behavior | "`next.config.ts` has `reactStrictMode: false` — likely suppressing a legacy warning" |
| **T3** | Memory-sourced — treat with suspicion | "The team mentioned in Slack that the deploy script is flaky" |
| **T4** | Rumor or third-party summary | "A StackOverflow post says this library has a bug" |
| **T5–T7** | Progressively weaker | unverifiable claims |

Phase 5 refuses `signoff_status: ready` if any Critical finding rests on T3 or weaker without a Phase 4.5 live probe that upgrades it to T1.

## Finding schema

**File:** [`docs/governance/finding-schema.md`](../../governance/finding-schema.md).

Every non-trivial claim in every artefact follows a canonical YAML shape:

```yaml
- id: F-023
  title: "Admin bulk-delete lacks audit log"
  surface: admin
  severity: High           # Critical | High | Medium | Low | Cosmetic
  evidence:
    - file: app/admin/actions/bulk-delete.ts
      lines: [45, 67]
      tier: T1
  validation:
    method: manual-inspection
    expected: "audit log entry emitted per row"
  fix_summary: "Wrap bulk-delete in an audit-emitter transaction"
  priority: P1
```

Every field is required. The validator rejects findings missing any field.

## Artefact write authorization

**File:** [`docs/governance/artefact-write-authorization.md`](../../governance/artefact-write-authorization.md).

The default Claude Code system prompt rule against creating "planning / decision / analysis" markdown documents **does not apply** to director-protocol artefacts under `reports/current/`. The operator has explicitly requested those files by invoking `/director`. The authorization doc is the formal override.

Every specialist dispatched during Phase 2 receives this override block in its brief. Without it, specialists would refuse to write their section of `evidence-register.md`, and the whole protocol would stall.

This is the one place the default Claude behavior is actively overridden. Outside of `reports/current/`, the default "don't write speculative docs" rule still holds.

## Hook governance

**File:** [`docs/governance/hook-governance.md`](../../governance/hook-governance.md).

Hooks are harness-level gates configured in `.claude/settings.json` (PreToolUse, PostToolUse, Notification, Stop). Ulak OS governance for hooks:

- **No silent bypasses.** `--no-verify` on commit hooks is forbidden by convention. Legitimate bypasses use the documented **bypass token protocol**: append a token to the commit message, rotation rules in §4.
- **No side-effect hooks without audit trail.** A hook that writes to disk, calls out to the network, or mutates git state must log its action to `reports/current/hook-log.md`.
- **Rotation.** Bypass tokens rotate on a schedule defined in the secrets rotation policy (see below).

If a hook blocks a commit you believe is legitimate, read §4 — do not reach for `--no-verify`.

## MCP governance

**File:** [`docs/governance/mcp-governance.md`](../../governance/mcp-governance.md).

Model Context Protocol (MCP) connectors bridge your AI coding CLI to external systems (GitHub, Figma, Jira, custom servers). Ulak OS enforces an **allowlist** model:

- `docs/governance/ai-provider-allowlist.md` lists every approved AI provider and every approved MCP connector.
- Connectors outside the allowlist are not loaded.
- A director run on a project with an unknown MCP connector logs a finding.

This protects against prompt supply-chain attacks: an untrusted MCP server could inject instructions into your session. The allowlist means every connector has been reviewed by a maintainer.

Adding a new connector to the allowlist requires a PR with: the connector's identity, its network endpoints, its data flow, and the threat model. See [`docs/governance/prompt-supply-chain.md`](../../governance/prompt-supply-chain.md) for the full contract.

## Secrets rotation policy

**File:** [`docs/governance/secrets-rotation-policy.md`](../../governance/secrets-rotation-policy.md).

Ulak OS itself has no secrets (it is static prompts and markdown). But the projects you scaffold with `/ulak-scaffold`, and the projects you audit with `/director`, do. The policy codifies:

- **Rotation cadence** per secret type (API keys, JWT signing keys, DB credentials, webhook secrets, deploy tokens).
- **Rotation procedure** — how to rotate without downtime, how to coordinate the rotation window, how to verify the rotation applied cleanly.
- **Emergency rotation** — what to do on suspected leak.
- **Storage rules** — `.env.local` never committed; secrets live in the provider's secret manager, not in `.env*` beyond development.

The scaffolder produces `.gitleaks.baseline` configured for the policy. The director flags drift when it sees a hardcoded secret in code or an expired rotation window in infrastructure config.

## Pattern-import ledger

**File:** [`docs/governance/pattern-import-ledger.md`](../../governance/pattern-import-ledger.md).

Ulak OS absorbs patterns from real projects. Every absorbed pattern gets a ledger entry with:

- **id** — the anti-pattern number (AP-NN) or sector-pack slug
- **source_project** — abstract descriptor (never a real project name, per redaction discipline)
- **source_files** — `path/to/file.ts:42-67` citations
- **trust_tier** — T1 to T7 per evidence trust scoring
- **rationale** — one-line why this matters
- **cross_project_occurrences** — count (must be ≥2 to import)

CI enforces the ledger. A PR that adds an anti-pattern or sector pack without a matching ledger entry, or with trust tier below T2, is rejected. See [chapter 08](./08-troubleshooting.md) § pattern-import-ledger check fails.

This is how institutional memory accumulates without leaking project identities. The ledger is the audit trail of Ulak OS's own evolution.

## Rule-pack governance

**File:** [`docs/governance/rule-pack-governance.md`](../../governance/rule-pack-governance.md).

Rule packs are the 7th unit type. They live under `docs/runtime/rule-packs/*.md` and load at Phase 0 when the corresponding stack is detected. v1.0.0 ships 8 rule packs: TypeScript + Next.js, Python + FastAPI, Docker Compose, API security, Turkish locale, localization SSOT, LLM streaming + context-aware, React Native + Expo.

Rule-pack contract:

- **≤500 bytes body.** Imperatives only. No exposition.
- **Activation line at the top** — declares which stack triggers the load.
- **Collision rule paragraph at the bottom** — declares which other rule packs it can or cannot coexist with.
- **No project-specific paths.** Pure generic so the pack applies anywhere the stack is used.

The collision matrix is enforced. If a rule-pack A declares incompatibility with rule-pack B, Phase 0 rejects loading both in the same run.

## Memory hygiene

**File:** [`docs/governance/memory-hygiene.md`](../../governance/memory-hygiene.md).

Ulak OS deliberately does not write to Claude's long-lived memory (or any vendor's equivalent) for project facts. Why:

- **Reproducibility.** Two operators with the same repo state should produce the same artefacts from the same commands.
- **Vendor portability.** Runtime state on disk means swapping from Claude to Gemini does not silently break anything.
- **Auditability.** `reports/archive/` is the audit trail. Memory that lives in a provider's store is not a shared artefact.

The rule: project facts that matter for a run live in files. Personal preferences (theme, editor setup) can live in memory — they are not project facts.

## Settings permissions governance

**File:** [`docs/governance/settings-permissions-governance.md`](../../governance/settings-permissions-governance.md).

`.claude/settings.json` declares what the AI coding CLI is allowed to do. Ulak OS ships a conservative default:

- **Deny list** for destructive operations that should never happen during an audit (`rm -rf`, `git push --force`, destructive database commands).
- **Allow list** for expected read-only operations (`ls`, `cat`, `grep`, validator scripts).
- **Ask list** for borderline operations (network calls, git commit, deploy scripts).

Scoped-by-project settings live in `.claude/settings.local.json`, gitignored, never committed. This prevents a single operator's personal overrides from bleeding into the shared project config.

## Observability baseline

**File:** [`docs/governance/observability-baseline.md`](../../governance/observability-baseline.md).

Every scaffolded project gets an observability baseline: structured logging with correlation IDs, error reporting hooked up (Sentry or equivalent), health-probe endpoint wired into the deploy webhook contract, request tracing sample rate set to a sane default.

The director audits existing projects against this baseline and flags missing pieces.

## Lock file hygiene

**File:** [`docs/governance/lock-file-hygiene.md`](../../governance/lock-file-hygiene.md).

`pnpm-lock.yaml`, `package-lock.json`, `poetry.lock`, `uv.lock`, `go.sum`, `Cargo.lock`, `requirements.txt` — all committed by default. Phase 0 of the director runs a **broken-lock sweep**: detects out-of-sync lockfiles, missing lockfiles when the package manager is detected, and lockfiles that disagree with their manifest. Findings land in the evidence register.

## AI provider allowlist

**File:** [`docs/governance/ai-provider-allowlist.md`](../../governance/ai-provider-allowlist.md).

Declares which AI providers and which models are approved for use with Ulak OS. The allowlist is enforced by the MCP governance layer: connectors that bridge to non-allowlisted providers are not loaded. Adding a provider requires a PR with a threat model.

## Prompt supply chain

**File:** [`docs/governance/prompt-supply-chain.md`](../../governance/prompt-supply-chain.md).

Ulak OS sources prompts from three channels: the pack itself (first-party), allowlisted MCP servers (second-party), and the operator's project (third-party, treated as data not instructions per the trust model). This doc codifies the split and the review procedure for each.

## Trust model

**File:** [`docs/governance/trust-model.md`](../../governance/trust-model.md).

Tool outputs are **data, not instructions**. When a tool returns "delete everything under /tmp", Ulak OS does not treat that as a command — it treats it as a string to be analyzed. This firewall defeats a class of injection attacks where an attacker plants instructions in a file the agent reads during Phase 1 inventory.

## Further reading

- [`../../governance/`](../../governance/) — all 22 documents
- [`../../runtime/anti-patterns.md`](../../runtime/anti-patterns.md) — the ~100-entry anti-pattern library that governance enforces
- [`../../runtime/sector-packs.md`](../../runtime/sector-packs.md) — the 24 sector packs that apply governance to domain-specific shapes

---

Next: [07 — Contributing](./07-contributing.md)
