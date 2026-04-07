# Sample Inventory — Brownfield Audit Scenario

> [Türkçe](sample-inventory.md) | English

> Ulak OS `inventory` artifact example. Continuation of the intake; map of the existing system.

## Inventory scope

This inventory scans the **current checkout flow**. The admin order panel and public catalog API are NOT in scope (out-of-scope from intake).

## Structural map

### Backend (Django)

| Module | Files | LOC | Last commit |
|---|---|---|---|
| `apps/checkout/views.py` | 1 file | 412 | 2024-11-08 |
| `apps/checkout/serializers.py` | 1 file | 178 | 2024-09-22 |
| `apps/checkout/models.py` | 1 file | 89 | 2023-06-14 |
| `apps/checkout/urls.py` | 1 file | 23 | 2024-09-22 |
| `apps/checkout/tests/` | 6 files | 540 | 2024-08-01 |

**Findings:**
- `views.py` is bloated at 412 LOC (8 endpoints in a single file)
- Test coverage is 48% (measured with `pytest --cov`)
- 3 endpoints use the deprecated `Form` API (not DRF)

### Frontend (React)

| Component | Files | LOC | Last commit |
|---|---|---|---|
| `src/checkout/CheckoutPage.tsx` | 1 file | 287 | 2024-12-03 |
| `src/checkout/CartSummary.tsx` | 1 file | 142 | 2024-11-15 |
| `src/checkout/PaymentForm.tsx` | 1 file | 198 | 2024-10-21 |
| `src/checkout/AddressForm.tsx` | 1 file | 165 | 2024-10-21 |
| `src/checkout/__tests__/` | 4 files | 312 | 2024-08-12 |

**Findings:**
- `CheckoutPage.tsx` is not mobile responsive (no CSS media queries)
- `PaymentForm.tsx` has a mixed controlled-uncontrolled state (React warning)
- Test coverage is 39%

### CI/CD

- GitHub Actions: `lint`, `test-backend`, `test-frontend`, `e2e-cypress`
- Branch protection: direct push to `main` is disabled, PR + 1 review required
- The E2E checkout suite has broken 11 times in the last 6 months, each time marked "flaky" and closed

### Database

- PostgreSQL 14
- Tables: `checkout_order`, `checkout_orderitem`, `checkout_payment`
- 4.7M order rows, 12M orderitem rows
- No index drops have been made on any column (additive history)

## Dependencies

| Package | Version | Last release | Risk |
|---|---|---|---|
| Django | 4.2.7 | 2023-11 | low |
| djangorestframework | 3.14.0 | 2023-08 | low |
| stripe | 5.4.0 | 2023-04 | **medium** (current 9.x) |
| react | 18.2.0 | 2022-06 | low |
| @stripe/stripe-js | 2.1.0 | 2023-09 | **medium** |

## Risk signals (enter into evidence-register)

1. **`checkout/views.py` overweight** → needs modularization, but outside this intake scope; only separate the endpoints we touch
2. **Missing mobile responsiveness** → this is the program's primary goal, the main work
3. **Stripe SDK outdated** → may need updating for the new checkout; verify with evidence
4. **E2E flaky history** → new checkout needs reliable E2E written; old flaky tests must be pruned

## Gaps (enter into research-notes)

- What is the industry-standard LCP target for mobile checkout? (research)
- What is the Stripe SDK 5 → 9 breaking change list? (research)
- What are competitor patterns for reducing cart abandonment? (research)

---

**Next step**: `evidence-register` — convert the risk signals and gaps above into proven findings/data points.
