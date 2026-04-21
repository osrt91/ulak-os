# Supabase Tutorial — Sıfırdan ilk Supabase projen

> **Amaç**: Ulak OS scaffold'u için gereken `NEXT_PUBLIC_SUPABASE_URL` +
> `NEXT_PUBLIC_SUPABASE_ANON_KEY` + `SUPABASE_SERVICE_ROLE_KEY` + `DATABASE_URL`
> değerlerini **15 dakikada** elde edersin, migration'ları Supabase'e push'larsın,
> ilk admin kullanıcıyı yaratırsın. Bu rehberden çıktığında `/ulak-next-steps`
> Adım 3.1 + 3.2 + 4 + 7'yi tamamlamış olursun.

> **Kime**: İlk kez Supabase'e kayıt olacak, terminal bilgisi temel seviyede
> ("`cd` ve `pnpm install` çalıştırabilirim") olan operatör. Postgres, RLS,
> JWT gibi terimler bilinmek zorunda değil — her biri yerinde kısaca açıklanır.

> **Ön koşul**: `/ulak-scaffold` ile proje üretmişsin, klasörde `supabase/`
> ve `.env.example` dosyaları var. Scaffold'u atladıysan: `docs/tutorials/README.md`
> §"Hangi sırayla".

---

## İçindekiler

1. Supabase nedir, neden bu?
2. Hesap açma (3 dk)
3. Organization + Project oluşturma (2 dk)
4. Project Settings → API (4 dk) — **KRİTİK BÖLÜM**
5. Migration push (3 dk)
6. Auth settings (2 dk)
7. İlk admin kullanıcı yaratma (2 dk)
8. RLS policies check (1 dk)
9. Sorun giderme

---

## 1. Supabase nedir, neden bu?

Supabase, **Postgres + auth + storage + realtime + edge functions** katmanlarını
tek hesapta sunan açık kaynaklı backend servisi. Firebase'in Postgres-tabanlı
alternatifi diye düşün — ama açık kaynak, SQL, ve istersen self-host edilebilir.

**Ulak OS neden Supabase default'u seçti?**

- **Postgres native**: tüm scaffold SQL migration'ları olduğu gibi çalışır; kendi
  sunucuna taşımak istersen aynı SQL çalışır (`self-hosted-supabase` sector pack).
- **RLS (Row Level Security) tablonun içine yerleşik**: multi-tenant SaaS için
  tenant izolasyonunu database katmanında zorlar — kod hatası data sızıntısına
  dönüşmez. Ulak scaffold'u RLS policy'leri migration'larla birlikte basar.
- **Auth dahil**: ayrı bir Auth0/Clerk entegre etmene gerek yok. JWT üretimi,
  session management, OAuth provider'lar (Google/GitHub/Apple) hepsi tek dashboard'da.
- **Free tier gerçekten yeterli** (MVP için): 500MB database, 50.000 monthly
  active user auth, 1GB storage, 2GB bandwidth, 50.000 Edge function invocation.
  Tipik küçük SaaS ilk 6 ay bu limitler altında kalır.
- **TR için uygun region**: Frankfurt (eu-central-1) datacenter ~30ms latency
  verir. US-East'e gitmek zorunda değilsin.

**Ne alternatif var?**

| Alternatif | Artısı | Eksisi |
|---|---|---|
| Firebase (Google) | Olgun, Google ekosistemi | NoSQL, SQL migration'ları çalışmaz, vendor-lock |
| Neon + Clerk + S3 | Daha esnek stack | 3 servis yönet, Ulak scaffold bu kombinasyon için hazır değil |
| Self-hosted Postgres + NextAuth | Tam kontrol | Operasyon yükü ciddi; hobby projesi değil |
| PlanetScale (MySQL) | Excellent DX | MySQL + non-standart RLS yok |

**Ulak kararı**: Scaffold'u basitleştirmek ve tek governance surface üretmek
için default Supabase. Self-host'a geçmek istediğinde aynı SQL çalışır
(`docs/runbooks/selfhost-backup-restore.md`).

---

## 2. Hesap açma (3 dk)

1. Tarayıcıda aç: **https://supabase.com/dashboard/sign-up**
2. İki seçenek:
   - **"Continue with GitHub"** (önerilir) — Ulak OS workflow'u zaten Git
     tabanlı; GitHub hesabınla tek tık giriş. İzinler: email adresi + public
     profile. GitHub'da hesabın yoksa önce **https://github.com/signup** (2 dk).
   - **Email + password** — klasik kayıt. Email confirmation link gelir,
     tıkla. 2 dk ekstra.
