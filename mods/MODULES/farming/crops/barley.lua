
local S = farming.intllib

-- barley seeds
minetest.register_node("farming:seed_barley", {
	description = S("Barley Seed"),
	tiles = {"farming_barley_seed.png"},
	inventory_image = "farming_barley_seed.png",
	wield_image = "farming_barley_seed.png",
	drawtype = "signlike",
	groups = {seed = 1, snappy = 3, attached_node = 1},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:barley_1")
	end
})

-- harvested barley
minetest.register_craftitem("farming:barley", {
	description = S("Barley"),
	inventory_image = "farming_barley.png",
	groups = {food_barley = 1, flammable = 2}
})

-- flour
minetest.register_craft({
	type = "shapeless",
	output = "farming:flour",
	recipe = {
		"farming:barley", "farming:barley", "farming:barley",
		"farming:barley", "farming:mortar_pestle"
	},
	replacements = {{"group:food_mortar_pestle", "farming:mortar_pestle"}}
})

-- barley definition
local def = {
	drawtype = "plantlike",
	tiles = {"farming_barley_1.png"},
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	drop = "",
	selection_box = farming.select,
	groups = {
		snappy = 3, flammable = 2, plant = 1, attached_node = 1,
		not_in_creative_inventory = 1, growing = 1
	},
	sounds = default.node_sound_leaves_defaults()
}

-- stage 1
minetest.register_node("farming:barley_1", table.copy(def))

-- stage 2
def.tiles = {"farming_barley_2.png"}
minetest.register_node("farming:barley_2", table.copy(def))

-- stage 3
def.tiles = {"farming_barley_3.png"}
minetest.register_node("farming:barley_3", table.copy(def))

-- stage 4
def.tiles = {"farming_barley_4.png"}
minetest.register_node("farming:barley_4", table.copy(def))

-- stage 5
def.tiles = {"farming_barley_5.png"}
minetest.register_node("farming:barley_5", table.copy(def))

-- stage 6
def.tiles = {"farming_barley_6.png"}
def.drop = {
	items = {
		{items = {"farming:barley"}, rarity = 2},
		{items = {"farming:seed_barley"}, rarity = 2}
	}
}
minetest.register_node("farming:barley_6", table.copy(def))

-- stage 7
def.tiles = {"farming_barley_7.png"}
def.drop = {
	items = {
		{items = {"farming:barley"}, rarity = 2},
		{items = {"farming:seed_barley"}, rarity = 1}
	}
}
minetest.register_node("farming:barley_7", table.copy(def))

-- stage 8 (final)
def.tiles = {"farming_barley_8.png"}
def.groups.growing = nil
def.drop = {
	items = {
		{items = {"farming:barley"}, rarity = 1},
		{items = {"farming:barley"}, rarity = 3},
		{items = {"farming:seed_barley"}, rarity = 1},
		{items = {"farming:seed_barley"}, rarity = 3}
	}
}
minetest.register_node("farming:barley_8", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:barley"] = {
	crop = "farming:barley",
	seed = "farming:seed_barley",
	minlight = 13,
	maxlight = 15,
	steps = 8
}

-- Fuel
minetest.register_craft({
	type = "fuel",
	recipe = "farming:barley",
	burntime = 1
})
