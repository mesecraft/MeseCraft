-- FIRE ELEMENTAL
-- INSPIRED BY THE FIREMAN FROM DWARF FORTRESS
-- Skin: original art for MeseCraft, drawn by utils/skingen/skingen.py.
-- TODO: Drops ash and lye.
mobs:register_mob("mesecraft_mobs:fire_man", {
   type = "monster",
   passive = false,
   attacks_monsters = false,
   damage = 4,
   reach = 2,
   attack_type = "dogshoot",
   arrow = "mesecraft_mobs:fire_man_fireball",
   shoot_interval = 2.5,
   dogshoot_switch = 2,
   dogshoot_count = 0,
   dogshoot_count_max =2,
   hp_min = 10,
   hp_max = 10,
   armor = 200,
   knock_back = false,
   collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
   visual = "mesh",
   mesh = "mobs_character.b3d",
   textures = {
  	    {"mesecraft_mobs_fire_man.png"},
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
   blood_texture = "fire_basic_flame.png",
   makes_footstep_sound = true,
   walk_velocity = 1,
   run_velocity = 2,
   jump = true,
   fly = false,
   water_damage = 0,
   lava_damage = 0,
   light_damage = 0,
   view_range = 16,
   sounds = {
	death = "fire_extinguish_flame",
        shoot_attack = "mesecraft_mobs_common_shoot_fireball",
	random = "fire_fire",
	},
   drops = {
--		{name = "mesecraft_mobs:ash", chance = 1, min = 1, max = 4}
	},
   do_custom = function(self)
		local apos = self.object:get_pos()
		minetest.add_particlespawner({
			1, --amount
			0.3, --time
			{x=apos.x-0.3, y=apos.y-1, z=apos.z-0.3}, --minpos
			{x=apos.x+0.3, y=apos.y+1, z=apos.z+0.3}, --maxpos
			{x=-0, y=-0, z=-0}, --minvel
			{x=0, y=0, z=0}, --maxvel
			{x=0,y=1,z=0}, --minacc
			{x=0.5,y=1.2,z=0.5}, --maxacc
			3, --minexptime
			4, --maxexptime
			1, --minsize
			3, --maxsize
			true, --collisiondetection
			"fire_basic_flame.png" --texture
		})
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
            texture="fire_basic_flame.png"
        })
        self.object:remove()
    end,
})
-- FIRE ELEMENTAL FIREBALL PROJECTILE
mobs:register_arrow("mesecraft_mobs:fire_man_fireball", {
   visual = "sprite",
   visual_size = {x = 0.5, y = 0.5},
   textures = {"mesecraft_mobs_arrow_fireball.png"},
   velocity = 7,
   glow = 5,
   tail = 1, -- enable tail
   tail_texture = "mesecraft_mobs_arrow_fireball_trail.png",
   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 32},
      }, nil)
       minetest.sound_play({name = "mesecraft_mobs_common_shoot_fireball_hit", gain = 1.0}, {pos=player:get_pos(), max_hear_distance = 12})
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 32},
      }, nil)
   end,

   hit_node = function(self, pos, node)
        minetest.sound_play({name = "mesecraft_mobs_common_shoot_fireball_hit", gain = 1.0}, {pos=pos, max_hear_distance = 12})
        minetest.set_node(pos, {name = "fire:permanent_flame"})
        self.object:remove()
   end,
})
-- REGISTER SPAWN PARAMETERS
mobs:spawn_specific("mesecraft_mobs:fire_man", {"default:cobblestone", "default:stone", "magma_conduits:hot_cobble", "magma_conduits:glow_obsidian","magma_conduits:stone", "group:stone"}, {"default:lava_flowing", "default:lava_source"}, 0, 16, 240, 12000, 2, -12499,-6500)   

-- REGISTER SPAWN EGG
mobs:register_egg("mesecraft_mobs:fire_man", "Fire Man Spawn Egg", "fire_basic_flame.png", 1)
