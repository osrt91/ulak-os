# Hook Governance

## Why this exists

Hooks in Claude Code are deterministic — they run as shell commands at specific lifecycle events (PreToolUse, PostToolUse, Stop, UserPromptSubmit, SessionStart, etc.). They are NOT prompt suggestions; they are guaranteed execution. This makes hooks the right surface for **deterministic guardrails**: things you want to happen every time, not things you hope the model remembers.

Hook governance exists because hooks also run shell with the same permissions as Claude Code itself. A malicious or buggy hook can exfiltrate secrets, delete files, or silently alter behavior. Every hook is a small blast radius you're opening on purpose.

## When a hook is the right tool

Use a hook when:

- The behavior must happen **every time**, with zero reliance on model memory or prompt wording
- The behavior is **simple and deterministic** — something a shell command can do reliably
- The behavior is about **side effects or enforcement**, not reasoning
- The behavior should **fail closed**: if the hook crashes, the lifecycle event halts

Do not use a hook when:

- The behavior requires reasoning or context ("decide whether this edit is reasonable")
- The behavior needs to be adjustable per project without code changes
- The behavior duplicates something a command or agent already does
- The behavior's "side effect" is "append to prompt" — that's a job for memory or commands

## Appropriate hook categories

### Guardrails
- Refuse edits to forbidden paths (e.g., `.env`, `.git/`, prod config)
- Refuse writes outside the project root
- Refuse shell commands matching a blocklist

### Side effects
- Post-edit formatter (Prettier, Black, gofmt)
- Post-edit linter trigger
- Audit log append
- Notification on session stop

### Integrations
- Trigger a CI webhook on session stop
- Sync reports/current to an archive on session stop
- Call a secrets scanner before any commit

### Release gates
- Block session stop if uncommitted changes exist on a release branch
- Block edit of `VERSION` file during non-release sessions

## Security rules

Hooks run as shell. Treat each hook as a small piece of infrastructure.

- **Every hook must be reviewed in diff before merge.** No silent hook additions.
- **Every hook must sanitize its inputs.** Hook input arguments come from tool calls and can contain adversarial paths or arguments.
- **No network calls in hooks by default.** Exceptions must be explicit and justified in the commit.
- **No secrets in hook environment unless scoped.** Hooks inherit the process environment; that's a leak surface.
- **Hooks that modify files must log the modification** so the user knows something ran.
- **Hooks must be idempotent** unless the non-idempotency is the point (and documented).
- **Hooks must fail closed.** If the hook can't verify its own correctness, it halts the operation.

## Bad hook patterns

- A hook that runs on every PostToolUse regardless of matcher — burns time and pollutes logs
- A hook that writes to a file outside the project root
- A hook that changes model behavior by injecting text into the prompt (use memory or commands instead)
- A hook whose command is a long inline shell string instead of a script file with its own review
- A hook that silently suppresses errors
- A hook that runs slow third-party binaries on every edit

## Allowed matcher discipline

When writing hook matchers, be narrow:

- `matcher: "Edit|Write"` is acceptable — two specific tools
- `matcher: ".*"` is almost always wrong — catches everything
- `matcher: "Bash"` is acceptable when you want to gate shell
- `matcher: "Write(src/**)"` is better than `matcher: "Write"` when the intent is specific

## Review checklist

Before merging a hook:

- [ ] Is this deterministic (not reasoning-dependent)?
- [ ] Is the matcher narrow?
- [ ] Are inputs sanitized?
- [ ] Does it fail closed on error?
- [ ] Is there a network call? If yes, is it justified in the commit message?
- [ ] Does it log when it runs?
- [ ] Is the command a script file (reviewable) or an inline one-liner (risky)?
- [ ] Is it idempotent?
- [ ] What is the blast radius if this hook is wrong?
- [ ] Can the user disable it per-session without editing code?

## Integration

- `.claude/settings.json` and `.claude/settings.local.json` — where hooks are declared
- `docs/governance/trust-model.md` — hooks operate on untrusted data; they enforce boundaries around it
- `docs/governance/mcp-governance.md` — related but distinct surface (MCP is a network protocol; hooks are local lifecycle)
