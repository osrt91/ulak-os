# Ulak OS ↔ Superpowers Skill Mapping

[Türkçe](superpowers-mapping.md) | English

This document maps the public [superpowers marketplace](https://github.com/obra/superpowers) skills onto Ulak OS's artefact chain. If superpowers is not installed, Ulak OS still runs with its own native skills — this mapping is an enrichment layer, not a hard dependency.

## Mapping table

| Ulak artefact | Equivalent superpowers skill | When |
|---|---|---|
| `intake` | `superpowers:brainstorming` | GREENFIELD, EXTEND modes |
| `evidence-register` | `superpowers:systematic-debugging` | REPAIR, RESCUE modes |
| `execution-roadmap` | `superpowers:writing-plans` | All modes |
| `execution` | `superpowers:executing-plans` + `superpowers:test-driven-development` | Execution phase |
| `validation-plan` | `superpowers:verification-before-completion` | All modes (mandatory) |
| `manager-verdict` | `superpowers:finishing-a-development-branch` | All modes (closure) |
| (parallel work) | `superpowers:dispatching-parallel-agents` | Independent task groups |
| (code review) | `superpowers:requesting-code-review` + `receiving-code-review` | Post-execution |

## How to use

### 1. As a mapping reference only (default)
If superpowers is installed, you can manually trigger the relevant skill while running Ulak OS commands. Example:

```
> /intake brownfield audit
[Ulak OS native intake flow runs]

> /skill superpowers:brainstorming
[Brainstorming skill performs additional intent exploration]
```

Ulak OS synthesizes both outputs into `reports/current/intake.md`.

### 2. Via wrapper commands (PoC: /ulak-intake)
Ulak OS v1.0.0 includes one proof-of-concept wrapper command: `/ulak-intake`. It auto-triggers superpowers if installed.

```
> /ulak-intake
[If superpowers:brainstorming is installed, calls it]
[Then writes reports/current/intake.md in Ulak intake format]
```

Other wrappers (`/ulak-roadmap`, `/ulak-validate`, `/ulak-evidence`, etc.) ship in v1.1+.

## License and dependency note

Superpowers content is NOT copied into this repo. This is only a mapping guide. For superpowers installation and licensing: https://github.com/obra/superpowers

## v1.1+ plan

- Remaining 5 wrapper commands (`/ulak-roadmap`, `/ulak-validate`, `/ulak-evidence`, `/ulak-pack-gap`, `/ulak-final`)
- Equivalent integration for Codex/Gemini (in their vendor-specific command formats)
- Graceful fallback tests when superpowers is absent
