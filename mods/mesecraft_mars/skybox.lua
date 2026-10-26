-- Mars sky and gravity, applied by height through climate_api.
if not minetest.get_modpath("climate_api") then
	return
end

local min_y = mesecraft_mars.y_start
local cave_end_y = mesecraft_mars.y_start + (mesecraft_mars.y_height * 0.97)
local max_y = mesecraft_mars.y_start + mesecraft_mars.y_skybox_height
local GRAVITY = 0.37

-- Gravity is set once when a player arrives and removed when they leave.
local GRAVITY_EFFECT = "mesecraft_mars:gravity"

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

climate_api.register_weather("mesecraft_mars:surface", {min_height = cave_end_y, max_height = max_y}, {
	["climate_api:skybox"] = {
		sky_data = {
			type = "plain",
			base_color = {r = 244, g = 189, b = 114},
			clouds = true,
		},
		cloud_data = {
			thickness = 64,
			color = {r = 124, g = 124, b = 124},
			ambient = {r = 0, g = 0, b = 0, a = 255},
			density = 0.3,
			height = max_y - 800,
			speed = {x = -2, y = -2},
		},
		priority = 1000,
	},
	[GRAVITY_EFFECT] = true,
})

climate_api.register_weather("mesecraft_mars:cave", {min_height = min_y, max_height = cave_end_y}, {
	["climate_api:skybox"] = {
		sky_data = {
			type = "plain",
			base_color = {r = 0, g = 0, b = 0},
			clouds = false,
		},
		sun_data = {visible = false, sunrise_visible = false},
		moon_data = {visible = false},
		star_data = {visible = false},
		priority = 1000,
	},
	[GRAVITY_EFFECT] = true,
})
