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
-- Every mod in the game, since mods share their API through a global named after the mod.
-- Regenerate when adding mods:
--   grep -rh '^name *=' mods --include=mod.conf | sed 's/name *= *//' | sort -u
globals = {"minetest", "core",
	"24hr_clock", "3d_armor", "3d_armor_flyswim", "3d_armor_sfinv", "3d_armor_stand", "afk", "awards",
	"basic_materials", "bees", "bell", "big_webs", "boats", "bonemeal", "bones_loot", "builtin_item",
	"bulletin_boards", "bweapons_api", "bweapons_bows_pack", "bweapons_firearms_pack",
	"bweapons_hitech_pack", "bweapons_magic_pack", "bweapons_utility_pack", "candles", "carpets",
	"carts", "castle", "cblocks", "ccompass", "chasms", "chat_colorize", "cleaner", "climate_api",
	"cloudlands", "commoditymarket", "commoditymarket_fantasy", "compost", "craftguide",
	"crafting_bench", "creative", "curtains", "death_compass", "decoblocks", "decorations_sea",
	"default", "df_achievements", "df_ambience", "df_caverns", "df_dependencies", "df_farming",
	"df_mapitems", "df_primordial_items", "df_trees", "df_underworld_items", "digilines", "doors",
	"drawers", "drinks", "dungeon_loot", "dye", "dynamic_liquid", "elevator", "emoji", "env_sounds",
	"extra_doors", "fancy_vend", "farming", "fire", "fire_plus", "fireflies", "floodables", "flowers",
	"footprints", "fruit_tools", "gadgets_api", "gadgets_consumables", "gadgets_default_effects",
	"gadgets_magic", "game_commands", "geomoria", "geomoria_lootchests", "give_initial_stuff",
	"gramophone", "hangglider", "hbarmor", "hbhunger", "headanim", "helicopter", "hidden_doors",
	"hopper", "hudbars", "hunter_statue", "ice_sprites", "ingots", "item_drop", "itemframes", "keys",
	"leaves_in_the_wind", "led_marquee", "lightning", "looped_node_sound", "lootchests",
	"lootchests_default", "lootchests_magic_materials", "magic_materials", "magma_conduits", "mana",
	"map", "mapgen_helper", "mesecons", "mesecons_alias", "mesecons_blinkyplant", "mesecons_button",
	"mesecons_commandblock", "mesecons_delayer", "mesecons_detector", "mesecons_doors",
	"mesecons_extrawires", "mesecons_fpga", "mesecons_gamecompat", "mesecons_gates",
	"mesecons_hydroturbine", "mesecons_insulated", "mesecons_lamp", "mesecons_lightstone",
	"mesecons_luacontroller", "mesecons_materials", "mesecons_microcontroller", "mesecons_movestones",
	"mesecons_mvps", "mesecons_noteblock", "mesecons_pistons", "mesecons_powerplant",
	"mesecons_pressureplates", "mesecons_random", "mesecons_receiver", "mesecons_solarpanel",
	"mesecons_stickyblocks", "mesecons_switch", "mesecons_torch", "mesecons_walllever",
	"mesecons_wires", "mesecraft_announcements", "mesecraft_baked_clay", "mesecraft_bedrock",
	"mesecraft_beds", "mesecraft_binoculars", "mesecraft_bones", "mesecraft_bucket",
	"mesecraft_butterflies", "mesecraft_christmas", "mesecraft_companion_cube",
	"mesecraft_death_messages", "mesecraft_diet", "mesecraft_fireplace", "mesecraft_furniture",
	"mesecraft_gauges", "mesecraft_guides", "mesecraft_halloween", "mesecraft_holiday_lights", "mesecraft_journal",
	"mesecraft_lua", "mesecraft_magic_mirror", "mesecraft_mailbox", "mesecraft_mars",
	"mesecraft_miners_helmet", "mesecraft_mobs", "mesecraft_overrides", "mesecraft_seasonal",
	"mesecraft_soundscapes", "mesecraft_spacesuit", "mesecraft_television", "mesecraft_toolranks",
	"mesecraft_torch", "mesecraft_void_chest", "mine_gas", "mob_horse", "mobs", "mobs_npc", "moognu",
	"moon_phases", "moreblocks", "morelights", "morelights_extras", "morelights_vintage", "moreores",
	"mp_morelights", "mtg_plus", "named_waypoints", "namegen", "nether",
	"new_fireworks", "oil", "orbs_of_time", "other_worlds", "paintings", "parties", "pie", "pigiron",
	"pit_caves", "player_api", "player_monoids", "playereffects", "playerfactions", "playerplus",
	"pontoons", "protector", "pyramids", "radiant_damage", "radioactive_gas", "realcompass",
	"regional_weather", "ropes", "scifi_nodes", "screwdriver", "sethome", "settlements",
	"settlements_desert", "settlements_igloo", "settlements_jungle", "settlements_medieval",
	"settlements_mer", "settlements_ruins", "sfinv", "shields", "shipwrecks", "show_wielded_item",
	"signs", "slats", "slimes", "smoke", "snowsong", "sounding_line", "spawn", "stairs", "stm_nodes",
	"subterrane", "thirsty", "tnt", "tnt_revamped", "torch_bomb", "trash_can", "treasurer",
	"tsm_railcorridors", "vacuum", "vessels", "walls", "weather", "wielded_light", "wieldview",
	"wool", "xpanes",
}

read_globals = {
	-- Luanti engine
	"vector", "ItemStack", "VoxelArea", "VoxelManip", "Settings", "AreaStore",
	"PseudoRandom", "PcgRandom", "SecureRandom", "PerlinNoise", "PerlinNoiseMap",
	"Raycast", "dump", "dump2", "DIR_DELIM", "INIT",

	-- Engine extensions to the Lua stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "copy_with_metatables", "indexof", "insert_all", "key_value_swap", "shuffle", "getn", "unpack"}},
	math = {fields = {"hypot", "sign", "factorial", "round"}},

	-- Mod APIs whose global differs from the mod name
	"otherworlds",

	-- Optional dependencies that are not part of this game
	"intllib", "moretrees", "pova", "technic", "pipeworks", "ethereal", "doc", "mail",
	"digiline", "cmi", "lucky_block", "areas", "unified_inventory", "wardrobe",
	"skins", "u_skins", "i3", "mcl_sounds", "mcl_vars", "mcl_mapgen", "mcl_formspec",
	"mcl_core", "hunger", "biomeinfo", "skybox", "flowerpot", "music", "loot",
}
