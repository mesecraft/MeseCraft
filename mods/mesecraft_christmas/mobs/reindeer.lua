	mobs:register_mob("mesecraft_christmas:reindeer" , {
		type = "animal",
		passive = false,
		attack_type = "dogfight",
                attacks_monsters = true,
                attack_animals = false,
                attack_npcs = false,
		damage = 5,
		reach = 2,
		hp_min = 20,
		hp_max = 20,
		armor = 25,
		collisionbox = {-0.35, -0.01, -0.35, 0.35, 1.2, 0.35},
		visual = "mesh",
		mesh = "reindeer.b3d",
		textures = {
			{"mesecraft_christmas_reindeer.png"},
		},
		makes_footstep_sound = true,
		sounds = {
			random = "mesecraft_christmas_reindeer_random",
			damage = "mesecraft_christmas_sleighbell",
			jump = "mesecraft_christmas_sleighbell",
			attack = "mesecraft_christmas_sleighbell",
			death = "mesecraft_christmas_reindeer_random",
		},
		walk_velocity = 0,
		run_velocity = 0,
		jump = false,
		suffocation = false,
		knock_back = false,
		water_damage = 0,
		lava_damage = 0,
		light_damage = 0,
		animation = {
			speed_normal = 25,
			speed_normal = 25,
			speed_run = 25,
			stand_start = 0,
			stand_end = 200,
			walk_start = 149,
			walk_end = 150,
			run_start = 150,
			run_end = 170,
		},
		follow = "mesecraft_christmas:candy_cane",
		view_range = 15,
		fear_height = 3,
		on_rightclick = function(self, clicker)
	                mobs_trader(self, clicker, entity, mesecraft_christmas.reindeer)
       		end,
                on_spawn = function(self)
                        self.nametag = "Santa's Reindeer"
                        self.object:set_properties({
                                nametag = self.nametag,
                                nametag_color = "#BB2528"
                	})
                        return true -- return true so on_spawn is run once only
                end,
		do_custom = function(self)
			if self.nametag == "Trader Rudolph" then
				self.textures = "mesecraft_christmas_reindeer_rudolph.png"
			end
			-- Remove mobs when its not Christmastime.
                        if not mesecraft_seasonal.keep(self, "christmas") then return false end
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
	                    texture="mesecraft_christmas_present_07.png"
	                })
	                self.object:remove()
	                end,

})

-- REGISTER SPAWN EGG
	mobs:register_egg("mesecraft_christmas:reindeer","Christmas Reindeer", "wool_brown.png", 1)

-- Reindeer's Trading Table
mesecraft_christmas.reindeer = {

        names = { "Dasher", "Dancer", "Prancer", "Vixen", "Comet", "Cupid", "Donner", "Blitzen", "Rudolph" },
        items = {
                --{item for sale, price, chance of appearing in trader's inventory}
                {"mesecraft_christmas:present_01 1", "default:apple 1", 1},
                {"mesecraft_christmas:present_02 1", "default:apple 1", 1},
                {"mesecraft_christmas:present_03 1", "default:apple 1", 1},
                {"mesecraft_christmas:present_04 1", "farming:oat 1", 1},
                {"mesecraft_christmas:present_05 1", "farming:oat 1", 1},
                {"mesecraft_christmas:present_06 1", "farming:carrot 1", 1},
                {"mesecraft_christmas:present_07 1", "farming:carrot 1", 1},
                }
        }

-- Spawns on Solid blocks -- Santa's spawning parameters.
mesecraft_seasonal.register_spawn("mesecraft_christmas:reindeer", {
	season = "christmas",
	nodes = {"default:snow", "default:snowblock", "default:dirt_with_snow"},
	min_light = 7, max_light = 16,
	min_y = 2, max_y = 200,
})