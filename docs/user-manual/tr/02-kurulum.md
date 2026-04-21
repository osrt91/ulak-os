# 02 — Kurulum

Ulak OS'u makinenize veya mevcut projenize eklemenin beş yolu vardır. Bu bölüm en yaygın üç yolu (one-liner installer, git clone, git submodule) + mevcut projeye entegrasyon + doğrulama + kaldırma adımlarını kapsar. Detaylı karşılaştırma için [install-methods runbook](../../runbooks/install-methods.md) dosyasına bakın.

## Ön koşullar

Kuruluma başlamadan önce:

- **git** (zorunlu, tüm yöntemler git clone kullanır)
- AI CLI'larından **en az biri**: Claude Code / Codex / Gemini CLI
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

**Ne zaman seçilir:** Bir makinede hızlıca denemek için. Her zaman `main` dalını takip eder, sürüm pinleme yoktur.

## Yöntem 2 — Git clone + manuel CLAUDE.md düzenlemesi

Her dosyayı okumadan güvenmek istemiyorsanız ya da wrapper CLI'sız çalışmayı tercih ediyorsanız:

```bash
git clone https://github.com/osrt91/ulak-os.git ~/tools/ulak-os

# İsteğe bağlı — bir sürüme sabitlemek:
cd ~/tools/ulak-os && git checkout v1.0.0
```

Governance eklemek istediğiniz her projede:

```bash
cd /path/to/your-project
cat >> CLAUDE.md <<EOF

# Ulak OS governance
@/home/you/tools/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
EOF
```

Windows'ta `CLAUDE.md` satırını tam yol ile (`@C:\Users\you\tools\ulak-os\prompts\core\...`) manuel olarak ekleyin.

**Ne zaman seçilir:** Kurulum yolunu kendiniz kontrol etmek istiyorsanız, her değişikliği bir `git pull` ile görmek istiyorsanız.

## Yöntem 3 — Git submodule olarak bağlama

Bir takım projesinde her gözden geçirenin aynı pack sürümünü görmesini istiyorsanız:

```bash
cd /path/to/your-project
git submodule add https://github.com/osrt91/ulak-os.git .ulak-os
cd .ulak-os && git checkout v1.0.0 && cd ..
git add .gitmodules .ulak-os
git commit -m "chore: pin Ulak OS v1.0.0 as submodule"

# Göreceli @-import — repo ile birlikte taşınır:
cat >> CLAUDE.md <<'EOF'

# Ulak OS governance (submodule-pinned)
@.ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
EOF

git add CLAUDE.md && git commit -m "chore: wire Ulak OS governance"
```

Takım arkadaşlarınız submodule ile klonlamalı:

```bash
git clone --recurse-submodules <your-repo>

# Ya da normal klon sonrası:
git submodule update --init --recursive
```

**Ne zaman seçilir:** Takım projeleri, reproducible audit (tekrarlanabilir denetim) gereksinimleri, CI ile laptop arasında sürüm parity (eşitliği) gerektiği durumlar.

## `ulak init` — mevcut projeye entegrasyon

Bir projeyi mevcut Ulak OS kurulumu ile yönetime almak için:

```bash
cd /path/to/your-existing-project
ulak init .
```

Bu komut şunu yapar:

1. Eğer varsa mevcut `CLAUDE.md` dosyasının yedeğini `CLAUDE.md.ulak-backup` adıyla alır.
2. `CLAUDE.md` dosyasının sonuna `@`-import satırını ekler (mevcut içeriği bozmadan).
3. Gerekirse `.claude/settings.json` dosyasını kurulum kopyasından türetir.
4. Seçeceğiniz bir locale (`tr` / `en`) ile varsayılan çıktı dilini belirler.

Yedek dosyası her zaman aynı dizinde kalır. Eğer yanlış bir şey olduğunu düşünüyorsanız:

```bash
ls CLAUDE.md*
# CLAUDE.md.ulak-backup varsa:
cp CLAUDE.md.ulak-backup CLAUDE.md
```

