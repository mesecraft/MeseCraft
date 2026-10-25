local S = minetest.get_translator(minetest.get_current_modname())

local torchspine_min_delay = df_trees.config.blood_thorn_delay_multiplier*df_trees.config.tree_min_growth_delay
local torchspine_max_delay = df_trees.config.blood_thorn_delay_multiplier*df_trees.config.tree_max_growth_delay

local looped_node_sound_modpath = minetest.get_modpath("looped_node_sound")

-- Rather than make this whole mod depend on subterrane just for this, I copied and pasted a chunk of stalactite code.
local x_disp = 0.125
local z_disp = 0.125

local function copy_pointed_thing(pointed_thing)
	return {
		type  = pointed_thing.type,
		above = pointed_thing.above and vector.copy(pointed_thing.above),
		under = pointed_thing.under and vector.copy(pointed_thing.under),
		ref   = pointed_thing.ref,
	}
end

local stal_on_place = function(itemstack, placer, pointed_thing)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return itemstack
	end
	if pt.type ~= "node" then
		return itemstack
	end

	local under = minetest.get_node(pt.under)
	local above = minetest.get_node(pt.above)

	if minetest.is_protected(pt.above, placer:get_player_name()) then
		minetest.record_protection_violation(pt.above, placer:get_player_name())
		return
	end

	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] or not minetest.registered_nodes[above.name] then
		return itemstack
	end
	-- check if you can replace the node above the pointed node
	if not minetest.registered_nodes[above.name].buildable_to then
		return itemstack
	end

	local new_param2
	-- check if pointing at an existing stalactite
	if minetest.get_item_group(under.name, "subterrane_stal_align") ~= 0 then
		new_param2 = under.param2
	else
		new_param2 = math.random(0,3)
	end

	-- add the node and remove 1 item from the itemstack
	local newnode= {name = itemstack:get_name(), param2 = new_param2, param1=0}
	local oldnode= minetest.get_node(pt.above)
	minetest.add_node(pt.above, {name = itemstack:get_name(), param2 = new_param2})
	
	-- Run script hook
	local take_item = true
	for _, callback in ipairs(core.registered_on_placenodes) do
		-- Deepcopy pos, node and pointed_thing because callback can modify them
		local place_to_copy = vector.copy(pt.above)
		local newnode_copy = {name=newnode.name, param1=newnode.param1, param2=newnode.param2}
		local oldnode_copy = {name=oldnode.name, param1=oldnode.param1, param2=oldnode.param2}
		local pointed_thing_copy = copy_pointed_thing(pointed_thing)
		if callback(place_to_copy, newnode_copy, placer, oldnode_copy, itemstack, pointed_thing_copy) then
			take_item = false
		end
	end
	
	if not minetest.is_creative_enabled(placer:get_player_name()) and take_item then
		itemstack:take_item()
	end
	return itemstack
end

local stal_box_1 = {{-0.0625+x_disp, -0.5, -0.0625+z_disp, 0.0625+x_disp, 0.5, 0.0625+z_disp}}
local stal_box_2 = {{-0.125+x_disp, -0.5, -0.125+z_disp, 0.125+x_disp, 0.5, 0.125+z_disp}}
local stal_box_3 = {{-0.25+x_disp, -0.5, -0.25+z_disp, 0.25+x_disp, 0.5, 0.25+z_disp}}
local stal_box_4 = {{-0.375+x_disp, -0.5, -0.375+z_disp, 0.375+x_disp, 0.5, 0.375+z_disp}}

local torchspine_list = {"df_trees:torchspine_1","df_trees:torchspine_2","df_trees:torchspine_3","df_trees:torchspine_4"}
local grow_torchspine = function(pos)
	local param2 = minetest.get_node(pos).param2
	
	if param2 > 3 then
		return -- tipped over, don't grow
	end
	
	local node_above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	local node_above_def = minetest.registered_nodes[node_above.name]
	if not node_above_def.buildable_to then
		-- don't grow, but do continue cycling the torch state
		minetest.swap_node(pos, {name = "df_trees:torchspine_1", param2 = param2})
		minetest.get_node_timer(pos):start(math.random(torchspine_min_delay, torchspine_max_delay))
		return
	end

	local pos_base = vector.new(pos)
	local height = 1
	for i = 1,3 do
		pos_base.y = pos_base.y-1
		if minetest.get_item_group(minetest.get_node(pos_base).name, "df_trees_torchspine") > 0 then
			height = height + 1
		else
			break
		end
	end
	if height >= 4 then
		-- don't grow, but do continue cycling the torch state
		minetest.swap_node(pos, {name = "df_trees:torchspine_1", param2 = param2})
		minetest.get_node_timer(pos):start(math.random(torchspine_min_delay, torchspine_max_delay))
		return
	end

	-- place a taller torchspine
	pos.y = pos.y + 1
	minetest.get_node_timer(pos):start(math.random(torchspine_min_delay, torchspine_max_delay))
	for i = 1, height+1 do
		minetest.swap_node(pos, {name=torchspine_list[i], param2 = param2})
		pos.y = pos.y - 1
	end
