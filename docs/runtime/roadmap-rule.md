# Roadmap Rule

## Why this exists

A roadmap of "do the things" is not a plan. A roadmap of "60+ ordered, tagged, dependency-aware steps with risks and success criteria" is a plan the user can actually execute. Ulak OS's output roadmap must meet the higher bar, or the user ends up with a list of aspirations and no path.

## The target: 60+ steps for large programs

A large program (full `/director komple` run on a real project) produces a roadmap with **at least 60 steps**. Smaller scopes (single screen, single endpoint, single flow) produce proportionally fewer steps. The point is not to pad — the point is that real programs have more pieces than a 10-bullet list captures.

If the director produces a 10-step roadmap for a multi-surface full-system rescue, something was skipped or aggregated too aggressively.

## Step shape

Every step must carry:

```yaml
- step: 42 # monotonic per roadmap
 goal: "" # one-line, outcome-oriented
 scope: "" # what is and isn't in this step
 actions: [] # concrete things to do
 dependencies: [] # list of earlier step numbers
 risks: [] # what could go wrong; each with severity
 outputs: [] # what the step produces (files, PRs, changes)
 success_criteria: "" # how we know the step is done
 difficulty: trivial|easy|medium|hard|spike
 effort: XS|S|M|L|XL
 tag: quick-win|foundational|strategic|compliance|release|guardrail|research|localization|pack|security|ux|test|refactor|migration
 owner_lane: "" # which specialist or team lane
```

## Tags

Tags are the way the user reads the roadmap by type, not just by order.

- **quick-win** — low risk, high visible value, short verification. Do these first.
- **foundational** — things that enable many later steps (design system, auth refactor, analytics taxonomy, locale baseline)
- **strategic** — big bets (migration, new platform, new country, new sector pack)
- **compliance** — regulatory or policy requirements
- **release** — things required to ship
- **guardrail** — prevent future regressions (tests, hooks, CI gates)
- **research** — live research / investigation that must happen before a dependent step can begin
- **localization** — language / locale / cultural work
- **pack** — generate / modify prompts, commands, skills, agents, MCP
- **security** — auth, authz, secrets, abuse prevention
- **ux** — design, UX, accessibility, content
- **test** — test writing, test infra
- **refactor** — code restructuring without behavior change
- **migration** — moving from one state to another (data, stack, pattern)

A step can carry multiple tags if they genuinely apply (e.g., `quick-win` + `security`).

## Ordering rules

- **Quick wins first** — low-risk, high-value steps go at the top so the user sees traction
- **Foundational before dependent strategic** — if a strategic step depends on a foundational one, foundational comes first
- **Guardrails throughout** — don't batch all the test / hook / CI work at the end
- **Research before dependent execution** — if a step needs live research, the research step precedes it
- **Rollback precedes destructive migration** — every migration step has a rollback step either before or as a sub-step

## Quick wins rule

Quick wins are a specific category:

- Low risk (limited blast radius if wrong)
- High visible value (user or team notices immediately)
- Short verification (can be verified in minutes or hours, not days)

A step labeled `quick-win` must meet all three. If it doesn't, re-tag it.

Quick wins are not "easy". They are "high value per risk unit". A trivial change that doesn't affect the user is not a quick win — it's just a small change.

## Dependencies

Dependencies are explicit and numeric:

```yaml
dependencies: [3, 17]
```

Means "this step can only start after step 3 and step 17 are complete". The director orders the roadmap so dependencies are topologically sorted.

If a step has no dependencies, say `dependencies: []` — don't omit the field.

## Success criteria

Every step must state how we know it's done. Vague criteria like "looks better" or "more secure" are rejected. Acceptable criteria:

- "Lint passes on the modified files"
- "E2E test for the checkout flow passes on staging"
- "CSP report-only mode shows zero violations for 7 days"
- "Turkish characters render correctly on /profile page in both light and dark mode"
- "Admin panel /users/delete endpoint returns 403 when called with a non-admin token"

Concrete, verifiable, time-bounded.

## Risks

Each step records its risks. Each risk has a severity and a mitigation:

```yaml
risks:
 - description: "Migration may lock the users table for > 30 seconds"
 severity: High
 mitigation: "Run during low-traffic window; use online migration tool"
```

## Hard rules

- **60+ steps for full-program roadmaps.** Smaller scopes can have fewer, proportionally.
- **Every step has a tag.** No tagless steps.
- **Every step has success criteria.** Vague criteria are rejected.
- **Quick wins are at the top.** Users see traction first.
- **Dependencies are topologically sorted.** No forward references.
- **Rollback precedes destructive migration.** No exceptions.
- **Research steps precede dependent execution.** No execution on untaken assumptions.
- **Guardrails are distributed throughout, not batched at the end.**

## Integration

- `docs/runtime/program-phases.md` — Phase 4 (synthesis) produces the roadmap
- `docs/runtime/artefact-contract.md` — `execution-roadmap.md` is the home
- `docs/runtime/output-profiles.md` — several profiles require a roadmap section
- `docs/governance/finding-schema.md` — findings feed into roadmap steps via `recommended_fix`
