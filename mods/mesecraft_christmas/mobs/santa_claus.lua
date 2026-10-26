mobs:register_mob("mesecraft_christmas:santa_claus", {
		type = "npc",
		passive = false,
		attack_type = "dogfight",
		attacks_monsters = true,
		attack_animals = false,
		attack_npcs = false,
		damage = 5,
		reach = 2,
		pathfinding = false,
		nametag = "Santa Claus", 
		hp_min = 25,
		hp_max = 25,
		armor = 50,
		collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
		visual = "mesh",
		mesh = "mobs_character.b3d",
		textures = {
			{"mesecraft_christmas_santa.png"},
		},
		makes_footstep_sound = true,
		sounds = {
			random = "mesecraft_christmas_santa_random",
			attack = "mesecraft_christmas_sleighbell",
			damage = "mesecraft_christmas_sleighbell",
			jump = "mesecraft_christmas_sleighbell",
			death = "mesecraft_christmas_santa_random",
		},
		blood_amount = 0,
		walk_velocity = 0,
		run_velocity = 0,
		jump = false,
		suffocation = false,
		knock_back = false,
		water_damage = 0,
		lava_damage = 0,
		light_damage = 0,
		view_range = 15,
		owner = "",
		fear_height = 3,
	        animation = {
	                speed_normal = 30,
	                speed_run = 30,
	                stand_start = 0,
	                stand_end = 79,
--	                walk_start = 168,
--	                walk_end = 187,
--	                run_start = 168,
--	                run_end = 187,
	                punch_start = 200,
	                punch_end = 219,
	        },
		        on_rightclick = function(self, clicker)
            		   mobs_trader(self, clicker, entity, mesecraft_christmas.santa)
		end,
	        on_spawn = function(self)
	                self.nametag = "Santa Claus"
	                self.object:set_properties({
	                        nametag = self.nametag,
	                        nametag_color = "#BB2528"
	                })
	                return true -- return true so on_spawn is run once only
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
		-- Mob will remove itself if its not Christmas time. 
	        do_custom = function(self)
			if not mesecraft_seasonal.keep(self, "christmas") then return false end
	        end,
})

-- Register Santa's Trading Table
mesecraft_christmas.santa = {

	names = { "Santa Claus" },
	items = {
                --{item for sale, price, chance of appearing in trader's inventory}
		{"mesecraft_christmas:present_01 1", "mesecraft_mobs:milk_glass 1", 1},
		{"mesecraft_christmas:present_02 1", "mesecraft_mobs:milk_glass 1", 1},
		{"mesecraft_christmas:present_03 1", "mesecraft_mobs:milk_glass 1", 1},
		{"mesecraft_christmas:present_04 1", "mesecraft_christmas:sugar_cookie 1", 1},
		{"mesecraft_christmas:present_05 1", "mesecraft_christmas:sugar_cookie_bell 1", 1},
		{"mesecraft_christmas:present_06 1", "mesecraft_christmas:sugar_cookie_star 1", 1},
		{"mesecraft_christmas:present_07 1", "mesecraft_christmas:sugar_cookie_tree 1", 1},
		}
	}
-- Register Spawn Eggs
mobs:register_egg("mesecraft_christmas:santa_claus", "Santa Claus Spawn Egg", "wool_red.png", 1)

-- Spawns on Solid blocks -- Santa's spawning parameters. Autoremove (do_custom) if not christmas-time.
mesecraft_seasonal.register_spawn("mesecraft_christmas:santa_claus", {
	season = "christmas",
	nodes = {"default:snow", "default:snowblock", "default:dirt_with_snow"},
	min_light = 7, max_light = 16,
	min_y = 2, max_y = 200,
})