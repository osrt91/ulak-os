# Ulak OS Agent Instructions

Bu depo, büyük yazılım projelerini audit etmek, yeniden yapılandırmak, pack üretmek ve kontrollü icra planı çıkarmak için tasarlanmış bir operating system deposudur.

## Reading order

### Çekirdek (her oturumda oku)
1. README.md
2. docs/adapters/universal-runtime-contract.md
3. docs/adapters/codex-cli.md
4. prompts/core/ulak-os-core-contract-2.0.0.md

### Runtime discipline (v2.1) — derin ve çakıldıkça oku
5. docs/runtime/router.md
6. docs/runtime/program-phases.md
7. docs/runtime/artefact-contract.md
8. docs/runtime/output-profiles.md
9. docs/runtime/context-budget.md
10. docs/runtime/active-variable-contract.md
11. docs/runtime/validation-result-schema.md
12. docs/runtime/universal-surface-inventory.md
13. docs/runtime/analysis-contexts.md
14. docs/runtime/roadmap-rule.md
15. docs/runtime/anti-patterns.md

### Operational motors (sadece ilgili görev geldiyse)
16. docs/runtime/toolchain-precheck.md
17. docs/runtime/intake-protocol.md
18. docs/runtime/architecture-currency.md
19. docs/runtime/localization-strategy.md
20. docs/runtime/turkish-normalization.md
21. docs/runtime/market-research-engine.md
22. docs/runtime/sector-packs.md

### Governance
23. docs/governance/evidence-trust-scoring.md
24. docs/governance/finding-schema.md
25. docs/governance/trust-model.md
26. docs/governance/surface-split.md
27. docs/governance/hook-governance.md
28. docs/governance/mcp-governance.md
29. docs/governance/memory-hygiene.md
30. docs/governance/prompt-supply-chain.md
31. docs/governance/plugin-skill-decision.md
32. docs/governance/rule-collision-matrix.md

### Run state
33. reports/current/* — geçerli oturumun artefaktları (varsa)

## Required behavior
- User intent açıkça `komple`, `full`, `complete`, `uçtan uca`, `baştan sona`, `kur`, `düzelt` ise scope menüsünü tekrar tekrar açma.
- Phase 0 → Phase 5 protokolünü tek pass'te yürüt; her phase için artefakt yaz.
- Inventory sığ olmasın — file:line citations ile derin tarama.
- Phase 2'de uygun tüm uzmanları tek mesajda paralel dispatch et.
- Phase 3 (did-you-know) zorunlu — non-obvious findings olmadan run done değil.
- Customer, admin ve public API yüzeylerini ayrı değerlendir.
- Quick win ile strategic migration'ı karıştırma.
- Her finding `docs/governance/finding-schema.md` formatında olsun ve `docs/governance/evidence-trust-scoring.md` tier'ı taşısın.
- Validation ve residual risk yazmadan işi bitmiş sayma.

## Required artefacts (full chain — v2.1.0 aligned)

### Phase 0 — Environment lock
- reports/current/runtime-manifest.md
- reports/current/assumptions.md

### Phase 1 — Deep inventory
- reports/current/intake.md
- reports/current/inventory.md

### Phase 2 — Parallel specialist evidence
- reports/current/evidence-register.md
- reports/current/deep-scan-report.md
- reports/current/research-notes.md (live research gerekirse)

### Phase 3 — Surprise layer (MANDATORY)
- reports/current/did-you-know.md

### Phase 4 — Synthesis
- reports/current/analysis-findings.md
- reports/current/target-state.md
- reports/current/execution-roadmap.md
- reports/current/validation-plan.md
- reports/current/pack-gap-register.md

### Phase 5 — Final verdict
- reports/current/manager-verdict.md
- reports/current/validation-result.yaml (or block inside manager-verdict.md)

## Adapter note
Bu repo Claude, Codex/Copilot ve Gemini için ortak çekirdeği taşır. Bu yüzden mümkünse `CLAUDE.md` ve `GEMINI.md` dosyalarındaki intent ile uyumlu kal.
