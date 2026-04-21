# Beginner Glossary — Ulak OS

> **TR** — Yeni başlayan operatörlerin ilk hafta karşılaşacağı 15 temel terim. Her madde 5 alanlı sabit şema ile yazılır: **Basit / Teknik / Analoji / Ulak'ta / İlgili**. `/ulak-explain <term>` bu dosyayı lookup eder.
> **EN** — 15 core terms a first-week operator meets. Every entry uses the fixed 5-field schema: **Simple / Technical / Analogy / In Ulak / Related**. `/ulak-explain <term>` reads this file.

Bu dosya kasıtlı olarak minimal tutulmuştur (15 madde). Paralel olarak çalışan `education-content-author` ajanı bu dosyayı 30 maddeye çıkaracaktır. Mevcut madde şeması değiştirilmez — append-only genişletilir.

Arama normalize kuralı:
- TR/EN alias kabul edilir (`rls` = `row level security`)
- Kısaltma = uzun biçim (`jwt` = `json web token`)
- Case-insensitive lookup

---

## rls
- **Alias**: row-level-security, row level security
- **Basit**: Database'de bir müşterinin verilerini başka müşterinin görmesini engelleyen filtre sistemi.
- **Teknik**: Postgres'in row-level security policy'leri; kullanıcı/tenant ID'sine göre SELECT/UPDATE/DELETE erişimini row bazında kısıtlar. Ulak scaffold'da Supabase üstünde aktive edilir.
- **Analoji**: Apartman dairesi — her komşu sadece kendi dairesinin anahtarına sahip; güvenlik binadan (database) yönetilir, kapıdan (uygulama) değil.
- **Ulak'ta**: `/ulak-scaffold` üretilen SQL migration'larında her tenant-specific tabloda RLS aktif edilir. Örnek: `supabase/migrations/00002_rls_policies.sql`. AP-11 (RLS-gate-bypass-prevention) bu prensibi korur.
- **İlgili**: tenant, multi-tenant, auth, supabase, AP-11
- **Daha fazla**: `docs/runtime/rule-packs/multi-tenant-supabase.md`, `docs/runtime/cross-tenant-rls-verification.md`

## supabase
- **Alias**: supabase.com
- **Basit**: Hazır backend — database + auth + storage + realtime bir arada. Kod yazmadan Postgres veritabanı açarsın.
- **Teknik**: Açık kaynak Firebase alternatifi; managed Postgres + PostgREST + GoTrue auth + Storage + Realtime. Self-hostable (bkz. `self-hosted-supabase` sector).
- **Analoji**: Arka mutfak — yemek pişirmek için soba, dolap, bulaşık makinesi hazır; sen sadece menüyü (uygulamanı) yazıyorsun.
- **Ulak'ta**: Default backend. `/ulak-scaffold` Supabase URL + anon key ister, RLS'li migration'lar üretir. 3 persona (customer/admin/public) ayrı policy kümesi alır.
- **İlgili**: postgres, rls, auth, firebase, self-hosted-supabase
- **Daha fazla**: `docs/runtime/rule-packs/multi-tenant-supabase.md`

## jwt
- **Alias**: json-web-token, token, access-token
- **Basit**: Kullanıcı giriş yaptıktan sonra server'ın verdiği dijital kimlik kartı. Her istekte bu kartı göstererek "ben giriş yapmıştım" kanıtlar.
- **Teknik**: JSON Web Token — imzalanmış (HS256 veya RS256) üç parçalı (header.payload.signature) base64url string. Expiration claim'i içerir; Supabase 1 saat varsayılan.
- **Analoji**: Sinemadaki giriş bilekliği — görevliye her salona girişte gösterirsin; gişeye geri dönmek gerekmez.
- **Ulak'ta**: Supabase Auth JWT üretir. Server-side doğrulama: `lib/supabase/server.ts`. Client'ta httpOnly cookie'de saklanır.
- **İlgili**: auth, session, supabase, cookie, rls
- **Daha fazla**: `docs/runtime/rule-packs/api-security.md`

## tenant
- **Alias**: kiracı, tenant-id, multi-tenant
- **Basit**: Aynı uygulamayı paylaşan ama verileri birbirinden izole müşteri hesabı. 100 kiracı = 100 ayrı şirket, tek uygulama.
- **Teknik**: Multi-tenant mimaride her satır `tenant_id` foreign key taşır; RLS policy tenant_id'ye göre filtreler. Shared-database / shared-schema pattern.
- **Analoji**: Ofis binası — herkes aynı binayı paylaşır ama kendi katındaki dosya dolabına bakar.
- **Ulak'ta**: `tenant_id` her customer-facing tabloda zorunlu. AP-11 + AP-14 (cross-tenant leak) bu izolasyonu korur.
- **İlgili**: rls, supabase, auth, AP-11
- **Daha fazla**: `docs/runtime/rule-packs/multi-tenant-supabase.md`

## env-local
- **Alias**: .env.local, env, environment-variables
- **Basit**: Gizli ayarları (şifre, API anahtarı) koda değil bu dosyaya yazarsın. Git'e commit etmezsin.
- **Teknik**: Next.js'te `.env.local` runtime env var'ları sağlar; `NEXT_PUBLIC_` prefix'li olanlar client'a açılır, diğerleri sadece server'da.
- **Analoji**: Ev anahtarı — cüzdanında tutarsın, sosyal medyaya koymazsın.
- **Ulak'ta**: Scaffold sonrası `.env.local.example` şablon üretilir; operatör gerçek değerlerle doldurur. `.gitignore` ile repo dışı tutulur (AP-06).
- **İlgili**: secrets, gitignore, AP-06, supabase
- **Daha fazla**: `docs/governance/secrets-rotation-policy.md`

## localhost
- **Alias**: localhost:3000, 127.0.0.1
- **Basit**: Sadece senin bilgisayarında çalışan site — internetten kimse göremez. Geliştirme için kullanılır.
- **Teknik**: Loopback network interface (127.0.0.1); 3000 Next.js dev server varsayılan port'u. Production'a `pnpm build && pnpm start` veya Vercel/VPS deploy ile geçilir.
- **Analoji**: Evindeki özel spor salonu — antrenman yaparsın, müşteri giremez.
- **Ulak'ta**: `pnpm dev` ile açılır. Production URL almak için deploy adımı gerekli (Vercel / VPS / Docker).
- **İlgili**: vercel, vps, deploy, pnpm
- **Daha fazla**: `docs/runbooks/first-hour-with-ulak-os.md`

