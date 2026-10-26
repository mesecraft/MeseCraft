local c_water = df_caverns.node_id.water
local c_air = df_caverns.node_id.air
local c_desert_sand = df_caverns.node_id.desert_sand
local c_stone_with_coal = df_caverns.node_id.stone_with_coal
local c_silver_sand = df_caverns.node_id.silver_sand
local c_snow = df_caverns.node_id.snow
local c_ice = df_caverns.node_id.ice
local c_hoar_moss = df_caverns.node_id.hoar_moss
local c_gravel = df_caverns.node_id.gravel
local c_oil = df_caverns.node_id.oil
local c_cobble_fungus_fine = df_caverns.node_id.cobble_fungus_fine
local c_cobble_fungus = df_caverns.node_id.cobble_fungus
local c_cobble = df_caverns.node_id.cobble
local c_wet_flowstone = df_caverns.node_id.wet_flowstone
local c_dry_flowstone = df_caverns.node_id.dry_flowstone
local c_glow_ore = df_caverns.node_id.glow_ore
local c_salty_cobble = df_caverns.node_id.salty_cobble
local c_salt_crystal = df_caverns.node_id.salt_crystal
local c_sprite = df_caverns.node_id.sprite
local c_webs_egg = df_caverns.node_id.big_webs_egg

local chasms_path = minetest.get_modpath("chasms")

local log_location
if mapgen_helper.log_location_enabled then
	log_location = mapgen_helper.log_first_location
end

local subsea_level = math.floor(df_caverns.config.level3_min - (df_caverns.config.level3_min - df_caverns.config.level2_min) * 0.33)
local flooding_threshold = math.min(df_caverns.config.tunnel_flooding_threshold, df_caverns.config.cavern_threshold)

local ice_thickness = 3

local get_biome = function(heat, humidity)
	if humidity < 23 then -- about 20% of locations fall below this threshold
		return "barren"
	elseif heat < 50 then
		return "blackcap"
	else
		return "bloodnether"
	end
end

df_caverns.register_biome_check(function(pos, heat, humidity)
	if pos.y < df_caverns.config.level3_min or pos.y >= df_caverns.config.level2_min then
		return nil
	end
	local biome = get_biome(heat, humidity)
	if biome == "bloodnether" then
		local cavern_value = subterrane.get_cavern_value("cavern layer 3", pos)
		if cavern_value == nil then
			-- this shouldn't happen, the pos.y check above should prevent it.
			return nil
		end
		if cavern_value < 0 then
			return "nethercap"
		end
		return "bloodthorn"
	end
	return biome
end)

local black_cap_shrublist
local nether_cap_shrublist
local blood_thorn_shrublist

if minetest.get_modpath("df_farming") then
	black_cap_shrublist = {
		df_farming.spawn_dead_fungus_vm,
	}
	nether_cap_shrublist = {
		df_farming.spawn_dead_fungus_vm,
		df_farming.spawn_dead_fungus_vm,
		df_farming.spawn_dead_fungus_vm,
		df_farming.spawn_cavern_fungi_vm,
	}
	blood_thorn_shrublist = {
		df_farming.spawn_quarry_bush_vm,
		df_farming.spawn_dead_fungus_vm,
		df_farming.spawn_dead_fungus_vm,
	}
end

local hoar_moss_perlin_params = {
	offset = 0,
	scale = 1,
	spread = {x = 3, y = 30, z = 3},
	seed = 345421,
	octaves = 3,
	persist = 0.63,
	lacunarity = 2.0,
	flags = "eased",
}

local black_cap_cavern_floor = function(abs_cracks, vert_rand, vi, area, data, data_param2)
	if math.random() < 0.25 then
		data[vi] = c_stone_with_coal
	else
		data[vi] = c_cobble_fungus
	end
	
	if abs_cracks < 0.1 then
		df_caverns.stalagmites(abs_cracks, vert_rand, vi, area, data, data_param2, false)
	elseif abs_cracks < 0.15 and math.random() < 0.3 then
		df_trees.spawn_torchspine_vm(vi+area.ystride, area, data, data_param2)
	else
		if math.random() < 0.05 then
			df_caverns.place_shrub(vi+area.ystride, area, data, data_param2, black_cap_shrublist)
		elseif math.random() < 0.01 and abs_cracks > 0.25 then
			df_trees.spawn_black_cap_vm(vi+area.ystride, area, data)
		end
	end
