# Walkthrough #1 — Sıfırdan ilk SaaS'a uçtan uca

> **Kime**: Ulak OS'a ilk kez giren, hiç SaaS yapmamış bir kullanıcı.
> **Süre**: 75-90 dakika (okuma + uygulama).
> **Sonuç**: GitHub'da repo, Vercel'de canlı URL, Supabase'de database, Resend'den email gönderen, Iyzico test ödeme alan bir "ev temizlik hizmeti marketplace" sitesi.
> **Ön koşul**: Claude Code + Ulak OS kurulu (kurulum için `docs/runbooks/install-methods.md`).

## Senaryo

Ali küçük bir işletme açmak istiyor: müşteriler siteye gelsin, temizlik görevlisi seçsin, randevu alsın, kredi kartıyla ödesin. Görevliler siteye giriş yapsın, takvimlerini yönetsin. Ali admin olarak her şeyi görsün. Türkiye'de kullanılacak, TL ödeme, KVKK uyumlu. Ali'nin kod yazma tecrübesi sıfır — sadece HTML-CSS gördü bir-iki kere.

Bu walkthrough Ali'nin Ulak OS'u nasıl kullandığını adım adım gösterir.

---

## Bölüm 1 — Hazırlık (5 dk)

### 1.1 Terminal aç

```bash
# Windows: PowerShell veya Git Bash
# macOS/Linux: Terminal
```

### 1.2 Ulak OS kurulu mu kontrol et

```bash
ulak --version
# v1.4.0 gibi bir çıktı görmeli
```

Eğer `command not found` ise `docs/runbooks/install-methods.md` oku (5 dakikalık bir işlem).

### 1.3 Boş bir çalışma klasörü oluştur

```bash
mkdir ~/projeler
cd ~/projeler
```

Ali bu klasörde Claude Code'u açacak. Yeni projeleri bu dizinin altına kuracağız.

---

## Bölüm 2 — İlk keşif (2 dk)

Ali Claude Code'u `~/projeler` klasöründe açar. Ekranda boş bir prompt. Ne yapacağını bilmiyor. İlk hamlesi:

```
/ulak-hello
```

Ulak cevap verir:

```
═══════════════════════════════════════════════════════════
 Ulak OS — 30 saniyelik tour
═══════════════════════════════════════════════════════════

 Ulak OS nedir?

 (1) AI coding CLI'larının üstüne oturan prompt işletim sistemi.
 (2) Audit + governance + full-stack SaaS scaffolder — üçü bir arada.
 (3) Vendor-neutral (Claude / Codex / Gemini), tek çekirdek.

─ Örnek komutlar ──────────────────────────────────────────

   /director komple       Mevcut projeyi audit et (Phase 0-5).
   /ulak-start            Yeni SaaS başlat (6 soruluk wizard).
   /ulak-ask "<soru>"     Doğal dille sor, Ulak yönlendirsin.

─ Şimdi ne yapalım? ───────────────────────────────────────

   [1] Yeni SaaS yap                    -> /ulak-start
   [2] Mevcut projeyi audit et          -> /director komple
   [3] Doğal dille sor                  -> /ulak-ask "<query>"
   [4] Tüm kapasiteleri göster          -> /ulak-packs

 Cevabın: _
═══════════════════════════════════════════════════════════
```

Ali cevap verir: `1`

Ulak otomatik olarak `/ulak-start` komutuna geçer.

---

## Bölüm 3 — Sihirbaz (12 dk)

### Q0 — Mod seçimi

```
Ulak OS seni iki şekilde yönlendirebilir:

 [t] Teknik mod — Next.js, Supabase, SSO gibi terimlerle
                  hızlı ve net. Önceki tecrübe varsa bunu seç.
                  (default)

 [b] Basit mod  — "sitenin motoru" (stack), "giriş yöntemi" (auth)
                  gibi basitleştirilmiş sorularla. İlk kez site
                  yapıyorsan bunu seç.

Seçim: _
```