end

local torch_node = df_dependencies.node_name_torch

minetest.register_node("df_trees:torchspine_1", {
	description = S("Torchspine Tip"),
	_doc_items_longdesc = df_trees.doc.torchspine_desc,
	_doc_items_usagehelp = df_trees.doc.torchspine_usage,
	tiles = {"dfcaverns_torchspine_0.5.png", "dfcaverns_torchspine_1.5.png", "dfcaverns_torchspine_1.png"},
	groups = {oddly_breakable_by_hand = 1, subterrane_stal_align = 1, flow_through = 1, fall_damage_add_percent = 100, df_trees_torchspine = 1, pickaxey=1, building_block=1, material_stone=1},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = torch_node,
	node_box = {
		type = "fixed",
		fixed = stal_box_1,
	},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,

	on_place = stal_on_place,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == torch_node then
			minetest.swap_node(pos, {name = "df_trees:torchspine_1_lit", param2 = node.param2})
		end
	end,
	
	on_timer = function(pos)
		local above_def = minetest.registered_nodes[minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name]
		if above_def and above_def.buildable_to then
			minetest.swap_node(pos, {name="df_trees:torchspine_1_lit", param2=minetest.get_node(pos).param2})
			minetest.sound_play({pos = pos}, {name="dfcaverns_torchspine_ignite"}, true)
		end
		minetest.get_node_timer(pos):start(math.random(torchspine_min_delay, torchspine_max_delay))
	end,
	
	on_destruct = function(pos)
		minetest.get_node_timer(pos):stop()
	end,
})

minetest.register_node("df_trees:torchspine_1_lit", {
	description = S("Torchspine Tip") .. " (lit)",
	_doc_items_longdesc = df_trees.doc.torchspine_desc,
	_doc_items_usagehelp = df_trees.doc.torchspine_usage,
	tiles = {df_dependencies.texture_gold_block, "dfcaverns_torchspine_1.5.png", "dfcaverns_torchspine_1_lit.png"},
	groups = {oddly_breakable_by_hand = 1, subterrane_stal_align = 1, flow_through = 1, torch = 1, fall_damage_add_percent = 150, smokey = 4, df_trees_torchspine = 1,pickaxey=1, building_block=1, material_stone=1,set_on_fire=3},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 8,
	is_ground_content = false,
	drop = torch_node .. " 2",
	node_box = {
		type = "fixed",
		fixed = stal_box_1,
	},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,

	on_place = stal_on_place,
	
	on_timer = function(pos)
		grow_torchspine(pos)
	end,
	
	on_destruct = function(pos)
		minetest.get_node_timer(pos):stop()
	end,
})

if looped_node_sound_modpath then
	looped_node_sound.register({
		node_list = {"df_trees:torchspine_1_lit"},
		sound = "dfcaverns_torchspine_loop",
		max_gain = 0.5,
		gain_per_node = 0.05,
	})
end

minetest.register_node("df_trees:torchspine_2", {
	description = S("Torchspine") .. " (size 2)",
	_doc_items_longdesc = df_trees.doc.torchspine_desc,
	_doc_items_usagehelp = df_trees.doc.torchspine_usage,
	tiles = {"dfcaverns_torchspine_1.5.png", "dfcaverns_torchspine_2.5.png", "dfcaverns_torchspine_2.png"},
	groups = {oddly_breakable_by_hand = 1, subterrane_stal_align = 1, flow_through = 1, fall_damage_add_percent = 50, df_trees_torchspine = 1,pickaxey=1, building_block=1, material_stone=1},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = stal_box_2,
	},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,

	drop = {
            max_items = 1,
            items = {
                {
                    items = {"df_trees:torchspine_ember"},  -- Items to drop
                    rarity = 2,  -- Probability of dropping is 1 / rarity
                },
            },
        },
	on_place = stal_on_place,
})

minetest.register_node("df_trees:torchspine_3", {
	description = S("Torchspine") .. " (size 3)",
	_doc_items_longdesc = df_trees.doc.torchspine_desc,
	_doc_items_usagehelp = df_trees.doc.torchspine_usage,
	tiles = {"dfcaverns_torchspine_2.5.png", "dfcaverns_torchspine_3.5.png", "dfcaverns_torchspine_3.png"},
	groups = {oddly_breakable_by_hand = 1, subterrane_stal_align = 1, flow_through = 1, df_trees_torchspine = 1,pickaxey=1, building_block=1, material_stone=1},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = stal_box_3,
	},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,

	drop = {
            max_items = 1,
            items = {
                {
                    items = {"df_trees:torchspine_ember"},  -- Items to drop
                    rarity = 2,  -- Probability of dropping is 1 / rarity
                },
                {
                    items = {"df_trees:torchspine_ember 2"},  -- Items to drop
                    rarity = 2,  -- Probability of dropping is 1 / rarity
                },
            },
        },
	on_place = stal_on_place,
})

