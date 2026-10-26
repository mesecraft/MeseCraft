-- MeseCraft: near-player mob spawning.
--
-- mobs_redo used to register one ABM per mobs:spawn() call. The engine runs every ABM over every
-- matching node in every active map block, so ~90 spawn ABMs (many of them on "group:stone" or
-- "group:cracky") kept the server busy in proportion to how much map was loaded, mostly far from
-- anyone who could see the mob.
--
-- Instead, every few seconds this samples a few vertical columns of nodes in a ring around each
-- player. Any node in a column that a spawn rule accepts gets a chance to spawn that mob, and the
-- usual checks in spawn_action (light, mob limits, space, protection, day/night) then decide.
-- The cost depends on the number of players, not the size of the loaded map.
--
-- Each rule keeps the chance and interval it was written with. One sampled column stands for a
-- slice of the ring, so a mob spawns near a player about as often as its ABM would have made it
-- spawn in that same area. The mob_spawn_rate setting scales every rule at once.

local ROUND_SECONDS = 2  -- time between sampling rounds
local COLUMNS = 3        -- columns sampled per player each round
local RING_MIN = 20      -- spawn no closer than this (mob_nospawn_range is 12)...
local RING_MAX = 48      -- ...and no further than this, horizontally
local COLUMN_HALF = 16   -- a column runs from 16 nodes below the player to 16 above

local spawn_rate = tonumber(minetest.settings:get("mob_spawn_rate")) or 1
local spawning_enabled = minetest.settings:get_bool("mobs_spawn") ~= false

-- How many seconds' worth of a rule's per-node ABM chance one sampled node represents:
-- the ring's area split between the columns of a round, times the round length.
local ring_area = math.pi * (RING_MAX * RING_MAX - RING_MIN * RING_MIN)
local node_seconds = ring_area / COLUMNS * ROUND_SECONDS * spawn_rate

-- Filled once all mods are loaded: node name -> list of rules that can spawn on it.
local rules_by_node = {}

-- Does a node name match a list of names and "group:..." entries?
local function matches(node_name, list)
	for _, entry in ipairs(list) do
		if entry == node_name then
			return true
		end
		local group = entry:match("^group:(.+)$")
		if group and minetest.get_item_group(node_name, group) > 0 then
			return true
		end
	end
	return false
end

minetest.register_on_mods_loaded(function()
	for _, rule in ipairs(mobs.spawn_rules) do
		-- Chance that one sampled node spawns this mob, as explained at the top.
		rule.probability = math.min(1, node_seconds / (rule.chance * rule.interval))
		-- Most rules want air next to the node; they only need to look at the node above.
		rule.air_only = #rule.neighbors == 1 and rule.neighbors[1] == "air"
		for name in pairs(minetest.registered_nodes) do -- includes "air"
			if matches(name, rule.nodes) then
				rules_by_node[name] = rules_by_node[name] or {}
				table.insert(rules_by_node[name], rule)
			end
		end
	end
end)

-- Is there a node from the rule's neighbor list next to pos? The node above is the usual case
-- (air, water or vacuum to spawn into), so check it before searching all around.
local function has_neighbor(rule, pos, above_name)
	if rule.air_only then
		return above_name == "air"
	end
	return matches(above_name, rule.neighbors)
		or minetest.find_node_near(pos, 1, rule.neighbors) ~= nil
end

-- Sample one column near ppos and give each matching node a chance to spawn a mob.
local function sample_column(ppos)
	local angle = math.random() * 2 * math.pi
	local dist = RING_MIN + math.random() * (RING_MAX - RING_MIN)
	local x = math.floor(ppos.x + math.cos(angle) * dist + 0.5)
	local z = math.floor(ppos.z + math.sin(angle) * dist + 0.5)
	local top = math.floor(ppos.y + 0.5) + COLUMN_HALF

	-- Walk down the column, remembering the node above each one.
	local above_name = minetest.get_node({x = x, y = top + 1, z = z}).name
	for y = top, top - 2 * COLUMN_HALF, -1 do
		local pos = {x = x, y = y, z = z}
		local node = minetest.get_node(pos)
		if node.name == "ignore" then
			return -- not generated or not loaded
		end
		local rules = rules_by_node[node.name]
		if rules then
			for _, rule in ipairs(rules) do
				-- The mob would stand in the node above, which is what the height limits check.
				if y + 1 >= rule.min_height and y + 1 <= rule.max_height
						and math.random() < rule.probability
						and has_neighbor(rule, pos, above_name) then
					-- spawn_action does the remaining checks and moves pos up itself.
					rule.action(pos, node)
					return -- at most one spawn attempt per column
				end
			end
		end
		above_name = node.name
	end
end

-- Exposed for tests and debugging: mobs.sample_spawn_column(player_pos)
mobs.sample_spawn_column = sample_column

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < ROUND_SECONDS then
		return
	end
	timer = 0
	if not spawning_enabled then
		return
	end
	for _, player in ipairs(minetest.get_connected_players()) do
		local ppos = player:get_pos()
		for _ = 1, COLUMNS do
			sample_column(ppos)
		end
	end
end)
