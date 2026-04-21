# Rule Pack — Docker + Compose

Activated when runtime-manifest detects `docker-compose.yml` or `Dockerfile` in repo root.

## Imperatives

- Every service runs as non-root (`USER appuser` in Dockerfile; `user:` in compose)
- Every service declares a healthcheck with sensible interval + timeout
- Every service declares `mem_limit` (compose) or memory reservation
- No raw `/var/run/docker.sock` bind-mount in an app container — use docker-socket-proxy with verb allowlist (anti-pattern AP-05)
- Production bindings use `127.0.0.1:<port>`; expose publicly only through the reverse proxy
- Prod compose adds `security_opt: [no-new-privileges:true]` and `cap_drop: ALL` for app containers
- Base compose = security hardened defaults; dev override adds source mounts + exposed ports; prod override forces loopback binds
- No secrets in image layers (`COPY.env.env` is rejected); use env_file or secret manager

## Collision rule

Project `.claude/rules/docker.md` overrides specific imperatives; unmatched inherit from this pack.
