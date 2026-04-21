---
description: Scaffold tamamlandıktan sonra "şimdi ne yapacağım" sorusunu 8-10 somut adımla cevaplar. Kullanıcının seçimlerine göre (sector, payment, deploy, email) kişiselleştirilmiş çalıştırma rehberi — pnpm install, .env.local doldurma, Supabase/Iyzico/Resend hesap açma linkleri, ilk migration, seed, pnpm dev, ilk admin kullanıcı oluşturma, admin paneline giriş. Beginner bu adımları takip edince localhost:3000 açılır ve giriş yapabilir.
description_en: Answers the "what do I do now?" question after scaffold completes, with 8-10 concrete steps. Produces a personalized runbook based on the user's choices (sector, payment, deploy, email) — pnpm install, .env.local fill-in, Supabase/Iyzico/Resend signup links, first migration, seed, pnpm dev, creating the first admin user, admin panel entry. Following these steps, a beginner reaches localhost:3000 and logs in.
phases_run: []
---

# /ulak-next-steps

> **TR** — Scaffold bitti, klasör duruyor — şimdi ne yaparım? Bu komut cevaplar.
> **EN** — Scaffold done, folder sits there — what now? This command answers.

## Amaç / Purpose

**TR**: `/ulak-scaffold` çalışır, `product_name/` dizinini üretir, commit atar. Klasör hazır ama beginner
bilmiyor: `pnpm install` nerede çalışır, `.env.local` nereden doldurulur, Supabase URL nereden alınır,
Iyzico sandbox hesabı nasıl açılır, localhost:3000'e nasıl ulaşır, ilk admin kullanıcı nasıl oluşturulur.
Bu komut, kullanıcının `/ulak-start` sırasında verdiği cevapları (sector, payment, deploy, email) okur
ve 8-10 somut, kopyalanabilir adıma dönüştürür. Her adımda: tahmini süre, açıklama, gerekiyorsa link,
dikkat notu.

**EN**: `/ulak-scaffold` runs, produces the `product_name/` directory, commits it. Folder is ready but
beginner doesn't know: where does `pnpm install` run, how is `.env.local` filled, where is the Supabase
URL, how does one open an Iyzico sandbox account, how to reach localhost:3000, how to create the first
admin user. This command reads the user's `/ulak-start` answers (sector, payment, deploy, email) and
turns them into 8-10 concrete, copy-pasteable steps. Each step: estimated time, explanation, link if
relevant, caution note.

## Ne yapmaz / What it does NOT do

- Disk'e yazmaz — sadece rehberi ekranda gösterir.
- Does not write to disk — only prints the runbook to the screen.
- Kullanıcı adına `pnpm install` çalıştırmaz — operatörün kendi terminalinde çalıştırmasını ister.
- Does not run `pnpm install` on behalf of the user — asks the operator to run it in their own terminal.
- Gerçek API key / token / secret içermez — tüm değerler placeholder + dashboard URL'sine işaret.
- Contains no real API keys / tokens / secrets — all values are placeholders + pointers to dashboard URLs.

## Ne zaman / When

- `/ulak-scaffold` başarılı biter bitmez (otomatik zincir — bkz. §Dispatch chain).
- Or manually: kullanıcı scaffold edilmiş bir klasöre girdikten sonra `/ulak-next-steps` çağırır.

## Girdi / Inputs

```yaml
product_path: "../product_name"       # scaffold edilen dizinin yolu (default = en son scaffold'un output_path'i)
sector: "marketplace"                 # --sector bayrağından
payment: "iyzico"                     # --payment bayrağından
email: "resend"                       # --email bayrağından
deploy: "traefik"                     # --deploy bayrağından
region: "tr"                          # --region bayrağından
compliance: "kvkk"                    # --compliance bayrağından
team_size: "small"                    # --team-size bayrağından
locale: "bilingual"                   # Q1.4'ten
```

Bayraklar bilinmiyorsa (örn. manuel çağrı), komut `product_path/package.json`'u okur ve dependency'lere
bakarak tahmin eder; tahmin edilemeyen alanlar için adımın açıklamasına "opsiyonel" etiketi düşer.

## Akış / Flow

### 1. Klasörü doğrula

```
─ Klasör kontrolü / Directory check ──────────────────────────────
 product_path:  ../koptak
 package.json:  ✓ bulundu
 next.config:   ✓ bulundu (Next.js 16 detected)
 supabase/:     ✓ bulundu
```

Yoksa uyar: `Scaffold klasörü bulunamadı — /ulak-scaffold önce çalıştı mı?`.

### 2. Adımları kişiselleştir

