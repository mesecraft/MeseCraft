-- MeseCraft announcements: post a rotating message to chat every few minutes,
-- for server-wide notices. Turn it off with `mesecraft_announcements = false`.
--
-- Written for MeseCraft (AGPLv3, like the rest of the game).

if not minetest.settings:get_bool("mesecraft_announcements", true) then
	return
end

-- Seconds between announcements.
local INTERVAL = 600

local LABEL = minetest.colorize("#fefe3f", "MESECRAFT: ")
local HIGHLIGHT = "#fefe3f"
local TEXT = "#00be00"

-- Each message is a list of parts; parts in a table are highlighted.
local messages = {
	{"MeseCraft is in beta. Expect big changes between versions!"},
	{"Join the MeseCraft community at ", {"www.mesecraft.com"}},
	{"Send suggestions, feedback and bug reports at ", {"www.mesecraft.com"}, "."},
	{"If you like MeseCraft, please leave it a review on ContentDB!"},
}

local function format(message)
	local out = LABEL
	for _, part in ipairs(message) do
		if type(part) == "table" then
			out = out .. minetest.colorize(HIGHLIGHT, part[1])
		else
			out = out .. minetest.colorize(TEXT, part)
		end
	end
	return out
end

local next_message = 1

local function announce()
	minetest.chat_send_all(format(messages[next_message]))
	next_message = next_message % #messages + 1
	minetest.after(INTERVAL, announce)
end

minetest.after(INTERVAL, announce)
