# 04 — Commands

Ulak OS v1.0.0 ships with **nine slash commands**. Each command is an operator entry point that dispatches a specific agent (or chain of agents) to produce a defined set of artefacts. This chapter covers what each command does, when to use it, the arguments it accepts, an example invocation, and the expected output.

All commands live as markdown files under `.claude/commands/` in the pack. For Gemini CLI, equivalent `.toml` files live under `.gemini/commands/`. Vendor-parity notes are at the end of this chapter.

## Command index

| Command | Primary purpose | Typical run time |
|---|---|---|
| [`/director`](#director) | Full Phase 0 → 5 program — the executive audit | 15–40 minutes |
| [`/final-verdict`](#final-verdict) | Re-validate existing artefacts and produce a merged verdict | 5–10 minutes |
| [`/frontend-war-room`](#frontend-war-room) | Premium redesign + visual system cleanup | 20–30 minutes |
| [`/intake`](#intake) | Phase 0–2 only: read the project, produce intake + inventory | 8–15 minutes |
| [`/pack-gap-audit`](#pack-gap-audit) | Inspect the operating pack, list missing units | 5–10 minutes |
| [`/triage-build`](#triage-build) | Diagnose a failing build by stack | 5–15 minutes |
| [`/ulak-design-ref`](#ulak-design-ref) | Fetch a public brand's design reference | under 1 minute |
| [`/ulak-intake`](#ulak-intake) | Produce the Ulak intake artefact (optionally via superpowers) | 3–8 minutes |
| [`/ulak-scaffold`](#ulak-scaffold) | Generate a full-stack SaaS starter | 10–20 minutes |

---

## /director

**Source:** `.claude/commands/director.md`

### What it does

Dispatches the `autonomous-program-director` subagent to run the complete Phase 0 → 5 protocol. This is the canonical "read everything, audit everything, give me a verdict" command.

### When to use

- First pass on a brownfield project
- Rescue mission on a broken or unfamiliar codebase
- Periodic health check on a project already governed by Ulak OS
- Before a major release when you want a structured signoff

### Arguments

Positional (operator intent, free-form):
- `komple` / `full` / `complete` — full Phase 0 → 5 program
- `brownfield audit`, `brownfield rescue` — state hints
- `mode=<intervention>` — one of CREATE, REPAIR, EXTEND, REFACTOR, MIGRATE, RESCUE, REPACKAGE

Keyword:
- `mode=<intervention>` — pre-set intervention mode, bypass router inference
- `entry=<file-path>` — resume from a prior handoff plan
- `skip_phase_1=true` — skip deep inventory if `reports/current/inventory.md` is fresh
- `skip_phase_2=<comma-list>` — skip specific specialist dispatches
- `parallel_dispatch=<N>` — override the Phase 2 default dispatch cap (default 6)
- `dispatch=<specialist|persona|both>` — discipline-based vs user-role-based specialists
- `validation_depth=<light|standard|deep>` — Phase 5 validation gate depth
- `profile=<AUDIT_PROFILE|GREENFIELD_BUILDER_PROFILE|...>` — pre-select output profile

### Example invocation

```
/director komple
```

Or with keywords:

```
/director komple mode=RESCUE dispatch=persona parallel_dispatch=9
```

### Expected output

Fifteen artefact files under `reports/current/`, chained across the six phases. The terminal-facing summary prints the manager verdict at the end, plus a pointer to `reports/current/manager-verdict.md` for the full narrative.

See [chapter 05](./05-workflows.md) § Workflow 1 for the complete walkthrough.

---

## /final-verdict

**Source:** `.claude/commands/final-verdict.md`

### What it does

Runs only the validation gate. Dispatches `qa-validation-commander`, `release-readiness-auditor`, `red-team-challenger`, and `autonomous-program-director` together to re-evaluate existing artefacts under `reports/current/` and produce a merged `manager-verdict.md`.

### When to use

- After executing the roadmap produced by `/director`, to re-validate
- When you want an independent challenge from the red-team agent
- Before a release, to refresh the validation gate with fresh probes

### Arguments

Inherits director keyword arguments (`validation_depth`, `profile`). No positional arguments needed in the common case.

### Example invocation

```
/final-verdict
```

### Expected output

Updated `reports/current/validation-plan.md` and a refreshed `reports/current/manager-verdict.md` with `signoff_status` re-computed against fresh evidence. If live probes were required by `validation-plan.md §6`, `live-probe-results.md` is updated too.

---

## /frontend-war-room

**Source:** `.claude/commands/frontend-war-room.md`

### What it does

Runs the frontend / mobile redesign protocol. Dispatches `frontend-ios-flutter-director`, `design-system-architect`, and `educational-ux-specialist`. Produces a design-system master document plus per-page overrides, analysis findings, target state, and an execution roadmap scoped to frontend work.

### When to use

- Premium redesign push
- Visual system cleanup across an existing product
- Mobile app rework

### Arguments

No required arguments. Keyword: `scope=<web|mobile|both>`.

### Example invocation

```
/frontend-war-room
```

### Expected output

- `reports/current/analysis-findings.md`
- `reports/current/target-state.md`
- `reports/current/execution-roadmap.md`
- `reports/current/design-system/MASTER.md` plus per-page override files under `design-system/pages/`

### Vendor note

Claude-native. Depends on Claude Code's parallel subagent dispatch. Listed in `vendor-parity-exemptions.txt` with rationale.

---

## /intake

**Source:** `.claude/commands/intake.md`

### What it does

Runs only Phase 0 through Phase 2. Dispatches the `cartographer` agent and the `project-intake` skill. Produces intake, inventory, and initial evidence register. Does not synthesize findings or write a verdict.

### When to use

- You want a "read-only" first pass before committing to a full `/director` run
- You plan to resume with `/director entry=reports/current/intake.md skip_phase_1=true` later
- You are testing Ulak OS on a project and want the light touch

### Arguments

No required arguments.

### Example invocation

```
/intake
```

### Expected output

- `reports/current/intake.md` — operator intent + project state summary
- `reports/current/inventory.md` — deep inventory with file:line citations
- `reports/current/evidence-register.md` — initial findings from the cartographer

---

## /pack-gap-audit

**Source:** `.claude/commands/pack-gap-audit.md`

### What it does

Inspects the current operating pack and lists missing or underdeveloped units: commands, skills, agents, hooks, MCP connectors, docs, eval coverage. Dispatches the `prompt-skill-plugin-governor` agent and the `pack-gap-completion` skill.

### When to use

- You are maintaining Ulak OS (or a fork) and want to see gaps
- You completed a run where the director said "this needed a skill we don't have"
- Periodic maintenance of your local governance surface

### Arguments

No required arguments.

### Example invocation

```
/pack-gap-audit
```

### Expected output

- `reports/current/pack-gap-register.md` — ordered list of missing units with severity
- `reports/current/manager-verdict.md` — merged verdict specific to pack gaps

---

## /triage-build

**Source:** `.claude/commands/triage-build.md`

### What it does

Generalized build-triage flow. Runs `toolchain-precheck` first to determine which stacks are present, then dispatches to the matching subsystem (frontend, backend, container, mobile) with standard diagnostic commands.

### When to use

- Your build or test is red and you do not yet know why
- You just inherited a project and the CI is failing
- You want a structured diagnostic pass before guessing

### Arguments

- Keyword: `stack=<frontend|backend|container|mobile|auto>` (default `auto`)
- Keyword: `log=<path/to/ci.log>` — provide a failing CI log directly

### Example invocation

```
/triage-build
```

### Expected output

Terminal narrative of the triage flow plus (if the failure is non-trivial) a finding written to `reports/current/analysis-findings.md`.

---

## /ulak-design-ref

**Source:** `.claude/commands/ulak-design-ref.md`

### What it does

Downloads a public brand's design reference (color palette, typography, component styles, layout principles) from the `VoltAgent/awesome-design-md` repository and writes it to `reports/current/design-references/<brand>/` so frontend agents can consume it during a redesign.

### When to use

- You want to reference a public brand's design system during a frontend redesign
- You are briefing the design-system-architect and want an external anchor

### Arguments

Positional: `<brand>` — the brand slug as it exists in `VoltAgent/awesome-design-md`.

### Example invocation

```
/ulak-design-ref stripe
```

### Expected output

`reports/current/design-references/stripe/DESIGN.md` containing the brand's design reference, ready for `/frontend-war-room` to consume.

---

## /ulak-intake

**Source:** `.claude/commands/ulak-intake.md`

### What it does

Produces the Ulak intake artefact — a structured capture of operator intent, success criteria, and constraints. If the `superpowers:brainstorming` skill is available in the environment, it is called first to enrich the intake. Otherwise the command runs its own intake flow.

### When to use

- Brand new project where you want a disciplined intent capture before writing any inventory
- Before starting a scaffold or an audit when the intent is not fully clear

### Arguments

Positional: free-form operator intent.

### Example invocation

```
/ulak-intake I want to build a B2B SaaS for small retail chains
```

### Expected output

- `reports/current/intake.md` with intent, success criteria, constraints, and initial scope

---

## /ulak-scaffold

**Source:** `.claude/commands/ulak-scaffold.md`

### What it does

Greenfield full-stack SaaS scaffolder. Produces a ship-ready starter project with Ulak OS governance baked in from commit 1. Dispatches the `saas-scaffolder` skill.

### When to use

- Starting a new SaaS product
- You want the 24 sector packs + 8 rule packs + ~100 anti-patterns + 22 governance docs applied from the start, not as a later audit
- You want a consistent stack across a portfolio of products

### Arguments

Inputs are collected interactively or via keyword arguments:

```yaml
product_name: "example-saas"
product_domain: "saas"           # saas | ecommerce | edtech | fintech | marketplace | content-ops | community | dev-tools
stack_frontend: "nextjs"         # nextjs (default) | remix | sveltekit
stack_backend: "supabase"        # supabase (default) | node-fastapi | hybrid
locale_primary: "en"             # en | tr
locales_supported: ["en", "tr"]
payment_provider: "stripe"       # none | stripe | iyzico | both
has_reseller_tier: false
has_admin_surface: true
has_mobile: false
hosting: "self-managed-vps"      # self-managed-vps | vercel | fly | railway
output_path: "../example-saas"
```

Any field can be omitted; the command prompts for required fields before executing.

### Example invocation

```
/ulak-scaffold product_name=example-saas product_domain=saas locale_primary=en payment_provider=stripe
```

### Expected output

A new directory containing a full Next.js + Supabase + Stripe + i18n + CI + tests + deploy project. Post-scaffold checklist and full flow in [chapter 05](./05-workflows.md) § Workflow 2.

---

## Vendor parity

Most commands exist on all three vendors (Claude Code, Codex / Copilot, Gemini CLI). A few are Claude-native and carry documented exemptions.

| Command | Claude Code | Codex / Copilot | Gemini CLI |
|---|---|---|---|
| `/director` | yes | yes | yes |
| `/final-verdict` | yes | yes | yes |
| `/frontend-war-room` | yes | **exempt** | **exempt** |
| `/intake` | yes | yes | yes |
| `/pack-gap-audit` | yes | yes | yes |
| `/triage-build` | yes | yes | yes |
| `/ulak-design-ref` | yes | yes | yes |
| `/ulak-intake` | yes | yes | yes |
| `/ulak-scaffold` | yes | yes | yes |

**Exemptions** are tracked in `.claude/vendor-parity-exemptions.txt`. `/frontend-war-room` is Claude-native because it depends on Claude Code's parallel subagent dispatch semantics and the specific agent-file format the war room expects. Codex and Gemini reach the same goals via a different flow (manually chain `/design-system-architect` + `/frontend-ios-flutter-director` via the generic dispatch).

The parity check is enforced by `scripts/validate-vendor-parity.sh`. If you add a command under `.claude/commands/` without a matching Gemini adapter (or exemption entry), the script fails.

## Related references

- [`../../architecture/director-protocol.md`](../../architecture/director-protocol.md) — the canonical phase table
- [`../../runtime/output-profiles.md`](../../runtime/output-profiles.md) — the 7 output profiles the `profile=` argument selects
- [`../../runtime/persona-dispatch-pattern.md`](../../runtime/persona-dispatch-pattern.md) — how `dispatch=persona` works
- [`../../governance/plugin-skill-decision.md`](../../governance/plugin-skill-decision.md) — how to decide whether a new proposal is a command vs skill vs agent

---

Next: [05 — Workflows](./05-workflows.md)
