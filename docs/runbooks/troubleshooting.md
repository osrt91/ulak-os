# Runbook — Troubleshooting

Common errors and fixes, grouped by surface. Each entry has: **symptom**, **diagnosis**, **fix**.

If your error is not here, open an issue at https://github.com/osrt91/ulak-os/issues with the output of `ulak doctor`.

---

## Installer & CLI wrapper

### 1. `installer says git not found`

**Symptom:**
```
[ulak] ERROR: git is required but not found on PATH
```

**Diagnosis:** `git` is not installed or not in the current shell's `PATH`.

**Fix:**
- macOS: `xcode-select --install`
- Debian/Ubuntu: `sudo apt install git`
- Fedora/RHEL: `sudo dnf install git`
- Windows: https://git-scm.com/download/win

Then re-run the installer.

---

### 2. `ulak: command not found`

**Symptom:** installer finished, but typing `ulak` errors.

**Diagnosis:** the chosen bin dir (`$HOME/bin` or `$HOME/.local/bin`) is not on `PATH` in your current shell.

**Fix:**
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
source ~/.bashrc
ulak --version
```

On Windows, the installer prints a PowerShell `[Environment]::SetEnvironmentVariable(...)` snippet — run it once and restart the terminal.

---

### 3. `ulak init overwrote my CLAUDE.md`

**Symptom:** your previous `CLAUDE.md` content appears to be gone after `ulak init`.

**Diagnosis:** almost always not true — `ulak init` is **append + backup**. Look for `CLAUDE.md.ulak-backup` in the same directory.

**Fix:**
```bash
ls CLAUDE.md*
# If CLAUDE.md.ulak-backup exists:
cp CLAUDE.md.ulak-backup CLAUDE.md
# If it truly is lost:
git checkout HEAD -- CLAUDE.md
```

If you can reproduce a case where the file is overwritten without a backup, open a bug.

---

## Claude Code command loading

### 4. `/director command not found`

**Symptom:** Claude Code does not recognize `/director`.

**Diagnosis:** `.claude/commands/director.md` is not reachable from the current project root. Either (a) Claude Code was launched from the wrong directory, or (b) `.claude/settings.json` is missing/misconfigured.

**Fix:**
1. Confirm you are in the project root where `CLAUDE.md` lives:
   ```bash
   pwd
   ls .claude/commands/ 2>/dev/null || echo "no .claude/commands here"
   ```
2. If `.claude/commands/` is missing, your project was scaffolded without one. Either:
   - `ulak init .` (adds the import but not local commands — commands come from the install dir via the `@`-import chain), or
   - Open Claude Code from `~/.ulak-os/` directly — all 9 commands load there.
3. If `.claude/settings.json` exists but commands still do not load, check it against `~/.ulak-os/.claude/settings.json` — a malformed JSON breaks command discovery.

---

### 5. `@-import broken: file not found`

**Symptom:** `validate-imports.sh` reports a missing target.

**Diagnosis:** a relative `@`-import path is resolving to a file that was renamed or moved.

**Fix:**
```bash
bash scripts/validate-imports.sh   # note the offending file
grep -rn "@docs/.*moved-or-renamed" docs/ prompts/ .claude/
# Update each hit to the new path. Then re-run:
bash scripts/validate-imports.sh
```

If the import chain is legitimate but the target lives **outside** the repo (e.g., an absolute path in a consumer `CLAUDE.md`), the validator should skip it — if it does not, that is a validator bug.

---

### 6. `validate-imports.sh reports cycle`

**Symptom:**
```
ERROR: import cycle detected: A.md -> B.md -> A.md
```

**Diagnosis:** a new file transitively imports itself.

**Fix:** the validator prints the cycle trace. Break the cycle by removing one of the `@`-imports — usually the more recent one. Cycles are not silently tolerated because they produce unbounded context growth.

---

## Director / audit workflow

### 7. `manager-verdict.md says signoff_status: blocked`

**Symptom:** after `/director komple`, the final verdict refuses to say "ready".

**Diagnosis:** the validation plan has unmet probes. This is intended — it is the Phase 4.5 live-probe gate (see `docs/runtime/live-probe-contract.md`).

**Fix:**
1. Read `reports/current/validation-plan.md` §6 (live probes).
2. Either execute the probes (the plan lists commands) and check `reports/current/live-probe-results.md` goes green, or
3. Explicitly accept each unmet probe as residual risk and rewrite `manager-verdict.md` with rationale.

Do not manually flip `signoff_status` to `ready` without doing one of the above — the whole audit trail loses meaning.

---

### 8. `did-you-know.md is empty or trivial`

**Symptom:** the did-you-know artefact has 2-3 obvious lines or is blank.

**Diagnosis:** Phase 2 evidence-register was shallow — typically a single generalist agent ran instead of a parallel specialist dispatch.

**Fix:** re-run the director with broader agent dispatch:
```
/director komple agents=security,seo,i18n,infra-release,design-system,data-database,privacy-compliance,release-readiness,backend-api,architecture,red-team
```

Then confirm `reports/current/evidence-register.md` has ≥10 specialist findings, each with a T1-T7 trust tier. The did-you-know layer should follow.

---

### 9. `scaffolder refuses to run`

**Symptom:** `/ulak-scaffold` aborts with a guard rejection.

**Diagnosis:** the scaffolder's Phase 0 guard has refused. Usually one of:
- target directory is not empty (scaffolder refuses to overwrite),
- a required rule pack is missing for the requested stack,
- `product_domain` is unknown (must match a sector pack slug),
- no `payment_provider` given when `sector=payment-integrated-saas`.

**Fix:** read the guard message verbatim — it names the exact check that failed. Empty the target dir, pass the correct sector slug, or add the missing rule pack under `docs/runtime/rule-packs/`.

---

## Governance CI

### 10. `pattern-import-ledger check fails in CI`

**Symptom:** CI job rejects a PR with:
```
pattern-import-ledger: missing provenance for AP-NN
# or: trust tier T3 below minimum T2
```

**Diagnosis:** your PR added an anti-pattern or sector pack without a ledger entry, or the entry has a trust tier below T2.

**Fix:** open `docs/governance/pattern-import-ledger.md` and add an entry:
```yaml
- id: AP-NN
  source_project: <abstract descriptor, e.g., "B2B SaaS with multi-locale">
  source_files:
    - path/to/file.ts:45-62
  trust_tier: T2   # or higher
  rationale: <one line>
