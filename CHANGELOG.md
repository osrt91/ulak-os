# Changelog

All notable **public releases** of Ulak OS. The pre-v1.0.0 internal development cycle is intentionally not retained in this changelog — that history led to the v1.0.0 consolidation (see the v1.0.0 entry's "Hardening" section) and was replaced by the semver reset + scrub pass. Public users see only the v1.x lineage from this file forward.

---

## [1.6.1] — 2026-04-22 — Branding refresh + dependency hygiene

### Added
- `docs/branding/social-preview.png` (1280×640 PNG) — GitHub social preview / Open Graph banner. Unified orange identity with bilingual `Türkçe · English` marker.
- `scripts/generate-social-preview.py` — idempotent Pillow-based generator (Segoe UI + geometric `anchor='mm'` centering for sub-pixel drift-free layout).
- `docs/branding/README.md` — palette documentation + regeneration instructions.
- `docs/release/v1.6.1-release-notes.md` — full branding refresh narrative.

### Changed
- `README.md` + `README.en.md` — hero redesign: centred layout, Mermaid architecture diagram, 3-card CTA grid, 6-scenario 2×3 grid, capability summary tiles, compact release history table.
- Badge + Mermaid palette: indigo/violet (`#7c3aed` / `#1e1b4b` / `#4c1d95`) → orange (`#ea580c` / `#431407` / `#7c2d12`) across both READMEs.
- Dependency bumps (Dependabot batch, 7 PRs merged): `actions/setup-python` 5→6, `actions/checkout` 4→6, `typescript-toolchain` group (3 updates), `better-sqlite3` 11.10→12.9, `ora` 8.2→9.3, `commander` 12.1→14.0.
- Version metadata: `package.json` + `prompts/pack.json` 1.6.0 → 1.6.1; README footer version refreshed.

### Removed
- Stale `v3.0.0` and `v3.0.0-public-ga` tags — deleted from origin + local. The v3.0.0 lineage was abandoned on 2026-04-21 in favour of the semver reset (v1.0.0-launch → v1.6.x). Tags served no public purpose; removing them prevents confusion on `gh release list`.

### Unchanged (explicit)
- Runtime contract (`prompts/core/ulak-os-core-contract-2.0.0.md`) byte-identical to v1.6.0.
- Commands (24) / skills (10) / agents (27) / sector packs (24) / rule packs (8) / governance docs (22) / anti-patterns (33) / templates (~100) counts + behaviour identical.
- Vendor capability matrix — support levels unchanged (Claude FULL, Gemini FULL-MINUS, Codex CORE, Copilot LIMITED).
- User manual (TR + EN, 20 files) — unchanged.

---

## [1.6.0] — 2026-04-21 — Cross-vendor parity (Gemini native + Codex NL + Copilot NL)

### Added
- **Gemini CLI native parity**: 18 new `.toml` commands generated from `.claude/commands/*.md` via `scripts/sync-gemini-commands.sh` (idempotent). Commands added: ulak-ask, ulak-audit-deep, ulak-brainstorm, ulak-demo, ulak-explain, ulak-hello, ulak-locale, ulak-mcp-discover, ulak-next-steps, ulak-packs, ulak-pattern-extract, ulak-scaffold, ulak-search, ulak-start, ulak-subagent-dispatch, ulak-test-driven, frontend-war-room, triage-build.
- `AGENTS.md` Natural-Language Trigger Map (+55L section) — 90 NL phrases mapped to 24 Ulak capabilities for **Codex CLI** (no slash dispatch needed).
- `.github/copilot-instructions.md` NL Trigger Map (+106L expansion) — 60+ triggers for **GitHub Copilot Chat** (VS Code).
- `docs/governance/vendor-capability-matrix.md` (183L, new) — primitive × vendor + command × vendor authoritative truth source.
- `docs/adapters/copilot-chat.md` (113L, new) — dedicated Copilot Chat adapter.
- `docs/walkthrough/01-first-saas-end-to-end-codex.md` (671L, new) — Ali scenario via Codex CLI NL triggers.
- `docs/walkthrough/01-first-saas-end-to-end-copilot.md` (360L, new) — Ali scenario via Copilot Chat VS Code workflow.

### Changed
- `CLAUDE.md` + `AGENTS.md` — import `vendor-capability-matrix.md`.
- `docs/adapters/universal-runtime-contract.md` — new "Runtime primitive contract" section (32 → 62 lines).
- `docs/adapters/codex-cli.md` — vendor primitive matrix + slash-to-NL principles (45 → 121 lines).
- `docs/adapters/gemini-cli.md` — 24-command support table + sync script docs.
- `docs/catalog.md` — new "Vendor support (C/G/X/P)" column per command.
- `.github/vendor-parity-exemptions.txt` — 91 → 44 lines (47 cycle-era exemptions removed).
- User manual (TR + EN, 20 files) refreshed to v1.6 reality: 24 commands, 4 vendors, walkthrough + tutorial + glossary cross-links.

### Fixed
- Vendor parity drift: previously 7/24 Gemini commands, now 24/24.
- CHANGELOG clutter: pre-v1.0.0 internal history moved to `docs/history/pre-public-changelog.md`.

### Vendor status
- Claude Code: **24/24 native** ✅
- Gemini CLI: **24/24 native** ✅ (new in v1.6)
- Codex CLI: **24/24 NL trigger** ✅ (new in v1.6)
- Copilot Chat: **22/24 NL trigger** ✅ (new in v1.6; 2 MCP-dependent commands degraded)

### Infrastructure
- Branch protection enabled on `main`: force-push blocked, deletion blocked, required CI checks (`Validate Ulak OS repo health` + `Scan for committed secrets`) + admin bypass preserved for solo operator.

---

## [1.5.0] — 2026-04-21 — Walkthrough #1 + "selam ulak" natural greeting

### Added
- `docs/walkthrough/01-first-saas-end-to-end.md` (435L, new) — Ali'nin 75-dakikalık ev temizlik marketplace senaryosu, 5 external service (Supabase + GitHub + Vercel + Resend + Iyzico) + 6 Ulak komutu tek akışta. "Ulak OS olmasaydı 15 iş günü, Ulak ile 75 dk" karşılaştırması.
- `docs/walkthrough/README.md` (107L, new) — walkthrough index + 6 gelecek walkthrough backlog.
- Intent router 3 greeting entry: "selam ulak" / "merhaba ulak" / "hi ulak" / "hello ulak" / "ulak" (tek kelime fallback) → `/ulak-hello`.
- README.md üstüne quick-start: "selam ulak yaz" + walkthrough linki.
- `/ulak-hello` tour'unda 5. seçenek: walkthrough dokümanına link.

### Fixed
- v1.1.0 vision layer sonrası beginner'ın "nereden başlayacağım" sorusu — `selam ulak` doğal greeting bir komut ezberlemeden girişi açıyor.

---

## [1.4.0] — 2026-04-21 — External service tutorials (Supabase + Vercel + GitHub + Resend)

### Added
- `docs/tutorials/supabase.md` (504L, new) — 9 bölüm, 15 dk: signup → project → API keys → migration push → auth → first admin user → RLS check → troubleshooting.
- `docs/tutorials/vercel.md` (415L, new) — 9 bölüm, 10 dk: signup → GitHub link → project import → env vars (3 scope) → deploy → custom domain → preview per-PR → troubleshooting.
- `docs/tutorials/github.md` (465L, new) — 11 bölüm, 20 dk: hesap → 2FA → Git install + config → SSH key → ilk repo → push → CI → Dependabot + secret scanning → ilk PR.
- `docs/tutorials/resend.md` (312L, new) — 7 bölüm, 15 dk: signup → domain verify (DKIM + SPF + DMARC) → API key → curl test → scaffold entegrasyonu.
- `docs/tutorials/README.md` (107L, new) — index + tavsiye edilen okuma sırası.
- Glossary 40 → 47 terim: ssh, dependabot, secret-scanning, transactional-email, dkim, spf, dmarc.
- FAQ 304 → 376 satır: 5 yeni Q&A (GitHub ücretli mi / SSH vs HTTPS / Resend alternatifleri / domain yok / Dependabot merge).

### Changed
- `/ulak-next-steps` 365 → 444 satır — her step'te ilgili tutorial linki. Toplam beginner yolculuğu: 55-75 dk scaffold'dan canlı URL'e.

---

## [1.3.0] — 2026-04-21 — Beginner layer (visibility + next-steps + dual-mode wizard + explain + demo)

### Added
- `/ulak-next-steps` (365L, new) — 8-10 step kişisel post-scaffold runbook: pnpm install, .env.local, Supabase/Iyzico/Resend hesap rehberi, migration, seed, pnpm dev, ilk admin user, admin panel. Auto-chains after `/ulak-scaffold`.
- `/ulak-explain <term>` (216L, new) — 5-alanlı şema term açıklayıcı (Basit / Teknik / Analoji / Ulak'ta / İlgili).
- `/ulak-demo` (324L, new) — 3 örnek proje tanıtımı (Minimal SaaS / Marketplace / LMS) ölçülmüş dosya sayısı + dev-day comparison.
- `docs/runtime/beginner-glossary.md` (514L, new) — 40 terim × 5-alan şeması.
- `docs/FAQ.md` 142 → 304 satır: 25 yeni Q&A (beginner onboarding + terim demistifikasyonu).

### Changed
- `/ulak-start` SUMMARY bloğu auto-activated capabilities panelini `[e]` confirmation'dan ÖNCE gösterir (sector overlay, rule packs, anti-patterns, governance, scaffold-file estimates).
- `/ulak-start` Q0 mode selection: `[t]` technical (default) / `[b]` beginner — tüm 27 soru paralel beginner-friendly rendering alır.
- `/mode t|b` mid-flow switch komutu.

---

## [1.2.0] — 2026-04-21 — Wizard deepening (6 → 27 questions, 5 phases)

### Changed
- `/ulak-start` 280 → 615 satır, 6 soru → **21-27 soru** (sector'a göre branched), 5 faza bölündü:
  - Phase 1 — Proje kimliği (4 soru)
  - Phase 2 — Teknik stack (6 soru)
  - Phase 3 — Sektör derinliği (0-4 branched soru)
  - Phase 4 — Operasyonlar (5 soru)
  - Phase 5 — Takım + deploy + compliance (6 soru)
- `docs/runtime/wizard-defaults.md` 57 → 280 satır, default matrix 64 → **285 entry** (16 sector × 15 axis + 15 sector × 3 deep). Cross-cutting rules 6 → 17.
- `docs/catalog.md` — command count sync (19 → 21, plugin.json + pack.json + README + ulak-packs + ulak-ask all aligned).
- 15 legacy slash command frontmatter — `description:` (TR) + `description_en:` (EN) backfill. `validate-bilingual.sh` Rule4 warnings 19 → 0.

### Added
- Wizard auto-dispatch: user `[e]` confirmation → `/ulak-scaffold` same-turn invocation.
- `/skip` / `/back` / `/restart` flow controls.

---

## [1.1.0] — 2026-04-21 — Vision layer (6 new commands for "talk naturally, don't search plugins")

### Added
- `/ulak-ask "<query>"` — natural-language intent router. 100 intent examples (50 TR + 50 EN) + disambiguation rules for 9 ambiguous keywords.
- `/ulak-packs` — inline view of all 135 pack capabilities (commands + skills + agents + sector overlays + rule packs + governance + ADRs + runbooks). Single page, TR-primary.
- `/ulak-search <keyword>` — keyword search across pack catalog, TR or EN. `/ulak-search payment` returns sector pack + templates + flags + ADRs in one screen.
- `/ulak-start` — interactive 6-question SaaS creation wizard (replaces long-flag `/ulak-scaffold` string). Per-sector sensible defaults so "just press enter" produces a working project.
- `/ulak-hello` — 30-second onboarding tour. 3-sentence intro + 3 sample commands + 4-choice routing (scaffold / audit / ask / browse).
- `/ulak-locale [tr|en|show]` — locale toggle. State persisted at `.claude/state/locale.txt`.
- `docs/runtime/intent-router.md` — 100 intent → capability mappings.
- `docs/runtime/wizard-defaults.md` — 64 sensible defaults across 16 sectors × 4 dimensions.
- `docs/catalog.md` — 135-entry bilingual single-page pack catalog.
- `docs/governance/localization-governance.md` — 6-rule bilingual content policy.
- `scripts/validate-bilingual.sh` — TR/EN parity validator.
- `package.json.bin` exposes both `ulak` and `ulak-os` aliases.
- `README.md` / `README.en.md` rewritten TR-first with vision-at-top + 3-command example.
- `.claude/state/locale.txt` as locale SSoT.

### Vision criteria delta
- "Don't search internet for plugins": 🟡 50% → 🟢 95%
- "Don't write prompts": 🔴 15% → 🟢 85%
- "Talk naturally": 🔴 0% → 🟢 80%
- "See what it is": 🟡 40% → 🟢 95%

---

## [1.0.0] — 2026-04-21 — First public launch (semver reset for marketplace submission)

### Context

Ulak OS v1.0.0 is the first publicly distributed artefact. A stranger can clone from a public registry without asking the author. The pre-launch working tree had carried a `3.0.0` manifest label inherited from an internal consolidation cycle — v1.0.0 is the honest label for first public drop (version number inflation hurts trust signals for marketplace listings and awesome-list submissions).

### What v1.0.0 ships

**Scaffolder** (285 templates):
- 124 saas-starter templates (Next.js + Supabase + TypeScript + Tailwind + RLS + CI + tests + deploy)
- 14 sector overlay kits (education, fintech, ecommerce, marketplace, enterprise-b2b, media-content, health-sensitive, ai-copilot, pwa-desktop, admin-cms-hardening, ai-relay-cost-control, member-gated-community, self-hosted-supabase, regulated-saas, container-k8s)
- Hybrid stack add-ons (FastAPI backend, Expo mobile, Telegram bot, monorepo, Traefik)

**Runtime** (33 rules + 8 rule packs + 22 governance docs + 24 sector pack definitions):
- Phase 0→5 director protocol
- 14-dimension audit scorecard
- Evidence trust tiers T1-T7
- Anti-pattern catalog (19 numbered + 98 bullets)

**Slash surface** (9 commands + 8 skills + 27 agents):
- `/director komple`, `/intake`, `/final-verdict`, `/pack-gap-audit`, `/frontend-war-room`, `/ulak-scaffold`, `/ulak-intake`, `/ulak-design-ref`, `/triage-build`
- 18 specialist agents + 9 persona agents (customer / admin / bayi / support / developer / compliance / security-redteam / geo / gov)

**Install**: one-liner (POSIX `install.sh` + PowerShell `install.ps1`), git clone, git submodule, npm (deferred), plugin marketplace (deferred).

**Docs**: bilingual README (TR-primary + EN), 9-section user manual (TR + EN = 20 files), 4 runbooks (first-hour, install-methods, troubleshooting, upgrading), FAQ, CHANGELOG, CODE_OF_CONDUCT, CONTRIBUTING, SECURITY.

### Hardening
- SEC-INCIDENT-2026-04-21 closed via 2-pass history scrub. Terminal redaction policy captured at `docs/governance/` (operator-only reference — banned identifiers and leaked secret prefixes are intentionally not reproduced in any public file).
- 4/4 critical + 9/9 high security findings from internal red-team closed.
- Cartography build-break closed (26 component templates).

### License
MIT. Commercial use welcome.

### Push status
Tag `v1.0.0-launch` (collision-free alias) pushed to `origin/main` after operator-side Resend + Cloudflare key rotation confirmed.

---

## Tags on origin (public release record)

- `v1.0.0-launch` — First public launch (semver reset)
- `v1.1.0-launch` — Vision layer
- `v1.2.0-launch` — Wizard deepening
- `v1.3.0-launch` — Beginner layer
- `v1.4.0-launch` — External service tutorials
- `v1.5.0-launch` — Walkthrough #1 + selam ulak
- `v1.6.0-launch` — Cross-vendor parity
- `v1.6.0-final` — v1.6 polish + user manual refresh
- `v3.0.0` / `v3.0.0-public-ga` — Pre-reset consolidation anchor (kept for lineage)

Release pages: [github.com/osrt91/ulak-os/releases](https://github.com/osrt91/ulak-os/releases).
