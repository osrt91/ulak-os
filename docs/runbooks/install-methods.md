# Runbook — Install methods

Five ways to install Ulak OS. Pick by your trust level, team structure, and pinning needs.

| Method | Speed | Pinnable | Network required | Good for |
|---|---|---|---|---|
| 1. One-liner curl / iwr | fastest | no | yes | solo dev, fresh machine |
| 2. Git clone + manual CLAUDE.md edit | slow | yes | yes | early adopters, transparency |
| 3. Git submodule in your project | medium | yes (SHA-pinned) | yes | teams, reproducible audits |
| 4. Claude Code plugin | N/A (future) | TBD | TBD | plugin marketplace users |
| 5. npm package | N/A (future) | TBD | TBD | JS/TS-heavy orgs |

---

## Method 1 — One-liner

**Prerequisites:** `git`, `curl` (or `wget`) on macOS/Linux; PowerShell 5.1+ on Windows.

**Commands:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh
```

```powershell
# Windows
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex
```

**Verification:**

```bash
ulak --version
ulak where
ulak doctor
```

**When to choose:** you want to try Ulak OS on your own box, you trust the URL (it is a static file in the public repo), and you are fine tracking `main`.

**Pros:** zero cognitive cost, idempotent, detects Claude / Codex / Gemini and prints tailored next steps.

**Cons:** always tracks `main` (no pinning); network required; implicit trust in the installer.

**Uninstall:**

```bash
rm -rf "${ULAK_HOME:-$HOME/.ulak-os}"
rm -f "$HOME/bin/ulak" "$HOME/.local/bin/ulak"
```

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.ulak-os"
Remove-Item -Force "$env:USERPROFILE\bin\ulak.cmd" -ErrorAction SilentlyContinue
```

---

## Method 2 — Git clone + manual CLAUDE.md edit

**Prerequisites:** `git`, a text editor.

**Commands:**

```bash
git clone https://github.com/osrt91/ulak-os.git ~/tools/ulak-os
# Optional: pin to a tag
cd ~/tools/ulak-os && git checkout v2.4.0
```

Then, in each project you want governed:

```bash
cd /path/to/your-project
cat >> CLAUDE.md <<EOF

# Ulak OS governance
@/home/you/tools/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
EOF
```

**Verification:**

```bash
cd ~/tools/ulak-os
bash scripts/validate-imports.sh
bash scripts/validate-schemas.sh
bash scripts/validate-vendor-parity.sh
```

**When to choose:** you want to read every file before trusting it; you prefer no wrapper CLI; you want the install path under your control (e.g., `~/tools/ulak-os` instead of `~/.ulak-os`).

**Pros:** fully transparent, every change is a `git pull` you control, easy to pin with `git checkout <tag>`.

**Cons:** slower to set up; manual `CLAUDE.md` edit per project; no `ulak` command unless you add `~/tools/ulak-os/bin` to your PATH.

**Uninstall:**

```bash
rm -rf ~/tools/ulak-os
# Remove the @-import line from each CLAUDE.md by hand (or grep -l + sed).
```

---

## Method 3 — Git submodule in your project

**Prerequisites:** `git`, project is already a git repo.

**Commands:**

```bash
cd /path/to/your-project
git submodule add https://github.com/osrt91/ulak-os.git .ulak-os
cd .ulak-os && git checkout v2.4.0 && cd ..
git add .gitmodules .ulak-os
git commit -m "chore: pin Ulak OS v2.4.0 as submodule"

# Relative import — moves with the repo:
cat >> CLAUDE.md <<'EOF'

# Ulak OS governance (submodule-pinned)
@.ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
EOF

git add CLAUDE.md && git commit -m "chore: wire Ulak OS governance"
```

**Verification:**

```bash
bash .ulak-os/scripts/validate-imports.sh
```

Teammates clone with `--recurse-submodules`:

```bash
git clone --recurse-submodules <your-repo>
# Or, after a plain clone:
git submodule update --init --recursive
```

**When to choose:** a team project where every reviewer should see the exact same pack version; reproducible audits across CI and laptops; compliance / audit trail needs.

**Pros:** SHA-pinned; every contributor sees the identical pack; upgrades are explicit (`cd .ulak-os && git checkout vNext`); works offline once cloned.

**Cons:** submodules add process overhead (new hires have to learn `--recurse-submodules`); storage is duplicated per project.

**Upgrade:**

```bash
cd .ulak-os
git fetch --tags && git checkout v2.4.1
cd ..
git add .ulak-os && git commit -m "chore: bump Ulak OS to v2.4.1"
```

**Uninstall:**

```bash
git submodule deinit -f .ulak-os
git rm -f .ulak-os
rm -rf .git/modules/.ulak-os
# Remove the @.ulak-os import from CLAUDE.md.
```

---

## Method 4 — Claude Code plugin install (not yet available)

**Status:** tracked; waiting on Claude Code plugin marketplace support.

**Planned flow:**

```bash
claude plugin install osrt91/ulak-os
# or by git URL:
claude plugin install https://github.com/osrt91/ulak-os.git
```

**Expected behavior:** `.claude-plugin/plugin.json` is the manifest that gets consumed. Commands, agents, skills, rule packs, and anti-patterns auto-register once the plugin is installed — no manual `@`-import required.

**Current fallback:** use Method 1 or Method 3. The `.claude-plugin/` directory is already wired and will be consumed as-is when the marketplace ships.

**Tracking issue:** https://github.com/osrt91/ulak-os/issues (search "plugin install")

---

## Method 5 — npm package (deferred to v3.1)

**Status:** deferred. An npm package (`@ulak-os/cli`) is planned to make `npx ulak init <dir>` work without a prior clone. This depends on v3.0 public launch having a stable CLI surface.

**Current fallback:** Method 1. The one-liner is functionally equivalent to what the npm package will provide, with git as the transport instead of npm.

**Tracking issue:** https://github.com/osrt91/ulak-os/issues (search "npm distribution")

---

## Decision flowchart

```
Am I just trying it out on one machine?
├── yes → Method 1 (one-liner)
└── no
    ├── Do I want to read every file first?
    │   └── yes → Method 2 (git clone)
    └── no
        └── Is it a team project that needs reproducible audits?
            ├── yes → Method 3 (submodule, pinned to tag)
            └── no  → Method 1 is still fine; upgrade to 3 if the team grows
```

---

## Common concerns

**"Does the installer need sudo?"** No. All methods write only to `$HOME` (or your project). If something asks for `sudo`, it is not Ulak OS.

**"Will any method phone home?"** No. The install is git-only. No telemetry. The only network activity is the clone/pull itself.

**"Can I run multiple versions side-by-side?"** Yes. Use Method 2 with different install dirs (e.g., `~/tools/ulak-os-2.4.0` and `~/tools/ulak-os-3.0.0`). Each project's `CLAUDE.md` points at the version it wants.

**"How do I know the install is healthy?"**

```
ulak doctor    # if installed via Method 1
# or:
cd <install-dir> && bash scripts/validate-imports.sh && bash scripts/validate-schemas.sh && bash scripts/validate-vendor-parity.sh
```

All green = pack is healthy.
