#!/usr/bin/env python3
"""Repaint mob textures whose original source couldn't be traced.

A model's texture has to put each colour where the model's UV map expects it,
so these repaints keep the old texture's layout: which areas are fur, belly,
eye or outline. Everything inside those areas is painted fresh. The old
texture is split into a few colour regions (k-means), and each region is
refilled with new noise around its average colour. Small details (the demon
eye's eyeball, the skeletons' bow and sword) are drawn from scratch.

Original art for MeseCraft (AGPLv3, like the rest of the game).

Run it once on the old textures; running it again repaints the repaint, which
is harmless but changes the noise.

Usage: python3 repaint.py GAME_DIR
"""
import math
import os
import random
import sys

from PIL import Image

TEX = "mods/mesecraft_mobs/textures/mesecraft_mobs_%s.png"


def kmeans(colours, k, rng, rounds=12):
    """Group colours into k clusters; returns a cluster index per colour."""
    centres = rng.sample(colours, k) if len(set(colours)) >= k else list(set(colours))
    k = len(centres)
    labels = [0] * len(colours)
    for _ in range(rounds):
        for i, c in enumerate(colours):
            labels[i] = min(range(k), key=lambda j: sum((c[t] - centres[j][t]) ** 2 for t in range(3)))
        for j in range(k):
            members = [colours[i] for i in range(len(colours)) if labels[i] == j]
            if members:
                centres[j] = tuple(sum(m[t] for m in members) / len(members) for t in range(3))
    return labels, centres


def repaint_regions(img, k, seed, grain=0.12, clump=2):
    """Refill each colour region of img with new noise around its mean colour."""
    rng = random.Random(seed)
    px = img.load()
    coords = [(x, y) for y in range(img.height) for x in range(img.width) if px[x, y][3] > 0]
    colours = [px[x, y][:3] for x, y in coords]
    labels, centres = kmeans(colours, k, rng)
    darkest = min(range(len(centres)), key=lambda j: sum(centres[j]))
    patches = {}
    for (x, y), label in zip(coords, labels):
        base = centres[label]
        if label == darkest:
            f = 1.0  # outlines and eyes stay flat
        else:
            key = (x // clump, y // clump)
            if key not in patches:
                patches[key] = rng.uniform(-grain, grain)
            f = 1 + patches[key] + rng.uniform(-grain / 2, grain / 2)
        a = px[x, y][3]
        px[x, y] = tuple(max(0, min(255, int(c * f))) for c in base) + (a,)
    return img


def draw_eyeball(img, cx, cy, r, seed):
    """A bloodshot eyeball: veined white, blue iris, black pupil."""
    rng = random.Random(seed)
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            d = math.hypot(x + 0.5 - cx, y + 0.5 - cy)
            if d > r:
                continue
            if d > r - 1:
                c = (150, 30, 34)                       # raw rim
            elif d < r * 0.22:
                c = (16, 12, 14)                        # pupil
            elif d < r * 0.55:
                v = rng.randint(-14, 14)
                c = (70 + v, 110 + v, 170 + v)          # iris
            else:
                c = (226, 220, 214) if rng.random() > 0.18 else (190, 40, 46)  # veins
            px[x, y] = c + (255,)


def draw_line(px, points, colours):
    for (x, y), c in zip(points, colours):
        px[x, y] = c


def weapon_box(img):
    """Bounding box of the drawn weapon in an otherwise empty texture."""
    return img.getbbox()


def draw_sword(img):
    x0, y0, x1, y1 = weapon_box(img)
    img.paste((0, 0, 0, 0), (0, 0, img.width, img.height))
    px = img.load()
    size = min(x1 - x0, y1 - y0)
    # Diagonal from the pommel (bottom left) to the tip (top right).
    for i in range(size):
        x, y = x0 + i, y1 - 1 - i
        if i < 3:
            c = (70, 46, 30, 255)                       # grip
        elif i == 3:
            c = (180, 150, 70, 255)                     # guard
            for dx, dy in ((-1, -1), (1, 1)):
                px[x + dx, y + dy] = (150, 120, 56, 255)
        else:
            c = (196, 200, 206, 255) if i % 3 else (232, 236, 240, 255)
            if i < size - 1:
                px[x + 1, y] = (120, 124, 132, 255)     # blade edge shadow
        px[x, y] = c


def draw_bow(img):
    x0, y0, x1, y1 = weapon_box(img)
    img.paste((0, 0, 0, 0), (0, 0, img.width, img.height))
    px = img.load()
    size = min(x1 - x0, y1 - y0)
    # String along the diagonal, limb curving out above it.
    for i in range(size):
        px[x0 + i, y1 - 1 - i] = (214, 210, 196, 255)
    for i in range(size):
        t = i / (size - 1)
        bulge = int(round(math.sin(t * math.pi) * size * 0.28))
        x, y = x0 + i, y1 - 1 - i - bulge
        if y0 <= y < y1:
            wood = (110, 74, 42, 255) if i % 4 else (140, 98, 56, 255)
            px[x, y] = wood
            if y - 1 >= y0:
                px[x, y - 1] = (78, 52, 30, 255)


def main(game):
    path = lambda name: os.path.join(game, TEX % name)

    def redo(name, k, **kw):
        img = Image.open(path(name)).convert("RGBA")
        repaint_regions(img, k, name, **kw).save(path(name), optimize=True)
        return img

    redo("bat", 4)

    eye = Image.open(path("demon_eye")).convert("RGBA")
    # Find the old eyeball (the light pixels) to place the new one there.
    px = eye.load()
    light = [(x, y) for y in range(eye.height) for x in range(eye.width)
             if px[x, y][3] and sum(px[x, y][:3]) > 330]
    xs, ys = [p[0] for p in light], [p[1] for p in light]
    cx, cy = (min(xs) + max(xs) + 1) / 2, (min(ys) + max(ys) + 1) / 2
    r = max(max(xs) - min(xs), max(ys) - min(ys)) / 2 + 0.5
    for x, y in light:
        px[x, y] = (120, 20, 24, 255)
    repaint_regions(eye, 3, "demon_eye")
    # Dark veins wandering across the flesh.
    rng = random.Random("demon_eye_veins")
    for _ in range(40):
        x, y = rng.randrange(eye.width), rng.randrange(eye.height)
        for _ in range(rng.randint(3, 7)):
            if px[x, y][3]:
                px[x, y] = (88, 12, 18, 255)
            x = max(0, min(eye.width - 1, x + rng.choice((-1, 0, 1))))
            y = max(0, min(eye.height - 1, y + 1))
    draw_eyeball(eye, cx, cy, r, "demon_eye")
    eye.save(path("demon_eye"), optimize=True)

    for name, draw in (("skeleton_fighter_sword", draw_sword), ("skeleton_bow", draw_bow)):
        img = Image.open(path(name)).convert("RGBA")
        draw(img)
        img.save(path(name), optimize=True)


if __name__ == "__main__":
    main(sys.argv[1])
