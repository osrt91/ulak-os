# Ulak OS

> **Vendor-neutral prompt operating system** — Single-core, three-adapter, solution-focused runtime for Claude Code, Codex/Copilot, and Gemini CLI.

**Version:** 1.0.0 (First Stable Public Release)
**Developer:** [Oğuzhan Sert](https://github.com/osrt91)
**License:** MIT

[Türkçe](README.md) | English

---

## What is Ulak OS?

Ulak OS is a prompt operating system that takes a large software project from **any starting point** and drives it to validated outcomes:

- 🟢 **If you're building from scratch** → `CREATE` mode, intake → roadmap → validation
- 🟡 **If you're picking up unfinished work** → `RESCUE` mode, start from the evidence-register
- 🔴 **If you're near the finish line** → `REPACKAGE` mode, focused on validation and manager-verdict

The same artefact chain runs in every case; **never says "done" without validation.**

## Three vendors, one core

| Vendor | Adapter file | First command |
|---|---|---|
| Claude Code | `CLAUDE.md` | `/director komple` |
| Codex / Copilot | `AGENTS.md` | "Read AGENTS.md, run program mode" |
| Gemini CLI | `GEMINI.md` | `/director komple` |

All share the `prompts/core/ulak-os-core-contract-1.0.0.md` core contract.

## Quick start (5 minutes)

### 1. Clone

```bash
git clone https://github.com/osrt91/ulak-os
cd ulak-os
```

### 2. Run the init script for your vendor

**macOS / Linux:**
```bash
bash scripts/init-claude.sh    # Claude Code
bash scripts/init-codex.sh     # Codex/Copilot
bash scripts/init-gemini.sh    # Gemini CLI
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\init-claude.ps1
powershell -ExecutionPolicy Bypass -File scripts\init-codex.ps1
powershell -ExecutionPolicy Bypass -File scripts\init-gemini.ps1
```

### 3. Start the vendor CLI and run the first command

```
$ claude
> /memory          # Verify CLAUDE.md is loaded
> /director komple  # Ulak OS enters program mode
```

The first command output begins writing the artefact chain under `reports/current/`.

## MCP connectors (optional)

The `.mcp.json` file ships with 3 MCP connector definitions: **GitHub** (official server, pre-configured), Jira and Figma (placeholder).

### GitHub MCP (official, easiest)

GitHub's official MCP server `https://api.githubcopilot.com/mcp/` is already wired up in `.mcp.json`. You only need to set your GitHub Personal Access Token:

```bash
# GitHub Personal Access Token
# Create one at https://github.com/settings/tokens
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_token_here"
```

When Ulak OS starts, Claude Code connects automatically and gives you direct access to issues, PRs, repository search, code review, and the full GitHub API.

### Jira and Figma (optional, your own endpoint)

```bash
# Jira (optional)
export JIRA_MCP_URL="https://your-jira-mcp-endpoint"
export JIRA_TOKEN="your_jira_token"

# Figma (optional)
export FIGMA_MCP_URL="https://your-figma-mcp-endpoint"
export FIGMA_TOKEN="your_figma_token"
```

**Note:** If none are set, Ulak OS still works; only the MCP tools remain disabled.

## Troubleshooting

| Problem | Solution |
|---|---|
| `/memory` does not show CLAUDE.md | Open Claude Code from the repo **root** |
| `@import` error | Run `bash scripts/validate-imports.sh` to see which file is missing |
| MCP connection error | Set the env vars above or accept MCP as disabled |
| Windows `.ps1` "execution policy" error | Use the `-ExecutionPolicy Bypass -File` parameter |
| `reports/current/` does not exist | Re-run the `bash scripts/init-<vendor>.sh` script |
| I see a `Claude Ulak` remnant | This is a bug — open an issue |

## Repository contents

```
ulak-os/
├── CLAUDE.md / AGENTS.md / GEMINI.md      # 3 adapter entry files
├── prompts/core/                           # vendor-agnostic core contract
├── docs/
│   ├── adapters/                           # platform-specific usage guides
│   ├── governance/                         # rule collision matrix, plugin/skill decisions
│   ├── history/                            # version lineage
│   ├── examples/                           # complete artefact examples
│   ├── ecosystem/                          # related-work + ecosystem references
│   └── skills-integration/                 # superpowers + awesome-design-md mapping
├── scripts/                                # init + validation scripts (sh + ps1)
├── .claude/                                # 20 subagents + 6 commands + 4 native skills
├── .gemini/                                # Gemini CLI custom commands
├── .github/workflows/                      # CI validation + secret scan
└── reports/current/                        # runtime artefacts written here
```

## Multi-language

In Ulak OS v1.0.0:
- 🇹🇷 **Turkish** (primary) — `*.md`
- 🇬🇧 **English** (parallel) — `*.en.md`

Planned for v1.1+: 🇫🇷 FR, 🇩🇪 DE, 🇪🇸 ES, 🇸🇦 AR, 🇯🇵 JA, 🇨🇳 ZH

## Ecosystem

Ulak OS is not an isolated product — it is part of an ecosystem. A list of public projects it can be used alongside, was inspired by, or considers complementary: [`docs/ecosystem/related-work.md`](docs/ecosystem/related-work.md).

Highlights:
- **[obra/superpowers](https://github.com/obra/superpowers)** — Agentic skill framework (Ulak mapping: [`docs/skills-integration/superpowers-mapping.md`](docs/skills-integration/superpowers-mapping.md))
- **[anthropics/skills](https://github.com/anthropics/skills)** — Anthropic official Agent Skills repo
- **[VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)** — DESIGN.md for 58+ brands (integrated with Ulak via `/ulak-design-ref` command)
- **[gsd-build/gsd-2](https://github.com/gsd-build/gsd-2)** — Spec-driven development system (philosophical kinship)
- **[hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)** — Curated Claude Code skill list

## Version history

This release is the **public stable** successor to the 1.0.0–1.9.1 series developed under the internal codename "Claude Ulak". Details: [`docs/history/version-lineage.md`](docs/history/version-lineage.md)

## Contributing

Pull requests are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`docs/governance/rule-collision-matrix.md`](docs/governance/rule-collision-matrix.md) first.

## License

MIT — [`LICENSE`](LICENSE)