Kullanıcının cevaplarına göre şunlar aktive olur:
- `payment=iyzico` → Adım 3.3'te Iyzico sandbox rehberi aktif.
- `payment=stripe` → Adım 3.3'te Stripe test mode rehberi aktif.
- `email=resend` → Adım 3.4'te Resend signup rehberi aktif.
- `sector=marketplace` → Adım 6'ya "demo seller hesabı oluştur" eklenir.
- `deploy=traefik` → Adım 9'da Traefik subdomain hint'i aktif.
- `region=tr` → Adım 3.3 Iyzico başlığına "TR pazarı" notu düşer.

## Çıktı şablonu / Output template

```
═════════════════════════════════════════════════════════════════
 /ulak-next-steps — koptak için çalıştırma rehberi
 /ulak-next-steps — runbook for koptak
═════════════════════════════════════════════════════════════════

 Scaffold tamam. 10 adımda localhost:3000'de giriş yapacaksın.
 Scaffold done. In 10 steps you'll be logged in at localhost:3000.

 Toplam süre / Total time: ~25-40 dk (hesap açma dahil)

─────────────────────────────────────────────────────────────────
 ADIM 1 — Dizine gir / Enter the directory
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     10 sn
 📖 Açıklama:         Scaffold edilen proje klasörüne geç.
 💻 Komut / Command:

     cd ../koptak

─────────────────────────────────────────────────────────────────
 ADIM 2 — Bağımlılıkları kur / Install dependencies
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     2-4 dk
 📖 Açıklama:         Next.js + Supabase client + shadcn + Tailwind
                      + test araçları — hepsi bir komutla.
 💻 Komut / Command:

     pnpm install

 ⚠️  Dikkat: pnpm yoksa `npm install -g pnpm` ile kur. `npm`
     kullanırsan lock file drift riski var (lock-file-hygiene).

─────────────────────────────────────────────────────────────────
 ADIM 3 — .env.local oluştur / Create .env.local
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     10-15 dk (hesap açma dahil)
 📖 Açıklama:         Proje gerçek hesaplarla konuşmak için
                      environment değişkenleri istiyor. Önce
                      şablonu kopyala, sonra değerleri doldur.
 💻 Komut / Command:

     cp .env.example .env.local

 ⚠️  Dikkat: .env.local ASLA commit edilmez — .gitignore zaten
     onu hariç tutuyor. Gerçek key'leri public repo'ya pushlama.

 Aşağıdaki 4 alt adımda her değişkeni sırayla doldur:

 ┌─── 3.1 Supabase ──────────────────────────────────────────┐
 │                                                            │
 │  NEXT_PUBLIC_SUPABASE_URL=<buraya>                         │
 │  NEXT_PUBLIC_SUPABASE_ANON_KEY=<buraya>                    │
 │  SUPABASE_SERVICE_ROLE_KEY=<buraya>  (dikkat: secret)      │
 │                                                            │
 │  🔗 Link: https://supabase.com/dashboard                    │
 │  📋 3 adım:                                                 │
 │    1. Dashboard'da "New Project" de. Region: Frankfurt     │
 │       (AB) ya da kendi bölgene yakın bir yer seç.          │
 │    2. Proje açılınca Settings → API sekmesine git.         │
 │    3. "Project URL" → NEXT_PUBLIC_SUPABASE_URL              │
 │       "anon public" key → NEXT_PUBLIC_SUPABASE_ANON_KEY    │
 │       "service_role" key → SUPABASE_SERVICE_ROLE_KEY       │
 │       (service_role tam yetkili — asla client'a gitmez)    │
 └────────────────────────────────────────────────────────────┘

 ┌─── 3.2 Database URL ──────────────────────────────────────┐
 │                                                            │
 │  DATABASE_URL=postgres://...                               │
 │                                                            │
 │  🔗 Supabase dashboard → Settings → Database → Connection  │
 │     string → "URI" modunu seç → kopyala.                   │
 │  ⚠️  Password placeholder'ı gerçek db şifrenle değiştir.   │
 └────────────────────────────────────────────────────────────┘

 ┌─── 3.3 Iyzico (TR pazarı, sector=marketplace) ───────────┐
 │                                                            │
 │  IYZICO_API_KEY=sandbox-<buraya>                           │
 │  IYZICO_SECRET_KEY=sandbox-<buraya>                        │
 │  IYZICO_BASE_URL=https://sandbox-api.iyzipay.com           │
 │                                                            │
 │  🔗 Link: https://sandbox-merchant.iyzipay.com             │
 │  📋 3 adım:                                                 │
 │    1. Ücretsiz sandbox hesabı aç (email + telefon).        │
 │    2. Merchant paneline gir → Ayarlar → API                │
 │       Anahtarları → "Sandbox" sekmesi.                     │
 │    3. API Key + Secret Key'i kopyala (sandbox- öneki       │
 │       olmalı — canlı key'i asla sandbox ortamına koyma).   │
 │  ⚠️  AP-08 (sandbox ↔ live env switch) — live için tamamen │
 │     ayrı key seti, production'a deploy ederken değiştir.   │
 └────────────────────────────────────────────────────────────┘

 ┌─── 3.4 Resend (email=resend) ─────────────────────────────┐
 │                                                            │
 │  RESEND_API_KEY=re_<buraya>                                │
 │                                                            │
 │  🔗 Link: https://resend.com/signup                        │
 │  📋 3 adım:                                                 │
 │    1. Email ile kayıt ol (ücretsiz tier 3000 mail/ay).     │
 │    2. Dashboard → "API Keys" → "Create API Key".           │
 │    3. Key'i kopyala (bir kez gösterilir — güvenli yere     │
 │       kaydet).                                             │
 │  ⚠️  Domain verify etmeden sadece onboarding@resend.dev    │
 │     adresinden gönderebilirsin. Production için kendi      │
 │     domain'ini ekle (Settings → Domains).                  │
 └────────────────────────────────────────────────────────────┘

─────────────────────────────────────────────────────────────────
 ADIM 4 — Migration uygula / Apply first migration
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     30 sn
 📖 Açıklama:         Scaffold edilen SQL migration'ları
                      Supabase'e uygula. RLS + marketplace schema
                      + payment tabloları gelir.
 💻 Komut / Command:

     pnpm supabase:push

 ⚠️  Dikkat: Bu komut DATABASE_URL üzerinden bağlanır. Adım 3.2
     doğru değilse burada kırılır — önce bağlantıyı test et.

─────────────────────────────────────────────────────────────────
 ADIM 5 — Demo data seed et / Seed demo data
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     20 sn
 📖 Açıklama:         Boş bir DB ile uğraşma — scaffolder
                      demo seller, demo buyer, demo ürün üretir.
 💻 Komut / Command:

     pnpm seed

─────────────────────────────────────────────────────────────────
 ADIM 6 — Dev server başlat / Start dev server
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     15 sn
 📖 Açıklama:         Next.js dev server. HMR aktif, kodda
                      değişiklik yaptıkça tarayıcı canlı yenilenir.
 💻 Komut / Command:

     pnpm dev

 ▸ Tarayıcı: http://localhost:3000

─────────────────────────────────────────────────────────────────
 ADIM 7 — İlk admin kullanıcı oluştur / Create first admin user
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     1 dk
 📖 Açıklama:         Supabase Studio üstünden ilk admin user'ı
                      elle oluştur. Sonraki kullanıcılar sign-up
                      akışından gelir.
 📋 3 adım:
   1. Supabase dashboard → Authentication → Users → "Add user".
   2. Email + password gir. "Auto-confirm" seçeneğini işaretle.
   3. User oluştuktan sonra "SQL Editor"a geç ve şu satırı koştur:

      update profiles set role = 'admin'
      where email = 'senin@email.com';

 ⚠️  AP-06 (admin-role-re-read) — role user_metadata'da değil,
     profiles tablosunda. Fresh-DB check her istekte çalışır.

─────────────────────────────────────────────────────────────────
 ADIM 8 — Admin paneline gir / Enter admin panel
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     30 sn
 📖 Açıklama:         Adım 7'deki email + password ile giriş yap.
 ▸ URL:              http://localhost:3000/admin

 Dashboard açılırsa: tebrikler, tam bir Ulak OS SaaS çalıştırıyorsun.

─────────────────────────────────────────────────────────────────
 ADIM 9 — Pre-push hook'ları kur / Install pre-push hooks
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     15 sn
 📖 Açıklama:         R-04 rule pack — commit öncesi validation +
                      type-check + test. CI'dan önce local'de koşar,
                      "yeşil main" disiplini.
 💻 Komut / Command:

     ./scripts/install-hooks.sh

─────────────────────────────────────────────────────────────────
 ADIM 10 — Baseline health score / Baseline health score
─────────────────────────────────────────────────────────────────
 ✅ Süre / Time:     5-10 dk
 📖 Açıklama:         Ulak OS üzerinden yeni projenin 14-dimension
                      audit skorunu al. Scaffold doğru yapıldı mı,
                      hangi gap'ler görünüyor — öğrenirsin.
 💻 Komut / Command (Claude Code'da, proje klasöründe):

     /ulak-audit-deep

─────────────────────────────────────────────────────────────────
 Sorun çıkarsa / If something breaks
─────────────────────────────────────────────────────────────────

 • pnpm install kırıldı      →  node --version  (>=18 olmalı)
 • pnpm supabase:push kırdı  →  DATABASE_URL doğru mu?
 • 3000 portunda başka uyg.  →  pnpm dev -- -p 3001
 • Admin paneli 404          →  profiles.role = 'admin' yapıldı mı?
 • /ulak-audit-deep çökerse  →  /triage-build ile triaj et

═════════════════════════════════════════════════════════════════
 Sonraki adım / What's next
═════════════════════════════════════════════════════════════════

 ▸ Proje çalışıyor. Şimdi değer katma zamanı.

 [1] İlk feature'ı TDD ile yaz     → /ulak-test-driven
 [2] Yeni bir fikri araştır        → /ulak-brainstorm
 [3] Frontend redesign             → /frontend-war-room
 [4] Paylaşılabilir pattern çıkar  → /ulak-pattern-extract
 [5] Neye sahipsin tekrar göster   → /ulak-packs

═════════════════════════════════════════════════════════════════
```

