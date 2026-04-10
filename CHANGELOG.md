# Changelog

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
