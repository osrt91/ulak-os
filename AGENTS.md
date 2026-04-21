# Ulak OS Agent Instructions

Bu depo, büyük yazılım projelerini audit etmek, yeniden yapılandırmak, pack üretmek ve kontrollü icra planı çıkarmak için tasarlanmış bir operating system deposudur.

## Reading order

### Çekirdek (her oturumda oku)
1. README.md
2. docs/adapters/universal-runtime-contract.md
3. docs/adapters/codex-cli.md
4. prompts/core/ulak-os-core-contract-2.0.0.md

### Runtime discipline (v2.1) — derin ve çakıldıkça oku
5. docs/runtime/router.md
6. docs/runtime/program-phases.md
7. docs/runtime/artefact-contract.md
8. docs/runtime/output-profiles.md
9. docs/runtime/context-budget.md
10. docs/runtime/active-variable-contract.md
11. docs/runtime/validation-result-schema.md
12. docs/runtime/universal-surface-inventory.md
13. docs/runtime/analysis-contexts.md
14. docs/runtime/roadmap-rule.md
15. docs/runtime/anti-patterns.md

### Operational motors (sadece ilgili görev geldiyse)
16. docs/runtime/toolchain-precheck.md
17. docs/runtime/intake-protocol.md
18. docs/runtime/architecture-currency.md
19. docs/runtime/localization-strategy.md
20. docs/runtime/turkish-normalization.md
21. docs/runtime/market-research-engine.md
22. docs/runtime/sector-packs.md

### Governance
23. docs/governance/evidence-trust-scoring.md
24. docs/governance/finding-schema.md
25. docs/governance/trust-model.md
26. docs/governance/surface-split.md
27. docs/governance/hook-governance.md
28. docs/governance/mcp-governance.md
29. docs/governance/memory-hygiene.md
30. docs/governance/prompt-supply-chain.md
31. docs/governance/plugin-skill-decision.md
32. docs/governance/rule-collision-matrix.md
33. docs/governance/vendor-capability-matrix.md

