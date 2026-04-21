# 02 — Installation

You can install Ulak OS five different ways. This chapter walks through the three that cover 95% of users: **one-liner installer**, **manual clone**, and **git submodule**. It then covers per-vendor setup for all four supported CLIs (Claude Code, Codex, Copilot, Gemini), the `ulak init` flow for existing projects, verification, troubleshooting, and uninstall. For the full decision tree and edge cases, see [`../../runbooks/install-methods.md`](../../runbooks/install-methods.md).

## The shortest path — `hi ulak`

v1.6 added a natural-language onboarding layer. If your AI coding CLI is already installed and Ulak OS is wired into your project (or the install directory), you can type this in the CLI:

```
hi ulak
```

The `/ulak-hello` skill fires, explains what Ulak OS does in three sentences, shows three example commands, and asks what you want to do. From there `/ulak-ask` routes your free-form intent to the right command. You do not need to memorize slash commands to start.

If `hi ulak` does not trigger a response, Ulak OS is not yet wired in — follow the install methods below, then try again.

## Prerequisites

- `git` on your PATH. The installer will refuse without it.
- **One** AI coding CLI from this list:
  - Claude Code (primary — full feature support)
  - Codex CLI
  - Copilot CLI
  - Gemini CLI
- A supported OS:
  - macOS (tested with zsh default and bash)
  - Linux (tested on Ubuntu 22.04 / 24.04 and Fedora)
  - Windows 10 or 11 with PowerShell 5.1 or newer

No `sudo` is required. Every install method writes only to `$HOME` (or your project). If something asks for `sudo`, it is not Ulak OS.

## Method 1 — One-liner installer (recommended)

The fastest path. Works on a fresh machine in under a minute.

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh
```

### Windows (PowerShell 5.1+)

```powershell
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex
```

### What it does

1. `git clone` the repo to `$HOME/.ulak-os/` (macOS/Linux) or `%USERPROFILE%\.ulak-os\` (Windows).
2. Drops an `ulak` command on your PATH (`$HOME/bin/ulak` or `$HOME/.local/bin/ulak` on POSIX; `%USERPROFILE%\bin\ulak.cmd` on Windows).
3. Detects which AI coding CLIs are installed (Claude Code / Codex / Copilot / Gemini) and prints tailored next steps for each.

### Preview first (dry run)

```bash
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh -s -- --dry-run
```

### Trade-offs

- **Pros:** zero cognitive cost, idempotent, tailored next steps.
- **Cons:** always tracks `main` branch (no pinning); requires network; implicit trust in the installer script.

## Method 2 — Manual clone

Use this if you want to read every file before trusting it, or if you want the install path under your control.

```bash
git clone https://github.com/osrt91/ulak-os.git ~/tools/ulak-os

# Optional: pin to a specific tag
cd ~/tools/ulak-os
git checkout v1.6.0
```

Then in each project you want governed:

```bash
cd /path/to/your-project
cat >> CLAUDE.md <<EOF

# Ulak OS governance
@$HOME/tools/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
EOF
```

## Method 3 — Git submodule (team projects)

```bash
cd /path/to/your-project
git submodule add https://github.com/osrt91/ulak-os.git .ulak-os
cd .ulak-os && git checkout v1.6.0 && cd ..
git add .gitmodules .ulak-os
git commit -m "chore: pin Ulak OS v1.6.0 as submodule"

cat >> CLAUDE.md <<'EOF'

# Ulak OS governance (submodule-pinned)
@.ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
EOF

