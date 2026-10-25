--------------------------------------------------
-- Tunnel tube

-- Magenta
-- curving trunk
-- Max trunk height 	8
-- depth 2-3

local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("df_trees:tunnel_tube", {
	description = S("Tunnel Tube"),
	_doc_items_longdesc = df_trees.doc.tunnel_tube_desc,
	_doc_items_usagehelp = df_trees.doc.tunnel_tube_usage,
	tiles = {"dfcaverns_tunnel_tube.png"},
	paramtype2 = "facedir",
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	groups = {choppy = 3, tree = 1, oddly_breakable_by_hand=1, flammable = 2, handy=1,axey=1, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = df_dependencies.sound_wood(),
	on_place = minetest.rotate_node,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,-8/16,-8/16,-4/16,8/16,8/16},
			{4/16,-8/16,-8/16,8/16,8/16,8/16},
			{-4/16,-8/16,-8/16,4/16,8/16,-4/16},
			{-4/16,-8/16,8/16,4/16,8/16,4/16},
		},
	},
})

minetest.register_node("df_trees:tunnel_tube_slant_bottom", {
	description = S("Tunnel Tube"),
	_doc_items_longdesc = df_trees.doc.tunnel_tube_desc,
	_doc_items_usagehelp = df_trees.doc.tunnel_tube_usage,
	tiles = {"dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png"},
	paramtype2 = "facedir",
	drawtype = "mesh",
	is_ground_content = false,
	mesh = "tunnel_tube_slant.obj",
	paramtype = "light",
	drop = "df_trees:tunnel_tube",
	groups = {choppy = 3, tree = 1, oddly_breakable_by_hand=1, flammable = 2, handy=1,axey=1, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = df_dependencies.sound_wood(),
	on_place = minetest.rotate_node,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.625, 0.5, 0.0, 0.375},
			{-0.5, 0.0, -0.875, 0.5, 0.5, 0.125},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.625, 0.5, 0.0, 0.375},
			{-0.5, 0.0, -0.875, 0.5, 0.5, 0.125},
		},
	},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("df_trees:tunnel_tube_slant_top", {
	description = S("Tunnel Tube"),
	_doc_items_longdesc = df_trees.doc.tunnel_tube_desc,
	_doc_items_usagehelp = df_trees.doc.tunnel_tube_usage,
	tiles = {"dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png"},
	paramtype2 = "facedir",
	drawtype = "mesh",
	is_ground_content = false,
	mesh = "tunnel_tube_slant_2.obj",
	paramtype = "light",
	drop = "df_trees:tunnel_tube",
	groups = {choppy = 3, tree = 1, oddly_breakable_by_hand=1, flammable = 2, handy=1,axey=1, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = df_dependencies.sound_wood(),
	on_place = minetest.rotate_node,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.125, 0.5, 0.0, 0.875},
			{-0.5, 0.0, -0.375, 0.5, 0.5, 0.625},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.125, 0.5, 0.0, 0.875},
			{-0.5, 0.0, -0.375, 0.5, 0.5, 0.625},
		},
	},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("df_trees:tunnel_tube_slant_full", {
	description = S("Tunnel Tube"),
	_doc_items_longdesc = df_trees.doc.tunnel_tube_desc,
	_doc_items_usagehelp = df_trees.doc.tunnel_tube_usage,
	tiles = {"dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png", "dfcaverns_tunnel_tube.png"},
	paramtype2 = "facedir",
	drawtype = "mesh",
	is_ground_content = false,
	mesh = "tunnel_tube_slant_full.obj",
	paramtype = "light",
	drop = "df_trees:tunnel_tube",
	groups = {choppy = 3, tree = 1, oddly_breakable_by_hand=1, flammable = 2, handy=1,axey=1, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = df_dependencies.sound_wood(),
	on_place = minetest.rotate_node,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.75, 0.5, 0, 0.25},
			{-0.5, 0, -1.25, 0.5, 0.5, -0.25},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.75, 0.5, 0, 0.25},
			{-0.5, 0, -1.25, 0.5, 0.5, -0.25},
		},
	},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

--Wood
minetest.register_craft({
	output = 'df_trees:tunnel_tube_wood 4',
	recipe = {
		{'df_trees:tunnel_tube'},
	}
})

