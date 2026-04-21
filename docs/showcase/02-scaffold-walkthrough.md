# Walkthrough 02 — `/ulak-scaffold` for a greenfield ExampleCorp SaaS

A fictional operator starts a new payment-integrated SaaS called **ExampleCorp Invoice** — a Turkish-first invoicing product with partner-agency resale tier. This walkthrough shows the scaffolder from prompt to first commit.

## Operator prompt

```
> /ulak-scaffold ExampleCorp Invoice \
    product=examplecorp-invoice \
    sector=payment-integrated-saas \
    stack=nextjs-supabase \
    locale_primary=tr \
    locales_supported=tr,en \
    payment_provider=iyzico \
    has_reseller_tier=true \
    has_admin_surface=true \
    has_mobile=false \
    hosting=self-managed-vps \
    output_path=../examplecorp-invoice
```

The operator provides all fields inline. The scaffolder doesn't need to prompt interactively.

## Template resolution

The scaffolder dispatches the `saas-scaffolder` skill which derives activations:

```yaml
# reports/current/scaffold-manifest.md
derived_activations:
  sector_packs:
    - saas
    - payment-integrated-saas          # because payment_provider != none
    - reseller-enabled-saas            # because has_reseller_tier = true
    - multi-tenant-supabase
    - vps-nginx-compose-topology       # because hosting = self-managed-vps
  rule_packs:
    - typescript-nextjs
    - docker-compose
    - api-security
    - turkish-locale                   # because locale_primary = tr
    - localization-ssot
  anti_patterns_enforced:
    - AP-01..AP-19 (19 total relevant to stack)
  templates_to_render: 27
```

Operator reviews `scaffold-plan.md` (the file tree the skill will produce) and approves.

## Output directory tree

The skill writes every file. The resulting tree:

```
../examplecorp-invoice/
├── .claude/
│   ├── settings.json
│   └── settings.local.example.json
├── .env.example
├── .github/
│   ├── dependabot.yml
│   ├── vendor-parity-exemptions.txt
│   └── workflows/
│       ├── ci-validation.yml
│       ├── deploy.yml
│       └── secret-scan.yml
├── .gitignore
├── .gitleaks.baseline
├── .gitleaks.toml
├── CLAUDE.md                              # @-imports Ulak OS core contract
├── DESIGN.md
├── README.md
├── app/
│   ├── (admin)/
│   │   └── admin/
│   │       └── page.tsx
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── (customer)/
│   │   └── dashboard/page.tsx
│   ├── (partner)/
│   │   └── partner/page.tsx               # because has_reseller_tier
│   ├── (public)/
│   │   └── page.tsx                       # landing page
│   ├── api/
│   │   ├── admin/
│   │   ├── customer/
│   │   ├── partner/
│   │   ├── public/
│   │   │   └── health/route.ts
│   │   └── webhooks/
│   │       └── iyzico/route.ts            # payment callback stub
│   ├── globals.css
│   └── layout.tsx
├── components/
│   ├── admin/
│   ├── auth/
│   ├── customer/
│   ├── shared/
│   └── ui/
├── docs/
│   ├── architecture/
│   ├── governance/
│   │   └── pattern-import-ledger.yaml     # seeded empty
│   ├── i18n/
│   │   ├── tr.json
│   │   └── en.json
│   └── runbooks/
│       ├── deploy.md
│       └── first-hours-on-vps.md
├── infrastructure/
│   ├── deploy-poll.sh
│   ├── deploy.sh
│   ├── docker-compose.override.yml.example
│   ├── docker-compose.prod.yml
│   ├── docker-compose.yml
│   ├── kale-kapisi.sh
│   └── nginx/
│       └── examplecorp-invoice.conf
├── lib/
│   ├── auth/
│   │   └── index.ts                       # single auth helper, AP-11 prevention
│   ├── i18n/
│   ├── logger.ts
│   ├── rate-limit.ts
│   └── supabase/
│       ├── admin.ts
│       ├── client.ts
│       └── server.ts
├── middleware.ts
├── next.config.ts
├── package.json
├── postcss.config.mjs
├── reports/
│   └── current/                           # gitignored
├── scripts/
│   ├── install-hooks.sh
│   ├── preflight.sh
│   ├── seed-local-db.sh
│   └── validate-imports.sh
├── supabase/
│   ├── config.toml
│   └── migrations/
│       ├── 00001_initial_schema.sql
│       ├── 00002_rls_policies.sql
│       └── 00003_seed_admin.sql
├── tailwind.config.ts
├── tests/
│   ├── e2e/
│   │   └── landing.spec.ts
│   ├── integration/
│   └── unit/
│       └── lib.test.ts
└── tsconfig.json
```

