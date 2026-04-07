---
name: project-intake
description: intake, inventory, and evidence-gathering workflow for full audits, rescue programs, or when the user wants the system to read the whole project before acting.
context: fork
agent: cartographer
allowed-tools: Read Grep Glob Bash(find *) Bash(ls *) Bash(cat *) Bash(tree *)
---

# Project Intake

Use this custom skill pack when the project needs to be mapped before deeper work.

## Required outputs
- reports/current/runtime-manifest.md
- reports/current/assumptions.md
- reports/current/intake.md
- reports/current/inventory.md
- reports/current/evidence-register.md

## Rules
1. Split customer, admin, and public API surfaces.
2. Record missing evidence instead of guessing.
3. Start artefacts immediately when intent is clear.
