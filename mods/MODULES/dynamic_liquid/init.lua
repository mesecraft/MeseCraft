dynamic_liquid = {} -- global table to expose liquid_abm for other mods' usage

dynamic_liquid.registered_liquids = {} -- used by the flow-through node abm
dynamic_liquid.registered_liquid_neighbors = {}

local water_level = tonumber(minetest.get_mapgen_setting("water_level"))

-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

dofile(MP.."/cooling_lava.lua")

-- By making this giant table of all possible permutations of horizontal direction we can avoid
-- lots of redundant calculations.

local all_direction_permutations = {
	{{x=0,z=1},{x=0,z=-1},{x=1,z=0},{x=-1,z=0}},
	{{x=0,z=1},{x=0,z=-1},{x=-1,z=0},{x=1,z=0}},
	{{x=0,z=1},{x=1,z=0},{x=0,z=-1},{x=-1,z=0}},
	{{x=0,z=1},{x=1,z=0},{x=-1,z=0},{x=0,z=-1}},
	{{x=0,z=1},{x=-1,z=0},{x=0,z=-1},{x=1,z=0}},
	{{x=0,z=1},{x=-1,z=0},{x=1,z=0},{x=0,z=-1}},
	{{x=0,z=-1},{x=0,z=1},{x=-1,z=0},{x=1,z=0}},
	{{x=0,z=-1},{x=0,z=1},{x=1,z=0},{x=-1,z=0}},
	{{x=0,z=-1},{x=1,z=0},{x=-1,z=0},{x=0,z=1}},
	{{x=0,z=-1},{x=1,z=0},{x=0,z=1},{x=-1,z=0}},
	{{x=0,z=-1},{x=-1,z=0},{x=1,z=0},{x=0,z=1}},
	{{x=0,z=-1},{x=-1,z=0},{x=0,z=1},{x=1,z=0}},
	{{x=1,z=0},{x=0,z=1},{x=0,z=-1},{x=-1,z=0}},
	{{x=1,z=0},{x=0,z=1},{x=-1,z=0},{x=0,z=-1}},
	{{x=1,z=0},{x=0,z=-1},{x=0,z=1},{x=-1,z=0}},
	{{x=1,z=0},{x=0,z=-1},{x=-1,z=0},{x=0,z=1}},
	{{x=1,z=0},{x=-1,z=0},{x=0,z=1},{x=0,z=-1}},
	{{x=1,z=0},{x=-1,z=0},{x=0,z=-1},{x=0,z=1}},
	{{x=-1,z=0},{x=0,z=1},{x=1,z=0},{x=0,z=-1}},
	{{x=-1,z=0},{x=0,z=1},{x=0,z=-1},{x=1,z=0}},
	{{x=-1,z=0},{x=0,z=-1},{x=1,z=0},{x=0,z=1}},
	{{x=-1,z=0},{x=0,z=-1},{x=0,z=1},{x=1,z=0}},
	{{x=-1,z=0},{x=1,z=0},{x=0,z=-1},{x=0,z=1}},
	{{x=-1,z=0},{x=1,z=0},{x=0,z=1},{x=0,z=-1}},
}

local get_node = minetest.get_node
local set_node = minetest.swap_node

-- Dynamic liquids
-----------------------------------------------------------------------------------------------------------------------

local disable_flow_above = tonumber(minetest.settings:get("dynamic_liquid_disable_flow_above"))

if disable_flow_above == nil or disable_flow_above >= 31000 then

-- version without altitude check
	dynamic_liquid.liquid_abm = function(liquid, flowing_liquid, chance)
		minetest.register_abm({
			label = "dynamic_liquid " .. liquid .. " and " .. flowing_liquid,
			nodenames = {liquid},
			neighbors = {flowing_liquid},
			interval = 1,
			chance = chance or 1,
			catch_up = false,
			action = function(pos,node) -- Do everything possible to optimize this method
				local check_pos = {x=pos.x, y=pos.y-1, z=pos.z}
				local check_node = get_node(check_pos)
				local check_node_name = check_node.name
				if check_node_name == flowing_liquid or check_node_name == "air" then
					set_node(pos, check_node)
					set_node(check_pos, node)
					return
				end
				local perm = all_direction_permutations[math.random(24)]
				local dirs -- declare outside of loop so it won't keep entering/exiting scope
				for i=1,4 do
					dirs = perm[i]
					-- reuse check_pos to avoid allocating a new table
					check_pos.x = pos.x + dirs.x 
					check_pos.y = pos.y
					check_pos.z = pos.z + dirs.z
					check_node = get_node(check_pos)
					check_node_name = check_node.name
					if check_node_name == flowing_liquid or check_node_name == "air" then
						set_node(pos, check_node)
						set_node(check_pos, node)
						return
					end
				end
			end
		})	
		dynamic_liquid.registered_liquids[liquid] = flowing_liquid
		table.insert(dynamic_liquid.registered_liquid_neighbors, liquid)
	end

