-----------------
-- Fruit Tools --
-----------------

-- Settings:

-- Replace weed pick with pickle pick when set to true - capabilities of both picks have the same capabilities
local say_no_to_cannabis = true

-- Every time the tool is used, it will randomly also drop the fruit the tool is made out of, configure quantities of fruit and chance here:
-- Enable or disable extra drops (default is true)
local extra_drops = true
-- Every one in x drops the fruit the tool is made out of will also drop, lower is more likely (default is 5)
local extra_drop_chance = 20
-- Maximum amount of extra drops (default is 5)
local extra_drop_max = 3
-- Minimum amount of extra drops (default is 1)
local extra_drop_min = 1

-- When a throwing food lands, there is a chance they plant the plant they are made of, adjust this functionality here:
-- Enable or disable planting (default is true)
local plant = true
-- Set to true to plant just a whole fully-grown plant, set to false to enable hoeing of dirt and planting a new plant (default is true)
local plant_whole = false
-- Adjust the plant chance (1 in every x node hits will plant a plant)
local plant_chance = 20


-- Code:

if farming.mod ~= "redo" then
    minetest.log("error", "[fruit_tools]: This mod requires TenPlus1's farming redo, not the default minetest_game farming mod.")
end

fruit_tools = {}
fruit_tools.version = "1.0"
fruit_tools.path = minetest.get_modpath("fruit_tools")

-- Sound effect function (unused as of now):
local function play_sound_effect(player, name)
    if player then
        local pos = player:get_pos()
        if pos then
            minetest.sound_play({
                pos = pos,
                name = name,
                max_hear_distance = 10,
                gain = 0.5,
            })
        end
    end
end

