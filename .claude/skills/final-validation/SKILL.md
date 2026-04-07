---
name: final-validation
description: final validation workflow for release-readiness, residual risk classification, and single-verdict closure after the main program work is done.
context: fork
agent: qa-validation-commander
allowed-tools: Read Grep Glob Bash
---

# Final Validation

## Goal
Prevent weak done-claims and require a real validation and verdict stage.

## Outputs
- reports/current/validation-plan.md
- reports/current/manager-verdict.md

## Rules
- No done-claim without a validation plan.
- Record residual risks explicitly.
- Use the verdict scale from the master prompt.
