-- Gold Man by FreeGamers.org
-- Skin: original art for MeseCraft, drawn by utils/skingen/skingen.py.

-- REGISTER DIAMOND MAN
mobs:register_mob("mesecraft_mobs:gold_man", {
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
                {"mesecraft_mobs_gold_man.png"},
        },
	makes_footstep_sound = true,
	sounds = {
		random = "mesecraft_mobs_stone_man_random",
		damage = "default_dig_metal",
		attack = "default_dug_metal", 
		jump = "default_metal_footstep",
		death = "default_dug_metal",
	},
        blood_texture = "default_gold_block.png",
	walk_velocity = 1,
	run_velocity = 2,
	jump_height = 1,
	stepheight = 1.1,
	floats = 0,
	view_range = 12,
	drops = {
		{name = "default:gold_lump", chance = 10, min = 0, max = 2},
	},
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
        suffocation = false,
        knock_back = false,
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
		{"default:pick_wood", 0}, -- wooden pick doesnt hurt gold man
		{"default:pick_stone", 4}, -- picks deal more damage to gold man
		{"default:pick_bronze", 5},
		{"default:pick_steel", 5},
		{"default:pick_mese", 6},
		{"default:pick_diamond", 7},
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
            texture="default_gold_block.png"
        })
        self.object:remove()
    end,
})

-- Spawning Parameters
mobs:spawn_specific("mesecraft_mobs:gold_man", {"group:cracky", "group:crumbly", "group:shovely", "group:pickaxey"}, {"air", "mine_gas:gas"}, 0, 7, 600, 4000, 1, -9500, -6500)

-- Register Spawn Egg
mobs:register_egg("mesecraft_mobs:gold_man", "Gold Man Spawn Egg", "default_gold_block.png", 1)
