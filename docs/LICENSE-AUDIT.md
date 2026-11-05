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

**Not problems:**
- Similarities in Minetest Game's rails, TNT, steel trapdoor and footsteps: that is Minetest Game's own art.
- dfcaverns `jungle_wood_02`, which was made in 2020, before Minecraft's cherry wood.

## Still open

1. **Mob skins:** about 25 skins on `mobs_character.b3d` have no credit and are probably from Planet Minecraft, where skins are all rights reserved unless stated otherwise. They need replacing with original or freely licensed skins:
   - astronaut, blood man, bogeyman, boomer, cyberdemon, diamond man, dirt man, fire imp, fire man, ghost, murderous ghost, gold man
   - grey civilian, grey enlisted, hell baron, imp, iron man, magma man, mancubus, reptilian elite, sand man, stone man, water man, zombie, space zombie
2. **Other uncredited mob textures:**
   - bat, cacodemon, cave crocodile, cave floater, crocodile, deer, demon eye, facehugger, flying saucer, jabberer, kangaroo, panda, penguin
   - pinky, rat, shark (the base texture is credited), skeleton bow and sword, skull, tree monster, clownfish 1 to 13
3. **Mobs based on DOOM:** cacodemon, cyberdemon, mancubus, hell baron, imp, pinky and the skull (lost soul) use id Software's character names and look-alike designs. They will be renamed and redesigned. Their sounds already come from Freedoom.
4. **Mob sounds:** about 270 sounds in `mesecraft_mobs` have no recorded source.
5. **Mods without license information:**
   - `curtains` by Jozet, based on xdecor's curtains
   - `radioactive_gas`
6. **To check:** `drawers_controller_top.png` looks somewhat like Minecraft's smooth stone slab. It's a partial match, not a copy.
