# SSS

Ulak OS hakkında sık sorulan sorular — Türkçe sürümü. Ulak OS'u ilk kez duyanlar, başlangıç operatörleri ve üçüncü taraf servisleri bağlayan kullanıcılar için.

> **English version** → [`FAQ.md`](./FAQ.md)

---

## Beginner — İlk kez site yapacak olanlar

> Bu bölüm ilk hafta operatörleri için. Kod tecrübesi ≤ orta seviyede olanlara yönelik sorular ve cevaplar. Tüm cevaplar TR-primary, repo'daki somut dosya/komutlara referans verir.

### Ulak OS'u kullanmak için kod bilmek gerekir mi?

Kısa cevap: **Kısmen.** Tamamen kod bilmeyen birisi `/ulak-start` ile wizard'ı tamamlayıp `/ulak-scaffold`'u çalıştırabilir; çıktı **çalışan bir proje iskeleti** olur (Next.js + Supabase + auth + i18n + CI). Ama:

- `.env.local` dolduracak — Supabase URL/anahtarı yapıştırabilecek kadar hesap açma
- `pnpm install && pnpm dev` çalıştırabilecek kadar terminal
- Hata mesajı gelince Claude Code'a soracak kadar "durumu anlatma"

bilmek gerekir. "Tek tuşla çıkar" değil — "3 saatte çalışan skeleton" diye düşün.

### `/ulak-start` çalıştırdım, 27 soru soruyor — çok mu?

Hayır, ama hepsine cevap vermek zorunda değilsin. Her soru için `[enter]` = **sensible default**. 27 soru 5 faza bölünmüştür (Product / Stack / Business / Integration / Ops). Tipik operatör 10-12 soruya aktif cevap verir, gerisini enter'lar. Wizard 6-8 dakikada biter.

Eğer 27 soru bile çoksa `/ulak-scaffold` flag'li versiyonunu doğrudan kullan — örn. `/ulak-scaffold --name myapp --sector saas-starter --locale tr`.

### Scaffold sonrası `.env.local` dosyası boş. Ne yazacağım?

Scaffold `.env.local.example` dosyası üretir — şablon. Gerçek `.env.local`'i sen dolduracaksın, çünkü secret'lar senin hesaplarına ait. Adımlar:

1. **Supabase**: `supabase.com` → New project aç → Settings → API → `Project URL` ve `anon key`'i kopyala → `NEXT_PUBLIC_SUPABASE_URL` ve `NEXT_PUBLIC_SUPABASE_ANON_KEY` alanlarına yapıştır.
2. **Iyzico/Stripe** (payment seçtiysen): Iyzico için sandbox → API Keys → `IYZICO_API_KEY` + `IYZICO_SECRET_KEY`. Stripe için dashboard → Developers → API keys.
3. **Resend** (email): `resend.com` → API Keys → `RESEND_API_KEY`.

Detay + linkler için: `/ulak-next-steps` (scaffold sonrası 8-10 adımı kişiselleştirilmiş olarak dökerek verir).

### Supabase nedir, Firebase'in alternatifi mi?

Supabase = açık kaynaklı backend hizmeti. Database (Postgres), auth, storage, realtime bir arada. Firebase'e alternatif olarak doğdu, ama Postgres tabanlı olması + açık kaynak olması + self-host edilebilir olması ile ayrışıyor.

Ulak OS'ta **default backend**. `/ulak-explain supabase` komutu 5 alanlı açıklama verir (basit / teknik / analoji / Ulak'ta / ilgili).

İlk kez Supabase projesi açmak için sıfırdan 15 dk'lık ekran-adım bazlı rehber: [`docs/tutorials/supabase.md`](./tutorials/supabase.md) — hesap + project + API keys + migration push + ilk admin kullanıcı.

### Iyzico hesabı nasıl açılır?

`iyzico.com` → Üye ol → TR TC/şirket bilgileri → sandbox hesap otomatik açılır (onaylanırken günler sürebilir). Sandbox'ta test kart numarası ile (`5890 0400 0000 0016`) simulate kredi kartı çalışır.

Production'a geçmek için onay gerekir: şirket kimliği + banka hesabı + vergi numarası. TR merkezli iş için Stripe'dan daha uygun. Detay: `/ulak-explain iyzico`.

### localhost:3000 ne demek, canlı site nasıl olur?

`localhost:3000` = senin bilgisayarında çalışan site. İnternet'ten kimse göremez, sadece senin chrome'un açar. Geliştirme için böyle.

Canlı (internetten erişilebilir) hale gelmesi için **deploy** gerekir. Ulak scaffold iki seçenek sunar:
- **Vercel**: `git push` → `vercel.com/new` → GitHub repo bağla → otomatik deploy. Ücretsiz başlar. Önerilen: beginner için.
- **VPS + Traefik**: Kendi sunucunu kiralar, Docker Compose + Traefik edge ile deploy. Kontrol fazla, sorumluluk da fazla. Aylık 5-20 USD VPS + zaman.

