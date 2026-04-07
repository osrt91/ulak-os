# Claude Ulak

**Claude Ulak 1.9.1**; çok büyük yazılım projelerini tek noktadan yöneten, gerektiğinde hibrit ajan ofisi açan, repo bağlamını okuyup artefakt üreten, güvenlik/UX/operasyon/dağıtım katmanlarını birlikte ele alan bir **Prompt Operating System + repo dağıtım paketi**dir.

Bu repo, tek bir dev prompt dosyasından fazlasıdır. Amaç:
- sıfırdan proje kurmak,
- mevcut projeye ortadan veya final aşamasından girmek,
- audit, research, context write, plan, pack, validation ve signoff zincirini tek sistemde toplamak,
- Claude Code, Codex/Copilot ve Gemini CLI için ayrı adaptör yüzeyleri sağlamak.

## Bu sürüm neden önemli?
Bu repo, önceki iç sürümlerde oluşan V8/V9/V10.* evrimini tek bir **yayınlanabilir** çizgiye indirger. Dışarıya gösterilen sürüm serisi artık `1.x` olarak tutulur. İç kod adları ve eski dosyalar `docs/archive/internal-releases/` altında korunur.

## Hızlı başlangıç

### Claude Code
1. Bu repoyu aç.
2. Claude Code içinde `/memory` ile `CLAUDE.md` dosyasının yüklendiğini doğrula.
3. İhtiyaca göre şu komutlardan biriyle başla:
   - `/director komple`
   - `/intake <hedef>`
   - `/frontend-war-room <ekran veya akış>`
   - `/pack-gap-audit`
   - `/final-verdict`

### Codex / Copilot / OpenAI Codex entegrasyonları
1. Repoyu git altında tut.
2. Kök dizindeki `AGENTS.md` dosyasını ana agent talimatı olarak kullan.
3. GitHub/Copilot ortamlarında ek repo talimatları için `.github/copilot-instructions.md` dosyası da hazır.
4. İlk istekte agent’a şunu söyle:
   - `Read AGENTS.md, CLAUDE.md, docs/adapters/codex-cli.md and docs/adapters/universal-runtime-contract.md, then run the appropriate program mode.`

### Gemini CLI
1. Repoyu aç.
2. `/memory reload` çalıştır.
3. `/commands reload` ile `.gemini/commands/*.toml` komutlarını yükle.
4. Başlangıç komutları:
   - `/director komple`
   - `/market-scan kategori veya rakip`
   - `/frontend:war-room belirli ekran`
   - `/final-verdict`

## Repo içeriği
- `CLAUDE.md` → Claude Code adaptörü
- `AGENTS.md` → Codex/Copilot uyumlu agent talimatları
- `GEMINI.md` → Gemini CLI proje bağlamı
- `.claude/` → Claude Code komutları, ajanları, skill’leri, ayarlar
- `.gemini/commands/` → Gemini CLI özel komutları
- `docs/adapters/` → platforma özel kullanım kılavuzları
- `docs/history/` → sürüm soyağacı ve dış/iç sürüm eşlemesi
- `docs/archive/internal-releases/` → eski iç sürümlerin kanonik kopyaları
- `prompts/core/` → vendor-agnostic çekirdek sözleşme
- `reports/current/` → runtime sırasında doldurulan artefaktlar
- `evals/` → golden prompt ve assertion taslakları

## Dağıtım görüşü
Bu sistemin **ayrı ayrı kopyalanmış üç prompt** olarak yaşaması doğru değil. Doğru model:
- **tek çekirdek sözleşme**,
- **ayrı vendor adaptörleri**,
- **aynı sürüm numarası**,
- **tek changelog**,
- **tek release notu**.

## Ne zaman 2.0.0?
Bu repo için öneri: `2.0.0` ancak aşağıdakiler gerçek projelerde doğrulandıktan sonra çıksın:
- en az 3 ayrı repoda pilot koşu,
- Claude/Codex/Gemini üzerinde adapter doğrulaması,
- eval regresyon seti,
- GitHub dağıtım akışı ve yayın notları,
- minimum bir CI/validation standardı.

Şu anki doğru yayın etiketi: **1.9.1 — Claude Ulak Distribution Parity Patch**.


## Eşit sürüm dağıtımı
`releases/` dizini altında 1.0.0–1.9.1 arasındaki tüm public sürümler aynı klasör yapısıyla taşınır.
