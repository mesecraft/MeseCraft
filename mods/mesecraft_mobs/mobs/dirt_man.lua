-- Original Dirt Monster concept by PilzAdam
-- Skin: original art for MeseCraft, drawn by utils/skingen/skingen.py.
-- Simplified by freegamers.org
-- Register mob with Mobs API
mobs:register_mob("mesecraft_mobs:dirt_man", {
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
		{"mesecraft_mobs_dirt_man.png"},
	},
	blood_texture = "default_dirt.png",
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
		{name = "default:dirt", chance = 1, min = 0, max = 2},
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
                {"default:shovel_wood", 3}, -- shovels deal more damage to dirt golem
                {"default:shovel_stone", 3},
                {"default:shovel_bronze", 4},
                {"default:shovel_steel", 4},
                {"default:shovel_mese", 5},
                {"default:shovel_diamond", 7},
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
            texture="default_dirt.png"
        })
        self.object:remove()
    end,
})

-- Register Spawn Parameters
mobs:spawn_specific("mesecraft_mobs:dirt_man", {"default:dirt_with_grass", "ethereal:gray_dirt"}, {"air"}, 0, 7, 60, 5000, 2, -500, 100, false)

-- Register Spawn Egg
mobs:register_egg("mesecraft_mobs:dirt_man", "Dirt Man Spawn Egg", "default_dirt.png", 1)
