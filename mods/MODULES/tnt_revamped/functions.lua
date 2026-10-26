-- Enabled when in singleplayer if un-set.
local enable_tnt = minetest.settings:get_bool("enable_tnt")
if enable_tnt == nil then
	enable_tnt = minetest.is_singleplayer()
end

local tnt_entity_velocity_mul = tonumber(minetest.settings:get("tnt_revamped.tnt_entity_velocity_mul")) or 2
local player_velocity_mul = tonumber(minetest.settings:get("tnt_revamped.player_velocity_mul")) or 10
local entity_velocity_mul = tonumber(minetest.settings:get("tnt_revamped.entity_velocity_mul")) or 10
local tnt_damage_nodes = minetest.settings:get_bool("tnt_revamped.damage_nodes") or false
local tnt_damage_entities = minetest.settings:get_bool("tnt_revamped.damage_entities") or false
local registered_nodes = minetest.registered_nodes
local registered_entities = minetest.registered_entities
local registered_items = minetest.registered_items
local get_node = minetest.get_node
local get_content_id = minetest.get_content_id
local get_node_drops = minetest.get_node_drops
local add_item = minetest.add_item
local is_protected = minetest.is_protected
local get_objects_inside_radius = minetest.get_objects_inside_radius
local check_single_for_falling = minetest.check_single_for_falling
local log = minetest.log
local pos_to_string = minetest.pos_to_string
local sound_play = minetest.sound_play
local add_entity = minetest.add_entity
local get_meta = minetest.get_meta
local set_node = minetest.set_node
local remove_node = minetest.remove_node
local get_node_or_nil = minetest.get_node_or_nil
local chat_send_player = minetest.chat_send_player
local new = vector.new
local equals = vector.equals
local direction = vector.direction
local normalize = vector.normalize
local multiply = vector.multiply
local distance = vector.distance
local divide = vector.divide
local length = vector.length
local round = vector.round
local subtract = vector.subtract
local add = vector.add
local max = math.max
local min = math.min
local random = math.random
local floor = math.floor
local pow = math.pow
local add_effects = tnt.add_effects

-- Fill a list with data for content IDs, after all nodes are registered
local cid_data = {}
minetest.register_on_mods_loaded(function()
	for name, def in pairs(registered_nodes) do
		cid_data[get_content_id(name)] = {
			name = name,
			drops = def.drops,
			flammable = def.groups.flammable,
			on_blast = def.on_blast
		}
	end
end)

local function rand_pos(center, pos, radius)
	local def
	local i = 0
	repeat
		-- Give up and use the center if this takes too long
		if i > 4 then
			pos.x, pos.z = center.x, center.z
			break
		end
		pos.x = center.x + random(-radius, radius)
		pos.z = center.z + random(-radius, radius)
		def = registered_nodes[get_node(pos).name]
		i = i + 1
	until def and not def.walkable
end

local function eject_drops(drops, pos, radius)
	local drop_pos = new(pos)
	for _, item in pairs(drops) do
		local count = min(item:get_count(), item:get_stack_max())
		while count > 0 do
			local take = max(1,min(radius * radius,
					count,
					item:get_stack_max()))
			rand_pos(pos, drop_pos, radius)
			local dropitem = ItemStack(item)
			dropitem:set_count(take)
			local obj = add_item(drop_pos, dropitem)
			if obj then
				obj:get_luaentity().collect = true
				obj:set_acceleration({x = 0, y = -10, z = 0})
				obj:set_velocity({x = random(-3, 3),
						y = random(0, 10),
						z = random(-3, 3)})
			end
			count = count - take
		end
	end
end

local function add_drop(drops, item)
	item = ItemStack(item)
	local name = item:get_name()
	local groups = item:get_definition().groups
	if groups.loss_probability and random(1, groups.loss_probability) == 1 then
		return
	end

	local drop = drops[name]
	if drop == nil then
		drops[name] = item
	else
		drop:set_count(drop:get_count() + item:get_count())
	end
