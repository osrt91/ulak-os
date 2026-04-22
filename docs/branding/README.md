# Branding assets

## Social preview banner

`social-preview.png` — 1280×640 PNG, GitHub repo social preview spec.

Used as the Open Graph image when the repo URL is shared (Twitter/X, Slack, Discord, LinkedIn, etc.).

### Regenerate

```bash
python scripts/generate-social-preview.py
```

Requires Pillow 10+ and Windows system fonts (Segoe UI family). Script at [`scripts/generate-social-preview.py`](../../scripts/generate-social-preview.py).

### Upload to GitHub (manual, one-time)

GitHub does not expose a public API for uploading social preview images. After editing:

1. Go to **Settings → General** on `github.com/osrt91/ulak-os`.
2. Scroll to **Social preview**.
3. Click **Edit** → **Upload an image**.
4. Select `docs/branding/social-preview.png`.

The upload is live immediately. Verify by pasting the repo URL into any platform that renders Open Graph cards.

## Colour palette

| Token | Hex | Usage |
|---|---|---|
| Orange-950 | `#431407` | Gradient start, badge `labelColor`, mermaid dark |
| Orange-700 | `#c2410c` | Gradient mid, chip body |
| Orange-600 | `#ea580c` | Badge primary fill, mermaid node primary |
| Orange-900 | `#7c2d12` | Mermaid stroke |
| Amber-500 | `#f59e0b` | Gradient end, halo accent |
| Amber-200 | `#fed7aa` | Tagline + secondary text on dark |
| Emerald-500 | `#10b981` | Success/artefact accent (mermaid, retained for contrast) |
| Slate-200 | `#e2e8f0` | Subtitle on dark surface |
