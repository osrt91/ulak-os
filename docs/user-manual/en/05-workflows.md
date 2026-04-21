# 05 — Workflows

This chapter walks through **five canonical workflows** for Ulak OS v1.6. Each section gives the usage scenario, the command sequence, the expected output, and an honest note on when the workflow is insufficient.

Text-based walkthroughs with more detail (terminal output, sample artefacts, annotated phases) live in [`../../showcase/`](../../showcase/README.md). Beginner-oriented external-service tutorials live in [`../../tutorials/`](../../tutorials/README.md).

## Workflow index

| # | Workflow | Entry | Time |
|---|---|---|---|
| 1 | [First-time SaaS](#workflow-1--first-time-saas-beginner-path) | `hi ulak` → `/ulak-start` → `/ulak-scaffold` → `/ulak-next-steps` | 30–60 min |
| 2 | [Existing-project audit](#workflow-2--existing-project-audit) | `/director komple` | 15–40 min |
| 3 | [Learn a specific service or term](#workflow-3--learn-a-specific-service-or-term) | `/ulak-explain` or `docs/tutorials/*.md` | 5–20 min |
| 4 | [Pack expansion](#workflow-4--pack-expansion) | `/pack-gap-audit` + `/ulak-pattern-extract` | variable |
| 5 | [Cross-project pattern lift](#workflow-5--cross-project-pattern-lift) | `/ulak-pattern-extract` + ledger | variable |

---

## Workflow 1 — First-time SaaS (beginner path)

### Usage scenario

You have never used Ulak OS. You want to ship a working SaaS skeleton today, without reading the whole manual first. You may not know what RLS, JWT, or idempotency mean — that is fine.

### Command sequence

```bash
# 1. Install Ulak OS (one-liner)
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh

# 2. Open your AI coding CLI in an empty directory
cd ~/projects
claude      # or: codex, copilot, gemini

# 3. Natural-language onboarding
```

Inside the CLI:

```
hi ulak
```

This triggers `/ulak-hello`: 3-sentence intro, 3 example commands, "what do you want to do?" question.

Reply with your intent, for example:

```
I want to build a new SaaS
```

`/ulak-ask` routes you to `/ulak-start`. Answer the 27-question wizard (pick `[b]` beginner mode if you want plain-language explanations). On confirmation, `/ulak-scaffold` runs automatically and writes a complete project to the output path.

Then:

```
/ulak-next-steps
```

This produces a personalized 8–10-step runbook: `pnpm install`, fill `.env.local`, create Supabase project (→ [tutorial 1](../../tutorials/supabase.md)), push first migration, create admin user, `pnpm dev`, open `localhost:3000`, log in.

### Where to go when stuck

- "What does this term mean?" → `/ulak-explain <term>`
- "How do I set up Supabase?" → [`docs/tutorials/supabase.md`](../../tutorials/supabase.md)
- "How do I deploy to Vercel?" → [`docs/tutorials/vercel.md`](../../tutorials/vercel.md)
- "How do I send email via Resend?" → [`docs/tutorials/resend.md`](../../tutorials/resend.md)
- "How do I push to GitHub?" → [`docs/tutorials/github.md`](../../tutorials/github.md)

### Expected output

A working scaffold under your chosen `output_path/`, plus:

```
reports/current/
├── scaffold-inputs.yaml
├── scaffold-manifest.md
├── scaffold-plan.md
└── next-steps.md          ← the runbook /ulak-next-steps wrote
```

After following `next-steps.md`, `localhost:3000` is running, admin login works, payment sandbox is configured, i18n switcher toggles between English and Turkish.

### When this workflow is insufficient

- **You do not want a SaaS.** The wizard is SaaS-first.
- **Your stack is not Next.js.** Remix and SvelteKit are experimental; other stacks require manual wiring via `/ulak-scaffold` overrides or post-scaffold modifications.
- **You want total control over file structure.** Use manual clone (Method 2 of install) + hand-writing your own scaffold.

Full walkthrough: [`../../showcase/02-scaffold-walkthrough.md`](../../showcase/02-scaffold-walkthrough.md).

---

## Workflow 2 — Existing-project audit

### Usage scenario

You inherited a codebase. Your team needs a structured understanding of what is there, what is wrong, what is risky, and what to do next. You want the answer to be reviewable artefacts on disk, not a chat transcript.

### Command sequence

```bash
cd /path/to/your-project
ulak init .                # append the @-import if Ulak OS is installed
claude                     # or: codex, copilot, gemini
```

Inside the CLI:

```
/director komple
```

Or, if you prefer natural-language:

```
hi ulak
# then: "audit this project end to end"
```

`/ulak-ask` routes to `/director komple`.

### What happens, phase by phase

1. **Phase 0 — Environment lock.** Reads git state, detects stacks, pins 9-field router decision, writes `runtime-manifest.md` and `assumptions.md`.
2. **Phase 1 — Deep inventory.** `cartographer` writes `inventory.md` with file:line citations for every surface, route, config, migration, i18n key.
3. **Phase 2 — Parallel specialist evidence.** Multiple specialists dispatch in parallel (security-hardening-lead, backend-api-architect, data-database-governor, design-system-architect, infra-release-sre, localization-i18n-lead, privacy-compliance-counsel, etc.).
4. **Phase 3 — Did-you-know.** Non-obvious findings layer (unused imports, RLS asymmetry, missing locale keys, rate-limit gaps, deploy scripts without rollback). Empty or trivial output is rejected and Phase 2 is widened.
5. **Phase 4 — Synthesis.** Five files: `analysis-findings.md`, `target-state.md`, `execution-roadmap.md`, `validation-plan.md`, `pack-gap-register.md`.
6. **Phase 4.5 — Live probes (conditional).** Runs if `validation-plan.md §6` requires probes.
7. **Phase 5 — Manager verdict.** Writes `manager-verdict.md` and `validation-result.yaml` with `signoff_status: ready | conditional | blocked`.

### Expected output

Fifteen artefact files under `reports/current/`:

```
reports/current/
├── runtime-manifest.md
├── assumptions.md
├── active-variables.yaml
├── inventory.md
├── evidence-register.md
├── deep-scan-report.md
├── specialists/
├── did-you-know.md
├── analysis-findings.md
├── target-state.md
├── execution-roadmap.md
├── validation-plan.md
├── pack-gap-register.md
├── live-probe-results.md   (if Phase 4.5 ran)
├── manager-verdict.md
└── validation-result.yaml
```

### Persona-split variant

For multi-tenant products with customer / admin / partner / support surfaces:

```
/director komple dispatch=persona persona_set=customer,admin,partner,support
```

Persona agents dispatch in Phase 2 (instead of or in addition to discipline agents). The director makes contradictions explicit instead of silently resolving them. Full walkthrough: [`../../showcase/03-persona-audit.md`](../../showcase/03-persona-audit.md).

### When this workflow is insufficient

- **You only need a map, not an audit.** Use `/intake`.
- **You want a second opinion via 14-dimension scorecard.** Use `/ulak-audit-deep`.
- **You need a frontend redesign, not a full audit.** Use `/frontend-war-room`.
- **Codebase is so large that a single run exceeds context.** Split by surface or run `/director skip_phase_1=true` after a one-time `/intake`.

Full walkthrough: [`../../showcase/01-audit-walkthrough.md`](../../showcase/01-audit-walkthrough.md).

---

## Workflow 3 — Learn a specific service or term

### Usage scenario

Post-scaffold, you see `SUPABASE_URL`, `STRIPE_WEBHOOK_SECRET`, or `RLS policy` in a file and want a quick explanation. Or you need to open a Supabase account for the first time and do not know where to click.

### Command sequence

For a term:

```
/ulak-explain rls
```

Returns a 5-field entry: **Simple** (one sentence for a non-technical reader), **Technical** (precise definition), **Analogy** (everyday comparison), **In Ulak** (how Ulak OS uses the term), **Related** (cross-linked terms in the glossary). Source: `docs/runtime/beginner-glossary.md` (47 terms).

For a service:

- Supabase → [`docs/tutorials/supabase.md`](../../tutorials/supabase.md) — account + project + API keys + migration push + first admin (15 minutes)
- Vercel → [`docs/tutorials/vercel.md`](../../tutorials/vercel.md) — account + GitHub connection + env vars + deploy + custom domain (10 minutes)
- GitHub → [`docs/tutorials/github.md`](../../tutorials/github.md) — account + repo creation + SSH key + first push (10 minutes)
- Resend → [`docs/tutorials/resend.md`](../../tutorials/resend.md) — account + API key + domain verify + first email (5 minutes)

### Expected output

For `/ulak-explain`: inline 5-field entry in the CLI.

For tutorials: side-by-side reading while completing the setup steps in the service's web UI.

### When this workflow is insufficient

- **You need a deep-dive conceptual doc.** Read the service's own documentation; the tutorial covers only the Ulak-relevant setup.
- **Your term is not in the 47-term glossary.** Open an issue to add it, or ask `/ulak-ask` for a broader search.

---

## Workflow 4 — Pack expansion

### Usage scenario

Running `/director` surfaced a gap — "we needed a sector pack for healthcare SaaS but none exists", or "the scaffolder should have a Laravel template but it's Next-only". You want to close the gap.

### Command sequence

```bash
cd ~/.ulak-os         # or wherever Ulak OS is installed
claude

/pack-gap-audit
```

Produces `reports/current/pack-gap-register.md` listing missing units.

Then for each gap, propose a fix. See [chapter 07](./07-contributing.md) for the contribution contract. If the gap is a pattern you observed in ≥2 real projects:

```
/ulak-pattern-extract source=./other-repo pattern="healthcare-hipaa-audit-log"
```

Writes a `pattern-import-ledger.md` entry plus a draft rule-pack / sector-pack / anti-pattern file.

### Expected output

- `reports/current/pack-gap-register.md` — ranked gap list
- New entries in `docs/governance/pattern-import-ledger.md`
- Optional new files under `docs/runtime/rule-packs/` or `docs/runtime/sector-packs.md`

### When this workflow is insufficient

- **Only one real-project occurrence.** Below the evidence bar. Wait for a second occurrence before importing.
- **Stack-specific guardrail, not a cross-cutting pattern.** Belongs in a rule pack, not an anti-pattern.

---

## Workflow 5 — Cross-project pattern lift

### Usage scenario

You noticed a defect or a good pattern in one project; you want to lift it into Ulak OS so every future project inherits the lesson. This is how the pack accumulates institutional memory.

### Command sequence

```bash
# 1. In the source project, identify the pattern with file:line evidence
# Example: webhook handler signs empty body (AP-18 precedent)

# 2. Run pattern-extract
cd ~/.ulak-os
claude

/ulak-pattern-extract source=/path/to/source-project pattern="webhook-signs-empty-body"
```

Ulak OS generates a ledger entry template. Fill in:

```yaml
- id: AP-NN
  title: "<short title>"
  source_projects:
    - descriptor: "abstract descriptor 1"
    - descriptor: "abstract descriptor 2"
  source_files:
    - path/to/file.ts:45-67
    - path/to/other-file.ts:120-145
  trust_tier: T2          # T1 if directly observed, T2 if inferred
  rationale: "<one-line why>"
  fix_summary: "<one-line fix>"
  cross_project_occurrences: 2
```

Minimum: **≥2 real-project citations** and **trust tier ≥ T2**.

Then:

```bash
bash scripts/validate-schemas.sh
git add docs/governance/pattern-import-ledger.md docs/runtime/anti-patterns.md
git commit -m "feat(patterns): import AP-NN — webhook-signs-empty-body"
```

### Expected output

- Updated `docs/governance/pattern-import-ledger.md`
- Updated `docs/runtime/anti-patterns.md` (or new rule-pack / sector-pack file)
- `validate-schemas.sh` green
- From the next run onward, every `/director` and `/ulak-scaffold` checks projects against this pattern

### When this workflow is insufficient

- **Only one source project.** Rejected by CI. Wait for a second occurrence.
- **Pattern is project-specific, not generalizable.** Keep it in the source repo; do not import.
- **Pattern is positive (good practice) not an anti-pattern.** Same flow but the ledger entry targets `docs/runtime/rule-packs/` or `docs/runtime/sector-packs.md`.

Full walkthrough: [`../../showcase/04-cross-project-absorption.md`](../../showcase/04-cross-project-absorption.md).

---

## Decision tree summary

```
What do I need?
├── First time, starting a new SaaS                   → Workflow 1  (hi ulak → /ulak-start)
├── Existing codebase, need full audit                 → Workflow 2  (/director komple)
├── Persona-split audit                                → Workflow 2, variant
├── Want a 14-dimension scorecard second opinion       → /ulak-audit-deep
├── Need to understand a term or service               → Workflow 3  (/ulak-explain, tutorials/)
├── Pack is missing a capability                       → Workflow 4  (/pack-gap-audit)
├── Want to add a cross-project pattern to Ulak OS     → Workflow 5  (/ulak-pattern-extract)
├── Only need intake / inventory                       → /intake
├── CI is red, do not know why                         → /triage-build
├── Frontend redesign                                  → /frontend-war-room
└── Re-validate a prior /director run                  → /final-verdict
```

## Tips

**Archive runs before a re-audit.** Before each `/director` run, move the current reports dir into `reports/archive/<date>/`. The audit trail stays intact and you can diff runs.

**State persona explicitly in multi-surface SaaS.** `dispatch=persona persona_set=customer,admin,partner` saves the router from guessing.

**Never flip `signoff_status` to `ready` manually.** If the verdict is blocked, read `validation-plan.md §6`, execute the probes, run `/final-verdict` to refresh.

**Force a sector pack when needed.** If the router picks the wrong sector in Phase 0, override in `active-variables.yaml` with `sector: fintech` (or the correct slug).

**Read a walkthrough before your first run.** [`docs/showcase/`](../../showcase/) contains four annotated runs (audit, scaffold, persona, cross-project) — spend 15 minutes there before your first real run.

**If you are new, use beginner mode.** `/ulak-start` picks `[t]` technical by default. `[b]` beginner mode replaces jargon with plain language and pulls glossary entries inline.

---

Next: [06 — Governance](./06-governance.md)
