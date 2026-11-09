#!/usr/bin/env python3
"""Generate MeseCraft's humanoid mob skins.

Every skin made here is original art for MeseCraft, built from code: noise,
palettes and a few hand-placed details such as eyes and mouths. Nothing is
traced or sampled from other games or skin sites. Re-running the script gives
the same images, because each skin seeds its own random generator.

Skins use the classic 64x32 character layout that mobs_character.b3d expects.

Usage: python3 skingen.py OUTPUT_DIR [skin_name ...]
"""

import os
import random
import sys

from PIL import Image

W, H = 64, 32

# ---------------------------------------------------------------------------
# Skin layout. Each body part is a box; its six faces sit at fixed places in
# the 64x32 texture. (x, y, width, height) for each face.
# ---------------------------------------------------------------------------


def box_faces(u, v, w, h, d):
    """Faces of a box unwrapped the standard way, starting at (u, v).

    w, h and d are the box's width, height and depth in pixels.
    """
    return {
        "top": (u + d, v, w, d),
        "bottom": (u + d + w, v, w, d),
        "right": (u, v + d, d, h),
        "front": (u + d, v + d, w, h),
        "left": (u + d + w, v + d, d, h),
        "back": (u + d + w + d, v + d, w, h),
    }


PARTS = {
    "head": box_faces(0, 0, 8, 8, 8),
    "body": box_faces(16, 16, 8, 12, 4),
    "arm": box_faces(40, 16, 4, 12, 4),
    "leg": box_faces(0, 16, 4, 12, 4),
}

# Shading per face, so the flat texture reads as a lit 3D shape in game.
FACE_LIGHT = {"top": 1.12, "front": 1.0, "left": 0.9, "right": 0.9,
              "back": 0.85, "bottom": 0.7}

# ---------------------------------------------------------------------------
# Colour helpers
# ---------------------------------------------------------------------------


