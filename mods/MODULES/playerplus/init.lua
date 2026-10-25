--[[
	walking on ice makes player walk faster,
	stepping through snow slows player down,
	touching a cactus hurts player,
	suffocation when head is inside solid node,
	player knock-back effects when punched.

	PlayerPlus by TenPlus1
]]

playerplus = {}

-- detect minetest 5.0
local mt50 = minetest.registered_nodes["default:permafrost"]

-- cache if player_monoids mod active?
local monoids = minetest.get_modpath("player_monoids")
local pova_mod = minetest.get_modpath("pova")

-- get node but use fallback for nil or unknown
local node_ok = function(pos, fallback)

	fallback = fallback or "air"

	local node = minetest.get_node_or_nil(pos)

	if node and minetest.registered_nodes[node.name] then
		return node.name
	end

	return fallback
end


local armor_mod = minetest.get_modpath("3d_armor")
local time = 0


minetest.register_globalstep(function(dtime)

	time = time + dtime

	-- every 1 second
	if time < 1 then
		return
	end

	-- reset time for next check
	time = 0

	-- define locals outside loop
	local name, pos, ndef, def, nslow, nfast

	-- loop through players
	for _,player in ipairs(minetest.get_connected_players()) do

		-- who am I?
		name = player:get_player_name()

		-- where am I?
		pos = player:get_pos()

		-- what is around me?
		pos.y = pos.y - 0.1 -- standing on
		playerplus[name].nod_stand = node_ok(pos)

		-- Does the node below me have an on_walk_over function set?
		ndef = minetest.registered_nodes[playerplus[name].nod_stand]
		if ndef and ndef.on_walk_over then
			ndef.on_walk_over(pos, ndef, player)
		end

		pos.y = pos.y + 1.5 -- head level
		playerplus[name].nod_head = node_ok(pos)

		pos.y = pos.y - 1.2 -- feet level
		playerplus[name].nod_feet = node_ok(pos)

		pos.y = pos.y - 0.2 -- reset pos

		-- get player physics
		def = player:get_physics_override()

		if armor_mod and armor and armor.def then
			-- get player physics from armor
			def.speed = armor.def[name].speed or def.speed
			def.jump = armor.def[name].jump or def.jump
			def.gravity = armor.def[name].gravity or def.gravity
		end

		-- apply speed changes
		if nfast and not playerplus[name].nfast then
			if monoids then
				playerplus[name].nfast = player_monoids.speed:add_change(
					player, def.speed + 0.4)
			elseif pova_mod then
				pova.add_override(name, "playerplus:nfast", {speed = 0.4})
				pova.do_override(player)
			else
				def.speed = def.speed + 0.4
			end

			playerplus[name].nfast = true

		elseif not nfast and playerplus[name].nfast then
			if monoids then
				player_monoids.speed:del_change(player, playerplus[name].nfast)
				playerplus[name].nfast = nil
			elseif pova_mod then
				pova.del_override(name, "playerplus:nfast")
				pova.do_override(player)
			else
				def.speed = def.speed - 0.4
			end

			playerplus[name].nfast = nil
		end

		-- apply slowdown changes
		if nslow and not playerplus[name].nslow then
			if monoids then
				playerplus[name].nslow = player_monoids.speed:add_change(
					player, def.speed - 0.3)
			elseif pova_mod then
				pova.add_override(name, "playerplus:nslow", {speed = -0.3})
				pova.do_override(player)
			else
				def.speed = def.speed - 0.3
			end

			playerplus[name].nslow = true

		elseif not nslow and playerplus[name].nslow then
			if monoids then
				player_monoids.speed:del_change(player, playerplus[name].nslow)
				playerplus[name].nslow = nil
			elseif pova_mod then
				pova.del_override(name, "playerplus:nslow")
				pova.do_override(player)
			else
				def.speed = def.speed + 0.3
			end

			playerplus[name].nslow = nil
		end

		-- set player physics
		if not monoids and not pova_mod then
			player:set_physics_override(def)
		end
--[[
		print ("Speed: " .. def.speed
			.. " / Jump: " .. def.jump
			.. " / Gravity: " .. def.gravity)
]]
		-- Is player suffocating inside a normal node without no_clip privs?
		local ndef = minetest.registered_nodes[playerplus[name].nod_head]

		if ndef.walkable == true
		and ndef.drowning == 0
		and ndef.damage_per_second <= 0
		and ndef.groups.disable_suffocation ~= 1
		and ndef.drawtype == "normal"
		and not minetest.check_player_privs(name, {noclip = true}) then

			if player:get_hp() > 0 then
				player:set_hp(player:get_hp() - 2)
			end
		end

		-- am I near a cactus?
		local near = minetest.find_node_near(pos, 1, "default:cactus")

		if near then

			-- am I touching the cactus? if so it hurts
			for _,object in pairs(minetest.get_objects_inside_radius(near, 1.1)) do

				if object:get_hp() > 0 then
					object:set_hp(object:get_hp() - 2)
				end
			end

		end

	end

end)


