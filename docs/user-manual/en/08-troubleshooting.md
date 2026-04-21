# 08 — Troubleshooting

Ten common failure modes and their fixes. Each entry has **Symptom**, **Diagnosis**, **Fix**. If your error is not here, see the full troubleshooting runbook at [`../../runbooks/troubleshooting.md`](../../runbooks/troubleshooting.md) or open an issue at `github.com/osrt91/ulak-os` with the output of `ulak doctor`.

## 1. `/director` command not found

**Symptom.** Your AI coding CLI does not recognize `/director`.

**Diagnosis.** `.claude/commands/director.md` is not reachable from the current project root. Either (a) the CLI was launched from the wrong directory, (b) `.claude/settings.json` is missing or malformed, or (c) the `@`-import in `CLAUDE.md` points at the wrong path.

**Fix.**
1. Confirm you are in the project root where `CLAUDE.md` lives:
   ```bash
   pwd
   ls .claude/commands/ 2>/dev/null || echo "no .claude/commands here"
   ```
2. If `.claude/commands/` is missing locally, commands come through the `@`-import chain. Either `ulak init .` the project, or open your CLI from the Ulak OS install directory directly (where all 9 commands load).
3. If `.claude/settings.json` exists but commands still do not load, compare it to the reference at `~/.ulak-os/.claude/settings.json`. Malformed JSON breaks command discovery.

## 2. `@`-import broken: file not found

**Symptom.** `validate-imports.sh` reports a missing target.

**Diagnosis.** A relative `@`-import path resolves to a file that was renamed, moved, or never existed.

**Fix.**
```bash
bash scripts/validate-imports.sh   # note the offending file
# Search every import that references the missing file:
grep -rn "@docs/.*moved-or-renamed" docs/ prompts/ .claude/
# Update each hit to the new path. Then re-run:
bash scripts/validate-imports.sh
```

If the import chain is legitimate but the target lives outside the repo (for example an absolute path in a consumer `CLAUDE.md`), the validator should skip it. If it does not, that is a validator bug — open an issue.

## 3. Scaffolder refuses to run

**Symptom.** `/ulak-scaffold` aborts with a guard rejection.

**Diagnosis.** The scaffolder's Phase 0 guard refused. Usually one of:
- Target directory is not empty (the scaffolder refuses to overwrite).
- A required rule pack is missing for the requested stack.
- `product_domain` is unknown (must match a sector pack slug).
- No `payment_provider` given when `sector=payment-integrated-saas`.

**Fix.** Read the guard message verbatim — it names the exact check that failed. Empty the target dir, pass the correct sector slug, add the missing rule pack under `docs/runtime/rule-packs/`, or supply the missing argument.

## 4. `validate-imports.sh` reports cycle

**Symptom.**
```
ERROR: import cycle detected: A.md -> B.md -> A.md
```

**Diagnosis.** A new file transitively imports itself. Cycles cause unbounded context growth and are rejected.

**Fix.** The validator prints the cycle trace. Break the cycle by removing one of the `@`-imports — usually the most recently added one. If both directions feel necessary, split the shared content into a third file that both import.

## 5. `manager-verdict.md` says `signoff_status: blocked`

**Symptom.** After `/director komple`, the final verdict refuses to say "ready".

**Diagnosis.** The validation plan has unmet probes, or a Critical finding rests on T2/T3 evidence that was not upgraded by a live probe. This is the Phase 4.5 live-probe gate doing its job — see [`docs/runtime/live-probe-contract.md`](../../runtime/live-probe-contract.md).

**Fix.**
1. Read `reports/current/validation-plan.md` §6 (live probes).
2. Either execute the probes (the plan lists the commands) and confirm `reports/current/live-probe-results.md` goes green, or
3. Explicitly accept each unmet probe as residual risk and rewrite `manager-verdict.md` with a rationale.

Do not manually flip `signoff_status` to `ready` without one of the above — the whole audit trail loses its meaning.

## 6. `did-you-know.md` is empty or trivial

**Symptom.** The did-you-know artefact has 2–3 obvious lines or is blank.

**Diagnosis.** Phase 2 evidence-register was shallow. Typically a single generalist agent ran instead of parallel specialist dispatch.

