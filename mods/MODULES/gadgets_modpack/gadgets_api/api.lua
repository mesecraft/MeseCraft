gadgets = {}
local gadgets_effect_visuals = {}
local gadgets_current_player_effects = {}

--Getting settingtypes
local enable_gadgets_effects = minetest.settings:get("gadgets_api_enable_effects") ~= false
local effect_interval = minetest.settings:get("gadgets_api_effect_interval") or 0.5

if enable_gadgets_effects then

    minetest.register_on_joinplayer(function(player)
        local name = player:get_player_name()
        gadgets_current_player_effects[name] = {}
        end
    )

    minetest.register_on_leaveplayer(function(player)
        local name = player:get_player_name()
        gadgets_current_player_effects[name] = nil
        end
    )

    local effect_timer = 0

    minetest.register_globalstep(function(dtime)
        effect_timer = effect_timer + dtime
        if effect_timer < effect_interval then return end
        for playername,effectlist in pairs(gadgets_current_player_effects) do
            if #effectlist > 0 then
                for _,v in pairs(effectlist) do
                    if gadgets_effect_visuals[v] then
                        local player = minetest.get_player_by_name(playername)
                        local def = gadgets_effect_visuals[v]
                        minetest.add_particlespawner({
                            amount = def.particle_amount,
                            time = effect_interval,
                            minpos = {x=-def.particle_displacement, y=0.5, z=-def.particle_displacement},
                            maxpos = {x=def.particle_displacement, y=1.5, z=def.particle_displacement},
                            minvel = {x=-def.particle_velocity, y=-def.particle_velocity, z=-def.particle_velocity},
                            maxvel = {x=def.particle_velocity, y=def.particle_velocity, z=def.particle_velocity},
                            minacc = {x=0, y=def.particle_gravity, z=0},
                            maxacc = {x=0, y=def.particle_gravity, z=0},
                            minexptime = 1,
                            maxexptime = 4,
                            minsize = def.particle_min_size,
                            maxsize = def.particle_size,
                            collisiondetection = false,
                            collision_removal = false,
                            attached = player,
                            glow = def.particle_glow,
                            vertical = false,
                            texture = def.particle,
                        })
                    end
                end
            end
        end
        effect_timer = 0
    end)

end

local function gadgets_on_use(itemstack, user, pointed_thing, def)

    if not user then return end

    local playername = user:get_player_name()
    local inv = user:get_inventory()
    local meta = minetest.deserialize(itemstack:get_meta():get_string(""))

    if def.mana_per_use and mana.get(playername) < def.mana_per_use or
    def.ammo_type and not inv:contains_item("main", {name=def.ammo_type, count=def.ammo_per_use})
    then
        if def.reload_sound then
            minetest.sound_play(def.reload_sound, {object=user, gain=def.reload_sound_gain, max_hear_distance=2*64})
        end
        return
    end

    if not def.consumable and def.has_durability then
        if
        def.requires_technic and not meta or
        def.requires_technic and meta.charge < def.technic_charge_per_use or
        not def.requires_technic and def.custom_charge and (65535 - itemstack:get_wear()) < (65535 / def.uses)
        then
            if def.reload_sound then
                minetest.sound_play(def.reload_sound, {object=user, gain=def.reload_sound_gain, max_hear_distance=2*64})
            end
            return
        end
    end

    local custom_return

    if def.custom_on_use then
        custom_return = def.custom_on_use(itemstack, user, pointed_thing)
    end

    if def.custom_wear and not custom_return then return end

    if not def.consumable and def.has_durability then
        if def.requires_technic then
            meta.charge = meta.charge - def.technic_charge_per_use
            technic.set_RE_wear(itemstack, meta.charge, def.technic_charge)
            itemstack:get_meta():set_string("", minetest.serialize(meta))
        else
            local wear = itemstack:get_wear()
            wear = wear + (65535/def.uses)
            if def.custom_charge and wear > 65535 then wear = 65535 end
            itemstack:set_wear(wear)
        end
    elseif def.consumable then
        itemstack:take_item()
    end

    if def.ammo_type then
        inv:remove_item("main", {name=def.ammo_type, count=def.ammo_per_use})
    end

    if def.mana_per_use then
        mana.subtract(playername, def.mana_per_use)
    end

    local playerpos = user:get_pos()
    local dir = user:get_look_dir()

    if def.return_item then
        if inv:room_for_item("main", {name = def.return_item}) then
            inv:add_item("main", {name = def.return_item})
        else
            local obj = minetest.add_item({x = playerpos.x, y = playerpos.y + 1.5, z = playerpos.z}, def.return_item)
            obj:set_velocity({x = dir.x * 5, y = dir.y * 5, z = dir.z * 5})
        end
    end

    if def.effect then
        if type(def.effect) == "string" then
            playereffects.apply_effect_type(def.effect, def.duration, user)
        elseif type(def.effect) == "table" then
            for _,v in pairs(def.effect) do
                playereffects.apply_effect_type(v, def.duration, user)
            end
        end
    end

    if def.use_sound then minetest.sound_play(def.use_sound, {object=user, gain=def.use_sound_gain, max_hear_distance=2*64}) end

    if def.use_particle then
        minetest.add_particlespawner({
            amount = def.use_particle_amount,
            time = 0.05,
            minpos = {x=-def.use_particle_displacement, y=0.5, z=-def.use_particle_displacement},
            maxpos = {x=def.use_particle_displacement, y=1.5, z=def.use_particle_displacement},
            minvel = {x=-def.use_particle_velocity, y=-def.use_particle_velocity, z=-def.use_particle_velocity},
            maxvel = {x=def.use_particle_velocity, y=def.use_particle_velocity, z=def.use_particle_velocity},
            minacc = {x=0, y=def.use_particle_gravity, z=0},
            maxacc = {x=0, y=def.use_particle_gravity, z=0},
            minexptime = 1,
            maxexptime = 4,
            minsize = def.use_particle_min_size,
            maxsize = def.use_particle_size,
            collisiondetection = false,
            collision_removal = false,
            attached = user,
            glow = def.use_particle_glow,
            vertical = false,
            texture = def.use_particle,
        })
    end

    return itemstack
