mobs:register_mob('mesecraft_halloween:halloween_ghost', {
	type = "animal",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 0,
	hp_min = 1,
	hp_max = 1,
	armor = 1,
	knock_back = false,
        collisionbox = {0.0,0.0,0.0, 0.0,0.0,0.0},
        visual = "mesh",
        mesh = "mobs_character.b3d",
        textures = {
                {"mesecraft_mobs_ghost.png"},
		{"mesecraft_mobs_ghost_murderous.png"},
        },
	blood_amount = 0,
	makes_footstep_sound = false,
	sounds = {
		random = "mesecraft_mobs_ghost_random",
		 death = "mesecraft_mobs_ghost_death",
		attack = "mesecraft_mobs_ghost_attack",
		damage = "mesecraft_mobs_ghost_damage",
		warcry = "mesecraft_mobs_ghost_warcry",
	},
	walk_velocity = 1,
	run_velocity = 1,
	jump = true,
	fly = true,
	floats = true,
	suffocation = false,
	view_range = 16,
	drops = {
	{name = "mesecraft_halloween:suit_ghost", chance = 100, min = 1, max = 1},
        {name = "mesecraft_halloween:candycorn", chance = 4, min = 1, max = 2},
        {name = "mesecraft_halloween:caramel_apple", chance = 4, min = 1, max = 2},
        {name = "mesecraft_halloween:halloween_chocolate", chance = 4, min = 1, max = 2},
        {name = "mesecraft_halloween:lolipop", chance = 4, min = 1, max = 2},
	},
	lava_damage = 0,
	water_damage = 0,
	light_damage = 20,
	fall_damage = 0,
        animation = {
                speed_normal = 0,
                speed_run = 79,
                stand_start = 0,
                stand_end = 79,
                walk_start = 0,
                walk_end = 79,
                run_start = 0,
                run_end = 79,
                punch_start = 0,
                punch_end = 79,
        },
	    -- Only spawn around Halloween date/time (Oct 10th - Nov 1st, 3 weeks).
	    do_custom = function(self)
		        if not mesecraft_seasonal.keep(self, "halloween") then return false end
	    end,
})

--Spawn Eggs
mobs:register_egg("mesecraft_halloween:halloween_ghost", "Halloween Ghost Spawn Egg", "wool_white.png", 1)

--mobs:spawn_specfic(name, nodes, neighbors, min_light, max_light, interval,chance, active_object_count, min_height, max_height, day_toggle, on_spawn)
--Spawn Functions
mesecraft_seasonal.register_spawn("mesecraft_halloween:halloween_ghost", {
	season = "halloween",
	nodes = {"group:cracky", "group:crumbly", "group:shovely", "group:pickaxey"},
	min_light = 0, max_light = 6,
	min_y = -30912, max_y = 30912,
	weight = 3,
})