## vercel
- **Alias**: vercel.com
- **Basit**: Next.js projesi için "git push yap, site canlıya çıksın" tek-tık hosting. Ücretsiz başlar.
- **Teknik**: Serverless + Edge platformu; Next.js'in yaratıcısı olan şirket işletir. Otomatik CI, preview URL, CDN, SSL dahil.
- **Analoji**: Yemek servisi — sen tabağı hazırlarsın (`git push`), onlar masaya taşır (URL verir).
- **Ulak'ta**: Default deploy seçeneği. Alternatifi VPS (Traefik + Docker Compose). `/ulak-scaffold --deploy vercel` seçimi yapılırsa `vercel.json` üretilir.
- **İlgili**: vps, traefik, deploy, localhost
- **Daha fazla**: `docs/runbooks/first-hour-with-ulak-os.md`

## vps
- **Alias**: virtual-private-server, sunucu
- **Basit**: Kiraladığın bir bilgisayar — üstüne istediğini kurarsın. Aylık 5-20 USD. Daha fazla kontrol, daha fazla sorumluluk.
- **Teknik**: Virtual Private Server; KVM/Xen üstünde çalışan izole Linux. Hetzner, DigitalOcean, Contabo yaygın. Ulak scaffold Traefik + Docker Compose topolojisi önerir.
- **Analoji**: Kendi kafeni kurmak — lokasyon senin, menüyü, dekoru, saatleri sen belirlersin; temizliği de sen yaparsın.
- **Ulak'ta**: `/ulak-scaffold --deploy vps` Traefik edge + Docker Compose + gitleaks + health-probe webhook ile gelir. `templates/sectors/multi-project-traefik-edge/` pattern'ini kullanır.
- **İlgili**: vercel, traefik, docker, deploy, AP-07
- **Daha fazla**: `docs/runtime/rule-packs/vps-nginx-compose-topology.md`

## iyzico
- **Alias**: iyzico.com
- **Basit**: Türkiye'de kredi kartı ödemesi almanın yerli yolu. TL tahsilat + Türk Lirası komisyon + Türkçe destek.
- **Teknik**: Türkiye odaklı payment gateway; 3D Secure, subscription, marketplace split, refund API'leri. BKM Express + bankaların POS'ları ile entegre.
- **Analoji**: Türkçe konuşan kasiyer — yabancı dil (Stripe) yerine Türkçe fatura kesiyor, Türk kullanıcıya güven veriyor.
- **Ulak'ta**: Payment seçeneği olarak Stripe ile birlikte sunulur. `/ulak-scaffold --payment iyzico` ile `lib/payment/iyzico/` üretilir. FSM pattern transactional-fsm-payment rule pack'inden gelir.
- **İlgili**: stripe, payment, kvkk, AP-12
- **Daha fazla**: `docs/runtime/rule-packs/payment-integrated-saas.md`

## stripe
- **Alias**: stripe.com
- **Basit**: Uluslararası kredi kartı ödemesi — USD, EUR alırsın. Geliştirici deneyimi en güçlü payment gateway'i.
- **Teknik**: Global payment platform; Checkout, Subscriptions, Connect (marketplace split), webhook-based lifecycle. Idempotency key zorunlu.
- **Analoji**: İngilizce konuşan kasiyer — turistleri (uluslararası müşteri) rahat çalışır; yerli (TR) müşteride friction yaratabilir.
- **Ulak'ta**: Payment seçeneği. `/ulak-scaffold --payment stripe` ile `lib/payment/stripe/` + webhook handler + idempotency helper üretilir.
- **İlgili**: iyzico, payment, webhook, fsm
- **Daha fazla**: `docs/runtime/rule-packs/payment-integrated-saas.md`

## kvkk
- **Alias**: 6698, turkish-gdpr
- **Basit**: Türkiye'nin kişisel veri kanunu. "Kullanıcı verisini saklarken neye dikkat etmelisin"in yasal versiyonu.
- **Teknik**: 6698 sayılı Kişisel Verilerin Korunması Kanunu. Veri sorumlusu kaydı (VERBİS), aydınlatma metni, açık rıza, silme hakkı, yurtdışı aktarım kuralı.
- **Analoji**: Apartman yönetim kuralı — komşularının bilgisini topluyorsan, nerede tuttuğunu, kime verdiğini, silme talebini nasıl karşılayacağını yazılı anlatmak zorundasın.
- **Ulak'ta**: `regulated-saas` sector overlay'inde KVKK runbook + auto-report üretici yer alır. AP-15 (kvkk-consent-flow) bu zorunluluğu korur.
- **İlgili**: gdpr, privacy, consent, regulated-saas
- **Daha fazla**: `docs/governance/localization-governance.md`, `templates/sectors/regulated-saas/`

## auth
- **Alias**: authentication, giriş
- **Basit**: Kullanıcının "ben Ali'yim" iddiasını doğrulama. Email+şifre, OAuth (Google), magic link gibi yöntemler.
- **Teknik**: Authentication = kimlik; Authorization = yetki. Supabase Auth GoTrue servisini kullanır, JWT üretir. Server-side session doğrulama zorunlu (AP-02).
- **Analoji**: Binaya girişte kimlik kartı (authentication) ile kapıdan geçmek; içeride hangi katlara gidebileceğin (authorization) başka bir mesele.
- **Ulak'ta**: Tek auth helper prensibi (AP-01) — tüm projede tek `lib/auth/` klasörü. Supabase Auth + RLS çiftliği default.
- **İlgili**: jwt, rls, supabase, AP-01, AP-02
- **Daha fazla**: `docs/runtime/rule-packs/api-security.md`