```

Then re-push.

---

### 11. `plugin.json schema validation fails`

**Symptom:** `validate-schemas.sh` flags `.claude-plugin/plugin.json`.

**Diagnosis:** after the v2.4.0 categories bump, `plugin.json` requires additional fields (e.g., `categories`, `license`, `keywords`).

**Fix:** compare your `plugin.json` against the committed one in `main`:
```bash
git show origin/main:.claude-plugin/plugin.json > /tmp/reference.json
diff /tmp/reference.json .claude-plugin/plugin.json
```

Add the missing keys. Required minimum: `name`, `version`, `description`, `license`, `author`, `categories`.

---

### 12. `vendor-parity script flags missing command`

**Symptom:**
```
PARITY: /some-command exists for claude but not for gemini
```

**Diagnosis:** you added a slash command under `.claude/commands/` without a matching Gemini adapter under `.gemini/commands/*.toml` (or Codex stub).

**Fix:** either add the Gemini port (preferred) or register an exemption:
```bash
echo "some-command  # reason: claude-native skill chain, no gemini equivalent yet" >> .claude/vendor-parity-exemptions.txt
```

Exemptions require human review — keep the list short.

---

## Secrets & git hygiene

### 13. `gitleaks baseline false positive`

**Symptom:** a pre-commit hook or CI run flags a string that is not actually a secret.

**Diagnosis:** gitleaks' heuristic matched a public test fixture, an example key in docs, or a template placeholder.

**Fix:** add the hit to `.gitleaks.baseline` with a rationale:
```json
{
  "description": "Stripe docs example key, see docs/examples/stripe-fixture.md",
  "file": "docs/examples/stripe-fixture.md",
  "offender": "sk_test_EXAMPLE...",
  "rule": "stripe-secret-key"
}
```

Never disable gitleaks wholesale — add baseline entries one at a time with rationale.

---

### 14. `git rm --cached already applied but file reappears staged`

**Symptom:** you ran `git rm --cached .env` after adding it to `.gitignore`, but `git status` still shows it as modified.

**Diagnosis:** another clone of the repo has not pulled the `.gitignore` update and is pushing the file back up.

**Fix:** ensure every collaborator runs `git pull` and then `git rm --cached <file>` on their clone too. The `.gitignore` only prevents **new** staging — already-tracked files keep tracking until explicitly untracked on every working copy.

---

### 15. `hook blocking commit`

**Symptom:** a guardrail hook (`pre-commit`, `commit-msg`) refuses a commit you believe is legitimate.

**Diagnosis:** the hook is doing its job — usually catching a secret pattern, a god-module change without a Strangler Fig marker, or a missing ADR for a governance edit.

**Fix:** do NOT pass `--no-verify`. Read `docs/governance/hook-governance.md` §4 for the bypass token protocol. Rare legitimate bypasses leave an audit entry in the commit message; casual `--no-verify` breaks the trail.

---

## Localization

### 16. `turkish characters appear broken` (bonus)

**Symptom:** output or JSON has `Ä°stanbul` instead of `İstanbul`.

**Diagnosis:** one of:
- `ensure_ascii: true` in a `json.dumps(...)` call (Python) — should be `ensure_ascii=False`,
- `toLocaleLowerCase()` without `'tr'` locale (JS) — should be `toLocaleLowerCase('tr')`,
- terminal codepage not set to UTF-8 (Windows) — run `chcp 65001`.

**Fix:** see `docs/runtime/turkish-normalization.md` for the full contract. Grep for `ensure_ascii\|toLocaleLowerCase[^(]*\(\)` across the repo — it usually surfaces the offender in seconds.

---

## Last-resort recovery

If you are deeply stuck, the cleanest reset:

```bash
# Back up your reports/ and any local sector-pack additions:
cp -r reports/current /tmp/ulak-reports-backup

# Nuke and re-install:
rm -rf ~/.ulak-os ~/bin/ulak
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh

# Verify:
ulak doctor
```

Your projects' `CLAUDE.md` imports keep pointing at `~/.ulak-os/...` so they work immediately.
