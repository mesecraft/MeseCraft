radiant_damage = {} --create a container for functions and constants

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/config.lua")

-- damage_def:
--{
--	interval = 1, -- number of seconds between each damage check
--	range = 3, -- range of the damage. Can be omitted if inverse_square_falloff is true, in that case it defaults to the range at which 1 point of damage is done by the most damaging emitter node type.
--	emitted_by = {}, -- nodes that emit this damage. At least one is required.
--	attenuated_by = {} -- This allows certain intervening node types to modify the damage that radiates through it. Note: Only works in Minetest version 0.5 and above.
--	default_attenuation = 1, -- the amount the damage is multiplied by when passing through any other non-air nodes. Note that in versions before Minetest 0.5 any value other than 1 will result in total occlusion (ie, any non-air node will block all damage)
--	inverse_square_falloff = true, -- if true, damage falls off with the inverse square of the distance. If false, damage is constant within the range.
--	above_only = false, -- if true, damage only propagates directly upward. Useful for when you want to damage players that stand on the node.
--	on_damage = function(player_object, damage_value, pos) -- An optional callback to allow mods to do custom behaviour. If this is set to non-nil then the default damage will *not* be done to the player, it's up to the callback to handle that.
--}

-- emitted_by has the following format:
-- {["default:stone_with_mese"] = 2, ["default:mese"] = 9}
-- where the value associated with each entry is the amount of damage dealt. Groups are permitted. Note that negative damage represents "healing" radiation.
-- attenuated_by has the following similar format:
-- {["group:stone"] = 0.25, ["default:steelblock"] = 0}
-- where the value is a multiplier that is applied to the damage passing through it. Groups are permitted. Note that you can use values greater than one to make a node type magnify damage instead of attenuating it.


-- Commmon function for looking up an emitted_by or attenuated_by value for a node
local get_val = function(node_name, target_names, target_groups)
	if target_names then
		local name_val = target_names[node_name]
		if name_val ~= nil then return name_val end
	end
	
	if target_groups then
		local node_def = minetest.registered_nodes[node_name]
		local node_groups = node_def.groups
		if node_groups then
			for group, _ in pairs(node_groups) do
				local group_val = target_groups[group]
				if group_val ~= nil then return group_val end -- returns the first group value it finds, if multiple apply it's undefined which will be selected
			end
		end
	end
	
	return nil
end

local attenuation_check

if Raycast ~= nil then -- version 0.5 of Minetest adds the Raycast class, use that.

-- Gets three raycasts from the faces of the nodes facing the player.
local get_raycasts = function(node_pos, player_pos)
	local results = {}
	if player_pos.x > node_pos.x then
		table.insert(results, Raycast({x=node_pos.x+0.51, y=node_pos.y, z=node_pos.z}, player_pos, false, true))
	else
		table.insert(results, Raycast({x=node_pos.x-0.51, y=node_pos.y, z=node_pos.z}, player_pos, false, true))
	end

	if player_pos.y > node_pos.y then
		table.insert(results, Raycast({y=node_pos.y+0.51, x=node_pos.x, z=node_pos.z}, player_pos, false, true))
	else
		table.insert(results, Raycast({y=node_pos.y-0.51, x=node_pos.x, z=node_pos.z}, player_pos, false, true))
	end

	if player_pos.z > node_pos.z then
		table.insert(results, Raycast({z=node_pos.z+0.51, x=node_pos.x, y=node_pos.y}, player_pos, false, true))
	else
		table.insert(results, Raycast({z=node_pos.z-0.51, x=node_pos.x, y=node_pos.y}, player_pos, false, true))
	end
	return results
end

