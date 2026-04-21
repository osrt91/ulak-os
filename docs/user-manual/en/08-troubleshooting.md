# 08 — Troubleshooting

Common failure modes and their fixes. Each entry has **Symptom**, **Diagnosis**, **Fix**. v1.6 split this chapter into two sections: **core troubleshooting** (pack-level and protocol-level issues) and a new **beginner / service setup** section for account-creation and external-service pain points that the scaffolder cannot automate.

If your error is not here, see the full troubleshooting runbook at [`../../runbooks/troubleshooting.md`](../../runbooks/troubleshooting.md), or ask Ulak OS directly:

```
/ulak-ask my director run fails during Phase 2 with a dispatch error
```

`/ulak-ask` routes to the most likely diagnostic command or doc. For unfamiliar terms, use `/ulak-explain <term>`.

## Core troubleshooting

### 1. `/director` command not found

**Symptom.** Your AI coding CLI does not recognize `/director`.

**Diagnosis.** `.claude/commands/director.md` is not reachable. Either (a) CLI launched from wrong directory, (b) `.claude/settings.json` missing or malformed, (c) `@`-import in `CLAUDE.md` points at wrong path.

**Fix.**
1. Confirm you are in the project root:
   ```bash
   pwd
   ls .claude/commands/ 2>/dev/null || echo "no .claude/commands here"
   ```
2. If `.claude/commands/` is missing locally, commands come through the `@`-import chain. Either `ulak init .` the project, or open your CLI from the install directory.
3. On Codex / Copilot, `/director` must be invoked via the NL trigger map — "audit this project" works.

### 2. `hi ulak` produces no response

**Symptom.** Typing `hi ulak` in the CLI returns nothing.

**Diagnosis.** Ulak OS core contract is not imported into the vendor-specific entry file (`CLAUDE.md` for Claude, `AGENTS.md` for Codex/Copilot, `.gemini/commands/` for Gemini). The `/ulak-hello` command cannot fire.

**Fix.** Run `ulak init . --vendor=<your-vendor>` in the project, or manually add the `@`-import to the entry file. Verify with `ulak doctor`.

### 3. `@`-import broken: file not found

**Symptom.** `validate-imports.sh` reports a missing target.

**Fix.**
```bash
bash scripts/validate-imports.sh
# Find references to the missing file:
grep -rn "@docs/.*moved-or-renamed" docs/ prompts/ .claude/
# Update hits to new path. Re-run:
bash scripts/validate-imports.sh
```

### 4. Scaffolder refuses to run

**Symptom.** `/ulak-scaffold` aborts with a guard rejection.

**Diagnosis.** Phase 0 guard refused. Usually one of:
- Target directory not empty
- Required rule pack missing for requested stack
- `product_domain` unknown (must match a sector pack slug)
- No `payment_provider` when `sector=payment-integrated-saas`

**Fix.** Read the guard message verbatim — it names the check that failed. If you are new, try `/ulak-start` instead (wizard prompts for every required field).

### 5. `validate-imports.sh` reports cycle

**Fix.** Validator prints the cycle trace. Break it by removing one `@`-import (usually the most recently added). Split shared content into a third file if both directions feel necessary.

### 6. `validate-vendor-parity.sh` fails

**Symptom.** CI rejects PR with "missing gemini adapter for <command>" or "no NL trigger map entry for <command>".

**Diagnosis.** You added a `.claude/commands/<name>.md` without the corresponding Gemini `.toml` or NL trigger map entry.

**Fix.** Run `bash scripts/sync-gemini-commands.sh` to auto-generate the `.toml`. Add the NL phrase to `AGENTS.md`. Add a row to `docs/governance/vendor-capability-matrix.md`. See [chapter 07](./07-contributing.md) § Vendor parity discipline.

### 7. `validate-bilingual.sh` fails

**Symptom.** CI rejects PR with "TR/EN parity drift in <file>".

