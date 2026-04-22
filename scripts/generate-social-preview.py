#!/usr/bin/env python3
"""Generate GitHub social preview banner (1280x640 PNG) for Ulak OS.

Design v4 (orange edition, perfectly centered):
- Every chip uses anchor='mm' so text is geometrically centered (no manual nudges)
- Single unified bilingual pill: [Türkçe · English] — balanced, symmetric
- Vertical rhythm: bar(top) -> title -> subtitle -> tagline -> chips(bottom) -> footer
- 3-stop warm gradient with a soft radial glow behind the wordmark
- Decorations pushed to the edges; no visual collision with typography
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


def text_size(draw, text, font):
    """Return (w, h) using anchor='lt' for width measurement."""
    b = draw.textbbox((0, 0), text, font=font, anchor="lt")
    return b[2] - b[0], b[3] - b[1]


def build():
    # --- base gradient ---
    orange_950 = (67, 20, 7)  # #431407 — matches docs/branding/README.md palette
    orange_700 = (194, 65, 12)
    amber_500  = (245, 158, 11)

    img = Image.new("RGB", (W, H), orange_950)
    px = img.load()
    max_d = W + H
    for y in range(H):
        for x in range(W):
            t = (x + y) / max_d
            px[x, y] = lerp3(orange_950, orange_700, amber_500, t)

    img = img.convert("RGBA")

    # --- radial glow behind wordmark ---
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    gcx, gcy = W // 2, H // 2 + 20
    for r in range(500, 0, -18):
        alpha = int(80 * (1 - r / 500))
        gdraw.ellipse(
            [gcx - r, gcy - int(r * 0.55), gcx + r, gcy + int(r * 0.55)],
            fill=(255, 220, 160, alpha),
        )
    glow = glow.filter(ImageFilter.GaussianBlur(34))
    img = Image.alpha_composite(img, glow)

    draw = ImageDraw.Draw(img, "RGBA")

    # --- decorations: rings tucked into top-left corner (out of text zone) ---
    rx, ry = -40, -30
    for ring in range(5):
        r = 140 + ring * 70
        alpha = max(10, 55 - ring * 10)
        draw.ellipse(
            [rx - r, ry - r, rx + r, ry + r],
            outline=(255, 237, 213, alpha),
            width=2,
        )

    # --- orbit pushed off-canvas bottom-right ---
    ocx, ocy = W + 20, H + 80
    for rw, rh, a in [(280, 120, 40), (210, 90, 60), (140, 60, 85)]:
        draw.ellipse(
            [ocx - rw, ocy - rh, ocx + rw, ocy + rh],
            outline=(255, 237, 213, a),
            width=2,
        )
    for angle_deg, size in [(200, 6), (220, 5), (245, 7)]:
        ang = math.radians(angle_deg)
        nx = ocx + int(210 * math.cos(ang))
        ny = ocy + int(90 * math.sin(ang))
        draw.ellipse(
            [nx - size, ny - size, nx + size, ny + size],
            fill=(255, 237, 213, 210),
        )

    # --- faded ">" prompt sigil bottom-right ---
    sigil_font = ImageFont.truetype(F_TITLE, 440)
    sigil = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(sigil)
    sdraw.text((W - 340, H - 420), ">", font=sigil_font, fill=(255, 237, 213, 22))
    sigil = sigil.filter(ImageFilter.GaussianBlur(2))
    img = Image.alpha_composite(img, sigil)

    draw = ImageDraw.Draw(img, "RGBA")

    # --- subtle dot grid ---
    for gy in range(0, H, 28):
        for gx in range(0, W, 28):
            draw.ellipse([gx - 1, gy - 1, gx + 1, gy + 1], fill=(255, 237, 213, 20))

    # --- diagonal sheen top-right ---
    draw.polygon(
        [(W - 380, 0), (W, 0), (W, 380), (W - 80, 0)],
        fill=(255, 237, 213, 16),
    )

    # --- fonts ---
    title_font    = ImageFont.truetype(F_TITLE, 148)
    subtitle_font = ImageFont.truetype(F_BODY, 34)
    tagline_font  = ImageFont.truetype(F_SEMI, 24)
    chip_font     = ImageFont.truetype(F_SEMI, 22)
    lang_font     = ImageFont.truetype(F_TITLE, 26)
    footer_font   = ImageFont.truetype(F_BODY, 22)

    # =====================================================
    # 1) BILINGUAL PILL — one unified chip, perfectly centered
    #    [ Türkçe · English ]
    # =====================================================
    lang_text = "Türkçe  ·  English"
    lw, lh = text_size(draw, lang_text, lang_font)
    pill_h = 58
    pill_w = lw + 80  # horizontal breathing room
    pill_x = (W - pill_w) // 2
    pill_y = 62

    # Soft halo around pill
    halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    hdr = ImageDraw.Draw(halo)
    hdr.rounded_rectangle(
        [pill_x - 4, pill_y - 4, pill_x + pill_w + 4, pill_y + pill_h + 4],
        radius=pill_h // 2 + 4,
        outline=(255, 200, 120, 190),
        width=4,
    )
    halo = halo.filter(ImageFilter.GaussianBlur(9))
    img = Image.alpha_composite(img, halo)
    draw = ImageDraw.Draw(img, "RGBA")

    # Pill body (dark glass) + amber outline
    draw.rounded_rectangle(
        [pill_x, pill_y, pill_x + pill_w, pill_y + pill_h],
        radius=pill_h // 2,
        fill=(48, 16, 6, 225),
        outline=(255, 210, 140, 240),
        width=2,
    )

    # Pill text — centered via anchor='mm'
    pill_cx = pill_x + pill_w // 2
    pill_cy = pill_y + pill_h // 2
    # draw Türkçe, separator, English separately so we can color the middle dot
    tr_txt = "Türkçe"
    sep_txt = "  ·  "
    en_txt = "English"
    tr_w, _ = text_size(draw, tr_txt, lang_font)
    sep_w, _ = text_size(draw, sep_txt, lang_font)
    en_w, _ = text_size(draw, en_txt, lang_font)
    total_w = tr_w + sep_w + en_w
    x0 = pill_cx - total_w // 2
    # Türkçe (warm amber tint for subtle TR accent)
    draw.text((x0 + tr_w // 2, pill_cy), tr_txt, font=lang_font,
              fill=(255, 220, 150), anchor="mm")
    # Separator (bright amber)
    draw.text((x0 + tr_w + sep_w // 2, pill_cy), sep_txt, font=lang_font,
              fill=(255, 180, 90), anchor="mm")
    # English (crisp white)
    draw.text((x0 + tr_w + sep_w + en_w // 2, pill_cy), en_txt, font=lang_font,
              fill=(255, 255, 255), anchor="mm")

    # =====================================================
    # 2) TITLE / SUBTITLE / TAGLINE — centered stack
    # =====================================================
    title = "Ulak OS"
    subtitle = "Vendor-neutral prompt OS for AI coding CLIs"
    tagline = "Reads your project  ·  Surfaces gaps  ·  Scaffolds full-stack SaaS"

    tw, th = text_size(draw, title, title_font)
    _, sh = text_size(draw, subtitle, subtitle_font)
    _, gh = text_size(draw, tagline, tagline_font)

    # Vertical layout
    title_cy    = pill_y + pill_h + 50 + th // 2
    subtitle_cy = title_cy + th // 2 + 42 + sh // 2
    tagline_cy  = subtitle_cy + sh // 2 + 20 + gh // 2

    # Title halo
    halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    hdr = ImageDraw.Draw(halo)
    hdr.text((W // 2, title_cy), title, font=title_font,
             fill=(255, 200, 110, 200), anchor="mm")
    halo = halo.filter(ImageFilter.GaussianBlur(20))
    img = Image.alpha_composite(img, halo)
    draw = ImageDraw.Draw(img, "RGBA")

    # Title shadow + main (both via anchor='mm' so shadow stays aligned)
    draw.text((W // 2 + 3, title_cy + 4), title, font=title_font,
              fill=(40, 14, 4, 210), anchor="mm")
    draw.text((W // 2, title_cy), title, font=title_font,
              fill=(255, 255, 255), anchor="mm")

    draw.text((W // 2, subtitle_cy), subtitle, font=subtitle_font,
              fill=(255, 237, 213), anchor="mm")
    draw.text((W // 2, tagline_cy), tagline, font=tagline_font,
              fill=(254, 215, 170), anchor="mm")

    # =====================================================
    # 3) VENDOR CHIPS — perfectly centered row
    # =====================================================
    chips = ["Claude Code", "Gemini CLI", "Codex CLI", "Copilot Chat"]
    chip_pad_x = 24
    chip_gap = 16
    chip_h = 50

    chip_widths = []
    for c in chips:
        w, _ = text_size(draw, c, chip_font)
        chip_widths.append(w + chip_pad_x * 2)
    total_w = sum(chip_widths) + chip_gap * (len(chips) - 1)
    chip_start_x = (W - total_w) // 2
    chip_y = H - 130
    chip_cy = chip_y + chip_h // 2

    # Chip glow pass
    chip_glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cg = ImageDraw.Draw(chip_glow)
    cursor = chip_start_x
    for cw in chip_widths:
        cg.rounded_rectangle(
            [cursor - 2, chip_y - 2, cursor + cw + 2, chip_y + chip_h + 2],
            radius=26, outline=(255, 180, 90, 170), width=3,
        )
        cursor += cw + chip_gap
    chip_glow = chip_glow.filter(ImageFilter.GaussianBlur(8))
    img = Image.alpha_composite(img, chip_glow)
    draw = ImageDraw.Draw(img, "RGBA")

    # Chip bodies + labels (anchor='mm')
    cursor = chip_start_x
    for label, cw in zip(chips, chip_widths):
        draw.rounded_rectangle(
            [cursor, chip_y, cursor + cw, chip_y + chip_h],
            radius=25,
            fill=(70, 22, 8, 215),
            outline=(255, 210, 140, 240),
            width=2,
        )
        draw.text((cursor + cw // 2, chip_cy), label,
                  font=chip_font, fill=(255, 255, 255), anchor="mm")
        cursor += cw + chip_gap

    # =====================================================
    # 4) FOOTER — repo URL, bottom-left
    # =====================================================
    draw.text((40, H - 34), "github.com/osrt91/ulak-os",
              font=footer_font, fill=(255, 215, 170), anchor="lm")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(OUT, "PNG", optimize=True)
    print(f"wrote {OUT} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    build()