attenuation_check = function(node_pos, player_pos, default_attenuation, attenuation_nodes, attenuation_groups)

	-- First check a simple degenerate case; if there are no special modifier nodes and the default attenuation
	-- is 1 then we don't need to bother with any detailed checking, the damage goes through unmodified.
	if default_attenuation == 1 and attenuation_nodes == nil and attenuation_groups == nil then return 1 end

	local raycasts = get_raycasts(node_pos, player_pos)
	
	local farthest_from_zero = 0
	for _, raycast in pairs(raycasts) do
		local current_attenuation = 1
		for ray_node in raycast do
			local ray_node_name = minetest.get_node(ray_node.under).name
			local ray_node_val = get_val(ray_node_name, attenuation_nodes, attenuation_groups)
			if ray_node_val == nil then ray_node_val = default_attenuation end
			current_attenuation = current_attenuation * ray_node_val
			if current_attenuation == 0 then break end -- once we hit zero no further checks are needed, it will never change.
		end
		
		-- By always selecting the farthest value from zero we accomodate both "healing" and "harmful" radiation
		-- and always let the most impactful value of either type through.
		-- If you've got both positive and negative modifiers (for example, if you've got a magical node that turns
		-- harmful radiation into healing radiation when it passes through) this could result in somewhat erratic effects.
		-- But that's part of the fun, eh? Players will just need to design and use their healing ray carefully.
		if math.abs(current_attenuation) > math.abs(farthest_from_zero) then
			farthest_from_zero = current_attenuation
		end		
	end
	return farthest_from_zero
end

else

-- Pre-Minetest 0.5 version. Attenuation_nodes and attenuation_groups are ignored
attenuation_check = function(node_pos, player_pos, default_attenuation, attenuation_nodes, attenuation_groups)

	if default_attenuation == 1 then return 1 end -- if default_attenuation is 1, don't attenuate.
	
	-- otherwise, it's all-or-nothing:	
	if player_pos.y > node_pos.y then
		if minetest.line_of_sight({y=node_pos.y+0.51, x=node_pos.x, z=node_pos.z}, player_pos) then return 1 end
	else
		if minetest.line_of_sight({y=node_pos.y-0.51, x=node_pos.x, z=node_pos.z}, player_pos) then return 1 end
	end

	if player_pos.x > node_pos.x then
		if minetest.line_of_sight({x=node_pos.x+0.51, y=node_pos.y, z=node_pos.z}, player_pos) then return 1 end
	else
		if minetest.line_of_sight({x=node_pos.x-0.51, y=node_pos.y, z=node_pos.z}, player_pos) then return 1 end
	end

	if player_pos.z > node_pos.z then
		if minetest.line_of_sight({z=node_pos.z+0.51, x=node_pos.x, y=node_pos.y}, player_pos) then return 1 end
	else
		if minetest.line_of_sight({z=node_pos.z-0.51, x=node_pos.x, y=node_pos.y}, player_pos) then return 1 end
	end
	return 0
end

end

radiant_damage.registered_damage_types = {}

