--[[
# HUD Overlay Effect
Use this effect to display a fullscreen image as part of a player's HUD.
Expects a table as the parameter containing the following values:
- ``file <string>``: The name (including file ending) if the image to be displayed
- ``z_index <number>`` (optional): The z_index to forward to player.hud_add. Defaults to 1
- ``color_correction <bool>`` (optional): Whether the image should automatically darken based on current light. Defaults to false.
]]

if not climate_mod.settings.hud_overlay then return end

local EFFECT_NAME = "climate_api:hud_overlay"

local handles = {}
local function apply_hud(pname, weather, hud)
	local player = minetest.get_player_by_name(pname)
	if player == nil then return end

	if handles[pname] == nil then handles[pname] = {} end
	if handles[pname][weather] ~= nil then
		player:hud_remove(handles[pname][weather])
	end

	local file
	if hud.color_correction then
		local pos = vector.add(player:get_pos(), {x = 0, y = 1, z = 0})
		local node_light = minetest.get_node_light(pos)
		if not node_light then node_light = 0 end
		local light = math.floor(math.max(node_light / 15, 0.2) * 256)
		local shadow = 256 - light

		local dark_file = hud.file .. "^[multiply:#000000ff^[opacity:" .. shadow
		local light_file = hud.file .. "^[opacity:" .. light
		file = "(" .. light_file .. ")^(" .. dark_file .. ")"
	else
		file = hud.file
	end

	local handle = player:hud_add({
		name = weather,
		type = "image",
		position = {x = 0, y = 0},
		alignment = {x = 1, y = 1},
		scale = { x = -100, y = -100},
		z_index = hud.z_index,
		text = file,
		offset = {x = 0, y = 0}
	})
	handles[pname][weather] = handle
end

local function remove_hud(pname, weather, hud)
	local player = minetest.get_player_by_name(pname)
	if player == nil then return end
	if handles[pname] == nil or handles[pname][weather] == nil then return end

	local handle = handles[pname][weather]
	player:hud_remove(handle)
	handles[pname][weather] = nil
end

local function start_effect(player_data)
	for playername, data in pairs(player_data) do
		for weather, value in pairs(data) do
			apply_hud(playername, weather, value)
		end
	end
end

local function handle_effect(player_data, prev_data)
	for playername, data in pairs(player_data) do
		for weather, value in pairs(data) do
			if prev_data[playername][weather] == nil
			or value.color_correction == true
			or prev_data[playername][weather].color_correction == true
			or value.file ~= prev_data[playername][weather].file
			or value.z_index ~= prev_data[playername][weather].z_index
			then
				apply_hud(playername, weather, value)
			end
		end
	end

	for playername, data in pairs(prev_data) do
		for weather, value in pairs(data) do
			if player_data[playername][weather] == nil then
				remove_hud(playername, weather, value)
			end
		end
	end
end

local function stop_effect(prev_data)
	for playername, data in pairs(prev_data) do
		for weather, value in pairs(data) do
			remove_hud(playername, weather, value)
		end
	end
end

climate_api.register_effect(EFFECT_NAME, start_effect, "start")
climate_api.register_effect(EFFECT_NAME, handle_effect, "tick")
climate_api.register_effect(EFFECT_NAME, stop_effect, "stop")
