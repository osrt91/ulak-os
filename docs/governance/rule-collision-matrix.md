# Rule Collision Matrix

When two or more Ulak OS rules apply to the same decision and disagree, this matrix tells you which rule wins. Every collision resolution is recorded in `reports/current/analysis-findings.md` with a `contradiction_status: direct` tag so the trade-off is visible in the manager-verdict.

## Priority order (high → low)

| Priority | Category | What it protects |
|---|---|---|
| **1** | Security, legal, privacy | Credentials, PII, regulated data, license compliance, consent |
| **2** | Evidence quality | Trust tier, completeness, contradiction-free findings |
| **3** | Reversibility + rollback | Non-destructive default, backup-before-mutate, dual-window rollout |
| **4** | Validation completeness | No unmet probe, no `signoff_status: ready` without signed gate |
| **5** | Reusable pack quality | Rule/sector/runtime pack conformance, anti-pattern avoidance |
| **6** | UX clarity | User-facing flow intuitive, jargon minimal, error messages actionable |
| **7** | Aesthetics | Design-token consistency, visual rhythm, brand alignment |

If two goals conflict, **the lower-numbered priority wins**. Record the trade-off.

## Resolution protocol

1. Identify both rules by their canonical reference (file:section).
2. Label each with its priority number from the table above.
3. The lower-numbered wins; the higher-numbered action is either (a) refused, (b) deferred to a later release with a tracking issue, or (c) reshaped until both can pass.
4. Write the resolution in `analysis-findings.md` with `contradiction_status: direct` + `resolution: <lower-priority-reference-wins>` + `deferred: <new issue #>`.

## Worked examples

### Example 1 — Security vs UX (Priority 1 vs 6)

**Scenario**: The `customer-persona` agent flags that the signup form has too many fields; removing some would improve activation. The `privacy-compliance-counsel` agent flags that removing `locale` + `country` weakens GDPR data-residency compliance.

**Collision**: UX wants fewer fields (priority 6); privacy wants country+locale retained (priority 1, legal).

**Resolution**: Priority 1 wins. Keep country + locale. Move them to a progressive-disclosure step so UX impact is softened without violating GDPR. Record: `resolution: privacy-retention-enforced; ux-softened-via-progressive-disclosure`.

### Example 2 — Reversibility vs Pack quality (Priority 3 vs 5)

**Scenario**: `architecture-lead` proposes consolidating two sector-pack overlays (e.g., `payment-integrated-saas` + `reseller-enabled-saas`) into a single pack to eliminate duplication. The merge removes a public rule-pack import; existing consumers depend on the old name.

**Collision**: Pack quality (priority 5) wants consolidation; reversibility (priority 3) flags breaking import names for live consumers.

**Resolution**: Priority 3 wins. Keep both old pack names as aliases pointing at the consolidated content for one minor-version window, deprecate with clear migration path, only remove aliases after consumers have migrated. Record: `resolution: alias-window-one-minor; migration-guide-linked`.

### Example 3 — Evidence quality vs Validation completeness (Priority 2 vs 4)

**Scenario**: `red-team-challenger` finds a T3 (telemetry-based) signal that a race condition exists; `qa-validation-commander` says `validation-plan` needs a probe that would take 48h to run. The 24h release window is binding.

**Collision**: Evidence quality (priority 2) wants T1/T2 before claiming the race exists; validation completeness (priority 4) wants the probe result before shipping.

**Resolution**: Priority 2 wins over priority 4 in terms of "do we call it a finding?" — without T1/T2 we mark it `completeness_risk: high` and `evidence_trust: T3`, not confirmed. Priority 2 does not override the release decision; that is a priority-1 question (if the race exposes secrets, priority 1 blocks release). If not priority 1, log as residual risk with a follow-up probe in the next window. Record: `resolution: finding-captured-as-T3-residual; probe-scheduled-post-release`.

### Example 4 — Security vs Reversibility (Priority 1 vs 3)

**Scenario**: A leaked credential is recoverable from a public git tag (SEC-INCIDENT class). `security-hardening-lead` recommends `git filter-repo` history rewrite. `release-readiness-auditor` flags that the rewrite will force-push to origin and invalidate every cloned fork + every pinned tag reference downstream.

**Collision**: Priority 1 (remove leaked credential from public surface) vs priority 3 (preserve reversibility + avoid breaking downstream consumers).

**Resolution**: Priority 1 does NOT automatically win here because the secret is already exfiltrated-accessible — rewrite does not undo prior exposure. The better move is priority 1 via **rotation + revocation** (which does retire the credential) and accept the tag-content trace as cosmetic residual (Option A in SEC-INCIDENT-2026-04-21). Priority 3 retains origin history. Record: `resolution: rotate-revoke-accept-as-burned; history-rewrite-optional-not-mandated`.

### Example 5 — Pack quality vs UX (Priority 5 vs 6)

**Scenario**: `design-system-architect` wants to enforce a token-only color palette (no inline hex). `frontend-ios-flutter-director` points out that one brand moment (onboarding hero) uses a bespoke gradient not in the token set. Forcing token-only would flatten the hero visual.

**Collision**: Pack quality (priority 5, design tokens as SSOT) vs UX (priority 6, brand-differentiated hero).

**Resolution**: Priority 5 wins in principle, but the resolution is **grow the token set to cover the hero use case** rather than refuse the use case. Every "exception" goes into the token file as a named gradient, not hard-coded. UX wins the surface; pack quality wins the SSOT. Record: `resolution: hero-gradient-token-added-to-design-system; no-inline-hex-rule-retained`.

## When the matrix does not resolve

If the collision involves two priority-1 concerns (e.g., legal privacy vs legal security), escalate to operator decision. Do not default; do not guess. The autonomous-program-director agent has a `signoff_status: blocked` path specifically for this case. The block surfaces in the manager-verdict with `resolution: operator-escalation-required`.

## Integration

- `docs/governance/finding-schema.md` — every finding uses `contradiction_status` field; direct collisions trigger this matrix.
- `docs/runtime/validation-result-schema.md` — `signoff_status: blocked` carries a `blocker_reason` field that references the matrix.
- `.claude/agents/autonomous-program-director.md` — dispatches this matrix during Phase 4 synthesis.
- `docs/adr/ADR-000-governance-kernel.md` (if present) — the matrix itself is a governance primitive; changes go through ADR.

## Canonical footer

Authoritative as of Ulak OS **v1.0.1**. Expanded from v1.0.0 12-line stub per cartography finding CART-003.