## Dispatch chain (ile /ulak-start entegrasyonu)

`/ulak-start` wizard ÖZET bloğunda user `[e]` ile onayladıktan sonra şu zincir çalışır:

```
/ulak-start  →  /ulak-scaffold (otomatik, aynı turn)  →  /ulak-next-steps (otomatik, aynı turn)
                                      │                                │
                                 disk'e yazar                     ekrana rehber
                                 commit atar                      basar, disk'e
                                                                 dokunmaz
```

`/ulak-scaffold` bittikten sonra `scaffold-log.md` "SUCCESS" yazıyorsa `/ulak-next-steps` otomatik
tetiklenir — kullanıcı input beklenmez. `scaffold-log.md` "FAILED" yazıyorsa next-steps yerine
`/triage-build` önerilir.

Manuel çağrılırsa (zincir dışı), `/ulak-next-steps` product_path'i arg olarak bekler:

```
/ulak-next-steps ../koptak
```

## Routing mantığı / Routing logic

| Girdi / Input | Davranış / Behavior |
|---|---|
| Arg yok, en son scaffold var | En son `reports/current/scaffold-log.md`'den product_path oku |
| Arg verildi (`../path`) | O path'i kullan |
| product_path'te package.json yok | "Scaffold klasörü değil gibi — /ulak-scaffold önce çalıştı mı?" |
| scaffold-log.md yok | Kullanıcıya `product_path` ister |
| payment=none | Adım 3.3 atlanır |
| email=none | Adım 3.4 atlanır |
| sector=other | Sector-özel adım (örn. seller hesabı) atlanır |

