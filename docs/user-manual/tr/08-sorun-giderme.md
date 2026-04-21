# 08 — Sorun giderme

> **v1.6 güncellemesi:** 10 çekirdek Ulak OS hatasına ek olarak **beginner / service setup** sorunları için yeni bir bölüm (Supabase auth, Vercel env var, GitHub push protection, Resend domain verify) eklendi. `/ulak-ask` + `/ulak-explain` ile self-serve problem çözme yolları da belirtildi.

Bu bölüm yaygın hataların semptom → tanı → fix özetlerini içerir. Tam sorun giderme dökümantasyonu için: [docs/runbooks/troubleshooting.md](../../runbooks/troubleshooting.md). Beginner setup sorunları için ilgili tutorial'a (Supabase/Vercel/GitHub/Resend) bakabilirsiniz.

## Önce self-serve: `/ulak-ask` + `/ulak-explain`

Hatayı tarif etmeden önce 30 saniyelik lookup denemeye değer:

- **Terim anlamadınız mı?** `/ulak-explain <term>` — beginner-glossary'de 47 term var (rls, supabase, jwt, env var, cors, rls, iyzico, pnpm, vb.). Örnek: `/ulak-explain rls`.
- **Hangi komut gerekiyor bilmiyor musunuz?** `/ulak-ask <niyet>` — doğal dil sorusuna göre en uygun komutu önerir. Örnek: `/ulak-ask hata ayıklamak istiyorum, testler kırmızı`.
- **Yeteneği unutmuş olabilir misiniz?** `/ulak-packs` tüm kapasitelerin inline dökümü.
- **Keyword araması?** `/ulak-search <kelime>` — sector/rule/template/template karışık liste.

Bunlar çalışmadığında aşağıdaki hata başlıklarına geçin.

## Ulak OS hataları

### 1. `/director` komutu tanınmıyor

**Semptom:** AI CLI `/director` yazdığınızda "command not found" diyor ya da öneriler arasında komut görünmüyor.

**Tanı:** `.claude/commands/director.md` mevcut projeden erişilemiyor. İhtimaller: (a) AI CLI yanlış dizinden açıldı, (b) entry dosyası (`CLAUDE.md` / `GEMINI.md` / `AGENTS.md`) wiring'i kırık.

**Fix:**

```bash
pwd                                        # entry dosyasının olduğu kök
ls .claude/commands/ 2>/dev/null           # Claude için 24 .md dosyası
ls .gemini/commands/ 2>/dev/null           # Gemini için .toml dosyaları
cat AGENTS.md 2>/dev/null | head -30       # Codex için reading-order + NL map
```

Eksikse:

```bash
ulak init . --vendor=<claude|gemini|codex|all>
# Ya da kurulum dizininden aç:
cd ~/.ulak-os && claude
```

Codex/Copilot'ta slash primitive olmadığı için `/director` yerine "run the director phase 0→5 protocol on this repo" yazın.

### 2. `@`-import kırık (Claude only)

**Semptom:** `validate-imports.sh` "file not found" diyor, Claude Code context'inde beklediğiniz dosya yok.

**Tanı:** Göreceli bir `@`-import yolu, yeniden adlandırılmış veya taşınmış dosyayı işaret ediyor.

**Fix:**

```bash
bash scripts/validate-imports.sh           # hatalı satırı listeler
```

Hata mesajındaki kırık yolu bulun, yeni yola güncelleyin, tekrar validator koşun.

### 3. Gemini'de komut eski kalmış

**Semptom:** Claude'da yeni bir komut ship edildi ama Gemini'de yok.

**Tanı:** `.gemini/commands/*.toml` dosyaları Claude `.md`'lerinden türetilir. Sync script koşmamış.

**Fix:**

```bash
bash scripts/sync-gemini-commands.sh
bash scripts/validate-vendor-parity.sh
```

### 4. Scaffolder koşmayı reddediyor

**Semptom:** `/ulak-scaffold` Phase 0'da guard rejection ile duruyor.

**Tanı:** Phase 0 guard'ı şunlardan birini reddetti:
- Hedef dizin boş değil
- İstenen stack için gerekli rule pack yok
- `product_domain` bilinmiyor
- `sector=payment-integrated-saas` ama `payment_provider` verilmemiş

**Fix:** Guard mesajını kelime kelime okuyun — hangi check failed olduğu yazar. İlgili argümanı verin ya da boş bir dizin gösterin. Bir sonraki sefer `/ulak-start` ile wizard akışını tercih edin — guard ihlalleri etkileşimli olarak önlenir.

### 5. `validate-imports.sh` döngü (cycle) raporluyor

**Semptom:**

```
ERROR: import cycle detected: A.md -> B.md -> A.md
```

**Tanı:** Yeni bir dosya transitif olarak kendisini import ediyor.

**Fix:** Cycle trace'ini yazdırır; `@`-import'lardan birini (genelde yeni eklenen) çıkarın.

### 6. `manager-verdict.md` `signoff_status: blocked` diyor

