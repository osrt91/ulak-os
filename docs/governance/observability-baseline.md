# Observability Baseline

## Why this exists

Several Ulak-family projects ship with **zero observability**: no structured logs, no metrics, no error tracker (Sentry / Rollbar / Honeybadger), no tracing. Production runs blind. A crash is visible only if a user reports it. A performance regression is visible only when someone manually notices slowness. A security event is visible only when it's too late.

"Observability" is not optional for production services. This doc sets the minimum baseline every Ulak OS project should meet before a `signoff_status: ready` verdict.

## The three pillars

### 1. Logging

**Minimum**: structured JSON logs to stdout; captured by container runtime / systemd / PM2 and rotated.

- **Log format**: JSON (not plain text). Fields: `timestamp` (ISO 8601 UTC), `level`, `message`, `logger`, `trace_id`, plus domain-specific fields
- **Log levels**: `debug` (dev only), `info`, `warn`, `error`, `fatal`; no `printf` style debugging in production code
- **Request correlation**: every HTTP request / background job / scheduled task carries a `trace_id`; logs at every layer include it
- **PII**: NO emails / passwords / tokens / card numbers in logs. Fields are redacted at the logger (e.g., `logger.scrub(['email', 'phone'])`)
- **Retention**: 30 days minimum locally, 90 days in aggregated storage (SaaS log platform or S3 archive)

### 2. Metrics

**Minimum**: RED method (Rate, Errors, Duration) for every HTTP endpoint + RED for every background job.

- **Rate**: requests/second per endpoint
- **Errors**: error count per endpoint (5xx + 4xx where applicable)
- **Duration**: p50 / p90 / p99 latency per endpoint
- **Resource**: CPU / memory / disk per host; DB connection pool utilization; Redis memory
- **Business**: signup rate, conversion rate, revenue per hour, refund rate — per product

Stack options (pick ONE stack per project):
- **Cloud SaaS**: Datadog, New Relic, Grafana Cloud (easy, expensive)
- **Self-hosted**: Prometheus + Grafana (free, requires ops)
- **Lightweight**: just OpenTelemetry + JSON logs + `jq` queries (for very small products)

### 3. Error tracking

**Minimum**: automatic exception capture + alerting.

- **Sentry** (SaaS; generous free tier) — default recommendation
- **Rollbar**, **Honeybadger**, **Bugsnag** — equivalents
- Every unhandled exception → auto-reported
- Release tagging: each deploy registers its git SHA with Sentry → errors attributed to release
- Source maps uploaded (for TypeScript / minified JS) → readable stack traces
- Alert rules: 3 new errors in 5 min OR any new error in production = page operator

## Minimum setup per stack

### Node.js / Next.js

```typescript
// instrumentation.ts (Next.js 15+)
import * as Sentry from '@sentry/nextjs'

if (process.env.NODE_ENV === 'production') {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.VERCEL_ENV || 'production',
    release: process.env.VERCEL_GIT_COMMIT_SHA || process.env.GIT_SHA,
    tracesSampleRate: 0.1,
    // Scrub PII
    beforeSend(event) {
      if (event.user?.email) event.user.email = '[redacted]'
      return event
    },
  })
}
```

Plus: `pino` or `winston` for structured logs; export metrics via `/metrics` endpoint (Prometheus format).

### Python / FastAPI

```python
# app/observability.py
import logging
import structlog
from sentry_sdk import init as sentry_init
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_init(
    dsn=os.getenv("SENTRY_DSN"),
    environment=os.getenv("ENV", "production"),
    release=os.getenv("GIT_SHA"),
    traces_sample_rate=0.1,
    integrations=[FastApiIntegration()],
)

structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.JSONRenderer(),
    ],
)

log = structlog.get_logger()
```

Plus: `prometheus-fastapi-instrumentator` for metrics.

### Docker / Compose

Every service runs with:

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "5"
    labels: "service"
```

Plus: log aggregation sidecar (Vector / Promtail / Loki) OR stream to cloud (CloudWatch / Datadog Agent).

## Phase 5 §5c gate

At each release, validation includes:

- `observability_logging: pass|fail` — structured JSON logs emitted at INFO+ level; no plaintext secrets in sampled output
- `observability_metrics: pass|fail` — `/metrics` or equivalent endpoint responds; RED for top 3 endpoints is measurable
- `observability_errors: pass|fail` — error tracker configured + test exception captured during staging run

Failure to meet baseline = `signoff_status: conditional` with "observability-below-baseline" residual risk.

## Cost discipline

Observability has operational cost. Baseline DOES NOT mean "capture everything":

- Sample traces at 10% (or lower for high-volume endpoints)
- Log at INFO level in prod (DEBUG only on dedicated debug hosts)
- Retention: 30 days hot, 90 days cold; beyond that archive to S3
- Scrub PII before upload (regulatory + cost)

## Upgrade paths

- **Zero → baseline** (this doc): structured logs + Sentry + RED metrics = ~2 days of work
- **Baseline → good**: APM (distributed tracing via OpenTelemetry), log aggregation (Loki / Elasticsearch), custom business metrics = ~2 weeks
- **Good → advanced**: trace-based alerting, anomaly detection, SLO dashboards = ~2 months

## Anti-patterns

- **`console.log` / `print` debugging shipped to production** — unstructured, unqueryable, not correlated
- **"Check the logs on the server"** — requires SSH, doesn't scale, misses intermittent issues
- **No release tracking** — errors appear but can't be attributed to the deploy that introduced them
- **Paging on every 5xx** — alert fatigue; rate-limit pages OR scope to error-rate anomalies
- **Metrics without dashboards** — data exists but nobody looks; dashboards are the forcing function

## Integration

- `docs/runtime/program-phases.md §Phase 5 §5c` — validation gates include observability
- `docs/runtime/sector-packs.md` — most sector packs assume observability baseline is met
- `docs/runtime/anti-patterns.md` — `No observability dashboards` anti-pattern cross-references here
- `docs/governance/secrets-rotation-policy.md` — observability SaaS keys rotate per policy
- `.claude/agents/infra-release-sre.md` — runs baseline gap analysis

## Canonical footer

Authoritative as of Ulak OS **v2.2.1**. Evidence base: cross-project scan confirming zero observability in the monorepo e-commerce project + the e-commerce project + the portfolio + CMS project + others (no Sentry/Datadog/logging library declared).
