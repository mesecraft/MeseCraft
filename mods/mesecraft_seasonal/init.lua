-- Holiday seasons, and a spawner for seasonal mobs that works near players.
--
-- Seasonal mobs used to register mobs_redo spawn ABMs on nearly every ground node all year,
-- then delete themselves out of season after checking the date every step. Instead, the
-- season is computed every few minutes, and while it's active a few spawn attempts are made
-- near each player. Out of season this costs nothing.

mesecraft_seasonal = {
	active = {}, -- season name -> true while the season is on
}

local seasons = {
	halloween = function(d) return (d.month == 10 and d.day >= 10) or (d.month == 11 and d.day <= 1) end,
	christmas = function(d) return d.month == 12 end,
}

local function update_seasons()
	local date = os.date("*t")
	for name, in_season in pairs(seasons) do
		mesecraft_seasonal.active[name] = in_season(date) or nil
	end
	minetest.after(600, update_seasons)
end
update_seasons()

-- For a mob's do_custom: removes the mob once its season is over.
function mesecraft_seasonal.keep(self, season)
	if not mesecraft_seasonal.active[season] then
		self.object:remove()
		return false
	end
	return true
end

local spawns = {}    -- list of spawn definitions
local is_seasonal = {} -- mob name -> true

-- def: season, nodes, min_light, max_light, min_y, max_y, weight (default 1)
function mesecraft_seasonal.register_spawn(mob, def)
	def.mob = mob
	def.weight = def.weight or 1
	spawns[#spawns + 1] = def
	is_seasonal[mob] = true
end

local INTERVAL = 15         -- seconds between spawn attempts
local MAX_NEAR_PLAYER = 4   -- seasonal mobs allowed within COUNT_RADIUS of a player
local COUNT_RADIUS = 40
local MIN_DIST, MAX_DIST = 12, 32

local settings = minetest.settings
local spawning_enabled = settings:get_bool("mobs_spawn") ~= false
local peaceful_only = settings:get_bool("only_peaceful_mobs")
local spawn_protected = settings:get_bool("mobs_spawn_protected") ~= false

local function is_air_like(pos)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	return def and not def.walkable and def.liquidtype == "none"
end

local function pick(candidates)
	local total = 0
	for _, def in ipairs(candidates) do total = total + def.weight end
	local r = math.random() * total
	for _, def in ipairs(candidates) do
		r = r - def.weight
		if r <= 0 then return def end
	end
end

-- One spawn attempt near a player (run for every player each INTERVAL while a season is on).
local function try_spawn(player)
	local ppos = player:get_pos()
	local near = 0
	for _, obj in ipairs(minetest.get_objects_inside_radius(ppos, COUNT_RADIUS)) do
		local ent = obj:get_luaentity()
		if ent and is_seasonal[ent.name] then
			near = near + 1
		end
	end
	if near >= MAX_NEAR_PLAYER then
		return
	end

	local candidates = {}
	for _, def in ipairs(spawns) do
		if mesecraft_seasonal.active[def.season]
				and ppos.y >= def.min_y - MAX_DIST and ppos.y <= def.max_y + MAX_DIST
				and not (peaceful_only and minetest.registered_entities[def.mob].type == "monster") then
			candidates[#candidates + 1] = def
		end
	end
	local def = pick(candidates)
	if not def then
		return
	end

	local angle = math.random() * 2 * math.pi
	local dist = MIN_DIST + math.random() * (MAX_DIST - MIN_DIST)
	local center = vector.round(vector.offset(ppos, math.cos(angle) * dist, 0, math.sin(angle) * dist))
	local ground = minetest.find_nodes_in_area_under_air(vector.offset(center, -4, -8, -4),
		vector.offset(center, 4, 8, 4), def.nodes)
	if #ground == 0 then
		return
	end
	local pos = vector.offset(ground[math.random(#ground)], 0, 1, 0)
	local light = minetest.get_node_light(pos)
	if pos.y < def.min_y or pos.y > def.max_y or not light
			or light < def.min_light or light > def.max_light
			or not is_air_like(vector.offset(pos, 0, 1, 0))
			or (not spawn_protected and minetest.is_protected(pos, "")) then
		return
	end
	minetest.add_entity(pos, def.mob)
end

mesecraft_seasonal.try_spawn = try_spawn

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < INTERVAL then
		return
	end
	timer = 0
	if not spawning_enabled or next(mesecraft_seasonal.active) == nil then
		return
	end
	for _, player in ipairs(minetest.get_connected_players()) do
		try_spawn(player)
	end
end)
