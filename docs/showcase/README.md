# Ulak OS in Action — Showcase Tour

This directory walks through Ulak OS on representative runs. Every example uses a **fictional operator persona called "ExampleCorp"** — a generic SaaS operator with a small portfolio of Turkish-first products. No real portfolio project names appear in these walkthroughs; the examples exist to demonstrate the protocol, not to advertise the author.

Estimated reading time: **35-45 minutes** for all four walkthroughs. The video script at the bottom of this list gives you the 5-minute tour instead.

## English

### When to read these

- You cloned Ulak OS and want to see what a run actually produces before invoking `/director` yourself
- You are evaluating whether the protocol is worth adopting for your own team
- You are writing a new sector pack / rule pack / anti-pattern and want examples of how they materialize in artefacts
- You need to demo Ulak OS to a stakeholder and want a reference script

### The four walkthroughs

1. **[01-audit-walkthrough.md](./01-audit-walkthrough.md)** — `/director komple` on a brownfield ExampleCorp SaaS. Watch the six-phase protocol run: Phase 0 runtime-manifest, Phase 1 deep inventory, Phase 2 parallel specialist evidence (security + data + architecture), Phase 3 did-you-know with five non-obvious findings, Phase 4 synthesis, Phase 5 manager verdict with `conditional` signoff. ~150 lines. **Best for**: first-time readers who want end-to-end visibility.

2. **[02-scaffold-walkthrough.md](./02-scaffold-walkthrough.md)** — `/ulak-scaffold` for a greenfield payment-integrated SaaS. See the prompt dialog, the template resolution, the output directory tree, the first commit message, the post-scaffold checklist. ~120 lines. **Best for**: operators about to start a new product.

3. **[03-persona-audit.md](./03-persona-audit.md)** — `/director dispatch=persona` with four personas (customer, admin, bayi/partner, support). See how the same repo looks different through each persona's lens, how findings merge in the evidence-register, and how contradictions become explicit residual risks instead of silently winning. ~130 lines. **Best for**: multi-tenant SaaS teams evaluating end-to-end UX discipline.

4. **[04-cross-project-absorption.md](./04-cross-project-absorption.md)** — Pattern extraction from one ExampleCorp product (AcmeBuilder) importing into another (BetaStore). Shows the `pattern-import-ledger.yaml` entry format, evidence tier, divergence notes. ~100 lines. **Best for**: portfolio operators maintaining multiple Ulak-governed projects.

### Video script

- **[video-script.md](./video-script.md)** — 5-minute screenplay with three scenes (audit, scaffold, persona). Terminal commands, TR + EN voiceover, visual focus notes, duration per section. **Best for**: recording a quick demo for a talk, a landing page, or internal training.

## Türkçe

### Ne zaman okunur

- Ulak OS'u kloplayıp `/director`'u çalıştırmadan önce ne üretiyor görmek istiyorsanız
- Kendi ekibinize getirmeyi değerlendirirken örnek koşu çıktılarına bakmak istiyorsanız
- Yeni bir sector pack / rule pack / anti-pattern yazarken artefaktlarda nasıl görüneceğini merak ediyorsanız
- Bir paydaşa Ulak OS'u göstereceğiniz zaman referans senaryo lazımsa

### Dört walkthrough

1. **[01-audit-walkthrough.md](./01-audit-walkthrough.md)** — Brownfield ExampleCorp SaaS üzerinde `/director komple`. Altı fazlı protokolü sonuna kadar izleyin: runtime-manifest, deep inventory, paralel specialist evidence, did-you-know, synthesis, manager-verdict.
2. **[02-scaffold-walkthrough.md](./02-scaffold-walkthrough.md)** — Greenfield ödeme-entegre bir SaaS için `/ulak-scaffold`. Prompt dialog, template çözümü, çıktı dizin ağacı, ilk commit mesajı, post-scaffold checklist.
3. **[03-persona-audit.md](./03-persona-audit.md)** — Dört persona (customer, admin, bayi/partner, support) ile `/director dispatch=persona`. Aynı repo'nun her persona lensinden nasıl farklı göründüğü, bulguların nasıl birleştiği, çelişkilerin residual risk olarak nasıl görünür kılındığı.
4. **[04-cross-project-absorption.md](./04-cross-project-absorption.md)** — Bir ExampleCorp üründen (AcmeBuilder) diğerine (BetaStore) pattern çıkarma. `pattern-import-ledger.yaml` girdi formatı, evidence tier'ı, divergence notları.

### Video script

- **[video-script.md](./video-script.md)** — 5 dakikalık, üç sahneli (audit, scaffold, persona) screenplay. Terminal komutları, TR + EN voiceover, görsel odak notları.

## Redaction discipline

All walkthroughs use **ExampleCorp** / **AcmeBuilder** / **BetaStore** abstract names and generic file paths (`src/app/...`, `infrastructure/...`). No real operator portfolio project is named. The CONTRIBUTING.md §redaction discipline section has the good/bad example pairs — these walkthroughs are the canonical application of that discipline.

If you submit a new walkthrough, use the same abstraction level. PRs with real project names will be asked to re-abstract.

## Canonical footer

Authoritative as of Ulak OS **v2.4.1** (Phase 3.0-B).
