#!/usr/bin/env python3
"""Pulse — premium ring + waveform logo (transparent + gradient variants)."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "icon"
SIZE = 1024
CX, CY = SIZE / 2, SIZE / 2


def _lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def _mix(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (
        int(_lerp(c1[0], c2[0], t)),
        int(_lerp(c1[1], c2[1], t)),
        int(_lerp(c1[2], c2[2], t)),
    )


def _background(dark: bool) -> Image.Image:
    img = Image.new("RGBA", (SIZE, SIZE))
    px = img.load()
    if dark:
        a, b, c = (12, 14, 32), (32, 28, 74), (58, 48, 118)
    else:
        a, b, c = (55, 48, 163), (79, 70, 229), (124, 58, 237)

    for y in range(SIZE):
        t = y / (SIZE - 1)
        for x in range(SIZE):
            u = x / (SIZE - 1) * 0.4 + t * 0.6
            col = _mix(a, b, u) if u < 0.55 else _mix(b, c, (u - 0.55) / 0.45)
            px[x, y] = (*col, 255)

    bloom = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(bloom)
    alpha = 48 if not dark else 26
    d.ellipse((500, -100, 980, 380), fill=(167, 139, 250, alpha))
    d.ellipse((-140, 520, 300, 960), fill=(129, 140, 248, alpha - 4))
    bloom = bloom.filter(ImageFilter.GaussianBlur(76))
    return Image.alpha_composite(img, bloom)


def _pulse_points(cx: float, cy: float, scale: float) -> list[tuple[float, float]]:
    s = scale
    return [
        (cx - 168 * s, cy + 8 * s),
        (cx - 118 * s, cy + 8 * s),
        (cx - 88 * s, cy - 52 * s),
        (cx - 38 * s, cy + 72 * s),
        (cx + 18 * s, cy - 88 * s),
        (cx + 72 * s, cy + 48 * s),
        (cx + 128 * s, cy + 8 * s),
        (cx + 168 * s, cy + 8 * s),
    ]


def _build_logo(dark: bool) -> Image.Image:
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ring_r = 198
    accent = (165, 180, 252, 255) if dark else (199, 210, 254, 255)
    stroke = (255, 255, 255, 255)

    # Glow behind mark
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse(
        (CX - ring_r - 36, CY - ring_r - 36, CX + ring_r + 36, CY + ring_r + 36),
        fill=(129, 140, 248, 70 if not dark else 45),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(42))
    canvas = Image.alpha_composite(canvas, glow)

    draw = ImageDraw.Draw(canvas)

    # Outer ring
    draw.ellipse(
        (CX - ring_r, CY - ring_r, CX + ring_r, CY + ring_r),
        outline=stroke,
        width=14,
    )
    draw.ellipse(
        (CX - ring_r, CY - ring_r, CX + ring_r, CY + ring_r),
        outline=(*accent[:3], 90),
        width=6,
    )

    # Pulse waveform
    pts = _pulse_points(CX, CY, 1.0)
    draw.line(pts, fill=stroke, width=12, joint="curve")
    draw.line(pts, fill=accent, width=4, joint="curve")

    # End cap dot
    ex, ey = pts[-1]
    draw.ellipse((ex - 10, ey - 10, ex + 10, ey + 10), fill=stroke)
    draw.ellipse((ex - 5, ey - 5, ex + 5, ey + 5), fill=accent[:3])

    return canvas


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    logo = _build_logo(dark=False)
    logo_dark = _build_logo(dark=True)

    logo.save(OUT / "app_icon_transparent.png", "PNG")
    logo_dark.save(OUT / "app_icon_transparent_dark.png", "PNG")

    # Primary app icon uses the dark transparent mark.
    dark_full = Image.alpha_composite(_background(True), logo_dark)
    dark_full.save(OUT / "app_icon.png", "PNG")
    dark_full.save(OUT / "app_icon_dark.png", "PNG")
    logo_dark.save(OUT / "app_icon_foreground.png", "PNG")

    print(f"Pulse icons saved to {OUT}")


if __name__ == "__main__":
    main()
