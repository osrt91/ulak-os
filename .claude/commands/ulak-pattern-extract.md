---
name: ulak-pattern-extract
description: Extract a reusable pattern from a candidate source project and register it in the pattern-import-ledger with T1/T2 evidence. Produces a native Ulak OS rule-pack / sector-pack / anti-pattern entry that other projects can adopt via /director komple or /ulak-scaffold. Use when you have read a real project that exhibits a pattern worth propagating across the portfolio.
agent: autonomous-program-director
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# /ulak-pattern-extract — cross-project pattern absorption

## When to use

- You just read a real project and noticed a pattern (good or bad) that applies elsewhere
- You're aggregating patterns from 2+ projects into a canonical rule-pack
- You want to register a pattern-import-ledger entry so it audits as T1/T2 evidence
- You're normalizing a scaffold pattern for future use by other projects

## When NOT to use

- Single-project noise (pattern must be observable across ≥ 2 real codebases to warrant a rule-pack)
- Trivial snippets (function-level reuse, not pattern-level)
- Patterns that Ulak OS already catalogs (check `docs/runtime/rule-packs/` + `sector-packs.md` first)

## Dispatch protocol

1. **Read the source** — cartographer pass over the candidate project
2. **Identify the pattern** — which shape is observable; what does it solve; what does it prevent
3. **Validate cross-project** — find at least one other codebase (or abstract shape description) where the pattern applies
4. **Classify**:
   - Rule-pack (orthogonal technical constraint, e.g., `turkish-locale`)
   - Sector-pack (domain-specific bundle, e.g., `payment-integrated-saas`)
   - Anti-pattern (shape to flag + refuse, e.g., `AP-16 .env.local git-tracked`)
   - ADR (architectural decision with rationale)
5. **Draft the Ulak OS entry** — following the canonical shape for the chosen classification
6. **Register in pattern-import-ledger** — abstract-descriptor source + trust tier + extraction date
7. **Cross-reference** — add links in anti-patterns.md, rule-pack-governance.md, and the relevant sector pack

## Output artefacts

- `docs/governance/pattern-import-ledger.md` — new entry: `IL-NNN: <abstract-source> → <ulak-target>, trust T2, evidence <file:line refs>, extracted 2026-NN-NN`
- New file under `docs/runtime/rule-packs/<name>.md` OR new section in `docs/runtime/sector-packs.md` OR new entry in `docs/runtime/anti-patterns.md` OR new `docs/adr/ADR-NNN-<topic>.md`
- `reports/current/pattern-extraction-log.md` — per-run summary including candidate source + decision rationale

## Redaction discipline

The source project MUST be referred to via abstract descriptor only. Examples:
- ❌ "extracted from scanner-project.com"
- ✅ "extracted from a security scanner SaaS"
- ❌ "as seen in trend-platform.com's homepage builder"
- ✅ "as seen in a CMS-style section builder from a multi-locale e-commerce platform"

Real project names are operator-only information. Every rule-pack shipped publicly has T1/T2 evidence that does not leak portfolio identity.

## Integration

- `docs/governance/pattern-import-ledger.md` — the canonical ledger
- `docs/governance/rule-pack-governance.md` — rule-pack authoring contract
- `docs/runtime/anti-patterns.md` — AP catalog
- `docs/adr/` — ADR template for architectural decisions
- `/director komple` — reads the ledger during Phase 2 evidence pass

## Example

```
/ulak-pattern-extract source="multi-locale e-commerce with 11 locales" target="rule-pack/localization-ssot"
```

Produces:
1. Cartographer reads the candidate source
2. Extracts the SSOT dictionary pattern + RTL handling + Turkish `toLocaleLowerCase('tr')` quirks
3. Writes `docs/runtime/rule-packs/localization-ssot.md` with 10 enforceable rules
4. Registers in pattern-import-ledger with T1 evidence (file:line citations)
5. Cross-links from `sector-packs.md §payment-integrated-saas` (since payment surfaces trigger locale concerns)
