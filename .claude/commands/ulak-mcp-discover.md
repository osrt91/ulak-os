---
name: ulak-mcp-discover
description: Public registry'den yeni MCP server'ları keşfet, trust tier'a göre sınıflandır ve governance kapısıyla Ulak OS MCP allowlist'ine eklenmesini öner. Operator incelemesi için aday raporu üretir; otomatik kurmaz. Community MCP server'larını Ulak OS run'ına veya scaffold edilmiş bir projeye entegre etmek için değerlendirirken kullan.
description_en: Discover new MCP servers from the public registry, classify by trust tier, propose addition to the Ulak OS MCP allowlist with governance gate. Produces a candidate report for operator review; does NOT auto-install. Use when evaluating community MCP servers for integration into an Ulak OS run or a scaffolded project.
agent: autonomous-program-director
allowed-tools: Read, Grep, Glob, Bash, WebFetch
---

# /ulak-mcp-discover — MCP server discovery + governance gate

## When to use

- Evaluating whether a community MCP server should join the Ulak OS allowlist
- Scoping a new capability that an MCP integration would unlock (e.g., GitHub / Linear / Slack / database)
- Periodic audit: which allowlisted MCPs have stale / deprecated upstreams

## When NOT to use

- Installing an MCP for ad-hoc single-session use (that's operator-scope via `settings.local.json`; does not need governance review)
- Emergency removal of a flagged MCP (use `/director` with `security-hardening-lead` dispatch instead)

## Dispatch protocol

1. **Fetch candidate list** from:
   - modelcontextprotocol.io (canonical registry)
   - Community-maintained lists (awesome-mcp, claude-code-mcp directories)
   - GitHub topic `mcp-server` with >50 stars + recent activity (last 90 days)
2. **Filter** by:
   - License (MIT / Apache-2.0 / BSD only)
   - Maintainer reputation (Anthropic-hosted / known-maintainer / trusted org)
   - Capability fit (does it deliver something Ulak OS packs don't already cover?)
3. **Trust-tier classification** per `docs/governance/evidence-trust-scoring.md`:
   - **T1**: Anthropic-maintained; canonical registry; documented API surface
   - **T2**: Well-known maintainer (e.g., GitHub, Google, Hugging Face); active upstream
   - **T3+**: Community / experimental — allowed only if capability is unique + review bar is high
4. **Risk audit**:
   - Which secrets does the MCP require? (API tokens, OAuth scopes)
   - What data does it access? (customer / admin / public-API layer)
   - Can it mutate state remotely? (governance decision: never auto-approved for write)
5. **Propose entry** in `docs/governance/mcp-governance.md` allowlist section with trust tier + rationale + rotation cadence
6. **Operator review gate** — the proposal is NEVER auto-applied; operator signs off before `.mcp.json` update

## Output artefacts

- `reports/current/mcp-discovery.md` — 10-20 candidate MCPs with classification + recommendation
- `reports/current/mcp-allowlist-proposal.yaml` — structured proposal (name + trust tier + scope + rotation cadence + justification)
- `reports/current/mcp-risk-matrix.md` — secret + data + mutation-surface per candidate

## Integration

- `docs/governance/mcp-governance.md` — allowlist + governance contract
- `docs/governance/ai-provider-allowlist.md` — related (AI model providers)
- `docs/governance/evidence-trust-scoring.md` — T1-T7 tiers used here
- `.mcp.json` (operator-scope) — actual MCP config; never edited by this command
- `docs/runtime/prompt-supply-chain.md` — supply-chain integrity for imported MCP tools

## Hard rules

- Never add an MCP to `.mcp.json` from this command — operator gate only
- Never accept `.claude/settings.json permissions.allow` expansion for an MCP without explicit governance entry
- Never trust an MCP that ships binary blobs (only source-auditable implementations)
- License GPL or unclear → refuse categorically

## Example

```
/ulak-mcp-discover scope="database + issue tracker + observability"
```

Produces a candidate report covering:
- **Database** candidates: Postgres MCP, Supabase MCP (T1/T2 via official maintainers)
- **Issue tracker**: GitHub MCP (T1), Linear MCP (T2)
- **Observability**: Grafana MCP (T2), Sentry MCP (T2)

Operator reviews → picks 3 → confirms → updates `docs/governance/mcp-governance.md` + `.mcp.json` manually.
