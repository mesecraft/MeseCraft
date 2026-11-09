"""Build box-shaped mob models (.b3d) and paint their textures in one go.

A model is a set of boxes, each fastened to a bone. Bones turn around a pivot
point, and their animation is given as a function per animation range. The
texture is laid out automatically: every box gets a strip of six faces, and
each texel is painted by a function that is told where on the model the texel
sits. Colour patterns therefore line up across box edges without any manual
UV work.

Units are texture pixels: 16 px is one node at visual_size 1.
Axes follow Luanti: +Y is up and the model faces +Z.

Original code for MeseCraft (AGPLv3, like the rest of the game).
"""
import math
import struct

from PIL import Image

# Luanti draws meshes at 10 units per node; models here are built at 16 px per node.
SCALE = 10 / 16

# The six faces of a box: outward normal and the face's "up" direction.
# The face's "right" direction is normal x up, which matches the way
# Luanti's own character model maps its skin (the texture's top row is "up").
FACES = (
    ((1, 0, 0), (0, 1, 0)),
    ((-1, 0, 0), (0, 1, 0)),
    ((0, 0, 1), (0, 1, 0)),
    ((0, 0, -1), (0, 1, 0)),
    ((0, 1, 0), (0, 0, 1)),
    ((0, -1, 0), (0, 0, 1)),
)


def cross(a, b):
    return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])


def dot(a, b):
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def add(a, b, k=1):
    return (a[0] + b[0] * k, a[1] + b[1] * k, a[2] + b[2] * k)


def rot(axis, degrees):
    """A quaternion (w, x, y, z) turning `degrees` around an axis ("x", "y" or "z")."""
    half = math.radians(degrees) / 2
    v = {"x": (1, 0, 0), "y": (0, 1, 0), "z": (0, 0, 1)}[axis]
    s = math.sin(half)
    return (math.cos(half), v[0] * s, v[1] * s, v[2] * s)


def qmul(a, b):
    """Combine two rotations: b first, then a."""
    w1, x1, y1, z1 = a
    w2, x2, y2, z2 = b
    return (w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2,
            w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2,
            w1 * y2 - x1 * z2 + y1 * w2 + z1 * x2,
            w1 * z2 + x1 * y2 - y1 * x2 + z1 * w2)


IDENTITY = (1, 0, 0, 0)


class Bone:
    def __init__(self, name, pivot, parent=None):
        self.name, self.pivot, self.parent = name, pivot, parent
        self.motion = {}  # animation name -> function(t in 0..1) -> quaternion


class Box:
    def __init__(self, bone, lo, hi, paint):
        self.bone, self.lo, self.hi, self.paint = bone, lo, hi, paint
        self.size = tuple(int(round(hi[i] - lo[i])) for i in range(3))
        w, h, d = self.size
        self.strip = (2 * d + 2 * w, d + h)  # texture area the six faces need

    def faces(self, u0, v0):
        """Yield (normal, corners, texel origin, width, height) for each face.

        Corners run top-left, top-right, bottom-right, bottom-left as seen from
        outside. The faces are packed like an unfolded box: top and bottom in
        the first row, the four sides in the second.
        """
        w, h, d = self.size
        centre = tuple((self.lo[i] + self.hi[i]) / 2 for i in range(3))
        half = tuple((self.hi[i] - self.lo[i]) / 2 for i in range(3))
        spots = {
            (1, 0, 0): (u0, v0 + d), (0, 0, 1): (u0 + d, v0 + d),
            (-1, 0, 0): (u0 + d + w, v0 + d), (0, 0, -1): (u0 + 2 * d + w, v0 + d),
            (0, 1, 0): (u0 + d, v0), (0, -1, 0): (u0 + d + w, v0),
        }
        for n, up in FACES:
            right = cross(n, up)
            fw = abs(dot(right, half)) * 2
            fh = abs(dot(up, half)) * 2
            c = add(centre, n, abs(dot(n, half)))
            tl = add(add(c, right, -fw / 2), up, fh / 2)
            tr = add(tl, right, fw)
            br = add(tr, up, -fh)
            bl = add(tl, up, -fh)
            yield n, right, up, (tl, tr, br, bl), spots[n], int(round(fw)), int(round(fh))


