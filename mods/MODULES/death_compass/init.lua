-- compass configuration interface - adjustable from other mods or minetest.conf settings
death_compass = {}

local S = minetest.get_translator("death_compass")
 
 -- how many seconds does the death compass work for? 0 for indefinite
local duration = tonumber(minetest.settings:get("death_compass_duration")) or 30
local automatic = minetest.settings:get_bool("death_compass_automatic", false)

local range_to_inactivate = 5

local hud_position = {
	x= tonumber(minetest.settings:get("death_compass_hud_x")) or 0.5,
	y= tonumber(minetest.settings:get("death_compass_hud_y")) or 0.9,
}
local hud_color = tonumber("0x" .. (minetest.settings:get("death_compass_hud_color") or "FFFF00")) or 0xFFFF00

-- If round is true the return string will only have the two largest-scale values
local function clock_string(seconds, round)
	seconds = math.floor(seconds)
	local days = math.floor(seconds/86400)
	seconds = seconds - days*86400
	local hours = math.floor(seconds/3600)
	seconds = seconds - hours*3600
	local minutes = math.floor(seconds/60)
	seconds = seconds - minutes*60

	local ret = {}
	if days == 1 then
		table.insert(ret, S("1 day"))
	elseif days > 1 then
		table.insert(ret, S("@1 days", days))
	end
	if hours == 1 then
		table.insert(ret, S("1 hour"))
	elseif hours > 1 then
		table.insert(ret, S("@1 hours", hours))
	end
	if minutes == 1 then
		table.insert(ret, S("1 minute"))
	elseif minutes > 1 then
		table.insert(ret, S("@1 minutes", minutes))
	end
	if seconds == 1 then
		table.insert(ret, S("1 second"))
	elseif seconds > 1 then
		table.insert(ret, S("@1 seconds", seconds))
	end
	
	if #ret == 0 then
		return S("@1 seconds", 0)
	end
	if #ret == 1 then
		return ret[1]
	end
	if round or #ret == 2 then
		return S("@1 and @2", ret[1], ret[2])
	end
	
	return table.concat(ret, S(", "))
end

local documentation = S("This does nothing in its current inert state. If you have this in your inventory when you die, however, it will follow you into your next life's inventory and point toward the location of your previous life's end.")
local durationdesc
if duration > 0 then
	durationdesc = S("The Death Compass' guidance will only last for @1 after death.", clock_string(duration, false))
else
	durationdesc = S("The Death Compass will point toward your corpse until you find it.")
end

-- set a position to the compass stack
local function set_target(stack, pos, name)
	local meta=stack:get_meta()
	meta:set_string("target_pos", minetest.pos_to_string(pos))
	meta:set_string("target_corpse", name)
	meta:set_int("time_of_death", minetest.get_gametime())
end

-- Get compass target
local function get_destination(player, stack)
	local posstring = stack:get_meta():get_string("target_pos")
	if posstring ~= "" then
		return minetest.string_to_pos(posstring)
	end
end

-- looped ticking sound if there's a duration on this
local player_ticking = {}
local function start_ticking(player_name)
	if not player_ticking[player_name] then
		player_ticking[player_name] = minetest.sound_play("death_compass_tick_tock",
			{to_player = player_name, gain = 0.125, loop = true})
	end
end
local function stop_ticking(player_name)
	local tick_tock_handle = player_ticking[player_name]
	if tick_tock_handle then
		minetest.sound_stop(tick_tock_handle)
		player_ticking[player_name] = nil
	end
end

local player_huds = {}
local function hide_hud(player, player_name)
	local id = player_huds[player_name]
	if id then
		player:hud_remove(id)
		player_huds[player_name] = nil
	end
end
local function update_hud(player, player_name, compass)
	local metadata = compass:get_meta()

	local target_pos = minetest.string_to_pos(metadata:get_string("target_pos"))
	local player_pos = player:get_pos()
	local distance = vector.distance(player_pos, target_pos)
	if not target_pos then
		return
	end

	local time_of_death = metadata:get_int("time_of_death")
	local target_name = metadata:get_string("target_corpse")

	local description
	if duration > 0 then
		local remaining = time_of_death + duration - minetest.get_gametime()
		if remaining < 0 then
			return
		end
		description = S("@1m to @2's corpse, @3 remaining", math.floor(distance),
			target_name, clock_string(remaining, true))
	else
		description = S("@1m to @2's corpse, died @3 ago", math.floor(distance),
			target_name, clock_string(minetest.get_gametime() - time_of_death, true))
	end

	local id = player_huds[player_name]
	if not id then
		id = player:hud_add({
			type = "text",
			position = hud_position,
			text = description,
			number = hud_color,
			scale = 20,
		})
		player_huds[player_name] = id
	else
		player:hud_change(id, "text", description)
	end
end

