-- Radioactive gas: Mese ore exposed to the vacuum of space slowly breathes out
-- a green gas. It is thin and walk-through, but it can't be breathed and it
-- burns a little. Air destroys it, so pumping air into a base clears it out.
--
-- Written for MeseCraft (AGPLv3, like the rest of the game).

minetest.register_node("radioactive_gas:gas", {
	description = "Radioactive Gas",
	drawtype = "glasslike",
	tiles = {"radioactive_gas.png"},
	use_texture_alpha = "blend",
	post_effect_color = {a = 20, r = 20, g = 250, b = 20},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,          -- no air to breathe
	damage_per_second = 1,
	groups = {
		not_in_creative_inventory = 1,
		cools_lava = 1,
		radioactive = 4,     -- radiant_damage hurts players standing near it
	},
})

-- Outgassing. Vacuum nodes only exist in space, so this only runs where an ore
-- touches vacuum, and the high chance keeps it rare.
minetest.register_abm({
	label = "Mese ore outgassing in vacuum",
	nodenames = {"vacuum:vacuum"},
	neighbors = {"default:stone_with_mese"},
	interval = 20,
	chance = 2000,
	action = function(pos)
		minetest.set_node(pos, {name = "radioactive_gas:gas"})
	end,
})

-- Air breaks the gas down.
minetest.register_abm({
	label = "Radioactive gas clears in air",
	nodenames = {"radioactive_gas:gas"},
	neighbors = {"air"},
	interval = 5,
	chance = 5,
	action = function(pos)
		minetest.remove_node(pos)
	end,
})