def hexc(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def shade(c, f):
    return tuple(max(0, min(255, int(round(v * f)))) for v in c[:3]) + (c[3],)


def mix(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(4))


class Skin:
    """A 64x32 skin being painted, with its own seeded random generator."""

    def __init__(self, name):
        self.img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        self.px = self.img.load()
        self.rng = random.Random(name)

    # -- filling ------------------------------------------------------------

    def fill(self, part, palette, faces=None, rows=None, cols=None,
             material=None, light=True):
        """Paint a part's faces with a material.

        palette is a list of colours from dark to light. material(skin, gx,
        gy, lx, ly, face) returns a 0..1 value picking from the palette; by
        default it is random grain. rows/cols limit painting to a range of
        local coordinates on each face, so clothes can cover part of a limb.
        """
        material = material or grain()
        for face, (x0, y0, w, h) in PARTS[part].items():
            if faces and face not in faces:
                continue
            for ly in range(h):
                if rows and not rows[0] <= ly <= rows[1]:
                    continue
                for lx in range(w):
                    if cols and not cols[0] <= lx <= cols[1]:
                        continue
                    t = material(self, x0 + lx, y0 + ly, lx, ly, face)
                    t = max(0.0, min(0.999, t))
                    c = palette[int(t * len(palette))]
                    if light:
                        c = shade(c, FACE_LIGHT[face])
                    self.px[x0 + lx, y0 + ly] = c

    def fill_all(self, palette, material=None):
        for part in PARTS:
            self.fill(part, palette, material=material)

    # -- detail drawing ---------------------------------------------------------

    def put(self, part, face, lx, ly, color):
        """Set one pixel in a face's local coordinates."""
        x0, y0, w, h = PARTS[part][face]
        if 0 <= lx < w and 0 <= ly < h:
            self.px[x0 + lx, y0 + ly] = color

    def rect(self, part, face, lx, ly, w, h, color):
        for y in range(ly, ly + h):
            for x in range(lx, lx + w):
                self.put(part, face, x, y, color)

    def get(self, part, face, lx, ly):
        x0, y0, _, _ = PARTS[part][face]
        return self.px[x0 + lx, y0 + ly]

    def band(self, part, ly, h, color, faces=("front", "back", "left", "right")):
        """A horizontal band around a limb or the body, such as a belt."""
        for face in faces:
            _, _, w, _ = PARTS[part][face]
            for y in range(ly, ly + h):
                for x in range(w):
                    self.put(part, face, x, y, shade(color, FACE_LIGHT[face]))

    def speckle(self, part, color, chance, faces=None, rows=None):
        """Scatter single pixels of a colour, such as pebbles or pores."""
        for face, (x0, y0, w, h) in PARTS[part].items():
            if faces and face not in faces:
                continue
            for ly in range(h):
                if rows and not rows[0] <= ly <= rows[1]:
                    continue
                for lx in range(w):
                    if self.rng.random() < chance:
                        self.px[x0 + lx, y0 + ly] = shade(color, FACE_LIGHT[face])

    def cracks(self, part, color, count, length=5, faces=None):
        """Random-walk lines, used for cracks, veins and lava seams."""
        for face, (x0, y0, w, h) in PARTS[part].items():
            if faces and face not in faces:
                continue
            for _ in range(count):
                x, y = self.rng.randrange(w), self.rng.randrange(h)
                for _ in range(length):
                    self.px[x0 + x, y0 + y] = color
                    x = max(0, min(w - 1, x + self.rng.choice((-1, 0, 1))))
                    y = max(0, min(h - 1, y + self.rng.choice((0, 1, 1))))

    def eyes(self, row, color, pupil=None, gap=2, width=2):
        """Two eyes on the head's front face, centred left to right."""
        left = (8 - (2 * width + gap)) // 2
        for i in range(2):
            x = left + i * (width + gap)
            self.rect("head", "front", x, row, width, 1, color)
            if pupil:
                self.put("head", "front", x + (1 - i) * (width - 1), row, pupil)

    def save(self, path):
        self.img.save(path, optimize=True)


# ---------------------------------------------------------------------------
# Materials: functions returning 0..1 for each pixel
# ---------------------------------------------------------------------------


def grain(bias=0.5, spread=0.5):
    """Plain random grain around a brightness."""
    def m(skin, gx, gy, lx, ly, face):
        return bias + (skin.rng.random() - 0.5) * 2 * spread
    return m


def blotches(scale=3, spread=0.35):
    """Clumpy noise: brightness changes in patches rather than per pixel."""
    cache = {}

    def m(skin, gx, gy, lx, ly, face):
        key = (gx // scale, gy // scale)
        if key not in cache:
            cache[key] = skin.rng.random()
        return cache[key] * (1 - spread) + skin.rng.random() * spread
    return m


def vertical(top, bottom, spread=0.2):
    """Brightness that changes from the top of the figure to the bottom.

    Uses the pixel's height on the standing figure, so head, body and legs
    line up into one gradient.
    """
    def m(skin, gx, gy, lx, ly, face):
        figure_y = figure_height(gx, gy, lx, ly, face)
        t = top + (bottom - top) * figure_y
        return t + (skin.rng.random() - 0.5) * 2 * spread
    return m


def figure_height(gx, gy, lx, ly, face):
    """Approximate height on the figure, 0 at the top of the head, 1 at the feet."""
    for part, faces in PARTS.items():
        for f, (x0, y0, w, h) in faces.items():
            if x0 <= gx < x0 + w and y0 <= gy < y0 + h:
                start, size = {"head": (0, 8), "body": (8, 12),
                               "arm": (8, 12), "leg": (20, 12)}[part]
                if f in ("top", "bottom"):
                    return (start + (0 if f == "top" else size)) / 32
                return (start + ly + 0.5) / 32
    return 0.5


def scales(spread=0.25):
    """Overlapping scales: a lighter rim on every other pixel in a staggered grid."""
    def m(skin, gx, gy, lx, ly, face):
        rim = 0.75 if (lx + (ly // 2) % 2) % 2 == 0 and ly % 2 == 0 else 0.35
        return rim + (skin.rng.random() - 0.5) * spread
    return m


def facets(cells=7):
    """Crystal facets: each pixel takes the shade of the nearest of a few
    random points, giving flat angular shards."""
    def m(skin, gx, gy, lx, ly, face):
        key = ("facets", face, gx // 8, gy // 8)
        pts = skin.__dict__.setdefault("_facets", {})
        if key not in pts:
            pts[key] = [(skin.rng.random() * 8, skin.rng.random() * 12,
                         skin.rng.random()) for _ in range(cells)]
        best = min(pts[key], key=lambda p: (p[0] - lx % 8) ** 2 + (p[1] - ly) ** 2)
        return best[2] * 0.85 + skin.rng.random() * 0.15
    return m


def ripples(period=3, spread=0.25):
    """Wavy horizontal bands, for water and sand."""
    def m(skin, gx, gy, lx, ly, face):
        wave = ((ly + (lx // 2) % 2) % period) / (period - 1)
        return 0.3 + wave * 0.45 + (skin.rng.random() - 0.5) * spread
    return m


def plates(size=4):
    """Metal plates: flat panels with darker seams and a lit top edge."""
    def m(skin, gx, gy, lx, ly, face):
        if ly % size == 0:
            return 0.95
        if ly % size == size - 1 or lx % (size * 2) == 0:
            return 0.1
        return 0.55 + (skin.rng.random() - 0.5) * 0.15
    return m


# ---------------------------------------------------------------------------
# Skins
# ---------------------------------------------------------------------------

SKINS = {}


def skin(fn):
    SKINS[fn.__name__] = fn
    return fn


def P(*cols, a=255):
    return [hexc(c, a) for c in cols]


@skin
def astronaut(s, dirty=False):
    suit = P("a8aab0", "c4c6cc", "d8dae0", "e8eaee")
    if dirty:
        suit = P("6e6a60", "8a8478", "a49c8c", "b8b0a0")
    s.fill_all(suit, blotches(2, 0.5))
    # Gloves and boots.
    dark = hexc("3c3f46")
    s.fill("arm", P("33363c", "41454c"), rows=(10, 11))
    s.fill("arm", P("33363c", "41454c"), faces=("bottom",))
    s.fill("leg", P("2c2f35", "3a3d44"), rows=(9, 11))
    s.fill("leg", P("2c2f35"), faces=("bottom",))
    # Mese-yellow stripes on the upper arms and a belt.
    mese = hexc("e2b23a")
    s.band("arm", 2, 1, mese)
    s.band("body", 10, 1, hexc("50545c"))
    # Helmet: visor across the front of the head.
    s.rect("head", "front", 1, 2, 6, 4, hexc("16233c"))
    s.rect("head", "front", 2, 3, 4, 2, hexc("1f3354"))
    s.put("head", "front", 2, 2, hexc("7aa2e0"))
    s.put("head", "front", 3, 2, hexc("4e74b4"))
    s.rect("head", "front", 0, 6, 8, 2, dark)          # neck ring
    s.band("head", 7, 1, hexc("50545c"))
    # Chest control panel with status lights.
    s.rect("body", "front", 2, 2, 4, 3, hexc("50545c"))
    s.put("body", "front", 2, 2, hexc("e04040"))
    s.put("body", "front", 4, 2, hexc("40d060"))
    s.put("body", "front", 3, 3, mese)
    # Life-support pack on the back.
    s.rect("body", "back", 1, 1, 6, 8, hexc("7c8088"))
    s.rect("body", "back", 2, 2, 4, 1, hexc("5a5e66"))
    s.rect("body", "back", 2, 6, 4, 1, hexc("5a5e66"))
    s.put("body", "back", 3, 4, hexc("40d060"))
    if dirty:
        # Space zombie: torn suit, blood, and a cracked visor with a rotten
        # face behind it.
        s.cracks("body", hexc("5a2020"), 3, 4)
        s.cracks("leg", hexc("5a2020"), 1, 4)
        s.speckle("body", hexc("3a1414"), 0.08)
        s.rect("head", "front", 1, 2, 6, 4, hexc("4e6a44"))
        s.rect("head", "front", 1, 3, 2, 1, hexc("101010"))
        s.rect("head", "front", 5, 3, 2, 1, hexc("101010"))
        s.put("head", "front", 2, 3, hexc("d8d0a0"))
        s.put("head", "front", 5, 3, hexc("d8d0a0"))
        s.rect("head", "front", 2, 5, 4, 1, hexc("2a1010"))
        s.put("head", "front", 6, 2, hexc("9ab0c8"))   # shards of visor glass
        s.put("head", "front", 5, 2, hexc("16233c"))
        s.put("head", "front", 1, 4, hexc("16233c"))


@skin
def zombie_space(s):
    astronaut(s, dirty=True)


@skin
def blood_man(s):
    s.fill_all(P("3e0508", "5a0a0e", "741014", "8e161a", "a8202a"), blotches(2, 0.6))
    # Glossy highlights where light catches the liquid.
    s.speckle("head", hexc("d85060"), 0.05, faces=("top", "front"))
    s.speckle("body", hexc("d85060"), 0.04)
    s.speckle("arm", hexc("d85060"), 0.04)
    # Drips running down the legs and arms.
    for part in ("leg", "arm"):
        s.cracks(part, hexc("2a0204"), 2, 6)
    s.eyes(3, hexc("140000"))
    s.put("head", "front", 2, 3, hexc("ffb040"))
    s.put("head", "front", 5, 3, hexc("ffb040"))
    s.rect("head", "front", 2, 5, 4, 2, hexc("1e0002"))


@skin
def bogeyman(s):
    s.fill_all(P("08080b", "0e0e13", "15151c", "1c1c26"), blotches(2, 0.5))
    # A ragged cloak: lighter tatters down the body and legs.
    s.cracks("body", hexc("2a2a38"), 4, 6)
    s.cracks("leg", hexc("2a2a38"), 2, 6)
    s.cracks("arm", hexc("2a2a38"), 1, 6)
    # Hood shadow over the top of the face.
    s.rect("head", "front", 0, 0, 8, 2, hexc("050507"))
    # Pale, staring eyes and a long jagged grin.
    s.eyes(3, hexc("e4e8ff"), pupil=hexc("7080c0"), gap=2, width=2)
    for x in range(1, 7):
        s.put("head", "front", x, 5 + (x % 2), hexc("d8d0bc"))
        s.put("head", "front", x, 6 - (x % 2), hexc("1a0a10"))
    # Long, thin fingers.
    for face in ("front", "back", "left", "right"):
        s.put("arm", face, 1, 11, hexc("c8c4b8"))
        s.put("arm", face, 3, 11, hexc("c8c4b8"))


@skin
def boomer(s):
    # A bloated creature full of volatile gas: sickly skin and glowing boils.
    s.fill_all(P("4a5422", "5a662a", "6a7832", "7a8a3c"), blotches(2, 0.5))
    s.cracks("body", hexc("c46a20"), 4, 5)
    s.cracks("arm", hexc("c46a20"), 1, 4)
    s.cracks("leg", hexc("c46a20"), 1, 4)
    for part in ("body", "head", "arm"):
        s.speckle(part, hexc("f2d850"), 0.06, faces=("front", "left", "right", "top"))
    # Swollen, glowing belly.
    s.rect("body", "front", 2, 4, 4, 5, hexc("b8b040"))
    s.rect("body", "front", 3, 5, 2, 3, hexc("f2e070"))
    # Small sunken eyes and a stitched-shut mouth.
    s.eyes(3, hexc("161808"), gap=4, width=1)
    s.rect("head", "front", 2, 5, 4, 1, hexc("2a2e10"))
    for x in (2, 4):
        s.put("head", "front", x, 6, hexc("2a2e10"))
        s.put("head", "front", x + 1, 4, hexc("2a2e10"))


@skin
def assault_tripod(s):
    # A SynTek war machine: gunmetal plating and a single red sensor.
    s.fill_all(P("2a2d32", "3a3e44", "4a4f56", "5c626a", "7a8088"), plates(4))
    s.speckle("body", hexc("9aa0a8"), 0.05, faces=("front", "back"))
    # Sensor visor.
    s.rect("head", "front", 1, 3, 6, 2, hexc("1a0606"))
    s.rect("head", "front", 2, 3, 4, 1, hexc("ff3020"))
    s.put("head", "front", 3, 4, hexc("ff8060"))
    s.rect("head", "front", 2, 6, 4, 1, hexc("1c1e22"))  # vent grille
    # Hazard stripes across the chest and a glowing power core.
    for x in range(8):
        s.put("body", "front", x, 1, hexc("e0b020") if x % 2 == 0 else hexc("1a1a1a"))
    s.rect("body", "front", 3, 4, 2, 2, hexc("ff5a20"))
    s.put("body", "front", 3, 4, hexc("ffd080"))
    # Arm cannons: dark barrels with a hot muzzle at the end.
    s.fill("arm", P("1e2024", "2a2d32"), rows=(8, 11))
    s.fill("arm", P("ff6020"), faces=("bottom",))
    s.put("arm", "bottom", 1, 1, hexc("1a0a06"))
    s.put("arm", "bottom", 2, 2, hexc("1a0a06"))
    # Piston legs.
    s.fill("leg", P("23262b", "30343a", "43484f"), cols=(1, 2), rows=(2, 9))
    s.band("leg", 11, 1, hexc("1a1c20"))


@skin
def diamond_man(s):
    s.fill_all(P("1d6470", "2a8a9a", "3fb0c0", "6ad8e0", "b0f4f8"), facets())
    s.eyes(3, hexc("08262c"))
    s.put("head", "front", 2, 3, hexc("e8ffff"))
    s.put("head", "front", 5, 3, hexc("e8ffff"))
    s.rect("head", "front", 3, 5, 2, 1, hexc("0e3a42"))


@skin
def dirt_man(s):
    s.fill_all(P("3e2a1a", "4e3622", "5e422a", "6e4e32", "7e5a3a"), blotches(2, 0.6))
    for part in PARTS:
        s.speckle(part, hexc("8a8478"), 0.04)          # pebbles
    for part in ("body", "leg", "arm"):
        s.cracks(part, hexc("2a1c10"), 2, 5)           # roots
    # Moss and a few sprouts on top, as if it climbed out of the ground.
    s.speckle("head", hexc("4e7a2a"), 0.35, faces=("top",))
    s.speckle("arm", hexc("4e7a2a"), 0.3, faces=("top",))
    s.put("head", "top", 3, 3, hexc("76a83a"))
    s.put("head", "top", 4, 5, hexc("76a83a"))
    s.eyes(3, hexc("140c06"))
    s.put("head", "front", 2, 3, hexc("e0a040"))
    s.put("head", "front", 5, 3, hexc("e0a040"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("1e140a"))


@skin
def fire_imp(s):
    s.fill_all(P("7a1810", "9a2414", "b8341a", "d24a22"), blotches(2, 0.4))
    # Darker, ember-scarred limbs and a soot-black belly.
    s.fill("leg", P("3a0c08", "5a1410"), rows=(8, 11))
    s.fill("arm", P("3a0c08", "5a1410"), rows=(10, 11))
    s.rect("body", "front", 2, 3, 4, 7, hexc("4a120c"))
    s.speckle("body", hexc("ffb040"), 0.05)
    # Little horns at the top corners of the head.
    for face in ("front", "back"):
        s.put("head", face, 0, 0, hexc("e8d8b0"))
        s.put("head", face, 7, 0, hexc("e8d8b0"))
    s.put("head", "top", 0, 7, hexc("e8d8b0"))
    s.put("head", "top", 7, 7, hexc("e8d8b0"))
    s.eyes(3, hexc("ffe040"), pupil=hexc("3a0800"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("2a0604"))
    s.put("head", "front", 2, 6, hexc("f0e8d0"))
    s.put("head", "front", 5, 6, hexc("f0e8d0"))


@skin
def fire_man(s):
    # Flames: hot yellow at the top, deep red at the feet, with flicker.
    s.fill_all(P("7a0e04", "a01808", "c83a0a", "e86010", "f89020", "ffc030", "ffe070"),
               vertical(0.95, 0.15, 0.22))
    s.eyes(3, hexc("fff8d0"), gap=2, width=2)
    s.rect("head", "front", 2, 5, 4, 1, hexc("fff0b0"))


@skin
def ghost(s, murderous=False):
    if murderous:
        s.fill_all(P("16161a", "222228", "2e2e36", "3c3c46"), vertical(0.8, 0.2, 0.25))
    else:
        s.fill_all(P("8e9aa8", "aab6c2", "c6d0da", "dde6ef", "eef3f8"),
                   vertical(0.85, 0.25, 0.2))
    # Wispy, fading lower body.
    s.cracks("leg", hexc("6a7684") if not murderous else hexc("08080a"), 3, 6)
    s.cracks("body", hexc("7e8a98") if not murderous else hexc("0c0c10"), 2, 5)
    if murderous:
        s.eyes(3, hexc("ff2020"), gap=2, width=2)
        s.put("head", "front", 2, 4, hexc("8a0a0a"))
        s.put("head", "front", 5, 5, hexc("8a0a0a"))
        s.rect("head", "front", 2, 6, 4, 1, hexc("050505"))
        s.cracks("arm", hexc("6a0a0a"), 1, 4, faces=("front",))
    else:
        s.rect("head", "front", 1, 2, 2, 3, hexc("1a1e26"))
        s.rect("head", "front", 5, 2, 2, 3, hexc("1a1e26"))
        s.rect("head", "front", 3, 5, 2, 2, hexc("2a3038"))


@skin
def ghost_murderous(s):
    ghost(s, murderous=True)


@skin
def gold_man(s):
    # Brushed gold: horizontal streaks of light.
    def brushed(skin, gx, gy, lx, ly, face):
        return 0.35 + 0.45 * ((ly * 7 + gx) % 5) / 4 + (skin.rng.random() - 0.5) * 0.2
    s.fill_all(P("6e5008", "8a6a10", "b08a18", "d4aa28", "f0d060"), brushed)
    s.speckle("body", hexc("fff2b0"), 0.03)
    s.eyes(3, hexc("3a2a04"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("4a3606"))


def grey_alien(s):
    """Skin and face shared by the grey civilian and enlisted aliens."""
    skin = P("8c9096", "9a9ea4", "a8acb2", "b4b8be")
    s.fill("head", skin, material=blotches(2, 0.4))
    s.fill("arm", skin, rows=(10, 11))
    s.fill("arm", skin, faces=("bottom",))
    # Large, slanted black eyes with a glint.
    eye = hexc("0a0a0e")
    for x, y in ((0, 2), (1, 2), (0, 3), (1, 3), (2, 3), (1, 4), (2, 4)):
        s.put("head", "front", x, y, eye)
        s.put("head", "front", 7 - x, y, eye)
    s.put("head", "front", 1, 3, hexc("6a7080"))
    s.put("head", "front", 6, 3, hexc("6a7080"))
    s.put("head", "front", 3, 6, hexc("6a6e74"))
    s.put("head", "front", 4, 6, hexc("6a6e74"))


@skin
def grey_civilian(s):
    s.fill("body", P("564c6a", "625878", "6e6484", "7a7090"), material=blotches(2, 0.4))
    s.fill("arm", P("564c6a", "625878", "6e6484"), material=blotches(2, 0.4))
    s.fill("leg", P("4a4260", "564c6a", "625878"), material=blotches(2, 0.4))
    grey_alien(s)
    # A pale collar and a small badge.
    s.rect("body", "front", 2, 0, 4, 1, hexc("b8b0cc"))
    s.put("body", "front", 5, 3, hexc("60d0c8"))


@skin
def grey_enlisted(s):
    armour = P("161a24", "1e2230", "262c3c", "303848")
    s.fill("body", armour, material=plates(3))
    s.fill("arm", armour, material=plates(3))
    s.fill("leg", armour, material=plates(4))
    grey_alien(s)
    # Teal light strips on the armour, and a belt.
    trim = hexc("30d0c0")
    for y in range(0, 12, 3):
        s.put("body", "front", 0, y, trim)
        s.put("body", "front", 7, y, trim)
    s.band("arm", 3, 1, hexc("1c8a80"))
    s.band("body", 9, 1, hexc("0c0e14"))
    s.put("body", "front", 3, 9, trim)
    s.rect("body", "front", 3, 2, 2, 2, hexc("1c8a80"))


@skin
def pain_lord(s):
    # Bone plates over dark muscle, glowing green eyes and hooves.
    s.fill_all(P("4a1014", "5a1418", "702028", "84303a"), blotches(2, 0.5))
    bone = P("a8a088", "c0b8a0", "d8d0b8", "ece4cc")
    s.fill("body", bone, faces=("front",), rows=(0, 4), material=blotches(2, 0.4))
    s.rect("body", "front", 3, 0, 2, 5, hexc("4a1014"))   # gap between chest plates
    s.fill("arm", bone, rows=(0, 3), material=blotches(2, 0.4))
    s.fill("arm", bone, faces=("top",))
    s.fill("leg", bone, rows=(2, 5), material=blotches(2, 0.4))
    s.fill("leg", P("1a1210", "241a16"), rows=(10, 11))    # hooves
    s.fill("head", bone, faces=("top",))
    # A crest of bone horns across the brow.
    for x in range(8):
        if x % 2 == 0:
            s.put("head", "front", x, 0, hexc("ece4cc"))
    s.rect("head", "front", 0, 1, 8, 1, hexc("c0b8a0"))
    s.eyes(3, hexc("60ff60"), pupil=hexc("d0ffd0"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("1a0406"))
    s.put("head", "front", 2, 6, hexc("ece4cc"))
    s.put("head", "front", 5, 6, hexc("ece4cc"))


@skin
def serpentipede(s):
    # A scaled, serpent-like hunter with a pale belly and spines.
    s.fill_all(P("33341a", "44451e", "565626", "68682e", "7a7a38"), scales())
    s.fill("body", P("8e8250", "a4985e", "b4a86c"), faces=("front",), cols=(2, 5),
           material=ripples(2, 0.15))
    s.fill("head", P("8e8250", "a4985e"), faces=("front",), rows=(5, 7), cols=(2, 5))
    for y in range(0, 12, 2):                       # spines down the back
        s.put("body", "back", 3, y, hexc("1e1e0c"))
        s.put("body", "back", 4, y + 1, hexc("1e1e0c"))
    s.eyes(3, hexc("f0d020"), gap=2, width=2)
    s.put("head", "front", 2, 3, hexc("101000"))    # slit pupils
    s.put("head", "front", 5, 3, hexc("101000"))
    s.rect("head", "front", 2, 6, 4, 1, hexc("2a1a0a"))
    for face in ("front", "left", "right", "back"):
        s.put("arm", face, 0, 11, hexc("e0d8b8"))   # claws
        s.put("arm", face, 2, 11, hexc("e0d8b8"))


@skin
def iron_man(s):
    s.fill_all(P("54585e", "6a6e74", "80848a", "969aa0", "b0b4ba"), plates(4))
    for part in ("body", "arm", "leg"):
        s.speckle(part, hexc("c8ccd2"), 0.04)        # rivets
    s.cracks("body", hexc("8a5a30"), 1, 3)          # a little rust
    s.eyes(3, hexc("101418"))
    s.put("head", "front", 2, 3, hexc("80c0ff"))
    s.put("head", "front", 5, 3, hexc("80c0ff"))
    s.rect("head", "front", 1, 5, 6, 1, hexc("2a2e34"))


@skin
def magma_man(s):
    s.fill_all(P("140f0c", "1c1612", "261e18", "30261e"), blotches(2, 0.5))
    for part, n in (("head", 2), ("body", 4), ("arm", 2), ("leg", 2)):
        s.cracks(part, hexc("ff7a18"), n, 6)
        s.cracks(part, hexc("ffb040"), max(1, n // 2), 3)
        s.cracks(part, hexc("c83a10"), n, 4)
    s.eyes(3, hexc("fff060"), gap=2, width=2)
    s.rect("head", "front", 2, 5, 4, 1, hexc("ff8a20"))


@skin
def combat_slug(s):
    # A fat, slimy slug creature with metal arm cannons.
    s.fill_all(P("5e6850", "6e7860", "7e8870", "8e9880", "a0aa90"), blotches(2, 0.6))
    s.speckle("body", hexc("3e4636"), 0.12)
    s.speckle("head", hexc("3e4636"), 0.1)
    s.speckle("body", hexc("c8d0b8"), 0.04)          # slime shine
    s.rect("body", "front", 1, 3, 6, 7, hexc("a8ae94"))  # swollen belly
    s.fill("body", P("98a084", "a8ae94", "b6bca2"), faces=("front",), rows=(3, 9),
           cols=(1, 6), material=ripples(3, 0.15))
    metal = P("2e3238", "3c4148", "4c525a", "5e646c")
    s.fill("arm", metal, rows=(4, 11), material=plates(3))
    s.fill("arm", P("ff6a20"), faces=("bottom",))
    s.put("arm", "bottom", 1, 1, hexc("2a0e04"))
    s.put("arm", "bottom", 2, 2, hexc("2a0e04"))
    s.eyes(2, hexc("0e100a"), gap=4, width=1)
    s.rect("head", "front", 1, 4, 6, 3, hexc("2e1a14"))  # wide mouth
    for x in range(1, 7, 2):
        s.put("head", "front", x, 4, hexc("d8d0b0"))
        s.put("head", "front", x + 1, 6, hexc("d8d0b0"))


@skin
def reptilian_elite(s):
    s.fill_all(P("22441e", "2e5a2a", "3a6e34", "4a8240", "5a9450"), scales())
    # Black armour with gold trim marks the elite.
    armour = P("121214", "1a1a1e", "242428")
    gold = hexc("d0a030")
    s.fill("body", armour, material=plates(3))
    s.fill("leg", armour, rows=(0, 8), material=plates(3))
    s.fill("arm", armour, rows=(0, 3), material=plates(2))
    s.band("body", 0, 1, gold)
    s.band("body", 9, 1, gold)
    s.band("arm", 3, 1, gold)
    s.rect("body", "front", 3, 3, 2, 3, gold)
    s.put("body", "front", 3, 4, hexc("e8d080"))
    s.eyes(3, hexc("f0d020"), gap=2, width=2)
    s.put("head", "front", 2, 3, hexc("101000"))
    s.put("head", "front", 5, 3, hexc("101000"))
    s.rect("head", "front", 2, 6, 4, 1, hexc("142810"))


@skin
def sand_man(s):
    s.fill_all(P("b09c70", "c2ae82", "d0bc92", "dcc8a0", "e8d8b2"), ripples(3, 0.35))
    for part in PARTS:
        s.speckle(part, hexc("8e7c56"), 0.06)
    s.eyes(3, hexc("3e3020"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("6a5838"))


@skin
def stone_man(s):
    s.fill_all(P("4e4e50", "5e5e60", "6e6e70", "7e7e80", "8e8e90"), blotches(3, 0.5))
    for part, n in (("head", 1), ("body", 3), ("arm", 1), ("leg", 1)):
        s.cracks(part, hexc("323234"), n, 5)
    s.speckle("head", hexc("4e7038"), 0.25, faces=("top",))
    s.speckle("arm", hexc("4e7038"), 0.15, faces=("top",))
    s.speckle("body", hexc("4e7038"), 0.04)
    s.eyes(3, hexc("1a1a1c"))
    s.put("head", "front", 2, 3, hexc("ffb040"))
    s.put("head", "front", 5, 3, hexc("ffb040"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("2a2a2c"))


@skin
def water_man(s):
    s.fill_all(P("163e84", "1e4e9e", "2a62b8", "3a78cc", "6aa0e0"), ripples(3, 0.3))
    for part in PARTS:
        s.speckle(part, hexc("b0d4f8"), 0.04)        # foam
    s.eyes(3, hexc("0a1e44"))
    s.put("head", "front", 2, 3, hexc("d8ecff"))
    s.put("head", "front", 5, 3, hexc("d8ecff"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("0e2a5a"))


@skin
def zombie(s):
    # A dead miner: grey-green skin, torn work shirt and overalls.
    skin_pal = P("4e5a40", "5e6a4c", "6e7a58", "7e8a66")
    s.fill("head", skin_pal, material=blotches(2, 0.5))
    s.fill("body", P("2e3a56", "3a4866", "465476"), material=blotches(2, 0.4))
    s.fill("arm", P("2e3a56", "3a4866", "465476"), rows=(0, 5))
    s.fill("arm", skin_pal, rows=(6, 11))
    s.fill("arm", skin_pal, faces=("bottom",))
    s.fill("leg", P("4a3826", "5a4430", "6a503a"), material=blotches(2, 0.4))
    s.fill("leg", P("1e1a16", "2a241e"), rows=(10, 11))
    # Overall straps and a brass buckle.
    s.rect("body", "front", 1, 0, 1, 7, hexc("5a4430"))
    s.rect("body", "front", 6, 0, 1, 7, hexc("5a4430"))
    s.rect("body", "front", 1, 7, 6, 5, hexc("5a4430"))
    s.put("body", "front", 1, 6, hexc("c8a040"))
    s.put("body", "front", 6, 6, hexc("c8a040"))
    # Tears that show rotten skin and wounds.
    for part, n in (("body", 3), ("leg", 2), ("arm", 1)):
        for _ in range(n):
            face = s.rng.choice(("front", "back", "left", "right"))
            _, _, w, h = PARTS[part][face]
            x, y = s.rng.randrange(w), s.rng.randrange(h)
            s.put(part, face, x, y, hexc("6e7a58"))
            s.put(part, face, min(w - 1, x + 1), y, hexc("5a1a16"))
    s.rect("head", "front", 1, 3, 2, 1, hexc("0e0e0a"))
    s.rect("head", "front", 5, 3, 2, 1, hexc("0e0e0a"))
    s.put("head", "front", 2, 3, hexc("d8d4a8"))
    s.put("head", "front", 5, 3, hexc("d8d4a8"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("1e1010"))
    s.put("head", "front", 3, 6, hexc("5a1a16"))
    s.put("head", "front", 6, 1, hexc("5a1a16"))


def main():
    out = sys.argv[1]
    names = sys.argv[2:] or list(SKINS)
    os.makedirs(out, exist_ok=True)
    for name in names:
        s = Skin(name)
        SKINS[name](s)
        s.save(os.path.join(out, "mesecraft_mobs_%s.png" % name))


if __name__ == "__main__":
    main()
