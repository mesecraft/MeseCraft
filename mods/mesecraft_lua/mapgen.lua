

local has_bedrock_mod = minetest.get_modpath("mesecraft_bedrock")

-- http://dev.minetest.net/PerlinNoiseMap

-- basic planet material noise
local base_params = {
   offset = 0,
   scale = 1,
   spread = {x=1024, y=512, z=1024},
   seed = 3468584,
   octaves = 5,
   persist = 0.6
}


local c_base = minetest.get_content_id("default:stone")
local c_bedrock


if has_bedrock_mod then
	c_bedrock = minetest.get_content_id("mesecraft_bedrock:bedrock")
end


local base_perlin
local base_perlin_map = {}

minetest.register_on_generated(function(minp, maxp, seed)

	if minp.y < mesecraft_lua.miny or minp.y > mesecraft_lua.maxy then
		return
	end

	-- solid layer
	local is_solid = minp.y < mesecraft_lua.maxsolidy

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	local side_length = maxp.x - minp.x + 1 -- 80
	local map_lengths_xyz = {x=side_length, y=side_length, z=side_length}

	base_perlin = base_perlin or minetest.get_perlin_map(base_params, map_lengths_xyz)
	base_perlin:get3dMap_flat(minp, base_perlin_map)

	local i = 1
	for z=minp.z,maxp.z do
	for y=minp.y,maxp.y do
	for x=minp.x,maxp.x do

		local index = area:index(x,y,z)

		if y >= mesecraft_lua.miny and y < (mesecraft_lua.miny + 10) and has_bedrock_mod then
			data[index] = c_bedrock

		else
			-- unpopulated node

			-- higher elevation = lower chance
			local chance = (y-minp.y) / side_length

			local base_n = base_perlin_map[i]

			if is_solid or base_n > chance then
				data[index] = c_base
			end
		end

		i = i + 1

	end --x
	end --y
	end --z

	vm:set_data(data)
-- 	Uncommenting below line to remove ores from moon. They need to be rebalanced manually.
--	minetest.generate_ores(vm, minp, maxp)
	vm:write_to_map()
end)

-- Predict the moon's surface height at x,z from the same noise and chunk rules as above.
-- Portals need this before the destination has been generated.
local chunk_len = (tonumber(minetest.get_mapgen_setting("chunksize")) or 5) * 16
local chunk_offset = -16 * math.floor(chunk_len / 32)
local base_point_perlin

local function chunk_min_y(y)
	return math.floor((y - chunk_offset) / chunk_len) * chunk_len + chunk_offset
end

function mesecraft_lua.surface_y(x, z)
	base_point_perlin = base_point_perlin or minetest.get_perlin(base_params)
	local top = chunk_min_y(mesecraft_lua.maxy) + chunk_len - 1
	for y = top, mesecraft_lua.miny, -1 do
		local minp_y = chunk_min_y(y)
		if minp_y >= mesecraft_lua.miny and minp_y <= mesecraft_lua.maxy then
			if minp_y < mesecraft_lua.maxsolidy
					or base_point_perlin:get_3d({x = x, y = y, z = z}) > (y - minp_y) / chunk_len then
				return y + 1
			end
		end
	end
	return mesecraft_lua.maxsolidy
end
