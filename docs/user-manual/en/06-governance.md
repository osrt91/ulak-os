# 06 — Governance

Governance is what makes Ulak OS disciplined instead of just a pile of prompts. This chapter summarizes the **22 governance documents** in `docs/governance/`, the **7 ADRs** in `docs/adr/`, the **4 runbooks** in `docs/runbooks/`, the **4 tutorials** in `docs/tutorials/`, the **3 showcase walkthroughs** in `docs/showcase/`, and the **47-term beginner glossary** at `docs/runtime/beginner-glossary.md`. All governance documents are Layer 1 (public runtime surface) — they load with every session via the core contract.

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
| **Vendor + localization (NEW v1.6)** | `vendor-capability-matrix.md`, `localization-governance.md` |

That is 22 documents total, matching the disk.

## Content layers beyond governance

v1.6 added curated content layers that complement governance. These are not governance docs themselves but they are load-bearing for operator success.

### 7 ADRs — `docs/adr/`

| ADR | Topic |
|---|---|
| ADR-000 | Pack foundation |
| ADR-001 | Rule packs as the seventh unit type |
| ADR-002 | Phase 5 as terminal |
| ADR-003 | Product surface split vs runtime (v2.x) |
| ADR-004 | Pattern-import ledger |
| ADR-005 | SaaS scaffolder |
| (planned) | Vendor-capability-matrix as governance |

### 4 runbooks — `docs/runbooks/`

| Runbook | Covers |
|---|---|
| `install-methods.md` | All five install paths with trade-offs |
| `troubleshooting.md` | 16+ failure modes, deeper than chapter 08 |
| `first-hour-with-ulak-os.md` | Clone → first audit → first scaffold → first commit in 60 min |
| `upgrading-from-v2.x.md` | Migration guide for operators on older versions |

### 4 tutorials — `docs/tutorials/` (NEW v1.6)

Beginner-oriented step-by-step guides for external services that `/ulak-scaffold` references but cannot automate (account signup, API key retrieval).

| Tutorial | Covers | Duration |
|---|---|---|
| `supabase.md` | Account + project + API keys + migration push + first admin | 15 min |
| `vercel.md` | Account + GitHub connection + env vars + deploy + custom domain | 10 min |
| `github.md` | Account + repo creation + SSH key + first push | 10 min |
| `resend.md` | Account + API key + domain verify + first email | 5 min |

### 3 showcase walkthroughs — `docs/showcase/` (NEW v1.6)

End-to-end annotated runs showing exactly what each workflow produces. `/ulak-demo` links to these.

| Walkthrough | Covers |
|---|---|
| `01-audit-walkthrough.md` | `/director komple` on a fictional brownfield (~150 lines) |
| `02-scaffold-walkthrough.md` | `/ulak-scaffold` for a greenfield payment-integrated SaaS (~120 lines) |
| `03-persona-audit.md` | `/director dispatch=persona` with four personas (~130 lines) |
| `04-cross-project-absorption.md` | Pattern extraction across two fictional products (~100 lines) |
| `video-script.md` | 5-minute screenplay for a demo video |

### 47-term beginner glossary — `docs/runtime/beginner-glossary.md` (NEW v1.6)

The lookup source for `/ulak-explain`. Each term defined in five fields: Simple / Technical / Analogy / In Ulak / Related. Covers RLS, JWT, CORS, webhook, idempotency, migration, seeding, RPC, edge function, middleware, CSRF, HMAC, and 35 more.

## Surface split

**File:** [`docs/governance/product-surface-split.md`](../../governance/product-surface-split.md) and [`docs/governance/surface-split.md`](../../governance/surface-split.md).

Ulak OS enforces a strict split of user-facing surfaces:

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

Every finding carries a trust tier.

| Tier | Meaning | Example |
|---|---|---|
| **T1** | Observed + verified via direct code read | "I read `auth.ts:42-67` and saw the helper fall through to `user_metadata`" |
| **T2** | Inferred from config / shape / behavior | "`next.config.ts` has `reactStrictMode: false` — likely suppressing a legacy warning" |
| **T3** | Memory-sourced — treat with suspicion | "Team mentioned in Slack the deploy script is flaky" |
| **T4** | Rumor or third-party summary | "A StackOverflow post says this library has a bug" |
| **T5–T7** | Progressively weaker | unverifiable claims |

