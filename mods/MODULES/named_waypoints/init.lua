local worldpath = minetest.get_worldpath()

local S = minetest.get_translator("named_waypoints")

named_waypoints = {}

local test_interval = 5

local player_huds = {} -- Each player will have a table of [position_hash] = hud_id pairs in here
local waypoint_defs = {} -- the registered definition tables
local waypoint_areastores = {} -- areastores containing waypoint data

local inventory_string = "inventory"
local hotbar_string = "hotbar"
local wielded_string = "wielded"

--waypoint_def = {
--	default_name = , -- a string that's used if a waypoint's data doesn't have a "name" property
--	default_color = , -- if not defined, defaults to 0xFFFFFFFF
--	visibility_requires_item = , -- item, if not defined then nothing is required
--	visibility_item_location = , -- "inventory", "hotbar", "wielded" (defaults to inventory if not provided)
--	visibility_volume_radius = , -- If not defined, HUD waypoints will not be shown.
--	visibility_volume_height = , -- if defined, then visibility check is done in a cylindrical volume rather than a sphere
--	discovery_requires_item = ,-- item, if not defined then nothing is required
--	discovery_item_location = ,-- -- "inventory", "hotbar", "wielded" (defaults to inventory if not provided)
--	discovery_volume_radius = , -- radius within which a waypoint can be auto-discovered by a player. "discovered_by" property is used in waypoint_data to store discovery info
--	discovery_volume_height = , -- if defined, then discovery check is done in a cylindrical volume rather than a sphere
--	on_discovery = function(player, pos, waypoint_data, waypoint_def) -- use "named_waypoints.default_discovery_popup" for a generic discovery notification
--}

named_waypoints.register_named_waypoints = function(waypoints_type, waypoints_def)
	waypoint_defs[waypoints_type] = waypoints_def
	player_huds[waypoints_type] = {}

	local areastore_filename = worldpath.."/named_waypoints_".. waypoints_type ..".txt"
	local area_file = io.open(areastore_filename, "r")
	local areastore = AreaStore()
	if area_file then
		area_file:close()
		areastore:from_file(areastore_filename)
	end
	waypoint_areastores[waypoints_type] = areastore	
end

local function save(waypoints_type)
	local areastore_filename = worldpath.."/named_waypoints_".. waypoints_type ..".txt"
	local areastore = waypoint_areastores[waypoints_type]
	if areastore then
		areastore:to_file(areastore_filename)
	else
		minetest.log("error", "[named_waypoints] attempted to save areastore for unregistered type " .. waypoints_type)
	end
end

-- invalidates a hud marker at a specific location
local function remove_hud_marker(waypoints_type, pos)
	local waypoint_def = waypoint_defs[waypoints_type]
	if not waypoint_def.visibility_volume_radius then
		-- if there's no visibility, there won't be any hud markers to remove
		return
	end
	local target_hash = minetest.hash_node_position(pos)
	local waypoints_for_this_type = player_huds[waypoints_type]
	for player_name, waypoints in pairs(waypoints_for_this_type) do
		local player = minetest.get_player_by_name(player_name)
		if player then
			for pos_hash, hud_id in pairs(waypoints) do
				if pos_hash == target_hash then
					player:hud_remove(hud_id)
					waypoints[pos_hash] = nil
					break
				end
			end
		end
	end
end

local function add_waypoint(waypoints_type, pos, waypoint_data, update_existing)
	assert(type(waypoint_data) == "table")
	local areastore = waypoint_areastores[waypoints_type]
	if not areastore then
		minetest.log("error", "[named_waypoints] attempted to add waypoint for unregistered type " .. waypoints_type)
		return false
	end
	local existing_area = areastore:get_areas_for_pos(pos, false, true)
	local id = next(existing_area)
	if id and not update_existing then
		return false -- already exists
	end	

	local data
	if id then
		data = minetest.deserialize(existing_area[id].data)
		for k,v in pairs(waypoint_data) do
			data[k] = v
		end		
		areastore:remove_area(id)
		remove_hud_marker(waypoints_type, pos)
	else
		data = waypoint_data
	end

	local waypoint_def = waypoint_defs[waypoints_type]
	if not (data.name or waypoint_def.default_name) then
		minetest.log("error", "[named_waypoints] Waypoint of type " .. waypoints_type .. " at "
			.. minetest.pos_to_string(pos) .. " was missing a name field in its data " .. dump(data)
			.. " and its type definition has no default to fall back on.")
		return false
	end
	areastore:insert_area(pos, pos, minetest.serialize(data), id)
	save(waypoints_type)
	return true	
