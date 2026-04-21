# 08 — Sorun giderme

Bu bölüm 10 yaygın hatanın semptom → tanı → fix formatında özetini içerir. Tam sorun giderme dökümantasyonu için: [docs/runbooks/troubleshooting.md](../../runbooks/troubleshooting.md).

## 1. `/director` komutu tanınmıyor

**Semptom:** Claude Code `/director` yazdığınızda "command not found" diyor ya da öneriler arasında komut görünmüyor.

**Tanı:** `.claude/commands/director.md` mevcut projeden erişilemiyor. İki ihtimal: (a) Claude Code yanlış dizinden açıldı, (b) `CLAUDE.md`'deki `@`-import kırık.

**Fix:**

```bash
pwd                                        # CLAUDE.md'nin olduğu kök olmalı
ls .claude/commands/ 2>/dev/null           # 9 .md dosyası görmelisiniz
```

Eğer `.claude/commands/` yoksa:

```bash
ulak init .                                # @-import bağlar; komutlar kurulum dizininden gelir
# Ya da Claude Code'u doğrudan kurulum dizininden aç:
cd ~/.ulak-os && claude
```

## 2. `@`-import kırık

**Semptom:** `validate-imports.sh` "file not found" diyor, ya da Claude Code context'inde beklediğiniz dosya yok.

**Tanı:** Göreceli bir `@`-import yolu, yeniden adlandırılmış veya taşınmış bir dosyayı işaret ediyor.

**Fix:**

```bash
bash scripts/validate-imports.sh           # hatalı satırı listeler
# Hata mesajındaki kırık yolu grep'leyin:
```

Dosya hangi yerde `@docs/.../moved-or-renamed` yazılmışsa, hepsini yeni yola güncelleyin, ardından tekrar validator koşun.

