# Customer Persona Audit — pre-v1.0.0-public-GA

**Agent**: customer-persona
**Date**: 2026-04-21
**Persona**: 10-year Next.js + Supabase developer from Berlin evaluating Ulak OS for a 5-person team

## Verdict summary

**`would_adopt: maybe`** — at 5 minutes I close the tab; at 15 minutes (if I stumble into FAQ + showcase) I'm convinced. Adoption gated on UX-CR-01, UX-CR-02, UX-HI-01, UX-HI-04 — weekend of doc work, not rewrite. Would check back in two weeks.

- **Primary JTBDs blocked**: 4/5 on 5-min budget; 1/5 on 60-min budget.
- **Finding totals**: 12 (2 Critical, 4 High, 4 Medium, 2 Low)
- **5-min adoption blockers**: 2
- **Windows subset blockers**: +1

## Findings (prioritized)

### UX-CR-01 (Critical) — FAQ.md is invisible from README

**Evidence**: `README.md:1-151`, `README.en.md:1-151`, `docs/FAQ.md:1-142` (rich content, never linked)

**Impact**: Stuck user has no path to FAQ. FAQ answers the exact questions a foreign evaluator asks: differentiation vs superpowers, offline use, model support, data-storage. None reaches the reader. Direct conversion leak at minutes 3-5.

**Fix**: Add "Help & further reading" section to both READMEs linking FAQ, runbooks/, showcase/, troubleshooting. Place above License.

### UX-CR-02 (Critical) — Showcase link says "coming soon" while content already exists

**Evidence**: `README.md:70` (yakında), `README.en.md:70` (coming in v2.4.1), `docs/showcase/01..04-*.md` all exist today

**Impact**: Under-sells strongest marketing asset. 5-min evaluator concludes tool is immature when showcase is actually best trust-builder.

**Fix**: Replace "(coming in v2.4.1)" with direct links to `./docs/showcase/` naming four walkthroughs.

### UX-HI-01 (High) — Quickstart bash commands hostile to Windows-only devs

**Evidence**: `README.md:32-36`, `README.en.md:32-36`, `scripts/install.ps1` exists but unmentioned, no `.ps1` sibling for validators

**Impact**: Windows-only dev hits `bash scripts/...` with no PowerShell alternative. Bails or 20-min WSL detour.

**Fix**: Add parallel PowerShell column OR direct users to `ulak doctor` (cross-platform validator wrapper).

### UX-HI-02 (High) — Insider terminology in value table has zero hyperlinks

**Evidence**: `README.en.md:13-19`

**Impact**: Within 2-min evaluation window, reader cannot parse "Phase 0→5 director protocol", "specialist agents", "15-dimension scorecard", "79 anti-pattern sweep". Skeptical dev: "too many buzzwords".

**Fix**: Hyperlink each term to source doc — director→`docs/runtime/program-phases.md`, anti-patterns→`docs/runtime/anti-patterns.md`, specialists→`.claude/agents/`.

### UX-HI-03 (High) — Scaffold walkthrough promises files not in committed templates

**Evidence**: `docs/showcase/02-scaffold-walkthrough.md:55-156` (41-file tree); `templates/saas-starter/` has 27 .template files

**Missing on disk**: `app/(admin)/`, `app/(customer)/`, `app/(partner)/`, `app/api/`, `components/`, `docs/architecture/`, `docs/i18n/`, `infrastructure/nginx/`, `supabase/migrations/00003_seed_admin.sql`

**Impact**: Walkthrough advertises a tree the template folder cannot produce. Skill must synthesize on the fly; if synthesis is incomplete, operator gets fewer files than advertised. Trust breach.

**Fix**: Either commit missing template stubs so 41-file claim is literal, or mark each file as "template" vs "synthesized".

### UX-HI-04 (High) — Version story inconsistent across surfaces

**Evidence**: `README.md:5` v2.4.0, `FAQ.md:111` "v3.0 is the first fully-public release", `CHANGELOG` v2.4.0, git log has v3.0 refs, `docs/showcase/02:179` v2.4.1

**Impact**: Evaluator cannot tell maturity. "Is this v2, v2.4, or v3?"

**Fix**: Pick one story — declaring v1.0.0 (public GA) will resolve; update README badge, canonical footer, FAQ.

### UX-MED-01 (Medium) — Curl-to-sh presented without safety explanation

**Evidence**: `docs/runbooks/first-hour-with-ulak-os.md:13-21`; `scripts/install.sh:1-20` IS safe

**Fix**: Prepend 4-bullet safety summary: installs under `$HOME`, no sudo, never writes outside `$HOME`, idempotent.

### UX-MED-02 (Medium) — "komple" never translated for foreign users

**Evidence**: `README.md:48`, `README.en.md:48`, `first-hour.md:109`

**Fix**: Rename to `/director full` OR annotate "komple (Turkish = full)" on first use.

### UX-MED-03 (Medium) — No author identity in README

**Evidence**: `README.md`, `README.en.md` no author line; `CODE_OF_CONDUCT.md:33` email only

**Fix**: Add README footer: "Maintained by Oğuzhan Sert · GitHub osrt91 · Contact info@oguzhansert.dev".

### UX-MED-04 (Medium) — Manager-verdict narrative in showcase is verbatim Turkish

**Evidence**: `docs/showcase/01-audit-walkthrough.md:166`

**Fix**: Provide inline English translation OR re-run walkthrough with `output_language=en`.

### UX-LO-01 (Low) — Runbook default example uses locale_primary=tr

**Evidence**: `docs/runbooks/first-hour-with-ulak-os.md:138`

**Fix**: Use `locale_primary=en` in default example; note "tr also supported".

### UX-LO-02 (Low) — No SECURITY.md at repo root

**Evidence**: Root dir no SECURITY.md; FAQ redirects to CoC

**Impact**: GitHub's Security tab and issue flows expect SECURITY.md; absence breaks standard responsible-disclosure convention.

**Fix**: Add 4-line SECURITY.md at repo root pointing to email in CoC.

### UX-LO-03 (Low) — Runbook phases never state wall-clock time

**Evidence**: `first-hour.md:112-121`

**Fix**: Add expected duration to each step header ("expect 8-15 min").

## Delights (preserved)

1. Troubleshooting runbook unusually specific (16 error-symptom→fix mappings)
2. FAQ honestly lists 7 things Ulak OS is NOT
3. Bug report template is governance-aware (secret-leakers redirected to email)
4. Installer defensively written (reading it increases trust)
5. Showcase walkthroughs have file:line citations throughout

## Signoff

`would_adopt: maybe` — 2 Critical findings gate 5-minute adoption. Fixing UX-CR-01, UX-CR-02, UX-HI-01, UX-HI-04 unblocks the majority. Weekend of doc work.

**Note on agent output**: customer-persona agent returned findings inline rather than writing to reports/tests/ (per its own operating rules). This file is the orchestrator's transcription of the inline findings.
