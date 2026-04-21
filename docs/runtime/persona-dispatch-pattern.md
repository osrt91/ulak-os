# Persona Dispatch Pattern

## Why this exists

The default director Phase 2 dispatches **specialists by discipline** — security-hardening-lead, backend-api-architect, design-system-architect, etc. Each specialist scans the whole project through the lens of their discipline. This works well when the project has a clear technical surface to audit (code + config + schema + deploy).

But some projects have a **user-layer complexity** that a pure discipline scan can miss. A multi-tenant SaaS with customer + admin + reseller surfaces isn't just "frontend + backend + admin". Each **persona** has different intent, different permissions, different failure modes, different deliverables. Auditing "frontend" doesn't tell you whether the Bayi (reseller) panel honors its sold promises.

Persona dispatch is the alternative: **audit the project as each persona would experience it**. 

## Persona dispatch vs specialist dispatch

| Axis | Specialist dispatch | Persona dispatch |
|---|---|---|
| **Unit of analysis** | Technical surface (auth, data, infra) | User role (buyer, admin, attacker) |
| **Output shape** | `specialists/security.md`, `specialists/backend-api.md` | `findings/customer-persona.md`, `findings/admin-persona.md` |
| **Finding framing** | "file X has a security bug" | "this user cannot complete their task because Y" |
| **Overlap value** | Two specialists independently agreeing → T1 consensus | Two personas hitting the same root cause → business impact confirmed |
| **Best for** | Technical debt, security, architecture cleanup | Multi-tenant products, SaaS with seller/buyer/admin, customer journey audits |
| **Worst for** | Simple single-user products (overkill) | Pure technical audits (misses the code-level rigor) |

**They are not mutually exclusive.** A single session can run BOTH in Phase 2: specialists in one batch + personas in another batch, merged into the evidence register. did this implicitly — the persona specialists ALSO read code, so they were effectively persona-framed specialists.

## When to use persona dispatch

Use persona dispatch when **ALL** of these are true:

1. The project has at least 2 distinct user roles with different permissions and intent (e.g., customer + admin + reseller)
2. A "can user X complete task Y" question is load-bearing for the audit outcome
3. Business findings (pricing, access, journey gaps) matter as much as technical findings
4. The project is live or near-live, so real user experience is the benchmark

Use specialist dispatch when:

- The project is pre-launch or early-stage (no real personas yet)
- The audit goal is technical (security, architecture, infra)
- The user base is single-persona (e.g., a CLI tool, a personal portfolio)
- The timeline is tight (specialist dispatch is faster — personas require code review through multiple lenses)

Use **both** when:

- The project is a mature multi-role product AND has technical debt
- The session has budget for a deep run (2+ hours, 8+ agents in parallel)
- The workstream plan will be organized by persona (see `docs/runtime/waves-pattern.md` and handoff-plan section 6)

## Standard personas

Not every project has every persona. The director picks from this catalog based on the project's user model:

### Customer / End user
The primary paying or using persona. Typical concerns:
- Onboarding friction
- Task completion
- Payment and billing clarity
- Trust signals
- Help and recovery paths
- Data privacy controls

### Admin / Operator
The internal user who runs the system. Typical concerns:
- Permission boundaries (vs customer surface)
- Dangerous action safety
- Audit trails
- Bulk operations
- Moderation and support tools
- Business intelligence surfaces

### Reseller / Bayi / Partner
A mid-tier persona between customer and platform. Typical concerns:
- White-label capability
- Sub-user management
- Commission / revenue share visibility
- API access and integration
- Quota and plan visibility
- Branded deliverables (reports, emails)

### Security / Red team
Not a user, but a persona lens. Adversarial framing. Typical concerns:
- Attack surface enumeration
- Auth bypass, privilege escalation, session theft
- Injection and SSRF
- Rate limiting and abuse prevention
- Secret handling
- Webhook signature bypass
- Multi-tenant isolation

### Support / CS
The operational persona handling tickets. Typical concerns:
- Ticket deflection quality
- Escalation paths
- Impersonation tooling
- Customer context visibility
- Bulk actions that affect customers

### Developer / API consumer
When the product has a public API. Typical concerns:
- API docs freshness
- Versioning and deprecation
- Rate limits and quotas
- SDK quality
- Webhook reliability
- Error shapes

### Compliance / Auditor
When the project has regulated surfaces (fintech, healthcare, minors). Typical concerns:
- Data retention and deletion
- Consent and disclosure
- Audit log retention
- Legal copy accuracy
- KVKK / GDPR / CCPA compliance
- Regulatory reporting

## Output contract per persona

Each persona dispatch writes `reports/current/findings/<persona>-persona.md` (not `specialists/`, because these are persona-framed, not discipline-framed). The file carries:

```yaml
---
artefact: persona-findings
persona: customer | admin | bayi | security-redteam | support | developer | compliance
session: <session-id>
date: <date>
---

# <Persona name> — Phase 2 findings

## Framing
How this persona experiences the product. 2-3 sentences.

## Findings by severity

### Blockers (<count>)
- [BLOCKER-id] Title
 - Evidence: file:line
 - Persona impact: what this persona cannot do / loses / risks
 - Fix summary
 - Sprint assignment

### High (<count>)...

### Medium (<count>)...

## Non-persona cross-cuts
Findings this persona surfaces that also affect other personas. Link to the overlap.

## Metrics
Findings count, blocker count, high count. Ratio of "tasks unaffected" to "tasks blocked" for this persona's primary jobs-to-be-done.
```

## Dispatch and merge

### Dispatch
In Phase 2, the director dispatches persona agents in parallel, same mechanism as specialist dispatch:

```
Task(subagent_type="customer-persona", prompt=...)
Task(subagent_type="bayi-persona", prompt=...)
Task(subagent_type="admin-persona", prompt=...)
Task(subagent_type="security-redteam", prompt=...)
```

Each persona agent has its own `.claude/agents/<name>.md` file with the persona framing. These persona agents **ARE shipped** in Ulak OS 2.1.x as of commit c21204b (7 persona files: admin-persona, bayi-persona, compliance-persona, customer-persona, developer-persona, support-persona, plus the existing security-redteam which doubles as a persona-style adversarial specialist).

### Merge
The director merges persona findings into the evidence register with a `source_persona` field:

```yaml
- id: FIND-001
 title: "Admin can silently self-escalate via user_metadata"
 source_personas: [security-redteam, admin]
 overlap_count: 2
 trust: T1 # two independent personas agreed
```

Overlap between personas is a **consensus signal**, same as specialist overlap (per UOI-04 in Ulak OS core contract principles).

## Hard rules

- **A persona dispatch is NOT just "re-run the specialist from a different angle"** — persona framing requires a different agent prompt, different questions, different output shape. Copying specialist prompts and renaming them is insufficient.
- **Persona findings must cite file:line** just like specialist findings. Persona framing doesn't exempt you from evidence rigor.
- **Persona overlap is treated the same as specialist overlap** for T-tier promotion: 2+ independent personas agreeing promotes T2/T3 → T1.
- **Do not dispatch personas the project doesn't have.** A single-user CLI tool has no "reseller" persona; forcing one produces noise.
- **Persona and specialist dispatch can coexist.** They overlap in code but framing differs. Both are valid Phase 2 inputs.
- **A persona with zero findings is a finding.** If the security-redteam persona returns empty, that's either a miraculously secure product or a failed dispatch. Investigate.

## Anti-patterns

- Generating persona reports by prompting one agent to "role-play as a customer" mid-conversation. True persona dispatch uses separate subagent contexts, not role-play within a single session.
- Treating persona dispatch as a substitute for discipline-based security review. Personas surface different risks; specialists surface others. You need both for high-coverage audits.
- Running all 7 personas when only 3 apply. Router should pick the applicable subset based on the project's user model.
- Persona findings without business impact statements. "This user cannot checkout" is persona framing; "payment service has a bug" is specialist framing. Persona files lead with the experience, not the technical symptom.

## Integration

- `docs/runtime/program-phases.md` — Phase 2 section notes persona dispatch as an alternative or complement to specialist dispatch
- `docs/runtime/artefact-contract.md` — `findings/<persona>-persona.md` is listed as an alternative Phase 2 output
- `docs/runtime/handoff-plan-contract.md` — workstreams in section 6 can be grouped by persona (W1 Customer, W2 Reseller, etc.)
- `docs/runtime/waves-pattern.md` — Wave assignment can respect persona boundaries when constructing the conflict map
- `docs/governance/finding-schema.md` — `source_personas` field for persona attribution
- Pack Gap: 7 persona agents (customer-persona, admin-persona, bayi-persona, security-redteam, support-persona, developer-persona, compliance-persona) are not yet in `.claude/agents/`. See `reports/sessions/2026-04-11--dev-sprint-0-1/pack-gap-proposals.md` for planned additions.

## Origin

This pattern was observed in the 2026-04-11 session, which explicitly dispatched 4 personas and produced persona-framed findings files in `reports/current/findings/`. The session produced:
- 22 customer findings (2 blocker, 7 high)
- 20 bayi findings (5 blocker — most of any persona, 7 high)
- 25 admin findings (2 blocker, 5 high)
- 25 security-redteam findings (4 blocker — KATASTROFİK, 7 high)

Total: 92 findings, 13 blockers, 26 high. The Bayi persona had the most blockers because the reseller surface was the least-tested and most-promised part of the product — a fact that would not have been visible in a pure specialist dispatch.