**Diagnosis.** You updated `docs/user-manual/en/05-workflows.md` without the matching `docs/user-manual/tr/05-is-akislari.md` change (or vice-versa), or you added an EN governance doc without the TR twin.

**Fix.** Update both languages in the same PR. The script lists exactly which headings or files drifted.

### 8. `manager-verdict.md` says `signoff_status: blocked`

**Symptom.** After `/director komple`, final verdict refuses to say "ready".

**Diagnosis.** Validation plan has unmet probes or a Critical finding rests on T2/T3 evidence not upgraded by a live probe.

**Fix.**
1. Read `reports/current/validation-plan.md` §6 (live probes).
2. Execute the probes, confirm `live-probe-results.md` goes green, OR
3. Explicitly accept each unmet probe as residual risk, rewrite `manager-verdict.md` with rationale.

Do not manually flip `signoff_status` to `ready` without one of the above.

### 9. `did-you-know.md` is empty or trivial

**Symptom.** The did-you-know artefact has 2–3 obvious lines or is blank.

**Diagnosis.** Phase 2 evidence-register was shallow. A single generalist agent ran instead of parallel specialist dispatch.

**Fix.** Re-run with broader dispatch:
```
/director komple parallel_dispatch=9
```
Or explicitly specify specialists:
```
/director komple skip_phase_1=true parallel_dispatch=11
```
Confirm `evidence-register.md` has ≥10 specialist findings with T1–T7 tiers.

### 10. Turkish characters appear broken

**Symptom.** Output or JSON has `Ä°stanbul` instead of `İstanbul`.

**Diagnosis.** `ensure_ascii: true` (Python), `toLocaleLowerCase()` without `'tr'` locale (JS), or Windows codepage not 65001.

**Fix.** See [`docs/runtime/turkish-normalization.md`](../../runtime/turkish-normalization.md).

### 11. `pattern-import-ledger` check fails in CI

**Fix.** Add a ledger entry in `docs/governance/pattern-import-ledger.md`:
```yaml
- id: AP-NN
  title: "<short title>"
  source_project: "<abstract descriptor>"
  source_files: [path/to/file.ts:45-62]
  trust_tier: T2
  rationale: "<one-line why>"
  fix_summary: "<one-line fix>"
  cross_project_occurrences: 2
```
Single-project patterns are rejected; wait for a second occurrence.

### 12. `plugin.json` schema validation fails

**Fix.** Compare against main:
```bash
git show origin/main:.claude-plugin/plugin.json > /tmp/reference.json
diff /tmp/reference.json .claude-plugin/plugin.json
```
Required minimum: `name`, `version`, `description`, `license`, `author`, `categories`.

### 13. Pre-commit hook blocking commit

**Fix.** Do not pass `--no-verify`. Read `docs/governance/hook-governance.md` §4 for the bypass-token protocol. If the hook itself is buggy, open an issue with the offending file + rule name.

## Beginner / service setup (v1.6)

The scaffolder generates the project skeleton but **cannot** create accounts or retrieve API keys from external services. These are the most common friction points and their fixes.

### B1. Supabase auth not working after scaffold

**Symptom.** You filled `.env.local` with `NEXT_PUBLIC_SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` but `pnpm dev` shows "Invalid API key" when you try to sign up.

**Diagnosis.** One of:
- You pasted the **anon key** where the **service role key** was expected (or vice versa).
- You copied keys from a different Supabase project.
- RLS policies are blocking the insert because the role in `auth.users` is missing.

**Fix.**
1. Open [`docs/tutorials/supabase.md`](../../tutorials/supabase.md) § "API keys".
2. Double-check which key goes in which env var (the tutorial shows the mapping).
3. Verify the Supabase project URL matches your `.env.local`.
4. Run the first migration (`supabase db push`) — it creates the role column.
5. `/ulak-explain rls` if you need a quick reminder of what RLS does.

### B2. Vercel deploy env vars missing

**Symptom.** `pnpm build` works locally but Vercel deploy shows "Environment variable NEXT_PUBLIC_SUPABASE_URL is not defined".

