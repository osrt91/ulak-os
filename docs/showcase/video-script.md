# Video Script — 5-minute Ulak OS demo

Three scenes, 5:00 total. TR primary voiceover with EN subtitle parity. Use a warm terminal theme, no flashy transitions, no background music — pace is the story.

Scenes reference the three main walkthroughs in this directory. If you're extending the video, [`04-cross-project-absorption.md`](./04-cross-project-absorption.md) is a good bonus scene but exceeds the 5-minute target.

## Scene 1 — The audit (0:00 - 2:00)

**Visual**: split screen. Left: terminal with Claude Code session open in `ExampleCorp Suite` repo. Right: `reports/current/` directory being populated in real time (file tree, growing).

**Operator types**:
```
/director komple brownfield audit mode=REPAIR
```

**TR voiceover (0:00 - 0:25)**: "Ulak OS'un çekirdek vaadi: bir repo'ya bakıp altı faz sonunda tek bir manager verdict üretmek. Folder dump inventory veya tek-agent evidence kabul edilmiyor. Şimdi bunu gerçek bir brownfield projede görelim."

**EN subtitle (0:00 - 0:25)**: "Ulak OS's core promise: look at a repo and, in six phases, produce one manager verdict. Folder-dump inventory and single-agent evidence are rejected. Let's see it on a real brownfield project."

**Visual focus (0:25 - 1:10)**: zoom into `reports/current/runtime-manifest.md` appearing; then `inventory.md` showing file:line citations scrolling; then `specialists/` directory filling with three parallel specialist files (security, data, architecture) simultaneously.

**TR voiceover (0:25 - 1:10)**: "Phase 0 runtime'ı kilitliyor — router kararı, active-variables, rule packs. Phase 1 deep inventory — cartographer her surface'i file:line ile topluyor. Phase 2 paralel specialist evidence — üç uzman aynı anda dispatch edildi, her biri kendi artefaktını yazıyor."

**EN subtitle (0:25 - 1:10)**: "Phase 0 locks the runtime — router decision, active variables, rule packs. Phase 1 is deep inventory — cartographer catalogues every surface with file:line. Phase 2 is parallel specialist evidence — three specialists dispatched in parallel, each writing its own artefact."

**Visual focus (1:10 - 1:45)**: open `did-you-know.md` and scroll through five non-obvious findings — highlight "RLS asymmetry on audit_log" and "locale drift between tr.json and en.json".

**TR voiceover (1:10 - 1:45)**: "Phase 3 did-you-know. Operatörün sormadığı ama projede olan sorunlar: audit_log tablosunda RLS yok, tr.json ile en.json arasında 47 key farkı, cert renew fallback eksik. Bu katman opsiyonel değil — boşsa protokol reddediyor."

**EN subtitle (1:10 - 1:45)**: "Phase 3 did-you-know. Problems the operator didn't ask about but the project has: RLS missing on audit_log, 47-key drift between tr.json and en.json, missing cert-renew fallback. This layer is not optional — empty fails the protocol."

**Visual focus (1:45 - 2:00)**: cut to `manager-verdict.md` opening with `signoff_status: conditional`.

**TR voiceover (1:45 - 2:00)**: "Phase 5 verdict: conditional. İki Critical bulgu Wave 1'de çözülmeden ready diyemez."

**EN subtitle (1:45 - 2:00)**: "Phase 5 verdict: conditional. Two Critical findings must ship in Wave 1 before ready."

## Scene 2 — The scaffold (2:00 - 3:30)

**Visual**: split screen. Left: terminal with Claude Code in a fresh directory. Right: directory tree on the right pane, empty at the start.

**Operator types**:
```
/ulak-scaffold ExampleCorp Invoice \
  product=examplecorp-invoice sector=payment-integrated-saas \
  stack=nextjs-supabase locale_primary=tr payment_provider=iyzico
```

**TR voiceover (2:00 - 2:30)**: "Aynı sistem yeni bir proje de üretebiliyor. `/ulak-scaffold` komutu 27 template'den tam bir SaaS iskeleti kuruyor. Next.js, Supabase, Iyzico, i18n, RLS policies, CI, deploy scripts, VPS hardening — hepsi commit 1'de."

**EN subtitle (2:00 - 2:30)**: "The same system also builds new projects. The `/ulak-scaffold` command produces a full SaaS skeleton from 27 templates. Next.js, Supabase, Iyzico, i18n, RLS policies, CI, deploy scripts, VPS hardening — all in commit 1."

**Visual focus (2:30 - 3:10)**: directory tree filling in real time — `app/`, `lib/`, `supabase/migrations/`, `infrastructure/`, `.github/workflows/`. Brief hover on `supabase/migrations/00002_rls_policies.sql` showing RLS enabled on every table.

