# Changelog

## [Unreleased] — v2.1.2 docs prep continued — FP-01 artefact write authorization fix

### Fix for FP-01 — Subagent Write tool blocked mid-phase

The oguzhansert.dev Sprint 0+1 session (2026-04-11) identified FP-01 as the top priority harness bug: 8 of 13 Phase 2 specialists and 1 of 9 Phase 4 artefacts could not write their `.md` deliverables to disk. They returned content inline and the orchestrator had to re-persist them. The root cause is **not a hook, skill, or settings rule** — it is the default Claude Code system prompt rule against creating planning/decision/analysis documents. The fix must be at the **prompt level**, not the tool level.

#### New governance doc

- **`docs/governance/artefact-write-authorization.md`** — formal override contract for the director protocol. Explains the collision between the default system prompt and the director protocol's artefact chain. Lists authorized write targets per phase (Phase 0 → Phase 5 + profile-specific artefacts). Propagation rule for specialist dispatch (director includes override block verbatim in every specialist brief). What the override does NOT permit (no new README.md, no scratch files, no bypass of permission boundaries). Detection and enforcement protocol (orchestrator-level diff of expected vs actual `reports/current/` contents).

#### Director agent update

- **`.claude/agents/autonomous-program-director.md`** — prominent "Artefact Write Authorization (OVERRIDES DEFAULT SYSTEM PROMPT)" section added at the top (right after the intro, before "Hard rule: depth before verdict"). Includes the propagation rule telling the director to include the override verbatim in every specialist dispatch prompt.

#### Specialist agent updates (19 files)

Each of the 19 specialist agent files gets a short "Artefact Write Authorization" section after its existing "Rules:" block, telling the specialist:
- The default rule does not apply to director-protocol artefacts under `reports/current/**`
- Write target for the specialist dispatch (`reports/current/specialists/<role>.md`)
- Pointer to the full governance doc

Files updated:
- architecture-lead, backend-api-architect, cartographer, data-database-governor,
- design-system-architect, educational-ux-specialist, frontend-ios-flutter-director,
- infra-release-sre, localization-i18n-lead, market-researcher,
- privacy-compliance-counsel, product-business-strategist, prompt-skill-plugin-governor,
- qa-validation-commander, red-team-challenger, release-readiness-auditor,
- security-hardening-lead, seo-aso-growth-strategist, support-ops-orchestrator

#### Command + core contract + CLAUDE.md reinforcement

- **`.claude/commands/director.md`** — adds an "Artefact Write Authorization (OVERRIDES DEFAULT)" section before the artefact chain listing, plus instruction to include the override in specialist dispatches.
- **`prompts/core/ulak-os-core-contract-2.0.0.md`** — new `@docs/governance/artefact-write-authorization.md` @import added to the Governance layer.
- **`CLAUDE.md`** — new runtime default line referencing the artefact write authorization override.

#### Why prompt-level, not hook-level

A Claude Code hook can block or allow tool calls, but it cannot FORCE a tool call the model decided not to make. The default rule causes the model to decline Write and return inline instead; the Write call is never attempted, so no hook fires. The fix has to be at the prompt level — telling the model that the rule does not apply in this context — not at the tool level.

### Patterns from the scanner-project.com session (2026-04-11)

A second session report came in from scanner-project.com — a security/compliance scanner with 78 HTTP routes, 32 Docker services, 198 pytest + 57 vitest, 4-persona audit producing 92 findings including 4 KATASTROFİK security blockers (SEC-B1 self-escalation to admin, SEC-B2 unauthenticated payment callback, SEC-B3 iyzico webhook signature bypass, SEC-B4 unauth `/config/tools`). Two new patterns were observed and absorbed:

- **`docs/runtime/handoff-plan-contract.md`** — new artefact type. `ulak-handoff-plan.md` is a director-produced file designed as the explicit entry point for a FUTURE session. Different from manager-verdict: manager-verdict closes the current session, handoff-plan opens the next. Conditional-mandatory when verdict is blocked/conditional and more work remains. 13 required sections including exec summary, context files to read, blockers with deadlines, workstream breakdown (business-layer grouping), phase skip recommendations, effort estimate, exact resume command.

- **`docs/runtime/persona-dispatch-pattern.md`** — alternative to discipline-based specialist dispatch. Audits the project as each user role (Customer, Admin, Bayi/Reseller, Security/Red-team, Support, Developer, Compliance) would experience it. Comparison table of specialist vs persona dispatch. When to use each. Dispatch-and-merge protocol with persona overlap as T-tier consensus boost. Output contract per persona (`findings/<persona>-persona.md`). Anti-patterns. The two dispatch modes can coexist — `dispatch=both` in the director command runs both.