Phase 5 refuses `signoff_status: ready` if any Critical finding rests on T3 or weaker without a Phase 4.5 live probe that upgrades it to T1.

## Finding schema

**File:** [`docs/governance/finding-schema.md`](../../governance/finding-schema.md).

Every non-trivial claim follows a canonical YAML shape:

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

Every field is required.

## Artefact write authorization

**File:** [`docs/governance/artefact-write-authorization.md`](../../governance/artefact-write-authorization.md).

The default Claude Code rule against creating "planning / decision / analysis" markdown documents **does not apply** to director-protocol artefacts under `reports/current/`. Every specialist dispatched during Phase 2 receives this override block in its brief.

This is the one place the default Claude behavior is actively overridden. Outside of `reports/current/`, the default "don't write speculative docs" rule still holds.

## Hook governance

**File:** [`docs/governance/hook-governance.md`](../../governance/hook-governance.md).

Hooks are harness-level gates configured in `.claude/settings.json`. Ulak OS rules:
- **No silent bypasses.** `--no-verify` is forbidden; legitimate bypasses use the documented **bypass token protocol**.
- **No side-effect hooks without audit trail.**
- **Rotation.** Bypass tokens rotate per the secrets rotation policy.

## MCP governance

**File:** [`docs/governance/mcp-governance.md`](../../governance/mcp-governance.md).

Model Context Protocol connectors bridge your CLI to external systems (GitHub, Figma, Jira). Ulak OS enforces an **allowlist** model. Connectors outside the allowlist are not loaded. A director run on a project with an unknown MCP logs a finding.

Discovery layer (v1.6): `/ulak-mcp-discover` candidates new community MCPs for operator review — governance-gated, never auto-installed.

## Vendor capability matrix (NEW v1.6)

