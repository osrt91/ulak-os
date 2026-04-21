# GitHub Tutorial — Sıfırdan ilk repo + ilk push

> **Amaç**: Ulak OS ile scaffold ettiğin projeyi GitHub'a yükle, CI'ı yeşil çalıştır,
> secret scanning + Dependabot aktif et, ilk PR'ı aç — **20 dakikada**.
>
> **Hedef kullanıcı**: Daha önce hiç GitHub'a push etmemiş, git komutlarını kısmen duymuş,
> terminal'den korkmayan beginner. Tüm komutlar kopyala-yapıştır.
>
> **Ön koşul**: `/ulak-scaffold` çalışmış, disk'te `my-saas/` (ya da kendi proje adınla) klasör duruyor.

---

## 1. GitHub nedir, neden gerekli?

**Kısa tanım**: Git tabanlı kod hosting platformu. Dünyada facto-standart — yazılım geliştiren herkes kullanır.

**Neden Ulak OS'un olmazsa olmazı**:

- **Ücretsiz**: Public + private repo sınırsız. Kişisel hesaplar için birincil hesap açma ücreti yok.
- **CI/CD ücretsiz**: GitHub Actions, public repo'larda **sınırsız dakika**, private'da **2000 dk/ay** free tier.
- **Secret scanning** + **Push protection**: Commit'te yanlışlıkla API key'i yakalarsan push'u engeller. Ücretsiz.
- **Dependabot**: Haftalık bağımlılık güncellemelerini PR olarak açar. Güvenlik açığı çıkarsa auto-PR. Ücretsiz.
- **Ulak OS entegre gelir**: Scaffolder `.github/workflows/ci.yml`, `.github/dependabot.yml`, issue ve PR template'lerini hazır koyar. GitHub'da repo oluşturduğun an her şey otomatik çalışır.

**Alternatifler** (ve neden default GitHub):

- **GitLab** — self-host güçlü, Ulak OS'a hazır workflow'u GitHub Actions format'ında; GitLab CI format'ına çevirmek manuel iş.
- **Bitbucket** — Atlassian ekosistemi içindeysen (Jira, Confluence) mantıklı. Tekil dev için overkill.
- **Codeberg / Gitea self-hosted** — full kontrol ama CI'ı kendin kurarsın.

Ulak OS scaffold'u GitHub'a optimize — başka platforma geçmek istersen `docs/adapters/` altına yazılacak; şimdilik GitHub birincil.

---

## 2. Hesap açma (3 dk)

1. Tarayıcıda <https://github.com/signup> aç.
2. **Email** + **şifre** + **username** seç.
   - ⚠️ Username **public** — profil URL'in `github.com/<username>` olur. Hesap boyunca genelde aynı kalır, düşün.
   - Özel karakter yok, 39 karakter sınırı.
3. "I'm not a robot" verify.
4. **Email verify** — inbox'u kontrol et, gelen linke tıkla. Gelmezse spam klasörüne bak.
5. Giriş yaptıktan sonra **2FA ekle** (kritik):
   - Sağ üst profil avatarı → **Settings** → **Password and authentication** → **Two-factor authentication** → **Enable 2FA**.
   - Yöntem: **Authenticator app** (önerilen). Uygulamalar: 1Password, Authy, Google Authenticator, Microsoft Authenticator.
   - QR kodu tara → 6 haneli kodu onayla.
   - **Recovery codes ver** — 16 tane tek-kullanımlık yedek kod. Telefonunu kaybedersen bunlarla girersin. Yazdır veya şifre yöneticisine kaydet; repo'ya ASLA commit etme.

**Ücret**: 0 TL / 0 USD. Ücretsiz hesap; private repo da ücretsiz.

---

## 3. Git kurulumu (lokal, 5 dk)

### Windows

1. <https://git-scm.com/download/win> → installer indir.
2. Çalıştır, **default seçimler OK** (next → next). "Git Bash" terminal'i birlikte kurulur — bu tutorial boyunca onu kullanacağız.
3. Kurulumdan sonra yeni bir PowerShell veya Git Bash aç, doğrula:

   ```bash
   git --version
   # çıktı: git version 2.40+ gibi bir şey
   ```

### macOS

```bash
# Homebrew varsa (tavsiye):
brew install git

# Yoksa, Apple'ın komut satırı araçlarını kur:
xcode-select --install
```

### Linux

```bash
# Ubuntu / Debian:
sudo apt update && sudo apt install -y git

# Fedora:
sudo dnf install -y git

# Arch:
sudo pacman -S git
```

### İlk konfigürasyon (tüm platformlarda ortak)

