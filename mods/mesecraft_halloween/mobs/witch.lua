--original base concept code by maikerumine, License WTFPL
--witch arrow texture and arrow shoot sound from gadgets_modpack by clockgen.
--sounds from snowsong mc pack.
--todo: drops

--Witch for halloween event (Oct 20 - Nov 3).
mobs:register_mob("mesecraft_halloween:witch", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
        collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "mobs_character.b3d",
	textures = {
		{"mesecraft_halloween_witch.png"},
	},
	makes_footstep_sound = true,
	damage = 6,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	pathfinding = 1,
	group_attack = true,
	suffocation = false,
	knockback = true,
	attack_type = "dogshoot",
	arrow = "mesecraft_halloween:witch_curse",
	shoot_interval = 2,
	dogshoot_switch = 2,
	dogshoot_count = 0,
	dogshoot_count_max =5,
	shoot_offset = 1.5,
	drops = {
                {name = "mesecraft_halloween:candycorn", chance = 4, min = 1, max = 2},
                {name = "mesecraft_halloween:caramel_apple", chance = 4, min = 1, max = 2},
                {name = "mesecraft_halloween:halloween_chocolate", chance = 4, min = 1, max = 2},
                {name = "mesecraft_halloween:lolipop", chance = 4, min = 1, max = 2},
                {name = "magic_materials:magic_flower", chance = 10, min = 1, max = 1},
                {name = "magic_materials:magic_mushroom", chance = 10, min = 1, max = 2},
                {name = "magic_materials:magic_root", chance = 10, min = 1, max = 2},
		{name = "gadgets_consumables:potion_mana_regen_02", chance = 10, min = 1, max = 1},
                {name = "gadgets_consumables:potion_gravity_02", chance = 10, min = 1, max = 1},
                {name = "mesecraft_halloween:mask_cat", chance = 100, min = 1, max = 1},
                {name = "mesecraft_halloween:suit_wizard", chance = 100, min = 1, max = 1},
                {name = "bweapons_magic_pack:staff_void", chance = 100, min = 1, max = 1},
	},
	sounds = {
		random = "mesecraft_mobs_witch_random",
		death = "mesecraft_mobs_witch_death",
		damage = "mesecraft_mobs_witch_damage",
		shoot_attack = "mesecraft_mobs_witch_shoot_attack",
		attack = "mesecraft_mobs_witch_attack",
		distance = 16,
	},
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
	water_damage = 5,
	lava_damage = 5,
	light_damage = 5,
	view_range = 16,
	fear_height = 4,
	    -- Only spawn around Halloween date/time (Oct 10th - Nov 1st, 3 weeks).
	do_custom = function(self)
	        if not mesecraft_seasonal.keep(self, "halloween") then return false end
	    end,
})
-- Witch's Arrow
mobs:register_arrow(":mesecraft_halloween:witch_curse", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"mesecraft_halloween_witch_arrow.png"},
	velocity = 10,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		--fire:permanent_flame(pos, 1, 1, 0) --causes crash.
	end
})

-- spawn egg
mobs:register_egg("mesecraft_halloween:witch", "Witch Spawn Egg", "mesecraft_halloween_witch_arrow.png", 1)

--mobs:spawn_specfic(name, nodes, neighbors, min_light, max_light, interval,chance, active_object_count, min_height, max_height, day_toggle, on_spawn)
-- World spawning parameters for the witch.
mesecraft_seasonal.register_spawn("mesecraft_halloween:witch", {
	season = "halloween",
	nodes = {"group:cracky", "group:crumbly", "group:shovely", "group:pickaxey"},
	min_light = 0, max_light = 5,
	min_y = -30912, max_y = 30192,
	weight = 2,
})