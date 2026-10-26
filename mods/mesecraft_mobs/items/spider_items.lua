-- todo: uses for silk.

-- Spiderweb item.
minetest.register_node("mesecraft_mobs:spiderweb", {
	description = "Spiderweb",
	drawtype = "plantlike",
	visual_scale = 1.2,
	tiles = {"mesecraft_mobs_items_spiderweb.png"},
	inventory_image = "mesecraft_mobs_items_spiderweb.png",
	paramtype = "light",
	liquid_viscosity = 20,
	liquidtype = "source",
	liquid_alternative_flowing = "mesecraft_mobs:spiderweb",
	liquid_alternative_source = "mesecraft_mobs:spiderweb",
	liquid_renewable = false,
	liquid_range = 0,
	walkable = false,
	pointable = true,
	diggable = true,
	buildable_to = false,
	drop = "mesecraft_mobs:spiderweb",
	groups = {snappy = 1, disable_jump = 1},
	sounds = default.node_sound_leaves_defaults(),
})

-- Spider Silk item.
minetest.register_craftitem("mesecraft_mobs:silk", {
	description = "Silk",
	inventory_image = "mesecraft_mobs_items_spider_silk.png",
	groups = {flammable = 2},
})

-- Make silk from spiderweb.
 minetest.register_craft({
	output = "mesecraft_mobs:silk",
	recipe = {
		{"mesecraft_mobs:spiderweb", "mesecraft_mobs:spiderweb", "mesecraft_mobs:spiderweb"},
		{"mesecraft_mobs:spiderweb", "default:stick", "mesecraft_mobs:spiderweb"},
		{"mesecraft_mobs:spiderweb", "mesecraft_mobs:spiderweb", "mesecraft_mobs:spiderweb"},
	}
})
-- Furnace Recipe for Spiderweb.
minetest.register_craft({
        type = "fuel",
        recipe = "mesecraft_mobs:spiderweb",
        burntime = 1,
})

-- Furnace Recipe for Silk
minetest.register_craft({
	type = "fuel",
	recipe = "mesecraft_mobs:silk",
	burntime = 1,
})
