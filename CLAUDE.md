# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

MeseCraft is a Luanti (formerly Minetest) **game**: a collection of Lua mods loaded by the engine, not a standalone program. Target engine is Luanti 5.11.0+. The runtime is LuaJIT, and the engine API is still exposed under the `minetest.*` global, which the existing code uses throughout. Licensed AGPLv3.

## Branches

- `dev`: where development happens. New code, fixes and PRs target `dev`.
- `main`: the stable branch for players and server operators. Small fixes sometimes land on `main` first and are then merged back into `dev`.

## Licensing of content

Don't add code or assets that are under non-commercial licenses (e.g. CC BY-NC) or that come from Minecraft (textures, sounds, models, or anything derived from them). This applies to vendored mods too: a texture once had to be replaced because of a copyright issue with `mobs_mc`. Check a mod's or asset's license before you bring it in.

## Running / testing

There is no build step, test suite or repo-level linter. You check changes by loading the game in the engine (`/usr/games/luanti` is installed). Because this directory sits in `~/.minetest/games/`, the engine picks it up as game id `mesecraft`. For example:

```
luanti --server --gameid mesecraft --world /path/to/test-world   # headless; Lua errors print to the terminal
```

You can also start a world from the Luanti UI. Lua load errors and `minetest.log` output also go to `~/.minetest/debug.txt`.

`.luarc.json` configures lua-language-server, with `lowercase-global` and `undefined-global` diagnostics turned off, because mods share state through globals. Some vendored mods include their own `.luacheckrc` and CI workflows. Those belong to the upstream projects and are not run for this repo.

`utils/optimize-textures.sh` runs optipng over the textures. `utils/pallette/` holds the reference color palette for textures.

## Layout and architecture

- `game.conf`: game metadata.
- `minetest.conf`: settings for this game only. It enables and disables features (TNT, fire, weather, bones, initial stuff) and holds per-mod configuration for the bundled mods, such as cloudlands altitude, dfcaverns layer depths and commoditymarket markets. When you change a bundled mod's behavior, check here before editing its code.
- `menu/`: main-menu art and theme music.
- `mods/MTG/`: a modpack copied from Minetest Game (`default`, `player_api`, `sfinv`, `stairs`, etc.). Most other mods build on this base.
- `mods/MODULES/`: a modpack of more than 100 third-party mods, vendored in-tree with no submodules. Many have been patched locally to integrate with MeseCraft; about 45 of them reference `mesecraft_*` mods. Edit them in place, and keep in mind that upstream updates have to be merged by hand.
- `mods/mesecraft_*`: mods written for or maintained by MeseCraft (mobs, moon/"lua" dimension, holidays, furniture, toolranks, etc.).

Each mod has a `mod.conf` (`name`, `description`, `depends`, `optional_depends`, `author`, `title`). Legacy `depends.txt` and `description.txt` files were removed for ContentDB, so don't add them back. Load order follows `depends`. Integration between mods is optional and guarded: a mod lists the other mod in `optional_depends` and wraps the integration in `if minetest.get_modpath("other_mod") then ... end`.

Each mod's `init.lua` typically gets `minetest.get_modpath(...)` and then calls `dofile()` on one file per feature. `mesecraft_mobs/init.lua`, for example, loads one file per mob from `mobs/` and the drops and food from `items/`. Mobs are built on `mobs_redo` (`mobs:register_mob`). Translations use `minetest.get_translator(modname)`.

### Cross-mod interfaces worth knowing

- **Tool ranks** (`mods/mesecraft_toolranks`): tools gain levels with use. The preferred hook is `mesecraft_toolranks.register_tool("mod:toolname")`. It overrides the item's description and wraps any existing `after_use` while preserving its wear, and it ignores duplicate registrations. Older integrations (moreores, christmas tools, farming hoes, etc.) instead set `description = mesecraft_toolranks.create_description(...)`, `original_description` and `after_use = mesecraft_toolranks.new_afteruse` by hand.
- **Moon dimension** (`mods/mesecraft_lua`): configured through `mesecraft_lua.miny`, `mesecraft_lua.maxy` and `mesecraft_lua.maxsolidy` settings (defaults 3000/3300/3200). It registers a portal only when `nether` is present.
- Holiday content (`mesecraft_christmas`, `mesecraft_halloween`, `mesecraft_holiday_lights`) changes recipes and items from other mods. When you rename items, update every recipe and loot reference across mods. `mesecraft_christmas` crafts, stockings and presents are an example.
