----- EXAMPLE EFFECT TYPES -----
--[[ This is just a helper function to inform the user of the chat command
of the result and, if successful, shows the effect ID. ]]
local function notify(name, retcode)
	if(retcode == false) then
		minetest.chat_send_player(name, "Effect application failed. Effect was NOT applied.")
	else
		minetest.chat_send_player(name, "Effect applied. Effect ID: "..tostring(retcode))
	end
end

--[[ Null effect. The apply function always returns false, which means applying the
effect will never succeed ]]
playereffects.register_effect_type("null", "No effect", nil, {},
	function()
		return false
	end
)


-- Makes the player screen black for 5 seconds (very experimental!)
playereffects.register_effect_type("blind", "Blind", nil, {},
	function(player)
		local hudid = player:hud_add({
			hud_elem_type = "image",
			position = { x=0.5, y=0.5 },
			scale = { x=-100, y=-100 },
			text = "playereffects_example_black.png",
		})
		if(hudid ~= nil) then
			return { hudid = hudid }
		else
			minetest.log("error", "[playereffects] [examples] The effect \"Blind\" could not be applied. The call to hud_add(...) failed.")
			return false
		end
	end,
	function(effect, player)
		player:hud_remove(effect.metadata.hudid)
	end
)

-- Makes the user faster
playereffects.register_effect_type("high_speed", "High speed", nil, {"speed"}, 
	function(player)
		player:set_physics_override({speed = 4})
	end,
	
	function(effect, player)
		player:set_physics_override({speed = 1})
	end
)

-- Makes the user faster (hidden effect)
playereffects.register_effect_type("high_speed_hidden", "High speed", nil, {"speed"}, 
	function(player)
		player:set_physics_override({speed = 4})
	end,
	
	function(effect, player)
		player:set_physics_override({speed = 1})
	end,
	true
)



-- Slows the user down
playereffects.register_effect_type("low_speed", "Low speed", nil, {"speed"}, 
	function(player)
		player:set_physics_override({speed = 0.25})
	end,
	
	function(effect, player)
		player:set_physics_override({speed = 1})
	end
)

-- Increases the jump height
playereffects.register_effect_type("highjump", "Greater jump height", "playereffects_example_highjump.png", {"jump"},
	function(player)
		player:set_physics_override({jump = 2})
	end,
	function(effect, player)
		player:set_physics_override({jump = 1})
	end
)

-- Adds the “fly” privilege. Keep the privilege even if the player dies
playereffects.register_effect_type("fly", "Fly mode available", "playereffects_example_fly.png", {"fly"},
	function(player)
		local playername = player:get_player_name()
		local privs = minetest.get_player_privs(playername)
		privs.fly = true
		minetest.set_player_privs(playername, privs)
	end,
	function(effect, player)
		local privs = minetest.get_player_privs(effect.playername)
		privs.fly = nil
		minetest.set_player_privs(effect.playername, privs)
	end,
	false, -- not hidden
	false  -- do NOT cancel the effect on death
)

-- Repeating effect type: Adds 1 HP per second
playereffects.register_effect_type("regen", "Regeneration", "heart.png", {"health"},
	function(player)
		player:set_hp(player:get_hp()+1)
	end,
	nil, nil, nil, 1
)

-- Repeating effect type: Adds 1 HP per 3 seconds
playereffects.register_effect_type("slowregen", "Slow Regeneration", "heart.png", {"health"},
	function(player)
		player:set_hp(player:get_hp()+1)
	end,
	nil, nil, nil, 3
)


-- Dummy effect for the stress test
playereffects.register_effect_type("stress", "Stress Test Effect", nil, {},
	function(player)
	end,
	function(effect, player)
	end
)



------ Chat commands for the example effects ------
-- Null effect (never succeeds)
minetest.register_chatcommand("null", {
	params = "",
	description = "Does nothing.",
	privs = {},
	func = function(name, param)
		local ret = playereffects.apply_effect_type("null", 5, minetest.get_player_by_name(name))
		notify(name, ret)
	end,
})

