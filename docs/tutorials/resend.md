# Resend Tutorial — Transactional email 15 dakikada

> **Amaç**: Ulak OS ile scaffold ettiğin projen user signup, password reset, notification
> email'lerini gönderebilsin. Resend hesabı aç, domain verify et, API key al,
> `.env.local`'a yaz, ilk test emailini gönder — **15 dakikada**.
>
> **Hedef kullanıcı**: İlk kez "transactional email" göndermek isteyen beginner.
> SMTP, DKIM, SPF gibi terimler kulağa karmaşık geliyorsa bu tutorial tamamını kapsar.
>
> **Ön koşul**: Ulak OS scaffold'u bitti. `/ulak-next-steps` §3.4'te "Resend" söz etti — şimdi
> ayrıntılı kurulum buradan.

---

## 1. Resend nedir, neden?

**Kısa tanım**: Email gönderim servisi (Email-API-as-a-service). Stripe'ın ödeme için olan pozisyonu — Resend email için.

**Neden Resend** (Ulak OS default seçimi):

- **Developer-first**: REST API + resmi SDK (Node, Python, Ruby, Go, PHP). Dashboard sade, dokümantasyon temiz.
- **Free tier**: Ayda **3000 email**, günde **100 email**. Küçük SaaS'ın ilk 3-6 ayına yeter.
- **React Email entegre**: Email template'lerini JSX/TSX olarak yazarsın. Ulak scaffold `emails/` klasörüne örnekler koyar.
- **Webhook + event tracking**: Email delivered / opened / bounced olaylarını webhook olarak alırsın.
- **EU + US region**: EU (Frankfurt) seçerek KVKK/GDPR friendly data residency.

**Alternatifler** (ve neden default Resend):

| Servis | Güçlü yan | Zayıf yan | Ulak OS'ta |
|---|---|---|---|
| **Resend** | DX, React Email, sade pricing | Yeni (2023) — SendGrid kadar battle-tested değil | **Default** |
| **Postmark** | Transactional email öncüsü, deliverability çok iyi | Daha pahalı — 10000 email $15 | İkinci seçenek |
| **AWS SES** | Çok ucuz ($0.10/1000 email) | Karmaşık kurulum, verify zahmeti, UI spartan | Enterprise scale |
| **SendGrid** | Büyük ekosistem | Twilio satın aldıktan sonra UX bozuldu, spam klasörüne düşme artışı raporlanıyor | Deprecated for Ulak |

Ulak scaffolder Resend-native: `lib/email/resend.ts` + `emails/welcome.tsx` / `emails/password-reset.tsx` / `emails/magic-link.tsx` hazır gelir.

---

## 2. Hesap açma (2 dk)

