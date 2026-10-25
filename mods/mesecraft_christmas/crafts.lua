-- Nodes
	-- 9 Candy Canes into 3 Candy Cane Blocks.
        minetest.register_craft({
                output = "mesecraft_christmas:candy_cane_block 3",
                recipe = {
                        {"mesecraft_christmas:candy_cane", "mesecraft_christmas:candy_cane", "mesecraft_christmas:candy_cane"},
                        {"mesecraft_christmas:candy_cane", "mesecraft_christmas:candy_cane", "mesecraft_christmas:candy_cane"},
                        {"mesecraft_christmas:candy_cane", "mesecraft_christmas:candy_cane", "mesecraft_christmas:candy_cane"},
                },
        })

	-- 9 Green Candy Canes into 3 Green Candy Cane Blocks.
        minetest.register_craft({
                output = "mesecraft_christmas:green_candy_cane_block 3",
                recipe = {
                        {"mesecraft_christmas:green_candy_cane", "mesecraft_christmas:green_candy_cane", "mesecraft_christmas:green_candy_cane"},
                        {"mesecraft_christmas:green_candy_cane", "mesecraft_christmas:green_candy_cane", "mesecraft_christmas:green_candy_cane"},
                        {"mesecraft_christmas:green_candy_cane", "mesecraft_christmas:green_candy_cane", "mesecraft_christmas:green_candy_cane"},
                },
        })

	-- 9 Gingerbread Men into 3 Gingerbread Blocks.
        minetest.register_craft({
                output = "mesecraft_christmas:gingerbread_block 3",
                recipe = {
                        {"mesecraft_christmas:gingerbread_man", "mesecraft_christmas:gingerbread_man", "mesecraft_christmas:gingerbread_man"},
                        {"mesecraft_christmas:gingerbread_man", "mesecraft_christmas:gingerbread_man", "mesecraft_christmas:gingerbread_man"},
                        {"mesecraft_christmas:gingerbread_man", "mesecraft_christmas:gingerbread_man", "mesecraft_christmas:gingerbread_man"},
                },
        })

        -- 9 Gingerbread into 3 Gingerbread Blocks.
        minetest.register_craft({
                output = "mesecraft_christmas:gingerbread_block 3",
                recipe = {
                        {"mesecraft_christmas:gingerbread", "mesecraft_christmas:gingerbread", "mesecraft_christmas:gingerbread"},
                        {"mesecraft_christmas:gingerbread", "mesecraft_christmas:gingerbread", "mesecraft_christmas:gingerbread"},
                        {"mesecraft_christmas:gingerbread", "mesecraft_christmas:gingerbread", "mesecraft_christmas:gingerbread"},
                },
        })

	-- Frosting Block
        minetest.register_craft({
                output = "mesecraft_christmas:frosting_block 3",
                recipe = {
                        {"group:food_sugar", "group:food_sugar", "group:food_sugar"},
                        {"group:food_sugar", "mesecraft_mobs:milk_bucket", "group:food_sugar"},
                        {"group:food_sugar", "group:food_sugar", "group:food_sugar"},
		},
		replacements = {{"mesecraft_mobs:milk_bucket", "mesecraft_bucket:bucket_empty"}},
        })


-- 3d_armor : Candy Cane Armor
	minetest.register_craft({
		output = "mesecraft_christmas:helmet_cane",
		recipe = {
			{"mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block"},
			{"mesecraft_christmas:candy_cane_block", "", "mesecraft_christmas:candy_cane_block"},
			{"", "", ""},
		},
	})
	minetest.register_craft({
		output = "mesecraft_christmas:chestplate_cane",
		recipe = {
			{"mesecraft_christmas:candy_cane_block", "", "mesecraft_christmas:candy_cane_block"},
			{"mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block"},
			{"mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block"},
		},
	})
	minetest.register_craft({
		output = "mesecraft_christmas:leggings_cane",
		recipe = {
			{"mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block"},
			{"mesecraft_christmas:candy_cane_block", "", "mesecraft_christmas:candy_cane_block"},
			{"mesecraft_christmas:candy_cane_block", "", "mesecraft_christmas:candy_cane_block"},
		},
	})
	minetest.register_craft({
		output = "mesecraft_christmas:boots_cane",
		recipe = {
			{"mesecraft_christmas:candy_cane_block", "", "mesecraft_christmas:candy_cane_block"},
			{"mesecraft_christmas:candy_cane_block", "", "mesecraft_christmas:candy_cane_block"},
		},
	})
	minetest.register_craft({
		output = "mesecraft_christmas:shield_cane",
		recipe = {
			{"mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block"},
			{"mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block"},
			{"", "mesecraft_christmas:candy_cane_block", ""},
		},
	})
-- Candy Cane Pickaxe
        minetest.register_craft({
                output = "mesecraft_christmas:pick_cane",
                recipe = {
                        {"mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block"},
                        {"", "mesecraft_christmas:candy_cane", ""},
                        {"", "mesecraft_christmas:candy_cane", ""},
                },
        })
-- Candy Cane Axe
        minetest.register_craft({
                output = "mesecraft_christmas:axe_cane",
                recipe = {
                        {"mesecraft_christmas:candy_cane_block", "mesecraft_christmas:candy_cane_block", ""},
                        {"", "mesecraft_christmas:candy_cane", ""},
                        {"", "mesecraft_christmas:candy_cane", ""},
                },
        })
-- Candy Cane Sword
        minetest.register_craft({
                output = "mesecraft_christmas:sword_cane",
                recipe = {
                        {"", "mesecraft_christmas:candy_cane_block", ""},
                        {"", "mesecraft_christmas:candy_cane_block", ""},
                        {"", "mesecraft_christmas:candy_cane", ""},
                },
        })


