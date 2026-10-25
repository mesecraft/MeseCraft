
local S = protector.intllib

-- get static spawn position
local statspawn = minetest.string_to_pos(minetest.settings:get("static_spawnpoint"))
		or {x = 0, y = 2, z = 0}

-- is spawn protected
local protector_spawn = tonumber(minetest.settings:get("protector_spawn")
	or minetest.settings:get("protector_pvp_spawn")) or 0

-- is night-only pvp enabled
local protector_night_pvp = minetest.settings:get_bool("protector_night_pvp")

-- disables PVP in your own protected areas
if minetest.settings:get_bool("enable_pvp")
and minetest.settings:get_bool("protector_pvp") then

	if minetest.register_on_punchplayer then

		minetest.register_on_punchplayer(function(player, hitter,
				time_from_last_punch, tool_capabilities, dir, damage)

			if not player
			or not hitter then
				print(S("[Protector] on_punchplayer called with nil objects"))
				return false
			end

			if not hitter:is_player() then
				return false
			end

			-- no pvp at spawn area
			local pos = player:get_pos()

			if pos.x < statspawn.x + protector_spawn
			and pos.x > statspawn.x - protector_spawn
			and pos.y < statspawn.y + protector_spawn
			and pos.y > statspawn.y - protector_spawn
			and pos.z < statspawn.z + protector_spawn
			and pos.z > statspawn.z - protector_spawn then
				return true
			end

			-- do we enable pvp at night time only ?
			if protector_night_pvp then

				-- get time of day
				local tod = minetest.get_timeofday() or 0

				if tod > 0.2 and tod < 0.8 then
					--
				else
					return false
				end
			end

			-- is player being punched inside a protected area ?
			if minetest.is_protected(pos, hitter:get_player_name()) then
				return true
			end

			return false

		end)
	else
		print(S("[Protector] pvp_protect not active, update your version of Minetest"))

	end
else
	print(S("[Protector] pvp_protect is disabled"))
end
