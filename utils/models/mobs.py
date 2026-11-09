#!/usr/bin/env python3
"""Build the deer, clownfish and crocodile egg models and their textures.

These replace models whose source was never recorded. Each mob is a handful of
boxes (see boxmodel.py), so the shapes are easy to read and edit here. Running
the script rewrites the models and textures in mods/mesecraft_mobs.

Original art for MeseCraft (AGPLv3, like the rest of the game).

Usage: python3 mobs.py GAME_DIR
"""
import math
import os
import sys
import zlib

from PIL import Image

from boxmodel import Model, rot, qmul

MOBS = "mods/mesecraft_mobs"


def h01(*key):
    """A repeatable pseudo-random number in 0..1 for a key."""
    return (zlib.crc32(repr(key).encode()) & 0xFFFF) / 0xFFFF


def grain(p, seed, amount, cell=1.0):
    """Brightness factor that varies in blocks of `cell` pixels across the model."""
    k = tuple(math.floor(c / cell) for c in p)
    return 1 + (h01(seed, k) - 0.5) * 2 * amount


def shade(c, f):
    return tuple(v * f for v in c)


def mix(a, b, t):
    t = max(0.0, min(1.0, t))
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def wave(t, cycles=1, phase=0.0):
    return math.sin(2 * math.pi * (t * cycles + phase))


# --------------------------------------------------------------------------
# Deer: a white-tailed buck. The model stands on y = 0 and faces +Z.

COAT = (150, 98, 58)
SPINE = (116, 74, 44)
WHITE = (228, 222, 208)
LEG = (172, 134, 98)
HOOF = (44, 36, 32)
ANTLER = (204, 184, 148)
DARK = (26, 22, 22)


