--global constants

helicopter.gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.8
helicopter.tilting_speed = 1
helicopter.tilting_max = 0.20
helicopter.power_max = 15
helicopter.power_min = 0.2 -- if negative, the helicopter can actively fly downwards
helicopter.wanted_vert_speed = 5

helicopter.vector_up = vector.new(0, 1, 0)
helicopter.vector_forward = vector.new(0, 0, 1)

helicopter.last_time_command = 0

function helicopter.vector_length_sq(v)
	return v.x * v.x + v.y * v.y + v.z * v.z
end

if not minetest.global_exists("matrix3") then
	dofile(minetest.get_modpath("helicopter") .. DIR_DELIM .. "matrix.lua")
end

function helicopter.check_node_below(obj)
	local pos_below = obj:get_pos()
	pos_below.y = pos_below.y - 0.1
	local node_below = minetest.get_node(pos_below).name
	local nodedef = minetest.registered_nodes[node_below]
	local touching_ground = not nodedef or -- unknown nodes are solid
			nodedef.walkable or false
	local liquid_below = not touching_ground and nodedef.liquidtype ~= "none"
	return touching_ground, liquid_below
end

function helicopter.heli_control(self, dtime, touching_ground, liquid_below, vel_before)
    helicopter.last_time_command = helicopter.last_time_command + dtime
    if helicopter.last_time_command > 1 then helicopter.last_time_command = 1 end

    if self.driver_name == nil then
        return
    end
    local driver = minetest.get_player_by_name(self.driver_name)

	if not driver then
		-- there is no driver (eg. because driver left)
		self.driver_name = nil
		if self.sound_handle then
			minetest.sound_stop(self.sound_handle)
			self.sound_handle = nil
		end
		self.object:set_animation_frame_speed(0)
		-- gravity
		self.object:set_acceleration(vector.multiply(helicopter.vector_up, -helicopter.gravity))
		return
	end

    local ctrl = driver:get_player_control()

    if ctrl.aux1 and helicopter.last_time_command > 0.3 then
        helicopter.last_time_command = 0
        if self._by_mouse == true then
            self._by_mouse = false
        else
            self._by_mouse = true
        end
    end
    
	local rot = self.object:get_rotation()

	local vert_vel_goal = 0
	if not liquid_below then
		if ctrl.jump then
			vert_vel_goal = vert_vel_goal + helicopter.wanted_vert_speed
		end
		if ctrl.sneak then
			vert_vel_goal = vert_vel_goal - helicopter.wanted_vert_speed
		end
	else
		vert_vel_goal = helicopter.wanted_vert_speed
	end

	-- rotation
	if not touching_ground then
        local rotation = self.object:get_rotation()
        local yaw = rotation.y
		local tilting_goal = vector.new()
		if ctrl.up then
			tilting_goal.z = tilting_goal.z + 4
		end
		if ctrl.down then
			tilting_goal.z = tilting_goal.z - 4
		end
        if self._by_mouse == true then
		    if ctrl.right then
			    tilting_goal.x = tilting_goal.x + 4
		    end
		    if ctrl.left then
			    tilting_goal.x = tilting_goal.x - 4
		    end
        else
		    if ctrl.right then
			    yaw = yaw - 0.02
                tilting_goal.x = tilting_goal.x + 0.2
		    end
		    if ctrl.left then
			    yaw = yaw + 0.02
                tilting_goal.x = tilting_goal.x - 0.2
		    end
        end
		tilting_goal = vector.multiply(vector.normalize(tilting_goal), helicopter.tilting_max)

		-- tilting
		if helicopter.vector_length_sq(vector.subtract(tilting_goal, self.tilting)) > (dtime * helicopter.tilting_speed)^2 then
			self.tilting = vector.add(self.tilting,
					vector.multiply(vector.direction(self.tilting, tilting_goal), dtime * helicopter.tilting_speed))
		else
			self.tilting = tilting_goal
		end
		if helicopter.vector_length_sq(self.tilting) > helicopter.tilting_max^2 then
			self.tilting = vector.multiply(vector.normalize(self.tilting), helicopter.tilting_max)
		end
		local new_up = vector.new(self.tilting)
		new_up.y = 1
		new_up = vector.normalize(new_up) -- this is what vector_up should be after the rotation
		local new_right = vector.cross(new_up, helicopter.vector_forward)
		local new_forward = vector.cross(new_right, new_up)
		local rot_mat = matrix3.new(
			new_right.x, new_up.x, new_forward.x,
			new_right.y, new_up.y, new_forward.y,
			new_right.z, new_up.z, new_forward.z
		)
		rot = matrix3.to_pitch_yaw_roll(rot_mat)

        if self._by_mouse == true then
		    rot.y = driver:get_look_horizontal()
        else
            rot.y = yaw
        end
        

	else
		rot.x = 0
		rot.z = 0
		self.tilting.x = 0
		self.tilting.z = 0
	end

	self.object:set_rotation(rot)

	-- calculate how strong the heli should accelerate towards rotated up
	local power = vert_vel_goal - vel_before.y + helicopter.gravity * dtime
	power = math.min(math.max(power, helicopter.power_min * dtime), helicopter.power_max * dtime)

    -- calculate energy consumption --
    ----------------------------------
    if self.energy > 0 and touching_ground == false then
        local position = self.object:get_pos()
        local altitude_consumption_variable = 0

        -- if gaining altitude, it consumes more power
        -- MeseCraft: per second rather than per step, and only above the cloudlands (y 400-600)
        local y_pos_reference = position.y - 1000 --after altitude 1000 the power need will increase
        if y_pos_reference > 0 then altitude_consumption_variable = ((y_pos_reference/1000)^2) * dtime end

        local consumed_power = (power/1500) + altitude_consumption_variable
        self.energy = self.energy - consumed_power;

        local energy_indicator_angle = ((self.energy * 18) - 90) * -1
        if self.pointer:get_luaentity() then
            self.pointer:set_attach(self.object,'',{x=0,y=11.26,z=9.37},{x=0,y=0,z=energy_indicator_angle})
        else
            --in case it have lost the entity by some conflict
            self.pointer=minetest.add_entity({x=0,y=11.26,z=9.37},'helicopter:pointer')
            self.pointer:set_attach(self.object,'',{x=0,y=11.26,z=9.37},{x=0,y=0,z=energy_indicator_angle})
        end
    end
    if self.energy <= 0 then
        power = 0.2
		if touching_ground or liquid_below then
            --criar uma fucao pra isso pois ela repete na linha 268
			-- sound and animation
            if self.sound_handle then minetest.sound_stop(self.sound_handle) end
			self.object:set_animation_frame_speed(0)
			-- gravity
			self.object:set_acceleration(vector.multiply(helicopter.vector_up, -helicopter.gravity))
		end
    end
    ----------------------------
    -- end energy consumption --


	local rotated_up = matrix3.multiply(matrix3.from_pitch_yaw_roll(rot), helicopter.vector_up)
	local added_vel = vector.multiply(rotated_up, power)
	added_vel = vector.add(added_vel, vector.multiply(helicopter.vector_up, -helicopter.gravity * dtime))
	return vector.add(vel_before, added_vel)
end


