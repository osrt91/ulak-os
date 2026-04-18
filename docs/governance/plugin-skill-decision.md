# Plugin / Skill / Agent / Command / Rule Pack Decision

Use:

- **command** → repeated invocation (slash command, operator-triggered)
- **agent** → specialist reasoning (dispatched via Task, discipline-specific)
- **skill** → repeated workflow (multi-step procedure, trigger-based)
- **hook** → deterministic enforcement (runs automatically on event)
- **MCP** → external system / data / tool bridge (network or process boundary)
- **rule pack** → always-on imperative guardrail for a specific stack or risk surface (≤500 bytes body, Phase 0 auto-loaded; see `docs/governance/rule-pack-governance.md`)
- **plugin** → reusable distribution across projects (bundles the above units)

Do not bloat the main prompt when a smaller reusable unit is better.

## Picking between units

- "I want a short imperative that fires whenever TypeScript is detected" → **rule pack**
- "I want a multi-step workflow the agent can invoke by name" → **skill**
- "I want a discipline-specific reasoning pass over the repo" → **agent**
- "I want operators to run this by typing `/x`" → **command**
- "I want this to fire automatically on SessionStart / before Bash / after Edit" → **hook**
- "I need to talk to GitHub / Supabase / a DB" → **MCP**
- "I want to ship all of the above as one installable unit" → **plugin**

## Overlap protocol

If two units would deliver the same value, prefer the smaller one. Promote shared content upward (e.g. a rule repeated in 3 rule packs should become an anti-pattern entry; a skill repeated in 4 commands should become its own skill that commands reference).
