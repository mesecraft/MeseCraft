-- Moon sky and gravity, applied by height through climate_api.
if not minetest.get_modpath("climate_api") then
	return
end

local GRAVITY = 0.165
local min_y = mesecraft_lua.miny - 200
local max_y = mesecraft_lua.maxy + 200

-- Gravity is set once when a player arrives and removed when they leave.
local GRAVITY_EFFECT = "mesecraft_lua:gravity"

climate_api.register_effect(GRAVITY_EFFECT, function(player_data)
	for playername in pairs(player_data) do
		local player = minetest.get_player_by_name(playername)
		if player then
			climate_api.player_physics.add(GRAVITY_EFFECT, player, "gravity", GRAVITY)
		end
	end
end, "start")

climate_api.register_effect(GRAVITY_EFFECT, function(player_data)
	for playername in pairs(player_data) do
		local player = minetest.get_player_by_name(playername)
		if player then
			climate_api.player_physics.remove(GRAVITY_EFFECT, player, "gravity")
		end
	end
end, "stop")

-- No atmosphere: black sky with stars, the sun still visible, no clouds.
climate_api.register_weather("mesecraft_lua:moon", {min_height = min_y, max_height = max_y}, {
	["climate_api:skybox"] = {
		sky_data = {
			type = "plain",
			base_color = {r = 0, g = 0, b = 0},
			clouds = false,
		},
		sun_data = {visible = true, sunrise_visible = false},
		moon_data = {visible = false},
		star_data = {visible = true, day_opacity = 1},
		priority = 1000,
	},
	[GRAVITY_EFFECT] = true,
})
