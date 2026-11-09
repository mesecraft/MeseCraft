-- Skin: original art for MeseCraft, drawn by utils/skingen/skingen.py.
-- Sand Monster by PilzAdam

mobs:register_mob("mesecraft_mobs:sand_man", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 4,
	hp_min = 4,
	hp_max = 20,
	armor = 100,
        collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "mobs_character.b3d",
	textures = {
		{"mesecraft_mobs_sand_man.png"},
	},
	blood_texture = "default_desert_sand.png",
	makes_footstep_sound = true,
	sounds = {
		random = "mesecraft_mobs_sand_man_random",
		damage = "default_sand_footstep",
		jump = "default_sand_footstep",
		attack = "default_sand_footstep",
		death = "default_item_smoke",
	},
	walk_velocity = 1.5,
	run_velocity = 4,
	view_range = 8, --15
	jump = true,
	floats = 0,
	drops = {
		{name = "default:desert_sand", chance = 1, min = 3, max = 5},
	},
	water_damage = 3,
	lava_damage = 4,
	light_damage = 0,
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
		{"default:shovel_wood", 3}, -- shovels deal more damage to sand monster
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
            texture="default_desert_sand.png"
        })
        self.object:remove()
    end,
})

-- Register Spawn Parameters
mobs:spawn_specific("mesecraft_mobs:sand_man", {"default:sand", "default:desert_sand"}, {"air"}, 0, 7, 480, 1200, 2, -500, 100, false)

-- Register Spawn Egg
mobs:register_egg("mesecraft_mobs:sand_man", "Sand Man Spawn Egg", "default_desert_sand.png", 1)
