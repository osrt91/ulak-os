# YÃ¼klÃ¼ Plugin ve Skill Ekosistemi

TÃ¼rkÃ§e | [English](installed-plugins.en.md)

Bu dokÃ¼man, Ulak OS ile birlikte kullanÄ±labilecek yÃ¼klÃ¼ plugin ve skill'leri listeler.

## Marketplace'ler

| Marketplace | Kaynak |
|------------|--------|
| claude-plugins-official | Anthropic resmi plugin deposu |
| superpowers-marketplace | obra/superpowers topluluk marketplace |

## YÃ¼klÃ¼ Pluginler

### Superpowers (v5.0.7)
Ana workflow skill paketi. Ulak OS artefakt zinciriyle eÅŸleÅŸtirmesi iÃ§in bkz: [superpowers-mapping.md](superpowers-mapping.md)

### context7
KÃ¼tÃ¼phane/framework dokÃ¼mantasyonunu Ã§eker. API syntax, config, versiyon migration, CLI kullanÄ±mÄ± iÃ§in web aramasÄ±ndan daha gÃ¼venilir.

### code-review
Pull request kod review skill'i. `superpowers:requesting-code-review` ve `superpowers:receiving-code-review` ile birlikte Ã§alÄ±ÅŸÄ±r.

### frontend-design
Ãœretim kalitesinde frontend arayÃ¼z tasarÄ±mÄ±. Generic AI estetiÄŸinden kaÃ§Ä±nan, yaratÄ±cÄ± ve cilalanmÄ±ÅŸ kod Ã¼retir.

### typescript-lsp (v1.0.0)
TypeScript Language Server Protocol entegrasyonu. Tip kontrolÃ¼, otomatik tamamlama ve refactoring desteÄŸi.

### skill-creator
Yeni skill oluÅŸturma, mevcut skill'leri dÃ¼zenleme ve performans Ã¶lÃ§Ã¼mÃ¼. Skill evals ve benchmark desteÄŸi.

### claude-md-management (v1.0.0)
CLAUDE.md dosyalarÄ±nÄ± denetleme ve iyileÅŸtirme. Kalite raporu Ã¼retir, ÅŸablona gÃ¶re gÃ¼nceller.

### supabase
Supabase entegrasyonu. VeritabanÄ±, auth, storage ve edge function yÃ¶netimi.

## Ortak KullanÄ±m Stack'i

Projelerde tekrar eden teknoloji deseni:

| Katman | Teknoloji |
|--------|-----------|
| Frontend | Next.js 15-16, React 19, TypeScript |
| Styling | Tailwind CSS 4, shadcn/ui |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| State | Zustand 5 |
| Validation | Zod 3-4 |
| Animation | Framer Motion |
| Test | Playwright E2E, Vitest |
| Deploy | PM2, Docker, Traefik |
| MCP | [removed-mcp] ([eski-vps] API) |
| Mobile | Capacitor / Expo (proje bazlÄ±) |

## Plugin â†” Ulak OS EÅŸleÅŸtirmesi

| Plugin | Ulak OS kullanÄ±mÄ± |
|--------|-------------------|
| superpowers | Artefakt zinciri workflow'u (brainstorming â†’ plan â†’ execute â†’ validate) |
| context7 | `research-notes` artefaktÄ± iÃ§in gÃ¼ncel dokÃ¼mantasyon Ã§ekme |
| code-review | `validation-plan` artefaktÄ± sonrasÄ± kod kalite kontrolÃ¼ |
| frontend-design | `/frontend-war-room` komutuyla birlikte UI implementasyonu |
| typescript-lsp | `ulak validate` CLI komutunda tip kontrolÃ¼ desteÄŸi |
| skill-creator | Yeni Ulak OS native skill'leri oluÅŸturma ve test etme |
| claude-md-management | Vendor adapter dosyalarÄ±nÄ± (CLAUDE.md, AGENTS.md) gÃ¼ncel tutma |
| supabase | Supabase kullanan projelerde veritabanÄ± artefaktlarÄ± |