-- Paper
minetest.register_craft({
	output = df_dependencies.node_name_paper .. " 3",
	type = "shapeless",
	recipe = {'df_trees:tunnel_tube', df_dependencies.node_name_bucket_water},
	replacements = {{df_dependencies.node_name_bucket_water, df_dependencies.node_name_bucket_empty}},
})

minetest.register_node("df_trees:tunnel_tube_wood", {
	description = S("Tunnel Tube Plies"),
	_doc_items_longdesc = df_trees.doc.tunnel_tube_desc,
	_doc_items_usagehelp = df_trees.doc.tunnel_tube_usage,
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"dfcaverns_tunnel_tube_wood_top.png", "dfcaverns_tunnel_tube_wood_top.png", "dfcaverns_tunnel_tube_wood_side.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1, handy=1,axey=1, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
	sounds = df_dependencies.sound_wood(),
	_mcl_blast_resistance = 10,
	_mcl_hardness = 2,
})

df_dependencies.register_all_stairs_and_fences("tunnel_tube_wood", {burntime = 9})

minetest.register_craft({
	type = "fuel",
	recipe = "df_trees:tunnel_tube_wood",
	burntime = 9,
})
minetest.register_craft({
	type = "fuel",
	recipe = "df_trees:tunnel_tube",
	burntime = 36,
})
minetest.register_craft({
	type = "fuel",
	recipe = "df_trees:tunnel_tube_sapling",
	burntime = 3,
})

-- TNT
-----------------------------------------------------------------------------------------------------------

local gunpowder = df_dependencies.node_name_gunpowder
local tnt_ignite_sound = df_dependencies.soundfile_tnt_ignite
local tnt_boom = df_dependencies.tnt_boom

if df_trees.config.enable_tnt then

	local tnt_radius = tonumber(minetest.settings:get("tnt_radius") or 3) * 2/3
	local tnt_def = {radius = tnt_radius, damage_radius = tnt_radius * 2}
	local torch_item = df_dependencies.node_name_torch
	
	local drop_items = {
			max_items = 1,
			items = {
				{
					items = {'df_trees:tunnel_tube_sapling'},
					rarity = 2,
				},
			}
		}
	if gunpowder then
		drop_items.max_items = 3
		table.insert(drop_items.items, {
					items = {'df_trees:tunnel_tube_sapling', gunpowder},
					rarity = 2,
				})
		table.insert(drop_items.items, {
					items = {'df_trees:tunnel_tube_sapling', gunpowder .. ' 2'},
					rarity = 2,
				})
	end

	local on_burn = function(pos)
		minetest.swap_node(pos, {name = "df_trees:tunnel_tube_fruiting_body_burning"})
		minetest.registered_nodes["df_trees:tunnel_tube_fruiting_body_burning"].on_construct(pos)
	end
	
	minetest.register_node("df_trees:tunnel_tube_fruiting_body", {
		description = S("Tunnel Tube Fruiting Body"),
		_doc_items_longdesc = df_trees.doc.tunnel_tube_desc,
		_doc_items_usagehelp = df_trees.doc.tunnel_tube_usage,
		tiles = {"dfcaverns_tunnel_tube.png^[multiply:#b09090"},
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {choppy = 3, oddly_breakable_by_hand=1, flammable = 2, tnt = 1, handy=1, hoey=1, shearsy=1, swordy=1, deco_block=1, dig_by_piston=1, fire_encouragement=15, fire_flammability=30},
		sounds = df_dependencies.sound_wood(),
		on_place = minetest.rotate_node,
		drop = drop_items,
		_mcl_blast_resistance = 12,
		_mcl_hardness = 2,
		
		on_punch = function(pos, node, puncher)
			if puncher:get_wielded_item():get_name() == torch_item then
				minetest.swap_node(pos, {name = "df_trees:tunnel_tube_fruiting_body_burning"})
				minetest.registered_nodes["df_trees:tunnel_tube_fruiting_body_burning"].on_construct(pos)
				minetest.log("action", puncher:get_player_name() .. " ignites " .. node.name .. " at " .. minetest.pos_to_string(pos))
			end
		end,
		on_blast = function(pos, intensity)
			minetest.swap_node(pos, {name="air"})
			minetest.after(0.1, function()
				tnt_boom(pos, tnt_def)
			end)
		end,
		mesecons = {effector =
			{action_on =
				function(pos)
					minetest.swap_node(pos, {name="air"})
					tnt_boom(pos, tnt_def)
				end
			}
		},
		on_burn = on_burn,
		on_ignite = on_burn,
		_on_burn = on_burn,
	})
	
	minetest.register_node("df_trees:tunnel_tube_fruiting_body_burning", {
		description = S("Tunnel Tube Fruiting Body"),
		_doc_items_longdesc = df_trees.doc.tunnel_tube_desc,
		_doc_items_usagehelp = df_trees.doc.tunnel_tube_usage,
		tiles = {"dfcaverns_tunnel_tube.png^[multiply:#b09090"},
		is_ground_content = false,
		groups = {not_in_creative_inventory = 1,},
		light_source = 5,
		drop = "",
		sounds = df_dependencies.sound_wood(),
		_mcl_blast_resistance = 0,
		_mcl_hardness = 2,
		on_timer = function(pos, elapsed)
			minetest.swap_node(pos, {name="air"})
			tnt_boom(pos, tnt_def)
		end,
		on_blast = function(pos)
			minetest.swap_node(pos, {name="air"})
			minetest.after(0.1, function()
				tnt_boom(pos, tnt_def)
			end)
		end,
		on_construct = function(pos)
			minetest.sound_play(tnt_ignite_sound, {pos = pos})
			minetest.get_node_timer(pos):start(4)
		end,
	})