end

local basic_flame_on_construct -- cached value
local function destroy(drops, npos, cid, c_air, c_fire,
		on_blast_queue, on_construct_queue,
		ignore_protection, ignore_on_blast, owner)

	if not ignore_protection and is_protected(npos, owner) then
		return cid
	end

	local def = cid_data[cid]

	if not def then
		return c_air
	elseif not ignore_on_blast and def.on_blast then
		on_blast_queue[#on_blast_queue + 1] = {
			pos = new(npos),
			on_blast = def.on_blast
		}
		return cid
	elseif def.flammable and basic_flame_on_construct then
		on_construct_queue[#on_construct_queue + 1] = {
			fn = basic_flame_on_construct,
			pos = new(npos)
		}
		return c_fire
	else
		local node_drops = get_node_drops(def.name, "")
		for _, item in pairs(node_drops) do
			add_drop(drops, item)
		end
		return c_air
	end
end

local function calc_velocity(pos1, pos2, old_vel, power)
	-- Avoid errors caused by a vector of zero length
	if equals(pos1, pos2) then
		return old_vel
	end

	local vel = direction(pos1, pos2)
	vel = normalize(vel)
	vel = multiply(vel, power)

	-- Divide by distance
	local dist = distance(pos1, pos2)
	dist = max(dist, 1)
	vel = divide(vel, dist)

	-- Limit to terminal velocity
	dist = length(vel)
	if dist > 250 then
		vel = divide(vel, dist / 250)
	end
	return vel
end

local function entity_physics(pos, radius, drops, in_water)
	local objs = get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:get_pos()
		local dist = max(1, distance(pos, obj_pos))

		local damage = (4 / dist) * radius
		if obj:is_player() then
			local obj_vel = obj:get_velocity()
			obj:add_player_velocity(calc_velocity(pos, obj_pos,
					obj_vel, radius * player_velocity_mul))

			if not in_water or (in_water and tnt_damage_entities) then
				local hp = obj:get_hp() - damage
				if hp < 0 then
					hp = 0
				end
				obj:set_hp(hp)
			end
		elseif (obj:get_luaentity() or {}).name ~= "tnt_revamped:empty_tnt_entity" then
			local do_damage = true
			local do_knockback = true
			local entity_drops = {}
			local luaobj = obj:get_luaentity()
			local objdef = registered_entities[luaobj.name]

			if objdef and objdef.on_blast then
				do_damage, do_knockback, entity_drops = objdef.on_blast(luaobj, damage)
			end

			if do_knockback then
				local obj_vel = obj:get_velocity()
				obj:add_velocity(calc_velocity(pos, obj_pos,
						obj_vel, radius * entity_velocity_mul))
			end

			if do_damage and (not in_water or (in_water and tnt_damage_entities)) then
				if not obj:get_armor_groups().immortal then
					obj:punch(obj, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy = damage},
					}, nil)
				end
			end

			for _, item in pairs(entity_drops) do
				add_drop(drops, item)
			end
		else
			obj:get_luaentity().flow_check_step = 0
			local obj_vel = obj:get_velocity()
			obj:add_velocity(calc_velocity(pos, obj_pos, obj_vel, radius * tnt_entity_velocity_mul))
		end
	end
end