### Director command argument surface

- **`.claude/commands/director.md`** — new "Arguments" section documenting:
  - Positional: `komple`, `brownfield audit`, etc.
  - Keyword: `mode=<CREATE|REPAIR|...>`, `entry=<file>`, `skip_phase_1=true`, `skip_phase_2=<comma-list>`, `parallel_dispatch=<N>`, `dispatch=<specialist|persona|both>`, `validation_depth=<light|standard|deep>`, `profile=<AUDIT_PROFILE|...>`
  - Resume form example: `/director komple mode=RESCUE entry=reports/current/ulak-handoff-plan.md skip_phase_1=true parallel_dispatch=9`

### Core contract update (scanner-project patterns)

- **`prompts/core/ulak-os-core-contract-2.0.0.md`** — two new @imports for the handoff-plan and persona-dispatch contracts in the Runtime rules layer.

### What's still NOT in this patch

- **Release tag** — still `[Unreleased]`. FP-01 fix + v2.1.2 contract prep + scanner-project patterns land together in the next tagged release.
- **PG-01 parallel-dispatch-planner skill** — deferred.
- **PG-04 migration-dry-runner skill** — deferred.
- **7 persona agent files** — `.claude/agents/customer-persona.md`, `admin-persona.md`, `bayi-persona.md`, `security-redteam.md`, `support-persona.md`, `developer-persona.md`, `compliance-persona.md` — not yet written. The contract is documented; the agents need their own prompts.
- **Director command argument parser** — the arguments are documented but the director agent's prompt does not yet parse them explicitly. Current runs ignore `mode=` etc. and infer from positional intent.
- **v1.x stale reference cleanup** — still ~10 stale v1.0.0/v1.1+ references in `docs/skills-integration/` and `docs/ecosystem/`. Tracked in earlier audit notes.

## [Unreleased — earlier] — v2.1.2 docs prep (v2.2 runtime contract drafts)

### Runtime contract additions from the oguzhansert.dev Sprint 0+1 session (2026-04-11)

The 7-file session report under `reports/sessions/2026-04-11-oguzhansert-dev-sprint-0-1/` identified 10 friction points and 15 pack-gap proposals from a real 1h 31m + sprint execution run. This patch addresses the contract-level findings (UOI-01, UOI-02, UOI-04, UOI-11) without shipping the harness hook (PG-03 still pending — needs shell/JS implementation, deferred).

#### New runtime contracts

- **`docs/runtime/waves-pattern.md`** — formalizes the "parallel within a Wave, serial between Waves" execution pattern the session improvised. Covers dependency grouping, pre-dispatch conflict map, validation gate between Waves, sub-waves for partial parallelism, reference example from oguzhansert.dev Sprint 1 (9+2+1+VPS agents, zero file conflicts), anti-patterns.

- **`docs/runtime/live-probe-contract.md`** — formalizes Phase 4.5 as conditional-mandatory when `validation-plan.md §6` has ≥1 probe, or any Critical finding depends on T2/T3 claims, or the roadmap contains destructive remote actions. Read-only-by-default rules, timeouts, credential handling, output artefact (`live-probe-results.md`), T-tier promotion rules, new findings layer (NF-* in did-you-know), gate enforcement. References the LP-07 JWT reuse probe and LP-09 /opt/oguzhansert staleness probe from the session as pivot examples.

- **`docs/runtime/dual-path-validation.md`** — formalizes the dual-path non-obvious findings pattern the operator improvised (manual did-you-know in parallel with director Phase 3, then merge). Path A (director) + Path B (independent reviewer) with a merge step. Consensus promotes T2/T3 → T1. Contradictions become probe candidates. Lens diversity guidance for parallel Path B subagents. Anti-patterns against same-prompt parallel, pre-merge contamination, T6/T7 promotion abuse.

#### Core contract update

- **`prompts/core/ulak-os-core-contract-2.0.0.md`** — three new @imports added to the Runtime rules layer (waves-pattern, live-probe-contract, dual-path-validation). Artefakt zinciri expanded to include `live-probe-results` as conditional-mandatory Phase 4.5, and notes that `execution-roadmap` is executed via Waves pattern and `did-you-know` can be optionally enhanced via dual-path validation.

#### Program phases update

