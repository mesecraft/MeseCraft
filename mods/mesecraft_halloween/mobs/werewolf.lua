-- Random howl sounds by klankbeeld - https://freesound.org/people/klankbeeld/sounds/133763/
-- hit sounds by robinhood76 - https://freesound.org/people/Robinhood76/sounds/161488/
-- Warcry sound by missozzy - https://freesound.org/people/missozzy/sounds/169985/
-- todo spawn a villager/npc when killed?
mobs:register_mob('mesecraft_halloween:werewolf', {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 3,
	damage = 10,
	hp_min = 50,
	hp_max = 50,
	armor = 75,
	knock_back = false,
        collisionbox = {-0.5,-1.5,-0.5, 0.5,1.2,0.5},
        visual = "mesh",
        mesh = "mobs_character.b3d",
	visual_size = {x=1.5, y=1.5},
        textures = {
                {"mesecraft_halloween_werewolf.png"},
        },
	blood_texture = "mobs_blood.png",
	makes_footstep_sound = true,
	sounds = {
		random ="mesecraft_mobs_werewolf_random",
		attack = "mesecraft_mobs_bogeyman_attack",
		damage = "mesecraft_mobs_werewolf_damage",
		death = "mesecraft_mobs_bogeyman_death",
		distance = 32,
	},
	walk_velocity = 2.0,
	run_velocity = 3.5,
	jump = true,
	floats = true,
	suffocation = false,
	view_range = 16,
	drops = {
	{name = "mobs_creautures:meat", chance = 1, min = 1, max = 1},
	{name = "mesecraft_mobs:bone", chance = 2, min = 1, max = 1},
        {name = "mesecraft_halloween:candycorn", chance = 4, min = 1, max = 2},
        {name = "mesecraft_halloween:caramel_apple", chance = 4, min = 1, max = 2},
        {name = "mesecraft_halloween:halloween_chocolate", chance = 4, min = 1, max = 2},
        {name = "mesecraft_halloween:lolipop", chance = 4, min = 1, max = 2},	
        {name = "clothing:pants_blue", chance = 50, min = 1, max = 1},
        {name = "mesecraft_halloween:suit_wearwolf", chance = 100, min = 1, max = 1},
	},
	lava_damage = 5,
	water_damage = 2,
	light_damage = 5,
	fall_damage = 2,
        animation = {
                speed_normal = 30,
                speed_run = 45,
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
mobs:register_egg("mesecraft_halloween:werewolf", "Werewolf Spawn Egg", "mesecraft_mobs_items_meat.png", 1)

--mobs:spawn_specfic(name, nodes, neighbors, min_light, max_light, interval,chance, active_object_count, min_height, max_height, day_toggle, on_spawn)
--Spawn Functions
mesecraft_seasonal.register_spawn("mesecraft_halloween:werewolf", {
	season = "halloween",
	nodes = {"group:flora", "group:leaves"},
	min_light = 0, max_light = 4,
	min_y = -30912, max_y = 30912,
})