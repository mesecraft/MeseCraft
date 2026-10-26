
-- More Ores
-- Original mod by Calinou with help from Nore
-- Re-coded by TenPlus1

local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

-- Minerals

minetest.register_node("moreores:mineral_silver", {
	description = S("%s Ore"):format(S("Silver")),
	tiles = {"default_stone.png^moreores_mineral_silver.png"},
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
	drop = "moreores:silver_lump",
})

minetest.register_node("moreores:mineral_mithril", {
	description = S("%s Ore"):format(S("Mithril")),
	tiles = {"default_stone.png^moreores_mineral_mithril.png"},
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
	drop = "moreores:mithril_lump",
})

-- Ores

minetest.register_craftitem("moreores:silver_lump", {
	description = S("%s Lump"):format(S("Silver")),
	inventory_image = "moreores_silver_lump.png",
})

minetest.register_craftitem("moreores:mithril_lump", {
	description = S("%s Lump"):format(S("Mithril")),
	inventory_image = "moreores_mithril_lump.png",
})

-- Ingots

minetest.register_craftitem("moreores:silver_ingot", {
	description = S("%s Ingot"):format(S("Silver")),
	inventory_image = "moreores_silver_ingot.png",
})

minetest.register_craftitem("moreores:mithril_ingot", {
	description = S("%s Ingot"):format(S("Mithril")),
	inventory_image = "moreores_mithril_ingot.png",
})

-- Helpers

local c = "moreores:silver_ingot"
local m = "moreores:mithril_ingot"

-- Cooking Ores into Ingots

minetest.register_craft({
	type = "cooking",
	output = c,
	recipe = "moreores:silver_lump",
})

minetest.register_craft({
	type = "cooking",
	output = m,
	recipe = "moreores:mithril_lump",
})

-- Blocks

