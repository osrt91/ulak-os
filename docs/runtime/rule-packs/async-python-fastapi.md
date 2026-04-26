# Rule Pack — Async Python + FastAPI

Activated when runtime-manifest detects `python` + `fastapi` AND ANY of: `asyncpg` / `httpx` / `aioredis` / `motor` / `aiokafka` in dependencies, OR `async def` count >50 across `app/`. Sibling to `python-fastapi.md` — that pack covers baseline imperatives; this pack covers async-safety pitfalls that explode under load.

Pattern source: `docs/governance/pattern-import-ledger.md` IL-007 (security/QA scanner SaaS, T1 evidence — 68 sync `db._get_conn()` calls in `async def` handlers triggered event-loop saturation).

## Imperatives

### Sync I/O in async handlers — banned, no exceptions

- An `async def` route handler MUST NEVER call a sync DB client (`psycopg2`, `pymongo`, `redis-py` <4.2 sync mode, `requests`, `urllib`). Each sync call blocks the **entire event loop** — every other in-flight request stalls.
- Rule: if it does I/O and you cannot `await` it, it does not belong in `async def`. Either the function is sync (FastAPI runs it on the threadpool) or you call the I/O on `asyncio.to_thread(...)` / `run_in_executor(...)` — never inline.
- Detection: `grep -rE "^\s+(db|conn|client)\._?get_conn\(\)" app/routers/ | grep -B2 "async def"` — any hit is a finding.
- Stack-specific replacements: `psycopg2` → `asyncpg`; `requests` → `httpx.AsyncClient`; `redis-py` → `redis.asyncio` (4.2+); `pymongo` → `motor`; `boto3` → `aioboto3`.

### Connection pool ownership

- One `asyncpg.Pool` per app instance, created in FastAPI `lifespan` context manager (`startup` is deprecated for async resource ownership). Stored on `app.state.db_pool` — NEVER as a module-level global initialized at import time (`anti-patterns.md` AP-07 cousin).
- Pool size: `min_size = 2`, `max_size = (vCPU * 2) + 1` as a starting heuristic; tune from `pg_stat_activity` peak observation, not guessed.
- `pool.acquire()` inside `async with` — never raw acquire/release, leaks on exception.
- Per-request connection: dependency-injected via `Depends(get_db)` — handlers take `db: asyncpg.Connection`, not `db: asyncpg.Pool`.

### Context vars over thread-local

- `contextvars.ContextVar` for request-scoped state (current user, trace ID, tenant ID) — `threading.local()` is a bug in async (event loop multiplexes one OS thread across many coroutines).
- Set context-var in middleware; read in handler / service / repository.

### Background tasks

- `BackgroundTasks` parameter is for **fire-and-forget after response** — short, idempotent, no critical state mutation. Do NOT use for "send 1000 emails", "rebuild index" — those need a real queue (Celery, Arq, Dramatiq, RQ).
- `asyncio.create_task(...)` inside a handler without holding the result is a **leak** — exception in the task surfaces nowhere. Always `await` the task before responding, OR ship the task to a queue with an audit trail.

### CPU-bound work

- `asyncio.to_thread(cpu_heavy)` for synchronous CPU work (PDF generation, image resize, regex on >10MB input) — keeps event loop free.
- `multiprocessing.Pool` or `concurrent.futures.ProcessPoolExecutor` for true CPU-parallel — async doesn't speed up CPU-bound code, only I/O-bound.
- Heavy ML inference: ship to a separate service with a queue, not inline in the request path.

### Timeouts and cancellation

- Every external HTTP call: `httpx.AsyncClient(timeout=httpx.Timeout(connect=3.0, read=10.0, write=5.0, pool=5.0))` — no naked default-infinite timeouts.
- DB query timeout: `asyncpg` `command_timeout` per query for long-runners; statement-level `SET LOCAL statement_timeout = '5s'` for read-heavy endpoints.
- Handler-level: `asyncio.wait_for(work(), timeout=30)` for endpoints that must respect SLA — return 504 on timeout, not silent hang.
- Cancellation propagation: when client disconnects, FastAPI's `Request.is_disconnected()` polled in long-running endpoints; cancel the downstream work.

