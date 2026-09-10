"""Generador del launcher icon exclusivo de ExploraClima.

Concepto grafico: horizonte planetario (azul noche / indigo), franja de
atmosfera y una linea de tendencia coral que asciende sobre el horizonte.
No reutiliza el concepto grafico de aplicaciones anteriores del proyecto.

Uso:  python3 tool/generate_icon.py
Genera:
  assets/icon/exploraclima_icon.png            (1024x1024, icono completo)
  assets/icon/exploraclima_icon_foreground.png (1024x1024, capa adaptativa)
  android/app/src/main/res/mipmap-*/ic_launcher.png
  android/app/src/main/res/mipmap-*/ic_launcher_round.png
  android/app/src/main/res/mipmap-*/ic_launcher_foreground.png
"""

import os
from PIL import Image, ImageDraw

S = 4096  # lienzo de trabajo (supersampling x4 sobre 1024)
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
ASSETS = os.path.join(ROOT, "assets", "icon")

NIGHT_TOP = (10, 20, 42)
NIGHT_BOTTOM = (33, 44, 96)
INDIGO = (63, 81, 181)
INDIGO_DEEP = (44, 57, 130)
CORAL = (255, 138, 114)
CORAL_SOFT = (255, 178, 158)
IVORY = (246, 241, 231)


def vertical_gradient(size, top, bottom):
    img = Image.new("RGB", (1, size), top)
    px = img.load()
    for y in range(size):
        t = y / max(1, size - 1)
        px[0, y] = (
            int(top[0] + (bottom[0] - top[0]) * t),
            int(top[1] + (bottom[1] - top[1]) * t),
            int(top[2] + (bottom[2] - top[2]) * t),
        )
    return img.resize((size, size), Image.NEAREST)


def draw_symbol(draw, cx, cy, scale):
    """Dibuja horizonte + atmosfera + linea de tendencia centrados en (cx, cy)."""
    r = int(1320 * scale)          # radio del horizonte/planeta
    horizon_y = cy + int(640 * scale)

    # Planeta / horizonte
    draw.ellipse(
        [cx - r, horizon_y, cx + r, horizon_y + 2 * r],
        fill=INDIGO_DEEP,
    )
    draw.arc(
        [cx - r, horizon_y, cx + r, horizon_y + 2 * r],
        start=180, end=360, fill=INDIGO, width=int(26 * scale),
    )

    # Franjas de atmosfera
    for i, (offset, color, width) in enumerate(
        [(200, INDIGO, 30), (370, CORAL_SOFT, 22)]
    ):
        rr = r + int(offset * scale)
        draw.arc(
            [cx - rr, horizon_y - (rr - r), cx + rr, horizon_y - (rr - r) + 2 * rr],
            start=203, end=337, fill=color, width=int(width * scale),
        )

    # Linea de tendencia climatica (ascendente)
    pts = [
        (cx - int(1000 * scale), cy + int(330 * scale)),
        (cx - int(500 * scale), cy + int(140 * scale)),
        (cx - int(30 * scale), cy + int(285 * scale)),
        (cx + int(470 * scale), cy - int(240 * scale)),
        (cx + int(880 * scale), cy - int(560 * scale)),
    ]
    draw.line(pts, fill=CORAL, width=int(120 * scale), joint="curve")

    # Nodos de la linea temporal
    for p, rad, color in [
        (pts[0], 60, IVORY),
        (pts[2], 70, IVORY),
        (pts[4], 150, CORAL),
    ]:
        rr = int(rad * scale)
        draw.ellipse([p[0] - rr, p[1] - rr, p[0] + rr, p[1] + rr], fill=color)
    rr = int(70 * scale)
    draw.ellipse(
        [pts[4][0] - rr, pts[4][1] - rr, pts[4][0] + rr, pts[4][1] + rr], fill=IVORY
    )


def build_full():
    base = vertical_gradient(S, NIGHT_TOP, NIGHT_BOTTOM).convert("RGBA")
    draw = ImageDraw.Draw(base)
    draw_symbol(draw, S // 2, S // 2, S / 4096 * 1.0)

    # Mascara con esquinas redondeadas (icono legacy cuadrado)
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, S - 1, S - 1], radius=int(S * 0.22), fill=255)
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    out.paste(base, (0, 0), mask)
    return out


def build_round():
    base = vertical_gradient(S, NIGHT_TOP, NIGHT_BOTTOM).convert("RGBA")
    draw = ImageDraw.Draw(base)
    draw_symbol(draw, S // 2, S // 2, S / 4096 * 1.0)
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, S - 1, S - 1], fill=255)
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    out.paste(base, (0, 0), mask)
    return out


def build_foreground():
    """Capa frontal del icono adaptativo: simbolo dentro de la zona segura."""
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(out)
    draw_symbol(draw, S // 2, S // 2, S / 4096 * 0.62)
    return out


DENSITIES = {
    "mipmap-mdpi": (48, 108),
    "mipmap-hdpi": (72, 162),
    "mipmap-xhdpi": (96, 216),
    "mipmap-xxhdpi": (144, 324),
    "mipmap-xxxhdpi": (192, 432),
}


def main():
    os.makedirs(ASSETS, exist_ok=True)
    full, rnd, fg = build_full(), build_round(), build_foreground()

    full.resize((1024, 1024), Image.LANCZOS).save(
        os.path.join(ASSETS, "exploraclima_icon.png")
    )
    fg.resize((1024, 1024), Image.LANCZOS).save(
        os.path.join(ASSETS, "exploraclima_icon_foreground.png")
    )

    for folder, (legacy, adaptive) in DENSITIES.items():
        target = os.path.join(RES, folder)
        os.makedirs(target, exist_ok=True)
        full.resize((legacy, legacy), Image.LANCZOS).save(
            os.path.join(target, "ic_launcher.png")
        )
        rnd.resize((legacy, legacy), Image.LANCZOS).save(
            os.path.join(target, "ic_launcher_round.png")
        )
        fg.resize((adaptive, adaptive), Image.LANCZOS).save(
            os.path.join(target, "ic_launcher_foreground.png")
        )
    print("Icono ExploraClima generado correctamente.")


if __name__ == "__main__":
    main()
