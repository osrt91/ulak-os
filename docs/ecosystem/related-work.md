# Ulak OS Ekosistemi & İlgili Çalışmalar

Türkçe | [English](related-work.en.md)

Ulak OS, kendisini izole bir ürün olarak değil, bir **ekosistemin parçası** olarak görür. Bu doküman doğrudan ilham aldığımız, beraber kullanılabilir veya tamamlayıcı olarak değerlendirdiğimiz public projeleri listeler.

## Public skill / agent çerçeveleri

### [obra/superpowers](https://github.com/obra/superpowers)
Agentic skill çerçevesi. Brainstorming, TDD, debugging, plan writing/execution gibi 15+ skill içerir. Ulak OS'un artefakt zinciri ile doğrudan eşleşir; mapping detayları için [`docs/skills-integration/superpowers-mapping.md`](../skills-integration/superpowers-mapping.md).

### [anthropics/skills](https://github.com/anthropics/skills)
Anthropic'in resmi Agent Skills public deposu. Claude Code skill ekosisteminin upstream noktası. superpowers ve diğer marketplace'lere temel oluşturur.

### [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
Claude Code skill, plugin, agent ve komut'larının curated listesi. "Daha fazla ne var?" sorusunun cevabı.

## Spec-driven & meta-prompting sistemleri

### [gsd-build/gsd-2](https://github.com/gsd-build/gsd-2)
Meta-prompting ve spec-driven development sistemi. Ulak OS'un felsefesine en yakın "related work" — ikisi de spec → plan → execute zincirine inanır. Farklı tool çağırma desenleri kullanır ama aynı problem alanını çözer.

### [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates)
Claude Code konfigürasyon CLI'ı. Bizim init scriptlerimizin alternatif bir desen örneği. "How others bootstrap Claude Code" referansı.

## Tasarım sistemleri

### [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)
58+ markanın DESIGN.md dosyaları (Stripe, Linear, Vercel, Notion, Tesla, vb.). Ulak OS'un frontend ajanları bu dosyaları kanıt-tabanlı tasarım kararları için kullanır. Entegrasyon detayları: [`docs/skills-integration/awesome-design-md-integration.md`](../skills-integration/awesome-design-md-integration.md)

## Cross-vendor plugin pattern referansı

### [akin-ozer/devops-skills-plugin](https://github.com/akin-ozer/cc-devops-skills)
Aynı `skills/` dizinini hem `.claude-plugin/plugin.json` hem `.codex-plugin/plugin.json` ile yayınlayan plugin. Ulak OS'un gelecek plugin marketplace yayını için **doğrudan referans olacak** cross-vendor manifest deseni.

## Araştırma adayları (future evaluation)

Aşağıdaki projeler Ulak OS'un gelecek sürümlerinde değerlendirilecek; şu an ship edilmedi ama izlenecek:

- **firecrawl/firecrawl** — Web scraping API, `research-currency` skill için
- **HKUDS/LightRAG** — RAG knowledge base, proje bilgi tabanı için
- **googleapis/genai-toolbox** — MCP database server
- **magicuidesign/magicui** — UI bileşen kütüphanesi
- **agentscope-ai/agentscope** — Agent framework alt katmanı
- **msitarzewski/agency-agents** — Specialized agents agency desenleri
- **nextlevelbuilder/ui-ux-pro-max-skill** — UI/UX skill superpowers desenine
- **affaan-m/everything-claude-code** — Agent performance optimization

Detaylı roadmap: [`ROADMAP.md`](../../ROADMAP.md)

## Felsefi yakınlıklar

Ulak OS bu ekosistemden **şunları öğrendi**:
- **Skill > prompt** ayrımı (superpowers, anthropics/skills)
- **Spec → plan → execute** disiplini (gsd-2, superpowers/writing-plans)
- **Vendor-neutral adapter** deseni (hibrit çekirdek + üç wrapper)
- **Public artefakt + private execution** (manage-by-evidence)
- **Kanıt-tabanlı tasarım** (awesome-design-md)
- **Curated reusability** (awesome-claude-code, awesome-design-md)
- **Cross-vendor plugin manifest** deseni (akin-ozer/devops-skills-plugin)

Ulak OS bu öğrenmeleri bir **artefakt zinciri** + **rule collision matrix** + **three-vendor adapter** ile birleştirir.
