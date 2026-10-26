-- 5.x translation
local S = minetest.get_translator("mesecraft_baked_clay")

local flowers = {
	{"delphinium", "Blue Delphinium",
	{-0.15, -0.5, -0.15, 0.15, 0.3, 0.15}, {color_cyan = 1}},

	{"thistle", "Thistle",
	{-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}, {color_magenta = 1}},

	{"lazarus", "Lazarus Bell",
	{-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}, {color_pink = 1}},

	{"mannagrass", "Reed Mannagrass",
	{-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}, {color_dark_green = 1}}
}

-- register some new flowers to fill in missing dye colours
-- flower registration (borrowed from default game)
local function add_simple_flower(name, desc, box, f_groups)

	f_groups.snappy = 3
	f_groups.flower = 1
	f_groups.flora = 1
	f_groups.attached_node = 1

	minetest.register_node("mesecraft_baked_clay:" .. name, {
		description = S(desc),
		drawtype = "plantlike",
		waving = 1,
		tiles = {"mesecraft_baked_clay_" .. name .. ".png"},
		inventory_image = "mesecraft_baked_clay_" .. name .. ".png",
		wield_image = "mesecraft_baked_clay_" .. name .. ".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		stack_max = 99,
		groups = f_groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {type = "fixed", fixed = box}
	})
end

for _,item in pairs(flowers) do
	add_simple_flower(unpack(item))
end

-- add new flowers to mapgen
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.004,
		spread = {x = 100, y = 100, z = 100},
		seed = 7133,
		octaves = 3,
		persist = 0.6
	},
	y_min = 10,
	y_max = 90,
	decoration = "mesecraft_baked_clay:delphinium"
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.004,
		spread = {x = 100, y = 100, z = 100},
		seed = 7134,
		octaves = 3,
		persist = 0.6
	},
	y_min = 15,
	y_max = 90,
	decoration = "mesecraft_baked_clay:thistle"
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "default:dirt_with_rainforest_litter"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.01,
		spread = {x = 100, y = 100, z = 100},
		seed = 7135,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = 90,
	decoration = "mesecraft_baked_clay:lazarus",
	spawn_by = "default:jungletree",
	num_spawn_by = 1
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "default:sand"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.009,
		spread = {x = 100, y = 100, z = 100},
		seed = 7136,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = 15,
	decoration = "mesecraft_baked_clay:mannagrass",
	spawn_by = "group:water",
	num_spawn_by = 1
})

