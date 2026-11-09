--###################
--################### Clownfish
--###################
-- Model and textures are built by utils/models/mobs.py.
mobs:register_mob("mesecraft_mobs:clownfish", {
	type = "animal",
	passive = true,
	runaway = true,
        runaway_from = {"player"},
	stepheight = 0.1,
	hp_min = 3,
	hp_max = 3,
	armor = 200,
	collisionbox = {-0.25, -0.2, -0.25, 0.25, 0.2, 0.25},
	visual = "mesh",
	mesh = "mesecraft_mobs_clownfish.b3d",
    	textures = {
        { "mesecraft_mobs_clownfish_1.png"},
	{ "mesecraft_mobs_clownfish_2.png"},
        { "mesecraft_mobs_clownfish_3.png"},
        { "mesecraft_mobs_clownfish_4.png"},
        { "mesecraft_mobs_clownfish_5.png"},
        { "mesecraft_mobs_clownfish_6.png"},
        { "mesecraft_mobs_clownfish_7.png"},
        { "mesecraft_mobs_clownfish_8.png"},
        { "mesecraft_mobs_clownfish_9.png"},
        { "mesecraft_mobs_clownfish_10.png"},
        { "mesecraft_mobs_clownfish_11.png"},
        { "mesecraft_mobs_clownfish_12.png"},
        { "mesecraft_mobs_clownfish_13.png"},
	},
	visual_size = {x = 0.45, y = 0.45},
        drops = {
 	       {name = "mesecraft_mobs:clownfish_raw", chance = 1, min = 1, max = 1},
	       {name = "bonemeal:bonemeal", chance = 20, min = 1, max = 1},
        },
	walk_velocity = 0.6,
	run_velocity = 2.75,
	jump = false,
	fly = true,
	fly_in = "default:water_source",
	fall_speed = 0,
	view_range = 6,
	water_damage = 0,
	lava_damage = 10,
	light_damage = 0,
	animation = {
		speed_normal = 30,
		speed_run = 50,
		stand_start = 0,
		stand_end = 40,
		walk_start = 50,
		walk_end = 80,
		run_start = 50,
		run_end = 80,
	},
})
-- Register spawning conditions. -- spawns in tropical and warm, near coral.
mobs:spawn_specific("mesecraft_mobs:clownfish",      {"default:coral_brown", "default:coral_orange","default:coral_cyan","default:coral_green","default:coral_pink", "decorations_sea:coral_01", "decorations_sea:coral_02", "decorations_sea:coral_03", "decorations_sea:coral_04", "decorations_sea:coral_05", "decorations_sea:coral_06", "decorations_sea:coral_07", "decorations_sea:coral_08", "decorations_sea:coral_plantlike_01", "decorations_sea:coral_plantlike_02", "decorations_sea:coral_plantlike_03", "decorations_sea:coral_plantlike_04", "decorations_sea:coral_plantlike_05"},       {"default:water_flowing","default:water_source"}, 1, 16, 60, 125, 16, -200, -1)

-- Register spawn egg.
mobs:register_egg("mesecraft_mobs:clownfish", "Clownfish Spawn Egg", "default_water.png", 1)
