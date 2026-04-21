# Walkthrough #1 (Codex variant) — Sıfırdan ilk SaaS'a uçtan uca

> **Kime**: Ulak OS'a Codex CLI üzerinden ilk kez giren, hiç SaaS yapmamış bir kullanıcı.
> **Süre**: 75-90 dakika (okuma + uygulama).
> **Sonuç**: GitHub'da repo, Vercel'de canlı URL, Supabase'de database, Resend'den email gönderen, Iyzico test ödeme alan bir "ev temizlik hizmeti marketplace" sitesi.
> **Ön koşul**: Codex CLI + Ulak OS kurulu (kurulum için `docs/runbooks/install-methods.md`).
> **Fark**: Bu variant Codex'in `/slash` dispatch desteklemediği gerçeğiyle hizalanmıştır. Tüm etkileşim doğal dil ile gider; Codex, `AGENTS.md` içindeki "Natural-Language Trigger Map" bölümü ile NL → protokol eşlemesi yapar.

## Senaryo

Ali küçük bir işletme açmak istiyor: müşteriler siteye gelsin, temizlik görevlisi seçsin, randevu alsın, kredi kartıyla ödesin. Görevliler siteye giriş yapsın, takvimlerini yönetsin. Ali admin olarak her şeyi görsün. Türkiye'de kullanılacak, TL ödeme, KVKK uyumlu. Ali'nin kod yazma tecrübesi sıfır — sadece HTML-CSS gördü bir-iki kere.

Ali Codex CLI kullanıyor çünkü ekibinin tercihi bu. Claude Code variant'ı ile aynı çıktıya 75-90 dakikada ulaşacak, sadece komutlar slash yerine doğal dil.

---

## Bölüm 1 — Hazırlık (5 dk)

### 1.1 Terminal aç

```bash
# Windows: PowerShell veya Git Bash
# macOS/Linux: Terminal
```

### 1.2 Codex CLI ve Ulak OS kurulu mu kontrol et

```bash
codex --version
# codex CLI 1.x veya 2.x çıktı görmeli

ulak --version
# v1.4.0 gibi bir çıktı görmeli
```

Eğer `command not found` ise `docs/runbooks/install-methods.md` oku.

### 1.3 Boş bir çalışma klasörü oluştur

```bash
mkdir ~/projeler
cd ~/projeler
```

Ali bu klasörde Codex CLI'yı açacak. Yeni projeleri bu dizinin altına kuracağız.

### 1.4 Codex'e Ulak OS'u tanıt

Codex, Claude Code gibi otomatik `CLAUDE.md` yüklemez. Ali ilk mesajında reading order'ı vermeli:

```
Read AGENTS.md, prompts/core/ulak-os-core-contract-2.0.0.md,
docs/adapters/codex-cli.md, and docs/adapters/universal-runtime-contract.md.
Then wait for my next instruction.
```

Codex bu dosyaları okur, özeti çıkarır, "hazırım" der.

---

## Bölüm 2 — İlk keşif (2 dk)

Ali Codex CLI'yı `~/projeler` klasöründe açar. İlk NL hamlesi:

```
selam ulak
```

Codex `AGENTS.md` §Natural-Language Trigger Map'i okumuş olduğu için "selam ulak" → `/ulak-hello` protokolü eşlemesini bilir. `.claude/commands/ulak-hello.md` template'ini aynen render eder:

```
═══════════════════════════════════════════════════════════
 Ulak OS — 30 saniyelik tour
═══════════════════════════════════════════════════════════

 Ulak OS nedir?

 (1) AI coding CLI'larının üstüne oturan prompt işletim sistemi.
 (2) Audit + governance + full-stack SaaS scaffolder — üçü bir arada.
 (3) Vendor-neutral (Claude / Codex / Gemini), tek çekirdek.

─ Örnek komutlar (Codex NL karşılıkları) ─────────────────

   "audit" / "director komple"       Mevcut projeyi tara.
   "ulak start" / "yeni saas"        27 soruluk wizard başlat.
   "ulak'a sor <soru>"               Doğal dille sor.

─ Şimdi ne yapalım? ───────────────────────────────────────

   [1] Yeni SaaS yap
   [2] Mevcut projeyi audit et
   [3] Doğal dille sor
   [4] Tüm kapasiteleri göster

 Cevabın: _
═══════════════════════════════════════════════════════════
```