end

local function gadgets_repair(itemstack, player, old_craft_grid, craft_inv, name, repair_with, uses, repair_uses)
    if itemstack == nil or itemstack:get_name() ~= name then return end
    local w_count = 0
    local r_count = 0
    local modstack

    for _,v in pairs(old_craft_grid) do
        if v:get_name() == name then
            w_count = w_count + 1
            modstack = v
        elseif v:get_name() == repair_with then
            r_count = r_count + 1
        end
    end

    if w_count == 1 and r_count == 1 then
        local wear = modstack:get_wear()
        if wear > 0 then
            wear = wear - (65535/uses * repair_uses)
            if wear < 0 then wear = 0 end
            modstack:set_wear(wear)
            return modstack
        end
    end

end

function gadgets.register_effect(def)

    local particle_glow = 0
    if def.particle_glow then
        particle_glow = 14
    end

    if def.particle and enable_gadgets_effects then
        local particle_options = {
            particle = def.particle,
            particle_amount = def.particle_amount or 4,
            particle_glow = particle_glow,
            particle_velocity = def.particle_velocity or 0.5,
            particle_gravity = def.particle_gravity or 2,
            particle_size = def.particle_size or 4,
            particle_min_size = math.floor((def.particle_size or 4)/2),
            particle_displacement = def.particle_displacement or 0.5,
        }
        gadgets_effect_visuals[def.id] = particle_options
    end

    playereffects.register_effect_type(
        def.id,
        def.name,
        def.icon,
        def.groups,
        function(player)
            if def.apply then
                def.apply(player)
            end
            if enable_gadgets_effects and def.particle then
                local name = player:get_player_name()
                --Re-initializing player tables right in apply function in case the server was shut down
                if not gadgets_current_player_effects[name] then
                    gadgets_current_player_effects[name] = {}
                end
                for _,v in pairs(gadgets_current_player_effects[name]) do
                    if v == def.id then return end
                end
                table.insert(gadgets_current_player_effects[name], def.id)
            end
        end,
        function(effect, player)
            if def.cancel then
                def.cancel(effect, player)
            end
            if enable_gadgets_effects and def.particle then
                local name = player:get_player_name()
                if not gadgets_current_player_effects[name] then return end
                for k,v in pairs(gadgets_current_player_effects[name]) do
                    if v == def.id then
                        table.remove(gadgets_current_player_effects[name], k)
                    end
                end
            end
        end,
        def.hidden,
        def.cancel_on_death,
        def.repeat_interval)

end

