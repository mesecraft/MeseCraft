local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local oil_desc
local oil_usage

if minetest.get_modpath("doc") then
	oil_desc = S("Liquid hydrocarbons formed from the detritus of long dead plants and animals processed by heat and pressure deep within the earth.")
	oil_usage = S("Buckets of oil can be used as fuel.")
end

local oil_sounds = {footstep = {name = "oil_oil_footstep", gain = 0.2}}

local water_source = df_dependencies.node_name_water_source
local water_flowing = df_dependencies.node_name_water_flowing
local bucket_empty = df_dependencies.node_name_bucket_empty

minetest.register_node("oil:oil_source", {
	description = S("Oil"),
	_doc_items_longdesc = oil_desc,
	_doc_items_usagehelp = oil_usage,
	drawtype = "liquid",
	tiles = {
		{
			name = "oil_oil_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name = "oil_oil_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
			backface_culling = false,
		},
	},
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	sunlight_propagates = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_range = 3,
	liquid_renewable = false,
	liquid_alternative_flowing = "oil:oil_flowing",
	liquid_alternative_source = "oil:oil_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 250, r = 0, g = 0, b = 0},
	groups = {liquid = 1, dig_by_piston=1},
	sounds = oil_sounds,
	_mcl_blast_resistance      = 100,
	_mcl_hardness              = -1,
})

minetest.register_node("oil:oil_flowing", {
	description = S("Flowing Oil"),
	_doc_items_longdesc = oil_desc,
	_doc_items_usagehelp = oil_usage,
	drawtype = "flowingliquid",
	tiles = {"oil_oil.png"},
	special_tiles = {
		{
			name = "oil_oil_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 4.0,
			},
		},
		{
			name = "oil_oil_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 4.0,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	sunlight_propagates = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_range = 3,
	liquid_renewable = false,
	liquid_alternative_flowing = "oil:oil_flowing",
	liquid_alternative_source = "oil:oil_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 250, r = 0, g = 0, b = 0},
	groups = {liquid = 1, not_in_creative_inventory = 1, dig_by_piston=1},
	sounds = oil_sounds,
	_mcl_blast_resistance      = 100,
	_mcl_hardness              = -1,
})

minetest.register_craft({
	type = "fuel",
	recipe = "oil:oil_source",
	burntime = 370, -- same as coalblock
})

if minetest.get_modpath("dynamic_liquid") then
	dynamic_liquid.liquid_abm("oil:oil_source", "oil:oil_flowing", 2)

	-- not using default liquid_abm to prevent oil from churning around once it's on the surface of water - we want slicks to remain cohesive and static
	minetest.register_abm({
		label = "oil:oil floats",
		nodenames = {"oil:oil_source"},
		neighbors = {water_source},
		interval = 1.0,
		chance = 1,
		catch_up = true,
		action = function(pos, node)
			local next_pos = {x=pos.x, y=pos.y+1, z=pos.z}
			local next_node = minetest.get_node(next_pos)
			local above_name = next_node.name
			if above_name == water_source then
				minetest.swap_node(next_pos, {name="oil:oil_source"})
				minetest.swap_node(pos, next_node)
			else
				next_pos.y = pos.y
				local displacement
				if math.random() > 0.5 then displacement = 1 else displacement = -1 end
				if math.random() > 0.5 then
					next_pos.x = next_pos.x + displacement
				else
					next_pos.z = next_pos.z + displacement
				end
				next_node = minetest.get_node(next_pos)
				if next_node.name == water_source then
					if above_name ~= "air" then
						-- we're not on the surface, so try any lateral movement
						minetest.swap_node(next_pos, {name="oil:oil_source"})
						minetest.swap_node(pos, next_node)
					elseif math.random() < 0.1 then -- expensive and not commonly needed, so don't try this often
						--Otherwise, count neighboring oil nodes and if we're increasing the number of neighboring oil nodes by moving then do so.
						local oil_neighbors_here, here_count = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y, z=pos.z-1}, {x=pos.x+1, y=pos.y, z=pos.z+1}, {"oil:oil_source"})
						local oil_neighbors_there, there_count = minetest.find_nodes_in_area({x=next_pos.x-1, y=next_pos.y, z=next_pos.z-1}, {x=next_pos.x+1, y=next_pos.y, z=next_pos.z+1}, {"oil:oil_source"})
						if there_count["oil:oil_source"] >= here_count["oil:oil_source"] then
							minetest.swap_node(next_pos, {name="oil:oil_source"})
							minetest.swap_node(pos, next_node)
						end
					end
				end				
			end
		end,
	})
	
	-- If oil is wandering around on top of a layer of water that isn't full, drop it down
	-- into the water layer. This helps drive the system toward a more static state with a flat-looking surface.
	minetest.register_abm({
		label = "oil:oil settles",
		nodenames = {"oil:oil_source"},
		neighbors = {water_flowing},
		interval = 1.0,
		chance = 1,
		catch_up = true,
		action = function(pos, node)
			local next_pos = {x=pos.x, y=pos.y-1, z=pos.z}
			local next_node = minetest.get_node(next_pos)
			if next_node.name == water_flowing then
				minetest.swap_node(next_pos, {name="oil:oil_source"})
				minetest.swap_node(pos, next_node)
			end
		end,
	})

end

if df_dependencies.bucket_register_liquid then
	df_dependencies.bucket_register_liquid(
		"oil:oil_source",
		"oil:oil_flowing",
		"oil:oil_bucket",
		"oil_bucket.png",
		S("Oil Bucket")
	)

	minetest.register_craft({
		type = "fuel",
		recipe = "oil:oil_bucket",
		burntime = 370, -- same as coalblock
		replacements = {{"oil:oil_bucket", bucket_empty}},
	})
	
	if minetest.get_modpath("basic_materials") then
		minetest.register_craft({
			type = "cooking",
			output = "basic_materials:paraffin",
			recipe = "oil:oil_bucket",
			cooktime = 5,
			replacements = {{"oil:oil_bucket", bucket_empty}},
		})
	end
end