end

local nether_cap_cavern_floor = function(cracks, abs_cracks, vert_rand, vi, area, data, data_param2)
	local ystride = area.ystride
	if abs_cracks < 0.1 then
		if vert_rand < 0.004 then
			subterrane.big_stalagmite(vi+ystride, area, data, 6, 15, c_ice, c_ice, c_ice)
		else
			local param2 = abs_cracks*1000000 - math.floor(abs_cracks*1000000/4)*4
			local height = abs_cracks * 50
			if vert_rand > 0.5 then
				subterrane.stalagmite(vi+ystride, area, data, data_param2, param2, math.floor(height), df_mapitems.icicle_ids)
			else
				subterrane.stalagmite(vi+ystride, area, data, data_param2, param2, math.floor(height*0.5), df_mapitems.dry_stalagmite_ids)
			end
		end
	end
	
	if cracks < -0.3 then
		data[vi] = c_silver_sand
		if  math.random() < 0.025 then
			df_trees.spawn_nether_cap_vm(vi+ystride, area, data)
		elseif math.random() < 0.05 then
			df_caverns.place_shrub(vi+ystride, area, data, data_param2, nether_cap_shrublist)
		elseif cracks < -0.4 and cracks > -0.6 then
			data[vi + ystride] = c_snow
		end
	elseif cracks > 0.1 then
		if math.random() < 0.002 then
			df_trees.spawn_nether_cap_vm(vi+ystride, area, data)
		else
			data[vi] = c_ice
		end
		if cracks > 0.4 then
			data[vi + ystride] = c_ice
			if cracks > 0.6 then
				data[vi + 2*ystride] = c_ice
			end
		end
	end	
end

local nether_cap_cavern_ceiling = function(abs_cracks, vert_rand, vi, area, data, data_param2)
	local ystride = area.ystride
	if abs_cracks < 0.1 then
		if vert_rand < 0.01 then
			subterrane.big_stalactite(vi-ystride, area, data, 6, 15, c_ice, c_ice, c_ice)
		else
			local param2 = abs_cracks*1000000 - math.floor(abs_cracks*1000000/4)*4
			local height = abs_cracks * 50
			if vert_rand > 0.5 then
				subterrane.stalactite(vi-ystride, area, data, data_param2, param2, math.floor(height), df_mapitems.icicle_ids)
			else
				subterrane.stalactite(vi-ystride, area, data, data_param2, param2, math.floor(height*0.5), df_mapitems.dry_stalagmite_ids)
			end
		end
	end	
	if c_sprite and abs_cracks < 0.5 and math.random() < 0.02 then
		local sprite_vi = vi-ystride*math.random(1,5)
		if data[sprite_vi] == c_air and area:containsi(sprite_vi) then
			data[sprite_vi] = c_sprite
			minetest.get_node_timer(area:position(sprite_vi)):start(1)
		end
	end
end

local blood_thorn_cavern_floor = function(abs_cracks, vert_rand, vi, area, data, data_param2)
	local ai = vi+area.ystride

	if abs_cracks < 0.075 then
		if vert_rand < 0.004 then
			subterrane.big_stalagmite(ai, area, data, 6, 15, c_dry_flowstone, c_dry_flowstone, c_dry_flowstone)
		elseif data[vi] ~= c_air and math.random() < 0.5 then
			data[vi] = c_salty_cobble
			if data[ai] == c_air and math.random() < 0.25 then
				data[ai] = c_salt_crystal
				data_param2[ai] = math.random(1,4)-1
			end
		else
			local param2 = abs_cracks*1000000 - math.floor(abs_cracks*1000000/4)*4
			local height = math.floor(abs_cracks * 66)
			subterrane.stalagmite(ai, area, data, data_param2, param2, height, df_mapitems.dry_stalagmite_ids)
		end
	elseif math.random() > abs_cracks + 0.66 then
		df_trees.spawn_blood_thorn_vm(ai, area, data, data_param2)
		data[vi] = c_desert_sand
	else
		if math.random() < 0.1 then
			df_caverns.place_shrub(ai, area, data, data_param2, blood_thorn_shrublist)
			data[vi] = c_desert_sand
		elseif math.random() > 0.25 then
			data[vi] = c_desert_sand
		else
			data[vi] = c_cobble
		end
	end
