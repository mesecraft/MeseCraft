-- Guide books written by MeseCraft players on the mesecraft.com forums, proofread and updated for
-- the current game. They fill settlement bookshelves, and new players start with How to Play.
mesecraft_guides = {}

local modpath = minetest.get_modpath("mesecraft_guides")

-- MTG's book shows 14 lines per page; wrapping keeps each page within the text box.
local LINE_WIDTH = 50
local LINES_PER_PAGE = 14
local MAX_TEXT = 10000

-- topic: the guide's thread under mesecraft.com/discussions/topic/ (credited in README.md, not in
-- the book). extra: other players whose replies were folded in.
mesecraft_guides.books = {
	{id = "introduction", title = "An Introduction to MeseCraft", author = "Fane",
		topic = "an-introduction-to-mesecraft"},
	{id = "how_to_play", title = "How to Play MeseCraft", author = "Kiopy7",
		topic = "guide-to-mesecraft-how-to-play"},
	{id = "tips_and_tricks", title = "Tips and Tricks", author = "Kiopy7",
		topic = "random-tips-and-trick-in-mesecraft"},
	{id = "minerals", title = "A Guide to Minerals, Alloys, Rocks and Crystals", author = "Kiopy7",
		topic = "a-guide-to-minerals-alloys-rocks-and-crystals", extra = "Charlie_Blockhead"},
	{id = "layers", title = "The Layers of the World", author = "Komodo", topic = "biomes"},
	{id = "taming", title = "A Guide to Taming", author = "mesecraft",
		topic = "guide-on-taming-part-1", extra = "Charlie_Blockhead"},
	{id = "market_1", title = "Market Reference, Vol. 1", author = "Odie", topic = "market-reference-book",
		market = true},
	{id = "market_2", title = "Market Reference, Vol. 2", author = "Odie", topic = "market-reference-book",
		market = true},
	{id = "almanac_1", title = "Farmer's Almanac, Vol. 1", author = "Keihdra", topic = "farmers-almanac"},
	{id = "almanac_2", title = "Farmer's Almanac, Vol. 2", author = "Keihdra", topic = "farmers-almanac"},
	{id = "almanac_3", title = "Farmer's Almanac, Vol. 3", author = "Keihdra", topic = "farmers-almanac"},
	{id = "almanac_4", title = "Farmer's Almanac, Vol. 4", author = "Keihdra", topic = "farmers-almanac"},
	{id = "almanac_5", title = "Farmer's Almanac, Vol. 5", author = "Keihdra", topic = "farmers-almanac"},
	{id = "almanac_6", title = "Farmer's Almanac, Vol. 6", author = "Keihdra", topic = "farmers-almanac"},
	{id = "garlic", title = "Garlic: Bane of Vampires", author = "Keihdra", topic = "farmers-almanac"},
}

