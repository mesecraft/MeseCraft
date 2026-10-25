-- Register the empty hive frame.
  minetest.register_craftitem('bees:frame_empty', {
    description = 'Empty Hive Frame',
    inventory_image = 'bees_frame_empty.png',
    --stack_max = 24,
  })
-- Register the full hive frame.
  minetest.register_craftitem('bees:frame_full', {
    description = 'Filled Hive Frame',
    inventory_image = 'bees_frame_full.png',
    --stack_max = 12,
  })
-- Register the bottle of honey.
  minetest.register_craftitem('bees:bottle_honey', {
    description = 'Bottle of Honey',
    inventory_image = 'bees_bottle_honey.png',
    --stack_max = 12,
    on_use = minetest.item_eat(3, "vessels:glass_bottle"),
  })
-- Register Bees Wax.
  minetest.register_craftitem('bees:wax', {
    description = 'Bees Wax',
    inventory_image = 'bees_wax.png',
    --stack_max = 48,
  })
-- Register honeycomb.
  minetest.register_craftitem('bees:honeycomb', {
    description = 'Honeycomb',
    inventory_image = 'bees_honeycomb.png',
    on_use = minetest.item_eat(2),
    --stack_max = 8,
  })
-- Register Queen Bee.
  minetest.register_craftitem('bees:queen', {
    description = 'Queen Bee',
    inventory_image = 'bees_particle_bee.png',
    --stack_max = 8,
  })
  minetest.register_craftitem('bees:wax_in_water', {
    description = 'Wax in Water',
    inventory_image = 'bees_wax_in_water.png',
    stack_max = 1,
  })