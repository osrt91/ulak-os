#!/usr/bin/env python3
"""Generate GitHub social preview banner (1280x640 PNG) for Ulak OS.

Design:
- Diagonal gradient background (indigo-950 -> violet-600)
- Large centered wordmark + tagline
- 4 vendor chips bottom-left
- Version tag bottom-right
- Subtle dot grid decoration
"""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

W, H = 1280, 640
OUT = Path(__file__).parent.parent / "docs" / "branding" / "social-preview.png"

# Windows system fonts (TrueType)
F_TITLE = "C:/Windows/Fonts/segoeuib.ttf"   # bold
F_BODY  = "C:/Windows/Fonts/segoeui.ttf"    # regular
F_SEMI  = "C:/Windows/Fonts/seguisb.ttf"    # semibold


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def build():
    img = Image.new("RGB", (W, H), (30, 27, 75))
    px = img.load()

    # Diagonal gradient: indigo-950 (#1e1b4b) top-left -> violet-600 (#7c3aed) bottom-right
    c1 = (30, 27, 75)
    c2 = (124, 58, 237)
    max_d = W + H
    for y in range(H):
        for x in range(W):
            t = (x + y) / max_d
            px[x, y] = lerp(c1, c2, t)

    draw = ImageDraw.Draw(img, "RGBA")

    # Subtle dot grid decoration (low alpha)
    for gy in range(0, H, 24):
        for gx in range(0, W, 24):
            draw.ellipse([gx - 1, gy - 1, gx + 1, gy + 1], fill=(255, 255, 255, 20))

    # Diagonal accent stripe top-right (emerald, very transparent)
    draw.polygon(
        [(W - 340, 0), (W, 0), (W, 340), (W - 80, 0)],
        fill=(16, 185, 129, 30),
    )

    # Wordmark + tagline (anchor="lt" keeps math predictable)
    title_font    = ImageFont.truetype(F_TITLE, 132)
    subtitle_font = ImageFont.truetype(F_BODY, 34)
    tagline_font  = ImageFont.truetype(F_SEMI, 24)
    chip_font     = ImageFont.truetype(F_SEMI, 22)
    version_font  = ImageFont.truetype(F_BODY, 22)

    # Pre-measure for centering
    title = "Ulak OS"
    subtitle = "Vendor-neutral prompt OS for AI coding CLIs"
    tagline = "Reads your project  ·  Surfaces gaps  ·  Scaffolds full-stack SaaS"

    tb = draw.textbbox((0, 0), title, font=title_font, anchor="lt")
    sb = draw.textbbox((0, 0), subtitle, font=subtitle_font, anchor="lt")
    gb = draw.textbbox((0, 0), tagline, font=tagline_font, anchor="lt")

    # Vertical layout: push title higher, add generous gaps
    title_h    = tb[3] - tb[1]
    subtitle_h = sb[3] - sb[1]

    ty = 145
    sy = ty + title_h + 40
    gy = sy + subtitle_h + 24

    # Title with soft shadow
    tx = (W - (tb[2] - tb[0])) // 2
    draw.text((tx + 3, ty + 3), title, font=title_font, fill=(15, 12, 45, 180), anchor="lt")
    draw.text((tx, ty), title, font=title_font, fill=(255, 255, 255), anchor="lt")

    # Subtitle
    sx = (W - (sb[2] - sb[0])) // 2
    draw.text((sx, sy), subtitle, font=subtitle_font, fill=(226, 232, 240), anchor="lt")

    # Tagline
    gx = (W - (gb[2] - gb[0])) // 2
    draw.text((gx, gy), tagline, font=tagline_font, fill=(196, 181, 253), anchor="lt")

    # Vendor chips (bottom row, centered)
    chips = ["Claude Code", "Gemini CLI", "Codex CLI", "Copilot Chat"]
    chip_padding_x, chip_padding_y = 22, 12
    gap = 16

    # Calculate total width
    chip_widths = []
    for c in chips:
        b = draw.textbbox((0, 0), c, font=chip_font)
        chip_widths.append((b[2] - b[0]) + chip_padding_x * 2)
    total_w = sum(chip_widths) + gap * (len(chips) - 1)
    start_x = (W - total_w) // 2
    chip_y = H - 120
    chip_h = 44

    cx = start_x
    for i, c in enumerate(chips):
        cw = chip_widths[i]
        # Chip background (glass effect)
        draw.rounded_rectangle(
            [cx, chip_y, cx + cw, chip_y + chip_h],
            radius=22,
            fill=(255, 255, 255, 38),
            outline=(255, 255, 255, 80),
            width=1,
        )
        tb = draw.textbbox((0, 0), c, font=chip_font)
        ttx = cx + (cw - (tb[2] - tb[0])) // 2
        tty = chip_y + (chip_h - (tb[3] - tb[1])) // 2 - 4
        draw.text((ttx, tty), c, font=chip_font, fill=(255, 255, 255))
        cx += cw + gap

    # Version tag bottom-right
    ver = "v1.6.0-final"
    vb = draw.textbbox((0, 0), ver, font=version_font)
    vw = vb[2] - vb[0]
    vx = W - vw - 40
    vy = H - 44
    draw.text((vx, vy), ver, font=version_font, fill=(196, 181, 253))

    # Maintainer tag bottom-left
    tag = "github.com/osrt91/ulak-os"
    draw.text((40, H - 44), tag, font=version_font, fill=(196, 181, 253))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, "PNG", optimize=True)
    print(f"wrote {OUT} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    build()
