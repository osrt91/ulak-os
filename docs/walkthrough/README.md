# Walkthroughs — Ulak OS uçtan uca senaryoları

Her walkthrough, gerçek bir kullanıcı profilini alıp sıfırdan canlı siteye kadar **kopyalanabilir adımlarla** götürür. Tutorial'lardan farkı: tutorial'lar tek bir servis anlatır (Supabase veya Vercel), walkthrough ise birden fazla servisi + Ulak komutunu birleştirip **tam bir iş akışı** gösterir.

## Mevcut walkthroughlar

| # | Başlık | Süre | Zorluk | Ne öğretir |
|---|---|---|---|---|
| 01 | [Sıfırdan ilk SaaS'a uçtan uca](01-first-saas-end-to-end.md) | 75-90 dk | Başlangıç | Ev temizlik marketplace + Supabase + GitHub + Vercel + Resend + Iyzico |

## Nasıl okunur

- **Baştan sona takip et** — her komutu kendi makinende çalıştır
- **Sadece ilgini çeken kısımları oku** — her bölüm bağımsız çalışabilir
- **Ulak OS'a geçmeden önce tüm walkthrough'u oku** — ön gösterim sağlar

## Walkthrough vs diğer dokümanlar

| Belge türü | İçerik | Örnek |
|---|---|---|
| **Walkthrough** | Tam senaryo, birden fazla servis, kopyalayabilir akış | Bu dizin |
| **Tutorial** | Tek servis derinlemesine | `docs/tutorials/supabase.md` |
| **Runbook** | Spesifik operasyonel prosedür | `docs/runbooks/troubleshooting.md` |
| **User manual** | Referans, kategorize bilgi | `docs/user-manual/tr/` |
| **FAQ** | Tek-soru-tek-cevap | `docs/FAQ.md` |

## Gelecek walkthroughlar (v1.6 backlog)

- **02**: Eğitim platformu (LMS) — sync lessons + sertifika + quiz
- **03**: Fintech starter — KYC (Sumsub) + AML + TR banka entegrasyonu
- **04**: Hybrid sistem — Next.js + FastAPI + Expo mobile + Telegram bot
- **05**: Brownfield rescue — mevcut legacy SaaS'ı Ulak OS governance'a taşıma
- **06**: Multi-tenant enterprise B2B — SSO + SCIM + audit retention
- **07**: AI copilot + cost cap — RAG + Anthropic/OpenAI fallback + budget

## Katkı

Yeni walkthrough yazmak istersen: gerçek bir kullanıcıyı oyna, her adımı kopyalanabilir yap, her hatayı + çözümünü ekle. Şablon: `01-first-saas-end-to-end.md` dosyasını referans al.

---

_Walkthrough'lar v1.5.0'da Ulak OS'a eklendi._
