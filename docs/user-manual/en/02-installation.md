# 02 — Installation

You can install Ulak OS five different ways. This chapter walks through the three that cover 95% of users: **one-liner installer**, **manual clone**, and **git submodule**. The other two (Claude Code plugin marketplace, npm package) are tracked as future work and summarized at the end. For the complete decision tree and the edge cases, see [`../../runbooks/install-methods.md`](../../runbooks/install-methods.md).

## Prerequisites

- `git` on your PATH. The installer will refuse without it.
- One AI coding CLI: Claude Code, Codex / Copilot, or Gemini CLI. Any one is enough.
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
3. Detects which AI coding CLIs are installed (Claude Code / Codex / Gemini) and prints tailored next steps.

### Preview first (dry run)

If you want to see what the installer will do without making changes:

```bash
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh -s -- --dry-run
```

```powershell
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex
# then run: ulak-install.ps1 -DryRun
```

### Trade-offs

- **Pros:** zero cognitive cost, idempotent, tailored next steps.
- **Cons:** always tracks `main` branch (no pinning); requires network; implicit trust in the installer script.

## Method 2 — Manual clone

Use this if you want to read every file before trusting it, or if you want the install path under your control (for example `~/tools/ulak-os` instead of `~/.ulak-os`).

```bash
git clone https://github.com/osrt91/ulak-os.git ~/tools/ulak-os

# Optional: pin to a specific tag for reproducibility
cd ~/tools/ulak-os
git checkout v1.0.0
```

Then in each project you want governed:

```bash
cd /path/to/your-project
cat >> CLAUDE.md <<EOF

# Ulak OS governance
@$HOME/tools/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
EOF
```

### Trade-offs

- **Pros:** fully transparent. Every update is a `git pull` you control. Easy to pin with `git checkout <tag>`.
- **Cons:** slower to set up. Manual `CLAUDE.md` edit per project. No `ulak` command unless you add the `bin/` subdirectory to your PATH.

## Method 3 — Git submodule (team projects)

For team projects where every reviewer should see the exact same pack version, and where CI reproducibility matters. Submodule pinning makes the pack version part of the repo's SHA.

```bash
cd /path/to/your-project
git submodule add https://github.com/osrt91/ulak-os.git .ulak-os
cd .ulak-os && git checkout v1.0.0 && cd ..
git add .gitmodules .ulak-os
git commit -m "chore: pin Ulak OS v1.0.0 as submodule"

# Relative import — moves with the repo
cat >> CLAUDE.md <<'EOF'

# Ulak OS governance (submodule-pinned)
@.ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
EOF

git add CLAUDE.md
git commit -m "chore: wire Ulak OS governance"
```

### Teammates onboarding

Once you commit the submodule, teammates clone with:

```bash
git clone --recurse-submodules <your-repo>

# Or, after a plain clone:
git submodule update --init --recursive
```

### Upgrading

```bash
cd .ulak-os
git fetch --tags && git checkout v1.1.0
cd ..
git add .ulak-os && git commit -m "chore: bump Ulak OS to v1.1.0"
```

### Trade-offs

- **Pros:** SHA-pinned. Every contributor sees the identical pack. Works offline after the initial clone.
- **Cons:** submodules add onboarding overhead (new hires have to learn `--recurse-submodules`). Storage is duplicated per project.

## `ulak init` — seed CLAUDE.md in an existing project

If you installed via Method 1 (one-liner), you have the `ulak` command. Run it inside a project to append the governance import to its `CLAUDE.md`:

```bash
cd /path/to/your-project
ulak init .
```

`ulak init` is **append + backup**: if `CLAUDE.md` already exists, it creates `CLAUDE.md.ulak-backup` before appending. If something goes wrong you can restore from the backup (or from `git checkout HEAD -- CLAUDE.md`).

The command does not add local `.claude/commands/` into your project — the commands come through the `@`-import chain from the install directory. If you want the commands physically in your project, use Method 3 (submodule) and copy `.claude/` from `.ulak-os/` as needed.

## Verification

After installing, run the health checks.

### Cross-platform (if `ulak` is on PATH)

```bash
ulak --version
ulak where
ulak doctor
```

`ulak doctor` runs every validator in sequence and reports green, yellow, or red on each. A green run means the pack is structurally healthy.

> **Tip:** starting from v1.0.0, the command is also exposed under the longer alias `ulak-os`. Both `ulak doctor` and `ulak-os doctor` hit the same binary — pick whichever you prefer; the alias helps in shells where the short `ulak` name clashes with another tool.

### Direct validator scripts (POSIX)

If you used Method 2 or want to inspect the validators one by one:

```bash
cd <install-dir>
bash scripts/validate-imports.sh         # @-import chain + cycle detection
bash scripts/validate-schemas.sh         # JSON schema conformance for plugin.json and friends
bash scripts/validate-vendor-parity.sh   # claude / codex / gemini command parity
```

All three green means the pack is healthy. See [chapter 08](./08-troubleshooting.md) if any fail.

## Troubleshooting installation

Common install-time issues are covered in [chapter 08](./08-troubleshooting.md) § Installer. The short list:

- `git not found` → install git from your OS package manager, then re-run.
- `ulak: command not found` → the bin directory is not on your PATH in the current shell. Re-source your shell rc file or open a new terminal.
- `installer timed out` → network issue. Fall back to Method 2 (manual clone).

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

Your projects' `CLAUDE.md` files still contain `@`-imports pointing at the install dir. Either remove those lines manually or re-run the installer to reconnect.

### Method 2 (manual clone)

```bash
rm -rf ~/tools/ulak-os
# Remove the @-import line from each CLAUDE.md by hand
```

### Method 3 (submodule)

```bash
git submodule deinit -f .ulak-os
git rm -f .ulak-os
rm -rf .git/modules/.ulak-os
# Remove the @.ulak-os import from CLAUDE.md
```

## Deferred methods (not yet available)

Both are tracked but not shipped with v1.0.0.

- **Claude Code plugin marketplace** — the `.claude-plugin/plugin.json` manifest is ready and will be consumed as-is when the marketplace supports third-party plugins. For now, use Method 1 or Method 3.
- **npm package (`@ulak-os/cli`)** — planned for a later release so that `npx ulak init <dir>` works without a prior clone. Tracking issue at `github.com/osrt91/ulak-os/issues` (search "npm distribution").

## Further reading

- [`../../runbooks/install-methods.md`](../../runbooks/install-methods.md) — the complete decision tree with all five methods
- [`../../runbooks/troubleshooting.md`](../../runbooks/troubleshooting.md) — full failure-mode list
- [`../../runbooks/first-hour-with-ulak-os.md`](../../runbooks/first-hour-with-ulak-os.md) — clone through first audit through first commit, narrated

---

Next: [03 — Architecture](./03-architecture.md)