3. İlk girişte "Welcome to Supabase" ekranı → **"Create your first project"**
   butonu ile Adım 3'e geç.

**Dikkat notları**:
- GitHub OAuth ile giriş yaptıysan, şifre koymazsın — bir sonraki girişte de
  "Continue with GitHub" kullanırsın. Email değiştirmek istersen
  Account Settings'ten "Connect a new email" akışı var.
- İki faktörlü kimlik doğrulamayı (2FA) hesap açılır açılmaz kur —
  Account Settings → Security → Enable 2FA. Authenticator app (Google
  Authenticator / 1Password / Authy) gerekir. Bu çok önemli; service-role
  key'in hesap takip edilebiliyor.

---

## 3. Organization + Project oluşturma (2 dk)

Supabase'te yapı: **Organization** > **Project** > **Database**. İlk girişte
Supabase default bir organization açar ("<kullanıcı-adın>'s Org"), içine
projeni koyarsın.

### 3.1 Organization'ı onayla veya yeniden adlandır

- Sol üst köşedeki organization dropdown'a tıkla.
- Default ismi kullanabilirsin, veya "New organization" ile şirket ismi
  oluştur (örn. `my-saas-llc`). **Hangisini seçersen seç, ücret aynı
  (Free tier).**

### 3.2 Project oluşturma

Dashboard ana ekranında **"New project"** tıkla. Form şunları ister:

| Alan | Ne yaz | Dikkat |
|---|---|---|
| **Name** | `my-saas-dev` | Development için `-dev` suffix koy. Production için ayrı project: `my-saas-prod`. |
| **Database Password** | Güçlü şifre (20+ karakter) | **KAYIT ET!** Password manager'a yapıştır. Recovery için kullanılacak, unutursan reset edemezsin. |
| **Region** | **Frankfurt (eu-central-1)** | TR'den ~30ms latency. US-East'e gitme; 150ms+ olur. |
| **Pricing Plan** | **Free** | Başlangıç için yeterli. Production'da Pro'ya ($25/ay) geçersin. |

### 3.3 Neden `-dev` + `-prod` iki proje?

- **İzolasyon**: development'ta yanlışlıkla production data'yı silmezsin.
- **Key hygiene**: dev key'leri devasa bir hata (örn. `.env.local` git'e
  push'landı) olursa sadece dev data etkilenir.
- **Anti-pattern AP-08** (sandbox ↔ live env switch): Ulak OS bu ayrımı
  zorunlu kılar; `docs/runtime/rule-packs/api-security.md` detay.

**"Create new project"** tıkla → 2 dakika database provisioning bekle.
Yeşil "Project is ready" yazısı görünce Adım 4'e geç.

---

## 4. Project Settings → API (4 dk) — KRİTİK BÖLÜM

Bu 3 değeri `.env.local`'a yazacağız. Her değeri **Supabase dashboard'dan
kopyala → terminal/editör'de `.env.local` dosyasına yapıştır**.

### 4.0 .env.local'i aç

Proje klasöründe terminal aç ve editör'de `.env.local`'i aç:

```bash
cd my-saas-project   # scaffold'un ürettiği dizin
cp .env.example .env.local   # henüz yapmadıysan
code .env.local      # VS Code
# veya: nano .env.local
```

`.env.local` içinde placeholder satırları göreceksin:

```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
DATABASE_URL=
```

### 4.1 Project URL

**Supabase dashboard yolu**: Sol menü → ⚙️ **Project Settings** → **API**.

İlk kart: **"Project URL"**. `https://xxxxxxxxxxxxxxxxxxxx.supabase.co` formatında.

- Kopyala butonu (📋 ikon) var → tıkla.
- `.env.local`'a yapıştır:

```
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxxxxxxxxxx.supabase.co
```

**Not**: `NEXT_PUBLIC_` prefix'i, bu değerin browser'a gönderilmesine Next.js'in
izin vermesi anlamına gelir. URL zaten public bir domain — sır değil.

### 4.2 Anon / Public Key (client-safe)

**Aynı ekran**: "Project API keys" kartı → iki satır:

- Birinci satır: `anon` `public` etiketli. Bu **client-safe** key.
- Değer `eyJhbGciOiJIUzI1...` diye başlayan uzun bir JWT string.

Kopyala → `.env.local`'a yapıştır:

```
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1...
```

**⚠️ Bu key client-side expose edilir — RLS policy'leri koruyor.**
Anon key'in tek başına bir zararı yok; Supabase, gelen istekleri **RLS
(Row Level Security)** policy'leri üzerinden filtreliyor. Ulak scaffold'un
ürettiği migration'lar her tenant tablosunda RLS'i enable ediyor.
Ayrıntı için `/ulak-explain rls`.

