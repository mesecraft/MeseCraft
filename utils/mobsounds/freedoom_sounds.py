#!/usr/bin/env python3
"""Build MeseCraft mob sounds from Freedoom's sound effects.

Freedoom (https://freedoom.github.io) is released under the BSD 3-Clause
license, so its sounds may be used and changed as long as the notice is kept
(see mods/mesecraft_mobs/LICENSE-freedoom.txt). This script reads the sound
lumps from freedoom2.wad, optionally changes their pitch, and writes Ogg
Vorbis files named the way the mobs expect.

SOUNDS below is the record of where every generated file comes from; the
credits in mods/mesecraft_mobs/credits.txt point here.

Needs ffmpeg with libvorbis.

Usage: python3 freedoom_sounds.py path/to/freedoom2.wad mods/mesecraft_mobs/sounds
"""

import os
import struct
import subprocess
import sys
import tempfile
import wave

# Output name (without "mesecraft_mobs_" and ".ogg") -> (Freedoom lump, pitch).
# A pitch above 1 makes the sound higher and shorter, below 1 deeper and longer.
SOUNDS = {
    # Shared projectile and melee sounds.
    "common_attack_claw": ("DSCLAW", 1.0),
    "common_shoot_fireball": ("DSFIRSHT", 1.0),
    "common_shoot_poisonball": ("DSFIRSHT", 0.7),
    "common_shoot_poisonball_hit": ("DSSLOP", 1.0),

    # Freedoom's own monsters, which replaced MeseCraft's DOOM look-alikes.
    "serpentipede_random": ("DSBGACT", 1.0),
    "serpentipede_warcry.1": ("DSBGSIT1", 1.0),
    "serpentipede_warcry.2": ("DSBGSIT2", 1.0),
    "serpentipede_damage": ("DSPOPAIN", 0.9),
    "serpentipede_death.1": ("DSBGDTH1", 1.0),
    "serpentipede_death.2": ("DSBGDTH2", 1.0),
    "flesh_worm_random": ("DSDMACT", 1.0),
    "flesh_worm_warcry": ("DSSGTSIT", 1.0),
    "flesh_worm_attack": ("DSSGTATK", 1.0),
    "flesh_worm_damage": ("DSDMPAIN", 1.0),
    "flesh_worm_death": ("DSSGTDTH", 1.0),
    "hatchling_random": ("DSDMACT", 1.4),
    "hatchling_warcry": ("DSSKLATK", 1.2),
    "hatchling_attack": ("DSSKLATK", 1.0),
    "hatchling_damage": ("DSDMPAIN", 1.3),
    "hatchling_death": ("DSFIRXPL", 1.2),
    "trilobite_random": ("DSDMACT", 0.85),
    "trilobite_warcry": ("DSCACSIT", 1.0),
    "trilobite_damage": ("DSDMPAIN", 0.9),
    "trilobite_death": ("DSCACDTH", 1.0),
    "pain_lord_random": ("DSDMACT", 0.75),
    "pain_lord_warcry": ("DSBRSSIT", 1.0),
    "pain_lord_damage": ("DSDMPAIN", 0.8),
    "pain_lord_death": ("DSBRSDTH", 1.0),
    "combat_slug_random": ("DSDMACT", 0.7),
    "combat_slug_warcry": ("DSMANSIT", 1.0),
    "combat_slug_shoot": ("DSMANATK", 1.0),
    "combat_slug_damage": ("DSMNPAIN", 1.0),
    "combat_slug_death": ("DSMANDTH", 1.0),
    "assault_tripod_random": ("DSHOOF", 1.0),
    "assault_tripod_warcry": ("DSCYBSIT", 1.0),
    "assault_tripod_shoot": ("DSRLAUNC", 1.0),
    "assault_tripod_damage": ("DSMETAL", 0.8),
    "assault_tripod_death": ("DSCYBDTH", 1.0),

    # Grey aliens: Freedoom creature sounds pitched up into chatter.
    "grey_attack.1": ("DSCLAW", 1.2),
    "grey_attack.2": ("DSPUNCH", 1.3),
    "grey_attack.3": ("DSCLAW", 1.4),
    "grey_damage.1": ("DSPOPAIN", 1.6),
    "grey_damage.2": ("DSDMPAIN", 1.7),
    "grey_damage.3": ("DSVIPAIN", 1.6),
    "grey_death.1": ("DSBSPDTH", 1.5),
    "grey_death.2": ("DSPODTH2", 1.7),
    "grey_civilian_random.1": ("DSBSPACT", 1.6),
    "grey_civilian_random.2": ("DSDMACT", 1.8),
    "grey_civilian_random.3": ("DSPOSACT", 1.7),
    "grey_civilian_random.4": ("DSBSPSIT", 1.9),
    "grey_civilian_random.5": ("DSSKEACT", 1.6),
    "grey_civilian_random.6": ("DSVILACT", 1.8),
    "grey_civilian_warcry": ("DSBSPSIT", 1.6),
    "grey_enlisted_random.1": ("DSBSPACT", 1.4),
    "grey_enlisted_random.2": ("DSDMACT", 1.6),
    "grey_enlisted_random.3": ("DSPOSACT", 1.5),
    "grey_enlisted_random.4": ("DSSKEACT", 1.4),
    "grey_enlisted_random.5": ("DSVILACT", 1.6),
    "grey_enlisted_random.6": ("DSBSPWLK", 1.3),
    "grey_enlisted_random.7": ("DSRADIO", 1.0),
    "grey_enlisted_shoot.1": ("DSPLASMA", 1.2),
    "grey_enlisted_shoot.2": ("DSPLASMA", 1.35),
    "grey_enlisted_shoot.3": ("DSPLASMA", 1.5),
    "grey_enlisted_warcry": ("DSBSPSIT", 1.4),

    # Reptilian elite: deep hisses and growls.
    "reptilian_elite_random.1": ("DSSKEACT", 0.8),
    "reptilian_elite_random.2": ("DSBGACT", 0.8),
    "reptilian_elite_random.3": ("DSBGSIT1", 0.75),
    "reptilian_elite_random.4": ("DSBGSIT2", 0.75),
    "reptilian_elite_random.5": ("DSKNTSIT", 0.85),
    "reptilian_elite_random.6": ("DSDMACT", 0.7),
    "reptilian_elite_random.7": ("DSVILACT", 0.8),

    # Flying saucer: machine hums and metal hits.
    "flying_saucer_random.1": ("DSBSPWLK", 0.6),
    "flying_saucer_random.2": ("DSSTNMOV", 1.0),
    "flying_saucer_random.3": ("DSPSTART", 0.7),
    "flying_saucer_random.4": ("DSTELEPT", 1.3),
    "flying_saucer_warcry": ("DSTELEPT", 0.8),
    "flying_saucer_damage.1": ("DSMETAL", 1.0),
    "flying_saucer_damage.2": ("DSMETAL", 1.2),
    "flying_saucer_death": ("DSBAREXP", 1.0),

    # Golems and small creatures.
    "dirt_man_random": ("DSSTNMOV", 0.6),
    "sand_man_random": ("DSSTNMOV", 0.8),
    "stone_man_random": ("DSSTNMOV", 0.5),
    "rat_random": ("DSDMACT", 2.4),
    "kangaroo": ("DSPOSACT", 1.3),
    "demon_eye_death": ("DSPEDTH", 1.3),
    "ghost_death": ("DSVILDTH", 1.1),
    "zombie_attack": ("DSCLAW", 0.9),
    "zombie_damage": ("DSPOPAIN", 1.0),

    # Halloween mobs (mesecraft_halloween uses these names).
    "witch_shoot_attack": ("DSTELEPT", 1.5),
    "werewolf_damage.1": ("DSDMPAIN", 1.0),
    "werewolf_damage.2": ("DSDMPAIN", 1.1),
    "werewolf_damage.3": ("DSDMPAIN", 0.9),
    "werewolf_random.1": ("DSDMACT", 0.8),
    "werewolf_random.2": ("DSBGACT", 0.7),
    "werewolf_random.3": ("DSSGTSIT", 0.9),
    "werewolf_random.4": ("DSKNTSIT", 1.1),
    "werewolf_random.5": ("DSDMACT", 0.65),
}