local function tnt_explode(pos, radius, ignore_protection, ignore_on_blast, owner, explode_center, in_water)
	
	if in_water == nil then
		in_water = false
	end

	-- recalculate new radius
	radius = floor(radius * pow(1, 1/3))

	if not in_water or tnt_damage_nodes then
	
		pos = round(pos)
		local p1 = subtract(pos, 2)
		local p2 = add(pos, 2)
		local count = 0
		local c_air = get_content_id("air")
		
		count = 1

		-- perform the explosion
		local vm = VoxelManip()
		local pr = PseudoRandom(os.time())
		p1 = subtract(pos, radius)
		p2 = add(pos, radius)
		local minp, maxp = vm:read_from_map(p1, p2)
		local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
		local data = vm:get_data()

		local drops = {}
		local on_blast_queue = {}
		local on_construct_queue = {}
		local c_fire

		if registered_nodes["fire:basic_flame"] then
			basic_flame_on_construct = registered_nodes["fire:basic_flame"].on_construct
			c_fire = get_content_id("fire:basic_flame")
		end
		for z = -radius, radius do
			for y = -radius, radius do
			local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
				for x = -radius, radius do
					local r = length(new(x, y, z))
					if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
						local cid = data[vi]
						local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
						if cid ~= c_air then
							data[vi] = destroy(drops, p, cid, c_air, c_fire,
								on_blast_queue, on_construct_queue,
								ignore_protection, ignore_on_blast, owner)
						end
					end
					vi = vi + 1
				end
			end
		end
	
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
		vm:update_liquids()

		-- call check_single_for_falling for everything within 1.5x blast radius
		for y = -radius * 1.5, radius * 1.5 do
			for z = -radius * 1.5, radius * 1.5 do
				for x = -radius * 1.5, radius * 1.5 do
					local rad = {x = x, y = y, z = z}
					local s = add(pos, rad)
					local r = length(rad)
					if r / radius < 1.4 then
						check_single_for_falling(s)
					end
				end
			end
		end

		for _, queued_data in pairs(on_blast_queue) do
			local dist = max(1, distance(queued_data.pos, pos))
			local intensity = (radius * radius) / (dist * dist)
			local node_drops = queued_data.on_blast(queued_data.pos, intensity, pos)
			if node_drops then
				for _, item in pairs(node_drops) do
					add_drop(drops, item)
				end
			end
		end

		for _, queued_data in pairs(on_construct_queue) do
			queued_data.fn(queued_data.pos)
		end

		log("action", "TNT owned by " .. owner .. " detonated at " ..
			pos_to_string(pos) .. " with radius " .. radius)

		return drops, radius
	end

	log("action", "TNT owned by " .. owner .. " detonated at " ..
		pos_to_string(pos) .. " with radius " .. radius)

	return {}, radius
end

function tnt.boom(pos, def, owner, in_water)
	local def1 = def or {}
	def1.radius = def.radius or 1
	def1.damage_radius = def.damage_radius or def.radius * 2
	if not owner then
		owner = "<Unknown>"
	end
	if def.boom_sound then
		if not def.boom_sound.def then
			def.boom_sound.def = {}
		end
		def.boom_sound.def.pos = pos
		sound_play(def.boom_sound.name, def.boom_sound.def)
	end
	local drops, radius = tnt_explode(pos, def1.radius, def1.ignore_protection,
			def1.ignore_on_blast, owner, def1.explode_center, in_water)
	-- append entity drops
	local damage_radius = (radius / max(1, def1.radius)) * def1.damage_radius
	entity_physics(pos, damage_radius, drops, in_water)
	if not def1.disable_drops then
		eject_drops(drops, pos, radius)
	end
	add_effects(pos, radius, drops)
	log("action", "A TNT explosion occurred at " .. pos_to_string(pos) ..
		" with radius " .. radius)
end

function tnt.create_entity(pos, def, owner)
	local obj = add_entity(pos, "tnt_revamped:empty_tnt_entity")
	local ent = obj:get_luaentity()

	if ent then
		local old_meta = get_meta(pos)
		
		if not owner then
			owner = old_meta:get_string("owner")
		end
		
		ent.owner = owner

		obj:set_acceleration({x = 0, y = -10, z = 0})

		if def.jump then
			obj:set_velocity({x = 0, y = def.jump, z = 0})
		end
		
		local oldnode = old_meta:get_string("oldnode")
		local old_param2 = old_meta:get_string("old_param2")

		if oldnode ~= "" and old_param2 ~= "" then
			set_node(pos, {name = oldnode, param2 = tonumber(old_param2)})
			ent.flow = true
		elseif oldnode ~= "" then
			set_node(pos, {name = oldnode})
		else
			remove_node(pos)
		end

		obj:set_properties({textures = def.entity_tiles, visual = "cube", visual_size = def.visual_size})

		ent:setup(def)
	end

	return obj