else
-- version with altitude check
	dynamic_liquid.liquid_abm = function(liquid, flowing_liquid, chance)
		minetest.register_abm({
			label = "dynamic_liquid " .. liquid .. " and " .. flowing_liquid .. " with altitude check",
			nodenames = {liquid},
			neighbors = {flowing_liquid},
			interval = 1,
			chance = chance or 1,
			catch_up = false,
			action = function(pos,node) -- Do everything possible to optimize this method
				-- This altitude check is the only difference from the version above.
				-- If the altitude check is disabled we don't ever need to make the comparison,
				-- hence the two different versions.
				if pos.y > disable_flow_above then
					return
				end
				local check_pos = {x=pos.x, y=pos.y-1, z=pos.z}
				local check_node = get_node(check_pos)
				local check_node_name = check_node.name
				if check_node_name == flowing_liquid or check_node_name == "air" then
					set_node(pos, check_node)
					set_node(check_pos, node)
					return
				end
				local perm = all_direction_permutations[math.random(24)]
				local dirs -- declare outside of loop so it won't keep entering/exiting scope
				for i=1,4 do
					dirs = perm[i]
					-- reuse check_pos to avoid allocating a new table
					check_pos.x = pos.x + dirs.x 
					check_pos.y = pos.y
					check_pos.z = pos.z + dirs.z
					check_node = get_node(check_pos)
					check_node_name = check_node.name
					if check_node_name == flowing_liquid or check_node_name == "air" then
						set_node(pos, check_node)
						set_node(check_pos, node)
						return
					end
				end
			end
		})	
		dynamic_liquid.registered_liquids[liquid] = flowing_liquid
		table.insert(dynamic_liquid.registered_liquid_neighbors, liquid)
	end

end

if not minetest.get_modpath("default") then
	return
end

local water = minetest.settings:get_bool("dynamic_liquid_water", true)
local river_water = minetest.settings:get_bool("dynamic_liquid_river_water", false)
local lava = minetest.settings:get_bool("dynamic_liquid_lava", true)

local water_probability = tonumber(minetest.settings:get("dynamic_liquid_water_flow_propability"))
if water_probability == nil then
	water_probability = 1
end

local river_water_probability = tonumber(minetest.settings:get("dynamic_liquid_river_water_flow_propability"))
if river_water_probability == nil then
	river_water_probability = 1
end

local lava_probability = tonumber(minetest.settings:get("dynamic_liquid_lava_flow_propability"))
if lava_probability == nil then
	lava_probability = 5
end

local springs = minetest.settings:get_bool("dynamic_liquid_springs", true)

if water then
	-- override water_source and water_flowing with liquid_renewable set to false
	local override_def = {liquid_renewable = false}
	minetest.override_item("default:water_source", override_def)
	minetest.override_item("default:water_flowing", override_def)
end

if lava then
	dynamic_liquid.liquid_abm("default:lava_source", "default:lava_flowing", lava_probability)
end
if water then
	dynamic_liquid.liquid_abm("default:water_source", "default:water_flowing", water_probability)
end
if river_water then	
	dynamic_liquid.liquid_abm("default:river_water_source", "default:river_water_flowing", river_water_probability)
end

-- Flow-through nodes
-----------------------------------------------------------------------------------------------------------------------

local flow_through = minetest.settings:get_bool("dynamic_liquid_flow_through", true)

