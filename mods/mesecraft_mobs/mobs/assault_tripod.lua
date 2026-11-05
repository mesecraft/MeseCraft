-- ASSAULT TRIPOD
-- A SynTek war machine that guards the Nether, firing rockets and exploding
-- when destroyed. Named after Freedoom's assault tripod; sounds from Freedoom
-- (see credits.txt).

mobs:register_mob("mesecraft_mobs:assault_tripod", {
        type = "monster",
        passive = false,
        reach = 6,
        damage = 2,
        attack_type = "shoot",
	shoot_interval = 2,
	arrow = "mesecraft_mobs:a_assault_tripod_rocket",
	shoot_offset = 1,
        hp_min = 666,
        hp_max = 666,
        armor = 100,
	visual = "mesh",
	mesh = "mobs_character.b3d",
	collisionbox = {-1.0,-3.0,-1.0, 1.0,2.4,1.0},
	visual_size = {x=3.0, y=3.0},
        textures = {
                {"mesecraft_mobs_assault_tripod.png"},
        },
	knock_back = false,
        makes_footstep_sound = true,
        walk_velocity = 1,
        run_velocity = 2.1,
        sounds = {
           distance = 32,
           random = "mesecraft_mobs_assault_tripod_random",
           war_cry = "mesecraft_mobs_assault_tripod_warcry",
           shoot_attack = "mesecraft_mobs_assault_tripod_shoot",
           damage = "mesecraft_mobs_assault_tripod_damage",
           death = "mesecraft_mobs_assault_tripod_death",
        },
        jump = true,
        drops = {
                {name = "bweapons_hitech_pack:missile_launcher", chance = 100, min = 1, max = 1}, -- Uses bweapons_modpack for drops
                {name = "bweapons_hitech_pack:missile", chance = 1, min = 1, max = 24},
        },
        water_damage = 0,
        lava_damage = 0,
        light_damage = 0,
        view_range = 32,
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
   on_die = function(self,pos)
                          mobs:explosion(pos, 3, 5, 3)
            end,
})
-- REGISTER ARROW: ASSAULT TRIPOD ROCKET (EXPLOSIVE)
mobs:register_arrow("mesecraft_mobs:a_assault_tripod_rocket", {
   visual = "sprite",
   visual_size = {x = 1.0, y = 1.0},
   textures = {"mesecraft_mobs_arrow_rocket.png"},
   velocity = 15,
   tail = 1, -- enable tail
   glow = 5,
   tail_texture = "mesecraft_mobs_arrow_rocket_trail.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 20},
      }, nil)
   end,
   
   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 20},
      }, nil)
   end,

   hit_node = function(self, pos, node)
        if minetest.get_node(pos).name ~= "default:cobble" then
              mobs:explosion(pos, 2, 2, 2)
        end
   end,
})

-- REGISTER SPAWN PARAMETERS
mobs:spawn_specific("mesecraft_mobs:assault_tripod", {"nether:sand","default:lava_source","nether:glowstone"},{"air"}, 0, 16, 600, 10000, 1, -30912, -16000)

-- REGISTER SPAWN EGG
mobs:register_egg("mesecraft_mobs:assault_tripod", "Assault Tripod Spawn Egg", "wool_red.png", 1)