## Yasaklar / Forbidden

- Gerçek API key / token / secret gösterme — sadece placeholder + dashboard URL.
- Portfolio / müşteri proje adlarına referans verme (`bayi*`, `ajans*`, `trend*`, `cevap*` yasak).
- Olmayan komut/skill/flag iddia etme — `/ulak-scaffold` bayrak seti
  `.claude/commands/ulak-scaffold.md` §Inputs bölümünden gelir.
- Kullanıcı adına komut çalıştırma — rehber gösterir, çalıştırmaz.

## Integration points

- `.claude/commands/ulak-start.md` — wizard; onay sonrası bu komutu zincirler.
- `.claude/commands/ulak-scaffold.md` — scaffolder; `reports/current/scaffold-log.md` üretir.
- `reports/current/scaffold-log.md` — en son scaffold'un product_path + bayrak seti kaynağı.
- `docs/runtime/wizard-defaults.md` — sector × payment default matrisi.
- `docs/governance/secrets-rotation-policy.md` — secret rotation disiplini (Adım 3 altındaki uyarılar).
- `.claude/commands/ulak-audit-deep.md` — Adım 10'dan referans alınır.

## Vizyon metriği / Vision metric

Bu komut "scaffold bitti → kullanıcı kaybolmadı → ilk admin user girişi" akışını 25-40 dakikaya
sıkıştırır. Başarı ölçütleri:

- Beginner 10 adımı takip ederek localhost:3000'de kendi admin kullanıcısı ile giriş yapabilmeli.
- Her adımda somut komut, tahmini süre, gerekirse link + dikkat notu olmalı.
- Hesap açılması gereken her servis için dashboard URL + 3 adım verilmeli (Supabase, Iyzico, Resend).
- Gerçek secret asla basılmamalı — sadece placeholder.
- Adım 10'a ulaşınca kullanıcı `/ulak-audit-deep` ile baseline skoru görmeli; "yeşilse yola devam".

ARGUMENTS:
$ARGUMENTS
