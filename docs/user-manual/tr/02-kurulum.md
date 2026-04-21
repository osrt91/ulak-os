# 02 — Kurulum

> **v1.6 güncellemesi:** Ulak OS artık **4 vendor** destekler — Claude Code, Gemini CLI, Codex CLI, GitHub Copilot Chat (VS Code). Her vendor için kurulum + wiring adımları ayrı bölümde. Bir makineye birden fazla vendor aynı anda bağlanabilir; Ulak OS kendi core contract'ını paylaşır.

Ulak OS'u makinenize veya mevcut projenize eklemenin beş yolu vardır. Bu bölüm en yaygın üç yolu (one-liner installer, git clone, git submodule) + mevcut projeye entegrasyon + doğrulama + kaldırma adımlarını kapsar. Detaylı karşılaştırma için [install-methods runbook](../../runbooks/install-methods.md) dosyasına bakın.

## Ön koşullar

Kuruluma başlamadan önce:

- **git** (zorunlu, tüm yöntemler git clone kullanır)
- AI CLI'larından **en az biri**: Claude Code / Gemini CLI / Codex CLI / GitHub Copilot Chat (VS Code)
- macOS ya da Linux için `curl` (ya da `wget`) — veya Windows için **PowerShell 5.1+**
- Yazma izninizin olduğu bir `$HOME` dizini (root / admin gerekmiyor)

> **Not:** Ulak OS hiçbir zaman `sudo` istemez. Eğer installer sizden yönetici parolası isterse, bu Ulak OS değildir.

## Yöntem 1 — Tek satır installer

En hızlı yol. Makinede Ulak OS'u `$HOME/.ulak-os/` altına kurar ve `$HOME/bin/ulak` (veya Windows'ta `ulak.cmd`) komutunu ekler.

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.ps1 | iex
```

### Doğrulama

```bash
ulak --version
ulak where
ulak doctor
```

Tüm komutlar hatasız dönmeli. `ulak doctor` yeşil çıktı vermeli.

> **İpucu:** v1.0.0'dan itibaren `ulak` komutu aynı zamanda `ulak-os` adıyla da çağrılabilir (aynı binary'nin iki alias'ı).

**Ne zaman seçilir:** Bir makinede hızlıca denemek için. Her zaman `main` dalını takip eder, sürüm pinleme yoktur.

## Yöntem 2 — Git clone + manuel wiring

Her dosyayı okumadan güvenmek istemiyorsanız ya da wrapper CLI'sız çalışmayı tercih ediyorsanız:

```bash
git clone https://github.com/osrt91/ulak-os.git ~/tools/ulak-os