def deer():
    m = Model((64, 64))
    body = m.bone("body", (0, 12.5, 0))
    neck = m.bone("neck", (0, 14, 6.5), body)
    head = m.bone("head", (0, 20, 6.5), neck)
    tail = m.bone("tail", (0, 15.5, -7), body)
    legs = {}
    for name, x, z in (("leg_fr", -1.5, 5), ("leg_fl", 1.5, 5), ("leg_br", -1.5, -5), ("leg_bl", 1.5, -5)):
        legs[name] = m.bone(name, (x, 9.5, z), body)

    def coat(p, n):
        y = p[1]
        c = mix(COAT, SPINE, (y - 14.5) / 1.5)
        if n[1] < 0 or y < 9.6:
            c = WHITE  # belly
        elif y < 10.6:
            c = mix(WHITE, COAT, 0.6)
        return shade(c, grain(p, "coat", 0.05) * grain(p, "patch", 0.04, 2))

    def neck_paint(p, n):
        if n[2] > 0 and p[1] > 17.5:
            return shade(WHITE, grain(p, "throat", 0.04))  # white throat patch
        return coat(p, n)

    def head_paint(p, n):
        x, y, z = p
        if abs(n[0]) and 9 < z < 10 and 21 < y < 22:
            return DARK  # eye
        if abs(n[0]) and 8.5 < z < 10.5 and 20.5 < y < 22.5:
            return shade(WHITE, 0.92)  # pale ring around the eye
        c = mix(COAT, SPINE, (y - 21.5) / 1.5)
        return shade(c, grain(p, "head", 0.05))

    def snout(p, n):
        x, y, z = p
        if abs(x) < 1 and (n[2] > 0 and y > 20.3 or (n[1] > 0 and z > 12)):
            return shade(DARK, grain(p, "nose", 0.2))  # wet black nose
        if n[1] < 0 or y < 20:
            return WHITE  # white chin
        if z > 11.5:
            return shade(WHITE, 0.9)  # pale band behind the nose
        return shade(mix(COAT, (120, 100, 86), 0.4), grain(p, "snout", 0.05))

    def ear(p, n):
        tip = abs(p[0]) > 3.4
        if n[2] > 0 and not tip:
            return (214, 182, 168)  # inside of the ear
        return shade(SPINE if tip else COAT, grain(p, "ear", 0.05))

    def antler(p, n):
        tip = p[1] > 26.4 and (abs(p[0]) > 2.4 or p[2] > 9)
        return shade((232, 222, 198) if tip else ANTLER, grain(p, "antler", 0.07))

    def tail_paint(p, n):
        if n[1] > 0 or (n[2] < 0 and p[1] > 15):
            return shade(COAT, grain(p, "tail", 0.05))
        return WHITE  # the white flag underneath

    def leg(p, n):
        y = p[1]
        if y < 1 or n[1] < 0:
            return shade(HOOF, grain(p, "hoof", 0.1))
        c = COAT if y > 6.5 else LEG
        if abs(p[0]) < 1 and y < 7:
            c = mix(c, WHITE, 0.4)  # lighter on the inner side
        return shade(c, grain(p, "leg", 0.05))

    m.box(body, (-3, 9, -7), (3, 16, 7), coat)
    m.box(neck, (-1.5, 13, 5), (1.5, 21, 8), neck_paint)
    m.box(head, (-2, 19, 6), (2, 23, 11), head_paint)
    m.box(head, (-1.5, 19.5, 10), (1.5, 21.5, 13), snout)
    m.box(tail, (-1, 12.5, -7.5), (1, 15.5, -6.5), tail_paint)
    for side in (1, -1):
        def span(a, b):
            return (a, b) if side > 0 else (-b, -a)

        x0, x1 = span(1, 4)
        m.box(head, (x0, 22, 7), (x1, 24, 8), ear)
        # Antler: a beam with a forward tine and an outward fork that turns up.
        x0, x1 = span(0.5, 1.5)
        m.box(head, (x0, 22.5, 7), (x1, 26.5, 8), antler)
        m.box(head, (x0, 25, 8), (x1, 26, 10), antler)
        x0, x1 = span(1.5, 3.5)
        m.box(head, (x0, 25.5, 7), (x1, 26.5, 8), antler)
        x0, x1 = span(2.5, 3.5)
        m.box(head, (x0, 26.5, 7), (x1, 28.5, 8), antler)
    for name, bone in legs.items():
        x, z = bone.pivot[0], bone.pivot[2]
        m.box(bone, (x - 1, 0, z - 1), (x + 1, 10, z + 1), leg)

    m.anim("stand", 0, 80)
    m.anim("walk", 90, 130)
    m.anim("run", 140, 160)
    # Standing: look around and flick the tail.
    head.motion["stand"] = lambda t: rot("y", 14 * wave(t))
    tail.motion["stand"] = lambda t: rot("x", 18 * max(0.0, wave(t, 2)))
    # Walking: diagonal legs move together.
    for name, phase in (("leg_fl", 0), ("leg_br", 0), ("leg_fr", 0.5), ("leg_bl", 0.5)):
        legs[name].motion["walk"] = lambda t, ph=phase: rot("x", 24 * wave(t, 1, ph))
        # Running: a bound, with the front and back pairs swinging in turn.
        ph = 0 if name.startswith("leg_f") else 0.5
        legs[name].motion["run"] = lambda t, ph=ph: rot("x", 38 * wave(t, 1, ph))
    neck.motion["walk"] = lambda t: rot("x", 4 * wave(t, 2))
    tail.motion["walk"] = lambda t: rot("x", 8 * wave(t, 2))
    body.motion["run"] = lambda t: rot("x", 5 * wave(t, 1, 0.25))
    tail.motion["run"] = lambda t: rot("x", 35)  # flag up while fleeing
    return m


# --------------------------------------------------------------------------
# Clownfish: built at 32 px per node for crisp bands, shown at visual_size 0.45.
# Thin fins are shaped with transparent texels.

WHITE_BAND = (250, 248, 240)
BLACK = (22, 20, 22)

