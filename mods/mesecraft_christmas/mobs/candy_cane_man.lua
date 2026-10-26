-- Candy Cane Man by FreeGamers.org

-- REGISTER CANDY CANE MAN
mobs:register_mob("mesecraft_christmas:candy_cane_man", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 12,
	hp_min = 20,
	hp_max = 20,
	armor = 50,
        collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
        visual = "mesh",
        mesh = "mobs_character.b3d",
        textures = {
                {"mesecraft_christmas_candy_cane_man.png"},
        },
	makes_footstep_sound = true,
	sounds = {
		random = "mesecraft_mobs_stone_man_random",
		damage = "default_break_glass",
		jump = "default_glass_footstep",
		death = "default_break_glass",
	},
        blood_texture = "mesecraft_christmas_nodes_candy_cane_block.png",
	walk_velocity = 1,
	run_velocity = 2,
	jump_height = 1,
	stepheight = 1.1,
	floats = 0,
	view_range = 12,
	drops = {
		{name = "mesecraft_christmas:candy_cane_block", chance = 5, min = 0, max = 2},
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
		{"default:pick_wood", 0}, -- wooden pick doesnt hurt diamond man
		{"default:pick_stone", 4}, -- picks deal more damage to diamond man.
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
            texture="mesecraft_christmas_nodes_candy_cane_block.png"
        })
        self.object:remove()
	end,
-- Remove the mob if it's not December.
    do_custom = function(self)
                if not mesecraft_seasonal.keep(self, "christmas") then return false end
    end,
})

-- Register Spawn Egg
mobs:register_egg("mesecraft_christmas:candy_cane_man", "Candy Cane Man Spawn Egg", "mesecraft_christmas_nodes_candy_cane_block.png", 1)

-- Spawning Parameters
mesecraft_seasonal.register_spawn("mesecraft_christmas:candy_cane_man", {
	season = "christmas",
	nodes = {"default:snowblock", "default:dirt_with_snow", "default:snow"},
	min_light = 0, max_light = 7,
	min_y = -9500, max_y = -6500,
})