if flow_through then

	local flow_through_directions = {
		{{x=1,z=0},{x=0,z=1}},
		{{x=0,z=1},{x=1,z=0}},
	}
	
	minetest.register_abm({
		label = "dynamic_liquid flow-through",
		nodenames = {"group:flow_through", "group:leaves", "group:sapling", "group:grass", "group:dry_grass", "group:flora", "groups:rail", "groups:flower"},
		neighbors = dynamic_liquid.registered_liquid_neighbors,
		interval = 1,
		chance = 2, -- since liquid is teleported two nodes by this abm, halve the chance
		catch_up = false,
		action = function(pos)
			local source_pos = {x=pos.x, y=pos.y+1, z=pos.z}
			local dest_pos = {x=pos.x, y=pos.y-1, z=pos.z}
			local source_node = get_node(source_pos)
			local dest_node
			local source_flowing_node = dynamic_liquid.registered_liquids[source_node.name]
			local dest_flowing_node
			if source_flowing_node ~= nil then
				dest_node = minetest.get_node(dest_pos)
				if dest_node.name == source_flowing_node or dest_node.name == "air" then
					set_node(dest_pos, source_node)
					set_node(source_pos, dest_node)
					return
				end
			end
			
			local perm = flow_through_directions[math.random(2)]
			local dirs -- declare outside of loop so it won't keep entering/exiting scope
			for i=1,2 do
				dirs = perm[i]
				-- reuse to avoid allocating a new table
				source_pos.x = pos.x + dirs.x 
				source_pos.y = pos.y
				source_pos.z = pos.z + dirs.z
				
				dest_pos.x = pos.x - dirs.x 
				dest_pos.y = pos.y
				dest_pos.z = pos.z - dirs.z			
				
				source_node = get_node(source_pos)
				dest_node = get_node(dest_pos)
				source_flowing_node = dynamic_liquid.registered_liquids[source_node.name]
				dest_flowing_node = dynamic_liquid.registered_liquids[dest_node.name]
				
				if (source_flowing_node ~= nil and (dest_node.name == source_flowing_node or dest_node.name == "air")) or
					(dest_flowing_node ~= nil and (source_node.name == dest_flowing_node or source_node.name == "air"))
				then
					set_node(source_pos, dest_node)
					set_node(dest_pos, source_node)
					return
				end
			end		
		end,
	})

	local add_flow_through = function(node_name)
		local node_def = minetest.registered_nodes[node_name]
		if node_def == nil then
			minetest.log("warning", "dynamic_liquid attempted to call add_flow_through on the node name "
				.. node_name .. ", which was not found in minetest.registered_nodes.")
			return
		end
		local new_groups = node_def.groups
		new_groups.flow_through = 1
		minetest.override_item(node_name,{groups = new_groups})
	end

	if minetest.get_modpath("default") then
		for _, name in pairs({
			"default:apple",
			"default:papyrus",
			"default:dry_shrub",
			"default:bush_stem",
			"default:acacia_bush_stem",
			"default:ladder_wood",
			"default:ladder_steel",
			"default:fence_wood",
			"default:fence_acacia_wood",
			"default:fence_junglewood",
			"default:fence_pine_wood",
			"default:fence_aspen_wood",
		}) do
			add_flow_through(name)
		end
	end
	
	if minetest.get_modpath("xpanes") then
		add_flow_through("xpanes:bar")
		add_flow_through("xpanes:bar_flat")
	end
	
	if minetest.get_modpath("carts") then
		add_flow_through("carts:rail")
		add_flow_through("carts:powerrail")
		add_flow_through("carts:brakerail")
	end

	-- Add "signs" support.
	if minetest.get_modpath("signs") then
		add_flow_through("signs:sign")
	end
end


-- Springs
-----------------------------------------------------------------------------------------------------------------------
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

local duplicate_def = function (name)
	local old_def = minetest.registered_nodes[name]
	return deep_copy(old_def)
end

-- register damp clay whether we're going to set the ABM or not, if the user disables this feature we don't want existing
-- spring clay to turn into unknown nodes.
local clay_def = duplicate_def("default:clay")
clay_def.description = S("Damp Clay")
if not springs then
	clay_def.groups.not_in_creative_inventory = 1 -- take it out of creative inventory though
end
minetest.register_node("dynamic_liquid:clay", clay_def)

local data = {}

