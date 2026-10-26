
-- unlit torch
minetest.register_node("mesecraft_torch:torch", {

	description = "Unlit Torch",
	drawtype = "torchlike",
	tiles = {
		{name = "mesecraft_torch_on_floor.png"},
		{name = "mesecraft_torch_ceiling.png"},
		{name = "mesecraft_torch_wall.png"},
	},
	inventory_image = "mesecraft_torch_on_floor.png",
	wield_image = "mesecraft_torch_on_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	light_source = 3,
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5 - 0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5 + 0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5 + 0.3, 0.3, 0.1},
	},
	groups = {choppy = 2, dig_immediate = 3, flammable = 1, attached_node = 1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
	-- Like MTG torches: water washes it off, lava burns it.
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		local def = minetest.registered_nodes[newnode.name]
		if not (def and def.groups and def.groups.lava) then
			minetest.add_item(pos, ItemStack("mesecraft_torch:torch"))
		end
	end,
})


-- override default torches to burn out after 8-10 minutes
minetest.override_item("default:torch", {

	on_timer = function(pos, elapsed)
		local p2 = minetest.get_node(pos).param2
		minetest.set_node(pos, {name = "mesecraft_torch:torch", param2 = p2})
		minetest.sound_play({name="mesecraft_torch_burnout", gain = 0.1},
			{pos = pos, max_hear_distance = 10})
	end,

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(
			math.random(mesecraft_torch.min_duration, mesecraft_torch.max_duration))
	end,
})
