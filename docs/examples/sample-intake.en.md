# Sample Intake — Brownfield Audit Scenario

> [Türkçe](sample-intake.md) | English

> This is an example file showing what Ulak OS's `intake` artifact should look like. A real intake output is generated in this same structure.

## Project state

**BROWNFIELD** — audit and modernization program for an existing e-commerce monolith (Django + React). The codebase is 4 years old; active development has slowed over the last 18 months and test coverage has declined.

## Intervention mode

**REPAIR** primary, **EXTEND** secondary. First clean up dead code and broken tests (REPAIR), then add a new checkout flow (EXTEND).

## User intent

The user wants to "make the checkout flow mobile-first and ship it live within 2 weeks." The current checkout page has an 8-second TTI, 32% cart abandonment, and 58% mobile bounce.

Primary goal: reduce cart abandonment to 20% and mobile bounce to 40%.

## Success criteria

1. New mobile checkout TTI < 2.5 seconds (measured by LCP)
2. Cart abandonment ≤ 20% (A/B after 4 weeks live)
3. Mobile bounce ≤ 40% (after 4 weeks live)
4. No regression on existing desktop checkout (% conversion delta ≤ ±2%)
5. CI green; coverage must rise from 60% to ≥ 70% (for new code)

## Constraints

- **Duration**: 14 calendar days (launch 2026-04-21)
- **Team**: 1 frontend, 1 backend, 0.5 QA — you coordinate
- **No stack change**: Django + React stays, no framework swap
- **Customer/admin/public API separation**: customer checkout is in scope; admin order panel and public catalog API are NOT TOUCHED
- **DB schema changes**: additive only (new column/table OK, no drops)
- **Feature flag**: new checkout behind flag, 5% → 25% → 100% ramp

## Out-of-scope

- Backend microservice decomposition (future, separate program)
- New payment gateway integration
- Email/SMS notification revamp
- Admin panel redesign

## Notes

- The customer success team holds 47 user bug reports; at intake time only 4 are related to checkout — these will be handled in the evidence-register
- An older A/B test (Q4 2025) measured the effect of CTA button color in checkout; the result was insignificant and will not be retried

---

**Next step**: proceed to the `inventory` artifact. The current checkout file/route map will be produced.