Ali cevap verir: `1`

Codex otomatik olarak `/ulak-start` protokolüne geçer.

---

## Bölüm 3 — Sihirbaz (12 dk)

### Q0 — Mod seçimi

Codex `.claude/commands/ulak-start.md` dosyasını okur ve Phase 0'u render eder:

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

Codex faz başlığını render eder ve soruları sırayla sorar:

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

Hepsinde Ali `[enter]` basar:

| Soru | Default | Ali'nin verdiği | Anlamı |
|---|---|---|---|
| Q2.1 Stack | Next.js+Supabase | [enter] | Web sitesi + hazır database |
| Q2.2 Auth | email+magic+google | [enter] | Üç giriş yolu açık |
| Q2.3 Database | Supabase managed | [enter] | Bulutta hazır DB |
| Q2.4 Payment | iyzico (TR region) | [enter] | TL kart ödeme |
| Q2.5 Storage | Supabase Storage | [enter] | Dosya yükleme hazır |
| Q2.6 Email | Resend | [enter] | Transactional email |

### Phase 3 — Sektör derinliği (marketplace için 3 soru)

**Q3.1: Komisyon oranı?** Ali: `[enter]` → %10
**Q3.2: Escrow?** Ali: `e` (evet, güven için)
**Q3.3: Anlaşmazlık çözüm akışı?** Ali: `[enter]` → evet

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
| Q5.3 Deploy | `3` (Vercel) |
| Q5.4 Preview per-PR | `e` |
| Q5.5 Compliance | `[enter]` → `kvkk` |
| Q5.6 Monitoring | `[enter]` (Grafana self-host) |

### Özet + Aktive edilenler paneli

Codex wizard'ı bitirir, özet ekranı render eder:

```
═══════════════════════════════════════════════════════════
 /ulak-start — ÖZET + AKTİVE EDİLENLER (Codex NL variant)
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

 ulak scaffold product_name=temiz-gunler \
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

 Onaydan sonra Codex Bash tool ile yukarıdaki komutu çalıştırır.
 Scaffold biter bitmez "scaffold bitti şimdi ne yapayım" yaz —
 post-scaffold runbook otomatik render edilir.

   [e] Evet, çalıştır                    Enter = e
   [h] Hayır, değişiklik yapacağım
   [d] Düzenle: [soru numarası]

 Cevabın: _
═══════════════════════════════════════════════════════════
```

Ali: `[enter]` → e

---

## Bölüm 4 — Scaffold (30 saniye)

Codex `/slash` dispatch etmez — bunun yerine Bash tool ile komutu manuel çalıştırır:

```bash
ulak scaffold product_name=temiz-gunler \
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
```

Çıktı:

```
Scaffolding 'temiz-gunler' from Ulak OS templates...

✓ Base: saas-starter (124 files)
✓ Sector overlay: marketplace (+8 files)
✓ Compliance overlay: kvkk (+6 files)
✓ Deploy target: vercel (+2 config files)
✓ Total: 140 files materialized in ./temiz-gunler/

Post-install:
  cd temiz-gunler
  "scaffold bitti şimdi ne yapayım" ← Codex NL tetikleyicisi
```

---

## Bölüm 5 — Post-scaffold runbook

Ali yazar:

```
scaffold bitti, şimdi ne yapayım
```

Codex `AGENTS.md` §NL Trigger Map'ten bu ifadeyi `/ulak-next-steps` protokolüne eşler. `.claude/commands/ulak-next-steps.md` template'ini okur ve kişiselleştirilmiş runbook render eder:

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

 Adım 5: Demo verileri ekle (1 dk)
   pnpm seed

 Adım 6: İlk çalıştır (5 sn)
   pnpm dev
   → http://localhost:3000

 Adım 7: İlk admin kullanıcıyı oluştur (2 dk)
   → Supabase Dashboard → Authentication → Users → Add user
   → SQL Editor: UPDATE profiles SET role='admin' WHERE email='...'

 Adım 8: Admin paneline gir (30 sn)
   → http://localhost:3000/login → admin user ile giriş
   → http://localhost:3000/admin

 Adım 9: Git ile versiyonla (3 dk)
   git init && git add -A
   git commit -m "feat: initial Ulak OS scaffold"
   → docs/tutorials/github.md §5-6

 Adım 10: GitHub'a yükle (20 dk ilk sefer)
   → docs/tutorials/github.md §2-11

 Adım 11: Vercel'e deploy et (10 dk)
   → docs/tutorials/vercel.md §2-6

 Adım 12: (Opsiyonel) Custom domain bağla (10 dk)
   → docs/tutorials/vercel.md §7