```bash
git config --global user.name "Senin İsmin"
git config --global user.email "sen@example.com"

# Ulak OS önerisi — modern default'lar:
git config --global init.defaultBranch main
git config --global pull.rebase false
```

⚠️ `user.email` **GitHub hesabındaki e-posta ile aynı olmalı** — yoksa commit'ler "kayıtsız" görünür (private avatar).

---

## 4. SSH key oluştur + GitHub'a ekle (5 dk) — **önerilen**

**Neden SSH**: HTTPS push her seferinde `password` soran eski moddan daha güvenli ve pratik. Bir kez kurarsın, unutursun.

### SSH key oluştur

```bash
ssh-keygen -t ed25519 -C "sen@example.com"
# "Enter file in which to save the key" sorusunda ENTER — default path
# "Enter passphrase" — boş ENTER veya bir parola koy (unutma!)
```

Üretilen iki dosya:
- `~/.ssh/id_ed25519` → **private key, asla paylaşma**
- `~/.ssh/id_ed25519.pub` → **public key, paylaşılabilir**

### Public key'i kopyala

```bash
# macOS:
pbcopy < ~/.ssh/id_ed25519.pub

# Linux (xclip gerekir):
xclip -selection clipboard < ~/.ssh/id_ed25519.pub

# Windows (Git Bash):
cat ~/.ssh/id_ed25519.pub | clip

# Veya her platformda manuel:
cat ~/.ssh/id_ed25519.pub
# "ssh-ed25519 AAAAC3Nza... sen@example.com" çıktısını seçip kopyala
```

### GitHub'a ekle

1. GitHub → sağ üst profil → **Settings** → **SSH and GPG keys** → **New SSH key**.
2. **Title**: "Kendi Bilgisayarım" (veya "MacBook-2026", ayırt edici bir şey).
3. **Key type**: Authentication Key (default).
4. **Key**: kopyaladığın public key'i yapıştır.
5. **Add SSH key** → şifreni soracak, onayla.

### Bağlantıyı test et

```bash
ssh -T git@github.com
# İlk seferde "yes" yaz (host verification)
# Beklenen çıktı:
# Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

⚠️ `Permission denied (publickey)` alıyorsan: public key doğru eklenmemiş. §11 Sorun giderme → "Permission denied".

---

## 5. İlk repo oluştur (3 dk)

1. github.com → sağ üst **+** → **New repository**.
2. **Repository name**: `my-saas` (ulak-scaffold klasör ismine **birebir** uy — örnek: scaffold'u `koptak` diye açtıysan burada da `koptak` yaz).
3. **Description** (opsiyonel): `Ulak OS ile scaffold edilmiş SaaS`.
4. **Visibility**:
   - **Public** — herkes kodu görür. GitHub Actions sınırsız dakika. Open source için ideal.
   - **Private** — sadece sen + davet ettiğin kişiler. Actions 2000 dk/ay free. Erken-dönem SaaS için güvenli default.
   - Ulak OS'un bakış açısı: **başlangıçta private** → MVP çalışınca public'e geç. Her zaman `Settings → Danger Zone → Change visibility`.
5. **Initialize this repository with**:
   - README ✗ (scaffold'da zaten var)
   - .gitignore ✗ (scaffold'da zaten var)
   - license ✗ (scaffold'da zaten var)
   - ⚠️ **Hiçbirini seçme** — local'de Ulak'ın ürettiği versiyonlar var; seçersen empty commit ile conflict çıkar.
6. **Create repository**.

Açılan sayfada `…or push an existing repository from the command line` bölümü sana komutları verir. Ama Ulak OS'a özel akış için **aşağıdaki §6'yı kullan** — birkaç fark var.

---

## 6. Local projeyi push et (2 dk)

Terminal'i aç, scaffold klasörüne geç:

```bash
cd my-saas                   # ya da kendi proje dizinin

# Eğer scaffold zaten git init yaptıysa bu adımı atla:
git init
git branch -M main

# İlk snapshot:
git add -A
git status                   # ne ekleneceğini gör — .env.local GÖRÜNMEMELI (gitignore)
git commit -m "feat: initial commit via Ulak OS scaffold"

# Remote bağla (SSH URL — §4'te SSH key'i kurduysan):
git remote add origin git@github.com:<username>/my-saas.git

# Veya HTTPS URL (SSH kurmadıysan):
# git remote add origin https://github.com/<username>/my-saas.git

# Push:
git push -u origin main
```

**Beklenen çıktı**:

```
Enumerating objects: 245, done.
Counting objects: 100% (245/245), done.
...
To github.com:<username>/my-saas.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

Tarayıcıda repo URL'ini aç — kod orada görünmeli.

