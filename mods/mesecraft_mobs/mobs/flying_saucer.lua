-- Flying Saucer
-- TODO: Add Drops.
mobs:register_mob("mesecraft_mobs:flying_saucer", {
   type = "monster",
   passive = false,
   damage = 100,
   reach = 3,
   attack_type = "shoot",
   shoot_interval = 3,
   arrow = "mesecraft_mobs:a_devastator_energy_cannon",
   shoot_offset = 0.5,
   hp_min = 50,
   hp_max = 50,
   armor = 35,
   collisionbox = {-3, -0.25, -3,  3, 3,  3},
   visual = "mesh",
   mesh = "mesecraft_mobs_flying_saucer.x",
   textures = {
      {"mesecraft_mobs_flying_saucer.png"},
   },
   blood_amount = 10,
   blood_texture = "default_steel_block.png",
   visual_size = {x=2, y=2},
   makes_footstep_sound = false,
   walk_velocity = 8,
   run_velocity = 10,
        sounds = {
                distance = "32",
                random = "mesecraft_mobs_flying_saucer_random",
                war_cry = "mesecraft_mobs_flying_saucer_warcry",
                shoot_attack = "mesecraft_mobs_common_shoot_plasmaball",
                damage = "mesecraft_mobs_flying_saucer_damage",
                death = "mesecraft_mobs_flying_saucer_death",
        },
   jump = true,
   fly = true,
   fall_speed = 0,
   stepheight = 10,
   water_damage = 0,
   lava_damage = 0,
   light_damage = 0,
   view_range = 24,
   on_die = function(self,pos)
                          minetest.add_entity(pos, "mesecraft_mobs:grey_enlisted")
			  mobs:explosion(pos, 2, 1, 2)
            end

})

--Spawn Paramters, on the Moon, above surface, in vacuum.
mobs:spawn_specific("mesecraft_mobs:flying_saucer", {"vacuum:vacuum"}, {"vacuum:vacuum"}, 0, 8, 480, 12000, 1, 2315, 2330, false)

-- Register Spawn Egg.
mobs:register_egg("mesecraft_mobs:flying_saucer", "Flying Saucer Spawn Egg", "default_steel_block.png", 1)

-- Register Devastator Energy Projectile
mobs:register_arrow("mesecraft_mobs:a_devastator_energy_cannon", {
   visual = "sprite",
   visual_size = {x = 2, y = 2},
   textures = {"mesecraft_mobs_arrow_plasmaball.png"},
   velocity = 16,
   glow = 5,
   tail = 1, -- enable tail
   tail_texture = "mesecraft_mobs_arrow_plasmaball_trail.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 100},
      }, nil)
         minetest.sound_play({name = "mesecraft_mobs_common_shoot_plasmaball_hit", gain = 1.0}, {pos=player:get_pos(), max_hear_distance = 16})
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 100},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      minetest.sound_play({name = "mesecraft_mobs_common_shoot_plasmaball_hit", gain = 1.0}, {pos=pos, max_hear_distance = 16})
      self.object:remove()
   end,
})

-------- CREDITS AND ATTRIBUTIONS --------
-- Mob concept and implementation by FreeGamers.org
-- Flying Saucer model by Melkor
-- Flying Saucer texture by Pilcrow182, based on Melkor's textures for Zeg9's UFO mod.
-- Sounds: built from Freedoom (BSD) by utils/mobsounds/freedoom_sounds.py.
