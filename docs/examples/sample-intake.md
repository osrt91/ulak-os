# Sample Intake — Brownfield Audit Scenario

> Bu, Ulak OS'un `intake` artefaktının nasıl görünmesi gerektiğini gösteren örnek bir dosyadır. Gerçek bir intake çıktısı bu yapıya benzer şekilde oluşturulur.

## Project state

**BROWNFIELD** — mevcut bir e-ticaret monolitinin (Django + React) audit ve modernizasyon programı. Kod 4 yıllık, son 18 ay aktif geliştirme yavaşlamış, test coverage düşmüş.

## Intervention mode

**REPAIR** birincil, **EXTEND** ikincil. Önce ölü kod ve broken test'leri temizle (REPAIR), sonra yeni bir checkout flow eklenir (EXTEND).

## User intent

Kullanıcı, "checkout flow'u 2 hafta içinde mobile-first yapıp canlıya almak" istiyor. Mevcut checkout sayfası 8 saniye TTI'a sahip, %32 cart abandonment var, mobile bounce %58.

Asıl hedef: cart abandonment'ı %20'ye indirmek ve mobile bounce'u %40'a düşürmek.

## Success criteria

1. Yeni mobile checkout TTI < 2.5 saniye (LCP ölçümüyle)
2. Cart abandonment ≤ %20 (4 hafta canlı sonrası A/B)
3. Mobile bounce ≤ %40 (4 hafta canlı sonrası)
4. Mevcut desktop checkout regresyon yok (% conversion delta ≤ ±%2)
5. CI yeşil; coverage %60'tan ≥ %70'e çıkmış olmalı (yeni kod için)

## Constraints

- **Süre**: 14 takvim günü (2026-04-21 lansman)
- **Ekip**: 1 frontend, 1 backend, 0.5 QA — sen koordine et
- **Stack değişikliği yok**: Django + React kalır, framework değişmez
- **Customer/admin/public API ayrımı**: customer checkout dokunulur, admin order panel ve public catalog API DOKUNULMAZ
- **DB şema değişikliği**: yalnızca additive (yeni kolon/tablo OK, drop YOK)
- **Feature flag**: yeni checkout flag arkasında, %5 → %25 → %100 rampa

## Out-of-scope

- Backend mikroservis ayrıştırma (ileride, ayrı program)
- Yeni payment gateway entegrasyonu
- Email/SMS notification revamp
- Admin paneli redesign

## Notes

- Customer success ekibinin elinde 47 adet kullanıcı bug raporu var; intake aşamasında yalnızca 4'ü checkout ile ilişkili — bunlar evidence-register'da işlenecek
- Eski A/B test (Q4 2025) checkout'ta CTA buton renginin etkisini ölçmüştü; sonuç anlamsız çıkmıştı, tekrar denenmeyecek

---

**Sonraki adım**: `inventory` artefaktına geç. Mevcut checkout dosya/route haritası çıkarılacak.
