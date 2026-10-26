-- add redshift, blue pants clothing?
mobs:register_mob('mesecraft_halloween:scarecrow', {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 3,
	damage = 6,
	hp_min = 20,
	hp_max = 20,
	armor = 100,
	knock_back = true,
        collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
        visual = "mesh",
        mesh = "mobs_character.b3d",
        textures = {
                {"mesecraft_halloween_scarecrow.png"},
        },
	blood_texture = "farming_wheat.png",
	makes_footstep_sound = true,
	sounds = {
                random = "mesecraft_mobs_sand_man_random",
                attack = "default_dig_crumbly",
                damage = "default_dig_snappy",
		jump = "default_dirt_footstep",
                death = "default_dig_oddly_breakable_by_hand",
        },	walk_velocity = 1,
	run_velocity = 2.75,
	jump = true,
	floats = true,
	suffocation = false,
	view_range = 16,
	drops = {
	{name = "farming:wheat", chance = 3, min = 1, max = 2},
        {name = "farming:seed_wheat", chance = 5, min = 1, max = 2},
	{name = "farming:straw", chance = 1, min = 1, max = 1},
        {name = "default:stick", chance = 1, min = 1, max = 2},
        {name = "mesecraft_halloween:candycorn", chance = 4, min = 1, max = 2},
        {name = "mesecraft_halloween:caramel_apple", chance = 4, min = 1, max = 2},
        {name = "mesecraft_halloween:halloween_chocolate", chance = 4, min = 1, max = 2},
        {name = "mesecraft_halloween:lolipop", chance = 4, min = 1, max = 2},
        {name = "decoblocks:scarecrow", chance = 50, min = 1, max = 1},
        {name = "mesecraft_halloween:suit_killer", chance = 100, min = 1, max = 1},
	},
	lava_damage = 10,
	water_damage = 5,
	light_damage = 5,
	fall_damage = 2,
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
	    -- Only spawn around Halloween date/time (Oct 10th - Nov 1st, 3 weeks).
	    do_custom = function(self)
		        if not mesecraft_seasonal.keep(self, "halloween") then return false end
	    end,
})
--Spawn Eggs
mobs:register_egg("mesecraft_halloween:scarecrow", "Scarecrow Spawn Egg", "farming_straw.png", 1)

--mobs:spawn_specfic(name, nodes, neighbors, min_light, max_light, interval,chance, active_object_count, min_height, max_height, day_toggle, on_spawn)
--Spawn Functions
mesecraft_seasonal.register_spawn("mesecraft_halloween:scarecrow", {
	season = "halloween",
	nodes = {"farming:wheat_6", "farming:wheat_7", "farming:wheat_8", "farming:oat_6", "farming:oat_7", "farming:oat_8","decoblocks:scarecrow"},
	min_light = 0, max_light = 5,
	min_y = -30912, max_y = 30912,
	weight = 2,
})