-- CAVE CROCODILE BY FREEGAMERS.ORG
-- INSPIRED BY DWARF FORTRESS
-- MODEL AND TEXTURE BASED ON PALEOTEST BY ELCEEJO

-- Land and Water animation sets
local animation_water = {
		speed_normal = 10,
		speed_sprint = 20,
		stand_start = 150,
		stand_end = 170,
		walk_start = 150,
		walk_end = 170,
		punch_start = 130,
		punch_end = 145,
		punch_loop = false,
		}
local animation_land = {
		speed_normal = 10,
		speed_sprint = 20,
		stand_start = 50,
		stand_end = 120,
		walk_start = 1,
		walk_end = 40,
		punch_start = 130,
		punch_end = 145,
		punch_loop = false,
		}

-- REGISTER CAVE CROCODILE
mobs:register_mob("mesecraft_mobs:cave_crocodile", {
	type = "monster",
	hp_min = 50,
	hp_max = 50,
	armor = 100,
	passive = false,
	walk_velocity = 1.0,
	run_velocity = 2.75,
        walk_chance = 5,
        jump = false,
        jump_height = 1.1,
        stepheight = 1.1,
        fly = true,
        fly_in = "default:water_source",
        runaway = false,
        pushable = false,
        view_range = 4,
        knock_back = false,
        damage = 15,
	fear_height = 6,
	fall_speed = -1,
	fall_damage = 10,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
        suffocation = false,
        floats = 0,
	owner = "",
	order = "follow",
	follow = {"mobs_creatures:meat"},
        reach = 3,
        attack_chance = 30,
        attack_animals = true,
        attack_npcs = true,
        attack_players = true,
        owner_loyal = true,
        group_attack = false,
	attack_type = "dogfight",
	pathfinding = 0,
	makes_footstep_sound = true,
	sounds = {
		attack = "mesecraft_mobs_crocodile_attack",
		damage = "mesecraft_mobs_crocodile_damage",
		death = "mesecraft_mobs_crocodile_death",
		jump = "mesecraft_mobs_crocodile_jump",
	},
	drops = {
		{name = "mesecraft_mobs:meat", chance = 1, min = 1, max = 10},
		{name = "mesecraft_mobs:leather",	chance = 1, min = 1, max = 10},
	},
	visual = "mesh",
	visual_size = {x=9, y=9},
	collisionbox = {-1, -0.6, -0.8, 1, 0.7, 0.8},
	textures = {
		{"mesecraft_mobs_cave_crocodile.png"},
	},
	child_texture = {
		{"mesecraft_mobs_cave_crocodile.png"},
	},
	mesh = "mesecraft_mobs_crocodile.b3d",
	animation = {
		speed_normal = 10,
		speed_sprint = 20,
		stand_start = 50,
		stand_end = 120,
		walk_start = 1,
		walk_end = 40,
		punch_start = 130,
		punch_end = 145,
		punch_loop = false,
	},

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end

		if self.owner == "" then
			self.owner = clicker:get_player_name()
		else
			if self.order == "follow" then
				self.order = "stand"
			else
				self.order = "follow"

			end

		end

	end,

	do_custom = function(self, dtime, nodef)

-- Mob changes animation and can swim in water

	local nodef = minetest.registered_nodes[self.standing_in]

        if nodef.groups.water then

        self.fly = true     
        self.fly_in = "default:water_source"
        self.floats = 0
        self.view_range = 12
        self.walk_chance = 100
        self.animation = animation_water
	elseif not self:attempt_flight_correction() then

        self.fly = false
        self.floats = 0
        self.view_range = 8
        self.walk_chance = 10
        self.animation = animation_land
            return
	end

-- Behaviour for young mobs

	if self.child == true then
		self.type = "animal"
		self.passive = true
	        self.attack_animals = false
		self.walk_velocity = 0.3
		self.run_velocity = 0.3
		return
	end
	-- Can Lay Eggs	
                self.egg_timer = (self.egg_timer or 0) + dtime
                if self.egg_timer < 5 then
                       return
                end
                self.egg_timer = 0

                if self.child
                or math.random(1, 100) > 1 then
                        return
                end

                local pos = self.object:get_pos()

                minetest.add_entity(pos, "mesecraft_mobs:cave_crocodile_egg")
                minetest.sound_play("mesecraft_mobs_chicken_eggpop.ogg", {
                        pos = pos,
                        gain = 1.0,
                        max_hear_distance = 8,
                })
        end,
})

mobs:spawn_specific("mesecraft_mobs:cave_crocodile", {"default:water_source", "default:water_flowing", "default:river_water_source", "default:river_water_flowing", "group:stone"}, {"default:water_source", "default:water_flowing", "default:river_water_source", "default:river_water_flowing"}, 0, 7, 240, 2500, 2, -6500,-500) 
mobs:register_egg("mesecraft_mobs:cave_crocodile", "Cave Crocodile Spawn Egg", "default_silver_sand.png", 1)

-- Cave Crocodile Egg
mobs:register_mob("mesecraft_mobs:cave_crocodile_egg", {
	type = "nil",
	hp_min = 5,
	hp_max = 5,
	armor = 200,
	passive = true,
	walk_velocity = 0,
	run_velocity = 0,
	jump = false,
	runaway = false,
        pushable = true,
	fear_height = 5,
	fall_damage = 0,
	fall_speed = -8,
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	collisionbox = {-0.2, -0.5, -0.2, 0.2, 0, 0.2},
	visual = "mesh",
	mesh = "mesecraft_mobs_egg.b3d",
	textures = {
		{"mesecraft_mobs_egg_3.png"},
	},
	makes_footstep_sound = false,
	animation = {
		speed_normal = 1,
		stand_start = 1,
		stand_end = 1,
		walk_start = 1,
		walk_end = 1,
	},

	do_custom = function(self, dtime)

		self.egg_timer = (self.egg_timer or 0) + dtime
		if self.egg_timer < 10 then
			return
		end
		self.egg_timer = 0

		if self.child
		or math.random(1, 100) > 1 then
			return
		end

		local pos = self.object:get_pos()

		mob = minetest.add_entity(pos, "mesecraft_mobs:cave_crocodile")
                ent2 = mob:get_luaentity()
		self.object:remove()

		mob:set_properties({
			textures = ent2.child_texture[1],
			visual_size = {
				x = ent2.base_size.x / 2,
				y = ent2.base_size.y / 2
			},
			collisionbox = {
				ent2.base_colbox[1] / 2,
				ent2.base_colbox[2] / 2,
				ent2.base_colbox[3] / 2,
				ent2.base_colbox[4] / 2,
				ent2.base_colbox[5] / 2,
				ent2.base_colbox[6] / 2
			},
		})

		ent2.child = true
		ent2.tamed = false
	end
})


mobs:register_egg("mesecraft_mobs:cave_crocodile_egg", "Cave Crocodile Egg", "mesecraft_mobs_egg_3_inv.png", 0)