### 4.3 Service Role Key (server-only, GİZLİ)

**Aynı ekran**: ikinci satır → `service_role` `secret` etiketli.

- Default'ta gizli. **"Reveal"** düğmesi var → tıkla, key göstersin.
- Kopyala → `.env.local`'a yapıştır:

```
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1...
```

**⚠️ UYARILAR — buradaki disiplini atlama**:

- `service_role` key **RLS'i bypass eder** — tüm satırları okur, yazar, siler.
  Bu key leak olursa tüm database'in açık.
- **ASLA GIT'E COMMIT ETME**. `.env.local` zaten `.gitignore`'da; ama yanlışlıkla
  `.env` veya `app/config.ts`'e yapıştırırsan pushlanır. Commit'ten önce
  `git status` kontrol et; `gitleaks` pre-push hook'u scaffold'da var (Adım 9).
- **ASLA client-side kod'a (React component, lib/client/*) koyma**. Sadece
  server-side kod (Next.js server action, API route, middleware, edge function)
  kullanabilir. Ulak scaffold'da `lib/supabase/server.ts` bu key'i okur;
  `lib/supabase/client.ts` sadece anon key kullanır.
- Key leak ettiyse: Supabase dashboard → Project Settings → API → "Reset"
  düğmesi. Yeni key gelir, eski key o anda geçersiz olur.

### 4.4 Database URL (`DATABASE_URL`)

Bu `API` ekranında değil, **Database** ekranında:

**Dashboard yolu**: Sol menü → ⚙️ **Project Settings** → **Database** → "Connection string" bölümü.

Üç tab var: **URI**, **PSQL**, **.NET** (ve diğerleri). **URI** sekmesini seç.
Format:

```
postgresql://postgres.xxxxxxxxxxxxxxxxxxxx:[YOUR-PASSWORD]@aws-0-eu-central-1.pooler.supabase.com:5432/postgres
```

- Kopyala → `.env.local`'a yapıştır:

```
DATABASE_URL=postgresql://postgres.xxxxxxxxxxxxxxxxxxxx:[YOUR-PASSWORD]@aws-0-eu-central-1.pooler.supabase.com:5432/postgres
```

- **`[YOUR-PASSWORD]` placeholder'ını Adım 3.2'de kaydettiğin database
  password'le değiştir.** Bunu unutursan migration push kırılır.

**Connection Pooler mı, Direct mi?** Dashboard'da iki seçenek gösterebilir:
- **Session pooler** (default, port 5432) — genel kullanım.
- **Transaction pooler** (port 6543) — serverless deploy'lar için (Vercel
  functions). Next.js + Vercel kullanıyorsan transaction pooler daha uygun.
- Emin değilsen **session pooler**'ı bırak; Ulak scaffold ikisiyle de çalışır.

### 4.5 Değerleri kontrol et

`.env.local` son hâli:

```
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxxxxxxxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
DATABASE_URL=postgresql://postgres.xxxxxxxxxxxxxxxxxxxx:MY_DB_PASSWORD@aws-0-eu-central-1.pooler.supabase.com:5432/postgres
```

Dört değer de doldu mu? Evet → Adım 5.

---

## 5. Migration push (3 dk)

