-- Creature journal (issue #114): like a field guide, creatures are recorded when a player first
-- sees one up close, and more is learned about them once the player defeats one.

mesecraft_journal = {}

local META_KEY = "mesecraft_journal"
local SEE_RADIUS = 12
local SEE_INTERVAL = 3

-- Player progress: name -> {seen = {mob = true}, defeated = {mob = count}}
local progress = {}

local function load(player)
	local name = player:get_player_name()
	if not progress[name] then
		local data = minetest.deserialize(player:get_meta():get_string(META_KEY)) or {}
		data.seen = data.seen or {}
		data.defeated = data.defeated or {}
		progress[name] = data
	end
	return progress[name]
end

local function save(player)
	player:get_meta():set_string(META_KEY, minetest.serialize(load(player)))
end

minetest.register_on_leaveplayer(function(player)
	progress[player:get_player_name()] = nil
end)

-- Creatures: every mobs_redo mob with a spawn egg.
local creatures = {} -- sorted list of mob names
local info = {}      -- mob name -> {title, icon, def, habitat}

local layers = {
	{-31000, -17000, "the Nether"},
	{-17000, -4000, "deep underground"},
	{-4000, -50, "caves and caverns"},
	{-50, 200, "the surface"},
	{200, 1000, "the sky and cloudlands"},
	{1000, 2000, "Earth orbit"},
	{2000, 2300, "the Moon"},
	{2300, 11000, "the asteroid belt"},
	{11000, 22000, "Mars"},
	{22000, 31000, "the red asteroids"},
}

local function add_layers(set, min_y, max_y)
	for i, layer in ipairs(layers) do
		if min_y < layer[2] and max_y > layer[1] then
			set[i] = true
		end
	end
end

local function describe(found)
	local names = {}
	for i, layer in ipairs(layers) do
		if found.layers[i] then names[#names + 1] = layer[3] end
	end
	local text = #names > 4 and "almost everywhere" or table.concat(names, ", ")
	if found.season then
		text = (text ~= "" and text .. ", " or "") .. "around " .. found.season
	end
	return text ~= "" and text or nil
end

local function collect_creatures()
	local found = {} -- mob name -> {layers = {layer index = true}, season = name}
	local function entry(mob)
		found[mob] = found[mob] or {layers = {}}
		return found[mob]
	end
	for _, rule in ipairs(mobs.spawn_rules) do
		add_layers(entry(rule.name).layers, rule.min_height, rule.max_height)
	end
	if minetest.get_modpath("mesecraft_seasonal") then
		for _, def in ipairs(mesecraft_seasonal.spawns) do
			local e = entry(def.mob)
			add_layers(e.layers, def.min_y, def.max_y)
			e.season = def.season:sub(1, 1):upper() .. def.season:sub(2)
		end
	end

	for name, def in pairs(minetest.registered_entities) do
		local egg = minetest.registered_items[name]
		if def._cmi_is_mob and egg then
			local title = minetest.strip_colors(minetest.get_translated_string("en", egg.description or "") or "")
			title = title:gsub(" [Ss]pawn [Ee]gg$", ""):gsub("^%s+", ""):gsub("%s+$", "")
			if title == "" then title = name end
			info[name] = {
				title = title,
				icon = name,
				def = def,
				habitat = found[name] and describe(found[name]),
			}
			creatures[#creatures + 1] = name
		end
	end
	table.sort(creatures, function(a, b) return info[a].title < info[b].title end)
end

-- Recording ----------------------------------------------------------------------------------

function mesecraft_journal.record_seen(player, mob)
	if not info[mob] then return end
	local data = load(player)
	if not data.seen[mob] then
		data.seen[mob] = true
		save(player)
		minetest.chat_send_player(player:get_player_name(), minetest.colorize("#c7e07a",
			"New creature in your journal: " .. info[mob].title))
	end
end

function mesecraft_journal.record_defeat(player, mob)
	if not info[mob] then return end
	local data = load(player)
	data.seen[mob] = true
	data.defeated[mob] = (data.defeated[mob] or 0) + 1
	save(player)
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < SEE_INTERVAL then return end
	timer = 0
	for _, player in ipairs(minetest.get_connected_players()) do
		for _, obj in ipairs(minetest.get_objects_inside_radius(player:get_pos(), SEE_RADIUS)) do
			local ent = obj:get_luaentity()
			if ent and ent._cmi_is_mob and ent.name then
				mesecraft_journal.record_seen(player, ent.name)
			end
		end
	end
end)

-- Defeats: wrap mobs_redo's death check (shared by all mobs through their metatable).
minetest.register_on_mods_loaded(function()
	collect_creatures()
	local any = creatures[1] and minetest.registered_entities[creatures[1]]
	local mob_class = any and getmetatable(any) and getmetatable(any).__index
	if not (mob_class and mob_class.check_for_death) then
		minetest.log("warning", "[mesecraft_journal] can't find mobs_redo's mob class; defeats won't be recorded")
		return
	end
	local check_for_death = mob_class.check_for_death
	mob_class.check_for_death = function(self, cause)
		local was_dying = self.state == "die"
		local died = check_for_death(self, cause)
		if died and not was_dying and cause and cause.puncher and cause.puncher:is_player() then
			mesecraft_journal.record_defeat(cause.puncher, self.name)
		end
		return died
	end
end)

-- Journal page -------------------------------------------------------------------------------

local function drop_list(def)
	local names = {}
	for _, drop in ipairs(def.drops or {}) do
		local item = minetest.registered_items[drop.name]
		if item and item.description then
			local d = minetest.strip_colors(minetest.get_translated_string("en", item.description)):match("^[^\n]*")
			if d and d ~= "" then names[#names + 1] = d end
		end
	end
	return #names > 0 and table.concat(names, ", ") or "nothing"
end

local function entry_text(mob, data)
	local c = info[mob]
	local def = c.def
	local lines = {}
	local kind = ({animal = "Animal", monster = "Monster", npc = "Person"})[def.type] or "Creature"
	lines[#lines + 1] = kind
	lines[#lines + 1] = "Found in: " .. (c.habitat or "unknown places")
	local defeated = data.defeated[mob] or 0
	if defeated > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Health: " .. tostring(def.hp_max or "?")
		if def.damage and def.damage > 0 and def.type ~= "animal" then
			lines[#lines + 1] = "Attack: " .. tostring(def.damage)
		end
		lines[#lines + 1] = "Drops: " .. drop_list(def)
		lines[#lines + 1] = "Defeated: " .. defeated
	else
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Defeat one to learn more."
	end
	return table.concat(lines, "\n")
end

local selected = {} -- player name -> index in creatures

sfinv.register_page("mesecraft_journal:creatures", {
	title = "Creatures",
	get = function(self, player, context)
		local data = load(player)
		local name = player:get_player_name()
		local rows, seen_count = {}, 0
		for _, mob in ipairs(creatures) do
			if data.seen[mob] then
				seen_count = seen_count + 1
				rows[#rows + 1] = minetest.formspec_escape(info[mob].title)
			else
				rows[#rows + 1] = "#777777???"
			end
		end
		local idx = selected[name] or 1
		local mob = creatures[idx]
		local detail
		if mob and data.seen[mob] then
			detail = "item_image[4,0.2;1,1;" .. info[mob].icon .. "]" ..
				"label[5.1,0.4;" .. minetest.formspec_escape(info[mob].title) .. "]" ..
				"textarea[4.1,1.4;4.2,7.4;;;" .. minetest.formspec_escape(entry_text(mob, data)) .. "]"
		else
			detail = "label[4,0.4;???]" ..
				"textarea[4.1,1.4;4.2,7.4;;;" .. minetest.formspec_escape("Not seen yet. Get close to one to add it to your journal.") .. "]"
		end
		local formspec = "label[0,0;" .. seen_count .. " of " .. #creatures .. " creatures seen]" ..
			"textlist[0,0.5;3.6,8.4;creature;" .. table.concat(rows, ",") .. ";" .. idx .. "]" ..
			detail
		return sfinv.make_formspec(player, context, formspec, false)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if fields.creature then
			local event = minetest.explode_textlist_event(fields.creature)
			if event.type == "CHG" or event.type == "DCL" then
				selected[player:get_player_name()] = event.index
				sfinv.set_player_inventory_formspec(player)
			end
		end
	end,
})
