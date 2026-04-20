# AI Provider Allowlist

## Why this exists

"Which AI provider may this project call" is a **governance decision**, not a code detail. It needs a declared allowlist so architecture review can check against it, because residual SDK imports and env-var references **linger long after a provider swap**. If the user decided two releases ago "no more Groq, we use Gemini", but `lib/groq_client.ts` still exists and someone wires it in for a feature, the governance intent is silently violated.

Evidence from the user's portfolio: a security scanner project's CLAUDE.md listed Groq + Hareki + OpenAI SDK historically; SETUP.md locked the current state to Google Gemini (`gemini-2.5-flash`); the user's Ulak OS memory confirms Gemini-only is the intended steady state. But `lib/hareki.ts` is still present in the security scanner project's frontend — **drift between intent and code**. This doc closes that gap.

## The allowlist contract

Every Ulak-OS-managed project declares an `ai_providers_allowed: [...]` array in its `runtime-manifest.md` (or `active-variables.yaml`). Architecture-lead flags any SDK import, env var, or client library referencing a non-allowlisted provider as a **drift finding** (`did-you-know` category).

Minimum viable declaration:

```yaml
ai_providers_allowed:
  - google-gemini       # gemini-2.5-flash, gemini-2.0-pro
ai_providers_forbidden:
  - openai              # no OpenAI SDK, no `openai` env vars
  - anthropic           # no Anthropic SDK  (even if Claude Code is the dev tool)
  - groq                # forbidden per operator decision 2026-02-15
  - hareki              # forbidden per operator decision 2026-02-15
  - cohere              # unused
```

A project that does not use AI at all declares:

```yaml
ai_providers_allowed: []  # project does not call AI at runtime
```

An empty allowed list with no forbidden list means "we haven't decided yet" — that's itself a finding (the decision needs to be made before shipping).

## Drift detection rules

Architecture-lead (or a dedicated subagent) scans for:

1. **SDK imports** — `import groq`, `from openai import ...`, `require('@anthropic-ai/sdk')` against the forbidden list
2. **Env var references** — `process.env.GROQ_API_KEY`, `os.getenv("OPENAI_API_KEY")` against the forbidden list
3. **Client lib files** — `lib/groq*`, `services/openai*`, `client/anthropic*` against the forbidden list
4. **Network calls** — `fetch('https://api.groq.com/...')`, `requests.get('api.openai.com/...')` against the forbidden list
5. **Documentation** — README, setup docs referencing forbidden providers without a "[deprecated]" marker

Each hit is a finding with severity inherited from the drift kind:

| Drift kind | Default severity |
|---|---|
| Active SDK import / env var used in runtime code | High (drift will affect users) |
| Env var declared but not used | Medium (residual configuration) |
| Client lib file exists but not imported | Medium (dead code) |
| Doc reference without deprecation marker | Low (doc drift) |

## Transition patterns

When switching providers (e.g. Groq → Gemini):

1. **Update runtime-manifest.md first** — add new provider to `allowed`, add old provider to `forbidden`
2. **Run drift detection** — file findings for every residual
3. **Plan migration in waves** — the findings become a roadmap
4. **Purge in the terminal wave** — delete dead client files, remove env var declarations
5. **Validation gate** — re-run drift detection, should return zero findings

## Multi-provider cases

Some projects legitimately need multiple providers (e.g. embeddings from one vendor, chat from another). Declare each role:

```yaml
ai_providers_allowed:
  - google-gemini          # chat, generation
  - openai:embeddings-only # explicit role scope
ai_providers_forbidden:
  - openai:chat            # chat via OpenAI forbidden even though embeddings allowed
```

The scope annotation is required when the same provider is partially allowed.

## Model-level pinning

Within an allowed provider, the specific model is declared separately:

```yaml
ai_models_pinned:
  google-gemini: "gemini-2.5-flash"  # pin for prod
  google-gemini-fallback: "gemini-2.0-pro"  # escape valve for specific endpoints
```

The pinning is tighter than the allowlist. Updating the pinned model is a versioned change (not a governance decision but a release decision).

## Worked example — a security scanner project

Target state (as of v2.1.3 audit):

```yaml
ai_providers_allowed:
  - google-gemini
ai_providers_forbidden:
  - groq
  - hareki
  - openai
ai_models_pinned:
  google-gemini: "gemini-2.5-flash"
```

Drift findings expected at baseline:
- `lib/hareki.ts` — residual client file (Low)
- `app/services/groq_client.py` — if present (High)
- README references — audit separately

## Integration

- `docs/runtime/active-variable-contract.md` — declares the `ai_providers_*` fields
- `docs/runtime/architecture-currency.md` — architecture-lead's scan includes this check
- `docs/governance/prompt-supply-chain.md` — provider changes are supply-chain events (record in the ledger)
- `docs/runtime/anti-patterns.md` — "Dead code" and "unused dependency" anti-patterns apply to residual provider code

## Canonical footer

Authoritative as of Ulak OS **v2.1.3**. Evidence base: user's portfolio-wide Gemini-only constraint (T3 memory) + a security scanner project's `lib/hareki.ts` drift evidence (T1). This doc was pattern G-02 in the the security scanner project extraction.
