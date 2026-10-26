-- code based off of pumpboom in nssm. pumpkin texture from farming_redo or crops.

-- REGISTER MOB & ATTRIBUTES
-- todo: add costume drops
mobs:register_mob("mesecraft_halloween:pumpboom", {
    type = "monster",
    hp_min = 10,
    hp_max = 10,
    collisionbox = {-0.45, -0.5, -0.45, 0.45, 0.45, 0.45},
    visual = "cube",
    textures = {{"farming_pumpkin_top.png",
                "farming_pumpkin_top.png",
                "farming_pumpkin_side.png",
                "farming_pumpkin_side.png",
                "farming_pumpkin_face_on.png",
                "farming_pumpkin_side.png"}},
    visual_size = {x=1, y=1},
    explosion_radius = 3,
    makes_footstep_sound = false,
    view_range = 12,
    fear_height = 4,
    walk_velocity = 1.5,
    run_velocity = 2.5,
    sounds = {
                random = "mesecraft_mobs_dirt_golem_random",
                attack = "tnt_ignite",
                death = "mesecraft_mobs_boomer_death",
                damage = "mesecraft_mobs_boomer_damage",
                fuse = "tnt_ignite",
                explode = "tnt_explode",
                distance = 16,
    },
    damage = 1.5,
    jump = true,
    drops = {
		{name = "farming:pumpkin_slice", chance = 1, min = 1, max = 2},
		{name = "candles:candle", chance = 1, min = 1, max = 1},
		{name = "mesecraft_halloween:candycorn", chance = 4, min = 1, max = 2},
		{name = "mesecraft_halloween:caramel_apple", chance = 4, min = 1, max = 2},
		{name = "mesecraft_halloween:halloween_chocolate", chance = 4, min = 1, max = 2},
		{name = "mesecraft_halloween:lolipop", chance = 4, min = 1, max = 2},
                {name = "tnt:gunpowder", chance = 25, min = 0, max = 2,},
                {name = "mesecraft_halloween:mask_pumpkin", chance = 100, min = 1, max = 1},
                {name = "mesecraft_halloween:shirt_halloween_hoodie", chance = 100, min = 1, max = 1},
                {name = "mesecraft_halloween:suit_pumpkin", chance = 100, min = 1, max = 1},
	},
    armor = 200,
    drawtype = "front",
    water_damage = 2,
    lava_damage = 5,
    light_damage = 0,
    suffocation = false,
    group_attack=true,
    knock_back= 4,
    blood_amount = 8,
    blood_texture="farming_pumpkin_slice.png",
    stepheight=1.1,
    on_rightclick = nil,
    attack_type = "explode",
	    -- Only spawn around Halloween date/time (Oct 10th - Nov 1st, 3 weeks).
	    do_custom = function(self)
		        if not mesecraft_seasonal.keep(self, "halloween") then return false end
	    end,
})

-- Register spawn egg
mobs:register_egg("mesecraft_halloween:pumpboom","Pumpboom Spawn Egg", "farming_pumpkin_side.png", 1)

--mobs:spawn_specfic(name, nodes, neighbors, min_light, max_light, interval,chance, active_object_count, min_height, max_height, day_toggle, on_spawn)
-- World spawning parameters for the pumpboom.
mesecraft_seasonal.register_spawn("mesecraft_halloween:pumpboom", {
	season = "halloween",
	nodes = {"group:cracky", "group:crumbly", "group:shovely", "group:pickaxey"},
	min_light = 0, max_light = 5,
	min_y = -30912, max_y = 30192,
	weight = 3,
})