-- TODO: Make them mountable/rideable and tameable.
-- Inspired by Dwarf Fortress. Texture and model come from "horror" mod by D00Med.
mobs:register_mob("mesecraft_mobs:jabberer", {
   type = "monster",
   passive = false,
   attacks_monsters = true,
   knock_back = false,
   damage = 12,
   reach = 3,
   attack_type = "dogfight",
   hp_min = 100,
   hp_max = 100,
   armor = 100,
   collisionbox = {-0.5, -0, -0.6, 0.6, 1.6, 0.6},
   visual = "mesh",
   mesh = "mesecraft_mobs_jabberer.b3d",
   textures = {
      {"mesecraft_mobs_jabberer.png"},
   },
   
   blood_amount = 80,
   visual_size = {x=3, y=3},
   makes_footstep_sound = true,
   walk_velocity = 2,
   run_velocity = 3,
   jump = true,
   drops = {
      {name = "mesecraft_mobs:meat", chance = 1, min = 5, max = 15},
      {name = "mesecraft_mobs:bone", chance = 1, min = 5, max = 25},
      {name = "mesecraft_mobs:feather", chance = 1, min = 1, max = 1},
      {name = "mesecraft_mobs:leather", chance = 1, min = 1, max = 10},
   },
   sounds = {
           random = "mesecraft_mobs_jabberer_random",
           death = "mesecraft_mobs_jabberer_death",
	   damage = "mesecraft_mobs_jabberer_damage",
	   attack = "mesecraft_mobs_jabberer_attack",
           distance = 16,
        },

   water_damage = 0,
   lava_damage = 10,
   light_damage = 0,
   view_range = 12,
   animation = {
      speed_normal = 10,
      speed_run = 20,
      walk_start = 42,
      walk_end = 62,
      stand_start = 1,
      stand_end = 11,
      run_start = 42,
      run_end = 62,
      punch_start = 20,
      punch_end = 35,
   },
})
-- Spawn Egg   
mobs:register_egg("mesecraft_mobs:jabberer", "Jabberer Spawn Egg", "default_dirt.png", 1)

-- Spawning parameters
mobs:spawn_specific("mesecraft_mobs:jabberer", {"group:stone"}, {"air"}, 0, 7, 480, 12000, 1, -9500, -3500)

-- ATTRIBUTION
-- random sound MinigunFiend - https://freesound.org/people/MinigunFiend/sounds/175206/
-- attack sound dinodilopho - https://freesound.org/people/dinodilopho/sounds/263530/
-- death sound fabianacarmonas - https://freesound.org/people/fabianacarmonas/sounds/491462/
-- damage sound Ragu21- https://freesound.org/people/Ragu21/sounds/342162/ 
