-- original cave code modified from paramat's subterrain
-- Modified by HeroOfTheWinds for caverealms
-- Modified by FaceDeer for subterrane
-- Depends default
-- License: code MIT

subterrane = {} --create a container for functions and constants

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/dependencies.lua")

local c_stone = minetest.get_content_id(subterrane.dependencies.stone)
local c_clay = minetest.get_content_id(subterrane.dependencies.clay)
local c_desert_stone = minetest.get_content_id(subterrane.dependencies.desert_stone)
local c_sandstone = minetest.get_content_id(subterrane.dependencies.sandstone)

local c_air = minetest.get_content_id("air")
local c_water = minetest.get_content_id(subterrane.dependencies.water)

local c_obsidian = minetest.get_content_id(subterrane.dependencies.obsidian)

local c_cavern_air = c_air
local c_warren_air = c_air

local subterrane_enable_singlenode_mapping_mode = minetest.settings:get_bool("subterrane_enable_singlenode_mapping_mode", false)
if subterrane_enable_singlenode_mapping_mode then
	c_cavern_air = c_stone
	c_warren_air = c_clay
end

local c_lava_set -- will be populated with a set of nodes that count as lava

-- Performance instrumentation
local t_start = os.clock()

subterrane.registered_layers = {}

dofile(modpath.."/defaults.lua")
dofile(modpath.."/features.lua") -- some generic cave features useful for a variety of mapgens
dofile(modpath.."/player_spawn.lua") -- Function for spawning a player in a giant cavern
dofile(modpath.."/test_pos.lua") -- Function other mapgens can use to test if a position is inside a cavern
dofile(modpath.."/legacy.lua") -- contains old node definitions and functions, will be removed at some point in the future.

