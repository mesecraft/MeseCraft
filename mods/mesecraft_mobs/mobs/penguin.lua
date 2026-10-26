-- Original mod created by D00Med

-- Register the penguin mob.
mobs:register_mob("mesecraft_mobs:penguin", {
	stepheight = 0.6,
	type = "animal",
	passive = true,
	reach = 1,
	hp_min = 5,
	hp_max = 10,
	armor = 200,
	collisionbox = {-0.2, -0.0, -0.2,  0.2, 0.5, 0.2},
	visual = "mesh",
	mesh = "mesecraft_mobs_penguin.b3d",
	visual_size = {x = 0.25, y = 0.25},
	textures = {
		{"mesecraft_mobs_penguin.png"},
	},
	sounds = {},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 2,
	runaway = true,
	jump = false,
	stepheight = 1.1,
	drops = {
		{name = "mesecraft_mobs:meat", chance = 1, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 2,
	animation = {
		speed_normal = 15,
		stand_start = 1,
		stand_end = 20,
		walk_start = 25,
		walk_end = 45,
		fly_start = 75, -- swim animation
		fly_end = 95,
		-- 50-70 is slide/water idle
	},
	fly_in = {"default:water_source", "default:water_flowing"},
	floats = 0,
--	follow = {"ethereal:fish_raw", "mobs_fish:clownfish", "mobs_fish:tropical"},
	view_range = 5,

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 5, 50, 80, false, nil) then return end
	end,
})

-- Register Spawning Parameters
mobs:spawn_specific("mesecraft_mobs:penguin", {"default:ice", "default:dirt_with_snow"}, {"air"}, 7, 16, 240, 5000, 3, 0, 200, true)

-- Register Spawning Egg
mobs:register_egg("mesecraft_mobs:penguin", "Penguin", "default_snow.png", 1)

