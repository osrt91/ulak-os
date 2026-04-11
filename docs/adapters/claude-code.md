# Claude Code adapter

## Önerilen kullanım
- Claude Code repo kökünde açılır.
- `CLAUDE.md` başlangıç belleğidir; core contract'ı `@`-import zinciriyle yükler.
- `.claude/commands/` içindeki komutlar slash komutu olarak çağrılır.
- `.claude/agents/` içindeki uzmanlar Phase 2'de paralel dispatch edilir.

## Başlangıç komutları
- `/director komple` — kanonik tam program (Phase 0 → Phase 5)
- `/intake brownfield audit` — sadece intake fazı, light bakış
- `/frontend-war-room` — frontend redesign moduna gir
- `/pack-gap-audit` — eksik command/skill/agent/hook raporu
- `/final-verdict` — mevcut artefaktları re-evaluate edip yeni signoff verir
- `/ulak-intake` — Ulak OS'a özgü intake
- `/ulak-design-ref` — public marka tasarım referansı

## v2.1 runtime davranışı
Director çağrıldığında autonomous-program-director subagent'ı şu protokolü zorunlu kılar:

| Phase | Ne üretir | Gate |
|---|---|---|
| 0 — Environment lock | runtime-manifest.md, assumptions.md, active-variables.yaml | Router decision pinned |
| 1 — Deep inventory | intake.md, inventory.md (file:line citations) | Folder dump rejected |
| 2 — Parallel specialist evidence | evidence-register.md, deep-scan-report.md | Single-agent evidence rejected |
| 3 — Did-you-know (MANDATORY) | did-you-know.md | Empty/trivial rejected |
| 4 — Synthesis | analysis-findings.md, target-state.md, execution-roadmap.md, validation-plan.md, pack-gap-register.md | All five present |
| 5 — Final verdict | manager-verdict.md, validation-result.yaml | Phase status non-trivial |

## Şemalar (her run'da uygulanır)
- `docs/runtime/router.md` — 9-field router decision YAML
- `docs/runtime/output-profiles.md` — 7 output profile (AUDIT / GREENFIELD_BUILDER / BROWNFIELD_INTERVENTION / LOCALIZATION_REPAIR / MARKET_ENTRY / PACK_GENERATION / RELEASE_READINESS)
- `docs/governance/finding-schema.md` — her finding için canonical YAML
- `docs/governance/evidence-trust-scoring.md` — T1-T7 trust tier her finding'de zorunlu
- `docs/runtime/active-variable-contract.md` — Phase 0 pinned runtime state
- `docs/runtime/validation-result-schema.md` — Phase 5 yapılandırılmış signoff

## Beklenen davranış
- intent netse menü açma; Phase 0'dan Phase 5'e kadar tek pass yürüt
- gerekli subagent'ları Phase 2'de **paralel** dispatch et (tek mesajda çoklu Task call)
- `reports/current/` altında her phase için artefakt yaz
- did-you-know'ı atlama — non-obvious findings layer zorunlu
- gerekiyorsa skill/command/agent gap'lerini `pack-gap-register.md`'de raporla
- validation eksikse `signoff_status: blocked` ver, `ready` deme
