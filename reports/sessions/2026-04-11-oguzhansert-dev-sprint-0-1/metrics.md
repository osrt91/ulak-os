---
artefact: metrics
session: oguzhansert-dev-sprint-0-1
date: 2026-04-11
---

# Session Metrics

Raw numbers from the oguzhansert.dev Sprint 0 + 1 session.

## Time budget

| phase | wall-clock (min) | % of total |
|---|---:|---:|
| Phase 0 + 1 intake + inventory | 17 | 17% |
| Phase 2 specialists parallel | 16 | 16% |
| Phase 2-5 synthesis | 28 | 27% |
| Live probes | 11 | 11% |
| Sprint 0 serial | 8 | 8% |
| Sprint 1 Wave 1 (9 agents parallel) | 7 | 7% |
| Sprint 1 Wave 2A (2 agents parallel) | 7 | 7% |
| Sprint 1 Wave 2B (1 agent sequential) | 4 | 4% |
| Sprint 1 Wave 3 VPS ops | 2 | 2% |
| Deploy + smoke | 2 | 2% |
| **Total** | **~102** | **100%** |

Audit phase (Phase 0 → verdict): 72 min (71%)
Execution phase (Sprint 0 → deploy): 30 min (29%)

## Agent dispatches

| wave / phase | count | type |
|---|---:|---|
| Phase 0 + 1 | 1 | autonomous-program-director |
| Phase 2 (specialists) | 13 | specialist agents |
| Phase 2-5 synthesis | 1 | autonomous-program-director |
| Sprint 1 Wave 1 | 9 | general-purpose |
| Sprint 1 Wave 2A | 2 | general-purpose |
| Sprint 1 Wave 2B | 1 | general-purpose |
| **Total** | **27** | |

**Parallel dispatch count:** 12 agents in the largest single message
(Phase 2 — 13 specialists). Next highest: Wave 1 with 9.

## Artefacts produced

### Target project (`reports/current/`)

| file | lines | bytes |
|---|---:|---:|
| runtime-manifest.md | 159 | 9,067 |
| assumptions.md | 133 | 9,459 |
| inventory.md | 631 | 67,011 |
| evidence-register.md | 173 | 29,007 |
| deep-scan-report.md | 185 | 16,803 |
| did-you-know.md | 259 | 33,403 |
| analysis-findings.md | 214 | 16,475 |
| target-state.md | 201 | 16,124 |
| execution-roadmap.md | 227 | 26,747 |
| validation-plan.md | 251 | 15,751 |
| pack-gap-register.md | 66 | 10,310 |
| manager-verdict.md | 208 | 16,525 |
| live-probe-results.md | 215 | ~13,000 |
| specialists/ × 13 | 1,721 total | ~170 KB |
| **Total** | **~4,643** | **~450 KB** |

### This session feedback folder (`ulak.os/reports/sessions/.../`)

| file | purpose |
|---|---|
| README.md | session overview |
| timeline.md | phase-by-phase log |
| what-worked.md | patterns to preserve |
| friction-points.md | harness bugs to fix |
| pack-gap-proposals.md | new skills/agents/commands |
| ulak-os-improvements.md | runtime contract updates |
| metrics.md | this file |

## Commits produced

| sha | message | files | insertions | deletions |
|---|---|---:|---:|---:|
| b3d75b5 | Sprint 0 | 61 | 325 | 4572 |
| 9360a8d | Sprint 1 Wave 1 | ~60 | ~1800 | ~300 |
| c5bac3e | Sprint 1 Wave 2 | 15 | 527 | 40 |
| b14af9d | reports audit artefacts | ~25 | ~4600 | 0 |
| **Total** | **4 commits** | **~161** | **~7252** | **~4912** |

## Code impact

