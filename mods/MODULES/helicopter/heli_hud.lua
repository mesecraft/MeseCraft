local heli_hud_list = {}

function update_heli_hud(player)
    --[[
    local player_name = player:get_player_name()

	hour = minetest.get_timeofday() * 24
	hour = math.ceil(hour)
    
    -- Get the dig and place count from storage, or default to 0
    local meta        = player:get_meta()
    local time_text   = "Time of day: " .. hour .. "h "
    local pos = player:get_pos()
    local altitude = math.ceil(pos.y)
    local altitude_text = "Altitude: " .. math.ceil(altitude)

    local ids = heli_hud_list[player_name]
    if ids then
        player:hud_change(ids["time"], "text", time_text)
        player:hud_change(ids["altitude"],   "text", altitude_text)
    else
        local screen_pos_y = -250
        local screen_pos_x = -100
        ids = {}
        ids["bg"] = player:hud_add({
            type = "image",
            position  = {x = 1, y = 0.5},
            offset    = {x = -240 + screen_pos_x, y = -10 + screen_pos_y},
            text      = "flight_info_bg.png",
            scale     = { x = 1, y = 1},
            alignment = { x = 1, y = 0 },
        })
        
        ids["title"] = player:hud_add({
            type = "text",
            position  = {x = 1, y = 0.5},
            offset    = {x = -120 + screen_pos_x, y = -25 + screen_pos_y},
            text      = "Flight Information",
            alignment = 0,
            scale     = { x = 100, y = 30},
            number    = 0xFFFFFF,
        })

        ids["time"] = player:hud_add({
            type = "text",
            position  = {x = 1, y = 0.5},
            offset    = {x = -180 + screen_pos_x, y = 0 + screen_pos_y},
            text      = time_text,
            alignment = -1,
            scale     = { x = 50, y = 10},
            number    = 0xFFFFFF,
        })

        ids["altitude"] = player:hud_add({
            type = "text",
            position  = {x = 1, y = 0.5},
            offset    = {x = -70 + screen_pos_x, y = 0 + screen_pos_y},
            text      = altitude_text,
            alignment = -1,
            scale     = { x = 50, y = 10},
            number    = 0xFFFFFF,
        })

        heli_hud_list[player_name] = ids
    end
    ]]--
end


function remove_heli_hud(player)
    --[[
    local player_name = player:get_player_name()
    local ids = heli_hud_list[player_name]
    player:hud_remove(ids["altitude"])
    player:hud_remove(ids["time"])
    player:hud_remove(ids["title"])
    player:hud_remove(ids["bg"])
    heli_hud_list[player_name] = nil
    ]]--
end