else
	minetest.register_node("df_trees:tunnel_tube_fruiting_body", {
		description = S("Tunnel Tube Fruiting Body"),
		_doc_items_longdesc = df_trees.doc.tunnel_tube_desc,
		_doc_items_usagehelp = df_trees.doc.tunnel_tube_usage,
		tiles = {"dfcaverns_tunnel_tube.png^[multiply:#b09090"},
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {choppy = 3, oddly_breakable_by_hand=1, flammable = 2,handy=1, hoey=1, shearsy=1, swordy=1, deco_block=1, dig_by_piston=1, fire_encouragement=15, fire_flammability=30},
		sounds = df_dependencies.sound_wood(),
		on_place = minetest.rotate_node,
		_mcl_blast_resistance = 12,
		_mcl_hardness = 2,
		
		drop = {
			max_items = 3,
			items = {
				{
					items = {'df_trees:tunnel_tube_sapling'},
					rarity = 2,
				},
				{
					items = {'df_trees:tunnel_tube_sapling'},
					rarity = 2,
				},
				{
					items = {'df_trees:tunnel_tube_sapling'},
					rarity = 2,
				},
			},
		},
	})
end
-----------------------------------------------------------------------------------------------------------

minetest.register_node("df_trees:tunnel_tube_sapling", {
	description = S("Tunnel Tube Spawn"),
	_doc_items_longdesc = df_trees.doc.tunnel_tube_desc,
	_doc_items_usagehelp = df_trees.doc.tunnel_tube_usage,
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"dfcaverns_tunnel_tube_sapling.png"},
	inventory_image = "dfcaverns_tunnel_tube_sapling.png",
	wield_image = "dfcaverns_tunnel_tube_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	floodable = true,
	selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
	},
	groups = {snappy = 2, dig_immediate = 3, flammable = 2,
		attached_node = 1, sapling = 1, light_sensitive_fungus = 11, dig_immediate=3,dig_by_piston=1,destroy_by_lava_flow=1,deco_block=1, compostability=30},
	sounds = df_dependencies.sound_leaves(),
	_mcl_blast_resistance = 10,
	_mcl_hardness = 0.2,

	on_construct = function(pos)
		if df_trees.tunnel_tube_growth_permitted(pos) then
			minetest.get_node_timer(pos):start(math.random(
				df_trees.config.tunnel_tube_delay_multiplier*df_trees.config.tree_min_growth_delay,
				df_trees.config.tunnel_tube_delay_multiplier*df_trees.config.tree_max_growth_delay))
		end
	end,

	on_destruct = function(pos)
		minetest.get_node_timer(pos):stop()
	end,
	
	on_timer = function(pos)
		if df_farming and df_farming.kill_if_sunlit(pos) then
			return
		end
		minetest.set_node(pos, {name="air"})
		df_trees.spawn_tunnel_tube(pos)
	end,
})

local tunnel_tube_directions = {
	[0] = {x=0,y=0,z=-1},
	[1] = {x=-1,y=0,z=0},
	[2] = {x=0,y=0,z=1},
	[3] = {x=1,y=0,z=0},
}

