-- TODO: ADD GLOBAL VARIABLES FOR CONTROLLING HEIGHT SPAWNS VIA MINETEST SETTING OR MINETEST.CONF

local path = minetest.get_modpath("mesecraft_mobs")

--staging area for new mobs that are incomplete
dofile(path .. "/mobs/facehugger.lua")


--Simplified Monsters
dofile(path .. "/mobs/bogeyman.lua")
dofile(path .. "/mobs/boomer.lua")
dofile(path .. "/mobs/demon_eye.lua")
dofile(path .. "/mobs/dirt_man.lua")
dofile(path .. "/mobs/ghost.lua")
dofile(path .. "/mobs/ghost_restless.lua")
dofile(path .. "/mobs/sand_man.lua")
dofile(path .. "/mobs/snowman.lua")
dofile(path .. "/mobs/stone_man.lua")
dofile(path .. "/mobs/skeleton_archer.lua")
dofile(path .. "/mobs/skeleton_fighter.lua")
dofile(path .. "/mobs/tree_monster.lua")
dofile(path .. "/mobs/zombie.lua")

-- Animals (surface and subterrane)
dofile(path .. "/mobs/bat.lua")
dofile(path .. "/mobs/cow.lua")
dofile(path .. "/mobs/deer.lua") -- Needs SFX.
dofile(path .. "/mobs/kangaroo.lua")
dofile(path .. "/mobs/ocelot.lua")
dofile(path .. "/mobs/mooshroom.lua")
dofile(path .. "/mobs/panda.lua") -- Needs spawn.
dofile(path .. "/mobs/parrot.lua")
dofile(path .. "/mobs/penguin.lua") -- Needs SFX, and Follow items.
dofile(path .. "/mobs/polar_bear.lua")
dofile(path .. "/mobs/rabbit.lua")
dofile(path .. "/mobs/rat.lua")
dofile(path .. "/mobs/sheep.lua") -- Needs SFX.
dofile(path .. "/mobs/spider.lua")
dofile(path .. "/mobs/wolf.lua")

-- Farm Animals
dofile(path .. "/mobs/pig.lua")
dofile(path .. "/mobs/chicken.lua")

-- Sea Animals (aquatic)
dofile(path .. "/mobs/clownfish.lua")
dofile(path .. "/mobs/cod.lua")
dofile(path .. "/mobs/crocodile.lua")
dofile(path .. "/mobs/dolphin.lua")
dofile(path .. "/mobs/salmon.lua")
dofile(path .. "/mobs/shark.lua")
dofile(path .. "/mobs/snapper.lua")
dofile(path .. "/mobs/turtle.lua")

-- Cave Creatures (anywhere)
dofile(path .. "/mobs/fire_imp.lua")
dofile(path .. "/mobs/ghost_murderous.lua") -- (-500)
dofile(path .. "/mobs/water_man.lua")

-- Cave Creatures (df_caverns, layer 1+2)
dofile(path .. "/mobs/cave_crocodile.lua")
dofile(path .. "/mobs/giant_bat.lua")
dofile(path .. "/mobs/giant_cave_spider.lua")

-- Cave Creatures (df_caverns, layers 2+3)
dofile(path .. "/mobs/cave_floater.lua")
dofile(path .. "/mobs/jabberer.lua")

-- Cave Creatures (df_caverns, layer 3)
dofile(path .. "/mobs/blood_man.lua")
dofile(path .. "/mobs/diamond_man.lua")
dofile(path .. "/mobs/gold_man.lua")
dofile(path .. "/mobs/iron_man.lua")
dofile(path .. "/mobs/magma_man.lua")

-- Cave Creatures (df_caverns, layer 3+4)
dofile(path .. "/mobs/fire_man.lua")

-- Moon Creatures (planet_moon)
dofile(path .. "/mobs/astronaut.lua")  -- trader npc
dofile(path .. "/mobs/flying_saucer.lua")
dofile(path .. "/mobs/grey_enlisted.lua")
dofile(path .. "/mobs/grey_civilian.lua")
dofile(path .. "/mobs/reptilian_elite.lua")
dofile(path .. "/mobs/zombie_space.lua")

-- Items (usually these are mob drops)
dofile(path .. "/items/blood.lua")
dofile(path .. "/items/bone.lua")
dofile(path .. "/items/butter.lua")
dofile(path .. "/items/cheese.lua")
dofile(path .. "/items/chicken_items.lua")
dofile(path .. "/items/clownfish_items.lua")
dofile(path .. "/items/cod_items.lua")
dofile(path .. "/items/death_items.lua")
dofile(path .. "/items/leather.lua")
dofile(path .. "/items/meat.lua")
dofile(path .. "/items/milk.lua")
dofile(path .. "/items/mutton.lua")
dofile(path .. "/items/poop.lua")
dofile(path .. "/items/pork.lua")
dofile(path .. "/items/rabbit_items.lua")
dofile(path .. "/items/rotten_flesh.lua")
dofile(path .. "/items/salmon_items.lua")
dofile(path .. "/items/spider_items.lua")
dofile(path .. "/items/snapper_items.lua")

-- Nether creatures, named after Freedoom's monsters
dofile(path .. "/mobs/trilobite.lua")
dofile(path .. "/mobs/assault_tripod.lua")
dofile(path .. "/mobs/pain_lord.lua")
dofile(path .. "/mobs/serpentipede.lua")
dofile(path .. "/mobs/combat_slug.lua")
dofile(path .. "/mobs/flesh_worm.lua")
dofile(path .. "/mobs/hatchling.lua")
