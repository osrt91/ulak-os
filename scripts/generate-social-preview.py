#!/usr/bin/env python3
"""Generate GitHub social preview banner (1280x640 PNG) for Ulak OS.

Design (orange edition):
- Warm diagonal gradient (orange-950 -> orange-600 -> amber-500)
- Radial glow behind wordmark for depth
- Concentric amber rings (top-left decoration)
- Abstract orbit ellipse (bottom-right decoration)
- Faded ">" prompt sigil background (CLI vibe)
- Wordmark with soft amber glow
- Glass-style vendor chips with amber border glow
- Dot grid + diagonal highlight stripe
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
from pathlib import Path
import math

W, H = 1280, 640
OUT = Path(__file__).parent.parent / "docs" / "branding" / "social-preview.png"

F_TITLE = "C:/Windows/Fonts/segoeuib.ttf"
F_BODY  = "C:/Windows/Fonts/segoeui.ttf"
F_SEMI  = "C:/Windows/Fonts/seguisb.ttf"


def lerp(a, b, t):
    t = max(0.0, min(1.0, t))
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def lerp3(a, b, c, t):
    if t < 0.5:
        return lerp(a, b, t * 2)
    return lerp(b, c, (t - 0.5) * 2)


def build():
    # --- base gradient: warm diagonal (3-stop) ---
    img = Image.new("RGB", (W, H), (67, 20, 7))
    px = img.load()

    orange_950 = (67, 20, 7)      # #431407
    orange_700 = (194, 65, 12)    # #c2410c
    amber_500  = (245, 158, 11)   # #f59e0b

    max_d = W + H
    for y in range(H):
        for x in range(W):
            t = (x + y) / max_d
            px[x, y] = lerp3(orange_950, orange_700, amber_500, t)

    # --- radial glow behind wordmark (boosts readability + depth) ---
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    cx, cy = W // 2, H // 2 - 20
    for r in range(460, 0, -20):
        alpha = int(60 * (1 - r / 460))
        gdraw.ellipse([cx - r, cy - int(r * 0.55), cx + r, cy + int(r * 0.55)],
                      fill=(255, 220, 160, alpha))
    glow = glow.filter(ImageFilter.GaussianBlur(28))
    img = Image.alpha_composite(img.convert("RGBA"), glow)

    draw = ImageDraw.Draw(img, "RGBA")

    # --- concentric rings top-left (decoration) ---
    rx, ry = 100, 120
    for ring in range(6):
        r = 60 + ring * 55
        alpha = max(12, 60 - ring * 9)
        draw.ellipse(
            [rx - r, ry - r, rx + r, ry + r],
            outline=(255, 237, 213, alpha),
            width=2,
        )

    # --- orbit ellipse bottom-right corner (half off-canvas for stylistic cut) ---
    ocx, ocy = W - 40, H + 30
    for rw, rh, a in [(260, 110, 45), (200, 85, 70), (140, 60, 95)]:
        draw.ellipse(
            [ocx - rw, ocy - rh, ocx + rw, ocy + rh],
            outline=(255, 237, 213, a),
            width=2,
        )
    # Orbit nodes (upper arc only — visible area)
    for angle_deg, size in [(195, 6), (215, 5), (245, 7)]:
        ang = math.radians(angle_deg)
        nx = ocx + int(200 * math.cos(ang))
        ny = ocy + int(85 * math.sin(ang))
        draw.ellipse([nx - size, ny - size, nx + size, ny + size],
                     fill=(255, 237, 213, 220))

    # --- faded prompt sigil ">" background ---
    sigil_font = ImageFont.truetype(F_TITLE, 520)
    sigil_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(sigil_layer)
    sdraw.text((W - 460, H - 580), ">", font=sigil_font, fill=(255, 237, 213, 22))
    sigil_layer = sigil_layer.filter(ImageFilter.GaussianBlur(2))
    img = Image.alpha_composite(img, sigil_layer)

    draw = ImageDraw.Draw(img, "RGBA")

    # --- subtle amber dot grid (very low alpha) ---
    for gy in range(0, H, 28):
        for gx in range(0, W, 28):
            draw.ellipse([gx - 1, gy - 1, gx + 1, gy + 1], fill=(255, 237, 213, 22))

    # --- diagonal highlight stripe top-right (glass sheen) ---
    draw.polygon(
        [(W - 380, 0), (W, 0), (W, 380), (W - 80, 0)],
        fill=(255, 237, 213, 18),
    )

    # --- typography ---
    title_font    = ImageFont.truetype(F_TITLE, 132)
    subtitle_font = ImageFont.truetype(F_BODY, 34)
    tagline_font  = ImageFont.truetype(F_SEMI, 24)
    chip_font     = ImageFont.truetype(F_SEMI, 22)
    version_font  = ImageFont.truetype(F_BODY, 22)

    title = "Ulak OS"
    subtitle = "Vendor-neutral prompt OS for AI coding CLIs"
    tagline = "Reads your project  ·  Surfaces gaps  ·  Scaffolds full-stack SaaS"

    tb = draw.textbbox((0, 0), title, font=title_font, anchor="lt")
    sb = draw.textbbox((0, 0), subtitle, font=subtitle_font, anchor="lt")
    gb = draw.textbbox((0, 0), tagline, font=tagline_font, anchor="lt")

    title_h    = tb[3] - tb[1]
    subtitle_h = sb[3] - sb[1]

    # Bilingual pill goes above the title — shift everything down slightly
    ty = 168
    sy = ty + title_h + 42
    gy = sy + subtitle_h + 24

    # --- bilingual pill: "Türkçe · English" centered above title ---
    lang_font = ImageFont.truetype(F_SEMI, 22)
    lang_text_tr = "Türkçe"
    lang_text_en = "English"
    lang_sep = " · "

    tr_b = draw.textbbox((0, 0), lang_text_tr, font=lang_font, anchor="lt")
    en_b = draw.textbbox((0, 0), lang_text_en, font=lang_font, anchor="lt")
    sep_b = draw.textbbox((0, 0), lang_sep, font=lang_font, anchor="lt")
    tr_w = tr_b[2] - tr_b[0]
    en_w = en_b[2] - en_b[0]
    sep_w = sep_b[2] - sep_b[0]
    inner_w = tr_w + sep_w + en_w
    pill_padding_x = 26
    pill_padding_y = 10
    pill_w = inner_w + pill_padding_x * 2
    pill_h = 40
    pill_x = (W - pill_w) // 2
    pill_y = 96

    # Glow pass
    lang_glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    lgdraw = ImageDraw.Draw(lang_glow)
    lgdraw.rounded_rectangle(
        [pill_x - 2, pill_y - 2, pill_x + pill_w + 2, pill_y + pill_h + 2],
        radius=20, outline=(255, 200, 120, 200), width=3,
    )
    lang_glow = lang_glow.filter(ImageFilter.GaussianBlur(6))
    img = Image.alpha_composite(img, lang_glow)

    draw = ImageDraw.Draw(img, "RGBA")

    # Pill body
    draw.rounded_rectangle(
        [pill_x, pill_y, pill_x + pill_w, pill_y + pill_h],
        radius=20,
        fill=(255, 237, 213, 40),
        outline=(255, 210, 140, 220),
        width=2,
    )
    # Pill contents: "Türkçe" in accent amber, separator + "English" in white
    text_x = pill_x + pill_padding_x
    text_y = pill_y + (pill_h - (tr_b[3] - tr_b[1])) // 2 - 4
    draw.text((text_x, text_y), lang_text_tr, font=lang_font, fill=(255, 220, 150), anchor="lt")
    draw.text((text_x + tr_w, text_y), lang_sep, font=lang_font, fill=(255, 237, 213), anchor="lt")
    draw.text((text_x + tr_w + sep_w, text_y), lang_text_en, font=lang_font, fill=(255, 255, 255), anchor="lt")

    # --- title glow: draw soft amber halo ---
    tx = (W - (tb[2] - tb[0])) // 2
    halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    hdraw = ImageDraw.Draw(halo)
    hdraw.text((tx, ty), title, font=title_font, fill=(255, 200, 110, 180), anchor="lt")
    halo = halo.filter(ImageFilter.GaussianBlur(14))
    img = Image.alpha_composite(img, halo)

    draw = ImageDraw.Draw(img, "RGBA")

    # Title shadow + main
    draw.text((tx + 3, ty + 4), title, font=title_font, fill=(40, 14, 4, 200), anchor="lt")
    draw.text((tx, ty), title, font=title_font, fill=(255, 255, 255), anchor="lt")

    # Subtitle
    sx = (W - (sb[2] - sb[0])) // 2
    draw.text((sx, sy), subtitle, font=subtitle_font, fill=(255, 237, 213), anchor="lt")

    # Tagline
    gxp = (W - (gb[2] - gb[0])) // 2
    draw.text((gxp, gy), tagline, font=tagline_font, fill=(254, 215, 170), anchor="lt")

    # --- vendor chips ---
    chips = ["Claude Code", "Gemini CLI", "Codex CLI", "Copilot Chat"]
    chip_padding_x, chip_padding_y = 22, 12
    gap = 16

    chip_widths = []
    for c in chips:
        b = draw.textbbox((0, 0), c, font=chip_font, anchor="lt")
        chip_widths.append((b[2] - b[0]) + chip_padding_x * 2)
    total_w = sum(chip_widths) + gap * (len(chips) - 1)
    start_x = (W - total_w) // 2
    chip_y = H - 140
    chip_h = 46

    # Chip glow pass
    chip_glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cgdraw = ImageDraw.Draw(chip_glow)
    cx_acc = start_x
    for i, c in enumerate(chips):
        cw = chip_widths[i]
        cgdraw.rounded_rectangle(
            [cx_acc - 2, chip_y - 2, cx_acc + cw + 2, chip_y + chip_h + 2],
            radius=24,
            outline=(255, 180, 90, 180),
            width=3,
        )
        cx_acc += cw + gap
    chip_glow = chip_glow.filter(ImageFilter.GaussianBlur(8))
    img = Image.alpha_composite(img, chip_glow)

    draw = ImageDraw.Draw(img, "RGBA")

    cx_acc = start_x
    for i, c in enumerate(chips):
        cw = chip_widths[i]
        # Chip body (amber glass with stronger fill for readability)
        draw.rounded_rectangle(
            [cx_acc, chip_y, cx_acc + cw, chip_y + chip_h],
            radius=23,
            fill=(80, 25, 8, 200),
            outline=(255, 210, 140, 240),
            width=2,
        )
        tb = draw.textbbox((0, 0), c, font=chip_font, anchor="lt")
        ttx = cx_acc + (cw - (tb[2] - tb[0])) // 2
        tty = chip_y + (chip_h - (tb[3] - tb[1])) // 2 - 4
        draw.text((ttx, tty), c, font=chip_font, fill=(255, 255, 255), anchor="lt")
        cx_acc += cw + gap

    # --- footer: repo url only (evergreen — no version tag) ---
    repo = "github.com/osrt91/ulak-os"
    draw.text((40, H - 44), repo, font=version_font, fill=(255, 215, 170), anchor="lt")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(OUT, "PNG", optimize=True)
    print(f"wrote {OUT} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    build()
