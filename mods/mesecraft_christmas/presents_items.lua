-- Christmas Presents by FreeGamers.org
-- Description: Adds Christmas presents that give random items.
-- Note: Make sure this runs after presents_functions.lua
-- Instructions: Uses item tables to determine what is common, rare, and special.
-- farming, pie, dye, default, mesecraft_mobs, holiday lights, 

mesecraft_christmas.christmas_common_item_pool = {}
mesecraft_christmas.christmas_uncommon_item_pool = {}
mesecraft_christmas.christmas_special_item_pool = {}

-- Common Item Pool
	table.insert(mesecraft_christmas.christmas_common_item_pool, "default:coal_lump")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "default:pine_needles")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "default:pine_sapling")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "default:pine_wood")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "dye:red")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "dye:green")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:candy_cane")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:peppermint_candies")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:green_peppermint_candies")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:sugar_cookie")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:eggnog_glass")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:hot_chocolate_glass")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_mobs:milk_glass")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:candy_cane_block")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:gingerbread_block")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:icicles")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:festive_garland")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:festive_garland_lights")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:garland_red")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:garland_yellow")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:garland_white")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:ornament_white")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:ornament_yellow")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:ornament_red")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:ornament_green")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:ornament_blue")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:ornament_orange")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:ornament_purple")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_christmas:ornament_pink")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "default:gold_ingot")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "default:blueberries")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "default:ice")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "default:snow")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_holiday_lights:lights_icy")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_holiday_lights:lights_festive")
	table.insert(mesecraft_christmas.christmas_common_item_pool, "mesecraft_holiday_lights:lights_rainbow")


-- Uncommon Item Pool
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "default:coal")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "default:pine_tree")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "farming:chocolate_dark")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "pie:pie_0")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "farming:porridge")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:green_candy_cane")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:gingerbread")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:gingerbread_cookie")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:sugar_cookie_star")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:sugar_cookie_tree")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:sugar_cookie_bell")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_mobs:milk_bucket")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:peppermint_seeds")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:ginger")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:green_candy_cane_block")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:frosting_block")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:mistletoe")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:reef")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:christmas_star")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:painting_03")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_christmas:painting_05")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "farming:blueberry_pie")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "gramophone:vinyl_disc10")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "gramophone:vinyl_disc11")
        table.insert(mesecraft_christmas.christmas_uncommon_item_pool, "mesecraft_rainbow_block:mesecraft_rainbow_block")

-- Special Item Pool
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:christmas_bell")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:helmet_cane")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:chestplate_cane")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:leggings_cane")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:boots_cane")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:shield_cane")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:mask_green_santa_hat")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:mask_santa_hat")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:mask_red_poof_ball_hat")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:suit_elf")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:suit_orange_parka")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:suit_santa")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:suit_tree")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:shirt_ugly_sweater")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:painting_01")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:painting_02")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:painting_04")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:painting_06")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:stocking")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:green_stocking")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:pick_cane")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:axe_cane")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "mesecraft_christmas:sword_cane")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "gramophone:vinyl_disc12")
        table.insert(mesecraft_christmas.christmas_special_item_pool, "gramophone:vinyl_disc13")


-- Register Presents (3 tiers: 3 commons, 2 uncommon, 2 special)

	-- Common Tier
	minetest.register_craftitem("mesecraft_christmas:present_01", {
		description = "" ..core.colorize("#35cdff","Christmas Present\n") ..core.colorize("#FFFFFF", "Wonder what's inside?"),
		inventory_image = "mesecraft_christmas_present_01.png",
		on_use = mesecraft_christmas.open_present("christmas_common"),
	})

	minetest.register_craftitem("mesecraft_christmas:present_02", {
		description = "" ..core.colorize("#35cdff","Christmas Present\n") ..core.colorize("#FFFFFF", "Wonder what's inside?"),
	        inventory_image = "mesecraft_christmas_present_02.png",
	        on_use = mesecraft_christmas.open_present("christmas_common"),
	})

	minetest.register_craftitem("mesecraft_christmas:present_03", {
		description = "" ..core.colorize("#35cdff","Christmas Present\n") ..core.colorize("#FFFFFF", "Wonder what's inside?"),
	        inventory_image = "mesecraft_christmas_present_03.png",
	        on_use = mesecraft_christmas.open_present("christmas_common"),
	})

	-- Uncommon Tier

	minetest.register_craftitem("mesecraft_christmas:present_04", {
                description = "" ..core.colorize("#146b3a","Christmas Present\n") ..core.colorize("#FFFFFF", "Wonder what's inside?"),
	        inventory_image = "mesecraft_christmas_present_04.png",
	        on_use = mesecraft_christmas.open_present("christmas_uncommon"),
	})

        minetest.register_craftitem("mesecraft_christmas:present_05", {
                description = "" ..core.colorize("#146b3a","Christmas Present\n") ..core.colorize("#FFFFFF", "Wonder what's inside?"),
                inventory_image = "mesecraft_christmas_present_05.png",
                on_use = mesecraft_christmas.open_present("christmas_uncommon"),
        })

	-- Special Tier

        minetest.register_craftitem("mesecraft_christmas:present_06", {
                description = "" ..core.colorize("#bb2528","Christmas Present\n") ..core.colorize("#FFFFFF", "Wonder what's inside?"),
                inventory_image = "mesecraft_christmas_present_06.png",
                on_use = mesecraft_christmas.open_present("christmas_special"),
        })

        minetest.register_craftitem("mesecraft_christmas:present_07", {
                description = "" ..core.colorize("#bb2528","Christmas Present\n") ..core.colorize("#FFFFFF", "Wonder what's inside?"),
                inventory_image = "mesecraft_christmas_present_07.png",
                on_use = mesecraft_christmas.open_present("christmas_special"),
        })
