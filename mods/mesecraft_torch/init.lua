
-- Realistic Torch mod by TenPlus1

mesecraft_torch = {}

-- check for timer settings or use defaults
mesecraft_torch.min_duration = tonumber(minetest.settings:get("torch_min_duration")) or 1200
mesecraft_torch.max_duration = tonumber(minetest.settings:get("torch_max_duration")) or 1800


-- check which torch(es) are available in minetest version
if minetest.registered_nodes["default:torch_ceiling"] then

	dofile(minetest.get_modpath("mesecraft_torch") .. "/3d.lua")
else
	dofile(minetest.get_modpath("mesecraft_torch") .. "/2d.lua")
end


-- start timer on any already placed torches
minetest.register_lbm({
	name = "mesecraft_torch:convert_torch_to_node_timer",
	nodenames = {"default:torch", "default:torch_wall", "default:torch_ceiling"},
	action = function(pos)
		if not minetest.get_node_timer(pos):is_started() then
			minetest.get_node_timer(pos):start(
				math.random(mesecraft_torch.min_duration, mesecraft_torch.max_duration))
		end
	end
})


-- creative check
local creative_mode_cache = minetest.settings:get_bool("creative_mode")
function is_creative(name)
	return creative_mode_cache or minetest.check_player_privs(name, {creative = true})
end


-- coal powder
minetest.register_craftitem("mesecraft_torch:coal_powder", {
	description = "Coal Powder",
	inventory_image = "mesecraft_torch_coal_powder.png",

	-- punching unlit torch with coal powder relights
	on_use = function(itemstack, user, pointed_thing)

		if not pointed_thing or pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local nod = minetest.get_node(pos)
		local rep = false

		if nod.name == "mesecraft_torch:torch" then
			nod.name = "default:torch"
			rep = true

		elseif nod.name == "mesecraft_torch:torch_wall" then
			nod.name = "default:torch_wall"
			rep = true

		elseif nod.name == "mesecraft_torch:torch_ceiling" then
			nod.name = "default:torch_ceiling"
			rep = true
		end

		if rep then
			minetest.set_node(pos, {name = nod.name, param2 = nod.param2})

			if not is_creative(user:get_player_name()) then
				itemstack:take_item()
			end
		end

		return itemstack
	end,
})

-- use coal powder as furnace fuel
minetest.register_craft({
	type = "fuel",
	recipe = "mesecraft_torch:coal_powder",
	burntime = 8,
})

-- 2x coal lumps = 12x coal powder
minetest.register_craft({
	type = "shapeless",
	output = "mesecraft_torch:coal_powder 12",
	recipe = {"default:coal_lump", "default:coal_lump"},
})

-- coal powder can make black dye
minetest.register_craft({
	type = "shapeless",
	output = "dye:black",
	recipe = {"mesecraft_torch:coal_powder"},
})

-- add coal powder to burnt out torch to relight
minetest.register_craft({
	type = "shapeless",
	output = "default:torch",
	recipe = {"mesecraft_torch:torch", "mesecraft_torch:coal_powder"},
})

-- 4x burnt out torches = 1x stick
minetest.register_craft({
	type = "shapeless",
	output = "default:stick",
	recipe = {"mesecraft_torch:torch", "mesecraft_torch:torch", "mesecraft_torch:torch", "mesecraft_torch:torch"},
})

-- if torch touches water then drop as unlit torch
minetest.register_abm({
	label = "Real Torch water check",
	nodenames = {
		"default:torch", "default:torch_wall", "default:torch:ceiling",
		"mesecraft_torch:torch", "mesecraft_torch:torch_wall", "mesecraft_torch:torch_ceiling"
	},
	neighbors = {"group:water"},
	interval = 5,
	chance = 1,
	catch_up = false,

	action = function(pos, node)

		local num = #minetest.find_nodes_in_area(
			{x = pos.x - 1, y = pos.y, z = pos.z},
			{x = pos.x + 1, y = pos.y, z = pos.z},
			{"group:water"})

		if num == 0 then
			num = num + #minetest.find_nodes_in_area(
				{x = pos.x, y = pos.y, z = pos.z - 1},
				{x = pos.x, y = pos.y, z = pos.z + 1},
				{"group:water"})
		end

		if num == 0 then
			num = num + #minetest.find_nodes_in_area(
				{x = pos.x, y = pos.y + 1, z = pos.z},
				{x = pos.x, y = pos.y + 1, z = pos.z},
				{"group:water"})
		end

		if num > 0 then
			minetest.set_node(pos, {name = "air"})

			minetest.sound_play({name="mesecraft_torch_extinguish", gain = 0.2},
				{pos = pos, max_hear_distance = 10})

			minetest.add_item(pos, {name = "mesecraft_torch:torch"})
		end
	end,
})


-- particle effects
local function add_effects(pos, radius)

	minetest.add_particle({
		pos = pos,
		velocity = vector.new(),
		acceleration = vector.new(),
		expirationtime = 0.4,
		size = radius * 10,
		collisiondetection = false,
		vertical = false,
		texture = "tnt_boom.png",
		glow = 15,
	})

	minetest.add_particlespawner({
		amount = 16,
		time = 0.5,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -2, y = -2, z = -2},
		maxvel = {x = 2, y = 2, z = 2},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = radius * 3,
		maxsize = radius * 5,
		texture = "tnt_smoke.png",
	})

	minetest.sound_play("tnt_explode", {pos = pos, gain = 0.1, max_hear_distance = 5})
end


-- override tnt:gunpowder to explode when used on torch,
-- will also re-light torches and cause player damage when used on lit torch.
if minetest.get_modpath("tnt") then

minetest.override_item("tnt:gunpowder", {

	on_use = function(itemstack, user, pointed_thing)

		if not pointed_thing or pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local nod = minetest.get_node(pos)

		local rep = false

		if nod.name == "mesecraft_torch:torch" then
			nod.name = "default:torch"
			rep = true

		elseif nod.name == "mesecraft_torch:torch_wall" then
			nod.name = "default:torch_wall"
			rep = true

		elseif nod.name == "mesecraft_torch:torch_ceiling" then
			nod.name = "default:torch_ceiling"
			rep = true
		end

		if rep then

			minetest.set_node(pos, {name = nod.name, param2 = nod.param2})

			add_effects(pos, 1)

			if not is_creative(user:get_player_name()) then
				itemstack:take_item()
			end

			return itemstack
		end

		if nod.name == "default:torch"
		or nod.name == "default:torch_wall"
		or nod.name == "default:torch_ceiling" then

			user:set_hp(user:get_hp() - 2)

			add_effects(pos, 1)

			if not is_creative(user:get_player_name()) then
				itemstack:take_item()
			end
		end

		return itemstack
	end,
})
end
