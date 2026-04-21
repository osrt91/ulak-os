# Walkthrough #1 (Copilot Chat variant) — Sıfırdan ilk SaaS'a uçtan uca

> **Kime**: Ulak OS'a ilk kez giren, hiç SaaS yapmamış, VS Code + GitHub Copilot Chat kullanan bir kullanıcı.
> **Süre**: 75-90 dakika (okuma + uygulama).
> **Sonuç**: GitHub'da repo, Vercel'de canlı URL, Supabase'de database, Resend'den email gönderen, Iyzico test ödeme alan bir "ev temizlik hizmeti marketplace" sitesi — aynen Claude Code variant'ı gibi.
> **Ön koşul**: VS Code + GitHub Copilot Chat stable (VS Code 1.90+), ve Ulak OS kurulu bir klasör (install için `docs/runbooks/install-methods.md`).

## Bu varyant hangi farkla?

Claude Code variant'ı (`01-first-saas-end-to-end.md`) slash komutları native çalıştırır. **Copilot Chat slash komut dispatch etmez** — bunun yerine `.github/copilot-instructions.md` içindeki Natural-Language Trigger Map üzerinden aynı 24 kapasiteyi doğal dille tetikler. Bu walkthrough aynı 10 bölümü Copilot Chat'te nasıl yürüteceğini adım adım gösterir.

## Senaryo

Ali küçük bir işletme açmak istiyor: müşteriler siteye gelsin, temizlik görevlisi seçsin, randevu alsın, kredi kartıyla ödesin. Görevliler siteye giriş yapsın, takvimlerini yönetsin. Ali admin olarak her şeyi görsün. Türkiye'de kullanılacak, TL ödeme, KVKK uyumlu. Ali'nin kod yazma tecrübesi sıfır — sadece HTML-CSS gördü bir-iki kere. Ali, VS Code'u daha önce indirmiş; Copilot aboneliği aktif.

---

## Bölüm 1 — Hazırlık (5 dk)

### 1.1 VS Code aç, Copilot Chat panelini aç

- `View → Command Palette → "Chat: Focus on Chat View"` veya sağ üstteki Copilot ikonu.
- Sidebar'da "Chat" paneli açılır. Altta metin kutusu, üstte "Ask Copilot anything" mesajı.

### 1.2 Ulak OS kurulu klasörü aç

Ali `~/projeler` altında klonlanmış bir Ulak OS kurulumu olan bir klasör açar:

```
File → Open Folder → ~/projeler
```

Bu klasörde `.github/copilot-instructions.md` dosyasının **bulunması zorunludur** — Copilot Chat bu dosyayı workspace açılışında otomatik okur ve her chat turn'una talimat olarak enjekte eder.

### 1.3 Doğrulama

Ali Copilot Chat'e şunu yazar:

```
@workspace ulak os burada mı kurulu
```

Copilot cevap verir:
```
Evet — repo kökünde AGENTS.md, CLAUDE.md, .github/copilot-instructions.md
ve prompts/core/ulak-os-core-contract-2.0.0.md var. Natural-Language
Trigger Map aktif. "selam ulak" yazarak başlayabilirsin.
```

---

## Bölüm 2 — İlk keşif (2 dk)

