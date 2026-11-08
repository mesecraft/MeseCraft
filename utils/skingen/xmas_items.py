#!/usr/bin/env python3
"""Draw the Christmas holiday pack's items, decorations, crops, candy cane gear
and paintings.

Original art for MeseCraft (AGPLv3, like the rest of the game). These replaced
textures whose sources couldn't be traced, including paintings made from
downscaled photos and illustrations.

The candy cane armor textures and previews keep only the shape of the old
files (which pixels 3d_armor's layout uses) and are filled with new stripes;
everything else is drawn from scratch.

Usage: python3 xmas_items.py GAME_DIR
"""
import math
import os
import random
import sys

from PIL import Image

DIR = "mods/mesecraft_christmas/textures/mesecraft_christmas_%s.png"


def rgb(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def shade(c, f):
    return tuple(max(0, min(255, int(v * f))) for v in c[:3]) + (c[3],)


RED, WHITE, GREEN = rgb("d0202c"), rgb("f6f6f6"), rgb("1e8a3a")
GOLD, DARKGOLD = rgb("f0c030"), rgb("a87a10")
COOKIE, COOKIE_EDGE = rgb("f0d090"), rgb("b88a48")
GINGER, GINGER_DARK = rgb("a8642c"), rgb("6e3c18")
LEAF, LEAF_DARK, LEAF_LIGHT = rgb("2e9a3a"), rgb("1a6424"), rgb("5cc04c")


class Icon:
    def __init__(self, w=16, h=16, seed="icon"):
        self.img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        self.px = self.img.load()
        self.w, self.h = w, h
        self.rng = random.Random(seed)

    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[x, y] = c

    def rect(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.put(xx, yy, c)

    def disc(self, cx, cy, r, c, light=None):
        """A filled circle; with light, the upper left is brighter."""
        for y in range(self.h):
            for x in range(self.w):
                dx, dy = x + 0.5 - cx, y + 0.5 - cy
                if dx * dx + dy * dy <= r * r:
                    f = 1.0
                    if light:
                        f = 1.15 - 0.35 * ((dx + dy) / (2 * r) + 0.5)
                    self.put(x, y, shade(c, f))

    def poly(self, pts, c):
        """Fill a polygon (scanline, even-odd)."""
        for y in range(self.h):
            yc = y + 0.5
            xs = []
            for (x1, y1), (x2, y2) in zip(pts, pts[1:] + pts[:1]):
                if (y1 <= yc < y2) or (y2 <= yc < y1):
                    xs.append(x1 + (yc - y1) * (x2 - x1) / (y2 - y1))
            xs.sort()
            for a, b in zip(xs[::2], xs[1::2]):
                for x in range(int(math.ceil(a - 0.5)), int(math.floor(b - 0.5)) + 1):
                    self.put(x, y, c)

    def outline(self, c=rgb("2a1a14")):
        """Darken the edge: transparent pixels next to opaque ones become c."""
        solid = {(x, y) for y in range(self.h) for x in range(self.w) if self.px[x, y][3]}
        for x, y in list(solid):
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                p = (x + dx, y + dy)
                if 0 <= p[0] < self.w and 0 <= p[1] < self.h and p not in solid:
                    self.px[p] = c

    def stripes(self, mask, a=RED, b=WHITE, width=2, light=True):
        """Fill the pixels in mask with diagonal candy cane stripes."""
        for x, y in mask:
            c = a if ((x + y) // width) % 2 == 0 else b
            if light:
                c = shade(c, 1.08 if (x + y) % 5 == 0 else 1.0)
            self.px[x, y] = c

    def save(self, path):
        self.img.save(path, optimize=True)


# ---------------------------------------------------------------------------
# Decorations
# ---------------------------------------------------------------------------

def ornament(colour):
    i = Icon(seed="ornament" + colour)
    i.disc(8, 10, 5.5, rgb(colour), light=True)
    i.rect(6, 3, 4, 2, rgb("9a9aa2"))       # cap
    i.put(7, 2, rgb("6a6a72"))
    i.put(8, 2, rgb("6a6a72"))
    i.put(6, 8, shade(rgb(colour), 1.6))   # glint
    i.put(7, 7, shade(rgb(colour), 1.4))
    i.outline(shade(rgb(colour), 0.35))
    return i


def star():
    i = Icon(seed="star")
    pts = []
    for k in range(10):
        r = 7.4 if k % 2 == 0 else 3.2
        a = -math.pi / 2 + k * math.pi / 5
        pts.append((8 + r * math.cos(a), 8.6 + r * math.sin(a)))
    i.poly(pts, GOLD)
    i.disc(8, 8.6, 2.2, rgb("fff0a0"))
    i.outline(DARKGOLD)
    return i


def wreath():
    i = Icon(seed="wreath")
    for y in range(16):
        for x in range(16):
            d = math.hypot(x + 0.5 - 8, y + 0.5 - 8)
            if 3.6 < d < 7.4:
                i.put(x, y, i.rng.choice((LEAF, LEAF_DARK, LEAF, LEAF_LIGHT)))
    for _ in range(9):                              # berries
        a = i.rng.random() * 2 * math.pi
        i.put(int(8 + 5.5 * math.cos(a)), int(8 + 5.5 * math.sin(a)), RED)
    i.rect(6, 12, 4, 2, RED)                        # bow
    i.put(5, 14, RED)
    i.put(10, 14, RED)
    return i


def icicles():
    i = Icon(seed="icicles")
    x = 0
    while x < 16:
        w = i.rng.choice((2, 3))
        length = i.rng.randint(5, 14)
        for y in range(length):
            width = max(1, round(w * (1 - y / length)))
            for dx in range(width):
                c = rgb("e8f4ff") if dx == 0 else rgb("a8d0f0")
                i.put(x + dx, y, c)
        x += w + i.rng.randint(1, 2)
    return i


def garland_white():
    i = Icon(seed="garland_white")
    for x in range(16):
        y = int(2 + 5 * math.sin(math.pi * (x + 0.5) / 16))
        i.put(x, y, rgb("e8e8f0"))
        i.put(x, y + 1, rgb("b8b8c8") if x % 2 else rgb("f8f8ff"))
    return i


def bell():
    i = Icon(seed="bell")
    pts = [(5, 4), (11, 4), (12, 9), (14, 13), (2, 13), (4, 9)]
    i.poly(pts, GOLD)
    for y in range(4, 13):                          # shading on the right side
        for x in range(9, 15):
            if i.px[x, y][3]:
                i.px[x, y] = shade(GOLD, 0.82)
    i.rect(6, 13, 4, 1, DARKGOLD)
    i.rect(7, 14, 2, 1, rgb("7a5a10"))              # clapper
    i.put(6, 6, rgb("fff0b0"))
    i.outline(rgb("6a4a08"))
    for x, y in ((6, 1), (7, 2), (9, 2), (10, 1), (8, 2)):   # holly on top
        i.put(x, y, LEAF if (x + y) % 2 else LEAF_DARK)
    i.put(8, 3, RED)
    return i


def stocking(colour):
    i = Icon(seed="stocking" + colour)
    body = [(5, 4), (11, 4), (11, 10), (13, 11), (13, 14), (4, 14), (4, 12), (5, 11)]
    i.poly(body, rgb(colour))
    for x, y in [(x, y) for y in range(4, 15) for x in range(16) if i.px[x, y][3]]:
        if (x * 3 + y * 7) % 11 == 0:
            i.px[x, y] = shade(rgb(colour), 0.8)
    i.rect(4, 1, 8, 3, WHITE)                       # fur cuff
    i.put(5, 2, rgb("dcdcdc"))
    i.put(9, 1, rgb("dcdcdc"))
    i.outline(shade(rgb(colour), 0.4))
    return i


def mistletoe():
    i = Icon(seed="mistletoe")
    i.rect(6, 0, 4, 2, RED)                          # ribbon
    i.put(5, 2, RED)
    i.put(10, 2, RED)
    for y in range(2, 13):                           # stems
        i.put(8, y, rgb("6a8a2a"))
    for cx, cy in ((5, 6), (11, 6), (4, 10), (12, 10), (8, 13)):
        for dx, dy in ((0, 0), (1, 0), (0, 1), (-1, 1)):
            i.put(cx + dx, cy + dy, LEAF if (dx + dy) % 2 else LEAF_LIGHT)
    for x, y in ((7, 8), (9, 8), (8, 10), (7, 11)):  # white berries
        i.put(x, y, rgb("f4f4ec"))
    return i


# ---------------------------------------------------------------------------
# Food
# ---------------------------------------------------------------------------

def sugar_cookie(shape):
    i = Icon(seed="cookie_" + shape)
    if shape == "plain":
        i.disc(8, 8.5, 6.5, COOKIE, light=True)
        for _ in range(8):
            i.put(i.rng.randint(4, 11), i.rng.randint(4, 12), rgb("f8f0d8"))  # sugar
    elif shape == "star":
        pts = []
        for k in range(10):
            r = 7.2 if k % 2 == 0 else 3.6
            a = -math.pi / 2 + k * math.pi / 5
            pts.append((8 + r * math.cos(a), 8.8 + r * math.sin(a)))
        i.poly(pts, COOKIE)
        i.disc(8, 8.8, 2.6, rgb("e85848"))          # red icing
    elif shape == "tree":
        i.poly([(8, 1.5), (13.5, 13), (2.5, 13)], COOKIE)
        i.rect(7, 13, 2, 2, COOKIE)
        i.poly([(8, 3.5), (11.5, 11.5), (4.5, 11.5)], rgb("68c058"))  # green icing
        for x, y in ((7, 7), (9, 9), (6, 10)):
            i.put(x, y, rgb("e83838"))
    elif shape == "bell":
        i.poly([(5, 3), (11, 3), (12, 8), (14, 13), (2, 13), (4, 8)], COOKIE)
        i.poly([(6, 4.5), (10, 4.5), (11, 8.5), (12.5, 12), (3.5, 12), (5, 8.5)], rgb("88a8e0"))
        i.rect(7, 13, 2, 1, COOKIE)
    i.outline(COOKIE_EDGE)
    return i


def peppermint_candies(colour):
    i = Icon(seed="peppermint" + colour)
    for cx, cy in ((5, 5), (11, 7), (6, 12)):
        for y in range(16):
            for x in range(16):
                dx, dy = x + 0.5 - cx, y + 0.5 - cy
                if dx * dx + dy * dy <= 3.2 * 3.2:
                    a = math.atan2(dy, dx)
                    i.put(x, y, rgb(colour) if int((a + math.pi) / (math.pi / 3)) % 2 else WHITE)
    i.outline(shade(rgb(colour), 0.45))
    return i


def gingerbread():
    i = Icon(seed="gingerbread_item")
    i.rect(2, 5, 12, 7, GINGER)
    for x in range(2, 14):
        for y in range(5, 12):
            if i.rng.random() < 0.25:
                i.put(x, y, shade(GINGER, 0.85))
    i.rect(2, 5, 12, 1, shade(GINGER, 1.2))
    for x in range(3, 13, 2):                       # icing zigzag
        i.put(x, 7, WHITE)
        i.put(x + 1, 8, WHITE)
    i.outline(GINGER_DARK)
    return i


def candy_cane_block(colour):
    i = Icon(seed="cane_block" + colour)
    i.stripes([(x, y) for y in range(16) for x in range(16)], rgb(colour), WHITE, width=4)
    for x in range(16):                             # glossy top edge
        i.put(x, 0, shade(i.px[x, 0], 1.15))
    return i


def gingerbread_block():
    i = Icon(seed="gingerbread_block")
    for y in range(16):
        for x in range(16):
            i.put(x, y, shade(GINGER, i.rng.uniform(0.85, 1.05)))
    for k in range(16):                             # icing border
        for x, y in ((k, 0), (k, 15), (0, k), (15, k)):
            if k % 2 == 0:
                i.put(x, y, WHITE)
    for x, y in ((4, 4), (11, 4), (4, 11), (11, 11), (8, 8)):   # gumdrops
        i.put(x, y, i.rng.choice((RED, GREEN, GOLD)))
    return i


# ---------------------------------------------------------------------------
# Crops
# ---------------------------------------------------------------------------

def ginger_root():
    i = Icon(seed="ginger_root")
    for cx, cy, r in ((6, 9, 3.2), (10, 8, 2.6), (8, 12, 2.4), (12, 11, 2.0), (4, 6, 1.8)):
        i.disc(cx, cy, r, rgb("d8b878"), light=True)
    for _ in range(6):
        i.put(i.rng.randint(4, 12), i.rng.randint(6, 13), rgb("b8945a"))
    i.outline(rgb("7a5a2a"))
    return i


def plant(stage, kind):
    """Crop stages 0-3: a row of plants that grow taller."""
    i = Icon(seed="%s%d" % (kind, stage))
    height = (3, 6, 10, 13)[stage]
    for base in (3, 8, 13):
        x0 = base + i.rng.choice((-1, 0))
        for y in range(15, 15 - height, -1):
            i.put(x0, y, LEAF_DARK)
            if kind == "peppermint" and (15 - y) % 3 == 1 and stage > 0:
                i.put(x0 - 1, y, LEAF_LIGHT)
                i.put(x0 + 1, y, LEAF)
            if kind == "ginger" and (15 - y) % 4 == 2 and stage > 0:
                i.put(x0 + 1, y - 1, LEAF)
                i.put(x0 + 2, y - 2, LEAF_LIGHT)
        if kind == "ginger" and stage == 3:
            i.put(x0, 15, rgb("d8b878"))
            i.put(x0 + 1, 15, rgb("d8b878"))
    return i


def peppermint_leaf():
    i = Icon(seed="mint_leaf")
    i.poly([(3, 13), (6, 6), (12, 2), (13, 8), (8, 12)], LEAF)
    for k in range(9):                              # midrib
        i.put(4 + k, 12 - k, LEAF_DARK)
    i.outline(rgb("124a18"))
    return i


def peppermint_seeds():
    i = Icon(seed="mint_seeds")
    for x, y in ((4, 5), (10, 4), (7, 9), (12, 10), (5, 12), (9, 13)):
        i.put(x, y, rgb("5a3a1e"))
        i.put(x + 1, y, rgb("7a5230"))
    return i


# ---------------------------------------------------------------------------
# Candy cane tools and armor
# ---------------------------------------------------------------------------

def cane_handle(i, length):
    """A striped diagonal handle from the bottom left."""
    i.stripes([(1 + k, 14 - k) for k in range(length)] + [(2 + k, 14 - k) for k in range(length)], width=2)


def cane_tool(kind):
    i = Icon(seed="cane_" + kind)
    if kind == "sword":
        cane_handle(i, 4)
        i.rect(4, 9, 3, 3, rgb("2e9a3a"))           # hard candy guard
        for k in range(8):
            i.stripes([(6 + k, 9 - k), (7 + k, 9 - k)], RED, WHITE, width=1)
    elif kind == "pick":
        cane_handle(i, 10)
        i.stripes([(x, y) for x, y in
                   [(4, 2), (5, 2), (6, 2), (7, 3), (8, 3), (9, 4), (10, 5), (11, 6), (12, 7),
                    (12, 8), (13, 9), (13, 10), (5, 3), (6, 3), (11, 7)]], width=1)
    elif kind == "axe":
        cane_handle(i, 11)
        # A broad blade of hard candy on the upper right of the handle.
        blade = Icon(seed="blade")
        blade.poly([(8, 1), (15, 2), (15, 9), (11, 7), (9, 5)], RED)
        mask = [(x, y) for y in range(16) for x in range(16) if blade.px[x, y][3]]
        i.stripes(mask, RED, WHITE, width=2)
    i.outline(rgb("5a0a10"))
    return i


def cane_armor_icon(kind):
    i = Icon(seed="cane_armor_" + kind)
    shapes = {
        "helmet": [(3, 3), (13, 3), (13, 10), (11, 10), (11, 7), (5, 7), (5, 10), (3, 10)],
        "chestplate": [(2, 2), (6, 2), (8, 4), (10, 2), (14, 2), (14, 7), (12, 7), (12, 14), (4, 14), (4, 7), (2, 7)],
        "leggings": [(3, 2), (13, 2), (13, 14), (9, 14), (9, 7), (7, 7), (7, 14), (3, 14)],
        "boots": [(2, 5), (6, 5), (6, 11), (7, 11), (7, 14), (2, 14), (9, 5), (13, 5), (13, 14), (9, 14)],
        "shield": [(3, 2), (13, 2), (13, 9), (8, 14), (3, 9)],
    }
    if kind == "boots":
        i.poly(shapes[kind][:6], RED)
        i.poly(shapes[kind][6:], RED)
    else:
        i.poly(shapes[kind], RED)
    i.stripes([(x, y) for y in range(16) for x in range(16) if i.px[x, y][3]], width=2)
    i.outline(rgb("5a0a10"))
    return i


def restripe(path, width=2):
    """Refill an armor texture's opaque pixels with new stripes."""
    img = Image.open(path).convert("RGBA")
    i = Icon(img.width, img.height)
    src = img.load()
    mask = [(x, y) for y in range(img.height) for x in range(img.width) if src[x, y][3] > 0]
    i.stripes(mask, width=width)
    return i


# ---------------------------------------------------------------------------
# Paintings (64x64, candy cane frame)
# ---------------------------------------------------------------------------

def frame(i):
    for k in range(64):
        for x, y in ((k, 0), (k, 1), (k, 62), (k, 63), (0, k), (1, k), (62, k), (63, k)):
            i.put(x, y, RED if (k // 3) % 2 else WHITE)
    for cx, cy in ((1, 1), (62, 1), (1, 62), (62, 62)):     # holly corners
        for dx, dy in ((0, 0), (1, 0), (0, 1), (-1, 0), (0, -1)):
            i.put(cx + dx, cy + dy, GREEN)
        i.put(cx, cy, RED)


def sky(i, top, bottom, stars=0):
    t, b = rgb(top), rgb(bottom)
    for y in range(64):
        f = y / 63
        c = tuple(int(t[k] + (b[k] - t[k]) * f) for k in range(3)) + (255,)
        for x in range(64):
            i.put(x, y, c)
    for _ in range(stars):
        i.put(i.rng.randrange(64), i.rng.randrange(36), rgb("f0f0ff"))


def snow_ground(i, y0, wave=2):
    for x in range(64):
        top = y0 + int(wave * math.sin(x / 9))
        for y in range(top, 64):
            i.put(x, y, rgb("eef2fa") if (x + y) % 7 else rgb("d4dcec"))


def pine(i, x, base, h, dark=False):
    green = LEAF_DARK if dark else rgb("1e6a30")
    for k in range(h):
        half = int((h - k) * 0.45)
        for dx in range(-half, half + 1):
            c = green if (dx + k) % 4 else shade(green, 1.25)
            if k % 4 == 0 and abs(dx) == half:
                c = rgb("f0f4fa")                   # snow on the branch tips
            i.put(x + dx, base - k, c)
    i.rect(x - 1, base, 2, 3, GINGER_DARK)


def falling_snow(i, n=60):
    for _ in range(n):
        i.put(i.rng.randrange(2, 62), i.rng.randrange(2, 62), rgb("ffffff"))


def house(i, x, y, w, h, roof="8a2a20"):
    i.rect(x, y, w, h, rgb("6a4a32"))
    i.poly([(x - 2, y), (x + w / 2, y - h * 0.7), (x + w + 2, y)], rgb(roof))
    i.poly([(x - 2, y), (x + w / 2, y - h * 0.7), (x + w + 2, y), (x + w + 1, y - 1), (x + w / 2, y - h * 0.7 + 1.5), (x - 1, y - 1)], rgb("f0f4fa"))
    for wx in range(x + 2, x + w - 2, 4):
        i.rect(wx, y + 2, 2, 2, rgb("f8d860"))       # lit windows
    i.rect(x + w // 2 - 1, y + h - 4, 2, 4, rgb("3a2416"))


def painting(n):
    i = Icon(64, 64, seed="painting%d" % n)
    if n == 1:      # a decorated tree in a warm room
        sky(i, "5a1418", "3a0c10")
        i.rect(0, 50, 64, 14, rgb("6a4024"))
        for x in range(0, 64, 6):
            i.rect(x, 50, 1, 14, rgb("4a2c18"))
        pine(i, 32, 50, 38)
        for _ in range(26):
            x, y = i.rng.randint(20, 44), i.rng.randint(16, 48)
            if i.px[x, y][:3] != i.px[2, y][:3]:
                i.put(x, y, i.rng.choice((RED, GOLD, rgb("3070e0"), WHITE)))
        star_icon = star().img.resize((10, 10), Image.NEAREST)
        i.img.alpha_composite(star_icon, (27, 6))
        for x, w, c in ((16, 7, RED), (40, 8, rgb("2a70c0")), (25, 5, GOLD)):
            i.rect(x, 53, w, 6, c)
            i.rect(x + w // 2, 53, 1, 6, WHITE)
    elif n == 2:    # sleigh across the moon
        sky(i, "0a1030", "2a3870", stars=40)
        i.disc(40, 20, 12, rgb("f4f0d0"))
        for k in range(14):                                     # sleigh and reindeer
            i.put(27 + k, 22 + (k % 3 == 0), rgb("101018"))
        i.rect(36, 18, 8, 4, rgb("101018"))
        snow_ground(i, 48)
        for x in (6, 16, 50, 58):
            pine(i, x, 52, 14, dark=True)
    elif n == 3:    # snowman in a snowfall
        sky(i, "7aa0d0", "c8d8f0")
        snow_ground(i, 44)
        i.disc(32, 46, 10, rgb("f8faff"), light=True)
        i.disc(32, 31, 7, rgb("f8faff"), light=True)
        i.disc(32, 20, 5, rgb("f8faff"), light=True)
        i.rect(27, 13, 10, 2, rgb("1a1a1a"))                    # hat
        i.rect(29, 7, 6, 6, rgb("1a1a1a"))
        i.put(30, 19, rgb("101010"))
        i.put(34, 19, rgb("101010"))
        i.rect(32, 21, 3, 1, rgb("f08020"))                     # carrot nose
        i.rect(26, 25, 12, 2, RED)                              # scarf
        for y in (29, 33, 37):
            i.put(32, y, rgb("202020"))
        falling_snow(i)
    elif n == 4:    # village by a frozen river at dusk
        sky(i, "f0a070", "6a5a9a")
        for x, y, w in ((8, 30, 12), (26, 32, 10), (42, 29, 14)):
            house(i, x, y, w, 9)
        i.rect(0, 41, 64, 8, rgb("a8c8e8"))                    # frozen river
        for x in range(0, 64, 5):
            i.put(x, 44, rgb("e0f0ff"))
        snow_ground(i, 49, wave=1)
        for x in (4, 58):
            pine(i, x, 40, 16, dark=True)
    elif n == 5:    # mountains and a cabin under the stars
        sky(i, "101838", "34407a", stars=50)
        for peak, h, c in ((14, 26, "5a6a8a"), (36, 34, "4a5a7a"), (56, 22, "5a6a8a")):
            i.poly([(peak - 22, 52), (peak, 52 - h), (peak + 22, 52)], rgb(c))
            i.poly([(peak - 6, 52 - h + 8), (peak, 52 - h), (peak + 6, 52 - h + 8)], rgb("f0f4fa"))
        snow_ground(i, 50)
        house(i, 36, 46, 12, 8)
        pine(i, 22, 54, 12, dark=True)
    elif n == 6:    # a reindeer in a snowy forest
        sky(i, "a8bcd8", "dce6f2")
        for x in (6, 14, 50, 58, 30):
            pine(i, x, 44, 26, dark=x == 30)
        snow_ground(i, 44)
        i.rect(22, 38, 16, 7, rgb("7a5232"))                    # body
        i.rect(36, 32, 5, 7, rgb("7a5232"))                     # neck and head
        i.rect(40, 31, 3, 3, rgb("7a5232"))
        for x in (23, 26, 33, 36):
            i.rect(x, 45, 2, 7, rgb("5a3a22"))                  # legs
        for x, y in ((37, 30), (36, 29), (35, 28), (38, 29), (39, 28), (40, 27)):
            i.put(x, y, rgb("d8c8a0"))                          # antlers
        i.put(43, 32, RED)                                      # red nose
        falling_snow(i, 30)
    frame(i)
    return i


def main(game):
    out = lambda name: os.path.join(game, DIR % name)
    items = {
        "nodes_christmas_star": star(),
        "nodes_reef": wreath(),
        "nodes_icicles": icicles(),
        "nodes_garland_white": garland_white(),
        "nodes_bell": bell(),
        "stocking": stocking("c8202c"),
        "green_stocking": stocking("1e8a3a"),
        "nodes_mistletoe": mistletoe(),
        "items_sugar_cookie": sugar_cookie("plain"),
        "items_sugar_cookie_star": sugar_cookie("star"),
        "items_sugar_cookie_tree": sugar_cookie("tree"),
        "items_sugar_cookie_bell": sugar_cookie("bell"),
        "items_peppermint_candies": peppermint_candies("d0202c"),
        "items_green_peppermint_candies": peppermint_candies("1e8a3a"),
        "items_gingerbread": gingerbread(),
        "nodes_candy_cane_block": candy_cane_block("d0202c"),
        "nodes_green_candy_cane_block": candy_cane_block("1e8a3a"),
        "nodes_gingerbread_block": gingerbread_block(),
        "crops_ginger_root": ginger_root(),
        "crops_peppermint_leaf": peppermint_leaf(),
        "crops_peppermint_seeds": peppermint_seeds(),
        "tool_sword_cane": cane_tool("sword"),
        "tool_pick_cane": cane_tool("pick"),
        "tool_axe_cane": cane_tool("axe"),
    }
    for colour, hexc in (("blue", "2a6ad0"), ("green", "1e9a48"), ("orange", "e07a1a"),
                         ("pink", "e050a8"), ("purple", "7a3ac8"), ("red", "d0283a"),
                         ("white", "d8d8e0"), ("yellow", "d8c020")):
        items["nodes_ornament_" + colour] = ornament(hexc)
    for stage in range(4):
        items["crops_ginger_stage_%d" % stage] = plant(stage, "ginger")
        items["crops_peppermint_stage_%d" % stage] = plant(stage, "peppermint")
    for kind in ("helmet", "chestplate", "leggings", "boots", "shield"):
        items["armor_%s_cane_inv" % kind] = cane_armor_icon(kind)
        items["%s_cane" % kind] = restripe(out("%s_cane" % kind))
        items["%s_cane_preview" % kind] = restripe(out("%s_cane_preview" % kind))
    for n in range(1, 7):
        items["painting_%02d" % n] = painting(n)
    for name, icon in items.items():
        icon.save(out(name))


if __name__ == "__main__":
    main(sys.argv[1])
