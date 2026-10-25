-- table for quick colors.
mesecraft_toolranks = {
	colors = {
		grey = minetest.get_color_escape_sequence("#9d9d9d"),
		green = minetest.get_color_escape_sequence("#1eff00"),
		gold = minetest.get_color_escape_sequence("#ffdf00"),
		white = minetest.get_color_escape_sequence("#ffffff")
	}
}

-- function to create our description of the tool.
function mesecraft_toolranks.create_description(name, uses, level)
	return mesecraft_toolranks.colors.green .. (name or "") .. "\n"
		.. mesecraft_toolranks.colors.gold .. "Level: " .. (level or 1) .. "\n"
		.. mesecraft_toolranks.colors.grey .. "Used: " .. (uses or 0) .. " times"
end

-- function to calculate levels (+150 uses per level)
function mesecraft_toolranks.get_level(uses)
  if uses < 50 then
    return 1
  else
    return math.floor((25 + math.sqrt(625 + 100 * uses))/50)
  end
end

-- function to run after a tool is used.
function mesecraft_toolranks.new_afteruse(itemstack, user, node, digparams)

	-- Get tool metadata and number of times used
	local itemmeta = itemstack:get_meta()
	local dugnodes = tonumber(itemmeta:get_string("dug")) or 0

	-- Only count nodes that spend the tool
	if digparams.wear > 0 then

		dugnodes = dugnodes + 1
		itemmeta:set_string("dug", dugnodes)
	else
		return
	end

	-- Get tool description and last level
	local itemdef   = itemstack:get_definition()
	local itemdesc  = itemdef.original_description or itemdef.description or "Tool"
	local lastlevel = tonumber(itemmeta:get_string("lastlevel")) or 1
	local name = user:get_player_name()

	-- Warn player when tool is almost broken
	if itemstack:get_wear() > 60100 then

		minetest.chat_send_player(name,
			mesecraft_toolranks.colors.gold .. "Your tool is almost broken!")

		minetest.sound_play("default_tool_breaks", {
			to_player = name,
			gain = 2.0,
		})
	end

	local level = mesecraft_toolranks.get_level(dugnodes)

	-- Alert player when tool has leveled up
	if lastlevel < level then

		minetest.chat_send_player(name, "Your "
			.. mesecraft_toolranks.colors.green .. itemdesc
			.. mesecraft_toolranks.colors.white .. " just leveled up!")

		minetest.sound_play("mesecraft_toolranks_levelup", {
			to_player = name,
			gain = 1.0,
		})

		itemmeta:set_string("lastlevel", level)
	end

	local newdesc = mesecraft_toolranks.create_description(itemdesc, dugnodes, level)

	-- Set new meta
	itemmeta:set_string("description", newdesc)

	local wear = digparams.wear

	-- Set wear level
	if level > 1 then
		wear = digparams.wear / (1 + level / 20)
	end

	itemstack:add_wear(wear)

	return itemstack
end


-- Helper function to inject toolranks in an item without overriding his after_use function (if any)
mesecraft_toolranks.registered_tools = {}
function mesecraft_toolranks.register_tool(name)
	-- Check if tool is already registered to prevent appending multiple after_use callbacks
	for _, registered_name in pairs(mesecraft_toolranks.registered_tools) do
		if registered_name == name then
			return false
		end
	end

  -- Retrieve attributes from the original item
	local original_definition = ItemStack(name):get_definition()
	local original_after_use = original_definition.after_use

	-- Set description & append after_use callback
	minetest.override_item(name, {
		original_description = original_definition.description,
		description = mesecraft_toolranks.create_description(original_definition.description, 0, 1),
		after_use = function(itemstack, user, node, digparams)
			if original_after_use then
				-- Run the original after_use, revert the applied wear
				-- and adjust digparams wear for the toolranks after_use
				local initial_wear = itemstack:get_wear()
				itemstack = original_after_use(itemstack, user, node, digparams)
				local wear = itemstack:get_wear() - initial_wear
				itemstack:set_wear(initial_wear)
				digparams.wear = wear
			end

			return mesecraft_toolranks.new_afteruse(itemstack, user, node, digparams)
		end
	})

	-- Track list of registered tool names
	table.insert(mesecraft_toolranks.registered_tools, name)
	return true
end

-- Sword
mesecraft_toolranks.register_tool("default:sword_wood")
mesecraft_toolranks.register_tool("default:sword_stone")
mesecraft_toolranks.register_tool("default:sword_steel")
mesecraft_toolranks.register_tool("default:sword_bronze")
mesecraft_toolranks.register_tool("default:sword_mese")
mesecraft_toolranks.register_tool("default:sword_diamond")

-- Pickaxe
mesecraft_toolranks.register_tool("default:pick_wood")
mesecraft_toolranks.register_tool("default:pick_stone")
mesecraft_toolranks.register_tool("default:pick_steel")
mesecraft_toolranks.register_tool("default:pick_bronze")
mesecraft_toolranks.register_tool("default:pick_mese")
mesecraft_toolranks.register_tool("default:pick_diamond")

-- Axe
mesecraft_toolranks.register_tool("default:axe_wood")
mesecraft_toolranks.register_tool("default:axe_stone")
mesecraft_toolranks.register_tool("default:axe_steel")
mesecraft_toolranks.register_tool("default:axe_bronze")
mesecraft_toolranks.register_tool("default:axe_mese")
mesecraft_toolranks.register_tool("default:axe_diamond")

-- Shovel
mesecraft_toolranks.register_tool("default:shovel_wood")
mesecraft_toolranks.register_tool("default:shovel_stone")
mesecraft_toolranks.register_tool("default:shovel_steel")
mesecraft_toolranks.register_tool("default:shovel_bronze")
mesecraft_toolranks.register_tool("default:shovel_mese")
mesecraft_toolranks.register_tool("default:shovel_diamond")
