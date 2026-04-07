# Sample Inventory — Brownfield Audit Scenario

> Ulak OS `inventory` artefakt örneği. Intake'in devamı; mevcut sistemin haritası.

## Inventory scope

Bu inventory, **mevcut checkout flow**'u tarar. Admin order panel ve public catalog API kapsamda DEĞİL (intake'deki out-of-scope).

## Yapısal harita

### Backend (Django)

| Modül | Dosyalar | LOC | Son commit |
|---|---|---|---|
| `apps/checkout/views.py` | 1 dosya | 412 | 2024-11-08 |
| `apps/checkout/serializers.py` | 1 dosya | 178 | 2024-09-22 |
| `apps/checkout/models.py` | 1 dosya | 89 | 2023-06-14 |
| `apps/checkout/urls.py` | 1 dosya | 23 | 2024-09-22 |
| `apps/checkout/tests/` | 6 dosya | 540 | 2024-08-01 |

**Tespitler:**
- `views.py` 412 LOC ile aşırı şişmiş (8 endpoint tek dosyada)
- Test coverage %48 (`pytest --cov` ile ölçüldü)
- 3 endpoint deprecated `Form` API kullanıyor (DRF değil)

### Frontend (React)

| Component | Dosyalar | LOC | Son commit |
|---|---|---|---|
| `src/checkout/CheckoutPage.tsx` | 1 dosya | 287 | 2024-12-03 |
| `src/checkout/CartSummary.tsx` | 1 dosya | 142 | 2024-11-15 |
| `src/checkout/PaymentForm.tsx` | 1 dosya | 198 | 2024-10-21 |
| `src/checkout/AddressForm.tsx` | 1 dosya | 165 | 2024-10-21 |
| `src/checkout/__tests__/` | 4 dosya | 312 | 2024-08-12 |

**Tespitler:**
- `CheckoutPage.tsx` mobile responsive değil (CSS media query yok)
- `PaymentForm.tsx` controlled-uncontrolled state karışımı (React warning)
- Test coverage %39

### CI/CD

- GitHub Actions: `lint`, `test-backend`, `test-frontend`, `e2e-cypress`
- Branch protection: `main` üzerine direct push kapalı, PR + 1 review zorunlu
- E2E checkout suite son 6 ayda 11 kez kırılmış, hep "flaky" olarak işaretlenip kapatılmış

### Veritabanı

- PostgreSQL 14
- `checkout_order`, `checkout_orderitem`, `checkout_payment` tabloları
- 4.7M satır order, 12M satır orderitem
- Hiçbir sütunda index drop'u yapılmamış (additive history)

## Bağımlılıklar

| Paket | Versiyon | Son yayın | Risk |
|---|---|---|---|
| Django | 4.2.7 | 2023-11 | düşük |
| djangorestframework | 3.14.0 | 2023-08 | düşük |
| stripe | 5.4.0 | 2023-04 | **orta** (güncel 9.x) |
| react | 18.2.0 | 2022-06 | düşük |
| @stripe/stripe-js | 2.1.0 | 2023-09 | **orta** |

## Risk işaretleri (evidence-register'a girer)

1. **`checkout/views.py` overweight** → modülerleştirilmeli ama bu intake'in dışında, sadece dokunduğumuz endpoint'leri ayır
2. **Mobile responsive eksikliği** → bu programın asıl hedefi, ana iş
3. **Stripe SDK eski** → yeni checkout için güncellenmesi gerekebilir, evidence ile doğrula
4. **E2E flaky history** → yeni checkout için E2E güvenilir yazılmalı; eski flaky test'ler ayıklanmalı

## Eksikler (research-notes'a girer)

- Mobile checkout için endüstri standardı LCP hedefi nedir? (research)
- Stripe SDK 5 → 9 breaking change listesi nedir? (research)
- Cart abandonment azaltma için competitor pattern'ları nelerdir? (research)

---

**Sonraki adım**: `evidence-register` — yukarıdaki risk işaretlerini ve eksikleri kanıtlanmış bulgu/data noktalarına dönüştür.
