-- MeseCraft Fireplace -----------------------------------------------

minetest.register_node("mesecraft_fireplace:fireplace", {
	description = "Fireplace",
	tiles = {"mesecraft_fireplace_top.png", "mesecraft_fireplace_top.png", "mesecraft_fireplace_side.png", "mesecraft_fireplace_side.png", "mesecraft_fireplace_side.png", "mesecraft_fireplace_front.png"},
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	paramtype2 = "facedir",
	sounds = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		node.name = "mesecraft_fireplace:fireplace_active"
		minetest.set_node(pos, node)
		minetest.sound_play("fire", {
			pos = pos,
			max_hear_distance = 10,
			gain = 6,
		})
	end
})

minetest.register_node("mesecraft_fireplace:fireplace_active", {
	tiles = {
	"mesecraft_fireplace_top.png", "mesecraft_fireplace_top.png", "mesecraft_fireplace_side.png", "mesecraft_fireplace_side.png", "mesecraft_fireplace_side.png",
		{
			name = "mesecraft_fireplace_active.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		}
	},
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	paramtype2 = "facedir",
	light_source = 8,
	on_rightclick = function(pos, node, clicker, itemstack)
		node.name = "mesecraft_fireplace:fireplace"
		minetest.set_node(pos, node)
	end
})

minetest.register_craft({
	output = 'mesecraft_fireplace:fireplace',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'default:stone', 'default:coalblock', 'default:stone'},
		{'default:stone', 'default:stone', 'default:stone'},
	}
})
