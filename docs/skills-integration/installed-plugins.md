# Yüklü Plugin ve Skill Ekosistemi

Türkçe | [English](installed-plugins.en.md)

Bu doküman, Ulak OS ile birlikte kullanılabilecek yüklü plugin ve skill'leri listeler.

## Marketplace'ler

| Marketplace | Kaynak |
|------------|--------|
| claude-plugins-official | Anthropic resmi plugin deposu |
| superpowers-marketplace | obra/superpowers topluluk marketplace |

## Yüklü Pluginler

### Superpowers (v5.0.7)
Ana workflow skill paketi. Ulak OS artefakt zinciriyle eşleştirmesi için bkz: [superpowers-mapping.md](superpowers-mapping.md)

### context7
Kütüphane/framework dokümantasyonunu çeker. API syntax, config, versiyon migration, CLI kullanımı için web aramasından daha güvenilir.

### code-review
Pull request kod review skill'i. `superpowers:requesting-code-review` ve `superpowers:receiving-code-review` ile birlikte çalışır.

### frontend-design
Üretim kalitesinde frontend arayüz tasarımı. Generic AI estetiğinden kaçınan, yaratıcı ve cilalanmış kod üretir.

### typescript-lsp (v1.0.0)
TypeScript Language Server Protocol entegrasyonu. Tip kontrolü, otomatik tamamlama ve refactoring desteği.

### skill-creator
Yeni skill oluşturma, mevcut skill'leri düzenleme ve performans ölçümü. Skill evals ve benchmark desteği.

### claude-md-management (v1.0.0)
CLAUDE.md dosyalarını denetleme ve iyileştirme. Kalite raporu üretir, şablona göre günceller.

### supabase
Supabase entegrasyonu. Veritabanı, auth, storage ve edge function yönetimi.

## Ortak Kullanım Stack'i

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
| MCP | hostinger-mcp (Hostinger API) |
| Mobile | Capacitor / Expo (proje bazlı) |

## Plugin ↔ Ulak OS Eşleştirmesi

| Plugin | Ulak OS kullanımı |
|--------|-------------------|
| superpowers | Artefakt zinciri workflow'u (brainstorming → plan → execute → validate) |
| context7 | `research-notes` artefaktı için güncel dokümantasyon çekme |
| code-review | `validation-plan` artefaktı sonrası kod kalite kontrolü |
| frontend-design | `/frontend-war-room` komutuyla birlikte UI implementasyonu |
| typescript-lsp | `ulak validate` CLI komutunda tip kontrolü desteği |
| skill-creator | Yeni Ulak OS native skill'leri oluşturma ve test etme |
| claude-md-management | Vendor adapter dosyalarını (CLAUDE.md, AGENTS.md) güncel tutma |
| supabase | Supabase kullanan projelerde veritabanı artefaktları |