-- Christmas Bell
-- Mistletoe
-- Christmas Reef
-- Icicles
-- Christmas Tree Star

-- Garland
minetest.register_craft({
        output = "mesecraft_christmas:garland 3",
	type = "shapeless",
        recipe = {"default:pine_needles", "default:pine_needles", "default:pine_needles"},
})
-- Festive Garland
minetest.register_craft({
        output = "mesecraft_christmas:festive_garland",
	type = "shapeless",
        recipe = {"mesecraft_christmas:garland", "farming:raspberries"},
})
-- Festive Garland with Lights
minetest.register_craft({
        output = "mesecraft_christmas:festive_garland_lights",
        type = "shapeless",
        recipe = {"mesecraft_christmas:festive_garland", "mesecraft_holiday_lights:lights_white"},
})

-- Red Garland
minetest.register_craft({
        output = "mesecraft_christmas:garland_red 3",
        type = "shapeless",
        recipe = {"mesecraft_christmas:garland","mesecraft_christmas:garland","mesecraft_christmas:garland", "dye:red"},
})

-- Yellow Garland
minetest.register_craft({
        output = "mesecraft_christmas:garland_yellow 3",
        type = "shapeless",
        recipe = {"mesecraft_christmas:garland","mesecraft_christmas:garland","mesecraft_christmas:garland", "dye:yellow"},
})

-- White Garland
minetest.register_craft({
        output = "mesecraft_christmas:garland_white 3",
        type = "shapeless",
        recipe = {"mesecraft_christmas:garland","mesecraft_christmas:garland","mesecraft_christmas:garland", "dye:white"},
})

-- ORNAMENTS
-- SKIPPED

-- CRAFT ITEMS

-- Candy Cane
-- SKIPPED

-- Green Candy Cane
-- SKIPPED

-- Peppermint Candies
minetest.register_craft({
        output = "mesecraft_christmas:peppermint_candies 8",
        type = "shapeless",
        recipe = {"mesecraft_christmas:peppermint","mesecraft_christmas:peppermint","group:food_sugar", "group:food_sugar", "dye:red", "farming:mortar_pestle"},
        replacements = {{"farming:mortar_pestle", "farming:mortar_pestle"}},
})

-- Green Peppermint Candies
minetest.register_craft({
        output = "mesecraft_christmas:green_peppermint_candies 8",
        type = "shapeless",
        recipe = {"mesecraft_christmas:peppermint","mesecraft_christmas:peppermint","group:food_sugar", "group:food_sugar", "dye:green", "farming:mortar_pestle"},
        replacements = {{"farming:mortar_pestle", "farming:mortar_pestle"}},
})

-- Gingerbread Dough
minetest.register_craft({
        output = "mesecraft_christmas:gingerbread_dough",
        type = "shapeless",
        recipe = {"mesecraft_christmas:ginger","mesecraft_christmas:ginger","group:food_flour", "group:food_flour", "group:food_sugar", "group:food_egg", "mesecraft_mobs:butter", "farming:mortar_pestle"},
        replacements = {{"farming:mortar_pestle", "farming:mortar_pestle"}},
})
-- Gingerbread Cooking Recipe
minetest.register_craft({
        type = "cooking",
        output = "mesecraft_christmas:gingerbread",
        recipe = "mesecraft_christmas:gingerbread_dough",
        cooktime = 10,
})
-- Gingerbread Cookie (Man)
-- SKIPPED

-- Sugar Cookie
minetest.register_craft({
        output = "mesecraft_christmas:sugar_cookie 6",
        type = "shapeless",
        recipe = {"group:food_flour","group:food_flour", "group:food_sugar", "group:food_sugar", "group:food_egg", "mesecraft_mobs:butter"},
})
-- Bell Sugar Cookie
minetest.register_craft({
        output = "mesecraft_christmas:sugar_cookie_bell 4",
        type = "shapeless",
        recipe = {"group:food_flour","group:food_flour", "group:food_sugar", "group:food_sugar", "group:food_egg", "mesecraft_mobs:butter", "dye:blue"},
})
-- Star Sugar Cookie
minetest.register_craft({
        output = "mesecraft_christmas:sugar_cookie_star 4",
        type = "shapeless",
        recipe = {"group:food_flour","group:food_flour", "group:food_sugar", "group:food_sugar", "group:food_egg", "mesecraft_mobs:butter", "dye:red"},
})
-- Tree Sugar Cookie
minetest.register_craft({
        output = "mesecraft_christmas:sugar_cookie_tree 4",
        type = "shapeless",
        recipe = {"group:food_flour","group:food_flour", "group:food_sugar", "group:food_sugar", "group:food_egg", "mesecraft_mobs:butter", "dye:green"},
})
-- Glass of Hot Chocolate
-- SKIPPED

-- Glass of Eggnog
-- SKIPPED, maybe use ginger


-- Stocking
--minetest.register_craft({
--      output = "mesecraft_christmas:stocking",
--      recipe = {
--            {"farming:string", "wool:white", "wool:white"},
--              {"", "wool:red", "wool:red"},
--              {"wool:red", "wool:red", "wool:red"},
--      }
--})
-- Green Stockings
--minetest.register_craft({
--      output = "mesecraft_christmas:green_stocking",
--      recipe = {
--              {"farming:string", "wool:white", "wool:white"},
--              {"", "wool:green", "wool:green"},
--             {"wool:green", "wool:green", "wool:green"},
--     }
--})