### Streaming responses

- `StreamingResponse` for >1MB payloads — generator yields chunks, async generator if I/O is async per chunk. Loading 10MB JSON into a dict to serialize is OOM-class on a 512MB container.
- Server-Sent Events: `EventSourceResponse` (`sse-starlette`) — built-in heartbeat, retry headers, proper Content-Type.

### Test discipline

- `pytest-asyncio` + `httpx.AsyncClient(transport=ASGITransport(app=app))` — async tests against the real ASGI app, not a mock.
- Test transactional: each test runs in a savepoint; rollback at teardown. `pytest-postgresql` or `pytest-docker` for ephemeral PG.
- Coverage on async handlers MUST run with `--cov` flag actually enabled (`anti-patterns.md` AP-28 — declaring `fail_under` in pyproject.toml without `--cov` in the test runner is a false-green CI gate).

### Observability

- Sentry: `sentry-sdk[fastapi]` with `traces_sample_rate=0.1` (or higher in dev); excludes 4xx by default — opt-in for 401/403 if security-relevant.
- Prometheus: `prometheus-fastapi-instrumentator` — request count, latency histogram, in-progress gauge per route.
- Trace propagation: OpenTelemetry FastAPI instrumentation — propagate `traceparent` to downstream `httpx` calls.
- Log correlation: structlog with context-var `trace_id` injected per request — every log line carries it.

### Anti-patterns specifically banned (cross-reference)

- `anti-patterns.md` AP-01 — In-memory state (rate limits, jobs) in process memory: doubly-bad in async (one event loop = state lost on every restart even if app didn't crash).
- `anti-patterns.md` AP-07 — DDL at import time: in async, this also runs on the event loop during startup, blocking the readiness probe.
- `anti-patterns.md` AP-24 — Sync DB calls in `async def`: codified directly here.
- `anti-patterns.md` AP-26 — Zombie router from `include_router` order: async makes this harder to diagnose because trace shows the wrong handler with no obvious failure.
- `anti-patterns.md` AP-31 — Cache invalidation timing race: async amplifies because the window between write-commit and cache-invalidate is multi-coroutine.

## Validator rules (CI-blocking)

- `scripts/validate-no-sync-in-async.sh` — grep + AST walk: any `async def` containing a known-sync DB/HTTP call is an error
- `scripts/validate-asyncpg-pool-lifecycle.sh` — ensure `lifespan` registers a pool, no module-level `Pool()` instances, all `pool.acquire()` inside `async with`
- `scripts/validate-cov-flag-actually-runs.sh` — preflight script invokes `pytest --cov=app` AND `--cov-fail-under` matches `pyproject.toml fail_under`

## Collision rule

Project `.claude/rules/python-async.md` overrides specific imperatives (e.g., a project has documented reasons for sync inside threaded handler); unmatched inherit. This pack does NOT replace `python-fastapi.md` — it layers on top.

## Integration

- `docs/runtime/rule-packs/python-fastapi.md` — base pack (this one extends)
- `docs/runtime/anti-patterns.md` AP-24, AP-26, AP-28, AP-31 — codify specific pitfalls with file:line evidence
- `docs/governance/observability-baseline.md` — Sentry + Prometheus + OpenTelemetry baseline
- `docs/governance/pattern-import-ledger.md` IL-007 (sync-in-async), IL-011 (cosmetic coverage), IL-014 (cache timing) — provenance

## Canonical footer

Authoritative as of Ulak OS **v1.7.0**. Imported from a Python 3.12 + FastAPI security/QA scanner SaaS observed 2026-04-26 absorption pass #2. The 68-sync-in-async finding (event loop saturation under load) is the load-bearing concrete evidence.
