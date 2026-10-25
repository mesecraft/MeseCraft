gadgets.register_effect({
    id = "gadgets_default_effects_speed_1",
    name = "Speed 1",
    icon = "gadgets_default_effects_speed_icon.png",
    groups = {"speed"},
    apply = function(player)
        player_monoids.speed:add_change(player, 1.75, "gadgets_default_effects_speed_1")
    end,
    cancel = function(effect, player)
        player_monoids.speed:del_change(player, "gadgets_default_effects_speed_1")
    end,
    hidden = false,
    cancel_on_death = true,
    repeat_interval = nil,
    particle = "gadgets_default_effects_speed_particle.png",
    particle_amount = 4,
    particle_glow = true,
    particle_velocity = 0,
    particle_gravity = 2,
    particle_size = 3,
    particle_displacement = 0.5,
})

gadgets.register_effect({
    id = "gadgets_default_effects_speed_2",
    name = "Speed 2",
    icon = "gadgets_default_effects_speed_icon.png",
    groups = {"speed"},
    apply = function(player)
        player_monoids.speed:add_change(player, 2.5, "gadgets_default_effects_speed_2")
    end,
    cancel = function(effect, player)
        player_monoids.speed:del_change(player, "gadgets_default_effects_speed_2")
    end,
    hidden = false,
    cancel_on_death = true,
    repeat_interval = nil,
    particle = "gadgets_default_effects_speed_particle.png",
    particle_amount = 4,
    particle_glow = true,
    particle_velocity = 0,
    particle_gravity = 2,
    particle_size = 3,
    particle_displacement = 0.5,
})

gadgets.register_effect({
    id = "gadgets_default_effects_jump_1",
    name = "Jump 1",
    icon = "gadgets_default_effects_jump_icon.png",
    groups = {"jump"},
    apply = function(player)
        player_monoids.jump:add_change(player, 1.5, "gadgets_default_effects_jump_1")
    end,
    cancel = function(effect, player)
        player_monoids.jump:del_change(player, "gadgets_default_effects_jump_1")
    end,
    hidden = false,
    cancel_on_death = true,
    repeat_interval = nil,
    particle = "gadgets_default_effects_jump_particle.png",
    particle_amount = 2,
    particle_glow = true,
    particle_velocity = 0.5,
    particle_gravity = 0.25,
    particle_size = 3,
    particle_displacement = 0.5,
})

gadgets.register_effect({
    id = "gadgets_default_effects_jump_2",
    name = "Jump 2",
    icon = "gadgets_default_effects_jump_icon.png",
    groups = {"jump"},
    apply = function(player)
        player_monoids.jump:add_change(player, 2.5, "gadgets_default_effects_jump_2")
    end,
    cancel = function(effect, player)
        player_monoids.jump:del_change(player, "gadgets_default_effects_jump_2")
    end,
    hidden = false,
    cancel_on_death = true,
    repeat_interval = nil,
    particle = "gadgets_default_effects_jump_particle.png",
    particle_amount = 2,
    particle_glow = true,
    particle_velocity = 0.5,
    particle_gravity = 0.25,
    particle_size = 3,
    particle_displacement = 0.5,
})

gadgets.register_effect({
    id = "gadgets_default_effects_gravity_1",
    name = "Gravity 1",
    icon = "gadgets_default_effects_gravity_icon.png",
    groups = {"gravity"},
    apply = function(player)
        player_monoids.gravity:add_change(player, 0.5, "gadgets_default_effects_gravity_1")
    end,
    cancel = function(effect, player)
        player_monoids.gravity:del_change(player, "gadgets_default_effects_gravity_1")
    end,
    hidden = false,
    cancel_on_death = true,
    repeat_interval = nil,
    particle = "gadgets_default_effects_gravity_particle.png",
    particle_amount = 2,
    particle_glow = true,
    particle_velocity = 0.25,
    particle_gravity = 0.25,
    particle_size = 2,
    particle_displacement = 0.5,
})

gadgets.register_effect({
    id = "gadgets_default_effects_gravity_2",
    name = "Gravity 2",
    icon = "gadgets_default_effects_gravity_icon.png",
    groups = {"gravity"},
    apply = function(player)
        player_monoids.gravity:add_change(player, 0.15, "gadgets_default_effects_gravity_2")
    end,
    cancel = function(effect, player)
        player_monoids.gravity:del_change(player, "gadgets_default_effects_gravity_2")
    end,
    hidden = false,
    cancel_on_death = true,
    repeat_interval = nil,
    particle = "gadgets_default_effects_gravity_particle.png",
    particle_amount = 2,
    particle_glow = true,
    particle_velocity = 0.25,
    particle_gravity = 0.25,
    particle_size = 2,
    particle_displacement = 0.5,
})

