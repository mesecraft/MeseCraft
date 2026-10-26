-- Hard-coding on account of issue https://github.com/minetest/minetest/issues/7364
local height_min = magma_conduits.config.lower_limit
local height_max = magma_conduits.config.upper_limit

minetest.register_ore({
	ore_type = "vein",
	ore = "default:lava_source",
	wherein = {
		"default:stone",
		"default:desert_stone",
		"default:sandstone",
		"default:stone_with_coal",
		"default:stone_with_iron",
		"default:stone_with_copper",
		"default:stone_with_tin",
		"default:stone_with_gold",
		"default:stone_with_diamond",
		"default:dirt",
		"default:dirt_with_grass",
		"default:dirt_with_dry_grass",
		"default:dirt_with_snow",
		"default:dirt_with_rainforest_litter",
		"default:dirt_with_coniferous_litter",
		"default:sand",
		"default:desert_sand",
		"default:silver_sand",
		"default:gravel",
	},
	column_height_min = 2,
	column_height_max = 6,
	y_min = height_min,
	y_max = height_max,
	noise_threshold = 0.9,
	noise_params = {
		offset = 0,
		scale = 3,
		spread = {x=magma_conduits.config.spread, y=magma_conduits.config.spread*2, z=magma_conduits.config.spread},
		seed = 25391,
		octaves = 4,
		persist = 0.5,
		flags = "eased",
	},
	random_factor = 0,
})

-------------------------------------------------------------------------------------------------

local water_level = tonumber(minetest.get_mapgen_setting("water_level"))

local ameliorate_floods = magma_conduits.config.ameliorate_floods
local obsidian_lining = magma_conduits.config.obsidian_lining

local c_air = minetest.get_content_id("air")
local c_lava = minetest.get_content_id("default:lava_source")
local c_stone = minetest.get_content_id("default:stone")
local c_obsidian = minetest.get_content_id("default:obsidian")

local is_adjacent_to_air = function(area, data, x, y, z)
	return (data[area:index(x+1, y, z)] == c_air
		or data[area:index(x-1, y, z)] == c_air
		or data[area:index(x, y, z+1)] == c_air
		or data[area:index(x, y, z-1)] == c_air
		or data[area:index(x, y-1, z)] == c_air)
end

local remove_unsupported_lava
remove_unsupported_lava = function(area, data, vi, x, y, z)
	--if below water level, abort. Caverns are on their own.
	if y < water_level or not area:contains(x, y, z) then return end

	if data[vi] == c_lava then
		if is_adjacent_to_air(area, data, x, y, z) then
			data[vi] = c_air
			for pi, x2, y2, z2 in area:iter_xyz(x-1, y, z-1, x+1, y+1, z+1) do
				if pi ~= vi and area:containsi(pi) then
					remove_unsupported_lava(area, data, pi, x2, y2, z2)
				end
			end
		end
	end
end

-- If we're adding glow versions of rock, then place glow obsidian directly.
local obsidianize_id
if magma_conduits.config.glowing_rock then
	obsidianize_id = minetest.get_content_id("magma_conduits:glow_obsidian")
else
	obsidianize_id = c_obsidian
end

local obsidianize = function(area, data, vi, x, y, z, minp, maxp)
	if data[vi] == c_lava then
		for pi in area:iter(math.max(x-1, minp.x), math.max(y-1, minp.y), math.max(z-1, minp.z),
							math.min(x+1, maxp.x), math.min(y+1, maxp.y), math.min(z+1, maxp.z)) do
			if data[pi] == c_stone then
				data[pi] = obsidianize_id
			end
		end
	end
end

local data = {}

minetest.register_on_generated(function(minp, maxp, seed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)
	
	-- Both passes only act on lava, so skip the calls for every other node.
	local has_lava = false
	for vi, x, y, z in area:iterp_xyz(minp, maxp) do
		if data[vi] == c_lava then
			has_lava = true
			if obsidian_lining then
				obsidianize(area, data, vi, x, y, z, minp, maxp)
			end
			if ameliorate_floods then
				remove_unsupported_lava(area, data, vi, x, y, z)
			end
		end
	end

	-- Most chunks have no lava; nothing changed, so skip relighting and writing the chunk.
	if not has_lava then
		return
	end

	--send data back to voxelmanip
	vm:set_data(data)
	--calc lighting
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:update_liquids()
	--write it to world
	vm:write_to_map()
end)