# One scheme per texture, after real anemonefish.
FISH = [
    # Ocellaris: orange with three white bands edged in black.
    dict(body=(238, 108, 24), bands=[(4.5, 1.0, 0.05), (-0.5, 1.6, -0.07), (-8.5, 0.8, 0)], edge=BLACK, tip=BLACK),
    # Black ocellaris: black with an orange face.
    dict(body=(34, 28, 30), face=(232, 104, 30), bands=[(4.5, 1.0, 0.05), (-0.5, 1.6, -0.07), (-8.5, 0.8, 0)], tip=(232, 104, 30)),
    # Tomato clownfish: red with one head band.
    dict(body=(204, 46, 26), bands=[(4.5, 1.0, 0.05)], edge=(60, 22, 20), fin=(220, 70, 36), tip=(150, 30, 20)),
    # Maroon clownfish: dark red with thin white bands.
    dict(body=(112, 20, 32), bands=[(4.5, 0.6, 0.05), (-0.5, 0.7, -0.07), (-8.5, 0.5, 0)], fin=(126, 26, 38), tip=(78, 12, 22)),
    # Gold-stripe maroon: the same with yellow bands.
    dict(body=(110, 22, 30), band=(236, 190, 60), bands=[(4.5, 0.6, 0.05), (-0.5, 0.7, -0.07), (-8.5, 0.5, 0)],
         fin=(126, 26, 38), tip=(78, 12, 22)),
    # Clark's anemonefish: dark body, orange face and fins, yellow tail.
    dict(body=(44, 32, 26), face=(230, 130, 40), bands=[(4.5, 1.2, 0.05), (-0.5, 1.6, -0.07)],
         fin=(236, 150, 40), tail=(240, 196, 70)),
    # Pink skunk clownfish: peach with a white stripe along the back.
    dict(body=(240, 166, 140), bands=[(4.5, 0.5, 0.05)], stripe=True, fin=(246, 186, 164), tip=(246, 186, 164)),
    # Orange skunk clownfish: orange with only the back stripe.
    dict(body=(236, 130, 40), bands=[], stripe=True, fin=(242, 152, 60), tip=(242, 152, 60)),
    # Saddleback: orange with a dark saddle over the back.
    dict(body=(226, 120, 40), bands=[(4.5, 1.0, 0.05), (-8.5, 0.6, 0)], saddle=(36, 28, 28), tip=BLACK),
    # Cinnamon clownfish: red-brown with one head band and a pale tail.
    dict(body=(150, 58, 32), bands=[(4.5, 1.0, 0.05)], fin=(176, 80, 40), tail=(206, 132, 80)),
    # Snowflake: wide, wavy white bands.
    dict(body=(238, 112, 28), bands=[(4.5, 1.6, 0.05), (-0.5, 2.4, -0.07), (-8.5, 1.0, 0)], wobble=1.2, edge=BLACK, tip=BLACK),
    # Platinum: nearly all white with an orange face and fins.
    dict(body=(240, 238, 232), face=(238, 112, 30), bands=[], fin=(238, 112, 30), tip=BLACK),
    # Golden: yellow with white bands.
    dict(body=(240, 182, 40), bands=[(4.5, 1.0, 0.05), (-0.5, 1.6, -0.07), (-8.5, 0.8, 0)], edge=(120, 80, 20), tip=(170, 110, 20)),
]


def clownfish(scheme):
    m = Model((64, 64))
    body = m.bone("body", (0, 0, 0))
    tail = m.bone("tail", (0, 0, -6), body)
    fin_l = m.bone("fin_l", (3, -0.5, 5), body)
    fin_r = m.bone("fin_r", (-3, -0.5, 5), body)
    s = scheme

    def skin(p, n):
        x, y, z = p
        c = s["body"]
        if s.get("face") and z > 5.5:
            c = s["face"]
        if s.get("saddle") and y > 1 and -6 < z < 2 and y > 4 - 2 * math.cos((z + 2) / 4):
            c = s["saddle"]
        if s.get("stripe") and y > 4 and z < 8:
            c = WHITE_BAND
        # Bands curve with the body: the head band follows the gill cover and
        # the middle band points forward, like the real fish.
        for centre, half, bow in s["bands"]:
            d = abs(z - bow * y * y - s.get("wobble", 0) * math.sin(y * 1.4) - centre)
            if d < half:
                c = s.get("band", WHITE_BAND)
            elif s.get("edge") and d < half + 0.9:
                c = s["edge"]
        if abs(n[0]) and 6.5 < z < 8.5 and 0 < y < 2:
            return (250, 250, 250) if z > 7.5 and y > 1 else BLACK  # eye with a glint
        if n[2] > 0 and -2 < y < -1:
            return shade(c, 0.6)  # mouth
        return shade(c, grain(p, "fish", 0.04))

    def fin_colour(p, outer):
        base = s.get("fin", s["body"])
        if outer and s.get("tip"):
            return s["tip"]
        return shade(base, grain(p, "fin", 0.04))

    def dorsal(p, n):
        z, y = p[2], p[1]
        lobe = (2.6, -2, 3.4) if z < 1 else (1.6, 3, 2.4)
        top = 5 + lobe[0] * math.sqrt(max(0.0, 1 - ((z - lobe[1]) / lobe[2]) ** 2))
        if y > top:
            return None
        return fin_colour(p, y > top - 1)

    def anal(p, n):
        z, y = p[2], p[1]
        bottom = -5 - 2.6 * math.sqrt(max(0.0, 1 - ((z + 2) / 3.2) ** 2))
        if y < bottom:
            return None
        return fin_colour(p, y < bottom + 1)

    def pectoral(p, n):
        z, y = p[2], p[1]
        r = ((z - 3) / 2.1) ** 2 + ((y + 0.5) / 1.6) ** 2
        if r > 1.15:
            return None
        return fin_colour(p, r > 0.85)

    def tail_fin(p, n):
        z, y = p[2], p[1]
        spread = -9 - z  # 0 at the stalk, 7 at the end
        if abs(y) > 2.2 + 0.5 * spread or z < -16 + 1.5 * (y / 5) ** 2:
            return None
        if s.get("tail"):
            return shade(s["tail"], grain(p, "tail", 0.04))
        return fin_colour(p, spread > 5.2)

    m.box(body, (-3, -5, -6), (3, 5, 6), skin)
    m.box(body, (-2, -3, 5.5), (2, 3, 9.5), skin)
    m.box(body, (-0.5, 4, -5), (0.5, 8, 5), dorsal)
    m.box(body, (-0.5, -8, -5), (0.5, -4, 1), anal)
    m.box(fin_l, (3, -2, 1), (4, 1, 5), pectoral)
    m.box(fin_r, (-4, -2, 1), (-3, 1, 5), pectoral)
    m.box(tail, (-1.5, -3, -10), (1.5, 3, -5), skin)
    m.box(tail, (-0.5, -5, -16), (0.5, 5, -9), tail_fin)

    m.anim("stand", 0, 40)
    m.anim("swim", 50, 80)
    tail.motion["stand"] = lambda t: rot("y", 10 * wave(t))
    fin_l.motion["stand"] = lambda t: rot("y", 20 * wave(t, 2))
    fin_r.motion["stand"] = lambda t: rot("y", -20 * wave(t, 2))
    tail.motion["swim"] = lambda t: rot("y", 28 * wave(t))
    body.motion["swim"] = lambda t: rot("y", 5 * wave(t, 1, 0.5))
    fin_l.motion["swim"] = lambda t: rot("y", 30 * wave(t, 2))
    fin_r.motion["swim"] = lambda t: rot("y", -30 * wave(t, 2))
    return m


