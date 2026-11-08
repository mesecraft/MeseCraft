-- Skeleton Fighter
mobs:register_mob("mesecraft_mobs:skeleton_fighter", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	pathfinding = 1,
	group_attack = true,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.98, 0.3},
	visual = "mesh",
	mesh = "mesecraft_mobs_skeleton_fighter.b3d",
	textures = {
		{"mesecraft_mobs_skeleton.png^mesecraft_mobs_skeleton_fighter_sword.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
        sounds = {
                random = "mesecraft_mobs_skeleton_random",
                death = "mesecraft_mobs_skeleton_death",
                damage = "mesecraft_mobs_skeleton_damage",
                shoot_attack = "mesecraft_mobs_common_shoot_arrow",
                attack = "mesecraft_mobs_skeleton_attack",
                jump = "mesecraft_mobs_skeleton_jump",
                distance = 16,
        },
	walk_velocity = 1.2,
	run_velocity = 2.4,
	damage = 10,
	reach = 2,
	drops = {
		{name = "mesecraft_mobs:bone", chance = 1, min = 0, max = 2,},
		{name = "default:stone_sword", chance = 5, min = 0, max = 1,},
	},
	animation = {
		stand_start = 0,
		stand_end = 40,
		stand_speed = 5,
		walk_start = 40,
		walk_end = 60,
		walk_speed = 15,
		run_start = 40,
		run_end = 60,
		run_speed = 30,
		shoot_start = 70,
		shoot_end = 90,
		punch_start = 70,
		punch_end = 90,
		die_start = 120,
		die_end = 130,
		die_loop = false,
		-- Not supported yet
		hurt_start = 100,
		hurt_end = 120,
	},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 5,
	view_range = 16,
	attack_type = "dogfight",
	shoot_interval = 2.5,
	shoot_offset = 1,
	dogshoot_switch = 1,
	dogshoot_count_max =0.5,
	blood_amount = 0,
	fear_height = 4,
})

--spawn
mobs:spawn_specific("mesecraft_mobs:skeleton_fighter", {"group:cracky", "group:crumbly", "group:shovely", "group:pickaxey"}, {"air"}, 0, 7, 960, 1000, 2, -500, -100)

-- spawn eggs
mobs:register_egg("mesecraft_mobs:skeleton_fighter", "Skeleton Fighter Spawn Egg", "wool_white.png", 1)
