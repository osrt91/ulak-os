# Rule Pack — Python + FastAPI

Activated when runtime-manifest detects `python` + `fastapi` in requirements.txt / pyproject.toml.

## Imperatives

- Python 3.12+ only (f-string debug `=`, PEP 695 generics)
- Type hints everywhere; `mypy --strict` must pass; no bare `Any`
- Pydantic v2 for request/response models; no plain dicts into DB / JSON columns
- `async def` for every I/O endpoint; never block the loop with sync SDKs
- Pin exact versions in requirements (or hash-pin); no unbounded ranges in prod
- Router files ≤400 LOC — split by domain (`app/routers/<domain>.py`)
- Never run `CREATE TABLE` at import time — use a migration runner (anti-pattern AP-07)
- Rate limiting must hit durable storage (Redis), not process memory (anti-pattern AP-01)

## Collision rule

Project `.claude/rules/python.md` overrides specific imperatives; unmatched inherit from this pack.
