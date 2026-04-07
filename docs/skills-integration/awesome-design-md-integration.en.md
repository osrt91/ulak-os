# awesome-design-md Integration

[Türkçe](awesome-design-md-integration.md) | English

Ulak OS uses the MIT-licensed design system references from the [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) repository in fetch-on-demand mode. Content is **not vendored** in this repo; it is downloaded on request.

## Why?

Ulak OS's frontend subagents (`design-system-architect`, `frontend-ios-flutter-director`) and the `/frontend-war-room` command work **evidence-based** when producing design decisions. Requests like "make it look like Stripe checkout" no longer require the model to "imagine" — the real Stripe DESIGN.md file is loaded as a reference.

## 58+ brands available

| Category | Examples |
|---|---|
| AI/ML | Claude, Cohere, ElevenLabs, Ollama, xAI |
| Developer Tools | Cursor, Linear, Vercel, Supabase, Warp |
| Design/Productivity | Figma, Notion, Framer, Miro |
| Fintech | Stripe, Coinbase, Revolut |
| Enterprise | Apple, Uber, Spotify, SpaceX |
| Automotive | Tesla, BMW, Ferrari, Lamborghini |

Full list: https://github.com/VoltAgent/awesome-design-md

## How to use?

### Via wrapper command (easiest)

```
/ulak-design-ref stripe
```

This command:
1. Calls `scripts/fetch-design-references.sh stripe`
2. Writes to `reports/current/design-references/stripe/DESIGN.md`
3. Summarizes the content and integrates it into the frontend task

### Via manual script

```bash
# macOS/Linux
bash scripts/fetch-design-references.sh stripe

# Windows
powershell -ExecutionPolicy Bypass -File scripts\fetch-design-references.ps1 stripe
```

### Integrated with frontend war room

```
/frontend-war-room checkout page mobile-first redesign
```

When the war room opens, it asks the user which brand reference would be appropriate or automatically suggests a few candidates. Once the user selects one, `/ulak-design-ref` runs in the background and the reference is added to the war room's context.

## License and attribution

awesome-design-md is MIT licensed. The source of every DESIGN.md file you download must be preserved along with the upstream URL. It is not intended to be copied directly into production code; it is used to guide decisions and provide inspiration.

## Dependencies

- Internet connection (during fetch)
- `curl` (Linux/macOS) or PowerShell (Windows)

## Limitations

- Does not work offline (previously downloaded references can be used offline)
- If the upstream repo's directory structure changes, the fetch script should be updated (3 fallback paths are already tried)
- Brand names must be lowercase (`stripe`, not `Stripe`)

## v1.1 plan

- `examples/design-driven-frontend/` → runnable example of the fetch + apply pattern
- Smoke test: fetch → parse → usable? for 5 popular brands
- Equivalent wrapper commands for Codex/Gemini
