
-- settings related to lootchests mod
geomoria_lootchests.slots = 32          -- capacity of the chest, number of item slots
geomoria_lootchests.spawn_chance = 30   -- how likely, in percent, a given slot has stuff (MeseCraft: 50 -> 30, issue #75); 
                                        -- in other words: how full is the chest likely to be?


-- the number is the maximum number that might spawn per slot
-- a smaller number might spawn, or the item might spawn in more than one slot
-- Note that there's a sanity test later to remove anything not loaded, typos won't crash
loot_table = {
    {"default:coal_lump", 40},
    {"default:stick", 99},
    {"default:torch", 90},
    {"candles:candle", 5},
    {"pigiron:iron_ingot", 12},
    {"default:steel_ingot", 8},
    {"default:copper_ingot", 16},
    {"default:tin_ingot", 16},
    {"default:bronze_ingot", 14},
    {"moreores:silver_ingot", 6},
    {"default:gold_ingot", 2},
    {"default:mese_post_light", 2},
    {"df_trees:goblin_cap_wood_mese_light", 2},
    {"moreblocks:glow_glass", 1},
    {"death_compass:inactive", 2},
    {"bees:grafting_tool"},
    {"bees:bottle_honey", 1},
    {"bees:wax", 10},
    {"farming:seed_barley", 10},
    {"farming:seed_cotton", 10},
    {"farming:seed_mint", 10},
    {"farming:seed_oat", 10},
    {"farming:seed_rice", 10},
    {"farming:seed_rye", 10},
    {"farming:seed_wheat", 10},
    {"farming:string", 6},
    {"fire:flint_and_steel"},
    {"bweapons_utility_pack:torch_bow"},
    {"bweapons_bows_pack:arrow", 50},
    {"bweapons_bows_pack:bolt", 50},
    {"bweapons_bows_pack:crossbow"},
    {"bweapons_bows_pack:wooden_bow"},
    {"default:axe_bronze"},
    {"default:axe_steel"},
    {"default:pick_bronze"},
    {"default:pick_steel"},
    {"default:shovel_bronze"},
    {"default:shovel_steel"},
    {"default:sword_bronze"},
    {"default:sword_steel"},
    {"farming:hoe_bronze"},
    {"farming:hoe_steel"},
    {"moreores:axe_silver"},
    {"moreores:hoe_silver"},
    {"moreores:pick_silver"},
    {"moreores:shovel_silver"},
    {"moreores:sword_silver"},
    {"3d_armor:boots_bronze"},
    {"3d_armor:boots_steel"},
    {"3d_armor:chestplate_bronze"},
    {"3d_armor:chestplate_steel"},
    {"3d_armor:helmet_bronze"},
    {"3d_armor:helmet_steel"},
    {"3d_armor:leggings_bronze"},
    {"3d_armor:leggings_steel"},
    {"mobs:horseshoe_bronze"},
    {"mobs:horseshoe_steel"},
    {"mobs:lasso"},
    {"mobs:shears"},
    {"shields:shield_bronze"},
    {"shields:shield_steel"},
    {"realcompass:0"},
    {"ropes:wood1rope_block", 2},
    {"tnt:gunpowder", 10},
    {"vessels:glass_bottle", 3},
    {"vessels:glass_fragments", 20},
    {"thirsty:gold_canteen"},
    {"thirsty:silver_canteen"},
}



----  End Configuration Section

local log = function(msg)
    minetest.log('warning','geomoria_lootchests - '..msg)
--    if minetest.get_player_by_name('singleplayer') then 
--        minetest.chat_send_player("singleplayer", tostring(msg) )
--    end
end

-- remove stuff if the relevant mod isn't loaded
-- (rebuilt rather than removed in place, which skipped entries after each removal)
local loaded = {}
for _, v in ipairs(loot_table) do
    if minetest.registered_items[v[1]] then
        loaded[#loaded + 1] = v
    else
        log(v[1]..' not loaded, removing from loot table')
    end
end
loot_table = loaded

-- commit final table
lootchests.loot_table["geomoria_lootchests:chest"] = loot_table
