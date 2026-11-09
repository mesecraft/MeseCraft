
-- add lucky blocks

if minetest.get_modpath("lucky_block") then

	lucky_block:add_blocks({
		{"dro", {"farming:corn"}, 5},
		{"dro", {"farming:coffee_cup_hot"}, 1},
		{"dro", {"farming:bread"}, 5},
		{"nod", "farming:jackolantern", 0},
		{"tro", "farming:jackolantern_on"},
		{"nod", "default:river_water_source", 1},
		{"tel"},
		{"dro", {"farming:trellis", "farming:grapes"}, 5},
		{"dro", {"farming:bottle_ethanol"}, 1},
		{"nod", "farming:melon", 0},
		{"dro", {"farming:donut", "farming:donut_chocolate", "farming:donut_apple"}, 5},
		{"dro", {"farming:hemp_leaf", "farming:hemp_fibre", "farming:seed_hemp"}, 10},
		{"nod", "fire:permanent_flame", 1},
		{"dro", {"farming:chili_pepper", "farming:chili_bowl"}, 5},
		{"dro", {"farming:bowl"}, 3},
		{"dro", {"farming:saucepan"}, 1},
		{"dro", {"farming:pot"}, 1},
		{"dro", {"farming:baking_tray"}, 1},
		{"dro", {"farming:skillet"}, 1},
		{"exp", 4},
		{"dro", {"farming:mortar_pestle"}, 1},
		{"dro", {"farming:cutting_board"}, 1},
		{"dro", {"farming:juicer"}, 1},
		{"dro", {"farming:mixing_bowl"}, 1},
		{"dro", {"farming:hoe_bronze"}, 1},
		{"dro", {"farming:hoe_mese"}, 1},
		{"dro", {"farming:hoe_diamond"}, 1},
		{"dro", {"farming:hoe_bomb"}, 10},
		{"dro", {"farming:turkish_delight"}, 5},
		{"lig"},
		{"dro", {"farming:scythe_mithril"}, 1},
		{"sch", "instafarm", 0, true, {
			{"farming:wheat_8", "farming:carrot_8"},
			{"farming:cotton_8", "farming:rhubarb_3"},
		}},
		{"sch", "instafarm", 0, true, {
			{"farming:wheat_8", "farming:pepper_5"},
			{"farming:cotton_8", "farming:onion_5"},
		}},
		{"sch", "instafarm", 0, true, {
			{"farming:wheat_8", "farming:beetroot_5"},
			{"farming:cotton_8", "farming:barley_8"},
		}},
		{"sch", "instafarm", 0, true, {
			{"farming:wheat_8", "farming:corn_8"},
			{"farming:cotton_8", "farming:grapes_8"},
		}},
		{"sch", "instafarm", 0, true, {
			{"farming:wheat_8", "farming:pea_5"},
			{"farming:cotton_8", "farming:coffee_5"},
		}},
		{"sch", "instafarm", 0, true, {
			{"farming:wheat_8", "farming:raspberry_4"},
			{"farming:cotton_8", "farming:tomato_8"},
		}},
		{"sch", "instafarm", 0, true, {
			{"farming:wheat_8", "farming:chili_8"},
			{"farming:cotton_8", "farming:cucumber_4"},
		}},
		{"nod", "default:chest", 0, {
			{name = "farming:seed_wheat", max = 15},
			{name = "farming:seed_barley", max = 15},
			{name = "farming:seed_barley", max = 15},
			{name = "farming:seed_hemp", max = 15},
			{name = "farming:seed_rye", max = 15},
			{name = "farming:seed_rice", max = 15},
			{name = "farming:seed_oat", max = 15},
			{name = "farming:soil_wet", max = 10},
		}},
	})
end
