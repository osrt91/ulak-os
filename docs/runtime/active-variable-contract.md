# Active Variable Contract

## Why this exists

Every serious run of the director operates on a bundle of runtime variables: what mode is active, what project state, which surfaces are in scope, what the user can edit, whether MCP is allowed, which branch we're on. Without a structured contract, these leak implicitly across phases and specialists disagree about what they're allowed to touch.

The active variable contract is the **YAML block the director writes at Phase 0** and pins in context through verdict. Every specialist reads from it. No specialist mutates it without the director's consent.

## The contract

At Phase 0, the director writes `reports/current/active-variables.yaml` (or the YAML block inside `runtime-manifest.md`) with the following fields:

```yaml
# ----- request context -----
REQUEST: "" # the user's literal ask
PROJECT_CONTEXT: "" # 1-3 sentences of what this project is
PROJECT_TYPE: "" # saas|mobile-app|marketplace|api|static-site|internal-tool|pack|...
INDUSTRY: "" # education|fintech|ecommerce|health|media|...
BUSINESS_MODEL: "" # subscription|one-time|ads|b2b-seat|freemium|...
PLATFORMS: "" # web|ios|android|flutter|desktop|cli|...
PRIMARY_GOAL: "" # one sentence, user's outcome
KNOWN_CONSTRAINTS: "" # timeline, budget, team, compliance
CURRENT_STACK: "" # languages, frameworks, databases, infra

# ----- surface map -----
ROUTES_AND_SCREENS: "" # summary or link to inventory.md
PUBLIC_URLS: "" # production URLs if any
CUSTOMER_SURFACES: "" # what end-users touch
ADMIN_SURFACES: "" # what operators/admins touch
API_SURFACES: "" # public, private, internal endpoints
STORE_SURFACES: "" # app store listings if mobile
SEO_SURFACES: "" # marketing pages, blog, landing
FILES_AND_FOLDERS: "" # key paths
KNOWN_RISKS: ""
KNOWN_BUGS: ""
DESIGN_REFERENCES: ""

# ----- output mode -----
OUTPUT_MODE: "markdown" # markdown | json | jira | figma | hybrid
EXECUTION_MODE: "analysis-only" # analysis-only | plan-only | controlled-editing | pack-generation | hybrid

# ----- permission boundaries -----
CAN_EDIT_FILES: false # may the director write to source?
CAN_RUN_TESTS: false # may it run the test suite?
CAN_USE_NETWORK: false # may it fetch from the web?
CAN_USE_MCP: false # may it call MCP servers?
CAN_TOUCH_PROD: false # hard safety — default false
NEEDS_APPROVAL_FOR_DESTRUCTIVE_ACTIONS: true

# ----- output location -----
REQUIRED_REPORT_PATH: "reports/current/"
TARGET_BRANCH: "" # if editing is allowed
MAX_PARALLEL_AGENTS: 6 # phase 2 parallel dispatch cap

# ----- router decision (filled by Phase 0) -----
ACTIVE_MODE: "" # see router-schema.md
PROJECT_STATE: "" # greenfield | brownfield | hybrid
INTERVENTION_MODE: "" # CREATE | REPAIR | EXTEND | REFACTOR | MIGRATE | RESCUE | REPACKAGE
OUTPUT_PROFILE: "" # see output-profiles.md
REQUIRED_PACKS: [] # sector packs activated (canonical name: required_sector_packs per runtime-constants.md)
REQUIRED_OVERLAYS: [] # overlays activated
BLOCKED_PATHS: [] # paths the director must not read/write
VALIDATION_DEPTH: "standard" # light | standard | deep

# ----- locale + output language (v2.2.0 addition — FIND-LOC-01) -----
OUTPUT_LANGUAGE: "tr" # tr | en | de |... — the language manager-verdict narrative + specialist artefacts use
RULE_PACKS_LOADED: [] # e.g. [typescript-nextjs, docker-compose, turkish-locale] — populated by Phase 0 toolchain-precheck
RULE_PACKS_PROJECT_OVERRIDES: [] # e.g. [python] — if.claude/rules/python.md exists, it overrides ulak-shipped python-fastapi.md for matching imperatives
MCP_AUTHORIZED_TOOLS: {} # per docs/governance/mcp-governance.md — justification + approved_at + scope per MCP server
```

## Default values

If the user does not specify:

- `CAN_EDIT_FILES: false` — the system is in analysis mode until told otherwise
- `CAN_TOUCH_PROD: false` — always false by default; requires explicit opt-in
- `NEEDS_APPROVAL_FOR_DESTRUCTIVE_ACTIONS: true` — irreversible actions always pause
- `VALIDATION_DEPTH: "standard"` — full phases run, but without exhaustive regression sweeps

## Mutation rules

- **The director owns the contract.** Only the director can write or update it.
- **Specialists read the contract.** They cannot mutate it. If a specialist needs a permission that isn't granted, it must return a `requested_permission` field and let the director decide.
- **The contract is pinned in context through verdict.** See context-budget.md for pin rules.
- **Mutations are logged.** Every update appends a line to `reports/current/active-variables.yaml` history section (or an `active-variables.history.md` sibling file) with timestamp and reason.

## Integration with safety

`CAN_TOUCH_PROD: false` is the final safety gate. Even if the user says "go ahead and fix it on prod", the director must:

1. Record the user's explicit request
2. Convert it into a proposed action
3. Require an explicit confirmation from the user that references the specific action
4. Only then flip the boundary for that action

This is how blast radius stays bounded.

## Integration with the manager-verdict

The final manager-verdict must reference the active variable contract and state which boundaries were reached or violated during the run. If `CAN_EDIT_FILES: false` was set but the director ended up proposing edits, that's fine — proposals are not edits. If it proposed edits AND the user confirmed AND the director wrote files, the verdict records the list of written files and their diffs.
