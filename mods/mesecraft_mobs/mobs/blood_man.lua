-- Blood Golem by FreeGamers.org
-- A weak creature made of cursed blood that spills upon death. Inspired by Dwarf Fortress's Blood Man.

-- Register mob with Mobs API
mobs:register_mob("mesecraft_mobs:blood_man", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 4,
	hp_min = 10,
	hp_max = 10,
	armor = 200,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	visual = "mesh",
        mesh = "mobs_character.b3d",
	textures = {
		{"mesecraft_mobs_blood_man.png"},
	},
	blood_texture = "mobs_blood.png",
	makes_footstep_sound = true,
	sounds = {
		random = "mesecraft_mobs_dirt_man_random",
		damage = "default_snow_footstep",
		jump = "default_snow_footstep",
		death = "default_water_footstep",
	},
	view_range = 12,
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	knock_back = false,
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	fall_damage = 0,
	fear_height = 4,
        animation = {
                speed_normal = 30,
                speed_run = 30,
                stand_start = 0,
                stand_end = 79,
                walk_start = 168,
                walk_end = 187,
                run_start = 168,
                run_end = 187,
                punch_start = 200,
                punch_end = 219,
        },
    on_die = function(self, pos) -- on die, spawn a blood source.
	if minetest.get_node(pos).name == "air" then
		minetest.set_node(pos, {name = "mesecraft_mobs:blood_source"})
	end
        self.object:remove()
    end,
})

-- Register Spawn Parameters
mobs:spawn_specific("mesecraft_mobs:blood_man", {"group:cracky", "group:crumbly", "group:shovely", "group:pickaxey"}, {"air"}, 0, 7, 60, 75000, 1, -9500, -6500)

-- Register Spawn Egg
mobs:register_egg("mesecraft_mobs:blood_man", "Blood Man Spawn Egg", "mesecraft_mobs_items_blood_source.png", 1)
