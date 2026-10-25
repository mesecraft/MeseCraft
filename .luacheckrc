-- Luacheck config for the whole game. Run from the repo root:
--   luacheck mods/path/to/changed_file.lua
-- Covers mods/MODULES and mods/MTG too: they are vendored but customized for MeseCraft.
-- Nested .luacheckrc files in vendored mods are only used when luacheck runs from that mod's directory.

std = "luajit"
max_line_length = false
unused_args = false

-- Mods share state through top-level globals (e.g. `mesecraft_toolranks = {}`).
allow_defined_top = true

ignore = {
	"6..", -- whitespace and formatting
}

-- Mods override engine functions such as minetest.item_drop.
globals = {"minetest", "core"}

read_globals = {
	-- Luanti engine
	"vector", "ItemStack", "VoxelArea", "VoxelManip", "Settings", "AreaStore",
	"PseudoRandom", "PcgRandom", "SecureRandom", "PerlinNoise", "PerlinNoiseMap",
	"Raycast", "dump", "dump2", "DIR_DELIM", "INIT",

	-- Engine extensions to the Lua stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "copy_with_metatables", "indexof", "insert_all", "key_value_swap", "shuffle", "getn", "unpack"}},
	math = {fields = {"hypot", "sign", "factorial", "round"}},

	-- Optional dependencies that are not part of this game
	"intllib", "moretrees", "pova", "technic", "pipeworks", "ethereal", "doc", "mail",
	"digiline", "cmi", "lucky_block", "areas", "unified_inventory", "wardrobe",
	"skins", "u_skins", "i3", "mcl_sounds", "mcl_vars", "mcl_mapgen", "mcl_formspec",
	"mcl_core", "hunger", "biomeinfo", "skybox", "flowerpot", "music", "loot",
}
