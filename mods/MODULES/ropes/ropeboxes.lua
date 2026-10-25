-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

local function rope_box_tiles(count, tint)
	return {
		string.format("ropes_ropebox_front_%i.png^[colorize:%s^ropes_ropebox_front_%i.png^ropes_%i.png", count, tint, count, count),
		string.format("ropes_ropebox_front_%i.png^[colorize:%s^ropes_ropebox_front_%i.png^ropes_%i.png", count, tint, count, count),
		string.format("ropes_ropebox_side.png^[colorize:%s^ropes_ropebox_side.png", tint),
		string.format("ropes_ropebox_side.png^[colorize:%s^ropes_ropebox_side.png", tint),
		string.format("ropes_ropebox_front_%i.png^[colorize:%s^ropes_ropebox_front_%i.png^ropes_%i.png", count, tint, count, count),
		string.format("ropes_ropebox_front_%i.png^[colorize:%s^ropes_ropebox_front_%i.png^ropes_%i.png", count, tint, count, count),
	}
end

local rope_box_data = {
{
	node={
		{-0.125, -0.125, -0.25, 0.125, 0.125, 0.25}, -- pulley
		{-0.125, -0.25, -0.125, 0.125, 0.25, 0.125}, -- pulley
		{-0.125, -0.1875, -0.1875, 0.125, 0.1875, 0.1875}, -- pulley_core
		{-0.1875, -0.5, -0.125, -0.125, 0.125, 0.125}, -- support
		{0.125, -0.5, -0.125, 0.1875, 0.125, 0.125}, -- support
	},
	--selection = {-0.1875, -0.5, -0.25, 0.1875, 0.25, 0.25}, -- selection
	tiles = 1,
},
{	
	node={
		{-0.1875, -0.125, -0.25, 0.1875, 0.125, 0.25}, -- pulley
		{-0.1875, -0.25, -0.125, 0.1875, 0.25, 0.125}, -- pulley
		{-0.1875, -0.1875, -0.1875, 0.1875, 0.1875, 0.1875}, -- pulley_core
		{-0.25, -0.5, -0.125, -0.1875, 0.125, 0.125}, -- support
		{0.1875, -0.5, -0.125, 0.25, 0.125, 0.125}, -- support
	},
	--selection = {-0.1875, -0.5, -0.25, 0.1875, 0.25, 0.25}, -- selection
	tiles = 2,
},
{	
	node={
		{-0.25, -0.125, -0.25, 0.25, 0.125, 0.25}, -- pulley
		{-0.25, -0.25, -0.125, 0.25, 0.25, 0.125}, -- pulley
		{-0.25, -0.1875, -0.1875, 0.25, 0.1875, 0.1875}, -- pulley_core
		{-0.3125, -0.5, -0.125, -0.25, 0.125, 0.125}, -- support
		{0.25, -0.5, -0.125, 0.3125, 0.125, 0.125}, -- support
	},
	--selection = {-0.3125, -0.5, -0.25, 0.3125, 0.25, 0.25}, -- selection
	tiles = 3,
},
{	
	node={
		{-0.3125, -0.125, -0.25, 0.3125, 0.125, 0.25}, -- pulley
		{-0.3125, -0.25, -0.125, 0.3125, 0.25, 0.125}, -- pulley
		{-0.3125, -0.1875, -0.1875, 0.3125, 0.1875, 0.1875}, -- pulley_core
		{-0.375, -0.5, -0.125, -0.3125, 0.125, 0.125}, -- support
		{0.3125, -0.5, -0.125, 0.375, 0.125, 0.125}, -- support
	},
	--selection = {-0.375, -0.5, -0.25, 0.375, 0.25, 0.25}, -- selection
	tiles = 4,
},
{	
	node={
		{-0.375, -0.125, -0.25, 0.375, 0.125, 0.25}, -- pulley
		{-0.375, -0.25, -0.125, 0.375, 0.25, 0.125}, -- pulley
		{-0.375, -0.1875, -0.1875, 0.375, 0.1875, 0.1875}, -- pulley_core
		{-0.4375, -0.5, -0.125, -0.375, 0.125, 0.125}, -- support
		{0.375, -0.5, -0.125, 0.4375, 0.125, 0.125}, -- support
	},
	--selection = {-0.4375, -0.5, -0.25, 0.4375, 0.25, 0.25}, -- selection
	tiles = 5,
},
{
	node={
		{-0.1875, -0.1875, -0.3125, 0.1875, 0.1875, 0.3125}, -- pulley
		{-0.1875, -0.3125, -0.1875, 0.1875, 0.3125, 0.1875}, -- pulley
		{-0.1875, -0.25, -0.25, 0.1875, 0.25, 0.25}, -- pulley_core
		{-0.25, -0.5, -0.125, -0.1875, 0.125, 0.125}, -- support
		{0.1875, -0.5, -0.125, 0.25, 0.125, 0.125}, -- support
	},
	--selection = {-0.1875, -0.5, -0.3125, 0.1875, 0.3125, 0.3125}, -- selection
	tiles = 2,
},
{	
	node={
		{-0.25, -0.1875, -0.3125, 0.25, 0.1875, 0.3125}, -- pulley
		{-0.25, -0.3125, -0.1875, 0.25, 0.3125, 0.1875}, -- pulley
		{-0.25, -0.25, -0.25, 0.25, 0.25, 0.25}, -- pulley_core
		{-0.3125, -0.5, -0.125, -0.25, 0.125, 0.125}, -- support
		{0.25, -0.5, -0.125, 0.3125, 0.125, 0.125}, -- support
	},
	--selection = {-0.3125, -0.5, -0.3125, 0.3125, 0.3125, 0.3125}, -- selection
	tiles = 3,
},
{	
	node={
		{-0.3125, -0.1875, -0.3125, 0.3125, 0.1875, 0.3125}, -- pulley
		{-0.3125, -0.3125, -0.1875, 0.3125, 0.3125, 0.1875}, -- pulley
		{-0.3125, -0.25, -0.25, 0.3125, 0.25, 0.25}, -- pulley_core
		{-0.375, -0.5, -0.125, -0.3125, 0.125, 0.125}, -- support
		{0.3125, -0.5, -0.125, 0.375, 0.125, 0.125}, -- support
	},
	--selection = {-0.375, -0.5, -0.3125, 0.375, 0.3125, 0.3125}, -- selection
	tiles = 4,
},
{	
	node={
		{-0.375, -0.1875, -0.3125, 0.375, 0.1875, 0.3125}, -- pulley
		{-0.375, -0.3125, -0.1875, 0.375, 0.3125, 0.1875}, -- pulley
		{-0.375, -0.25, -0.25, 0.375, 0.25, 0.25}, -- pulley_core
		{-0.4375, -0.5, -0.125, -0.375, 0.125, 0.125}, -- support
		{0.375, -0.5, -0.125, 0.4375, 0.125, 0.125}, -- support
	},
	--selection_bottom = {-0.4375, -0.5, -0.3125, 0.4375, 0.3125, 0.3125}, -- selection
	tiles = 5,
}
}