local function wrap(text)
	local out = {}
	for para in (text .. "\n"):gmatch("([^\n]*)\n") do
		local line = ""
		for word in para:gmatch("%S+") do
			if line ~= "" and #line + 1 + #word > LINE_WIDTH then
				out[#out + 1] = line
				line = word
			else
				line = line == "" and word or line .. " " .. word
			end
		end
		out[#out + 1] = line
	end
	-- Drop the trailing blank lines left by the file's final newline.
	while out[#out] == "" do
		out[#out] = nil
	end
	return out
end

local by_id = {}
for _, book in ipairs(mesecraft_guides.books) do
	local file = assert(io.open(modpath .. "/books/" .. book.id .. ".txt", "r"))
	local text = file:read("*a")
	file:close()
	local credit = "Written by " .. book.author
	if book.extra then
		credit = credit .. ", with notes from " .. book.extra
	end
	text = text .. "\n\n" .. credit .. " for the MeseCraft forums."
	local lines = wrap(text)
	book.text = table.concat(lines, "\n")
	book.page_max = math.ceil(#lines / LINES_PER_PAGE)
	if #book.text > MAX_TEXT then
		minetest.log("warning", "[mesecraft_guides] " .. book.id .. " is longer than a book can hold")
	end
	by_id[book.id] = book
end

-- Returns a written book ItemStack for the guide with this id.
function mesecraft_guides.make_book(id)
	local book = assert(by_id[id], "unknown guide " .. tostring(id))
	local stack = ItemStack("default:book_written")
	local meta = stack:get_meta()
	meta:set_string("title", book.title)
	meta:set_string("owner", book.author)
	meta:set_string("description", book.title .. "\nby " .. book.author)
	meta:set_string("text", book.text)
	meta:set_int("page", 1)
	meta:set_int("page_max", book.page_max)
	return stack
end

local function has_book(inv, listname, title)
	for _, stack in ipairs(inv:get_list(listname) or {}) do
		if stack:get_meta():get_string("title") == title then
			return true
		end
	end
	return false
end

-- Adds a random guide the inventory list doesn't hold yet. Returns false when there was no room
-- or every guide is already there.
function mesecraft_guides.add_random_book(inv, listname, filter)
	local choices = {}
	for _, book in ipairs(mesecraft_guides.books) do
		if (not filter or filter(book)) and not has_book(inv, listname, book.title) then
			choices[#choices + 1] = book
		end
	end
	if #choices == 0 then
		return false
	end
	local stack = mesecraft_guides.make_book(choices[math.random(#choices)].id)
	if not inv:room_for_item(listname, stack) then
		return false
	end
	inv:add_item(listname, stack)
	return true
end

-- New players start with How to Play, and are told where to find it.
minetest.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	local stack = mesecraft_guides.make_book("how_to_play")
	if inv:room_for_item("main", stack) then
		inv:add_item("main", stack)
	end
	local name = player:get_player_name()
	-- Wait a moment so the message isn't lost among the join messages.
	minetest.after(5, function()
		if minetest.get_player_by_name(name) then
			minetest.chat_send_player(name, minetest.colorize("#ffd36b",
				"Welcome to MeseCraft! New here? Hold the How to Play book in your hotbar and left-click to read it."))
		end
	end)
end)

-- Settlement libraries: shelves in new settlements get a guide or two (market buildings get the
-- market reference), and when the slow "Settlement book authoring" ABM has no ledger or travel
-- guide to write, it shelves a guide instead.
if minetest.get_modpath("settlements") and minetest.settings:get_bool("settlements_generate_books", true) then
	local function is_market(book) return book.market end

	local function stock_shelf(pos, market_building)
		local inv = minetest.get_meta(pos):get_inventory()
		if market_building then
			mesecraft_guides.add_random_book(inv, "books", is_market)
		end
		for _ = 1, math.random(1, 2) do
			mesecraft_guides.add_random_book(inv, "books")
		end
		local def = minetest.registered_nodes["default:bookshelf"]
		if def and def.on_construct then
			def.on_construct(pos) -- refreshes the shelf's infotext without touching its contents
		end
	end

	minetest.register_on_mods_loaded(function()
		local wrapped = {}
		local function wrap_schematic(schematic)
			if wrapped[schematic] then
				return
			end
			wrapped[schematic] = true
			local market_building = (schematic.name or ""):find("market") ~= nil
			local old = schematic.initialize_node
			schematic.initialize_node = function(pos, node, node_def, settlement_info)
				if old then
					old(pos, node, node_def, settlement_info)
				end
				if node.name == "default:bookshelf" then
					stock_shelf(pos, market_building)
				end
			end
		end

		for _, def in pairs(settlements.registered_settlements) do
			for _, schematic in ipairs(def.schematics or {}) do
				wrap_schematic(schematic)
			end
			for _, schematic in ipairs(def.central_schematics or {}) do
				wrap_schematic(schematic)
			end
			local old_generate = def.generate_book
			def.generate_book = function(pos, town_name)
				local book = old_generate and old_generate(pos, town_name)
				if book then
					return book
				end
				-- Settlements pass the shelf when filling a new library, but the settlement's
				-- centre from the ABM, so only skip duplicates when pos really is a shelf.
				local inv = minetest.get_node(pos).name == "default:bookshelf"
					and minetest.get_meta(pos):get_inventory()
				local choices = {}
				for _, guide in ipairs(mesecraft_guides.books) do
					if not (inv and has_book(inv, "books", guide.title)) then
						choices[#choices + 1] = guide
					end
				end
				if #choices > 0 then
					return mesecraft_guides.make_book(choices[math.random(#choices)].id)
				end
			end
		end
	end)
end