-- This method will update the registered_damage_types table with new values, keeping all the parameters
-- consistent and in proper relation to each other.
local update_damage_type = function(damage_name, new_def)

	if radiant_damage.registered_damage_types[damage_name] == nil then
		radiant_damage.registered_damage_types[damage_name] = {}
	end
	local damage_def = radiant_damage.registered_damage_types[damage_name]
	
	-- Interval
	if new_def.interval ~= nil then
		damage_def.interval = new_def.interval
	elseif damage_def.interval == nil then
		damage_def.interval = 1
	end
	
	-- Inverse square falloff
	if new_def.inverse_square_falloff ~= nil then
		damage_def.inverse_square_falloff = new_def.inverse_square_falloff
	elseif damage_def.inverse_square_falloff == nil then
		damage_def.inverse_square_falloff = true
	end
	
	-- Default attenuation value
	if new_def.default_attenuation ~= nil then
		damage_def.default_attenuation = new_def.default_attenuation
	elseif damage_def.default_attenuation == nil then
		damage_def.default_attenuation = 0
	end
	
	-- Above Only
	damage_def.above_only = new_def.above_only -- default to false

	-- on_damage callback
	damage_def.on_damage = new_def.on_damage
	
	-- it is efficient to split the emission and attenuation data into separate node and group maps.
	
	-- Emitted by
	damage_def.emission_nodes = damage_def.emission_nodes or {}
	damage_def.emission_groups = damage_def.emission_groups or {}
	for nodename, damage in pairs(new_def.emitted_by) do
		if damage == 0 then damage = nil end -- causes removal of damage-0 node types
		if string.sub(nodename, 1, 6) == "group:" then
			damage_def.emission_groups[string.sub(nodename, 7)] = damage -- omit the "group:" prefix
		else
			damage_def.emission_nodes[nodename] = damage
		end
	end
	
	damage_def.nodenames = damage_def.nodenames or {} -- for use with minetest.find_nodes_in_area
	for nodename, damage in pairs(new_def.emitted_by) do
		local handled = false
		for i, v in ipairs(damage_def.nodenames) do
			if v == nodename then
				if damage == 0 then
					table.remove(damage_def.nodenames, i)
				end
				handled = true
				break
			end
		end
	
		if not handled then
			table.insert(damage_def.nodenames, nodename)
		end
	end

	-- These remain nil unless some valid data is provided.
	if new_def.attenuated_by and Raycast then
		for nodename, attenuation in pairs(new_def.attenuated_by) do
			damage_def.attenuation_nodes = damage_def.attenuation_nodes or {}
			damage_def.attenuation_groups = damage_def.attenuation_groups or {}		
			if string.sub(nodename, 1, 6) == "group:" then
				damage_def.attenuation_groups[string.sub(nodename, 7)] = attenuation -- omit the "group:" prefix
			else
				damage_def.attenuation_nodes[nodename] = attenuation
			end
		end
	end	

	-- remove any attenuation nodes or groups that match the default attenuation, they're pointless.
	if damage_def.attenuation_groups then
		for node, attenuation in pairs(damage_def.attenuation_groups) do
			if attenuation == damage_def.default_attenuation then
				damage_def.attenuation_groups[node] = nil
			end
		end
	end
	if damage_def.attenuation_nodes then
		for node, attenuation in pairs(damage_def.attenuation_nodes) do
			if attenuation == damage_def.default_attenuation then
				damage_def.attenuation_nodes[node] = nil
			end
		end
	end

	-- Range
	if new_def.range ~= nil then
		damage_def.absolute_range = true
		damage_def.range = new_def.range
	elseif damage_def.inverse_square_falloff and not damage_def.absolute_range then
		damage_def.range = 0
		for _, damage in pairs(damage_def.emission_nodes) do
			damage_def.range = math.max(math.sqrt(math.abs(damage*8)), damage_def.range) -- use the maximum damage-dealer to determine range.
		end
		for _, damage in pairs(damage_def.emission_groups) do
			damage_def.range = math.max(math.sqrt(math.abs(damage*8)), damage_def.range) -- use the maximum damage-dealer to determine range.
		end
	end

	return damage_def
end

radiant_damage.override_radiant_damage = function(damage_name, damage_def)
	if radiant_damage.registered_damage_types[damage_name] then
		update_damage_type(damage_name, damage_def)
	elseif minetest.settings:get_bool("enable_damage") then
		minetest.log("error", "Attempt was made to override unregistered radiant_damage type " .. damage_name)
	end
end