local function register_rope_block(multiple, max_multiple, name_prefix, node_prefix, tint, flammable)
	local node_name = string.format("ropes:%s%irope_block", node_prefix, multiple)
	local rope_block_def = {
		description = S("@1 Ropebox @2m", name_prefix, ropes.ropeLength*multiple),
		_doc_items_create_entry = false,
		drawtype="nodebox",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "wallmounted",
		walkable = false,
		climbable = true,
		tiles = rope_box_tiles(rope_box_data[multiple].tiles, tint),
		node_box = {
			type = "fixed",
			fixed = rope_box_data[multiple].node
		},
		selection_box = {
			type = "fixed",
			fixed = rope_box_data[multiple].node
		},
		collision_box = {type="regular"},
		groups = {choppy=2, oddly_breakable_by_hand=1, rope_block = 1},
		
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type == "node" then
				local target_node = minetest.get_node(pointed_thing.under)
				local target_def = minetest.registered_nodes[target_node.name]
				if target_def.walkable == false then
					return itemstack
				end
			end
			return minetest.item_place(itemstack, placer, pointed_thing)
		end,
	
		after_place_node = function(pos, placer)
			local pos_below = {x=pos.x, y=pos.y-1, z=pos.z}
			local placer_name = placer:get_player_name()
			
			if minetest.is_protected(pos_below, placer_name) and not minetest.check_player_privs(placer, "protection_bypass") then
				return
			end
		
			local node_below = minetest.get_node(pos_below)
			if node_below.name == "air" then
				minetest.add_node(pos_below, {name="ropes:rope_bottom"})
				local meta = minetest.get_meta(pos_below)
				meta:set_int("length_remaining", ropes.ropeLength*multiple)
				meta:set_string("placer", placer:get_player_name())
			end
		end,
		
		after_destruct = function(pos)
			local pos_below = {x=pos.x, y=pos.y-1, z=pos.z}
			ropes.destroy_rope(pos_below, {'ropes:rope', 'ropes:rope_bottom'})
		end
	}	
	
	-- If this number is higher than permitted, we still want to register the block (in case
	-- some were already placed in-world) but we want to hide it from creative inventory
	-- and if someone digs it we want to disintegrate it into its component parts to prevent
	-- reuse.
	if multiple > max_multiple then
		rope_block_def.groups.not_in_creative_inventory = 1
		rope_block_def.drop = string.format("ropes:%s1rope_block %i", node_prefix, multiple)
	end
	
	if flammable then
		rope_block_def.groups.flammable = flammable
		
		minetest.register_craft({
			type = "fuel",
			recipe = node_name,
			burntime = ropes.rope_burn_time * multiple + ropes.wood_burn_time,
		})
	end
	
	minetest.register_node(node_name, rope_block_def)
	
	if (multiple ~= 1) then
		-- Only register a recipe to craft this if it's within the permitted multiple range
		if multiple <= max_multiple then
			for i = 1, multiple-1 do
				local rec = {string.format("ropes:%s%irope_block", node_prefix, i)}
				for n = 1, multiple-i do
					table.insert(rec, "ropes:ropesegment")
				end
				minetest.register_craft({
					output = node_name,
					type = "shapeless",
					recipe = rec
				})
			end
		end
	
		-- Always allow players to disintegrate this into component parts, in case
		-- there were some in inventory and the setting was changed.
		minetest.register_craft({
			output = "ropes:ropesegment",
			type = "shapeless",
			recipe =  {
				node_name
			},
			replacements = {
				{node_name, string.format('ropes:%s%irope_block', node_prefix, multiple-1)},
			},
		})
	end
	
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", "ropes:rope", "nodes", node_name)
	end
