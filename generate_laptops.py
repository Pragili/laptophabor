#!/usr/bin/env python3
"""Generates clean flat-illustration laptop images for the LaptopHarbor seed data.
Pure-Pillow vector-style drawing, supersampled for smooth edges. No network needed."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUT = os.path.join(os.path.dirname(__file__), "backend", "src", "uploads")
os.makedirs(OUT, exist_ok=True)

FB = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FR = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

S = 2                      # supersample factor
W = 800                    # final size
CW = W * S                 # canvas working size


def font(path, size):
    return ImageFont.truetype(path, size * S)


def hx(c):
    c = c.lstrip("#")
    return tuple(int(c[i:i + 2], 16) for i in (0, 2, 4))


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def luminance(c):
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def vgrad(size, top, bottom):
    """Vertical gradient image."""
    w, h = size
    img = Image.new("RGB", (1, h))
    px = img.load()
    for y in range(h):
        px[0, y] = lerp(top, bottom, y / max(1, h - 1))
    return img.resize((w, h))


def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return m


def paste_grad(base, box, top, bottom, radius, diagonal=False):
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    if diagonal:
        g = Image.new("RGB", (w, h))
        px = g.load()
        for yy in range(h):
            for xx in range(0, w, 4):
                t = (xx / w * 0.5 + yy / h * 0.5)
                col = lerp(top, bottom, min(1, t))
                for k in range(xx, min(xx + 4, w)):
                    px[k, yy] = col
    else:
        g = vgrad((w, h), top, bottom)
    base.paste(g, (x0, y0), rounded_mask((w, h), radius))


def draw_laptop(cfg, variant=0):
    body = hx(cfg["body"])
    deck = hx(cfg["deck"])
    acc1 = hx(cfg["acc1"])
    acc2 = hx(cfg["acc2"])
    bg_top = hx(cfg["bg_top"])
    bg_bot = hx(cfg["bg_bot"])
    dark_bg = luminance(bg_top) < 110

    # Variant tweaks so gallery shots differ
    if variant == 1:
        acc1, acc2 = acc2, acc1
        bg_top = lerp(bg_top, (255, 255, 255) if not dark_bg else (0, 0, 0), 0.12)
    elif variant == 2:
        bg_top = lerp(bg_top, acc1, 0.10)
        bg_bot = lerp(bg_bot, acc2, 0.10)

    img = Image.new("RGB", (CW, CW), bg_top)
    img.paste(vgrad((CW, CW), bg_top, bg_bot), (0, 0))
    d = ImageDraw.Draw(img, "RGBA")

    cx = CW // 2

    # ---- soft shadow under the laptop base ----
    sh = Image.new("RGBA", (CW, CW), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sh)
    sd.ellipse([cx - 280 * S, 520 * S, cx + 280 * S, 575 * S],
               fill=(0, 0, 0, 70 if dark_bg else 34))
    sh = sh.filter(ImageFilter.GaussianBlur(14 * S))
    img.paste(sh, (0, 0), sh)

    # ---- screen (open lid) ----
    sx0, sy0, sx1, sy1 = cx - 215 * S, 140 * S, cx + 215 * S, 430 * S
    d.rounded_rectangle([sx0, sy0, sx1, sy1], radius=20 * S, fill=body)
    # bezel highlight
    d.rounded_rectangle([sx0, sy0, sx1, sy1], radius=20 * S, outline=lerp(body, (255, 255, 255), 0.18), width=2 * S)
    # display
    dx0, dy0, dx1, dy1 = sx0 + 18 * S, sy0 + 18 * S, sx1 - 18 * S, sy1 - 26 * S
    paste_grad(img, (dx0, dy0, dx1, dy1), acc1, acc2, 10 * S, diagonal=True)
    d = ImageDraw.Draw(img, "RGBA")
    # camera dot
    d.ellipse([cx - 3 * S, sy0 + 7 * S, cx + 3 * S, sy0 + 13 * S], fill=lerp(body, (255, 255, 255), 0.3))

    # brand wordmark on the display (boot-logo style)
    logo = cfg["logo"]
    lf = font(FB, 30 if len(logo) <= 8 else 22)
    tb = d.textbbox((0, 0), logo, font=lf)
    d.text((cx - (tb[2] - tb[0]) / 2, (dy0 + dy1) / 2 - (tb[3] - tb[1]) / 2 - 6 * S),
           logo, font=lf, fill=(255, 255, 255, 235))

    # ---- hinge ----
    d.rounded_rectangle([cx - 220 * S, sy1 - 4 * S, cx + 220 * S, sy1 + 10 * S],
                        radius=6 * S, fill=lerp(body, (0, 0, 0), 0.15))

    # ---- base / keyboard deck (perspective trapezoid) ----
    tl = (cx - 230 * S, 442 * S)
    tr = (cx + 230 * S, 442 * S)
    br = (cx + 300 * S, 520 * S)
    bl = (cx - 300 * S, 520 * S)
    d.polygon([tl, tr, br, bl], fill=deck)
    # front lip
    d.polygon([bl, br, (br[0], br[1] + 12 * S), (bl[0], bl[1] + 12 * S)],
              fill=lerp(deck, (0, 0, 0), 0.22))
    # keyboard inset
    kb = lerp(deck, (0, 0, 0), 0.30)
    d.polygon([(cx - 175 * S, 452 * S), (cx + 175 * S, 452 * S),
               (cx + 205 * S, 500 * S), (cx - 205 * S, 500 * S)], fill=kb)
    # key rows hint
    for r in range(4):
        yy = 458 * S + r * 10 * S
        spread = 150 * S + r * 12 * S
        d.line([(cx - spread, yy), (cx + spread, yy)],
               fill=lerp(kb, (255, 255, 255), 0.18), width=2 * S)
    # trackpad
    d.polygon([(cx - 45 * S, 505 * S), (cx + 45 * S, 505 * S),
               (cx + 52 * S, 516 * S), (cx - 52 * S, 516 * S)],
              fill=lerp(deck, (255, 255, 255), 0.12))
    # accent strip on deck (brand colour)
    d.line([(cx - 230 * S, 444 * S), (cx + 230 * S, 444 * S)], fill=acc1 + (200,), width=3 * S)

    # ---- captions ----
    ink = (245, 247, 250) if dark_bg else (30, 41, 59)
    sub = lerp(ink, bg_bot, 0.35)
    nf = font(FB, 30)
    cf = font(FR, 18)
    name = cfg["model"]
    tb = d.textbbox((0, 0), name, font=nf)
    d.text((cx - (tb[2] - tb[0]) / 2, 600 * S), name, font=nf, fill=ink)
    cat = cfg["cat"].upper()
    tb2 = d.textbbox((0, 0), cat, font=cf)
    # category chip
    chip_w = (tb2[2] - tb2[0]) + 28 * S
    chip_x = cx - chip_w / 2
    d.rounded_rectangle([chip_x, 648 * S, chip_x + chip_w, 684 * S],
                        radius=18 * S, fill=acc1 + (40,), outline=acc1 + (180,), width=2 * S)
    d.text((cx - (tb2[2] - tb2[0]) / 2, 656 * S), cat, font=cf, fill=acc1)

    return img.resize((W, W), Image.LANCZOS)


# Per-product config — order matches seed.js / mock_data.dart products[0..21]
P = [
    dict(brand="Dell", model="Alienware m16", cat="Gaming", logo="ALIENWARE",
         body="#2A2E37", deck="#343945", acc1="#06B6D4", acc2="#0E7490", bg_top="#141A22", bg_bot="#0B0E13"),
    dict(brand="Lenovo", model="Legion 5 Pro", cat="Gaming", logo="LEGION",
         body="#2B2B2E", deck="#38383C", acc1="#F43F5E", acc2="#9F1239", bg_top="#17171C", bg_bot="#0C0C10"),
    dict(brand="Asus", model="ROG Zephyrus G14", cat="Gaming", logo="ROG",
         body="#26222B", deck="#322C3A", acc1="#D946EF", acc2="#7E22CE", bg_top="#181020", bg_bot="#0D0814"),
    dict(brand="Apple", model="MacBook Air M3", cat="Ultrabook", logo="MacBook Air",
         body="#C8CDD4", deck="#D5DAE0", acc1="#60A5FA", acc2="#2563EB", bg_top="#EEF2F7", bg_bot="#DCE3EC"),
    dict(brand="Apple", model="MacBook Pro 14", cat="Ultrabook", logo="MacBook Pro",
         body="#9AA0A8", deck="#A7ADB5", acc1="#64748B", acc2="#1E293B", bg_top="#E9EDF2", bg_bot="#D6DCE4"),
    dict(brand="Dell", model="Dell XPS 15", cat="Ultrabook", logo="DELL",
         body="#D2D6DC", deck="#DEE2E7", acc1="#38BDF8", acc2="#0284C7", bg_top="#EDF1F6", bg_bot="#DBE2EA"),
    dict(brand="HP", model="HP Spectre x360", cat="2-in-1", logo="SPECTRE",
         body="#1A1D22", deck="#24272D", acc1="#E0B544", acc2="#B8860B", bg_top="#ECEEF1", bg_bot="#D9DCE2"),
    dict(brand="Lenovo", model="ThinkPad X1 Carbon", cat="Business", logo="ThinkPad",
         body="#23262B", deck="#2C3036", acc1="#3B82F6", acc2="#1E3A8A", bg_top="#E8EBEF", bg_bot="#D5DAE1"),
    dict(brand="HP", model="HP Pavilion 15", cat="Budget", logo="HP",
         body="#5B6470", deck="#6B7280", acc1="#3B82F6", acc2="#1D4ED8", bg_top="#EEF1F5", bg_bot="#DCE2EA"),
    dict(brand="Acer", model="Acer Aspire 5", cat="Budget", logo="ACER",
         body="#6B7280", deck="#7B8490", acc1="#0EA5E9", acc2="#0369A1", bg_top="#EFF2F6", bg_bot="#DDE3EB"),
    dict(brand="Asus", model="Zenbook 14 OLED", cat="Ultrabook", logo="ZENBOOK",
         body="#2C3340", deck="#39414F", acc1="#14B8A6", acc2="#0D9488", bg_top="#EAF0F4", bg_bot="#D7E0E7"),
    dict(brand="Acer", model="Predator Helios 16", cat="Gaming", logo="PREDATOR",
         body="#1F2A26", deck="#28362F", acc1="#10B981", acc2="#047857", bg_top="#0E1A14", bg_bot="#07100C"),
    dict(brand="Microsoft", model="Surface Laptop 5", cat="Ultrabook", logo="SURFACE",
         body="#C9CDD2", deck="#D6DADF", acc1="#3B82F6", acc2="#1D4ED8", bg_top="#EEF1F5", bg_bot="#DCE1E9"),
    dict(brand="Razer", model="Razer Blade 15", cat="Gaming", logo="RAZER",
         body="#15171A", deck="#1F2226", acc1="#22C55E", acc2="#15803D", bg_top="#0C0E10", bg_bot="#060708"),
    dict(brand="MSI", model="MSI Stealth 16", cat="Gaming", logo="MSI",
         body="#1B1B1E", deck="#26262A", acc1="#EF4444", acc2="#B91C1C", bg_top="#121214", bg_bot="#080809"),
    dict(brand="Dell", model="Dell Inspiron 15", cat="Budget", logo="DELL",
         body="#5E6772", deck="#6E7783", acc1="#60A5FA", acc2="#2563EB", bg_top="#EEF1F5", bg_bot="#DCE2EA"),
    dict(brand="HP", model="HP Omen 16", cat="Gaming", logo="OMEN",
         body="#1A1C20", deck="#24272C", acc1="#EF4444", acc2="#991B1B", bg_top="#101113", bg_bot="#070809"),
    dict(brand="Lenovo", model="Lenovo Yoga 9i", cat="2-in-1", logo="YOGA",
         body="#2A2622", deck="#36302B", acc1="#D4A056", acc2="#A06D2A", bg_top="#EDEAE6", bg_bot="#DBD5CD"),
    dict(brand="Apple", model="MacBook Air M2", cat="Ultrabook", logo="MacBook Air",
         body="#D6CBB4", deck="#E0D7C4", acc1="#60A5FA", acc2="#3B82F6", bg_top="#F2EFE8", bg_bot="#E4DDD0"),
    dict(brand="Asus", model="Asus TUF Gaming A15", cat="Gaming", logo="TUF",
         body="#2A2A24", deck="#35352C", acc1="#EAB308", acc2="#A16207", bg_top="#15140F", bg_bot="#0A0A07"),
    dict(brand="Acer", model="Acer Swift 3", cat="Ultrabook", logo="SWIFT",
         body="#CDD1D6", deck="#DADEE2", acc1="#38BDF8", acc2="#0284C7", bg_top="#EEF1F5", bg_bot="#DCE2E9"),
    dict(brand="Samsung", model="Samsung Galaxy Book3", cat="Ultrabook", logo="GALAXY BOOK",
         body="#262B33", deck="#333A44", acc1="#3B82F6", acc2="#1E40AF", bg_top="#E9EDF2", bg_bot="#D6DCE4"),
]

if __name__ == "__main__":
    import sys
    only = int(sys.argv[1]) if len(sys.argv) > 1 else None
    for i, cfg in enumerate(P):
        if only is not None and i != only:
            continue
        for v, suffix in enumerate(["", "-b", "-c"]):
            draw_laptop(cfg, v).save(os.path.join(OUT, f"laptop-{i}{suffix}.png"))
        print(f"  laptop-{i} ({cfg['model']}) ✓")
    print("done")