radiant_damage.register_radiant_damage = function(damage_name, damage_def)
	if not minetest.settings:get_bool("enable_damage") then return end -- don't bother if enable_damage isn't set.
	
	if radiant_damage.registered_damage_types[damage_name] then
		minetest.log("error", "Attempt was made to register the already-registered radiant_damage type " .. damage_name)
		return
	end

	local damage_def = update_damage_type(damage_name, damage_def)

	local range = damage_def.range
	local above_only = damage_def.above_only
	local nodenames = damage_def.nodenames
	local default_attenuation = damage_def.default_attenuation
	local attenuation_nodes = damage_def.attenuation_nodes
	local attenuation_groups = damage_def.attenuation_groups
	local emission_nodes = damage_def.emission_nodes
	local emission_groups = damage_def.emission_groups
	local inverse_square_falloff = damage_def.inverse_square_falloff
	local on_damage = damage_def.on_damage
	local interval = damage_def.interval
	
	local timer = 0

	minetest.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer >= interval then
			timer = timer - interval
			
			for _, player in pairs(minetest.get_connected_players()) do
				local player_pos = player:get_pos() -- node player's feet are in this location. Add 1 to y to get chest height, more intuitive that way
				player_pos.y = player_pos.y + 1

				local rounded_pos = vector.round(player_pos)
				local nearby_nodes
				if above_only then
					nearby_nodes = minetest.find_nodes_in_area(vector.add(rounded_pos, {x=0, y= -range, z=0}), rounded_pos, nodenames)
				else
					nearby_nodes = minetest.find_nodes_in_area(vector.add(rounded_pos, -range), vector.add(rounded_pos, range), nodenames)
				end
				
				local total_damage = 0
				
				for _, node_pos in ipairs(nearby_nodes) do
					local distance
					if above_only then
						distance = math.max(player_pos.y - node_pos.y, 1)
					else
						distance = math.max(vector.distance(player_pos, node_pos), 1) -- clamp to 1 to avoid inverse falloff causing crazy huge damage when standing inside a node
					end
					
					if distance <= range then
						local attenuation = attenuation_check(node_pos, player_pos, default_attenuation, attenuation_nodes, attenuation_groups)
						if attenuation ~= 0 then
							local damage = get_val(minetest.get_node(node_pos).name, emission_nodes, emission_groups)
							if inverse_square_falloff then
								total_damage = total_damage + (damage / (distance * distance)) * attenuation
							else
								total_damage = total_damage + damage * attenuation
							end
						end
					end
				end	

				if on_damage == nil then
					total_damage = math.floor(total_damage)
					if total_damage ~= 0 then
						minetest.log("action", player:get_player_name() .. " takes " .. tostring(total_damage) .. " damage from " .. damage_name .. " radiant damage at " .. minetest.pos_to_string(rounded_pos))
						player:set_hp(player:get_hp() - total_damage)
					end
				else
					on_damage(player, total_damage, rounded_pos)
				end
			end
		end
	end)
end

if radiant_damage.config.enable_heat_damage then
	local on_fire_damage
	if minetest.get_modpath("3d_armor") and armor ~= nil then
		-- 3d_armor uses a strange fire protection system different from all the rest, wherein
		-- its armor protects wholly against some heat sources and not at all against others
		-- based on how "hot" they are and how strong against fire the armor is.
		-- Level 1 protects against a wall torch, level 3 protects against a basic fire, and level 5 protects against lava.
		
		-- Converting this into a standard armor type is going to require some arbitrary decisions.
		-- My decision is: level 5 protection should reduce the default damage from lava immersion from 8 to 0.5 hp (0.0625 multiplier).
		-- Level 3 protection reduces the default damage from basic flame from 4 to 0.5 hp (0.125 multiplier)
		-- Torches don't do damage in default so I will ignore that.
		-- Level 0 has a damage multiplier of 1.
		
		-- That gives us three data points: (0,1), (3,0.125), (5,0.0625). Fitting that to an exponential curve gives us:
		-- y = 0.0481417 + 0.9518583*e^(-0.8388176*x)
		-- Which looks about right on a graph, and "looks about right on a graph" is good enough for me.
		on_fire_damage = function(player, damage, pos)
			local fire_protection = armor.def[player:get_player_name()].fire
			local fire_multiplier = 1
			if fire_protection then
				fire_multiplier = math.min(1, 0.0481417 + 0.9518583 * math.exp(-0.8388176*fire_protection))
			end
			-- If the player also has conventional fire armor, use whatever's better.
			local fire_armor = player:get_armor_groups().fire
			if fire_armor then
				fire_multiplier = math.min(fire_multiplier, fire_armor/100)
			end
			damage = math.floor(damage * fire_multiplier)
			if damage > 0 then
				minetest.log("action", player:get_player_name() .. " takes " .. tostring(damage) .. " damage from heat radiant damage at " .. minetest.pos_to_string(pos))
				player:set_hp(player:get_hp() - damage)
				minetest.sound_play("radiant_damage_sizzle", {gain = math.min(1, damage/10), pos=pos})
			end
		end
	else
		on_fire_damage = function(player, damage, pos)
			local fire_armor = player:get_armor_groups().fire
			if fire_armor then
				damage = damage * fire_armor / 100
			end
			damage = math.floor(damage)
			if damage > 0 then
				minetest.log("action", player:get_player_name() .. " takes " .. tostring(damage) .. " damage from heat radiant damage at " .. minetest.pos_to_string(pos))
				player:set_hp(player:get_hp() - damage)
				minetest.sound_play("radiant_damage_sizzle", {gain = math.min(1, damage/10), pos=pos})
			end
		end
	end
		
	radiant_damage.register_radiant_damage("heat", {
		interval = 1,
		emitted_by = {["group:lava"] = radiant_damage.config.lava_damage, ["fire:basic_flame"] = radiant_damage.config.fire_damage, ["fire:permanent_flame"] = radiant_damage.config.fire_damage},
		inverse_square_falloff = true,
		default_attenuation = 0, -- heat is blocked by anything.
		on_damage = on_fire_damage,
	})