`/ulak-explain localhost` ve `/ulak-explain vercel` / `/ulak-explain vps` detay verir.

### Vercel vs VPS — hangisini seçmeliyim?

Kriterler:
- **Beginner + hızlı ship**: Vercel. 10 dakikada canlı.
- **Düşük bütçe + uzun vadeli**: VPS. Aylık 5 USD'a başlayabilir.
- **Trafik tahmin edilemez + hızlı scale**: Vercel (serverless).
- **Tam kontrol (kendi DB, kendi cron, hassas data)**: VPS.
- **TR data residency zorunlu (KVKK)**: TR-based VPS (Hetzner FRA hariç; İstanbul DC arayan için yerli sağlayıcı).

Ulak OS her iki pattern'i de destekler; scaffold sırasında `--deploy vercel` veya `--deploy vps` seçersin.

Vercel'e ilk kez deploy için 10 dk'lık ekran-adım bazlı rehber: [`docs/tutorials/vercel.md`](./tutorials/vercel.md) — hesap + GitHub bağlama + env vars + custom domain + preview deploy + sorun giderme.

### Ödeme aldığımda vergi + KDV meselesi?

Ulak OS yazılım katmanıdır — **vergi mevzuatı tavsiyesi vermez**. Gerçek cevap: bir mali müşavire sor. Ama genel bilgi:

- TR'de şahıs şirketi / LTD ŞTİ açman gerekir (ödeme almak için)
- KDV (%20, yazılım/hizmet) + gelir/kurumlar vergisi
- Iyzico/Stripe ödeme alırken fatura kesme yükümlülüğü sende
- e-Fatura / e-Arşiv zorunluluğu belirli ciroda

Ulak scaffold'da `regulated-saas` sector overlay'i KVKK compliance için yardımcıdır (vergi için değil). Mali meseleler operatörün sorumluluğunda.

### Yazılımsız birisi bu projeyi kullanabilir mi?

Sınırlı. Ulak OS operatör-yönlü bir araç — **AI ile konuşan** bir insan lazım. Fakat o insan backend + frontend + DevOps ayrı ayrı bilmek zorunda değil; Claude Code yardımıyla yapabilir.

Pratik eşik: "Bir terminalde komut çalıştırabilirim, hata mesajını Claude'a kopyalayıp yapıştırabilirim" seviyesi yeterli. Hiç terminal görmemiş bir kullanıcı için şu an zor — ileride `/ulak-hello` gibi onboarding surface'ları büyüyecek.

### Ben bitirdim ama tasarım basit. Nasıl güzelleştiririm?

Üç seçenek:
1. `/frontend-war-room` komutu — Ulak OS'un premium redesign akışı. design-system-architect + frontend-ios-flutter-director ajanları paralel çalışır, token/spacing/typography/surface elden geçirir.
2. `/ulak-design-ref <brand>` — `awesome-design-md`'den bir markanın tasarım referansını çeker, frontend ajanlara dayanak verir. Örn: `/ulak-design-ref stripe`.
3. Manuel tasarımcı tutma + Tailwind tweak. Ulak scaffold `shadcn/ui` variant'ı base olarak koyar; üstüne custom theme eklemek standart iş.

---

## Beginner — Terim demistifikasyonu

