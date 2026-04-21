# Settings & Permissions Governance

## Why this exists

Claude Code's `.claude/settings.json` and `.claude/settings.local.json` control what the agent can read, write, execute, fetch, and which MCP servers it can talk to. A poorly-formed settings pair is an invisible security hole:

- `Bash(*)` authorizes every shell command — including `rm -rf /` and `curl | sh`.
- `Delete(*)` lets the agent wipe arbitrary paths.
- `.claude/settings.local.json` committed to git leaks operator-specific permissions, MCP tokens, and host-specific Bash allowlists to every consumer of the repo.

Ulak OS itself shipped the last defect until v2.1.3: the self-audit found `settings.local.json` **tracked in git** (FIND-SEC-01+02 in the v2.1.3 director run) with `Bash(*)` and `Delete(*)` wildcards. This doc is the doctrine that prevents recurrence.

## The two files

| File | Shape | Committed? | Who owns the content |
|---|---|---|---|
| `.claude/settings.json` | Project-wide defaults, minimal permissions, enabled hooks | YES | Project maintainer |
| `.claude/settings.local.json` | Operator-specific overrides, MCP tokens, per-machine Bash paths | **NO — gitignored** | Individual operator |
| `.claude/settings.local.example.json` | Template that documents the shape + safe defaults | YES | Project maintainer |

If only `settings.json` exists, operators must copy `settings.local.example.json` to `settings.local.json` and tailor it. The example file is the contract; the live file is the execution state.

## Permission form discipline

### Allow list

- **Never** use `Bash(*)` — scope by verb: `Bash(git:*)`, `Bash(npm:*)`, `Bash(ls:*)`, `Bash(docker:*)`
- **Never** authorize `Delete(*)` — scope by directory: `Delete(reports/current/**)`, `Delete(.next/**)`
- `Read(**)`, `Glob(**)`, `Grep(**)` are safe broad grants (non-destructive)
- `Write(**)`, `Edit(**)` inherit the "no destructive" assumption from the broader project; prefer scoped forms if the repo has sensitive directories (e.g., `Write(src/**)` + `Write(docs/**)` only)
- `WebFetch(*)` should be scoped by domain: `WebFetch(domain:docs.claude.com)`, `WebFetch(domain:api.myproject.com)`

### Deny list

Every project `settings.json` SHOULD include a deny block for absolute safety, even if the allow list already omits these:

```json
{
 "permissions": {
 "deny": [
 "Bash(rm -rf /*)",
 "Bash(rm -rf ~*)",
 "Bash(git push --force*)",
 "Bash(git push -f*)",
 "Bash(git reset --hard*)",
 "Bash(curl * | sh)",
 "Bash(wget * | sh)"
 ]
 }
}
```

Deny rules override allow rules. Even if `Bash(git:*)` is allowed, `Bash(git push --force*)` is blocked.

### MCP authorization

Every entry in `enabledMcpjsonServers` (and every tool in `enabled_mcpjson_servers`) must have a **justification** recorded in `active-variables.yaml` under `mcp_authorized_tools` per `docs/governance/mcp-governance.md`. Example:

```yaml
mcp_authorized_tools:
 github:
 justification: "PR review and issue triage for v2.1.3 release; scoped to read + list operations"
 approved_at: 2026-04-18
 approved_by: osrt91
 scope: read-only # or read-write if write operations are intended
```

If a server is enabled without a recorded justification, the release-readiness-auditor flags the run as `settings_governance: fail`.

## Git hygiene

- `.claude/settings.local.json` — **gitignored**, never committed
- `.claude/settings.local.example.json` — committed; template + governance notes
- `.claude/scheduled_tasks.lock` — gitignored (per-session state; see `docs/governance/lock-file-hygiene.md`)
- `.claude/worktrees/` — gitignored (transient per-session; see `docs/governance/memory-hygiene.md` worktree cleanup)
- `.claude/logs/` — already gitignored (per existing `.gitignore` pattern)

Sample `.gitignore` block for Claude Code projects:

```gitignore
# Claude Code local settings (per-operator, never commit).claude/settings.local.json.claude/scheduled_tasks.lock.claude/worktrees/.claude/logs/
```

## Hooks surface

`settings.json` may declare hooks (SessionStart, PreBash, PostEdit, etc.). Every hook declaration MUST:

1. Point to a script in the repo (no inline shell beyond one-liners) so the hook body is code-reviewed
2. Have a documented purpose in `docs/governance/hook-governance.md`
3. Never execute destructive operations on failure (anti-pattern: SessionEnd hook that `rm -rf`s work)

A project with zero hooks declared is not a gap; it's a minimal surface. But if governance expects enforcement (e.g. a mandatory log-rotation hook per FIND-INF-04 in v2.1.3 audit), the absence IS a finding.

## Worked examples

### Minimal safe `settings.json` (for a quiet project)

```json
{
 "$schema": "https://json.schemastore.org/claude-code-settings.json",
 "permissions": {
 "allow": [
 "Read(**)",
 "Glob(**)",
 "Grep(**)",
 "Edit(**)",
 "Write(**)",
 "Bash(git:*)",
 "Bash(npm:*)",
 "WebFetch(domain:docs.claude.com)"
 ],
 "deny": [
 "Bash(rm -rf /*)",
 "Bash(git push --force*)",
 "Bash(git reset --hard*)"
 ]
 }
}
```

### -derived lesson — what NOT to ship

settings.json (before the self-audit) shipped:

```json
{ "permissions": { "allow": ["Bash(*)", "Read(*)", "Write(*)", "Edit(*)", "MultiEdit(*)", "Delete(*)"] } }
```

This is **effective root access** inside the repo. The fix: replace with scoped verbs + a deny list as shown above. The Ulak OS rule-pack-governance `api-security` pack + this doc now encode the lesson.

## Integration

- `docs/governance/mcp-governance.md` — MCP authorization detail (justifications, rotation, revocation)
- `docs/governance/lock-file-hygiene.md` — lock-file hygiene referenced above
- `docs/governance/hook-governance.md` — hook authoring rules
- `docs/governance/memory-hygiene.md` — worktree and session cleanup
- `docs/governance/rule-collision-matrix.md` — deny rules override allow rules (collision priority 1: security)
- Release readiness: release-readiness-auditor agent reads this doc to gate `settings_governance`

## Canonical footer

This file is authoritative as of Ulak OS **v2.1.3**. -derived SP (settings-permissions) findings FIND-SEC-01+02 and the pattern extraction bucket G-04 are the evidence base.