Ali: `b` (basit mod).

### Phase 1 — Proje kimliği (4 soru)

**Q1.1: Proje adı?**
```
(default=ulak-saas-20260421)
```
Ali: `temiz-gunler`

**Q1.2: Ne tür proje?**
Basit mod listede:
```
[1] Minimal web sitesi (tek kullanıcı tipi)
[2] E-ticaret (ürün katalogu + sepet)
[3] Eğitim platformu
[4] Fintech (banka işlem tarzı)
[5] İki taraflı site (sağlayıcı + müşteri — ör. kurye, usta, gezdirici)
[6] Kurumsal şirketler için (SSO + ekip yönetimi)
...
```
Ali: `5` (iki taraflı site)

**Q1.3: Kullanıcı ölçeği?**
```
[1] Solo proje (tek geliştiren)
[2] Küçük takım (2-5 kişi)
[3] Orta ölçek (5-20 kişi)
...
```
Ali: `2`

**Q1.4: Dil?**
```
[1] Türkçe (default)
[2] İngilizce
[3] İki dilli
[4] Çok dilli
```
Ali: `[enter]`

### Phase 2 — Teknik stack (6 soru)

Hepsinde Ali `[enter]` basar — default'lar Ali için uygun:

| Soru | Default | Ali'nin verdiği | Anlamı |
|---|---|---|---|
| Q2.1 Stack | Next.js+Supabase | [enter] | Web sitesi + hazır database |
| Q2.2 Auth | email+magic+google | [enter] | Üç giriş yolu açık |
| Q2.3 Database | Supabase managed | [enter] | Bulutta hazır DB |
| Q2.4 Payment | iyzico (TR region) | [enter] | TL kart ödeme |
| Q2.5 Storage | Supabase Storage | [enter] | Dosya yükleme hazır |
| Q2.6 Email | Resend | [enter] | Transactional email |

### Phase 3 — Sektör derinliği (marketplace için 3 soru)

**Q3.1: Komisyon oranı?**
```
Her satıştan platformun aldığı pay (%). 
default=0.10 — "%10 = 100 TL'den 10 TL platform, 90 TL görevli"
```
Ali: `[enter]` → %10

**Q3.2: Escrow (ödeme askıda)?**
```
Para müşteriden alınır ama iş bitene kadar platformda bekler,
iş bittiğinde görevliye ödenir. Anlaşmazlık güvencesi.
default=hayır (basit akış önerilen)
```
Ali: `e` (evet, güven için tercih etti)

**Q3.3: Anlaşmazlık çözüm akışı?**
```
default=evet (escrow açıksa zaten mantıklı)
```
Ali: `[enter]` → evet

### Phase 4 — Operasyonlar (5 soru)

| Soru | Ali'nin cevabı |
|---|---|
| Q4.1 Region | `3` (Turkey) → **otomatik KVKK eklendi** |
| Q4.2 Analytics | `[enter]` (Plausible self-host) |
| Q4.3 Error tracking | `[enter]` (Sentry) |
| Q4.4 Uptime | `[enter]` (Better Stack) |
| Q4.5 Backup | `[enter]` (daily snapshot) |

### Phase 5 — Takım + deploy + compliance (6 soru)

| Soru | Cevap |
|---|---|
| Q5.1 Takım boyutu | `2` (2-5) |
| Q5.2 CI | `[enter]` (GitHub Actions) |
| Q5.3 Deploy | `3` (Vercel — Ali "tek tık" istiyor) |
| Q5.4 Preview per-PR | `e` (team>1 olduğu için auto-yes zaten) |
| Q5.5 Compliance | `[enter]` → `kvkk` (region=tr auto) |
| Q5.6 Monitoring | `[enter]` (Grafana self-host) |

### Özet + Aktive edilenler paneli

