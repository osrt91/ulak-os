# Vendor Capability Matrix

> Ulak OS'un desteklediği 4 vendor için runtime primitive + komut destek tablosu.
> Disk-gerçek: `scripts/validate-vendor-parity.sh` her CI'da bunu doğrular.

**Versiyon**: v2.3.0+ · **Son güncelleme**: 2026-04-21 · **Disk reconcile**: `bash scripts/validate-vendor-parity.sh`

---

## 1) Neden bu dosya var?

`docs/adapters/universal-runtime-contract.md` platform-agnostic davranış sözleşmesini tanımlar. Ancak "Ulak OS hangi vendor'da neyi yapabiliyor?" sorusunun **tek tablolu** cevabı yoktu. Bu dosya iki matrisi sabitliyor:

- **A — Primitive matrix**: her vendor'ın sağladığı runtime primitiveler (file ops, bash, grep, subagent dispatch, skill, MCP…).
- **B — Command → vendor support matrix**: Ulak OS'un 24 native slash komutunun hangi vendor'da nasıl çalıştığı.

Kaynak-of-truth:
- Claude Code komutları: `.claude/commands/*.md`
- Gemini CLI komutları: `.gemini/commands/*.toml`
- Codex/Copilot: bağımsız slash dir yok — `AGENTS.md` reading-order + natural-language dispatch (bkz. `docs/adapters/codex-cli.md`).
- Vendor parity exemptions: `.github/vendor-parity-exemptions.txt`

Lejant:
- `OK` = native destek, full-fidelity
- `PARTIAL` = çalışır ama kısıt var (NL trigger, serial workaround, limited fidelity)
- `MISSING` = desteklenmez / henüz ship edilmedi
- `N/A` = vendor'da bu primitive kavram olarak yok

---

## 2) A — Primitive matrix

Runtime primitiveler — Ulak OS'un bir vendor üzerinde çalışması için kullandığı alt yapı.

| Primitive                              | Claude Code            | Gemini CLI            | Codex CLI                     | Copilot Chat             |
|---------------------------------------|------------------------|-----------------------|-------------------------------|--------------------------|
| Slash command dispatch                | OK (.md + frontmatter) | OK (.toml)            | MISSING                       | MISSING                  |
| Natural-language routing              | OK (via Skill tool)    | PARTIAL (limited)     | OK (reading-order + prompt)   | OK (instructions file)   |
| File Read                             | OK                     | OK                    | OK                            | OK                       |
| File Write                            | OK                     | OK                    | OK                            | PARTIAL (VS Code apply)  |
| File Edit (diff apply)                | OK                     | OK                    | OK                            | OK                       |
| Bash / shell execute                  | OK                     | PARTIAL               | OK                            | PARTIAL (terminal suggest) |
| Grep (ripgrep content search)         | OK                     | OK                    | OK                            | OK (@workspace)          |
| Glob (file pattern search)            | OK                     | OK                    | OK                            | OK                       |
| Subagent parallel dispatch            | OK                     | MISSING               | MISSING (serial workaround)   | MISSING (serial)         |
| `@`-import syntax (context chaining)  | OK                     | MISSING               | MISSING                       | MISSING                  |
| Skill invocation (named capability)   | OK (Skills)            | PARTIAL               | MISSING                       | MISSING                  |
| MCP server support                    | OK                     | OK                    | OK (via ENV)                  | MISSING                  |
| Multi-turn session memory             | OK (CLAUDE.md)         | OK (GEMINI.md)        | OK (AGENTS.md)                | PARTIAL (chat scope)     |
| Hooks (PreToolUse / PostToolUse etc.) | OK                     | MISSING               | MISSING                       | MISSING                  |
| Settings-level permissions            | OK (settings.json)     | PARTIAL               | MISSING                       | MISSING                  |

### Kritik primitive kategorileri

**Temel (tüm vendor zorunlu, eksikse Ulak OS çalışmaz):**
- File Read + Grep + Glob
- File Write / Edit
- Multi-turn session memory

**Zenginleştirici (eksikse NL fallback yeterli):**
- Slash command dispatch → doğal dil yönlendirme yeterli
- Subagent parallel dispatch → serial workaround yeterli (yavaş)
- `@`-import syntax → reading-order listesi yeterli
- Skill invocation → inline protokol metni yeterli

**Kritik eksik (vendor "tam desteklenmez" statüsü alır):**
- Bash/shell execute yoksa → validator'lar (`validate-*.sh`) koşmaz
- File Write yoksa → artefakt zinciri diske yazılamaz
- MCP yoksa → design-ref, github entegrasyonu sınırlı

