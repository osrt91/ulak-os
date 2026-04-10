# Ulak OS

> **Vendor-neutral prompt operating system** — Claude Code, Codex/Copilot ve Gemini CLI için tek çekirdekli, üç adaptörlü, çözüme odaklı runtime.

**Sürüm:** 2.0.0 (CLI Console + Memory + Vendor Adapters)
**Geliştirici:** [Oğuzhan Sert](https://github.com/osrt91)
**Lisans:** MIT

[English version](README.en.md)

---

## Ulak OS nedir?

Ulak OS, büyük yazılım projelerini **istediğin noktadan** ele alıp doğrulanmış sonuçlara götüren bir prompt operating system'dir:

- 🟢 **Sıfırdan kuruyorsan** → `CREATE` modu, intake → roadmap → validation
- 🟡 **Yarım bıraktığını devralıyorsan** → `RESCUE` modu, evidence-register'dan başla
- 🔴 **Finale yakınsa** → `REPACKAGE` modu, validation ve manager-verdict odaklı

Aynı artefakt zinciri her durumda çalışır; **doğrulama olmadan "bitti" demez.**

## Üç vendor, tek çekirdek

| Vendor | Adapter dosyası | İlk komut |
|---|---|---|
| Claude Code | `CLAUDE.md` | `/director komple` |
| Codex / Copilot | `AGENTS.md` | "Read AGENTS.md, run program mode" |
| Gemini CLI | `GEMINI.md` | `/director komple` |

Hepsi `prompts/core/ulak-os-core-contract-2.0.0.md` çekirdek sözleşmesini paylaşır.

## Hızlı başlangıç (5 dakika)

### 1. Klonla

```bash
git clone https://github.com/osrt91/ulak-os
cd ulak-os
```

### 2. Vendor'una göre init script'i çalıştır

**macOS / Linux:**
```bash
bash scripts/init-claude.sh    # Claude Code
bash scripts/init-codex.sh     # Codex/Copilot
bash scripts/init-gemini.sh    # Gemini CLI
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\init-claude.ps1
powershell -ExecutionPolicy Bypass -File scripts\init-codex.ps1
powershell -ExecutionPolicy Bypass -File scripts\init-gemini.ps1
```

### 3. Vendor CLI'yi başlat ve ilk komutu çalıştır

```
$ claude
> /memory          # CLAUDE.md yüklü mü doğrula
> /director komple  # Ulak OS programa girer
```

İlk komut çıktısı `reports/current/` altına artefakt zincirini yazmaya başlar.

## MCP connector'ları (opsiyonel)

`.mcp.json` dosyası 3 MCP connector tanımı içerir: **GitHub** (resmi server, hazır kurulu), Jira ve Figma (placeholder).

### GitHub MCP (resmi, en kolay)

GitHub'ın resmi MCP server'ı `https://api.githubcopilot.com/mcp/` zaten `.mcp.json`'da yapılı. Sadece GitHub Personal Access Token'ı ortam değişkenine koyman yeterli:

```bash
# GitHub Personal Access Token
# https://github.com/settings/tokens üzerinden oluştur
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_token_here"
```

Ulak OS açıldığında Claude Code otomatik bağlanır; issue/PR/repo arama, code review, GitHub API'sinin tüm fonksiyonları doğrudan kullanılabilir.

### Jira ve Figma (opsiyonel, kendi endpoint'in)

```bash
# Jira (opsiyonel)
export JIRA_MCP_URL="https://your-jira-mcp-endpoint"
export JIRA_TOKEN="your_jira_token"

# Figma (opsiyonel)
export FIGMA_MCP_URL="https://your-figma-mcp-endpoint"
export FIGMA_TOKEN="your_figma_token"
```

**Not:** Hiçbiri set edilmezse Ulak OS yine çalışır; sadece MCP tool'ları devre dışı kalır.

## Sorun giderme

| Sorun | Çözüm |
|---|---|
| `/memory` CLAUDE.md'yi göstermiyor | Claude Code'u repo **kökünden** aç |
| `@import` hatası | `bash scripts/validate-imports.sh` ile hangi dosya bulunamadığını gör |
| MCP bağlantı hatası | Yukarıdaki env var'ları set et veya MCP'yi devre dışı kabul et |
| Windows `.ps1` "execution policy" hatası | `-ExecutionPolicy Bypass -File` parametresini kullan |
| `reports/current/` yok | `bash scripts/init-<vendor>.sh` script'ini tekrar çalıştır |
| `Claude Ulak` kalıntısı görüyorum | Bu bir bug — issue aç |

## Repo içeriği

```
ulak-os/
├── CLAUDE.md / AGENTS.md / GEMINI.md      # 3 adaptör başlangıç dosyası
├── prompts/core/                           # vendor-agnostic çekirdek sözleşme
├── docs/
│   ├── adapters/                           # platform-spesifik kullanım rehberleri
│   ├── governance/                         # rule collision matrix, plugin/skill kararları
│   ├── history/                            # version lineage
│   ├── examples/                           # dolu artefakt örnekleri
│   ├── ecosystem/                          # related-work + ekosistem referansları
│   └── skills-integration/                 # superpowers + awesome-design-md mapping
├── scripts/                                # init + validation scriptleri (sh + ps1)
├── .claude/                                # 20 subagent + 8 komut + 4 native skill
├── .gemini/                                # Gemini CLI özel komutları
├── .github/workflows/                      # CI validation + secret scan
└── reports/current/                        # runtime artefakt yazılır
```

## Çoklu dil

Ulak OS v2.0.0'da:
- 🇹🇷 **Türkçe** (birincil) — `*.md`
- 🇬🇧 **English** (paralel) — `*.en.md`

v2.1+ planlanıyor: 🇫🇷 FR, 🇩🇪 DE, 🇪🇸 ES, 🇸🇦 AR, 🇯🇵 JA, 🇨🇳 ZH

## Ekosistem

Ulak OS izole bir ürün değil, bir ekosistemin parçası. Beraber kullanılabilir, ilham aldığı veya tamamlayıcı olarak değerlendirdiği public projelerin listesi: [`docs/ecosystem/related-work.md`](docs/ecosystem/related-work.md).

Öne çıkanlar:
- **[obra/superpowers](https://github.com/obra/superpowers)** — Agentic skill çerçevesi (Ulak ile mapping: [`docs/skills-integration/superpowers-mapping.md`](docs/skills-integration/superpowers-mapping.md))
- **[anthropics/skills](https://github.com/anthropics/skills)** — Anthropic resmi Agent Skills repo'su
- **[VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)** — 58+ marka için DESIGN.md (Ulak ile entegre: `/ulak-design-ref` komutu)
- **[gsd-build/gsd-2](https://github.com/gsd-build/gsd-2)** — Spec-driven development sistemi (felsefi akrabalık)
- **[hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)** — Claude Code skill curated listesi

## Versiyon geçmişi

Bu sürüm, "Claude Ulak" iç kod adıyla geliştirilen 1.0.0–1.9.1 serisinin **public stable** halefidir. Detaylar: [`docs/history/version-lineage.md`](docs/history/version-lineage.md)

## Katkı

Pull request'ler hoşgörülür. Önce [`CONTRIBUTING.md`](CONTRIBUTING.md) ve [`docs/governance/rule-collision-matrix.md`](docs/governance/rule-collision-matrix.md) dosyalarını oku.

## Lisans

MIT — [`LICENSE`](LICENSE)
