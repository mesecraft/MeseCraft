minetest.register_craft({
	output = 'decoblocks:scarecrow',
	recipe = {
		{'', 'farming:pumpkin', ''},
		{'default:stick', 'farming:straw', 'default:stick'},
		{'', 'group:wood', ''},
	}
})

minetest.register_craft({
	output = 'decoblocks:paper_lantern',
	recipe = {
		{'group:wood', 'default:paper', 'group:wood'},
		{'default:paper', 'morelights:bulb', 'default:paper'},
		{'group:wood', 'default:paper', 'group:wood'},
	}
})

minetest.register_craft({
        output = 'decoblocks:spikes 4',
        recipe = {
                {'', '', ''},
                {'', 'default:steel_ingot', ''},
                {'', 'default:steel_ingot', ''},
        }
})

--These recipes use Ethereal's bamboo when it is installed; papyrus stands in for it otherwise.
local bamboo = minetest.get_modpath("ethereal") and "ethereal:bamboo" or "default:papyrus"

minetest.register_craft({
        output = 'decoblocks:bamboo_fence',
        recipe = {
                {'', '', ''},
                {bamboo, 'default:stick', bamboo},
                {bamboo, 'default:stick', bamboo},
        }
})