1. <https://resend.com/signup> aç.
2. Seçenek:
   - **Email + password** (klasik)
   - **Continue with GitHub** (hızlı — GitHub hesabın §1'de açıldıysa tavsiye)
3. Email verify — inbox'u kontrol et (spam klasörüne de bak), linke tıkla.
4. Dashboard açılır → `resend.com/overview` gibi bir URL'e landing.

**Ücret**: 0 USD. Free tier — kredi kartı gerekmez.

---

## 3. Domain verify (ÖNEMLİ, 5-10 dk)

Email gönderirken **kimden geliyor**? `sen@siten.com` veya `onboarding@siten.com`. Bu "siten.com" adresinin gerçekten senin olduğunu DNS kayıtları ile Resend'e kanıtlarsın. Olmazsa email'ler spam klasörüne düşer.

### Seçenek A — Kendi domain'in var (önerilen)

1. Resend dashboard → **Domains** → **Add Domain**.
2. Domain adını yaz (örn. `siten.com`) → **Add**.
3. Region seç:
   - **EU (Frankfurt)** — KVKK + GDPR için, TR + Avrupa kullanıcılar için default.
   - **US (N. Virginia)** — US kullanıcılar için.
   - ⚠️ Region bir kez seçilir, değiştirilemez — domain'i yeniden ekleyerek aşılır.
4. Resend sana 3-4 DNS kaydı gösterir. Örnek (gerçek değerler seninkinden farklı olur):

   | Type | Name / Host | Value |
   |---|---|---|
   | **MX** | `send` | `feedback-smtp.eu-west-1.amazonses.com` (priority 10) |
   | **TXT** (SPF) | `send` | `v=spf1 include:amazonses.com ~all` |
   | **TXT** (DKIM) | `resend._domainkey` | `p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBi...` (uzun) |
   | **TXT** (DMARC, opsiyonel) | `_dmarc` | `v=DMARC1; p=none;` |

5. DNS sağlayıcına git — domain'i kimden aldıysan (Cloudflare, Namecheap, GoDaddy, Turhost, Natro…) onun paneline. Örnek Cloudflare:
   - Dashboard → domain seç → **DNS** → **Records** → **Add record**.
   - Her satır için type + name + content gir. TTL: Auto (default).
   - **Proxy status** (Cloudflare'e özel): **DNS only** (turuncu bulut kapalı) — email DNS kayıtları için proxy açık olmamalı.
6. Resend'e dön → domain sayfasında **Verify DNS Records** butonu.
7. Bekle — DNS propagation 1-30 dakika sürebilir. "Verified" yeşil ibaresini görene kadar periyodik tıkla.

**DKIM, SPF, DMARC ne iş?** (beginner özet — detay `/ulak-explain dkim` / `spf` / `dmarc`):

- **SPF**: "Bu domain'den email hangi sunuculardan çıkabilir" listesi. Resend sunucularını listeler.
- **DKIM**: Her email'e dijital imza atar; alıcı sunucu imzayı doğrular. "Bu email gerçekten siten.com'dan geldi" kanıtı.
- **DMARC**: SPF + DKIM başarısız olursa ne yapılsın? `p=none` = rapor gönder ama email'i at; `p=quarantine` = spam klasörüne düşür; `p=reject` = tamamen reddet.

Üçünün doğru olması = email deliverability %99+. Eksiği = Gmail / Outlook spam klasörüne atar.

### Seçenek B — Domain'in yok

Test için Resend'in paylaşılan adresini kullanabilirsin: `onboarding@resend.dev`.

**Kısıtlar**:
- Sadece **kendi Resend hesabı email adresine** gönderim. Başka adreslere reject.
- Production'da görünmez ("onboarding@resend.dev" dan email gelmesi kullanıcı için güvensiz).

**Production yolu**: domain satın al.
- **Namecheap** — ~$10/yıl (.com), setup 5 dakika, ucuz.
- **Cloudflare Registrar** — ~$9/yıl (at-cost), DNS otomatik Cloudflare'de.
- **Turhost / Natro** (TR) — TR TLD (.com.tr) veya .com, TR destek, ~₺200-400/yıl.

Domain alındı = §3A'ya geri dön.

---

## 4. API Key oluştur (1 dk) — **kritik adım**

1. Resend dashboard → sol menü **API Keys** → **Create API Key**.
2. **Name**: açıklayıcı bir şey — `my-saas-production` veya `my-saas-local-dev`. (Farklı ortam için farklı key'ler tavsiye — production vs dev ayırmak deliverability debug'ını kolaylaştırır.)
3. **Permission**: **Sending access** (default — sadece email gönderebilir, domain/webhook yönetemez). Full access yerine Sending access kullan — güvenlik.
4. **Domain**: specific domain (az önce verify ettiğin) veya `All domains`. İlk seferde verify ettiğin domain'i seç — ek güvenlik katmanı.
5. **Add** → key ekranda gösterilir.

⚠️ **Key sadece BİR KERE gösterilir** — panelde bir daha göremezsin. Hemen kopyala.

### `.env.local`'a yapıştır

```bash
# my-saas/.env.local dosyasına ekle (dosya yoksa oluştur):
RESEND_API_KEY=re_abc123DefGhi456jkL...
RESEND_FROM_EMAIL=onboarding@siten.com
```

⚠️ **`RESEND_API_KEY` server-only** — `NEXT_PUBLIC_` prefix'i YOK. Client-side'dan erişim güvenlik açığı (key repo'ya kaçarsa saldırgan senin hesabından email gönderir). Ulak scaffold `lib/email/resend.ts` içinde sadece server-side kullanır.

⚠️ **`.env.local` commit EDİLMEMELİ** — Ulak scaffold `.gitignore`'a zaten koydu. Doğrulamak için:

```bash
git check-ignore .env.local
# çıktı: .env.local   → ignore edildiğine işaret
```

---

## 5. İlk email testi (3 dk)

### Hızlı test — curl

```bash
# <API_KEY> + <FROM> + <TO> yerine kendi değerlerini koy:
curl -X POST https://api.resend.com/emails \
  -H "Authorization: Bearer re_abc123..." \
  -H "Content-Type: application/json" \
  -d '{
    "from": "onboarding@siten.com",
    "to": ["kendi-email@example.com"],
    "subject": "İlk Resend Emaili",
    "html": "<p>Merhaba! Bu Ulak OS + Resend test emaili. Her şey çalışıyor.</p>"
  }'
```

Beklenen cevap:

```json
{ "id": "abc-def-ghi-jkl-mno" }
```

Kendi inbox'unu kontrol et — email 3-10 saniyede gelir. Gelmezse:
- **Spam klasörü** (DKIM/SPF/DMARC eksikse ilk birkaç email spam'e düşebilir — normal, warmup süreci).
- **Resend dashboard → Logs** sekmesi → email status: `delivered`, `bounced`, `blocked` — gerçekte ne olduğunu gör.

### SDK ile (production pattern)

Ulak scaffold `lib/email/resend.ts` dosyası bunu zaten kurmuş:

```typescript
// lib/email/resend.ts (Ulak scaffold default)
import { Resend } from 'resend';

if (!process.env.RESEND_API_KEY) {
  throw new Error('RESEND_API_KEY missing from env');
}

export const resend = new Resend(process.env.RESEND_API_KEY);
export const FROM_EMAIL = process.env.RESEND_FROM_EMAIL ?? 'onboarding@resend.dev';
```

Kullanım (örnek: welcome email):

```typescript
// app/api/signup/route.ts içinde veya server action'da:
import { resend, FROM_EMAIL } from '@/lib/email/resend';
import WelcomeEmail from '@/emails/welcome';

await resend.emails.send({
  from: FROM_EMAIL,
  to: user.email,
  subject: 'Hoş geldin!',
  react: WelcomeEmail({ name: user.name }),
});
```

---

## 6. Ulak scaffold entegrasyonu (2 dk)

Scaffold'ın ürettiği dosyalar:

```
my-saas/
├── lib/email/
│   └── resend.ts              # SDK init + FROM_EMAIL
├── emails/                    # React Email template'leri
│   ├── welcome.tsx
│   ├── password-reset.tsx
│   └── magic-link.tsx
└── app/api/
    ├── signup/route.ts        # welcome email tetikler
    ├── auth/
    │   ├── reset-password/route.ts   # password-reset email
    │   └── magic-link/route.ts       # magic-link email
```

`.env.local`'a API key yazıp kaydettikten sonra:

```bash
cd my-saas
pnpm dev
# Tarayıcıda: http://localhost:3000
# Sign up form'a gir → email + password yaz → Submit
# Inbox'ına welcome email'i gelir (3-10 sn)
```

### Template'leri özelleştir

`emails/welcome.tsx` — React component, JSX içinde yaz:

```tsx
import { Html, Head, Body, Heading, Text, Button } from '@react-email/components';

export default function WelcomeEmail({ name }: { name: string }) {
  return (
    <Html>
      <Head />
      <Body>
        <Heading>Hoş geldin {name}!</Heading>
        <Text>Ulak OS ile yapılan bu uygulamaya kayıt olduğun için teşekkürler.</Text>
        <Button href="https://siten.com/dashboard">Dashboard'a git</Button>
      </Body>
    </Html>
  );
}
```

Styling için React Email'in native component'leri veya inline CSS kullan. Çoğu email client CSS-in-head'i desteklemez — **inline CSS** en güvenli.

### React Email dev preview

```bash
pnpm email:dev
# Tarayıcıda: http://localhost:3001
# Tüm template'leri görsel olarak önizleyebilirsin, gerçek email göndermeden.
```

---

## 7. Sorun giderme

### Domain "verified" olmuyor

- **Bekle** — DNS propagation 1-30 dk, nadiren 24 saat.
- DNS kayıtları doğru mu: `dig TXT siten.com` veya <https://mxtoolbox.com> → DNS lookup.
- **Cloudflare kullanıcıları**: proxy açık mı? Email DNS kayıtları proxy (turuncu bulut) ile çalışmaz → **DNS only** (gri bulut).
- Name/Host kısmında tam string'i yazmış mısın? `send` değil `send.siten.com` isteniyor olabilir — DNS paneline göre değişir.

### Email spam klasörüne düşüyor

- DKIM + SPF + DMARC üçü de yeşil mi? <https://www.mail-tester.com> → test email gönder → 10 üzerinden skor al.
- From adres resend.dev default'u ise → mutlaka kendi domain'ine geç.
- **Warmup**: İlk 50-100 email'de Gmail/Outlook az şüpheci davranır. Düzenli kullanım + bounce rate düşükse deliverability gün geçtikçe artar.

### "Rate limit exceeded" (429)

Free tier: **100 email/gün, 3000/ay**. Aşarsan:
- Pro plan: $20/ay → 50000 email/ay, 10 email/saniye.
- <https://resend.com/pricing>

### API key `.env.local`'da ama "RESEND_API_KEY missing" hatası

- Next.js dev server'ı yeniden başlat (`pnpm dev` durdur + yeniden başlat). Env değişiklikleri restart ister.
- Dosya adı gerçekten `.env.local` mi? `.env.local.example` (scaffold template'i) ile karıştırmadığından emin ol.
- `env | grep RESEND` → env gerçekten yüklendi mi?

### "Invalid from address"

- `FROM_EMAIL` domain'i Resend'de verify edilmemiş. §3'ü tekrarla.
- Test için `onboarding@resend.dev` kullan (sadece hesap sahibi email'ine gönderir).

### Webhook event'leri gelmiyor (ileri seviye)

Resend → Dashboard → Webhooks → Add Endpoint → `https://siten.com/api/webhooks/resend`. Her event (delivered, bounced, opened) POST olarak gelir. Idempotency + imza doğrulama zorunlu — `docs/runtime/webhook-ci-deploy-pattern.md` pattern'i.

### Daha fazla

- `docs/runbooks/troubleshooting.md` § Resend / Email — genişletilmiş senaryolar.
- `docs/runtime/rule-packs/api-security.md` — webhook + idempotency disiplini.
- `docs/tutorials/github.md` — sıradaki (eğer henüz okumadıysan GitHub tutorial'ı).

---

## Sonraki adım

Email çalışıyor, domain verify edildi, scaffold template'leri entegre. Şimdi:

1. **Deploy** → production'a çık: Vercel (`/ulak-explain vercel`) veya VPS (`/ulak-explain vps`).
2. **Email analytics** → Resend dashboard → Logs sekmesi — delivery + bounce + open rate.
3. **Transactional template'leri özelleştir** → `emails/` klasöründe React Email ile.
4. **Compliance**: EU kullanıcıları varsa `docs/runtime/rule-packs/api-security.md` §email-compliance → unsubscribe link + data residency.

---

*Son güncelleme: 2026-04-21 · v3.0.x · Beginner-first, TR-primary. `/ulak-explain resend` komutu bu tutorial'a pointer.*