def read_lumps(wad_path):
    """Return {lump name: (sample rate, 8-bit unsigned PCM)} for DMX sounds."""
    data = open(wad_path, "rb").read()
    _, count, directory = struct.unpack_from("<4sii", data, 0)
    sounds = {}
    for i in range(count):
        offset, size, name = struct.unpack_from("<ii8s", data, directory + 16 * i)
        name = name.rstrip(b"\0").decode("ascii")
        if not name.startswith("DS") or size < 8:
            continue
        fmt, rate, samples = struct.unpack_from("<HHI", data, offset)
        if fmt == 3:
            # DMX sounds carry 16 bytes of padding at each end of the samples.
            sounds[name] = (rate, data[offset + 8 + 16: offset + 8 + samples - 16])
    return sounds


def main():
    wad_path, out_dir = sys.argv[1:3]
    lumps = read_lumps(wad_path)
    with tempfile.TemporaryDirectory() as tmp:
        for out_name, (lump, pitch) in SOUNDS.items():
            rate, pcm = lumps[lump]
            wav = os.path.join(tmp, lump + ".wav")
            with wave.open(wav, "wb") as w:
                w.setnchannels(1)
                w.setsampwidth(1)
                w.setframerate(rate)
                w.writeframes(pcm)
            # Changing the sample rate shifts pitch; resample back to 22050 Hz.
            audio_filter = "asetrate=%d,aresample=22050" % int(rate * pitch)
            target = os.path.join(out_dir, "mesecraft_mobs_%s.ogg" % out_name)
            subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", wav,
                            "-af", audio_filter, "-ac", "1", "-c:a", "libvorbis",
                            "-q:a", "3", "-map_metadata", "-1", target], check=True)


if __name__ == "__main__":
    main()
