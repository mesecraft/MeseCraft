-- MAGMA MAN
-- Skin: original art for MeseCraft, drawn by utils/skingen/skingen.py.

mobs:register_mob("mesecraft_mobs:magma_man", {
   type = "monster",
   passive = false,
   attacks_monsters = false,
   damage = 20,
   reach = 2,
   attack_type = "dogfight",
   hp_min = 30,
   hp_max = 30,
   armor = 25,
   knock_back = false,
   collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
   visual = "mesh",
   mesh = "mobs_character.b3d",
   textures = {
  	    {"mesecraft_mobs_magma_man.png"},
   },
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
   blood_amount = 60,
   blood_texture = "default_obsidian.png",
   makes_footstep_sound = true,
   walk_velocity = 1,
   run_velocity = 2,
   jump = true,
   fly = false,
   drops = {
	{ name = "default:obsidian", chance = 1, min = 1, max = 4 },
   },
   water_damage = 0,
   lava_damage = 0,
   light_damage = 0,
   view_range = 16,
   sounds = {
	death = "default_cool_lava",
        random = "mesecraft_mobs_dirt_man_random",
	jump = "default_hard_footstep",
	attack = "default_place_node_hard",
	damage = "default_dug_node",
   },
   drops = {
--		{name = "mesecraft_mobs:ash", chance = 1, min = 1, max = 4}
	},
   do_custom = function(self)
		-- if standing in water, remove replace with air play steam.
		local pos = self.object:get_pos()
		if minetest.get_node(pos).name == "default:water_source" or minetest.get_node(pos).name == "default:water_flowing" or minetest.get_node(pos).name == "default:river_water_source" or minetest.get_node(pos).name == "default:river_water_flowing" or minetest.get_node(pos).name == "default:snow" or minetest.get_node(pos).name == "default:ice" then
			minetest.add_particlespawner({
				amount = 1,
				time = 1,
				minpos = pos,
				maxpos = pos,
				minvel = {x=-1, y=0, z=-1},
				maxvel = {x=1, y=1, z=1},
				minacc = {x=0, y=2, z=0},
				maxacc = {x=0, y=2, z=0},
				minexptime = 1,
				maxexptime = 2,
				minsize = 4,
				maxsize = 8,
				collisiondetection = false,
				vertical = false,
				texture = "smoke_puff.png",
			})
		      	minetest.sound_play({name = "default_cool_lava", gain = 1.0}, {pos=pos, max_hear_distance = 16})
			minetest.set_node(pos, {name = "air"})
		else
			return
		end
    end,
    on_die = function(self, pos) -- on die, spawn particles.
        if minetest.get_node(pos).name == "air" then
                minetest.set_node(pos, {name = "default:lava_source"})
        end
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
            texture="default_obsidian.png"
        })
        self.object:remove()
    end,
})
-- REGISTER SPAWN PARAMETERS
mobs:spawn_specific("mesecraft_mobs:magma_man", {"default:cobblestone", "default:stone", "magma_conduits:hot_cobble", "magma_conduits:glow_obsidian","magma_conduits:stone", "group:stone"}, {"default:lava_flowing", "default:lava_source"}, 0, 16, 480, 6000, 1, -12499,-6500)   

-- REGISTER SPAWN EGG
mobs:register_egg("mesecraft_mobs:magma_man", "Magma Man Spawn Egg", "default_lava.png", 1)
