-- Candy Cane Man by FreeGamers.org

-- REGISTER CANDY CANE MAN
mobs:register_mob("mesecraft_christmas:christmas_tree_man", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 15,
	hp_min = 30,
	hp_max = 30,
	armor = 100,
        collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
        visual = "mesh",
        mesh = "mobs_character.b3d",
        textures = {
                {"mesecraft_christmas_christmas_tree_man.png"},
        },
	makes_footstep_sound = true,
        sounds = {
                random = "mesecraft_mobs_dirt_man_random",
                attack = "default_dig_snappy",
                damage = "default_dig_choppy",
                death = "default_place_node_hard",
                jump = "default_wood_footstep",
        },
        blood_texture = "default_pine_needles.png",
	walk_velocity = 1,
	run_velocity = 2,
	jump_height = 1,
	stepheight = 1.1,
	floats = 0,
	view_range = 12,
	drops = {
		{name = "default:pine_needles", chance = 1, min = 0, max = 3},
		{name = "mesecraft_christmas:christmas_star", chance = 10, min = 0, max = 1},
		{name = "default:pine_tree", chance = 2, min = 0, max = 2},
		{name = "mesecraft_christmas:present_06", chance = 5, min = 0, max = 2},
		{name = "mesecraft_christmas:present_07", chance = 5, min = 0, max = 2},
	},
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	suffocation = false,
	knock_back = true,
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
	immune_to = {
		{"default:axe_wood", 0}, -- wooden axe doesnt hurt christmas tree man
		{"default:axe_stone", 4}, -- axes deal more damage to christmas tree man.
		{"default:axe_bronze", 5},
		{"default:axe_steel", 5},
		{"default:axe_mese", 6},
		{"default:axe_diamond", 7},
	},
    on_die = function(self, pos) -- on die, spawn particles.
        minetest.add_particlespawner({
            amount = 100,
            time = 0.1,
            minpos = {x=pos.x-1, y=pos.y-1, z=pos.z-1},
            maxpos = {x=pos.x+1, y=pos.y+1, z=pos.z+1},
            minvel = {x=-0, y=-0, z=-0},
            maxvel = {x=1, y=1, z=1},
            minacc = {x=-0.5,y=5,z=-0.5},
            maxacc = {x=0.5,y=5,z=0.5},
            minexptime = 0.1,
            maxexptime = 1,
            minsize = 1,
            maxsize = 2,
            collisiondetection = false,
            texture="default_pine_needles.png"
        })
        self.object:remove()
    end,
-- Remove the mob if it's not December.
    do_custom = function(self)
                if not mesecraft_seasonal.keep(self, "christmas") then return false end
    end,
})

-- Register Spawn Egg
mobs:register_egg("mesecraft_christmas:christmas_tree_man", "Christmas Tree Man Spawn Egg", "default_pine_needles.png", 1)

-- Spawning Parameters
mesecraft_seasonal.register_spawn("mesecraft_christmas:christmas_tree_man", {
	season = "christmas",
	nodes = {"default:snowblock", "default:dirt_with_snow", "default:snow"},
	min_light = 0, max_light = 7,
	min_y = -9500, max_y = -6500,
})