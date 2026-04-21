---
name: awesome-packs-index
description: Read-only index of community Claude Code packs (commands / skills / agents / plugins / MCPs) curated from awesome-claude-code and related public sources. Produces a cross-referenceable pack-catalog with license + trust tier + capability-fit against Ulak OS gaps. Use during pack-gap audits, when onboarding a new plugin, or when answering "does someone else already solve this?". Does NOT install anything; read-only reference for operator decisions.
context: fork
agent: prompt-skill-plugin-governor
allowed-tools: Read, Grep, Glob, Bash, WebFetch
---

# Awesome Packs Index — community pack catalog

## Goal

Maintain a curated, searchable index of community Claude Code / Codex / Gemini CLI packs so Ulak OS operators can see "does this already exist?" before committing to building it.

## When to use

- Pack-gap audit: before writing a new skill, check if an awesome-* pack already solves it
- Community-ecosystem review: quarterly scan for emerging packs worth adopting or learning from
- Operator onboarding: new team member wants to see the community landscape at a glance
- Conflict resolution: when two packs duplicate capability, compare trust + activity + fit

## Sources

| Source | Type | Trust |
|---|---|---|
| `hesreallyhim/awesome-claude-code` | Curated list | T2 (maintainer-vetted) |
| `anthropics/superpowers` | Official skill bundle | T1 |
| `modelcontextprotocol/servers` | Official MCP registry | T1 |
| GitHub topic `claude-code-plugin` | Community | T3 (individual repos) |
| GitHub topic `mcp-server` | Community | T3 |
| Discord/Twitter community threads | Ephemeral | T5+ (needs vetting per-pack) |

## Outputs

### `reports/current/awesome-packs-index.md`

Structured catalog:

```markdown
# Community Pack Index — generated 2026-NN-NN

## Commands
| Name | Source | License | Trust | Ulak overlap | Recommendation |
|---|---|---|---|---|---|
| /some-command | github.com/author/repo | MIT | T3 | duplicates Ulak OS /director partial | monitor, don't install |
| ... | ... | ... | ... | ... | ... |

## Skills
## Agents
## Plugins
## MCPs

## Ulak OS gap candidates
(packs that fill a real gap; consider pattern-extract)

## License concerns
(non-MIT/Apache packs flagged)

## Activity concerns
(packs with no commits in 180 days, not under active maintenance)
```

### `reports/current/pack-gap-fill-candidates.yaml`

Machine-readable list of community packs that Ulak OS could learn from or absorb patterns from. Drives `/ulak-pattern-extract` when operator confirms.

## Hard rules

- **Read-only**: this skill never installs or modifies `.mcp.json` / `.claude/settings.json`
- **Redaction**: no operator-portfolio names appear in the index (even as positive mention — pure community focus)
- **License gate**: packs without a detectable MIT/Apache-2.0/BSD license are flagged explicitly; GPL are noted but never recommended
- **Activity gate**: no commits in 180 days marks the pack "stagnant"; no recommendation to adopt without operator override

## Integration

- `.claude/skills/pack-gap-completion/SKILL.md` — gap-detection skill that calls this index
- `docs/governance/pattern-import-ledger.md` — ledger entries for absorbed patterns
- `.claude/commands/ulak-pattern-extract.md` — the command that formalizes an absorption
- `/ulak-mcp-discover` — sibling for MCP-specific discovery
- `docs/distribution/awesome-claude-code-pr.md` — Ulak OS submission to the list (reciprocal)

## Refresh cadence

Quarterly (every 90 days). Stale index flagged by `scripts/check-secret-rotation-due.sh`-style freshness check.

## Canonical footer

Authoritative as of Ulak OS **v2.1.0**. Ships with Phase D (v2.1.0) community ecosystem integration.