-- get right image number for players compass
local function get_compass_stack(player, stack)
	local target = get_destination(player, stack)
	local inactive_return
	if automatic then
		inactive_return = ItemStack("")
	else
		inactive_return = ItemStack("death_compass:inactive")
	end	
	
	if not target then
		return inactive_return
	end
	local pos = player:get_pos()
	local distance = vector.distance(pos, target)
	local player_name = player:get_player_name()
	
	if distance < range_to_inactivate then
		stop_ticking(player_name)
		minetest.sound_play("death_compass_bone_crunch", {to_player=player_name, gain = 1.0})
		return inactive_return
	end
	
	local dir = player:get_look_horizontal()
	local angle_north = math.deg(math.atan2(target.x - pos.x, target.z - pos.z))
	if angle_north < 0 then
		angle_north = angle_north + 360
	end
	local angle_dir = math.deg(dir)
	local angle_relative = (angle_north + angle_dir) % 360
	local compass_image = math.floor((angle_relative/22.5) + 0.5)%16

	-- create new stack with metadata copied
	local metadata = stack:get_meta():to_table()
	local meta_fields = metadata.fields
	local time_of_death = tonumber(meta_fields.time_of_death)

	if duration > 0 then
		local remaining = time_of_death + duration - minetest.get_gametime()
		if remaining < 0 then
			stop_ticking(player_name)
			minetest.sound_play("death_compass_bone_crunch", {to_player=player_name, gain = 1.0})
			return inactive_return
		end
		start_ticking(player_name)
	end

	local newstack = ItemStack("death_compass:dir"..compass_image)
	if metadata then
		newstack:get_meta():from_table(metadata)
	end
	return newstack
end

-- update inventory and hud
minetest.register_globalstep(function(dtime)
	for i, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local compass_in_quickbar
		local inv = player:get_inventory()
		if inv then
			for i, stack in ipairs(inv:get_list("main")) do
				if i > 8 then
					break
				end
				if string.sub(stack:get_name(), 0, 17) == "death_compass:dir" then
					player:get_inventory():set_stack("main", i, get_compass_stack(player, stack))
					compass_in_quickbar = true
				end
			end
			if compass_in_quickbar then
				local wielded = player:get_wielded_item()
				if string.sub(wielded:get_name(), 0, 17) == "death_compass:dir" then
					update_hud(player, player_name, wielded)
				else
					hide_hud(player, player_name)
				end
			end
		end
		if not compass_in_quickbar then
			stop_ticking(player_name)
			hide_hud(player, player_name)
		end
	end
end)

-- register items
for i = 0, 15 do
	local image = "death_compass_16_"..i..".png"
	minetest.register_craftitem("death_compass:dir"..i, {
		description = S("Death Compass"),
		inventory_image = image,
		wield_image = image,
		stack_max = 1,
		groups = {death_compass = 1, not_in_creative_inventory = 1},
	})
end

if not automatic then
	local display_doc = function(itemstack, user)
		local player_name = user:get_player_name()
		minetest.chat_send_player(player_name, documentation .. "\n" .. durationdesc)
	end

	minetest.register_craftitem("death_compass:inactive", {
		description = S("Death Compass"),
		_doc_items_longdesc = documentation,
		_doc_items_usagehelp = durationdesc,
		inventory_image = "death_compass_inactive.png",
		wield_image = "death_compass_inactive.png",
		stack_max = 1,
        on_place = display_doc,
        on_secondary_use = display_doc,
	})

	minetest.register_craft({
		output = 'death_compass:inactive',
		recipe = {
			{'', 'mesecraft_bones:bones', ''},
			{'mesecraft_bones:bones', 'default:mese_crystal_fragment', 'mesecraft_bones:bones'},
			{'', 'mesecraft_bones:bones', ''}
		}
	})
	
	-- Allow a player to deliberately deactivate a death compass
	minetest.register_craft({
		output = 'death_compass:inactive',
        type = "shapeless",
        recipe = {
            'group:death_compass',
		}
	})

end

local player_death_location = {}
minetest.register_on_dieplayer(function(player, reason)
	local player_name = player:get_player_name()
	local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	local list = inv:get_list("main")
	local count = 0
	if automatic then
		count = 1
	else
		for i, itemstack in pairs(list) do
			if itemstack:get_name() == "death_compass:inactive" then
				count = count + itemstack:get_count()
				list[i] = ItemStack("")
			end
		end
	end
	if count > 0 then
		inv:set_list("main", list)
		player_death_location[player_name] = {count=count,pos=player:get_pos()}
	end
	
end)
-- Run before bones mods: otherwise the compass is moved into the bones with the rest of
-- the inventory and never activates.
table.insert(minetest.registered_on_dieplayers, 1, table.remove(minetest.registered_on_dieplayers))
-- Called when a player dies
-- `reason`: a PlayerHPChangeReason table, see register_on_player_hpchange

minetest.register_on_respawnplayer(function(player)
	local player_name = player:get_player_name()
	local compasses = player_death_location[player_name]
	if compasses then
		local inv = minetest.get_inventory({type="player", name=player_name})
		
		-- Remove any death compasses they might still have for some reason
		local current = inv:get_list("main")
		for i, item in pairs(current) do
			if item:get_name() == "death_compass:inactive" then
				current[i] = ItemStack("")
			end
		end
		inv:set_list("main", current)
		
		-- give them new compasses pointing to their place of death
		for i = 1, compasses.count do
			local compass = ItemStack("death_compass:dir0")
			set_target(compass, compasses.pos, player_name)
			inv:add_item("main", compass)
		end
	end
	return false
end)
--    * Called when player is to be respawned
--    * Called _before_ repositioning of player occurs
--    * return true in func to disable regular player placement