41 files generated from the 27 templates (some templates materialize into multiple derived files — e.g., `.gitignore.template` + `.gitleaks.toml.template` produce both files plus the `.gitleaks.baseline` sibling).

## What's in it

- **`CLAUDE.md`** imports the Ulak OS core contract via `@`-chain; the next `/director komple` run starts with governance already loaded
- **`app/(public)`, `app/(auth)`, `app/(customer)`, `app/(admin)`, `app/(partner)`** route groups implement product-surface-split discipline from commit 1
- **`lib/auth/index.ts`** is the only auth resolution path; every server-role file imports from here (AP-11 prevention)
- **`supabase/migrations/00002_rls_policies.sql`** enables RLS on every tenant-scoped table with a `tenant_id = auth.jwt()->>'tenant_id'` predicate
- **`app/api/webhooks/iyzico/route.ts`** stub signs full body + timestamp + nonce (AP-18 prevention) before parse
- **`infrastructure/deploy.sh`** has a health probe check before marking deploy green, plus a rollback path on failure (AP-12 prevention)
- **`infrastructure/kale-kapisi.sh`** applies UFW + fail2ban + SSH lockdown + docker-proxy on first VPS run
- **`.env.example`** lists every required env var as a placeholder; `.gitignore` blocks `.env*` from ever being committed
- **`.github/workflows/ci-validation.yml`** runs validate-imports + validate-schemas + gitleaks + typecheck + unit + e2e on every PR
- **`scripts/preflight.sh` + `install-hooks.sh`** enforce the same checks pre-push (R-04 pre-push parity)
- **`docs/governance/pattern-import-ledger.yaml`** seeded empty; future cross-project pattern imports track here

## First commit message

The skill runs `git init` then commits with this message (substituted from the template):

```
feat: scaffold from Ulak OS v2.4.1 — examplecorp-invoice

Stack: Next.js 16 + Supabase + Iyzico
Locales: tr, en
Sector packs: saas, payment-integrated-saas, reseller-enabled-saas,
              multi-tenant-supabase, vps-nginx-compose-topology
Rule packs: typescript-nextjs, docker-compose, api-security,
            turkish-locale, localization-ssot

Generated by Ulak OS /ulak-scaffold.

Co-Authored-By: Ulak OS scaffolder <noreply@ulak.os>
```

## Post-scaffold checklist

```bash
cd ../examplecorp-invoice
pnpm install                              # generates pnpm-lock.yaml
cp .env.example .env.local                # fill with real Supabase + Iyzico keys
pnpm dev                                  # http://localhost:3000 should load landing
./scripts/install-hooks.sh                # enables pre-push parity
pnpm test                                 # unit test passes
pnpm exec playwright test                 # e2e smoke passes
```

Operator optionally runs `/director komple` on the new repo. The baseline audit returns **zero Critical findings** — because the governance that would otherwise be retrofitted was already in place at commit 1.

## Verification gate

The skill writes `scaffold-verdict.yaml`:

```yaml
scaffold_verdict:
  product_name: examplecorp-invoice
  files_created: 41
  validation:
    structure_valid: true
    no_real_secrets_in_tree: pass
    rls_templates_present: pass
    ci_workflows_valid: pass
    pattern_import_ledger_seeded: true
  next_steps:
    - cd ../examplecorp-invoice
    - pnpm install
    - cp .env.example .env.local && fill values
    - pnpm dev
    - ./scripts/install-hooks.sh
  optional_followup:
    - Run /director komple for v0.1.0 baseline audit
```

Total wall time from prompt to committed repo: ~3 minutes. The operator now has a ship-ready starter with 19 anti-patterns prevented by construction.
