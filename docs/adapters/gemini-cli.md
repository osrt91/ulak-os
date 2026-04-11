# Gemini CLI adapter

## Başlangıç
1. `/memory reload`
2. `/commands reload`
3. Gerekirse `/memory show` ile aktif context'in yüklendiğini doğrula.

## Kullanım modeli
- `GEMINI.md` proje bağlamını verir; core contract'ı `@`-import zinciriyle yükler.
- `.gemini/commands/*.toml` proje komutlarını sağlar.
- İstek tam program ise `/director komple` ile başlat — menü açma.

## Uygun komutlar
| Komut | Ne yapar |
|---|---|
| `/director komple` | Phase 0 → Phase 5 tam program protokolü |
| `/intake brownfield` | Sadece intake fazı |
| `/market-scan` | Live market research lane |
| `/frontend:war-room` | Frontend redesign modu |
| `/pack-gap-audit` | Eksik command/skill/agent/hook raporu |
| `/ulak-intake` | Ulak OS'a özgü intake artefaktı |
| `/ulak-design-ref` | Public marka tasarım referansı |
| `/final-verdict` | Mevcut artefaktları re-evaluate edip yeni signoff |

## v2.1 davranışı (zorunlu)
Gemini'nin Claude Code'unkiyle eşdeğer protokolü çalıştırması için her komut prompt'u 8-phase artefakt zincirini referans alır:

| Phase | Üretir | Gate |
|---|---|---|
| 0 — Environment lock | runtime-manifest.md, assumptions.md | router decision committed |
| 1 — Deep inventory | intake.md, inventory.md | file:line citations |
| 2 — Specialist evidence | evidence-register.md, deep-scan-report.md | birden çok bakış |
| 3 — Did-you-know | did-you-know.md | non-obvious zorunlu |
| 4 — Synthesis | analysis-findings.md, target-state.md, execution-roadmap.md, validation-plan.md, pack-gap-register.md | beşi de |
| 5 — Manager verdict | manager-verdict.md, validation-result.yaml | signoff açık |

Gemini'nin tek-agent yapısı paralel specialist dispatch'i sınırlı — Phase 2'de uzmanları sıralı geçirip her geçiş için `reports/current/specialists/<role>.md` üret.

## Şemalar
- `docs/runtime/router.md` — 9-field router decision YAML
- `docs/runtime/output-profiles.md` — 7 output profile
- `docs/governance/finding-schema.md` — finding canonical YAML
- `docs/governance/evidence-trust-scoring.md` — T1-T7 tier zorunlu
- `docs/runtime/validation-result-schema.md` — Phase 5 signoff schema

## Beklenen çıktı
Gemini de aynı artefakt zincirini izlemeli, did-you-know layer'ı atlamamalı ve validation olmadan done dememeli. Phase 5 manager-verdict'i `signoff_status: blocked | conditional | ready` net olarak emit etmeli.
