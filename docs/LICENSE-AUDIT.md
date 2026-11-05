# MeseCraft license audit

MeseCraft was temporarily removed from ContentDB over copyright concerns. This document records how the game's media was checked, what was found, what has been fixed, and what is still open. It is kept up to date as items are resolved.

## How the media was checked (November 2026)

- **Textures:** all 4,150 PNG files were compared against the textures in eleven Minecraft client versions, from 1.2.5 to 26.3, taken from Mojang's own downloads. The comparison used exact pixel matches and image similarity. Every flagged pair was then checked by eye. They were also compared with Mineclonia's free textures.
- **Sounds:** all 972 sound files were compared against Minecraft's 8,417 sounds, first for identical files and then by waveform. They were also compared against the original DOOM sounds and the Freedoom sounds.
- **Licenses:** every mod's license files and credits were read, looking for missing licenses, missing credits and non-commercial terms.

**Limits:** this can't detect copies that were redrawn by hand, sounds that were pitch-shifted, assets taken from other games, or 3D models.

## Fixed

| What | Problem | Fix |
|---|---|---|
| `farming`: melon block, melon stem and barley stage textures | Matched Minecraft's melon and wheat | Replaced with upstream Farming Redo's 2022 redraws: TenPlus1 (CC BY 3.0), and the melon block by alerikaisattera (CC BY-SA 4.0) |
| `pie`: `pie_inv.png` | Minecraft's cake | Removed. The inventory now shows the 3D cake |
| `emoji`: `emoji_sound.ogg` | Minecraft's experience orb sound, byte for byte | Replaced with a new sound made for MeseCraft (CC0) |
| `hangglider`: `hangglider_flak_shot.ogg` | Matched Minecraft's old explosion sound | Removed. It now plays the game's CC0 `tnt_explode` at a higher pitch |
| `helicopter`: `helicopter_motor.ogg` | Non-commercial license (Robinhood76, BY-NC) | Replaced with a new sound made for MeseCraft (CC0) |
| `new_fireworks`: both sounds | One was non-commercial (Syna-Max, BY-NC), and which file it was wasn't recorded | Rocket replaced with a new sound (CC0). The bang plays `tnt_explode` |
| `mesecraft_mobs`: cod, dolphin, turtle, snapper, wolf collar, spiderweb item, salmon | Copies of Minecraft textures (issue #111) | Replaced earlier with original art |
| `mesecraft_mobs`: 43 Mineclonia textures | Uncredited, or credited to the wrong source | Credited to Mineclonia and Pixel Perfection by XSSheep (CC BY-SA 4.0) in `credits.txt`. The spider was credited to lottmobs |
| `mesecraft_mobs`: 38 Freedoom sounds | Freedoom not credited; its BSD license requires the notice | Listed in `credits.txt` with `LICENSE-freedoom.txt`. None of the 959 sounds checked match the original DOOM |
| bees, smoke, paintings, itemframes, mob_horse, geomoria_lootchests | No license file | `LICENSE.txt` added, from each mod's upstream or its own code |
| `mesecraft_mobs`: 25 humanoid mob skins | Uncredited skins from skin sites, several copying Minecraft blocks (the boomer was a creeper with TNT) | Replaced with original skins drawn by `utils/skingen/skingen.py` |
| `mesecraft_mobs`: cacodemon, cyberdemon, mancubus, hell baron, imp, pinky and lost soul | Named and styled after DOOM's monsters | Renamed after Freedoom's monsters: trilobite, assault tripod, combat slug, pain lord, serpentipede, flesh worm and hatchling. Humanoid ones got new skins; D00Med's models (CC BY-SA 3.0) were recoloured by `utils/skingen/recolor.py`; all their sounds are Freedoom's |
| `mesecraft_mobs`: about 100 sounds | No recorded source, sounds from a deleted freesound pack (JarAxe), one from freesfx.co.uk (no redistribution), one BY-NC (Timbre) | Rebuilt from Freedoom (BSD) by `utils/mobsounds/freedoom_sounds.py`, which records each file's source |
| `mesecraft_mobs`: the other sounds | Not credited | Traced and credited: SnowSong by Alecia Shepherd (CC BY-SA 4.0, from the file tags), freesound.org CC0 and CC BY 4.0 sounds named in the mob code, and pooper (CC BY-SA 3.0) |
| `mesecraft_mobs`: jabberer, cave floater, facehugger, penguin, panda, crocodiles, kangaroo, flying saucer, rat, tree monster | Not credited | Credited from the sources named in the mob code: D00Med (CC BY-SA 3.0), AspireMint (CC BY-SA 3.0), ElCeejo (GPLv3), Zeg9's ufos (WTFPL), PilzAdam |
| `curtains` | No license; textures of unknown origin | Rewritten for MeseCraft with new textures (AGPLv3) |
| `radioactive_gas` | No license upstream (Pandorabox) | Rewritten for MeseCraft with a new texture (AGPLv3) |

**Not problems:**
- Similarities in Minetest Game's rails, TNT, steel trapdoor and footsteps: that is Minetest Game's own art.
- dfcaverns `jungle_wood_02`, which was made in 2020, before Minecraft's cherry wood.

## Still open

1. **Mob textures not traced yet:** the bat model, deer, clownfish (1 to 13), skeleton bow and sword, and the demon eye texture.
2. **To check:** `drawers_controller_top.png` looks somewhat like Minecraft's smooth stone slab. It's a partial match, not a copy.
