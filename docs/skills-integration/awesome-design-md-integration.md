# awesome-design-md Entegrasyonu

Türkçe | [English](awesome-design-md-integration.en.md)

Ulak OS, [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) reposundaki MIT lisanslı tasarım sistem referanslarını fetch-on-demand modunda kullanır. İçerik bu repoda **kopyalanmaz**; istek üzerine indirilir.

## Neden?

Ulak OS'un frontend subagent'ları (`design-system-architect`, `frontend-ios-flutter-director`) ve `/frontend-war-room` komutu, tasarım kararları üretirken **kanıt-tabanlı** çalışır. "Stripe checkout gibi olsun" istekleri için artık modeli "hayal etmesi" gerekmez — gerçek Stripe DESIGN.md dosyası referans olarak yüklenir.

## 58+ marka mevcut

| Kategori | Örnekler |
|---|---|
| AI/ML | Claude, Cohere, ElevenLabs, Ollama, xAI |
| Developer Tools | Cursor, Linear, Vercel, Supabase, Warp |
| Design/Productivity | Figma, Notion, Framer, Miro |
| Fintech | Stripe, Coinbase, Revolut |
| Enterprise | Apple, Uber, Spotify, SpaceX |
| Otomotiv | Tesla, BMW, Ferrari, Lamborghini |

Tam liste: https://github.com/VoltAgent/awesome-design-md

## Nasıl kullanılır?

### Wrapper komut üzerinden (en kolay)

```
/ulak-design-ref stripe
```

Bu komut:
1. `scripts/fetch-design-references.sh stripe` çağırır
2. `reports/current/design-references/stripe/DESIGN.md` dosyasına yazar
3. İçeriği özetler ve frontend görevine entegre eder

### Manuel script üzerinden

```bash
# macOS/Linux
bash scripts/fetch-design-references.sh stripe

# Windows
powershell -ExecutionPolicy Bypass -File scripts\fetch-design-references.ps1 stripe
```

### Frontend war room ile entegre

```
/frontend-war-room checkout sayfası mobile-first redesign
```

Savaş odası açıldığında, hangi marka referansının uygun olacağını kullanıcıya sorar veya otomatik birkaç aday önerir. Kullanıcı seçince `/ulak-design-ref` arka planda çalışır ve referans war room'un context'ine eklenir.

## Lisans ve attribution

awesome-design-md MIT lisanslıdır. İndirdiğin her DESIGN.md dosyasının kaynağı upstream URL ile birlikte saklanmalıdır. Üretim koduna doğrudan kopyalanması istenmez; kararı/ilhamı yönlendirmek için kullanılır.

## Bağımlılıklar

- İnternet bağlantısı (fetch sırasında)
- `curl` (Linux/macOS) veya PowerShell (Windows)

## Sınırlar

- Offline çalışmaz (önceden indirilen referanslar offline kullanılabilir)
- Upstream repo'nun dizin yapısı değişirse fetch script güncellenmeli (3 fallback path zaten denenir)
- Marka adları lowercase olmalıdır (`stripe`, `Stripe` değil)

## Gelecek plan

- `examples/design-driven-frontend/` → fetch + apply pattern'ının çalıştırılabilir örneği
- Smoke test: 5 popüler marka için fetch → parse → kullanılabilir mi?
- Codex/Gemini için eşdeğer wrapper komutlar
