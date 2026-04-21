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

### 2.0.0 — CLI Console + Memory + Vendor Adapters (2026-04-09)

Introduced the `ulak` CLI wrapper, SQLite + FTS5 project memory, and the vendor adapter abstraction (subprocess-based dispatch to Claude Code / Codex / Gemini CLI). Pack versioning and pack-update flow also shipped.

### 2.1.0 — V9 Runtime Discipline Integration (2026-04-11)

Detailed above. The operational discipline from internal V7 + V9 lineage.

### 2.1.1 — 2.1.4: Discipline polish + CI hardening

- **2.1.1** (2026-04-14) — rule-collision matrix, plugin-vs-skill decision framework, memory hygiene policy
- **2.1.2** (2026-04-15) — artefact write authorization surface-split, expanded intake protocol
- **2.1.3** (2026-04-18) — cross-project pattern absorption pass (39 patterns absorbed from a production candidate project)
- **2.1.4** (2026-04-20) — CI hardening: gitleaks baseline, dependabot, schema conformance upgrade, vendor-parity enforcement, eval runner warn-only ship

### 2.2.0 — 2.2.3: Multi-project pattern absorption + scaffolder infrastructure

- **2.2.0** — 5 new sector packs (admin-cms-hardening, ai-relay-cost-control, telegram-bot, member-gated-community-platform, multi-app-nextjs-expo-monorepo), 4 new rule packs (localization-ssot, turkish-locale, llm-streaming-context-aware, react-native-expo), 2 new runtime rules (webhook-ci-deploy-pattern, interactive-map-privacy), 7 new anti-patterns (AP-10..AP-16)
- **2.2.1** (2026-04-20) — Resend key leakage post-mortem + redaction discipline adoption
- **2.2.2** (2026-04-20) — SaaS scaffolder introduction: `/ulak-scaffold` command + `saas-scaffolder` skill + sector pack + seed templates
- **2.2.3** (2026-04-20) — scaffolder templates complete (middleware, auth helper, RLS migrations, CI, deploy, VPS hardening, preflight) + awesome-design-md integration (59 brand design-system references)

### 2.3.0 — Plugin packaging + full scaffolder + ADRs (2026-04-20)

- `.claude-plugin/plugin.json` + `.claude-plugin/README.md` — Claude Code marketplace manifest
- 12 additional scaffolder templates (tsconfig, next.config, tailwind, layout, landing, supabase clients, tests, settings) — total 27
- 5 ADRs covering rule packs, Phase 5 terminal, product vs runtime surface split, pattern import ledger, SaaS scaffolder
- 3 thin agents expanded to full format (cartographer, architecture-lead, infra-release-sre)

### 2.4.0 — Public-launch baseline (2026-04-21, Phase 3.0-A)

First of five sub-releases in the v3.0 public-launch arc. Flipped license from `UNLICENSED` to MIT across three manifests. Rewrote root README bilingually (TR primary + EN parity) for a foreign-audience five-minute test. Added CONTRIBUTING, CODE_OF_CONDUCT (Contributor Covenant v2.1), four GitHub templates (bug/feature/pattern/PR). Second project-name redaction pass removed 3658 residual occurrences across 90 files. Untracked `reports/sessions/` (operator-only session notes) and added to .gitignore.

### 2.4.1+ (never shipped as independent tags)

During the 2.4.0 → public-GA window, content for Phases 3.0-B, 3.0-C, and 3.0-D was written against the `main` branch without intermediate tags:

- **3.0-B content** — 5 mermaid architecture diagrams + 5 abstract showcase walkthroughs + video script
- **3.0-C content** — 8 thin specialist agent expansions (backend-api-architect, data-database-governor, qa-validation-commander, red-team-challenger, design-system-architect, frontend-ios-flutter-director, prompt-skill-plugin-governor, security-hardening-lead polish) + plugin marketplace submission prep (CATEGORIES, RATIONALE, screenshots placeholder)
- **3.0-D content** — POSIX + PowerShell installers (`scripts/install.sh`, `scripts/install.ps1`), `bin/ulak` wrapper, 4 runbooks (first-hour, upgrading-from-v2, install-methods, troubleshooting), `docs/FAQ.md`
- **3.0-E content** — awesome-claude-code PR draft + 5-agent final-test pass + TR/EN user manual

These never tagged as `2.4.1 / 2.5.0 / 2.5.1` because the full bundle was collapsed into the `1.0.0 (public GA)` release below.

## Public-GA release line (Ulak OS)

### 1.0.0 (public GA) — 2026-04-21

The project's first **general-availability** release for a public, foreign-developer audience. Prior public tags (1.0.0 / 2.0.0 / 2.1.x / 2.2.x / 2.3.0 / 2.4.0) were accessible on GitHub but were operator-internal in practice: repository was `UNLICENSED` until 2.4.0, documentation was Turkish-primary and operator-jargon-heavy, and public docs contained redacted portfolio names and session reports. 1.0.0 (public GA) is the first release where:

- License is MIT across every package manifest
- README is bilingual (TR + EN) and written for a stranger who clones the repo with five minutes
- Community files (CONTRIBUTING, CODE_OF_CONDUCT, issue/PR templates) are in place
- Installer scripts (POSIX + PowerShell) provide a one-liner install path
- Full 5-scene showcase documentation + architecture diagrams explain the system visually
- 8 specialist agents are expanded from 31-line stubs to production 80–110-line specs
- Plugin marketplace submission prep (CATEGORIES, RATIONALE) is complete
- Full TR + EN user manuals exist
- Final 5-agent adversarial pass verified the repo against QA, security, release-readiness, cartography, and customer-first perspectives

### Versioning collision note

The legacy `v1.0.0` tag at commit `39b88e9` (2026-04-07 brand-rename release) remains present on `origin` for historical reference. The public-GA release ships as a semantically equivalent `v1.0.0` in package manifests (`package.json`, `prompts/pack.json`, `.claude-plugin/plugin.json`), but uses a distinct annotated git tag to avoid rewriting the legacy pointer. The distinct tag is applied at the public-GA commit; consumers should pin to the annotated-tag commit, not the lightweight legacy `v1.0.0`.

The versioning reset from `2.4.0` → `1.0.0 (public GA)` is **intentional** and follows the same "fresh release under a new distribution context" pattern as the earlier 1.9.1 → 1.0.0 reset. It is not a regression in capability; it is a restart of the externally-facing version counter to signal "this is the first release an outsider should depend on."

## Future releases (post public-GA)

- **1.0.1 / 1.1.x** — patch and minor after-GA releases (screenshots, performance, additional sector packs)
- **2.0.0 (post-GA)** — the next major after public-GA. Expected content: src/ CLI rewrite, Firecrawl MCP integration, LightRAG memory upgrade, alternative stack templates (Remix, SvelteKit, FastAPI)

The internal `2.x` lineage above is **not** the same as the post-GA `2.0.0` that will eventually follow `1.0.0 (public GA)`. The internal `2.x` lineage belongs to the operator-internal history described above; the post-GA `2.0.0` will be the first major bump after the `1.0.0 (public GA)` baseline.