## Doğrulama: `ulak doctor` + üç validator

Kurulumun sağlıklı olduğunu üç script doğrular:

```bash
# Tek komutta özet:
ulak doctor

# Ya da kurulum dizininden tek tek:
cd ~/.ulak-os    # veya git clone dizini
bash scripts/validate-imports.sh
bash scripts/validate-schemas.sh
bash scripts/validate-vendor-parity.sh
```

- **validate-imports.sh**: Tüm `@`-import yollarının çözüldüğünü, döngü (cycle) olmadığını kontrol eder.
- **validate-schemas.sh**: `plugin.json`, `active-variables.yaml`, `validation-result.yaml` şemalarını doğrular.
- **validate-vendor-parity.sh**: Claude / Codex / Gemini adapter'ları arasındaki feature parity'yi kontrol eder; istisnalar `vendor-parity-exemptions.txt` altında olmalı.

Hepsi yeşil çıkmalı. Bir sorun varsa çıktıyı okuyun — script hangi dosyanın hangi nedenle reddedildiğini söyler.

## Troubleshooting — kurulum başarısız olursa

### `ulak: command not found` hatası

`$HOME/bin` ya da `$HOME/.local/bin` dizini `PATH`'te değil. Çözüm:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc   # veya ~/.zshrc
source ~/.bashrc
ulak --version
```

Windows'ta installer PowerShell snippet'i yazar (`[Environment]::SetEnvironmentVariable(...)`) — onu bir kez koşturun ve terminali yeniden açın.

### Installer `git not found` diyorsa

```bash
# macOS:
xcode-select --install

# Debian / Ubuntu:
sudo apt install git

# Fedora / RHEL:
sudo dnf install git
```

Windows için: https://git-scm.com/download/win

### `/director` komutu Claude Code tarafından tanınmıyorsa

Projenizin kök dizininde (CLAUDE.md'nin olduğu yerde) olduğunuzu doğrulayın:

```bash
pwd
ls .claude/commands/ 2>/dev/null || echo "no .claude/commands here"
```

Eğer `.claude/commands/` yoksa, ya `ulak init .` koşun (import bağlantısı kurulur, komutlar kurulum dizininden gelir) ya da Claude Code'u `~/.ulak-os/` dizininden açın — orada 9 komut hazır durumdadır.

Detaylı sorun giderme: [troubleshooting runbook](../../runbooks/troubleshooting.md).

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

Her projenin `CLAUDE.md` dosyasındaki `@`-import satırını el ile silin.

### Yöntem 3 (submodule) ile kurduysanız

```bash
git submodule deinit -f .ulak-os
git rm -f .ulak-os
rm -rf .git/modules/.ulak-os
```

Ardından `CLAUDE.md` içinden `@.ulak-os/...` satırını silin.

## Dikkat edilmesi gerekenler

- **Installer network'e çıkar mı?** Sadece git clone / pull için. Telemetri, usage tracking, phone-home yok.
- **Güncelleme nasıl yapılır?** Yöntem 1 için `ulak upgrade`. Yöntem 2 için `cd ~/tools/ulak-os && git pull`. Yöntem 3 için `cd .ulak-os && git fetch --tags && git checkout v1.0.1`.
- **Birden fazla sürüm aynı anda çalışabilir mi?** Evet, Yöntem 2 ile farklı dizinlere (`~/tools/ulak-os-1.0.0`, `~/tools/ulak-os-1.0.1`) klonlayın; her proje istediği sürümü `@`-import ile bağlar.

## İlgili belgeler

- [install-methods runbook](../../runbooks/install-methods.md) — beş yöntemin detaylı karşılaştırması
- [troubleshooting runbook](../../runbooks/troubleshooting.md) — 11 yaygın kurulum ve çalışma hatası
- [first-hour-with-ulak-os](../../runbooks/first-hour-with-ulak-os.md) — kurulum sonrası ilk saat senaryosu

Sonraki bölüm: [03 — Mimari](./03-mimari.md)
