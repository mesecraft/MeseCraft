-- Register the recipe for the honey extractor.
  minetest.register_craft({
    output = 'bees:extractor',
    recipe = {
      {'','default:steel_ingot',''},
      {'default:steel_ingot','default:stick','default:steel_ingot'},
      {'default:mese_crystal','default:steel_ingot','default:mese_crystal'},
    }
  })
-- Register the recipe for the hive smoker.
  minetest.register_craft({
    output = 'bees:smoker',
    recipe = {
      {'default:steel_ingot', 'wool:red', ''},
      {'', 'default:torch', ''},
      {'', 'default:steel_ingot',''},
    }
  })
-- Register the recipe for artificial bee hive.
  minetest.register_craft({
    output = 'bees:hive_artificial',
    recipe = {
      {'group:wood','group:wood','group:wood'},
      {'group:wood','default:stick','group:wood'},
      {'group:wood','default:stick','group:wood'},
    }
  })
-- Register the recipe for bee hive grafting tool.
  minetest.register_craft({
    output = 'bees:grafting_tool',
    recipe = {
      {'', '', 'default:steel_ingot'},
      {'', 'default:stick', ''},
      {'', '', ''},
    }
  })
-- Register the recipe for empty hive frames.
  minetest.register_craft({
    output = 'bees:frame_empty',
    recipe = {
      {'group:wood',  'group:wood',  'group:wood'},
      {'default:stick', 'default:stick', 'default:stick'},
      {'default:stick', 'default:stick', 'default:stick'},
    }
  })
-- Register the recipe for the honeycomb block.
minetest.register_craft({
	output = "bees:honeycomb 8",
	recipe = {
		{"bees:honeycomb_block"},
	}
})
-- Register the recipe for honeycombs --> honeycomb_block.
minetest.register_craft({
	output = "bees:honeycomb_block",
	recipe = {
		{"bees:honeycomb", "bees:honeycomb", "bees:honeycomb"},
		{"bees:honeycomb", "", "bees:honeycomb"},
		{"bees:honeycomb", "bees:honeycomb", "bees:honeycomb"},
	}
})

minetest.register_craft({ 
	type = "shapeless", 
	output = "bees:honeycomb", 
	recipe = { "bees:frame_full", },
	replacements = {{"bees:frame_full", "bees:frame_empty"}}, 
})


minetest.register_craft({ 
	type = "shapeless", 
	output = "bees:wax_in_water", 
	recipe = { "mesecraft_bucket:bucket_water", "bees:honeycomb", }
})

minetest.register_craft({ 
	type = "shapeless", 
	output = "bees:wax_in_water", 
	recipe = { "mesecraft_bucket:bucket_river_water", "bees:honeycomb", }
})


minetest.register_craft({ 
	type = "cooking", 
	output = "bees:wax", 
	recipe = "bees:wax_in_water", 
	cooktime = 10.0, 
	replacements = {{"bees:wax_in_water", "mesecraft_bucket:bucket_empty"}}
})