---

## 3) B — Command → vendor support matrix

24 Ulak OS native komutu + 2 Gemini-only (`market-scan`, `frontend/war-room` alias). Disk kaynağı `.claude/commands/*.md` ve `.gemini/commands/*.toml`.

**Not**: Codex CLI ve Copilot Chat'te slash komutu primitive'i yok — her komut **natural-language trigger** ile çağrılır (ör. "run the director phase 0→5 protocol on this repo"). Native dispatch MISSING ama davranış reproducible.

### B.1 — Komut → vendor destek tablosu

| Komut / Command            | Claude Code | Gemini CLI | Codex CLI              | Copilot Chat           | Gerekçe / Rationale                                                      |
|----------------------------|-------------|------------|------------------------|------------------------|--------------------------------------------------------------------------|
| `/director`                | OK          | OK         | PARTIAL (NL + serial)  | PARTIAL (NL + serial)  | Parallel specialist dispatch Claude'a özgü; diğerlerinde seri geçiş     |
| `/intake`                  | OK          | OK         | PARTIAL (NL)           | PARTIAL (NL)           | Read-heavy; NL trigger yeterli                                           |
| `/frontend-war-room`       | OK          | OK         | PARTIAL (NL)           | PARTIAL (NL)           | Gemini'de `frontend/war-room.toml` namespaced alias da mevcut           |
| `/pack-gap-audit`          | OK          | OK         | PARTIAL (NL)           | PARTIAL (NL)           | Read-only audit; NL yeterli                                              |
| `/final-verdict`           | OK          | OK         | PARTIAL (NL)           | PARTIAL (NL)           | Artefakt reconcile; NL + File Read yeterli                               |
| `/triage-build`            | OK          | OK         | PARTIAL (NL + Bash)    | PARTIAL (NL + terminal)| Bash execute gerektirir; Copilot terminal-suggest fallback               |
| `/ulak-ask`                | OK          | OK         | PARTIAL (NL)           | PARTIAL (NL)           | NL zaten primary surface; vendor'a bağlı değil                           |
| `/ulak-start`              | OK          | OK         | PARTIAL (NL Q&A)       | PARTIAL (NL Q&A)       | 27-soru wizard; interactive Q&A vendor-agnostic                          |
| `/ulak-scaffold`           | OK          | OK         | PARTIAL (NL + Write)   | PARTIAL (NL + apply)   | File write-heavy; Copilot'ta apply-action fallback                       |
| `/ulak-next-steps`         | OK          | OK         | OK (NL map inline)     | OK (NL map inline)     | Inline render; disk write yok                                             |
| `/ulak-hello`              | OK          | OK         | OK (NL map inline)     | OK (NL map inline)     | 30-saniye tour; inline                                                   |
| `/ulak-explain`            | OK          | OK         | OK (NL lookup)         | OK (NL lookup)         | Glossary lookup; Read + inline render                                    |
| `/ulak-demo`               | OK          | OK         | OK (NL + Read)         | OK (NL + Read)         | Template count + inline; Read + Bash(find)                               |
| `/ulak-packs`              | OK          | OK         | OK (NL inline dump)    | OK (NL inline dump)    | Inline catalog dump                                                      |
| `/ulak-search`             | OK          | OK         | PARTIAL (NL + Grep)    | PARTIAL (NL + Grep)    | Keyword search on catalog                                                |
| `/ulak-locale`             | OK          | OK         | PARTIAL (NL + Write)   | PARTIAL (NL + apply)   | State file write                                                         |
| `/ulak-intake`             | OK          | OK         | PARTIAL (NL)           | PARTIAL (NL)           | Ulak-specific intake artefact                                            |
| `/ulak-brainstorm`         | OK          | OK         | PARTIAL (NL)           | PARTIAL (NL)           | Brainstorming protocol inline                                            |
| `/ulak-audit-deep`         | OK          | OK         | PARTIAL (NL + serial)  | PARTIAL (NL + serial)  | 14-dim scorecard; parallel Claude-optimal                                |
| `/ulak-design-ref`         | OK          | OK         | PARTIAL (NL + Bash)    | MISSING                | Figma/design MCP; Copilot'ta MCP yok                                     |
| `/ulak-pattern-extract`    | OK          | OK         | PARTIAL (NL)           | PARTIAL (NL)           | Pattern ingest + import ledger                                           |
| `/ulak-mcp-discover`       | OK          | OK         | PARTIAL (NL)           | MISSING                | MCP registry query; Copilot MCP yok                                      |
| `/ulak-subagent-dispatch`  | OK          | PARTIAL    | PARTIAL (NL serial)    | PARTIAL (NL serial)    | Parallel dispatch Claude native; diğerleri serial workaround             |
| `/ulak-test-driven`        | OK          | OK         | PARTIAL (NL + Bash)    | PARTIAL (NL + terminal)| Red-Green-Refactor + test runner                                         |
| `/market-scan` (Gemini)    | MISSING     | OK         | PARTIAL (NL)           | PARTIAL (NL)           | Gemini-only wrapper; Claude `market-researcher` agent kullanır           |
| `/war-room` alias (Gemini) | MISSING     | OK         | N/A                    | N/A                    | Namespace drift; v2.2'de normalize edilecek                              |

