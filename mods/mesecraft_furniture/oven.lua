local S = mesecraft_furniture.intllib

--Oven with recipe API--
local oven_fs = "size[8,7]"
    .."image[3.5,1.5;1,1;default_furnace_fire_bg.png]"
    .."list[current_player;main;0,3;8,4;]"
    .."list[context;input;2,1.5;1,1;]"
    .."list[context;output;5,1.5;1,1;]"
    .."label[3,0.5;"..S("Oven").."]"
    .."label[1.5,1;"..S("Uncooked Food").."]"
    .."label[4.5,1;"..S("Cooked Food").."]"
    .."listring[context;output]"
    .."listring[current_player;main]"
    .."listring[context;input]"
    .."listring[current_player;main]"

local function get_active_oven_fs(item_percent)
    return "size[8,7]"
	    .."image[3.5,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"
	    ..(item_percent)..":default_furnace_fire_fg.png]"
        .."list[current_player;main;0,3;8,4;]"
        .."list[context;input;2,1.5;1,1;]"
        .."list[context;output;5,1.5;1,1;]"
        .."label[3,0.5;"..S("Oven").."]"
        .."label[1.5,1;"..S("Uncooked Food").."]"
        .."label[4.5,1;"..S("Cooked Food").."]"
        .."listring[context;output]"
        .."listring[current_player;main]"
        .."listring[context;input]"
        .."listring[current_player;main]"
end

--x,y;w,h

-- Adding recipe API so we don't end up hardcoding items
mesecraft_furniture.oven = {}
local oven = mesecraft_furniture.oven
oven.recipes = {}
function oven.register_recipe(input, output) oven.recipes[input] = output end

local function update_formspec(progress, goal, meta)
    local formspec

    if progress > 0 and progress <= goal then
        local item_percent = math.floor(progress / goal * 100)
        formspec = get_active_oven_fs(item_percent)
    else
        formspec = oven_fs
    end

    meta:set_string("formspec", formspec)
end

local function recalculate(pos)
	local meta, timer = minetest.get_meta(pos), minetest.get_node_timer(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack("input", 1)

	local k = oven.recipes[stack:get_name()]
	if not k then return end

	timer:stop()
    update_formspec(0, 3, meta)
    timer:start(1)
end

local function do_cook_single(pos)
    local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local food_uncooked = inv:get_stack("input", 1)
    food_uncooked:set_count(1)

    --If the uncooked food wasn't removed mid-cooking, then cook it.
    if not oven.recipes[food_uncooked:get_name()] then
        -- Oven cooked nothing because there was nothing to cook
        minetest.get_node_timer(pos):stop()
        update_formspec(0, 3, meta)
    else
        inv:remove_item("input", food_uncooked) -- Clear the slot
	    local food_cooked = oven.recipes[food_uncooked:get_name()] -- Get the cooked food
	    inv:add_item("output", food_cooked) -- Put the cooked food in the slot
    end
end

minetest.register_node("mesecraft_furniture:oven", {
	description = S("Oven"),
	tiles = {
		"mesecraft_furniture_oven_top.png",
		"mesecraft_furniture_oven_bottom.png",
		"mesecraft_furniture_oven_right.png",
		"mesecraft_furniture_oven_left.png",
		"mesecraft_furniture_oven_back.png",
		"mesecraft_furniture_oven_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky = 2, tubedevice = 1, tubedevice_receiver = 1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.375, 0.5, 0.3125, 0.5},
			{-0.4375, -0.4375, -0.4375, 0.4375, 0.25, -0.375},
			{-0.375, 0.125, -0.5, 0.375, 0.1875, -0.375},
		},
	},
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("input") and inv:is_empty("output")
	end,

	on_timer = function(pos, elapsed)
        local meta = minetest.get_meta(pos)
        local stack = meta:get_inventory():get_stack("input", 1)
        local cooking_time = meta:get_int("cooking_time") or 0
        cooking_time = cooking_time + 1
        
        if cooking_time % 3 == 0 then
            do_cook_single(pos)
        end

        update_formspec(cooking_time % 3, 3, meta)
        meta:set_int("cooking_time", cooking_time)

        --Keep cooking until there is nothing left to cook.
        if not stack:is_empty() then
            return true
        else
            meta:set_int("cooking_time", 0)
            update_formspec(0, 3, meta)
            return false
        end
	end,

	on_metadata_inventory_put = recalculate,
	on_metadata_inventory_take = recalculate,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", oven_fs)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 1)
	end,
	
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "input", drops)
		default.get_inventory_drops(pos, "output", drops)
		table.insert(drops, "mesecraft_furniture:oven")
		minetest.remove_node(pos)
		return drops
	end,

	allow_metadata_inventory_put = function(pos, list, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return (list == "input" and oven.recipes[stack:get_name()]) and stack:get_count() or 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return stack:get_count()
	end,
})

