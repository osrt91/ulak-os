# Sample Validation Plan

**Purpose**: Worked example of a well-formed `validation-plan.md` with Â§1â€“Â§7 sections, including the MANDATORY `Â§6 â€” Live probes (read-only)` surface that Phase 4.5 of `docs/runtime/program-phases.md` consumes.

This sample is modeled on a mid-sized SaaS project with customer + admin + partner surfaces, a Supabase backend, and a [eski-vps] VPS deploy. Adapt the sections to the scope of your run.

**Canonical-as-of-version**: Ulak OS v2.1.3. When the validation-plan schema evolves, this sample is updated or deprecated. See `docs/runtime/validation-result-schema.md` for the machine-readable schema this plan fills.

---

## Â§1 â€” Engineering gates

Run during Phase 5 Â§5c. Each gate has a pass criterion and a blocking-or-warning classification.

| Gate | Command | Passes when | Classification |
|---|---|---|---|
| build | `npm run build` (or equivalent) | exit 0, no new warnings above baseline | blocking |
| lint | `npm run lint` / `ruff check` | 0 errors; warnings â‰¤ baseline + 5 | blocking |
| typecheck | `tsc --noEmit` / `mypy --strict` | 0 errors | blocking |
| unit tests | `npm test` / `pytest tests/unit` | all pass; coverage â‰¥ 70% | blocking |
| integration tests | `npm run test:integration` / `pytest tests/integration` | all pass; DB fixtures cleaned | blocking |
| e2e tests | `npx playwright test` | critical flows green; flake rate < 2% | warning |
| contract tests | `npm run test:contract` | schema diff vs. OpenAPI is zero | blocking on breaking changes |
| visual regression | `npm run test:visual` | diff â‰¤ threshold on all checked views | warning |
| accessibility | `npx axe-core` on key pages | 0 serious issues; moderate â‰¤ baseline | blocking on serious |
| security regression | `npm audit --audit-level=high` + custom rules | 0 high/critical unfixed | blocking |
| localization | `scripts/validate-i18n.sh` | every locale has every key; no orphaned keys | warning |
| release checks | `scripts/release-readiness.sh` | store metadata complete; links resolve | blocking |
| prompt regression | `evals/run.sh` (if Ulak OS pack) | golden set passes; regression rate 0% | warning initially, blocking once baseline stable |

---

## Â§2 â€” Surfaces checked

Flat enumerable list of every surface that must be exercised during validation.

- `/customer/**` â€” all routes rendered without error, auth required
- `/admin/**` â€” all routes rendered without error, admin role required
- `/reseller/**` (or `/partner/**`) â€” all routes, plan-capability required
- Public API endpoints â€” OpenAPI spec resolves, each endpoint returns expected shape
- Store listing URLs â€” App Store, Play Store (if mobile), web landing
- Deep links â€” share links, password-reset links, OAuth redirects
- Webhooks â€” provider signatures verified, idempotent retries handled

---

## Â§3 â€” Documentation coherence

Run during Phase 5 Â§5c as structural gates (not behavioral).

- `phase_numbering_consistent` â€” no file uses a phase number outside 0â€“5 or 4.5
- `office_roster_imported` â€” CLAUDE.md (or core contract) imports `office-roster.md` if specialist dispatch is used
- `rule_pack_unit_present` â€” if the stack has a published rule pack, `.claude/rules/<stack>.md` exists OR `active-variables.yaml` records why it wasn't loaded
- `persona_dispatch_accurate` â€” `docs/runtime/persona-dispatch-pattern.md` reflects which persona agents are actually shipped
- `cross_refs_resolve` â€” every `docs/` `@`-import and markdown link targets an existing file

---

## Â§4 â€” Specialist dispatch verification

Phase 2 artefacts (`evidence-register.md`, `deep-scan-report.md`) must prove depth.

- `eight_specialists_dispatched` â€” or the project-appropriate subset (â‰¥4 in a single parallel batch)
- `inventory_file_line_citations` â€” Phase 1 inventory has file:line citations on the majority of claims
- `did_you_know_non_trivial` â€” Phase 3 surfaces findings the user did not ask about
- `open_questions_resolved` â€” every `TODO-DIRECTOR:` marker has a decision recorded in target-state.md

---

## Â§5 â€” Audit-gate status

Meta-gates that verify the audit protocol itself was followed.

- `all_phase_4_artefacts_present` â€” analysis-findings + target-state + execution-roadmap + validation-plan + pack-gap-register
- `all_phase_5_artefacts_present` â€” validation-result.yaml (or embedded block) + manager-verdict.md
- `evidence_trust_tiers_assigned` â€” every finding in evidence-register.md has T1â€“T7
- `rule_collision_recorded` â€” any rule that contradicts default behavior is logged in rule-collision-matrix.md

---

## Â§6 â€” Live probes (read-only)

This section is consumed by **Phase 4.5** (`docs/runtime/live-probe-contract.md`). Every probe here is read-only by default. Destructive probes are not allowed; destructive actions are scheduled in Â§5b execution with a separate approval path.

