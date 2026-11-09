-- Curtains: wall-mounted cloth in every wool colour, opened and closed with a
-- right-click, plus a wooden curtain rod to hang above them.
--
-- Written for MeseCraft (AGPLv3, like the rest of the game). The textures are
-- greyscale and tinted per colour, so one pair of images covers all colours.

local S = minetest.get_translator("curtains")

-- Wooden curtain rod: a thin bar along the top edge of a wall.
minetest.register_node("curtains:tapestry_top", {
	description = S("Wooden Curtain Rod"),
	drawtype = "nodebox",
	tiles = {"default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {-0.6, -0.5, 0.375, 0.6, -0.375, 0.5},
	},
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	type = "shapeless",
	output = "curtains:tapestry_top",
	recipe = {"default:stick"},
})

minetest.register_craft({
	type = "shapeless",
	output = "default:stick",
	recipe = {"curtains:tapestry_top"},
})

-- Tint for each wool colour, applied to the greyscale cloth with [multiply.
local colours = {
	{"black", S("Black Curtain"), "#3a3631"},
	{"blue", S("Blue Curtain"), "#3c6a96"},
	{"brown", S("Brown Curtain"), "#8a644f"},
	{"cyan", S("Cyan Curtain"), "#4fb6be"},
	{"dark_green", S("Dark Green Curtain"), "#5e7640"},
	{"dark_grey", S("Dark Grey Curtain"), "#6a6563"},
	{"green", S("Green Curtain"), "#8fba62"},
	{"grey", S("Grey Curtain"), "#b0aba7"},
	{"magenta", S("Magenta Curtain"), "#d0589a"},
	{"orange", S("Orange Curtain"), "#e8863e"},
	{"pink", S("Pink Curtain"), "#e8a0a0"},
	{"red", S("Red Curtain"), "#b8423e"},
	{"violet", S("Violet Curtain"), "#8a4aa8"},
	{"white", S("White Curtain"), "#f2ece4"},
	{"yellow", S("Yellow Curtain"), "#e8c84a"},
}

-- Properties shared by the closed and open curtain of every colour.
local function curtain_def(texture, other_state)
	return {
		drawtype = "signlike",
		tiles = {texture},
		inventory_image = texture,
		wield_image = texture,
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		selection_box = {type = "wallmounted"},
		groups = {dig_immediate = 3, flammable = 3},
		sounds = default.node_sound_leaves_defaults(),
		-- Right-click swaps between the closed and open curtain.
		on_rightclick = function(pos, node, _, itemstack)
			minetest.swap_node(pos, {name = other_state, param2 = node.param2})
			return itemstack
		end,
	}
end

for _, entry in ipairs(colours) do
	local colour, description, tint = entry[1], entry[2], entry[3]
	local closed = "curtains:curtain_" .. colour
	local open = "curtains:curtain_open_" .. colour

	local closed_def = curtain_def("curtains_closed.png^[multiply:" .. tint, open)
	closed_def.description = description
	minetest.register_node(closed, closed_def)

	-- The open curtain drops the closed one and stays out of creative.
	local open_def = curtain_def("curtains_open.png^[multiply:" .. tint, closed)
	open_def.drop = closed
	open_def.groups.not_in_creative_inventory = 1
	minetest.register_node(open, open_def)

	minetest.register_craft({
		output = closed,
		recipe = {{"wool:" .. colour}},
	})
end
