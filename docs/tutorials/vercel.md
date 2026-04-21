# Vercel Tutorial — Next.js projeni 10 dakikada canlıya al

> **Amaç**: Ulak scaffold ettiğin Next.js projeni `git push` → otomatik deploy
> → `<project>.vercel.app` domain ile **10 dakikada** canlıya al. Opsiyonel
> olarak kendi `siten.com` domain'ini bağla, HTTPS otomatik gelsin.

> **Kime**: İlk kez deploy yapacak, GitHub'da repo'su olan operatör.
> Domain satın almadıysan da olur — Vercel ücretsiz subdomain verir.

> **Ön koşul**: `/ulak-scaffold` + `docs/tutorials/supabase.md` tamamlandı,
> `localhost:3000`'de site açılıyor, GitHub'a push'ladın (veya push'layacaksın).

---

## İçindekiler

1. Vercel nedir?
2. Hesap açma (3 dk)
3. Vercel ↔ GitHub bağlama (2 dk)
4. Project import (3 dk)
5. Environment variables (5 dk) — **KRİTİK BÖLÜM**
6. Deploy (1 dk)
7. Custom domain bağlama (10 dk — opsiyonel)
8. Preview deploy + CI
9. Sorun giderme

---

## 1. Vercel nedir?

Vercel = **Next.js'in yaratıcısı şirket**. Next.js'i en sorunsuz deploy eden
platform — zaten framework'u yazan ekip. Git repo bağlarsın, her `git push`
otomatik deploy olur.

**Ulak OS neden Vercel default'u sunar?**

- **Sıfır config**: Next.js'i auto-detect eder, build command + output
  directory kendi anlar.
- **Preview deploys**: her pull request ayrı bir ephemeral URL'e deploy
  olur; PR reviewer'a "şuna bak" diyebilirsin.
- **Serverless by default**: function'lar ve edge middleware otomatik
  ölçeklenir; traffic spike'ı sen yönetmezsin.
- **Free tier gerçekten kullanılır**: hobby projeleri için bandwidth,
  build dakikası, deploy sayısı limitli ama yeterli. Kredi kartı istemez.
- **HTTPS otomatik**: Let's Encrypt SSL sertifikası her domain için, setup
  yok.

**Ne alternatif var?**

| Alternatif | Artısı | Eksisi |
|---|---|---|
| Netlify | Benzer DX, static site odaklı | Next.js server features için Vercel daha iyi |
| AWS Amplify | Enterprise, AWS stack içinde | Config karmaşık; Next.js features geride |
| Cloudflare Pages | Edge network hızlı, ucuz | Next.js SSR için workaround gerekir |
| **Kendi VPS + Traefik** | Tam kontrol, $5/ay fixed cost | Ops yükü: server bakımı, SSL rotation, monitoring |

