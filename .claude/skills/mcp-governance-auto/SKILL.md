---
name: mcp-governance-auto
description: Auto-maintain the Ulak OS MCP allowlist. Reads `docs/governance/mcp-governance.md` + `.mcp.json` + `settings.local.json`, detects drift (newly added MCPs in settings that aren't governance-approved; approved MCPs not present; stale entries past rotation cadence), writes a reconciliation report, and proposes a PR-ready diff. Operator-gated (never auto-applies). Use during /director komple Phase 2 evidence pass, quarterly governance review, or when adding a new MCP needs a paper trail.
context: fork
agent: prompt-skill-plugin-governor
allowed-tools: Read, Grep, Glob, Bash
---

# MCP Governance Auto — allowlist drift detection + reconciliation

## Goal

Keep `docs/governance/mcp-governance.md` (authoritative allowlist) in sync with `.mcp.json` (runtime config) and `settings.local.json permissions.allow` (operator scope). Detect drift early, propose reconciliation, never auto-apply.

## When to use

- `/director komple` Phase 2: audits the MCP surface for governance drift
- Quarterly governance review
- Before adding a new MCP (the paper trail is generated from this skill)
- Incident response: post-compromise check that no MCP was silently added

## Inputs

```yaml
governance_doc: "docs/governance/mcp-governance.md"
runtime_config: ".mcp.json"
operator_scope: ".claude/settings.local.json"
report_path: "reports/current/mcp-reconciliation.md"
```

## Outputs

### `reports/current/mcp-reconciliation.md`

Structured reconciliation:

```markdown
# MCP Governance Reconciliation — 2026-NN-NN

## Allowlist-declared MCPs (governance/mcp-governance.md)
- github (T2, rotation: 90d, last_rotated: 2026-NN)
- context7 (T1, rotation: 180d)
- ...

## Runtime MCPs (.mcp.json)
- github ✓ matches allowlist
- context7 ✓
- linear ✗ NOT in allowlist

## Operator-scope allow entries (settings.local.json)
- mcp__github__* ✓ matches runtime
- mcp__linear__* ✗ runtime-only; missing governance entry

## Drift
| Kind | Detail | Action |
|---|---|---|
| **Undeclared MCP in runtime** | linear not in mcp-governance.md | Propose governance entry OR remove from .mcp.json |
| **Stale rotation** | github: 120d since rotation (limit: 90d) | Rotate + update last_rotated field |

## Proposed diff for mcp-governance.md
(structured markdown patch)

## Operator actions required
1. Review + approve/reject each drift item
2. Apply the governance diff
3. Update `.mcp.json` to match approved state
4. Rotate stale entries via /ulak-mcp-discover
```

### `reports/current/mcp-allowlist-proposal.yaml`

Machine-readable proposal for the GitHub bot / CI to convert to a PR.

## Hard rules

- **Never auto-apply**: the report is read-only until operator signs off
- **Never leak raw tokens**: if scanning settings.local.json encounters a key-looking value, redact before reporting
- **Respect trust tiers**: T1 MCPs get longer rotation cadence; T3+ requires stricter review

## Integration

- `docs/governance/mcp-governance.md` — authoritative allowlist
- `docs/governance/secrets-rotation-policy.md` — rotation cadence per secret
- `.claude/agents/prompt-skill-plugin-governor.md` — agent that dispatches this skill
- `/ulak-mcp-discover` — command for adding new MCPs to the allowlist
- `scripts/check-secret-rotation-due.sh` — CI gate that reads the rotation fields

## Canonical footer

Authoritative as of Ulak OS **v2.1.0**. Supports the v2.1 community ecosystem integration (Phase D).
