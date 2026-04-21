# Transactional FSM Payment Flow

## Why this exists

Payment flows involve external providers (Stripe, Iyzico, Telegram Stars, crypto wallets) that may succeed, fail, or go silent. A naive implementation — "call provider → on success update DB" — has two bugs baked in:

1. **Partial failure**: provider succeeds, DB update fails. User paid; you don't know.
2. **No timeout**: provider never responds. User's money is in flight with no recovery path.

The correct shape is a **finite state machine with timeout + rollback** at every transition. The `` project (multi-payment SaaS) implements this cleanly across 4 payment rails. This doc codifies the pattern.

## When to apply

Apply for any payment, reservation, or multi-step external call where partial failure would cause user harm (double-charge, lost payment, reserved-but-unpaid inventory).

Do NOT apply when:
- The external call is idempotent AND the retry cost is zero (pure read)
- The flow is purely optimistic UI (provider is the authority; DB is a cache)

## The states

```
INITIATED → RESERVED → PROVIDER_CONTACTED → CONFIRMED → COMPLETED
 ↓ ↓ ↓
 RELEASED TIMED_OUT REFUNDED
 ↓
 FAILED
```

### State definitions

- **INITIATED** — user clicked buy; no DB writes yet
- **RESERVED** — inventory decrement + payment_intent row created; rolled back on failure
- **PROVIDER_CONTACTED** — request sent to payment provider; awaiting response
- **CONFIRMED** — provider returned success OR webhook confirmed success
- **COMPLETED** — order fulfilled; inventory committed; user notified
- **TIMED_OUT** — provider didn't respond within T seconds; schedule reconciliation
- **RELEASED** — inventory returned; payment_intent cancelled (if unreached)
- **REFUNDED** — payment already succeeded but downstream failed; refund triggered
- **FAILED** — terminal; logged; user shown error; no retry without explicit action

### Transition rules

- **INITIATED → RESERVED**: atomic (single DB transaction)
- **RESERVED → PROVIDER_CONTACTED**: single message to provider; record the external_id they return
- **PROVIDER_CONTACTED → CONFIRMED**: driven by provider webhook OR active poll (bound by max poll time)
- **PROVIDER_CONTACTED → TIMED_OUT**: after T seconds (e.g., 15 min for TON, 48h for wire transfer)
- **TIMED_OUT → CONFIRMED**: reconciliation job queries provider for final state; if paid, proceed
- **TIMED_OUT → RELEASED**: reconciliation confirms no payment; release the hold
- **CONFIRMED → COMPLETED**: post-confirmation downstream (fulfillment, notification)
- **any → REFUNDED**: operator-initiated OR automated on downstream failure

## Timeout discipline

- Each state has a MAX_DURATION before transition is forced
- No state has "unbounded waiting"
- A reconciliation job (cron or worker) walks stuck states every N minutes
- Stuck-state alerts: if a state is held > 2× MAX_DURATION, alert operator (not just user)

Example (adapted from TON payment):

```python
STATE_TIMEOUTS = {
 "INITIATED": 120, # seconds — user must submit within 2 min
 "RESERVED": 300, # seconds — 5 min to send transaction
 "PROVIDER_CONTACTED": 900, # seconds — 15 min waiting for network confirm
 "CONFIRMED": 60, # seconds — must hit COMPLETED within 1 min
}
```

## Idempotency + external_id

Every transition that has external side effects (charge, transfer, email) must be idempotent via an `external_id` (provider's transaction ID, our UUID for non-provider transitions).

- Save `external_id` on RESERVED
- Every subsequent transition references it
- Reconciliation job uses `external_id` to query provider
- Webhook handler uses `external_id` to find the right state row

Webhook delivered twice → same `external_id` → no double-processing.

## Audit trail

Every state transition writes an append-only row:

```sql
CREATE TABLE payment_state_transitions (
 id UUID DEFAULT gen_random_uuid,
 payment_intent_id UUID NOT NULL,
 from_state TEXT,
 to_state TEXT NOT NULL,
 transition_cause TEXT NOT NULL, -- 'user_action' | 'provider_webhook' | 'reconciliation_job' | 'operator_override'
 transition_time TIMESTAMPTZ DEFAULT now,
 metadata JSONB, -- provider response, amount, fees, etc
 trace_id UUID -- for distributed tracing
);
```

No UPDATE, no DELETE on this table (append-only). Diagnostics ("why is this payment stuck?") walk the transition log.

## Rollback discipline

- RESERVED → RELEASED must reverse the inventory decrement (in same transaction)
- PROVIDER_CONTACTED → RELEASED must cancel the provider-side intent (send cancel/void to provider)
- CONFIRMED → REFUNDED must trigger the provider's refund API (not just mark it refunded locally)
- REFUNDED is not a silent local change; it propagates to provider

## Multi-rail abstraction

When supporting ≥2 payment rails (Stripe + Iyzico + crypto), abstract the FSM behind a rail-specific driver:

```python
class PaymentRail(ABC):
 @abstractmethod
 def reserve(self, amount, currency, idempotency_key):...
 @abstractmethod
 def confirm(self, reservation_id):...
 @abstractmethod
 def cancel(self, reservation_id):...
 @abstractmethod
 def refund(self, reservation_id, amount):...
 @abstractmethod
 def handle_webhook(self, payload, signature):...

class StripeRail(PaymentRail):...
class IyzicoRail(PaymentRail):...
class TelegramStarsRail(PaymentRail):...
class TonConnectRail(PaymentRail):...
```

The FSM is rail-agnostic. Adding a new rail = implementing the driver interface.

## Evidence

 Analogous shape needed for Stripe-only and Iyzico-only projects that lack the discipline.

## Anti-patterns

- **Fire-and-forget payment call** — no FSM, no timeout, no reconciliation
- **Webhook trust without signature verification** — AP-08 (payment-integrated-saas)
- **Inventory decrement OUTSIDE payment transaction** — guaranteed double-sell on retry
- **`UPDATE payment SET state = 'completed'`** (no transition log) — no audit trail
- **Silent refund without provider API call** — user still charged

## Integration

- `docs/runtime/sector-packs.md §payment-integrated-saas` — this FSM is a required sub-pattern
- `docs/runtime/sector-packs.md §telegram-bot` — TON / Telegram Stars rails
- `docs/runtime/anti-patterns.md §AP-08` — payment sandbox/live discipline
- `docs/governance/secrets-rotation-policy.md` — payment API keys

## Canonical footer

Authoritative as of Ulak OS **v2.2.1**. 
