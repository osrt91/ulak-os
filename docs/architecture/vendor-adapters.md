# Vendor Adapters

Ulak OS targets three CLI surfaces: **Claude Code** (primary, parallel-dispatch native), **Codex / Copilot CLI** (long-context code authoring), and **Gemini CLI** (research + market scans). Each CLI has its own entry point and its own context mechanism, but they all consume the same core contract and the same runtime / governance docs.

Adapter specs (one per vendor):
- [`docs/adapters/claude-code.md`](../adapters/claude-code.md) — primary target, `@-import` syntax, `.claude/commands/*.md`
- [`docs/adapters/codex-cli.md`](../adapters/codex-cli.md) — AGENTS.md root hint, reading-order list (no `@-import`)
- [`docs/adapters/gemini-cli.md`](../adapters/gemini-cli.md) — `GEMINI.md` memory, `.gemini/commands/*.toml`

## Topology

```mermaid
graph TD
  subgraph Shared core surface
    CORE[prompts/core/<br/>ulak-os-core-contract-2.0.0.md]
    RT[docs/runtime/*.md<br/>router · phases · artefacts · waves · personas · anti-patterns]
    GOV[docs/governance/*.md<br/>finding · trust · surface-split · authorizations]
    MOT[operational motors<br/>intake · architecture-currency · localization · market-research · sector-packs]
  end

  subgraph Vendor adapters
    CLAUDE_AD[docs/adapters/claude-code.md]
    CODEX_AD[docs/adapters/codex-cli.md]
    GEMINI_AD[docs/adapters/gemini-cli.md]
  end

  subgraph Vendor entry points
    C1[CLAUDE.md<br/>@-import chain]
    C2[.claude/commands/*.md]
    C3[.claude/agents/*.md]

    X1[AGENTS.md<br/>reading-order hint]
    X2[.codex/commands/*.md<br/>optional]

    G1[GEMINI.md<br/>@-import chain]
    G2[.gemini/commands/*.toml]
  end

  CORE --> CLAUDE_AD
  CORE --> CODEX_AD
  CORE --> GEMINI_AD

  RT --> CLAUDE_AD
  RT --> CODEX_AD
  RT --> GEMINI_AD
  GOV --> CLAUDE_AD
  GOV --> CODEX_AD
  GOV --> GEMINI_AD
  MOT -.->|"mode-loaded"| CLAUDE_AD
  MOT -.->|"mode-loaded"| CODEX_AD
  MOT -.->|"mode-loaded"| GEMINI_AD

  CLAUDE_AD --> C1
  CLAUDE_AD --> C2
  CLAUDE_AD --> C3

  CODEX_AD --> X1
  CODEX_AD --> X2

  GEMINI_AD --> G1
  GEMINI_AD --> G2

  C2 --> ART[reports/current/**<br/>same artefact chain across vendors]
  X2 --> ART
  G2 --> ART

  PAR[scripts/validate-vendor-parity.sh<br/>per-command parity check]
  C2 -.-> PAR
  X2 -.-> PAR
  G2 -.-> PAR
```

## Vendor-specific conventions

| Convention | Claude Code | Codex / Copilot | Gemini CLI |
|---|---|---|---|
| Startup memory file | `CLAUDE.md` (repo root) | `AGENTS.md` (repo root) + optional `.github/copilot-instructions.md` | `GEMINI.md` (repo root) |
| Context-import syntax | `@path/to/file.md` works natively | No `@-import`; reading-order list passed in first prompt | `@path/to/file.md` works natively |
| Command directory | `.claude/commands/<name>.md` | `.codex/commands/<name>.md` (optional; reading-order hint in first message is more common) | `.gemini/commands/<name>.toml` |
| Command file format | Markdown with YAML frontmatter | Markdown (no enforced frontmatter) | TOML |
| Subagent model | Native parallel dispatch via `Task` | Single-agent; simulate specialists by sequential passes writing `reports/current/specialists/<role>.md` | Single-agent; same sequential simulation |
| Skill model | `.claude/skills/<name>/SKILL.md` loaded by the agent | No native skill mechanism; skills inlined as sub-prompts | No native skill mechanism; skills inlined as sub-prompts |
| Hook mechanism | `.claude/settings.json` hooks (PreToolUse, PostToolUse, Stop) | None native | None native |
| Phase 2 dispatch | Parallel (one message, multiple `Task` calls) | Serial (one specialist pass at a time) | Serial (one specialist pass at a time) |
| MCP support | Full (stdio, SSE, HTTP) | Limited / vendor-dependent | Full |
| Reload command | — (CLAUDE.md re-read on new session) | Start new session | `/memory reload` + `/commands reload` |

