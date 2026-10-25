--[[
--==========================================
-- FreeGamers Candles Version -- FreeGamers.org
-- Original Candles mod by darkrose
-- Copyright (C) Lisa Milne 2013 <lisa@ltmnet.com>
-- Code: GPL version 2
-- http://www.gnu.org/licenses/>
--==========================================
--]]

screwdriver = screwdriver or {}

local candles = {}

candles.types = {
	{
		unlit = "candles:candle",
		lit = "candles:candle_lit",
		name = "Candle",
		ingot = nil,
		image = "candles_candle"
	},
	{
		unlit = "candles:candle_floor_silver",
		lit = "candles:candle_floor_silver_lit",
		name = "Silver Candle Stick",
		ingot = "moreores:silver_ingot",
		image = "candles_candle_silver"
	},
	{
		unlit = "candles:candle_floor_gold",
		lit = "candles:candle_floor_gold_lit",
		name = "Gold Candle Stick",
		ingot = "default:gold_ingot",
		image = "candles_candle_gold"
	},
	{
		unlit = "candles:candle_floor_bronze",
		lit = "candles:candle_floor_bronze_lit",
		name = "Bronze Candle Stick",
		ingot = "default:bronze_ingot",
		image = "candles_candle_bronze"
	},
	{
		unlit = "candles:candle_wall_silver",
		lit = "candles:candle_wall_silver_lit",
		name = "Silver Wall-Mount Candle",
		ingot = "moreores:silver_ingot",
		image = "candles_candle_silver"
	},
	{
		unlit = "candles:candle_wall_gold",
		lit = "candles:candle_wall_gold_lit",
		name = "Gold Wall-Mount Candle",
		ingot = "default:gold_ingot",
		image = "candles_candle_gold"
	},
	{
		unlit = "candles:candle_wall_bronze",
		lit = "candles:candle_wall_bronze_lit",
		name = "Bronze Wall-Mount Candle",
		ingot = "default:bronze_ingot",
		image = "candles_candle_bronze"
	},
	{
		unlit = "candles:candelabra_silver",
		lit = "candles:candelabra_silver_lit",
		name = "Silver Candelebra",
		ingot = "moreores:silver_ingot",
		image = "candles_candelabra_silver"
	},
	{
		unlit = "candles:candelabra_gold",
		lit = "candles:candelabra_gold_lit",
		name = "Gold Candelebra",
		ingot = "default:gold_ingot",
		image = "candles_candelabra_gold"
	},
	{
		unlit = "candles:candelabra_bronze",
		lit = "candles:candelabra_bronze_lit",
		name = "Bronze Candelebra",
		ingot = "default:bronze_ingot",
		image = "candles_candelabra_bronze"
	},
}

candles.find_lit = function(name)
	for i,n in pairs(candles.types) do
		if n.unlit == name then
			return n.lit
		end
	end
	return nil
end

candles.find_unlit = function(name)
	for i,n in pairs(candles.types) do
		if n.lit == name then
			return n.unlit
		end
	end
	return nil
end

candles.light1 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if wield and wield == "default:torch" then
		local litname = candles.find_lit(node.name)
		minetest.add_node(pos,{name=litname, param1=node.param1, param2=node.param2})
	local p1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local n1 = minetest.get_node(p1)
	if n1.name == "air" then
			minetest.add_node(p1, {name="candles:candle_flame"})
		end
		end
	end

candles.light2 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if wield and wield == "default:torch" then
		local litname = candles.find_lit(node.name)
		minetest.add_node(pos,{name=litname, param1=node.param1, param2=node.param2})
		end
	end

candles.light3 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if wield and wield == "default:torch" then
		local litname = candles.find_lit(node.name)
		minetest.add_node(pos,{name=litname, param1=node.param1, param2=node.param2})
	local p1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local n1 = minetest.get_node(p1)
	if n1.name == "air" then
			minetest.add_node(p1, {name="candles:candelabra_flame", param2 = 1})
		end
		end
	end

	candles.snuff1 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if not wield or wield ~= "default:torch" then
		local unlitname = candles.find_unlit(node.name)
		minetest.add_node(pos,{name=unlitname, param1=node.param1, param2=node.param2})

	local p1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local n1 = minetest.get_node(p1)
	if n1.name == "candles:candle_flame"then
			minetest.remove_node(p1, {name="candles:candle_flame"})
		end
	end
	end

	candles.snuff2 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if not wield or wield ~= "default:torch" then
		local unlitname = candles.find_unlit(node.name)
		minetest.add_node(pos,{name=unlitname, param1=node.param1, param2=node.param2})
		end
		end

	candles.snuff3 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if not wield or wield ~= "default:torch" then
		local unlitname = candles.find_unlit(node.name)
		minetest.add_node(pos,{name=unlitname, param1=node.param1, param2=node.param2})

	local p1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local n1 = minetest.get_node(p1)
	if n1.name == "candles:candelabra_flame"then
			minetest.remove_node(p1, {name="candles:candelabra_flame"})
		end
	end
	end