local tunnel_tube_displacement =
{
	[4] = 1,
	[5] = 1,
	[6] = 2,
	[7] = 2,
	[8] = 3,
	[9] = 3,
}

df_trees.spawn_tunnel_tube = function(pos)
	local direction = math.random(1,4)-1 -- serves as both the facedir and the lookup in the direction table
	local height = math.random(4,9)
	local top_pos = vector.add(pos, vector.multiply(tunnel_tube_directions[direction], tunnel_tube_displacement[height]))
	top_pos.y = pos.y + height - 1

	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(pos, top_pos)
	local area = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()

	df_trees.spawn_tunnel_tube_vm(area:indexp(pos), area, data, param2_data, height, direction)

	vm:set_data(data)
	vm:set_param2_data(param2_data)
	vm:write_to_map()
	vm:update_map()	
end

local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")
local c_tunnel_tube = minetest.get_content_id("df_trees:tunnel_tube")
local c_tunnel_tube_bottom = minetest.get_content_id("df_trees:tunnel_tube_slant_bottom")
local c_tunnel_tube_top = minetest.get_content_id("df_trees:tunnel_tube_slant_top")
local c_tunnel_tube_full = minetest.get_content_id("df_trees:tunnel_tube_slant_full")
local c_tunnel_tube_fruiting_body  = minetest.get_content_id("df_trees:tunnel_tube_fruiting_body")

-- was simplest to just hardcode these patterns for each height from 4 to 9
-- pattern is displacement, node
local tunnel_tube_patterns =
{
	[4] = {{0, c_tunnel_tube}, {0, c_tunnel_tube_bottom}, {1, c_tunnel_tube_top}, {1, c_tunnel_tube_fruiting_body}},
	[5] = {{0, c_tunnel_tube}, {0, c_tunnel_tube}, {0, c_tunnel_tube_bottom}, {1, c_tunnel_tube_top}, {1, c_tunnel_tube_fruiting_body}},
	[6] = {{0, c_tunnel_tube}, {0, c_tunnel_tube}, {0, c_tunnel_tube_bottom}, {1, c_tunnel_tube_top}, {1, c_tunnel_tube_full}, {2, c_tunnel_tube_fruiting_body}},
	[7] = {{0, c_tunnel_tube}, {0, c_tunnel_tube}, {0, c_tunnel_tube}, {0, c_tunnel_tube_bottom}, {1, c_tunnel_tube_top}, {1, c_tunnel_tube_full}, {2, c_tunnel_tube_fruiting_body}},
	[8] = {{0, c_tunnel_tube}, {0, c_tunnel_tube}, {0, c_tunnel_tube}, {0, c_tunnel_tube_bottom}, {1, c_tunnel_tube_top}, {1, c_tunnel_tube_full}, {2, c_tunnel_tube_full}, {3, c_tunnel_tube_fruiting_body}},
	[9] = {{0, c_tunnel_tube}, {0, c_tunnel_tube}, {0, c_tunnel_tube}, {0, c_tunnel_tube}, {0, c_tunnel_tube_bottom}, {1, c_tunnel_tube_top}, {1, c_tunnel_tube_full}, {2, c_tunnel_tube_full}, {3, c_tunnel_tube_fruiting_body}},
}

df_trees.spawn_tunnel_tube_vm = function(vi, area, data, param2_data, height, direction)
	if height == nil then height = math.random(4,9) end
	if direction == nil then direction = math.random(1,4)-1 end

	local increment
	if direction == 0 then
		increment = -area.zstride
	elseif direction == 1 then
		increment = -1
	elseif direction == 2 then
		increment = area.zstride
	elseif direction == 3 then
		increment = 1
	else
		return
	end

	local previous_vi = vi
	local pattern = tunnel_tube_patterns[height]
	if pattern == nil then
		minetest.log("error", "Tunnel tube pattern was nil somehow. height: " .. string(height) .. " location: " .. minetest.pos_to_string(area:position(vi)))
		return nil
	end
	for i, nodepattern in ipairs(pattern) do
		local current_vi = vi + nodepattern[1] * increment
		if data[current_vi] == c_air or data[current_vi] == c_ignore then
			previous_vi = current_vi
			data[current_vi] = nodepattern[2]
			param2_data[current_vi] = direction
		else
			data[previous_vi] = c_tunnel_tube_fruiting_body
			param2_data[previous_vi] = direction
			break
		end
		vi = vi + area.ystride
	end
end