**Diagnosis.** You wired `.env.local` locally but did not add the same vars to Vercel's project settings.

**Fix.** [`docs/tutorials/vercel.md`](../../tutorials/vercel.md) § "Environment variables" walks through Project Settings → Environment Variables. Add every key from `.env.example` (except local-only ones). Re-deploy.

### B3. GitHub push protection blocking secrets

**Symptom.** `git push` fails with "GH013: Repository rule violations — secret detected".

**Diagnosis.** You accidentally committed a real API key or the `.gitignore` rule for `.env.local` was not in the initial commit.

**Fix.**
1. Remove the secret from the committed history:
   ```bash
   git filter-repo --path .env.local --invert-paths
   # Or, for a single commit:
   git reset HEAD~1 --soft
   git checkout -- .env.local
   # Then re-commit without the secret
   ```
2. Rotate the leaked key in the service's dashboard (assume it is compromised).
3. Ensure `.env.local` is in `.gitignore` (the scaffolder does this — verify it survived).
4. [`docs/tutorials/github.md`](../../tutorials/github.md) § "First push" covers this scenario.

### B4. Resend domain verify failing

**Symptom.** You added a domain to Resend, set the DNS records, but Resend dashboard still says "Pending".

**Diagnosis.** DNS propagation can take up to 48 hours, or the TXT / MX / CNAME records are wrong.

**Fix.**
1. [`docs/tutorials/resend.md`](../../tutorials/resend.md) § "Domain verify" lists the exact record format per common DNS host.
2. Use `dig +short TXT <your-domain>` to verify propagation.
3. If records look right but Resend does not see them, wait 1 hour and re-check. Full propagation can take 24+ hours on some registrars.

### B5. "What does this term mean?"

**Symptom.** You are reading a migration file or `.env.example` and see a term (RLS, JWT, CSRF, HMAC, CORS, idempotency, webhook, middleware, etc.) you do not recognize.

**Fix.**
```
/ulak-explain <term>
```
Returns a 5-field explanation (Simple / Technical / Analogy / In Ulak / Related). Source: the 47-term [`beginner-glossary.md`](../../runtime/beginner-glossary.md). If the term is not in the glossary, open an issue to add it.

### B6. "What do I do now?" after scaffold

**Symptom.** Scaffold completed, but you do not know which command to run first.

**Fix.**
```
/ulak-next-steps
```
Produces a personalized 8–10-step runbook for your scaffold choices (sector, payment, deploy, email). Following those steps reaches localhost:3000 with working admin login.

## Self-serve problem solving

Two commands exist specifically for "stuck in the manual, want a shortcut":

- **`/ulak-ask <free-form question>`** — routes your plain-language question to the most likely command or doc.
- **`/ulak-explain <term>`** — 5-field glossary lookup.

These let you stay inside the CLI instead of switching to a browser.

## Last-resort recovery

```bash
# Back up your reports and local sector-pack additions:
cp -r reports/current /tmp/ulak-reports-backup

# Reinstall:
rm -rf ~/.ulak-os ~/bin/ulak
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh

# Verify:
ulak doctor
```

Your projects' `CLAUDE.md` imports keep pointing at `~/.ulak-os/...` so they work immediately after reinstall.

## Further reading

- [`../../runbooks/troubleshooting.md`](../../runbooks/troubleshooting.md) — 16+ failure modes
- [`../../runbooks/install-methods.md`](../../runbooks/install-methods.md) — alternative install paths
- [`../../tutorials/`](../../tutorials/README.md) — service-setup tutorials
- [`../../runtime/turkish-normalization.md`](../../runtime/turkish-normalization.md) — Turkish character handling
- [`../../governance/hook-governance.md`](../../governance/hook-governance.md) — hook bypass protocol
- [`../../runtime/beginner-glossary.md`](../../runtime/beginner-glossary.md) — 47-term glossary

---

Next: [09 — FAQ](./09-faq.md)