> "Bu kelimeyi ilk kez duyuyorum" dediğin zaman bak. Her terim için detay: `/ulak-explain <term>` komutunu çalıştır — 5 alanlı açıklama verir (Basit / Teknik / Analoji / Ulak'ta / İlgili).

### JWT nedir?

**JSON Web Token.** Kullanıcı giriş yaptıktan sonra server'ın verdiği dijital kimlik kartı — sonraki her istekte bu kartı gösterirsin, "giriş yapmıştım" diye kanıtlarsın. Ulak'ta Supabase Auth JWT üretir. `/ulak-explain jwt` detaylı.

### RLS nedir?

**Row Level Security** — Postgres'in "bu satırı bu kullanıcı görebilir" kuralı. Database seviyesinde filtre. Ulak OS scaffold'da tenant-specific tablolarda default aktif. `/ulak-explain rls`.

### Tenant nedir?

Aynı uygulamayı paylaşan ama verileri birbirinden izole müşteri. 100 tenant = 100 ayrı şirket, tek uygulama. Ulak'ta multi-tenant disiplin `tenant_id` kolon + RLS policy ile sağlanır. `/ulak-explain tenant`.

### Migration nedir?

Database şemasını değiştirmek için tarihli SQL dosyaları. `supabase/migrations/00001_init.sql` → `00005_lms_schema.sql`. Versiyon kontrolü + rollback için gerekli. `/ulak-explain migration`.

### `i18n` ne?

`internationalization` (18 harf, başı I, sonu N, arada 18 → i18n). Çoklu dil desteği. Ulak'ta localization-ssot rule pack default. ≥2 locale zorunlu. `/ulak-explain i18n`.

### `.env.local` nedir?

Gizli ayarları (şifre, API anahtarı) koda değil bu dosyaya yazdığın yer. `.gitignore` içinde olur, repo'ya commit edilmez. `NEXT_PUBLIC_` prefix'li olanlar client'a açılır. `/ulak-explain env-local`.

### Webhook nedir?

Bir sistemden başka sisteme olay bildiren HTTP callback. Örn. Stripe ödeme tamamlandığında sana POST atar — "ödeme geldi, sipariş onayla". Ulak scaffold'da idempotency + signature verification zorunludur (AP-13). Detay: `docs/runtime/rule-packs/api-security.md`.

### Pnpm nedir, npm'den farkı ne?

`pnpm` = Package Manager, npm/yarn alternatifi. Disk'te daha az yer kaplar (symlink-based), daha hızlı install yapar, monorepo'ya daha uygun. Ulak scaffold default pnpm ile gelir. Alternatif istersen `package.json` stil aynı, komutlar değişir (`pnpm install` vs `npm install`).

### Monorepo ne?

Birden fazla proje/paketin tek bir git repo'da durduğu yapı. Ulak'ta `templates/monorepo-root/` + `templates/shared-packages/` var; örn. web + mobile + shared types tek repo'da. Tekil proje için gereksiz, 2+ paket varsa anlamlı.

### Docker Compose ne?

Birden çok container'ı (örn. web + database + redis) tek `docker-compose.yml` dosyasıyla başlatıp durduran araç. Ulak scaffold local dev için compose dosyası üretir. VPS deploy'da Traefik + compose pattern'i önerilir (bkz. `docs/runtime/rule-packs/vps-nginx-compose-topology.md`).

### CI nedir, neden gerekli?

**Continuous Integration.** Her git push'ta otomatik çalışan testler/linter/typecheck. Ulak scaffold `.github/workflows/ci.yml` ile gelir: typecheck + test + build + (opsiyonel) gitleaks. "Lokalimde çalışıyor" dedirtmez, repo'daki herkese aynı kapıyı kurar.

### OAuth nedir?

"Google ile giriş yap" / "GitHub ile giriş yap" dediğin zaman arkada çalışan protokol. Kullanıcı şifresini sana vermez, Google sana "bu kullanıcı Ali" diye token gönderir. Ulak'ta Supabase Auth OAuth provider'ları (Google, GitHub, Apple) config ile açılır.

### Seed data ne?

Boş bir database'i "çalışır örnek veriyle" dolduran initial insert'ler. `supabase/seed.sql`. Örn: admin kullanıcı, örnek kurs, örnek ürün. Development için zorunlu, production'da opsiyonel.

### Supabase anon key güvenli mi, public'e koyabilir miyim?

`NEXT_PUBLIC_SUPABASE_ANON_KEY` **client'a açılır** — `NEXT_PUBLIC_` prefix'i tam bu yüzden. Kendi başına bir tehlike değil; RLS policy'leri bu anahtarla gelen istekleri kısıtlar. **Ama**: `service_role` key'ini **asla** client'a veya repo'ya koyma — o admin anahtarıdır. `/ulak-explain env-local` + `docs/governance/secrets-rotation-policy.md`.

### KVKK nedir, ben de mi uyacağım?

6698 sayılı Kişisel Verilerin Korunması Kanunu. TR'de kullanıcı verisi işleyen herkes uymak zorunda. Aydınlatma metni, açık rıza, silme hakkı, VERBİS kaydı. Ulak OS'ta `regulated-saas` sector overlay'i KVKK runbook + auto-report üretici içerir. Yasal tavsiye değil — gerçek uyumluluk için avukat/danışman gerekir. `/ulak-explain kvkk`.

### Auth vs Authz farkı?

- **Authentication** (auth) = "Sen kimsin?" (giriş)
- **Authorization** (authz) = "Ne yapabilirsin?" (yetki)

Supabase Auth + RLS, bu iki katmanı birlikte işler. Örn: Ali giriş yaptı (auth), ama admin paneli sadece `role = 'admin'` olanlara açık (authz).

---

## Beginner — GitHub + Resend (external services)

> Scaffold'dan sonra GitHub'a push ve email gönderimi için external service hesap açma soruları. Detaylı adım-adım rehberler: `docs/tutorials/github.md` (20 dk) + `docs/tutorials/resend.md` (15 dk).

### GitHub hesabı açmak ücretli mi?

**Hayır** — kişisel hesap + sınırsız public repo + sınırsız private repo + 2000 CI dakikası/ay (private) / sınırsız (public) **ücretsiz**. Ücretli tier'lar (Pro/Team/Enterprise) ekstra CI dakikası, SSO, advanced security gibi kurumsal feature'lar sağlar; beginner ve small team için gerekmez.

Credit card kayıt zorunlu değil — email + telefon doğrulama yeterli. `/ulak-scaffold` ürettiği projeyi free tier'a push edebilirsin.

### SSH key nedir, neden HTTPS yerine kullanayım?

**SSH key** = lokal makinende üretilen şifreli kimlik çifti (public + private). GitHub'a public'i ekler, private'i diskinde saklarsın. Her push'ta GitHub "private key var mı?" diye bakar — şifre/token sormaz.

**HTTPS yerine SSH**:
- **Pratiklik**: Bir kez kurulur, her push'ta şifre sormaz. HTTPS artık Personal Access Token (PAT) istiyor — her ay rotate etmen gerekir.
- **Güvenlik**: Private key diskinde kalır; HTTPS'te token commit'e sızabilir.
- **Standard**: Çoğu Git rehberi SSH'yi default gösterir.

**HTTPS ne zaman mantıklı**:
- Kurumsal network SSH port'u (22) blokluyorsa.
- Geçici bir makinede anlık clone için.

Ulak OS rehberi SSH'yi default öneriyor. Detay: `docs/tutorials/github.md` §4.

### Resend vs Postmark vs SendGrid — hangisini seçmeliyim?

| Servis | Free tier | Aylık ücret (10k email) | Güçlü yan | Zayıf yan |
|---|---|---|---|---|
| **Resend** | 3000/ay, 100/gün | $20 (50k email) | DX, React Email, sade pricing, 2023'te çıktı | Yeni — SendGrid kadar battle-tested değil |
| **Postmark** | 100/ay | $15 (10k email) | Deliverability altın standart, transactional-only | Daha pahalı, marketing email yasak |
| **SendGrid** | 100/gün | $19.95 (50k email) | Büyük ekosistem, analytics detaylı | Twilio alımından beri UX bozuldu, spam klasörüne düşme artışı raporlanıyor |
| **AWS SES** | 62k/ay (EC2'den) | $1 (10k email) | Ultra-ucuz, scale sınırsız | Karmaşık kurulum, UI spartan, sandbox'tan çıkma zahmetli |

**Ulak OS default'u Resend** — beginner DX + React Email entegrasyonu + scaffold'un `lib/email/resend.ts` hazır gelmesi + EU region KVKK friendly.

Production'da 50k+ email/ay gönderiyorsan AWS SES'e geçiş düşünülebilir; ama başlangıç Resend.

### Domain'im yok ama test email göndermek istiyorum

İki yol:

1. **Resend'in shared address'i** (`onboarding@resend.dev`) — sadece **kendi Resend hesabının email adresine** gönderim. Başka kimseye gönderemezsin. Dev/test için ideal, production'da görünmez.

2. **Domain satın al** — Namecheap ~$10/yıl, Cloudflare Registrar ~$9/yıl (at-cost), TR için Turhost/Natro ~₺200-400/yıl. DNS kayıtlarını verify et → kendi adresinden email at. Detay: `docs/tutorials/resend.md` §3.

**Pratik tavsiye**: development sırasında `onboarding@resend.dev` ile başla. MVP'yi çalıştırmaya hazır olunca domain al + verify et. Deliverability domain verify olmadan kötüdür.

### Dependabot PR'larını nasıl merge ederim?

Her hafta Pazartesi sabahı inbox'ında 1-5 PR bulabilirsin. Güvenli akış:

1. **PR'ı aç** → "Files changed" ile `package.json` + lockfile diff'ine bak.
2. **CI yeşil mi**: yeşilse genelde güvenli (patch/minor).
3. **Changelog'u oku** — PR açıklamasında release notes linki olur. Breaking change var mı?
4. **Squash and merge** → PR kapanır, main güncellenir.

**Major version bump'larda dikkat**:
- Next.js 14 → 15 gibi major'lar breaking change getirir.
- CHANGELOG'u oku + kendi testlerini manuel koş.
- Şüphe duyuyorsan "close without merging" de — Dependabot gelecek hafta yeniden açar, sen hazır olduğunda.

**Toplu merge şart değil**: 5 PR varsa günde 1 tane merge et, güven geliştikçe tempo artar. "`auto-merge` patches only" ayarı GitHub UI'de repo level açılabilir (Dependabot'un güvenli patch'lerini otomatik merge eder).

Detay: `docs/tutorials/github.md` §8.

