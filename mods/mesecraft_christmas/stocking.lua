-- Stocking Stuffing Code.
-- Primarily based on GreenXenith's code from christmas_decor mod. Minor changes such as items and nodetype.
local stocking = {}
local stuffer = {}
stuffer.stuffers = {}

function stuffer.register_stuff(name, count)
	if count == nil then count = 1 end
	local stuff = {
		name = name,
		count = count,
		metadata = "",
	}
	table.insert(stuffer.stuffers, stuff)
end

function stuffer.select_stuffers(count)
	local p_stuffers = {}
	for i=1,#stuffer.stuffers do
		table.insert(p_stuffers, stuffer.stuffers[i])
	end
	local itemstacks = {}
	for i=1,#stuffer.stuffers do
		itemstacks[i] = stuffer.stuff_to_itemstack(stuffer.stuffers[i])
	end
	return itemstacks
end

function stuffer.stuff_to_itemstack(stuff)
	local itemstack = {}
	itemstack.name = stuff.name
	itemstack.count = stuffer.determine_count(stuff)
	itemstack.metadata = stuff.metadata

	return ItemStack(itemstack)
end

function stuffer.determine_count(stuff)
	if(type(stuff.count)=="number") then
		return stuff.count
	end
end

-- REGISTER STUFFERS BELOW HERE
--stuffer.register_stuff("modname:nodename", amount)
stuffer.register_stuff("default:gold_ingot", 25)
stuffer.register_stuff("mesecraft_christmas:candy_cane", 25)
stuffer.register_stuff("mesecraft_christmas:pick_cane", 1)
stuffer.register_stuff("mesecraft_christmas:axe_cane", 1)
stuffer.register_stuff("mesecraft_christmas:sword_cane", 1)
stuffer.register_stuff("mesecraft_christmas:helmet_cane", 1)
stuffer.register_stuff("mesecraft_christmas:chestplate_cane", 1)
stuffer.register_stuff("mesecraft_christmas:leggings_cane", 1)
stuffer.register_stuff("mesecraft_christmas:boots_cane", 1)
stuffer.register_stuff("mesecraft_christmas:shield_cane", 1)
stuffer.register_stuff("farming:chocolate_dark", 25)
stuffer.register_stuff("mesecraft_christmas:peppermint_candies", 25)
stuffer.register_stuff("mesecraft_christmas:green_candy_cane", 25)
stuffer.register_stuff("mesecraft_christmas:green_peppermint_candies", 25)
stuffer.register_stuff("mesecraft_christmas:sugar_cookie_tree", 25)


-- REGISTER STUFFERS ABOVE HERE
function stocking.get_stocking_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec =
		"size[9,9]"..
		"background[-0.8,-0.4;10,10;mesecraft_christmas_stocking_background.png]"..
		"image_button_exit[7.75,1;1,1;mesecraft_christmas_stocking_exit_button.png;exit;]"..
		"listcolors[#D4393C;#d45658]"..
		"list[nodemeta:".. spos .. ";main;-0.2,2;8,2;]"..
		"list[current_player;main;-0.2,5;8,4;]" ..
		"listring[current_player;main]"
	return formspec
end

stocking.can_dig_function = function(pos, player)
	local meta = minetest.get_meta(pos);
	local name = player and player:get_player_name()
	local owner = meta:get_string("owner")
	local inv = meta:get_inventory()
	return name == owner and inv:is_empty("main")
end

local days_elapsed_in_year = function(year, month, day)
	local days_elapsed_in_month = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334}
	local days_elapsed_in_leapyear_month = { 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335}

	local function is_leap_year(year)
		return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
	end

	if is_leap_year(year) then
		return (days_elapsed_in_leapyear_month[month] + (day - 1))
	else
		return (days_elapsed_in_month[month] + (day - 1))
	end
end

local date_in_seconds = function()
	local year = tonumber(os.date("%Y"))
	local month = tonumber(os.date("%m"))
	local day = tonumber(os.date("%d"))
	local second =  tonumber(os.date("%S"))
	local minute = tonumber(os.date("%M"))
	local hour = tonumber(os.date("%H"))
	return ((days_elapsed_in_year(year, month, day) * 86400) + (hour * 3600) + (minute * 60) + second)
end

local christmas_date = 30931200 --Christmas date in seconds

check_fillable = function(pos)
	local year = tonumber(os.date("%Y"))
	local meta = minetest.get_meta(pos)
	if year == meta:get_int("fill_year") then
		if date_in_seconds() > christmas_date then
			return true
		elseif date_in_seconds() <= christmas_date then
			return false
		end
	elseif year > meta:get_int("fill_year") then
		return true
	end
end,