**Semptom:** `/director komple` sonunda manager verdict "blocked" diyor.

**Tanı:** Validation plan'da karşılanmamış probe var; Phase 4.5 live-probe gate'i engelliyor.

**Fix:**

1. `reports/current/validation-plan.md` §6'yı (live probes) okuyun
2. Probe komutlarını elle koşturun, `reports/current/live-probe-results.md`'yi güncelleyin
3. Ya da karşılanmamış probe'u "residual risk" olarak açıkça kabul edin
4. `/final-verdict` ile signoff'u yeniden değerlendirin

**Yapmayın:** `signoff_status`'u manuel `ready`'ye çevirmek — audit trail anlamını kaybeder.

### 7. `did-you-know.md` boş veya trivial

**Semptom:** Did-you-know artefaktı 2-3 satır, hepsi operatörün zaten sorduğu şeyi tekrarlıyor.

**Tanı:** Phase 2 evidence-register sığ kaldı — tek generalist agent çalıştı, paralel specialist dispatch yapılmadı.

**Fix:**

```
/director komple agents=security,seo,i18n,infra-release,design-system,data-database,privacy-compliance,release-readiness,backend-api,architecture,red-team
```

Paralel dispatch Claude Code'da tam destekli; Gemini'de PART, Codex/Copilot'ta serial fallback. Gerekirse Claude Code'a geçin.

### 8. Türkçe karakterler bozuk

**Semptom:** Çıktıda `ı, ş, ğ, ç, ö, ü` harfleri `?` veya mojibake.

**Tanı:** Terminal locale UTF-8 değil.

**Fix — Linux/macOS:**

```bash
export LANG=tr_TR.UTF-8
export LC_ALL=tr_TR.UTF-8
```

**Fix — Windows PowerShell:**

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

`/ulak-locale tr` ile çıktı dilini sabitleyin.

### 9. `pattern-import-ledger` CI'da fail

**Semptom:** CI reject: "pattern-import-ledger: missing provenance for AP-NN" ya da "trust tier T3 below minimum T2".

**Fix:** `docs/governance/pattern-import-ledger.md` dosyasına eksik entry ekle (en az T2 + ≥2 kaynak + rationale). `bash scripts/validate-schemas.sh` koştur.

### 10. `plugin.json` schema validation fail

**Fix:** Referans `plugin.json` ile diff al:

```bash
git show origin/main:.claude-plugin/plugin.json > /tmp/reference.json
diff /tmp/reference.json .claude-plugin/plugin.json
```

Eksik alanları ekle.

### 11. Hook commit'i bloke ediyor

**Fix A:** Hata mesajını oku, disiplin ihlalini düzelt.

**Fix B:** Geçici bypass:

```bash
export ULAK_BYPASS_TOKEN=$(ulak bypass --duration 15m --reason "wip debugging")
git commit -m "wip: ..."
```

**Yapmayın:** `--no-verify` — Ulak governance bunu yasaklar; CI yine reddeder.

### 12. `validate-bilingual.sh` CI'da fail (v1.6)

**Semptom:** PR reject: "TR/EN parity delta >30%" veya "missing EN counterpart for <file>".

**Tanı:** TR dosyası güncellendi ama EN karşılığı güncellenmedi (ya da tersi).

**Fix:** EN dosyasını da aynı PR'da güncelle. Heading yapısı ve cross-link'ler iki tarafta da paralel olsun. Detay: [docs/governance/localization-governance.md](../../governance/localization-governance.md).

### 13. `validate-vendor-parity.sh` CI'da fail (v1.6)

**Semptom:** PR reject: "DY-03 vendor-parity silent-drift: /ulak-<new> not in .gemini/commands/".

**Tanı:** Yeni Claude komutu eklendi ama Gemini senkronu yapılmadı.

**Fix:**

```bash
bash scripts/sync-gemini-commands.sh
bash scripts/validate-vendor-parity.sh
```

Gerekirse `.github/vendor-parity-exemptions.txt`'e exemption ekle + [vendor-capability-matrix.md](../../governance/vendor-capability-matrix.md) güncelle.

## Beginner / service setup sorunları (v1.6)

Scaffold ettiniz, `/ulak-next-steps` adımları gösterdi ama bir serviste takıldınız. Aşağıdaki mini-tanılar en sık dört servisi kapsar; her biri için tam tutorial var.

### A. Supabase auth çalışmıyor — "Invalid API key"

**Tanı:** `.env.local`'a `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` yazılmamış ya da yanlış değer.

**Fix:**

1. Supabase dashboard'da Project → Settings → API
2. `URL` ve `anon public` key'i kopyala
3. `.env.local`'a yapıştır (`.env.example` placeholder'ları değiştir)
4. `pnpm dev` restart

Detaylı kurulum: [docs/tutorials/supabase.md](../../tutorials/supabase.md). Terim anlamadıysanız: `/ulak-explain supabase`, `/ulak-explain anon-key`, `/ulak-explain env var`.

### B. Supabase auth çalışmıyor — "User not authorized" (RLS)

