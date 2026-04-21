# 05 — Workflows

This chapter walks through **five end-to-end workflows**. Each section gives the usage scenario, the command sequence, the expected output, and an honest note on when the workflow is insufficient and what to reach for instead.

Text-based walkthroughs with more detail (terminal output, sample artefacts, annotated phases) live in [`../../showcase/`](../../showcase/README.md).

## Workflow index

| # | Workflow | Entry command | Time |
|---|---|---|---|
| 1 | [Brownfield audit](#workflow-1--brownfield-audit) | `/director komple` | 15–40 min |
| 2 | [Greenfield scaffold](#workflow-2--greenfield-scaffold) | `/ulak-scaffold` | 10–20 min |
| 3 | [Multi-persona audit](#workflow-3--multi-persona-audit) | `/director dispatch=persona` | 20–40 min |
| 4 | [Pattern import](#workflow-4--pattern-import) | Manual edit + `/pack-gap-audit` | variable |
| 5 | [Re-audit / follow-up](#workflow-5--re-audit--follow-up) | `/final-verdict` | 5–10 min |

---

## Workflow 1 — Brownfield audit

### Usage scenario

You inherited a codebase. Your team needs a structured understanding of what is there, what is wrong, what is risky, and what to do next. You want the answer to be reviewable artefacts on disk, not a chat transcript.

### Command sequence

```bash
# 1. Make sure Ulak OS is wired into the project's CLAUDE.md
cd /path/to/your-project
ulak init .            # append the @-import if Ulak OS is installed on your machine

# 2. Open your AI coding CLI in the project
claude   # or: codex, gemini

# 3. Inside the CLI, run the full program
/director komple
```

### What happens, phase by phase

1. **Phase 0 — Environment lock.** The director reads your git state, detects stacks (Next.js, Supabase, Python, Docker, and more), pins the 9-field router decision, writes `runtime-manifest.md` and `assumptions.md`.
2. **Phase 1 — Deep inventory.** The `cartographer` agent walks the project and writes `inventory.md` with file:line citations for every surface (customer, admin, public API, partner), every route, every config file, every migration, every i18n key per locale.
3. **Phase 2 — Parallel specialist evidence.** The director dispatches multiple specialists at once (security-hardening-lead, backend-api-architect, data-database-governor, design-system-architect, infra-release-sre, localization-i18n-lead, privacy-compliance-counsel, and others as relevant). Each writes its section to `evidence-register.md`.
4. **Phase 3 — Did-you-know.** The director assembles the non-obvious findings layer: unused imports inflating bundle size, RLS asymmetry across sibling tables, missing locale keys, rate-limit gaps, deploy scripts without rollback. Empty or trivial output is rejected and Phase 2 is widened.
5. **Phase 4 — Synthesis.** Five files: `analysis-findings.md`, `target-state.md`, `execution-roadmap.md`, `validation-plan.md`, `pack-gap-register.md`.
6. **Phase 4.5 — Live probes (conditional).** Runs if `validation-plan.md §6` requires probes. Outputs `live-probe-results.md`.
7. **Phase 5 — Manager verdict.** Writes `manager-verdict.md` and `validation-result.yaml`. If any Critical finding is unresolved, `signoff_status: blocked`; if all pass, `signoff_status: ready`.

### How to read the manager verdict

Open `reports/current/manager-verdict.md`. The canonical structure:

1. **Runtime decision** — the router's 9-field pinning.
2. **Phase status** — per-phase artefact state (`complete`, `weak-evidence`, `missing`).
3. **Critical / High / Medium findings** — severity-ranked.
4. **Top 3 did-you-know highlights** — non-obvious findings inline.
5. **Residual risks** — what remains unresolved and why.
6. **Next execution lane** — the suggested follow-up (execute roadmap wave 1, run `/frontend-war-room`, open a specific investigation).

If `signoff_status: ready` with unresolved Critical findings, the verdict is by contract invalid — re-run with `/final-verdict` to force re-validation.

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
│   ├── security-hardening-lead.md
│   ├── backend-api-architect.md
│   ├── data-database-governor.md
│   └── ...
├── did-you-know.md
├── analysis-findings.md
├── target-state.md
├── execution-roadmap.md
├── validation-plan.md
├── pack-gap-register.md
├── live-probe-results.md           (if Phase 4.5 ran)
├── manager-verdict.md
└── validation-result.yaml
```

### When this workflow is insufficient

- **You only need a map, not an audit.** Use `/intake` — it runs Phase 0–2 only.
- **You already have artefacts from a prior run and want to refresh the verdict.** Use `/final-verdict` (Workflow 5).
- **You need a frontend redesign, not a full audit.** Use `/frontend-war-room`.
- **The codebase is so large that a single director run exceeds your context budget.** Split by surface: run `/director mode=EXTEND scope=<specific-surface>`.

Full walkthrough with sample output: [`../../showcase/01-audit-walkthrough.md`](../../showcase/01-audit-walkthrough.md).

---

## Workflow 2 — Greenfield scaffold

### Usage scenario

You are starting a new SaaS product. You want the governance, the discipline, the anti-pattern gates, and the stack wiring applied from commit 1 — not retrofitted later.

### Command sequence

```bash
# 1. Open your AI coding CLI from the Ulak OS repo (or any directory — the command is vendor-agnostic)
cd ~/.ulak-os         # or wherever you installed
claude                # or: codex, gemini

# 2. Run the scaffolder with inline arguments
/ulak-scaffold product_name=example-saas product_domain=saas locale_primary=en payment_provider=stripe output_path=../example-saas
```

If you omit arguments, the command prompts for required fields interactively.

### What happens

1. **Phase 0 — Router decision.** Writes `reports/current/scaffold-manifest.md` with your inputs plus derived activations (which sector packs will load in the generated project's `CLAUDE.md`, which rule packs will load, which anti-patterns the CI gates will enforce).
2. **Phase 4 — Plan synthesis.** Writes `scaffold-plan.md` listing every file the scaffolder will create. You review this before Phase 5.
3. **Phase 5 — Materialization.** The `saas-scaffolder` skill:
   - Creates the target directory (refuses if non-empty).
   - Writes `package.json`, `tsconfig.json`, `next.config.ts`, `tailwind.config.ts`.
   - Writes `app/` structure with public / auth / customer / admin (and partner if `has_reseller_tier=true`).
   - Writes `supabase/` migrations with RLS policy templates.
   - Writes `infrastructure/` with docker-compose + prod override + Traefik labels + VPS hardening script.
   - Writes `.github/workflows/` with validate-imports, validate-schemas, gitleaks, dependabot, eval-smoke (warn-only initially).
   - Writes `tests/` with vitest + playwright stubs.
   - Writes `scripts/preflight.sh` and `scripts/install-hooks.sh`.
   - Writes `.env.example` (placeholders only, zero real secrets).
   - Writes `.gitignore` with Ulak's discipline patterns.
   - Writes `.claude/` with scoped settings + local example.
   - Writes `CLAUDE.md` importing the Ulak OS core contract.
   - Runs `git init` and creates commit 1.

### Anti-patterns gated by construction

Eight anti-patterns the scaffolded project cannot contain at commit 1:

- **AP-16** — `.env.local` committed (it is gitignored from day one)
- **AP-19** — Root `.env.local` in a monorepo (per-app env files if `has_mobile=true`)
- **AP-11** — Multi-layer auth bypass (single auth helper, all entry points route through it)
- **AP-12** — Fake rollback deploy (deploy template includes health-probe contract)
- **AP-18** — Static HMAC over empty body (deploy webhook template signs full body + timestamp)
- **AP-06** — `user_metadata` as the source of truth for role (DB-sourced role only)
- **AP-13** — Missing `server-only` guards on server modules
- **AP-RLS-asymmetry** — RLS templates are symmetric across sibling tables by default

### Post-scaffold checklist

```bash
cd ../example-saas
pnpm install
cp .env.example .env.local
# Fill .env.local with real values (Stripe test keys, Supabase URL, and so on)
pnpm dev                    # verify baseline works
./scripts/install-hooks.sh  # pre-push parity hook
git log --oneline -5        # confirm commit 1 is pristine
```

Then optionally run `/director komple` from Ulak OS against the new project to validate the baseline health score.

### When this workflow is insufficient

- **You want something that is not a SaaS.** The scaffolder is SaaS-first. For CLI tools, libraries, games, or embedded projects, use your stack's native starter and add Ulak governance via `ulak init`.
- **Your stack is not covered.** The primary stack is Next.js + Supabase. Remix, SvelteKit, and FastAPI hybrids are experimental (flagged in the scaffolder docs).
- **You need a different payment provider.** Stripe and Iyzico are supported; others require manual wiring via the payment-integrated-saas sector pack.

Full walkthrough: [`../../showcase/02-scaffold-walkthrough.md`](../../showcase/02-scaffold-walkthrough.md).

---

## Workflow 3 — Multi-persona audit

### Usage scenario

You run a multi-tenant SaaS with distinct user surfaces (customer, admin, partner / reseller, support). You want to know how the product looks through each persona's lens and where the surfaces disagree with each other.

### Command sequence

```bash
cd /path/to/your-project
claude                 # or: codex, gemini

/director komple dispatch=persona persona_set=customer,admin,partner,support
```

Or combine discipline-based and persona-based dispatch:

```
/director komple dispatch=both parallel_dispatch=9
```

### What happens

The director dispatches **persona agents** in Phase 2 instead of (or in addition to) discipline agents:

- `customer-persona` — the end user view
- `admin-persona` — the operator / moderator view
- `bayi-persona` (partner / reseller view — Turkish "bayi" means dealer/partner)
- `support-persona` — the support agent view
- `developer-persona` — the internal developer view
- `compliance-persona` — the legal / compliance view
- `security-redteam` — the adversarial view

Each persona produces a section in `evidence-register.md`. The director then merges them in `deep-scan-report.md`, making **contradictions explicit** instead of silently resolving them.

### Typical contradictions this surfaces

- Admin surface has a bulk-delete action; compliance persona flags it as a GDPR right-to-be-forgotten gap.
- Customer persona expects order-history export; support persona expects the same data, but at a per-customer granularity the backend does not provide.
- Partner persona wants a sub-account model; security red-team flags it as an IDOR / BOLA expansion.

Contradictions become **residual risks** in `manager-verdict.md`, not silent winners. The operator then decides.

### Expected output

Same 15-file artefact chain as Workflow 1, but with a richer `evidence-register.md` (per-persona sections), a `deep-scan-report.md` that calls out contradictions, and a `manager-verdict.md` that lists contradictions under Residual Risks.

### When this workflow is insufficient

- **Single-surface product.** Persona dispatch is overhead when all your users see the same app.
- **You only have 2 personas.** Just run `/director komple` — the default dispatch picks up the obvious ones.
- **Contradictions need legal review.** Ulak OS surfaces the contradiction; a human counsel resolves it.

Full walkthrough: [`../../showcase/03-persona-audit.md`](../../showcase/03-persona-audit.md).

---

## Workflow 4 — Pattern import

### Usage scenario

You noticed a defect (or a good pattern) in one project. You want to lift it into Ulak OS so every future project — yours or a teammate's — inherits the lesson.

### Command sequence

Pattern import is **manual documentation**, not a command. The flow:

```bash
# 1. In the source project, identify the pattern with file:line evidence
# Example: a webhook that signs an empty body instead of the full payload

# 2. Open the Ulak OS repo
cd ~/.ulak-os

# 3. Add an entry to the pattern-import ledger
vim docs/governance/pattern-import-ledger.md
```

Append an entry:

```yaml
- id: AP-20
  title: "Webhook signs empty body"
  source_project: "payment-integrated SaaS with Stripe webhook"
  source_files:
    - infrastructure/webhook-handler.ts:45-67
  trust_tier: T2       # T1 if directly observed, T2 if inferred from config
  rationale: "Empty-body HMAC is trivially replayable; attacker resends
              arbitrary payloads with the captured signature."
  fix_summary: "Sign full body + timestamp; server verifies both."
  cross_project_occurrences: 2
```

Pattern import requires **≥2 real-project citations** (abstract descriptors if the projects are private). Trust tier must be T2 or stronger. See [chapter 07](./07-contributing.md) for the full contribution contract.

```bash
# 4. Add the corresponding anti-pattern entry
vim docs/runtime/anti-patterns.md

# 5. Run the pack-gap audit to confirm wiring
claude
/pack-gap-audit
```

### What happens

- The new anti-pattern entry becomes part of the public runtime surface. Every director run from this point forward checks projects against it.
- The ledger entry provides provenance: anyone reading Ulak OS can see where this pattern came from, at what trust tier, and in how many projects it has been observed.
- The `/pack-gap-audit` run confirms the new entry is reachable from `anti-patterns.md` and the ledger.

### Expected output

- Updated `docs/governance/pattern-import-ledger.md`
- Updated `docs/runtime/anti-patterns.md`
- `reports/current/pack-gap-register.md` showing any wiring gaps

### When this workflow is insufficient

- **Only one real-project observation.** Below the evidence bar. Wait for a second occurrence before importing.
- **Pattern is stack-specific (e.g., "always use React.memo here").** Belongs in a **rule pack**, not an anti-pattern. See [chapter 07](./07-contributing.md) § Rule pack.
- **Pattern is a full architectural shape.** Belongs in a **sector pack**.

Full walkthrough: [`../../showcase/04-cross-project-absorption.md`](../../showcase/04-cross-project-absorption.md).

---

## Workflow 5 — Re-audit / follow-up

### Usage scenario

You ran `/director` a week ago. You executed part of the roadmap. You want to re-evaluate the artefacts and refresh the verdict.

### Command sequence

```bash
cd /path/to/your-project
claude                # or: codex, gemini

/final-verdict
```

### What happens

`/final-verdict` dispatches four agents (`qa-validation-commander`, `release-readiness-auditor`, `red-team-challenger`, `autonomous-program-director`) plus the `final-validation` skill. The flow:

1. Read existing artefacts under `reports/current/`.
2. Re-run Phase 4.5 live probes if `validation-plan.md §6` has any, or if any Critical finding rested on T2/T3 evidence.
3. Red-team challenges the existing verdict. If the existing `signoff_status: ready` is unsupported, the red-team flips it.
4. Writes a merged `manager-verdict.md` with fresh residual risk counting.

### Expected output

- Updated `reports/current/validation-plan.md`
- Updated `reports/current/manager-verdict.md`
- Updated `reports/current/live-probe-results.md` if probes ran

### When this workflow is insufficient

- **You made big changes since the prior run.** The inventory is stale — re-run `/director komple` instead.
- **The prior run was incomplete.** `/final-verdict` cannot synthesize from missing artefacts; it only re-validates.
- **You want to add new specialist evidence.** Use `/director komple skip_phase_1=true parallel_dispatch=...` to resume from the existing inventory with wider specialist dispatch.

---

## Further reading

- [`../../showcase/README.md`](../../showcase/README.md) — all four showcase walkthroughs with sample output
- [`../../runbooks/first-hour-with-ulak-os.md`](../../runbooks/first-hour-with-ulak-os.md) — clone → first audit → first scaffold → first commit in 60 minutes
- [`../../runtime/waves-pattern.md`](../../runtime/waves-pattern.md) — how `execution-roadmap.md` turns into sequenced execution
- [`../../runtime/persona-dispatch-pattern.md`](../../runtime/persona-dispatch-pattern.md) — Workflow 3 detail

---

Next: [06 — Governance](./06-governance.md)
