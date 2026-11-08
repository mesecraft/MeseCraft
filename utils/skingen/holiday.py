#!/usr/bin/env python3
"""Generate the Christmas and Halloween mob skins and costumes.

Original art for MeseCraft (AGPLv3, like the rest of the game), drawn with the
helpers in skingen.py. These replaced uncredited skins from skin sites and
costumes based on copyrighted characters (Kenny from South Park, Totoro,
Harry Potter, Michael Myers).

The Halloween zombies wear GreenXenith's costumes from the "halloween" mod
(MIT License) over a generated zombie; those costume files are read from the
game, not redrawn.

Costumes are 3d_armor textures: the same 64x32 layout as a skin, transparent
wherever the costume doesn't cover the player. Each costume also gets a 16x16
inventory icon made from its front view.

Usage: python3 holiday.py GAME_DIR
"""
import os
import sys

from PIL import Image

from skingen import P, PARTS, Skin, blotches, hexc, ripples, scales, zombie

XMAS = "mods/mesecraft_christmas/textures/"
HALLOWEEN = "mods/mesecraft_halloween/textures/"

SKIN = P("c8946c", "d4a07a", "dcac86")  # a plain human skin tone for faces
WHITE = P("d8d8d8", "e8e8e8", "f4f4f4")


def face(s, eyes="2a1e14", mouth="8a4a3a", skin=SKIN):
    """Fill the head with skin and draw simple eyes and a mouth."""
    s.fill("head", skin, material=blotches(2, 0.3))
    s.eyes(4, hexc("f0f0f0"), pupil=hexc(eyes))
    s.rect("head", "front", 3, 6, 2, 1, hexc(mouth))


def boots(s, colour="1a1614"):
    s.fill("leg", P(colour, colour), rows=(10, 11))
    s.fill("leg", P(colour), faces=("bottom",))


def hat(s, palette, band=None, tip=None, rows=3):
    """A hat: the top of the head plus the top rows of each side."""
    s.fill("head", palette, faces=("top",))
    s.fill("head", palette, faces=("front", "back", "left", "right"), rows=(0, rows - 1))
    if band:
        s.band("head", rows - 1, 1, hexc(band))
    if tip:
        s.put("head", "top", 3, 3, hexc(tip))
        s.put("head", "top", 4, 3, hexc(tip))
        s.put("head", "top", 3, 4, hexc(tip))
        s.put("head", "top", 4, 4, hexc(tip))


# ---------------------------------------------------------------------------
# Christmas mobs
# ---------------------------------------------------------------------------

def santa_suit(s, red=("8e141a", "a81c22", "c02428")):
    red = P(*red)
    s.fill("body", red, material=blotches(2, 0.3))
    s.fill("arm", red, material=blotches(2, 0.3))
    s.fill("leg", red, material=blotches(2, 0.3))
    s.band("arm", 10, 1, hexc("f0f0f0"))            # fur cuffs
    s.fill("arm", P("1e1e1e", "2a2a2a"), rows=(11, 11))  # gloves
    s.rect("body", "front", 3, 0, 2, 9, hexc("f0f0f0"))  # fur down the front
    s.band("body", 11, 1, hexc("f0f0f0"))
    s.band("body", 8, 1, hexc("161616"))              # belt
    s.rect("body", "front", 3, 8, 2, 1, hexc("e0b030"))
    boots(s)


