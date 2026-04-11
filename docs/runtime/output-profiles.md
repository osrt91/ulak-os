# Output Profiles

## Why this exists

Not every job should produce the same report format. An audit needs executive summary + findings + risk register. A greenfield build needs product assumptions + first release slice + architecture baseline. A localization repair needs locale diff + fallback chain + Turkish normalization. Without profile-gated output, the director emits the same shapeless report every time and the user has to hunt for the relevant fields.

An **output profile** is a contract: given a task type, these are the required sections and fields. The director selects one profile at Phase 0 based on the router decision, and the final artefacts must conform to it.

## Profile selection (Phase 0, by the router)

| Router `artefact_program` × `active_mode` | Profile |
|---|---|
| Full + audit | `AUDIT_PROFILE` |
| Full + creation (greenfield) | `GREENFIELD_BUILDER_PROFILE` |
| Full + intervention (brownfield) | `BROWNFIELD_INTERVENTION_PROFILE` |
| Full + localization work | `LOCALIZATION_REPAIR_PROFILE` |
| Full + market entry | `MARKET_ENTRY_PROFILE` |
| Full + pack generation | `PACK_GENERATION_PROFILE` |
| Full + release-readiness | `RELEASE_READINESS_PROFILE` |

A task may qualify for more than one profile. The router picks the primary; additional profiles are loaded as overlays.

## The seven profiles

### 1. AUDIT_PROFILE

Required sections in the final output:

- Executive summary (3-5 bullets)
- Scope (what was and wasn't inspected)
- Inventory (deep, file+line — see artefact-contract.md)
- Findings by severity (Critical → Low, using finding-schema.md)
- Risk register
- Target state
- Validation plan
- Quick wins
- Roadmap
- Residual risks

### 2. GREENFIELD_BUILDER_PROFILE

Required sections:

- Product assumptions
- First release slice (minimum shippable)
- Architecture baseline
- Design system baseline
- Folder topology
- Analytics plan
- Testing baseline
- Release plan

### 3. BROWNFIELD_INTERVENTION_PROFILE

Required sections:

- Current state (what exists)
- Blast radius (what could break)
- Safe intervention plan (ordered, flagged)
- Compatibility notes (old → new bridges)
- Rollback path
- Migration checkpoints
- Validation matrix
- Unchanged surfaces (explicitly listed as out of scope)

### 4. LOCALIZATION_REPAIR_PROFILE

Required sections:

- Current locales (what's shipping)
- Missing locales (what should ship)
- Broken strings (hardcoded, truncated, miscased)
- Turkish/Unicode issues (from turkish-normalization.md — ı/i/İ/I, display vs search vs slug)
- Fallback chain
- Search/index impact (what normalization does to queries)
- Release gate
- Validation checklist

### 5. MARKET_ENTRY_PROFILE

Required sections:

- Market summary
- Competitor tiers
- Language opportunity map
- Pricing map
- Trust / compliance needs
- Launch recommendations
- Risks

### 6. PACK_GENERATION_PROFILE

Required sections:

- Target repo topology
- `CLAUDE.md` plan
- Commands plan
- Agents plan
- Skills plan
- Hooks plan
- MCP plan
- Evals plan
- Report destinations

### 7. RELEASE_READINESS_PROFILE

Required sections:

- Release blockers
- Environment sanity
- Rollback readiness
- Crash / monitoring readiness
- Store / compliance (Apple App Store, Google Play, legal disclosures)
- Final checks
- Signoff matrix

## Rules

- **Pick the profile before writing any final output.** The Phase 4 synthesis step depends on it.
- **If a required section has no content, say so explicitly.** Do not silently omit. Write "no data — requires T2/T3 evidence" and flag in residual risks.
- **Do not mix profiles mid-output.** If the task has two aspects (e.g., brownfield + localization), use the primary profile and surface the second as a subsection or a linked report under the same reports/current/ directory.
- **A profile is a contract, not a template.** Use the section order, but write prose that fits the project.

## Integration with the artefact chain

Each profile maps to the standard artefact chain (`reports/current/*.md`) but with profile-specific field requirements. The director's Phase 4 (synthesis) must cross-check the output against the selected profile's required sections before Phase 5 can finalize the verdict.

## Integration with the manager-verdict

The manager-verdict explicitly names the active profile and lists which required sections were satisfied vs. which ended up empty (with reasons). If any required section is empty without a documented reason, the phase is marked `weak-evidence` and recorded as a residual risk.