function gadgets.register_gadget(def)

    --Initial checks
    if def.name == nil or def.description == nil or def.texture == nil then
        minetest.log("error", "[gadgets_api] Missing parameters in item definition!")
        return
    end

    if not minetest.get_modpath("technic") and def.requires_technic then
        minetest.log("error", "[gadgets_api] Technic modpack is required for technic-powered gadgets!")
        return
    end

    if not minetest.get_modpath("mana") and def.mana_per_use then
        minetest.log("error", "[gadgets_api] Mana is required for registering mana-consuming gadgets!")
        return
    end

    --Setting values to defaults if not defined
    local stack_max = def.stack_max or 4
    local uses = def.uses or 8
    local technic_charge = def.technic_charge or 100000
    local technic_charge_per_use = technic_charge/uses
    local mana_per_use = def.mana_per_use or 50
    local ammo_per_use = def.ammo_per_use or 1
    local repair_uses = def.repair_uses or 1
    local duration = def.duration or 120
    local use_sound_gain = def.use_sound_gain or 1
    local reload_sound_gain = def.reload_sound_gain or 1
    local craft_amount = def.craft_amount or 1
    local tool_groups = {}

    local use_particle_amount = def.use_particle_amount or 4
    local use_particle_glow = 0
    local use_particle_velocity = def.use_particle_velocity or 0
    local use_particle_gravity = def.use_particle_gravity or 0
    local use_particle_size = def.use_particle_size or 4
    local use_particle_min_size = math.floor(use_particle_size/2)
    local use_particle_displacement = def.use_particle_displacement or 0

    local recipe_type = "shaped"

    if def.shapeless_recipe then
        recipe_type = "shapeless"
    end

    if def.use_particle_glow then
        use_particle_glow = 14
    end

    if not def.consumable and uses > 1 then
        stack_max = 1
    end

    if def.effect == nil then
        duration = 1
    end

    local on_refill = nil
    local wear_represents = "mechanical_wear"

    if def.requires_technic then
        on_refill = technic.refill_RE_charge
        wear_represents = "technic_RE_charge"
    elseif def.custom_charge then
        wear_represents = "gadgets_custom_charge"
    end

    if def.consumable or not def.tool_repair then
        tool_groups["disable_repair"] = 1
    end

    --Creating a temporary setting definition to pass to a on_use function
    local tdef = {
        mana_per_use = def.mana_per_use,
        light_source = def.light_source,
        ammo_type = def.ammo_type,
        ammo_per_use = ammo_per_use,
        reload_sound = def.reload_sound,
        reload_sound_gain = reload_sound_gain,
        consumable = def.consumable,
        has_durability = def.has_durability,
        requires_technic = def.requires_technic,
        technic_charge = technic_charge,
        technic_charge_per_use = technic_charge_per_use,
        custom_charge = def.custom_charge,
        uses = uses,
        return_item = def.return_item,
        effect = def.effect,
        duration = duration,
        use_sound = def.use_sound,
        use_sound_gain = use_sound_gain,
        custom_wear = def.custom_wear,
        custom_on_use = def.custom_on_use,
        use_particle = def.use_particle,
        use_particle_amount = use_particle_amount,
        use_particle_glow = use_particle_glow,
        use_particle_velocity = use_particle_velocity,
        use_particle_gravity = use_particle_gravity,
        use_particle_size = def.use_particle_size,
        use_particle_min_size = use_particle_min_size,
        use_particle_displacement = use_particle_displacement,
    }

    --Register a craftitem if one-time use, register a tool otherwise
    if def.consumable then
            minetest.register_craftitem(def.name, {
            description = def.description,
            inventory_image = def.texture,
            wield_image = def.texture,
            stack_max = stack_max,
            liquids_pointable = false,
            groups = tool_groups,
            light_source = def.light_source,
            on_use = function(itemstack, user, pointed_thing)
                local stack = gadgets_on_use(itemstack, user, pointed_thing, tdef)
                return stack
            end
        })
    else
        minetest.register_tool(def.name, {
            description = def.description,
            inventory_image = def.texture,
            wield_image = def.texture,
            liquids_pointable = false,
            groups = tool_groups,
            on_refill = on_refill,
            wear_represents = wear_represents,
            light_source = def.light_source,
            on_use = function(itemstack, user, pointed_thing)
                local stack = gadgets_on_use(itemstack, user, pointed_thing, tdef)
                return stack
            end
        })
    end

    --Register a crafting recipe
    if def.recipe then
        for _,v in pairs(def.recipe) do
            minetest.register_craft({
            type = recipe_type,
            output = def.name .. " " .. craft_amount,
            recipe = v,
            replacements = def.replacements,
            })
        end
    end

    --Register tool as technic_powered
    if def.requires_technic and not def.consumable then
        technic.register_power_tool(def.name, technic_charge)
    end

    if def.repair_with and not def.consumable then
        minetest.register_craft({
            type = "shapeless",
            output = def.name,
            recipe = {
                def.name,
                def.repair_with,
            },
        })

        minetest.register_on_craft(
            function(itemstack, player, old_craft_grid, craft_inv)
                local stack = gadgets_repair(itemstack, player, old_craft_grid, craft_inv, def.name, def.repair_with, uses, repair_uses)
                return stack
            end)

        minetest.register_craft_predict(
            function(itemstack, player, old_craft_grid, craft_inv)
                local stack = gadgets_repair(itemstack, player, old_craft_grid, craft_inv, def.name, def.repair_with, uses, repair_uses)
                return stack
            end)

    end
end
