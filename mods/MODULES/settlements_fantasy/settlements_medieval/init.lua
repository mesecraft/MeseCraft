local modpath = minetest.get_modpath(minetest.get_current_modname())

-- internationalization boilerplate
local S, NS = settlements.S, settlements.NS

local schem_path = modpath.."/schematics/"

if minetest.get_modpath("namegen") then
	namegen.parse_lines(io.lines(modpath.."/namegen_towns.cfg"))
end

-------------------------------------
-- Node initialization
local function fill_chest(pos)
	-- fill chest
	local inv = minetest.get_inventory( {type="node", pos=pos} )
	-- always
	inv:add_item("main", "default:apple "..math.random(1,3))
	-- low value items
	if math.random(0,1) < 1 then
		inv:add_item("main", "farming:bread "..math.random(0,3))
		inv:add_item("main", "default:steel_ingot "..math.random(0,3))
		-- additional fillings when farming mod enabled
		if minetest.get_modpath("farming") ~= nil and farming.mod == "redo" then
			if math.random(0,1) < 1 then
				inv:add_item("main", "farming:melon_slice "..math.random(0,3))
				inv:add_item("main", "farming:carrot "..math.random(0,3))
				inv:add_item("main", "farming:corn "..math.random(0,3))
			end
		end
	end
	-- medium value items
	if math.random(0,3) < 1 then
		inv:add_item("main", "default:pick_steel "..math.random(0,1))
		inv:add_item("main", "default:pick_bronze "..math.random(0,1))
		inv:add_item("main", "fire:flint_and_steel "..math.random(0,1))
		inv:add_item("main", "mesecraft_bucket:bucket_empty "..math.random(0,1))
		inv:add_item("main", "default:sword_steel "..math.random(0,1))
	end
end

