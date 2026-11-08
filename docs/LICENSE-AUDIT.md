# MeseCraft license audit

MeseCraft was temporarily removed from ContentDB over copyright concerns. This document records how the game's media was checked, what was found, what has been fixed, and what is still open. It is kept up to date as items are resolved.

## How the media was checked (November 2026)

- **Textures:** all 4,150 PNG files were compared against the textures in eleven Minecraft client versions, from 1.2.5 to 26.3, taken from Mojang's own downloads. The comparison used exact pixel matches and image similarity. Every flagged pair was then checked by eye. They were also compared with Mineclonia's free textures.
- **Sounds:** all 972 sound files were compared against Minecraft's 8,417 sounds, first for identical files and then by waveform. They were also compared against the original DOOM sounds and the Freedoom sounds.
- **Licenses:** every mod's license files and credits were read, looking for missing licenses, missing credits and non-commercial terms.

**Second scan (8 November 2026):**
- **Textures:** all 4,159 PNG files were compared again against Minecraft 1.2.5, 1.7.10, 1.12.2 and 26.3 (Mojang's downloads and a local install), including flipped, rotated, recoloured and enlarged copies. A separate pass looked for textures whose transparent outline matches a Minecraft texture exactly, which catches recolours. Every candidate was checked by eye.
- **Sounds:** all 974 sound files were fingerprinted against Minecraft's 5,927 sounds from 1.2.5 to 26.3, allowing for trimming and re-encoding. Control copies of Minecraft sounds scored as matches, so the method works. Close candidates were confirmed by waveform correlation.
- **Licenses:** every mod was checked for a license file and for copyleft notices. All 180 freesound.org links and 10 soundbible.com links in the credits were checked against their current license pages. Untraced music was compared against Kevin MacLeod's library.

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
| `fruit_tools`: `melon_slice.png` | Minecraft's melon slice, mirrored | Removed. The thrown melon uses Farming Redo's melon slice |
| `mesecraft_torch`: `mesecraft_torch_coal_powder.png` | Minecraft's gunpowder outline, darkened | Redrawn by `utils/skingen/items.py` |
| `mesecraft_mobs`: bat, sheep, deer, clownfish and demon eye textures; skeleton sword and bow | No traceable source. The bat and sheep were wrongly credited to Mineclonia | Repainted by `utils/skingen/repaint.py`, which keeps only the UV layout; sword and bow redrawn |
| `mesecraft_christmas`: 7 mob skins and 8 costumes | Uncredited skins from skin sites; the orange parka copied Kenny from South Park | Redrawn by `utils/skingen/holiday.py` |
| `mesecraft_halloween`: 9 mob skins; wizard, forest spirit and killer costumes | Uncredited skins; costumes copied Harry Potter, Totoro and Michael Myers | Redrawn by `utils/skingen/holiday.py`. The other costumes are GreenXenith's (MIT), now credited |
| `mesecraft_christmas`: reindeer, garlands, candy cane and other items | Not credited | Credited to GreenXenith's christmas_decor (MIT) |
| `mesecraft_christmas`: sleigh bell and reindeer sounds | No source recorded | Replaced with CC0 freesound recordings. The bell and Santa sounds were traced to CC0 sources |
| `mesecraft_magic_mirror`: teleport sound | No source recorded | Replaced with a sound made for MeseCraft (CC0) |
| `gramophone`: Christmas records | No source recorded | Three traced to Kevin MacLeod (CC BY 4.0) and credited; "Jingle Bells" replaced with his version |
| `gramophone`: `DISABLED.txt` | Said the mod was disabled for a non-commercial license, but it still loaded | The non-commercial track was already replaced in 2023; the stale note was removed |
| `mesecraft_announcements` | Forked from a mod with no findable license | Rewritten for MeseCraft (AGPLv3) |
| `mesecraft_mobs`: three missing sounds (bogeyman damage, panda, skeleton fighter) | Referenced but missing | Built from Freedoom, or pointed at existing credited sounds |
| bweapons, gadgets and lootchests modpacks, castle, decorations_sea, magic_materials, shipwrecks, cleaner, signs, lightning, hbhunger, show_wielded_item | GPL/LGPL code without the license text | `LICENSE.txt` added with the full GNU text |
| hbarmor, hudbars, mana, mtg_plus, playereffects, pyramids, tsm_railcorridors | MIT code without the notice | `LICENSE.txt` added with the MIT notice |
| MeseCraft's own mods without a license file | Unclear license | `LICENSE.txt` added pointing to the game's AGPLv3 |
| Credit fixes | | `mesecraft_bucket` credits ElementW for the bucket textures; `mesecraft_beds` credits the Blender Foundation (CC BY 3.0) for `bouncy.ogg`; SnowSong credits for toolranks and mob_horse sounds; stale credits for replaced sounds and skins removed from the code |

**Not problems:**
- Similarities in Minetest Game's rails, TNT, steel trapdoor and footsteps: that is Minetest Game's own art.
- dfcaverns `jungle_wood_02`, which was made in 2020, before Minecraft's cherry wood.
- Minetest Game's `default_break_glass.1.ogg` is the same recording as an old Minecraft glass sound. Minetest Game credits it to cmusounddesign on freesound.org (CC BY 3.0); both games used the same free recording.
- Buckets share Minecraft's bucket outline because they are edits of Minetest Game's bucket by ElementW (CC BY-SA 3.0).
- The two laurent recordings listed in `mesecraft_soundscapes` (now non-commercial on freesound) are in the "not used" notes; no files from them ship.
- dfcaverns credits two freesound sounds that were deleted from freesound since; dfcaverns recorded them as CC0, which can't be withdrawn.
- Mob textures for Mineclonia's mobs match Minecraft's layout because they are drawn for the same models; the textures themselves are Pixel Perfection's (CC BY-SA 4.0).

## Still open

1. **Christmas item icons with unconfirmed sources:** about 20 small textures credited to "IAmJoshuaStone" and "C_is_CREATIVE" without a license (cookies, candies, stockings, mistletoe, the bell, gingerbread, the red chest, crop stages), and the candy cane block credited to GreenXenith but not found in christmas_decor. They match nothing in Minecraft or the other Christmas mods checked. Listed in `mods/mesecraft_christmas/attributions.txt`.
2. **Models:** 3D models were not compared against Minecraft. The bat model's source is not recorded.
3. **To check:** `drawers_controller_top.png` looks somewhat like Minecraft's smooth stone slab. It's a partial match, not a copy.