class Model:
    def __init__(self, tex_size):
        self.tex_size = tex_size
        self.bones, self.boxes, self.anims = [], [], []

    def bone(self, name, pivot, parent=None):
        b = Bone(name, pivot, parent)
        self.bones.append(b)
        return b

    def box(self, bone, lo, hi, paint):
        self.boxes.append(Box(bone, lo, hi, paint))

    def anim(self, name, start, end):
        self.anims.append((name, start, end))

    def _pack(self):
        """Place each box's strip on the texture, tallest rows first."""
        tw, th = self.tex_size
        order = sorted(self.boxes, key=lambda b: -b.strip[1])
        x = y = row = 0
        spots = {}
        for b in order:
            bw, bh = b.strip
            if x + bw > tw:
                x, y, row = 0, y + row, 0
            if y + bh > th:
                raise ValueError("texture %dx%d is too small" % (tw, th))
            spots[id(b)] = (x, y)
            x += bw
            row = max(row, bh)
        return spots

    def texture(self):
        """Paint every face texel by asking its box what colour that spot is."""
        spots = self._pack()
        img = Image.new("RGBA", self.tex_size, (0, 0, 0, 0))
        px = img.load()
        for b in self.boxes:
            for n, right, up, corners, (u, v), fw, fh in b.faces(*spots[id(b)]):
                for t in range(fh):
                    for s in range(fw):
                        p = add(add(corners[0], right, s + 0.5), up, -(t + 0.5))
                        c = b.paint(p, n)
                        if c is not None:
                            px[u + s, v + t] = tuple(int(max(0, min(255, round(k)))) for k in c) + (255,) * (4 - len(c))
        return img

    def b3d(self):
        """Encode the model as a Blitz3D (.b3d) file, the format Luanti animates."""
        tw, th = self.tex_size
        spots = self._pack()
        verts, tris, weights = [], [], {b.name: [] for b in self.bones}
        for b in self.boxes:
            for n, _, _, corners, (u, v), fw, fh in b.faces(*spots[id(b)]):
                base = len(verts)
                uvs = ((u, v), (u + fw, v), (u + fw, v + fh), (u, v + fh))
                for p, (tu, tv) in zip(corners, uvs):
                    weights[b.bone.name].append(len(verts))
                    verts.append((tuple(k * SCALE for k in p), n, (tu / tw, tv / th)))
                # Wind each triangle so its normal points outward.
                a, bb, c = corners[0], corners[3], corners[2]
                outward = dot(cross(add(bb, a, -1), add(c, a, -1)), n) > 0
                quad = (0, 3, 2, 0, 2, 1) if outward else (0, 2, 3, 0, 1, 2)
                tris.extend(base + i for i in quad)

        def chunk(tag, data):
            return tag + struct.pack("<i", len(data)) + data

        def node(name, pos, inner):
            return chunk(b"NODE", name.encode() + b"\0" + struct.pack("<3f3f4f", *pos, 1, 1, 1, *IDENTITY) + inner)

        vrts = struct.pack("<iii", 1, 1, 2) + b"".join(
            struct.pack("<3f3f2f", *p, *n, *t) for p, n, t in verts)
        mesh = chunk(b"MESH", struct.pack("<i", -1) + chunk(b"VRTS", vrts)
                     + chunk(b"TRIS", struct.pack("<i", 0) + struct.pack("<%di" % len(tris), *tris)))
        frames = max(end for _, _, end in self.anims) + 1 if self.anims else 0

        def bone_node(bone):
            parent = bone.parent.pivot if bone.parent else (0, 0, 0)
            pos = tuple((bone.pivot[i] - parent[i]) * SCALE for i in range(3))
            inner = chunk(b"BONE", b"".join(struct.pack("<if", i, 1.0) for i in weights[bone.name]))
            if self.anims:
                # Every bone gets a key on every frame, so no range borrows its
                # pose from a neighbouring one.
                keys = b""
                for name, start, end in self.anims:
                    move = bone.motion.get(name)
                    for f in range(start, end + 1):
                        q = move((f - start) / (end - start)) if move else IDENTITY
                        # .b3d frames count from 1; the engine subtracts 1 on
                        # loading, so Lua sees the frame numbers used here.
                        keys += struct.pack("<i4f", f + 1, *q)
                inner += chunk(b"KEYS", struct.pack("<i", 4) + keys)
            for child in self.bones:
                if child.parent is bone:
                    inner += bone_node(child)
            return node(bone.name, pos, inner)

        root = mesh
        if self.anims:
            root += chunk(b"ANIM", struct.pack("<iif", 0, frames + 1, 30.0))
        root += b"".join(bone_node(b) for b in self.bones if b.parent is None)
        brush = chunk(b"BRUS", struct.pack("<i", 1) + b"skin\0" + struct.pack("<5fiii", 1, 1, 1, 1, 0, 1, 0, -1))
        return chunk(b"BB3D", struct.pack("<i", 1) + brush + node("root", (0, 0, 0), root))