**Ulak kararı**: Beginner için Vercel default, çünkü 10 dakikada canlıya
çıkarır. Kontrol/bütçe isteyen operatör `docs/runbooks/vps-deploy.md`'ye
geçer (VPS + Traefik + Docker Compose pattern'i scaffold içinde hazır —
`--deploy vps` flag'i).

**Vercel ne zaman terk edilmeli?**

- Trafik çok büyük (aylık $20+ bandwidth ücreti biriktiğinde VPS ucuzlar).
- Hassas data + residency zorunlu (KVKK kapsamı için TR-based VPS
  gerekebilir; Vercel US/EU edge'lerde serve eder).
- Custom networking (VPN, private network) gerekiyor.

---

## 2. Hesap açma (3 dk)

1. Tarayıcıda aç: **https://vercel.com/signup**
2. **"Continue with GitHub"** — önerilir (Ulak OS workflow'u zaten Git
   tabanlı).
   - GitLab / Bitbucket da seçenek; GitHub en sorunsuz.
   - Hiç GitHub hesabın yoksa: https://github.com/signup (2 dk), sonra
     dön buraya.
3. GitHub "Authorize Vercel" ekranı → izinler:
   - **Email address** (primary email okuma)
   - **Read access to all public repos**
   - Private repo için Adım 3'te ayrıca install var; bu adımda sadece
     login yap.
4. İlk giriş → Welcome ekranı → **"Continue"**.
5. **Free plan** seçili gelir. Kredi kartı ister değil. Devam et.

**Hesap isimlendirme**: Vercel sana bir **team scope** verir — default
adın (GitHub username'in). Team name'i sonra değiştirebilirsin; başta
atla.

---

## 3. Vercel ↔ GitHub bağlama (2 dk)

Signup sonrası veya dashboard → **"Add New..."** → **"Project"** →
**"Import Git Repository"** tıkla.

### 3.1 GitHub App install

İlk kez: "Install Vercel" butonu çıkar. Tıkla → GitHub'a yönlendirir:

- **"Only select repositories"** (önerilir) — güvenlik: Vercel sadece
  deploy edeceğin repo'ya erişir.
- Veya **"All repositories"** — tüm repo'larına erişim (hızlı ama geniş).

Başta **tek repo** seç (scaffold ettiğin proje), sonra lazım olursa ekle.

### 3.2 Repo listesi

Vercel ekranında GitHub repolarının listesi gelir. Scaffold ettiğin projeyi
bul. Yoksa:

- Henüz GitHub'a push'lamadın mı? Terminal'de:
  ```bash
  cd my-saas-project
  git remote add origin git@github.com:<kullanici>/my-saas-project.git
  git push -u origin main
  ```
- "Adjust GitHub App Permissions" linki → erişime yeni repo ekle.

Repo satırında **"Import"** tıkla.

---

## 4. Project import (3 dk)

Vercel formu:

| Alan | Değer | Not |
|---|---|---|
| **Project Name** | `my-saas-project` (default repo adı) | Bu `<name>.vercel.app` subdomain'ini belirler. |
| **Framework Preset** | **Next.js** (auto-detect) | Eğer auto-detect olmazsa manuel seç. |
| **Root Directory** | `./` | Monorepo ise `./apps/web` gibi spesifik. |
| **Build Command** | `pnpm build` (auto) | Ulak scaffold pnpm kullanır. |
| **Output Directory** | `.next` (auto) | Next.js default. |
| **Install Command** | `pnpm install` (auto) | |
| **Node.js Version** | 18.x veya 20.x | Default 20.x (Ulak scaffold test edilmiş). |

### 4.1 Monorepo varsa

Ulak scaffold default monorepo değil, ama `/ulak-scaffold` seçiminde
`multi-app-nextjs-expo-monorepo` sector'ü aktif ettiyseniz:

- **Root Directory**: `apps/web` olarak ayarla.
- Vercel ayrıca **"Ignored Build Step"** field'ı ekler — `turbo run build --filter=web`
  gibi. Scaffold Turbo config üretmişse otomatik algılar.

### 4.2 "Deploy" düğmesine ŞİMDİ basma

Env var'ları önce gir (Adım 5), sonra deploy et. Aksi halde build env var
olmadan fail eder.

---

## 5. Environment variables — KRİTİK BÖLÜM (5 dk)

Vercel formunda aşağıda **"Environment Variables"** bölümü var. `+` ile
key-value çiftleri eklersin.

Her değişken için **3 scope**:

- **Production** — `main` branch push'larında + production deploy'larda okunur.
- **Preview** — feature branch push'larında + PR preview'larında okunur.
- **Development** — `vercel dev` lokalde çalıştırırsan (nadir).

Aşağıdaki tablo scaffold'un ihtiyaçları; değerleri `.env.local`'dan kopyala.

### 5.1 Supabase var'ları

| Key | Scope | Kaynak |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Production + Preview | `.env.local` → Adım 4.1 (Supabase tutorial) |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Production + Preview | `.env.local` → Adım 4.2 |
| `SUPABASE_SERVICE_ROLE_KEY` | **Production only** (Sensitive ✓) | `.env.local` → Adım 4.3 |
| `DATABASE_URL` | Production only (Sensitive ✓) | `.env.local` → Adım 4.4 |

- `NEXT_PUBLIC_` prefix'li olanlar client'a gider — sır değil, RLS koruyor.
- `SUPABASE_SERVICE_ROLE_KEY` ve `DATABASE_URL` **Sensitive** işaretle
  (form'da checkbox var). Vercel UI'da bu değerler maskelenir.
- Preview scope'a service-role key koyma — her PR ortamında üretilen
  preview URL'inde leak riski artar. Preview için ayrı dev Supabase
  project kullan.

### 5.2 Payment var'ları (eğer `--payment iyzico`)

| Key | Scope | Kaynak |
|---|---|---|
| `IYZICO_API_KEY` | Production only (Sensitive) | Iyzico merchant panel → Production API keys |
| `IYZICO_SECRET_KEY` | Production only (Sensitive) | Iyzico merchant panel → Production API keys |
| `IYZICO_BASE_URL` | Production | `https://api.iyzipay.com` (live) |

Preview ortamı için ayrı set — Iyzico'nun sandbox key'leriyle:

| Key | Scope | Value |
|---|---|---|
| `IYZICO_API_KEY` | Preview | `sandbox-...` |
| `IYZICO_SECRET_KEY` | Preview | `sandbox-...` |
| `IYZICO_BASE_URL` | Preview | `https://sandbox-api.iyzipay.com` |

**Anti-pattern AP-08** (sandbox ↔ live switch): production env'de
**asla** sandbox key kullanma — gerçek ödemeler sandbox'a gidip kaybolur.

### 5.3 Email var'ları (eğer `--email resend`)

| Key | Scope | Kaynak |
|---|---|---|
| `RESEND_API_KEY` | Production only (Sensitive) | Resend dashboard → API Keys |
| `EMAIL_FROM` | Production | `noreply@siten.com` (domain verify sonrası) veya `onboarding@resend.dev` (verify önce) |

### 5.4 Ekleme adımı

Her key için:
1. **Key** alanına key adı.
2. **Value** alanına değer (yapıştır).
3. Scope seçicisi: Production / Preview / Development üç checkbox; ilgili olanları işaretle.
4. Sensitive ise "Sensitive" toggle'ı aç (mask edilsin).
5. **Add** tıkla.

Tüm var'ları ekledikten sonra sayfada "X Environment Variables" yazıyor olmalı.

### 5.5 Post-deploy env değiştirme

Proje deploy olduktan sonra env eklemek/değiştirmek için:

- Dashboard → Project → **Settings** → **Environment Variables**.
- Değişiklik yaptıktan sonra **"Deployments"** → son deploy'un yanındaki
  3-nokta menü → **"Redeploy"** → **"Use existing Build Cache"** seçili
  **kapalı** (env değişti, yeniden build lazım) → **"Redeploy"**.

---

## 6. Deploy (1 dk)

Form doldu mu? **"Deploy"** düğmesine bas.

- Build başlar. Konsol log'u ekranda gösterilir. Tipik süre: 60-120 saniye.
- Tipik fazlar:
  1. "Cloning repository" (5 sn)
  2. "Installing dependencies" (30-60 sn)
  3. "Building" (30-60 sn) — Next.js build + static optimization
  4. "Deploying" (5 sn)
- Yeşil **"Deployment successful"** → tebrikler.

Ekranda iki link gösterilir:
- `<project-name>-<hash>.vercel.app` — bu deploy'a özel (ephemeral hissi).
- `<project-name>.vercel.app` — production alias, hep son deploy'a bağlı.

İkincisini aç → siten canlıda.

### 6.1 İlk testler

- Landing page yükleniyor mu?
- `/login` sayfası açılıyor mu?
- Login dene — Supabase Adım 7'de yarattığın admin kullanıcı ile gir.
- Login olduysa → cookie + RLS doğru çalışıyor.
- 500 hata alırsan → Adım 9.

---

## 7. Custom domain bağlama (10 dk — opsiyonel)

`.vercel.app` subdomain yeterliyse Adım 8'e atla. Kendi `siten.com`
domain'in varsa:

### 7.1 Vercel'de domain ekle

- Dashboard → Project → **Settings** → **Domains** → **"Add"**.
- Domain'i yaz: `siten.com` → **"Add"**.

Vercel sana **2 DNS record** söyler. İki seçenek:

**Seçenek A — apex (`siten.com`) + www**:
- **A record**: `@ → 76.76.21.21`
- **CNAME**: `www → cname.vercel-dns.com`

**Seçenek B — sadece subdomain (`app.siten.com`)**:
- **CNAME**: `app → cname.vercel-dns.com`

### 7.2 DNS sağlayıcına git

Domain'i nereden aldıysan (GoDaddy, Namecheap, Cloudflare, Google
Domains, TR.net, vb.):

- Domain yönetimi → DNS Management / DNS Records.
- **"Add record"** ile yukarıdaki 2 kaydı gir.
- **TTL**: 3600 (1 saat) veya Auto.

### 7.3 Propagation bekle

- Yeni DNS kaydı tüm dünyaya dağılması 15 dk - 24 saat sürebilir.
- `dig siten.com` veya https://dnschecker.org ile kontrol et.
- Vercel dashboard → Domains sayfası yeşil ✓ verince bağlantı tamam.

### 7.4 HTTPS

Vercel **Let's Encrypt** SSL sertifikasını otomatik verir. Kaç dakika
sürer (birkaç dk). Dashboard'da "Valid Configuration" + "HTTPS" yeşil
olunca https://siten.com açılır.

### 7.5 www redirect

Vercel default olarak apex (`siten.com`) ve `www.siten.com` iki domain
olarak ekler. Biri diğerine redirect edecek. Dashboard → Domains →
hangisini primary yapmak istersen "Redirect to" ayarla.

---

## 8. Preview deploy + CI

Bir sonraki push'ta gör:

```bash
git checkout -b feature/new-landing
# dosya değiştir
git commit -am "feat: new landing hero"
git push origin feature/new-landing
```

GitHub'da PR aç. Vercel bot otomatik:

1. PR'a bir **check** ekler ("Deploying...").
2. 60-90 sn sonra **preview URL** paylaşır PR comment'inde
   (`<project>-<hash>-<username>.vercel.app`).
3. "Visit Preview" → değişiklikleri gör.
4. PR'a review yapıp merge edince → `main`'e gider → otomatik production
   deploy → `siten.com` güncellenir.

### 8.1 Build cache

Vercel her build'i önceki build cache ile hızlandırır. Temiz build
istersen:

- Dashboard → Deployments → 3-nokta → **"Redeploy"** → "Use existing
  Build Cache" **off** → Redeploy.

### 8.2 Rollback

Bozuk deploy canlıda mı? Dashboard → Deployments → iyi olan bir önceki
deploy → 3-nokta → **"Promote to Production"**. Anlık olarak `siten.com`
eski deploy'a döner. Risk yok — bozuk deploy hala arşivde durur, tekrar
promote edebilirsin.

---

## 9. Sorun giderme

### Build error: "Module not found"

- Package.json'a dependency eklemedin, sadece `node_modules`'a kurdun.
- Çözüm: `pnpm add <paket>` → `git add package.json pnpm-lock.yaml` → push.

### Build error: "Type error in ..."

- TypeScript strict mode aktif, local'de `pnpm build` çalıştır, aynı
  hatayı alırsın — düzelt, push.

### Deploy success ama sayfa 500

- Env var eksik/yanlış. Deployment log'una bak: sağda "Function Logs".
- `SUPABASE_URL` veya `SERVICE_ROLE_KEY` Production scope'ta set edilmiş mi?
- Fix: Settings → Environment Variables → eksik olanı ekle → Redeploy.

### Preview deploy `.env.local` değerlerini okumuyor

- `.env.local` Vercel'e yüklenmez (git'te değil).
- Preview için ayrı env var set etmelisin (Adım 5.1 tablosu).

### Custom domain "Invalid Configuration"

- DNS kayıtları henüz propagate olmadı. Bekle (15 dk - 24 saat).
- `dig siten.com A` ile test et; Vercel'in IP'si (76.76.21.21) döndüğünde çözüldü.

### Free tier limitine yakın

- Dashboard → Usage → Bandwidth / Build Minutes / Function Invocations.
- 100GB bandwidth / ay hobby plan limiti. Aşarsan Pro Plan ($20/ay).

### Function timeout

- Vercel Hobby: 10 sn function timeout. Pro: 60 sn.
- Uzun iş background job'a taşı (cron, queue).

### "Command failed: pnpm install"

- Scaffold'un `package.json`'ında `packageManager` field'ı yanlış
  Node version istiyor olabilir.
- Vercel Settings → General → Node.js Version → 20.x (Ulak scaffold test
  edilmiş).

### Başka sorun

- `docs/runbooks/troubleshooting.md` §Vercel bölümü.
- Vercel'in kendi doc'u: https://vercel.com/docs.
- `/triage-build` komutu Vercel build log'larını Claude Code'a verip
  otomatik triaj eder.

---

## Bundan sonra

- **Monitoring**: Vercel → Analytics tab → free tier'da 2500 event/ay.
- **Error tracking**: Ulak scaffold `lib/observability/` içinde Sentry
  adapter hazır (env var ile aktive edilir).
- **Custom domain + email**: Domain verified sonra Resend'de
  `siten.com` domain'ini ekle, DKIM/SPF record'ları gir, email
  gönderimlerin kendi domain'inden çıksın.

VPS'e geçiş düşünüyorsan: `docs/runbooks/vps-deploy.md` (Traefik +
Docker Compose pattern; `--deploy vps` flag'iyle scaffold bu dosyaları
zaten ürettiyse hazır).

---

*Bu dokümanın referans UI'ı 2024-2026 stabil Vercel Dashboard'udur.
UI değişikliği fark edersen PR aç: `docs/tutorials/vercel.md`.*
