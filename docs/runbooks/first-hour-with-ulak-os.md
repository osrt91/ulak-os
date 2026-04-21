# Runbook — First hour with Ulak OS

Target audience: a developer who just ran the installer (`install.sh` on macOS/Linux or `install.ps1` on Windows) and wants to get concrete value in 60 minutes.

This runbook is **linear**. Do the steps in order. You do not need to read anything else first.

---

## Minute 0–10 — Install + verify

### 0–3 — Run the installer

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh
```

```powershell
# Windows (PowerShell 5.1+)
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex
```

Expected tail of output:

```
[ulak] Installed. Next steps:

  1. Verify:
       ulak --version
...
```

### 3–5 — Verify the CLI

```
$ ulak --version
ulak 2.4.0 (install: /home/you/.ulak-os)
```

```
$ ulak where
/home/you/.ulak-os
```

If `ulak --version` says `command not found`, the install directory is not on your `PATH`. Fix:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 5–10 — Inspect what got installed

```
$ ls ~/.ulak-os
.claude/        .claude-plugin/   CHANGELOG.md   CLAUDE.md    docs/
prompts/        scripts/          templates/     bin/         README.md
```

Key directories:

| Directory | Role |
|---|---|
| `.claude/` | 9 slash commands + 27 agents + 9 skills |
| `prompts/core/` | Vendor-neutral core contract |
| `docs/runtime/` | 33 runtime rules |
| `docs/governance/` | 22 governance docs |
| `templates/saas-starter/` | 27 scaffolder template files |

Run the health check:

```
$ ulak doctor
[ulak] running scripts/validate-imports.sh
[ulak] running scripts/validate-schemas.sh
[ulak] running scripts/validate-vendor-parity.sh
```

All green → pack is healthy.

---

## Minute 10–20 — First audit on a brownfield project

Pick one of your existing projects. Nothing will be modified except one `CLAUDE.md` file.

```
$ cd ~/code/some-existing-project
$ ulak init .
[ulak] created CLAUDE.md with Ulak OS core import
[ulak] ready: open your AI coding CLI in /home/you/code/some-existing-project and run /director
```

Open the resulting `CLAUDE.md` — it is ~5 lines:

```
# some-existing-project — project memory

@/home/you/.ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md

## Runtime defaults
- validation olmadan done deme
- artefakt zincirini erken başlat
```

Now open Claude Code in that directory and run:

```
/director komple
```

The director will run Phase 0 → Phase 5:

1. **Phase 0** — environment lock (`runtime-manifest.md`, `assumptions.md`)
2. **Phase 1** — deep inventory (file:line citations, not an `ls` dump)
3. **Phase 2** — 4–13 specialist agents dispatched in parallel
4. **Phase 3** — `did-you-know.md` (mandatory non-obvious findings)
5. **Phase 4** — synthesis: `analysis-findings`, `target-state`, `execution-roadmap`, `validation-plan`, `pack-gap-register`
6. **Phase 5** — `manager-verdict.md` with signoff status

Everything lands under `reports/current/`. Read `manager-verdict.md` last — it summarizes the other 12 artefacts.

---

## Minute 20–35 — First scaffold of a greenfield SaaS

Scaffold a brand-new project from zero. Pick an empty directory name that does **not** yet exist.

```
$ cd ~/code
$ mkdir example-saas && cd example-saas
$ ulak init .
```

Back in Claude Code, now sitting in `example-saas/`:

```
/ulak-scaffold product_name=example-saas product_domain=saas locale_primary=tr payment_provider=stripe
```

After the scaffolder finishes, inspect the tree:

```
$ tree -L 2 -I 'node_modules|.next'
.
├── CLAUDE.md
├── README.md
├── app/
│   ├── (auth)/
│   ├── (dashboard)/
│   └── layout.tsx
├── components/
├── lib/
│   ├── supabase/
│   └── auth/                 # single auth helper (AP-11 prevention)
├── middleware.ts             # session refresh
├── supabase/
│   ├── migrations/
│   └── policies/             # RLS templates
├── scripts/
│   ├── deploy.sh             # webhook-ready
│   └── vps-harden.sh         # SSH port + UFW + fail2ban
├── .github/workflows/
├── .gitignore                # AP-16 discipline
├── .gitleaks.baseline
└── package.json
```

Things to notice at commit 1 — these are `/ulak-scaffold` guarantees, not follow-up tasks:

- No duplicated auth helpers (AP-11)
- `server-only` import guards on sensitive lib code (AP-13)
- Role reads from DB, never from `user_metadata` (AP-06)
- RLS policies ship with explicit USING + WITH CHECK symmetry
- Health-probe on deploy webhook (AP-12 + AP-18)
- `.gitleaks.baseline` exists and is empty (no false positives yet)

---

## Minute 35–50 — Persona audit

Run the director a second time on the scaffold — this time in persona mode:

```
/director persona=customer,admin,partner
```

What this does: the director dispatches the same Phase 0–5 program three times with different persona contexts loaded. You will get:

- `reports/current/manager-verdict.md` (merged)
- `reports/current/personas/customer/did-you-know.md`
- `reports/current/personas/admin/did-you-know.md`
- `reports/current/personas/partner/did-you-know.md`

Compare the three `did-you-know.md` files. Example observations you might see:

```
# customer
- AP-06 drift risk: role leak if signup form accidentally writes to user_metadata

# admin
- Missing audit trail on role elevation endpoints (T4 evidence)

# partner
- No per-tenant billing isolation yet; roadmap item P-03
```

This is the persona-dispatch pattern at work. No persona is "the" audit — the merge is the audit.

---

## Minute 50–60 — Commit + next steps

Commit the scaffolded project normally:

```
$ git init -b main
$ git add -A
$ git commit -m "chore: initial scaffold via Ulak OS v2.4.0"
```

The generated `.gitignore`, `.gitleaks.baseline`, and `CLAUDE.md` are included. The `reports/current/` folder should be committed too — it is the evidence trail for the audit you just ran.

### Where to go next

- `docs/showcase/README.md` — deeper tours of real projects built with Ulak OS
- `docs/runbooks/upgrading-from-v2.x.md` — how to move an older install to v2.4.0+
- `docs/runbooks/troubleshooting.md` — when something is weird
- `docs/runbooks/install-methods.md` — alternatives to the one-liner
- `docs/FAQ.md` — "how is this different from X?" answers
- `CONTRIBUTING.md` — adding your own sector pack / anti-pattern

Feedback, bug reports, and new sector packs: file an issue at https://github.com/osrt91/ulak-os/issues.

You are done. In one hour you ran:
- a full 13-artefact director audit on an existing project,
- a full SaaS scaffold from zero,
- a persona-split audit on that scaffold,
- and committed a clean baseline.
