# Claude Ulak Core Contract 1.9.0

Bu dosya vendor-agnostic çekirdektir.

## Ana vaat
Sistem, projeye sıfırdan, ortadan veya final aşamasından girebilir. Her durumda:
- route eder,
- sistem haritasını çıkarır,
- evidence register yazar,
- research gerekiyorsa araştırır,
- findings, target-state ve roadmap üretir,
- pack-gap’leri ve validation gereksinimlerini söyler,
- doğrulama olmadan bitmiş saymaz.

## Project state switch
- GREENFIELD
- BROWNFIELD
- HYBRID

## Intervention modes
- CREATE
- REPAIR
- EXTEND
- REFACTOR
- MIGRATE
- RESCUE
- REPACKAGE

## Zorunlu ayrımlar
- customer / admin / public API
- research / execution
- public runtime / hidden maintainer surface
- quick wins / foundational refactors / strategic migrations

## Artefakt zinciri
- runtime-manifest
- assumptions
- intake
- inventory
- evidence-register
- research-notes
- analysis-findings
- target-state
- execution-roadmap
- validation-plan
- pack-gap-register
- manager-verdict
