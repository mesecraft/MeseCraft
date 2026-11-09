MeseCraft Game mod: beds
=======================
See license.txt for license information.

This is a modified version of beds for MeseCraft that dumps the fancy_bed and includes colored versions of the simple bed. Also merges the featuers of bouncy_bed into the mod. Source and functions are based on the mtg beds mod. The colored beds nodes are based on colored beds by Napiophelios which is under MIT license.

Authors of source code
----------------------
Originally by BlockMen (MIT)
Various Minetest developers and contributors (MIT)

Authors of media (textures)
---------------------------
BlockMen (CC BY-SA 3.0)
 All textures unless otherwise noted

TumeniNodes (CC BY-SA 3.0)
 beds_bed_under.png

This mod adds a bed to Minetest which allows players to skip the night.
To sleep, right click on the bed. If playing in singleplayer mode the night gets skipped
immediately. If playing multiplayer you get shown how many other players are in bed too,
if all players are sleeping the night gets skipped. The night skip can be forced if more
than half of the players are lying in bed and use this option.

Another feature is a controlled respawning. If you have slept in bed (not just lying in
it) your respawn point is set to the beds location and you will respawn there after
death.
You can disable the respawn at beds by setting "enable_bed_respawn = false" in
minetest.conf.
You can disable the night skip feature by setting "enable_bed_night_skip = false" in
minetest.conf or by using the /set command in-game.

Sounds
------
bouncy.ogg: Blender Foundation, CC BY 3.0 (https://creativecommons.org/licenses/by/3.0/),
from MeseCraft's bouncy_bed mod.
