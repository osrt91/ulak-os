---
artefact: what-worked
session: oguzhansert-dev-sprint-0-1
date: 2026-04-11
---

# What Worked — Patterns Worth Preserving

Things Ulak OS 2.1 did well in this session. These should NOT change
in the next version, or should change only with deliberate care.

## 1. The mandatory 6-phase artefact chain

```
Phase 0 → runtime-manifest + assumptions
Phase 1 → inventory (cartographer-grade, file:line)
Phase 2 → evidence-register + deep-scan-report (merged)
Phase 3 → did-you-know (MANDATORY non-obvious layer)
Phase 4 → analysis + target + roadmap + validation + pack-gap
Phase 5 → manager-verdict
```

Every phase produced a file. Every file had YAML frontmatter with
`phase`, `signoff_status`. The director could verify completeness with
`ls reports/current/`. **This is the load-bearing discipline of the
whole protocol** — without it, you get "vibes-based" audits.

Keep this shape.

## 2. The "non-obvious findings" layer

Phase 3's `did-you-know.md` was the single highest-leverage output of
the session. 21 entries, each one a "you have this but it doesn't do
what you think it does" statement. Examples from this session:

- "Your `/admin/seo` panel writes to `seo_metadata` and nothing in the
  rendered site ever reads it. Every minute tuning SEO there was
  wasted."
- "`server-only` is installed as a dep but `import "server-only"`
  = 0 matches. The safety rail was bought and never installed."
- "Your blog page renders a `0 posts` counter badge — literally
  advertises absence."

The director's reward function must keep rewarding surprise. A
protocol that only surfaces obvious findings is a protocol nobody
needs.

