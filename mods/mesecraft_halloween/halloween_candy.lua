--[[ Candy ]]--

-- Candy base
minetest.register_craftitem("mesecraft_halloween:caramelized_sugar", {
    description = "Caramelized Sugar",
    inventory_image = "mesecraft_halloween_items_caramelized_sugar.png",
})

minetest.register_craft({
    type = "cooking",
    output = "mesecraft_halloween:caramelized_sugar",
    recipe = "farming:sugar",
    cooktime = 14,
})

-- Candies
minetest.register_craftitem("mesecraft_halloween:candycorn", {
    description = "Candycorn",
    inventory_image = "mesecraft_halloween_items_candycorn.png",
    on_use = minetest.item_eat(3),
})

minetest.register_craft({
    type = "shapeless",
    output = "mesecraft_halloween:candycorn 3",
    recipe = {"mesecraft_halloween:caramelized_sugar", "dye:orange", "dye:yellow", "dye:white"},
})

minetest.register_craftitem("mesecraft_halloween:halloween_chocolate", {
    description = "Halloween Chocolate",
    inventory_image = "mesecraft_halloween_items_chocolate.png",
    on_use = minetest.item_eat(5),
})

minetest.register_craft({
    type = "shapeless",
    output = "mesecraft_halloween:halloween_chocolate",
    recipe = {"mesecraft_halloween:caramelized_sugar", "farming:chocolate_dark", "dye:orange", "default:paper"},
})

minetest.register_craftitem("mesecraft_halloween:lolipop", {
	description = "Lolipop",
	inventory_image = "mesecraft_halloween_items_lolipop.png",
	on_use = minetest.item_eat(2),
})

minetest.register_craft({
	output = "mesecraft_halloween:lolipop 2",
	recipe = {
		{"", "dye:orange", ""},
		{"default:paper", "mesecraft_halloween:caramelized_sugar", "default:paper"},
		{"", "default:stick", ""},
	},
})

minetest.register_craftitem("mesecraft_halloween:caramel_apple", {
	description = "Caramel Apple",
	inventory_image = "mesecraft_halloween_items_caramel_apple.png",
	on_use = minetest.item_eat(4),
})

minetest.register_craft({
	output = "mesecraft_halloween:caramel_apple",
	recipe = {
		{"mesecraft_halloween:caramelized_sugar"},
		{"default:apple"},
		{ "default:stick",},
	},
})