end

named_waypoints.add_waypoint = function(waypoints_type, pos, waypoint_data)
	if not waypoint_data then
		waypoint_data = {}
	end
	return add_waypoint(waypoints_type, pos, waypoint_data, false)
end

named_waypoints.update_waypoint = function(waypoints_type, pos, waypoint_data)
	return add_waypoint(waypoints_type, pos, waypoint_data, true)
end

named_waypoints.get_waypoint = function(waypoints_type, pos)
	local areastore = waypoint_areastores[waypoints_type]
	local existing_area = areastore:get_areas_for_pos(pos, false, true)
	local id = next(existing_area)
	if not id then
		return nil -- nothing here
	end	
	return minetest.deserialize(existing_area[id].data)
end

-- returns a list of tables with the values {pos=, data=}
named_waypoints.get_waypoints_in_area = function(waypoints_type, minp, maxp)
	local areastore = waypoint_areastores[waypoints_type]
	local areas = areastore:get_areas_in_area(minp, maxp, true, true, true)
	local returnval = {}
	for id, data in pairs(areas) do
		table.insert(returnval, {pos=data.min, data=minetest.deserialize(data.data)})
	end
	return returnval
end

named_waypoints.remove_waypoint = function(waypoints_type, pos)
	local areastore = waypoint_areastores[waypoints_type]
	local existing_area = areastore:get_areas_for_pos(pos, false, true)
	local id = next(existing_area)
	if not id then
		return false -- nothing here
	end
	areastore:remove_area(id)
	remove_hud_marker(waypoints_type, pos)
	save(waypoints_type)
	return true
end

local function add_hud_marker(waypoints_type, player, player_name, pos, label, color)
	local waypoints_for_this_type = player_huds[waypoints_type]
	local waypoints = waypoints_for_this_type[player_name] or {}
	local pos_hash = minetest.hash_node_position(pos)
	if waypoints[pos_hash] then
		-- already exists
		return
	end
	waypoints_for_this_type[player_name] = waypoints
	color = color or 0xFFFFFF
	local hud_id = player:hud_add({
		type = "waypoint",
		name = label,
		text = "m",
		number = color,
		world_pos = pos})
	waypoints[pos_hash] = hud_id
end

local grouplen = #"group:"
local function test_items(player, item, location)
	if not item then
		return true
	end

	location = location or inventory_string
	local group
	if item:sub(1,grouplen) == "group:" then
		group = item:sub(grouplen+1)
	end
	
	if location == inventory_string then
		local player_inv = player:get_inventory()
		if group then
			for _, itemstack in pairs(player_inv:get_list("main")) do
				if minetest.get_item_group(itemstack:get_name(), group) > 0 then
					return true
				end
			end
		elseif player_inv:contains_item("main", ItemStack(item)) then
			return true
		end

	elseif location == hotbar_string then
		local player_inv = player:get_inventory()
		if group then
			for i = 1,8 do
				local hot_item = player_inv:get_Stack("main", i)
				if minetest.get_item_group(hot_item:get_name(), group) > 0 then
					return true
				end
			end
		else
			local hot_required = ItemStack(item)
			for i = 1, 8 do
				local hot_item = player_inv:get_stack("main", i)
				if hot_item:get_name() == hot_required:get_name() and hot_item:get_count() >= hot_required:get_count() then
					return true
				end
			end
		end

	elseif location == wielded_string then
		local wielded_item = player:get_wielded_item()
		if group then
			return minetest.get_item_group(wielded_item:get_name(), group) > 0
		else
			local wielded_required = ItemStack(item)
			if wielded_item:get_name() == wielded_required:get_name() and wielded_item:get_count() >= wielded_required:get_count() then
				return true
			end
		end
	else
		minetest.log("error", "[named_waypoints] Illegal inventory location " .. location .. " to test for an item.")
	end
	return false