# --------------------------------------------------------------------------
# Crocodile egg: four crossed boxes make a rounded oval lying on its side.
# The mob's origin is half a node above the ground, so the egg sits at y = -8.

SHELL = (234, 228, 210)


def egg():
    m = Model((32, 32))
    b = m.bone("egg", (0, -5, 0))

    def shell(p, n):
        if h01("speck", tuple(math.floor(c) for c in p)) < 0.06:
            return (196, 176, 144)
        c = shade(SHELL, grain(p, "shell", 0.04))
        if abs(p[2]) < 1.5:
            c = shade(c, 0.95)  # the chalky band around the middle
        if p[1] < -6.5:
            c = shade(c, 0.9)
        return c

    m.box(b, (-2, -7, -3), (2, -3, 3), shell)
    m.box(b, (-1, -8, -2), (1, -2, 2), shell)
    m.box(b, (-1, -6, -4), (1, -4, 4), shell)
    m.box(b, (-3, -6, -2), (3, -4, 2), shell)
    return m


def egg_icon():
    """A 16x16 inventory picture of the egg."""
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    px = img.load()
    for y in range(16):
        for x in range(16):
            dx, dy = (x + 0.5 - 8) / 6.5, (y + 0.5 - 8.5) / 5
            r = dx * dx + dy * dy
            if r > 1:
                continue
            light = 1.06 - 0.16 * (dx + dy + 1) / 2  # lit from the top left
            c = shade(SHELL, light * grain((x, y), "icon", 0.03))
            if r > 0.8:
                c = shade(SHELL, 0.7)
            if h01("icon_speck", x, y) < 0.05 and r < 0.8:
                c = (196, 176, 144)
            px[x, y] = tuple(int(v) for v in c) + (255,)
    px[5, 5] = (252, 250, 244, 255)  # shine
    return img


def main(game):
    out = lambda kind, name: os.path.join(game, MOBS, kind, name)

    m = deer()
    open(out("models", "mesecraft_mobs_deer.b3d"), "wb").write(m.b3d())
    m.texture().save(out("textures", "mesecraft_mobs_deer.png"), optimize=True)

    for i, scheme in enumerate(FISH, 1):
        m = clownfish(scheme)
        if i == 1:
            open(out("models", "mesecraft_mobs_clownfish.b3d"), "wb").write(m.b3d())
        m.texture().save(out("textures", "mesecraft_mobs_clownfish_%d.png" % i), optimize=True)

    m = egg()
    open(out("models", "mesecraft_mobs_crocodile_egg.b3d"), "wb").write(m.b3d())
    m.texture().save(out("textures", "mesecraft_mobs_crocodile_egg.png"), optimize=True)
    egg_icon().save(out("textures", "mesecraft_mobs_crocodile_egg_inv.png"), optimize=True)


if __name__ == "__main__":
    main(sys.argv[1])
