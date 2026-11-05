#!/usr/bin/env python3
"""Recolour D00Med's mobs_doom textures into MeseCraft's Freedoom-named mobs.

The trilobite, flesh worm and hatchling use D00Med's models and textures from
mobs_doom (CC BY-SA 3.0). This script shifts their colours so they no longer
look like DOOM's red cacodemon, pink demon and lost soul. The results are
derivatives of D00Med's work and stay under CC BY-SA 3.0.

Each rule maps a band of hues to a new hue, saturation and brightness scale.
Pixels outside every band only get the global adjustment.

Usage: python3 recolor.py SOURCE_TEXTURE OUTPUT_TEXTURE MOB
"""

import colorsys
import sys

from PIL import Image

# hue bands in degrees: (from, to, new hue, saturation scale, value scale)
RULES = {
    # Red shell becomes a slate-violet carapace; the blue mouth turns
    # orange-red and the green eye turns yellow.
    "trilobite": [((330, 30), 265, 0.55, 0.95),
                  ((200, 260), 20, 1.0, 1.2),
                  ((90, 160), 55, 1.0, 1.3)],
    # Pink flesh becomes a tan, ochre worm hide.
    "flesh_worm": [((320, 40), 38, 0.6, 0.95)],
    # The dark olive skull becomes a bruised purple shell with blue eyes.
    "hatchling": [((30, 90), 285, 0.9, 1.15),
                  ((0, 30), 200, 1.0, 1.3)],
}


def in_band(h, band):
    lo, hi = band
    return lo <= h <= hi if lo <= hi else (h >= lo or h <= hi)


def main():
    src, dst, mob = sys.argv[1:4]
    img = Image.open(src).convert("RGBA")
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            for band, new_h, s_scale, v_scale in RULES[mob]:
                if s > 0.08 and in_band(h * 360, band):
                    h, s, v = new_h / 360, min(1, s * s_scale), min(1, v * v_scale)
                    break
            r, g, b = colorsys.hsv_to_rgb(h, s, v)
            px[x, y] = (int(r * 255), int(g * 255), int(b * 255), a)
    img.save(dst, optimize=True)


if __name__ == "__main__":
    main()
