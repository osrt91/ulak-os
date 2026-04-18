# Rule Pack — TypeScript + Next.js

Activated when runtime-manifest detects `typescript` + (`next` | `next.js`) in package.json.

## Imperatives

- `tsconfig.json` must have `"strict": true`; no `"noImplicitAny": false` escape
- No `any` — use `unknown` + narrowing; `as` casts require a short comment
- No `console.log` shipped to prod — use the logger; lint rule enforces
- Default to Server Components; add `"use client"` only with a concrete reason
- Images via `next/image`; raw `<img>` needs a lint-disable + rationale
- No `require()`; ESM imports only
- Don't commit `.next/`, `next-env.d.ts`, or `tsconfig.tsbuildinfo`
- Data fetching in Server Components or `route.ts`; never fetch from Client Components for first paint

## Collision rule

If a project rule at `.claude/rules/typescript.md` redefines one of these, project wins for that imperative; unmatched imperatives inherit from this pack (per `docs/governance/rule-pack-governance.md`).