**Tanı:** RLS policy'leri aktif ama mevcut user'a SELECT yetkisi yok.

**Fix:** `supabase/migrations/00002_rls_policies.sql`'e bakın. RLS policy'leri customer / admin / public surface başına ayrı tanımlanır. Bir row query'si "not authorized" dönüyorsa o surface için policy eksik veya JWT claim'leri doğru set edilmemiş.

Terim lookup: `/ulak-explain rls`, `/ulak-explain jwt`, `/ulak-explain supabase-auth`.

### C. Vercel deploy fail — "Missing environment variables"

**Tanı:** Vercel dashboard'da production/preview environment'e env var eklenmemiş.

**Fix:**

1. Vercel → Project → Settings → Environment Variables
2. `.env.local`'daki tüm `NEXT_PUBLIC_*` ve server-side env var'ları ekle
3. Environment: `Production`, `Preview`, `Development` için ayrı ayrı belirtilebilir
4. Kayıt sonrası yeni deploy trigger et

**Yaygın tuzak:** `NEXT_PUBLIC_` prefixi client-side'a açık olur — secret'ları **asla** bu prefix ile tanımlama. Server-only key'ler (örn. `SUPABASE_SERVICE_ROLE_KEY`) `NEXT_PUBLIC_` olmadan kayıt.

Detaylı kurulum: [docs/tutorials/vercel.md](../../tutorials/vercel.md).

### D. GitHub push fail — "push declined due to repository rule violations" (secret scanning)

**Tanı:** GitHub push protection bir secret tespit etti (gitleaks pattern eşleşti). `.env.local` veya bir test dosyasında gerçek API key commit edildi.

**Fix:**

1. Secret'ı dosyadan çıkar veya placeholder ile değiştir
2. `git log --all | grep <secret>` ile history'deki varlığını kontrol et
3. History'de varsa rotate et (kullanım dışı bırak) + history rewrite (`git filter-repo` veya BFG) — ikisi de riskli, dikkatli kullan
4. `.gitignore`'a `.env.local` eklendiğinden emin ol
5. Push tekrar dene

Kesinlikle **yapma:** "Allow secret" tıklayarak bypass — secret zaten leak olmuştur, rotate et.

Detaylı kurulum + branch protection: [docs/tutorials/github.md](../../tutorials/github.md). Terim lookup: `/ulak-explain gitleaks`, `/ulak-explain secret-scanning`.

### E. Resend — email gönderilmiyor, "domain not verified"

**Tanı:** Resend panelinde domain DKIM/SPF record'ları DNS'de set edilmemiş ya da propagate olmamış.

**Fix:**

1. Resend → Domains → `<yourdomain.com>` → Verify
2. Verilen DKIM + SPF + Return-Path record'larını DNS sağlayıcınıza (Cloudflare, GoDaddy, vb.) ekle
3. DNS propagation 5-30 dk (`dig TXT _resend._domainkey.<yourdomain>` ile kontrol)
4. Resend panelinde "Verify" butonunu tekrar tıkla
5. Status `Verified` olunca API key aktive olur

Supabase Auth email'lerini Resend'den göndermek için: Supabase → Authentication → Email Templates → SMTP → Resend credentials.

Detaylı kurulum: [docs/tutorials/resend.md](../../tutorials/resend.md).

### F. `pnpm install` hataları

**Tanı:** Node.js sürümü uyumsuz veya lock file corrupted.

**Fix:**

```bash
node --version     # 20.x veya 22.x bekleniyor
pnpm --version     # 9.x veya 10.x
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

Lock file disiplini: [docs/governance/lock-file-hygiene.md](../../governance/lock-file-hygiene.md).

## Hala tıkandınız mı?

- `/ulak-ask <sorunun tarifi>` — en uygun komutu/skill'i önerir
- `/ulak-explain <term>` — bilmediğiniz terimi aç
- [docs/runbooks/troubleshooting.md](../../runbooks/troubleshooting.md) — tam troubleshooting runbook
- [docs/runbooks/install-methods.md](../../runbooks/install-methods.md) — kurulum özelinde sorunlar
- [docs/runbooks/first-hour-with-ulak-os.md](../../runbooks/first-hour-with-ulak-os.md) — ilk saat senaryosu
- [docs/tutorials/](../../tutorials/) — 4 servis (Supabase, Vercel, GitHub, Resend) derinlemesine
- [docs/walkthrough/](../../walkthrough/) — 3 uçtan uca senaryo (Claude / Codex / Copilot variant)

Hâlâ çözülemiyorsa:

1. `ulak doctor` çıktısını kopyalayın
2. https://github.com/osrt91/ulak-os/issues altında yeni issue açın
3. Issue'da: beklenen davranış, gerçek davranış, `ulak doctor` çıktısı, reproduction steps, vendor (Claude/Gemini/Codex/Copilot)

Güvenlik açıkları için public issue AÇMAYIN — bkz. [07-Katkı](./07-katki.md) "Security issue bildirme" bölümü.

Sonraki bölüm: [09 — SSS](./09-sss.md)
