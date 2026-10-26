local S = minetest.get_translator(minetest.get_current_modname())

local required_nodes = {}
local function select_required(def)
	local newdef = {}
	for _, node in ipairs(def) do
		table.insert(newdef, {string.match(node, "(.-):"), node})
	end
	local ret = df_dependencies.select_required(newdef)
	table.insert(required_nodes, ret)
	return ret
end

local function select_optional(def)
	local newdef = {}
	for _, node in ipairs(def) do
		table.insert(newdef, {string.match(node, "(.-):"), node})
	end
	local ret = df_dependencies.select_optional(newdef)
	table.insert(required_nodes, ret)
	return ret
end


minetest.after(0, function()
	-- "after" needs to be used here because some of these nodes actually get registered in DF Caverns itself
	-- stair nodes, for example, depend on the stairs mod but get registered from here. Kind of weird but
	-- one goes to war with the mods one has.
	local problem_nodes = {}
	for _, node_name in pairs(required_nodes) do
		if minetest.registered_items[node_name] == nil then
			table.insert(problem_nodes, node_name)
		end
	end
	
	assert(#problem_nodes == 0, "Nodes " .. table.concat(problem_nodes, ", ") .. " were returned by a selection call but are not registered.")
end)


df_dependencies.node_name_apple = select_required({"default:apple", "mcl_core:apple"})
df_dependencies.node_name_chest = select_required({"default:chest", "mcl_chests:chest"})
df_dependencies.node_name_coalblock = select_required({"default:coalblock", "mcl_core:coalblock"})
df_dependencies.node_name_coal_lump = select_required({"default:coal_lump", "mcl_core:coal_lump"})
df_dependencies.node_name_cobble = select_required({"default:cobble", "mcl_core:cobble"})
df_dependencies.node_name_coral_skeleton = select_required({"default:coral_skeleton", "mcl_ocean:dead_horn_coral_block"})
df_dependencies.node_name_desert_sand = select_required({"default:desert_sand", "mcl_core:redsand"})
df_dependencies.node_name_dirt = select_required({"default:dirt", "mcl_core:dirt"})
df_dependencies.node_name_dry_grass_3 = select_required({"default:dry_grass_3", "mcl_core:deadbush"})  -- There doesn't seem to be an MCL equivalent of this
df_dependencies.node_name_dry_grass_4 = select_required({"default:dry_grass_4", "mcl_core:deadbush"}) -- There doesn't seem to be an MCL equivalent of this
df_dependencies.node_name_dry_shrub = select_required({"default:dry_shrub", "mcl_core:deadbush"})
df_dependencies.node_name_furnace = select_required({"default:furnace", "mcl_furnaces:furnace"})
df_dependencies.node_name_gold_ingot = select_required({"default:gold_ingot", "mcl_core:gold_ingot"})
df_dependencies.node_name_gravel = select_required({"default:gravel", "mcl_core:gravel"})
df_dependencies.node_name_ice = select_required({"default:ice", "mcl_core:ice"})
df_dependencies.node_name_junglewood = select_required({"default:junglewood", "mcl_core:junglewood"})
df_dependencies.node_name_lava_source = select_required({"default:lava_source", "mcl_core:lava_source"})
df_dependencies.node_name_mese_crystal = select_required({"mesecons:wire_00000000_off", "default:mese_crystal"}) --make sure default:mese_crystal is second, so that default will take priority if mesecons is also installed.
df_dependencies.node_name_mossycobble = select_required({"default:mossycobble", "mcl_core:mossycobble"})
df_dependencies.node_name_obsidian = select_required({"default:obsidian", "mcl_core:obsidian"})
df_dependencies.node_name_paper = select_required({"default:paper", "mcl_core:paper"})
df_dependencies.node_name_river_water_flowing = select_required({"default:river_water_flowing", "mclx_core:river_water_flowing"})
df_dependencies.node_name_river_water_source = select_required({"default:river_water_source", "mclx_core:river_water_source"})
df_dependencies.node_name_sand = select_required({"default:sand", "mcl_core:sand"})
df_dependencies.node_name_silver_sand = select_required({"default:silver_sand", "mcl_core:sand"}) -- There doesn't seem to be an MCL equivalent of this
df_dependencies.node_name_snow = select_required({"default:snow", "mcl_core:snow"})
df_dependencies.node_name_stone = select_required({"default:stone", "mcl_core:stone"})
df_dependencies.node_name_stone_with_coal = select_required({"default:stone_with_coal", "mcl_core:stone_with_coal"})
df_dependencies.node_name_stone_with_mese = select_required({"default:stone_with_mese", "mcl_core:stone_with_redstone"})
df_dependencies.node_name_torch = select_required({"default:torch", "mcl_torches:torch"})
df_dependencies.node_name_torch_wall = select_required({"default:torch_wall", "mcl_torches:torch_wall"})
df_dependencies.node_name_water_flowing = select_required({"default:water_flowing", "mcl_core:water_flowing"})
df_dependencies.node_name_water_source = select_required({"default:water_source", "mcl_core:water_source"})
df_dependencies.node_name_stone_with_iron = select_required({"default:stone_with_iron", "mcl_core:stone_with_iron"})
df_dependencies.node_name_steelblock = select_required({"default:steelblock", "mcl_core:ironblock"})
df_dependencies.node_name_stone_with_copper = select_required({"default:stone_with_copper", "mcl_copper:stone_with_copper"})
df_dependencies.node_name_copperblock = select_required({"default:copperblock", "mcl_copper:block_raw"})

df_dependencies.node_name_dirt_furrowed = select_required({"farming:soil", "mcl_farming:soil"})
df_dependencies.node_name_dirt_wet = select_required({"farming:soil_wet", "mcl_farming:soil_wet"})
--df_dependencies.node_name_mortar_pestle = select_optional({"farming:mortar_pestle"}) -- TODO where did this go?
df_dependencies.node_name_string = select_required({"farming:string", "mcl_mobitems:string"})

df_dependencies.node_name_bucket_empty = select_required({"mesecraft_bucket:bucket_empty", "mcl_buckets:bucket_empty"})
df_dependencies.node_name_bucket_lava = select_required({"mesecraft_bucket:bucket_lava", "mcl_buckets:bucket_lava"})
df_dependencies.node_name_bucket_water = select_required({"mesecraft_bucket:bucket_water", "mcl_buckets:bucket_water"})

-- from "wool"

df_dependencies.node_name_wool_white = select_required({"wool:white", "mcl_wool:white"})

-- from "fireflies"
df_dependencies.node_name_fireflies = select_optional({"fireflies:firefly"})

-- from "vessels"
df_dependencies.node_name_glass_bottle = select_required({"vessels:glass_bottle", "mcl_potions:glass_bottle"})
df_dependencies.node_name_shelf = select_optional({"vessels:shelf"})

-- from "beds"
df_dependencies.node_name_bed_bottom = select_required({"mesecraft_beds:bed_red_bottom", "mcl_beds:bed_red_bottom"})
df_dependencies.node_name_bed_top = select_required({"mesecraft_beds:bed_red_top", "mcl_beds:bed_red_top"})

-- from "doors"
df_dependencies.node_name_door_wood_a = select_required({"doors:door_wood_a", "mcl_doors:wooden_door_b_1"})
df_dependencies.node_name_door_hidden = select_required({"doors:hidden", "mcl_doors:wooden_door_t_1"})

-- from "stairs"

df_dependencies.node_name_slab_goblin_cap_stem_wood = select_required({"stairs:slab_goblin_cap_stem_wood", "mcl_stairs:slab_goblin_cap_stem_wood"})
df_dependencies.node_name_slab_slade_brick = select_required({"stairs:slab_slade_brick", "mcl_stairs:slab_slade_brick"})
df_dependencies.node_name_stair_goblin_cap_stem_wood = select_required({"stairs:stair_goblin_cap_stem_wood", "mcl_stairs:stair_goblin_cap_stem_wood"})
df_dependencies.node_name_stair_inner_slade_brick = select_required({"stairs:stair_inner_slade_brick", "mcl_stairs:stair_slade_brick_inner"})
df_dependencies.node_name_stair_outer_slade_brick = select_required({"stairs:stair_outer_slade_brick", "mcl_stairs:stair_slade_brick_outer"})
df_dependencies.node_name_stair_slade_block = select_required({"stairs:stair_slade_block", "mcl_stairs:stair_slade_block"})
df_dependencies.node_name_slab_slade_block = select_required({"stairs:slab_slade_block", "mcl_stairs:slab_slade_block"})
df_dependencies.node_name_stair_slade_brick = select_required({"stairs:stair_slade_brick", "mcl_stairs:stair_slade_brick"})
df_dependencies.node_name_slab_slade_block_top = select_optional({"mcl_stairs:slab_slade_block_top"})

-- from "tnt"

df_dependencies.node_name_gunpowder = select_optional({"tnt:gunpowder", "mcl_mobitems:gunpowder"})

local modpath = minetest.get_modpath(minetest.get_current_modname())

if not df_dependencies.node_name_fireflies then
	dofile(modpath.."/fireflies.lua")
	df_dependencies.node_name_fireflies = "df_dependencies:firefly"
end