-- set_hp truncates to whole points, so carry the half point between ticks.
local health_regen_carry = {}

gadgets.register_effect({
    id = "gadgets_default_effects_health_regen",
    name = "Health Regen",
    icon = "gadgets_default_effects_health_regen_icon.png",
    groups = {"health_regen"},
    apply = function(player)
        local name = player:get_player_name()
        local amount = (health_regen_carry[name] or 0) + 0.5
        local whole = math.floor(amount)
        health_regen_carry[name] = amount - whole
        if whole > 0 then
            player:set_hp(player:get_hp() + whole)
        end
    end,
    nil,
    hidden = false,
    cancel_on_death = true,
    repeat_interval = 1,
    particle = "gadgets_default_effects_health_regen_particle.png",
    particle_amount = 2,
    particle_glow = true,
    particle_velocity = 0.25,
    particle_gravity = 0.5,
    particle_size = 2,
    particle_displacement = 0.5,
})

gadgets.register_effect({
    id = "gadgets_default_effects_water_breath",
    name = "Water Breath",
    icon = "gadgets_default_effects_water_breath_icon.png",
    groups = {"water_breath"},
    apply = function(player)
        player:set_breath(player:get_breath()+2)
    end,
    nil,
    hidden = false,
    cancel_on_death = true,
    repeat_interval = 1,
    particle = "gadgets_default_effects_water_breath_particle.png",
    particle_amount = 4,
    particle_glow = false,
    particle_velocity = 0.5,
    particle_gravity = 0.5,
    particle_size = 2,
    particle_displacement = 0.5,
})

gadgets.register_effect({
    id = "gadgets_default_effects_fire_shield",
    name = "Fire Shield",
    icon = "gadgets_default_effects_fire_shield_icon.png",
    groups = {"fire_shield"},
    apply = function(player)
        local pos = player:get_pos()
        local targets = minetest.get_objects_inside_radius(pos, 3)
        for _,v in pairs(targets) do
            if v ~= player then
                v:punch(player, 1.0, {
                    full_punch_interval=1.0,
                    damage_groups={fleshy=5},
                    }, nil)
            end
        end
    end,
    nil,
    hidden = false,
    cancel_on_death = true,
    repeat_interval = 1,
    particle = "gadgets_default_effects_fire_shield_particle.png",
    particle_amount = 6,
    particle_glow = true,
    particle_velocity = 0.5,
    particle_gravity = 1.5,
    particle_size = 3,
    particle_displacement = 0.5,
})

if minetest.get_modpath("sprint_lite") then
    gadgets.register_effect({
        id = "gadgets_default_effects_stamina_regen",
        name = "Stamina Regen",
        icon = "gadgets_default_effects_stamina_regen_icon.png",
        groups = {"stamina_regen"},
        apply = function(player)
            local name = player:get_player_name()
            sprint_lite.set_stamina(name, 1.5, true)
        end,
        nil,
        hidden = false,
        cancel_on_death = true,
        repeat_interval = 1,
        particle = "gadgets_default_effects_stamina_regen_particle.png",
        particle_amount = 2,
        particle_glow = true,
        particle_velocity = 0.25,
        particle_gravity = 0.5,
        particle_size = 2,
        particle_displacement = 0.5,
    })
end

if minetest.get_modpath("mana") then
    gadgets.register_effect({
        id = "gadgets_default_effects_mana_regen",
        name = "Mana Regen",
        icon = "gadgets_default_effects_mana_regen_icon.png",
        groups = {"mana_regen"},
        apply = function(player)
            local name = player:get_player_name()
            mana.add_up_to(name, 15)
        end,
        nil,
        hidden = false,
        cancel_on_death = true,
        repeat_interval = 1,
        particle = "gadgets_default_effects_mana_regen_particle.png",
        particle_amount = 2,
        particle_glow = true,
        particle_velocity = 0.25,
        particle_gravity = 0.5,
        particle_size = 2,
        particle_displacement = 0.5,
    })
end