end

local create_entity = tnt.create_entity

function tnt.register_tnt(def)
	local name
	if not def.name:find(':') then
		name = "tnt:" .. def.name
	else
		name = def.name
		def.name = def.name:match(":([%w_]+)")
	end
	if not def.tiles then def.tiles = {} end
	local tnt_top = def.tiles.top or def.name .. "_top.png"
	local tnt_bottom = def.tiles.bottom or def.name .. "_bottom.png"
	local tnt_side = def.tiles.side or def.name .. "_side.png"
	local tnt_burning = def.tiles.burning or def.name .. "_top_burning.png"
	if not def.damage_radius then def.damage_radius = def.radius * 2 end
	if not def.time then def.time = 4 end
	if not def.jump then def.jump = 3 end
	if not def.visual_size then def.visual_size = {x = 1, y = 1, z = 1} end
	
	if enable_tnt then
		local function ignite_sound_func(pos)
			if def.ignite_sound then
				if not def.ignite_sound.def then
					def.ignite_sound.def = {}
				end
				def.ignite_sound.def.pos = pos
				sound_play(def.ignite_sound.name, def.ignite_sound.def)
			end
		end

		local tiles = {tnt_burning,
				tnt_bottom, tnt_side, tnt_side, tnt_side, tnt_side
		}

		if not def.entity_tiles then def.entity_tiles = tiles end

		local function convert_to_entity(pos, def)
			local meta = get_meta(pos)
			local name = meta:get_string("owner") or nil
			create_entity(pos, def, name)

			ignite_sound_func(pos)
		end
		
		local node_def = {
			description = def.description,
			tiles = {tnt_top, tnt_bottom, tnt_side},
			is_ground_content = false,
			groups = {dig_immediate = 2, mesecon = 2, tnt = 1, flammable = 5, explosive = def.radius, blast_resistance = 25, strength = def.strength},
			after_place_node = function(pos, placer)
				if placer:is_player() then
					local meta = get_meta(pos)
					meta:set_string("owner", placer:get_player_name())
				end
			end,
			on_punch = function(pos, node, puncher)
				local item_name = puncher:get_wielded_item():get_name()
				local player_name = puncher:get_player_name()
				if registered_items[item_name].groups.torch then
					if is_protected(pos, player_name) then
						chat_send_player(player_name, "This area is protected")
						return
					end
					convert_to_entity(pos, def)
				end
			end,
			on_blast = function(pos, intensity, blaster)
				convert_to_entity(pos, def)
			end,
			on_blast_break = function(pos)
				convert_to_entity(pos, def)
			end,
			mesecons = {effector =
				{action_on =
					function(pos)
						convert_to_entity(pos, def)
					end
				}
			},
			on_burn = function(pos)
				convert_to_entity(pos, def)
			end,
			on_ignite = function(pos, igniter)
				convert_to_entity(pos, def)
			end,
		}

		if not registered_nodes[name] then
			minetest.register_node(":" .. name, node_def)
		else
			minetest.override_item(name, node_def)
		end
	end
end

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local groups = registered_nodes[newnode.name].groups
	
	if groups.tnt or groups.volatile then
		local meta = get_meta(pos)
		local name = oldnode.name
		local def = registered_items[name]
		
		if def.liquidtype == "flowing" then
			meta:set_string("oldnode", name)
			meta:set_string("old_param2", oldnode.param2)
		else
			meta:set_string("oldnode", name)
		end
	end
end)