### B.2 — Özet sayılar

- **Claude Code**: 24 native OK komutu, 2 exemption (market-scan, war-room — Gemini-only).
- **Gemini CLI**: 26 native OK komutu (24 Claude-parity + 2 Gemini-only).
- **Codex CLI**: 0 native slash; 22 komut PARTIAL (NL trigger), 4 OK (inline-only: next-steps, hello, explain, demo, packs).
- **Copilot Chat**: 0 native slash; 20 komut PARTIAL, 4 OK (inline-only), 2 MISSING (MCP-dependent).

---

## 4) Vendor "tam destek" kriterleri

Bir vendor "Ulak OS full runtime" sayılabilmesi için şu 8 kapasiteyi sağlamalı:

1. File Read + Grep + Glob
2. File Write veya Edit
3. Bash/shell execute
4. Multi-turn session memory (context file)
5. MCP veya equivalent external service integration
6. Skill/named-capability invocation (veya NL equivalent)
7. Slash command dispatch (veya reading-order NL equivalent)
8. Settings-level permission governance

| Vendor        | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | Statü         |
|---------------|---|---|---|---|---|---|---|---|---------------|
| Claude Code   | Y | Y | Y | Y | Y | Y | Y | Y | **FULL**      |
| Gemini CLI    | Y | Y | P | Y | Y | P | Y | P | **FULL-MINUS** |
| Codex CLI     | Y | Y | Y | Y | Y | N | N | N | **CORE**      |
| Copilot Chat  | Y | P | P | P | N | N | N | N | **LIMITED**   |

(`Y` = full, `P` = partial, `N` = missing)

- **FULL** = tüm 24 komut native çalışır.
- **FULL-MINUS** = tüm 24 komut çalışır; bazılarında NL/serial fallback kullanılır.
- **CORE** = komutlar NL trigger ile çalışır; artefakt zinciri üretilir ama slash-native değil.
- **LIMITED** = read-heavy komutlar OK; write/MCP-heavy komutlar MISSING.

---

## 5) Exemption protokolü

Bir komut bir vendor'da intentionally ship edilmiyorsa:

1. `.github/vendor-parity-exemptions.txt` dosyasına `<vendor>:<command>` satırı ekle.
2. Satırın üstüne kısa gerekçe yaz (naming drift, MCP dependency, v1.2 deferred, vb.).
3. Bu dosyadaki B.1 tablosunu güncelle (ilgili hücreyi `MISSING` yap, gerekçe kolonunu doldur).
4. `bash scripts/validate-vendor-parity.sh` koştur — OK dönmeli.

Exemption olmayan gap **CI'ı kırar** (W4.16 — DY-03 vendor-parity silent-drift finding).

---

## 6) Reconcile check

```bash
# Gerçek disk durumu vs matrix tutarlılığı:
bash scripts/validate-vendor-parity.sh .

# Çıktı: her komut için claude/gemini/codex kolonlu tablo + exit 0.
# Exit 1 ise: exemption eksik veya komut drift etmiş — matrisi güncelle.
```

Son reconcile: 2026-04-21 → validator exit 0, parity maintained.

---

## 7) İlgili dosyalar

- `docs/adapters/universal-runtime-contract.md` — platform-agnostic davranış sözleşmesi (runtime primitive kontratı bölümü bu dosyaya referans verir)
- `docs/adapters/claude-code.md` — Claude Code adapter detayları
- `docs/adapters/gemini-cli.md` — Gemini CLI adapter detayları
- `docs/adapters/codex-cli.md` — Codex/Copilot adapter detayları
- `.github/vendor-parity-exemptions.txt` — declared gaps
- `scripts/validate-vendor-parity.sh` — disk vs matrix validator
- `docs/catalog.md` — katalog (Vendor support kolonu bu matrisi yansıtır)
