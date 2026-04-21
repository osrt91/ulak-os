# Runbook — Upgrading from v2.x to v2.4.0+

Target audience: an existing Ulak OS user on **v2.1.3 or earlier** who wants to reach v2.4.0+ (the public-launch track).

If you are on v2.4.0 already, skip to the self-check section at the bottom — the diff to v2.4.x patches is trivial.

---

## What changed since v2.1.3

| Surface | v2.1.3 | v2.4.0 |
|---|---|---|
| Sector packs | 16 | 24 |
| Rule packs | 4 | 8 |
| Anti-patterns | 69 | 79 (AP-01..AP-19 added) |
| Runtime rules | ~24 | 33 |
| Governance docs | ~12 | 22 |
| Agents | 12 | 27 (personas + autonomous-program-director) |
| Scaffolder | not present | `/ulak-scaffold` + 27 templates |
| ADRs | 0 | 6 (rule packs, Phase 5 terminal, product surface split, pattern-import ledger, SaaS scaffolder, plugin packaging) |
| Plugin packaging | not present | `.claude-plugin/` with `plugin.json` |
| License | implicit | explicit MIT (`LICENSE`) |
| Docs | Turkish-only README | bilingual (`README.md` + `README.en.md`) |
| CI | minimal | validate-imports + validate-schemas + validate-vendor-parity + gitleaks + dependabot |
| Pattern import ledger | informal | canonical governance surface at `docs/governance/pattern-import-ledger.md` |

Headline additions you should care about:

- **SaaS scaffolder** — `/ulak-scaffold` produces a shippable Next.js + Supabase + payment project at commit 1, with 8 anti-patterns already gated by construction.
- **Deep inventory contract** — Phase 1 now rejects "folder dump" inventories. If you run `/director` and get a thin inventory, the manager-verdict will flag it as residual risk.
- **Did-you-know is mandatory** — an empty or trivial `did-you-know.md` blocks signoff. Shallow evidence-register is the usual root cause.
- **Persona dispatch** — `/director persona=customer,admin,partner` fans out the full program across personas and merges the findings.
- **Pattern-import ledger** — every cross-project pattern lift carries provenance + trust tier. New entries below T2 fail CI.

---

## Breaking changes

**None.** The contract has been append-only across every v2.x release. A CLAUDE.md file written against v2.1.3 still loads cleanly under v2.4.0.

Two soft caveats:

1. **Pattern-import ledger is now canonical.** If you had a local fork adding anti-patterns without provenance, CI will now fail on PR. Add the ledger entry and a T2+ trust tier.
2. **Vendor parity script is stricter.** Gemini CLI adapter commands must live under `.gemini/commands/*.toml`. If you custom-authored a command only in `.claude/commands/` expecting Codex/Gemini to inherit, it now appears in the exemption list.

---

## Migration steps

### Step 1 — Pull the repo

If you installed via `git clone`:

```bash
cd ~/.ulak-os       # or wherever you cloned
git fetch --tags --prune
git checkout main
git pull --ff-only
git describe --tags
# expect: v2.4.0 (or later)
```

If you installed via `ulak` installer v2.3+:

```bash
ulak update
ulak --version
```

### Step 2 — Refresh CLAUDE.md imports in each project

Projects that use Ulak OS via an `@`-import in `CLAUDE.md` do not need to be re-initialized — the import points at the live core contract, which picks up all new governance docs automatically.

But if a project was scaffolded with v2.1.3's one-liner `install.sh`, the `CLAUDE.md` may reference a removed file. Easiest fix:

```bash
cd /path/to/existing-project
ulak init .
# Idempotent — prints "CLAUDE.md already references Ulak OS core — no change" if
# the import is fine, otherwise appends a fresh import line.
```

If you prefer to edit by hand, confirm this line exists in `CLAUDE.md`:

```
@/absolute/path/to/ulak-os/prompts/core/ulak-os-core-contract-2.0.0.md
```

### Step 3 — Verify the pack locally

```bash
cd ~/.ulak-os
bash scripts/validate-imports.sh        # @-import chain + cycle detection
bash scripts/validate-schemas.sh        # JSON/TOML schemas
bash scripts/validate-vendor-parity.sh  # claude / gemini / codex command parity
```

All three should exit 0. If any fails, read the troubleshooting runbook.

### Step 4 — If you had customizations

If you added local sector packs or anti-patterns as unpushed commits:

```bash
git log --oneline origin/main..HEAD
# Review. Rebase onto new main:
git rebase origin/main
# Resolve any conflicts, then re-run the validators.
```

Conflicts are usually in `docs/runtime/sector-packs.md` (append-to-list style — both sides added entries). Keep both, renumber as needed, rebuild the pattern-import ledger entry for yours.

---

## Self-check: "Did Ulak OS actually improve my audit quality?"

Re-run the director on a project you audited under v2.1.3:

```bash
cd /path/to/previously-audited-project
# Snapshot the old verdict somewhere:
cp reports/current/manager-verdict.md /tmp/verdict-v2.1.3.md
# Fresh run:
# (In Claude Code) /director komple
# When it finishes:
diff /tmp/verdict-v2.1.3.md reports/current/manager-verdict.md
```

You should observe:

1. **Richer did-you-know layer.** v2.4.0 specialists surface non-obvious findings (unused imports, missing i18n keys, cert fallback mistakes, N+1 risks, RLS asymmetry). v2.1.3 often left this section sparse.
2. **Pack-gap-register has more entries.** The v2.4.0 register knows about 79 anti-patterns vs 69 — more gating, more candidates.
3. **Persona-aware findings** (if you ran `/director persona=...`). v2.1.3 did not split by persona.
4. **Trust tiers on every finding.** v2.4.0 enforces T1-T7 on every evidence entry; v2.1.3 allowed untagged.
5. **Validation plan is more granular.** Phase 4.5 live-probe section references specific probes; v2.1.3 was frequently empty.

If the new verdict is not measurably richer, either your project was already very clean or the director ran shallow. Check `reports/current/evidence-register.md` — a file of < 30 lines is a red flag; re-dispatch with a broader agent pool (see `docs/runtime/persona-dispatch-pattern.md`).

---

## Troubleshooting mini-section

### Imports fail after upgrade

Symptom: `validate-imports.sh` reports "file not found" on a doc that used to exist.

Fix: a file was renamed in a later release. Run `git log -- docs/governance/` to spot the rename, then update the `@`-import in your consuming file.

### Tags went missing

Symptom: `git describe --tags` returns nothing.

Fix: your local clone was fetched without tags. Run `git fetch --tags --prune`. If still missing, delete and re-clone.

### Installer overwrote my CLAUDE.md

Symptom: your previous `CLAUDE.md` content is gone.

Fix: `ulak init .` is designed to **append** and back up — look for `CLAUDE.md.ulak-backup` alongside. If that file is missing too, you hit an old installer version; restore from git: `git checkout HEAD -- CLAUDE.md`.

### The director now says signoff_status: blocked where v2.1.3 said ready

This is intended. v2.4.0's validation gate is stricter. Read `reports/current/validation-plan.md` §6 — unmet live-probes are the usual blocker. Run the probes or document them as residual risks in `manager-verdict.md`.