═══════════════════════════════════════════════════════════
 Toplam: 75-85 dk sıfırdan canlıya.
 Takıldığın yer olursa:
   "X ne demek"                → /ulak-explain protokolü
   "ulak'a sor <soru>"         → /ulak-ask protokolü
═══════════════════════════════════════════════════════════
```

Ali adım adım ilerler. Kritik 4 adımın detayı:

---

## Bölüm 6 — Supabase kurulumu (15 dk)

Ali Codex'e yazar:

```
docs/tutorials/supabase.md dosyasını oku ve adım adım bana yönlendir
```

Codex `Read` tool ile tutorial'ı yükler, paragraf paragraf yönlendirir:

1. `supabase.com/dashboard/sign-up` → GitHub ile giriş
2. "Create new project" → name: `temiz-gunler-dev` → Frankfurt region → güçlü DB password (1Password'a kaydet)
3. Project Settings → API → 3 değeri `.env.local`'e kopyala
4. `npx supabase link --project-ref xxxxx` + `npx supabase db push`
5. Supabase Studio → Tables → 12 tablo oluştu görür
6. Authentication → Users → Add user → `ali@temiz-gunler.test`
7. SQL Editor → `UPDATE profiles SET role='admin' WHERE email='ali@...'`

**Takıldığı yer**: Ali `service_role` key'inin nerede olduğunu bulamaz. Codex'e yazar:

```
service-role-key ne demek
```

Codex `AGENTS.md` §NL Trigger Map'ten bu ifadeyi `/ulak-explain` protokolüne eşler, `docs/runtime/beginner-glossary.md` dosyasını okur, 5-alanlı şemayı render eder:

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

Ali Codex'e yazar:

```
github'a push etmek istiyorum, docs/tutorials/github.md aç ve yönlendir
```

Codex tutorial'ı açar, adım adım ilerletir:

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
4. GitHub'da Actions sekmesi → CI otomatik başladı → 2 dk sonra yeşil
5. Settings → Security → Secret scanning + Dependabot aktif

**Push protection yakaladı**: Ali yanlışlıkla `.env.local`'i git'e eklemiş. GitHub push'u reddediyor.

```
remote: error: GH013: Repository rule violations found
remote: — Push cannot contain secrets
```

Ali Codex'e yazar:

```
secret push reddedildi ulak'a sor
```

Codex `/ulak-ask` protokolünü tetikler:

```
→ /triage-build protokolü VEYA
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

Ali Codex'e yazar:

```
vercel'e deploy edelim, tutorial'ı aç
```

Codex `docs/tutorials/vercel.md` dosyasını okur, yönlendirir:

1. `vercel.com/signup` → GitHub ile giriş
2. Dashboard → "Add New Project" → `temiz-gunler` repo'yu import
3. Framework: Next.js (auto-detect) → Deploy
4. **İlk deploy fail**: env var'lar eksik
5. Settings → Environment Variables → 6 env'i 3 scope için gir:
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

Ali Codex'e yazar:

```
iyzico test ödeme nasıl yapılır ulak'a sor
```

Codex `/ulak-ask` protokolünü tetikler:

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

### Ali'nin Codex'te yaptığı (75-90 dk toplam)

