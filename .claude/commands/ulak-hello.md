---
description: 30 saniyelik onboarding tour. Ulak OS'un ne yaptığını 3 cümlede anlatır, 3 örnek komut gösterir ve "ne yapmak istiyorsun?" diye sorar. Yeni kullanıcının "ne olduğunu görmesi" için ilk ekran.
description_en: 30-second onboarding tour. Explains what Ulak OS does in 3 sentences, shows 3 example commands, and asks "what do you want to do?". The first-screen experience so new users can "see what this is".
phases_run: []
---

# /ulak-hello

> **TR** — Yeni mi geldin? 30 saniye ver, ne olduğunu göreceksin.
> **EN** — New here? Give it 30 seconds and you'll see what this is.

## Amaç / Purpose

**TR**: Ulak OS'a ilk kez giren kullanıcı `CLAUDE.md`'yi okumaz, 23 governance doc'u incelemez, 27 agent'ı taramaz. 30 saniyede şunu görmeli: (1) ne yapan bir şey bu, (2) hangi komutlarla denenir, (3) şimdi ne yapsam. Bu komut bu üç soruyu cevaplar; kullanıcıya bir seçim listesi verir; seçime göre ilgili komuta yönlendirir.

**EN**: A first-time user will not read `CLAUDE.md`, skim 23 governance docs, or scroll 27 agents. In 30 seconds they must see: (1) what is this, (2) which commands to try, (3) what to do next. This command answers those three questions, presents a choice list, and routes the user to the matching command.

## Ne yapmaz / What it does NOT do

- Disk'e yazmaz, artefakt üretmez, subagent dispatch etmez.
- Does not write to disk, does not produce artefacts, does not dispatch subagents.
- Program Director'ı (`/director komple`) çağırmaz — o Phase 0-5 ağır işlemdir, bu dosya sadece yönlendirici.
- Does not call the Program Director (`/director komple`) — that is the heavyweight Phase 0-5 program; this command only routes.

## Akış / Flow

Tek mesajla aşağıdaki template'i göster. Kullanıcı `[1..4]` arası bir rakam girerse ilgili komuta yönlendir. Başka bir şey girerse özgürce yorumla ve `/ulak-ask` önerisi ver.

### 1. Başlık (3 cümle — TR-first)

```
Ulak OS nedir?

1) AI coding CLI'larının (Claude Code / Codex / Gemini) üstüne oturan bir prompt işletim
   sistemi — audit, governance ve SaaS scaffolding, üçünü birden yapar.
2) Tek komutla bütün bir projeyi okur, eksikleri bulur, roadmap çıkarır; ya da sıfırdan
   tam yığın (Next.js + Supabase + payment + i18n + CI + deploy) bir SaaS üretir.
3) Vendor-neutral — aynı çekirdek üç CLI adaptöründe çalışır; mimarinizi bir şirkete
   kilitlemez.
```

### 2. Üç örnek komut

```
Örnekler:

  /director komple               -> Mevcut projeyi baştan sona audit et.
                                    27 uzman paralel çalışır, 5 fazda bitirir.
  /ulak-start                    -> Yeni SaaS oluştur. 6 kısa soruya cevap ver;
                                    scaffolder doğru parametrelerle çalışsın.
  /ulak-ask "<soru>"             -> Doğal dille sor: "rls'yi nasıl test ederim",
                                    "pack-gap'e bak", "turkish locale ekle".
```

### 3. Seçim menüsü

```
Şimdi ne yapmak istiyorsun? (1-4)

  [1] Yeni SaaS yap                   -> /ulak-start
  [2] Mevcut projeyi audit et         -> /director komple
  [3] Doğal dille sor                 -> /ulak-ask "<query>"
  [4] Tüm kapasiteleri göster         -> /ulak-packs

  İlk kez mi SaaS yapıyorsun? `/ulak-start` çalıştırınca
  ilk soruda [b] basit mod'u seç — Next.js/Supabase/SSO yerine
  gündelik dille ilerler, teknik terimi geçtikçe kısa açıklama verir.

  First time building a SaaS? When you run `/ulak-start`, pick
  [b] beginner mode at the first prompt — plain language instead
  of Next.js/Supabase/SSO, with inline glossary for each term.

Cevap / Answer: _
```

