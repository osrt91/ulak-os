# Walkthrough 03 — Persona-dispatch `/director` on ExampleCorp Suite

The specialist-dispatch walkthrough in [01-audit-walkthrough.md](./01-audit-walkthrough.md) examined the repo through **discipline** lenses (security, data, architecture). This walkthrough examines the same fictional ExampleCorp Suite repo through **user-role** lenses: four personas each audit the product from their own role's perspective, then the director merges their findings and surfaces contradictions as explicit residual risks.

## Operator intent

```
> /director dispatch=persona persona_set=customer,admin,bayi,support
```

The operator triggers persona-dispatch with four personas. Specialist-dispatch is skipped for this run; the intent is "look at this product as each of the four user roles sees it."

## The four personas

Each persona is an agent file at `.claude/agents/<role>-persona.md`. The contract for persona-dispatch lives in `docs/runtime/persona-dispatch-pattern.md`. The director dispatches all four in parallel in Phase 2.

- **`customer-persona`** — a self-service SaaS user on the $49/mo plan. Cares about: landing page clarity, signup friction, dashboard responsiveness, billing accuracy, ability to export their data, privacy expectations.
- **`admin-persona`** — an internal ExampleCorp admin reviewing a tenant's activity. Cares about: audit log completeness, user impersonation safety, moderation tools, export controls, access revocation speed.
- **`bayi-persona`** (partner / reseller) — a partner agency with 30 sub-tenants under their account. Cares about: white-label branding, per-tenant billing visibility, bulk operations, commission accuracy, support escalation path.
- **`support-persona`** — a front-line support agent handling tickets. Cares about: ability to view (not impersonate) tenant state, refund issuance, feature-flag toggling, clear escalation to engineering.

## Per-persona findings

Merged into `reports/current/evidence-register.md` under one section per persona.

### `customer-persona` findings

- `F-CUS-01 [High T1]` — landing page `app/(public)/page.tsx:14-28` has English marketing copy despite `locale_primary: tr`; Turkish-first positioning undermined.
- `F-CUS-02 [High T1]` — signup flow `app/(auth)/register/page.tsx:43-67` asks for `companyName` mandatorily but many ExampleCorp customers are solo operators; requested field blocks 18% of signups per hypothetical analytics.
- `F-CUS-03 [Medium T1]` — dashboard `app/(customer)/dashboard/page.tsx:67-89` has the N+1 query already flagged in the specialist audit; customer perceives dashboard as slow.
- `F-CUS-04 [Medium T2]` — billing `app/(customer)/billing/page.tsx:34` shows net amounts but no KDV (Turkish VAT) breakdown; Turkish customers expect it itemized.
- `F-CUS-05 [Low T1]` — no "export my data" button on any customer surface; GDPR + KVKK data-portability expectation unmet.

### `admin-persona` findings

- `F-ADM-01 [Critical T1]` — `app/(admin)/admin/audit-log/page.tsx` reads from a table with **RLS disabled** (confirms the specialist-run F-DATA-01 from walkthrough 01); admin accidentally sees cross-tenant entries.
- `F-ADM-02 [High T1]` — no user-impersonation safety: `app/(admin)/admin/users/[id]/impersonate/route.ts:22` does not write to audit_log before granting the impersonation token. Admin actions on behalf of a user are untraceable.
- `F-ADM-03 [Medium T1]` — admin export tool `app/(admin)/admin/export/page.tsx` has no rate limit (confirms F-SEC-02); one admin's accidental repeat click can trigger 40 full-tenant dumps.
- `F-ADM-04 [Medium T2]` — access revocation: admins can disable a user via UI but the session token remains valid until natural expiry (up to 7 days); no forced-logout mechanism.

### `bayi-persona` findings

- `F-BAY-01 [High T1]` — partner dashboard `app/(partner)/partner/page.tsx:45-78` shows sub-tenant list correctly but does not surface per-tenant billing; partner has to click into each tenant. For 30 sub-tenants that's unusable.
- `F-BAY-02 [Medium T1]` — white-label: `app/(public)/page.tsx` does not support partner-branded landing; partner referrals land on ExampleCorp-branded page, reducing conversion.
- `F-BAY-03 [Medium T2]` — commission calculation uses a flat 20% per `lib/billing/commission.ts:12`; no per-partner override; one-size-fits-all pricing is rigid.

