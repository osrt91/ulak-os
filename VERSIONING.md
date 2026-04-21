# Versioning

## Ulak OS — Public release line

- **2.0.0** — CLI Console + Memory + Vendor Adapters (2026-04-09)
 - CLI orchestration layer (`ulak` binary with 8 subcommands)
 - SQLite + FTS5 project memory
 - Vendor adapter abstraction (subprocess-based)
 - Pack versioning and upgrade system
 - TypeScript project infrastructure
 - Full platform command parity and EN translation coverage

- **1.0.0** — First Stable Public Release (2026-04-07)
 - Brand transition Claude Ulak → Ulak OS
 - Three-vendor adapter parity
 - CI quality gates + cross-platform bootstrap scripts
 - Multi-language: TR + EN parallel
 - awesome-design-md integration + ecosystem related-work doc

The pre-1.0.0 internal "Claude Ulak" development series is documented below for historical reference.

Bu projede iki katmanlı sürümleme kullanılır:

## 1) Public release line
GitHub, README, changelog ve dağıtım paketlerinde görünen seri budur.

- 1.0.0 — Master Core Baseline
- 1.1.0 — Frontend Modernization Baseline
- 1.2.0 — V6 Prompt Operating System
- 1.3.0 — V6.6 Execution Pack
- 1.4.0 — V7 Consolidation
- 1.5.0 — V8 Language / Market / Architecture Hardening
- 1.6.0 — V9 Adaptive Runtime Router
- 1.7.0 — V10.2 Hybrid Office Front OS
- 1.8.0 — V10.3 Autonomous Program Director
- 1.9.0 — Ulak OS Distribution Candidate
- 1.9.1 — Equalized Version Distribution

## 2) Internal codename line
Tarihsel iz sürmek için korunur:
- V7
- V8
- V9
- V10.2
- V10.3

## Kural
- Kullanıcıya ve GitHub’a gösterilen sürüm = **public release line**
- Arşiv ve teknik soy ağacı = **internal codename line**
- 2.0.0 yayınlanmıştır. Yeni değişiklikler 2.x çizgisinde ilerletilir. Dağıtım ve arşiv eşitlemeleri mümkün olduğunda patch sürüm olarak çıkarılır.
