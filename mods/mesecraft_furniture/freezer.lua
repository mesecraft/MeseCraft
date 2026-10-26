local S = mesecraft_furniture.intllib

--Freezer--

--
-- Formspecs
--

local function active_formspec(fuel_percent, item_percent)
	local formspec = 
		"size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[context;src;2.5,1;1,1;]"..
		"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
		(item_percent)..":gui_furnace_arrow_fg.png^[transformR270]"..
		"list[context;dst;4.75,0.96;3,2;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
	return formspec
end

local inactive_formspec =
	"size[8,8.5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;2.5,1.5;1,1;]"..
	"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
	"list[context;dst;4.75,0.96;3,2;]"..
	"list[current_player;main;0,4.25;8,1;]"..
	"list[current_player;main;0,5.5;8,3;8]"..
	"listring[context;dst]"..
	"listring[current_player;main]"..
	"listring[context;src]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0, 4.25)

--
-- Node callback functions that are the same for active and inactive freezer
--

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end

	      
local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

	      
local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

	      
local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

	      
local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

	      
local function freezer_node_timer(pos, elapsed)
	--
	-- Inizialize metadata
	--
	local meta = minetest.get_meta(pos)

	local src_time = meta:get_float("src_time") or 0


	local inv = meta:get_inventory()
	local srclist = inv:get_list("src")

	local dstlist = inv:get_list("dst")

	--
	-- Cooking
	--

	-- takes both regular and river water
	if inv:contains_item("src", "mesecraft_bucket:bucket_water") or
	      inv:contains_item("src", "mesecraft_bucket:bucket_river_water") then
		if inv:room_for_item("dst", "default:ice") and
			 inv:room_for_item("dst", "mesecraft_bucket:bucket_empty") then
			inv:remove_item("src", "mesecraft_bucket:bucket_water")
			inv:remove_item("src", "mesecraft_bucket:bucket_river_water")
			inv:add_item("dst", "default:ice")
			inv:add_item("dst", "mesecraft_bucket:bucket_empty")
	      end
	end

	-- support for water source
	if inv:contains_item("src", "default:water_source") or
	      inv:contains_item("src", "default:river_water_source") then
		if inv:room_for_item("dst", "default:ice") then
			inv:remove_item("src", "default:water_source")
			inv:remove_item("src", "default:river_water_source")
			inv:add_item("dst", "default:ice")
	      end
	end
	      
	-- Check if we have cookable content
	return
end

	      
--
-- Node definitions
--

minetest.register_node("mesecraft_furniture:freezer", {
	description = S("Freezer"),
	tiles = {
		"mesecraft_furniture_froz_top.png",
		"mesecraft_furniture_froz_bottom.png",
		"mesecraft_furniture_froz_right.png",
		"mesecraft_furniture_froz_left.png",
		"mesecraft_furniture_froz_back.png",
		"mesecraft_furniture_froz_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky = 2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.3125, 0.5, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.4375, -0.375, 0.4375, 0.5, -0.3125}, -- NodeBox2
			{0.3125, -0.25, -0.5, 0.375, 0.25, -0.4375}, -- NodeBox6
			{0.3125, -0.25, -0.4375, 0.375, -0.1875, -0.375}, -- NodeBox7
			{0.3125, 0.1875, -0.4375, 0.375, 0.25, -0.375}, -- NodeBox8
		}
	},
	can_dig = can_dig,

	on_timer = freezer_node_timer,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", inactive_formspec)
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('dst', 6)
	end,

	on_metadata_inventory_move = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(1.0)
	end,
	on_metadata_inventory_put = function(pos)
		-- start timer function, it will sort out whether freezer will work or not.
		local timer = minetest.get_node_timer(pos)
		timer:start(1.0)
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "src", drops)
		default.get_inventory_drops(pos, "dst", drops)
		drops[#drops+1] = "mesecraft_furniture:freezer"
		minetest.remove_node(pos)
		return drops
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})
	      
minetest.register_craft({
	output = 'mesecraft_furniture:freezer',
	recipe = {
	{'default:steel_ingot','default:mese_crystal','default:steel_ingot',},
	{'default:steel_ingot','default:ice','default:steel_ingot',},
	{'default:steel_ingot','default:mese_crystal','default:steel_ingot',},
	}
})

minetest.register_craft({
      output = "default:snowblock 3",
      type = "shapeless",
      recipe = {
	 "default:ice"
      }
})