end

local function test_range(player_pos, waypoint_pos, volume_radius, volume_height)
	if not volume_radius then
		return false
	end
	if volume_height then
		if math.abs(player_pos.y - waypoint_pos.y) > volume_height then
			return false
		end
		return math.sqrt(
			((player_pos.x - waypoint_pos.x)*(player_pos.x - waypoint_pos.x))+
			((player_pos.z - waypoint_pos.z)*(player_pos.z - waypoint_pos.z))) <= volume_radius
	else
		return vector.distance(player_pos, waypoint_pos) <= volume_radius
	end
end

-- doesn't test for discovery status being lost, it is assumed that waypoints are
-- rarely ever un-discovered once discovered.
local function remove_distant_hud_markers(waypoint_type)
	local waypoint_def = waypoint_defs[waypoint_type]
	local vis_radius = waypoint_def.visibility_volume_radius
	if not vis_radius then
		-- if there's no visibility, there won't be any hud markers to remove
		return
	end
	local waypoints_for_this_type = player_huds[waypoint_type]
	local players_to_remove = {}
	local vis_inv = waypoint_def.visibility_requires_item
	local vis_loc = waypoint_def.visibility_item_location
	local vis_height = waypoint_def.visibility_volume_height

	for player_name, waypoints in pairs(waypoints_for_this_type) do
		local player = minetest.get_player_by_name(player_name)
		if player then
			local waypoints_to_remove = {}
			local player_pos = player:get_pos()
			for pos_hash, hud_id in pairs(waypoints) do
				local pos = minetest.get_position_from_hash(pos_hash)
				if not (test_items(player, vis_inv, vis_loc) 
					and test_range(player_pos, pos, vis_radius, vis_height)) then
					table.insert(waypoints_to_remove, pos_hash)
					player:hud_remove(hud_id)
				end
			end
			for _, pos_hash in ipairs(waypoints_to_remove) do
				waypoints[pos_hash] = nil
			end
			if not next(waypoints) then -- player's waypoint list is empty, remove it
				table.insert(players_to_remove, player_name)
			end
		else
			table.insert(players_to_remove, player_name)
		end
	end
	for _, player_name in ipairs(players_to_remove) do
		player_huds[player_name] = nil
	end
end

local function get_range_box(pos, volume_radius, volume_height)
	if volume_height then
		return {x = pos.x - volume_radius, y = pos.y - volume_height, z = pos.z - volume_radius},
			{x = pos.x + volume_radius, y = pos.y + volume_height, z = pos.z + volume_radius}
	else
		return vector.subtract(pos, volume_radius), vector.add(pos, volume_radius)
	end
end

