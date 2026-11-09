-- HATCHLING
-- A small, fast flyer of the Nether. Named after Freedoom's hatchling.
-- Model and texture from D00Med's mobs_doom (CC BY-SA 3.0), recoloured for
-- MeseCraft; sounds from Freedoom (see credits.txt).

mobs:register_mob("mesecraft_mobs:hatchling", {
   type = "monster",
   passive = false,
   damage = 10,
   reach = 2,
   attack_type = "dogfight",
   hp_min = 20,
   hp_max = 20,
   armor = 100,
   collisionbox = {-0.2, -0.05, -0.2, 0.2, 0.75, 0.2},
   visual = "mesh",
   mesh = "mesecraft_mobs_hatchling.b3d",
   textures = {
      {"mesecraft_mobs_hatchling.png"},
   },
   visual_size = {x=1.5, y=1.5},
   makes_footstep_sound = true,
   sounds = {
      distance = 20,
      random = "mesecraft_mobs_hatchling_random",
      war_cry = "mesecraft_mobs_hatchling_warcry",
      attack = "mesecraft_mobs_hatchling_attack",
      damage = "mesecraft_mobs_hatchling_damage",
      death = "mesecraft_mobs_hatchling_death",
   },
   walk_velocity = 2,
   run_velocity = 4,
   jump = true,
   fly = true,
   -- A glowing trail. One spawner is attached to the mob the first time it
   -- steps and lasts as long as the mob, instead of a new one every step.
   do_custom = function(self)
      if self.trail then
         return
      end
      self.trail = minetest.add_particlespawner({
         amount = 8,
         time = 0, -- until the mob is removed
         attached = self.object,
         minpos = {x = -0.3, y = 0.6, z = -0.3},
         maxpos = {x = 0.3, y = 0.6, z = 0.3},
         minacc = {x = 0, y = 1.5, z = 0},
         maxacc = {x = 0.5, y = 1.5, z = 0.5},
         minexptime = 1,
         maxexptime = 1,
         minsize = 2,
         maxsize = 3,
         texture = "mesecraft_mobs_arrow_plasmaball_trail.png",
      })
   end,
   fall_speed = 0,
   stepheight = 10,
   water_damage = 0,
   lava_damage = 0,
   light_damage = 0,
   view_range = 16,
   glow = 6,
   animation = {
      speed_normal = 10,
      speed_run = 20,
      walk_start = 20,
      walk_end = 40,
      stand_start = 1,
      stand_end = 20,
      run_start = 20,
      run_end = 40,
      punch_start = 40,
      punch_end = 65,
   },
})

-- REGISTER SPAWN PARAMETERS
mobs:spawn_specific("mesecraft_mobs:hatchling", {"nether:sand", "nether:glowstone", "default:lava_source"}, {"air"}, 0, 16, 480, 4000, 5, -30912, -16000)

-- REGISTER SPAWN EGG
mobs:register_egg("mesecraft_mobs:hatchling", "Hatchling Spawn Egg", "wool_magenta.png", 1)

