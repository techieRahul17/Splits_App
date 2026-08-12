"""Rasterise docs/logo.svg into launcher icon PNGs.

PIL has no antialiasing for shape drawing, so everything is rendered on a 4x
canvas and downsampled with LANCZOS. Geometry mirrors docs/logo.svg exactly.
"""
import os

from PIL import Image, ImageDraw

OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "icon")
BASE = 1024
SS = 4                      # supersample factor
S = BASE * SS

GOLD_TOP = (255, 216, 115)
GOLD_BOT = (231, 168, 30)
INK = (31, 23, 3)

CORNER_R = 232 * SS

# Coin geometry (in 1024-space, scaled by SS at draw time)
COIN_C = (512, 512)
COIN_R = 302
CUT_ANGLE_DEG = -20     # direction of the cut's normal
CUT_OFFSET = 70         # chord distance from centre; non-zero => unequal split
CUT_GAP = 34            # how far each piece slides along the normal


def p(x, y):
    return (x * SS, y * SS)


def diagonal_gradient(size, c1, c2):
    """Build a small diagonal gradient and upscale it.

    Per-pixel work on a 4096px canvas is far too slow in pure Python, and a
    gradient upscales without visible loss.
    """
    n = 256
    small = Image.new("RGB", (n, n))
    px = small.load()
    for y in range(n):
        for x in range(n):
            t = (x + y) / (2 * n - 2)
            px[x, y] = (
                round(c1[0] + (c2[0] - c1[0]) * t),
                round(c1[1] + (c2[1] - c1[1]) * t),
                round(c1[2] + (c2[2] - c1[2]) * t),
            )
    return small.resize((size, size), Image.BICUBIC)


def _half_plane_mask(size, normal, point, positive):
    """Mask covering one side of the line through `point` with `normal`.

    Built as a huge quad rather than per-pixel tests, which keeps it fast even
    on the supersampled canvas.
    """
    nx, ny = normal
    px, py = point
    tx, ty = -ny, nx           # along the line
    big = size * 3
    sign = 1 if positive else -1

    quad = [
        (px + tx * big, py + ty * big),
        (px - tx * big, py - ty * big),
        (px - tx * big + nx * big * sign, py - ty * big + ny * big * sign),
        (px + tx * big + nx * big * sign, py + ty * big + ny * big * sign),
    ]
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).polygon(quad, fill=255)
    return mask


def glyph_layer(size):
    """A coin cut into two unequal pieces, drawn apart along the cut."""
    import math

    cx, cy = COIN_C[0] * SS, COIN_C[1] * SS
    r = COIN_R * SS
    theta = math.radians(CUT_ANGLE_DEG)
    nx, ny = math.cos(theta), math.sin(theta)

    coin = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(coin).ellipse([cx - r, cy - r, cx + r, cy + r], fill=INK)

    # Point on the cut line. Offsetting it from the centre is what makes the
    # two resulting pieces different sizes.
    d = CUT_OFFSET * SS
    lx, ly = cx + nx * d, cy + ny * d

    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gap = CUT_GAP * SS
    for positive in (True, False):
        piece = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        piece.paste(coin, (0, 0), _half_plane_mask(size, (nx, ny), (lx, ly), positive))

        # Slide each piece along the normal, in opposite directions, so the
        # cut opens into a clean gap.
        shift = 1 if positive else -1
        dx, dy = -nx * gap * shift, -ny * gap * shift
        moved = piece.transform(
            (size, size), Image.AFFINE, (1, 0, dx, 0, 1, dy),
            resample=Image.BICUBIC,
        )
        out.alpha_composite(moved)
    return out


def draw_glyph_onto(img):
    img.alpha_composite(glyph_layer(img.size[0]))


def rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1],
                                           radius=radius, fill=255)
    return mask


def save(img, name):
    path = os.path.join(OUT_DIR, name)
    img.resize((BASE, BASE), Image.LANCZOS).save(path, "PNG")
    print("wrote", path)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    grad = diagonal_gradient(S, GOLD_TOP, GOLD_BOT)

    # 1. Full icon: rounded gold tile + glyph.
    icon = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    icon.paste(grad, (0, 0), rounded_mask(S, CORNER_R))
    draw_glyph_onto(icon)
    save(icon, "icon.png")

    # 2. Adaptive foreground: glyph only, transparent.
    fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw_glyph_onto(fg)
    save(fg, "icon_foreground.png")

    # 3. Adaptive background: full-bleed gradient, no rounding. The launcher
    #    applies its own mask, so corners must not be pre-rounded here.
    save(grad.convert("RGBA"), "icon_background.png")


if __name__ == "__main__":
    main()