**Keep:** the mandatory "cannot be trivial restatement" gate.
**Keep:** the minimum-15-entries floor.
**Keep:** the "include ≥3 positive findings" requirement (in this
session, `src/lib/auth.ts:67` Turkish alphabet whitelist was the
lone positive — but finding even one positive changes the tone of
the manager-verdict from "everything is on fire" to "this is a
repairable project with these issues".

## 3. Parallel specialist dispatch with explicit overlap

13 specialists in parallel on Phase 2 produced 3-overlap on admin
auth (security + backend-api + red-team all independently flagged
cookie-presence-only). That overlap was **diagnostic** — it moved
the finding from T2 "one specialist said so" to T1 "three specialists
independently said so" without any cross-talk.

Keep the overlap. Do NOT de-duplicate the specialists for efficiency.
The cost of running red-team + security + backend-api on the same
auth surface is small compared to the confidence gain.

## 4. The subagent brief shape

Every subagent prompt this session used the same structure:

```
1. Project context (root, branch, stack)
2. Why this agent exists (why Ulak OS dispatched you)
3. Mandate (exact item IDs from roadmap)
4. Files you OWN (whitelist)
5. Files you MUST NOT touch (explicit blacklist)
6. Detailed requirements per item
7. Execution steps (read, edit, validate)
8. Success criteria (grep-able assertions)
9. Reply format with word cap
```

The explicit whitelist + blacklist is what made parallel dispatch
safe. Every agent knew exactly what was outside their lane.

This shape should be codified as a **subagent-brief template** in the
Ulak OS pack. Operators + the director should both use it.

## 5. Live-probe as T-tier upgrade

`validation-plan.md` listed 11 live probes explicitly as "not
validated without VPS access". When the user authorized SSH access,
the probes ran and the session state upgraded from "T2/T3 assumptions"
to "T1 direct runtime observation" for:
- Actual schema (LP-01)
- RLS state (LP-02)
- PG password (LP-04)
- ADMIN_SECRET presence (LP-05)
- Traefik cert (LP-06)
- **JWT reuse (LP-07) — the biggest risk, fully MIT**
- tt_edge network (LP-08)
- Cloudflare fronting (LP-11)

Without the live-probe phase, Sprint 1 would have blindly rotated
credentials that did not need rotating, and **would have blindly
deleted `/opt/oguzhansert/` which turned out to be not-stale**.

**Keep this phase.** Formalize it. Make it mandatory before any
data-mutation or destructive action gets scheduled.

## 6. Roadmap item schema

Every roadmap item had:
- `id` (R-001 style)
- `phase` (quick-win / foundational / strategic)
- `title`
- `surfaces`
- `effort` (XS/S/M/L/XL)
- `deps`
- `validation_hook`

This schema is the reason the execution phase worked. Agents could
grep for their item IDs, orchestrator could track progress, and
every item had a defined "done" criterion.

Keep this schema. It may be worth lifting into a formal
`docs/runtime/roadmap-item-schema.md` contract.

## 7. The conflict-map pre-dispatch pass

Before Wave 1 dispatch, the orchestrator manually built a file
conflict map:

```
G1 edits src/lib/content.ts — sole owner
G1 edits src/app/api/admin/[table]/route.ts ALLOWED_TABLES — sole owner
G3 edits src/i18n/routing.ts — sole owner
G3 edits messages/en.json + tr.json — sole owner
...
```

This is not in the Ulak OS pack today. It should be. A
**parallel-dispatch planning step** before calling `Task` tool on
multiple agents, outputting a conflict matrix, would prevent the
"two agents edit the same file" class of bugs.

See `pack-gap-proposals.md` § PG-01 for the proposed skill.

## 8. Sequential-after-parallel pattern

Wave 2A ran G4A + G4C in parallel (disjoint files) + Wave 2B ran
G4B sequential (shared files with G4A). This is the correct shape
for "some work is parallel, some is dependent" — and it's different
from the single-wave `dispatching-parallel-agents` skill assumes.

Worth generalizing: a **"waves" pattern** where each wave can be
parallel but waves run sequentially. Different from pure parallel
or pure serial.

## 9. Reply-format discipline

Every agent prompt ended with:
```
Reply format (≤250 words):
1. ...
2. ...
```

The word cap forced agents to summarize. The numbered list forced
them to answer what the orchestrator asked, not drift into monologues.
This was a 10x context efficiency gain on orchestrator side.

Keep the cap. Consider codifying it as a subagent-brief contract.

## 10. Commit chain with structured messages

Every Sprint/Wave ended with a commit whose message listed the
roadmap item IDs implemented + verified output of pnpm tsc + pnpm
lint + pnpm build. Example from Sprint 1 Wave 1:

```
Sprint 1 Wave 1: dead admin removal, legal surface, infra hardening

R-119 Dead admin module removal (G1): ...
R-120 + R-024 next/image migration + hero compression (G2): ...
R-117 + R-118 Legal surface + cookie banner (G3): ...
...
Verified: pnpm tsc --noEmit = 0, pnpm lint = 0 errors / 20 warnings
(pre-existing tracked warns), pnpm build = green (24 routes...)
```

This made the commit log itself a form of audit evidence. Future
director runs against the same project can read the log to
understand the "why" of every change. Keep this pattern.

## 11. Memory system pre-loading

The orchestrator's auto-memory system carried 3 memories from earlier
sessions:
- VPS deploy topology (port 3005, `~/oguzhansert.dev`)
- PM2 ecosystem Next.js 16 rules
- Supabase JWT secret and key provenance

Every one of those memories was relevant this session and saved probe
cost. The memory was small, specific, cited file paths, and had
"why" + "how to apply" lines.

The Ulak OS runtime should treat this memory layer as a first-class
input to the director, not just a background convenience. Consider
a formal `memory-hygiene` gate: before dispatching the director,
load memories and flag any that conflict with current project state.

## 12. Hook / tool behaviour when blocked

When an agent's Write tool was blocked by some session-level hook
(multiple specialists hit this — see `friction-points.md`), the agent
gracefully degraded to returning the full content inline. The
orchestrator persisted the content from the conversation state.

This is resilient, but it burns context and risks truncation. The
pattern worked BECAUSE the agents correctly detected the block and
adapted. That's a preserved capability worth keeping — but the
hook should be fixed so the degradation path isn't needed.
