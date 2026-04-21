# 05 — İş akışları

> **v1.6 güncellemesi:** 5 canonical workflow açıklanır: (1) "İlk kez SaaS" — `selam ulak` → `/ulak-start` → scaffold → next-steps → deploy; (2) Mevcut proje audit; (3) Belirli servis öğrenme; (4) Pack genişletme; (5) Cross-project pattern. Her workflow için senaryo, komut dizisi, beklenen çıktı ve ilgili walkthrough/tutorial linki verilir.

Bu bölüm Ulak OS'un en çok kullanılan beş iş akışını (workflow) kapsar. Her iş akışı için: **kullanım senaryosu**, **komut dizisi**, **beklenen çıktı**, ve **bu iş akışının yetmediği durumlar** verilir.

## İş akışı 1 — İlk kez SaaS (greenfield onboarding)

**Senaryo:** Daha önce SaaS yapmamış veya Ulak OS'u ilk kez deneyen bir operatör. Next.js + Supabase + payment + i18n + CI yazmak için haftalar harcamak istemiyor. Günün sonunda `localhost:3000`'de çalışan, staging'e push edilebilecek, Ulak governance'ı baştan bağlı bir SaaS istiyor.

**Komut dizisi:**

```bash
# 1. Ulak OS kurulumu (daha önce yaptıysanız atlayın)
curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh

# 2. Kaynak dizinde AI CLI'nızı açın (Claude Code / Gemini CLI / Codex / Copilot)
cd ~/projects
claude    # veya: gemini / codex / VS Code'u aç
```

Ardından AI CLI'nızın prompt'una doğal dilde:

```
selam ulak
```

`/ulak-hello` tour'u açılır. Sonra:

```
/ulak-start
```

5 fazlı, 27 soruluk wizard başlar. İlk kez SaaS yapıyorsanız `[b]` basit mod seçin — sorular gündelik dilde, inline terim açıklamalarıyla (`rls`, `supabase`, `iyzico` gibi terimler `/ulak-explain` lookup ile). Wizard bitince onay istenir; onayla `/ulak-scaffold` otomatik dispatch edilir.

Scaffold tamamlanınca:

```
/ulak-next-steps
```

8-10 somut adımla: `pnpm install`, `.env.local` doldurma, Supabase/Iyzico/Resend hesap açma linkleri, ilk migration, seed, `pnpm dev`, ilk admin kullanıcı oluşturma, admin paneline giriş. Bu adımların sonunda localhost:3000 açılır ve giriş yapabilirsiniz.

**Tüm akış tek walkthrough'da:** [docs/walkthrough/01-first-saas-end-to-end.md](../../walkthrough/01-first-saas-end-to-end.md) (Claude Code variant, 75-90 dk). Codex variant: [01-first-saas-end-to-end-codex.md](../../walkthrough/01-first-saas-end-to-end-codex.md). Copilot variant: [01-first-saas-end-to-end-copilot.md](../../walkthrough/01-first-saas-end-to-end-copilot.md).

**Bu iş akışı yetmez eğer:**

- Stack'iniz Next.js dışı bir çerçeve (Rails, Django, Laravel). Manuel yapı gerekir.
- Frontend Next.js ama backend ayrı bir servis (Python/Go). `stack_backend=node-fastapi` ile monorepo'ya geçin.
- Mobile-first uygulama. `has_mobile=true` scaffolder'da mobile/ workspace ekler ama native mobile stack ayrı seçilmeli.

## İş akışı 2 — Mevcut proje audit (brownfield derin denetim)

**Senaryo:** Üç sene önce başka bir takım tarafından yazılmış, son iki sene yarım-bakımlı bırakılmış bir SaaS uygulamasını devraldınız. Neyi atabileceğinizi, neyi düzeltmeniz gerektiğini, production'a çıkmadan önce hangi kırmızı çizgilerin yakalanacağını bilmiyorsunuz.

**Komut dizisi:**

```bash
cd /path/to/inherited-project
ulak init .                                   # vendor auto-detect
claude                                        # veya: gemini / codex / VS Code

# Proje içinde:
/director komple output_language=tr
```

Persona kırılımı isterseniz:

```
/director komple persona=customer,admin,partner output_language=tr
```

İkinci görüş 14-dimension scorecard:

```
/ulak-audit-deep
```

**Beklenen çıktı:** `reports/current/` altında 15 artefakt. En kritik üçü:

- `inventory.md` — her API route, env var, migration, i18n key, config dosyası file:line bazlı
- `did-you-know.md` — non-obvious findings: unused import, RLS asimetrisi, kırık i18n, N+1 risk, deploy rollback yokluğu
- `manager-verdict.md` — `ready` / `conditional` / `blocked` + top 3 did-you-know + residual risks + next execution lane

`/ulak-audit-deep` ek olarak 14 dimension için 0-100 skor + A-F grade üretir.