# İsteğe bağlı — bir sürüme sabitlemek:
cd ~/tools/ulak-os && git checkout v1.6.0
```

Ardından aşağıdaki "Vendor × kurulum matrisi" bölümünden seçtiğiniz vendor için wiring komutunu koşun.

## Yöntem 3 — Git submodule olarak bağlama

Bir takım projesinde her gözden geçirenin aynı pack sürümünü görmesini istiyorsanız:

```bash
cd /path/to/your-project
git submodule add https://github.com/osrt91/ulak-os.git .ulak-os
cd .ulak-os && git checkout v1.6.0 && cd ..
git add .gitmodules .ulak-os
git commit -m "chore: pin Ulak OS v1.6.0 as submodule"
```

Ardından vendor'a özel wiring dosyasına `@.ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md` satırı eklenir.

Takım arkadaşlarınız submodule ile klonlamalı:

```bash
git clone --recurse-submodules <your-repo>
# Ya da normal klon sonrası:
git submodule update --init --recursive
```

**Ne zaman seçilir:** Takım projeleri, reproducible audit gereksinimleri, CI ile laptop arasında sürüm parity gerektiği durumlar.

## 4 vendor × kurulum matrisi

Bir projenin kökünde hangi dosya Ulak OS ile konuşur? Aşağıdaki matris her vendor için dosyayı ve wiring komutunu verir. Kurulum dizini (Yöntem 1 ile) `$HOME/.ulak-os` veya (Yöntem 2/3 ile) kendi belirttiğiniz yoldur.

| Vendor | Entry dosyası | Wiring helper | Status (bkz. vendor-capability-matrix) |
|---|---|---|---|
| **Claude Code** | `CLAUDE.md` | `bash scripts/init-claude.sh` / `.ps1` | FULL |
| **Gemini CLI** | `GEMINI.md` + `.gemini/commands/*.toml` | `bash scripts/init-gemini.sh` / `.ps1` + `bash scripts/sync-gemini-commands.sh` | FULL-MINUS |
| **Codex CLI** | `AGENTS.md` (reading-order + NL trigger map) | `bash scripts/init-codex.sh` / `.ps1` | CORE |
| **Copilot Chat (VS Code)** | `.github/copilot-instructions.md` | Manuel — aşağıdaki şablonu ekleyin | LIMITED |

> **Natural-language (NL) trigger not:** Codex ve Copilot'ta slash komutu primitive'i yoktur. Projenizin entry dosyasına Ulak OS NL trigger map eklenir; operatör `selam ulak` / `hi ulak` yazınca `/ulak-hello` davranışı tetiklenir, "run the director phase 0→5 protocol" yazınca `/director komple` davranışı koşar. Map detayı: [docs/adapters/codex-cli.md](../../adapters/codex-cli.md), [docs/adapters/copilot-chat.md](../../adapters/copilot-chat.md).

### Claude Code wiring

```bash
cd /path/to/your-project
bash ~/.ulak-os/scripts/init-claude.sh     # CLAUDE.md'yi append-only şekilde günceller
# Ya da manuel:
cat >> CLAUDE.md <<'EOF'

# Ulak OS governance
@~/.ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
EOF
```

Windows'ta `CLAUDE.md` satırını tam yol ile (`@C:\Users\you\.ulak-os\prompts\core\...`) manuel olarak ekleyin ya da `init-claude.ps1` koşturun.

### Gemini CLI wiring

```bash
cd /path/to/your-project
bash ~/.ulak-os/scripts/init-gemini.sh     # GEMINI.md + .gemini/commands/*.toml'u bağlar
bash ~/.ulak-os/scripts/sync-gemini-commands.sh     # 24 komutu .toml'a senkronize eder
```

Her yeni Claude Code komutu eklendiğinde `sync-gemini-commands.sh` tekrar koşturulmalıdır — bu disiplin [07-Katkı](./07-katki.md) içinde de anlatılır.

### Codex CLI wiring

```bash
cd /path/to/your-project
bash ~/.ulak-os/scripts/init-codex.sh     # AGENTS.md'yi reading-order + NL trigger map ile oluşturur
```

Ardından Codex CLI'yı bu dizinde açın. Komutları `/director` yerine doğal dilde tetikleyin: *"run the director phase 0→5 protocol on this repo"*.

### Copilot Chat (VS Code) wiring

Copilot Chat slash dispatch veya MCP desteklemez (LIMITED statüsü). VS Code'da projeyi açın ve `.github/copilot-instructions.md` dosyasına ekleyin:

```markdown
# Ulak OS NL trigger map

Bu repo Ulak OS v1.6 governance ile bağlıdır. Core contract:
~/.ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md

## Natural language triggers
- "selam ulak" / "hi ulak" → ulak-hello (30-saniye tour)
- "new saas" / "start wizard" → ulak-start (27-soru wizard)
- "audit this repo" / "run director" → director komple
- "what can ulak do" → ulak-packs (inline catalog)
- "explain <term>" → ulak-explain
- "plan next steps" → ulak-next-steps

## Limitations
- MCP-dependent: /ulak-design-ref ve /ulak-mcp-discover Copilot'ta MISSING.
- Parallel dispatch: director Phase 2'de serial fallback.
```

Tam şablon: [docs/adapters/copilot-chat.md](../../adapters/copilot-chat.md).

## `ulak init` — mevcut projeye entegrasyon

Bir projeyi mevcut Ulak OS kurulumu ile yönetime almak için:

```bash
cd /path/to/your-existing-project
ulak init .                          # auto-detect vendor, tek vendor'sa direkt wiring
ulak init . --vendor=claude          # sadece Claude Code
ulak init . --vendor=gemini          # sadece Gemini CLI
ulak init . --vendor=codex           # sadece Codex CLI
ulak init . --vendor=all             # 4 vendor da
```

Bu komut şunu yapar:

1. Eğer varsa mevcut entry dosyalarını yedekler (`CLAUDE.md.ulak-backup` vb.).
2. Seçilen vendor için entry dosyasını append-only günceller.
3. Gerekirse `.claude/settings.json` dosyasını türetir.
4. Seçeceğiniz bir locale (`tr` / `en`) ile varsayılan çıktı dilini belirler (`.claude/state/locale.txt`, `/ulak-locale` ile değiştirilir).

Yedek dosyası her zaman aynı dizinde kalır.

## Doğrulama: `ulak doctor` + dört validator

Kurulumun sağlıklı olduğunu dört script doğrular:

```bash
ulak doctor

cd ~/.ulak-os
bash scripts/validate-imports.sh          # @-import çözümleme + cycle detection
bash scripts/validate-schemas.sh          # plugin.json, active-variables.yaml, validation-result.yaml
bash scripts/validate-vendor-parity.sh    # 4 vendor × 24 komut matrisi; exemption listesi kontrolü
bash scripts/validate-bilingual.sh        # TR/EN doküman parity (v1.6 enforcement)
```

Hepsi yeşil çıkmalı. Bir sorun varsa script hangi dosyanın hangi nedenle reddedildiğini söyler.

## İlk 30 saniye — self-test

Kurulum bitince entry dosyası ne olursa olsun doğal dilde deneyin:

```
selam ulak
```

ya da

```
hi ulak
```

`/ulak-hello` davranışı tetiklenmeli: 30 saniyelik tour, Ulak OS'un 3 cümlede açıklaması, 3 örnek komut, "ne yapmak istiyorsun?" sorusu. Devamında:

- `/ulak-start` — 27 soruluk wizard (basit moddan başlayabilirsiniz)
- `/ulak-packs` — tüm kapasitelerin inline dökümü
- `/ulak-search payment` — payment temalı sector/rule/template aratması

## Troubleshooting — kurulum başarısız olursa

### `ulak: command not found` hatası

`$HOME/bin` ya da `$HOME/.local/bin` dizini `PATH`'te değil:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
ulak --version
```

Windows'ta installer PowerShell snippet'i yazar — onu bir kez koşturun ve terminali yeniden açın.

### Slash komut tanınmıyor

Projenizin kök dizininde (vendor entry dosyasının olduğu yerde) olduğunuzu doğrulayın:

```bash
pwd
ls .claude/commands/ 2>/dev/null || echo "no .claude/commands here"
ls .gemini/commands/ 2>/dev/null || echo "no .gemini/commands here"
cat AGENTS.md 2>/dev/null | head -20
```

Eksikse `ulak init . --vendor=<vendor>` koşun.

### Gemini'de komut eski kalmış

Claude tarafı yeni komut eklendiyse Gemini `.toml` dosyaları eski olabilir. Fix:

```bash
bash scripts/sync-gemini-commands.sh
```

Detaylı sorun giderme: [08-Sorun giderme](./08-sorun-giderme.md) + [troubleshooting runbook](../../runbooks/troubleshooting.md).

## Uninstall — kaldırma

### Yöntem 1 (one-liner) ile kurduysanız

**macOS / Linux:**

```bash
rm -rf "${ULAK_HOME:-$HOME/.ulak-os}"
rm -f "$HOME/bin/ulak" "$HOME/.local/bin/ulak"
```

**Windows:**

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.ulak-os"
Remove-Item -Force "$env:USERPROFILE\bin\ulak.cmd" -ErrorAction SilentlyContinue
```

### Yöntem 2 (manuel klon) ile kurduysanız

```bash
rm -rf ~/tools/ulak-os
```

Her projenin entry dosyasındaki (`CLAUDE.md` / `GEMINI.md` / `AGENTS.md` / `copilot-instructions.md`) `@`-import ya da NL trigger map satırını el ile silin.

### Yöntem 3 (submodule) ile kurduysanız

```bash
git submodule deinit -f .ulak-os
git rm -f .ulak-os
rm -rf .git/modules/.ulak-os
```

Ardından entry dosyasından `@.ulak-os/...` satırını silin.

## Dikkat edilmesi gerekenler

- **Installer network'e çıkar mı?** Sadece git clone / pull için. Telemetri, usage tracking, phone-home yok.
- **Güncelleme nasıl yapılır?** Yöntem 1 için `ulak upgrade`. Yöntem 2 için `cd ~/tools/ulak-os && git pull`. Yöntem 3 için `cd .ulak-os && git fetch --tags && git checkout v1.6.0`.
- **Birden fazla vendor aynı anda çalışabilir mi?** Evet — aynı proje kökünde `CLAUDE.md` + `GEMINI.md` + `AGENTS.md` + `.github/copilot-instructions.md` birlikte yaşayabilir. Her vendor kendi entry'sini okur.
- **Birden fazla sürüm aynı anda çalışabilir mi?** Evet, Yöntem 2 ile farklı dizinlere (`~/tools/ulak-os-1.6.0`, `~/tools/ulak-os-1.7.0`) klonlayın.

## İlgili belgeler

- [install-methods runbook](../../runbooks/install-methods.md) — beş yöntemin detaylı karşılaştırması
- [troubleshooting runbook](../../runbooks/troubleshooting.md) — 11+ yaygın kurulum ve çalışma hatası
- [first-hour-with-ulak-os](../../runbooks/first-hour-with-ulak-os.md) — kurulum sonrası ilk saat senaryosu
- [docs/governance/vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md) — 4 vendor primitive + komut matrisi
- [docs/adapters/](../../adapters/) — her vendor için adapter notları

Sonraki bölüm: [03 — Mimari](./03-mimari.md)
