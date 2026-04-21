# Ulak OS — External Service Tutorials

> **TR** — `/ulak-scaffold` proje iskeletini üretir, ama hesap açma + API key alma dış
> servislerde olur (Supabase, Vercel, GitHub, Resend). Bu dizin, hiç tecrübesi olmayan
> operatörün her servisi **sıfırdan adım-adım** geçebilmesi için tutorial'ları barındırır.
>
> **EN** — `/ulak-scaffold` generates the project skeleton, but account creation + API
> key retrieval happens in external services (Supabase, Vercel, GitHub, Resend). This
> directory hosts step-by-step tutorials for a beginner with zero prior experience.

---

## Mevcut tutorial'lar / Available tutorials

| Tutorial | Süre | Kapsam | Dosya |
|---|---|---|---|
| **Supabase** | 15 dk | Hesap + project + API keys + migration push + ilk admin | [`supabase.md`](./supabase.md) |
| **Vercel** | 10 dk | Hesap + GitHub bağlama + env vars + deploy + custom domain | [`vercel.md`](./vercel.md) |
| GitHub | 10 dk | Hesap + repo oluşturma + SSH key + first push | `github.md` *(upcoming)* |
| Resend | 5 dk | Hesap + API key + domain verify + first email | `resend.md` *(upcoming)* |

---

## Hangi sırayla / In what order

Ulak scaffold sonrası tipik akış:

```
/ulak-scaffold done
   │
   ▼
(1) GitHub         — repo için host (code backup + deploy source)
   │
   ▼
(2) Supabase       — backend: database + auth + storage
   │
   ▼
(3) Vercel         — deploy: Next.js canlıya al
   │
   ▼
(4) Resend (opt)   — production email (transactional)
```

Minimum viable path: **GitHub + Supabase + Vercel** (20 dk). Resend scaffold sonrası
login/signup email'leri için opsiyonel — development'ta Supabase'in default email'i
yeterli.

---

## Toplam süre / Total time

| Aşama | Süre |
|---|---|
| GitHub (yoksa) | 10 dk |
| Supabase | 15 dk |
| Vercel | 10 dk |
| Resend (opsiyonel) | 5 dk |
| **Toplam** | **40 dk** (Resend dahil) veya **35 dk** (Resend atla) |

`/ulak-scaffold` + tutorial'lar + deploy dahil → ilk canlı URL'e ~1 saat.

---

## Beginner-friendly prensipler

Bu tutorial'ların hepsi aşağıdaki disipline uyar:

1. **TR-primary, EN-secondary**. Kod + komutlar + key isimleri EN (çünkü gerçek UI'da
   EN). Açıklamalar, uyarılar, kararlar TR. `/ulak-locale en` ile EN-primary sürüme
   geçiş ileride eklenecek.
2. **Ekran + adım bazlı, ezbere dayatmayan**. Her adımda "Dashboard → sol menü → şu
   tıkla" tarzı. UI konumu gerçek (2024-2026 stabil).
3. **Her servis için neden Ulak default'u bu** açıklaması. Alternatif tablosu var;
   karar gerekçesi belirtilmiş.
4. **"ASLA"larla gizli key'leri korur**. Service role key, database password,
   production API key — hangisinin nerede kullanılacağı açık.
5. **Free tier limitleri doğru**. Abartmıyor, underspec etmiyor — servislerin
   publicly declared limitleri ile hizalı.
6. **Sorun giderme bölümü zorunlu**. Her tutorial'ın son bölümü "X hatası alırsan
   şöyle çöz" tablosu.
7. **Gerçek isim/URL kullanılmaz**. Placeholder: `xxxxxxxxxxxxxxxxxxxx`, `siten.com`,
   `my-saas-project`. Portfolio projesine referans yok.
8. **`/ulak-next-steps` ile entegre**. Tutorial hangi `/ulak-next-steps` adımlarını
   tamamlar, üst bölümde belirtilir.

---

## Katkı / Contributing

Yeni external service tutorial'ı eklemek istiyorsan:

1. Dosya adı: `<service>.md` (lowercase, kebab-case).
2. Yukarıdaki 8 prensibe uy.
3. Ortalama 300-450 satır, 5-9 bölüm, icindekiler + süre tablosu üstte.
4. `docs/catalog.md` §Tutorials bölümüne satır ekle.
5. `.claude/commands/ulak-next-steps.md`'de ilgili adıma link ekle.
6. PR + `/director komple` ile validation.

**Yasaklar**:
- Gerçek key / token / email / domain yazmak
- Portfolio ismi (bayi*, ajans*, trend*, cevap*) geçmek
- Uydurulmuş UI konumu (gerçekten öyle bir button/menü yoksa yazma)
- Yanlış fiyatlama iddia etmek

---

*Son güncelleme / Last updated: 2026-04-21 · v3.0.x beginner expansion*