```
═══════════════════════════════════════════════════════════
 /ulak-start — ÖZET + AKTİVE EDİLENLER
═══════════════════════════════════════════════════════════

 Proje:       temiz-gunler
 Sektör:      marketplace
 Stack:       Next.js + Supabase
 Payment:     iyzico (region=tr)
 Email:       Resend
 Deploy:      Vercel
 Compliance:  kvkk (region=tr otomatik)
 Team:        2-5
 Escrow:      açık (güvence için seçildi)

─ Ulak OS bu projeye otomatik aktive etti ────────────────

 📦 Sector overlay
    → marketplace (commission + escrow + dispute)

 📋 Rule pack (8'den aktif 3)
    → multi-tenant-supabase (RLS tenant isolation)
    → transactional-fsm-payment (pending→active→canceled)
    → reseller-enabled-saas (2-sided permission model)

 🛡️  Anti-pattern koruması (50+ katalogdan bu projede aktif 8)
    → AP-06 admin-role-re-read
    → AP-11 rls-gate-bypass-prevention
    → AP-EC-02 oversell-prevention (DB trigger)
    → ... toplam 8

 🏛️  Governance
    → KVKK compliance (region=tr)
    → commission-immutability
    → audit-retention 1-year (team>1)

 📄 Scaffold edilecek dosyalar
    → 42 page template (auth + customer + seller + admin + partner)
    → 18 API route
    → 12 component (shadcn + dashboard)
    → 8 SQL migration
    → 6 compliance template (KVKK consent + data export)
    → TOPLAM: ~140 dosya

─ Çalıştırılacak komut ───────────────────────────────────

 /ulak-scaffold product_name=temiz-gunler \
   --sector=marketplace \
   --stack=nextjs-supabase \
   --payment=iyzico \
   --storage=supabase-storage \
   --email=resend \
   --region=tr \
   --compliance=kvkk \
   --team-size=small \
   --deploy=vercel \
   --analytics=plausible \
   --error-tracking=sentry \
   --escrow=true \
   --dispute=true \
   --preview-per-pr

─ Sonraki adımlar ───────────────────────────────────────

 Scaffold sonrası /ulak-next-steps otomatik çalışacak.

   [e] Evet, çalıştır                    Enter = e
   [h] Hayır, değişiklik yapacağım
   [d] Düzenle: [soru numarası]

 Cevabın: _
═══════════════════════════════════════════════════════════
```

Ali: `[enter]` → e

---

## Bölüm 4 — Scaffold (30 saniye)

Ulak `/ulak-scaffold`'ı otomatik çağırır. Terminal çıktısı:

```
Scaffolding 'temiz-gunler' from Ulak OS templates...

✓ Base: saas-starter (124 files)
✓ Sector overlay: marketplace (+8 files)
✓ Compliance overlay: kvkk (+6 files)
✓ Deploy target: vercel (+2 config files)
✓ Total: 140 files materialized in ./temiz-gunler/

Post-install:
  cd temiz-gunler
  /ulak-next-steps    ← otomatik başlatılıyor
```

---

## Bölüm 5 — Post-scaffold runbook (`/ulak-next-steps`)

