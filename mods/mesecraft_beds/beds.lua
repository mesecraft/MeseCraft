-- mesecraft_beds/beds.lua

-- support for MT game translation.
local S = beds.get_translator

-- Simple shaped bed

beds.colors = {
	{"black", "Black"},
	{"blue", "Blue"},
	{"brown", "Brown"},
	{"cyan", "Cyan"},
	{"dark_green", "Dark Green"},
	{"dark_grey", "Dark Grey"},
	{"green", "Green"},
	{"grey", "Grey"},
	{"magenta", "Magenta"},
	{"orange", "Orange"},
	{"pink", "Pink"},
	{"red", "Red"},
	{"violet", "Violet"},
	{"white", "White"},
	{"yellow", "Yellow"},
}

for _, row in ipairs(beds.colors) do
local color = row[1]
local desc = row[2]

-- Simple shaped bed

local simple_texture = "beds_bed_inv.png^wool_"..color..".png^beds_bed_inv.png^[makealpha:255,128,128"

beds.register_bed("mesecraft_beds:bed_" ..color, {
	description =  S(desc.. " Bed"),
	inventory_image = simple_texture,
	wield_image = simple_texture,
	tiles = {
		bottom = {
			"wool_"..color..".png",
			"default_wood.png",
			"beds_bed_side_bottom_r_"..color..".png",
			"beds_bed_side_bottom_r_"..color..".png^[transformfx",
			"beds_bed_side_bottom_"..color..".png"
		},
		top = {
			"beds_bed_top_top_"..color..".png",
			"default_wood.png",
			"beds_bed_side_top_r_"..color..".png",
			"beds_bed_side_top_r_"..color..".png^[transformfx",
			"beds_bed_side_top.png",
		}
	},
	nodebox = {
		bottom = {-0.5, -0.5, -0.5, 0.5, 0.0625, 0.5},
		top = {-0.5, -0.5, -0.5, 0.5, 0.0625, 0.5},
	},
	selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.0625, 1.5},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3, bed = 2, fall_damage_add_percent=-50, bouncy=90},
        sounds = { 
		footstep = { name = "bouncy", gain = 0.8 },
                dig = { name = "default_dig_oddly_breakable_by_hand", gain = 1.0 },
                dug = { name = "default_dug_node", gain = 1.0 },
        },
	recipe = {
		{"wool:"..color, "wool:"..color, "wool:white"},
		{"group:wood", "group:wood", "group:wood"}
	},
})

-- Fuel
minetest.register_craft({
	type = "fuel",
	recipe = "mesecraft_beds:bed_"..color,
	burntime = 12,
})
end

-- Aliases for PilzAdam's beds mod, adds compatibility for mods expecting there to bed mtg beds.
minetest.register_alias("beds:bed_bottom", "mesecraft_beds:bed_red_bottom")
minetest.register_alias("beds:bed_top", "mesecraft_beds:bed_red_top")
minetest.register_alias("beds:fancy_bed_bottom", "mesecraft_beds:bed_red_bottom")
minetest.register_alias("beds:fancy_bed_top", "mesecraft_beds:bed_red_top")
