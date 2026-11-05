#!/usr/bin/env python3
"""Draw the greyscale curtain textures for the curtains mod.

Cloth hangs in vertical folds: brightness follows a wave across the width,
with a hem along the bottom. The open curtain is the same cloth gathered to
both sides. Original art for MeseCraft; the mod tints it per wool colour.

Usage: python3 curtains.py TEXTURE_DIR
"""
import math
import os
import random
import sys

from PIL import Image


def fold(x, width):
    """Brightness of a fold at column x, between about 0.65 and 1.0."""
    return 0.82 + 0.18 * math.sin(x / width * math.pi * 2 * 3.5)


def cloth(rng, x, y, gathered=1.0):
    v = fold(x * gathered, 16) - (0.08 if y >= 14 else 0) + rng.uniform(-0.03, 0.03)
    g = max(0, min(255, int(v * 235)))
    return (g, g, g, 255)


def main(out):
    rng = random.Random("curtains")
    closed = Image.new("RGBA", (16, 16))
    for y in range(16):
        for x in range(16):
            closed.putpixel((x, y), cloth(rng, x, y))
    closed.save(os.path.join(out, "curtains_closed.png"), optimize=True)

    # Open: each side is a gathered panel that narrows towards a tie-back.
    opened = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    for y in range(16):
        width = 5 if y < 4 else (3 if 7 <= y <= 9 else 4)
        for x in range(width):
            opened.putpixel((x, y), cloth(rng, x, y, 2.0))
            opened.putpixel((15 - x, y), cloth(rng, x, y, 2.0))
    for x in (2, 13):  # tie-backs
        opened.putpixel((x, 8), (120, 120, 120, 255))
    opened.save(os.path.join(out, "curtains_open.png"), optimize=True)


if __name__ == "__main__":
    main(sys.argv[1])