def santa(s):
    face(s, eyes="3a5a9a")
    santa_suit(s)
    hat(s, P("a81c22", "c02428"), band="f0f0f0", tip="f8f8f8")
    # Beard and moustache.
    s.rect("head", "front", 1, 5, 6, 3, hexc("ececec"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("d8d8d8"))
    s.rect("head", "front", 3, 6, 2, 1, hexc("6a2a2a"))
    for side in ("left", "right"):
        s.rect("head", side, 0, 5, 8, 3, hexc("e4e4e4"))


def mrs_claus(s):
    face(s, eyes="4a6a3a", mouth="b04040")
    s.put("head", "front", 1, 3, hexc("8a6a20"))     # glasses
    s.rect("head", "front", 1, 3, 6, 1, hexc("8a6a20"))
    s.eyes(4, hexc("f0f0f0"), pupil=hexc("4a6a3a"))
    # White hair with a bun at the back.
    s.fill("head", WHITE, faces=("top", "back"))
    s.fill("head", WHITE, faces=("front", "left", "right"), rows=(0, 1))
    s.fill("head", WHITE, faces=("left", "right"), cols=(5, 7))
    s.rect("head", "back", 3, 1, 2, 2, hexc("c8c8c8"))
    dress = P("8e141a", "a81c22", "c02428")
    s.fill("body", dress, material=blotches(2, 0.3))
    s.fill("arm", dress, material=blotches(2, 0.3))
    s.fill("leg", dress, material=blotches(2, 0.3), rows=(0, 8))
    s.fill("arm", SKIN, rows=(10, 11))
    s.band("arm", 9, 1, hexc("f0f0f0"))
    s.rect("body", "front", 2, 4, 4, 8, hexc("f4f4f4"))   # apron
    s.rect("leg", "front", 0, 0, 4, 6, hexc("f4f4f4"))
    s.band("leg", 8, 1, hexc("f0f0f0"))
    s.fill("leg", P("e8d8d0"), rows=(9, 9))
    boots(s, "2a1a14")


def zombie_elf(s):
    skin = P("5e6a4c", "6e7a58", "7e8a66")
    s.fill("head", skin, material=blotches(2, 0.5))
    s.rect("head", "front", 1, 4, 2, 1, hexc("0e0e0a"))
    s.rect("head", "front", 5, 4, 2, 1, hexc("0e0e0a"))
    s.put("head", "front", 2, 4, hexc("d8d4a8"))
    s.put("head", "front", 5, 4, hexc("d8d4a8"))
    s.rect("head", "front", 2, 6, 4, 1, hexc("1e1010"))
    for side in ("left", "right"):                   # pointed ears
        s.put("head", side, 3, 3, hexc("7e8a66"))
    hat(s, P("1e5a28", "246a30"), band="c8a040")
    green = P("1a4a22", "1e5a28", "246a30")
    s.fill("body", green, material=blotches(2, 0.4))
    s.fill("arm", green, material=blotches(2, 0.4))
    s.fill("arm", skin, rows=(10, 11))
    s.band("body", 8, 1, hexc("2a1a10"))
    s.rect("body", "front", 3, 8, 2, 1, hexc("c8a040"))
    s.speckle("body", hexc("5a1a16"), 0.06)          # torn and stained
    for y in range(12):                                # striped stockings
        s.band("leg", y, 1, hexc("d02a2a") if y % 2 else hexc("f0f0f0"))
    boots(s, "1a4a22")


def krampus(s):
    s.fill_all(P("2a1a12", "3a2418", "4a2e1e", "5a3826"), blotches(2, 0.6))
    s.cracks("body", hexc("1a100a"), 4, 6)
    s.cracks("leg", hexc("1a100a"), 2, 6)
    # Dark goat face, yellow eyes and a long red tongue.
    s.rect("head", "front", 1, 2, 6, 6, hexc("1e140e"))
    s.eyes(3, hexc("e8c020"), pupil=hexc("1a0a00"))
    s.rect("head", "front", 3, 5, 2, 3, hexc("b02a30"))
    # Curling horns.
    for face_name in ("front", "back"):
        for x, y in ((0, 0), (1, 0), (6, 0), (7, 0)):
            s.put("head", face_name, x, y, hexc("d8ccb0"))
    for x, y in ((0, 6), (0, 7), (7, 6), (7, 7), (1, 7), (6, 7)):
        s.put("head", "top", x, y, hexc("d8ccb0"))
    # A chain across the chest and goat hooves.
    for i in range(8):
        s.put("body", "front", i, 2 + i // 2, hexc("8a8a90") if i % 2 else hexc("5a5a60"))
    s.fill("leg", P("141010", "1e1814"), rows=(10, 11))


def christmas_tree_man(s):
    s.fill_all(P("143a1a", "1a4a22", "205a2a", "286a32"), scales())
    s.fill("leg", P("4a3020", "5a3a26", "6a4430"), material=blotches(2, 0.4))
    s.fill("leg", P("8a2020", "a02828"), rows=(9, 11))  # the pot
    for part, n in (("body", 0.12), ("arm", 0.1), ("head", 0.06)):
        for colour in ("e02828", "e8c020", "2860e0", "e8e8f0"):
            s.speckle(part, hexc(colour), n / 4, faces=("front", "back", "left", "right"))
    s.eyes(4, hexc("f0e8a0"), pupil=hexc("1a1a1a"))
    s.rect("head", "front", 3, 6, 2, 1, hexc("0a200e"))
    # A star on top.
    s.fill("head", P("e8c020", "f8d838"), faces=("top",))


def candy_cane_man(s):
    def stripes(skin, gx, gy, lx, ly, face):
        return 0.9 if (lx + ly) % 4 < 2 else 0.1
    for part in PARTS:
        s.fill(part, [hexc("c81c24"), hexc("f4f4f4")], material=stripes, light=False)
    s.fill("head", P("eeeeee", "f8f8f8"), faces=("front",))
    s.eyes(3, hexc("1a1a1a"))
    s.rect("head", "front", 2, 5, 4, 1, hexc("c81c24"))
    s.put("head", "front", 1, 4, hexc("e87070"))     # rosy cheeks
    s.put("head", "front", 6, 4, hexc("e87070"))


def gingerbread_man(s):
    s.fill_all(P("8a5428", "9a602e", "aa6c36", "b8783e"), blotches(2, 0.4))
    icing = hexc("f4f0e8")
    for part in ("arm", "leg"):                      # icing zigzags on the cuffs
        for face_name in ("front", "back", "left", "right"):
            for x in range(4):
                s.put(part, face_name, x, 9 + (x % 2), icing)
    s.eyes(3, hexc("1a1a1a"))
    s.put("head", "front", 2, 5, icing)
    s.rect("head", "front", 3, 6, 2, 1, icing)
    s.put("head", "front", 5, 5, icing)
    for y, colour in ((2, "e02828"), (5, "28a040"), (8, "e02828")):  # gumdrop buttons
        s.rect("body", "front", 3, y, 2, 2, hexc(colour))


# ---------------------------------------------------------------------------
# Halloween mobs
# ---------------------------------------------------------------------------

def frankenstein(s):
    skin = P("5a7a44", "668a4e", "729658")
    s.fill("head", skin, material=blotches(2, 0.4))
    s.fill("head", P("101010", "1a1a1a"), faces=("top",))
    s.fill("head", P("101010", "1a1a1a"), faces=("front", "back", "left", "right"), rows=(0, 1))
    s.rect("head", "front", 1, 3, 6, 1, hexc("3a4a2a"))  # heavy brow
    s.eyes(4, hexc("d8d8b0"), pupil=hexc("1a1a1a"))
    s.rect("head", "front", 2, 6, 4, 1, hexc("2a3a1e"))
    for x in range(1, 7, 2):                         # stitches
        s.put("head", "front", x, 2, hexc("1e1e1e"))
    for side in ("left", "right"):                   # neck bolts
        s.put("head", side, 3, 7, hexc("8a8a90"))
        s.put("head", side, 4, 7, hexc("8a8a90"))
    coat = P("1e1e22", "26262c", "303036")
    s.fill("body", coat, material=blotches(2, 0.4))
    s.fill("arm", coat, rows=(0, 8))
    s.fill("arm", skin, rows=(9, 11))                # sleeves too short
    s.fill("leg", P("2a2620", "36302a"), material=blotches(2, 0.4))
    boots(s, "0e0e0e")


def grim_reaper(s):
    robe = P("0a0a0c", "121216", "1a1a20")
    s.fill_all(robe, blotches(2, 0.5))
    s.cracks("body", hexc("24242c"), 3, 7)
    s.cracks("leg", hexc("24242c"), 2, 7)
    # Skull face deep inside the hood.
    s.rect("head", "front", 2, 2, 4, 5, hexc("d8d4c4"))
    s.rect("head", "front", 2, 3, 1, 2, hexc("101010"))
    s.rect("head", "front", 5, 3, 1, 2, hexc("101010"))
    s.put("head", "front", 3, 5, hexc("6a665a"))
    s.put("head", "front", 4, 5, hexc("6a665a"))
    for x in range(2, 6):
        s.put("head", "front", x, 6, hexc("a8a494") if x % 2 else hexc("2a2a24"))
    s.fill("arm", P("c8c4b4", "d8d4c4"), rows=(11, 11))  # bony fingers


def scarecrow(s):
    s.fill("head", P("a88a50", "b8985a", "c8a664"), material=ripples(2, 0.3))  # sackcloth
    s.rect("head", "front", 1, 3, 2, 2, hexc("1a1208"))
    s.rect("head", "front", 5, 3, 2, 2, hexc("1a1208"))
    for x in range(1, 7):
        s.put("head", "front", x, 6, hexc("3a2a12") if x % 2 else hexc("a88a50"))
    hat(s, P("8a6a30", "9a7a3a", "aa8a44"), band="5a3a1a", rows=2)
    plaid = lambda skin, gx, gy, lx, ly, face: 0.9 if lx % 3 == 0 or ly % 3 == 0 else 0.3
    s.fill("body", P("6a1a1a", "a82828"), material=plaid)
    s.fill("arm", P("6a1a1a", "a82828"), material=plaid)
    s.fill("leg", P("1e2e5a", "28386a", "32427a"), material=blotches(2, 0.4))
    s.rect("body", "front", 1, 6, 6, 6, hexc("28386a"))   # overall bib
    s.rect("body", "front", 1, 0, 1, 6, hexc("28386a"))
    s.rect("body", "front", 6, 0, 1, 6, hexc("28386a"))
    for part in ("arm", "leg"):                      # straw poking out
        s.fill(part, P("d8b848", "e8c858"), rows=(11, 11))
        s.fill(part, P("d8b848"), faces=("bottom",))


def werewolf(s):
    s.fill_all(P("3a3028", "4a3e34", "5a4c40", "6a5a4c"), blotches(2, 0.6))
    s.cracks("body", hexc("2a221c"), 4, 5)
    # Snout, nose, fangs and yellow eyes.
    s.rect("head", "front", 2, 4, 4, 4, hexc("7a6a5a"))
    s.rect("head", "front", 3, 4, 2, 1, hexc("141010"))
    s.put("head", "front", 2, 7, hexc("f0ece0"))
    s.put("head", "front", 5, 7, hexc("f0ece0"))
    s.rect("head", "front", 3, 6, 2, 1, hexc("4a1416"))
    s.eyes(2, hexc("f0c020"), pupil=hexc("1a1000"), gap=4, width=1)
    for face_name in ("front", "back"):               # ears
        s.put("head", face_name, 0, 0, hexc("2a221c"))
        s.put("head", face_name, 7, 0, hexc("2a221c"))
    # Torn trousers and claws.
    s.fill("leg", P("2a3450", "343e5c"), rows=(0, 8), material=blotches(2, 0.4))
    s.speckle("leg", hexc("5a4c40"), 0.15, rows=(6, 8))
    for face_name in ("front", "back", "left", "right"):
        s.put("arm", face_name, 0, 11, hexc("e0dcc8"))
        s.put("arm", face_name, 3, 11, hexc("e0dcc8"))


def witch(s):
    skin = P("6a8a4a", "769656", "82a262")
    s.fill("head", skin, material=blotches(2, 0.4))
    s.eyes(4, hexc("f0e040"), pupil=hexc("2a0a2a"))
    s.put("head", "front", 4, 5, hexc("4a6a32"))     # crooked nose
    s.put("head", "front", 4, 6, hexc("4a6a32"))
    s.rect("head", "front", 2, 7, 4, 1, hexc("2a1a2a"))
    hat(s, P("141018", "1c1622", "24202c"), band="6a2a8a", rows=3)
    s.fill("head", P("2a1a2a", "3a2a3a"), faces=("left", "right", "back"), rows=(3, 7))  # hair
    dress = P("141018", "1c1622", "24202c")
    s.fill("body", dress, material=blotches(2, 0.4))
    s.fill("arm", dress, material=blotches(2, 0.4))
    s.fill("leg", dress, material=blotches(2, 0.4))
    s.fill("arm", skin, rows=(11, 11))
    s.band("body", 7, 1, hexc("6a2a8a"))
    s.put("body", "front", 3, 7, hexc("c8a040"))
    s.band("leg", 9, 1, hexc("6a2a8a"))
    boots(s, "0a080c")


# ---------------------------------------------------------------------------
# Costumes (transparent where they don't cover the player)
# ---------------------------------------------------------------------------

def costume_santa(s):
    santa_suit(s)


def costume_elf(s):
    green = P("1a4a22", "1e5a28", "246a30")
    s.fill("body", green, material=blotches(2, 0.3))
    s.fill("arm", green, material=blotches(2, 0.3), rows=(0, 10))
    s.band("arm", 10, 1, hexc("e02828"))
    for x in range(8):                               # zigzag hem
        s.put("body", "front", x, 11 - (x % 2), hexc("e02828"))
        s.put("body", "back", x, 11 - (x % 2), hexc("e02828"))
    s.band("body", 7, 1, hexc("2a1a10"))
    s.rect("body", "front", 3, 7, 2, 1, hexc("c8a040"))
    for y in range(10):
        s.band("leg", y, 1, hexc("d02a2a") if y % 2 else hexc("f0f0f0"))
    s.fill("leg", P("1e5a28", "246a30"), rows=(10, 11))
    s.fill("leg", P("1e5a28"), faces=("bottom",))


def costume_parka(s):
    # A quilted winter parka over dark trousers. No hood up, so the face stays
    # uncovered.
    orange = P("b85a14", "cc6a1c", "dc7a26", "ea8a32")
    quilt = lambda skin, gx, gy, lx, ly, face: 0.15 if ly % 3 == 2 else 0.6 + skin.rng.random() * 0.3
    s.fill("body", orange, material=quilt)
    s.fill("arm", orange, material=quilt)
    s.rect("body", "front", 3, 0, 2, 12, hexc("8a8a8a"))  # zip
    s.rect("body", "front", 2, 0, 4, 1, hexc("e8e0d0"))   # fur collar
    s.band("arm", 11, 1, hexc("4a2a10"))
    s.fill("leg", P("23262e", "2c303a"), material=blotches(2, 0.3))
    boots(s, "3a2414")


def costume_tree(s):
    s.fill("body", P("143a1a", "1a4a22", "205a2a", "286a32"), material=scales())
    s.fill("arm", P("143a1a", "1a4a22", "205a2a"), material=scales())
    s.fill("leg", P("4a3020", "5a3a26"), material=blotches(2, 0.4))
    for part in ("body", "arm"):
        for colour in ("e02828", "e8c020", "2860e0"):
            s.speckle(part, hexc(colour), 0.04, faces=("front", "back", "left", "right"))
    for y in range(0, 12, 3):                         # tinsel
        for x in range(8):
            if (x + y) % 3 == 0:
                s.put("body", "front", x, y + (x % 2), hexc("e8e0a0"))


def costume_sweater(s):
    red, green, white = hexc("a81c22"), hexc("1e6a2c"), hexc("f0f0f0")

    def knit(skin, gx, gy, lx, ly, face):
        return 0.4 + skin.rng.random() * 0.2
    s.fill("body", P("8e141a", "a81c22", "b82428"), material=knit)
    s.fill("arm", P("8e141a", "a81c22", "b82428"), material=knit)
    for part in ("body", "arm"):                     # green bands with a white zigzag
        for y in (3, 4, 5) if part == "body" else (3, 4):
            s.band(part, y, 1, green)
    for face_name in ("front", "back"):
        for x in range(8):
            s.put("body", face_name, x, 3 + (x % 2) * 2, white)
        s.put("body", face_name, 3, 8, white)          # a snowflake
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            s.put("body", face_name, 3 + dx, 8 + dy, white)
    s.band("body", 11, 1, green)
    s.band("arm", 11, 1, green)
    _ = red


def costume_santa_hat(s, colour=("a81c22", "c02428")):
    hat(s, P(*colour), band="f0f0f0", tip="f8f8f8")


def costume_green_santa_hat(s):
    costume_santa_hat(s, ("1e5a28", "246a30"))


def costume_poof_hat(s):
    knit = lambda skin, gx, gy, lx, ly, face: 0.3 + (lx % 2) * 0.4
    s.fill("head", P("a81c22", "c02428"), faces=("top",), material=knit)
    s.fill("head", P("a81c22", "c02428"), faces=("front", "back", "left", "right"), rows=(0, 2), material=knit)
    s.band("head", 1, 1, hexc("f0f0f0"))
    s.band("head", 2, 1, hexc("8e141a"))
    s.rect("head", "top", 3, 3, 2, 2, hexc("f8f8f8"))


def costume_forest_spirit(s):
    # Moss and leaves with a carved wooden mask.
    moss = P("2a4a1a", "34561e", "3e6224", "4a702a")
    for part in ("body", "arm", "leg"):
        s.fill(part, moss, material=blotches(2, 0.6))
        s.speckle(part, hexc("6a8a2a"), 0.12)
        s.speckle(part, hexc("8a5a2a"), 0.04)        # autumn leaves
    s.fill("head", P("6a4a2a", "7a5632", "8a623a"), faces=("front",), material=ripples(2, 0.2))
    s.rect("head", "front", 1, 3, 2, 2, hexc("140c06"))
    s.rect("head", "front", 5, 3, 2, 2, hexc("140c06"))
    s.put("head", "front", 2, 3, hexc("a8e060"))     # glowing eyes
    s.put("head", "front", 5, 3, hexc("a8e060"))
    s.rect("head", "front", 3, 6, 2, 1, hexc("140c06"))
    s.fill("head", moss, faces=("top",))
    s.put("head", "top", 2, 2, hexc("8ac040"))
    s.put("head", "top", 5, 4, hexc("8ac040"))


def costume_wizard(s):
    robe = P("2a1a5a", "34226a", "3e2a7a")
    s.fill("body", robe, material=blotches(2, 0.3))
    s.fill("arm", robe, material=blotches(2, 0.3))
    s.fill("leg", robe, material=blotches(2, 0.3))
    for part in ("body", "arm", "leg"):              # stars and moons
        s.speckle(part, hexc("e8d040"), 0.05, faces=("front", "back", "left", "right"))
    s.band("arm", 11, 1, hexc("c8a040"))
    s.band("body", 7, 1, hexc("c8a040"))
    hat(s, P("2a1a5a", "34226a"), band="c8a040", tip="e8d040", rows=3)
    # A long grey beard.
    s.rect("head", "front", 1, 5, 6, 3, hexc("b0b0b4"))
    s.rect("body", "front", 2, 0, 4, 4, hexc("a8a8ac"))


def costume_masked_stranger(s):
    # A burlap sack mask and a long dark coat.
    s.fill("head", P("8a7048", "9a7c52", "a8885c"), material=ripples(2, 0.3))
    s.rect("head", "front", 1, 3, 2, 1, hexc("0a0806"))
    s.rect("head", "front", 5, 3, 2, 1, hexc("0a0806"))
    for x in range(1, 7):
        s.put("head", "front", x, 6, hexc("3a2a1a"))
    s.band("head", 7, 1, hexc("4a3020"))             # drawstring at the neck
    coat = P("16181c", "1e2026", "262a30")
    s.fill("body", coat, material=blotches(2, 0.3))
    s.fill("arm", coat, material=blotches(2, 0.3))
    s.fill("leg", coat, rows=(0, 7), material=blotches(2, 0.3))
    s.fill("leg", P("101214"), rows=(8, 11))


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

MOBS = {
    XMAS + "mesecraft_christmas_santa.png": santa,
    XMAS + "mesecraft_christmas_mrs_claus.png": mrs_claus,
    XMAS + "mesecraft_christmas_zombie_elf.png": zombie_elf,
    XMAS + "mesecraft_christmas_crampus_claus.png": krampus,
    XMAS + "mesecraft_christmas_christmas_tree_man.png": christmas_tree_man,
    XMAS + "mesecraft_christmas_candy_cane_man.png": candy_cane_man,
    XMAS + "mesecraft_christmas_gingerbread_man.png": gingerbread_man,
    HALLOWEEN + "mesecraft_halloween_frankenstein.png": frankenstein,
    HALLOWEEN + "mesecraft_halloween_grim_reaper.png": grim_reaper,
    HALLOWEEN + "mesecraft_halloween_scarecrow.png": scarecrow,
    HALLOWEEN + "mesecraft_halloween_werewolf.png": werewolf,
    HALLOWEEN + "mesecraft_halloween_witch.png": witch,
}

# costume texture -> (draw function, inventory icon)
COSTUMES = {
    XMAS + "mesecraft_christmas_suit_santa.png": (costume_santa, XMAS + "inv_suit_santa.png"),
    XMAS + "mesecraft_christmas_suit_elf.png": (costume_elf, XMAS + "inv_suit_elf.png"),
    XMAS + "mesecraft_christmas_suit_orange_parka.png": (costume_parka, XMAS + "inv_suit_orange_parka.png"),
    XMAS + "mesecraft_christmas_suit_tree.png": (costume_tree, XMAS + "inv_suit_tree.png"),
    XMAS + "mesecraft_christmas_shirt_ugly_sweater.png": (costume_sweater, XMAS + "inv_shirt_ugly_sweater.png"),
    XMAS + "mesecraft_christmas_mask_santa_hat.png": (costume_santa_hat, XMAS + "inv_mask_santa_hat.png"),
    XMAS + "mesecraft_christmas_mask_green_santa_hat.png": (costume_green_santa_hat, XMAS + "inv_mask_green_santa_hat.png"),
    XMAS + "mesecraft_christmas_mask_red_poof_ball_hat.png": (costume_poof_hat, XMAS + "inv_mask_red_poof_ball_hat.png"),
    HALLOWEEN + "halloween_suit_forest_spirit.png": (costume_forest_spirit, HALLOWEEN + "inv_suit_forest_spirit.png"),
    HALLOWEEN + "halloween_suit_wizard.png": (costume_wizard, HALLOWEEN + "inv_suit_wizard.png"),
    HALLOWEEN + "halloween_suit_killer.png": (costume_masked_stranger, HALLOWEEN + "inv_suit_killer.png"),
}

# Halloween zombies wearing GreenXenith's costumes (MIT).
ZOMBIE_COSTUMES = {
    "mesecraft_halloween_zombie_halloween_1.png": "halloween_suit_dark_unicorn.png",
    "mesecraft_halloween_zombie_halloween_2.png": "halloween_suit_dino.png",
    "mesecraft_halloween_zombie_halloween_3.png": "halloween_suit_dino_pink.png",
    "mesecraft_halloween_zombie_halloween_4.png": "halloween_suit_unicorn.png",
}


def icon(costume):
    """A 16x16 inventory icon: the costume's front view, centred."""
    v = Image.new("RGBA", (16, 32), (0, 0, 0, 0))
    for part, offsets in (("head", [(4, 0)]), ("body", [(4, 8)]),
                          ("arm", [(0, 8), (12, 8)]), ("leg", [(4, 20), (8, 20)])):
        x, y, w, h = PARTS[part]["front"]
        tile = costume.crop((x, y, x + w, y + h))
        for i, off in enumerate(offsets):
            v.alpha_composite(tile if i == 0 else tile.transpose(Image.FLIP_LEFT_RIGHT), off)
    box = v.getbbox()
    v = v.crop(box)
    scale = min(16 / v.width, 16 / v.height)
    v = v.resize((max(1, round(v.width * scale)), max(1, round(v.height * scale))), Image.NEAREST)
    out = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    out.alpha_composite(v, ((16 - v.width) // 2, (16 - v.height) // 2))
    return out


def main(game):
    for path, draw in MOBS.items():
        s = Skin(os.path.basename(path))
        draw(s)
        s.save(os.path.join(game, path))
    for path, (draw, icon_path) in COSTUMES.items():
        s = Skin(os.path.basename(path))
        draw(s)
        s.save(os.path.join(game, path))
        icon(s.img).save(os.path.join(game, icon_path), optimize=True)
    for out, suit in ZOMBIE_COSTUMES.items():
        s = Skin(out)
        zombie(s)
        costume = Image.open(os.path.join(game, HALLOWEEN, suit)).convert("RGBA")
        s.img.alpha_composite(costume)
        s.save(os.path.join(game, HALLOWEEN, out))


if __name__ == "__main__":
    main(sys.argv[1])
