-- COMBAT SLUG
-- A bloated creature with rocket-firing arm cannons. Named after Freedoom's
-- combat slug; sounds from Freedoom (see credits.txt).

mobs:register_mob("mesecraft_mobs:combat_slug", {
   type = "monster",
   passive = false,
   reach = 2,
   attack_type = "shoot",
   shoot_interval = 4.0,
   arrow = "mesecraft_mobs:a_combat_slug_rocket",
   shoot_offset = 1,
   hp_min = 50,
   hp_max = 50,
   armor = 100,
   collisionbox = {-0.95,-2.0,-0.95, 0.95,1.6,0.95},
   visual = "mesh",
   mesh = "mobs_character.b3d",
   textures = {
      {"mesecraft_mobs_combat_slug.png"},
   },
   visual_size = {x=3, y=2},
   makes_footstep_sound = true,
   walk_velocity = 1,
   run_velocity = 1.5,
   knock_back = false,
   jump = true,
   sounds = {
      distance = 20,
      random = "mesecraft_mobs_combat_slug_random",
      war_cry = "mesecraft_mobs_combat_slug_warcry",
      shoot_attack = "mesecraft_mobs_combat_slug_shoot",
      damage = "mesecraft_mobs_combat_slug_damage",
      death = "mesecraft_mobs_combat_slug_death",
   },
   drops = {
      {name = "mesecraft_mobs:meat", chance = 1, min = 1, max = 5},
      {name = "bweapons_hitech_pack:missile", chance = 1, min = 1, max = 6},
   },
   water_damage = 0,
   lava_damage = 0,
   light_damage = 0,
   view_range = 12,
        animation = {
                speed_normal = 30,
                speed_run = 45,
                stand_start = 0,
                stand_end = 79,
                walk_start = 168,
                walk_end = 187,
                run_start = 168,
                run_end = 187,
                punch_start = 200,
                punch_end = 219,
                shoot_start = 200,
                shoot_end = 219,
        },
})
-- REGISTER PROJECTILE
mobs:register_arrow("mesecraft_mobs:a_combat_slug_rocket", {
   visual = "sprite",
   visual_size = {x = 1, y = 1},
   textures = {"mesecraft_mobs_arrow_rocket.png"},
   velocity = 12,
   tail = 1, -- enable tail
   glow = 5,
   tail_texture = "mesecraft_mobs_arrow_rocket_trail.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 15},
      }, nil)
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 15},
      }, nil)
   end,

   hit_node = function(self, pos, node)
	if minetest.get_node(pos).name ~= "default:cobble" then
	      mobs:explosion(pos, 2, 2, 2)
	end
   end,
})

-- REGISTER SPAWN PARAMETERS
mobs:spawn_specific("mesecraft_mobs:combat_slug", {"nether:sand","nether:glowstone","default:lava_source"}, {"air"}, 0, 16, 480, 3000, 4, -30912, -16000)

-- REGISTER SPAWN EGG
mobs:register_egg("mesecraft_mobs:combat_slug", "Combat Slug Spawn Egg", "default_sand.png", 1)