## migration
- **Alias**: database-migration, schema-migration
- **Basit**: Database şemasını değiştirmenin "versiyonlu" yolu. Yeni tablo, yeni kolon eklerken tarihli bir SQL dosyası yazılır.
- **Teknik**: Zamanda-ileri SQL dosyaları (örn. `00001_init.sql` → `00005_lms_schema.sql`). Her migration idempotent ve atomic olmalı. Supabase CLI sıralı uygular.
- **Analoji**: Evde tadilat defteri — "Ocak'ta mutfak boyandı, Şubat'ta banyo genişletildi" listesi; geri alma (rollback) için gerekli.
- **Ulak'ta**: `supabase/migrations/` altında tarihli dosyalar. `/ulak-scaffold` sector bazlı migration zinciri üretir (örn. marketplace için `00005_marketplace_schema.sql`).
- **İlgili**: supabase, rls, schema, rollback
- **Daha fazla**: `docs/runtime/rule-packs/multi-tenant-supabase.md`

## i18n
- **Alias**: internationalization, localization, l10n, çoklu-dil
- **Basit**: Uygulamayı birden çok dilde göstermek — TR ve EN arasında bir toggle. Hard-coded metin yerine çeviri tablosu.
- **Teknik**: Internationalization (abbr. "i18n"). Ulak OS'ta SSOT locale dosyası (`locales/tr/*.json`), placeholder discipline, locale-aware casing (TR `i/ı/İ/I`), DB kolon nötr rule.
- **Analoji**: Restoran menüsü — aynı yemek, 3 dilde yazılmış; kuruluşu tek kaynak JSON yönetir.
- **Ulak'ta**: `localization-ssot` rule pack default aktif. ≥2 locale zorunlu. AP-19 (localization-leak) bu disiplini korur.
- **İlgili**: locale, ssot, turkish-locale, AP-19
- **Daha fazla**: `docs/runtime/localization-strategy.md`, `docs/runtime/turkish-normalization.md`

## anti-pattern
- **Alias**: AP, AP-NN, yanlış-pattern
- **Basit**: "Bunu yapma" rehberi — gerçek projelerde yanmış, tekrarlanmaması gereken yanlışlar. Ulak'ta numaralı (AP-01 ... AP-19).
- **Teknik**: Named anti-pattern registry. Her madde {problem / belirti / doğru pattern / referans projede kanıt} 4 alanlı şema ile yazılır. 19 numaralı + ~79 bullet vardır.
- **Analoji**: Yemek tarifinde "tavayı boş ısıtma" uyarısı — başkası yanmış, sen yanmayasın diye.
- **Ulak'ta**: `/ulak-scaffold` 8 AP'yi yapısal olarak gate'ler (single auth helper, server-only guards, RLS symmetry...). `/director komple` bulursa findings'e düşer.
- **İlgili**: rls, auth, secrets, AP-01, AP-11
- **Daha fazla**: `docs/runtime/anti-patterns.md`

---

## Lookup kuralları

`/ulak-explain <term>` çağrıldığında:

1. Term'i lowercase + trim + Turkish-normalize et
2. Önce ana key'de (örn. `rls`), sonra `Alias:` satırlarında ara
3. Eşleşme varsa 5-alan şemasında render et
4. Eşleşme yoksa fallback: `docs/catalog.md` + `docs/runtime/*.md` grep + en yakın 3 adayı "Did you mean?" olarak listele

## Genişletme protokolü