minetest.register_node("mesecraft_christmas:stocking", {
	description = "Stocking",
	drawtype = "signlike",
	tiles = {"mesecraft_christmas_stocking.png"},
	inventory_image = "mesecraft_christmas_stocking.png",
	wield_image = "mesecraft_christmas_stocking.png",
	walkable = false,
	selection_box = {
		type = "wallmounted",
	},
	paramtype2 = "colorwallmounted",
	sunlight_propagates = true,
	groups = {snappy = 3},
	sounds = default.node_sound_leaves_defaults(),
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if player then
			minetest.chat_send_player(player:get_player_name(), "Wait until Christmas Eve for Santa to fill your stocking!")
			return 0
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.is_yes(placer:get_meta():get_string("has_placed_stocking")) then
			minetest.chat_send_player(placer:get_player_name(), "Santa won't fill more than one stocking!")
			return itemstack
		else
			return minetest.item_place(itemstack, placer, pointed_thing)
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local owner = placer:get_player_name()
		meta:set_string("owner", owner)
		meta:set_string("infotext", owner.."'s Stocking")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*2)
		placer:get_meta():set_string("has_placed_stocking", "true")
		local year = tonumber(os.date("%Y"))
		if date_in_seconds() >= christmas_date then
			meta:set_int("fill_year", year + 1)
		elseif date_in_seconds() < christmas_date then
			meta:set_int("fill_year", year)
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local player = clicker:get_player_name()
		local stuffers = stuffer.select_stuffers()
		local year = tonumber(os.date("%Y"))
		local owner  = meta:get_string("owner")
		if owner == player then
			if check_fillable(pos) == true or clicker:get_meta():get_string("needs_fill") == "true" then
				for i=1, #stuffers do
					inv:set_stack("main", i, stuffers[i])
				end
				if date_in_seconds() >= christmas_date then
					meta:set_int("fill_year", year + 1)
				elseif date_in_seconds() < christmas_date then
					meta:set_int("fill_year", year)
				end
				clicker:get_meta():set_string("needs_fill", "false")
			end
			if owner == player then
				minetest.show_formspec(
					clicker:get_player_name(),
					"default:chest_locked",
					stocking.get_stocking_formspec(pos))
			else
				return itemstack
			end
			return itemstack
		end
	end,
	can_dig = stocking.can_dig_function,
	on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in stocking at " .. minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to stocking at " .. minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from stocking at " .. minetest.pos_to_string(pos))
	end,
	on_dig = function(pos, node, digger)
		local meta = minetest.get_meta(pos)
		local inv = digger:get_inventory()
		if stocking.can_dig_function(pos, digger) then
			if minetest.is_yes(check_fillable(pos)) then
				digger:get_meta():set_string("needs_fill", "true")
			end
			digger:get_meta():set_string("has_placed_stocking", "false")
			minetest.remove_node(pos)
			inv:add_item("main", "mesecraft_christmas:stocking")
		end
	end
})
-- Green Stocking
minetest.register_node("mesecraft_christmas:green_stocking", {
	description = "Green Stocking",
	drawtype = "signlike",
	tiles = {"mesecraft_christmas_green_stocking.png"},
	inventory_image = "mesecraft_christmas_green_stocking.png",
	wield_image = "mesecraft_christmas_green_stocking.png",
	walkable = false,
	selection_box = {
		type = "wallmounted",
	},
	paramtype2 = "colorwallmounted",
	sunlight_propagates = true,
	groups = {snappy = 3},
	sounds = default.node_sound_leaves_defaults(),
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if player then
			minetest.chat_send_player(player:get_player_name(), "Wait until Christmas Eve for Santa to fill your stocking!")
			return 0
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.is_yes(placer:get_meta():get_string("has_placed_stocking")) then
			minetest.chat_send_player(placer:get_player_name(), "Santa won't fill more than one stocking!")
			return itemstack
		else
			return minetest.item_place(itemstack, placer, pointed_thing)
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local owner = placer:get_player_name()
		meta:set_string("owner", owner)
		meta:set_string("infotext", owner.."'s Stocking")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*2)
		placer:get_meta():set_string("has_placed_stocking", "true")
		local year = tonumber(os.date("%Y"))
		if date_in_seconds() >= christmas_date then
			meta:set_int("fill_year", year + 1)
		elseif date_in_seconds() < christmas_date then
			meta:set_int("fill_year", year)
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local player = clicker:get_player_name()
		local stuffers = stuffer.select_stuffers()
		local year = tonumber(os.date("%Y"))
		local owner  = meta:get_string("owner")
		if owner == player then
			if check_fillable(pos) == true or clicker:get_meta():get_string("needs_fill") == "true" then
				for i=1, #stuffers do
					inv:set_stack("main", i, stuffers[i])
				end
				if date_in_seconds() >= christmas_date then
					meta:set_int("fill_year", year + 1)
				elseif date_in_seconds() < christmas_date then
					meta:set_int("fill_year", year)
				end
				clicker:get_meta():set_string("needs_fill", "false")
			end
			if owner == player then
				minetest.show_formspec(
					clicker:get_player_name(),
					"default:chest_locked",
					stocking.get_stocking_formspec(pos))
			else
				return itemstack
			end
			return itemstack
		end
	end,
	can_dig = stocking.can_dig_function,
	on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in stocking at " .. minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to stocking at " .. minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from stocking at " .. minetest.pos_to_string(pos))
	end,
	on_dig = function(pos, node, digger)
		local meta = minetest.get_meta(pos)
		local inv = digger:get_inventory()
		if stocking.can_dig_function(pos, digger) then
			if minetest.is_yes(check_fillable(pos)) then
				digger:get_meta():set_string("needs_fill", "true")
			end
			digger:get_meta():set_string("has_placed_stocking", "false")
			minetest.remove_node(pos)
			inv:add_item("main", "mesecraft_christmas:green_stocking")
		end
	end
})

-- Crafts
--minetest.register_craft({
--	output = "christmas_decor:stocking",
--	recipe = {
--		{"", "wool:white", "wool:white"},
--		{"", "wool:red", "wool:red"},
--		{"wool:red", "wool:red", "wool:red"},
--	}
--})