git add CLAUDE.md
git commit -m "chore: wire Ulak OS governance"
```

Teammates onboard with `git clone --recurse-submodules <your-repo>` (or `git submodule update --init --recursive` after a plain clone).

## Cross-vendor setup — the 5 × 4 matrix

Ulak OS supports four CLIs. Each of the five install methods above works with each vendor, but the **entry file** differs. Once the pack is on disk, wire it into the vendor-specific entry file:

| Install method | Claude Code | Codex CLI | Copilot CLI | Gemini CLI |
|---|---|---|---|---|
| **1. One-liner** | auto — writes `CLAUDE.md` import | auto — writes `AGENTS.md` import | auto — writes `AGENTS.md` import | auto — writes `.gemini/commands/*.toml` |
| **2. Manual clone** | append `@...core-contract` to `CLAUDE.md` | append to `AGENTS.md` | append to `AGENTS.md` | copy `.gemini/commands/*.toml` into project |
| **3. Submodule** | `@.ulak-os/prompts/core/...` in `CLAUDE.md` | `@.ulak-os/prompts/core/...` in `AGENTS.md` | `@.ulak-os/prompts/core/...` in `AGENTS.md` | symlink `.ulak-os/.gemini/` into project |
| **4. Plugin marketplace** (deferred) | `.claude-plugin/plugin.json` manifest ready | n/a | n/a | n/a |
| **5. npm package** (deferred) | `npx ulak init` | `npx ulak init --vendor=codex` | `npx ulak init --vendor=copilot` | `npx ulak init --vendor=gemini` |

### Vendor-specific entry files

- **Claude Code** uses `CLAUDE.md` as its startup memory.
- **Codex CLI** and **Copilot CLI** share `AGENTS.md` as the startup surface. Natural-language trigger phrases (the "NL trigger map") compensate for the absence of literal slash commands.
- **Gemini CLI** reads `.gemini/commands/*.toml` — one file per command. Ulak OS ships these alongside `.claude/commands/*.md`.

Parity is enforced by `scripts/validate-vendor-parity.sh` and by [`docs/governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md).

## `ulak init` — seed an entry file in an existing project

If you installed via Method 1 (one-liner), you have the `ulak` command. Run it inside a project to append the governance import to the correct entry file for your vendor:

```bash
cd /path/to/your-project
ulak init .                                # auto-detects vendor
ulak init . --vendor=codex                 # explicit
ulak init . --vendor=copilot --vendor=gemini   # multi-vendor
```

`ulak init` is **append + backup**: if the target entry file already exists, it creates a `.ulak-backup` copy before appending. If something goes wrong you can restore from the backup (or from `git checkout HEAD -- <file>`).

## Verification

After installing, run the health checks.

```bash
ulak --version
ulak where
ulak doctor
```

`ulak doctor` runs every validator in sequence and reports green, yellow, or red on each. A green run means the pack is structurally healthy across all four vendors.

> **Tip:** starting from v1.0.0, the command is also exposed under the longer alias `ulak-os`. Both `ulak doctor` and `ulak-os doctor` hit the same binary.

### Direct validator scripts (POSIX)

```bash
cd <install-dir>
bash scripts/validate-imports.sh         # @-import chain + cycle detection
bash scripts/validate-schemas.sh         # JSON schema conformance
bash scripts/validate-vendor-parity.sh   # 4-vendor command parity
bash scripts/validate-bilingual.sh       # TR/EN doc parity
```

All four green means the pack is healthy. See [chapter 08](./08-troubleshooting.md) if any fail.

## First contact — try `hi ulak`

After install + verification, open your AI coding CLI in any project that imports Ulak OS and type:

```
hi ulak
```

or

```
/ulak-hello
```

You should see the 30-second onboarding tour: what Ulak OS does, three example commands, and a "what do you want to do?" prompt. If you get back nothing, Ulak OS is not imported — re-check `CLAUDE.md` / `AGENTS.md` / `.gemini/commands/`.

## Troubleshooting installation

Common install-time issues are covered in [chapter 08](./08-troubleshooting.md) § Installer. Short list:

- `git not found` → install git from your OS package manager, then re-run.
- `ulak: command not found` → the bin directory is not on your PATH. Re-source your shell rc file or open a new terminal.
- `hi ulak` produces no response → Ulak OS core-contract import is missing from the vendor-specific entry file.
- Gemini CLI shows no commands → the `.gemini/commands/*.toml` files are not in the project or the symlink target is stale.
- Codex / Copilot does not recognize a command → NL trigger map is not loaded; see [chapter 04](./04-commands.md) § Vendor support.

Full diagnostic flow: [`../../runbooks/troubleshooting.md`](../../runbooks/troubleshooting.md).

## Uninstall

### Method 1 (one-liner)

```bash
rm -rf "${ULAK_HOME:-$HOME/.ulak-os}"
rm -f "$HOME/bin/ulak" "$HOME/.local/bin/ulak"
```

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.ulak-os"
Remove-Item -Force "$env:USERPROFILE\bin\ulak.cmd" -ErrorAction SilentlyContinue
```

Your projects' `CLAUDE.md` / `AGENTS.md` / `.gemini/commands/` entries still point at the install dir. Either remove those references manually or re-run the installer to reconnect.

### Method 2 (manual clone)

```bash
rm -rf ~/tools/ulak-os
# Remove the @-import line from each CLAUDE.md / AGENTS.md / .gemini/commands by hand
```

### Method 3 (submodule)

```bash
git submodule deinit -f .ulak-os
git rm -f .ulak-os
rm -rf .git/modules/.ulak-os
# Remove the @.ulak-os imports from CLAUDE.md / AGENTS.md / .gemini/commands
```

## Deferred methods (not yet available)

- **Claude Code plugin marketplace** — the `.claude-plugin/plugin.json` manifest is ready. For now, use Method 1 or Method 3.
- **npm package (`@ulak-os/cli`)** — planned so that `npx ulak init <dir>` works without a prior clone. Tracking issue at `github.com/osrt91/ulak-os/issues`.

## Further reading

- [`../../runbooks/install-methods.md`](../../runbooks/install-methods.md) — the complete decision tree with all five methods
- [`../../runbooks/troubleshooting.md`](../../runbooks/troubleshooting.md) — full failure-mode list
- [`../../runbooks/first-hour-with-ulak-os.md`](../../runbooks/first-hour-with-ulak-os.md) — clone through first audit through first commit, narrated
- [`../../governance/vendor-capability-matrix.md`](../../governance/vendor-capability-matrix.md) — per-vendor command / skill / agent support matrix
- [`../../tutorials/README.md`](../../tutorials/README.md) — Supabase, Vercel, GitHub, Resend setup (used after scaffold)

---

Next: [03 — Architecture](./03-architecture.md)
