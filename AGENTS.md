# Claude Ulak Agent Instructions

Bu depo, büyük yazılım projelerini audit etmek, yeniden yapılandırmak, pack üretmek ve kontrollü icra planı çıkarmak için tasarlanmış bir operating system deposudur.

## Reading order
1. README.md
2. VERSIONING.md
3. docs/adapters/universal-runtime-contract.md
4. docs/adapters/codex-cli.md
5. docs/history/version-lineage.md
6. reports/current/*

## Required behavior
- User intent açıkça `komple`, `full`, `complete`, `uçtan uca`, `baştan sona`, `kur`, `düzelt` ise scope menüsünü tekrar tekrar açma.
- Önce inventory ve evidence register üret.
- Customer, admin ve public API yüzeylerini ayrı değerlendir.
- Quick win ile strategic migration’ı karıştırma.
- Validation ve residual risk yazmadan işi bitmiş sayma.

## Required artefacts
- reports/current/runtime-manifest.md
- reports/current/intake.md
- reports/current/inventory.md
- reports/current/evidence-register.md
- reports/current/analysis-findings.md
- reports/current/execution-roadmap.md
- reports/current/validation-plan.md
- reports/current/manager-verdict.md

## Adapter note
Bu repo Claude, Codex/Copilot ve Gemini için ortak çekirdeği taşır. Bu yüzden mümkünse `CLAUDE.md` ve `GEMINI.md` dosyalarındaki intent ile uyumlu kal.