### Run state
34. reports/current/* — geçerli oturumun artefaktları (varsa)

## Required behavior
- User intent açıkça `komple`, `full`, `complete`, `uçtan uca`, `baştan sona`, `kur`, `düzelt` ise scope menüsünü tekrar tekrar açma.
- Phase 0 → Phase 5 protokolünü tek pass'te yürüt; her phase için artefakt yaz.
- Inventory sığ olmasın — file:line citations ile derin tarama.
- Phase 2'de uygun tüm uzmanları tek mesajda paralel dispatch et.
- Phase 3 (did-you-know) zorunlu — non-obvious findings olmadan run done değil.
- Customer, admin ve public API yüzeylerini ayrı değerlendir.
- Quick win ile strategic migration'ı karıştırma.
- Her finding `docs/governance/finding-schema.md` formatında olsun ve `docs/governance/evidence-trust-scoring.md` tier'ı taşısın.
- Validation ve residual risk yazmadan işi bitmiş sayma.

## Required artefacts (full chain — v2.1.0 aligned)

### Phase 0 — Environment lock
- reports/current/runtime-manifest.md
- reports/current/assumptions.md

### Phase 1 — Deep inventory
- reports/current/intake.md
- reports/current/inventory.md

### Phase 2 — Parallel specialist evidence
- reports/current/evidence-register.md
- reports/current/deep-scan-report.md
- reports/current/research-notes.md (live research gerekirse)

### Phase 3 — Surprise layer (MANDATORY)
- reports/current/did-you-know.md

### Phase 4 — Synthesis
- reports/current/analysis-findings.md
- reports/current/target-state.md
- reports/current/execution-roadmap.md
- reports/current/validation-plan.md
- reports/current/pack-gap-register.md

### Phase 5 — Final verdict
- reports/current/manager-verdict.md
- reports/current/validation-result.yaml (or block inside manager-verdict.md)

## Adapter note
Bu repo Claude, Codex/Copilot ve Gemini için ortak çekirdeği taşır. Bu yüzden mümkünse `CLAUDE.md` ve `GEMINI.md` dosyalarındaki intent ile uyumlu kal.

## Natural-Language Trigger Map (Codex / non-slash vendors)

Codex CLI `/slash` dispatch'ini desteklemez (Claude Code ve Gemini desteklerken). Aynı 24 Ulak OS kapasitesine doğal dil ile erişim zorunludur: kullanıcı aşağıdaki ifadelerden birini yazarsa, belirtilen slash komutunun protokolünü **aynen** uygula. İlgili `.claude/commands/<name>.md` dosyasını oku, template'i render et, artefakt gerekiyorsa `reports/current/**` altına yaz.

### Conversion principles
- **NL trigger** = kullanıcının yazdığı doğal dil cümlesi (TR veya EN).
- **Protocol** = `.claude/commands/<name>.md` içindeki flow'u aynen uygula.
- **Inline render** = artefakt yazmadan chat içinde göster (ör. `/ulak-hello`, `/ulak-packs`).
- **Artefakt write** = `reports/current/**` altına md dosyası üret (ör. `/director komple`, `/ulak-intake`, `/ulak-audit-deep`).
- **Chain** = ardışık komut zinciri; kullanıcıya onay sormadan sıradakine geçme, wizard sonunda onay sor.
- **Codex primitive eksikse** (ör. paralel subagent dispatch): sıralı iterasyon ile simüle et ve residual-risk notu düş.

### Trigger map (24 komut)

#### Selamlama / Giriş
- "selam ulak" / "merhaba ulak" / "hi ulak" / "hello ulak" / "tanıt kendini" / "what is ulak" → `/ulak-hello` protokolü (inline render, 30-sn tour, son menü sorusu kullanıcıya). Template kaynağı: `.claude/commands/ulak-hello.md`.

#### Yeni SaaS oluşturma (core flow)
- "ulak start" / "yeni saas" / "yeni proje" / "start ulak" / "begin saas" / "saas yapmak istiyorum" / "start new saas" / "yeni site yapmak istiyorum" → `/ulak-start` protokolü (inline wizard, 27 soru 5 faza bölünür, her faz başında başlık render et; özet ekranı sonrasında kullanıcı `e` veya `[enter]` derse `/ulak-scaffold` zincirle).
- "scaffold et" / "materialize et" / "scaffold now" / "generate project" / "projeyi üret" → `/ulak-scaffold` protokolü (Bash ile `ulak scaffold <flags>` çalıştır; 284 template materialize; saas-scaffolder skill tetiklenir).
- "scaffold bitti şimdi ne" / "next steps" / "ne yapayım şimdi" / "what now" / "post-scaffold runbook" / "şimdi nasıl çalıştırırım" → `/ulak-next-steps` protokolü (kişisel runbook render — 12 adım + tutorial linkleri + env key listesi).

#### Audit / Müdahale (Program Director)
- "audit" / "komple tarama" / "director komple" / "full audit" / "baştan sona" / "uçtan uca tarama" / "run director" / "deep scan" → `/director komple` protokolü (Phase 0→5 tam artefakt zinciri; Codex tek-agent olduğundan Phase 2 **sıralı uzman geçişi** olarak yür, her uzman için `reports/current/specialists/<role>.md` dosyası üret; paralel dispatch residual-risk olarak kaydet).
- "sadece intake" / "intake çalıştır" / "read the repo" / "önce tanı" / "ulak intake" → `/ulak-intake` veya `/intake` protokolü (Phase 0-1 artefaktı: `runtime-manifest.md`, `assumptions.md`, `intake.md`, `inventory.md`).
- "14 boyutlu audit" / "deep audit" / "kalite skoru" / "quality scorecard" / "fourteen dimension" / "health check" → `/ulak-audit-deep` protokolü (14-dimension skill; A-F grade + target-state + gap analysis).
- "final verdict" / "son karar" / "re-evaluate" / "signoff yenile" / "verdict update" → `/final-verdict` protokolü (mevcut `reports/current/` artefaktlarını re-eval et, yeni `manager-verdict.md` yaz).
- "frontend war room" / "redesign" / "premium ui" / "ui elden geçir" / "visual system cleanup" → `/frontend-war-room` protokolü (design-system + frontend uzman dispatch).
- "build kırık" / "build broken" / "ci red" / "triage build" / "build hatası" → `/triage-build` protokolü (toolchain-precheck → stack-spesifik tanı).
- "pack gap" / "eksik pack" / "missing skill" / "gap analysis" / "hangi skill eksik" → `/pack-gap-audit` protokolü (pack-gap-completion skill).

#### Doğal dil yönlendirme / Arama
- "ulak'a sor" / "natural query" / "<soru>" / "help me with X" / "ulak ask" → `/ulak-ask` protokolü (ulak-ask skill; disambiguation + komut öner).
- "tüm kapasiteler" / "ne yapabilir" / "list all" / "show catalog" / "katalog göster" / "all commands" → `/ulak-packs` protokolü (`docs/catalog.md` inline render).
- "ara X" / "find X" / "ulak search <kw>" / "<keyword> ara" / "search catalog" → `/ulak-search` protokolü (keyword arama, birleşik sonuç).
- "örnek göster" / "show examples" / "demo" / "3 örnek saas" / "sample projects" → `/ulak-demo` protokolü (3 örnek SaaS inline render).
- "ne demek X" / "what is X" / "açıkla X" / "explain term" / "glossary X" → `/ulak-explain` protokolü (beginner-glossary 5-alanlı şema render).
- "dil değiştir" / "locale tr" / "switch to english" / "toggle language" / "set locale" → `/ulak-locale` protokolü (`.claude/state/locale.txt` güncelle).

#### İleri seviye / Research
- "brainstorm" / "fikir üret" / "ideation" / "koda dokunmadan önce" / "explore idea" → `/ulak-brainstorm` protokolü (superpowers:brainstorming + `docs/superpowers/specs/<date>-<topic>.md` yaz).
- "tasarım referansı" / "design reference" / "awesome-design-md fetch" / "fetch design brief" → `/ulak-design-ref` protokolü (public marka md fetch + frontend agents'e ilet).
- "pattern çıkar" / "extract pattern" / "pattern ledger" / "bu kod pattern olur mu" → `/ulak-pattern-extract` protokolü (pattern-import-ledger T1/T2 evidence ile yaz).
- "tdd yap" / "test-driven" / "önce test yaz" / "tdd workflow" → `/ulak-test-driven` protokolü (superpowers:test-driven-development).
- "mcp server keşfet" / "find mcp" / "discover mcp" / "yeni mcp öner" → `/ulak-mcp-discover` protokolü (public registry + governance kapısı).
- "paralel dispatch" / "parallel subagent" / "çoklu ajan" / "n subagent" → `/ulak-subagent-dispatch` protokolü. **Codex note**: paralel primitive yok; sıralı iterasyon olarak uygula, her subagent brief'ini sıralı yaz + çıktıları manual merge et, residual-risk olarak kaydet.

### Codex primitive matrix
Aşağıdakiler Codex tarafında mevcuttur: `Read`, `Write`, `Edit`, `Bash`, uzun kod bağlamı, tek-oturum state.
Aşağıdakiler Codex tarafında **yoktur**: slash dispatch, paralel subagent Task tool, hook subsystem, MCP native call (vendor-spesifik). Bu eksikler için workaround'lar `docs/adapters/codex-cli.md` içinde listelenir.

### Fallback
Listede yoksa: `/ulak-ask` protokolünü uygula — kullanıcı intent'ini ulak-ask skill ile en yakın komuta yönlendir, belirsizse "did you mean?" disambiguation yap.
