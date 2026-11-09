#!/usr/bin/env python3
"""Draw small item icons and textures that replaced Minecraft look-alikes.

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


def metal_panel(seed):
    """A 16x16 brushed steel panel: dark frame, bevelled edge and corner rivets."""
    rng = random.Random(seed)
    im = Image.new("RGBA", (16, 16))
    for y in range(16):
        streak = rng.randint(-6, 6)  # brushing runs in horizontal streaks
        for x in range(16):
            v = 146 + streak + rng.randint(-4, 4)
            if x in (0, 15) or y in (0, 15):
                v = 52 + rng.randint(-4, 4)  # frame
            elif x == 1 or y == 1:
                v = 184  # light catches the top and left edge
            elif x == 14 or y == 14:
                v = 104  # shadow on the bottom and right edge
            im.putpixel((x, y), (v, v + 2, v + 8, 255))
    for x, y in ((3, 3), (12, 3), (3, 12), (12, 12)):
        im.putpixel((x, y), (206, 208, 214, 255))
        im.putpixel((x + 1, y + 1), (88, 90, 98, 255))
    return im


def drawers_controller(folder):
    """The drawer controller: a steel box with vents, an intake slot and status lights."""
    path = lambda face: os.path.join(folder, "drawers_controller_%s.png" % face)
    metal_panel("controller_top").save(path("top"), optimize=True)

    side = metal_panel("controller_side")
    for y in (5, 8, 11):  # three vent slots
        for x in range(5, 11):
            side.putpixel((x, y - 1), (110, 112, 120, 255))
            side.putpixel((x, y), (34, 34, 40, 255))
    side.save(path("side"), optimize=True)

    front = metal_panel("controller_front")
    for x in range(4, 12):  # intake slot, with a lip below it
        for y in (4, 5):
            front.putpixel((x, y), (24, 24, 30, 255))
        front.putpixel((x, 6), (190, 192, 198, 255))
    for x in (4, 6, 8):  # status lights
        front.putpixel((x, 10), (60, 200, 90, 255))
        front.putpixel((x, 11), (30, 110, 50, 255))
    front.putpixel((11, 10), (230, 170, 40, 255))
    front.putpixel((11, 11), (130, 90, 20, 255))
    front.save(path("front"), optimize=True)


def main(game):
    coal_powder(os.path.join(game, "mods/mesecraft_torch/textures/mesecraft_torch_coal_powder.png"))
    drawers_controller(os.path.join(game, "mods/MODULES/drawers/textures"))


if __name__ == "__main__":
    main(sys.argv[1])