Tipik süre: 20-40 dakika.

**Bu iş akışı yetmez eğer:**

- Repo 100k+ LOC ve tek `/director` context budget'ı aşıyor — submodule bazlı parçalı denetim.
- Sadece CI'nin yeşillenmesi gerekiyor — `/triage-build` yeterli.
- Production'a çıkmak istemiyor, sadece "okumak" istiyorsanız — `/intake` daha hafif.

Walkthrough: [docs/showcase/01-audit-walkthrough.md](../../showcase/01-audit-walkthrough.md).

## İş akışı 3 — Belirli servis öğrenme

**Senaryo:** Scaffold edildi, proje çalışıyor. Ama `.env.local`'a `SUPABASE_SERVICE_ROLE_KEY` yazmak gerekiyor — bu ne demek, nereden alınır? Ya da Vercel'e deploy ederken "production branch" ne anlama geliyor? Bir dakikalık lookup veya yarım saatlik derinlemesine okuma istiyorsunuz.

**Komut dizisi:**

Bir dakikalık lookup — operatörün bilmediği terim:

```
/ulak-explain supabase
/ulak-explain rls
/ulak-explain iyzico
```

Her terim için 5 alanlı şema (Basit / Teknik / Analoji / Ulak'ta / İlgili) döner. Kaynak: [docs/runtime/beginner-glossary.md](../../runtime/beginner-glossary.md).

Yarım saatlik derinlemesine okuma — servis setup'ı:

- [docs/tutorials/supabase.md](../../tutorials/supabase.md) — hesap açma + proje oluşturma + migration + RLS + Next.js integration
- [docs/tutorials/vercel.md](../../tutorials/vercel.md) — deploy + env var + production branch + preview
- [docs/tutorials/github.md](../../tutorials/github.md) — repo + push + Actions + branch protection + Dependabot
- [docs/tutorials/resend.md](../../tutorials/resend.md) — domain verify + DKIM + transactional email + Supabase Auth mail

**Beklenen çıktı:** `/ulak-explain` terim başına 5 alanlı açıklama (inline). Tutorial'lar 4-6 dk okuma, copy-paste adımlar.

**Bu iş akışı yetmez eğer:**

- Servis Ulak pack'te yok (ör. Firebase, Clerk). O zaman vendor'ın kendi dokümantasyonuna gidin; ardından `/ulak-pattern-extract` ile öğrendiğinizi pack'e geri taşıyın.
- Terim glossary'de yok. Glossary `append-only` genişler; PR ile katkı verin ([07-Katkı](./07-katki.md)).

## İş akışı 4 — Pack genişletme (yeni yetenek keşfi + yazımı)

**Senaryo:** Projeyi çalıştırırken "Ulak OS'da şu komut olsa iyi olurdu" hissi aldınız, veya sector pack bir alanı kapsamıyor. Eksiği önce tespit edip sonra doldurmak istiyorsunuz.

**Komut dizisi:**

Önce eksikleri tespit:

```
/pack-gap-audit
```

`reports/current/pack-gap-register.md` altında eksik command/skill/agent/hook/MCP connector/doc/eval listesi çıkar.

Pattern çıkarıp pack'e kaydetmek:

```
/ulak-pattern-extract
```

Örnek senaryo: Mevcut projenizdeki "ödeme webhook + idempotency + DB unique constraint" üçlüsünü Ulak pack'ine ekleme. Komut, pattern-import-ledger'a T1/T2 evidence ile entry yazar ve `docs/runtime/rule-packs/` veya `docs/runtime/anti-patterns.md` altına dokümantasyonu üretir.

İdeation önce, implementation sonra:

```
/ulak-brainstorm
```

Yeni bir feature/skill için kod yazmadan ideation — superpowers:brainstorming + Ulak governance. Sonuç `docs/superpowers/specs/<date>-<topic>.md` altına yazılır.

Yeni MCP keşfi:

```
/ulak-mcp-discover
```

Public registry'den MCP server'ları trust tier'a göre sınıflandırır, allowlist önerisi verir. Otomatik kurmaz — operatör inceler, manuel `settings.json`'a ekler.

**Beklenen çıktı:**

- `reports/current/pack-gap-register.md` — eksikler listesi
- `docs/governance/pattern-import-ledger.md` — yeni entry
- `docs/runtime/rule-packs/<new-pack>.md` veya `docs/runtime/anti-patterns.md` — dokümantasyon
- `docs/superpowers/specs/<date>-<topic>.md` — ideation çıktısı
- `reports/current/mcp-discovery/*.md` — MCP aday raporu

**Bu iş akışı yetmez eğer:**

- Pattern tek-kaynak (≥2 proje kanıtı gerektirir) — önce ikinci bir proje kanıtı ekleyin.
- Yeni bir pack-unit tipi (8. tip) — ADR gerekir ([07-Katkı](./07-katki.md) "ADR gerektiren değişiklikler" bölümü).

## İş akışı 5 — Cross-project pattern (kurumsal bellek transferi)

**Senaryo:** Portföyünüzde 3 SaaS projesi var; her birinde benzer bir pattern çözüldü ama her seferinde sıfırdan. Deseni Ulak OS'un pattern-import-ledger'ına kaydedip bir sonraki `/director` veya `/ulak-scaffold` çalıştığında otomatik hatırlanmasını istiyorsunuz.

**Komut dizisi:**

```bash
# 1. Kaynak projede deseni tespit et (manuel veya /director çıktısı)
cd /path/to/source-project
claude
/director komple

# 2. Desen tespit edildiyse Ulak pack'ine lift et
cd ~/tools/ulak-os    # ya da submodule: cd .ulak-os
claude

/ulak-pattern-extract
```

Komut etkileşimli olarak şunları sorar:
- Kaynak proje descriptor'u (abstract, ör. "Türkçe-birincil bir SaaS")
- Kaynak dosya yolları + satır aralıkları
- Trust tier (T1/T2 — T3 ve altı kabul edilmez)
- Rationale (neden ≥2 projede aynı şekilde çıkmış)
- Hedef pack (anti-pattern / rule-pack / sector-pack)

Sonuç: `docs/governance/pattern-import-ledger.md` entry + `docs/runtime/*` dokümantasyonu. Bilingual parity (TR + EN) zorunlu.

Son olarak validation + commit:

```bash
bash scripts/validate-schemas.sh
bash scripts/validate-bilingual.sh
git add docs/governance/pattern-import-ledger.md docs/runtime/...
git commit -m "feat(patterns): import AP-42 from multi-tenant SaaS evidence"
git push
```

**Beklenen çıktı:**

- `pattern-import-ledger.md` yeni entry (T1/T2 + ≥2 kaynak + rationale)
- Pattern referansı `docs/runtime/` altına eklenmiş
- CI'da pattern-import-ledger + bilingual schema check geçti
- Bir sonraki `/director` veya `/ulak-scaffold` koştuğunda bu pattern otomatik referans edilir

Walkthrough: [docs/showcase/04-cross-project-absorption.md](../../showcase/04-cross-project-absorption.md).

**Bu iş akışı yetmez eğer:**

- Pattern sadece bir projede görüldü — single-source T2 altında kalır; ikinci kaynak ekleyin.
- Pattern generic değil proje-özgü — kaynak repo'da kalsın, Ulak OS'a import etmeyin.

## Özet karar ağacı

```
İhtiyacım ne?
├── Sıfırdan yeni bir SaaS başlatmak              → İş akışı 1 (selam ulak → /ulak-start → /ulak-scaffold → /ulak-next-steps)
├── Mevcut projeyi derin denetlemek               → İş akışı 2 (/director komple + opsiyonel /ulak-audit-deep)
├── Belirli servis/terim öğrenmek                 → İş akışı 3 (/ulak-explain veya tutorials/*.md)
├── Ulak pack'i genişletmek                       → İş akışı 4 (/pack-gap-audit + /ulak-pattern-extract + /ulak-brainstorm)
├── Proje-arası pattern kurumsal belleğe almak    → İş akışı 5 (/ulak-pattern-extract + pattern-import-ledger)
├── Persona-özgü findings istiyorum               → /director komple persona=customer,admin,partner
├── Önceki audit'i güncellemek                    → /final-verdict
├── CI kırık, nedenini bulacağım                  → /triage-build
├── Frontend redesign                              → /frontend-war-room + /ulak-design-ref <brand>
└── Sadece intake/inventory istiyorum             → /intake (hafif)
```

## İpuçları

- **NL ile başla.** Komut hatırlamıyorsanız `selam ulak` yazın veya `/ulak-ask <niyet>` — dispatcher doğru komutu bulur.
- **Sihirbazla başla.** `/ulak-start` 27 soruyla sector + rule + payment + deploy seçimlerini otomatikleştirir.
- **Run'ları arşivle.** Her `/director` çalıştırmadan önce mevcut `reports/current/` dizinini `reports/archive/<tarih>/` altına taşı.
- **Persona'yı açıkça belirt.** Multi-surface SaaS'ta `persona=customer,admin,partner` zaman kazandırır.
- **Validation-plan §6'yı okumadan "ready" deme.** Signoff blocked ise neden blocked, validation-plan söyler; re-run etmek yerine fix edip `/final-verdict` koş.
- **Sector pack'i zorla.** Router yanlış sektörü seçerse Phase 0 sonrası `active-variables.yaml`'a `sector: fintech` gibi override ekle.
- **Walkthrough + tutorial'ları oku.** İlk koşturmanızdan önce ilgili walkthrough ya da tutorial 10-15 dk'lık sessiz bir önizleme sağlar.

Sonraki bölüm: [06 — Yönetişim](./06-yonetisim.md)
