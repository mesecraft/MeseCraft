-- MeseCraft Game module: mesecraft_bucket
-- This version is forked from the Minetest Game mod "bucket".
-- See README.txt for licensing and other information.


-- Load support for game translation.
local S = minetest.get_translator("mesecraft_bucket")

-- Register the bucket craft item.
minetest.register_craft({
	output = "mesecraft_bucket:bucket_empty 1",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"", "default:steel_ingot", ""},
	}
})

-- Initialize
mesecraft_bucket = {}
mesecraft_bucket.liquids = {}

-- Protection compatibility
local function check_protection(pos, name, text)
	if minetest.is_protected(pos, name) then
		minetest.log("action", (name ~= "" and name or "A mod")
			.. " tried to " .. text
			.. " at protected position "
			.. minetest.pos_to_string(pos)
			.. " with a bucket")
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

-- Register a new liquid
--    source = name of the source node
--    flowing = name of the flowing node
--    itemname = name of the new bucket item (or nil if liquid is not takeable)
--    inventory_image = texture of the new bucket item (ignored if itemname == nil)
--    name = text description of the bucket item
--    groups = (optional) groups of the bucket item, for example {water_bucket = 1}
--    force_renew = (optional) bool. Force the liquid source to renew if it has a
--                  source neighbour, even if defined as 'liquid_renewable = false'.
--                  Needed to avoid creating holes in sloping rivers.
-- This function can be called from any mod (that depends on bucket).
function mesecraft_bucket.register_liquid(source, flowing, itemname, inventory_image, name,
		groups, force_renew)
	mesecraft_bucket.liquids[source] = {
		source = source,
		flowing = flowing,
		itemname = itemname,
		force_renew = force_renew,
	}
	mesecraft_bucket.liquids[flowing] = mesecraft_bucket.liquids[source]

	if itemname ~= nil then
		minetest.register_craftitem(itemname, {
			description = name,
			inventory_image = inventory_image,
			stack_max = 1,
			liquids_pointable = true,
			groups = groups,

			on_place = function(itemstack, user, pointed_thing)
				-- Must be pointing to node
				if pointed_thing.type ~= "node" then
					return
				end

				local node = minetest.get_node_or_nil(pointed_thing.under)
				local ndef = node and minetest.registered_nodes[node.name]

				-- Call on_rightclick if the pointed node defines it
				if ndef and ndef.on_rightclick and
						not (user and user:is_player() and
						user:get_player_control().sneak) then
					return ndef.on_rightclick(
						pointed_thing.under,
						node, user,
						itemstack)
				end

				local lpos

				-- Check if pointing to a buildable node
				if ndef and ndef.buildable_to then
					-- buildable; replace the node
					lpos = pointed_thing.under
				else
					-- not buildable to; place the liquid above
					-- check if the node above can be replaced

					lpos = pointed_thing.above
					node = minetest.get_node_or_nil(lpos)
					local above_ndef = node and minetest.registered_nodes[node.name]

					if not above_ndef or not above_ndef.buildable_to then
						-- do not remove the bucket with the liquid
						return itemstack
					end
				end

				if check_protection(lpos, user
						and user:get_player_name()
						or "", "place "..source) then
					return
				end

				minetest.set_node(lpos, {name = source})
				return ItemStack("mesecraft_bucket:bucket_empty")
			end
		})
	end
end