Eğer dışarıdaki bir dosyayı işaret ediyorsa (örn. consumer projenin `CLAUDE.md`'sinde absolute path) — validator bunu skip etmeli; etmiyorsa validator bug'ıdır, issue açın.

## 3. Scaffolder koşmayı reddediyor

**Semptom:** `/ulak-scaffold` Phase 0'da guard rejection ile duruyor.

**Tanı:** Scaffolder'ın Phase 0 guard'ı aşağıdakilerden birini reddetti:

- Hedef dizin boş değil
- İstenen stack için gerekli rule pack yok
- `product_domain` bilinmiyor (sector pack slug'larından biri olmalı)
- `sector=payment-integrated-saas` ama `payment_provider` verilmemiş

**Fix:** Guard mesajını kelime kelime okuyun — hangi check failed olduğu yazar. İlgili argümanı verin ya da boş bir dizin gösterin.

## 4. `validate-imports.sh` döngü (cycle) raporluyor

**Semptom:**

```
ERROR: import cycle detected: A.md -> B.md -> A.md
```

**Tanı:** Yeni bir dosya transitif olarak kendisini import ediyor.

**Fix:** Validator cycle trace'ini yazdırır. Döngüyü kırmak için `@`-import'lardan birini (genelde yeni eklenen) çıkarın. Cycle sessizce tolere edilmez — unbounded context büyümesi yaratır.

## 5. `manager-verdict.md` `signoff_status: blocked` diyor

**Semptom:** `/director komple` sonunda manager verdict "blocked" diyerek ready demiyor.

**Tanı:** Validation plan'da karşılanmamış probe var. Phase 4.5 live-probe gate'i bilinçli olarak bunu engelliyor (bkz. [docs/runtime/live-probe-contract.md](../../runtime/live-probe-contract.md)).

**Fix:**

1. `reports/current/validation-plan.md` §6'yı (live probes) okuyun
2. Probe komutlarını elle koşturun, `reports/current/live-probe-results.md`'yi güncelleyin
3. Ya da her karşılanmamış probe'u "residual risk" olarak açıkça kabul edin ve `manager-verdict.md`'yi rationale ile güncelleyin
4. `/final-verdict` ile signoff'u yeniden değerlendirin

**Yapmayın:** `signoff_status`'u manuel `ready`'ye çevirmek. Tüm audit trail anlamını kaybeder.

## 6. `did-you-know.md` boş veya trivial

**Semptom:** Did-you-know artefaktı 2-3 satır, hepsi operatörün zaten sorduğu şeyi tekrarlıyor.

**Tanı:** Phase 2 evidence-register sığ kaldı — tek generalist agent çalıştı, paralel specialist dispatch yapılmadı.

**Fix:** Director'ı daha geniş agent dispatch ile re-run edin:

```
/director komple agents=security,seo,i18n,infra-release,design-system,data-database,privacy-compliance,release-readiness,backend-api,architecture,red-team
```

Sonra `reports/current/evidence-register.md` dosyasında ≥10 specialist finding olduğunu ve her birinin T1–T7 trust tier taşıdığını doğrulayın. Did-you-know layer bunun üstünden tekrar non-obvious findings çıkarır.

## 7. Türkçe karakterler bozuk

**Semptom:** Çıktıda `ı, ş, ğ, ç, ö, ü` harfleri `?` veya mojibake olarak görünüyor.

**Tanı:** Terminal locale UTF-8 değil ya da editörün encoding'i farklı.

**Fix:**

Linux / macOS:

```bash
locale                                     # en_US.UTF-8 veya tr_TR.UTF-8 görmelisiniz
export LANG=tr_TR.UTF-8
export LC_ALL=tr_TR.UTF-8
```

Windows PowerShell:

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

`.claude/settings.json` içinde zorunlu değil ama `output_language: tr` eklenmesi çıktı diline etki eder. Artefakt dosyaları zaten UTF-8 yazılır; problem neredeyse her zaman terminal konfigürasyonundadır.

## 8. `pattern-import-ledger` CI'da fail

**Semptom:** CI job bir PR'ı şu mesajla reddediyor:

```
pattern-import-ledger: missing provenance for AP-NN
# ya da: trust tier T3 below minimum T2
```

**Tanı:** PR'ınız bir anti-pattern veya sector pack eklemiş ama ledger entry yok, ya da entry'nin trust tier'ı T2'nin altında.

**Fix:** `docs/governance/pattern-import-ledger.md` dosyasını açın, eksik entry'yi ekleyin:

```yaml
- id: AP-NN
  source_projects:
    - descriptor: "abstract descriptor 1"
    - descriptor: "abstract descriptor 2"
  source_files:
    - path/to/file.ts:45-62
  trust_tier: T2                             # en az T2
  rationale: |
    Kısa açıklama.
```

Ardından:

```bash
bash scripts/validate-schemas.sh
git add docs/governance/pattern-import-ledger.md
git commit -m "chore(patterns): add ledger entry for AP-NN"
git push
```

## 9. `plugin.json` schema validation fail

**Semptom:** `validate-schemas.sh` `.claude-plugin/plugin.json` dosyasını flagliyor.

**Tanı:** v1.0.0 categories bump'ından sonra `plugin.json` ek alanlar gerektirir (`categories`, `license`, `keywords`).

**Fix:** Main branch'teki referans `plugin.json` ile karşılaştırın:

```bash
git show origin/main:.claude-plugin/plugin.json > /tmp/reference.json
diff /tmp/reference.json .claude-plugin/plugin.json
```

Eksik alanları ekleyin, ardından:

```bash
bash scripts/validate-schemas.sh
```

## 10. Hook commit'i bloke ediyor

**Semptom:** `git commit` çalışmıyor, pre-commit hook bir Ulak OS disiplin check'inde reddediyor.

**Tanı:** Ulak OS hook'ları reports/current/ altındaki finding-schema YAML'ı geçerli değilse veya lock file disiplin bozulmuşsa commit'i reddeder.

**Fix:**

Option A — **disiplin ihlalini düzelt** (tercih edilen yol):

- Hata mesajı hangi dosyayı ve neden reddettiğini yazar. Düzeltin ve tekrar commit edin.

Option B — **geçici bypass token ile devam et**:

```bash
export ULAK_BYPASS_TOKEN=$(ulak bypass --duration 15m --reason "wip debugging")
git commit -m "wip: ..."
```

Token'lar audit log'a düşer. Production branch'e merge sırasında bypass sayısı checked olur (bkz. [hook-governance.md](../../governance/hook-governance.md)).

**Yapmayın:** Hook'u `--no-verify` ile atlatmak — Ulak OS governance disiplini bunu açıkça yasaklar; CI yine reddeder.

## Hala tıkandınız mı?

Bu liste 10 yaygın durumu kapsar. Daha fazla örnek ve derin tanı için:

- [docs/runbooks/troubleshooting.md](../../runbooks/troubleshooting.md) — tam sorun giderme runbook'u (11+ ek case)
- [docs/runbooks/install-methods.md](../../runbooks/install-methods.md) — kurulum özelinde sorunlar
- [docs/runbooks/first-hour-with-ulak-os.md](../../runbooks/first-hour-with-ulak-os.md) — ilk saat senaryosu

Daha hala çözülemiyorsa:

1. `ulak doctor` çıktısını kopyalayın
2. https://github.com/osrt91/ulak-os/issues altında yeni issue açın
3. Issue'da: beklenen davranış, gerçek davranış, `ulak doctor` çıktısı, reproduction steps

Güvenlik açıkları için public issue AÇMAYIN — bkz. [07-Katkı](./07-katki.md) "Security issue bildirme" bölümü.

Sonraki bölüm: [09 — SSS](./09-sss.md)