| metric | before | after | delta |
|---|---:|---:|---:|
| package.json deps | 35 | 26 | -9 (openai, tailwindcss-animate, @supabase/ssr, @content-collections/*, shiki, rehype-pretty-code, remark-gfm) |
| transitive npm pkgs | — | -199 | -199 (via pnpm install after dep removal) |
| pnpm install time | ~20s | **1.3s** | 15× faster |
| me.png size | 732 KB | 11 KB | -721 KB (98.5%) |
| admin modules | 11 | 7 | -4 (seo, galeri, ayarlar, yonlendirmeler deleted) |
| declared i18n routes | 8 | 4 | -4 orphans (+1 /gizlilik) |
| messages/en.json keys | 72 | 59 | -13 orphan keys |
| orphan SVG files | 19 | 11 | -8 dark/wordmark variants |
| public/ template images | 10 | 0 | -10 atomic/buildspace/ib/… |
| raw `<img>` elements | 7 | 0 | all migrated to `next/image` (edge OG routes excluded) |
| ESLint rule count | 1 (next/core-web-vitals) | 6 | +5 (no-explicit-any, no-unused-vars, no-console, prefer-const, no-useless-escape) |
| CI jobs | 1 (lint) | 2 (lint + typecheck) | +1 |
| CI steps | 4 | 8 | +4 (secret guard, i18n parity, typecheck, build env guard) |
| deployed routes | 24 | 26 | +2 (/api/health, /[locale]/gizlilik) |
| migration files | 3 | 7 | +4 (unique-indexes, revoke-grant, audit-log, admin-sessions) |
| prod DB tables | 11 | 12 | +1 (audit_log) |

## Security posture

| item | before | after |
|---|---|---|
| admin auth | cookie presence only | full value verify via validateAdminSession |
| ADMIN_SECRET validation | none (accepts empty) | fail-closed if unset or <32 chars |
| dashboard SSR leak | 11 service-role queries on any cookie | gated by validateAdminSession |
| CSRF | none | Origin allow-list on mutation routes |
| cookie sameSite | lax | strict |
| rate limiting on [table]/[id] routes | none | 60/min per IP |
| rate-limit IP parsing | raw x-forwarded-for | parseClientIp (cf-connecting-ip aware) |
| SVG upload (stored XSS vector) | allowed | blocked |
| upload error leak | raw `String(err)` | handleApiError |
| audit log | none | logAdminAction on 7 mutation paths |
| anon DB grants | ALL on ALL tables | SELECT only on 7 public tables |
| committed PG password in git | `32b89620...` (bootstrap seed) | parameterized via env |
| committed kong.yml JWTs | plaintext (but demo tokens) | not used in prod (verified via live probe) |
| `.env.local.bak*` permissions | 0644 (world-readable) | 0600 |
| /opt/oguzhansert/ secrets | 0644 | 0600 (still needs deletion, deferred) |
| pm2-logrotate | not installed | installed + configured (10M/14d/compress) |
| ID-linked seed dedup | 3x duplicates from 3 seed runs | 1 row per natural key |
| profile.social_links URL validation | none | https: + mailto: only |

## Live probe results

11 probes executed, all resolved:

| id | probe | result |
|---|---|---|
| LP-01 | prod schema columns | T1 — 00-create-tables.sql is authoritative |
| LP-02 | RLS state | T1 — all 11 tables rowsecurity=true, SELECT policies |
| LP-04 | PG password (committed vs rotated) | T1 — rotated, committed value rejected |
| LP-05 | ADMIN_SECRET presence | T1 — set, 41 chars |
| LP-06 | Traefik cert resolver | T1 — LE cert valid |
| LP-07 | JWT reuse from kong.yml | **T1 — MITIGATED** (zero sha256 overlap) |
| LP-08 | tt_edge network | T1 — doesn't exist on live VPS |
| LP-09 | uptime monitoring | deferred (external-only, not VPS-visible) |
| LP-10 | log rotation | T1 — not installed → fixed in Wave 3 |
| LP-11 | Cloudflare front | T1 — confirmed (cf-ray header) |
| — | bonus: docker container list | 7 tenant × 2 auth+rest containers |
| — | bonus: /opt/oguzhansert stale | **T1 — NOT STALE** (found recent .env.local) |
| — | bonus: .env.local.bak perms | **T1 — 0644 world-readable** (fixed) |
| — | bonus: PM2 21 restarts/15h | T1 — confirmed, fixed via 300M→512M |
| — | bonus: prod skills duplicates | T1 — 33 rows for 11 names, deduped |

## Non-obvious findings (Phase 3)

21 entries in `did-you-know.md`. Director-flagged top 3:

1. `/admin/seo` CRUD panel writes to `seo_metadata` — nothing reads
2. `server-only` installed but never imported — safety rail off
3. Blog page renders a "0 posts" counter — advertises absence

## File conflict count

**0 conflicts** across 12 parallel dispatches in Sprint 1 Wave 1 + Wave 2A.

Conflict matrix was built manually by the orchestrator before each
parallel dispatch. All 9 Wave 1 agents + both Wave 2A agents returned
clean with no file-ownership collisions.

## Deploy metrics

| metric | value |
|---|---:|
| prev commit | 301d9eac |
| new commit | b14af9d5 |
| pnpm install (post-cleanup) | 1.3s |
| pnpm build | ~45s |
| pm2 restart downtime | ~5s |
| health probe attempts to green | 2 of 15 |
| external smoke probes 200 | 6 of 6 |
| deploy total | ~90s |

## Context + compute efficiency

Approximate totals across the session (based on subagent duration
logs):

| subagent | tool calls | duration (s) |
|---|---:|---:|
| P0+1 director | ~170 | ~1000 |
| P2 × 13 specialists | ~600 | ~8000 (parallel) |
| P2-5 synthesis director | ~30 | ~1700 |
| Sprint 1 Wave 1 × 9 | ~180 | ~2500 (parallel) |
| Sprint 1 Wave 2 × 3 | ~90 | ~700 (partial parallel) |
| **Total subagent tool calls** | **~1070** | — |
| Orchestrator tool calls | ~130 | — |
| **Grand total** | **~1200** | **~14,000 (parallel reduced)** |

Estimated wall-clock if run entirely serial (no parallel dispatch):
~200-250 minutes. Actual: 102 minutes. **~2-2.5× speedup from
parallel dispatch pattern.**

## The single most impactful operator message

> "VPS erişimin klasöründe var zaten."

One 6-word message unlocked the live-probe phase, which:
- Converted the biggest risk (LP-07 JWT reuse) from T2 to T1-mitigated
- Prevented the blind delete of `/opt/oguzhansert/`
- Surfaced 5 new findings not in the static analysis
- Made the Wave 3 VPS ops possible

The Ulak OS director protocol should weight credential-access
authorization as the highest-leverage operator input.