minetest.register_craftitem("mesecraft_bucket:bucket_empty", {
	description = S("Empty Bucket"),
	inventory_image = "mesecraft_bucket.png",
	groups = {tool = 1},
	liquids_pointable = true,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "object" then
			pointed_thing.ref:punch(user, 1.0, { full_punch_interval=1.0 }, nil)
			return user:get_wielded_item()
		elseif pointed_thing.type ~= "node" then
			-- do nothing if it's neither object nor node
			return
		end
		-- Check if pointing to a liquid source
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		local liquiddef = mesecraft_bucket.liquids[node.name]
		local item_count = user:get_wielded_item():get_count()

		-- if flowing, grab a nearby source instead
		if liquiddef ~= nil
		and node.name == liquiddef.flowing then
			local voffset = vector.offset(pos,0,1,0) 	-- start above
			local vnode = minetest.get_node(voffset)
			if vnode.name == liquiddef.source then
				pos = voffset
				node = vnode
			else
				-- check cardinal directions in random order
				local dirs = {{1,0},{0,1},{-1,0},{0,-1}}
				for i=4,2,-1 do
					j = math.random(i)
					dirs[i],dirs[j]=dirs[j],dirs[i]
				end
				for _, dir in ipairs(dirs) do
					voffset = vector.offset(pos,dir[1],0,dir[2])
					vnode = minetest.get_node(voffset)
					if vnode.name == liquiddef.source
					then 
						pos = voffset
						node = vnode
						break
					end
				end
			end
			if pos == pointed_thing.under then
				-- still unchanged, check under
				voffset = vector.offset(pos,0,-1,0)
				vnode = minetest.get_node(voffset)
				if vnode.name == liquiddef.source then
					pos = voffset
					node = vnode
				end
			end
		end

		if liquiddef ~= nil
		and liquiddef.itemname ~= nil
		and node.name == liquiddef.source then
			if check_protection(pointed_thing.under,
					user:get_player_name(),
					"take ".. node.name) 
			or check_protection(pos,
					user:get_player_name(),
					"take ".. node.name) 
			then
				return
			end

			-- default set to return filled bucket
			local giving_back = liquiddef.itemname

			-- check if holding more than 1 empty bucket
			if item_count > 1 then

				-- if space in inventory add filled bucket, otherwise drop as item
				local inv = user:get_inventory()
				if inv:room_for_item("main", {name=liquiddef.itemname}) then
					inv:add_item("main", liquiddef.itemname)
				else
					local pos = user:get_pos()
					pos.y = math.floor(pos.y + 0.5)
					minetest.add_item(pos, liquiddef.itemname)
				end

				-- set to return empty buckets minus 1
				giving_back = "mesecraft_bucket:bucket_empty "..tostring(item_count-1)

			end

			-- force_renew requires a source neighbour
			local source_neighbor = false
			if liquiddef.force_renew then
				source_neighbor =
					minetest.find_node_near(pos, 1, liquiddef.source)
			end
			if not (source_neighbor and liquiddef.force_renew) then
				minetest.add_node(pos, {name = "air"})
			end

			return ItemStack(giving_back)
		else
			-- non-liquid nodes will have their on_punch triggered
			local node_def = minetest.registered_nodes[node.name]
			if node_def then
				node_def.on_punch(pointed_thing.under, node, user, pointed_thing)
			end
			return user:get_wielded_item()
		end
	end,
})

mesecraft_bucket.register_liquid(
	"default:water_source",
	"default:water_flowing",
	"mesecraft_bucket:bucket_water",
	"mesecraft_bucket_water.png",
	S("Water Bucket"),
	{tool = 1, water_bucket = 1}
)

-- River water source is 'liquid_renewable = false' to avoid horizontal spread
-- of water sources in sloping rivers that can cause water to overflow
-- riverbanks and cause floods.
-- River water source is instead made renewable by the 'force renew' option
-- used here.

mesecraft_bucket.register_liquid(
	"default:river_water_source",
	"default:river_water_flowing",
	"mesecraft_bucket:bucket_river_water",
	"mesecraft_bucket_river_water.png",
	S("River Water Bucket"),
	{tool = 1, water_bucket = 1},
	true
)

mesecraft_bucket.register_liquid(
	"default:lava_source",
	"default:lava_flowing",
	"mesecraft_bucket:bucket_lava",
	"mesecraft_bucket_lava.png",
	S("Lava Bucket"),
	{tool = 1}
)

minetest.register_craft({
	type = "fuel",
	recipe = "mesecraft_bucket:bucket_lava",
	burntime = 60,
	replacements = {{"mesecraft_bucket:bucket_lava", "mesecraft_bucket:bucket_empty"}},
})

-- Register buckets as dungeon loot
if minetest.global_exists("dungeon_loot") then
	dungeon_loot.register({
		{name = "mesecraft_bucket:bucket_empty", chance = 0.55},
		-- water in deserts/ice or above ground, lava otherwise
		{name = "mesecraft_bucket:bucket_water", chance = 0.45,
			types = {"sandstone", "desert", "ice"}},
		{name = "mesecraft_bucket:bucket_water", chance = 0.45, y = {0, 32768},
			types = {"normal"}},
		{name = "mesecraft_bucket:bucket_lava", chance = 0.45, y = {-32768, -1},
			types = {"normal"}},
	})
end
