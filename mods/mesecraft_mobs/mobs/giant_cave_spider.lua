--TODO ADD POISON
--TODO ADD JUMPS AND CLIMBS
-- declare velocity for spider crawl function
local get_velocity = function(self)

        local v = self.object:get_velocity()

        return (v.x * v.x + v.z * v.z) ^ 0.5
end
-- REGISTER WEB EXPLOSION FUNCTION
function explosion_web(pos, webtype)
    pos.y = round(pos.y)
    for i=pos.x-1, pos.x+1, 1 do
        for j=pos.y-3, pos.y, 1 do
            for k=pos.z-1, pos.z+1, 1 do
                -- TODO 0 check, why are we operating on two positions?
                local p = {x=i,y=j,z=k}
                local k = {x=i,y=j+1,z=k}
                local current = minetest.get_node(p).name
                local ontop  = minetest.get_node(k).name
                if current == "air" then
                --if not nssm.unswappable_node(p) then -- replaces to many nodes
                    minetest.set_node(p, {name=webtype})
                end
            end
        end
    end
end

--register spider mob
mobs:register_mob("mesecraft_mobs:giant_cave_spider", {
	type = "monster",
	knock_back = false,
	attack_animals = true,
	attack_nps = true,
	pathfinding = 1,
	hp_min = 100,
	hp_max = 100,
    	armor = 100,
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 1.4, 0.7},
	textures = {
		{"mesecraft_mobs_spider.png"},
		{"mesecraft_mobs_spider_2.png"},
	},
	visual_size = {x=4,y=4},
	visual = "mesh",
	mesh = "mesecraft_mobs_spider.b3d",
	makes_footstep_sound = false,
	view_range = 8,
	walk_velocity = 1,
	run_velocity = 3,
	damage = 50,
	drops = {
		{name = "mesecraft_mobs:spiderweb", chance = 1, min = 1, max = 4,},
		{name = "mobs_creautres:meat", chance = 1, min = 1, max = 8,}
	},
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	attack_type = "dogshoot",
	arrow = "mesecraft_mobs:spiderweb_ball",
	shoot_interval = 2.5,
	shoot_offset = 1,
	dogshoot_switch = 1,
	dogshoot_count_max = 1.8,
	animation = {
	        stand_speed = 10,
	        walk_speed = 25,
		run_speed = 50,
		stand_start = 20,
	        stand_end = 40,
		walk_start = 0,
	        walk_end = 20,
		run_start = 0,
	        run_end = 20,
	},
	jump = true,
	step = 1,
       	sounds = {
                random = "mesecraft_mobs_spider_random",
                jump = "mesecraft_mobs_spider_jump",
                death = "mesecraft_mobs_spider_death",
                distance = 16,
        },
	-- custom function to make spiders climb vertical facings
	do_custom = function(self, dtime)

		-- quarter second timer
		self.spider_timer = (self.spider_timer or 0) + dtime
		if self.spider_timer < 0.25 then
			return
		end
		self.spider_timer = 0

		-- need to be stopped to go onwards
		if get_velocity(self) > 0.2 then
			self.disable_falling = false
			return
		end

		local pos = self.object:get_pos()
		local yaw = self.object:get_yaw()

		pos.y = pos.y + self.collisionbox[2] - 0.2

		local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)
		local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)
		local nod = minetest.get_node_or_nil({
			x = pos.x + dir_x,
			y = pos.y + 0.5,
			z = pos.z + dir_z
		})

		-- get current velocity
		local v = self.object:get_velocity()

		-- can only climb solid facings
		if not nod or not minetest.registered_nodes[nod.name]
		or not minetest.registered_nodes[nod.name].walkable then
			self.disable_falling = nil
			v.y = 0
			self.object:set_velocity(v)
			return
		end

--print ("----", nod.name, self.disable_falling, dtime)

		-- turn off falling if attached to facing
		self.disable_falling = true

		-- move up facing
		v.y = self.jump_height
		mobs:set_animation(self, "jump")
		self.object:set_velocity(v)
	end
})
-- REGISTER WEB BALL ARROW
mobs:register_arrow("mesecraft_mobs:spiderweb_ball", {
    visual = "sprite",
    visual_size = {x = 2, y = 2},
    textures = {"mesecraft_mobs_items_spiderweb.png"},
    velocity = 12,
    -- direct hit
    hit_player = function(self, player)
        local p = player:get_pos()
        explosion_web(p, "mesecraft_mobs:spiderweb")
    end,
    hit_mob = function(self, player)
        player:punch(self.object, 1.0, {
            full_punch_interval = 1.0,
            damage_groups = {fleshy = 10},
        }, nil)
    end,

    hit_node = function(self, pos, node)
        explosion_web(pos, "mesecraft_mobs:spiderweb")
    end
})

--API Template: mobs:spawn_specfic(name, nodes, neighbors, min_light, max_light, interval, chance, active_object_count, min_height, max_height, day_toggle, on_spawn)
mobs:spawn_specific("mesecraft_mobs:giant_cave_spider", { "group:cracky", "group:crumbly", "group:shovely", "group:pickaxey", "mesecraft_mobs:spiderweb", "df_mapitems:dirt_with_cave_moss", "default:dirt"}, {"air"}, 0, 7, 240, 8000, 6, -6500, -500)
mobs:register_egg("mesecraft_mobs:giant_cave_spider", "Giant Cave Spider Spawn Egg", "wool_black.png", 1)
