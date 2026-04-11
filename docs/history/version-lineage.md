# Version lineage

## Internal release line (Claude Ulak series, 1.0.0–1.9.1)
- **1.0.0** — Master Core Baseline
- **1.1.0** — Frontend Modernization Baseline
- **1.2.0** — V6 Prompt Operating System
- **1.3.0** — V6.6 Execution Pack
- **1.4.0** — V7 Consolidation
- **1.5.0** — V8 Language / Market / Architecture Hardening
- **1.6.0** — V9 Adaptive Runtime Router
- **1.7.0** — V10.2 Hybrid Office Front OS
- **1.8.0** — V10.3 Autonomous Program Director
- **1.9.0** — Ulak OS Distribution Candidate
- **1.9.1** — Equalized Version Distribution (distribution parity patch)

## Internal codename map
- public 1.4.0 ↔ internal V7
- public 1.5.0 ↔ internal V8
- public 1.6.0 ↔ internal V9
- public 1.7.0 ↔ internal V10.2
- public 1.8.0 ↔ internal V10.3

## Reconstruction note
1.0.0–1.3.0 evresi doğrudan tek bundle halinde korunmadı; bu evre, mevcut sohbet kayıtları ve yüklenen metinlerden yeniden yapılandırıldı.

## Public release line (Ulak OS brand)

- **2.1.0** — V9 Runtime Discipline Integration (2026-04-11)
- **2.0.0** — CLI Console + Memory + Vendor Adapters (2026-04-09)
- **1.0.0** — Ulak OS First Stable Public Release (2026-04-07)

### 2.1.0 note

Ulak OS 2.1.0 integrates the operational discipline from the internal V7 and V9 lineage into the 2.0 distributed doc architecture. The core contract file stays at 2.0.0; the 2.1.0 delta is the runtime and governance layer that the contract now imports. Highlights:

- Evidence trust scoring (T1-T7) with required fields on every finding
- Canonical finding schema (YAML with severity, priority, trust, validation)
- Output profiles (7 profile types gating final output shape)
- Active variable contract (pinned Phase 0 runtime state)
- Validation result schema (structured Phase 7 output)
- Context budget manager with layered load / evict / pin rules
- Expanded router decision (9-field YAML) and program phases (8 phases with gates)
- Trust model (data vs instructions firewall) with injection defense patterns
- Surface split (public runtime / hidden core / maintainer)
- Operational motors: toolchain precheck, intake protocol, architecture currency, localization strategy, Turkish normalization, market research engine, sector packs
- Governance: hook governance, MCP governance, memory hygiene, prompt supply chain
- Eval harness groundwork: 5 expanded golden examples + core assertions catalog
- Director agent and `/director` command updated to enforce the new schemas

No breaking change to 2.0.0 behavior. The discipline layer is additive; existing runs still work but now produce deeper, schema-conformant output by default.

### Brand transition note

The "Claude Ulak" name was used internally during the 1.0.0–1.9.1 development series. With version 1.0.0 of the **Ulak OS** brand, the project enters its first stable public release phase. The core contract logic is unchanged from Claude Ulak 1.9.0/1.9.1; only the brand, packaging, CI infrastructure, and i18n layer differ. Pre-1.0.0 artifacts are documented above for historical reference; they are preserved in the original `claude-ulak_1.9.1_equalized_github_repo/` workspace backup and are not shipped with the public Ulak OS 1.0.0 release.

The version number reset (1.9.1 → 1.0.0) is **intentional** and follows semver semantics for a first stable major release under a new brand identity. It is not a regression or downgrade.
