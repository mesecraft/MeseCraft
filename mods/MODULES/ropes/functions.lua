ropes.make_rope_on_timer = function(rope_node_name)
	return function(pos, elapsed)
		local currentend = minetest.get_node(pos)
		local currentmeta = minetest.get_meta(pos)
		local currentlength = currentmeta:get_int("length_remaining")
		local placer_name = currentmeta:get_string("placer")
		local newpos = {x=pos.x, y=pos.y-1, z=pos.z}
		local newnode = minetest.get_node(newpos)
		local oldnode = minetest.get_node(pos)
		if currentlength > 1 and (not minetest.is_protected(newpos, placer_name)
		or minetest.check_player_privs(placer_name, "protection_bypass")) then
			if  newnode.name == "air" then
				minetest.add_node(newpos, {name=currentend.name, param2=oldnode.param2})
				local newmeta = minetest.get_meta(newpos)
				newmeta:set_int("length_remaining", currentlength-1)
				newmeta:set_string("placer", placer_name)
				minetest.set_node(pos, {name=rope_node_name, param2=oldnode.param2})
				ropes.move_players_down(pos, 1)
			else
				local timer = minetest.get_node_timer( pos )
				timer:start( 1 )
			end
		end
	end
end

local data = {}
local c_air = minetest.get_content_id("air")

ropes.destroy_rope = function(pos, nodes)
	local top = pos.y
	local bottom = pos.y-15
	local voxel_manip = minetest.get_voxel_manip()

	local finished = false
	local ids_to_destroy = {}
	for _, node in pairs(nodes) do
		ids_to_destroy[minetest.get_content_id(node)] = true
	end
	
	while not finished do
		local emin, emax = voxel_manip:read_from_map({x=pos.x, y=bottom, z=pos.z}, {x=pos.x, y=top, z=pos.z})
		voxel_manip:get_data(data)
		local voxel_area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		bottom = emin.y			
		for y = top, bottom, -1 do
			local index = voxel_area:index(pos.x, y, pos.z)
			if ids_to_destroy[data[index]] then
				data[index] = c_air
			else
				finished = true
				break
			end
		end
		voxel_manip:set_data(data)
		voxel_manip:write_to_map()
		voxel_manip:update_map()
		top = bottom - 1
		bottom = bottom - 15
	end
end


ropes.hanging_after_destruct = function(pos, top_node, middle_node, bottom_node)
	local node = minetest.get_node(pos)
	if node.name == top_node or node.name == middle_node or node.name == bottom_node then
		return -- this was done by another ladder or rope node changing this one, don't react
	end

	pos.y = pos.y + 1 -- one up
	local node_above = minetest.get_node(pos)
	if node_above.name == middle_node then
		minetest.swap_node(pos, {name=bottom_node, param2=node_above.param2})
	end
	
	pos.y = pos.y - 2 -- one down
	local node_below = minetest.get_node(pos)
	if node_below.name == middle_node then
		ropes.destroy_rope(pos, {middle_node, bottom_node})
	elseif node_below.name == bottom_node then
		minetest.swap_node(pos, {name="air"})
	end
end

ropes.move_players_down = function(pos, radius)
	local all_objects = minetest.get_objects_inside_radius({x=pos.x, y=pos.y+radius, z=pos.z}, radius)
	local players = {}
	local _,obj
	for _,obj in pairs(all_objects) do
		if obj:is_player() then
			local obj_pos = obj:get_pos()
			if math.abs(obj_pos.x-pos.x) < 0.5 and math.abs(obj_pos.z-pos.z) < 0.5 then
				obj:move_to({x=obj_pos.x, y=obj_pos.y-1, z=obj_pos.z}, true)
			end
		end
	end
end
