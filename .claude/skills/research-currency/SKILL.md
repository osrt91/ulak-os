---
name: research-currency
description: research and currency check workflow for market signals, competitor positioning, language opportunities, and whether the proposed stack or UX is below the 2026 bar.
context: fork
agent: market-researcher
allowed-tools: Read Grep Glob Bash
---

# Research Currency

## Goal
Determine whether the current plan is supported by sufficiently strong evidence and whether it is current enough for a 2026-grade recommendation.

## Outputs
- reports/current/research-notes.md
- reports/current/analysis-findings.md

## Rules
- Distinguish strong evidence from weak signals.
- Say when evidence is too weak.
- Escalate stale architecture or below-bar UX clearly.