minetest.register_chatcommand("blind", {
	params = "",
	description = "Makes your screen black for a short time.",
	privs = {},
	func = function(name, param)
		local ret = playereffects.apply_effect_type("blind", 5, minetest.get_player_by_name(name))
		notify(name, ret)
	end,
})
minetest.register_chatcommand("fast", {
	params = "",
	description = "Makes you fast for a short time.",
	privs = {},
	func = function(name, param)
		local ret = playereffects.apply_effect_type("high_speed", 10, minetest.get_player_by_name(name))
		notify(name, ret)
	end,
})
minetest.register_chatcommand("hfast", {
	params = "",
	description = "Makes you fast for a short time (hidden effect).",
	privs = {},
	func = function(name, param)
		local ret = playereffects.apply_effect_type("high_speed_hidden", 10, minetest.get_player_by_name(name))
		notify(name, ret)
	end,
})
minetest.register_chatcommand("slow", {
	params = "",
	description = "Makes you slow for a long time.",
	privs = {},
	func = function(name, param)
		local ret = playereffects.apply_effect_type("low_speed", 120, minetest.get_player_by_name(name))
		notify(name, ret)
	end,
})
minetest.register_chatcommand("highjump", {
	params = "",
	description = "Makes you jump higher for a short time.",
	privs = {},
	func = function(name, param)
		local ret = playereffects.apply_effect_type("highjump", 20, minetest.get_player_by_name(name))
		notify(name, ret)
	end,
})

minetest.register_chatcommand("fly", {
	params = "",
	description = "Grants you the fly privilege for a minute. You keep the effect when you die.",
	privs = {},
	func = function(name, param)
		local ret = playereffects.apply_effect_type("fly", 60, minetest.get_player_by_name(name))
		notify(name, ret)
	end,
})

minetest.register_chatcommand("regen", {
	params = "",
	description = "Gives you 1 half heart per second 10 times, healing you by 5 hearts in total.",
	privs = {},
	func = function(name, param)
		local ret = playereffects.apply_effect_type("regen", 10, minetest.get_player_by_name(name))
		notify(name, ret)
	end,
})

minetest.register_chatcommand("slowregen", {
	params = "",
	description = "Gives you 1 half heart every 3 seconds 10 times, healing you by 5 hearts in total.",
	privs = {},
	func = function(name, param)
		local ret = playereffects.apply_effect_type("slowregen", 10, minetest.get_player_by_name(name))
		notify(name, ret)
	end,
})

--[[
	Cancel all active effects
]]
minetest.register_chatcommand("cancelall", {
	params = "",
	description = "Cancels all your effects.",
	privs = {},
	func = function(name, param)
		local effects = playereffects.get_player_effects(name)
		for e=1, #effects do
			playereffects.cancel_effect(effects[e].effect_id)
		end
		minetest.chat_send_player(name, "All effects cancelled.")
	end,
})

--[[ The stress test applies a shitload of effects at once.
This is used to test the performance of this mod at very large effect numbers. ]]
minetest.register_chatcommand("stresstest", {
	params = "[<effects>]",
	descriptions = "Start the stress test for Player Effects with <effects> effects.",
	privs = {server=true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local max = 100
		if(type(param)=="string") then
			if(type(tonumber(param)) == "number") then
				max = tonumber(param)
			end
		end
		minetest.debug("[playereffects] Stress test started for "..name.." with "..max.." effects.")
		for i=1,max do
			playereffects.apply_effect_type("stress", math.random(6,60), player)
			if(i%100==0) then
				minetest.debug("[playereffects] Effect "..i.." of "..max.." applied.")
				minetest.chat_send_player(name, "[playereffects] Effect "..i.." of "..max.." applied.")

			end
		end
	end
})