- **`docs/runtime/program-phases.md`** — new Phase 4.5 section with purpose, required-when conditions, director tasks, artefacts, phase gate. Phase 3 section gains a dual-path optional enhancement note. Phase 6 section updated to use the Waves pattern with per-Wave conflict maps and per-Wave validation gates.

#### Director agent update

- **`.claude/agents/autonomous-program-director.md`** — Phase 4 synthesis updated to require `depends_on` fields on roadmap items (for Waves grouping) and live probes in validation-plan §6 when T2/T3 evidence is blocking. New Phase 4.5 section added with the conditional-mandatory protocol. Rules section gains three new directives: Waves pattern for execution, Phase 4.5 conditional-mandatory gate, dual-path validation as optional Phase 3 enhancement.

### What's NOT in this patch

- **PG-03 — `director-artefact-write-exempt` hook** — deferred. Needs shell/JS implementation (.claude/hooks/). FP-01 (Write tool blocked mid-phase) remains unfixed until the hook lands. This patch documents the contracts that will be enforced once the hook exists.
- **Harness-level implementations** — all changes are markdown contract docs. The runtime harness (Claude Code hooks, pre-tool-use rules) still needs code changes to match the new contracts.
- **v2.1.2 release tag** — intentionally not tagged yet. This is `[Unreleased]` until PG-03 lands, at which point v2.1.2 or v2.2.0 will ship as a cohesive release.

### Why "Unreleased" instead of a tagged release

Per session report recommendation: "PG-01, PG-02, PG-03 as Critical (they fix the harness itself)". Shipping contract docs without the matching harness fix would announce the rule without the enforcement. The contract docs land first so the next director run can cite them; the hook lands next as v2.1.2 or v2.2.0.

## [2.1.1] — 2026-04-11

### Vendor parity + version-lineage cleanup

Brings Codex/Copilot and Gemini CLI vendor adapters to v2.1.0 parity with Claude Code, and removes the historical version-lineage leak from active runtime contexts.

#### Vendor parity (Claude == Codex == Gemini at v2.1)

- **GEMINI.md / GEMINI.en.md** — rewritten to mirror CLAUDE.md structure: imports core contract + universal-runtime-contract + gemini-cli adapter + governance docs (plugin-skill-decision, rule-collision-matrix). Added Project identity + Runtime defaults + Working rule blocks for symmetry. Gemini-specific reminders updated to reference Phase 0 → Phase 5 protocol.
- **AGENTS.md / AGENTS.en.md** — rewritten with categorized reading order covering Core (4 entries), Runtime discipline v2.1 (11 entries), Operational motors (7 entries), Governance (10 entries), Run state (1 entry). Required behavior section enforces Phase 0 → Phase 5 protocol, parallel specialist dispatch, did-you-know mandate, finding-schema conformance. Required artefacts list now organized by phase and includes deep-scan-report.md, did-you-know.md, validation-result.yaml.
- **`.github/copilot-instructions.md`** — updated to reference core contract v2.0.0 (which transitively imports v2.1 layer), Phase 0 → Phase 5 protocol, file:line citations, parallel dispatch, did-you-know mandate, finding-schema conformance.

#### Adapter docs (3 files)

- **`docs/adapters/claude-code.md`** — expanded from 19-line stub. Added Phase 0 → Phase 5 protocol table with gates, schemas enforced (router, output-profiles, finding-schema, evidence-trust-scoring, active-variable-contract, validation-result-schema), expected behavior with parallel dispatch.
- **`docs/adapters/codex-cli.md`** — expanded from 21-line stub. Added v2.1 protocol table, schemas list, sequential specialist guidance for Codex's tool model (Phase 2 sequential lanes since Codex cannot parallel-dispatch like Claude Code).
- **`docs/adapters/gemini-cli.md`** — expanded from 22-line stub. Added v2.1 protocol table, command table (8 commands matching .gemini/commands/), schemas list, sequential specialist guidance.

#### Gemini commands parity (.gemini/commands/, 5 updated + 3 new)