end

local rope_def = {
	description = S("Rope"),
	_doc_items_longdesc = ropes.doc.ropebox_longdesc,
    _doc_items_usagehelp = ropes.doc.ropebox_usage,
	walkable = false,
	climbable = true,
	sunlight_propagates = true,
	paramtype = "light",
	drop = "",
	tiles = { "ropes_3.png", "ropes_3.png", "ropes_3.png", "ropes_3.png", "ropes_5.png", "ropes_5.png" },
	groups = {choppy=2, flammable=2, not_in_creative_inventory=1},
	sounds = {
            footstep = {name = "ropes_creak", gain = 0.8, max_hear_distance = 6},
            dig = "__group",
            dug = "__group",
	},
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {-1/16, -1/2, -1/16, 1/16, 1/2, 1/16},
		connect_top = {-1/16, 1/2, -1/16, 1/16, 3/4, 1/16}
	},
	connects_to = {"group:rope_block"},
	connect_sides = {"top"},
	selection_box = {
		type = "fixed",
		fixed = {-1/16, -1/2, -1/16, 1/16, 1/2, 1/16},
	},
  	after_destruct = function(pos)
		ropes.hanging_after_destruct(pos, "ropes:rope_top", "ropes:rope", "ropes:rope_bottom")
	end,
}

