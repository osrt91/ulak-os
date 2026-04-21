# Ulak OS repository instructions

This repository hosts a cross-platform prompt operating system.

## Always do these first
- Read `AGENTS.md` (the full reading order is defined there).
- Read `docs/adapters/universal-runtime-contract.md`.
- Read `prompts/core/ulak-os-core-contract-2.0.0.md` (the core contract that imports the v2.1 runtime discipline layer).

## Behavioral rules
- Do not reopen scope menus when the user intent is already full-program.
- Execute the Phase 0 → Phase 5 protocol in a single pass.
- Start with deep inventory and evidence capture before any refactor suggestion.
- Inventory must carry file:line citations — top-level `ls` output is not an inventory.
- In Phase 2, dispatch all relevant specialists in parallel; never serialize.
- Phase 3 (did-you-know) is mandatory; the run is not done without non-obvious findings.
- Keep customer, admin, and public API surfaces separate.
- Every finding must conform to `docs/governance/finding-schema.md` with an evidence trust tier from `docs/governance/evidence-trust-scoring.md`.
- Do not claim completion without writing validation and residual risks.

---

## Ulak OS — Natural-Language Trigger Map

GitHub Copilot Chat (VS Code stable) does NOT support slash-command dispatch the way Claude Code does. Ulak OS exposes 24 slash capabilities; in Copilot Chat those same capabilities are reached through **natural-language triggers**. When a user message matches one of the phrases below, behave as if the matching slash command had been invoked — read the referenced command file, render its flow inline, then drive the interactive loop from the chat window.

Match on substring, case-insensitive. Turkish and English triggers are equivalent. Route to the first rule that matches.

### 1. Onboarding + discovery

| User phrase (TR / EN) | Behaves as | Source file |
|---|---|---|
| "selam ulak", "merhaba ulak", "hi ulak", "hello ulak", "ulak nedir", "what is ulak", "ulak tour", "başla" | `/ulak-hello` | `.claude/commands/ulak-hello.md` |
| "paketleri göster", "kapasiteler", "show packs", "list capabilities", "ulak ne yapabilir", "what can ulak do" | `/ulak-packs` | `.claude/commands/ulak-packs.md` |
| "örnek göster", "show me examples", "ulak demo", "show demo", "example projects" | `/ulak-demo` | `.claude/commands/ulak-demo.md` |
| "tam senaryo", "walkthrough", "uçtan uca örnek", "end-to-end example" | Read + render `docs/walkthrough/01-first-saas-end-to-end-copilot.md` inline |

### 2. New SaaS / scaffolding

| User phrase | Behaves as | Source file |
|---|---|---|
| "yeni saas", "yeni proje", "ulak ile site yap", "start a new saas", "new project", "build a saas", "scaffold a saas" | `/ulak-start` (27-question wizard) | `.claude/commands/ulak-start.md` |
| "scaffold et", "scaffold now", "doğrudan kur", "skip wizard, scaffold", "/ulak-scaffold <params>" | `/ulak-scaffold` | `.claude/commands/ulak-scaffold.md` |
| "tasarım referansı", "design reference", "public marka referans" | `/ulak-design-ref` | `.claude/commands/ulak-design-ref.md` |
| "sonraki adımlar", "şimdi ne yapacağım", "next steps", "what now", "post-scaffold runbook" | `/ulak-next-steps` | `.claude/commands/ulak-next-steps.md` |

### 3. Term + concept learning

| User phrase | Behaves as | Source file |
|---|---|---|
| "X nedir", "explain X", "X ne demek", "what is X", "rls nedir", "service role key nedir", "anon key explained" | `/ulak-explain <term>` | `.claude/commands/ulak-explain.md` → reads `docs/runtime/beginner-glossary.md` |
| "sözlük", "terimler", "glossary", "all terms" | List glossary entries from `docs/runtime/beginner-glossary.md` |

### 4. Service setup (tutorials)

| User phrase | Behaves as | Source file |
|---|---|---|
| "supabase nasıl", "supabase setup", "supabase kurulumu", "how do i set up supabase" | Walk `docs/tutorials/supabase.md` step by step |
| "vercel deploy", "vercel'e deploy", "how to deploy on vercel" | Walk `docs/tutorials/vercel.md` |
| "github push", "github repo aç", "github setup", "push to github" | Walk `docs/tutorials/github.md` |
| "resend email", "resend kurulumu", "transactional email setup" | Walk `docs/tutorials/resend.md` |

### 5. Audit + quality

| User phrase | Behaves as | Source file |
|---|---|---|
| "bu projeyi audit et", "audit this project", "kalite kontrolü", "quality check", "tam denetim", "full audit", "director komple", "run the director" | `/director komple` (Phase 0 → Phase 5) | `.claude/commands/director.md` |
| "14 boyut", "14 dimension", "skorkart", "scorecard", "derin audit", "deep audit" | `/ulak-audit-deep` | `.claude/commands/ulak-audit-deep.md` |
| "sadece intake", "intake only", "just read the project", "light bakış" | `/intake` | `.claude/commands/intake.md` |
| "frontend war room", "ui elden geçir", "frontend redesign" | `/frontend-war-room` | `.claude/commands/frontend-war-room.md` |
| "pack gap", "eksikler", "paket gap", "missing commands", "missing skills" | `/pack-gap-audit` | `.claude/commands/pack-gap-audit.md` |
| "final verdict", "son karar", "re-evaluate", "resign-off" | `/final-verdict` | `.claude/commands/final-verdict.md` |
| "build kırık", "build broken", "triage build", "ci red", "why is ci failing" | `/triage-build` | `.claude/commands/triage-build.md` |

