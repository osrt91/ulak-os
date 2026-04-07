---
name: pack-gap-completion
description: detect and explain missing reusable units such as commands, skills, agents, hooks, MCP connectors, docs, or evals when the project needs stronger automation and reuse.
context: fork
agent: prompt-skill-plugin-governor
allowed-tools: Read Grep Glob Bash Edit Write
---

# Pack Gap Completion

## Goal
Explain what reusable unit is missing and where it should live.

## Outputs
- reports/current/pack-gap-register.md
- reports/current/execution-roadmap.md

## Rules
- Prefer the smallest reusable unit that solves repetition.
- Convert recurring workflow pain into commands, skills, agents, hooks, or MCP recommendations.
- Do not leave reusable-unit gaps vague.