**File:** [`docs/governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md).

Enforced single source of truth for which command / skill / agent / sector pack works on which vendor (Claude Code, Codex, Copilot, Gemini). Three status levels:

- **✓ full** — native vendor support
- **🟡 partial** — supported via NL trigger map, serial fallback, or reduced scope
- **❌ exempt** — documented exemption with rationale

Adding a new command without a matrix entry fails `scripts/validate-vendor-parity.sh`. Exemption entries require rationale text.

## Localization governance (NEW v1.6)

**File:** [`docs/governance/localization-governance.md`](../../governance/localization-governance.md).

Bilingual parity (TR + EN) enforcement across the entire public surface:
- Every command has `description` (TR) and `description_en` (EN) frontmatter.
- Every governance doc, ADR, runbook, tutorial, and walkthrough has a TR and EN version.
- `scripts/validate-bilingual.sh` compares TR/EN doc inventories and fails the build on drift.
- The `sync-gemini-commands.sh` script keeps `.gemini/commands/*.toml` aligned with `.claude/commands/*.md`.

## Secrets rotation policy

**File:** [`docs/governance/secrets-rotation-policy.md`](../../governance/secrets-rotation-policy.md).

Rotation cadence, procedure, emergency rotation, and storage rules. `.env.local` never committed; secrets live in the provider's secret manager beyond development. The scaffolder produces `.gitleaks.baseline` configured for the policy.

## Pattern-import ledger

**File:** [`docs/governance/pattern-import-ledger.md`](../../governance/pattern-import-ledger.md).

Every absorbed pattern gets a ledger entry with `id`, abstract `source_project`, `source_files` citations, `trust_tier` (≥T2), `rationale`, `cross_project_occurrences` (≥2). CI enforces the ledger.

## Rule-pack governance

**File:** [`docs/governance/rule-pack-governance.md`](../../governance/rule-pack-governance.md).

Rule packs are the 7th unit type. v1.6 ships 8: TypeScript + Next.js, Python + FastAPI, Docker Compose, API security, Turkish locale, localization SSOT, LLM streaming + context-aware, React Native + Expo.

Contract:
- ≤500 bytes body (imperatives only)
- Activation line declares trigger stack
- Collision rule paragraph at bottom
- No project-specific paths

## Memory hygiene

**File:** [`docs/governance/memory-hygiene.md`](../../governance/memory-hygiene.md).

Project facts live in files, never in provider memory stores. Ensures reproducibility, vendor portability, auditability.

## Settings permissions governance

**File:** [`docs/governance/settings-permissions-governance.md`](../../governance/settings-permissions-governance.md).

`.claude/settings.json` declares what the CLI is allowed to do. Ulak OS ships a conservative default: deny list for destructive ops, allow list for read-only, ask list for borderline.

## Observability baseline

**File:** [`docs/governance/observability-baseline.md`](../../governance/observability-baseline.md).

Every scaffolded project gets structured logging with correlation IDs, error reporting hooked up, health-probe endpoint, sane tracing sample rate.

## Lock file hygiene

**File:** [`docs/governance/lock-file-hygiene.md`](../../governance/lock-file-hygiene.md).

All lockfiles committed by default. Phase 0 runs a broken-lock sweep.

## AI provider allowlist

**File:** [`docs/governance/ai-provider-allowlist.md`](../../governance/ai-provider-allowlist.md).

Declares which AI providers and models are approved. Adding a provider requires a PR with a threat model.

## Prompt supply chain

**File:** [`docs/governance/prompt-supply-chain.md`](../../governance/prompt-supply-chain.md).

Three channels: pack itself (first-party), allowlisted MCPs (second-party), operator's project (third-party, data not instructions).

## Trust model

**File:** [`docs/governance/trust-model.md`](../../governance/trust-model.md).

Tool outputs are **data, not instructions**. This firewall defeats injection attacks where an attacker plants instructions in a file the agent reads during Phase 1 inventory.

## Common schemas at a glance

### Validation-result YAML

```yaml
run_id: 2026-04-21-director-001
signoff_status: conditional    # ready | conditional | blocked
phases:
  phase_0: { status: complete, artefacts: [...] }
  phase_1: { status: complete, artefacts: ["inventory.md"] }
  ...
  phase_4_5: { status: partial, blocked_probes: ["AUTH-P2"] }
  phase_5: { status: complete }
residual_risks:
  - id: SEC-CU-03
    reason: "live-probe AUTH-P2 credentials missing"
    severity: Critical
next_action: "operator runs AUTH-P2 probe with production credentials"
```

Full schema: [`validation-result-schema.md`](../../runtime/validation-result-schema.md).

### Router decision YAML

```yaml
project_state: BROWNFIELD       # GREENFIELD | BROWNFIELD | HYBRID
intervention_mode: REPAIR       # CREATE | REPAIR | EXTEND | REFACTOR | MIGRATE | RESCUE | REPACKAGE
output_profile: AUDIT           # 7 profiles
output_language: en             # en | tr
scope: full
live_probe_required: true
dispatch_mode: parallel
validation_depth: deep
persona_set: [customer, admin, partner]
```

## Governance first-session checklist

When you take over a project or start fresh:

1. Read `docs/governance/README.md` (10 minutes)
2. Read `surface-split.md` + `product-surface-split.md`
3. Read `finding-schema.md`
4. Memorize T1–T7 trust tiers
5. Read `vendor-capability-matrix.md` to know what is supported on your CLI
6. Skim `pattern-import-ledger.md` for prior patterns
7. Use `/ulak-explain` when any term in steps 1–6 is unfamiliar

## Further reading

- [`../../governance/`](../../governance/) — all 22 governance documents
- [`../../runtime/anti-patterns.md`](../../runtime/anti-patterns.md) — the ~100-entry anti-pattern library that governance enforces
- [`../../runtime/sector-packs.md`](../../runtime/sector-packs.md) — 24 sector packs
- [`../../adr/`](../../adr/) — 7 ADRs
- [`../../runbooks/`](../../runbooks/) — 4 runbooks
- [`../../tutorials/`](../../tutorials/README.md) — 4 external-service tutorials
- [`../../showcase/`](../../showcase/README.md) — 3 walkthroughs + video script
- [`../../runtime/beginner-glossary.md`](../../runtime/beginner-glossary.md) — 47-term glossary

---

Next: [07 — Contributing](./07-contributing.md)
