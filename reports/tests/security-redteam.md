# Security Red Team Report â€” pre-v1.0.0-public-GA

**Target:** Ulak OS (https://github.com/osrt91/ulak-os, v2.4.0 HEAD, public GA candidate)
**Persona:** security-redteam (adversarial lens, no execution against live systems)
**Date:** 2026-04-21
**Related Phase-2 persona:** security-hardening-lead (see Cross-cuts)

## Summary

| Severity | Count |
|---|---|
| **Critical** | 2 |
| **High**     | 4 |
| **Medium**   | 5 |
| **Low**      | 3 |
| **Total**    | 14 |

**Overall verdict: `signoff_status: BLOCKED` pending Critical remediation.**

Two critical findings dominate:
1. permanently-recoverable live credentials in the public v2.1.4 git tag, and
2. command injection in the installer via attacker-controlled environment variables that flow into eval.

Both are reachable by any unauthenticated internet user who finds the public repo. Neither is mitigated today.

The hook surface, templates, and governance docs are otherwise well-written; the discipline layer is clearly more mature than the attacker-facing ingress surfaces.

---

## Attack surface per category

### A. Install script injection

**scripts/install.sh â€” CRITICAL**: run() at lines 50-56 uses eval on strings that embed environment variables ULAK_BRANCH, ULAK_REPO_URL, and ULAK_HOME via single-quote interpolation. A caller-controlled variable containing a single quote breaks out of the single-quoted literal and injects arbitrary shell, producing RCE under the victim shell. Single-quote escaping is not applied; the variables come directly from the environment (install.sh:22-24).

**scripts/install.sh â€” MEDIUM**: accepts --dry-run but no signature/hash verification of the cloned repo. Combined with the README one-liner, any compromise of the GitHub account, a stolen commit signing key, or a malicious branch reference silently executes on every new victim.

**scripts/install.ps1 â€” LOW**: writes ulak.cmd that hardcodes -ExecutionPolicy Bypass when dispatching to ulak.ps1 (line 147). Defensible for an installer the user explicitly ran, but it normalizes the anti-pattern on the target.

**bin/ulak â€” LOW**: cmd_init takes positional arg as a directory path without traversal validation (bin/ulak:73, 77, 105). ulak init ~/.ssh would append a governance block to ~/.ssh/CLAUDE.md â€” not dangerous alone, but brittle.


### B. Hook surface

**.claude/settings.json â€” MEDIUM**: disableSkillShellExecution: false (line 61) plus Bash(find *) allows arbitrary -exec execution (find /tmp -exec sh -c to run curl piped to sh). BFLA-vulnerable allowlist: authorizes the tool family without constraining dangerous flags.

**.claude/settings.json â€” MEDIUM**: Read(./.env) deny list uses relative paths. Transitive agents that cd into subdirs bypass the relative match. Prefer absolute or glob denies (Read(**/.env)).

**templates/saas-starter/.claude/settings.json.template â€” HIGH**: allows Bash(docker compose:*) alongside Edit(**) + Write(**) with shell execution enabled. A command like "docker compose run --rm -v /:/host ubuntu cat /host/etc/shadow" produces host-file read â€” classic container escape via bind mount. Every scaffolded project inherits the surface. Write deny only covers ./.env and ./.env.local; apps/x/.env.local still writable, contradicting AP-19 prevention in accompanying docs.

### C. Git history secrets â€” CRITICAL

Commit 4f2f5cf (tag v2.1.4, Apr 2026) still contains:
- Resend API key: re_J... (full 35-char key)
- Cloudflare API token: cfk_... (36-char token)
- VPS IPv4: [REDACTED_VPS_IP]

Redaction commit d1d05d6 self-documents the leak but tag v2.1.4 remains reachable via git show on that path, and from GitHub web UI at the tagged commit. The commit message confirms the keys were published to origin/main in v2.1.4 tag.

Blast radius: Resend key grants outbound-mail send as the owner (phishing as the brand); Cloudflare token scope unknown (prefix-only leak per commit note; consumers should assume full). Operator stated rotate Resend immediately but with v2.1.4 tag intact the window never closed.

No secret found in HEAD via grep for AKIA, sk-ant-, ghp_, xoxb-, BEGIN RSA/OPENSSH/PRIVATE, Bearer tokens, JWT-like strings. Only history leak is the v2.1.4 artefact. settings.local.json historical commit 5616234 shows a low-privilege allow list (WebFetch + MCP query-docs) â€” minimal blast radius from that leak.

### D. Example artefact credentials

docs/examples/*.md and reports/current/*.md scanned for AKIA..., sk-ant-..., ghp_..., Bearer..., -----BEGIN â€” zero matches. Examples use abstract placeholders. .gitleaks.toml at HEAD is clean. .env / .env.local files do not exist in the repo â€” good.

### E. Scaffolder template safety

**HIGH â€” RLS tenant isolation hole** in templates/saas-starter/supabase/migrations/00002_rls_policies.sql.template:63-82. role_admin_write and role_admin_update policies check only role in (admin) with no tenant_id = public.user_role_assignments.tenant_id constraint. An admin of tenant A can INSERT/UPDATE role assignments for users in tenant B â€” horizontal privilege escalation across tenants. The audit_log audit_admin_read policy (line 89-95) correctly scopes by tenant_id; the user-role policies regress from that pattern.

**MEDIUM â€” middleware public-prefix gap** at templates/saas-starter/middleware.ts.template:41-44. PUBLIC_PREFIXES includes /, and the matcher config on line 61-63 excludes api/public entirely. Net: /api/public/* never hits auth. If a future contributor adds /api/public/debug or /api/public/admin-op, there is no gate.

**MEDIUM â€” Service role client singleton** in lib/supabase/admin.ts.template:19 stores a module-scoped _admin client. In a serverless runtime with module reuse across tenants (Vercel/Cloudflare Workers), persistent state is fine for stateless service role, but a future change adding user context would leak cross-request.

**MEDIUM â€” deploy rollback race** in templates/saas-starter/infrastructure/deploy.sh.template:62-83. $PREVIOUS_COMMIT captured before git fetch + git checkout $COMMIT; rollback leaves stale .next/ in place. $COMMIT unvalidated. Defense-in-depth: validate against strict regex.

**LOW â€” kale-kapisi.sh.template sshd_config sed rewriting**: multiple sed calls are brittle against non-default sshd_config. sshd -t (line 64) mitigates crash risk, not policy correctness.

**LOW â€” install-hooks.sh.template bypass**: grep for preflight-bypass marker on last commit message (line 22) is an unkeyed honor-system token. Any committer who knows the string bypasses preflight.

### F. Governance gaps

**MEDIUM â€” no key-rotation rehearsal evidence**: secrets-rotation-policy.md specifies cadence but there is no reports/current/secret-rotation-log.md committed showing a completed rotation.

**MEDIUM â€” scripts/check-secret-rotation-due.sh does not exist**: secrets-rotation-policy.md:104 promises this CI check. ls scripts/ shows no such file. Policy text is ahead of implementation â€” false-green risk.

**LOW â€” MCP allowlist enforced at doc level only**: mcp-governance.md relies on release-readiness-auditor. No load-time check in .claude/settings.json prevents MCP activation.

**LOW â€” hook governance bypass token undocumented**: hook-governance.md does not define a break-glass procedure to temporarily disable a hook.


### G. Did-you-know adversarial findings

**DY-SEC-01**: README + 4 runbooks promote curl | sh and iwr | iex without checksum verification. Fix: publish SHA256 in signed Release body; update docs to sha256sum check before sh.

**DY-SEC-02**: validate-schemas.sh fetches JSON schemas from json.schemastore.org at CI time (line 99). If the network is down or schemastore.org is hijacked, validation silently passes with WARN (line 127) or imports attacker-controlled schema. Vendor schemas into schemas/ with hash pinning; fail-closed on fetch error.

**DY-SEC-03**: settings.local.json HEAD contains a Bash(cp ...) entry pointing into an adjacent operator project path on the operator machine. Gitignored now, but the previous incident 2fcb2534 proves this can be mis-committed.

**DY-SEC-04**: .gitignore covers .env and .env.* but apps/*/.env.local pattern only in the template gitignore. Partial adopters can track apps/foo/.env.local. AP-19 anti-pattern vulnerability surface.

**DY-SEC-05**: .claude/logs/*.log rotated by SessionStart hook. Current hook at line 34 does NOT include tool arguments â€” good. A future contributor adding CLAUDE_TOOL_INPUT for debug would land secrets in a local log file.

**DY-SEC-06**: fetch-design-references.sh curl writes attacker-controlled markdown to disk at line 111. An attacker who compromises upstream VoltAgent/awesome-design-md gets prompt-injection into every downstream Claude session that reads the design reference.

**DY-SEC-07**: No CVE scanning gate. package.json pins better-sqlite3 ^11.0.0, commander ^12.1.0, etc. without pnpm audit / npm audit in CI.

**DY-SEC-08**: install.sh trap handler at line 61 does rm -rf on $ULAK_HOME on ULAK_PARTIAL=1 rollback. ULAK_HOME equal to $HOME plus induced clone failure deletes the entire home directory.

---

## Findings (severity-ordered, finding-schema)

- **SEC-B-01** (Critical, 24h): Live credentials permanently recoverable from public git tag v2.1.4.
  - Evidence: commit 4f2f5cf, .gitleaks.toml:34-46 at that commit, cross-ref commit d1d05d6. Tiers: T1.
  - Fix: rotate Resend + Cloudflare keys NOW; decide whether to rewrite history or accept keys as burned forever.

- **SEC-B-02** (Critical, 24h): Command injection in install.sh via ULAK_* env vars through eval.
  - Evidence: scripts/install.sh:50-56 (run uses eval), scripts/install.sh:22-24 (env vars), scripts/install.sh:111-113, 121 (interpolation sites). Tiers: T1.
  - Fix: remove eval, validate env vars against strict regex allowlists, add ShellCheck SC2086 + SC2294 to CI.

- **SEC-B-03** (High, 24h): Scaffolder RLS allows cross-tenant admin write to user_role_assignments.
  - Evidence: templates/saas-starter/supabase/migrations/00002_rls_policies.sql.template:64-82. Tiers: T1.
  - Fix: add with-check clause binding NEW.tenant_id to caller tenant_id (mirror audit_log pattern at line 89-95).

- **SEC-B-04** (High): Scaffolder .claude/settings.json authorizes container escape via Bash(docker compose:*).
  - Evidence: templates/saas-starter/.claude/settings.json.template:21. Tiers: T1.
  - Fix: replace with specific ops (up/down/logs).

- **SEC-B-05** (High): Install one-liner has no signature/hash verification.
  - Evidence: README.md, docs/runbooks/install-methods.md:23, docs/runbooks/first-hour-with-ulak-os.md:15. Tiers: T1.
  - Fix: SHA256 published in Release, Sigstore cosign path.

- **SEC-B-06** (High): fetch-design-references.sh writes attacker-controlled markdown into reports/current/.
  - Evidence: scripts/fetch-design-references.sh:111. Tiers: T2.
  - Fix: pin upstream to known commit, hash-check content, strip injection sigils.

- **SEC-B-07** (Medium): Permissive Bash(find *) plus disableSkillShellExecution=false allows arbitrary exec.
  - Evidence: .claude/settings.json:7, 61. Tiers: T1.
  - Fix: narrow to find-by-name pattern; disable skill shell execution unless needed.

- **SEC-B-08** (Medium): middleware public-prefix + matcher exclusion skips /api/public entirely.
  - Evidence: templates/saas-starter/middleware.ts.template:41-63. Tiers: T1.
  - Fix: document and add integration test.

- **SEC-B-09** (Medium): validate-schemas.sh silently passes on network failure.
  - Evidence: scripts/validate-schemas.sh:99-132. Tiers: T1.
  - Fix: vendor schemas, fail-closed on fetch error.

- **SEC-B-10** (Medium): Deploy script rollback does not reset .next/; COMMIT arg unvalidated.
  - Evidence: templates/saas-starter/infrastructure/deploy.sh.template:62-83. Tiers: T2.
  - Fix: validate COMMIT via regex; rm -rf .next before rebuild-on-rollback.

- **SEC-B-11** (Medium): secrets-rotation-policy.md references scripts/check-secret-rotation-due.sh that does not exist.
  - Evidence: docs/governance/secrets-rotation-policy.md:104. Tiers: T1.
  - Fix: write or remove claim.

- **SEC-B-12** (Low): install-hooks.sh template bypass token is unsigned.
  - Evidence: templates/saas-starter/scripts/install-hooks.sh.template:22. Tiers: T1.
  - Fix: HMAC or drop.

- **SEC-B-13** (Low): install.sh trap rm -rf uses untrusted ULAK_HOME on rollback.
  - Evidence: scripts/install.sh:63. Tiers: T1.
  - Fix: validate ULAK_HOME is under HOME and basename is .ulak-os before rm.

- **SEC-B-14** (Low): MCP allowlist enforcement is doc-layer only; no load-time gate.
  - Evidence: docs/governance/mcp-governance.md:104-110. Tiers: T2.
  - Fix: SessionStart hook that diffs .mcp.json vs mcp_authorized_tools; abort on mismatch.


---

## Exploit PoC sketches â€” top 3

### PoC 1 (SEC-B-01) â€” Extract leaked secrets from public tag

    git clone https://github.com/osrt91/ulak-os.git
    cd ulak-os
    git show 4f2f5cf:.gitleaks.toml | grep -Eo "re_[A-Za-z0-9_]{30,}|cfk_[A-Za-z0-9]{30,}"
    # returns the two burned keys

### PoC 2 (SEC-B-02) â€” Inject via ULAK_BRANCH into install.sh eval

Attacker crafts an env var ULAK_BRANCH containing a single quote followed by shell commands. When run() calls eval on the git clone line that interpolates ULAK_BRANCH inside single quotes, the eval splits on semicolons and runs the attacker commands as the victim uid. Net: arbitrary RCE from any shell one-liner the victim is tricked into running.

### PoC 3 (SEC-B-03) â€” Cross-tenant admin escalation

    -- As admin of tenant A, signed in with Supabase JWT
    insert into public.user_role_assignments
      (user_id, tenant_id, role)
    values
      (self_uid, tenant_B_id, "admin");
    -- role_admin_write policy only checks caller.role=admin; no cross-tenant
    -- clause. Caller is now admin of tenant B and can read/write tenant B data.

---

## 24-hour critical gate

MUST close before v1.0.0 public GA:

- SEC-B-01 â€” rotate Resend + Cloudflare keys; decide history rewrite vs burned-key acceptance
- SEC-B-02 â€” remove eval from scripts/install.sh; add arg validation
- SEC-B-03 â€” fix RLS cross-tenant hole in scaffolder template

Publishing v1.0.0 while SEC-B-02 is live means the signature-free install oneliner (SEC-B-05) is an amplifier: a single account takeover gives an attacker a ready-made RCE primitive through every new clone.

---

## Non-persona cross-cuts (overlap with security-hardening-lead)

- Secrets rotation â€” security-hardening-lead owns the policy catalog; red-team observes policy-vs-implementation drift (SEC-B-11). Consensus.
- Hook surface hardening â€” security-hardening-lead lists hook governance; red-team shows concrete exploit paths (SEC-B-07, SEC-B-04).
- Install script â€” red-team owns SEC-B-02 and SEC-B-05.
- RLS template â€” red-team scans policy logic correctness per-table (SEC-B-03).

Where both personas flag the same area with different angles, escalate the combined finding.

---

## Metrics

- findings_total: 14
- critical: 2
- high: 4
- medium: 5
- low: 3
- deadline_24h_count: 3 (SEC-B-01, SEC-B-02, SEC-B-03)
- redacted_live_secrets: 2 (Resend, Cloudflare)
- did_you_know_findings: 8

## Signoff verdict

`signoff_status: BLOCKED`

Justification: Two critical findings are reachable by any internet-facing actor with a git client and a shell. SEC-B-01 is a permanent credential leak in a public tag. SEC-B-02 is a one-character escape from RCE on every first-time install. SEC-B-03 ships a cross-tenant privilege-escalation hole to every scaffolded project. Public GA under these conditions is an integrity-of-product event, not a launch.

The autonomous-program-director owns the final verdict; this report is an input to that verdict.
