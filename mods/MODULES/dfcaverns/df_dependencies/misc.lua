local S = minetest.get_translator(minetest.get_current_modname())

local select_required = df_dependencies.select_required
local select_optional = df_dependencies.select_optional

df_dependencies.mods_required.farming = true

-- If the farming mod is installed, add the "straw" group to farming straw.
-- This way goblin caps just need to check for group:straw to get cave straw as well
local straw_def = minetest.registered_items["farming:straw"]
if straw_def then
	local new_groups = {}
	for group, val in pairs(straw_def.groups) do
		new_groups[group] = val
	end
	new_groups.straw = 1
	minetest.override_item("farming:straw", {
		groups = new_groups
	})
end

-- used to determine colour of spindlestem caps
if minetest.get_modpath("default") then
	df_dependencies.data_iron_containing_nodes = {"default:stone_with_iron", "default:steelblock"}
	df_dependencies.data_copper_containing_nodes = {"default:stone_with_copper", "default:copperblock"}
	df_dependencies.data_mese_containing_nodes = {"default:stone_with_mese", "default:mese"}
elseif minetest.get_modpath("mcl_core") then
	df_dependencies.data_iron_containing_nodes = {}
	minetest.after(0, function()
		for nodename, _ in pairs(minetest.registered_nodes) do
			if string.find(nodename, "iron") then
				table.insert(df_dependencies.data_iron_containing_nodes, nodename)
			end
		end
	end)
	df_dependencies.data_copper_containing_nodes = {}
	minetest.after(0, function()
		for nodename, _ in pairs(minetest.registered_nodes) do
			if string.find(nodename, "copper") then
				table.insert(df_dependencies.data_copper_containing_nodes, nodename)
			end
		end
	end)
	df_dependencies.data_mese_containing_nodes = {"mcl_deepslate:deepslate_with_redstone", "mcl_deepslate:deepslate_with_redstone_lit",
		"mcl_core:stone_with_redstone", "mcl_core:stone_with_redstone_lit", "group:mesecon_conductor_craftable", "group:mesecon", "group:mesecon_effector_off"}
end

-- common nodes that can be found next to pit plasma, triggering matter degradation
-- don't trigger on air, that's for sparkle generation
df_dependencies.abm_pit_plasma_neighbors = {"group:stone", "group:lava", "group:water", "group:material_stone"}

df_dependencies.texture_cobble = select_required({{"default", "default_cobble.png"}, {"mcl_core", "default_cobble.png"}})
df_dependencies.texture_coral_skeleton = select_required({{"default", "default_coral_skeleton.png"}, {"mcl_ocean", "mcl_ocean_dead_horn_coral_block.png"}})
df_dependencies.texture_dirt = select_required({{"default", "default_dirt.png"}, {"mcl_core", "default_dirt.png"}})
df_dependencies.texture_gold_block = select_required({{"default", "default_gold_block.png"}, {"mcl_core", "default_gold_block.png"}})
df_dependencies.texture_ice = select_required({{"default", "default_ice.png"}, {"mcl_core", "default_ice.png"}})
df_dependencies.texture_sand = select_required({{"default", "default_sand.png"}, {"mcl_core", "default_sand.png"}})
df_dependencies.texture_stone = select_required({{"default", "default_stone.png"}, {"mcl_core", "default_stone.png"}})
df_dependencies.texture_wood = select_required({{"default", "default_wood.png"}, {"mcl_core", "default_wood.png"}})
df_dependencies.texture_mineral_coal = select_required({{"default", "default_mineral_coal.png"}, {"mcl_core", "mcl_core_coal_ore.png"}}) -- MCL's coal texture isn't transparent, but is only used with gas seeps and should work fine that way
df_dependencies.texture_glass_bottle = select_required({{"vessels", "vessels_glass_bottle.png"}, {"mcl_potions", "mcl_potions_potion_bottle.png"}})
df_dependencies.texture_meselamp = "dfcaverns_glow_mese.png"

df_dependencies.texture_tool_steelhoe = select_required({{"default", "farming_tool_steelhoe.png"}, {"mcl_farming", "farming_tool_steelhoe.png"}})
df_dependencies.texture_tool_steelpick = select_required({{"default", "default_tool_steelpick.png"}, {"mcl_farming", "default_tool_steelpick.png"}})
df_dependencies.texture_tool_steelshovel = select_required({{"default", "default_tool_steelshovel.png"}, {"mcl_farming", "default_tool_steelshovel.png"}})
df_dependencies.texture_farming_soil = select_required({{"default", "(default_dirt.png^farming_soil.png)"}, {"mcl_farming", "mcl_farming_farmland_dry.png"}})

df_dependencies.texture_mapping_kit = select_required({{"default", "map_mapping_kit.png"}, {"mcl_maps", "mcl_maps_map_filled.png"}})

df_dependencies.nethercap_name = S("Nethercap")
if minetest.get_modpath("mcl_mapgen_core") or minetest.get_modpath("nether") then
	-- since there's a whole layer called the Nether in Mineclone (and the nether mod) and it has its own mushrooms, rename
	-- nethercaps when that's present to avoid confusion.
	df_dependencies.nethercap_name = S("Icecap")
end