minetest.register_node("df_trees:torchspine_4", {
	description = S("Torchspine") .. " (size 4)",
	_doc_items_longdesc = df_trees.doc.torchspine_desc,
	_doc_items_usagehelp = df_trees.doc.torchspine_usage,
	tiles = {"dfcaverns_torchspine_3.5.png", "dfcaverns_torchspine_4.5.png", "dfcaverns_torchspine_4.png"},
	groups = {oddly_breakable_by_hand = 1, subterrane_stal_align = 1, flow_through = 1, df_trees_torchspine = 1,pickaxey=1, building_block=1, material_stone=1},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = stal_box_4,
	},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,

	drop = {
            max_items = 1,
            items = {
                {
                    items = {"df_trees:torchspine_ember 2"},  -- Items to drop
                    rarity = 2,  -- Probability of dropping is 1 / rarity
                },
                {
                    items = {"df_trees:torchspine_ember"},  -- Items to drop
                    rarity = 1,  -- Probability of dropping is 1 / rarity
                },
            },
        },	on_place = stal_on_place,
})

minetest.register_node("df_trees:torchspine_ember", {
	description = S("Torchspine Ember"),
	_doc_items_longdesc = df_trees.doc.torchspine_desc,
	_doc_items_usagehelp = df_trees.doc.torchspine_usage,
	tiles = {"dfcaverns_torchspine_0.5.png",},
	groups = {oddly_breakable_by_hand = 1, subterrane_stal_align = 1, flow_through = 1,pickaxey=1, building_block=1, material_stone=1,set_on_fire=1},
	drawtype = "nodebox",
	paramtype = "light",
	light_source = 2,
	paramtype2 = "facedir",
	walkable = false,
	is_ground_content = false,
	floodable = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.0625 + x_disp, -0.5, -0.125 + z_disp, 0.125 + x_disp, -0.375, 0.0625 + z_disp},
		}
	},
	_mcl_blast_resistance = 10,
	_mcl_hardness = 1,

	on_place = stal_on_place,
	
	on_construct = function(pos)
		if df_trees.torchspine_growth_permitted(pos) then
			minetest.get_node_timer(pos):start(math.random(torchspine_min_delay, torchspine_max_delay))
		end
	end,
	on_destruct = function(pos)
		minetest.get_node_timer(pos):stop()
	end,
	
	on_timer = function(pos)
		minetest.swap_node(pos, {name="df_trees:torchspine_1", param2=minetest.get_node(pos).param2})
		minetest.get_node_timer(pos):start(math.random(torchspine_min_delay, torchspine_max_delay))
		minetest.sound_play({pos = pos}, {name="dfcaverns_torchspine_ignite"}, true)
	end,
})

df_trees.spawn_torchspine = function(pos)
	local x, y, z = pos.x, pos.y, pos.z
	local stem_height = math.random(1,4)

	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
		{x = x, y = y, z = z},
		{x = x, y = y+height-1, z = z}
	)
	local area = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()
	local data_param2 = vm:get_param2_data()

	df_trees.spawn_torchspine_vm(vi, area, data, data_param2, height)
	
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

local torchspine_c =
{
	minetest.get_content_id("df_trees:torchspine_1"),
	minetest.get_content_id("df_trees:torchspine_2"),
	minetest.get_content_id("df_trees:torchspine_3"),
	minetest.get_content_id("df_trees:torchspine_4")
}
local torchspine_lit_c =
{
	minetest.get_content_id("df_trees:torchspine_1_lit"),
	minetest.get_content_id("df_trees:torchspine_2"),
	minetest.get_content_id("df_trees:torchspine_3"),
	minetest.get_content_id("df_trees:torchspine_4")
}

df_trees.spawn_torchspine_vm = function(vi, area, data, data_param2, height, lit)
	if height == nil then height = math.random(1,4) end
	if lit == nil then lit = math.random() < 0.3 end
	local param2 = math.random(0,3)
	local list
	if lit then list = torchspine_lit_c else list = torchspine_c end
	
	for i = 0, height-1 do
		if not minetest.registered_nodes[minetest.get_name_from_content_id(data[vi + area.ystride*i])].buildable_to then
			height = i
			break
		end
	end
	
	for i = 0, height-1 do
		local index = vi + area.ystride*i
		data[index] = list[height-i]
		data_param2[index] = param2
	end
	
	local pos = area:position(vi)
	pos.y = pos.y+height-1
	local node = minetest.get_node(pos)
	minetest.get_node_timer(pos):start(math.random()*3000)
end

minetest.register_lbm({
    label = "Start timers for torchspine nodes that used to depend on the ABM",
    name = "df_trees:start_torchspine_timers",
    nodenames = {"df_trees:torchspine_ember", "df_trees:torchspine_1", "df_trees:torchspine_1_lit"},
    run_at_every_load = false,
    action = function(pos, node)
		minetest.get_node_timer(pos):start(math.random(torchspine_min_delay, torchspine_max_delay))
	end,
})
