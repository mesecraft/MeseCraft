local S = mesecraft_furniture.intllib

--Mirror (a.k.a. Medicine Cabinet)--
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

local formspec = 'size [9,10]'..
                 'bgcolor[#080808BB;true]'..
                 'list[context;storage;3,1.5;3,3;]'..
                 'list[current_player;main;0.5,5.5;8,4;]'..
                 'listring[]'

minetest.register_node("mesecraft_furniture:mirror_closed", {
   description = S("Mirror"),
   tiles = {
		"mesecraft_furniture_mirror_top.png",
		"mesecraft_furniture_mirror_bottom.png",
		"mesecraft_furniture_mirror_right.png",
		"mesecraft_furniture_mirror_left.png",
		"default_wood.png",
		"mesecraft_furniture_mirror_front.png"
	},
   drawtype = "nodebox",
   paramtype = "light",
   paramtype2 = "facedir",
   groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
   on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('storage', 3*3)
   end,
   on_punch = function(pos, node, puncher)
		minetest.swap_node(pos, {name = "mesecraft_furniture:mirror", param2 = node.param2})
		local meta = minetest.get_meta(pos);
		meta:set_string('formspec',formspec)
		end,
   node_box = {
       type = "fixed",
       fixed = {
			{-0.4375, -0.375, 0.3125, 0.4375, 0.5, 0.5},
			{0, -0.375, 0.25, 0.4375, 0.5, 0.3125},
			{-0.4375, -0.375, 0.25, 2.98023e-008, 0.5, 0.3125},
       },
   }
})

minetest.register_node("mesecraft_furniture:mirror", {
   description = S("Mirror (Open)"),
   tiles = {
		"mesecraft_furniture_mirror_open_top.png",
		"mesecraft_furniture_mirror_open_bottom.png",
		"mesecraft_furniture_mirror_open_right.png",
		"mesecraft_furniture_mirror_open_left.png",
		"mesecraft_furniture_mirror_front.png",
		"mesecraft_furniture_mirror_open_front.png"
	},
   drawtype = "nodebox",
   paramtype = "light",
   paramtype2 = "facedir",
   drop = "mesecraft_furniture:mirror_closed",
   groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, not_in_creative_inventory = 1},
   on_punch = function(pos, node, puncher)
		minetest.swap_node(pos, {name = "mesecraft_furniture:mirror_closed", param2 = node.param2})
		local meta = minetest.get_meta(pos);
		meta:set_string('formspec',nil)
		end,
   can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty('storage')
   end,
   on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "storage", drops)
		drops[#drops+1] = "mesecraft_furniture:mirror_closed"
		minetest.remove_node(pos)
		return drops
   end,
   allow_metadata_inventory_put = allow_metadata_inventory_put,
   allow_metadata_inventory_move = allow_metadata_inventory_move,
   allow_metadata_inventory_take = allow_metadata_inventory_take,
   node_box = {
       type = "fixed",
       fixed = {
			{-0.4375, -0.375, 0.3125, 0.4375, 0.5, 0.5},
			{0.4375, -0.375, -0.125, 0.5, 0.5, 0.3125},
			{-0.5, -0.375, -0.125, -0.4375, 0.5, 0.3125},
       },
   }
})

minetest.register_craft({
	output = 'mesecraft_furniture:mirror_closed',
	recipe = {
	{'default:steel_ingot','default:steel_ingot','default:steel_ingot',},
	{'default:glass','default:glass','default:glass',},
	{'default:steel_ingot','default:steel_ingot','default:steel_ingot',},
	}
})
