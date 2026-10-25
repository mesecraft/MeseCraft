
local S = protector.intllib
local radius = (tonumber(minetest.settings:get("protector_radius")) or 5)

-- radius limiter (minetest cannot handle node volume of more than 4096000)
if radius > 22 then radius = 22 end

local hud = {}
local hud_timer = 0
local hud_interval = (tonumber(minetest.settings:get("protector_hud_interval")) or 5)

if hud_interval > 0 then
minetest.register_globalstep(function(dtime)

	-- every 5 seconds
	hud_timer = hud_timer + dtime
	if hud_timer < hud_interval then
		return
	end
	hud_timer = 0

	for _, player in pairs(minetest.get_connected_players()) do

		local name = player:get_player_name()
		local pos = vector.round(player:get_pos())
		local hud_text = ""

		local protectors = minetest.find_nodes_in_area(
			{x = pos.x - radius , y = pos.y - radius , z = pos.z - radius},
			{x = pos.x + radius , y = pos.y + radius , z = pos.z + radius},
			{"protector:protect","protector:protect2", "protector:protect_hidden"})

		if #protectors > 0 then
			local npos = protectors[1]
			local meta = minetest.get_meta(npos)
			local nodeowner = meta:get_string("owner")

			hud_text = S("Owner: @1", nodeowner)
		end

		if not hud[name] then

			hud[name] = {}

			hud[name].id = player:hud_add({
				type = "text",
				name = "Protector Area",
				number = 0xFFFF22,
				position = {x = 0, y = 0.95},
				offset = {x = 8, y = -8},
				text = hud_text,
				scale = {x = 200, y = 60},
				alignment = {x = 1, y = -1},
			})

			return
		else
			player:hud_change(hud[name].id, "text", hud_text)
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	hud[player:get_player_name()] = nil
end)

end