| Zaman | NL tetikleyici | Codex protokolü | Sonuç |
|---|---|---|---|
| 0-2 dk | "selam ulak" | `/ulak-hello` | Ulak OS'u tanıdı |
| 2-14 dk | "1" (menüden) | `/ulak-start` wizard | 27 soruya cevap, özet + aktive panel |
| 14-15 dk | "[enter] = e" (onay) | `ulak scaffold` (Bash tool) | 140 dosyalık proje klasörü |
| 15-16 dk | "scaffold bitti şimdi ne yapayım" | `/ulak-next-steps` | Kişisel 12-adım runbook |
| 16-30 dk | "supabase tutorial'ı oku" | `Read` + yönlendirme | DB + auth + 3 env key |
| 30-45 dk | "github'a push edelim" | `Read` + yönlendirme | Repo + push + CI yeşil |
| 45-55 dk | "vercel'e deploy edelim" | `Read` + yönlendirme | Canlı URL + env vars |
| 55-65 dk | (resend tutorial) | `Read` + yönlendirme | Email entegrasyonu |
| 65-75 dk | "iyzico test ödeme nasıl" | `/ulak-ask` | Ödeme akışı |
| 75-85 dk | Polish + ilk admin user | — | Prod-ready demo |

### Codex vs Claude Code farkı (Ali'nin deneyimi)

| Boyut | Claude Code | Codex CLI |
|---|---|---|
| Komut tetikleyici | `/ulak-hello` slash | "selam ulak" NL |
| Scaffold çalıştırma | `/ulak-scaffold` auto-dispatch | Bash tool manuel run |
| Reading order | `CLAUDE.md` + `@`-import otomatik | Ali ilk mesajda manuel verir |
| Paralel subagent | Var | Yok — sıralı iterasyon |
| Çıktı kalitesi | Aynı | Aynı |
| Süre | 75-90 dk | 75-90 dk |

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

Aynı iş sıfırdan Codex ile: ~15 iş günü (3 hafta).
Ulak OS ile (Codex): 75-90 dakika.

---

## Codex'e özel notlar

### `/slash` yok, reading order manuel
Claude Code'da `CLAUDE.md` auto-load olur. Codex'te Ali ilk mesajında şunu verir:
```
Read AGENTS.md, prompts/core/ulak-os-core-contract-2.0.0.md,
docs/adapters/codex-cli.md, and docs/adapters/universal-runtime-contract.md.
```

### Paralel subagent yok
Claude Code'da `/director komple` Phase 2'de 7+ uzman paralel çalışır. Codex'te sıralı olarak her uzman dosyası `reports/current/specialists/<role>.md` altına ayrı ayrı yazılır. Süre daha uzun, doğruluk aynı.

### Skill invocation yok
Claude Code'da `Skill` tool var. Codex'te ilgili skill dosyasını (`.claude/skills/<name>/SKILL.md`) okur, protokolü manuel inline eder.

---

## Ali'ye v1.x sonrası tavsiyeler

1. İlk 10 gerçek kullanıcı → feedback topla
2. "director komple" de → Phase 0-5 audit
3. "14 boyutlu audit" de → quarterly health check
4. Custom domain bağla (`temizgunler.com`)
5. Iyzico sandbox → production'a geç (KYC lazım)
6. Supabase free tier → pro'ya (500 MAU aşarsa)
7. Vercel free → pro'ya (100 GB bandwidth aşarsa)
8. Monitoring: Sentry alerts + Better Stack uptime alerts

---

## Başka senaryolar için

- Minimal SaaS (tek kullanıcı tipi): "demo göster" → `/ulak-demo` protokolü → [1]
- Eğitim platformu: "demo göster" → [3]
- Fintech / Marketplace: "demo göster" → [2]
- Kendi senaryonu: "yeni saas" → `/ulak-start` wizard → otomatik scaffold

## Related docs

- `docs/walkthrough/01-first-saas-end-to-end.md` — Claude Code variant (aynı senaryo)
- `docs/adapters/codex-cli.md` — Codex vendor-primitive matrix + NL conversion principles
- `AGENTS.md` §"Natural-Language Trigger Map" — 24 komutun NL eşlemesi (kanonik)
- `docs/runbooks/first-hour-with-ulak-os.md` — daha kısa özet
- `docs/tutorials/supabase.md` + `vercel.md` + `github.md` + `resend.md` — servis rehberleri
- `docs/runtime/beginner-glossary.md` — 47 terim açıklaması
- `docs/FAQ.md` — 30+ sık sorulan soru
- `docs/catalog.md` — 24 komut + 10 skill + 27 ajan tam listesi