local rope_extension_timer = ropes.make_rope_on_timer("ropes:rope")

local rope_bottom_def = {
	description = S("Rope"),
	_doc_items_create_entry = false,
	walkable = false,
	climbable = true,
	sunlight_propagates = true,
	paramtype = "light",
	drop = "",
	tiles = { "ropes_3.png", "ropes_3.png", "ropes_3.png", "ropes_3.png", "ropes_5.png", "ropes_5.png" },
	drawtype = "nodebox",
	groups = {choppy=2, flammable=2, not_in_creative_inventory=1},
	sounds = {
            footstep = {name = "ropes_creak", gain = 0.8, max_hear_distance = 6},
            dig = "__group",
            dug = "__group",
	},
	node_box = {
		type = "connected",
		fixed = {
			{-1/16, -3/8, -1/16, 1/16, 1/2, 1/16},
			{-2/16, -5/16, -2/16, 2/16, -1/16, 2/16},
		},
		connect_top = {-1/16, 1/2, -1/16, 1/16, 3/4, 1/16}
	},
	connects_to = {"group:rope_block"},
	connect_sides = {"top"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1/16, -3/8, -1/16, 1/16, 1/2, 1/16},
			{-2/16, -5/16, -2/16, 2/16, -1/16, 2/16},
		},

	},
	
	on_construct = function( pos )
		local timer = minetest.get_node_timer( pos )
		timer:start( 1 )
	end,
	
	on_timer = rope_extension_timer,
	
    after_destruct = function(pos)
		ropes.hanging_after_destruct(pos, "ropes:rope_top", "ropes:rope", "ropes:rope_bottom")
	end,
}

minetest.register_node("ropes:rope", rope_def)
minetest.register_node("ropes:rope_bottom", rope_bottom_def)

if ropes.woodRopeBoxMaxMultiple > 0 or ropes.create_all_definitions then
	if ropes.woodRopeBoxMaxMultiple > 0 then
		minetest.register_craft({
			output = "ropes:wood1rope_block",
			recipe =  {
				{'group:wood'},
				{'group:vines'}
			}
		})
	end
	for i = 1,9 do
		if ropes.woodRopeBoxMaxMultiple >= i or ropes.create_all_definitions then
			register_rope_block(i, ropes.woodRopeBoxMaxMultiple, S("Wood"), "wood", "#86683a", 2)
		end
	end
end

if ropes.copperRopeBoxMaxMultiple > 0 or ropes.create_all_definitions then
	if ropes.copperRopeBoxMaxMultiple > 0 then
		minetest.register_craft({
			output = "ropes:copper1rope_block",
			recipe =  {
				{'default:copper_ingot'},
				{'group:vines'}
			}
		})
	end
	for i = 1,9 do
		if ropes.copperRopeBoxMaxMultiple >= i or ropes.create_all_definitions then
			register_rope_block(i, ropes.copperRopeBoxMaxMultiple, S("Copper"), "copper", "#c88648")
		end
	end
end

if ropes.steelRopeBoxMaxMultiple > 0 or ropes.create_all_definitions then
	if ropes.steelRopeBoxMaxMultiple > 0 then
		minetest.register_craft({
			output = "ropes:steel1rope_block",
			recipe =  {
				{'default:steel_ingot'},
				{'group:vines'}
			}
		})
	end
	for i = 1,9 do
		if ropes.steelRopeBoxMaxMultiple >= i or ropes.create_all_definitions then
			register_rope_block(i, ropes.steelRopeBoxMaxMultiple, S("Steel"), "steel", "#ffffff")
		end
	end
end