**Fix.** Re-run the director with broader specialist dispatch:
```
/director komple parallel_dispatch=9
```

Or specify specialists explicitly:
```
/director komple skip_phase_1=true parallel_dispatch=11
```

Then confirm `reports/current/evidence-register.md` has ≥10 specialist findings, each with a T1–T7 trust tier. The did-you-know layer follows.

## 7. Turkish characters appear broken

**Symptom.** Output or JSON has `Ä°stanbul` instead of `İstanbul`.

**Diagnosis.** One of:
- `ensure_ascii: true` in a `json.dumps(...)` call (Python) — should be `ensure_ascii=False`.
- `toLocaleLowerCase()` without `'tr'` locale (JS) — should be `toLocaleLowerCase('tr')`.
- Terminal codepage not set to UTF-8 (Windows) — run `chcp 65001`.

**Fix.** See [`docs/runtime/turkish-normalization.md`](../../runtime/turkish-normalization.md) for the full contract. Grep for `ensure_ascii\|toLocaleLowerCase[^(]*\(\)` across the repo — the offender usually surfaces in seconds.

## 8. `pattern-import-ledger` check fails in CI

**Symptom.** CI rejects a PR with:
```
pattern-import-ledger: missing provenance for AP-NN
# or: trust tier T3 below minimum T2
```

**Diagnosis.** Your PR added an anti-pattern or sector pack without a ledger entry, or the entry has a trust tier below T2.

**Fix.** Open `docs/governance/pattern-import-ledger.md` and add an entry:
```yaml
- id: AP-NN
  title: "<short title>"
  source_project: "<abstract descriptor, e.g., 'B2B SaaS with multi-locale'>"
  source_files:
    - path/to/file.ts:45-62
  trust_tier: T2           # or T1 if directly observed
  rationale: "<one-line why>"
  fix_summary: "<one-line fix>"
  cross_project_occurrences: 2
```

Then re-push. Single-project patterns are rejected — wait for a second occurrence.

## 9. `plugin.json` schema validation fails

**Symptom.** `validate-schemas.sh` flags `.claude-plugin/plugin.json`.

**Diagnosis.** The plugin manifest is missing a required field (typically `categories`, `license`, or `keywords`).

**Fix.** Compare your `plugin.json` against the committed one in `main`:
```bash
git show origin/main:.claude-plugin/plugin.json > /tmp/reference.json
diff /tmp/reference.json .claude-plugin/plugin.json
```

Add the missing keys. Required minimum: `name`, `version`, `description`, `license`, `author`, `categories`.

## 10. Pre-commit hook blocking commit

**Symptom.** A guardrail hook (`pre-commit`, `commit-msg`) refuses a commit you believe is legitimate.

**Diagnosis.** The hook is doing its job — usually catching a secret pattern, a god-module change without a Strangler Fig marker, or a missing ADR for a governance edit.

**Fix.** **Do not pass `--no-verify`.** Read [`docs/governance/hook-governance.md`](../../governance/hook-governance.md) §4 for the bypass-token protocol. Rare legitimate bypasses leave an audit entry in the commit message; casual `--no-verify` breaks the trail.

If the hook itself is buggy (false positive), open an issue with the offending file + rule name. The maintainer updates the hook, not the operator bypasses it.

## Last-resort recovery

If you are deeply stuck:

```bash
# Back up your reports and any local sector-pack additions:
cp -r reports/current /tmp/ulak-reports-backup

# Reinstall:
rm -rf ~/.ulak-os ~/bin/ulak
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh

# Verify:
ulak doctor
```

Your projects' `CLAUDE.md` imports keep pointing at `~/.ulak-os/...` so they work immediately after reinstall.

## Further reading

- [`../../runbooks/troubleshooting.md`](../../runbooks/troubleshooting.md) — the full runbook covering 16+ failure modes
- [`../../runbooks/install-methods.md`](../../runbooks/install-methods.md) — alternative install paths if Method 1 fails
- [`../../runtime/turkish-normalization.md`](../../runtime/turkish-normalization.md) — the Turkish character handling contract
- [`../../governance/hook-governance.md`](../../governance/hook-governance.md) — hook bypass protocol

---

Next: [09 — FAQ](./09-faq.md)
