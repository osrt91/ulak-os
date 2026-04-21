---
name: ulak-explain
description: Bir teknik terimi beginner-friendly 5 alanlı şemada açıklar (Basit / Teknik / Analoji / Ulak'ta / İlgili). Scaffold sonrası ".env.local"a ne yazacağını veya "rls" gibi kısaltmaları merak eden operatör için. Lookup kaynağı docs/runtime/beginner-glossary.md.
description_en: Explains a technical term in a beginner-friendly 5-field schema (Simple / Technical / Analogy / In Ulak / Related). For the operator wondering what RLS means or what to fill in `.env.local` after scaffolding. Lookup source: `docs/runtime/beginner-glossary.md`.
agent: autonomous-program-director
allowed-tools: Read, Grep, Glob
argument-hint: "<term> — örn: rls, supabase, jwt, iyzico, kvkk, vps, env-local"
model: claude-opus-4-7
---

# /ulak-explain — beginner-friendly terim açıklayıcı

## Vizyon

Yeni başlayan operatör scaffold'u çalıştırır, `.env.local` boş çıkar, "Supabase URL nedir?" diye kalır; ya da findings'te "RLS eksik" görür, "RLS ne?" diye gugıla düşer. `/ulak-explain` bu anda devreye girer: terimi 5 alanlı sabit şemada açıklar, her seferinde aynı formatta.

Bu komut bir "dokümantasyon" değil — **öğretici bir format zorlar**: basit cümle → teknik ayrıntı → günlük hayat analojisi → Ulak OS bağlamı → ilgili terimler + daha fazla kaynak. Operatör 30 saniyede "ne olduğunu" görür, kaynağa dalmak isterse yönlendirilir.

## When to use

- `.env.local` doldururken "Supabase URL ne?" diye takıldığında
- Findings'te "RLS bypass riski" yazıyor, operatör "RLS neydi?" diye merak ediyor
- Scaffold sonrası `jwt`, `tenant`, `migration` gibi kelimeler akıp geçiyor, biri yakalamak istiyor
- Yeni takım üyesi onboarding — "projede 10 terim tekrar ediyor, hepsini bir yerden öğreneyim"

## When NOT to use

- Genel programlama konsepti (örn. "closure nedir") — bu LLM cevabı, glossary değil. `/ulak-ask` ile yönlendir, genel açıklama için provider chat'i kullan.
- Detaylı mimari açıklama gerekiyor — `/ulak-packs` veya ilgili rule pack dosyasını aç.
- Dosya düzeyi soru ("bu fonksiyon ne yapıyor") — `/ulak-ask` ile doğru komutu bul.

## Akış

### 1. Term normalize
Girdiyi lowercase + trim + Turkish-normalize et:
- `/ulak-explain RLS` → `rls`
- `/ulak-explain "Row Level Security"` → `row-level-security`
- `/ulak-explain İYZİCO` → `iyzico`

### 2. Primary lookup
`docs/runtime/beginner-glossary.md` dosyasını oku:
- Önce başlık olarak (`## <term>`) ara
- Sonra `- **Alias**:` satırlarında ara
- Eşleşme varsa 5 alanı extract et ve render et

### 3. Render
Sabit format, her terim için aynı:

```
═══════════════════════════════════════════
<TERM_UPPER>
═══════════════════════════════════════════

[Basit]     <1-2 satır günlük dilde açıklama>

[Teknik]    <2-3 satır teknik tanım>

[Analoji]   <1-2 satır analoji>

[Ulak'ta]   <2-3 satır — Ulak OS context'inde nerede görünür>

[İlgili]    <virgülle ayrılmış alias'lar ve bağlantılı terimler>

[Daha fazla] <dosya yolları — 1-3 adet>
═══════════════════════════════════════════
```

### 4. Fallback — glossary'de yoksa

Adımlar:
1. `docs/catalog.md` içinde grep et (case-insensitive)
2. `docs/runtime/*.md` dosyalarında grep et
3. `docs/governance/*.md` dosyalarında grep et
4. İlk 3 yakın eşleşmeyi "Did you mean?" listesi olarak göster

Çıktı:
```
═══════════════════════════════════════════
"<term>" glossary'de bulunamadı
═══════════════════════════════════════════

 Yakın eşleşmeler:
   • rls            — Row Level Security
   • supabase       — Hazır backend
   • jwt            — JSON Web Token

 Veya şu dosyalarda geçiyor:
   - docs/runtime/rule-packs/<match>.md:NN
   - docs/governance/<match>.md:NN

 Denemek ister misin? /ulak-explain <doğru-terim>
 Glossary'ye ekleme gerekiyorsa: /pack-gap-audit
═══════════════════════════════════════════
```

## Örnek çalışmalar

### Örnek 1 — Direkt eşleşme
```
/ulak-explain rls
```
Output:
```
═══════════════════════════════════════════
RLS — Row Level Security
═══════════════════════════════════════════

[Basit]     Database'de bir müşterinin verilerini başka
            müşterinin görmesini engelleyen filtre sistemi.

[Teknik]    Postgres'in row-level security policy'leri
            kullanıcı/tenant ID'sine göre SELECT/UPDATE/DELETE
            erişimini row bazında kısıtlar. Ulak scaffold'da
            Supabase üstünde aktive edilir.

[Analoji]   Apartman dairesi gibi — her komşu sadece kendi
            dairesinin anahtarına sahip; güvenlik binadan
            (database) yönetilir, kapıdan (uygulama) değil.

[Ulak'ta]   /ulak-scaffold üretilen SQL migration'larında her
            tenant-specific tabloda RLS aktif edilir.
            Örnek: supabase/migrations/00002_rls_policies.sql
            AP-11 (RLS-gate-bypass-prevention) bu prensibi korur.

[İlgili]    tenant, multi-tenant, auth, supabase, AP-11

[Daha fazla]
   • docs/runtime/rule-packs/multi-tenant-supabase.md
   • docs/runtime/cross-tenant-rls-verification.md
═══════════════════════════════════════════
```

### Örnek 2 — Alias eşleşmesi
```
/ulak-explain "row level security"
```
→ Normalize: `row-level-security` → Alias match: `rls` → Yukarıdaki aynı çıktı.

### Örnek 3 — Türkçe terim
```
/ulak-explain çoklu-dil
```
→ Alias match `çoklu-dil` → `i18n` çıktısı.

### Örnek 4 — Kısaltma
```
/ulak-explain kvkk
```
→ Direkt match → KVKK 5-alan çıktısı.

### Örnek 5 — Bulunamayan terim + fallback
```
/ulak-explain webhook
```
Output:
```
═══════════════════════════════════════════
"webhook" glossary'de bulunamadı
═══════════════════════════════════════════

 Glossary'de yakın bir şey yok. Ama şu dosyalarda geçiyor:

   • docs/runtime/webhook-ci-deploy-pattern.md
   • docs/runtime/transactional-fsm-payment.md  (payment webhook)
   • docs/runtime/rule-packs/api-security.md    (webhook signature)

 Özet: Webhook, bir sistemden başka bir sisteme olay
 bildirimi yapan HTTP callback'tir (örn. Stripe ödeme
 tamamlandığında sana POST atar). Ulak OS'ta idempotency
 + signature verification zorunludur (AP-13).

 Glossary'ye eklensin mi? Öner: /pack-gap-audit
═══════════════════════════════════════════
```

### Örnek 6 — Boş veya bilinmeyen
```
/ulak-explain zzxcvb
```
→ Glossary ve grep fallback'ta da yok → "Yakın eşleşme bulunamadı. /pack-gap-audit öner" mesajı.

## Rules

- **Uydurma yasak**. `beginner-glossary.md` ve repo içeriği dışında bir şey söyleme. Terim yok + grep yok = "bulunamadı" de, hikaye uydurma.
- **Sabit format zorunlu**. 5 alan sırası değişmez, alan ismi değişmez.
- **Secret yok**. Terim "api-key" veya benzeri olursa, gerçek bir secret örneği verme; "örnek placeholder" kullan.
- **Diske yazmaz**. `/ulak-explain` bir sorgu komutudur — çıktı inline döner. `CLAUDE.md` §Working rule'daki default "diske yaz" protokolü burada geçerli değildir (bu, `/ulak-ask` ile aynı istisna).
- **Tek terim**. `/ulak-explain rls jwt` girilirse → ilk terimi işle, ikincisi için "ikinci terim için ayrı çalıştır" uyarısı ver.
- **Case-insensitive + Turkish normalize**. `RLS` = `rls`, `İYZİCO` = `iyzico`, `ÇOKLU-DIL` = `çoklu-dil`.

## Yasaklar

- "Genel tarih dersi" verme (örn. "JWT 2010'da IETF tarafından...") — Basit alanı pratik olsun.
- Uydurma dosya yolu koyma (`Daha fazla` kısmı gerçek bir `docs/...` dosyasına işaret etmeli).
- Competing frameworks reklamı yapma (örn. "Firebase daha iyi" gibi yanlı değerlendirme).
- Rakip ürünler hakkında kesin iddialar kurma — sadece betimle.

## Kaynak dosyalar

- **`docs/runtime/beginner-glossary.md`** — primary lookup. 15 terim seed; 30'a çıkacak (paralel ajan).
- **`docs/catalog.md`** — fallback grep için capability catalog.
- **`docs/runtime/*.md`** — fallback grep için runtime rules.
- **`docs/governance/*.md`** — fallback grep için governance.

## Integration

- `/ulak-ask "rls nedir"` → `/ulak-explain rls` önerisi
- `/ulak-hello` seçim menüsü 5. seçenek olarak "terim açıkla" eklenebilir (opsiyonel)
- `/pack-gap-audit` — glossary eksik terimler için uyarı üretir

## EN quick note

`/ulak-explain <term>` explains a technical term in a fixed 5-field schema (Simple / Technical / Analogy / In Ulak / Related). Primary source: `docs/runtime/beginner-glossary.md` (15 seeded terms). Fallback: greps `docs/catalog.md` + `docs/runtime/*.md` + `docs/governance/*.md`, shows top-3 near matches. Never invents content. Output is inline (no disk writes). Case-insensitive + Turkish-normalized lookup.

ARGUMENTS:
$ARGUMENTS