- **director.toml** — rewritten as full v2.1 protocol prompt. References router, program-phases, artefact-contract, output-profiles, finding-schema, evidence-trust-scoring. Hard rules: no scope menu, file:line inventory, multi-specialist Phase 2, did-you-know mandatory, signoff_status emit.
- **final-verdict.toml** — rewritten to re-read existing artefacts and produce fresh signoff per validation-result-schema.md. Hard rule: no `ready` with unresolved Critical findings.
- **intake.toml** — rewritten as Phase 0 + Phase 1 only (light pass). Listed all surface types to inventory with file:line requirement. Returns and asks before proceeding to full /director komple.
- **market-scan.toml** — rewritten with mandatory questions, T1-T6 source priority, full required output artefact list per market-research-engine.md.
- **frontend/war-room.toml** — rewritten with active specialists list, screen-audit/design-system/question-flow output structure, red-flag detection scan, currency labels.
- **NEW: pack-gap-audit.toml** — inspects operating pack for missing commands/agents/skills/hooks/MCP/docs/evals. Areas covered: command parity, specialist coverage vs 28 analysis contexts, hook governance, MCP gaps, doc gaps, eval gaps.
- **NEW: ulak-intake.toml** — Ulak-specific intake artefact with file intake summary, evidence map, conflict register, missing evidence list per intake-protocol.md.
- **NEW: ulak-design-ref.toml** — fetches public brand design reference (via awesome-design-md) and extracts patterns for frontend war room consumption with synthesis-not-cloning rule.

#### Version-lineage cleanup (the leak)

`docs/history/version-lineage.md` is hidden core content per `docs/governance/surface-split.md`. It was previously @-imported into 4 active loaders, leaking V6 / V7 / V8 / V9 / V10 / 1.x history into every session context. This release removes those imports:

- **CLAUDE.md** — removed `@docs/history/version-lineage.md`
- **CLAUDE.en.md** — same
- **GEMINI.md** — same (replaced as part of parity rewrite)
- **GEMINI.en.md** — same
- **AGENTS.md** — removed from reading order (replaced as part of parity rewrite)
- **AGENTS.en.md** — same
- **`.github/copilot-instructions.md`** — removed "Check version-lineage for public/internal version mapping" line

The file remains in `docs/history/` for maintainer reference. It is no longer auto-loaded into any active runtime context.

### Not changed

- Core contract filename stays `ulak-os-core-contract-2.0.0.md`. The 2.1.x line continues to be additive parity work.
- v2.1.0 director hardening, runtime discipline layer, and eval harness groundwork unchanged.
- No breaking changes to v2.1.0 runs.

## [2.1.0] — 2026-04-11

### Added — V9 Runtime Discipline Integration

Operational discipline from the internal V7 and V9 lineage, integrated into the 2.0 distributed doc architecture. The core contract file stays at 2.0.0; the delta is the runtime and governance layer the contract now imports.

#### Runtime discipline (docs/runtime/)
- `context-budget.md` — layered context model (1 core → 7 sector packs), eviction rules, pin rules, compression stages
- `output-profiles.md` — seven output profiles (AUDIT, GREENFIELD_BUILDER, BROWNFIELD_INTERVENTION, LOCALIZATION_REPAIR, MARKET_ENTRY, PACK_GENERATION, RELEASE_READINESS) with required sections
- `active-variable-contract.md` — Phase 0 YAML contract with request context, surface map, permission boundaries, output location
- `validation-result-schema.md` — Phase 7 YAML with engineering, test, surface gates and signoff status rules
- `toolchain-precheck.md` — tool detection schema (required / conditional / optional / not-needed / not-recommended)
- `intake-protocol.md` — 4-step protocol for user-provided material (file intake, evidence map, conflict register, missing evidence)
- `architecture-currency.md` — question stack and labels (CURRENT_RECOMMENDED, OUTDATED_AVOID, etc.) for architectural recommendations
- `localization-strategy.md` — 5-phase motor for locale work, ADD_NOW / ADD_NEXT_WAVE labels
- `turkish-normalization.md` — Turkish character handling, ı/i/İ/I case pair rules, display vs search vs slug three-layer split
- `market-research-engine.md` — when live research is required, T1-T6 source priority, mandatory questions, required output artefacts
- `sector-packs.md` — core kernel vs optional sector overlays (education, saas, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop)
- `analysis-contexts.md` — 28 mandatory analysis contexts from product/business through prompt/runtime governance
- `anti-patterns.md` — categorized anti-pattern catalog (architectural, frontend, backend, security, data, infra, localization, prompt)
- `universal-surface-inventory.md` — canonical surface taxonomy with broken-surface map requirement for RESCUE
- `roadmap-rule.md` — 60+ step rule with step shape, tag vocabulary, ordering rules

#### Runtime expansions
- `router.md` expanded from 14-line decision list to full 9-field YAML router decision template with surface list and integration hooks
- `artefact-contract.md` expanded with depth requirement, mandatory chain mapped to phases, profile-specific optional artefacts
- `program-phases.md` expanded from 12 lines to 8-phase protocol with per-phase purpose, director tasks, artefacts written, phase gates

