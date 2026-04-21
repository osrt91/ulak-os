# Lock File Hygiene

## Why this exists

Claude Code sessions write transient lock files to signal "I'm the active session holding this resource." If a session crashes, is force-killed, or the machine reboots, the lock file persists as a zombie — future sessions see it, assume the resource is held, and refuse to proceed.

The self-audit revealed `.claude/scheduled_tasks.lock` containing a raw `pid` with no TTL, no liveness check, no owner session tag. A machine reboot would leave that lock in place; a new session would then either deadlock or clobber it. Ulak OS's own repo had the same shape.

This doc is the doctrine to prevent zombie locks.

## Lock file contract

Every lock file under `.claude/` (or any Ulak-OS-managed location) MUST record:

| Field | Type | Purpose |
|---|---|---|
| `sessionId` | string | Session UUID holding the lock |
| `pid` | integer | OS process ID of the session |
| `acquiredAt` | ms-epoch integer | When the lock was taken |
| `ttlSeconds` | integer | Default 3600 (1 hour); max 14400 (4 hours) |
| `resource` | string | What's locked ("scheduled-task-runner", "worktree-mutex", etc.) |
| `holder` | string (optional) | Human-readable session description |

Example well-formed lock:

```json
{
 "sessionId": "a3f1-b29c",
 "pid": 18440,
 "acquiredAt": 1776470622303,
 "ttlSeconds": 3600,
 "resource": "scheduled-task-runner",
 "holder": "director-komple-ulakos-self-audit"
}
```

## Liveness check (Phase 0)

The autonomous-program-director runs a liveness sweep at the start of Phase 0 for every lock file under `.claude/`:

1. **TTL check** — if `acquiredAt + ttlSeconds * 1000 < now`, the lock is **expired**. Break it with a log entry in `runtime-manifest.md` under `broken_locks:`.
2. **Pid liveness check** — if the pid is NOT alive on this machine (cross-platform via `ps -p <pid>` on POSIX or `Get-Process -Id <pid>` on Windows), the lock is **stale**. Break it with a log entry.
3. **Both alive + fresh** — lock is **active**. Director either waits (with a 60s backoff) or refuses the run with a clear message about the active session.

## Breaking a lock

Breaking a lock means:

1. Move the old lock file to `.claude/broken-locks/<timestamp>-<resource>.json` (audit trail)
2. Emit a log line to `runtime-manifest.md § broken_locks`:
 ```
 Broken lock at.claude/scheduled_tasks.lock. Reason: pid 18440 not alive on this machine. Moved to.claude/broken-locks/2026-04-18T14:22:01Z-scheduled-task-runner.json.
 ```
3. Proceed to acquire the lock fresh

Never silently delete a zombie lock. The audit trail matters when debugging "why did two sessions run at once".

## TTL discipline

- Default TTL: 3600 seconds (1 hour). Covers the vast majority of interactive sessions.
- Maximum TTL: 14400 seconds (4 hours). Long programs like `/director komple` full runs.
- Lock holders MUST refresh their lock every `ttlSeconds / 2` if they want to extend. Set-and-forget = lock expires mid-run, another session breaks it, conflict.

## Git hygiene

Every lock file pattern under `.claude/` MUST be gitignored. Lock files are per-session runtime state, not source. Committing them leaks operator process IDs and forces merge conflicts on trivial session turns.

Standard `.gitignore` block (covered by `docs/governance/settings-permissions-governance.md` too):

```gitignore.claude/scheduled_tasks.lock.claude/*.lock.claude/worktrees/.claude/broken-locks/
```

## Cross-environment concerns

- **PID collision across hosts** — a stale lock from host A with pid 18440 may coincidentally match a live pid 18440 on host B. Use `hostname` (or a per-host UUID) in the lock file if sessions span hosts.
- **Container restart** — if the session runs inside Docker and the container restarts, old pids inside the container are no longer valid. Container-scoped sessions should use `container_id` in the lock.
- **Worktrees** — each git worktree may have its own `.claude/` tree. Worktree cleanup policy (`docs/governance/memory-hygiene.md`) covers aged worktree dirs; zombie lock files inside aged worktrees are handled by the cleanup pass.

## Integration

- `docs/governance/settings-permissions-governance.md` —.gitignore block for lock files
- `docs/governance/memory-hygiene.md` — worktree cleanup including dead worktrees with stale locks
- `docs/runtime/program-phases.md` — Phase 0 liveness sweep
- `docs/runtime/toolchain-precheck.md` — environment check may record pid capability (ps, Get-Process)
- `.claude/agents/autonomous-program-director.md` — runs the Phase 0 liveness sweep

## Canonical footer

This file is authoritative as of Ulak OS **v2.1.3**. The motivating evidence is `scheduled_tasks.lock` containing pid 18440 from 2026-04-18 with no TTL (FIND-INF-* category in the v2.1.3 audit).