Scaffold, `supabase/migrations/` altında SQL migration dosyaları üretti
(sector'a göre 3-7 dosya). Bunları Supabase projeye uygulamak için iki yol:

### 5.1 Yol A — Supabase CLI (önerilen)

Scaffold'un ürettiği `package.json`'da zaten `supabase:push` script'i var.
Önce CLI'yi projene bağla:

```bash
# project ref = dashboard URL'inde / sonrasındaki 20 karakter
# örn: supabase.com/dashboard/project/xxxxxxxxxxxxxxxxxxxx
npx supabase link --project-ref xxxxxxxxxxxxxxxxxxxx

# sonra push
pnpm supabase:push
# veya doğrudan:
npx supabase db push
```

**Terminal ne göstermeli**: her migration dosyası için `Applied` satırı.
Hata alırsan Adım 9'a bak.

### 5.2 Yol B — Supabase Studio SQL Editor (manuel)

CLI çalışmazsa (corporate network, Docker eksik, vs.):

1. Dashboard → sol menü → **SQL Editor**.
2. **"+ New query"**.
3. Editör'de `supabase/migrations/00001_initial_schema.sql` dosyasının
   tüm içeriğini kopyala → SQL Editor'a yapıştır.
4. **"Run"** (Ctrl+Enter).
5. Yeşil "Success" görmeli. Hata varsa output panel'de SQL hatası gösterir.
6. **Her migration dosyası için tekrarla** — `00001_...`, `00002_...`,
   `00003_...` **dosya adı sırasıyla**. Sırayı bozma; `00005_admin_tools_schema.sql`
   genellikle `00001_init`'e bağımlıdır.

### 5.3 Push doğru mu oldu?

Dashboard → sol menü → **Database** → **Tables**.

Listede scaffold'un ürettiği tablolar olmalı:
- `profiles` (tüm projeler)
- `tenants` (multi-tenant scaffold'da)
- `products` / `orders` (marketplace/ecommerce sector'de)
- diğer sector-spesifik tablolar

Tablo listesi boşsa migration çalışmadı → Adım 9.

---

## 6. Auth settings (2 dk)

Dashboard → sol menü → **Authentication** → **Providers**.

### 6.1 Email Provider (default)

Varsayılan olarak enable (✓). Yapman gereken tek şey:

- **"Confirm email"** toggle'ı: development için **off** bırakabilirsin
  (her test kullanıcı için email doğrulama beklemezsin). Production'da
  **on** yap.

### 6.2 Google OAuth (opsiyonel)

`/ulak-start` wizard'ında Google login'i aktif ettiysen:

- **Google** satırına tıkla.
- Enable toggle.
- **Client ID** ve **Client Secret** ister. Bu değerleri **Google Cloud
  Console**'dan alacaksın (ayrı bir ~30 dk iş):
  1. https://console.cloud.google.com → proje oluştur.
  2. "APIs & Services" → "Credentials" → "Create Credentials" →
     "OAuth 2.0 Client ID".
  3. Application type: **Web application**.
  4. Authorized redirect URIs:
     `https://xxxxxxxxxxxxxxxxxxxx.supabase.co/auth/v1/callback`
     (kendi project URL'inle değiştir)
  5. Client ID + Client Secret'i Supabase Google provider formuna yapıştır.
- Toggle'ı aç → **Save**.

GitHub / Apple / diğer provider'lar için benzer akış; Supabase dokümantasyonu
her biri için adım listeli.

### 6.3 Email templates (opsiyonel, production için)

- **Authentication** → **Email Templates** → password reset, magic link,
  confirm signup şablonlarını markayla düzenleyebilirsin.
- Default'ı bırakırsan Supabase markalı email gider — MVP için kabul
  edilebilir.

---

## 7. İlk admin kullanıcı yaratma (2 dk)

Kullanıcı sign-up akışı scaffold'da çalışıyor, ama **ilk admin'i sen elle
yaratacaksın** (çünkü henüz kimse admin değil, UI'dan promote edilemez).

### 7.1 Kullanıcı oluştur

Dashboard → **Authentication** → **Users** → sağ üst **"Add user"** →
**"Create new user"**:

- **Email**: kendi email'in (veya test@example.com).
- **Password**: güçlü şifre (10+ karakter).
- **Auto Confirm User**: ✓ (işaretle; confirmation email beklemesin).

**"Create user"** tıkla. Kullanıcı listesinde görünür.

### 7.2 Profile satırı oluştu mu kontrol et

Scaffold genelde `auth.users` insert'ine trigger ekler — otomatik
`public.profiles` satırı oluşur. Kontrol et:

- Dashboard → **Table Editor** → **profiles** tablosunu aç.
- Yeni kullanıcının UUID'siyle bir satır olmalı.
- Yoksa, trigger çalışmamış — migration'ı tekrar kontrol et (Adım 5).

### 7.3 Rolü admin yap

- Kullanıcının **UUID**'sini `auth.users` tablosundan kopyala (`id` kolonu).
- SQL Editor'a geç:

```sql
UPDATE public.profiles
SET role = 'admin'
WHERE id = '<yapıştır-uuid>';
```

- **Run**.
- Profiles tablosunda rolün `admin` olduğunu doğrula.

### 7.4 Scaffold alternatifi

Scaffold bir `scripts/seed-admin.ts` ürettiyse, terminalden:

```bash
pnpm seed:admin -- --email you@example.com
```

yazıp otomatik olarak yapabilirsin. `package.json` `scripts` bölümünü
kontrol et.

**⚠️ Anti-pattern AP-06** (admin-role-re-read): Ulak scaffold role'ü
`auth.users.user_metadata`'da değil, `public.profiles.role` kolonunda
tutar ve **her istekte fresh okur**. Burada `profiles`'ı güncellemek
yeterli — JWT'de role cache'lenmez.

---

## 8. RLS policies check (1 dk)

Dashboard → **Database** → **Tables** → her tablonun satırında
**"RLS enabled"** ✓ görmelisin (Ulak migration'ı zaten enable etti).

- Bir tabloya tıkla → **"Policies"** sekmesi → policy listesi gösterilir.
  Tipik policy'ler:
  - `tenant_isolation_select` — kullanıcı sadece kendi tenant'ının satırlarını görür.
  - `owner_write` — sadece owner update/delete edebilir.
  - `admin_bypass` — admin role'ü full access (service_role bypass'ı ayrı katman).
- Policy yoksa scaffold migration'ı eksik kalmış → Adım 5'i tekrarla.

**RLS test etmek için** (bonus):

- SQL Editor'da:

```sql
SELECT * FROM products;  -- service_role ile hepsini görürsün
```

- App'te (pnpm dev açıkken): anon key ile istek atarsan sadece kendi
  satırlarını görürsün.

RLS derinleştirmek için: `docs/governance/product-surface-split.md` +
`/ulak-explain rls`.

---

## 9. Sorun giderme

### "Invalid API key" hatası

- `.env.local`'a yanlış key yapıştırdın. Adım 4'ü tekrarla.
- `NEXT_PUBLIC_SUPABASE_URL` sonunda `/` olmamalı.
- Key'lerde baştan/sondan boşluk var mı kontrol et (`xxd` ile bit bazlı
  kontrol gerekebilir).
- Dev server'ı yeniden başlat: `.env.local` değişikliği hot-reload etmez,
  `pnpm dev`'i durdurup tekrar başlat.

### "Connection refused" / migration push kırılır

- `DATABASE_URL`'deki `[YOUR-PASSWORD]` placeholder'ını gerçek şifreyle
  değiştirdin mi? (Adım 4.4)
- Password'de özel karakter (`@`, `#`, `/`) varsa URL-encode et:
  `@` → `%40`, `#` → `%23`.
- Network bloke olabilir (corporate VPN) — 5432 portu açık mı?

### "relation does not exist" hatası

- Migration'lar sırayla push'lanmadı — daha geç bir migration erken çalıştı.
- Çözüm: Supabase dashboard → **Database** → **Tables** → tüm `public.*`
  tabloları sil → migration'ları en baştan push'la (Yol A veya Yol B).
- **Uyarı**: production'da bunu yapmazsın; dev ortamında sıkıntısız.

### "Auth session missing" login sonrası

- Browser cookie'leri temiz mi? Supabase session cookie'ye yazıyor;
  third-party cookie block eden browser setting varsa kırılır.
- `NEXT_PUBLIC_SUPABASE_URL` ile app'in URL'si farklı origin'de mi?
  Scaffold varsayımı: ikisi de `localhost:3000` veya ikisi de
  `siten.com`.

### Google OAuth "redirect_uri_mismatch"

- Google Cloud Console'daki authorized redirect URI tam eşleşmeli:
  `https://xxxxxxxxxxxxxxxxxxxx.supabase.co/auth/v1/callback`.
- Trailing slash yok, http yerine https, `/auth/v1/callback` path.

### Free tier limitlerine yaklaştım

- Dashboard → **Reports** → usage göster.
- Database size >400MB: eski data'yı archive table'a taşı veya Pro'ya yükselt ($25/ay).
- Auth MAU >40.000: büyük başarı; artık Pro tier kaçınılmaz.

### Başka sorun

- `docs/runbooks/troubleshooting.md` §Supabase bölümüne bak.
- `/triage-build` komutu Next.js + Supabase hatalarını otomatik triaj eder.
- Supabase Discord topluluğu: https://discord.supabase.com (hızlı).

---

## Bundan sonra

`/ulak-next-steps` komutuna geri dön:

- **Adım 5** (seed data) — `pnpm seed` çalıştır.
- **Adım 6** (dev server) — `pnpm dev` → `http://localhost:3000`.
- **Adım 8** (admin panel) — `http://localhost:3000/admin` → yukarıda yarattığın email + password ile gir.

Deploy aşamasına geldiğinde: `docs/tutorials/vercel.md` (Vercel ile canlıya alma)
veya `docs/runbooks/selfhost-backup-restore.md` (kendi VPS'ine).

---

*Bu dokümanın referans UI'ı 2024-2026 stabil Supabase Dashboard'udur.
UI değişikliği fark edersen PR aç: `docs/tutorials/supabase.md`.*
