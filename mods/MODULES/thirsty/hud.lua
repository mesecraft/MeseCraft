--[[

HUD definitions for Thirsty

Optionally from one of the supported mods

Any hud needs to define the following functions:

- thirsty.hud_init(player)
  Initialize the HUD for a new player.

- thirsty.hud_update(player, value)
  Display the new value "value" for the given player. "value" is
  a floating point number, not necessarily bounded. You can use the
  "thirsty.hud_clamp(value)" function to get an integer between 0
  and 20.

]]

local PPA = thirsty.persistent_player_attributes

function thirsty.hud_clamp(value)
    if value < 0 then
        return 0
    elseif value > 20 then
        return 20
    else
        return math.ceil(value)
    end
end

if minetest.get_modpath("hudbars") then
    hb.register_hudbar('thirst', 0xffffff, "Hydration", {
        bar = 'thirsty_hudbars_bar.png',
        icon = 'thirsty_cup_100_16.png',
	bgicon = 'thirsty_cup_bgicon_16.png'
	
    }, 20, 20, false)
    function thirsty.hud_init(player)
        hb.init_hudbar(player, 'thirst',
            thirsty.hud_clamp(PPA.get_value(player, 'thirsty_hydro')),
        20, false)
    end
    function thirsty.hud_update(player, value)
        hb.change_hudbar(player, 'thirst', thirsty.hud_clamp(value), 20)
    end
elseif minetest.get_modpath("hud") then
    -- default positions follow [hud] defaults
    local position = HUD_THIRST_POS or { x=0.5, y=1 }
    local offset   = HUD_THIRST_OFFSET or { x=15, y=-133} -- above AIR
    hud.register('thirst', {
        type = "statbar",
        position = position,
        text = "thirsty_cup_100_24.png",
        background = "thirsty_cup_0_24.png",
        number = 20,
        max = 20,
        size = HUD_SB_SIZE, -- by default { x=24, y=24 },
        offset = offset,
    })
    function thirsty.hud_init(player)
        -- automatic by [hud]
    end
    function thirsty.hud_update(player, value)
        hud.change_item(player, 'thirst', {
            number = thirsty.hud_clamp(value)
        })
    end
else
    -- 'builtin' hud
    function thirsty.hud_init(player)
        -- above breath bar, for now
        local name = player:get_player_name()
        thirsty.players[name].hud_id = player:hud_add({
            type = "statbar",
            position = { x=0.5, y=1 },
            text = "thirsty_cup_100_24.png",
            number = thirsty.hud_clamp(PPA.get_value(player, 'thirsty_hydro')),
            direction = 0,
            size = { x=24, y=24 },
            offset = { x=25, y=-(48+24+16+32)},
        })
    end
    function thirsty.hud_update(player, value)
        local name = player:get_player_name()
        local hud_id = thirsty.players[name].hud_id
        player:hud_change(hud_id, 'number', thirsty.hud_clamp(value))
    end
end