### `support-persona` findings

- `F-SUP-01 [High T1]` — support agents have no "view tenant state" surface; the only way to help a customer is to impersonate (which triggers F-ADM-02's untraced impersonation). Missing read-only support console.
- `F-SUP-02 [Medium T1]` — refund issuance flow is manual; no `app/api/admin/refund/route.ts`; support has to log into Iyzico dashboard separately.
- `F-SUP-03 [Low T1]` — feature-flag toggle per-tenant requires a DB migration; no runtime toggle UI.

## Merge and contradiction surfacing

The director merges the per-persona findings into `deep-scan-report.md`. Several findings **converge** (high-confidence consensus):

- **RLS on audit_log missing** → appears in admin-persona (F-ADM-01) AND data specialist (F-DATA-01 from walkthrough 01) if both dispatch modes ran. Convergence promotes trust tier from T1 to T0 (observed + verified across lenses).
- **Admin export has no rate limit** → appears in admin-persona (F-ADM-03) AND security specialist (F-SEC-02). Convergence confirms Critical severity.

Several findings **contradict** or tension:

- `F-CUS-02 (signup companyName mandatory)` improves conversion for solo operators
- `F-ADM-02 (no impersonation audit)` suggests admins need MORE tracking, not less
- `F-BAY-02 (white-label landing)` requires giving partners customization
- `F-SUP-03 (feature-flag toggle)` suggests per-tenant runtime config

Combining these: giving partners white-label branding + per-tenant feature flags + runtime toggles creates a partner tier that is almost a separate product surface. This is a **strategic decision** the product owner must make; the director records it as a residual risk:

```yaml
# residual_risks in validation-result.yaml
- id: RR-01
  type: strategic-decision
  description: >
    Partner tier is feature-requesting a white-labelled, per-tenant-configurable
    sub-product. Either commit to full partner-tier build-out (4-6 weeks effort)
    or mark partner features as deferred and set expectation with existing partners.
  decision_owner: product
  blocking: false  # not blocking Phase 5 ready, but blocking partner-tier quality
```

## Phase 3 — Did-you-know (persona-mode)

`did-you-know.md` in persona mode surfaces items no single persona saw alone but that appear when personas are merged:

1. **The same data is visible to all four personas but with different expectations.** Tenant audit log is readable by customer (their own rows, per RLS), admin (all rows per F-ADM-01 bug), bayi (sub-tenant rows — should be), support (read-only — doesn't exist). Four personas, four different expectations of the same table. The RLS policy must encode all four.
2. **The `app/api/webhooks/iyzico` handler has no persona ownership.** No persona sees it (it's machine-to-machine), but a failure affects customer billing, admin refunds, bayi commission. Nobody is watching.
3. **Turkish KDV handling cuts across customer (wants VAT line) + bayi (needs VAT-exclusive commission base) + support (refunds reverse VAT).** A single fix in `lib/billing/vat.ts` serves all three personas.

## Phase 5 — Verdict

```yaml
signoff_status: conditional
phase_status:
  phase_0: complete
  phase_1: complete
  phase_2: complete (dispatch=persona, 4 personas ran parallel)
  phase_3: complete
  phase_4: complete
  phase_5: complete
critical_findings_open: 1            # RR-01 promoted from F-ADM-01 + F-DATA-01 consensus
persona_contradictions:
  - customer vs admin on signup friction (mandatory fields)
  - partner tier feature scope (RR-01)
residual_risks:
  - RR-01 partner tier strategic scope
  - Turkish KDV cross-persona fix
next_execution_lane: waves
```

Manager verdict narrative: four personas converged on RLS + audit + rate-limit issues (high-confidence consensus); three contradictions surface strategic decisions the operator has to make explicitly rather than letting one persona win silently. The persona-dispatch mode produced a materially different roadmap than specialist-dispatch alone — both modes complement each other.

## When to use persona vs specialist vs both

- **`specialist`** (default) — discipline lenses catch technical defects (RLS, auth, rate limits)
- **`persona`** — role lenses catch UX gaps + strategic scope tensions
- **`both`** — overlap promotion: findings that appear in both specialist and persona evidence are promoted to consensus T0 tier; contradictions between the two are surfaced as explicit residual risks rather than silently resolved

For ExampleCorp Suite, the operator chose persona-only this run because the specialist run had already happened three months earlier; persona was the complementary lens.