#### Governance (docs/governance/)
- `evidence-trust-scoring.md` — T1-T7 tiers, default ordering, required finding fields, integration hooks
- `finding-schema.md` — canonical YAML schema for all findings, severity vs priority split, merge rule
- `trust-model.md` — instructions vs data firewall, injection patterns, trust boundaries
- `surface-split.md` — public runtime / hidden core / maintainer surface separation
- `hook-governance.md` — when hooks are appropriate, security rules, review checklist
- `mcp-governance.md` — scope rules, approved vs high-risk surfaces, approval workflow
- `memory-hygiene.md` — layered memory model, hygiene rules, what goes where
- `prompt-supply-chain.md` — canonical source identification, version labels, release discipline

#### Eval harness groundwork (evals/)
- `golden/01_full_program_komple.md` through `05_frontend_rebuild.md` — expanded from 9-line stubs to full goldens with router YAML, active agent map, assertions, validation criteria, regression signals
- `assertions/core-assertions.md` — 14 assertion types with resolution values and regression signal catalog
- `assertions/README.md` — baseline assertion contract and pointer to core assertions

#### Director hardening
- `.claude/agents/autonomous-program-director.md` — references all new schemas, enforces trust tiers on every finding, profile selection at Phase 0, overlay discipline
- `.claude/commands/director.md` — lists enforced schemas and hard rules for the full protocol
- `prompts/core/ulak-os-core-contract-2.0.0.md` — imports the entire v2.1 runtime and governance layer via `@` imports

### Changed
- The `/director komple` command now runs deep inventory + parallel specialist dispatch + did-you-know by default. Shallow inventory (folder dump) and single-agent evidence are rejected.
- Router decision is now a 9-field YAML pinned for the whole run, not a 4-bullet mental note.
- Every finding must carry evidence_source, evidence_trust, completeness_risk, contradiction_status.

### Not changed
- Core contract filename stays `ulak-os-core-contract-2.0.0.md`. The 2.1.0 delta is the surrounding layer.
- Vendor adapters (Claude Code, Codex/Copilot, Gemini CLI) continue to work unchanged.
- CLI orchestration (`ulak` command) behavior unchanged.
- SQLite memory layer unchanged.
- No breaking changes to 2.0.0 runs.

## [2.0.0] — 2026-04-09

### Added — CLI Console + Memory + Vendor Adapters

- CLI orchestration layer: `ulak` command with 8 subcommands (init, run, status, validate, memory, config, upgrade, export)
- SQLite + FTS5 project memory layer (`.ulak/memory.db`) for cross-session learning extraction
- Vendor adapter abstraction (subprocess-based): Claude Code, Codex/Copilot, Gemini CLI auto-detection and routing
- Pack versioning and upgrade system (`src/pack/loader.ts`, `upgrader.ts`, `validator.ts`)
- TypeScript project infrastructure: `src/` source tree (18 files), `dist/` compiled output, `tsconfig.json`
- vitest test scaffold with unit and e2e configuration
- Platform command parity: Claude and Gemini now share 8 commands each
- `market-scan` command for Claude (was Gemini-only)
- 3 new Gemini commands: `pack-gap-audit`, `ulak-design-ref`, `ulak-intake`
- Core contract v2.0.0 with CLI orchestration, memory, and adapter sections
- 17 new EN translation files for docs/ subdirectories

### Changed

- Core contract reference: `ulak-os-core-contract-1.0.0.md` → `ulak-os-core-contract-2.0.0.md` in all adapter files
- Command count: 6 → 8 per vendor (full parity)
- `package-lock.json` now tracked for reproducible builds

## [1.0.0] — 2026-04-07

### Added — First Stable Public Release (Ulak OS brand)

- Vendor-neutral brand: Claude Ulak → **Ulak OS**
- Three-adapter parity (Claude Code, Codex/Copilot, Gemini CLI) sharing one core contract
- Cross-platform bootstrap scripts: 6 files (`init-{claude,codex,gemini}.{sh,ps1}`)
- CI validation infrastructure: schema validation, @import chain check, brand consistency, gitleaks secret scan
- Public skill integration: `docs/skills-integration/superpowers-mapping.md` + `/ulak-intake` PoC wrapper
- awesome-design-md integration: fetch script + `/ulak-design-ref` wrapper + integration doc (TR + EN)
- Multi-language: TR (primary) + EN (parallel) for README, adapters, core contract, samples, skill integration docs
- Sample artifacts: filled `intake`, `inventory`, `manager-verdict` in TR + EN
- Ecosystem related-work doc covering superpowers, anthropics/skills, gsd-2, awesome-design-md, akin-ozer/devops-skills-plugin (TR + EN)
- Structured ROADMAP with v1.1 candidates (plugin marketplace publication priority)
- LICENSE: MIT, Copyright (c) 2026 Oğuzhan Sert <info@oguzhansert.dev>

