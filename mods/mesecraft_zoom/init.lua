---@diagnostic disable: lowercase-global
-- init tables

local tbars = {}
local bbars = {}
local default_fov = 0
local multiplier = false

local function get_setting(key, default)
	local num = tonumber(minetest.settings:get(key))
	if num == nil then
		return default
	else
		return num
	end
end

local svalues = {

	sounds = minetest.settings:get_bool("cinematic_zoom.sounds", false),
	speed = get_setting("cinematic_zoom.speed", 1),
	button = minetest.settings:get_bool("cinematic_zoom.button", true),
	amount = get_setting("cinematic_zoom.amount", 30),
	fov = get_setting("fov", 72)

}

local zoombutton = "zoom"

if not svalues.button == true then
	zoombutton = "sneak"
end

cinematic_zoom = {

	activated = {},
	on_sneak = {},
	dspeed = {},
	uspeed = {},

}

-- register functions

local function set_player_bars(player, top, bottom)
	tbars[player:get_player_name()] = top
	bbars[player:get_player_name()] = bottom
end



function cinematic_zoom.set_bar_state(player, state)
	cinematic_zoom.activated[player:get_player_name()] = state
end

function cinematic_zoom.activate_on_sneak(player, bool)
	cinematic_zoom.on_sneak[player:get_player_name()] = bool
end



minetest.register_on_joinplayer(function(player) -- make hud elements for each player that joins

	local top = player:hud_add({
    	type = "image",
    	position = {x = 0.5, y = 0},
		offset = {x = 0, y = -200},
		text = "black.png",
    	scale = { x = 2000, y = 400},
    	alignment = { x = 0, y = 0 },
		z_index = 100
	})
	local bottom = player:hud_add({
    	type = "image",
    	position = {x = 0.5, y = 1},
		offset = {x = 0, y = 200},
    	text = "black.png",
    	scale = { x = 2000, y = 400},
    	alignment = { x = 0, y = 0 },
		z_index = 100
	})

	player:set_properties({zoom_fov = 0})
	set_player_bars(player, top, bottom) --init values	
	
	default_fov = svalues.fov

	if not player:get_fov() == 0 then
		default_fov,multiplier = player:get_fov()--assume that the fov on join is the one that's used throughout the game
	end
	
	if multiplier == true then
		default_fov = default_fov * svalues.fov
	end

	if svalues.amount == 0 then
		svalues.amount = default_fov
	end

end)


minetest.register_globalstep(function(dtime)
    for _,player in pairs(minetest.get_connected_players()) do --for each connected player animate one frame every globalstep

		local name = player:get_player_name()

		--set fov values
		local fov,multiplier = player:get_fov()

		if default_fov == 0 then
			default_fov = svalues.fov
		end

		if multiplier == true then
			fov = default_fov * fov
		end

		if fov <= 0 then
			fov = svalues.fov
		end

		local fov_val = fov

		--move bars
		
		if cinematic_zoom.activated[name] == true then --if activated then animate one frame closing and zooming in

			local ybottom = player:hud_get(bbars[name])["offset"].y
			local ytop = player:hud_get(tbars[name])["offset"].y

			player:hud_change(bbars[name], "offset", {x = 0, y = ybottom + (svalues.speed * (2*dtime * (-1 * (ybottom - 100)))) }) --uncanny math
			player:hud_change(tbars[name], "offset", {x = 0, y = ytop + (svalues.speed * (2*dtime * (-1 * (ytop + 100)))) })

		end

		if cinematic_zoom.activated[name] == false and player:hud_get(tbars[name])["offset"].y > -200 then --if deactivated animate one frame opening and zooming up/out

			local ybottom = player:hud_get(bbars[name])["offset"].y
			local ytop = player:hud_get(tbars[name])["offset"].y

			player:hud_change(bbars[name], "offset", {x = 0, y = ybottom + (svalues.speed * (2*dtime * (ybottom + 100))) })
			player:hud_change(tbars[name], "offset", {x = 0, y = ytop + (svalues.speed * (2*dtime * (ytop - 100))) })

        end

		--zoom fov

		if cinematic_zoom.activated[name] == true and fov > svalues.amount then --zoom in one frame

			if fov > svalues.amount then
				fov_val = fov - (fov - svalues.amount) * (svalues.speed / 10)
			end

			player:set_fov(fov_val, false, 0.1)

		end

		if cinematic_zoom.activated[name] == false and fov < default_fov - 0.01 then --zoom out one frame

			if fov < default_fov then
				fov_val = fov + (default_fov - fov) * ((svalues.speed * 2) / 10)
			end

			player:set_fov(fov_val, false, 0.1)

		end


    end
end
)


controls.register_on_press(function(player, key) --on press play a sound (if enabled) and set bars/zoom to be on
    if key == zoombutton then
		if svalues.sounds == true then
			minetest.sound_play("cinematic_zoom_down", {
				to_player = player:get_player_name(),
				gain = 1,
				pitch = 1,
			})
		end
		cinematic_zoom.set_bar_state(player, true)
	end
end)

controls.register_on_release(function(player, key) --on release play a sound (if enabled) and set bars/zoom to be off
    if key == zoombutton then
		if svalues.sounds == true then
			minetest.sound_play("cinematic_zoom_up", {
				to_player = player:get_player_name(),
				gain = 1,
				pitch = 1,
			})
		end
		cinematic_zoom.set_bar_state(player, false)
    end
end)