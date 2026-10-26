-- Gingerbread Man by FreeGamers.org
-- Register mob with Mobs API

mobs:register_mob("mesecraft_christmas:gingerbread_man", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 4,
	hp_min = 3,
	hp_max = 27,
	armor = 100,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	visual = "mesh",
        mesh = "mobs_character.b3d",
	textures = {
		{"mesecraft_christmas_gingerbread_man.png"},
	},
	blood_texture = "mesecraft_christmas_nodes_gingerbread_block.png",
	makes_footstep_sound = true,
	sounds = {
		random = "mesecraft_mobs_dirt_man_random",
		damage = "default_dirt_footstep",
		attack = "default_dirt_footstep",
		jump = "default_dirt_footstep",
		death = "default_dirt_footstep",
	},
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "mesecraft_christmas:gingerbread_block", chance = 1, min = 1, max = 2},
		{name = "mesecraft_christmas:frosting_block", chance = 2, min = 1, max = 2},
		{name = "mesecraft_christmas:gingerbread_cookie", chance = 2, min = 1, max = 3},
		{name = "mesecraft_christmas:present_06", chance = 5, min = 1, max = 2},
		{name = "mesecraft_christmas:present_07", chance = 5, min = 1, max = 2},
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 3,
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
        immune_to = {
                {"default:sword_wood", 3}, -- swords deal more damage to gingerbread man.
                {"default:sword_stone", 3},
                {"default:sword_bronze", 4},
                {"default:sword_steel", 4},
                {"default:sword_mese", 5},
                {"default:sword_diamond", 7},
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
            maxsize = 3,
            collisiondetection = false,
            texture="mesecraft_christmas_nodes_gingerbread_block.png"
        })
        self.object:remove()
    end,
-- Remove the mob if it's not December.
    do_custom = function(self)
                if not mesecraft_seasonal.keep(self, "christmas") then return false end
    end,
})

-- Register Spawn Egg
mobs:register_egg("mesecraft_christmas:gingerbread_man", "Gingerbread Man Spawn Egg", "mesecraft_christmas_nodes_gingerbread_block.png", 1)

-- Register Spawn Parameters
mesecraft_seasonal.register_spawn("mesecraft_christmas:gingerbread_man", {
	season = "christmas",
	nodes = {"default:snowblock", "default:dirt_with_snow", "default:snow", "default:ice"},
	min_light = 0, max_light = 7,
	min_y = -500, max_y = 100,
	weight = 2,
})