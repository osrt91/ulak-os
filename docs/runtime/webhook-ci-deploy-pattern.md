# Webhook-Triggered CI Deploy Pattern

## Why this exists

Production deploy can be initiated from multiple sources: push-to-main (CI-driven), manual SSH, cron-poll fallback (see `docs/runtime/architecture-currency.md §Deploy resilience`), or **webhook-triggered from a third party** (CI completion → POST to deploy webhook on target host). The last is increasingly common — GitHub Actions run tests, then POST to a private deploy endpoint which pulls + rebuilds + health-checks. This pattern has its own discipline.

the security scanner project-family projects (a security scanner project, an EdTech AI platform project, a community/event platform project) use GitHub Actions → webhook POST pattern. Without discipline, it silently fails (`curl` returns 200 but deploy script logs show crash; CI still reports green).

## When to apply

Apply webhook-triggered deploy when **all** are true:

- Target host is self-managed (VPS, bare metal, edge box) — not a managed PaaS with native CI hook
- CI produces an artifact (image, zip, build dir) that the webhook endpoint consumes
- Operator wants CI-to-deploy separation of concerns (CI is stateless; webhook target has the deploy runtime)

Do NOT use when:

- PaaS native integration exists (Vercel push, Railway auto-deploy, Cloudflare Pages) — use that
- Deploy path is push-to-main only (no external trigger needed)
- Target has no persistent state (webhook state machine is overkill)

## Protocol

### 1. Webhook endpoint contract

Endpoint accepts POST with:
- `Authorization: Bearer <deploy-token>` — rotatable secret, separate from app secrets
- JSON body: `{ "commit": "<sha>", "branch": "main", "trigger_source": "github-actions|manual|scheduled" }`
- Returns 202 Accepted + `X-Deploy-Id: <uuid>` — NOT 200. 202 signals "received, processing async".

### 2. Deploy script idempotency

The script run by the endpoint MUST:
- Check if `commit` is already deployed → return 200 with `already-deployed` status
- Acquire a flock-guarded lock (per `docs/governance/lock-file-hygiene.md`)
- Pull + build + restart in one atomic sequence; each step logs to a deploy-id-scoped file
- Run smoke check post-restart: `curl localhost:<port>/health` + sample read endpoint
- On smoke-check failure: rollback (restore previous image / previous symlink) before returning

### 3. CI-side

The CI workflow step that triggers deploy MUST:
- Only trigger on green CI (all prior jobs passed)
- Send `commit` = `${{ github.sha }}` so the deploy knows what to pull
- Check the webhook response: `X-Deploy-Id` header present, body confirms `status: processing`
- Poll `/deploy-status/<deploy-id>` (or wait for a callback) until complete OR timeout (default 10 minutes)
- CI fails if deploy status ends in `failed` or `rolled-back`

### 4. Observability

- Every webhook invocation logs: source IP, `X-Deploy-Id`, commit, trigger source, result, duration
- Logs retained 90 days minimum (rollback investigation)
- Alerting on: deploy failure rate > 5% in last hour, smoke-check failure, rollback triggered

### 5. Anti-patterns to avoid

- **Webhook endpoint public without auth** — anyone with the URL can deploy arbitrary commits
- **CI reports green on deploy failure** — happens when CI step doesn't check webhook response body; fix: require explicit success from the deploy-id poll
- **No health check post-deploy** — fake rollback (AP-12): deploy "succeeds" but app is broken
- **No flock on deploy script** — concurrent webhook invocations corrupt state
- **Deploy token rotated without CI update** — webhook returns 401, CI is green (see above) because response not checked
- **AP-18 Static HMAC over empty body** — `openssl dgst -sha256 -hmac $SECRET` computed over `""` or `"{}"` produces a constant signature; anyone who observes it replays forever. Fix: sign the full body including commit + timestamp + nonce; verify timestamp within 5-minute replay window.

### 6. Post-deploy health-probe contract (v2.2.1 addition)

The webhook endpoint MUST run a post-deploy health probe that is stricter than "process started":

1. **`/health` endpoint returns 200** — the application process is up and accepting HTTP
2. **Sample read endpoint returns expected shape** — e.g., `/api/public/status` returns valid JSON with `{ ok: true, version: <deployed-sha> }`; this proves the NEW code is running (not the old one on a still-warm port)
3. **Sample write path (if applicable)** — dry-run write to a canary table; confirms DB connection + migrations landed
4. **Dependency liveness** — probes Redis / external APIs the app depends on
5. **If ANY probe fails** — automatic rollback to previous image/symlink; webhook response `state: rolled-back`

The time between "deploy script says done" and "health probe passes" is the **silent window**. A deploy script that skips health probing guarantees the silent window is infinite when something breaks. Fake rollback (AP-12) is the anti-pattern this section closes.

## Worked example — an EdTech AI platform project

```yaml
# .github/workflows/deploy.yml (excerpt)
on:
  push:
    branches: [main]

jobs:
  test:
    # ... unit + integration + E2E tests
  deploy:
    needs: test
    if: success()
    runs-on: ubuntu-latest
    steps:
      - name: Trigger deploy webhook
        run: |
          RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
            -H "Authorization: Bearer ${{ secrets.DEPLOY_TOKEN }}" \
            -H "Content-Type: application/json" \
            -d "{\"commit\":\"${{ github.sha }}\",\"branch\":\"main\",\"trigger_source\":\"github-actions\"}" \
            https://deploy.example.com/webhook)
          STATUS=$(echo "$RESPONSE" | tail -n 1)
          BODY=$(echo "$RESPONSE" | head -n -1)
          if [[ "$STATUS" != "202" ]]; then
            echo "::error::Deploy webhook returned $STATUS"
            echo "$BODY"
            exit 1
          fi
          DEPLOY_ID=$(echo "$BODY" | jq -r '.deploy_id')
          echo "Deploy id: $DEPLOY_ID"
          # Poll for completion (up to 10 min)
          for i in $(seq 1 60); do
            sleep 10
            STATE=$(curl -s -H "Authorization: Bearer ${{ secrets.DEPLOY_TOKEN }}" \
              https://deploy.example.com/status/$DEPLOY_ID | jq -r '.state')
            case "$STATE" in
              complete) echo "Deploy complete"; exit 0 ;;
              failed|rolled-back) echo "::error::Deploy $STATE"; exit 1 ;;
              processing) echo "Still processing..."; continue ;;
            esac
          done
          echo "::error::Deploy polling timed out"
          exit 1
```

## Integration

- `docs/runtime/architecture-currency.md §Deploy resilience` — cron-poll is the CI-independent fallback when webhook-deploy is the primary path
- `docs/governance/lock-file-hygiene.md` — deploy-script flock discipline
- `docs/runtime/anti-patterns.md` — AP-12 (fake rollback deploy), AP-03 (non-blocking CI)
- `docs/runtime/sector-packs.md §vps-nginx-compose-topology` — compatible with this deploy model

## Canonical footer

Authoritative as of Ulak OS **v2.2.0**. Evidence base: an EdTech AI platform project `.github/workflows/deploy.yml` + a security scanner project / a community/event platform project deploy scripts. Added in v2.2.0 cross-project pattern absorption pass.
