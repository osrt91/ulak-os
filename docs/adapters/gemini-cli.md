# Gemini CLI adapter

## Başlangıç
1. `/memory reload`
2. `/commands reload`
3. Gerekirse `/memory show` ile aktif context'in yüklendiğini doğrula.

## Kullanım modeli
- `GEMINI.md` proje bağlamını verir; core contract'ı `@`-import zinciriyle yükler.
- `.gemini/commands/*.toml` proje komutlarını sağlar.
- İstek tam program ise `/director komple` ile başlat — menü açma.

## Gemini CLI'da çalışan Ulak OS kapasite listesi

Toplam **24 komut** Gemini CLI adaptöründe native `.toml` olarak çalışır. Claude
adaptörüyle tam parity — `scripts/validate-vendor-parity.sh` her commit'te
gap'i reddeder.

### Kaynak-to-hedef sözleşmesi

- **Source of truth**: `.claude/commands/*.md` (YAML frontmatter + markdown body).
- **Hedef**: `.gemini/commands/*.toml` (TOML — `description` + triple-quoted `prompt`).
- **Sync motoru**: `scripts/sync-gemini-commands.sh` (idempotent; orjinal 7
  hand-authored TOML dosyasına dokunmaz).
- **CI guardrail**: `scripts/validate-vendor-parity.sh` — yeni bir `.claude/commands/*.md`
  eklenir ve sync yapılmazsa build kırılır.

Hand-authored 7 Gemini TOML (v2.1 ve öncesi, elle yazılmış):
`director`, `final-verdict`, `intake`, `market-scan`, `pack-gap-audit`,
`ulak-design-ref`, `ulak-intake`.

v3.0.x Gemini sync pass ile eklenen 18 komut (Claude `.md` kaynağından
auto-generate):
`frontend-war-room`, `triage-build`, `ulak-ask`, `ulak-audit-deep`,
`ulak-brainstorm`, `ulak-demo`, `ulak-explain`, `ulak-hello`, `ulak-locale`,
`ulak-mcp-discover`, `ulak-next-steps`, `ulak-packs`, `ulak-pattern-extract`,
`ulak-scaffold`, `ulak-search`, `ulak-start`, `ulak-subagent-dispatch`,
`ulak-test-driven`.

Ayrıca `war-room` Gemini-only alias'ı back-compat için tutulur
(canonical isim `frontend-war-room`).

### Komut tablosu

| Komut | Ne yapar |
|---|---|
| `/director komple` | Phase 0 → Phase 5 tam program protokolü |
| `/intake brownfield` | Sadece intake fazı |
| `/market-scan` | Live market research lane (Gemini-only) |
| `/frontend-war-room` | Frontend redesign modu (canonical) |
| `/pack-gap-audit` | Eksik command/skill/agent/hook raporu |
| `/triage-build` | Kırılan build'i stack'ine göre triaj eder |
| `/ulak-intake` | Ulak OS'a özgü intake artefaktı |
| `/ulak-design-ref` | Public marka tasarım referansı |
| `/final-verdict` | Mevcut artefaktları re-evaluate edip yeni signoff |
| `/ulak-ask` | Doğal dil intent → mevcut komut yönlendirici |
| `/ulak-audit-deep` | 14-dimension scorecard + A-F grade |
| `/ulak-brainstorm` | Kod yazmadan önce yapılandırılmış ideation |
| `/ulak-demo` | 3 örnek SaaS projesi tanıtır |
| `/ulak-explain` | Bir teknik terimi 5-alanlı şemada açıklar |
| `/ulak-hello` | 30 saniyelik onboarding tour |
| `/ulak-locale` | Ulak OS aktif locale'ini yönetir (TR/EN toggle) |
| `/ulak-mcp-discover` | Yeni MCP server adayları + governance raporu |
| `/ulak-next-steps` | Scaffold sonrası 8-10 somut adım runbook |
| `/ulak-packs` | Tüm Ulak OS kapasitelerini tek yerde listeler |
| `/ulak-pattern-extract` | Kaynak projeden pattern çıkarma |
| `/ulak-scaffold` | Full-stack SaaS scaffolder |
| `/ulak-search` | Ulak OS kapasite kataloğunda keyword araması |
| `/ulak-start` | 5 fazlı, 27 soruluk interaktif SaaS sihirbazı |
| `/ulak-subagent-dispatch` | N bağımsız subagent'ı paralel dispatch |
| `/ulak-test-driven` | TDD workflow (superpowers disiplin ile) |

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