⚠️ **Push reject olduysa** (`remote rejected` veya `fetch first`): muhtemelen §5'te README veya license seçmişsin, GitHub'da empty commit var. Çözüm:

```bash
git pull --rebase origin main
git push -u origin main
```

---

## 7. CI otomatik çalışır (Ulak scaffold hazır) (2 dk)

Ulak OS scaffold'u `.github/workflows/ci.yml` dosyasını hazır koyar. Push ile birlikte **otomatik tetiklenir**.

### CI'ı izle

1. GitHub → repo → **Actions** sekmesi.
2. "CI" workflow otomatik başladı. 1-4 dakika sürer.
3. İkonlar:
   - 🟡 sarı = çalışıyor
   - ✅ yeşil = başarılı
   - ❌ kırmızı = başarısız

### Ulak scaffold CI'ı ne yapar?

```yaml
# .github/workflows/ci.yml özeti
jobs:
  typecheck     # pnpm typecheck
  lint          # pnpm lint
  test          # pnpm test
  build         # pnpm build
  gitleaks      # secret leak scan
```

**Yeşil**: 4 job da geçti. Hazır.

**Kırmızı**: tıkla → failing job → "View logs" → son birkaç satırdan hatayı oku. En yaygın sebepler:

- `pnpm install` başarısız → `package.json` vs lockfile mismatch. Local'de `pnpm install && git add pnpm-lock.yaml && git commit --amend --no-edit && git push -f origin main`. (⚠️ force push yalnız henüz hiç merge olmamış main için güvenli; başkasıyla çalışıyorsan yapma.)
- `typecheck` kırmızı → local'de `pnpm typecheck` koş, hatayı gör, düzelt, commit, push.
- `gitleaks` kırmızı → bir yerde gerçek API key komitlenmiş. §9 push protection bölümüne bak, commit'i scrub et.

Her push / PR CI'ı tekrar tetikler — "yeşil main" disiplinine gir.

---

## 8. Dependabot aktive et (1 dk)

1. Repo → **Settings** → sol menüde **Code security and analysis** (bazı hesaplarda **Security & analysis**).
2. Aşağıdaki üçünü **Enable** yap:
   - **Dependabot alerts** → güvenlik açığı olan paketi email ile bildirir.
   - **Dependabot security updates** → açığa gelen fix'i otomatik PR olarak açar.
   - **Dependabot version updates** → haftalık rutin güncellemeler (pnpm, GitHub Actions, Docker tag).

Ulak scaffold **`.github/dependabot.yml`** dosyasını zaten koymuş — config haftalık schedule ile gelir:

```yaml
# .github/dependabot.yml (Ulak scaffold default)
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 5
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

**Pazartesi sabahı**: inbox'ında 1-5 PR bulabilirsin. Merge için:

1. PR'ı aç → "Files changed" ile diff'e bak.
2. CI yeşilse genelde güvenli — özellikle patch/minor update'ler.
3. **Squash and merge** → PR kapanır, main güncellenir.
4. **Major version bump** (örn. Next.js 14 → 15) → breaking change'e işaret; CHANGELOG'u oku.

---

## 9. Secret scanning aktive et (1 dk)

1. Repo → **Settings** → **Code security and analysis**.
2. **Secret scanning** → **Enable** — repo'da daha önce commit edilmiş secret'ları tarar, bulursa uyarır.
3. **Push protection** → **Enable** — **commit anında** secret yakalar, push'u tamamen engeller.

Push protection örnek deneyim:

```
# Sen:
git push

# GitHub cevap:
remote: error: GH013: Repository rule violations found for refs/heads/main.
remote: - Push cannot contain secrets
remote: - Detected secret: Stripe API Key
remote:   - commit: abc123
remote:   - path: src/lib/stripe.ts:12
```

**Yakaladıysa çözüm** (commit'i geri alıp secret'ı kaldır):

```bash
# Son commit'i soft reset et (değişiklikler working tree'de kalır):
git reset --soft HEAD~1

# secret'ı dosyadan sil, .env.local'a taşı, gitignore'da olduğunu doğrula:
# src/lib/stripe.ts içinden STRIPE_KEY = "sk_live_..." satırını sil
# yerine: const key = process.env.STRIPE_SECRET_KEY

# Yeniden commit:
git add -A
git commit -m "fix: move stripe key to env var"
git push
```

⚠️ **Key'i zaten leak ettiysen**: commit'i silmek yetmez. **Key'i rotate et** (Stripe/Resend/Supabase dashboard → eski key'i revoke + yeni key oluştur). Ulak OS `docs/governance/secrets-rotation-policy.md` tam prosedürü tutar.

---

## 10. İlk PR'ı aç (opsiyonel, 3 dk)

```bash
# Yeni branch aç:
git checkout -b feature/ilk-degisiklik