### Changed

- Core contract file: `claude-ulak-core-contract-1.9.0.md` → `ulak-os-core-contract-1.0.0.md`
- AGENTS.md required artefacts list aligned with core contract: 8 → 12 entries
- Version reset: 1.9.1 → 1.0.0 (intentional, per first stable public release semantics)

### Documentation

- README troubleshooting section
- README MCP environment variable documentation
- version-lineage.md brand transition note explaining the version reset

The pre-1.0.0 entries below document the internal "Claude Ulak" development series.

Tüm yayınlar **public release** sürümleriyle kaydedilir. İç kod adları parantez içinde tutulur.

## 1.0.0 — Equalized Version Distribution
- Tüm internal sürümler için `releases/<version>/` klasörleri oluşturuldu (sonradan Ulak OS 1.0.0 final cleanup'ta kaldırıldı; arşiv `claude-ulak_1.9.1_equalized_github_repo/` workspace backup'ında korunmaktadır).
- Kişisel arşiv ve GitHub repo tarafı aynı sürüm yapısına getirildi.
- Exact artifact olmayan erken sürümler `reconstructed` olarak işaretlendi.
- Bu sürüm çekirdeği değil, dağıtım düzenini günceller.


## 1.9.0 — Ulak OS Distribution Candidate
- GitHub’a koyulabilir açıklayıcı repo yapısı hazırlandı.
- Claude Code, Codex/Copilot ve Gemini CLI için ayrı adaptör dosyaları eklendi.
- Tek sürüm hattı `1.x` altında birleştirildi.
- İç sürümlerin arşivi `docs/archive/internal-releases/` altına taşındı.
- Dağıtım, portability ve release stratejisi dokümantasyonu eklendi.
- `.gemini/commands/` tabanlı Gemini özel komutları oluşturuldu.
- `.github/copilot-instructions.md` ve `AGENTS.md` ile Codex/Copilot uyumu iyileştirildi.

## 1.8.0 — Autonomous Program Director (internal: V10.3)
- Tek istekten tam program akışı başlatan yönetici ajan modeli kuruldu.
- Zorunlu artefakt zinciri standardize edildi.
- Tek dosyalı bootstrap üretildi.
- Hibrit ofis yapısı yönetici merkezli hale geldi.

## 1.7.0 — Hybrid Office Front OS (internal: V10.2)
- 20 kişilik hibrit ajan ofisi yaklaşımı tanımlandı.
- “Komple” intent geldiğinde tekrar menü açmama kuralı getirildi.
- Front savaş odası ve agentic long-prompt çalışma biçimi tanımlandı.

## 1.6.0 — Adaptive Runtime Router (internal: V9)
- Runtime router ve context budget manager eklendi.
- Hidden core / public surface / maintainer surface ayrımı getirildi.
- Intervention mode sistemi eklendi.

## 1.5.0 — Language / Market / Architecture Hardening (internal: V8)
- Türkçe karakter, Unicode ve locale-aware text normalization motoru eklendi.
- Market research ve architecture currency katmanları eklendi.
- Language coverage ve localization release gates güçlendirildi.

## 1.4.0 — V7 Consolidation
- Standard, optimized ve comparison bazlı ilk paketleme yapıldı.
- Önceki birikimler ilk kez üç dosyalı bundle’a dönüştürüldü.

## 1.3.0 — V6.6 Execution Pack
- Claude Code execution-first pack kurgusu kuruldu.
- Skills/plugins/subagents/hooks/MCP toplu düşüncesi eklendi.

## 1.2.0 — V6 Prompt Operating System
- Prompt, işletim sistemi olarak ele alınmaya başlandı.
- Coverage matrix, overlays, governance ve release/compliance katmanları büyüdü.

## 1.1.0 — Frontend Modernization Baseline
- Flutter/iOS premium redesign düşüncesi ayrı bir çekirdek haline geldi.
- Screen-by-screen frontend/UX derinliği oluşturuldu.

## 1.0.0 — Master Core Baseline
- Ana mimari, audit, refactor ve modernization omurgası kuruldu.