local elapsed = 0
minetest.register_globalstep(function(dtime)
	elapsed = elapsed + dtime
	if elapsed < test_interval then
		return
	end
	elapsed = 0

	local connected_players = minetest.get_connected_players()
	for waypoint_type, waypoint_def in pairs(waypoint_defs) do
		local vis_radius = waypoint_def.visibility_volume_radius
		local disc_radius = waypoint_def.discovery_volume_radius
		if vis_radius or disc_radius then

			local areastore = waypoint_areastores[waypoint_type]
			local dirty_areastore = false
			
			local vis_height = waypoint_def.visibility_volume_height
			local vis_inv = waypoint_def.visibility_requires_item
			local vis_loc = waypoint_def.visibility_item_location
			
			local disc_height = waypoint_def.discovery_volume_height
			local disc_inv = waypoint_def.discovery_requires_item
			local disc_loc = waypoint_def.discovery_item_location
			
			local on_discovery = waypoint_def.on_discovery
			local default_color = waypoint_def.default_color
			local default_name = waypoint_def.default_name

			for _, player in ipairs(connected_players) do
				local player_pos = player:get_pos()
				local player_name = player:get_player_name()
				
				if disc_radius then			
					local min_discovery_edge, max_discovery_edge = get_range_box(player_pos, disc_radius, disc_height)
					local potentially_discoverable = areastore:get_areas_in_area(min_discovery_edge, max_discovery_edge, true, true, true)
					for id, area_data in pairs(potentially_discoverable) do
						local pos = area_data.min
						local data = minetest.deserialize(area_data.data)
						local discovered_by = data.discovered_by or {}
		
						if not discovered_by[player_name] and
							test_items(player, disc_inv, disc_loc) 
							and test_range(player_pos, pos, disc_radius, disc_height) then
							
							discovered_by[player_name] = true
							data.discovered_by = discovered_by
							areastore:remove_area(id)
							areastore:insert_area(pos, pos, minetest.serialize(data), id)
							
							if on_discovery then
								on_discovery(player, pos, data, waypoint_def)
							end
							
							dirty_areastore = true						
						end
					end			
				end
	
				if vis_radius then
					local min_visual_edge, max_visual_edge = get_range_box(player_pos, vis_radius, vis_height)
					local potentially_visible = areastore:get_areas_in_area(min_visual_edge, max_visual_edge, true, true, true)
					for id, area_data in pairs(potentially_visible) do
						local pos = area_data.min
						local data = minetest.deserialize(area_data.data)
						local discovered_by = data.discovered_by
	
						if (not disc_radius or (discovered_by and discovered_by[player_name])) and
							test_items(player, vis_inv, vis_loc) 
							and test_range(player_pos, pos, vis_radius, vis_height) then
							add_hud_marker(waypoint_type, player, player_name, pos,
								data.name or default_name, data.color or default_color)
						end
					end
				end
			end
			if dirty_areastore then
				save(waypoint_type)
			end
			remove_distant_hud_markers(waypoint_type)
		end
	end
end)

-- Use this as a definition's on_discovery for a generic popup and sound alert
named_waypoints.default_discovery_popup = function(player, pos, data, waypoint_def)
	local player_name = player:get_player_name()
	local discovery_name = data.name or waypoint_def.default_name
	local discovery_note = S("You've discovered @1", discovery_name)
	local formspec = "formspec_version[2]" ..
		"size[5,2]" ..
		"label[1.25,0.75;" .. minetest.formspec_escape(discovery_note) ..
		"]button_exit[1.0,1.25;3,0.5;btn_ok;".. S("OK") .."]"
	minetest.show_formspec(player_name, "named_waypoints:discovery_popup", formspec)
	minetest.chat_send_player(player_name, discovery_note)
	minetest.log("action", "[named_waypoints] " .. player_name .. " discovered " .. discovery_name)
	minetest.sound_play({name = "named_waypoints_chime01", gain = 0.25}, {to_player=player_name})
end


------------------------------------------------------------------------------------------------------------------
--- Admin commands

