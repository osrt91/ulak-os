# Codex / Copilot adapter

## Neden ayrı dosya var?
Codex/Copilot tarafında güvenli ve taşınabilir yol; kök `AGENTS.md` ile repo davranışını yönlendirmek, gerekiyorsa `.github/copilot-instructions.md` ile ek repo talimatı vermektir. Codex ve GitHub Copilot CLI Claude Code'un `@`-import sözdizimini desteklemez, bu yüzden bağlam dosyalarını **reading order** halinde liste olarak sunarız.

## Önerilen kullanım akışı
1. Repo git altında olsun.
2. Önce read-only/suggest tarzı modda repo okunsun.
3. İlk istekte agent'a şu yönlendirmeyi ver:
   ```
   Read AGENTS.md, CLAUDE.md, prompts/core/ulak-os-core-contract-2.0.0.md,
   docs/adapters/codex-cli.md, and docs/adapters/universal-runtime-contract.md.
   Then execute the Phase 0 → Phase 5 protocol for: <görev>
   ```
4. Sonra görev tipi açık yazılsın:
   - greenfield / brownfield / rescue / refactor / release-readiness / localization

## v2.1 protokol özet
Codex/Copilot, Claude Code'un autonomous-program-director'ünün eşdeğerini doğrudan çalıştırmaz, ama aynı 8-phase artefakt zincirini takip etmek **zorundadır**:

| Phase | Üretilecek artefakt | Kabul kriteri |
|---|---|---|
| 0 — Environment lock | runtime-manifest.md, assumptions.md | router decision committed |
| 1 — Deep inventory | intake.md, inventory.md (file:line) | klasör dökümü kabul edilmez |
| 2 — Specialist evidence | evidence-register.md, deep-scan-report.md | birden çok uzman bakışı |
| 3 — Did-you-know | did-you-know.md | non-obvious findings zorunlu |
| 4 — Synthesis | analysis-findings.md, target-state.md, execution-roadmap.md, validation-plan.md, pack-gap-register.md | beşi de var |
| 5 — Manager verdict | manager-verdict.md, validation-result.yaml | signoff_status açık |

Codex'in tek-agent yapısı paralel specialist dispatch'i zor — bu yüzden Phase 2'yi sıralı uzman geçişi olarak yür: önce security, sonra infra, sonra design-system, vb. Her uzman geçişi için ayrı `reports/current/specialists/<role>.md` dosyası üret.

## Şemalar (her run için zorunlu)
- `docs/runtime/router.md` — 9-field router decision YAML
- `docs/runtime/output-profiles.md` — 7 profil (AUDIT / GREENFIELD_BUILDER / BROWNFIELD_INTERVENTION / LOCALIZATION_REPAIR / MARKET_ENTRY / PACK_GENERATION / RELEASE_READINESS)
- `docs/governance/finding-schema.md` — her finding için canonical YAML
- `docs/governance/evidence-trust-scoring.md` — T1-T7 tier zorunlu
- `docs/runtime/validation-result-schema.md` — Phase 5 signoff

## Güvenli mod önerisi
- İlk koşu: okuma + plan (analysis-only mode)
- İkinci koşu: küçük, kontrollü edit (controlled-editing mode)
- Üçüncü koşu: validation ve residual risk

## Not
Bu repo tek seferde büyülü dönüşüm vaat etmez; repo erişimi, doğru izinler ve validation komutları varsa güçlü sonuç üretir. Codex/Copilot'un gücü uzun bağlamı ve kod yazma odaklı kullanım iken Claude Code'un gücü paralel agent dispatch ve native multi-tool orkestrasyon. v2.1 protokolü ikisini de aynı verdict standardına bağlar.
