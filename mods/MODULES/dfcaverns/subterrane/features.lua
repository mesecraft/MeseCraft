local c_air = minetest.get_content_id("air")

---------------------------------------------------------------------------
-- For registering a set of stalactite/stalagmite nodes to use with the small stalactite placement function below

local x_disp = 0.125
local z_disp = 0.125

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
	minetest.add_node(pt.above, {name = itemstack:get_name(), param2 = new_param2})
	if not minetest.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item()
	end
	return itemstack
end

local stal_box_1 = {{-0.0625+x_disp, -0.5, -0.0625+z_disp, 0.0625+x_disp, 0.5, 0.0625+z_disp}}
local stal_box_2 = {{-0.125+x_disp, -0.5, -0.125+z_disp, 0.125+x_disp, 0.5, 0.125+z_disp}}
local stal_box_3 = {{-0.25+x_disp, -0.5, -0.25+z_disp, 0.25+x_disp, 0.5, 0.25+z_disp}}
local stal_box_4 = {{-0.375+x_disp, -0.5, -0.375+z_disp, 0.375+x_disp, 0.5, 0.375+z_disp}}

-- Note that a circular table reference will result in a crash, TODO: guard against that.
-- Unlikely to be needed, though - it'd take a lot of work for users to get into this bit of trouble.
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

subterrane.register_stalagmite_nodes = function(base_name, base_node_def, drop_base_name)
	base_node_def.groups = base_node_def.groups or {}
	base_node_def.groups.subterrane_stal_align = 1
	base_node_def.groups.flow_through = 1
	base_node_def.drawtype = "nodebox"
	base_node_def.paramtype = "light"
	base_node_def.paramtype2 = "facedir"
	base_node_def.node_box = {type = "fixed"}
	
	local def1 = deep_copy(base_node_def)
	def1.groups.fall_damage_add_percent = 100
	def1.node_box.fixed = stal_box_1
	def1.on_place = stal_on_place
	if drop_base_name then
		def1.drop = drop_base_name.."_1"
	end
	-- Size suffix so the four sizes can be told apart (and sorted) by name.
	def1.description = def1.description and (def1.description .. " (size 1)")
	minetest.register_node(base_name.."_1", def1)

	local def2 = deep_copy(base_node_def)
	def2.groups.fall_damage_add_percent = 50
	def2.node_box.fixed = stal_box_2
	def2.on_place = stal_on_place
	if drop_base_name then
		def2.drop = drop_base_name.."_2"
	end
	def2.description = def2.description and (def2.description .. " (size 2)")
	minetest.register_node(base_name.."_2", def2)

	local def3 = deep_copy(base_node_def)
	def3.node_box.fixed = stal_box_3
	def3.on_place = stal_on_place
	if drop_base_name then
		def3.drop = drop_base_name.."_3"
	end
	def3.description = def3.description and (def3.description .. " (size 3)")
	minetest.register_node(base_name.."_3", def3)

	local def4 = deep_copy(base_node_def)
	def4.node_box.fixed = stal_box_4
	def4.on_place = stal_on_place
	if drop_base_name then
		def4.drop = drop_base_name.."_4"
	end
	def4.description = def4.description and (def4.description .. " (size 4)")
	minetest.register_node(base_name.."_4", def4)
	
	return {
		minetest.get_content_id(base_name.."_1"),
		minetest.get_content_id(base_name.."_2"),
		minetest.get_content_id(base_name.."_3"),
		minetest.get_content_id(base_name.."_4"),
	}
end

-------------------------------------------------------------------------------------------------
-- Use with stalactite nodes defined above

-- stalagmite_id is a table of the content ids of the four stalagmite sections, from _1 to _4.
function subterrane.stalagmite(vi, area, data, param2_data, param2, height, stalagmite_id)
	if height == nil then height = math.random(1,4) end
	if param2 == nil then param2 = math.random(0,3) end
	
	local sign, id_modifier
	if height > 0 then
		sign = 1
		id_modifier = 1 -- stalagmites are blunter than stalactites
	else
		sign = -1
		id_modifier = 0
	end
	
	for i = 1, math.abs(height) do
		local svi = vi + (height - i * sign) * area.ystride
		if data[svi] == c_air then -- test for air because we don't want these poking into water
			data[svi] = stalagmite_id[math.min(i+id_modifier,4)]
			param2_data[svi] = param2
		end
	end	
end

function subterrane.stalactite(vi, area, data, param2_data, param2, height, stalagmite_id)
	subterrane.stalagmite(vi, area, data, param2_data, param2, -height, stalagmite_id)
end

-------------------------------------------------------------------------------------------------
-- Builds very large stalactites and stalagmites