```
═══════════════════════════════════════════════════════════
 /ulak-next-steps — temiz-gunler için kişisel runbook
═══════════════════════════════════════════════════════════

 Adım 1: Klasöre gir
   cd temiz-gunler

 Adım 2: Bağımlılıkları yükle (3-5 dk)
   pnpm install
   
   Ne yapar: package.json'daki 40+ kütüphaneyi indirir.
   Hata alırsan: 'pnpm' yoksa → `npm install -g pnpm` önce.

 Adım 3: .env.local dosyasını doldur (15 dk ilk sefer)
   
   Ne: Senin özel anahtarların burada duracak.
   Nerede: temiz-gunler/.env.local (yeni dosya oluştur)
   
   Gereken 6 değişken:
   
   3.1 NEXT_PUBLIC_SUPABASE_URL      (Supabase'den)
       → docs/tutorials/supabase.md §4.1 (15 dk rehber)
   
   3.2 NEXT_PUBLIC_SUPABASE_ANON_KEY (Supabase'den)
       → aynı tutorial §4.2
   
   3.3 SUPABASE_SERVICE_ROLE_KEY     (Supabase'den, GİZLİ)
       → aynı tutorial §4.3
   
   3.4 RESEND_API_KEY                (Resend'den)
       → docs/tutorials/resend.md §4 (10 dk rehber)
   
   3.5 IYZICO_API_KEY                (Iyzico test hesabı)
       → iyzico.com/sandbox → hesap aç → Ayarlar → API keys
   
   3.6 IYZICO_SECRET                 (Iyzico test hesabı)
       → aynı ekran

 Adım 4: Migration uygula (3 dk)
   npx supabase link --project-ref <project-ref>
   npx supabase db push
   
   Ne yapar: 8 SQL dosyasını Supabase'e yükler — tablolar oluşur.

 Adım 5: Demo verileri ekle (1 dk)
   pnpm seed
   
   Ne yapar: 3 test kullanıcı, 10 görevli, 20 rezervasyon ekler.

 Adım 6: İlk çalıştır (5 sn)
   pnpm dev
   
   Tarayıcıda http://localhost:3000 açılır.

 Adım 7: İlk admin kullanıcıyı oluştur (2 dk)
   → Supabase Dashboard → Authentication → Users → Add user
   → Email: ali@temiz-gunler.test, password: <güçlü şifre>
   → SQL Editor: UPDATE profiles SET role='admin' WHERE email='ali@...'

 Adım 8: Admin paneline gir (30 sn)
   → http://localhost:3000/login → admin user ile giriş
   → http://localhost:3000/admin → yönetim paneli

 Adım 9: Git ile versiyonla (3 dk)
   git init && git add -A
   git commit -m "feat: initial Ulak OS scaffold"
   → docs/tutorials/github.md §5-6 (repo create + push)

 Adım 10: GitHub'a yükle (20 dk ilk sefer)
   → docs/tutorials/github.md §2-11 (hesap + SSH + push + CI)

 Adım 11: Vercel'e deploy et (10 dk)
   → docs/tutorials/vercel.md §2-6 (hesap + env vars + deploy)

 Adım 12: (Opsiyonel) Custom domain bağla (10 dk)
   → docs/tutorials/vercel.md §7 (DNS kayıtları)

═══════════════════════════════════════════════════════════
 Toplam: 75-85 dk sıfırdan canlıya.
 Takıldığın yer olursa /ulak-explain <terim> veya
 /ulak-ask "<soru>" yaz.
═══════════════════════════════════════════════════════════
```

Ali adım adım ilerler. Aşağıda kritik 4 adımın detayı.

---

## Bölüm 6 — Supabase kurulumu (15 dk)