## Routing mantığı / Routing logic

| Kullanıcı girdisi | Ne yap |
|---|---|
| `1` veya "yeni" / "saas" / "scaffold" / "start" | `/ulak-start` komutunu öner ve nedenini söyle: "6 soruya cevap ver, Ulak OS tam yığın SaaS çıkarsın" |
| `2` veya "audit" / "mevcut" / "director" / "scan" | `/director komple` komutunu öner ve nedenini söyle: "Phase 0-5, 27 specialist paralel, 13 artefakt" |
| `3` veya "sor" / "ask" / "query" / "doğal" | `/ulak-ask "<soru>"` kullanımını göster; kullanıcının girdisini şablona yerleştir |
| `4` veya "paket" / "kapasite" / "liste" / "pack" | `/ulak-packs` komutunu öner (kapasite özeti) |
| Başka bir şey (serbest metin) | `/ulak-ask` disambiguator'ını çağır: kullanıcının metnini query olarak ver |
| Boş / iptal | Kapat ve sessiz kal; `/help` ile geri döneceğini söyle |

## Çıktı şablonu / Output template

Komut her çalıştığında aşağıdaki gibi tek bir bloğu render etmeli. Başka bir şey yazma.

```
═════════════════════════════════════════════════════════════════
 Ulak OS — 30 saniyelik tour
═════════════════════════════════════════════════════════════════

 Ulak OS nedir?

 (1) AI coding CLI'larının üstüne oturan prompt işletim sistemi.
 (2) Audit + governance + full-stack SaaS scaffolder — üçü bir arada.
 (3) Vendor-neutral (Claude / Codex / Gemini), tek çekirdek.

─ Örnek komutlar ────────────────────────────────────────────────

   /director komple       Mevcut projeyi audit et (Phase 0-5).
   /ulak-start            Yeni SaaS başlat (6 soruluk wizard).
   /ulak-ask "<soru>"     Doğal dille sor, Ulak yönlendirsin.

─ Şimdi ne yapalım? ─────────────────────────────────────────────

   [1] Yeni SaaS yap                    -> /ulak-start
   [2] Mevcut projeyi audit et          -> /director komple
   [3] Doğal dille sor                  -> /ulak-ask "<query>"
   [4] Tüm kapasiteleri göster          -> /ulak-packs
   [5] Sıfırdan tam senaryo gör         -> docs/walkthrough/01-first-saas-end-to-end.md

 ℹ  İlk kez SaaS yapıyorsan:
    - Hızlı başla        : [1] + ilk soruda [b] basit mod
    - Önce tam yolu gör  : [5] 75 dk'lık uçtan uca walkthrough

 Cevabın: _
═════════════════════════════════════════════════════════════════
```

## Validation

- Komut çıktısı **tek bloktur**; ek narrative, ek link, ek açıklama eklenmez.
- 4 seçeneğin hepsi görünür olmalıdır; biri eksikse çıktı reddedilir.
- Kullanıcı girdisi yorumlandığında **gerçek komuta yönlendirme** zorunlu — "şunu yazabilirsin" yerine "çalıştırıyorum: `/ulak-start`" gibi net aksiyon.
- TR-first: başlıklar, menü ve seçenekler Türkçe render edilir. EN mirror `description_en` ile sağlanır.

## İlgili / Related

- [`/ulak-start`](./ulak-start.md) — 6 soruluk SaaS wizard
- [`/director`](./director.md) — tam program (Phase 0-5)
- [`/ulak-ask`](./ulak-ask.md) — doğal dil routing
- [`README.md`](../../README.md) §"Ne yapabilirim?" — 6 somut senaryo

---

_Bu komut `CLAUDE.md` §Working rule ile uyumludur: kullanıcı intent'i netse menü döngüsüne geri dönmez, doğrudan seçilen komuta devreder._