--giant stalagmite spawner
function subterrane.big_stalagmite(vi, area, data, min_height, max_height, base_material, root_material, shaft_material)
	local pos = area:position(vi)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	local top = math.random(min_height,max_height)
	for j = -2, top do --y
		for k = -3, 3 do
			for l = -3, 3 do
				if j <= 0 then
					if k*k + l*l <= 9 then
						local vi = area:index(x+k, y+j, z+l)
						if mapgen_helper.buildable_to(data[vi]) then data[vi] = base_material end
					end
				elseif j <= top/5 then
					if k*k + l*l <= 4 then
						local vi = area:index(x+k, y+j, z+l)
						data[vi] = root_material
					end
				elseif j <= top/5 * 3 then
					if k*k + l*l <= 1 then
						local vi = area:index(x+k, y+j, z+l)
						data[vi] = shaft_material
					end
				else
					local vi = area:index(x, y+j, z)
					data[vi] = shaft_material
				end
			end
		end
	end
end

--giant stalactite spawner
function subterrane.big_stalactite(vi, area, data, min_height, max_height, base_material, root_material, shaft_material)
	local pos = area:position(vi)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	local bot = math.random(-max_height, -min_height) --grab a random height for the stalagmite
	for j = bot, 2 do --y
		for k = -3, 3 do
			for l = -3, 3 do
				if j >= -1 then
					if k*k + l*l <= 9 then
						local vi = area:index(x+k, y+j, z+l)
						if mapgen_helper.buildable_to(data[vi]) then data[vi] = base_material end
					end
				elseif j >= bot/5 then
					if k*k + l*l <= 4 then
						local vi = area:index(x+k, y+j, z+l)
						data[vi] = root_material
					end
				elseif j >= bot/5 * 3 then
					if k*k + l*l <= 1 then
						local vi = area:index(x+k, y+j, z+l)
						data[vi] = shaft_material
					end
				else
					local vi = area:index(x, y+j, z)
					data[vi] = shaft_material
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------
-- Giant mushrooms

--function to create giant 'shrooms. Cap radius works well from about 2-6
--if ignore_bounds is true this function will place the mushroom even if it overlaps the edge of the voxel area.
function subterrane.giant_mushroom(vi, area, data, stem_material, cap_material, gill_material, stem_height, cap_radius, ignore_bounds)

	if not ignore_bounds and 
		not (area:containsi(vi - cap_radius - area.zstride*cap_radius) and 
		area:containsi(vi + cap_radius + stem_height*area.ystride + area.zstride*cap_radius)) then
			return false -- mushroom overlaps the bounds of the voxel area, abort.
	end

	local pos = area:position(vi)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	--cap
	for k = -cap_radius, cap_radius do
	for l = -cap_radius, cap_radius do
		if k*k + l*l <= cap_radius*cap_radius then
			local vi = area:index(x+k, y+stem_height, z+l)
			if mapgen_helper.buildable_to(data[vi]) then data[vi] = cap_material end
		end
		if k*k + l*l <= (cap_radius-1)*(cap_radius-1) and (cap_radius-1) > 0 then
			local vi = area:index(x+k, y+stem_height+1, z+l)
			data[vi] = cap_material
			vi = area:index(x+k, y+stem_height, z+l)
			if data[vi] == cap_material then data[vi] = gill_material end
		end
		if k*k + l*l <= (cap_radius-2)*(cap_radius-2) and (cap_radius-2) > 0 then
			local vi = area:index(x+k, y+stem_height+2, z+l)
			if mapgen_helper.buildable_to(data[vi]) then data[vi] = cap_material end
		end
		if k*k + l*l <= (cap_radius-3)*(cap_radius-3) and (cap_radius-3) > 0 then
			local vi = area:index(x+k, y+stem_height+3, z+l)
			if mapgen_helper.buildable_to(data[vi]) then data[vi] = cap_material end
		end
	end
	end
	--stem
	for j = -2, stem_height do -- going down to -2 to ensure the stem is flush with the ground
		local vi = area:index(x, y+j, z)
		if j >= 0 or area:containsi(vi) then -- since -2 puts us below the bounds we've already tested, add a contains check here.
			if mapgen_helper.buildable_to(data[vi]) or data[vi] == gill_material then data[vi] = stem_material end
			if cap_radius > 3 then
				local ai = area:index(x, y+j, z+1)
				if mapgen_helper.buildable_to(data[ai]) or data[ai] == gill_material then data[ai] = stem_material end
				ai = area:index(x, y+j, z-1)
				if mapgen_helper.buildable_to(data[ai]) or data[ai] == gill_material then data[ai] = stem_material end
				ai = area:index(x+1, y+j, z)
				if mapgen_helper.buildable_to(data[ai]) or data[ai] == gill_material then data[ai] = stem_material end
				ai = area:index(x-1, y+j, z)
				if mapgen_helper.buildable_to(data[ai]) or data[ai] == gill_material then data[ai] = stem_material end
			end
		end
	end
	return true
end