minetest.register_craft({
	output = 'mesecraft_furniture:oven',
	recipe = {
	{'default:steel_ingot','default:mese','default:steel_ingot',},
	{'default:steel_ingot','default:furnace','default:steel_ingot',},
	{'default:steel_ingot','default:mese','default:steel_ingot',},
	}
})

minetest.register_node("mesecraft_furniture:oven_overhead", {
	description= S("Oven Overhead"),
	tiles = {
		"mesecraft_furniture_camp_top.png",
		"mesecraft_furniture_camp_bottom.png",
		"mesecraft_furniture_camp_left.png",
		"mesecraft_furniture_camp_right.png",
		"mesecraft_furniture_camp_back.png",
		"mesecraft_furniture_camp_front.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, furniture = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, 0.4375, -0.4375, 0.4375, 0.5, 0.4375}, 
			{-0.5, 0.25, -0.5, 0.5, 0.4375, 0.5}, 
		}
	}
})

minetest.register_craft({
	output = 'mesecraft_furniture:oven_overhead',
	recipe = {
	{'default:steel_ingot','default:mese_crystal_fragment','default:steel_ingot',},
	{'','','',},
	{'','','',},
	}
})

-- Recipe Registration
oven.register_recipe("default:ice", "default:water_source")
-- No milk bucket as this doesn't support substitutes for now
oven.register_recipe("mesecraft_mobs:chicken_raw", "mesecraft_mobs:chicken_cooked")
oven.register_recipe("mesecraft_mobs:meat", "mesecraft_mobs:meat_cooked")
oven.register_recipe("mesecraft_mobs:pork_raw", "mesecraft_mobs:pork_cooked")
oven.register_recipe("mesecraft_mobs:mutton_raw", "mesecraft_mobs:mutton_cooked")
oven.register_recipe("farming:coffee_cup", "farming:coffee_cup_hot") -- What a crutch there was...

-- Added for MeseCraft
oven.register_recipe("mesecraft_mobs:meat", "mobs_creauters:meat_cooked")
oven.register_recipe("mesecraft_mobs:pork_raw", "mesecraft_mobs:pork_cooked")
oven.register_recipe("mesecraft_mobs:mutton_raw", "mesecraft_mobs:mutton_cooked")
oven.register_recipe("mesecraft_mobs:rabbit_raw", "mesecraft_mobs:rabbit_cooked")
oven.register_recipe("mesecraft_mobs:chicken_raw", "mesecraft_mobs:chicken_cooked")
oven.register_recipe("mesecraft_mobs:snapper_raw", "mesecraft_mobs:snapper_cooked")
oven.register_recipe("mesecraft_mobs:salmon_raw", "mesecraft_mobs:salmon_cooked")
oven.register_recipe("mesecraft_mobs:clownfish_raw", "mesecraft_mobs:clownfish_cooked")
oven.register_recipe("mesecraft_mobs:cod_raw", "mesecraft_mobs:cod_cooked")
oven.register_recipe("farming:flour", "farming:bread")
oven.register_recipe("farming:rice_flour", "farming:rice_bread")
oven.register_recipe("farming:flour_multigrain", "farming:bread_multigrain")
oven.register_recipe("df_farming:cave_flour", "df_farming:cave_bread")
oven.register_recipe("christmas_holiday_pack:gingerbread_dough", "christmas_holiday_pack:gingerbread")
oven.register_recipe("farming:pumpkin_dough", "farming:pumpkin_bread")
oven.register_recipe("default:clay_lump", "default:clay_brick")
oven.register_recipe("default:clay", "mesecraft_baked_clay:natural")
oven.register_recipe("farming:corn", "farming:corn_cob")
oven.register_recipe("farming:potato", "farming:baked_potato")

-- Add needed recipes as you go, note that other mods can add more recipes too