candles.create_wall = function(ctype)
	minetest.register_node(ctype.unlit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image..".png"},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1},
		on_punch = candles.light1,
		sunlight_propagates = true,
		walkable = false,
		sounds = default.node_sound_metal_defaults({
			dug = {name = "default_dig_crumbly", gain = 1.0}, 
			dig = {name = "default_dig_crumbly", gain = 0.1},
			}
		),
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
				{-0.0625, -0.1875, -0.0625, 0.0625, 0.0625, 0.0625},
				{-0.125, -0.25, -0.125, 0.125, -0.125, 0.125},
				{-0.0625, -0.3125, -0.0625, 0.375, -0.25, 0.0625},
				{0.4375, -0.4375, -0.1875, 0.5, -0.125, 0.1875},
				{0.3125, -0.375, -0.125, 0.5, -0.1875, 0.125},
				{-0.0625, 0.125, -0.0625, 0.0625, 0.5, 0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.1875, -0.5, -0.25, 0.5, 0.5, 0.25},
		},
		on_place = function(itemstack, placer, pointed_thing)
			local above = pointed_thing.above
			local under = pointed_thing.under
			local dir = {x = under.x - above.x,
				     y = under.y - above.y,
				     z = under.z - above.z}

			local wdir = minetest.dir_to_wallmounted(dir)
			local fdir = minetest.dir_to_facedir(dir)

			if wdir == 0 or wdir == 1 then
				return itemstack
			else
				fdir = fdir-1
				if fdir < 0 then
					fdir = 3
				end
				minetest.add_node(above, {name = itemstack:get_name(), param2 = fdir})
				itemstack:take_item()
				return itemstack
			end
		end
	})

	minetest.register_node(ctype.lit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image.."_lit.png"},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1, not_in_creative_inventory = 1},
		on_punch = candles.snuff1,
		sunlight_propagates = true,
		walkable = false,
		sounds = default.node_sound_metal_defaults({
			dug = {name = "default_dig_crumbly", gain = 1.0}, 
			dig = {name = "default_dig_crumbly", gain = 0.1},
			}
		),
		on_rotate = screwdriver.rotate_simple,
		drop = ctype.unlit,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
				{-0.0625, -0.1875, -0.0625, 0.0625, 0.0625, 0.0625},
				{-0.125, -0.25, -0.125, 0.125, -0.125, 0.125},
				{-0.0625, -0.3125, -0.0625, 0.375, -0.25, 0.0625},
				{0.4375, -0.4375, -0.1875, 0.5, -0.125, 0.1875},
				{0.3125, -0.375, -0.125, 0.5, -0.1875, 0.125},
				{-0.0625, 0.125, -0.0625, 0.0625, 0.5, 0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.1875, -0.5, -0.25, 0.5, 0.5, 0.25},
		},
		can_dig = function(pos,player)
			return false
		end,
	})
	minetest.register_craft({
		output = ctype.unlit,
		recipe = {
			{"","candles:candle",""},
			{"",ctype.ingot,ctype.ingot},
		}
	})
end

candles.create_floor= function(ctype)
	minetest.register_node(ctype.unlit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image..".png"},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1},
		on_punch = candles.light1,
		sunlight_propagates = true,
		walkable = false,
		sounds = default.node_sound_metal_defaults({
			dug = {name = "default_dig_crumbly", gain = 1.0}, 
			dig = {name = "default_dig_crumbly", gain = 0.1},
			}
		),
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.0625, -0.375, -0.0625, 0.0625, 0.5, 0.0625},
				{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
				{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
				{-0.125, -0.4375, -0.125, 0.125, -0.375, 0.125},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875},
			},
		},
				on_place = function(itemstack, placer, pointed_thing)
			local above = pointed_thing.above
			local under = pointed_thing.under
			local dir = {x = under.x - above.x,
				     y = under.y - above.y,
				     z = under.z - above.z}

			local wdir = minetest.dir_to_wallmounted(dir)
			local fdir = minetest.dir_to_facedir(dir)

			if wdir == 1 then
				minetest.add_node(above, {name = itemstack:get_name(), param2 = fdir})
				itemstack:take_item()
			end
			return itemstack
		end
	})

	minetest.register_node(ctype.lit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image.."_lit.png"},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1, not_in_creative_inventory = 1},
		on_punch = candles.snuff1,
		sunlight_propagates = true,
		walkable = false,
		sounds = default.node_sound_metal_defaults({
			dug = {name = "default_dig_crumbly", gain = 1.0}, 
			dig = {name = "default_dig_crumbly", gain = 0.1},
			}
		),
		on_rotate = screwdriver.rotate_simple,
		drop = ctype.unlit,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.0625, -0.375, -0.0625, 0.0625, 0.5, 0.0625},
				{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
				{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
				{-0.125, -0.4375, -0.125, 0.125, -0.375, 0.125},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875},
			},
		},
		can_dig = function(pos,player)
			return false
		end,
	})
	minetest.register_craft({
		output = ctype.unlit,
		recipe = {
			{"candles:candle"},
			{ctype.ingot},
		}
	})