-- check for old sneak_glitch setting
local old_sneak = minetest.settings:get_bool("old_sneak")

-- set to blank on join (for 3rd party mods)
minetest.register_on_joinplayer(function(player)

	local name = player:get_player_name()

	playerplus[name] = {}
	playerplus[name].nod_head = ""
	playerplus[name].nod_feet = ""
	playerplus[name].nod_stand = ""

	-- apply old sneak glitch if enabled
	if old_sneak then
		player:set_physics_override({new_move = false, sneak_glitch = true})
	end
end)


-- clear when player leaves
minetest.register_on_leaveplayer(function(player)

	playerplus[ player:get_player_name() ] = nil
end)


-- add privelage to disable knock-back
minetest.register_privilege("no_knockback", {
		description = "Disables player knock-back effect",
		give_to_singleplayer = false})

-- is player knock-back effect enabled?
if minetest.settings:get_bool("player_knockback") ~= false then

minetest.register_entity("playerplus:temp", {
	physical = true,
	collisionbox = {-0.20, -1, -0.20, 0.20, 1, 0.20},
	visual_size = {x = 0, y = 0},
	visual = "sprite",
	textures = {"trans.png"},
	stepheight = 0.6,

	on_step = function(self, dtime)

		self.timer = (self.timer or 0) + dtime

		if self.timer > 1 then
			self.object:remove()
		end
	end
})


-- player knock-back function
local punchy = function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)

	local damage = 0

	-- get tool damage
	if tool_capabilities then

		local armor = player:get_armor_groups() or {}
		local tmp

		for group,_ in pairs( (tool_capabilities.damage_groups or {}) ) do

			tmp = time_from_last_punch / (tool_capabilities.full_punch_interval or 1.4)

			if tmp < 0 then
				tmp = 0.0
			elseif tmp > 1 then
				tmp = 1.0
			end

			damage = damage + (tool_capabilities.damage_groups[group] or 0) * tmp

		end

		-- check for knockback value
		if tool_capabilities.damage_groups["knockback"] then
			damage = tool_capabilities.damage_groups["knockback"]
		end

	end
	-- END tool damage

--	print ("---", player:get_player_name(), damage)

	if not dir then return end

	-- check if player has 'no_knockback' privelage
	local privs = minetest.get_player_privs(player:get_player_name())

	if privs["no_knockback"] then
		return
	end

	local y_offset = mt50 and -10 or 0
	local vel = damage * 2
	local pos = player:get_pos() ; pos.y = pos.y + 1.0
	local ent = minetest.add_entity(pos, "playerplus:temp")
	local obj = ent:get_luaentity()
	local yaw = player:get_look_horizontal() or 0 ; yaw = -yaw * (180 / 3.14) -- pi

	if obj and not player:get_attach() then

		player:set_attach(ent, "", {x = 0, y = y_offset, z = 0}, {x = 0, y = yaw, z = 0})

		ent:set_velocity({
			x = dir.x * vel,
			y = -1,
			z = dir.z * vel
		})

		ent:set_acceleration({
			x = dir.x * -1,
			y = 0,
			z = dir.z * -1
		})

		minetest.after(0.25, function()

			player:set_detach()

			ent:remove()
		end)

	else
		ent:remove()
	end
end

minetest.register_on_punchplayer(punchy)

end -- END if
