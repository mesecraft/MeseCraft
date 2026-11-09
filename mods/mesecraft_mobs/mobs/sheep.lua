--License for code WTFPL and otherwise stated in readmes
--###################
--################### SHEEP
--###################

-- Wool on, and shorn (the wool texture replaced by a transparent one).
local WOOLLY = {"mesecraft_mobs_sheep_fur.png", "mesecraft_mobs_sheep.png"}
local SHORN = {"transparent_pixel.png", "mesecraft_mobs_sheep.png"}

-- Register the mob with the API.
mobs:register_mob("mesecraft_mobs:sheep", {
	type = "animal",
	hp_min = 8,
	hp_max = 8,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.29, 0.45},
	visual = "mesh",
	-- Mineclonia's sheep model: the first texture is the wool, the second the
	-- body. A shorn sheep swaps the wool for a transparent texture.
	visual_size = {x=1.07, y=1.07},
	mesh = "mesecraft_mobs_sheep.b3d",
	textures = {WOOLLY},
	gotten_texture = SHORN,
	makes_footstep_sound = true,
	walk_velocity = 1,
	drops = {
		{name = "mesecraft_mobs:mutton_raw", chance = 1, min = 1, max = 2,},
		{name = "wool:white", chance = 1, min = 1, max = 1,},
	},
	water_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 4,
	sounds = {
		random = "mesecraft_mobs_sheep",
		death = "mesecraft_mobs_sheep",
		damage = "mesecraft_mobs_sheep",
		distance = 16,
	},
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 40,		stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	follow = "farming:wheat",
	view_range = 12,

	-- Eat grass
	replace_rate = 20,
	replace_what = {
		-- Grass Block
		{ "default:dirt_with_grass", "default:dirt", -1 },
		-- “Tall Grass”
		{ "default:grass_5", "air", 0 },
		{ "default:grass_4", "air", 0 },
		{ "default:grass_3", "air", 0 },
		{ "default:grass_2", "air", 0 },
		{ "default:grass_1", "air", 0 },
	},
	-- Properly regrow wool after eating grass
	on_replace = function(self, pos, oldnode, newnode)
		self.gotten = false
		self.drops = {
			{name = "mesecraft_mobs:mutton_raw", chance = 1, min = 1, max = 2,},
			{name = "wool:white", chance = 1, min = 1, max = 2,},
		}
		self.base_texture = WOOLLY
		self.object:set_properties({textures = WOOLLY})
	end,
	-- Set random color on spawn
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		if mobs:feed_tame(self, clicker, 1, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if item:get_name() == "mobs:shears" and not self.gotten then
			self.gotten = true
			local pos = self.object:get_pos()
			minetest.sound_play("shears", {pos = pos})
			pos.y = pos.y + 0.5
			minetest.add_item(pos, ItemStack("wool:white "..math.random(1,3)))
			self.object:set_properties({textures = SHORN})
			if not minetest.settings:get_bool("creative_mode") then
				item:add_wear(276)
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
			end
			self.drops = {
				{name = "mesecraft_mobs:mutton_raw", chance = 1, min = 1, max = 2,},
			}
			return
		end
		if mobs:capture_mob(self, clicker, 0, 5, 70, false, nil) then return end
	end,
})
-- Spawn Parameters
mobs:spawn_specific("mesecraft_mobs:sheep", {"default:dirt_with_grass", "default:dirt_with_dry_grass"}, {"air"}, 6, 15, 480, 480, 2, 2, 150)
-- Spawn Eggs
mobs:register_egg("mesecraft_mobs:sheep", "Sheep Spawn Egg", "wool_white.png", 1)
