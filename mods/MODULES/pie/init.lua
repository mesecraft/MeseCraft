
-- check for available hunger mods
local hmod = minetest.global_exists("hunger")
local hbmod = minetest.global_exists("hbhunger")
local stmod = minetest.global_exists("stamina")

-- eat pie slice function
local replace_pie = function(node, puncher, pos)


	-- which size of pie did we hit?
	local pie = node.name:split("_")[1]
	local num = tonumber(node.name:split("_")[2])


	-- eat slice or remove whole pie
	if num == 3 then
		node.name = "air"
	elseif num < 3 then
		node.name = pie .. "_" .. (num + 1)
	end

	minetest.swap_node(pos, {name = node.name})


	-- Wuzzy's hbhunger mod
	if hbmod then

		local h = tonumber(hbhunger.hunger[puncher:get_player_name()])
--		print ("hbhunger is "..h)

		h = math.min(h + 4, 30)

		hbhunger.hunger[puncher:get_player_name()] = h

		minetest.sound_play("hbhunger_eat_generic", {
			pos = pos, gain = 0.7, max_hear_distance = 5})

	-- none of the above found? add to health instead
	else

		local h = puncher:get_hp()
--		print ("health is "..h)

		h = math.min(h + 4, 20)

		puncher:set_hp(h)
	end
end


-- register pie bits
local register_pie = function(pie, desc)

	-- full pie
	minetest.register_node("pie:" .. pie .. "_0", {
		description = desc,
		paramtype = "light",
		sunlight_propagates = false,
		tiles = {
			pie .. "_top.png", pie .. "_bottom.png", pie .. "_side.png",
			pie .. "_side.png", pie .. "_side.png", pie .. "_side.png"
		},
		-- No inventory image: the inventory shows the 3D cake made from the tiles above.
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.45, -0.5, -0.45, 0.45, 0, 0.45}},
		},

		on_punch = function(pos, node, puncher, pointed_thing)
			replace_pie(node, puncher, pos)
		end,
	})

	-- 3/4 pie
	minetest.register_node("pie:" .. pie .. "_1", {
		description = "3/4" .. desc,
		paramtype = "light",
		sunlight_propagates = true,
		tiles = {
			pie .. "_top.png", pie .. "_bottom.png", pie .. "_side.png",
			pie .. "_side.png", pie .. "_side.png", pie .. "_inside.png"
		},
		groups = {not_in_creative_inventory = 1},
		drop = {},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.45, -0.5, -0.25, 0.45, 0, 0.45}},
		},

		on_punch = function(pos, node, puncher, pointed_thing)
			replace_pie(node, puncher, pos)
		end,
	})

	-- 1/2 pie
	minetest.register_node("pie:" .. pie .. "_2", {
		description = "Half " .. desc,
		paramtype = "light",
		sunlight_propagates = true,
		tiles = {
			pie .. "_top.png", pie .. "_bottom.png", pie .. "_side.png",
			pie .. "_side.png", pie .. "_side.png", pie .. "_inside.png"
		},
		groups = {not_in_creative_inventory = 1},
		drop = {},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.45, -0.5, 0.0, 0.45, 0, 0.45}},
		},

		on_punch = function(pos, node, puncher, pointed_thing)
			replace_pie(node, puncher, pos)
		end,
	})

	-- 1/4 pie
	minetest.register_node("pie:" .. pie .. "_3", {
		description = "Piece of " .. desc,
		paramtype = "light",
		sunlight_propagates = true,
		tiles = {
			pie .. "_top.png", pie .. "_bottom.png", pie .. "_side.png",
			pie .. "_side.png", pie .. "_side.png", pie .. "_inside.png"
		},
		groups = {not_in_creative_inventory = 1},
		drop = {},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.45, -0.5, 0.25, 0.45, 0, 0.45}},
		},

		on_punch = function(pos, node, puncher, pointed_thing)
			replace_pie(node, puncher, pos)
		end,
	})

end


-- normal cake
register_pie("pie", "Cake")

minetest.register_craft({
	output = "pie:pie_0",
	recipe = {
		{"group:food_sugar", "group:food_milk", "group:food_sugar"},
		{"group:food_sugar", "group:food_egg", "group:food_sugar"},
		{"group:food_wheat", "group:food_flour", "group:food_wheat"},
	},
	replacements = {{ "mobs:bucket_milk", "mesecraft_bucket:bucket_empty"}}
})

-- chocolate cake
register_pie("choc", "Chocolate Cake")

minetest.register_craft({
	output = "pie:choc_0",
	recipe = {
		{"group:food_sugar", "group:food_milk", "group:food_sugar"},
		{"group:food_chocolate", "group:food_egg", "group:food_chocolate"},
		{"group:food_wheat", "group:food_flour", "group:food_wheat"},
	},
	replacements = {{ "mobs:bucket_milk", "mesecraft_bucket:bucket_empty"}}
})