end

if radiant_damage.config.enable_mese_damage then

local shields = {"default:steelblock", "default:copperblock", "default:tinblock", "default:bronzeblock", "default:goldblock"}
local amplifiers = {"default:diamondblock", "default:coalblock"}

for _, shielding_node in ipairs(shields) do
	local node_def = minetest.registered_nodes[shielding_node]
	if node_def then
		local new_groups = node_def.groups or {}
		new_groups.mese_radiation_shield = 1
		minetest.override_item(shielding_node, {groups=new_groups})
	end
end
for _, amp_node in ipairs(amplifiers) do
	local node_def = minetest.registered_nodes[amp_node]
	if node_def then
		local new_groups = node_def.groups or {}
		new_groups.mese_radiation_amplifier = 1
		minetest.override_item(amp_node, {groups=new_groups})
	end
end

-- MeseCraft: tell players what is hurting them, at most once a minute (issue #69).
local last_radiation_notice = {}
local function notify_radiation(player)
	local name = player:get_player_name()
	local now = minetest.get_gametime()
	if (last_radiation_notice[name] or -60) + 60 <= now then
		last_radiation_notice[name] = now
		minetest.chat_send_player(name, minetest.colorize("#9fff6a",
			"Mese radiation is hurting you. Mese ore nearby is the source; more stone between you and it blocks it."))
	end
end

local on_radiation_damage = function(player, damage, pos)
	local radiation_multiplier = player:get_armor_groups().radiation
	if radiation_multiplier then
		damage = damage * radiation_multiplier / 100
	end
	damage = math.floor(damage)
	if damage > 0 then
		minetest.log("action", player:get_player_name() .. " takes " .. tostring(damage) .. " damage from mese radiation damage at " .. minetest.pos_to_string(pos))
		player:set_hp(player:get_hp() - damage)
		notify_radiation(player)
		minetest.sound_play({name = "radiant_damage_geiger", gain = math.min(1, damage/10)}, {to_player=player:get_player_name()})
	end
end

radiant_damage.register_radiant_damage("mese", {
	interval = radiant_damage.config.mese_interval,
	inverse_square_falloff = true,
	emitted_by = {["default:stone_with_mese"] = radiant_damage.config.mese_damage, ["default:mese"] = radiant_damage.config.mese_damage * 9},
	attenuated_by = {["group:stone"] = 0.5, ["group:mese_radiation_shield"] = 0.1, ["group:mese_radiation_amplifier"] = 4},
	default_attenuation = 0.9,
	on_damage = on_radiation_damage,
})
end



