local armor_mod = minetest.get_modpath("3d_armor")

-- Replace min/max table with random value from min to max
local function get_val(val)
	if type(val) == "table" then
		val = math.random(val.min or 1, val.max or 5)
	end

	return val
end

function fire_plus.burn_player(player, burns, damage, not_initial)
	if not player then
		minetest.log("warning", "[Fire Plus] (burn_player): player is nil")
	end

	local name = player
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
	end

	if not player or player:get_hp() <= 0 then
		fire_plus.extinguish_player(name)
		return
	end

	name = player:get_player_name()

	-- 3d_armor fire protection puts out flames
	if armor_mod and armor.def[name].fire > 1 then
		fire_plus.extinguish_player(name)
	end

	-- Fire was extinguished
	if not fire_plus.burning[name] and not_initial then
		return
	end

	if not fire_plus.burning[name] then
		burns = get_val(burns)

		fire_plus.burning[name] = {
			burns_left = burns,
			hud_id = player:hud_add({
				type = "image",
				position  = {x = 0.5, y = 0.95},
				offset    = {x = 0, y = 0},
				text      = "fire_basic_flame.png",
				alignment = -1,
				scale     = {x = 100, y = 32},
				number    = 0xFFFFFF,
			}),
			sound_id = minetest.sound_play("fire_fire", {
				to_player = name,
				gain = 1.0,
				loop = true,
			}),
			particlespawner_id = minetest.add_particlespawner({
				amount = 10,
				time = 0,
				minpos = vector.new(-0.3, 0.5, -0.3),
				maxpos = vector.new( 0.3,   2,  0.3),
				minvel = {x = -1, y = 0, z = -1},
				maxvel = {x =  1, y = 1, z =  1},
				minacc = {x =  0, y = 2, z =  0},
				maxacc = {x =  0, y = 3, z =  0},
				minexptime = 0.5,
				maxexptime = 1,
				minsize = 3,
				maxsize = 3,
				texture = "fire_basic_flame.png",
				collisiondetection = true,
				glow = minetest.LIGHT_MAX,
				attached = player,
			})
		}
	else
		player:set_hp(player:get_hp() - get_val(damage), {type = "set_hp", fire_plus = true})

		if minetest.get_modpath("tnt") then
			local tntpos = minetest.find_node_near(player:get_pos(), fire_plus.tnt_explode_radius, {"tnt:tnt"}, true)

			if tntpos then
				tnt.boom(tntpos, {radius = fire_plus.tnt_explode_radius, damage_radius = fire_plus.tnt_explode_radius})
			end
		end

		if not_initial then
			fire_plus.burning[name].burns_left = fire_plus.burning[name].burns_left - 1
		else
			fire_plus.burning[name].burns_left = burns
		end
	end

	if fire_plus.burning[name].burns_left > 0 then
		minetest.after(fire_plus.burn_interval, function()
			fire_plus.burn_player(name, burns, damage, true)
		end)
	else
		fire_plus.extinguish_player(name)
	end
end

function fire_plus.extinguish_player(player)
	local name = player

	if player then
		if type(name) ~= "string" then
			name = player:get_player_name()
		else
			player = minetest.get_player_by_name(name)
		end
	end

	if not fire_plus.burning[name] then return end

	if player then
		player:hud_remove(fire_plus.burning[name].hud_id)
		minetest.sound_fade(fire_plus.burning[name].sound_id, 1, 0)
	end

	minetest.delete_particlespawner(fire_plus.burning[name].particlespawner_id)

	fire_plus.burning[name] = nil
end