if springs then	
	local c_clay = minetest.get_content_id("default:clay")
	local c_spring_clay = minetest.get_content_id("dynamic_liquid:clay")

	-- Turn mapgen clay into spring clay
	minetest.register_on_generated(function(minp, maxp, seed)
		if minp.y >= water_level or maxp.y <= -15 then
			return
		end
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		vm:get_data(data)
		
		local changed = false
		for voxelpos = 1, #data do
			if data[voxelpos] == c_clay then
				data[voxelpos] = c_spring_clay
				changed = true
			end
		end
		if changed then
			vm:set_data(data)
			vm:write_to_map()
		end
	end)
	
	minetest.register_abm({
		label = "dynamic_liquid damp clay spring",
		nodenames = {"dynamic_liquid:clay"},
		neighbors = {"air", "default:water_source", "default:water_flowing"},
		interval = 1,
		chance = 1,
		catch_up = false,
		action = function(pos,node)
			local check_node
			local check_node_name
			while pos.y < water_level do
				pos.y = pos.y + 1
				check_node = get_node(pos)
				check_node_name = check_node.name
				if check_node_name == "air" or check_node_name == "default:water_flowing" then
					set_node(pos, {name="default:water_source"})
				elseif check_node_name ~= "default:water_source" then
					--Something's been put on top of this clay, don't send water through it
					break
				end
			end
		end
	})
	
	local spring_sounds = nil
	if default.node_sound_gravel_defaults ~= nil then
		spring_sounds = default.node_sound_gravel_defaults()
	elseif default.node_sound_sand_defaults ~= nil then
		spring_sounds = default.node_sound_dirt_defaults()
	end
	
	-- This is a creative-mode only node that produces a modest amount of water continuously no matter where it is.
	-- Allow this one to turn into "unknown node" when this feature is disabled, since players had to explicitly place it.
	minetest.register_node("dynamic_liquid:spring", {
		description = S("Spring"),
		_doc_items_longdesc = S("A natural spring that generates an endless stream of water source blocks"),
		_doc_items_usagehelp = S("Generates one source block of water directly on top of itself once per second, provided the space is clear. If this natural spring is dug out the flow stops and it is turned into ordinary cobble."),
		drops = "default:gravel",
		tiles = {"default_cobble.png^[combine:16x80:0,-48=crack_anylength.png",
			"default_cobble.png","default_cobble.png","default_cobble.png","default_cobble.png","default_cobble.png",
			},
		is_ground_content = false,
		groups = {cracky = 3, stone = 2},
		sounds = spring_sounds,
	})
	
	minetest.register_abm({
		label = "dynamic_liquid creative spring",
		nodenames = {"dynamic_liquid:spring"},
		neighbors = {"air", "default:water_flowing"},
		interval = 1,
		chance = 1,
		catch_up = false,
		action = function(pos,node)
			pos.y = pos.y + 1
			local check_node = get_node(pos)
			local check_node_name = check_node.name
			if check_node_name == "air" or check_node_name == "default:water_flowing" then
				set_node(pos, {name="default:water_source"})
			end
		end
	})	
end

local mapgen_prefill = minetest.settings:get_bool("dynamic_liquid_mapgen_prefill", true)

local waternodes

if mapgen_prefill then
	local c_water = minetest.get_content_id("default:water_source")
	local c_air = minetest.get_content_id("air")
	waternodes = {}

	local fill_to = function (vi, data, area)
		if area:containsi(vi) and area:position(vi).y <= water_level then
			if data[vi] == c_air then
				data[vi] = c_water
				table.insert(waternodes, vi)
			end
		end
	end

--	local count = 0
	local drop_liquid = function(vi, data, area, min_y)
		if data[vi] ~= c_water then
			-- we only care about water.
			return
		end
		local start = vi -- remember the water node we started from
		local ystride = area.ystride
		vi = vi - ystride
		if data[vi] ~= c_air then
			-- if there's no air below this water node, give up immediately.
			return
		end
		vi = vi - ystride -- There's air below the water, so move down one.
		while data[vi] == c_air and area:position(vi).y > min_y do
			-- the min_y check is here to ensure that we don't put water into the mapgen
			-- border zone below our current map chunk where it might get erased by future mapgen activity.
			-- if there's more air, keep going.
			vi = vi - ystride
		end
		vi = vi + ystride -- Move back up one. vi is now pointing at the last air node above the first non-air node.
		data[vi] = c_water
		data[start] = c_air