end

local hoar_moss_generator

local decorate_level_3 = function(minp, maxp, seed, vm, node_arrays, area, data)
	math.randomseed(minp.x + minp.y*2^8 + minp.z*2^16 + seed) -- make decorations consistent between runs

	local heatmap = minetest.get_mapgen_object("heatmap")
	local humiditymap = minetest.get_mapgen_object("humiditymap")
	local data_param2 = df_caverns.data_param2
	vm:get_param2_data(data_param2)
	local nvals_cracks = mapgen_helper.perlin2d("df_cavern:cracks", minp, maxp, df_caverns.np_cracks)
	local nvals_cave = node_arrays.nvals_cave
	local cave_area = node_arrays.cave_area
	local cavern_def = node_arrays.cavern_def
	
	-- Partly fill flooded caverns and warrens
	if minp.y <= subsea_level then
		for vi, x, y, z in area:iterp_yxz(area.MinEdge, area.MaxEdge) do
			local cave = nvals_cave[vi]
			if y <= subsea_level and cave < -flooding_threshold then
				if data[vi] == c_air and y <= subsea_level then
					data[vi] = c_water
				end
				
				if x >= minp.x and x <= maxp.x and y >= minp.y and y <= maxp.y and z >= minp.z and z <= maxp.z then				
					local index2d = mapgen_helper.index2di(minp, maxp, area, vi)
					local biome_name = get_biome(heatmap[index2d], humiditymap[index2d])
					if biome_name == "blackcap" then
						-- oil slick
						if y == subsea_level and data[vi] == c_water and math.abs(cave) + nvals_cracks[index2d]*0.025 < cavern_def.cave_threshold + 0.1 then
							data[vi] = c_oil
							if log_location then log_location("level3_blackcap_oil", vector.new(x,y,z)) end
						end
					elseif biome_name == "bloodnether" and y <= subsea_level and y > subsea_level - ice_thickness and data[vi] == c_water then
						-- floating ice
						data[vi] = c_ice
						if log_location then log_location("level3_nethercap_floating_ice", vector.new(x,y,z)) end
					end
				end
			end
		end
	end
	
	---------------------------------------------------------
	-- Cavern floors
	
	for _, vi in ipairs(node_arrays.cavern_floor_nodes) do
		local vert_rand = mapgen_helper.xz_consistent_randomi(area, vi)
		local index2d = mapgen_helper.index2di(minp, maxp, area, vi)
		local biome_name = get_biome(heatmap[index2d], humiditymap[index2d])
		local cracks = nvals_cracks[index2d]
		local abs_cracks = math.abs(cracks)
		local flooded_caverns = nvals_cave[vi] < 0 -- this indicates if we're in the "flooded" set of caves or not.

		if flooded_caverns and minp.y < subsea_level and area:get_y(vi) < subsea_level then
			-- underwater floor. Not using df_caverns.flooded_cavern_floor to make level 3 water darker
			local ystride = area.ystride
			if abs_cracks > 0.25 and data[vi-ystride] ~= c_water then
				data[vi] = c_gravel
			end
			-- put in only the large stalagmites that won't get in the way of the water
			if abs_cracks < 0.1 then
				if vert_rand < 0.004 then
					subterrane.big_stalagmite(vi+ystride, area, data, 6, 15, c_wet_flowstone, c_wet_flowstone, c_wet_flowstone)
				end
			end
			if log_location then log_location("level3_flooded_"..biome_name, area:position(vi)) end
		elseif biome_name == "barren" then
			if flooded_caverns then
				-- wet zone floor
				df_caverns.dry_cavern_floor(abs_cracks, vert_rand, vi, area, data, data_param2)
				if log_location then log_location("level3_barren_dry", area:position(vi)) end
			else
				-- dry zone floor, add crystals
				if abs_cracks < 0.075 then
					df_caverns.stalagmites(abs_cracks, vert_rand, vi, area, data, data_param2, false)
				elseif abs_cracks > 0.3 and math.random() < 0.005 then
					df_mapitems.place_big_crystal_cluster(area, data, data_param2, vi+area.ystride,  math.random(0,2), false)
				end
				if log_location then log_location("level3_barren_wet", area:position(vi)) end
			end
		elseif biome_name == "blackcap" then
			black_cap_cavern_floor(abs_cracks, vert_rand, vi, area, data, data_param2)
			if log_location then log_location("level3_blackcap", area:position(vi)) end
		elseif biome_name == "bloodnether" then
			if flooded_caverns then
				nether_cap_cavern_floor(cracks, abs_cracks, vert_rand, vi, area, data, data_param2)				
				if log_location then log_location("level3_nethercap", area:position(vi)) end
			else
				blood_thorn_cavern_floor(abs_cracks, vert_rand, vi, area, data, data_param2)		
				if log_location then log_location("level3_bloodthorn", area:position(vi)) end
			end
		end
	end
	
	--------------------------------------
	-- Cavern ceilings

	for _, vi in ipairs(node_arrays.cavern_ceiling_nodes) do
		local vert_rand = mapgen_helper.xz_consistent_randomi(area, vi)
		local index2d = mapgen_helper.index2di(minp, maxp, area, vi)
		local biome_name = get_biome(heatmap[index2d], humiditymap[index2d])
		local abs_cracks = math.abs(nvals_cracks[index2d])
		local flooded_caverns = nvals_cave[vi] < 0 -- this indicates if we're in the "flooded" set of caves or not.

		if flooded_caverns and minp.y < subsea_level and area:get_y(vi) < subsea_level then
			-- underwater ceiling, do nothing

		elseif biome_name == "blackcap" then
			if abs_cracks < 0.1 then
				df_caverns.stalactites(abs_cracks, vert_rand, vi, area, data, data_param2, false)
			end	
			if math.random() < 0.25 then
				data[vi] = c_stone_with_coal
			end

		elseif biome_name == "barren" then
			if flooded_caverns then
				-- wet zone ceiling
				if abs_cracks < 0.1 then
					df_caverns.stalactites(abs_cracks, vert_rand, vi, area, data, data_param2, true)
				end
			else
				-- dry zone ceiling, add crystals
				if abs_cracks < 0.1 then
					df_caverns.stalactites(abs_cracks, vert_rand, vi, area, data, data_param2, false)
				end
				if abs_cracks > 0.3 and math.random() < 0.005 then
					df_mapitems.place_big_crystal_cluster(area, data, data_param2, vi, math.random(0,3), true)
				end
			end

		elseif biome_name == "bloodnether" then
			if flooded_caverns then
				--Nethercap ceiling
				nether_cap_cavern_ceiling(abs_cracks, vert_rand, vi, area, data, data_param2)
			else
				-- bloodthorn ceiling
				if abs_cracks < 0.075 then
					if data[vi] ~= c_air and math.random() < 0.5 then
						data[vi] = c_salty_cobble
						local bi = vi - area.ystride
						if data[bi] == c_air and math.random() < 0.25 then
							data[bi] = c_salt_crystal
							data_param2[bi] = 19 + math.random(1,4)
						end
					else
						df_caverns.stalactites(abs_cracks, vert_rand, vi, area, data, data_param2, false)
					end
				elseif abs_cracks > 0.75 and math.random() < 0.05 then
					data[vi] = c_glow_ore
					df_mapitems.place_big_crystal(data, data_param2, vi-area.ystride, true)
				end
			end
		end
	end
	

	----------------------------------------------
	-- Tunnel floors

	for _, vi in ipairs(node_arrays.tunnel_floor_nodes) do
		local index2d = mapgen_helper.index2di(minp, maxp, area, vi)
		local biome_name = get_biome(heatmap[index2d], humiditymap[index2d])
		local flooded_caverns = nvals_cave[vi] < 0 -- this indicates if we're in the "flooded" set of caves or not.

		if not (flooded_caverns and minp.y < subsea_level and area:get_y(vi) < subsea_level) then
			if flooded_caverns or biome_name == "blackcap" then		
				-- we're in flooded areas or are not barren
				df_caverns.tunnel_floor(minp, maxp, area, vi, nvals_cracks, data, data_param2, true)
			else
				df_caverns.tunnel_floor(minp, maxp, area, vi, nvals_cracks, data, data_param2, false, c_gravel)
			end
		end
	end
	
	------------------------------------------------------
	-- Tunnel ceiling
	
	for _, vi in ipairs(node_arrays.tunnel_ceiling_nodes) do
		local index2d = mapgen_helper.index2di(minp, maxp, area, vi)
		local humidity = humiditymap[index2d]
		local biome_name = get_biome(heatmap[index2d], humidity)
		local flooded_caverns = nvals_cave[vi] < 0 -- this indicates if we're in the "flooded" set of caves or not.
		local ystride = area.ystride
		
		if not (flooded_caverns and minp.y < subsea_level and area:get_y(vi) < subsea_level) then
			if flooded_caverns or biome_name == "blackcap" then
				-- we're in flooded areas or are not barren
				df_caverns.tunnel_ceiling(minp, maxp, area, vi, nvals_cracks, data, data_param2, true)
			else
				df_caverns.tunnel_ceiling(minp, maxp, area, vi, nvals_cracks, data, data_param2, false)
			end
			if c_webs_egg and humidity < 40 and nvals_cracks[index2d] > 0.5 and math.random() < 0.1 then
				local index = vi-ystride
				if data[index] == c_air then
					data[index] = c_webs_egg
					minetest.get_node_timer(area:position(index)):start(1)
				end
			end
		else
			-- air pockets
			local cracks = nvals_cracks[index2d]
			if cracks > 0.5 and data[vi-ystride] == c_water then
				data[vi-ystride] = c_air
				if cracks > 0.7 and data[vi-ystride*2] == c_water then
					data[vi-ystride*2] = c_air
				end
			end			
		end
	end

	
	------------------------------------------------------
	-- Warren ceiling

	for _, vi in ipairs(node_arrays.warren_ceiling_nodes) do
		local index2d = mapgen_helper.index2di(minp, maxp, area, vi)
		local biome_name = get_biome(heatmap[index2d], humiditymap[index2d])
		local flooded_caverns = nvals_cave[vi] < 0 -- this indicates if we're in the "flooded" set of caves or not.
		
		if log_location then
			local flood_name = ""
			if flooded_caverns then flood_name = "_flooded" end
			log_location("level3_warren_"..biome_name..flood_name, area:position(vi))
		end
		
		if flooded_caverns and minp.y < subsea_level and area:get_y(vi) < subsea_level then
			-- underwater ceiling, do nothing
		elseif biome_name == "bloodnether" and flooded_caverns then
			-- Nethercap warrens
			local cracks = nvals_cracks[index2d]
			local abs_cracks = math.abs(cracks)
			local vert_rand = mapgen_helper.xz_consistent_randomi(area, vi)
			local ystride = area.ystride
			if abs_cracks < 0.15 then
				if vert_rand < 0.004 then
					subterrane.big_stalactite(vi-ystride, area, data, 6, 15, c_ice, c_ice, c_ice)
				else
					local param2 = abs_cracks*1000000 - math.floor(abs_cracks*1000000/4)*4
					local height = abs_cracks * 50
					if vert_rand > 0.5 then
						subterrane.stalactite(vi-ystride, area, data, data_param2, param2, math.floor(height), df_mapitems.icicle_ids)
					else
						subterrane.stalactite(vi-ystride, area, data, data_param2, param2, math.floor(height*0.5), df_mapitems.dry_stalagmite_ids)
					end
				end
			end
		else
			if flooded_caverns or biome_name == "blackcap" then
				df_caverns.tunnel_ceiling(minp, maxp, area, vi, nvals_cracks, data, data_param2, true)
			else
				df_caverns.tunnel_ceiling(minp, maxp, area, vi, nvals_cracks, data, data_param2, false)
			end
		end
	end

	----------------------------------------------
	-- Warren floors
	
	for _, vi in ipairs(node_arrays.warren_floor_nodes) do
		local index2d = mapgen_helper.index2di(minp, maxp, area, vi)
		local biome_name = get_biome(heatmap[index2d], humiditymap[index2d])
		local flooded_caverns = nvals_cave[vi] < 0 -- this indicates if we're in the "flooded" set of caves or not.
		
		if minp.y < subsea_level and area:get_y(vi) < subsea_level and flooded_caverns then
			-- underwater floor, do nothing
		elseif biome_name == "bloodnether" and flooded_caverns then
			-- nethercap warren
			local cracks = nvals_cracks[index2d]
			local abs_cracks = math.abs(cracks)
			local vert_rand = mapgen_helper.xz_consistent_randomi(area, vi)
			local ystride = area.ystride
			if abs_cracks < 0.15 then
				if vert_rand < 0.004 then
					subterrane.big_stalagmite(vi+ystride, area, data, 6, 15, c_ice, c_ice, c_ice)
				else
					local param2 = abs_cracks*1000000 - math.floor(abs_cracks*1000000/4)*4
					local height =abs_cracks * 50
					if vert_rand > 0.5 then
						subterrane.stalagmite(vi+ystride, area, data, data_param2, param2, math.floor(height), df_mapitems.icicle_ids)
					else
						subterrane.stalagmite(vi+ystride, area, data, data_param2, param2, math.floor(height*0.5), df_mapitems.dry_stalagmite_ids)
					end
				end
			elseif cracks > 0.4 then
				data[vi + ystride] = c_ice
				if cracks > 0.6 then
					data[vi + 2*ystride] = c_ice
				end
			end
		else
			if flooded_caverns or biome_name == "blackcap" then
				df_caverns.tunnel_floor(minp, maxp, area, vi, nvals_cracks, data, data_param2, true)
			else
				df_caverns.tunnel_floor(minp, maxp, area, vi, nvals_cracks, data, data_param2, false, c_gravel)
			end
		end
	end
	
	----------------------------------------------
	-- Column material override for dry and icy biomes
	for _, vi in ipairs(node_arrays.column_nodes) do
		local index2d = mapgen_helper.index2di(minp, maxp, area, vi)
		local biome_name = get_biome(heatmap[index2d], humiditymap[index2d])
		local flooded_caverns = nvals_cave[vi] < 0

		if biome_name == "bloodnether" and data[vi] == c_wet_flowstone then
			if not flooded_caverns then
				data[vi] = c_dry_flowstone -- bloodthorn
			else
				if area:get_y(vi) > subsea_level - ice_thickness then
					if data[vi + 1] == c_air or data[vi - 1] == c_air or data[vi + area.zstride] == c_air or data[vi - area.zstride] == c_air then
						--surface node, potential hoar moss streak
						-- This particular Perlin noise is only called in small amounts on rare occasions, so don't bother
						-- with the full blown generated array rigamarole.
						hoar_moss_generator = hoar_moss_generator or minetest.get_perlin(hoar_moss_perlin_params)
						local pos = area:position(vi)
						if hoar_moss_generator:get_3d({x=pos.z, y=pos.y, z=pos.x}) > 0.5 then
							data[vi] = c_hoar_moss
						else
							data[vi] = c_ice
						end
					else
						data[vi] = c_ice
					end
				else
					data[vi] = c_water -- ice columns shouldn't extend below the surface of the water. There should probably be a bulge below, though. Not sure best way to implement that.
				end
			end
		elseif biome_name == "barren" and not flooded_caverns and data[vi] == c_wet_flowstone then
			data[vi] = c_dry_flowstone
		end
		
		if chasms_path then
			local pos = area:position(vi)
			if chasms.is_in_chasm_without_taper(pos) then
				if flooded_caverns and pos.y < subsea_level then
					data[vi] = c_water -- this puts a crack in the ice of icy biomes, but why not? A crack in the ice is interesting.
				else
					data[vi] = c_air
				end
			end
		end

		
	end

	vm:set_param2_data(data_param2)
end

-- Layer 3
subterrane.register_layer({
	name = "cavern layer 3",
	y_max = df_caverns.config.level2_min-1,
	y_min = df_caverns.config.level3_min,
	cave_threshold = df_caverns.config.cavern_threshold,
	boundary_blend_range = 64, -- range near ymin and ymax over which caves diminish to nothing
	perlin_cave = df_caverns.perlin_cave,
	perlin_wave = df_caverns.perlin_wave,
	solidify_lava = true,
	columns = {
		maximum_radius = 20,
		minimum_radius = 5,
		node = "df_mapitems:wet_flowstone",
		weight = 0.25,
		maximum_count = 50,
		minimum_count = 10,
	},
	decorate = decorate_level_3,
	warren_region_variability_threshold = 0.33,
	double_frequency = true,
	is_ground_content = df_caverns.is_ground_content,
})
