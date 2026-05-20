# ajanscan.com â†’ Ulak OS Pattern Extraction (Phase A)

**Date**: 2026-04-18
**Source project**: `C:\Users\osrt91\desktop\proje\ajanscan.com\` (production SaaS â€” web security/QA scanner, multi-tenant Supabase, Iyzico payments, reseller tier)
**Target**: Ulak OS runtime + governance surface enrichment
**Method**: 3-agent parallel extraction (Explore deep-reader + architecture-lead + prompt-skill-plugin-governor) followed by dedup against Ulak OS current state
**Scope**: vendor-agnostic, cross-project reusable patterns only â€” project-specific details excluded

## Executive summary

**39 unique extractable patterns** identified, mapped to **7 target surfaces** in Ulak OS:

| Target surface | New entries | Extends existing |
|---|---|---|
| `docs/runtime/anti-patterns.md` | 9 | â€” |
| `docs/runtime/sector-packs.md` | 6 new sector packs | 1 extended |
| `docs/runtime/rule-packs/*.md` | **new directory** + 4 starter packs | â€” |
| `docs/governance/` | 6 new files | 4 extended |
| `.claude/skills/` | 3 new skills | â€” |
| `.claude/commands/` | 1 new command | â€” |
| `.claude/agents/` | â€” | 2 enhanced (design-system-architect, autonomous-program-director) |

**Top 10 critical findings (T1 evidence, critical priority):**
1. God module / >3000 LOC file anti-pattern with Strangler Fig migration path
2. In-memory state (rate limits, active scans) â€” not durable across restart
3. JWT/tokens in URL query params or WebSocket path
4. Non-blocking CI gates (`continue-on-error: true` on security/test jobs)
5. `user_metadata` used as authorization source on Supabase stacks
6. Raw `docker.sock` bind-mount in app container (needs docker-socket-proxy)
7. Payment provider hardcoded to sandbox OR live (no env-only toggle)
8. Unvalidated JSONB storage (no Pydantic/schema guard on write)
9. No rule-pack unit type in Ulak OS decision matrix (governance gap)
10. No customer/admin/partner-reseller product-surface split governance doc

**Non-obvious did-you-know items (would have been missed by a shallow scan):**
- ajanscan's `.claude/settings.json` allows `Delete(*)` + `Bash(*)` wildcards â€” Ulak OS has NO governance on well-formed `settings.json`
- `scheduled_tasks.lock` carries a pid but no TTL/liveness protocol â€” stale pid can deadlock future sessions
- 12 stale `worktrees/agent-*` dirs (~19 days old) with no cleanup policy
- ajanscan's `rules/` folder (docker/python/security/typescript) is a `<500-byte always-on imperative guardrail` pattern that Ulak OS doesn't have a category for
- `user_metadata` is client-mutable via Supabase SDK â€” but Ulak OS current RLS-asymmetry anti-pattern doesn't cover this specific failure mode
- `continue-on-error: true` on gitleaks + security audit means secrets deploy silently â€” no Ulak OS anti-pattern covers "security gate that doesn't gate"
- Stripe test keys, Groq API keys, Supabase service-role key present in git history â€” Ulak OS has "secrets in committed files" but no specialist agent for rotation/history-purge workflow
- Iyzico webhook signature verification exists but `AJANSCAN_IYZICO_CAPTURE=1` raw-body capture is env-gated â€” this sandbox/live + capture pattern is worth a sector-pack section
- Compliance modules (CVSS/MITRE/NIST/ISO/KEV) are **addressable as a framework-registry** with one adapter per framework + one aggregator â€” regulated-SaaS pack
- Cron-poll deploy fallback (`infrastructure/deploy-poll.sh`) is a CI-quota-exhaustion workaround â€” but also a **deploy resilience pattern** worth promoting

## Bucket 1: ANTI-PATTERNS (9 new entries for `docs/runtime/anti-patterns.md`)

Dedup note: Ulak OS already covers "God files", "Schema drift", "RLS asymmetry", "Dead code", "Secrets in committed files", "No rollback plan". Below are genuinely new.

| # | Entry | Section | Source (ajanscan file:lines) | Priority |
|---|---|---|---|---|
| AP-01 | **In-memory state not durable** (rate limits, active jobs stored in process memory; restart = data loss; horizontal scale impossible) | Data / persistence | `anti-patterns.md:182-213`, `ajanscan.py` (slowapi default, active_scans dict) | critical |
| AP-02 | **Token in URL / query parameter** (JWT passed as URL query or WebSocket path; logged by nginx, browser history, CDN, Referrer) | Security | `anti-patterns.md:216-244` | critical |
| AP-03 | **Non-blocking CI gate** (`continue-on-error: true` on secrets/security/test jobs â†’ gate gives false green) | Infra / release | `anti-patterns.md:248-284` | critical |
| AP-04 | **Unvalidated JSONB storage** (write to JSONB column with no Pydantic/schema guard, no DB check constraint â†’ silent data corruption) | Data / persistence | `anti-patterns.md:155-178` | high |
| AP-05 | **Raw docker.sock bind-mount** (app container mounts `/var/run/docker.sock` directly; must use docker-socket-proxy with verb allowlist, read-only socket, cap_drop: ALL) | Infra / release | `docker-compose.yml:103-120` | critical |
| AP-06 | **`user_metadata` used as authz source** (on Supabase/GoTrue, `user_metadata` is client-writable via SDK â†’ authorization bypass; canonical source must be server-side DB row with TTL cache) | Security | `auth.py:37-73` | critical |
| AP-07 | **DDL at router import time** (`CREATE TABLE IF NOT EXISTS` run at module import â†’ race conditions on first boot, schema drift across instances, uncaught migration failures) | Data / persistence | `app/routers/reseller.py:20-42` | medium |
| AP-08 | **Payment provider hardcoded to sandbox or live** (sandbox/live not a pure env-var switch, webhook signature not verified, same code path not exercised in both modes) | Backend / API | `payment.py:35-43, 717-742` | critical |
| AP-09 | **Copy-paste service logic** (same 100+ LOC API call duplicated 3+ times with minor variations; drift between copies) | Architectural | `anti-patterns.md:35-60` | high |

## Bucket 2: SECTOR PACKS (6 new + 1 extension to `docs/runtime/sector-packs.md`)

Dedup note: Ulak already has `saas`, `fintech`, `marketplace`, `enterprise-b2b`, `health-sensitive`, `ai-copilot`. Below are genuine additions.

| # | Pack name | Why new (not covered by existing packs) | Source |
|---|---|---|---|
| SP-01 | `multi-tenant-supabase` | Shared PG + per-tenant GoTrue + per-tenant PostgREST + per-tenant JWT_SECRET; deploy precheck for tenant Docker network | `SUPABASE.md:24-31`, `docker-compose.yml:48`, `deploy.sh:10` |
| SP-02 | `container-orchestrating-app` | Apps that introspect/spawn sibling containers via docker-socket-proxy (scanner-pattern) | `docker-compose.yml:103-120` |
| SP-03 | `payment-integrated-saas` | Sandboxâ†”live env toggle, webhook signature verification, TRY+USD dual-amount tables, yearly-discount invariants | `payment.py` (full) |
| SP-04 | `regulated-saas` (cybersecurity / fintech / healthcare variants) | Compliance framework-registry: one adapter per mandated framework (CVSS/MITRE/NIST/ISO/KEV) + aggregator producing audit-ready report | `compliance_reporter.py`, `cvss_processor.py`, `mitre_attack.py`, `nist_csf.py`, `iso27001.py`, `kev_checker.py` |
| SP-05 | `reseller-enabled-saas` | Fourth surface beyond public/customer/admin; plan-capability gating; per-reseller branding data model | `app/routers/reseller.py:17`, `app/models/reseller_branding.py` |
| SP-06 | `vps-nginx-compose-topology` | Base + dev + prod compose layering; 127.0.0.1 bind discipline; nginx sole public ingress; "Kale KapÄ±sÄ±" VPS hardening; CI-independent cron-poll deploy fallback | `docker-compose.prod.yml:15-23`, `infrastructure/kale-kapisi.sh`, `infrastructure/deploy-poll.sh` |
| SP-EXT-01 | Extend `saas` pack with **web-quality-scanner sub-pattern** | Plugin system (BasePlugin abstract), 9-category scoring engine, multi-format report generation, PTES phase orchestration | `executive-summary.md:8-11`, `complexity-hotspots.md:70-107` |

## Bucket 3: NEW UNIT TYPE â€” Rule Packs (`docs/runtime/rule-packs/*.md`)

**Gap**: Ulak OS `docs/governance/plugin-skill-decision.md` defines command/agent/skill/hook/MCP/plugin â€” NOT rule-pack. But ajanscan's `.claude/rules/` pattern (always-on, <500-byte imperative guardrails per stack) fills a distinct role.

**Proposal**:
- Add `rule-pack` to the decision matrix in `docs/governance/plugin-skill-decision.md`
- New governance doc: `docs/governance/rule-pack-governance.md` (size cap, imperatives-only rule, pure-generic vs project-specific split, load order in Phase 0)
- Ship 4 starter packs in `docs/runtime/rule-packs/`:

| Pack file | Content scope |
|---|---|
| `rule-packs/typescript-nextjs.md` | strict mode, no `any`, no `console.log`, Server Components, `next/image` â€” near-universal |
| `rule-packs/python-fastapi.md` | Python 3.12+, Pydantic models, async-first, type hints, requirements hygiene |
| `rule-packs/docker-compose.md` | non-root user, healthcheck, mem_limit, dev/prod parity, no raw docker.sock |
| `rule-packs/api-security.md` | .env hygiene, rate limiting, audit log, CVSS v4.0 scoring choice |

**Load order**: rule packs activate in Phase 0 based on detected stack; recorded in `active-variables.yaml` as `rule_packs_loaded: [typescript-nextjs, docker-compose]`.

**Project-local overrides**: `.claude/rules/{stack}.md` in consuming repo overrides Ulak-shipped pack for same stack.

## Bucket 4: NEW GOVERNANCE DOCS (6 new + 4 extensions)

### New docs
| # | File | Why it's new (not a duplicate) | Source |
|---|---|---|---|
| G-01 | `docs/governance/rule-pack-governance.md` | No rule-pack unit type exists | Part 1 of prompt-skill-plugin-governor findings |
| G-02 | `docs/governance/ai-provider-allowlist.md` | `which AI provider may this project call` is a declared governance decision, not a code detail; residual SDK imports linger after provider swaps | ajanscan CLAUDE.md + SETUP.md + Gemini-only memory constraint + `lib/hareki.ts` drift evidence |
| G-03 | `docs/governance/pattern-import-ledger.md` | Cross-project pattern inheritance (TrendOfTrendâ†’ajanscan) leaves no provenance trail; lightweight YAML ledger keeps upstream bug-fixes propagable | memory + `app/integrations_store.py`, `app/routers/content.py` |
| G-04 | `docs/governance/settings-permissions-governance.md` | Ulak OS has NO guidance on well-formed `settings.json`; ajanscan ships `Delete(*)` + `Bash(*)` wildcards | `ajanscan/.claude/settings.json` (8 lines) |
| G-05 | `docs/governance/lock-file-hygiene.md` | `scheduled_tasks.lock` pid without TTL/liveness protocol can deadlock future sessions; no existing doctrine | `ajanscan/.claude/scheduled_tasks.lock` |
| G-06 | `docs/governance/product-surface-split.md` | Runtime surface-split.md is about Public/Hidden/Maintainer layers (internal Ulak concept). Customer/admin/public/partner API separation is a **product-level** concern â€” different governance. | Called out in CLAUDE.md runtime-defaults but NO file defines it; ajanscan's 4-surface reality (`app/routers/admin*.py`, `reseller.py`, `scan.py`) forces the question |

### Extended docs
| # | Existing file | Extension | Source |
|---|---|---|---|
| G-EXT-01 | `docs/governance/mcp-governance.md` | Add audit-trail requirement: every authorized MCP tool in `settings.local.json` must have a justification in `active-variables.yaml` under `mcp_authorized_tools` | `ajanscan/.claude/settings.local.json` (8 [eski-vps] MCPs authorized) |
| G-EXT-02 | `docs/governance/memory-hygiene.md` | Worktree cleanup policy: dirs >7d flagged, >30d auto-prune-eligible; pack-gap-audit reports stale worktrees | `ajanscan/.claude/worktrees/` (12 stale dirs) |
| G-EXT-03 | `docs/governance/plugin-skill-decision.md` | Add rule-pack as a 7th unit type | cross-reference G-01 |
| G-EXT-04 | `docs/governance/prompt-supply-chain.md` | Add pattern-import-ledger cross-link | cross-reference G-03 |

## Bucket 5: NEW RUNTIME RULES (5 new entries for `docs/runtime/`)

| # | File | Content | Source |
|---|---|---|---|
| R-01 | `docs/runtime/strangler-fig-protocol.md` | Staged monolith decomposition: A (pure functions) â†’ B (services) â†’ C (routers) â†’ D (engine). Atomic extraction + test after each step + commit per step. Triggered when single file exceeds 1-3k LOC. | `04_modernization/backend-modernization.md`, `final-executive-report.md:86-114` |
| R-02 | `docs/runtime/multi-agent-merge-sequence.md` | When 4+ specialists work in parallel: merge by dependency depth (infra depth 0 â†’ backend depth 1 â†’ frontend depth 2 â†’ validation depth N). Reduces conflicts ~70%. | `06_multi_agent/agent-topology.md:250-305`, `orchestrator-rules.md:109-130` |
| R-03 | `docs/runtime/audit-scoring-framework.md` | 14 universal dimensions for baseline + target: Architecture, Testing, Secrets, Observability, CI/CD, Duplication, Dependencies, Type Safety, Plugin System, API Design, Infrastructure, Frontend, Data Validation, Documentation. Each 0-100, grade A-F. | `methodology.md:107-161`, `final-executive-report.md:22-52` |
| R-04 | Extend `docs/runtime/toolchain-precheck.md` with **Pre-push parity** and **VPS baseline** sections | scripts/preflight.sh mirrors CI 1-for-1 (ruffâ†’pytestâ†’tscâ†’buildâ†’audit); githook install path; fast vs full mode. VPS baseline requires reproducible hardening script (SSH port change, key-only, root disabled, UFW, fail2ban, dual-session safety rule). | `CLAUDE.md:67-94`, `infrastructure/kale-kapisi.sh` |
| R-05 | Extend `docs/runtime/architecture-currency.md` with **Deploy resilience** section | Every deploy topology must declare a CI-independent fallback (cron-poll, manual SSH) with flock-guarded idempotent runner. CI-only deploy path = residual risk at Phase 4. | `infrastructure/deploy-poll.sh:1-69`, `CLAUDE.md` |

## Bucket 6: SKILLS (3 new)

| # | Skill | Input | Output | Source |
|---|---|---|---|---|
| SK-01 | `.claude/skills/god-module-decomposition/` | file path, target package, extraction plan (phases, deps, line ranges) | new package + shim of original + per-step commits + updated imports. Gates: no circular imports, all funcs typed, each module <400 LOC | Strangler Fig executor from `04_modernization/` |
| SK-02 | `.claude/skills/fourteen-dimension-audit/` | repo path, scoring rubric | per-dimension scorecard, target state, gap matrix, executive grade (before/after) | `methodology.md` |
| SK-03 | `.claude/skills/multi-agent-orchestration/` | backlog JSON, sprint length, num agents, merge rules | sprint assignment, dependency graph, file-ownership matrix, merge sequence, daily standup template | `orchestrator-rules.md` |

## Bucket 7: COMMANDS & AGENT ENHANCEMENTS

### New command
| # | Command | Purpose | Source |
|---|---|---|---|
| C-01 | `.claude/commands/triage-build.md` | Generic build-failure triage: section per detected stack (frontend/backend/container/mobile), each with standard diagnostic commands. Runs toolchain-precheck first, dispatches to right subsystem block. | Generalized from `ajanscan/.claude/commands/fix-build.md` |

### Agent enhancements (not new agents â€” extend existing prompts)
| # | Agent | Enhancement |
|---|---|---|
| AG-EXT-01 | `design-system-architect.md` | Add Master + per-page override output contract: emit `reports/current/design-system/MASTER.md` and per-page `pages/{page}.md` when running. Adopted from ajanscan's ui-ux-pro-max skill pattern. |
| AG-EXT-02 | `autonomous-program-director.md` | Add rule-pack load responsibility in Phase 0; record `rule_packs_loaded` in `active-variables.yaml`. |
| AG-EXT-03 | `security-hardening-lead.md` or new sub-agent | Add "secrets rotation & history purge" workflow (gitleaks baseline, git-filter-repo runbook, pre-commit hook installation) â€” current agent covers detection but not rotation/purge lifecycle. |

### Deferred / future
| # | Item | Why deferred |
|---|---|---|
| D-01 | `ulak-design-intelligence-mcp` (data-backed design retrieval) | ajanscan's ui-ux-pro-max skill ships 12 CSVs + Python CLI. Porting as skill violates Ulak's vendor-agnostic adapter contract. Future path: wrap as MCP server so it's vendor-neutral. |
| D-02 | `orchestrator-coordinator` agent | autonomous-program-director already covers coordinator role. Need decision whether to split file-ownership/conflict-arbitration into a dedicated agent or extend existing. Flag for director synthesis. |
| D-03 | `security-secrets-auditor` agent | Overlap with security-hardening-lead + privacy-compliance-counsel. Flag for director to decide: extend existing vs new focused agent. |

## Implementation waves (recommended)

### Wave 1 â€” Documentation-only, reversible (1-2 sessions)
Low risk, no runtime behavior change. All findings are additive.

- AP-01 through AP-09 (9 anti-pattern entries)
- G-EXT-03 (add rule-pack to decision matrix)
- G-EXT-04 (cross-link)
- G-01 (rule-pack-governance.md)

### Wave 2 â€” Rule packs + 3 governance docs
- Rule-packs directory + 4 starter packs
- G-04 (settings-permissions)
- G-05 (lock-file hygiene)
- G-06 (product-surface-split â€” high priority, it's been a CLAUDE.md defaults rule with no supporting doc)

### Wave 3 â€” Sector packs + remaining governance
- SP-01 through SP-06 + SP-EXT-01
- G-02 (AI-provider-allowlist)
- G-03 (pattern-import-ledger)
- G-EXT-01, G-EXT-02

### Wave 4 â€” Runtime rules
- R-01 through R-05

### Wave 5 â€” Skills, commands, agent extensions
- SK-01, SK-02, SK-03
- C-01
- AG-EXT-01, AG-EXT-02, AG-EXT-03

### Wave 6 â€” Deferred (next sprint)
- D-01, D-02, D-03 (require director synthesis decision)

## Open questions for director (Phase B)

1. **Orchestrator split**: Should file-ownership + conflict arbitration be a dedicated agent (`orchestrator-coordinator`) or extension of `autonomous-program-director`? (D-02)
2. **Secrets specialist split**: New `security-secrets-auditor` focused on rotation/history-purge, or extend `security-hardening-lead`? (D-03)
3. **Product-surface split vs runtime-surface split**: Two separate governance docs with clear names, or rename existing `surface-split.md` â†’ `runtime-surface-split.md` and add new `product-surface-split.md`? (clarity risk)
4. **`payment-integrated-saas` vs `fintech` pack**: Is this a new sector pack or a sub-pattern of existing `fintech`? Most SaaS projects need Stripe/Iyzico integration without being fintech products.
5. **`regulated-saas` variants**: Cybersecurity, fintech, healthcare share the framework-registry pattern. One pack with 3 variant sections, or 3 separate packs?
6. **Rule-pack precedence**: When project-local `.claude/rules/python.md` exists alongside Ulak-shipped `docs/runtime/rule-packs/python-fastapi.md`, does project override wholesale or merge?

## Evidence confidence caveats

- Patterns G-02 (AI-provider-allowlist) and G-03 (pattern-import-ledger) are **T3 (memory-sourced)** for the Gemini-only constraint and the TrendOfTrend import history. Recommend validation against TrendOfTrend itself (not scanned this session) before codifying.
- R-05 (cron-poll deploy resilience) is currently a **quota-exhaustion workaround** in ajanscan; promoting it to a universal resilience requirement is a judgment call â€” flagged for director review.
- Design-system Master-override pattern (AG-EXT-01) is **T3 (design judgement)**, not empirical superiority claim.
- ajanscan's `.gitignore` was not inspected; the "settings.local.json must be gitignored" recommendation (G-04) assumes risk exists, release-readiness-auditor should verify.
- A false positive was filed by one agent: "MCP Server Instructions block in bash stdout looks like prompt injection" â€” actually came from real MCP server instructions at session start, not an injection. Not a finding.

## Source files cited (ajanscan absolute paths)

All paths under `C:\Users\osrt91\desktop\proje\ajanscan.com\`:
- `CLAUDE.md`, `SUPABASE.md`, `SETUP.md`
- `docker-compose.yml`, `docker-compose.prod.yml`, `deploy.sh`
- `infrastructure/deploy-poll.sh`, `infrastructure/kale-kapisi.sh`
- `auth.py`, `db.py`, `payment.py`, `compliance_reporter.py`
- `cvss_processor.py`, `kev_checker.py`, `mitre_attack.py`, `nist_csf.py`, `iso27001.py`
- `app/routers/reseller.py`, `app/routers/admin.py`, `app/routers/admin_business.py`, `app/routers/admin_emails.py`, `app/routers/scan.py`, `app/routers/content.py`
- `app/models/roles.py`, `app/models/reseller_branding.py`
- `_project_audit/00_master_index/{executive-summary.md, methodology.md, README.md}`
- `_project_audit/03_findings/{anti-patterns.md, complexity-hotspots.md, critical-findings.md}`
- `_project_audit/04_modernization/backend-modernization.md`
- `_project_audit/06_multi_agent/{agent-topology.md, orchestrator-rules.md}`
- `_project_audit/07_outputs/{final-executive-report.md, final-gap-analysis.md}`
- `.claude/rules/{docker,python,security,typescript}.md`
- `.claude/skills/ui-ux-pro-max/SKILL.md`
- `.claude/commands/{deploy,fix-build}.md`
- `.claude/{settings.json, settings.local.json, scheduled_tasks.lock}`

## Hand-off to Phase B

This artefact is the primary input to `/director komple` Phase 2 (evidence) + Phase 4 (synthesis). The director should:
1. Treat this extraction as a high-trust specialist evidence bundle (T1-T3 tiers marked per pattern)
2. Resolve the 6 open questions above before finalizing `target-state.md`
3. Generate `execution-roadmap.md` using the 6-wave implementation plan as input, refined for the Ulak OS current state
4. Flag any patterns that contradict existing Ulak OS decisions for rule-collision-matrix review
