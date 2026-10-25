-- radioactive outgasing of ores in vacuum

-- gas definition, drowns and is slightly radioactive
minetest.register_node("radioactive_gas:gas", {
	description = "Moon gas",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drawtype = "glasslike",
	drowning = 1,
	damage_per_second = 1,
	post_effect_color = {a = 20, r = 20, g = 250, b = 20},
	tiles = {"radioactive_gas.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	groups = {
    not_in_creative_inventory = 1,
    not_blocking_trains = 1,
    cools_lava = 1,
    radioactive = 4,
  },
	drop = {},
	sunlight_propagates = true
})

-- ores gas out in vacuum
minetest.register_abm({
  label = "moon ore outgasing",
	nodenames = {"vacuum:vacuum"},
	neighbors = {
    "default:stone_with_mese",
    "default:mineral_uranium"
  },
	interval = 20,
	chance = 2000,
	action = function(pos)
    minetest.set_node(pos, {name = "radioactive_gas:gas"})
  end
})

-- radioactive gas removal if near air
minetest.register_abm({
  label = "radioactive gas removal",
	nodenames = {"radioactive_gas:gas"},
	neighbors = {"air"},
	interval = 5,
	chance = 5,
	action = function(pos)
    minetest.set_node(pos, {name = "air"})
  end
})