--		count = count + 1
--		if count % 100 == 0 then
--			minetest.chat_send_all("dropped water " .. (start-vi)/ystride .. " at " .. minetest.pos_to_string(area:position(vi)))
--		end
	end
	
	minetest.register_on_generated(function(minp, maxp, seed)
		if minp.y > water_level then
			-- we're in the sky.
			return
		end
	
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		vm:get_data(data)
		local maxp_y = maxp.y
		local minp_y = minp.y
		
		if maxp_y > -70 then
			local top = vector.new(maxp.x, math.min(maxp_y, water_level), maxp.z) -- prevents flood fill from affecting any water above sea level
			for vi in area:iterp(minp, top) do
				if data[vi] == c_water then
					table.insert(waternodes, vi)
				end
			end
			
			while table.getn(waternodes) > 0 do
				local vi = table.remove(waternodes)
				local below = vi - area.ystride
				local left = vi - area.zstride
				local right = vi + area.zstride
				local front = vi - 1
				local back = vi + 1
				
				fill_to(below, data, area)
				fill_to(left, data, area)
				fill_to(right, data, area)
				fill_to(front, data, area)
				fill_to(back, data, area)
			end
		else
			-- Caves sometimes generate with liquid nodes hovering in mid air.
			-- This immediately drops them straight down as far as they can go, reducing the ABM thrashing.
			-- We only iterate down to minp.y+1 because anything at minp.y will never be dropped farther anyway.
			for vi in area:iter(minp.x, minp_y+1, minp.z, maxp.x, maxp_y, maxp.z) do
				-- fortunately, area:iter iterates through y columns going upward. Just what we need!
				-- We could possibly be a bit more efficient by remembering how far we dropped then
				-- last liquid node in a column and moving stuff down that far,
				-- but for now let's keep it simple.
				if data[vi] == c_water then -- drop_liquid only acts on water; skip the call otherwise
					drop_liquid(vi, data, area, minp_y)
				end
			end
		end
		
		vm:set_data(data)
		vm:write_to_map()
		vm:update_liquids()
	end)
end

local displace_liquid = minetest.settings:get_bool("dynamic_liquid_displace_liquid", true)
if displace_liquid then

	local cardinal_dirs = {
		{x= 0, y=0,  z= 1},
		{x= 1, y=0,  z= 0},
		{x= 0, y=0,  z=-1},
		{x=-1, y=0,  z= 0},
		{x= 0, y=-1, z= 0},
		{x= 0, y=1,  z= 0},
	}
	-- breadth-first search passing through liquid searching for air or flowing liquid.
	local flood_search_outlet = function(start_pos, source, flowing)
		local start_node =  minetest.get_node(start_pos)
		local start_node_name = start_node.name
		if start_node_name == "air" or start_node_name == flowing then
			return start_pos
		end
	
		local visited = {}
		visited[minetest.hash_node_position(start_pos)] = true
		local queue = {start_pos}
		local queue_pointer = 1
		
		while #queue >= queue_pointer do
			local current_pos = queue[queue_pointer]		
			queue_pointer = queue_pointer + 1
			for _, cardinal_dir in ipairs(cardinal_dirs) do
				local new_pos = vector.add(current_pos, cardinal_dir)
				local new_hash = minetest.hash_node_position(new_pos)
				if visited[new_hash] == nil then
					local new_node = minetest.get_node(new_pos)
					local new_node_name = new_node.name
					if new_node_name == "air" or new_node_name == flowing then
						return new_pos
					end
					visited[new_hash] = true
					if new_node_name == source then
						table.insert(queue, new_pos)
					end
				end
			end		
		end
		return nil
	end

	-- Conserve liquids, when placing nodes in liquids try to find a place to displace the liquid to.
	minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
		local flowing = dynamic_liquid.registered_liquids[oldnode.name]
		if flowing ~= nil then
			local dest = flood_search_outlet(pos, oldnode.name, flowing)
			if dest ~= nil then
				minetest.swap_node(dest, oldnode)
			end
		end
	end)

end
