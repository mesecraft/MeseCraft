mesecraft_diet = {
	players = {}
}

function mesecraft_diet.__init()
	local file = io.open(minetest.get_worldpath().."/mesecraft_diet.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			mesecraft_diet.players = table.players
			return
		end
	end
end

function mesecraft_diet.save()
	local file = io.open(minetest.get_worldpath().."/mesecraft_diet.txt", "w")
	if file then
		file:write(minetest.serialize({
			players = mesecraft_diet.players
		}))
		file:close()
	end
end

-- Poison player
local function poisenp(tick, time, time_left, player)
	time_left = time_left + tick
	if time_left < time then
		minetest.after(tick, poisenp, tick, time, time_left, player)
	else
		--reset hud image
	end
	if player:get_hp()-1 > 0 then
		player:set_hp(player:get_hp()-1)
	end

end

function mesecraft_diet.item_eat(max, replace_with_item, poisen, heal)
	return function(itemstack, user, pointed_thing)

		-- Process player data
		local name = user:get_player_name()
		local player = mesecraft_diet.__player(name)
		local item = itemstack:get_name()

		-- Get type
		local ftype = ""
		if (minetest.registered_items[item] and minetest.registered_items[item].groups) then
			local groups = minetest.registered_items[item].groups
			if groups.food_type_meal then
				ftype = "meal"
			elseif groups.food_type_snack then
				ftype = "snack"
			elseif groups.food_type_dessert then
				ftype = "dessert"
			elseif groups.food_type_drink then
				ftype = "drink"
			end
		end

		-- Calculate points
		local points = max
		if (#player.eaten>0) then
			local same_food = 0
			local same_type = 0
			for _,v in pairs(player.eaten) do
				if v[1] == item then
					same_food = same_food + 1
				end
				if v[2] == ftype then
					same_type = same_type + 1
				end
			end
			local mult = same_food/10
			points = points * 1-mult
	 
			if (mult > 0.9) then
				local desc = item
				if (minetest.registered_items[item] and minetest.registered_items[item].description) then
					desc = minetest.registered_items[item].description
				end
				minetest.chat_send_player(name,"Your stomach hates "..desc)
			elseif (mult > 0.4) then
				minetest.chat_send_player(name,"Your stomach could do with a change.")
			end
			if points > max then
				error("[DIET] This shouldn't happen! points > max")
				return
			end
		end

		-- Increase health
		if minetest.get_modpath("hbhunger") and hbhunger then
			minetest.sound_play({name = "hbhunger_eat_generic", gain = 1}, {pos=user:get_pos(), max_hear_distance = 16})

			-- saturation
			local h = tonumber(hbhunger.hunger[name])
			h = h + points
			if h > 30 then h = 30 end
			hbhunger.hunger[name] = h
			hbhunger.set_hunger_raw(user)

			-- healing
			local hp = user:get_hp()
			if hp < 20 and heal then
				hp = hp + heal
				if hp > 20 then hp = 20 end
				user:set_hp(hp)
			end

			 -- Poison
			if poisen then
				--set hud-img
				poisenp(1.0, poisen, 0, user)
			end
	 
		else
			local hp = user:get_hp()		
			if (hp+points > 20) then
				hp = 20
			else
				hp = hp + points
			end		
			user:set_hp(hp)
		end

		-- Register
		mesecraft_diet.__register_eat(player,item,ftype)

		mesecraft_diet.save()

		-- Remove item
		itemstack:add_item(replace_with_item)
		itemstack:take_item()
		return itemstack
	end
end	

function mesecraft_diet.__player(name)
	if name == "" then
		return nil
	end
	if mesecraft_diet.players[name] then
		return mesecraft_diet.players[name]
	end
	
	mesecraft_diet.players[name] = {
		name = name,
		eaten = {}
	}
	mesecraft_diet.save()
	return mesecraft_diet.players[name]
end

function mesecraft_diet.__register_eat(player,food,type)
	table.insert(player.eaten,{food,type})
	
	while (#player.eaten > 10) do
		table.remove(player.eaten,1)
	end
end

local function overwrite(name, hunger_change, replace_with_item, poisen, heal)
	local tab = minetest.registered_items[name]
	if not tab then
		return
	end
	tab.on_use = mesecraft_diet.item_eat(hunger_change, replace_with_item, poisen, heal)
end

mesecraft_diet.__init()

overwrite("default:apple", 2)
if minetest.get_modpath("farming") ~= nil then
	overwrite("farming:bread", 4)
end

if minetest.get_modpath("mobs") ~= nil then
	if mobs.mod ~= nil and mobs.mod == "redo" then
		overwrite("mobs:cheese", 4)
		overwrite("mesecraft_mobs:meat", 4)
		overwrite("mobs:rat_cooked", 4)
		overwrite("mobs:honey", 2)
		overwrite("mobs:pork_raw", 3, "", 3)
		overwrite("mobs:pork_cooked", 8)
		overwrite("mobs:chicken_cooked", 6)
		overwrite("mobs:chicken_raw", 2, "", 3)
		overwrite("mobs:chicken_egg_fried", 2)
		if minetest.get_modpath("mesecraft_bucket") then 
			overwrite("mobs:bucket_milk", 3, "mesecraft_bucket:bucket_empty")
		end
	end
end

if minetest.get_modpath("farming") and farming.mod == "redo" then
   overwrite("farming:bread", 6)
   overwrite("farming:potato", 1)
   overwrite("farming:baked_potato", 6)
   overwrite("farming:cucumber", 4)
   overwrite("farming:tomato", 4)
   overwrite("farming:carrot", 3)
   overwrite("farming:carrot_gold", 6, "", nil, 8)
   overwrite("farming:corn", 3)
   overwrite("farming:corn_cob", 5)
   overwrite("farming:melon_slice", 2)
   overwrite("farming:pumpkin_slice", 1)
   overwrite("farming:pumpkin_bread", 9)
   overwrite("farming:coffee_cup", 2, "farming:drinking_cup")
   overwrite("farming:coffee_cup_hot", 3, "farming:drinking_cup", nil, 2)
   overwrite("farming:cookie", 2)
   overwrite("farming:chocolate_dark", 3)
   overwrite("farming:donut", 4)
   overwrite("farming:donut_chocolate", 6)
   overwrite("farming:donut_apple", 6)
   overwrite("farming:raspberries", 1)
   overwrite("farming:blueberries", 1)
   overwrite("farming:muffin_blueberry", 4)
   if minetest.get_modpath("vessels") then
      overwrite("farming:smoothie_raspberry", 2, "vessels:drinking_glass")
      overwrite("farming:pineapple_juice", 4, "vessels:drinking_glass")
   end
   overwrite("farming:rhubarb", 1)
   overwrite("farming:rhubarb_pie", 6)
   overwrite("farming:garlic", 1)
   overwrite("farming:chili_bowl", 8, "farming:bowl")
   overwrite("farming:grapes", 2)
   overwrite("farming:peas", 1)
   overwrite("farming:pea_soup", 4, "farming:bowl")
   overwrite("farming:pepper", 2)
   overwrite("farming:chili_pepper", 2)
   overwrite("farming:pineapple_ring", 1)
   overwrite("farming:onion", 1)
   overwrite("farming:bread_slice", 1)
   overwrite("farming:toast", 1)
   overwrite("farming:toast_sandwich", 4)
   overwrite("farming:porridge", 6)
end