end

candles.create_candelabra = function(ctype)
	minetest.register_node(ctype.unlit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image..".png"},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1},
		on_punch = candles.light3,
		sunlight_propagates = true,
		walkable = false,
		sounds = default.node_sound_metal_defaults({
			dug = {name = "default_dig_crumbly", gain = 1.0}, 
			dig = {name = "default_dig_crumbly", gain = 0.1},
			}
		),
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.0625, -0.375, -0.0625, 0.0625, 0.5, 0.0625},
				{-0.0625, 0.0625, -0.4375, 0.0625, 0.125, 0.4375},
				{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
				{-0.125, -0.4375, -0.125, 0.125, -0.375, 0.125},
				{-0.125, 0.125, 0.25, 0.125, 0.1875, 0.5},
				{-0.125, 0.125, -0.5, 0.125, 0.1875, -0.25},
				{-0.125, 0.125, -0.125, 0.125, 0.1875, 0.125},
				{-0.0625, 0.1875, 0.3125, 0.0625, 0.5, 0.4375},
				{-0.0625, 0.125, -0.4375, 0.0625, 0.5, -0.3125},
				{-0.4375, 0.0625, -0.0625, 0.4375, 0.125, 0.0625},
				{0.25, 0.125, -0.125, 0.5, 0.1875, 0.125},
				{0.3125, 0.1875, -0.0625, 0.4375, 0.5, 0.0625},
				{-0.5, 0.125, -0.125, -0.25, 0.1875, 0.125},
				{-0.4375, 0.1875, -0.0625, -0.3125, 0.5, 0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.45, -0.45, -0.45, 0.45, 0.45, 0.45},
		},
		on_place = function(itemstack, placer, pointed_thing)
			local above = pointed_thing.above
			local under = pointed_thing.under
			local dir = {x = under.x - above.x,
				     y = under.y - above.y,
				     z = under.z - above.z}

			local wdir = minetest.dir_to_wallmounted(dir)
			local fdir = minetest.dir_to_facedir(dir)

			if wdir == 1 then
				minetest.add_node(above, {name = itemstack:get_name(), param2 = fdir})
				itemstack:take_item()
			end
			return itemstack
		end
	})

	minetest.register_node(ctype.lit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image.."_lit.png"},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1, not_in_creative_inventory = 1},
		on_punch = candles.snuff3,
		sunlight_propagates = true,
		walkable = false,
		sounds = default.node_sound_metal_defaults({
			dug = {name = "default_dig_crumbly", gain = 1.0}, 
			dig = {name = "default_dig_crumbly", gain = 0.1},
			}
		),
		on_rotate = screwdriver.rotate_simple,
		drop = ctype.unlit,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.0625, -0.375, -0.0625, 0.0625, 0.5, 0.0625},
				{-0.0625, 0.0625, -0.4375, 0.0625, 0.125, 0.4375},
				{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
				{-0.125, -0.4375, -0.125, 0.125, -0.375, 0.125},
				{-0.125, 0.125, 0.25, 0.125, 0.1875, 0.5},
				{-0.125, 0.125, -0.5, 0.125, 0.1875, -0.25},
				{-0.125, 0.125, -0.125, 0.125, 0.1875, 0.125},
				{-0.0625, 0.1875, 0.3125, 0.0625, 0.5, 0.4375},
				{-0.0625, 0.125, -0.4375, 0.0625, 0.5, -0.3125},
				{-0.4375, 0.0625, -0.0625, 0.4375, 0.125, 0.0625},
				{0.25, 0.125, -0.125, 0.5, 0.1875, 0.125},
				{0.3125, 0.1875, -0.0625, 0.4375, 0.5, 0.0625},
				{-0.5, 0.125, -0.125, -0.25, 0.1875, 0.125},
				{-0.4375, 0.1875, -0.0625, -0.3125, 0.5, 0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.45, -0.45, -0.45, 0.45, 0.45, 0.45},
		},
		can_dig = function(pos,player)
			return false
		end,
	})
	minetest.register_craft({
		output = ctype.unlit,
		recipe = {
			{"candles:candle","candles:candle","candles:candle"},
			{ctype.ingot,ctype.ingot,ctype.ingot},
		}
	})
