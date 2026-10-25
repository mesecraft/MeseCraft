--Register Candy Cane Pickaxe
minetest.register_tool("mesecraft_christmas:pick_cane", {
	description = "Candy Cane Pickaxe",
	inventory_image = "mesecraft_christmas_tool_pick_cane.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.4, [2]=1.2, [3]=0.60}, uses=20, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
})
minetest.register_alias("mesecraft_christmas:candy_cane_pickaxe", "mesecraft_christmas:pick_cane")

--Register Candy Cane Axe
minetest.register_tool("mesecraft_christmas:axe_cane", {
	description = "Candy Cane Axe",
	inventory_image = "mesecraft_christmas_tool_axe_cane.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.20, [2]=1.00, [3]=0.60}, uses=20, maxlevel=3},
		},
		damage_groups = {fleshy=6},
	}
})
minetest.register_alias("mesecraft_christmas:candy_cane_axe", "mesecraft_christmas:axe_cane")

--Register Candy Cane Sword
minetest.register_tool("mesecraft_christmas:sword_cane", {
	description = "Candy Cane Sword",
	inventory_image = "mesecraft_christmas_tool_sword_cane.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.0, [2]=1.00, [3]=0.35}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=7},
	}
})
minetest.register_alias("mesecraft_christmas:candy_cane_sword", "mesecraft_christmas:sword_cane")

-- Add mesecraft_toolranks support
if minetest.get_modpath("mesecraft_toolranks") then
	-- Helper function
	local function add_tool(name, desc, afteruse)
		minetest.override_item(name, {
			original_description = desc,
			description = mesecraft_toolranks.create_description(desc, 0, 1),
			after_use = afteruse and mesecraft_toolranks.new_afteruse
		})
	end
	add_tool("mesecraft_christmas:pick_cane", "Candy Cane Pickaxe", true)
	add_tool("mesecraft_christmas:axe_cane", "Candy Cane Axe", true)
	add_tool("mesecraft_christmas:sword_cane", "Candy Cane Sword", true)
end