**Probe format**:

```yaml
- id: LP-01
 question: "Does production JWT_SECRET match the kong.yml:8 committed secret?"
 target: vps.example.com
 command: "ssh -p 2244 deploy@vps.example.com 'env | grep ^JWT_SECRET'"
 expected_result: "JWT_SECRET is different from kong.yml:8 value (refutes the secret-leak hypothesis)"
 failure_action: "If match: critical finding, rotate secret immediately, file NF-* in did-you-know.md"
 timeout_seconds: 30
 credential_requirement: "SSH key for deploy@vps, OR operator runs this and reports back"
 evidence_tier_on_pass: T1 # upgrade from T2
 evidence_tier_on_fail: T1 # T1 with a critical finding attached
```

**Example probe bank** (for a Supabase + VPS project):

```yaml
- id: LP-01
 question: "Is /api/admin/users reachable without an admin JWT?"
 target: https://api.example.com
 command: "curl -i -s https://api.example.com/api/admin/users"
 expected_result: "HTTP 401 or 403 (admin gate enforced)"
 failure_action: "If 200: critical auth bypass finding; open NF-* and add to execution roadmap as P0"
 timeout_seconds: 10
 credential_requirement: none

- id: LP-02
 question: "Do production containers mount docker.sock directly?"
 target: vps.example.com
 command: "ssh -p 2244 deploy@vps.example.com 'docker inspect <app_container> | jq \".[].Mounts\"'"
 expected_result: "No mount of /var/run/docker.sock; instead docker-socket-proxy sidecar on internal network"
 failure_action: "If raw mount: file AP-05 violation finding, roadmap task to migrate to docker-socket-proxy"
 timeout_seconds: 30
 credential_requirement: "SSH key for deploy@vps"

- id: LP-03
 question: "Does the reseller API honor plan-capability gating (customer plan user cannot reach /reseller/**)?"
 target: https://api.example.com
 command: |
 curl -i -s -H "Authorization: Bearer $CUSTOMER_JWT" \
 https://api.example.com/reseller/dashboard
 expected_result: "HTTP 403 with plan-capability-denied body"
 failure_action: "If 200 or 404 (different leak): critical authz finding"
 timeout_seconds: 10
 credential_requirement: "Valid customer-tier JWT (not admin or reseller)"

- id: LP-04
 question: "Is the Iyzico webhook verifying the HMAC signature?"
 target: https://api.example.com
 command: |
 curl -i -s -X POST -d '{"test":"unsigned"}' \
 https://api.example.com/webhooks/iyzico
 expected_result: "HTTP 401 or 400 (unsigned rejected)"
 failure_action: "If 200: file AP-08 finding; webhook signature verification missing"
 timeout_seconds: 10
 credential_requirement: none

- id: LP-05
 question: "Are user_metadata values used for authorization anywhere in production?"
 target: "DB read"
 command: |
 psql $DATABASE_URL -c "SELECT count(*) FROM app_logs
 WHERE message LIKE '%user_metadata%' AND level IN ('auth','role');"
 expected_result: "0 rows (authz reads come from user_role_assignments, not user_metadata)"
 failure_action: "If > 0: file AP-06 finding; audit the call sites"
 timeout_seconds: 15
 credential_requirement: "Read-only Postgres role for app_logs"
```

**Pre-check mapping** â€” every destructive item in execution-roadmap.md must have a matching `pre_check: [LP-xx]` entry pointing to a probe above.

---

## Â§7 â€” Rollback readiness

Every execution wave must declare its rollback path. The validation plan aggregates them.

```yaml
rollback:
 wave_1:
 approach: "git revert + redeploy from tagged baseline v2.1.2"
 blast_radius: "docs only; no runtime behavior change"
 verification: "run Â§1 lint + typecheck + build after revert"
 wave_2:
 approach: "delete newly-created governance files; revert core-contract imports"
 blast_radius: "safe; nothing depends on them yet"
 wave_3:
 approach: "append-only content; revert per commit"
 wave_4:
 approach: |
 Pack-surface changes: revert per agent/command/skill file.
 Version bump: DO NOT untag v2.1.3 once tagged; instead publish v2.1.4 with fixes.
 blast_radius: "ecosystem â€” dependent projects may pin to v2.1.3"
```

---

## Integration

- `docs/runtime/validation-result-schema.md` â€” machine-readable output this plan drives
- `docs/runtime/live-probe-contract.md` â€” Â§6 probe execution protocol
- `docs/runtime/program-phases.md` â€” Phase 4.5 (live probes) + Phase 5 Â§5c (validation gates)
- `docs/runtime/anti-patterns.md` â€” AP-* codes referenced in probe failure actions
- `docs/governance/finding-schema.md` â€” NF-* finding shape when a probe discovers new issues

## Canonical footer

This file is authoritative as of **Ulak OS v2.1.3** (2026-04-18). If the validation-plan schema or the live-probe contract changes, this sample must be regenerated. Pinned reference for consumers wanting to lock to this sample: commit SHA at time of read (check git log).
