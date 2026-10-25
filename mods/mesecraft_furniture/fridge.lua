local S = mesecraft_furniture.intllib

--Refridgerator--
local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "storage" then
		return stack:get_count()
	else
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

minetest.register_node("mesecraft_furniture:fridge", {
	description= S("Fridge"),
	tiles = {
		"mesecraft_furniture_fridge_top.png",
		"mesecraft_furniture_fridge_bottom.png",
		"mesecraft_furniture_fridge_right.png",
		"mesecraft_furniture_fridge_left.png",
		"mesecraft_furniture_fridge_back.png",
		"mesecraft_furniture_fridge_front.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, furniture = 1},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('storage', 6*4)
		meta:set_string('formspec',
			'size [9,10]'..
			default.gui_bg..
			default.gui_bg_img..
			default.gui_slots..
			'bgcolor[#080808BB;true]'..
			'list[context;storage;1.5,1;6,4;]'..
			'list[current_player;main;0.5,6;8,4;]'..
			'listring[]')
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty('storage')
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "storage", drops)
		drops[#drops+1] = "mesecraft_furniture:fridge"
		minetest.remove_node(pos)
		return drops
	end,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.3125, 0.5, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.4375, -0.375, 0.4375, 0.5, -0.3125}, -- NodeBox2
			{0.3125, -0.25, -0.5, 0.375, 0.25, -0.4375}, -- NodeBox6
			{0.3125, -0.25, -0.4375, 0.375, -0.1875, -0.375}, -- NodeBox7
			{0.3125, 0.1875, -0.4375, 0.375, 0.25, -0.375}, -- NodeBox8
		}
	}
})

minetest.register_craft({
	output = 'mesecraft_furniture:fridge',
	recipe = {
	{'default:steel_ingot','default:steel_ingot','default:steel_ingot',},
	{'default:steel_ingot','default:snow','default:steel_ingot',},
	{'default:steel_ingot','default:steel_ingot','default:steel_ingot',},
	}
})