## Vendor parity enforcement

`scripts/validate-vendor-parity.sh` builds a matrix of commands per vendor and fails the build if a command exists for one vendor but not another, unless the gap has a declared exemption.

### How it works

1. Scans `.claude/commands/*.md`, `.gemini/commands/*.{toml,md}`, and `.codex/commands/*.md` to build per-vendor command sets
2. Reads `.github/vendor-parity-exemptions.txt` for documented gaps (format: `<vendor>:<command>` with a `# reason` comment above)
3. Computes the union of all command names and checks each cell in the `command × vendor` matrix
4. Codex is treated as optional (the `.codex/commands/` directory is not required); if present, its commands are checked for parity against Claude and Gemini
5. Exits non-zero on any unexplained missing cell, printing the parity matrix and a reminder to add an exemption if intentional

### Typical exemption

```
# Figma MCP dependency not ported to Gemini CLI yet
gemini:ulak-design-ref

# Plugin manifest is Claude-Code-specific
codex:plugin-manifest
```

Exemptions are not a backdoor — every exemption is a **documented drift** that is visible in one place and reviewable on PR. When the gap is closed, the exemption line is removed.

### CI integration

The validator runs in `.github/workflows/ci-validation.yml` alongside `validate-imports.sh` and `validate-schemas.sh`. A PR that adds a Claude-only command without either porting it to Gemini or declaring an exemption fails CI. This prevents silent drift — the original motivation (DY-03 finding in v2.1.4) was exactly this class of "shipped for Claude, never for Gemini" blind spot.

### Writing new commands with parity in mind

When adding a new command:

1. Write the Claude Code spec at `.claude/commands/<name>.md` (primary target)
2. Write the Gemini equivalent at `.gemini/commands/<name>.toml` (same behavior, different syntax)
3. Optionally write the Codex variant at `.codex/commands/<name>.md`, or add an exemption if the command depends on a vendor-specific capability (parallel dispatch, MCP-only workflow, Claude-specific plugin manifest)
4. Run `bash scripts/validate-vendor-parity.sh` locally; the matrix should print `✓` for the vendors you ported and `-` with `OK` for the ones you exempted

## Shared artefact chain

Regardless of vendor, every run writes to `reports/current/**` with the same file names: `runtime-manifest.md`, `inventory.md`, `evidence-register.md`, `deep-scan-report.md`, `did-you-know.md`, `analysis-findings.md`, `target-state.md`, `execution-roadmap.md`, `validation-plan.md`, `pack-gap-register.md`, `manager-verdict.md`, `validation-result.yaml`. An operator who runs Phase 0-3 in Claude Code and then switches to Gemini for Phase 4 synthesis gets continuity because the context lives in files, not in vendor-specific memory.

## Related docs

- [`docs/adapters/claude-code.md`](../adapters/claude-code.md) · [`docs/adapters/codex-cli.md`](../adapters/codex-cli.md) · [`docs/adapters/gemini-cli.md`](../adapters/gemini-cli.md)
- [`docs/adapters/universal-runtime-contract.md`](../adapters/universal-runtime-contract.md) — vendor-agnostic behavior spec
- [`scripts/validate-vendor-parity.sh`](../../scripts/validate-vendor-parity.sh) — the enforcement script
- [`.github/vendor-parity-exemptions.txt`](../../.github/vendor-parity-exemptions.txt) — current declared exemptions