Ali ne yapacağını bilmiyor. Slash komut arar, bulamaz (Copilot Chat'te yok). Sadece yazar:

```
selam ulak
```

Copilot, Natural-Language Trigger Map rule #1 ile eşleştirir, `/ulak-hello` denk olduğunu söyler, `.claude/commands/ulak-hello.md` içindeki template'i inline render eder:

```
Bu `/ulak-hello` protokolüne denk düşüyor. Copilot Chat slash desteklemediği
için inline simüle ediyorum.

═════════════════════════════════════════════════════════════════
 Ulak OS — 30 saniyelik tour
═════════════════════════════════════════════════════════════════

 Ulak OS nedir?
 (1) AI coding CLI'larının üstüne oturan prompt işletim sistemi.
 (2) Audit + governance + full-stack SaaS scaffolder — üçü bir arada.
 (3) Vendor-neutral (Claude / Codex / Gemini / Copilot), tek çekirdek.

─ Şimdi ne yapalım? ─────────────────────────────────────────────
   [1] Yeni SaaS yap                    -> /ulak-start
   [2] Mevcut projeyi audit et          -> /director komple
   [3] Doğal dille sor                  -> /ulak-ask "<query>"
   [4] Tüm kapasiteleri göster          -> /ulak-packs

 Cevabın: _
═════════════════════════════════════════════════════════════════
```

Ali yeni turn'da yazar: `1`

Copilot cevap verir: "Tamam, bu `/ulak-start` protokolüne denk. Simüle ediyorum..."

---

## Bölüm 3 — Sihirbaz (12 dk) — Copilot içinde 27-soru

Copilot, `.claude/commands/ulak-start.md` dosyasını okur ve **faz faz** ilerler. Her fazda kullanıcıya cevap bekletir — Ali Copilot Chat metin kutusuna yazar, gönderir, Copilot bir sonraki fazı render eder.

### Q0 — Mod seçimi

Copilot render eder:
```
Ulak OS seni iki şekilde yönlendirebilir:
 [t] Teknik mod (default)
 [b] Basit mod — ilk kez SaaS yapıyorsan
Seçim: _
```

Ali: `b`

### Phase 1 — Proje kimliği (4 soru)

Her soru ayrı Copilot turn'u:

- **Q1.1 Proje adı?** Ali: `temiz-gunler`
- **Q1.2 Ne tür proje?** Copilot 7 seçenek render eder. Ali: `5` (iki taraflı site)
- **Q1.3 Kullanıcı ölçeği?** Ali: `2`
- **Q1.4 Dil?** Ali: `[enter]` — Copilot teyit eder: "default=Türkçe olarak alıyorum."

### Phase 2 — Teknik stack (6 soru)

Ali tüm sorulara `[enter]` cevabını yazar. Copilot her birinde default'u açıkça tekrar eder:

```
Q2.1 Stack? (default=Next.js+Supabase) → [enter] → default alındı.
Q2.2 Auth?  (default=email+magic+google) → [enter] → default alındı.
...
```

### Phase 3 — Sektör derinliği (marketplace için 3 soru)

- **Q3.1 Komisyon?** Ali: `[enter]` → %10
- **Q3.2 Escrow?** Ali: `e` (evet)
- **Q3.3 Dispute?** Ali: `[enter]` → evet

### Phase 4 — Operasyonlar (5 soru)

- **Q4.1 Region?** Ali: `3` — Copilot: "region=tr seçildi; KVKK otomatik eklenecek."
- **Q4.2–Q4.5** hepsi `[enter]`

### Phase 5 — Takım + deploy + compliance (6 soru)

- **Q5.1** takım: `2`
- **Q5.2** CI: `[enter]` (GitHub Actions)
- **Q5.3** deploy: `3` (Vercel)
- **Q5.4** preview per-PR: auto-yes (team > 1)
- **Q5.5** compliance: `[enter]` → kvkk (region=tr)
- **Q5.6** monitoring: `[enter]`

### Özet + Aktive edilenler paneli

Copilot tek mesajla özet + aktive panel + çalıştırılacak komut bloğunu render eder (Claude variant'ındaki ile birebir aynı — 140 dosya, 3 rule pack, 8 anti-pattern). Son satır:

```
─ Çalıştırılacak komut ───────────────────────────────────
 /ulak-scaffold product_name=temiz-gunler \
   --sector=marketplace --stack=nextjs-supabase \
   --payment=iyzico --storage=supabase-storage \
   --email=resend --region=tr --compliance=kvkk \
   --team-size=small --deploy=vercel \
   --escrow=true --dispute=true --preview-per-pr

 Bunu terminal'de çalıştırmam için onaylar mısın?  [e/h] _
```

---

## Bölüm 4 — Scaffold (30 saniye) — Copilot'un özel kısıtı

Copilot Chat **doğrudan terminal komutu çalıştıramaz**; VS Code terminalini açıp Ali'ye komutu önerir. Ali onaylar:

```
Ali: e
```

Copilot:
```
Terminal'de şu komutu çalıştır:

  cd ~/projeler
  ulak scaffold temiz-gunler \
    --sector=marketplace --stack=nextjs-supabase \
    --payment=iyzico --storage=supabase-storage \
    --email=resend --region=tr --compliance=kvkk \
    --team-size=small --deploy=vercel --escrow=true --dispute=true

Ctrl+` tuşuna basarak VS Code terminalini aç. Komut bittiğinde
bana "tamam" yaz, ben `/ulak-next-steps`'i simüle edeyim.
```

Ali Ctrl+\` ile terminal açar, komutu yapıştırır. 30 saniye sonra:
```
Scaffolding 'temiz-gunler' from Ulak OS templates...
✓ Total: 140 files materialized in ./temiz-gunler/
```

Ali chat'e döner: `tamam`

Copilot bir sonraki bölümü başlatır.

---

## Bölüm 5 — Post-scaffold runbook (/ulak-next-steps)

Copilot `.claude/commands/ulak-next-steps.md`'yi okur ve 12 adımlı kişisel runbook'u inline render eder (env var'lar, `pnpm install`, migration, seed, ilk admin user, Git init, GitHub push, Vercel deploy, custom domain — Claude variant ile aynı).

Her adımın sonunda Copilot:
```
Bu adımı bitirince "bitti" veya "done" yaz, bir sonrakine geçeyim.
Takılırsan "X nedir" veya "hata: <metin>" yaz, açıklayayım.
```

---

## Bölüm 6 — Supabase kurulumu (15 dk)

Ali chat'e yazar: `supabase nasıl`

Copilot Natural-Language Trigger Map rule #4 ile eşleştirir:
```
Bu `docs/tutorials/supabase.md` tutorial'ına denk. Adım adım yürütüyorum.
```

Copilot tutorial dosyasını workspace'den okur ve her section'u sırayla render eder. Ali takıldığında `service role key nedir` yazar:

```
Bu `/ulak-explain service-role-key` protokolüne denk. 5 alanlı şema:

service_role / Service Role Key

[Basit]     Supabase'de sunucu tarafı işlemler için kullanılan gizli anahtar.
[Teknik]    Postgres'te RLS'i bypass edebilen, JWT imzalamaya yetkili
            server-only API key.
[Analoji]   Apartmanın bina müdürünün master anahtarı.
[Ulak'ta]   .env.local → SUPABASE_SERVICE_ROLE_KEY
[İlgili]    anon-key, RLS, JWT, admin-ops
```

Ali Supabase dashboard'da "Reveal" düğmesini bulur, key'i kopyalar.

---

## Bölüm 7 — GitHub yükleme (20 dk)

Ali: `github push nasıl yapılır`

Copilot tutorial'ı adım adım yürütür. Ali yanlışlıkla `.env.local`'i commit eder, push reddedilir:
```
remote: error: GH013: Push cannot contain secrets
```

Ali yazar: `secret push reddedildi`

Copilot Natural-Language Trigger Map rule #5 (triage-build) ile eşleştirir:
```
Bu `/triage-build` protokolüne denk. Çözüm özeti:

1. git rm --cached .env.local
2. .gitignore'a '.env.local' ekle
3. git add .gitignore
4. git commit -m "fix: exclude .env.local from git"
5. git push

Komutları terminal'de sırayla çalıştır. Bitince "yeşil" yaz.
```

Ali çözer, push yeşil olur.

---

## Bölüm 8 — Vercel deploy (10 dk)

Ali: `vercel deploy`

Copilot `docs/tutorials/vercel.md`'yi yürütür. 6 env var 2 scope'ta girilir (Sensitive olanlar Production-only). Redeploy → `temiz-gunler.vercel.app` 90 saniye sonra canlı.

---

## Bölüm 9 — İlk test ödeme (5 dk)

Ali: `iyzico test ödeme nasıl`

Copilot `/ulak-ask` disambiguator'ını simüle eder:
```
Bu doğal bir sorgu. Ulak OS şunu öneriyor:
→ Iyzico sandbox test kart: 5528 7900 0000 0008
→ CVC: 123, Expiry: 12/30
→ /admin/orders/new üzerinden test sipariş aç, webhook'u izle.

Webhook geldi mi, `processed_webhook_events` tablosunda görmelisin.
Bitince "webhook geldi" yaz.
```

Ali sandbox ödemesi yapar, webhook'u tablosunda görür.

---

## Bölüm 10 — Ne yaptık, özet

### Ali'nin yaptığı (75-90 dk toplam)

| Zaman | İş | Sonuç |
|---|---|---|
| 0-2 dk | "selam ulak" → tour | Ulak OS'u tanıdı |
| 2-14 dk | "yeni saas" → 27-soru wizard | Özet + aktive panel |
| 14-15 dk | Terminal'de scaffold komut | 140 dosya |
| 15-30 dk | "supabase nasıl" → tutorial | DB + auth + 3 key |
| 30-45 dk | "github push nasıl" + triage | Repo + CI yeşil |
| 45-55 dk | "vercel deploy" → tutorial | Canlı URL |
| 55-65 dk | "resend email" → tutorial | Email |
| 65-75 dk | "iyzico test" → disambiguator | Ödeme akışı |
| 75-85 dk | Polish + admin user + test | Prod-ready demo |

### Claude Code variant ile farklar

| Boyut | Claude Code | Copilot Chat |
|---|---|---|
| Tetikleme | `/ulak-start` slash | "yeni saas" doğal dil |
| Subagent dispatch | Phase 2'de paralel 27 agent | Sıralı; specialist'ler tek tek |
| Terminal komut | Claude Code doğrudan yürütebilir | VS Code terminal'inde kullanıcı onayı + yapıştır |
| Artefakt yazımı | `reports/current/**` otomatik | Director protokolü dışında inline-only; yazı açık onay ister |
| `@workspace` | Yok, repo CWD otomatik | Gerekli — her turn'da `@workspace` prefix önerilir |

### Ulak OS'un arkada yaptığı (iki variant'ta birebir aynı)

- 14 sector overlay'den **marketplace** seçildi
- 8 rule pack'ten **3** aktive edildi (multi-tenant-supabase, transactional-fsm-payment, reseller-enabled-saas)
- 50+ anti-pattern'den **8'i** enforce edildi (DB trigger + CHECK constraint)
- 22 governance doc'tan **4**'ü aktif (KVKK, commission-immutability, audit-retention, payment-FSM)
- 140 template dosyası materialize edildi
- CI + secret scanning + Dependabot hazır

### Ali'ye v1.x sonrası tavsiyeler

1. İlk 10 gerçek kullanıcı → feedback
2. "bu projeyi audit et" → `/director komple` (Phase 0-5)
3. "derin audit" quarterly — 14-dimension health check
4. Custom domain bağla
5. Iyzico sandbox → production (KYC)
6. Supabase free → pro (500 MAU aşarsa)
7. Vercel free → pro (100 GB bandwidth)
8. Sentry alerts + Better Stack uptime

---

## Başka senaryolar için

- Minimal SaaS: "örnek göster" → `/ulak-demo` [1]
- Eğitim platformu: "örnek göster" → `/ulak-demo` [3]
- Fintech / Marketplace: "örnek göster" → `/ulak-demo` [2]
- Kendi senaryonu: "yeni saas" → 27 soru → otomatik scaffold

## Related docs

- `01-first-saas-end-to-end.md` — aynı senaryo, Claude Code variant
- `.github/copilot-instructions.md` — 60+ Natural-Language Trigger Map
- `docs/adapters/copilot-chat.md` — Copilot Chat adapter derinlemesine
- `docs/adapters/codex-cli.md` — Codex / GitHub Copilot CLI adapter (sister)
- `docs/tutorials/{supabase,vercel,github,resend}.md` — servis rehberleri
- `docs/runtime/beginner-glossary.md` — 47 terim

---

_Walkthrough Copilot Chat variant Ulak OS v2.3.x'te eklendi. Trigger map tek otoritedir (`.github/copilot-instructions.md`); walkthrough örnektir, kapsam değildir._
