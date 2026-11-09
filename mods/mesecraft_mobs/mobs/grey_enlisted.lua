-- TODO: Add own projectile texture, add drops
-- GREY ALIEN ENLISTED
mobs:register_mob("mesecraft_mobs:grey_enlisted", {
   type = "monster",
   passive = false,
   damage = 3,
   reach = 2,
   attack_type = "dogshoot",
   shoot_interval = 2,
   dogshoot_switch = 1,
   dogshoot_count = 1,
   dogshoot_count_max = 2.1,
   arrow = "mesecraft_mobs:a_greys_energy_pistol",
   shoot_offset = 1.5,
   hp_min = 15,
   hp_max = 15,
   armor = 50,
   collisionbox = {-0.35,-0.85,-0.35, 0.35,0.70,0.35},
   visual = "mesh",
   mesh = "mobs_character.b3d",
   textures = {
      {"mesecraft_mobs_grey_enlisted.png"},
   },
   blood_amount = 8,
   visual_size = {x=0.9, y=0.9},
   makes_footstep_sound = true,
   walk_velocity = 2,
   run_velocity = 2.5,
   floats = 1,
   jump = true,
   sounds = {
                distance = "16",
                random = "mesecraft_mobs_grey_enlisted_random",
                attack = "mesecraft_mobs_grey_attack",
                shoot_attack = "mesecraft_mobs_grey_enlisted_shoot",
		war_cry = "mesecraft_mobs_grey_enlisted_warcry",
                damage = "mesecraft_mobs_grey_damage",
                death = "mesecraft_mobs_grey_death",
   },
   drops = {
--      {name = "default:coal_lump", chance = 1, min = 1, max = 2},
   },
   water_damage = 5,
   lava_damage = 10,
   light_damage = 0,
   view_range = 12,
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
})
--Spawn Functions
mobs:spawn_specific("mesecraft_mobs:grey_enlisted", {"default:gravel"}, {"vacuum:vacuum"}, 0, 16, 480, 2400, 2, 3200, 3400, false)

-- Register Spawn Egg
mobs:register_egg("mesecraft_mobs:grey_enlisted", "Grey Enlisted Spawn Egg", "default_stone.png", 1)

-- PROJECTILE ENERGY PISTOL
mobs:register_arrow("mesecraft_mobs:a_greys_energy_pistol", {
   visual = "sprite",
   visual_size = {x = 5.0, y = 0.5},
   textures = {"mesecraft_mobs_arrow_plasmaball.png"},
   velocity = 10,
   glow = 5,
   tail = 1, -- enable tail
   tail_texture = "mesecraft_mobs_arrow_plasmaball.png",
   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 20},
      }, nil)
       minetest.sound_play({name = "mesecraft_mobs_common_shoot_plasmaball_hit", gain = 1.0}, {pos=player:get_pos(), max_hear_distance = 12})
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 20},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      minetest.sound_play({name = "mesecraft_mobs_common_shoot_plasmaball_hit", gain = 1.0}, {pos=pos, max_hear_distance = 12})
      self.object:remove()
   end,
})

-------- CREDITS & ATTRIBUTIONS --------
-- Concept and implementation by FreeGamers.org
-- Skin: original art for MeseCraft, drawn by utils/skingen/skingen.py.
-- Sounds: built from Freedoom (BSD) by utils/mobsounds/freedoom_sounds.py.

