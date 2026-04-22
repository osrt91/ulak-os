#!/usr/bin/env python3
"""Generate GitHub social preview banner (1280x640 PNG) for Ulak OS.

Design v3 (orange edition, polished):
- Clean 3-stop orange gradient (orange-950 -> orange-600 -> amber-500)
- Prominent bilingual bar: [TR Türkçe] [EN English] with visible accent blocks
- Large centered wordmark with soft halo, no decoration overlap
- Decorations pushed to corners so typography owns the center
- Faded ">" sigil bottom-right for CLI vibe
- Subtle dot grid + diagonal sheen for texture
- Glass-style vendor chips with amber border glow
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
    orange_950 = (60, 18, 6)       # deeper anchor
    orange_700 = (194, 65, 12)     # #c2410c
    amber_500  = (245, 158, 11)    # #f59e0b

    img = Image.new("RGB", (W, H), orange_950)
    px = img.load()
    max_d = W + H
    for y in range(H):
        for x in range(W):
            t = (x + y) / max_d
            px[x, y] = lerp3(orange_950, orange_700, amber_500, t)

    img = img.convert("RGBA")

    # --- radial glow behind wordmark (boosts readability + depth) ---
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    cx, cy = W // 2, H // 2 + 10
    for r in range(480, 0, -16):
        alpha = int(75 * (1 - r / 480))
        gdraw.ellipse(
            [cx - r, cy - int(r * 0.55), cx + r, cy + int(r * 0.55)],
            fill=(255, 220, 160, alpha),
        )
    glow = glow.filter(ImageFilter.GaussianBlur(32))
    img = Image.alpha_composite(img, glow)

    draw = ImageDraw.Draw(img, "RGBA")

    # --- concentric rings pushed to top-left corner (out of text zone) ---
    rx, ry = -40, -20
    for ring in range(5):
        r = 140 + ring * 70
        alpha = max(10, 55 - ring * 10)
        draw.ellipse(
            [rx - r, ry - r, rx + r, ry + r],
            outline=(255, 237, 213, alpha),
            width=2,
        )

    # --- orbit ellipse: pushed well off-canvas bottom-right ---
    ocx, ocy = W + 20, H + 80
    for rw, rh, a in [(280, 120, 40), (210, 90, 60), (140, 60, 85)]:
        draw.ellipse(
            [ocx - rw, ocy - rh, ocx + rw, ocy + rh],
            outline=(255, 237, 213, a),
            width=2,
        )
    # Orbit nodes on visible upper arc
    for angle_deg, size in [(200, 6), (220, 5), (245, 7)]:
        ang = math.radians(angle_deg)
        nx = ocx + int(210 * math.cos(ang))
        ny = ocy + int(90 * math.sin(ang))
        draw.ellipse(
            [nx - size, ny - size, nx + size, ny + size],
            fill=(255, 237, 213, 210),
        )

    # --- faded prompt sigil ">" bottom-right background ---
    sigil_font = ImageFont.truetype(F_TITLE, 440)
    sigil_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(sigil_layer)
    sdraw.text(
        (W - 340, H - 420),
        ">",
        font=sigil_font,
        fill=(255, 237, 213, 22),
    )
    sigil_layer = sigil_layer.filter(ImageFilter.GaussianBlur(2))
    img = Image.alpha_composite(img, sigil_layer)

    draw = ImageDraw.Draw(img, "RGBA")

    # --- subtle amber dot grid (very low alpha) ---
    for gy in range(0, H, 28):
        for gx in range(0, W, 28):
            draw.ellipse(
                [gx - 1, gy - 1, gx + 1, gy + 1],
                fill=(255, 237, 213, 20),
            )

    # --- diagonal highlight stripe top-right (glass sheen) ---
    draw.polygon(
        [(W - 380, 0), (W, 0), (W, 380), (W - 80, 0)],
        fill=(255, 237, 213, 16),
    )

    # --- typography ---
    title_font    = ImageFont.truetype(F_TITLE, 140)
    subtitle_font = ImageFont.truetype(F_BODY, 34)
    tagline_font  = ImageFont.truetype(F_SEMI, 24)
    chip_font     = ImageFont.truetype(F_SEMI, 22)
    version_font  = ImageFont.truetype(F_BODY, 22)
    lang_font     = ImageFont.truetype(F_TITLE, 26)
    lang_code_font = ImageFont.truetype(F_TITLE, 22)

    title = "Ulak OS"
    subtitle = "Vendor-neutral prompt OS for AI coding CLIs"
    tagline = "Reads your project  ·  Surfaces gaps  ·  Scaffolds full-stack SaaS"

    # ---------------------------------------------------------------
    # BILINGUAL BAR — two pill chips at top, each with accent + label
    # ---------------------------------------------------------------
    # Each chip: [ colored square with "TR"/"EN" ] [ "Türkçe"/"English" ]

    pill_h = 56
    pill_pad_x = 22
    pill_gap = 20
    accent_w = 44  # colored code square width inside pill

    langs = [
        ("TR", "Türkçe",  (230, 85, 45)),    # warm red-orange accent
        ("EN", "English", (255, 200, 100)),  # amber accent
    ]

    # measure labels
    pill_widths = []
    for code, label, _ in langs:
        lb = draw.textbbox((0, 0), label, font=lang_font, anchor="lt")
        label_w = lb[2] - lb[0]
        pill_widths.append(accent_w + pill_pad_x + label_w + pill_pad_x)

    total_bar_w = sum(pill_widths) + pill_gap
    bar_start_x = (W - total_bar_w) // 2
    bar_y = 64

    # Draw pills
    cx_acc = bar_start_x
    for i, (code, label, accent) in enumerate(langs):
        pw = pill_widths[i]
        # Glow pass (soft amber halo)
        plg = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        plgd = ImageDraw.Draw(plg)
        plgd.rounded_rectangle(
            [cx_acc - 3, bar_y - 3, cx_acc + pw + 3, bar_y + pill_h + 3],
            radius=pill_h // 2 + 2,
            outline=(255, 200, 120, 180),
            width=3,
        )
        plg = plg.filter(ImageFilter.GaussianBlur(7))
        img = Image.alpha_composite(img, plg)
        draw = ImageDraw.Draw(img, "RGBA")

        # Pill body (dark glass)
        draw.rounded_rectangle(
            [cx_acc, bar_y, cx_acc + pw, bar_y + pill_h],
            radius=pill_h // 2,
            fill=(50, 18, 8, 220),
            outline=(255, 210, 140, 240),
            width=2,
        )

        # Accent block (code color)
        accent_x0 = cx_acc + 4
        accent_y0 = bar_y + 4
        accent_x1 = accent_x0 + accent_w
        accent_y1 = bar_y + pill_h - 4
        draw.rounded_rectangle(
            [accent_x0, accent_y0, accent_x1, accent_y1],
            radius=pill_h // 2 - 4,
            fill=accent + (255,),
        )
        # Code text on accent
        cb = draw.textbbox((0, 0), code, font=lang_code_font, anchor="lt")
        cw_ = cb[2] - cb[0]
        ch_ = cb[3] - cb[1]
        draw.text(
            (accent_x0 + (accent_w - cw_) // 2,
             accent_y0 + (accent_y1 - accent_y0 - ch_) // 2 - 3),
            code,
            font=lang_code_font,
            fill=(40, 14, 4),
            anchor="lt",
        )

        # Label text (Türkçe / English)
        label_x = accent_x1 + pill_pad_x // 2 + 6
        lb = draw.textbbox((0, 0), label, font=lang_font, anchor="lt")
        lh = lb[3] - lb[1]
        label_y = bar_y + (pill_h - lh) // 2 - 4
        draw.text((label_x, label_y), label, font=lang_font, fill=(255, 255, 255), anchor="lt")

        cx_acc += pw + pill_gap

    # ---------------------------------------------------------------
    # TITLE + SUBTITLE + TAGLINE — centered stack
    # ---------------------------------------------------------------
    tb = draw.textbbox((0, 0), title, font=title_font, anchor="lt")
    sb = draw.textbbox((0, 0), subtitle, font=subtitle_font, anchor="lt")
    gb = draw.textbbox((0, 0), tagline, font=tagline_font, anchor="lt")

    title_w = tb[2] - tb[0]
    title_h = tb[3] - tb[1]
    subtitle_h = sb[3] - sb[1]

    ty = bar_y + pill_h + 60
    sy = ty + title_h + 40
    gy = sy + subtitle_h + 22

    # Title halo
    tx = (W - title_w) // 2
    halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    hdraw = ImageDraw.Draw(halo)
    hdraw.text((tx, ty), title, font=title_font, fill=(255, 200, 110, 190), anchor="lt")
    halo = halo.filter(ImageFilter.GaussianBlur(18))
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

    # ---------------------------------------------------------------
    # VENDOR CHIPS at bottom
    # ---------------------------------------------------------------
    chips = ["Claude Code", "Gemini CLI", "Codex CLI", "Copilot Chat"]
    chip_padding_x = 22
    gap = 16

    chip_widths = []
    for c in chips:
        b = draw.textbbox((0, 0), c, font=chip_font, anchor="lt")
        chip_widths.append((b[2] - b[0]) + chip_padding_x * 2)
    total_w = sum(chip_widths) + gap * (len(chips) - 1)
    start_x = (W - total_w) // 2
    chip_y = H - 128
    chip_h = 48

    # Chip glow pass
    chip_glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cgdraw = ImageDraw.Draw(chip_glow)
    cx_acc = start_x
    for i, c in enumerate(chips):
        cw = chip_widths[i]
        cgdraw.rounded_rectangle(
            [cx_acc - 2, chip_y - 2, cx_acc + cw + 2, chip_y + chip_h + 2],
            radius=24,
            outline=(255, 180, 90, 170),
            width=3,
        )
        cx_acc += cw + gap
    chip_glow = chip_glow.filter(ImageFilter.GaussianBlur(8))
    img = Image.alpha_composite(img, chip_glow)
    draw = ImageDraw.Draw(img, "RGBA")

    cx_acc = start_x
    for i, c in enumerate(chips):
        cw = chip_widths[i]
        draw.rounded_rectangle(
            [cx_acc, chip_y, cx_acc + cw, chip_y + chip_h],
            radius=23,
            fill=(70, 22, 8, 210),
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
