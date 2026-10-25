
-- GENERATED CODE
-- Node Box Editor, version 0.9.0

position1 = nil
position2 = nil

minetest.register_node("scifi_nodes:egg", {
	description = "Alien Egg",
	tiles = {
		"scifi_nodes_egg_top.png",
		"scifi_nodes_egg_top.png",
		"scifi_nodes_egg_side.png",
		"scifi_nodes_egg_side.png",
		"scifi_nodes_egg_side.png",
		"scifi_nodes_egg_side.png"
	},
	sunlight_propagates = false,
	drawtype = "nodebox",
	paramtype = "light",
	groups = {cracky=1, oddly_breakable_by_hand=1, dig_immediate=2, falling_node=1},
	light_source = 5,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, -0.4375, 0.25}, -- NodeBox1
			{-0.375, -0.4375, -0.375, 0.375, -0.3125, 0.375}, -- NodeBox2
			{-0.4375, -0.3125, -0.375, 0.4375, 0.3125, 0.375}, -- NodeBox3
			{-0.375, 0.3125, -0.375, 0.375, 0.4375, 0.375}, -- NodeBox4
			{-0.3125, 0.4375, -0.3125, 0.3125, 0.5625, 0.3125}, -- NodeBox5
			{-0.25, 0.5625, -0.25, 0.25, 0.6875, 0.25}, -- NodeBox6
			{-0.1875, 0.6875, -0.1875, 0.1875, 0.75, 0.1875}, -- NodeBox7
			{-0.125, 0.75, -0.125, 0.125, 0.8125, 0.125}, -- NodeBox8
			{-0.375, -0.3125, -0.4375, 0.375, 0.3125, 0.4375}, -- NodeBox9
		}
	}
})

if minetest.get_modpath("scifi_mobs") then
minetest.register_abm({
	nodenames = {"scifi_nodes:egg"},
	interval = 30, chance = 10,
	action = function(pos, node, _, _)
		minetest.add_entity(pos, "scifi_mobs:xenomorph")
		minetest.remove_node(pos)
	end
})
end
