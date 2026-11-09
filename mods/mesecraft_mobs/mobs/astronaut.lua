--ASTRONAUT
-- TODO, DROPS, SOUNDS, ATTRIBUTIONS, trader
mobs:register_mob('mesecraft_mobs:astronaut', {
	type = "npc",
	attack_type = "dogfight",
	passive = false,
	attacks_monsters = true,
	attack_animals = false,
	attack_npcs = false,
	reach = 2,
	damage = 7,
	hp_min = 15,
	hp_max = 20,
	armor = 115,
	knock_back = false,
        collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
        visual = "mesh",
        mesh = "mobs_character.b3d",
        textures = {
                {"mesecraft_mobs_astronaut.png"},
        },
	blood_texture = "mobs_blood.png",
	makes_footstep_sound = true,
	sounds = {
		random ="mesecraft_mobs_astronaut_random",
--		warcry = "mesecraft_mobs_zombie_warcry",
--		attack = "mesecraft_mobs_zombie_attack",
--		damage = "mesecraft_mobs_zombie_damage",
--		death = "mesecraft_mobs_zombie_death",
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	floats = true,
	suffocation = false,
	view_range = 16,
	drops = {
--	{name = "mesecraft_mobs:rotten_flesh", chance = 5, min = 0, max = 1}
	},
	lava_damage = 5,
	water_damage = 2,
	light_damage = 0,
	fall_damage = 2,
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
        on_rightclick = function(self, clicker)
                mobs_trader(self, clicker, entity, mobs.lunar_human)
	end,

})

--Spawn Functions
mobs:spawn_specific("mesecraft_mobs:astronaut", {"default:gravel"}, {"vacuum:vacuum"}, 7, 16, 600, 1000, 1, 3000 ,3500)

--Spawn Eggs
mobs:register_egg("mesecraft_mobs:astronaut", "Astronaut Spawn Egg", "wool_white.png", 1)

-------- CREDITS & ATTRIBUTIONS --------
-- Trader concept by FreeGamers.org
-- Skin: original art for MeseCraft, drawn by utils/skingen/skingen.py.
-- Sounds by craigsmith - https://freesound.org/people/craigsmith/sounds/438900/
