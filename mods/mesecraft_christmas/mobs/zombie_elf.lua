mobs:register_mob('mesecraft_christmas:zombie_elf', {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 4,
	hp_min = 10,
	hp_max = 20,
	armor = 125,
	knock_back = true,
        collisionbox = {-0.24,-0.75,-0.24, 0.24,0.6,0.24},
        visual = "mesh",
	visual_size = { x=0.75, y=0.75},
        mesh = "mobs_character.b3d",
        textures = {
                {"mesecraft_christmas_zombie_elf.png"},
        },
	blood_texture = "mobs_blood.png",
	makes_footstep_sound = true,
	sounds = {
		random ="mesecraft_mobs_fire_imp_random",
		warcry = "mesecraft_mobs_fire_imp_warcry",
		attack = "mesecraft_christmas_sleighbell",
		damage = "mesecraft_christmas_sleighbell",
		death = "mesecraft_mobs_fire_imp_death",
	},
	walk_velocity = 2,
	run_velocity = 3.25,
	jump = true,
	floats = true,
	suffocation = true,
	view_range = 16,
	drops = {
	{name = "mesecraft_christmas:present_01", chance = 2, min = 1, max = 1},
	{name = "mesecraft_christmas:present_02", chance = 2, min = 1, max = 1},
	{name = "mesecraft_christmas:present_03", chance = 8, min = 1, max = 1},
	{name = "mesecraft_christmas:present_04", chance = 8, min = 1, max = 1},
	},
	lava_damage = 5,
	water_damage = 2,
	light_damage = 5,
	fall_damage = 2,
        animation = {
                speed_normal = 30,
                speed_run = 50,
                stand_start = 0,
                stand_end = 79,
                walk_start = 168,
                walk_end = 187,
                run_start = 168,
                run_end = 187,
                punch_start = 200,
                punch_end = 219,
	},
        do_custom = function(self)
                if not mesecraft_seasonal.keep(self, "christmas") then return false end
        end,
})

--Spawn Eggs
mobs:register_egg("mesecraft_christmas:zombie_elf", "Zombie Elf Spawn Egg", "wool_green.png", 1)

--Spawn Functions
mesecraft_seasonal.register_spawn("mesecraft_christmas:zombie_elf", {
	season = "christmas",
	nodes = {"default:snow", "default:snowblock", "default:dirt_with_snow"},
	min_light = 7, max_light = 16,
	min_y = 2, max_y = 200,
	weight = 3,
})