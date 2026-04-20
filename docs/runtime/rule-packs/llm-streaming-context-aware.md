# Rule Pack — LLM Streaming (Context-Aware)

Activated when runtime-manifest detects LLM SDK + streaming API usage (SSE, ReadableStream, or chunked response from AI provider).

## Imperatives

- Context injection at request time: pass user's current page / route / session state into system prompt (not hardcoded "you are an assistant")
- Token cap enforced server-side: `maxOutputTokens` always set explicitly (never omit → unbounded cost)
- Input length cap before forwarding: reject user messages >N tokens at API layer with 413-style error
- Stream to client via SSE or ReadableStream; never buffer full response server-side then send
- Stream errors mid-response: emit `event: error` frame, never swallow → client hangs
- Cost observability: log token count + model + user_id per request to a metrics channel
- Rate limit per user AND per session — LLM costs spike on automation
- Injection resistance: user input is always quoted / escaped in system prompt; never `${user_input}` template
- Prompt logs go to a privacy-scoped table with TTL; NEVER to public logs (contains PII)
- Cache identical (prompt, context) pairs for N minutes when safe (deterministic queries only)

## Collision rule

Project `.claude/rules/ai-relay.md` overrides specific imperatives. LLM-heavy products should also activate `ai-relay-cost-control` sector pack.
