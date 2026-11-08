#!/usr/bin/env python3
"""Draw small item icons that replaced Minecraft look-alikes.

Original art for MeseCraft (AGPLv3, like the rest of the game).

Usage: python3 items.py GAME_DIR
"""
import os
import random
import sys

from PIL import Image


def coal_powder(path):
    """A low, wide heap of black powder with a few glinting grains."""
    rng = random.Random("coal_powder")
    im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    # Half-width of the heap on each row, from its peak down to its base.
    rows = {7: 2, 8: 4, 9: 5, 10: 6, 11: 7, 12: 7, 13: 6}
    for y, half in rows.items():
        for x in range(8 - half, 8 + half):
            edge = x in (8 - half, 8 + half - 1) or y == 13
            shade = 18 if edge else rng.randint(30, 62)
            if not edge and y < 10 and x < 8:
                shade += 18  # light falls on the upper left of the heap
            im.putpixel((x, y), (shade, shade, shade + 4, 255))
    for _ in range(6):  # glinting grains
        y = rng.randint(8, 12)
        x = rng.randint(8 - rows[y] + 1, 8 + rows[y] - 2)
        im.putpixel((x, y), (120, 120, 128, 255))
    # Loose grains scattered beside the heap.
    for x, y in ((1, 13), (3, 14), (13, 14), (14, 12), (12, 14)):
        im.putpixel((x, y), (40, 40, 44, 255))
    im.save(path, optimize=True)


def main(game):
    coal_powder(os.path.join(game, "mods/mesecraft_torch/textures/mesecraft_torch_coal_powder.png"))


if __name__ == "__main__":
    main(sys.argv[1])