local function generate_book(pos, town_name)
	local callbacks = {}
	table.insert(callbacks, {func = settlements.generate_travel_guide, param1=pos, param2=town_name})
	if settlements.generate_ledger then
		table.insert(callbacks, {func = settlements.generate_ledger, param1="kings", param2=town_name})
	end
	local callback = callbacks[math.random(#callbacks)]
	return callback.func(callback.param1, callback.param2)
end

local function fill_shelf(pos, town_name)
	local inv = minetest.get_inventory( {type="node", pos=pos} )
	for i = 1, math.random(2, 8) do
		local book = generate_book(pos, town_name)
		if book then
			inv:add_item("books", book)
		end
	end
end

local generate_books = minetest.settings:get_bool("settlements_generate_books", true)

local initialize_node = function(pos, node, node_def, settlement_info)
	if settlement_info.name and node.name == "signs:wall_sign" then
		local meta = minetest.get_meta(pos)
		meta:set_string("text", S("@1 Town Hall", settlement_info.name))
	end
	-- when chest is found -> fill with stuff
	if node.name == "default:chest" then
		fill_chest(pos)
	end
	if generate_books and node.name == "default:bookshelf" then
		fill_shelf(pos, settlement_info.name)
	end
	if minetest.get_item_group(node.name, "plant") > 0 then
		minetest.get_node_timer(pos):start(1000) -- start crops growing
	end
end

--------------------------------------------
-- Schematics

local townhall_schematic = {
	name = "townhall",
	schematic = dofile(schem_path.."medieval_townhall.lua"),
	buffer = 2, -- buffer space around the building, footprint is treated as radius max(size.x, size.z) + buffer for spacing purposes
	max_num = 0.1, -- This times the number of buildings in a settlement gives the maximum number of these buildings in a settlement.
					-- So for example, 0.1 means at most 1 of these buildings in a 10-building settlement and 2 in a 20-building settlement.
	replace_nodes_optional = true, -- If true, default:cobble will be replaced with a random wall material
	initialize_node = initialize_node, -- allows additional post-creation actions to be executed on schematic nodes once they're constructed
	platform_ignore_group_above = "group:leafdecay", -- causes special handling of nodes belonging to this group. If 
		-- the node is in the space above the schematic being placed it will not be turned into air.
		-- For leaves, make sure to add trigger_timers_for_nodes = "group:leafdecay" to the settlement settings to clean
		-- up blobs of leaves that might be left over from trunks that have been removed.
}
local kingsmarket_schematic = {
	name = "kingsmarket",
	schematic = dofile(schem_path.."medieval_kingsmarket.lua"),
	buffer = 1,
	max_num = 0.1,
	replace_nodes_optional = true,
	initialize_node = initialize_node,
	platform_ignore_group_above = "group:leafdecay",
}

-- list of schematics
local schematic_table = {
	{
		name = "well",
		schematic = dofile(schem_path.."medieval_well.lua"),
		buffer = 2,
		max_num = 0.045,
		height_adjust = -2, -- adjusts the y axis of where the schematic is built, to allow for "basement" stuff
		platform_ignore_group_above = "group:leafdecay",
	},
	{
		name = "hut",
		schematic = dofile(schem_path.."medieval_hut.lua"),
		buffer = 1,
		max_num = 0.9,
		replace_nodes_optional = true,
		initialize_node = initialize_node,
		platform_ignore_group_above = "group:leafdecay",
	},
	{
		name = "garden",
		schematic = dofile(schem_path.."medieval_garden.lua"),
		max_num = 0.1,
		initialize_node = initialize_node,
		platform_ignore_group_above = "group:leafdecay",
	},
	{
		name = "lamp",
		schematic = dofile(schem_path.."medieval_lamp.lua"),
		buffer = 3,
		max_num = 0.05,
		platform_ignore_group_above = "group:leafdecay",
	},
	{
		name = "tower",
		schematic = dofile(schem_path.."medieval_tower.lua"),
		buffer = 3,
		max_num = 0.055,
		platform_ignore_group_above = "group:leafdecay",
	},
	{
		name = "church",
		schematic = dofile(schem_path.."medieval_church.lua"),
		buffer = 2,
		max_num = 0.075,
		platform_ignore_group_above = "group:leafdecay",
	},
	{
		name = "blacksmith",
		schematic = dofile(schem_path.."medieval_blacksmith.lua"),
		buffer = 2,
		max_num = 0.050,
		platform_ignore_group_above = "group:leafdecay",
	},
	kingsmarket_schematic,
	{
		name = "nightmarket",
		schematic = dofile(schem_path.."medieval_nightmarket.lua"),
		buffer = 1,
		max_num = 0.025,
		replace_nodes_optional = true,
		initialize_node = initialize_node,
		platform_ignore_group_above = "group:leafdecay",
	},
}

local medieval_settlements = {
	description = S("village"), -- a general name for this kind of settlement

	-- this settlement will be placed on nodes with this surface material type.
	surface_materials = {
		"default:dirt",
		"default:dirt_with_grass",
		"default:dry_dirt_with_dry_grass",
		"default:dirt_with_snow",
		"default:dirt_with_dry_grass",
		"default:dirt_with_coniferous_litter",
		"default:sand",
		"default:silver_sand",
		"default:snow",
	},

	-- TODO: add a biome list. The tricky part here is, what if a biome list but not a surface materials list is provided?
	-- How to find the surface, and how to know what to replace surface material nodes with in the schematic?

	-- nodes in all schematics will be replaced with these nodes, or a randomly-selected node
	-- from a list of choices if a list is provided
	replacements = {
		["default:junglewood"] = "settlements_medieval:junglewood",
	},

	-- Affected by per-building replace_nodes flag
	replacements_optional = {
		["default:cobble"] = {
			"default:junglewood",
			"default:pine_wood",
			"default:wood",
			"default:aspen_wood",
			"default:acacia_wood",
			"default:stonebrick",
			"default:cobble",
			"default:desert_stonebrick",
			"default:desert_cobble",
			"default:sandstone",
		},
	},

	-- This node will be replaced with the surface material of the location the building is placed on.
	replace_with_surface_material = "default:dirt_with_grass",

	-- Trees often interfere with surface detection. These nodes will be ignored when detecting surface level.
	ignore_surface_materials = {
		"default:tree",
		"default:jungletree",
		"default:pine_tree",
		"default:acacia_tree",
		"default:aspen_tree",
		"default:bush_stem",
		"default:bush_leaves",
		"default:acacia_bush_stem",
		"default:acacia_bush_leaves",
		"default:pine_bush_stem",
		"default:pine_bush_needles",
		"default:blueberry_bush_leaves_with_berries",
		"default:blueberry_bush_leaves",
	},

	platform_shallow = "default:dirt",
	platform_deep = "default:stone",
	path_material = "default:gravel",

	schematics = schematic_table,

	-- Select one of these to form the center of town. If not defined, one will be picked from the regular schematic table
	central_schematics = {
		townhall_schematic,
		kingsmarket_schematic,
	},

	building_count_min = 5,
	building_count_max = 25,

	altitude_min = 2,
	altitude_max = 300,

	generate_name = function(pos)
		if minetest.get_modpath("namegen") then
			return namegen.generate("settlement_towns")
		end
		return S("Town")
	end,

	generate_book = generate_book,
	
	-- This is a special-purpose property used for cleaning up leaf blobs that might have been left behind
	-- when tree trunks got removed by buildings. It goes through every node in the mapchunk and sets the
	-- node's timer going if it matches (using find_nodes_in_area).
	trigger_timers_for_nodes = "group:leafdecay",
}

settlements.register_settlement("medieval", medieval_settlements)

-- register block for npc spawn
local function deep_copy(table_in)
	local table_out = {}
	for index, value in pairs(table_in) do
		if type(value) == "table" then
			table_out[index] = deep_copy(value)
		else
			table_out[index] = value
		end
	end
	return table_out
end

minetest.register_alias("settlements:junglewood", "settlements_medieval:junglewood")

local junglewood_def = deep_copy(minetest.registered_nodes["default:junglewood"])
junglewood_def.drop = "default:junglewood"
minetest.register_node("settlements_medieval:junglewood", junglewood_def)
-- register inhabitants
if minetest.get_modpath("mobs_npc") ~= nil then
	-- Villagers and traders appear on the junglewood floors of settlement buildings.
	for _, mob in ipairs({"mobs_npc:npc", "mobs_npc:trader"}) do
		mobs:spawn({
			name = mob,
			nodes = {"settlements_medieval:junglewood"},
			chance = 20,
			active_object_count = 2,
		})
	end
end