- Append-only: mevcut maddeler silinmez, şemaları değiştirilmez
- Yeni maddede 5 alan (Basit / Teknik / Analoji / Ulak'ta / İlgili) zorunlu
- `Daha fazla` opsiyonel ama varsa gerçek bir dosya yoluna işaret etmeli
- Alfabetik değil, "öğrenim sırasına" göre dizilmiştir; yeni maddeler ilgili komşularının yanına eklenir

---

## sso
- **Alias**: single-sign-on, single sign on, saml, oidc
- **Basit**: Şirket e-postanla bir kez giriyorsun, tüm şirket uygulamaları seni tanıyor. Büyük şirketlerin kullandığı merkezi giriş sistemi.
- **Teknik**: SAML 2.0 / OIDC üzerinden merkezi IdP ile kimlik federasyonu; kullanıcı organizasyonunun kimlik sağlayıcısıyla (Google Workspace, Azure AD, Okta) girer.
- **Analoji**: İş binası turnikesi — bir kez kimlik bastın, tüm katlara geçebiliyorsun; her katta tekrar giriş yapma.
- **Ulak'ta**: Sadece `audience=enterprise` seçilirse aktif; solo/small-team için gereksiz karmaşıklık. `saas,admin-cms-hardening` overlay'inde default Google + Azure AD + Okta.
- **İlgili**: auth, scim, idp, enterprise, jwt
- **Daha fazla**: `docs/runtime/rule-packs/admin-cms-hardening.md`

## scim
- **Alias**: system-for-cross-domain-identity-management, user-provisioning
- **Basit**: Şirkete yeni biri girdiğinde IT ekibi onu tek tek eklemez; şirketin kimlik sisteminden uygulamana otomatik aktarılır. Çıktığında da otomatik kapanır.
- **Teknik**: SCIM 2.0 protokolü; IdP'den kullanıcı create/update/deprovision isteklerini otomatik taşır. Enterprise için zorunlu; 50+ kişi ekiplerde İK yükünü keser.
- **Analoji**: Bina güvenliğinin çalışan giriş-çıkış listesini otomatik güncellemesi — İK tek yerde ekler, tüm binada yetki açılır.
- **Ulak'ta**: `false` default. Small team için gereksiz; `audience=enterprise` olsa bile opt-in. SSO ile birlikte recommend.
- **İlgili**: sso, auth, idp, enterprise
- **Daha fazla**: `docs/runtime/rule-packs/admin-cms-hardening.md`

## oauth
- **Alias**: oauth2, oauth-2.0, üçüncü-taraf-giriş
- **Basit**: "Google ile giriş yap" butonu. Kullanıcı Google'da giriş yapar, Google sana "bu kişi doğru" der. Şifre senin sunucuna hiç gelmez.
- **Teknik**: OAuth 2.0 / OIDC akışı — authorization code flow + PKCE. Supabase Auth provider olarak Google, GitHub, Apple, Microsoft destekler.
- **Analoji**: Etkinlik girişinde kimliğini kasiyere göstermek yerine bilekliğin olması — kapıdaki görevli bilekliği görüyor, kim olduğunu zaten biliyor.
- **Ulak'ta**: Google + GitHub default; consumer sector'lerde (2/5/13) Apple eklenir. `email+magic-link+google-oauth` Ulak varsayılan kombosu.
- **İlgili**: auth, jwt, magic-link, sso, supabase
- **Daha fazla**: `docs/runtime/rule-packs/api-security.md`

## magic-link
- **Alias**: passwordless, magic link, email-link-login
- **Basit**: Şifre yerine email adresini girersin, email'ine link gelir, linke tıklarsın, girmiş olursun. Şifre hatırlamak gerekmez.
- **Teknik**: Tek kullanımlık, zaman sınırlı (15 dk default), tek-seferlik imzalı token taşıyan email linki. Supabase Auth magic-link endpoint + GoTrue üstünden.
- **Analoji**: Partiye davet kartı — kart üstündeki QR tek kullanımlık; okuttun mu bitti, başka birine verilemez.
- **Ulak'ta**: Her stack'te açık. Sebep: şifre unutma churn sebebi #1. `email+magic-link+google-oauth` kombosu default.
- **İlgili**: auth, oauth, jwt, supabase
- **Daha fazla**: `docs/runtime/rule-packs/api-security.md`

## csrf
- **Alias**: cross-site-request-forgery, sahte-istek
- **Basit**: Kötü niyetli bir site kullanıcının tarayıcısını kullanarak senin siten adına işlem yapmaya çalışabilir. Bu saldırıya karşı korunma.
- **Teknik**: Cross-Site Request Forgery; başka bir site cookie ile senin API'ne istek atma saldırısı. Double-submit cookie veya SameSite=Strict + CSRF token ile önlenir.
- **Analoji**: Birinin senin anahtarını kopyalayıp evine girmeden önce kapıya ikinci bir kilit taktığın düşün — her girişte iki kilidi de biliyor olman gerekiyor.
- **Ulak'ta**: Next.js SameSite=Lax cookie + framework-level CSRF token. Kullanıcı konfigüre etmez; API security rule pack zorunlu kılar.
- **İlgili**: auth, jwt, api, webhook
- **Daha fazla**: `docs/runtime/rule-packs/api-security.md`

## ssr
- **Alias**: server-side-rendering, server side rendering
- **Basit**: Sayfa kullanıcıya gelmeden önce sunucuda hazırlanıyor. Google'ın okuması ve kullanıcının "boş sayfa" görmemesi için.
- **Teknik**: Server-Side Rendering; sayfa HTML'i sunucuda render edilir, client full HTML alır. Next.js App Router'da `async` server components default SSR.
- **Analoji**: Restoranda yemek mutfakta hazırlanıp masaya geliyor — sen oturur oturmaz önünde tabak; kimse önünde pişirmiyor.
- **Ulak'ta**: Public marketing sayfası = SSR, admin = CSR. Next.js App Router otomatik seçer; kullanıcı override edebilir.
- **İlgili**: csr, nextjs, seo
- **Daha fazla**: `docs/runtime/rule-packs/frontend-currency.md`

## csr
- **Alias**: client-side-rendering, client side rendering, spa
- **Basit**: Sayfa tarayıcıda hazırlanır. Admin paneli gibi login'in arkasındaki ekranlar için uygun (SEO gerekmez).
- **Teknik**: Client-Side Rendering; boş HTML shell + JS bundle, React tarayıcıda mount olup içeriği çizer. `'use client'` directive ile Next.js'te işaretlenir.
- **Analoji**: Evde IKEA mobilyası gelince sen kurarsın — kutu küçük (hızlı indirme), ama kurmak (render) için zaman lazım.
- **Ulak'ta**: Otomatik; dashboard + admin sayfaları için kullanılır, marketing için SSR seçilir.
- **İlgili**: ssr, nextjs
- **Daha fazla**: `docs/runtime/rule-packs/frontend-currency.md`

## api
- **Alias**: application-programming-interface, rest, graphql
- **Basit**: Frontend API'ye istek atar, API veriyi geri verir. İki yazılım parçasının konuşma kapısı.
- **Teknik**: HTTP (REST / GraphQL / tRPC) endpoint seti; client ile server arasındaki sözleşme. Ulak OS'ta Next.js Route Handlers (REST) + Supabase client default.
- **Analoji**: Restoran menüsü — müşteri (frontend) siparişi garson (API) aracılığıyla verir, mutfak (backend) hazırlar, geri döner.
- **Ulak'ta**: 3 persona ayrımı zorunlu — customer API / admin API / public API ayrı klasör + ayrı auth guard. AP-02 (API split) bu ayrımı korur.
- **İlgili**: webhook, auth, rls, jwt
- **Daha fazla**: `docs/governance/product-surface-split.md`

## webhook
- **Alias**: callback, geri-çağırma, server-to-server-event
- **Basit**: Başka bir servis (Stripe, GitHub, Iyzico) senin siteye "ödeme geldi" / "commit push edildi" gibi olayları haber vermek için bir URL'ine istek atar.
- **Teknik**: 3rd party'nin olay olduğunda senin endpoint'ini HTTP POST ile tetiklemesi; imzalı (HMAC) payload + idempotency key.
- **Analoji**: Kargo teslim bildirimi — paketi sen takip etmiyorsun, kargocu geldiğinde zili çalıyor.
- **Ulak'ta**: Stripe/Iyzico webhook'ları + GitHub Actions webhook'u otomatik kurulur. `lib/payment/*/webhook.ts` imza doğrulama zorunlu.
- **İlgili**: stripe, iyzico, idempotent, api, fsm
- **Daha fazla**: `docs/runtime/webhook-ci-deploy-pattern.md`

## idempotent
- **Alias**: idempotency, idempotency-key, retry-safe
- **Basit**: Aynı işlemi 10 kez tekrarlarsan bile bir kez yapılmış sayılır. Ödemelerde kritik: "2 kere tahsilat etmesin" garantisi.
- **Teknik**: Aynı request'in N kez çalışmasının tek kez çalışmasıyla aynı sonucu üretmesi. Idempotency-Key header + server-side request dedup (Redis / DB constraint).
- **Analoji**: Asansör düğmesi — 10 kere de bassan asansör bir kere geliyor; fazla basmak fazla geliş demek değil.
- **Ulak'ta**: Payment + critical write endpoint'lerinde zorunlu; `docs/runtime/transactional-fsm-payment.md` pattern'i idempotency-key + FSM tabanlı.
- **İlgili**: fsm, webhook, stripe, iyzico
- **Daha fazla**: `docs/runtime/transactional-fsm-payment.md`

## fsm
- **Alias**: finite-state-machine, state-machine, durum-makinesi
- **Basit**: Bir işin hangi aşamada olduğunu takip etmek. Sipariş: "beklemede → ödeme alındı → hazırlanıyor → kargoda → teslim edildi". Her adım bir önceki adımdan sonra gelir.
- **Teknik**: Belirli state'ler + geçişler (transitions) ile modellenen process; explicit state machine (XState) veya internal enum-based transition.
- **Analoji**: Trafik ışığı — kırmızı → sarı → yeşil → sarı → kırmızı; kırmızıdan direkt yeşile atlamak yok.
- **Ulak'ta**: Payment + order flow için explicit FSM zorunlu (`docs/runtime/transactional-fsm-payment.md`); diğerleri implicit.
- **İlgili**: idempotent, webhook, payment
- **Daha fazla**: `docs/runtime/transactional-fsm-payment.md`

## escrow
- **Alias**: emanet, held-funds, platform-escrow
- **Basit**: Alıcı ödemesi sende bekler. Alıcı "ürünü aldım" der, sen parayı satıcıya gönderirsin. Anlaşmazlık olursa para sende kalır.
- **Teknik**: 2-sided marketplace primitive; alıcı ödemesinin platform tarafından tutulup, teslimat onayı sonrası satıcıya release edilmesi. Stripe Connect / Iyzico marketplace split ile.
- **Analoji**: Emlakçıda kapora — alıcı parayı emlakçıya verir, tapu devri olunca satıcıya geçer; emlakçı ortada güven kaynağı.
- **Ulak'ta**: `sector=marketplace` + opt-in; default `false`. MVP'de genelde yok, trust artınca eklenir. Marketplace overlay'de escrow + dispute-flow birlikte.
- **İlgili**: commission, marketplace, payment, dispute-flow
- **Daha fazla**: `templates/sectors/marketplace/`

## commission
- **Alias**: komisyon, platform-fee, fee-split
- **Basit**: Her satıştan platformun aldığı pay. "10%" demek = 100 TL'lik satıştan 10 TL platform, 90 TL satıcı alır.
- **Teknik**: Platform'un transaction tutarı üzerinden aldığı yüzde veya sabit kesinti; Stripe Connect `application_fee` veya manuel fee split logic.
- **Analoji**: Emlakçı komisyonu — evi kiralayan müşteri emlakçıya belli bir yüzde verir; işi yapan ortaya para koyar.
- **Ulak'ta**: Marketplace overlay'de `0.10` (%10) default — sektör ortalaması. `docs/runtime/wizard-defaults.md` §marketplace'de tunable.
- **İlgili**: escrow, marketplace, payment
- **Daha fazla**: `docs/runtime/wizard-defaults.md`

## kyc
- **Alias**: know-your-customer, kimlik-doğrulama
- **Basit**: Kullanıcının kim olduğunu kanıtlaması. Kimlik fotoğrafı + selfie — sistem yüzü kimlikteki fotoğrafla karşılaştırır. Finans uygulamaları zorunlu yapar.
- **Teknik**: Kimlik doğrulama + belge (kimlik, pasaport) + biyometri (selfie) ile kullanıcının kim olduğunu teyit etme; Sumsub/Onfido/Veriff SDK entegrasyonu.
- **Analoji**: Bankada hesap açarken kimlik gösterip selfie çektirmek — yasa hesap sahibinin gerçekten o kişi olmasını istiyor.
- **Ulak'ta**: `sector=fintech` → `sumsub` default (TR uyumu + bankalara onay); diğer sektörlerde opsiyonel.
- **İlgili**: aml, fintech, compliance
- **Daha fazla**: `templates/sectors/fintech/`

## aml
- **Alias**: anti-money-laundering, kara-para-aklama-önleme
- **Basit**: Kullanıcıların kara para aklamadığından emin olma süreci. Büyük transfer → sistem durdurup kontrol eder. "Bu kişi yaptırım listesinde mi?" sorgular.
- **Teknik**: Transaction monitoring + sanctions screening + suspicious activity reporting (SAR); regulator-driven compliance zorunlu fintech için.
- **Analoji**: Havaalanında büyük nakit parayla yakalanırsan durduruluyorsun — "bu para nereden?" sorulması gerekiyor; sistem benzer sorgu.
- **Ulak'ta**: `sector=fintech` → otomatik aktif. KYC ile birlikte audit-trail zorunlu.
- **İlgili**: kyc, fintech, compliance, audit-log
- **Daha fazla**: `templates/sectors/fintech/`

## gdpr
- **Alias**: general-data-protection-regulation, ab-veri-koruma
- **Basit**: AB'nin veri koruma yasası. Kullanıcı "verilerimi göster / sil" diyebilir, sen uymak zorundasın. İhlal olursa 72 saatte bildirmelisin.
- **Teknik**: AB 2016/679 (GDPR); data subject rights (erişim, silme, taşıma), DPIA, DPO, 72-saat breach notification. Ciro'nun %4'üne kadar ceza.
- **Analoji**: Komşunun "benim hakkımda ne biliyorsun?" sorusuna detaylı cevap vermek zorunda olman — ve istediğinde silmen.
- **Ulak'ta**: `region=eu` → force; `region=global` → conservative uyum. `regulated-saas` overlay'de auto-report üretir.
- **İlgili**: kvkk, hipaa, compliance, privacy
- **Daha fazla**: `docs/governance/localization-governance.md`

## hipaa
- **Alias**: health-insurance-portability-accountability-act, abd-saglik-veri
- **Basit**: Amerika'nın sağlık veri yasası. Hasta verisi (PHI) taşıyorsan uyumak zorundasın. Verileri şifrele, kim gördüğünü logla, 3rd party ile BAA imzala.
- **Teknik**: 45 CFR Parts 160 + 164; PHI encryption at rest + in transit, BAA (Business Associate Agreement), access logging, minimum necessary rule.
- **Analoji**: Hasta dosyasını sadece yetkili doktor + hemşire okur — kat görevlisi göremiyor; dolap kilitli, anahtarın kimlerde olduğu kayıt.
- **Ulak'ta**: `sector=health-sensitive` → force. PHI encryption + BAA requirements + audit-log zorunlu.
- **İlgili**: phi, gdpr, compliance, audit-log
- **Daha fazla**: `templates/sectors/health-sensitive/`

## soc2
- **Alias**: soc-2, soc2-type2, trust-services-criteria
- **Basit**: Enterprise müşterilerin "senin sistemin güvenli mi?" sorusunu cevaplayan denetim raporu. Süreçleri dokümante edip bağımsız denetimden geçirmek.
- **Teknik**: AICPA Trust Services Criteria (security, availability, confidentiality, processing integrity, privacy); Type 1 snapshot, Type 2 = 6-12 ay audit periyodu.
- **Analoji**: Restoran hijyen sertifikası — sağlık bakanlığı 6 ay izleyip sertifika veriyor; müşteri duvardaki sertifikayı görüp güveniyor.
- **Ulak'ta**: `audience=enterprise` → Type 2 baseline recommend. Audit-retention min 1-year force.
- **İlgili**: compliance, audit-log, enterprise, gdpr
- **Daha fazla**: `templates/sectors/regulated-saas/`

## coppa
- **Alias**: children-online-privacy-protection-act, cocuk-veri-yasasi
- **Basit**: 13 yaş altı çocuk kullanıcın varsa ebeveyn onayı almadan veri toplayamazsın. ABD yasası; eğitim uygulamaları çok etkilenir.
- **Teknik**: 15 U.S.C. 6501-6506; 13 yaş altı için verifiable parental consent, minimum data collection, ayrı privacy policy.
- **Analoji**: Okulun "çocuğumun fotoğrafını etkinlikte kullanabilirsiniz" izin formu — ebeveyn imzası olmadan yasak.
- **Ulak'ta**: `sector=education` + minors → auto. KVKK/GDPR ile birlikte uygulanır.
- **İlgili**: gdpr, kvkk, compliance, education
- **Daha fazla**: `templates/sectors/education/`

## pci-dss
- **Alias**: pci, pci-dss-saq, kart-verisi-guvenligi
- **Basit**: Kredi kartı verisine dokunuyorsan uyman gereken standart. Çözüm: hiç dokunma — Stripe/Iyzico token'la çalış, veri onlarda kalır.
- **Teknik**: Payment Card Industry Data Security Standard; 12 kontrol + 6 kategori. Stripe/Iyzico token ile SAQ-A scope'una indirilir (en hafif seviye).
- **Analoji**: Mağazada kart okuyucuyu kendin yapmak yerine bankanın cihazını kullanmak — uyumsa banka; senin sorumluluğun sadece cihazı prize takmak.
- **Ulak'ta**: Payment provider'a delegate edilir — direkt kart verisi tutulmaz. AP-08 sandbox↔live switch discipline.
- **İlgili**: stripe, iyzico, payment, compliance
- **Daha fazla**: `docs/runtime/rule-packs/payment-integrated-saas.md`

## ci
- **Alias**: continuous-integration, surekli-entegrasyon
- **Basit**: Sen kod push ettiğinde otomatik testler koşar, hata varsa söyler. "Kod bozuk olarak main'e girmesin" garantisi.
- **Teknik**: Her commit'te otomatik test + lint + build + secret-scan çalıştıran pipeline. GitHub Actions default.
- **Analoji**: Üretim hattındaki kalite kontrol kamerası — her ürün bandan geçerken kontrol edilir, kusurlu olan ayrılır.
- **Ulak'ta**: `github-actions` default. `validate-imports + validate-schemas + gitleaks + eval-smoke` workflow'ları otomatik kurulur.
- **İlgili**: cd, github-actions, gitleaks
- **Daha fazla**: `docs/runtime/webhook-ci-deploy-pattern.md`

## cd
- **Alias**: continuous-deployment, continuous-delivery, surekli-dagitim
- **Basit**: CI geçtiyse kod otomatik olarak sunucuya yüklenir. Manuel deploy yok.
- **Teknik**: CI geçtikten sonra otomatik production deploy; kırmızı testte rollback. Manuel tetikli (push to main) veya tam otomatik.
- **Analoji**: Üretim hattının sonunda paketlenip kamyona otomatik yüklenmesi — ayrı bir operatör değil.
- **Ulak'ta**: Manuel tetikli default (main merge = deploy); full-otomatik opt-in. Webhook + post-deploy health probe zorunlu.
- **İlgili**: ci, deploy, webhook
- **Daha fazla**: `docs/runtime/webhook-ci-deploy-pattern.md`

## k8s
- **Alias**: kubernetes, konteyner-orkestrator
- **Basit**: Büyük ölçekli uygulamaları yönetmek için kullanılan sistem. 100 sunucun varsa hangisinde hangi uygulama kaç kopya çalışacağını yönetir. Küçük ölçek için gereksiz.
- **Teknik**: Container workload scheduler + service mesh + ingress; declarative YAML config, reconciliation loop. ArgoCD ile GitOps deploy pattern'ı.
- **Analoji**: Büyük şantiyede vinç + iskele + depo + ekip yöneticisi — her işi koordine eden şef; küçük daireye tadilat için abartı.
- **Ulak'ta**: Sadece `sector=container-orchestrating-app` veya `regulated-saas` için. Diğerleri Traefik + docker-compose yeterli.
- **İlgili**: traefik, docker, deploy, vps
- **Daha fazla**: `docs/runtime/rule-packs/container-orchestrating-app.md`

## traefik
- **Alias**: traefik-proxy, reverse-proxy
- **Basit**: Bir VPS'te 5 farklı proje varsa, her projenin kendi alan adına isabet eden trafiği doğru uygulamaya yönlendiren sistem. SSL sertifikalarını da otomatik yeniler.
- **Teknik**: Cloud-native reverse proxy + LB; otomatik Let's Encrypt + dinamik service discovery (docker labels). nginx'in modern alternatifi.
- **Analoji**: Otelin resepsiyonu — gelen misafiri doğru odaya yönlendiriyor; anahtarı da resepsiyon yapıyor.
- **Ulak'ta**: VPS deploy stack'inin standart parçası (SP-06/SP-13). `/ulak-scaffold --deploy vps` bunu otomatik kurar.
- **İlgili**: vps, docker, deploy, nginx
- **Daha fazla**: `docs/runtime/rule-packs/vps-nginx-compose-topology.md`

## nextjs
- **Alias**: next.js, next-js, next
- **Basit**: React'i production'a hazır hâlde paketleyen framework. Sayfa oluştur, yönlendirme ver, deploy et — arka planda SSR, image optimization, middleware hepsi hazır.
- **Teknik**: React + SSR/SSG/CSR hybrid + App Router + middleware + image optimization; Vercel maintained. v14+ App Router kanonik.
- **Analoji**: Hazır pizza dükkanı franchise'ı — hamur, fırın, menü, marka hazır; sen sadece şubeyi açıyorsun.
- **Ulak'ta**: Ulak OS default stack. App Router (v14+) + TypeScript + Tailwind hazır gelir.
- **İlgili**: react, ssr, csr, vercel, supabase
- **Daha fazla**: `docs/runtime/rule-packs/frontend-currency.md`

## postgres
- **Alias**: postgresql, pg, relational-db
- **Basit**: Dünyanın en güvenilir veritabanı. Satır-sütun mantığı (tablo). E-ticaret, SaaS, fintech — hepsi Postgres'te çalışabilir.
- **Teknik**: PostgreSQL 14+; JSONB, full-text search, RLS, pgvector, WAL replication. Supabase'in altında çalışan database.
- **Analoji**: İyi dizilmiş kütüphane — her kitap kendi rafında, her rafta indeks; aradığını 3 saniyede buluyorsun.
- **Ulak'ta**: Postgres via Supabase. Migration'lar `supabase/migrations/` altında sıralı uygulanır. AP-11 RLS bypass koruması bu seviyede.
- **İlgili**: supabase, rls, migration, pgvector
- **Daha fazla**: `docs/runtime/rule-packs/multi-tenant-supabase.md`

## redis
- **Alias**: redis-cache, upstash, in-memory-store
- **Basit**: Hafızada veri tutan süper hızlı depo. "Son 5 dakikalık popüler ürünler" gibi sık değişen ve hızlı okunması gereken veriler için.
- **Teknik**: In-memory key-value store; cache, session, rate-limit, pub-sub, queue backend. TTL + LRU eviction.
- **Analoji**: Tezgahın üstündeki sık kullanılan araç çekmecesi — her seferinde depoya (Postgres) gitmeye gerek yok.
- **Ulak'ta**: Phase 1'de yok; ihtiyaç gelince Upstash (managed Redis) eklenir. Rate-limit + idempotency-key store için.
- **İlgili**: postgres, idempotent, cache
- **Daha fazla**: `docs/runtime/rule-packs/api-security.md`

## monorepo
- **Alias**: mono-repo, tek-repo, workspace
- **Basit**: Web + mobil + bot + admin — hepsi aynı git repo'sunda. Ortak kod bir kere yazılır, herkes kullanır.
- **Teknik**: Tek git repo + çok paket (pnpm workspace, turbo, Nx); paylaşılan config + tip tanımları + shared-libs klasörü.
- **Analoji**: Bir apartmanda birden fazla daire — ortak bahçe, ortak çatı, ortak doğalgaz; her daire kendi mutfağında çalışıyor.
- **Ulak'ta**: Hybrid stack'ler (web+mobile+bot) için pnpm workspace default. `sector=multi-app-nextjs-expo-monorepo` buna optimize.
- **İlgili**: pnpm, nextjs, workspace
- **Daha fazla**: `templates/sectors/multi-app-nextjs-expo-monorepo/`

## pwa
- **Alias**: progressive-web-app, installable-web
- **Basit**: Web sitesi ama telefona uygulama gibi kurulabiliyor. App Store'a gerek yok, kullanıcı "ana ekrana ekle" ile uygulama gibi açar.
- **Teknik**: Service worker + manifest + installable; offline-first + push notification (Android), iOS'ta sınırlı destek.
- **Analoji**: Süpermarketin "anında teslimat" kutusu — aynı market, ama eve kadar gelmiş gibi kullanıyorsun.
- **Ulak'ta**: `sector=pwa-desktop` için aktif; diğerleri web-only. Offline-first + background-sync default açık.
- **İlgili**: nextjs, service-worker, mobile
- **Daha fazla**: `templates/sectors/pwa-desktop/`

## phi
- **Alias**: protected-health-information, korunan-saglik-bilgisi
- **Basit**: Hasta ismi + hastalık kombinasyonu gibi sağlık verileri. Bunları tuttuğun an HIPAA devreye girer.
- **Teknik**: HIPAA-tanımlı kişisel sağlık veri alanı; 18 identifier (isim, adres, MRN, biyometrik...). Encryption at rest + in transit zorunlu.
- **Analoji**: Hasta dosyası içeriği — doktor not defteri, tahlil sonuçları, teşhis; sır kategorisinde.
- **Ulak'ta**: `sector=health-sensitive` → PHI taşıdığı varsayılır, encryption force + BAA required.
- **İlgili**: hipaa, encryption, audit-log, compliance
- **Daha fazla**: `templates/sectors/health-sensitive/`

## rag
- **Alias**: retrieval-augmented-generation, erisim-destekli-uretim
- **Basit**: AI'a cevap üretmeden önce ilgili dokümanları bulma. "Bu soruyu cevaplayacaksan önce benim belgelerimden ara, oradan üret" yaklaşımı. Halüsinasyonu azaltır.
- **Teknik**: User query → embedding → vector DB retrieval → LLM prompt'una context inject → grounded response. pgvector / Pinecone / Qdrant.
- **Analoji**: Öğretmenin "sınavda kitabı aç ve baktığın sayfadan cevap yaz" demesi — tahminden değil kaynaktan cevap.
- **Ulak'ta**: `pgvector` default — Supabase Postgres'e doğrudan eklenir. `sector=ai-copilot` overlay'de rag=true default.
- **İlgili**: llm, pgvector, supabase, ai-copilot
- **Daha fazla**: `templates/sectors/ai-copilot/`

## llm
- **Alias**: large-language-model, buyuk-dil-modeli
- **Basit**: ChatGPT / Claude / Gemini'nin arkasındaki model. Metin al, metin üret. API üstünden uygulamana entegre edebilirsin.
- **Teknik**: Transformer-based generative model (GPT-4, Claude Sonnet, Gemini Pro); context window + token pricing + streaming.
- **Analoji**: Kütüphaneyi okumuş asistan — her şeyi biliyor gibi davranıyor ama bazen uyduruyor; kaynak göstermezse dikkatli olmak lazım.
- **Ulak'ta**: Primary `anthropic-sonnet` + fallback `gemini-flash`; AI Provider Allowlist'e tabi (`docs/governance/ai-provider-allowlist.md`).
- **İlgili**: rag, cost-cap, ai-copilot
- **Daha fazla**: `docs/governance/ai-provider-allowlist.md`

## cost-cap
- **Alias**: cost-cap-per-user, maliyet-tavani, token-limit
- **Basit**: "Bir kullanıcı ayda en fazla 10 dolarlık AI harcasın" gibi tavan. Olmazsa bir kullanıcı seni binlerce dolar borçlu bırakabilir.
- **Teknik**: Per-user / per-tenant token limiti; aşıldığında 429 return + banner. Redis counter + reset cadence (günlük/aylık).
- **Analoji**: Cep telefonu ayrı data paketi — limitin biterse internet yavaşlar; sürpriz fatura gelmiyor.
- **Ulak'ta**: `sector=ai-copilot` için zorunlu. Default `10-usd-per-day` per tenant. SP-08 ai-relay-cost-control overlay.
- **İlgili**: llm, tenant, redis, ai-copilot
- **Daha fazla**: `templates/sectors/ai-relay-cost-control/`

## tier
- **Alias**: plan-tier, subscription-tier, plan-kademesi
- **Basit**: "Free / Pro / Business" gibi ürün kademeleri. Her kademe farklı özellikleri açar.
- **Teknik**: Feature-gated subscription level; Stripe Price ID'lerine bağlı + feature-flag check.
- **Analoji**: Havayolu bilet sınıfları — economy / business / first; aynı uçak, farklı koltuk + farklı servis.
- **Ulak'ta**: 3-tier (free + pro + business) default; `sector=saas` kanonik. `lib/billing/tiers.ts` SSOT.
- **İlgili**: stripe, payment, subscription
- **Daha fazla**: `docs/runtime/rule-packs/payment-integrated-saas.md`

## audit-log
- **Alias**: audit-trail, denetim-kaydi, event-log
- **Basit**: Sistemde kim ne zaman ne yaptı log'u. "Admin X kullanıcı Y'nin hesabını pasifleştirdi, 15:30'da". SOC 2 + enterprise için zorunlu.
- **Teknik**: Append-only event log; who/what/when/where, tamper-evident (hash chain optional). Postgres audit tablosu + trigger.
- **Analoji**: Apartman giriş defteri — kim kaçta girdi, kim imza attı, sonradan sorun çıkarsa bakılıyor.
- **Ulak'ta**: `admin-cms-hardening` overlay ile aktif. Impersonation + four-eyes ile birlikte zorunlu.
- **İlgili**: soc2, impersonation, four-eyes, enterprise
- **Daha fazla**: `docs/runtime/rule-packs/admin-cms-hardening.md`

## impersonation
- **Alias**: user-impersonation, kullanici-taklidi
- **Basit**: Destek ekibinin müşteri hesabına "müşteri gibi görünerek" girmesi. "Kullanıcı X şikâyet ediyor, ekranını göreyim" dediğinde. Log'lanır.
- **Teknik**: Admin'in diğer kullanıcı adına session açması; audit log + time-limit + reason string + explicit consent banner.
- **Analoji**: Otel müdürünün misafir odasına anahtarla girişi — herkes bilsin diye girdiğini, saatini, sebebini kayda geçirmek zorunda.
- **Ulak'ta**: `audit-log=true` ile birlikte aktif; explicit consent olmadan yasak. `admin-cms-hardening` overlay standart.
- **İlgili**: audit-log, four-eyes, enterprise
- **Daha fazla**: `docs/runtime/rule-packs/admin-cms-hardening.md`

## four-eyes
- **Alias**: four-eyes-principle, dual-control, iki-kisi-onayi
- **Basit**: "Para çekme" / "kullanıcı silme" gibi tehlikeli işlemler tek kişinin tıklamasıyla olmaz — ikinci kişi onaylamalı. Bankalarda çok yaygın.
- **Teknik**: High-risk action için ikinci admin onayı zorunlu; dual-control principle. Pending-approval state + second-admin sign-off.
- **Analoji**: Bankada kasanın iki anahtarı — kimse tek başına kasayı açamıyor, iki yetkili aynı anda olmak zorunda.
- **Ulak'ta**: `sector=fintech` → force; diğerleri opt-in. Dangerous ops (user-delete, payout) için recommend.
- **İlgili**: audit-log, impersonation, fintech, admin
- **Daha fazla**: `docs/runtime/rule-packs/admin-cms-hardening.md`

## idp
- **Alias**: identity-provider, kimlik-saglayici
- **Basit**: Kimlik sahibi servisi. "Google senin kim olduğunu biliyor" — Google IdP. SSO'da kullanıcın IdP'ye girer, IdP sana onaylar.
- **Teknik**: SAML/OIDC IdP; Okta, Azure AD, Google Workspace; kullanıcı kimliği emit eder + claims (email, name, groups).
- **Analoji**: Pasaport veren devlet — sen pasaportu gösteriyorsun, karşı devlet "bu kişiyi biz tanıyoruz" diyor.
- **Ulak'ta**: `enterprise` seçilirse Google + Azure AD baseline. SSO + SCIM ile birlikte gelir.
- **İlgili**: sso, scim, auth, enterprise
- **Daha fazla**: `docs/runtime/rule-packs/admin-cms-hardening.md`

---

*Son güncelleme: 2026-04-21 · v3.0.x seed genişletildi · **40 madde** · `/ulak-start` basit mod dual-render otoritesi*