# Bir şey değiştir (örnek: README'ye satır ekle):
echo "" >> README.md
echo "## Proje hakkında" >> README.md
echo "Ulak OS ile scaffold edildi." >> README.md

# Commit + push:
git add README.md
git commit -m "docs: README'ye proje açıklaması ekle"
git push -u origin feature/ilk-degisiklik
```

Push bittikten sonra terminal sana direkt bir link basar:

```
remote: Create a pull request for 'feature/ilk-degisiklik' on GitHub by visiting:
remote:      https://github.com/<username>/my-saas/pull/new/feature/ilk-degisiklik
```

**Tarayıcıda**:
1. Linke git (veya GitHub'da "Compare & pull request" sarı banner'ına tıkla).
2. **Title** + **Description** yaz. Ulak scaffold PR template koymuş olabilir — doldur.
3. **Create pull request**.
4. CI otomatik tetiklenir (1-4 dk).
5. Yeşil → **Squash and merge** → PR kapanır, main güncellenir.
6. Local'e senkron:

   ```bash
   git checkout main
   git pull origin main
   git branch -d feature/ilk-degisiklik   # merge olduğu için local branch'i sil
   ```

---

## 11. Sorun giderme

### `Permission denied (publickey)`

SSH key GitHub'a eklenmemiş veya yanlış eklendi.

```bash
# 1. Key var mı:
ls -la ~/.ssh/
# id_ed25519 + id_ed25519.pub görmelisin

# 2. Key agent'a eklenmiş mi:
ssh-add -l
# Boşsa:
ssh-add ~/.ssh/id_ed25519

# 3. GitHub'a gerçekten eklenmiş mi:
ssh -T git@github.com
# Hâlâ permission denied ise:
#   - Settings → SSH keys → key'i sil + §4'ü baştan yap
```

### `fatal: remote origin already exists`

```bash
git remote remove origin
git remote add origin git@github.com:<username>/my-saas.git
```

### `repository not found`

Remote URL yanlış. Kontrol:

```bash
git remote -v
# origin  git@github.com:<username>/my-saas.git (fetch)
# origin  git@github.com:<username>/my-saas.git (push)
```

URL'deki `<username>` ve repo adı **tam** eşleşmeli (case-sensitive).

### Push protection gerçek key yakalamış

§9 sonundaki çözüm. Kısa özet: `git reset --soft HEAD~1` → key'i kaldır → yeniden commit → push. Ve **key'i rotate et**.

### CI kırmızı ama local'de yeşil

- `pnpm-lock.yaml` commit'lendi mi? (`git status` → `pnpm-lock.yaml` untracked ise commit'le)
- Node versiyonu farkı: CI `node 20` kullanıyorsa local'de de öyle (`node --version`).
- `.env.local` secret'ları CI'da yok (doğru davranış); CI script'i fail ediyorsa test ortamı için mock kullanmalı — `docs/runtime/rule-packs/api-security.md` §CI-env bölümüne bak.

### Branch protection main'e direct push engelliyor

Ulak scaffold ileri disiplin ile main'i koruma altına almanı önerir:

1. Settings → Branches → Add rule → `main`.
2. **Require a pull request before merging** ✓
3. **Require status checks to pass** ✓ → CI'ı seç.
4. Save.

Artık main'e direkt push yok, her değişiklik PR'dan geçer.

### Dependabot PR'ları üst üste yığıldı

- `open-pull-requests-limit: 5` config'i yığılmayı önler.
- Eski PR'ları close et (güvenli — Dependabot gelecek hafta yeniden açar).
- Major version bump'lar manuel değerlendirilmeli; patch/minor'ı toplu merge edebilirsin.

### Daha fazla

- `docs/runbooks/troubleshooting.md` § Git / GitHub bölümü — genişletilmiş senaryolar.
- `docs/governance/secrets-rotation-policy.md` — leak durumunda rotate protokolü.
- `docs/tutorials/resend.md` — sıradaki tutorial (email gönderimi).

---

## Sonraki adım

GitHub'a push edildi, CI yeşil, Dependabot + secret scanning aktif. Şimdi:

1. **Transactional email**: `/ulak-next-steps` → §3.4 Resend → `docs/tutorials/resend.md`.
2. **Deploy**: Vercel (`/ulak-explain vercel`) veya VPS (`/ulak-explain vps`).
3. **İlk feature'ı TDD ile yaz**: `/ulak-test-driven`.
4. **Baseline health score**: `/ulak-audit-deep`.

---

*Son güncelleme: 2026-04-21 · v3.0.x · Beginner-first, TR-primary, Ulak OS standart beş-alan disiplininde.*