Ali `docs/tutorials/supabase.md` dosyasını açar (Claude Code'da `Read` ile).

Adımları sırayla uygular:

1. `supabase.com/dashboard/sign-up` → GitHub ile giriş (Ali'nin henüz GitHub hesabı yok — önce onu aç)
2. "Create new project" → name: `temiz-gunler-dev` → Frankfurt region → güçlü DB password (1Password'a kaydet)
3. Project Settings → API → 3 değeri `.env.local`'e kopyala
4. `npx supabase link --project-ref xxxxx` + `npx supabase db push`
5. Supabase Studio → Tables → 12 tablo oluştu görür (users, profiles, bookings, walkers, payments, ...)
6. Authentication → Users → Add user → `ali@temiz-gunler.test`
7. SQL Editor → `UPDATE profiles SET role='admin' WHERE email='ali@...'`

**Takıldığı yer**: Ali `service_role` key'inin nerede olduğunu bulamaz. `/ulak-explain service-role-key` yazar:

```
service_role / Service Role Key

[Basit]     Supabase'de sunucu tarafı işlemler için kullanılan gizli
            anahtar. Client-side asla kullanılmaz.

[Teknik]    Postgres'te RLS'i bypass edebilen, JWT imzalamaya yetkili
            server-only API key.

[Analoji]   Apartmanın bina müdürünün master anahtarı — sadece yetkili
            kişi elinde olmalı.

[Ulak'ta]   .env.local'deki SUPABASE_SERVICE_ROLE_KEY değişkeni
            buraya gelir. lib/supabase/admin.ts bunu kullanır.

[İlgili]    anon-key, RLS, JWT, admin-ops

[Daha fazla] docs/tutorials/supabase.md §4.3 — "Reveal" düğmesini bul.
```

Ali "Reveal" düğmesini dashboard'da bulup kopyalar.

---

## Bölüm 7 — GitHub yükleme (20 dk)

Ali `docs/tutorials/github.md` dosyasını açar.

1. GitHub hesabı aç → 2FA kur → SSH key oluştur (`ssh-keygen -t ed25519`) → public key'i GitHub'a ekle
2. `github.com/new` → `temiz-gunler` repo oluştur (private)
3. Terminal:
   ```bash
   cd temiz-gunler
   git init
   git add -A
   git commit -m "feat: initial Ulak OS scaffold"
   git branch -M main
   git remote add origin git@github.com:ali/temiz-gunler.git
   git push -u origin main
   ```
4. GitHub'da Actions sekmesi → CI otomatik başladı → 2 dk sonra ✓ yeşil
5. Settings → Security → Secret scanning + Dependabot aktif

**Push protection yakaladı**: Ali yanlışlıkla `.env.local`'i git'e eklemiş. GitHub push'u reddediyor.
```
remote: error: GH013: Repository rule violations found
remote: — Push cannot contain secrets
```

Ali `/ulak-ask "secret push reddedildi"` yazar. Ulak yönlendirir:
```
→ /triage-build komutunu kullan VEYA
→ docs/runbooks/troubleshooting.md § Secret push protection

Çözüm özeti:
1. git rm --cached .env.local
2. .gitignore'a '.env.local' ekle
3. git add .gitignore
4. git commit -m "fix: exclude .env.local from git"
5. git push (yeşil olur)
```

Ali çözer. Push başarılı.

---

## Bölüm 8 — Vercel deploy (10 dk)

1. `vercel.com/signup` → GitHub ile giriş
2. Dashboard → "Add New Project" → `temiz-gunler` repo'yu import
3. Framework: Next.js (auto-detect) → Deploy
4. **İlk deploy fail**: env var'lar eksik
5. Settings → Environment Variables → 6 env'i 3 scope (Production/Preview) için gir:
   - `NEXT_PUBLIC_SUPABASE_URL` (plain, 2 scope)
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` (plain, 2 scope)
   - `SUPABASE_SERVICE_ROLE_KEY` (**Sensitive**, Production only)
   - `IYZICO_API_KEY`, `IYZICO_SECRET` (Sensitive, Production only)
   - `RESEND_API_KEY` (Sensitive, Production only)
6. Deployments → son deploy → "Redeploy"
7. 90 saniye sonra `temiz-gunler.vercel.app` canlıda

Ali tarayıcıda açar → landing page görür → Login → admin olarak giriş yapar → admin panelde bookings tablosunu görür.

---

## Bölüm 9 — İlk test ödeme (5 dk)

Ali `/ulak-ask "iyzico test ödeme nasıl"` yazar.

Ulak:
```
→ Ulak scaffold'ta Iyzico test kartları hazır.
→ docs/runbooks/test-payments.md var mı bakayım... yok.
→ iyzico sandbox test kartı: 5528 7900 0000 0008 (VISA test)
→ CVC: 123, Expiry: 12/30
→ /admin/orders/new → test sipariş oluştur → ödeme akışını gör

Veya: Iyzico sandbox docs.
```

Ali sandbox ödeme testi yapar. Webhook geldi — `processed_webhook_events` tablosunda görür. Başarı.

---

## Bölüm 10 — Ne yaptık, özet

### Ali'nin yaptığı (75-90 dk toplam)

| Zaman | İş | Sonuç |
|---|---|---|
| 0-2 dk | `/ulak-hello` tour | Ulak OS'u tanıdı |
| 2-14 dk | `/ulak-start` sihirbazı (basit mod) | 27 soruya cevap, özet + aktive panel |
| 14-15 dk | `/ulak-scaffold` auto-dispatch | 140 dosyalık proje klasörü |
| 15-30 dk | Supabase tutorial | DB + auth + 3 env key |
| 30-45 dk | GitHub tutorial | Repo + push + CI yeşil |
| 45-55 dk | Vercel tutorial | Canlı URL + env vars |
| 55-65 dk | Resend tutorial | Email entegrasyonu |
| 65-75 dk | Iyzico test hesap | Ödeme akışı |
| 75-85 dk | Polish + ilk admin user + test | Prod-ready demo |

### Ulak OS'un arkada yaptığı

- 14 sector overlay'den **marketplace** seçildi
- 8 rule pack'ten **3** aktive edildi (multi-tenant-supabase, transactional-fsm-payment, reseller-enabled-saas)
- 50+ anti-pattern'den **8'i** DB trigger + CHECK constraint olarak enforce edildi
- 22 governance doc'tan **ilgili 4**'ü (KVKK, commission-immutability, audit-retention, payment-FSM) aktif
- 140 template dosyası materialize edildi
- `.env.local` şablonu doğru değişken listeleriyle üretildi
- CI workflow + secret scanning + Dependabot hazır geldi
- KVKK consent flow + data export gerçekten çalışan kod olarak entegre

### Ali'nin "Ulak OS olmasaydı" senaryosu

Aynı işi sıfırdan yapmak:
- Next.js + Supabase setup: 1 gün
- Auth flow: 1 gün
- RLS policy'ler (tenant isolation doğru): 2 gün
- Payment (Iyzico webhook + idempotency + FSM): 3 gün
- Marketplace schema + commission + escrow + dispute: 4 gün
- Admin panel CRUD: 2 gün
- CI setup: 0.5 gün
- Vercel deploy config: 0.5 gün
- KVKK uyum katmanı: 1 gün
- Email entegrasyonu: 0.5 gün

**Toplam**: ~15 iş günü (3 hafta)
**Ulak OS ile**: 75-90 dakika (1.5 saat)

## Ali'ye v1.x sonrası tavsiyeler

1. İlk 10 gerçek kullanıcı → feedback topla
2. `/director komple` koştur → kalite skorkartı + gap analysis
3. `/ulak-audit-deep` quarterly — 14-dimension health check
4. Custom domain bağla (`temizgunler.com`)
5. Iyzico sandbox → production'a geç (KYC lazım)
6. Supabase free tier → pro'ya (500 MAU aşarsa)
7. Vercel free → pro'ya (100 GB bandwidth aşarsa)
8. Monitoring: Sentry alerts + Better Stack uptime alerts

---

## Başka senaryolar için

- Minimal SaaS (tek kullanıcı tipi): `/ulak-demo` → [1]
- Eğitim platformu: `/ulak-demo` → [3]
- Fintech / Marketplace: `/ulak-demo` → [2]
- Kendi senaryonu: `/ulak-start` ile 6-27 soru → otomatik scaffold

## Related docs

- `docs/runbooks/first-hour-with-ulak-os.md` — daha kısa özet
- `docs/tutorials/supabase.md` + `vercel.md` + `github.md` + `resend.md` — servis rehberleri
- `docs/runtime/beginner-glossary.md` — 47 terim açıklaması
- `docs/FAQ.md` — 30+ sık sorulan soru
- `docs/catalog.md` — 24 komut + 10 skill + 27 ajan tam listesi