local formspec_state = {}
local function get_formspec(player_name)
	local player = minetest.get_player_by_name(player_name)
	local player_pos = player:get_pos()
	local state = formspec_state[player_name] or {}
	formspec_state[player_name] = state
	state.row_index = state.row_index or 1

	local formspec = {
		"formspec_version[2]"
		.."size[8,9]"
		.."button_exit[7.0,0.25;0.5,0.5;close;X]"
		.."label[0.5,0.6;Type:]dropdown[1.25,0.5;2,0.25;type_select;"
	}
	
	local types = {}
	local i = 0
	local dropdown_selected_index
	for waypoint_type, def in pairs(waypoint_defs) do
		i = i + 1
		if not state.selected_type then
			state.selected_type = waypoint_type
		end
		if state.selected_type == waypoint_type then
			dropdown_selected_index = i
		end
		table.insert(types, waypoint_type)
	end
	local selected_def = waypoint_defs[state.selected_type]
	formspec[#formspec+1] = table.concat(types, ",") .. ";"..dropdown_selected_index.."]"
	
	formspec[#formspec+1] = "tablecolumns[text;text;text]table[0.5,1.0;7,4;waypoint_table;"
	local areastore = waypoint_areastores[state.selected_type]
	if not areastore then
		return ""
	end
	local areas_by_id = areastore:get_areas_in_area({x=-32000, y=-32000, z=-32000}, {x=32000, y=32000, z=32000}, true, true, true)
	local areas = {}
	for id, area in pairs(areas_by_id) do
		area.id = id
		table.insert(areas, area)
	end
	
	table.sort(areas, function(area1, area2)
		local dist1 = vector.distance(area1.min, player_pos)
		local dist2 = vector.distance(area2.min, player_pos)
		return dist1 < dist2
	end)
	
	local selected_area = areas[state.row_index]
	if not selected_area then
		state.row_index = 1
	end
	
	local selected_name = ""
	local selected_data_string = ""

	state.selected_id = nil
	state.selected_pos = nil

	for i, area in ipairs(areas) do
		if i == state.row_index then
			state.selected_id = area.id
			state.selected_pos = area.min
			selected_area = area
			selected_data_string = selected_area.data
			local selected_data = minetest.deserialize(selected_data_string)
			selected_name = minetest.formspec_escape(selected_data.name or selected_def.default_name or "unnamed")
		end
		local pos = area.min
		local data_string = area.data
		local data = minetest.deserialize(data_string)
		formspec[#formspec+1] = minetest.formspec_escape(data.name or selected_def.default_name or "unnamed")
			..","..minetest.formspec_escape(minetest.pos_to_string(pos))
			..",".. minetest.formspec_escape(data_string)
		formspec[#formspec+1] = ","
	end
	formspec[#formspec] = ";"..state.row_index.."]" -- don't use +1, this overwrites the last ","
	
	state.selected_pos = state.selected_pos or {x=0,y=0,z=0}
	
	formspec[#formspec+1] = "container[0.5,5.25]"
		.."label[0,0.15;X]field[0.25,0;1,0.25;pos_x;;"..state.selected_pos.x.."]"
		.."label[1.5,0.15;Y]field[1.75,0;1,0.25;pos_y;;"..state.selected_pos.y.."]"
		.."label[3.0,0.15;Z]field[3.25,0;1,0.25;pos_z;;"..state.selected_pos.z.."]"
		.."container_end[]"

	formspec[#formspec+1] = "textarea[0.5,5.75;7,2.25;waypoint_data;;".. minetest.formspec_escape(selected_data_string) .."]"

	formspec[#formspec+1] = "container[0.5,8.25]"
		.."button[0,0;1,0.5;teleport;"..S("Teleport").."]button[1,0;1,0.5;save;"..S("Save").."]"
		.."button[2,0;1,0.5;rename;"..S("Rename").."]field[3,0;2,0.5;waypoint_name;;" .. selected_name .."]"
		.."button[5,0;1,0.5;create;"..S("New").."]button[6,0;1,0.5;delete;"..S("Delete").."]"
		.."container_end[]"

	return table.concat(formspec)
end

minetest.register_chatcommand("named_waypoints", {
    description = S("Open server controls for named_waypoints"),
    func = function(name, param)
		if not minetest.check_player_privs(name, {server = true}) then
			minetest.chat_send_player(name, S("This command is for server admins only."))
			return
		end
		minetest.show_formspec(name, "named_waypoints:server_controls", get_formspec(name))
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "named_waypoints:server_controls" then
		return
	end

	if fields.close then
		return
	end
	
	local player_name = player:get_player_name()
	if not minetest.check_player_privs(player_name, {server = true}) then
		minetest.chat_send_player(player_name, S("This command is for server admins only."))
		return
	end
	
	local refresh = false
	local state = formspec_state[player_name]
	if fields.type_select then
		formspec_state[player_name].selected_type = fields.type_select
		refresh = true
	end
	
	if fields.waypoint_table then
		local table_event = minetest.explode_table_event(fields.waypoint_table)
		if table_event.type == "CHG" then
			formspec_state[player_name].row_index = table_event.row
			refresh = true
		end
	end
	
	if fields.save then
		local deserialized = minetest.deserialize(fields.waypoint_data)
		local pos_x = tonumber(fields.pos_x)
		local pos_y = tonumber(fields.pos_y)
		local pos_z = tonumber(fields.pos_z)
		if deserialized and pos_x and pos_y and pos_z and state.selected_id then
			local areastore = waypoint_areastores[state.selected_type]
			local pos = vector.floor({x=pos_x, y=pos_y, z=pos_z})
			areastore:remove_area(state.selected_id)
			areastore:insert_area(pos, pos,
				fields.waypoint_data, state.selected_id)

			save(state.selected_type)
			remove_hud_marker(state.selected_type, state.selected_pos)
			minetest.chat_send_player(player_name, S("Waypoint updated."))
		else
			minetest.chat_send_player(player_name, S("Invalid syntax."))
		end
		refresh = true
	end
	
	if fields.delete then
		local areastore = waypoint_areastores[state.selected_type]
		areastore:remove_area(state.selected_id)
		save(state.selected_type)
		remove_hud_marker(state.selected_type, state.selected_pos)
		refresh = true		
	end
	
	if fields.create then
		local pos = player:get_pos()
		local areastore = waypoint_areastores[state.selected_type]
		local existing_area = areastore:get_areas_for_pos(pos, false, true)
		local id = next(existing_area)
		if id then
			minetest.chat_send_player(player_name, S("There's already a waypoint there."))
			return
		end		
		areastore:insert_area(pos, pos, minetest.serialize({}))
		save(state.selected_type)
		refresh = true
	end	
	
	if fields.rename then
		local areastore = waypoint_areastores[state.selected_type]
		local area = areastore:get_area(state.selected_id, true, true)
		local data = minetest.deserialize(area.data)
		data.name = fields.waypoint_name
		areastore:remove_area(state.selected_id)
		areastore:insert_area(area.min, area.min, minetest.serialize(data), state.selected_id)
		save(state.selected_type)
		remove_hud_marker(state.selected_type, state.selected_pos)
		minetest.chat_send_player(player_name, S("Waypoint updated."))
	end
	
	if fields.teleport then
		player:set_pos(state.selected_pos)
	end
	
	if refresh then
		minetest.show_formspec(player_name, "named_waypoints:server_controls", get_formspec(player_name))
	end
end)

local function set_all_discovered(player_name, waypoint_type, state)
	local waypoint_list = named_waypoints.get_waypoints_in_area(waypoint_type,
		{x=-32000, y=-32000, z=-32000}, {x=32000, y=32000, z=32000})
	for id, waypoint in pairs(waypoint_list) do
		waypoint.data.discovered_by = waypoint.data.discovered_by or {}
		waypoint.data.discovered_by[player_name] = state
		named_waypoints.update_waypoint(waypoint_type, waypoint.pos, waypoint.data)
	end
end

minetest.register_chatcommand("named_waypoints_discover_all", {
	description = S("Set all waypoints of a type as discovered by you"),
	params = S("waypoint type"),
	privs = {["server"]=true},
	func = function(name, param)
		if param == "" or waypoint_defs[param] == nil then
			minetest.chat_send_player(name, S("Please provide a valid waypoint type as a parameter"))
			return
		end
		set_all_discovered(name, param, true)
	end,
})

minetest.register_chatcommand("named_waypoints_undiscover_all", {
	description = S("Set all waypoints of a type as not discovered by you"),
	params = S("waypoint type"),
	privs = {["server"]=true},
	func = function(name, param)
		if param == "" or waypoint_defs[param] == nil then
			minetest.chat_send_player(name, S("Please provide a valid waypoint type as a parameter"))
			return
		end
		set_all_discovered(name, param, nil)
	end,
})