-- custom particle effects (from TenPlus1's mobs_redo)
local effect = function(pos, amount, texture, min_size, max_size, radius, gravity, glow)

    radius = radius or 2
    min_size = min_size or 0.5
    max_size = max_size or 1
    gravity = gravity or -10
    glow = glow or 0

    minetest.add_particlespawner({
        amount = amount,
        time = 0.25,
        minpos = pos,
        maxpos = pos,
        minvel = {x = -radius, y = -radius, z = -radius},
        maxvel = {x = radius, y = radius, z = radius},
        minacc = {x = 0, y = gravity, z = 0},
        maxacc = {x = 0, y = gravity, z = 0},
        minexptime = 0.1,
        maxexptime = 1,
        minsize = min_size,
        maxsize = max_size,
        texture = texture,
        glow = glow,
    })
end

-- Fruit tools occasionally drop the fruit they are made of
local tool_item_pairs = {
    {tool = "fruit_tools:hoe_bean", fruit = "farming:beans"},
    {tool = "fruit_tools:sword_chili", fruit = "farming:chili_pepper"},
    {tool = "fruit_tools:sword_carrot", fruit = "farming:carrot"},
    {tool = "fruit_tools:sword_carrot_gold", fruit = "farming:carrot_gold"},
    {tool = "fruit_tools:pick_corn", fruit = "farming:corn"},
    {tool = "fruit_tools:axe_raspberry", fruit = "farming:raspberries"},
    {tool = "fruit_tools:axe_melon", fruit = "farming:melon_slice"},
    {tool = "fruit_tools:shovel_grape", fruit = "farming:grapes"},
    {tool = "fruit_tools:shovel_apple", fruit = "default:apple"},
}

-- checks if user is holding a fruit tool, if they are returns the fruit pair name, else returns false
local function is_holding_fruit_tool(player)
    if player then
        local tool = player:get_wielded_item():get_name()
        local fruit_pair_name = false

    for i, p in ipairs(tool_item_pairs) do
        if tool == p.tool then
            fruit_pair_name = p.fruit
        end
    end

    return fruit_pair_name
    end
end

local function get_random_drop_quantity()
    local drop_quantity = false
    if extra_drops and math.random(1, extra_drop_chance) == 1 then
        drop_quantity = math.random(extra_drop_min, extra_drop_max)
    end
    return drop_quantity
end

local old_handle_node_drops = minetest.handle_node_drops

function minetest.handle_node_drops(pos, drops, digger)
    -- Check if fruit tool, if fruit tool save fruit pair for later, if not fruit tool proceed as normal
    local fruit_drop_name = is_holding_fruit_tool(digger)
    if not fruit_drop_name then
        return old_handle_node_drops(pos, drops, digger)
    end

    local new_drops = drops
    local drop_quantity = get_random_drop_quantity()

    if drop_quantity then
        table.insert(new_drops,
                ItemStack({
                    name = fruit_drop_name,
                    count = drop_quantity,
                })
            )
    end

    return old_handle_node_drops(pos, new_drops, digger)
end

-- Do the same for hoes when they are used
local old_hoe_on_use = farming.hoe_on_use

function farming.hoe_on_use(itemstack, user, pointed_thing, uses)
    local fruit_drop_name = is_holding_fruit_tool(user)
    if not fruit_drop_name then
        return old_hoe_on_use(itemstack, user, pointed_thing, uses)
    end

    local drops = {}
    local drop_quantity = get_random_drop_quantity()

    if drop_quantity then
        table.insert(drops,
                ItemStack({
                    name = fruit_drop_name,
                    count = drop_quantity,
                })
            )
        if pointed_thing.type == "node" then
            old_handle_node_drops(pointed_thing.above, drops, user)
        end
    end

    return old_hoe_on_use(itemstack, user, pointed_thing, uses)
end

-- Register craftitems:
minetest.register_craftitem("fruit_tools:resin", {
    description = "Tool Resin (Use to craft fruit tools)",
    inventory_image = "resin_bottle.png",
})

minetest.register_craft({
    output = "fruit_tools:resin",
    recipe = {
        {"default:diamond", "default:gold_ingot", "default:diamond"},
        {"default:mese_crystal", "vessels:glass_bottle", "default:mese_crystal"},
        {"default:diamond", "mesecraft_bucket:bucket_water", "default:diamond"}
    },
})

-- Register sheilds:
if minetest.get_modpath("3d_armor") then
    armor:register_armor("fruit_tools:shield_orange", {
        description = "Orange Shield",
        inventory_image = "fruit_tools_inv_shield_orange.png",
        groups = {armor_shield=1, armor_heal=16, armor_use=100},
        armor_groups = {fleshy=16},
        damage_groups = {cracky=2, snappy=1, level=3},
        reciprocate_damage = true,
        on_punched = function(player, hitter, time_from_last_punch, tool_capabilities)
            if type(hitter) == "userdata" then
                if extra_drops then
                    local drops = {}
                    local drop_quantity = get_random_drop_quantity()

                    if drop_quantity then
                        table.insert(drops,
                                ItemStack({
                                    name = "ethereal:orange",
                                    count = drop_quantity,
                                })
                            )
                        old_handle_node_drops(player:get_pos(), drops, hitter)
                    end
                end
            end
        end,
    })

    minetest.register_craft({
        output = "fruit_tools:shield_orange",
        recipe = {
            {"ethereal:orange", "fruit_tools:resin", "ethereal:orange"},
            {"fruit_tools:resin", "ethereal:orange", "fruit_tools:resin"},
            {"", "fruit_tools:resin", ""}
        },
    })

    armor:register_armor("fruit_tools:shield_tomato", {
        description = "Tomato Shield",
        inventory_image = "fruit_tools_inv_shield_tomato.png",
        groups = {armor_shield=1, armor_heal=14, armor_use=150},
        armor_groups = {fleshy=15},
        damage_groups = {cracky=2, snappy=1, level=3},
        reciprocate_damage = true,
        on_punched = function(player, hitter, time_from_last_punch, tool_capabilities)
            if type(hitter) == "userdata" then
                if extra_drops then
                    local drops = {}
                    local drop_quantity = get_random_drop_quantity()

                    if drop_quantity then
                        table.insert(drops,
                                ItemStack({
                                    name = "farming:tomato",
                                    count = drop_quantity,
                                })
                            )
                        old_handle_node_drops(player:get_pos(), drops, hitter)
                    end
                end
            end
        end,
    })

    minetest.register_craft({
        output = "fruit_tools:shield_tomato",
        recipe = {
            {"farming:tomato", "fruit_tools:resin", "farming:tomato"},
            {"fruit_tools:resin", "farming:tomato", "fruit_tools:resin"},
            {"", "fruit_tools:resin", ""}
        },
    })
end

-- Register hoe:
farming.register_hoe(":fruit_tools:hoe_bean", {
    description = "Bean Hoe",
    inventory_image = "hoe_bean.png",
    max_uses = 1000,
    recipe = {
        {"farming:beans", "farming:beans", ""},
        {"fruit_tools:resin", "group:stick", "fruit_tools:resin"},
        {"fruit_tools:resin", "group:stick", "fruit_tools:resin"}
    }
})

-- Register swords:
minetest.register_tool("fruit_tools:sword_chili", {
    description = "Chili Sword",
    inventory_image = "sword_chili.png",
    tool_capabilities = {
        full_punch_interval = 0.5,
        max_drop_level=1,
        groupcaps={
            snappy={times={[1]=1.85, [2]=0.80, [3]=0.25}, uses=60, maxlevel=3},
        },
        damage_groups = {fleshy=8},
        },
        sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "fruit_tools:sword_chili",
    recipe = {
        {"", "farming:chili_pepper", ""},
        {"fruit_tools:resin", "farming:chili_pepper", "fruit_tools:resin"},
        {"fruit_tools:resin", "farming:chili_pepper", "fruit_tools:resin"}
    },
})

minetest.register_tool("fruit_tools:sword_carrot", {
    description = "Carrot Sword",
    inventory_image = "sword_carrot.png",
    tool_capabilities = {
        full_punch_interval = 0.5,
        max_drop_level=1,
        groupcaps={
            snappy={times={[1]=1.70, [2]=0.70, [3]=0.20}, uses=80, maxlevel=3},
        },
        damage_groups = {fleshy=9},
        },
        sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "fruit_tools:sword_carrot",
    recipe = {
        {"", "farming:carrot", ""},
        {"fruit_tools:resin", "farming:carrot", "fruit_tools:resin"},
        {"fruit_tools:resin", "farming:carrot", "fruit_tools:resin"}
    },
})

minetest.register_tool("fruit_tools:sword_carrot_gold", {
    description = "Golden Carrot Sword",
    inventory_image = "sword_carrot_gold.png",
    tool_capabilities = {
        full_punch_interval = 0.4,
        max_drop_level=1,
        groupcaps={
            snappy={times={[1]=1.65, [2]=0.60, [3]=0.15}, uses=100, maxlevel=3},
        },
        damage_groups = {fleshy=10},
    },
    sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "fruit_tools:sword_carrot_gold",
    recipe = {
        {"", "farming:carrot_gold", ""},
        {"fruit_tools:resin", "farming:carrot_gold", "fruit_tools:resin"},
        {"fruit_tools:resin", "farming:carrot_gold", "fruit_tools:resin"}
    },
})

-- Register Picks:
local pick_name = "fruit_tools:pick_weed"
local pick_image = "pick_weed.png"
local pick_description = "Weed Pickaxe"
local pick_priv = "dealer"

if say_no_to_cannabis == false then
    minetest.register_alias("fruit_tools:pick_pickle", "fruit_tools:pick_weed")

    minetest.register_privilege("dealer", {
        description = "Players can use the Weed Pick with this priv.",
        give_to_singleplayer = false,
    })
else
    minetest.register_alias("fruit_tools:pick_weed", "fruit_tools:pick_pickle")

    minetest.register_privilege("picklepick", {
        description = "Players can use the Pickle Pick with this priv.",
        give_to_singleplayer = false,
    })

    pick_name = "fruit_tools:pick_pickle"
    pick_image = "pick_pickle.png"
    pick_description = "Pickle Pickaxe"
    pick_priv = "picklepick"
end

minetest.register_tool(pick_name, {
    description = pick_description,
    inventory_image = pick_image,
    range = 20,
    tool_capabilities = {
        full_punch_interval = 0.1,
        max_drop_level = 3,
        groupcaps = {
            unbreakable =   {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
            dig_immediate = {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
            fleshy =    {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
            choppy =    {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
            bendy =     {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
            cracky =    {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
            crumbly =   {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
            snappy =    {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3}
        },
        damage_groups = {fleshy = 100}
    },
    after_use = function(itemstack, user, pointed_thing)
        if not minetest.check_player_privs(user:get_player_name(), {[pick_priv] = true}) then
            minetest.log("action", "[fruit_tools] "..user:get_player_name().." just tried to use a "..pick_description.."!")
            minetest.chat_send_player(user:get_player_name(), "You are not authorised to use the mighty "..pick_description.."!")
            itemstack:take_item()
            return itemstack
        end
    end,
})

-- Make cloud removable with admin picks
minetest.register_node(":default:cloud", {
    description = "Cloud",
    tiles = {"default_cloud.png"},
    drop = "",
    groups = {unbreakable = 1},
    is_ground_content = false,
    sounds = default.node_sound_defaults(),
})

minetest.register_tool("fruit_tools:pick_corn", {
    description = "Corn Pickaxe",
    inventory_image = "pick_corn.png",
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level=3,
        groupcaps={
            cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
        },
        damage_groups = {fleshy=5},
    },
    sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "fruit_tools:pick_corn",
    recipe = {
        {"farming:corn_cob", "farming:corn_cob", "farming:corn_cob"},
        {"fruit_tools:resin", "default:stick", "fruit_tools:resin"},
        {"fruit_tools:resin", "default:stick", "fruit_tools:resin"}
    },
})

-- Register axes:
minetest.register_tool("fruit_tools:axe_raspberry", {
    description = "Raspberry Axe",
    inventory_image = "axe_raspberry.png",
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level=1,
        groupcaps={
            choppy={times={[1]=1.90, [2]=0.80, [3]=0.40}, uses=50, maxlevel=2},
        },
        damage_groups = {fleshy=7},
    },
    sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "fruit_tools:axe_raspberry",
    recipe = {
        {"fruit_tools:resin", "farming:raspberries", "farming:raspberries"},
        {"fruit_tools:resin", "default:stick", "farming:raspberries"},
        {"fruit_tools:resin", "default:stick", "fruit_tools:resin"}
    },
})

minetest.register_tool("fruit_tools:axe_melon", {
    description = "Melon Axe",
    inventory_image = "axe_melon.png",
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level=1,
        groupcaps={
            choppy={times={[1]=1.80, [2]=0.70, [3]=0.30}, uses=70, maxlevel=2},
        },
        damage_groups = {fleshy=7},
    },
    sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "fruit_tools:axe_melon",
    recipe = {
        {"fruit_tools:resin", "farming:melon_slice", "farming:melon_slice"},
        {"fruit_tools:resin", "default:stick", "farming:melon_slice"},
        {"fruit_tools:resin", "default:stick", "fruit_tools:resin"}
    },
})

-- Register shovels:
minetest.register_tool("fruit_tools:shovel_grape", {
    description = "Grape Shovel",
    inventory_image = "shovel_grape.png",
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level=1,
        groupcaps={
            crumbly = {times={[1]=1.00, [2]=0.40, [3]=0.20}, uses=50, maxlevel=3},
        },
        damage_groups = {fleshy=4},
    },
    sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "fruit_tools:shovel_grape",
    recipe = {
        {"", "farming:grapes", ""},
        {"fruit_tools:resin", "default:stick", "fruit_tools:resin"},
        {"fruit_tools:resin", "default:stick", "fruit_tools:resin"}
    },
})

minetest.register_tool("fruit_tools:shovel_apple", {
    description = "Apple Shovel",
    inventory_image = "shovel_apple.png",
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level=1,
        groupcaps={
            crumbly = {times={[1]=0.9, [2]=0.30, [3]=0.10}, uses=80, maxlevel=3},
        },
        damage_groups = {fleshy=4},
    },
    sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "fruit_tools:shovel_apple",
    recipe = {
        {"", "default:apple", ""},
        {"fruit_tools:resin", "default:stick", "fruit_tools:resin"},
        {"fruit_tools:resin", "default:stick", "fruit_tools:resin"}
    },
})

if minetest.get_modpath("mobs") then
    function fruit_tools:register_throwing_food(modname, foodname, plantname, final_stage, toplant, plantwhole)
        local food
        local f = string.find(foodname, ":")
        if f then
            food = foodname:sub(f + 1)
        else
            food = foodname
            foodname = foodname
        end

        if not plantname then
            toplant = false
        else
            local p = string.find(plantname, ":")
            if not p then
                plantname = "farming:"..plantname
            end
        end

        if modname ~= "fruit_tools" and modname:sub(1,1) ~= ":" then
            modname = ":"..modname
        end

        local description
        if minetest.registered_craftitems[foodname] then
            description = minetest.registered_craftitems[foodname].description
        else
            -- If failed to get description, do our best to capitalise the food name so it looks right and log a warning
            description = food:sub(1,1):upper()..food:sub(2)
            minetest.log("warning", "[fruit_tools]: failed to get description for food: "..foodname)
        end

        mobs:register_arrow(modname..":"..food.."_entity", {
            visual = "sprite",
            visual_size = {x=.5, y=.5},
            textures = {food..".png"},
            velocity = 6,

            hit_player = function(self, player)
                if player:get_player_name() == self.playername then
                    return
                end

                local pos = player:get_pos()
                pos.y = pos.y + ((-player:get_properties().collisionbox[2] + player:get_properties().collisionbox[5]) * .5) + 0.5
                effect(pos, 5, food.."_splat.png", 1, 3, 2, -10, 0)

                player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
                    full_punch_interval = 1.0,
                    damage_groups = {fleshy = 2},
                }, nil)
            end,

            hit_mob = function(self, player)
                local pos = player:get_pos()
                pos.y = pos.y + ((-player:get_properties().collisionbox[2] + player:get_properties().collisionbox[5]) * .5) + 0.5
                effect(pos, 5, food.."_splat.png", 1, 3, 2, -10, 0)

                player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
                    full_punch_interval = 1.0,
                    damage_groups = {fleshy = 2},
                }, nil)
            end,

            hit_node = function(self, pos, node)
                local under = {x=pos.x,y=pos.y-1,z=pos.z}

                local above = {x=pos.x,y=pos.y+1,z=pos.z}

                local landed_thing = {type="node", under=pos, above=above}

                effect(above, 5, food.."_splat.png", 1, 3, 2, -10, 0)

                if not plant
                or not toplant
                or math.random(1, plant_chance) ~= 1
                or minetest.get_node_or_nil(above).name ~= "air"
                or minetest.get_item_group(node, "soil") ~= 1
                then
                    return
                end

                if plantwhole then
                    if minetest.is_protected(above, self.playername)then
                        return
                    end

                    local final_plant
                    if not final_stage then
                        final_plant = plantname
                    else
                        final_plant = plantname.."_"..tostring(final_stage)
                    end

                    minetest.set_node(above, {name = final_plant})
                else
                    if minetest.is_protected(above, self.playername) or minetest.is_protected(pos, self.playername) then
                        return
                    end

                    minetest.set_node(pos, {name = "farming:soil_wet"})

                    farming.place_seed(nil, minetest.get_player_by_name(self.playername), landed_thing, plantname.."_1")
                end
            end,
        })

        local food_GRAVITY = 9
        local food_VELOCITY = 19

        local shoot_food = function (item, player, pointed_thing)
            local playerpos = player:get_pos()

            play_sound_effect(player, "default_place_node_hard")

            local obj = minetest.add_entity({
                x = playerpos.x,
                y = playerpos.y +1.5,
                z = playerpos.z
            }, modname..":"..food.."_entity")

            local ent = obj:get_luaentity()
            local dir = player:get_look_dir()

            ent.velocity = food_VELOCITY -- needed for api internal timing
            ent.switch = 1 -- needed so that food doesn't despawn straight away

            obj:set_velocity({
                x = dir.x * food_VELOCITY,
                y = dir.y * food_VELOCITY,
                z = dir.z * food_VELOCITY
            })

            obj:set_acceleration({
                x = dir.x * -3,
                y = -food_GRAVITY,
                z = dir.z * -3
            })

            local ent2 = obj:get_luaentity()
            ent2.playername = player:get_player_name()

            item:take_item()

            return item
        end

        minetest.register_craftitem(":"..modname..":throwing_"..food, {
            description = "Throwing "..description,
            inventory_image = food..".png",
            on_use = shoot_food,
        })

        minetest.register_craft({
            output = modname..":throwing_"..food.." 9",
            recipe = {
                {foodname, foodname, foodname},
                {foodname, "default:stone", foodname},
                {foodname, foodname, foodname}
            },
        })

        minetest.register_craft({
            output = foodname.." 9",
            recipe = {
                {modname..":throwing_"..food, modname..":throwing_"..food, modname..":throwing_"..food},
                {modname..":throwing_"..food, modname..":throwing_"..food, modname..":throwing_"..food},
                {modname..":throwing_"..food, modname..":throwing_"..food, modname..":throwing_"..food},
            },
        })
    end

    -- Register throwing foods:
    fruit_tools:register_throwing_food("fruit_tools", "farming:donut_apple", nil, nil, false, nil)

    fruit_tools:register_throwing_food("fruit_tools", "farming:tomato", "tomato", 8, true, plant_whole)
    fruit_tools:register_throwing_food("fruit_tools", "default:blueberries", "blueberry", 4, true, plant_whole)
    fruit_tools:register_throwing_food("fruit_tools", "farming:grapes", "grapebush", nil, true, true)
    fruit_tools:register_throwing_food("fruit_tools", "farming:raspberries", "raspberry", 4, true, plant_whole)
    fruit_tools:register_throwing_food("fruit_tools", "farming:melon_slice", "melon", 8, true, plant_whole)

	if minetest.get_modpath("etheral") then
		fruit_tools:register_throwing_food("fruit_tools", "ethereal:orange", nil, nil, false, nil)
		fruit_tools:register_throwing_food("fruit_tools", "ethereal:strawberry", nil, nil, false, nil)
	end
end

-- Add mesecraft_toolranks support if found
if minetest.get_modpath("mesecraft_toolranks") then
    for i, p in ipairs(tool_item_pairs) do
        local original_description = minetest.registered_tools[p.tool].description
        minetest.override_item(p.tool, {
            original_description = original_description,
            description = mesecraft_toolranks.create_description(original_description, 0, 1),
            after_use = mesecraft_toolranks.new_afteruse
        })
    end
end
