-- TODO: Add drops, mese-based trading npc.
-- GREY CIVILIAN ALIEN
mobs:register_mob("mesecraft_mobs:grey_civilian", {
   type = "animal",
   passive = true,
   runaway = true,
   damage = 3,
   reach = 2,
   attack_type = "dogfight",
   hp_min = 15,
   hp_max = 15,
   armor = 100,
   collisionbox = {-0.35,-0.85,-0.35, 0.35,0.70,0.35},
   visual = "mesh",
   mesh = "mobs_character.b3d",
   textures = {
      {"mesecraft_mobs_grey_civilian.png"},
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
                random = "mesecraft_mobs_grey_civilian_random",
                attack = "mesecraft_mobs_grey_attack",
		war_cry = "mesecraft_mobs_grey_civilian_warcry",
                damage = "mesecraft_mobs_grey_damage",
                death = "mesecraft_mobs_grey_death",
   },
   drops = {
--      {name = "default:coal_lump", chance = 1, min = 1, max = 2},
   },
   water_damage = 1,
   lava_damage = 1,
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
mobs:spawn_specific("mesecraft_mobs:grey_civilian", {"default:gravel", "default:stone"}, {"vacuum:vacuum"}, 0, 16, 240, 1600, 4, 3000, 3200)

-- Register Spawn Egg
mobs:register_egg("mesecraft_mobs:grey_civilian", "Grey Civilian Spawn Egg", "default_stone.png", 1)

-------- CREDITS & ATTRIBUTIONS --------
-- Concept and implementation by FreeGamers.org
-- Skin: original art for MeseCraft, drawn by utils/skingen/skingen.py.
-- Sounds: built from Freedoom (BSD) by utils/mobsounds/freedoom_sounds.py.

