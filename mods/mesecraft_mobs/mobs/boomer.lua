-- Skin: original art for MeseCraft, drawn by utils/skingen/skingen.py.
--License for code WTFPL and otherwise stated in readmes
-- REGISTER MOB & ATTRIBUTES
mobs:register_mob("mesecraft_mobs:boomer", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	pathfinding = 1,
	visual = "mesh",
	mesh = "mobs_character.b3d",
	textures = {
		{"mesecraft_mobs_boomer.png"},
	},
	sounds = {
		attack = "tnt_ignite",
		death = "mesecraft_mobs_boomer_death",
		damage = "mesecraft_mobs_boomer_damage",
		fuse = "tnt_ignite",
		explode = "tnt_explode",
		distance = 16,
	},
	makes_footstep_sound = true,
	walk_velocity = 1.05,
	run_velocity = 2.5,
	runaway_from = { "mobs_mc:ocelot", "mobs_mc:cat" },
	attack_type = "explode",
	damage = 30,
	explosion_radius = 3,
	reach = 2,
	explosion_damage_radius = 7,
	explosion_timer = 1.5,
	allow_fuse_reset = true,
	stop_to_explode = true,
	-- Force-ignite creeper with flint and steel and explode after 1.5 seconds.
	-- TODO: Make creeper flash after doing this as well.
	-- TODO: Test and debug this code.
	on_rightclick = function(self, clicker)
		if self._forced_explosion_countdown_timer ~= nil then
			return
		end
		local item = clicker:get_wielded_item()
		if item:get_name() == "fire:flint_and_steel" then
			if not minetest.settings:get_bool("creative_mode") then
				-- Wear tool
				local wdef = item:get_definition()
				item:add_wear(1000)
				-- Tool break sound
				if item:get_count() == 0 and wdef.sound and wdef.sound.breaks then
					minetest.sound_play(wdef.sound.breaks, {pos = clicker:get_pos(), gain = 0.5})
				end
				clicker:set_wielded_item(item)
			end
			self._forced_explosion_countdown_timer = self.explosion_timer
			minetest.sound_play(self.sounds.attack, {pos = self.object:get_pos(), gain = 1, max_hear_distance = 16})
		end
	end,
	do_custom = function(self, dtime)
		if self._forced_explosion_countdown_timer ~= nil then
			self._forced_explosion_countdown_timer = self._forced_explosion_countdown_timer - dtime
			if self._forced_explosion_countdown_timer <= 0 then
				mobs:explosion(self.object:get_pos(), self.explosion_radius, 0, 1, self.sounds.explode)
				self.object:remove()
			end
		end
	end,
	maxdrops = 2,
	drops = {
		{name = "tnt:gunpowder", chance = 1, min = 1, max = 4,},
                {name = "tnt:tnt_stick", chance = 25, min = 1, max = 2,},
                {name = "tnt:tnt", chance = 100, min = 1, max = 1,},
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
                punch_start = 0,
                punch_end = 79,
        },
	floats = 1,
	fear_height = 4,
	water_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	view_range = 16,
	blood_amount = 0,
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
            minsize = 2,
            maxsize = 4,
            collisiondetection = false,
	    texture="tnt_smoke.png"
        })
        self.object:remove()
    end,
})

-- Spawns on Solid blocks
mobs:spawn_specific("mesecraft_mobs:boomer", {"group:cracky", "group:crumbly", "group:shovely", "group:pickaxey"}, {"air"}, 0, 6, 60, 10000, 2, -26000, 150, false)

-- spawn eggs
mobs:register_egg("mesecraft_mobs:boomer", "Boomer Spawn Egg", "tnt_bottom.png", 1)