minetest.register_node("moreores:silver_block", {
	description = S("%s Block"):format(S("Silver")),
	tiles = {"moreores_silver_block.png"},
	groups = {snappy = 1, bendy = 2, cracky = 1, melty = 2, level= 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("moreores:mithril_block", {
	description = S("%s Block"):format(S("Mithril")),
	tiles = {"moreores_mithril_block.png"},
	groups = {snappy = 1, bendy = 2, cracky = 1, melty = 2, level= 2},
	sounds = default.node_sound_metal_defaults(),
})

-- Ingot to Block Crafts and vice-versa

minetest.register_craft( {
	output = "moreores:silver_block",
	recipe = {{c, c, c}, {c, c, c}, {c, c, c}},
})

minetest.register_craft( {
	output = c .. " 9",
	recipe = {{"moreores:silver_block"}}
})

minetest.register_craft( {
	output = "moreores:mithril_block",
	recipe = {{m, m, m}, {m, m, m}, {m, m, m}},
})

minetest.register_craft( {
	output = m .. " 9",
	recipe = {{"moreores:mithril_block"}}
})

-- Mapgen Ores

minetest.register_ore({
	ore_type = "scatter",
	ore = "moreores:mineral_silver",
	wherein = "default:stone",
	clust_scarcity = 16*16*16,
	clust_num_ores = 4,
	clust_size = 11,
	y_min = -31000,
	y_max = -512,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "moreores:mineral_mithril",
	wherein = "default:stone",
	-- MeseCraft: about one ore per 4600 nodes, from just below the primordial caverns.
	clust_scarcity = 24*24*24,
	clust_num_ores = 3,
	clust_size = 3,
	y_min = -31000,
	y_max = -4100,
})

-- Silver Tools

minetest.register_tool("moreores:pick_silver", {
	description = S("%s Pickaxe"):format(S("Silver")),
	inventory_image = "moreores_tool_silverpick.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 3,
		groupcaps = {
			cracky = {times = {[1] = 2.60, [2] = 1.00, [3] = 0.60}, uses = 100, maxlevel = 1},
		},
		damage_groups = {fleshy = 6},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("moreores:shovel_silver", {
	description = S("%s Shovel"):format(S("Silver")),
	inventory_image = "moreores_tool_silvershovel.png",
	wield_image = "moreores_tool_silvershovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 3,
		groupcaps = {
			crumbly = {times = {[1] = 1.10, [2] = 0.40, [3] = 0.25}, uses = 100, maxlevel = 1},
		},
		damage_groups = {fleshy = 6},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("moreores:axe_silver", {
	description = S("%s Axe"):format(S("Silver")),
	inventory_image = "moreores_tool_silveraxe.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 3,
		groupcaps = {
			choppy = {times = {[1] = 2.50, [2] = 0.80, [3] = 0.50}, uses = 100, maxlevel = 1},
			fleshy = {times = {[2] = 1.10, [3] = 0.60}, uses = 100, maxlevel = 1}
		},
		damage_groups = {fleshy = 6},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("moreores:sword_silver", {
	description = S("%s Sword"):format(S("Silver")),
	inventory_image = "moreores_tool_silversword.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 3,
		groupcaps = {
			fleshy = {times = {[2] = 0.70, [3] = 0.30}, uses = 100, maxlevel = 1},
			snappy = {times = {[2] = 0.70, [3] = 0.30}, uses = 100, maxlevel = 1},
			choppy = {times = {[3] = 0.80}, uses = 100, maxlevel = 0}
		},
		damage_groups = {fleshy = 6},
	},
	sound = {breaks = "default_tool_breaks"},
})

-- Silver Tool Crafts

minetest.register_craft({
	output = "moreores:pick_silver",
	recipe = {{c, c, c}, {"", "group:stick", ""}, {"", "group:stick", ""}}
})

minetest.register_craft({
	output = "moreores:shovel_silver",
	recipe = {{c}, {"group:stick"}, {"group:stick"}}
})

minetest.register_craft({
	output = "moreores:axe_silver",
	recipe = {{c, c}, {c, "group:stick"}, {"", "group:stick"}}
})

minetest.register_craft({
	output = "moreores:sword_silver",
	recipe = {{c}, {c}, {"group:stick"}}
})

-- Mithril Tools

minetest.register_tool("moreores:pick_mithril", {
	description = S("%s Pickaxe"):format(S("Mithril")),
	inventory_image = "moreores_tool_mithrilpick.png",
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level = 3,
		groupcaps = {
			cracky = {times = {[1] = 2.25, [2] = 0.55, [3] = 0.35}, uses = 200, maxlevel = 2},
		},
		damage_groups = {fleshy = 9},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("moreores:shovel_mithril", {
	description = S("%s Shovel"):format(S("Mithril")),
	inventory_image = "moreores_tool_mithrilshovel.png",
	wield_image = "moreores_tool_mithrilshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level = 3,
		groupcaps = {
			crumbly = {times = {[1] = 0.70, [2] = 0.35, [3] = 0.20}, uses = 200, maxlevel = 2},
		},
		damage_groups = {fleshy = 9},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("moreores:axe_mithril", {
	description = S("%s Axe"):format(S("Mithril")),
	inventory_image = "moreores_tool_mithrilaxe.png",
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level = 3,
		groupcaps = {
			choppy = {times = {[1] = 1.75, [2] = 0.45, [3] = 0.45}, uses = 200, maxlevel = 2},
			fleshy = {times = {[2] = 0.95, [3] = 0.30}, uses = 200, maxlevel = 1}
		},
		damage_groups = {fleshy = 9},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("moreores:sword_mithril", {
	description = S("%s Sword"):format(S("Mithril")),
	inventory_image = "moreores_tool_mithrilsword.png",
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level = 3,
		groupcaps = {
			fleshy = {times = {[2] = 0.65, [3] = 0.25}, uses = 200, maxlevel = 2},
			snappy = {times = {[2] = 0.70, [3] = 0.25}, uses = 200, maxlevel = 2},
			choppy = {times = {[3] = 0.65}, uses = 200, maxlevel = 0}
		},
		damage_groups = {fleshy = 9},
	},
	sound = {breaks = "default_tool_breaks"},
})

-- Mithril Tool Crafts

minetest.register_craft({
	output = "moreores:pick_mithril",
	recipe = {{m, m, m}, {"", "group:stick", ""}, {"", "group:stick", ""}}
})

minetest.register_craft({
	output = "moreores:shovel_mithril",
	recipe = {{m}, {"group:stick"}, {"group:stick"}}
})

minetest.register_craft({
	output = "moreores:axe_mithril",
	recipe = {{m, m}, {m, "group:stick"}, {"", "group:stick"}}
})

minetest.register_craft({
	output = "moreores:sword_mithril",
	recipe = {{m}, {m}, {"group:stick"}}
})

-- Compatibility

minetest.register_alias("moreores:mineral_tin", "default:stone_with_tin")
minetest.register_alias("moreores:tin_ingot", "default:tin_ingot")
minetest.register_alias("moreores:tin_block", "default:tinblock")
minetest.register_alias("moreores:tin_lump", "default:tin_lump")

-- mesecraft_toolranks Mod Support

local function add_tool(name, desc, afteruse)

	minetest.override_item(name, {
		original_description = desc,
		description = mesecraft_toolranks.create_description(desc, 0, 1),
		after_use = afteruse and mesecraft_toolranks.new_afteruse
	})
end

if minetest.get_modpath("mesecraft_toolranks") then

	add_tool("moreores:pick_silver", S("%s Pickaxe"):format(S("Silver")), true)
	add_tool("moreores:axe_silver", S("%s Axe"):format(S("Silver")), true)
	add_tool("moreores:shovel_silver", S("%s Shovel"):format(S("Silver")), true)
	add_tool("moreores:sword_silver", S("%s Sword"):format(S("Silver")), true)

	add_tool("moreores:pick_mithril", S("%s Pickaxe"):format(S("Mithril")), true)
	add_tool("moreores:axe_mithril", S("%s Axe"):format(S("Mithril")), true)
	add_tool("moreores:shovel_mithril", S("%s Shovel"):format(S("Mithril")), true)
	add_tool("moreores:sword_mithril", S("%s Sword"):format(S("Mithril")), true)
end

print ("[MOD] moreores " .. S("loaded"))
