local bedrock = {}

bedrock.layer = -30912 -- This is the location of the bottom layer.
bedrock.thickness = -30910 -- This is how many layers are on top of the bottom layer. NOTE: these layers are not just flat layers but are more randomized.
bedrock.node = {name = "mesecraft_bedrock:bedrock"} -- This is the block used.

local depth = tonumber(minetest.settings:get("mesecraft_bedrock_y"))
if depth ~= nil then
	bedrock.layer = depth
end

local layers = tonumber(minetest.settings:get("mesecraft_bedrock_layers"))
if layers ~= nil then
	bedrock.thickness = layers
end

minetest.register_on_generated(function(minp, maxp)
	if maxp.y >= bedrock.layer and minp.y <= bedrock.layer then
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local data = vm:get_data()
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local c_bedrock = minetest.get_content_id("mesecraft_bedrock:bedrock")

		for x = minp.x, maxp.x do
			for z = minp.z, maxp.z do
				local p_pos = area:index(x, bedrock.layer, z)
				data[p_pos] = c_bedrock
			end
		end

		vm:set_data(data)
		vm:calc_lighting()
		vm:update_liquids()
		vm:write_to_map()
	end
end)

minetest.register_node("mesecraft_bedrock:bedrock", {
	description = ("Bedrock"),
	tiles = {"mesecraft_bedrock.png"},
	groups = {indestructible=1, not_in_creative_inventory=1, },
	sounds = { footstep = { name = "default_hard_footstep", gain = 1.10 } },
	is_ground_content = false,
	on_blast = function() end,
	on_destruct = function () end,
	can_dig = function() return false end,
	diggable = true,
	drop = "",
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "mesecraft_bedrock:bedrock",
	wherein = "default:stone",
	clust_scarcity = 1*1*1,
	clust_num_ores = 5,
	clust_size = 2,
	y_min = bedrock.layer,
	y_max = bedrock.thickness
})

if minetest.get_modpath("mesecons_mvps") ~= nil then
	mesecon.register_mvps_stopper("mesecraft_bedrock:bedrock")
end
minetest.log("info", "MeseCraft Bedrock loaded successfully!")