### 6. Natural-language routing + ideation

| User phrase | Behaves as | Source file |
|---|---|---|
| "ulak <question>", "natural ask", "doğal sor", "ulak-ask <query>", serbest metin intent | `/ulak-ask` disambiguator | `.claude/commands/ulak-ask.md` |
| "ara <keyword>", "search <keyword>", "ulak kataloğunda ara" | `/ulak-search` | `.claude/commands/ulak-search.md` |
| "beyin fırtınası", "brainstorm a feature", "fikir geliştir", "ideate" | `/ulak-brainstorm` | `.claude/commands/ulak-brainstorm.md` |
| "intake üret", "ulak intake", "ulak okuması yap" | `/ulak-intake` | `.claude/commands/ulak-intake.md` |

### 7. Multi-agent + advanced

| User phrase | Behaves as | Source file |
|---|---|---|
| "paralel ajan", "dispatch parallel", "N subagent çalıştır" | `/ulak-subagent-dispatch` — **Copilot limitation: simulated sequentially, see Limits** | `.claude/commands/ulak-subagent-dispatch.md` |
| "tdd yap", "write failing test first", "test driven", "red-green-refactor" | `/ulak-test-driven` | `.claude/commands/ulak-test-driven.md` |
| "pattern çıkar", "extract pattern", "pattern import" | `/ulak-pattern-extract` | `.claude/commands/ulak-pattern-extract.md` |
| "mcp keşfet", "discover mcp", "yeni mcp server bul" | `/ulak-mcp-discover` | `.claude/commands/ulak-mcp-discover.md` |
| "dil değiştir", "tr yap", "en yap", "switch locale", "toggle language" | `/ulak-locale` | `.claude/commands/ulak-locale.md` |

Total mapped natural-language triggers: **60+** across **24 Ulak OS capabilities**.

---

## Response shape — when the user types a NL trigger

Always follow this 5-step envelope so the user sees which slash command is being simulated and can opt out:

1. **Recognize**. Quote back the phrase you matched and name the target capability.
2. **Declare the simulation** explicitly — use the form:
   > "Bu `/ulak-start` protokolüne denk düşüyor. Copilot Chat slash desteklemediği için ben inline simüle ediyorum."
   > (EN: "This maps to `/ulak-start`. Copilot Chat does not support slash commands, so I will simulate it inline.")
3. **Render the flow** from the source file. Respect its structure — wizards go phase by phase; explain-style commands return the 5-field schema; audit commands return the Phase-0→5 artefact list.
4. **Drive the loop interactively**. After each step, ask the user a concrete follow-up question. Defaults are shown as `(default=...)` and a bare `[enter]` reply accepts the default — **tell the user** when you are treating empty/"[enter]" as default acceptance.
5. **Graceful exit**. If the user types `exit`, `iptal`, `cancel`, `quit`, `dur`, or `kapat` at any step, stop the loop politely, summarize what was captured, and return them to the chat free-form.

When two rules could match, prefer the more specific one. When nothing matches, route to `/ulak-ask` with the user's raw message as the query (rule #6).

---

## Limits (Copilot Chat specific)

- **No parallel subagent dispatch.** Copilot Chat is single-agent. For `/ulak-subagent-dispatch` or Phase 2 of `/director komple`, run specialists **sequentially** and write each specialist's section under `reports/current/specialists/<role>.md` one at a time. This is consistent with `docs/adapters/codex-cli.md` guidance.
- **Inline render only by default.** Do NOT write to disk unless the operator explicitly says "yaz", "write", "kaydet", "commit it", or confirms a write proposal. The single exception is director-protocol artefacts under `reports/current/**` — see `docs/governance/artefact-write-authorization.md`; write those whenever the run is operating under the director protocol.
- **`@workspace` + `@file` references.** Encourage the user to `@workspace` prefix so Copilot pulls the full repo context (the reading order in `AGENTS.md` assumes it). For single-file questions, `#file:<path>` is fine.
- **Slash-command feature parity is semantic, not literal.** When a NL trigger simulates a slash command, the **behavior** must match the source command file exactly; only the **UI** differs (chat turns instead of a slash invocation). Do not skip validation gates, phase order, or schema conformance because the trigger was typed in plain language.
- **No claims about Copilot Workspace (preview).** This adapter is scoped to Copilot Chat in VS Code (stable). Do not reference Workspace features.

---

## Quick self-test

Before shipping a long response, check: (a) did I name the slash command I'm simulating? (b) did I render the flow from the command file, not from memory? (c) if there's a wizard, did I pause after each phase for the user's answer? (d) are any disk writes gated by explicit operator confirmation or director-protocol authorization? All four answers must be "yes".