local disable_mapgen_caverns = function()
	local mg_name = minetest.get_mapgen_setting("mg_name")
	local flags_name
	local default_flags
	
	if mg_name == "v7" then 
		flags_name = "mgv7_spflags"
		default_flags = "mountains,ridges,nofloatlands"
	elseif mg_name == "v5" then
		flags_name = "mgv5_spflags"
		default_flags = ""
	else
		return
	end
	
	local function split(source, delimiters)
		local elements = {}
		local pattern = '([^'..delimiters..']+)'
		string.gsub(source, pattern, function(value) elements[#elements + 1] = value; end);
		return elements
	end
	
	local flags_setting = minetest.get_mapgen_setting(flags_name) or default_flags
	local new_flags = {}
	local flags = split(flags_setting, ", ")
	local nocaverns_present = false
	for _, flag in pairs(flags) do
		if flag ~= "caverns" then
			table.insert(new_flags, flag)
		end
		if flag == "nocaverns" then
			nocaverns_present = true
		end
	end
	if not nocaverns_present then
		table.insert(new_flags, "nocaverns")
	end
	minetest.set_mapgen_setting(flags_name, table.concat(new_flags, ","), true)
end
disable_mapgen_caverns()

-- Column stuff
----------------------------------------------------------------------------------

local grid_size = mapgen_helper.block_size * 4

subterrane.get_column_points = function(minp, maxp, column_def)
	local grids = mapgen_helper.get_nearest_regions(minp, grid_size)
	local points = {}
	for _, grid in ipairs(grids) do
		--The y value of the returned point will be the radius of the column
		local minp = {x=grid.x, y = column_def.minimum_radius*100, z=grid.z}
		local maxp = {x=grid.x+grid_size-1, y=column_def.maximum_radius*100, z=grid.z+grid_size-1}
		for _, point in ipairs(mapgen_helper.get_random_points(minp, maxp, column_def.minimum_count, column_def.maximum_count)) do
			point.y = point.y / 100
			if point.x > minp.x - point.y
				and point.x < maxp.x + point.y
				and point.z > minp.z - point.y
				and point.z < maxp.z + point.y then
				table.insert(points, point)
			end			
		end
	end
	return points
end

subterrane.get_column_value = function(pos, points)
	local heat = 0
	for _, point in ipairs(points) do
		local axis_point = {x=point.x, y=pos.y, z=point.z}
		local radius = point.y
		if (pos.x >= axis_point.x-radius and pos.x <= axis_point.x+radius
			and pos.z >= axis_point.z-radius and pos.z <= axis_point.z+radius) then
			
			local dist = vector.distance(pos, axis_point)
			if dist < radius then
				heat = math.max(heat, 1 - dist/radius)
			end
			
		end
	end
	return heat
end


-- Decoration node lists
----------------------------------------------------------------------------------

-- States any given node can be in. Used to detect boundaries
local outside_region = 1
local inside_ground = 2
local inside_tunnel = 3
local inside_cavern = 4
local inside_warren = 5
local inside_column = 6

-- These arrays will contain the indices of various nodes relevant to decoration
-- Note that table.getn and # will not correctly report the number of items in these since they're reused
-- between calls and are not cleared for efficiency. You can iterate through them using ipairs,
-- and you can get their content count from the similarly-named variable associated with them.
local cavern_data
local cavern_floor_nodes
local cavern_ceiling_nodes
local warren_floor_nodes
local warren_ceiling_nodes
local tunnel_floor_nodes
local tunnel_ceiling_nodes
local column_nodes

local initialize_node_arrays = function()
	cavern_data = {}
	cavern_floor_nodes = {}
	cavern_data.cavern_floor_nodes = cavern_floor_nodes
	cavern_data.cavern_floor_count = 0
	cavern_ceiling_nodes = {}
	cavern_data.cavern_ceiling_nodes = cavern_ceiling_nodes
	cavern_data.cavern_ceiling_count = 0
	warren_floor_nodes = {}
	cavern_data.warren_floor_nodes = warren_floor_nodes
	cavern_data.warren_floor_count = 0
	warren_ceiling_nodes = {}
	cavern_data.warren_ceiling_nodes = warren_ceiling_nodes
	cavern_data.warren_ceiling_count = 0
	tunnel_floor_nodes = {}
	cavern_data.tunnel_floor_nodes = tunnel_floor_nodes
	cavern_data.tunnel_floor_count = 0
	tunnel_ceiling_nodes = {}
	cavern_data.tunnel_ceiling_nodes = tunnel_ceiling_nodes
	cavern_data.tunnel_ceiling_count = 0
	column_nodes = {}
	cavern_data.column_nodes = column_nodes
	cavern_data.column_count = 0
end
initialize_node_arrays()

-- inserts nil after the last node so that ipairs will function correctly
local close_node_arrays = function()
	cavern_ceiling_nodes[cavern_data.cavern_ceiling_count + 1] = nil
	cavern_floor_nodes[cavern_data.cavern_floor_count + 1] = nil
	warren_ceiling_nodes[cavern_data.warren_ceiling_count + 1] = nil
	warren_floor_nodes[cavern_data.warren_floor_count + 1] = nil
	tunnel_ceiling_nodes[cavern_data.tunnel_ceiling_count + 1] = nil
	tunnel_floor_nodes[cavern_data.tunnel_floor_count + 1] = nil
	column_nodes[cavern_data.column_count + 1] = nil
end

-- clear the tables without deleting them - easer on memory management this way
local clear_node_arrays = function()
	cavern_data.cavern_ceiling_count = 0
	cavern_data.cavern_floor_count = 0
	cavern_data.warren_ceiling_count = 0
	cavern_data.warren_floor_count = 0
	cavern_data.tunnel_ceiling_count = 0
	cavern_data.tunnel_floor_count = 0
	cavern_data.column_count = 0
	
--	for k,v in pairs(cavern_ceiling_nodes) do cavern_ceiling_nodes[k] = nil end
--	for k,v in pairs(cavern_floor_nodes) do cavern_floor_nodes[k] = nil end
--	for k,v in pairs(warren_ceiling_nodes) do warren_ceiling_nodes[k] = nil end
--	for k,v in pairs(warren_floor_nodes) do warren_floor_nodes[k] = nil end
--	for k,v in pairs(tunnel_ceiling_nodes) do tunnel_ceiling_nodes[k] = nil end
--	for k,v in pairs(tunnel_floor_nodes) do tunnel_floor_nodes[k] = nil end
--	for k,v in pairs(column_nodes) do column_nodes[k] = nil end
	
	close_node_arrays()
end

-- cave_layer_def
--{
--	name = -- optional, defaults to the string "y_min to y_max" (with actual values inserted in place of y_min and y_max). Used for logging.
--	y_max = -- required, the highest elevation this cave layer will be generated in.
--	y_min = -- required, the lowest elevation this cave layer will be generated in.
--	cave_threshold = -- optional, Cave threshold. Defaults to 0.5. 1 = small rare caves, 0 = 1/2 ground volume
--	warren_region_threshold = -- optional, defaults to 0.25. Used to determine how much volume warrens take up around caverns. Set it to be equal to or greater than the cave threshold to disable warrens entirely.
--	warren_region_variability_threshold = -- optional, defaults to 0.25. Used to determine how much of the region contained within the warren_region_threshold actually has warrens in it.
--	warren_threshold = -- Optional, defaults to 0.25. Determines how "spongey" warrens are, lower numbers make tighter, less-connected warren passages.
--	boundary_blend_range = -- optional, range near ymin and ymax over which caves diminish to nothing. Defaults to 128.
--	perlin_cave = -- optional, a 3D perlin noise definition table to define the shape of the caves
--	perlin_wave = -- optional, a 3D perlin noise definition table that's averaged with the cave noise to add more horizontal surfaces (squash its spread on the y axis relative to perlin_cave to accomplish this)
--	perlin_warren_area = -- optional, a 3D perlin noise definition table for defining what places warrens form in
--	perlin_warrens = -- optional, a 3D perlin noise definition table for defining the warrens
--	solidify_lava = -- when set to true, lava near the edges of caverns is converted into obsidian to prevent it from spilling in.
--	columns = -- optional, a column_def table for producing truly enormous dripstone formations. See below for definition. Set to nil to disable columns.
--	double_frequency = -- when set to true, uses the absolute value of the cavern field to determine where to place caverns instead. This effectively doubles the number of large non-connected caverns.
--	decorate = -- optional, a function that is given a table of indices and a variety of other mapgen information so that it can place custom decorations on floors and ceilings. It is given the parameters (minp, maxp, seed, vm, cavern_data, area, data). See below for the cavern_data table's member definitions.
--	is_ground_content = -- optional, a function that takes a content_id and returns true if caverns should be carved through that node type. If not provided it defaults to a "is_ground_content" test.
--}

-- column_def
--{
--	maximum_radius = -- Maximum radius for individual columns, defaults to 10
--	minimum_radius = -- Minimum radius for individual columns, defaults to 4 (going lower that this can increase the likelihood of "intermittent" columns with floating sections)
--	node = -- node name to build columns out of. Defaults to default:stone
--	warren_node = -- node name to build columns out of in warren areas. If not set, the nodes that would be columns in warrens will be left as original ground contents
--	weight = -- a floating point value (usually in the range of 0.5-1) to modify how strongly the column is affected by the surrounding cave. Lower values create a more variable, tapered stalactite/stalagmite combination whereas a value of 1 produces a roughly cylindrical column. Defaults to 0.25
--	maximum_count = -- The maximum number of columns placed in any given column region (each region being a square 4 times the length and width of a map chunk). Defaults to 50
--	minimum_count = -- The minimum number of columns placed in a column region. The actual number placed will be randomly selected between this range. Defaults to 0.
--}

-- cavern_data -- This is passed into the decorate method.
--{
--	cavern_floor_nodes = {} -- List of data indexes for nodes that are part of cavern floors. Note: Use ipairs() when iterating this, not pairs()
--	cavern_floor_count = 0 -- the count of nodes in the preceeding list.
--	cavern_ceiling_nodes = {} -- List of data indexes for nodes that are part of cavern ceilings. Note: Use ipairs() when iterating this, not pairs()
--	cavern_ceiling_count = 0 -- the count of nodes in the preceeding list.
--	warren_floor_nodes = {} -- List of data indexes for nodes that are part of warren floors. Note: Use ipairs() when iterating this, not pairs()
--	warren_floor_count = 0 -- the count of nodes in the preceeding list.
--	warren_ceiling_nodes = {} -- List of data indexes for nodes that are part of warren floors. Note: Use ipairs() when iterating this, not pairs()
--	warren_ceiling_count = 0 -- the count of nodes in the preceeding list.
--	tunnel_floor_nodes = {} -- List of data indexes for nodes that are part of floors in pre-existing tunnels (anything generated before this mapgen runs). Note: Use ipairs() when iterating this, not pairs()
--	tunnel_floor_count = 0 -- the count of nodes in the preceeding list.
--	tunnel_ceiling_nodes = {}  -- List of data indexes for nodes that are part of ceiling in pre-existing tunnels (anything generated before this mapgen runs). Note: Use ipairs() when iterating this, not pairs()
--	tunnel_ceiling_count = 0 -- the count of nodes in the preceeding list.
--	column_nodes = {} -- Nodes that belong to columns. Note that if the warren_node was not set in the column definition these might not have been replaced by anything yet. This list contains *all* column nodes, not just ones on the surface.
--	column_count = 0 -- the count of nodes in the preceeding list.

--	contains_cavern = false -- Use this if you want a quick check if the generated map chunk has any cavern volume in it. Don't rely on the node counts above, if the map chunk doesn't intersect the floor or ceiling those could be 0 even if a cavern is present.
--	contains_warren = false -- Ditto for contains_cavern
--	nvals_cave = nvals_cave -- The noise array used to generate the cavern.
--	cave_area = cave_area -- a VoxelArea for indexing nvals_cave
--	cavern_def = cave_layer_def -- a reference to the cave layer def.
--}

subterrane.register_layer = function(cave_layer_def)
	local error_out = false
	if cave_layer_def.y_min == nil then
		minetest.log("error", "[subterrane] cave layer def " .. tostring(cave_layer_def.name) .. " did not have a y_min defined. Not registered.")
		error_out = true
	end
	if cave_layer_def.y_max == nil then
		minetest.log("error", "[subterrane] cave layer def " .. tostring(cave_layer_def.name) .. " did not have a y_max defined. Not registered.")
		error_out = true
	end
	if error_out then return end

	subterrane.set_defaults(cave_layer_def)
	
	local YMIN = cave_layer_def.y_min
	local YMAX = cave_layer_def.y_max
	
	if cave_layer_def.name == nil then
		cave_layer_def.name = tostring(YMIN) .. " to " .. tostring(YMAX)
	end

	local cave_name = cave_layer_def.name

	if subterrane.registered_layers[cave_name] ~= nil then
		minetest.log("warning", "[subterrane] cave layer def " .. tostring(cave_name) .. " has already been registered. Overriding with new definition.")
	end
	subterrane.registered_layers[cave_name] = cave_layer_def

	local block_size = mapgen_helper.block_size
	
	if (YMAX+32+1)%block_size ~= 0 then
		local boundary = YMAX -(YMAX+32+1)%block_size
		minetest.log("warning", "[subterrane] The y_max setting "..tostring(YMAX)..
			" for cavern layer " .. cave_name .. " is not aligned with map chunk boundaries. Consider "..
			tostring(boundary) .. " or " .. tostring(boundary+block_size) .. " for maximum mapgen efficiency.")
	end
	if (YMIN+32)%block_size ~= 0 then
		local boundary = YMIN - (YMIN+32)%block_size
		minetest.log("warning", "[subterrane] The y_min setting "..tostring(YMIN)..
			" for cavern layer " .. cave_name .. " is not aligned with map chunk boundaries. Consider "..
			tostring(boundary) .. " or " .. tostring(boundary+block_size) .. " for maximum mapgen efficiency.")
	end

	local BLEND = math.min(cave_layer_def.boundary_blend_range, (YMAX-YMIN)/2)

	local TCAVE = cave_layer_def.cave_threshold
	local warren_area_threshold = cave_layer_def.warren_region_threshold -- determines how much volume warrens are found in around caverns
	local warren_area_variability_threshold = cave_layer_def.warren_region_variability_threshold -- determines how much of the warren_area_threshold volume actually has warrens in it
	local warren_threshold = cave_layer_def.warren_threshold -- determines narrowness of warrens themselves

	local solidify_lava = cave_layer_def.solidify_lava
	
	local np_cave = cave_layer_def.perlin_cave
	local np_wave = cave_layer_def.perlin_wave
	local np_warren_area = cave_layer_def.perlin_warren_area
	local np_warrens = cave_layer_def.perlin_warrens
	
	local y_blend_min = YMIN + BLEND * 1.5
	local y_blend_max = YMAX - BLEND * 1.5	
	
	local column_def = cave_layer_def.columns
	local c_column
	local c_warren_column

	if column_def then
		c_column = minetest.get_content_id(column_def.node)
		if column_def.warren_node then
			c_warren_column = minetest.get_content_id(column_def.warren_node)
		end
	end

	local double_frequency = cave_layer_def.double_frequency
		
	local decorate = cave_layer_def.decorate

	if subterrane_enable_singlenode_mapping_mode then
		decorate = nil
		c_column = c_air
		c_warren_column = nil
	end
	
	local is_ground_content = cave_layer_def.is_ground_content
	if is_ground_content == nil then
		is_ground_content = mapgen_helper.is_ground_content
	end
	
-- On generated
----------------------------------------------------------------------------------

minetest.register_on_generated(function(minp, maxp, seed)
	--if out of range of cave definition limits, abort
	if minp.y > YMAX or maxp.y < YMIN then
		return
	end
	t_start = os.clock()

	if c_lava_set == nil then
		c_lava_set = {}
		for name, def in pairs(minetest.registered_nodes) do
			if def.groups ~= nil and def.groups.lava ~= nil then
				c_lava_set[minetest.get_content_id(name)] = true
			end
		end
	end
	
	local vm, data, data_param2, area = mapgen_helper.mapgen_vm_data_param2()
	local emin = area.MinEdge
	local emax = area.MaxEdge
	local nvals_cave, cave_area = mapgen_helper.perlin3d("subterrane:cave", emin, emax, np_cave) --cave noise for structure
	local nvals_wave = mapgen_helper.perlin3d("subterrane:wave", emin, emax, np_wave) --wavy structure of cavern ceilings and floors

	-- pre-average everything so that the final values can be passed
	-- along to the decorate function if it wants them
	for vi, value in ipairs(nvals_cave) do
		nvals_cave[vi] = (value + nvals_wave[vi])/2
	end
	
	local warren_area_uninitialized = true
	local nvals_warren_area
	local warrens_uninitialized = true
	local nvals_warrens

	local previous_y = emin.y
	local previous_node_state = outside_region
	local this_node_state = outside_region
	
	local column_points = nil
	local column_weight = nil
	
	-- This information might be of use to the decorate function.
	cavern_data.contains_cavern = false
	cavern_data.contains_warren = false
	cavern_data.nvals_cave = nvals_cave
	cavern_data.cave_area = cave_area
	cavern_data.cavern_def = cave_layer_def
	
	-- The interp_yxz iterator iterates upwards in columns along the y axis.
	-- starts at miny, goes to maxy, then switches to a new x,z and repeats.
	for vi, x, y, z in area:iterp_yxz(emin, emax) do
		-- We're "over-generating" when carving out the empty space of the cave volume so that decorations
		-- can slop over the boundaries of the mapblock without being cut off.
		-- We only want to add vi to the various decoration node lists if we're actually within the mapblock.
		local is_within_current_mapblock = x >= minp.x and x <= maxp.x and y >= minp.y and y <= maxp.y and z >= minp.z and z <= maxp.z
		
		if y < previous_y then
			-- we've switched to a new column
			previous_node_state = outside_region
		else
			previous_node_state = this_node_state
		end
		previous_y = y
		this_node_state = inside_ground
			
		local cave_local_threshold
		if y < y_blend_min then
			cave_local_threshold = TCAVE + ((y_blend_min - y) / BLEND) ^ 2
		elseif y > y_blend_max then
			cave_local_threshold = TCAVE + ((y - y_blend_max) / BLEND) ^ 2
		else
			cave_local_threshold = TCAVE
		end

		local cave_value = nvals_cave[vi]
		if double_frequency then
			if cave_value < 0 then
				cave_value = -cave_value
				if subterrane_enable_singlenode_mapping_mode then
						c_cavern_air = c_desert_stone
						c_warren_air = c_sandstone
				end
			else
				if subterrane_enable_singlenode_mapping_mode then
						c_cavern_air = c_stone
						c_warren_air = c_clay
				end

			end			
		end
		
		-- inside a giant cavern
		if cave_value > cave_local_threshold then
			local column_value = 0
			if column_def then
				if column_points == nil then
					column_points = subterrane.get_column_points(emin, maxp, column_def)
					column_weight = column_def.weight
				end
				column_value = subterrane.get_column_value({x=x, y=y, z=z}, column_points)
			end
			
			if column_value > 0 and cave_value - column_value * column_weight < cave_local_threshold then
				-- only add column nodes if we're within the current mapblock because
				-- otherwise we're adding column nodes that the decoration loop won't know about
				if is_ground_content(data[vi]) and is_within_current_mapblock then
					data[vi] = c_column -- add a column node
				end
				this_node_state = inside_column
			else
				if is_ground_content(data[vi]) then
					data[vi] = c_cavern_air --hollow it out to make the cave
				end
				this_node_state = inside_cavern
				if is_within_current_mapblock then
					cavern_data.contains_cavern = true
				end
			end
		end
		
		-- If there's lava near the edges of the cavern, solidify it.
		if solidify_lava and cave_value > cave_local_threshold - 0.05 and c_lava_set[data[vi]] then
			data[vi] = c_obsidian
		end
			
		--borderlands of a giant cavern, possible warren area
		if cave_value <= cave_local_threshold and cave_value > warren_area_threshold then
		
			if warren_area_uninitialized then
				nvals_warren_area = mapgen_helper.perlin3d("subterrane:warren_area", emin, emax, np_warren_area) -- determine which areas are spongey with warrens
				warren_area_uninitialized = false
			end
			
			local warren_area_value = nvals_warren_area[vi]
			if warren_area_value > warren_area_variability_threshold then
				-- we're in a warren-containing area
				if solidify_lava and c_lava_set[data[vi]] then
					data[vi] = c_obsidian					
				end
				
				if warrens_uninitialized then
					nvals_warrens = mapgen_helper.perlin3d("subterrane:warrens", emin, emax, np_warrens) --spongey warrens
					warrens_uninitialized = false
				end
				
				-- we don't want warrens "cutting off" abruptly at the large-scale boundary noise thresholds, so turn these into gradients
				-- that can be applied to choke off the warren gradually.
				local cave_value_edge = math.min(1, (cave_value - warren_area_threshold) * 20) -- make 0.3 = 0 and 0.25 = 1 to produce a border gradient
				local warren_area_value_edge = math.min(1, warren_area_value * 50) -- make 0 = 0 and 0.02 = 1 to produce a border gradient
				
				local warren_value = nvals_warrens[vi]
				local warren_local_threshold = warren_threshold + (2 - warren_area_value_edge - cave_value_edge)
				if warren_value > warren_local_threshold then

					local column_value = 0
					if column_def then
						if column_points == nil then
							column_points = subterrane.get_column_points(emin, emax, column_def)
							column_weight = column_def.weight
						end
						column_value = subterrane.get_column_value({x=x, y=y, z=z}, column_points)
					end

					if column_value > 0 and column_value + (warren_local_threshold - warren_value) * column_weight > 0 then
						if c_warren_column then
							if is_ground_content(data[vi]) then
								data[vi] = c_warren_column -- add a column node
							end
							this_node_state = inside_column
						end
					else
						if is_ground_content(data[vi]) then
							data[vi] = c_warren_air --hollow it out to make the cave
						end
						if is_within_current_mapblock then
							cavern_data.contains_warren = true
						end
						this_node_state = inside_warren
					end
				end
			end
		end
		
		-- If decorate is defined, we want to track all this stuff
		if decorate ~= nil then
			local c_current_node = data[vi]
			local current_node_is_open = c_current_node == c_air -- mapgen_helper.buildable_to(c_current_node)
			if current_node_is_open and this_node_state == inside_ground then
				-- we're in a preexisting open space (tunnel).
				this_node_state = inside_tunnel
			end
			
			if is_within_current_mapblock then
				if this_node_state == inside_column then
					cavern_data.column_count = cavern_data.column_count + 1
					column_nodes[cavern_data.column_count] = vi
				elseif previous_node_state ~= this_node_state and previous_node_state ~= inside_column then
					if previous_node_state == inside_ground then
						if this_node_state == inside_tunnel then
							-- we just entered a tunnel from below.
							cavern_data.tunnel_floor_count = cavern_data.tunnel_floor_count + 1
							tunnel_floor_nodes[cavern_data.tunnel_floor_count] = vi-area.ystride
						elseif this_node_state == inside_cavern then
							-- we just entered the cavern from below
							cavern_data.cavern_floor_count = cavern_data.cavern_floor_count + 1
							cavern_floor_nodes[cavern_data.cavern_floor_count] = vi - area.ystride
						elseif this_node_state == inside_warren then
							-- we just entered the warren from below
							cavern_data.warren_floor_count = cavern_data.warren_floor_count + 1
							warren_floor_nodes[cavern_data.warren_floor_count] = vi - area.ystride
						end
					elseif this_node_state == inside_ground then
						if previous_node_state == inside_tunnel then
							-- we just left a tunnel from below
							cavern_data.tunnel_ceiling_count = cavern_data.tunnel_ceiling_count + 1
							tunnel_ceiling_nodes[cavern_data.tunnel_ceiling_count] = vi
						elseif previous_node_state == inside_cavern then
							--we just left the cavern from below
							cavern_data.cavern_ceiling_count = cavern_data.cavern_ceiling_count + 1
							cavern_ceiling_nodes[cavern_data.cavern_ceiling_count] = vi
						elseif previous_node_state == inside_warren then
							--we just left the cavern from below
							cavern_data.warren_ceiling_count = cavern_data.warren_ceiling_count + 1
							warren_ceiling_nodes[cavern_data.warren_ceiling_count] = vi
						end
					end
				end
			end
		end
	end
	
	if decorate then
		close_node_arrays() -- inserts nil after the last node so that ipairs will function correctly
		decorate(minp, maxp, seed, vm, cavern_data, area, data)
		clear_node_arrays() -- if decorate is not defined these arrays will never have anything added to them, so it's safe to not call this in that case
	end
	
	--send data back to voxelmanip
	vm:set_data(data)
	--calc lighting
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:update_liquids()
	--write it to world
	vm:write_to_map()
	
	local time_taken = os.clock() - t_start -- how long this chunk took, in seconds
	mapgen_helper.record_time(cave_name, time_taken)
end)

end

local last_check = os.clock()
minetest.register_globalstep(function(dtime)
	local current_time = os.clock()
	local threshold = t_start + 60
	if last_check < threshold and current_time > threshold then
		-- It's been 60 seconds since we last generated a cavern, release the memory the cavern arrays are being stored in.
		initialize_node_arrays()
	end
	last_check = current_time
end)

minetest.log("info", "[Subterrane] loaded!")