**TR voiceover (2:30 - 3:10)**: "Dikkat edin: audit_log tablosu var, RLS aktif. lib/auth tek entry point, middleware'den admin API'ye kadar hepsi buradan okuyor. AP-11 multi-layer auth bypass imkansız. Webhook body + timestamp + nonce imzalıyor; AP-18 engellendi. Deploy script health probe ve rollback içeriyor; AP-12 engellendi."

**EN subtitle (2:30 - 3:10)**: "Notice: audit_log table exists with RLS enabled. lib/auth is the single entry point; every layer from middleware to admin API reads through it. AP-11 multi-layer auth bypass impossible. Webhook signs body + timestamp + nonce; AP-18 prevented. Deploy script has health probe and rollback; AP-12 prevented."

**Visual focus (3:10 - 3:30)**: `git log --oneline` showing "feat: scaffold from Ulak OS v2.4.1 — examplecorp-invoice".

**TR voiceover (3:10 - 3:30)**: "İlk commit zaten ship-ready. `/director komple` çalıştırırsanız sıfır Critical bulgu döner — çünkü governance commit 1'de vardı, iki hafta sonra retrofitte değil."

**EN subtitle (3:10 - 3:30)**: "First commit is already ship-ready. Running `/director komple` returns zero Critical findings — because governance was in commit 1, not retrofitted two weeks later."

## Scene 3 — The persona lens (3:30 - 5:00)

**Visual**: back to ExampleCorp Suite repo. Split screen: left terminal, right a visual diagram showing four persona avatars — customer, admin, bayi, support.

**Operator types**:
```
/director dispatch=persona persona_set=customer,admin,bayi,support
```

**TR voiceover (3:30 - 4:05)**: "Specialist dispatch teknik bulguları çıkarıyor — security, data, architecture. Persona dispatch farklı bir lens: aynı projeye dört farklı kullanıcı rolünün gözünden bakıyoruz. Customer, admin, partner bayi, support. Her biri kendi bulgularını yazıyor."

**EN subtitle (3:30 - 4:05)**: "Specialist dispatch surfaces technical defects — security, data, architecture. Persona dispatch is a different lens: we look at the same project through four user roles. Customer, admin, partner, support. Each writes its own findings."

**Visual focus (4:05 - 4:35)**: zoom into `evidence-register.md` showing four sections. Highlight convergence: "RLS on audit_log" appears in both admin-persona and (earlier) data specialist — promoted to T0 consensus.

**TR voiceover (4:05 - 4:35)**: "İki lens convergence yaptığında evidence tier yükseliyor — hem admin persona hem data specialist audit_log RLS eksikliğini tespit etti, T1'den T0'a yükseldi. Nerede çelişiyorlar? Customer mandatory companyName'den şikayetçi, admin daha fazla impersonation tracking istiyor. Çelişki residual risk olarak açıkça loglanıyor."

**EN subtitle (4:05 - 4:35)**: "When two lenses converge, evidence tier rises — both admin-persona and data specialist caught audit_log RLS missing, promoted T1 → T0. Where they disagree? Customer complains about mandatory companyName; admin wants more impersonation tracking. The contradiction is logged as an explicit residual risk."

**Visual focus (4:35 - 5:00)**: cut to `manager-verdict.md` final narrative paragraph.

**TR voiceover (4:35 - 5:00)**: "Ulak OS üç şey yapıyor: repo'ya bakıp verdict üretiyor, yeni projeyi scaffold ediyor, portfolyodan pattern absorbe ediyor. Hepsi aynı artefakt zincirine yazıyor. Vendor-neutral — Claude, Codex, Gemini üçü de çalıştırıyor. Dene."

**EN subtitle (4:35 - 5:00)**: "Ulak OS does three things: audit a repo with a verdict, scaffold a new project, absorb patterns from your portfolio. All write to the same artefact chain. Vendor-neutral — Claude, Codex, Gemini all run it. Try it."

## Duration breakdown

| Scene | Start | End | Duration |
|---|---|---|---|
| 1 — Audit | 0:00 | 2:00 | 2:00 |
| 2 — Scaffold | 2:00 | 3:30 | 1:30 |
| 3 — Persona | 3:30 | 5:00 | 1:30 |
| **Total** | | | **5:00** |

## Production notes

- Terminal font: JetBrains Mono 16pt on dark background
- Voice: calm, matter-of-fact; no hype
- Avoid reading the code — narrate the system's intent
- The TR voiceover is primary; EN appears as closed-captions, synced per timestamp
- Closing frame: Ulak OS logo (if branded) + GitHub URL + MIT license badge
- Do not show real API keys / tokens in any terminal frame; the scaffold demo uses a throwaway directory

## Related showcase docs

- [01-audit-walkthrough.md](./01-audit-walkthrough.md) — full Scene 1 content
- [02-scaffold-walkthrough.md](./02-scaffold-walkthrough.md) — full Scene 2 content
- [03-persona-audit.md](./03-persona-audit.md) — full Scene 3 content
