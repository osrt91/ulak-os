# Brand Design Reference Index

Ulak OS referenced brand design systems for the `/ulak-design-ref` command and the `saas-scaffolder` skill's `DESIGN.md` template. Sourced from `VoltAgent/awesome-design-md` (https://github.com/VoltAgent/awesome-design-md).

## How to use

### During scaffold

```bash
/ulak-scaffold product_name=my-saas product_domain=saas design_reference=linear.app
```

The scaffolder writes `DESIGN.md` in the new project citing the chosen brand's awesome-design-md entry. The scaffolded project's `design-system-architect` agent reads this DESIGN.md when dispatched.

### On an existing project

```bash
/ulak-design-ref stripe
```

Fetches the brand's DESIGN.md pointer into `reports/current/design-references/<brand>/` and briefs subsequent frontend-war-room / design-system-architect runs.

### Full local mirror (offline)

```bash
bash scripts/fetch-design-references.sh --all
```

Clones the whole awesome-design-md repo into `vendor/awesome-design-md/` (gitignored). Useful when working offline or when you want to browse all 59 brands at once.

## Available brands (59, as of 2026-04-20)

Organized by category (informal grouping).

### AI / dev tools
- `claude` · `cohere` · `composio` · `cursor` · `lovable` · `minimax` · `mistral.ai` · `ollama` · `opencode.ai` · `replicate` · `together.ai` · `voltagent` · `warp` · `x.ai` · `elevenlabs` · `runwayml`

### Developer infrastructure
- `supabase` · `vercel` · `framer` · `figma` · `expo` · `mongodb` · `clickhouse` · `sanity` · `mintlify` · `posthog` · `sentry` · `resend` · `hashicorp` · `ibm`

### SaaS + productivity
- `linear.app` · `notion` · `airtable` · `cal` · `miro` · `raycast` · `webflow` · `zapier` · `intercom` · `superhuman` · `semrush`

### Fintech + commerce
- `stripe` · `coinbase` · `kraken` · `revolut` · `wise` · `airbnb` · `uber`

### Consumer brands
- `apple` · `pinterest` · `spotify` · `tesla`

### Automotive + aerospace
- `bmw` · `ferrari` · `lamborghini` · `renault` · `spacex` · `nvidia`

### Other
- `clay`

## Picking a brand reference

The brand's public design system is a *starting point* for the scaffolded project's visual identity. You're not cloning the brand — you're inheriting their discipline (typography scale, color palette, component rhythm, motion language) as a baseline, then evolving it for your product.

Good fits by product domain:

| Domain | Brand candidates |
|---|---|
| `saas` general | linear.app, notion, vercel, figma |
| `content-ops` / publishing | notion, sanity, webflow |
| `fintech` / payment | stripe, wise, revolut |
| `ai-copilot` / AI-heavy | claude, cohere, cursor, raycast |
| `ecommerce` | airbnb, shopify (not in list — use stripe or uber as proxies) |
| `community` / social | pinterest, spotify |
| `developer-tools` | vercel, warp, raycast, mintlify |
| `telegram-bot` / chat | claude, intercom, superhuman |
| `regulated-saas` / enterprise | ibm, hashicorp, apple |

## Caveat — content source location

Each `design-md/<brand>/README.md` in the awesome-design-md repo now points to `https://getdesign.md/<brand>/design-md/`. The actual DESIGN.md content lives at that external URL. The `/ulak-design-ref` command tries multiple URL patterns; if the brand has moved its content, the command surfaces the redirect URL for you to fetch manually.

## Update cadence

`vendor/awesome-design-md/` is a shallow clone (no history). Refresh with:

```bash
cd vendor/awesome-design-md && git pull
```

Or re-clone:

```bash
rm -rf vendor/awesome-design-md
bash scripts/fetch-design-references.sh --all
```

## Integration

- `scripts/fetch-design-references.sh` — fetches one brand OR `--all` for full mirror
- `.claude/commands/ulak-design-ref.md` — one-brand fetch command
- `.claude/skills/saas-scaffolder/` — consumes `design_reference` input, writes `DESIGN.md` in scaffolded project
- `templates/saas-starter/DESIGN.md.template` — the file the scaffolder writes
- `docs/governance/pattern-import-ledger.md` — brand-design-reference imports can be logged here as IL-N entries

## License

Individual brand assets remain property of their respective owners. awesome-design-md entries are curated references, not brand assets. Treat every brand's design system as inspiration + discipline learning, not as a source of copyable assets.

## Canonical footer

Authoritative as of Ulak OS **v2.2.3**. Index regenerated when `vendor/awesome-design-md/` is refreshed. Source: https://github.com/VoltAgent/awesome-design-md.