end

minetest.register_node("candles:candle", {
	description = "Candle",
	drawtype = "plantlike",
	tiles = {"candles_candle.png"},
	paramtype = "light",
	groups = {crumbly=3,oddly_breakable_by_hand=1},
	on_punch = candles.light2,
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.1875, -0.5, -0.1875, 0.1875, 0.125, 0.1875},
	},
	on_place = function(itemstack, placer, pointed_thing)
		local above = pointed_thing.above
		local under = pointed_thing.under
		local dir = {x = under.x - above.x,
			     y = under.y - above.y,
			     z = under.z - above.z}

		local wdir = minetest.dir_to_wallmounted(dir)

		if wdir == 1 then
			minetest.add_node(above, {name = "candles:candle"})
			itemstack:take_item()
		end
		return itemstack
	end
})

minetest.register_node("candles:candle_lit", {
	description = "Candle",
	drawtype = "plantlike",
	tiles = {
		{name="candles_candle_lit.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1}},
	},
	paramtype = "light",
	groups = {crumbly=3,oddly_breakable_by_hand=1, not_in_creative_inventory = 1},
	on_punch = candles.snuff2,
	sunlight_propagates = true,
	walkable = false,
	light_source = 11,
	drop = "candles:candle",
	selection_box = {
		type = "fixed",
		fixed = {-0.1875, -0.5, -0.1875, 0.1875, 0.125, 0.1875},
	},
	can_dig = function(pos,player)
		return false
	end,
})

minetest.register_node("candles:candle_flame", {
	drawtype = "plantlike",
	tiles = {
		{
			name = "candles_candle_flame.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	paramtype = "light",
	light_source = 12,
	walkable = false,
	buildable_to = false,
	pointable = false,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {torch = 1, dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "",
	can_dig = function(pos,player)
			return false
		end,
})

minetest.register_node("candles:candelabra_flame", {
	drawtype = "plantlike",
		tiles = {
		{
			name = "candles_candelabra_flame.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 1,
	light_source = 14,
	walkable = false,
	buildable_to = false,
	pointable = false,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {torch = 1, dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "",
	can_dig = function(pos,player)
		return false
	end,
	})


for i,n in pairs(candles.types) do
   if n.ingot then
		if string.find(n.unlit,"candle_wall") then
		candles.create_wall(n)
		end
		if string.find(n.unlit,"candelabra") then
		candles.create_candelabra(n)
		end
		if string.find(n.unlit,"candle_floor") then
		candles.create_floor(n)
		end
	end
end

-----------------
-- Chandelier
-----------------
minetest.register_node("candles:gold_chandelier", {
	description = "Gold Chandelier",
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {{
		name = "candles_gold_chandelier_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 2.5
		}
	}},
	wield_image = "candles_gold_chandelier.png",
	inventory_image = "candles_gold_chandelier.png",
	selection_box = {
		type = "fixed",
		fixed = {-0.375, -0.5, -0.375, 0.375, 0.5, 0.375}
	},
	walkable = false,
	groups = {dig_immediate = 2},
	light_source = 10,
	groups = {cracky = 2, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("candles:gold_chandelier_unlit", {
	description = "Unlit Gold Chandelier",
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {"candles_gold_chandelier_unlit.png"},
	selection_box = {
		type = "fixed",
		fixed = {-0.375, -0.5, -0.375, 0.375, 0.5, 0.375}
	},
	walkable = false,
	groups = {dig_immediate = 2}
})

minetest.register_craft({
	output = "candles:gold_chandelier",
	recipe = {
		{"", "default:gold_ingot", ""},
		{"default:torch", "default:gold_ingot", "default:torch"}
	}
})

minetest.register_craft({
	output = "candles:gold_chandelier_unlit",
	recipe = {
		{"candles:candle", "default:gold_ingot", "candles:candle"},
		{"", "default:gold_ingot", ""},
		{"candles:candle", "", "candles:candle"}
	}
})

------------------
-- Craft Recipes
------------------
minetest.register_craft({
	output = "candles:wax 2", --Palm Wax???   :)
	recipe = {
		{"default:jungleleaves", "default:jungleleaves", "default:jungleleaves"},
		{"default:jungleleaves", "default:jungleleaves", "default:jungleleaves"},
		{"default:jungleleaves", "default:jungleleaves", "default:jungleleaves"},
	}
})

minetest.register_craft({
	output = "candles:candle",
	recipe = {
		{"bees:wax", "farming:cotton", "bees:wax"},
	}
})
