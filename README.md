MeseCraft - A blocky survival game.
==========================
Copyright (C) 2019-2026 MeseCraft
<contact@mesecraft.com>


Description
-------------------------
MeseCraft is a singleplayer and multiplayer blocky survival game for Luanti. Explore, survive, and craft in a beautiful and dangerous world. Discover unique biomes, mobs, villages, items, caverns, the Moon and Mars, magic, tech, holiday events, and more. Craft a new adventure with MeseCraft! https://www.mesecraft.com

Design philosophy
-------------------------
* **Fun and featured.** Plenty to discover, built from the best of the Luanti community's mods and MeseCraft's own.
* **Efficient.** Features have to earn their cost. MeseCraft should run well on modest servers and devices, so heavy per-node or per-tick work is avoided or replaced.
* **Stable.** Updates must not break existing worlds. Removed or renamed items are aliased, and old builds are converted rather than lost.
* **User-friendly.** Things should work the way players expect, without reading a manual.
* **Built on Minetest Game.** MeseCraft runs on top of an unmodified copy of Minetest Game, so it can be updated from upstream. MeseCraft's changes live in its own mods.
* **Free to share.** All code and media are freely licensed. No non-commercial licenses and no assets taken or derived from Minecraft.

Requirements
--------------------------
Luanti 5.11.0 or newer is recommended. MeseCraft is tested up to Luanti 5.17.
Luanti is freely available on most platforms: https://www.luanti.org/downloads/

Installation
-------------------------
From Luanti:
1. Open Luanti.
2. Go to the "Content" tab.
3. Press the "Browse online content" button.
4. Go to the "Games" tab.
5. Search for "MeseCraft".
6. Find "MeseCraft" by MeseCraft. When you find it, click on it.
7. Click on the green "Install" button. Luanti will download and install the game.
8. Finally, you can play MeseCraft from the "Start Game" tab in Luanti.

From source: clone https://github.com/mesecraft/MeseCraft into the `games` folder of your Luanti user directory (for example `~/.minetest/games/mesecraft`).

Development
-------------------------
The game is actively supported and maintained. Please report bugs at https://github.com/mesecraft/MeseCraft/issues so they can be reviewed and fixed. Help is welcome; join our community of players and developers at https://www.mesecraft.com.

Before sending changes:
* Run `luacheck` on the Lua files you changed and fix any new warnings.
* Run `utils/check.sh`. It loads the game and fails on Lua errors, engine warnings, or recipes that use unknown items.
* Don't edit `mods/MTG`. Change Minetest Game behavior from MeseCraft's mods instead (see `mods/mesecraft_overrides`).

Branches
-------------------------
There are two branches of MeseCraft:
* `main`: The stable version of MeseCraft. For players and server operators. It prioritizes operational stability to create a positive gameplay experience.
* `dev`: The development version of MeseCraft. For testers and developers. New code, fixes, and pull requests should target here.

Credits
-------------------------
* Game Design - Komodo (Jeremy Weston)
* MeseCraft players & community members.
* The Luanti community
* Minetest Modders

See each mod's license and credits files for its authors and media sources.

License
--------------------------
GNU AFFERO GENERAL PUBLIC LICENSE VERSION 3. Bundled mods keep their own licenses.
