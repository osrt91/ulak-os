---
description: Scaffold a full-stack SaaS project with Ulak OS governance baked in. Produces a shippable Next.js + Supabase + payment + auth + i18n project skeleton in a greenfield directory with CI, tests, RLS policies, deploy pattern, and all Ulak rule packs + sector packs pre-wired. Use when starting a new SaaS product from scratch.
phases_run: [0, 4, 5]
---

# /ulak-scaffold

Greenfield full-stack SaaS scaffolder. Produces a ship-ready starter project with Ulak OS governance baked in from commit 1.

## When to use

- Starting a new SaaS product
- You want the 23 sector packs + 8 rule packs + 79 anti-patterns + 22 governance docs applied from the start, not as a later audit
- You want a consistent stack across a portfolio of products

## What it produces

A new directory under the operator's chosen path containing:

- **Next.js 16 + TypeScript 5 + Tailwind CSS 4** frontend (SSR + App Router + Server Components)
- **Supabase** (self-hosted or cloud) for auth + DB + storage + realtime
- **Payment provider** (Stripe / Iyzico / both / none) with the transactional FSM pattern pre-wired
- **Auth architecture**: DB-sourced role (not `user_metadata`) + product-surface-split (customer / admin + optional partner-reseller)
- **i18n**: locale SSOT + `turkish-locale` rule pack baseline (tr + en default; extensible)
- **RLS policies**: tenant isolation templates
- **CI** (.github/workflows/): validate-imports + validate-schemas + gitleaks + dependabot + eval-smoke (warn-only initially)
- **`.env.example`**: all required env vars with placeholders, ZERO real secrets
- **`.gitignore`**: `.env.local` + `.claude/settings.local.json` + all Ulak governance patterns
- **`.claude/`**: settings.json with deny list + settings.local.example.json template + CLAUDE.md importing Ulak OS core contract
- **`docs/`**: README + SETUP + pattern-import-ledger.yaml seed
- **`infrastructure/`**: docker-compose base + prod override + Traefik labels + kale-kapisi.sh template
- **`tests/`**: vitest config + first unit test + first e2e stub
- **`scripts/`**: preflight.sh + install-hooks.sh (pre-push parity from R-04)

## Inputs (collected interactively or via args)

```yaml
product_name: "wording-manager" # kebab-case; used for package.json + directory + Supabase schema
product_domain: "content-ops" # one of: saas, ecommerce, edtech, fintech, marketplace, content-ops, community, dev-tools
stack_frontend: "nextjs" # nextjs | remix | sveltekit (nextjs default; others require custom work)
stack_backend: "supabase" # supabase | node-fastapi | hybrid
locale_primary: "tr" # tr | en (determines which rule packs load)
locales_supported: ["tr", "en"] # array
payment_provider: "iyzico" # none | stripe | iyzico | both
has_reseller_tier: false # true activates SP-05 reseller-enabled-saas
has_admin_surface: true # nearly always true
has_mobile: false # true scaffolds a mobile/ workspace (Expo + react-native-expo rule pack)
hosting: "self-managed-vps" # self-managed-vps | vercel | fly | railway
output_path: "../wording-manager" # where to scaffold; sibling directory by default
```

Any field can be omitted; the command will prompt for required fields before executing.

## Phases

### Phase 0 — router decision
Output: scaffold-manifest.md

Records the inputs above + derived activations:
- Which sector packs will activate in the generated project's CLAUDE.md
- Which rule packs will load
- Which anti-patterns will be enforced in the CI gates

### Phase 4 — synthesis of target structure
Output: scaffold-plan.md

Lists every file the scaffolder will create with content summary. Operator reviews before Phase 5 execution.

### Phase 5 — materialization
Output: files on disk + `reports/current/scaffold-log.md`

Dispatches the `saas-scaffolder` skill which:
1. Creates the target directory
2. Writes package.json + tsconfig.json + next.config.ts + tailwind.config.ts
3. Writes app/ structure (public / auth / customer / admin / [partner/ if has_reseller_tier])
4. Writes supabase/ migrations with RLS templates
5. Writes infrastructure/ compose + prod override + kale-kapisi.sh
6. Writes.github/workflows/ CI + dependabot + gitleaks
7. Writes tests/ with vitest + playwright stubs
8. Writes scripts/preflight.sh + install-hooks.sh
9. Writes.env.example +.gitignore +.claude/ tree
10. Writes CLAUDE.md that imports Ulak OS core contract
11. Runs `git init` + first commit

## Post-scaffold action

After the scaffold completes, the operator runs in the new project directory:

```bash
cd../wording-manager
pnpm install
cp.env.example.env.local
# fill.env.local with real values
pnpm dev # verify baseline works./scripts/install-hooks.sh # pre-push parity
```

Then optionally runs `/director komple` from Ulak OS on the new project to validate the baseline health score.

## Rules

- **No real secrets ever.** `.env.example` has placeholders only. The scaffolder refuses to embed tokens.
- **Ulak governance applied from commit 1.** The generated CLAUDE.md imports Ulak OS core contract; the generated `.gitignore` has Ulak's discipline; the CI workflows are Ulak's validated patterns.
- **Pattern-import-ledger seeded.** A blank `docs/governance/pattern-import-ledger.yaml` is created so future cross-project pattern imports are trackable.
- **Vendor adapter parity.** If the operator later adds `.gemini/commands/` or `.codex/`, the vendor-parity check will catch drift.

## Anti-patterns this command avoids

By design, the scaffolded project cannot contain these at commit 1:

- AP-16 `.env.local` committed (it's gitignored)
- AP-19 Root `.env.local` in monorepo (if has_mobile, per-app env files are the default)
- AP-11 Multi-layer auth bypass (single auth helper is generated, all entry points use it)
- AP-12 Fake rollback deploy (deploy script template includes health probe contract)
- AP-18 Static HMAC over empty body (deploy webhook template signs full body + timestamp)

## Integration

- `.claude/skills/saas-scaffolder/` — the executable skill
- `docs/runtime/sector-packs.md §greenfield-saas-starter` (SP-14) — the sector pack for new SaaS
- `templates/saas-starter/` — reference template files
- `docs/runtime/output-profiles.md` — PACK_GENERATION_PROFILE + GREENFIELD_BUILDER_PROFILE both feed this command

ARGUMENTS:
$ARGUMENTS
