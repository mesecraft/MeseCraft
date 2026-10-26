-- MeseCraft's changes to Minetest Game, applied with overrides so mods/MTG stays identical to upstream.

-- MeseCraft's mese crystal art.
minetest.override_item("default:mese_crystal", {
	inventory_image = "mesecraft_overrides_mese_crystal.png",
})

-- Spawning: MTG places players at the predicted ground level before the area is generated,
-- and structures added afterwards (volcanoes, mostly) can bury that spot. Once the area has
-- loaded, lift a buried player to the first open space above.
mesecraft_overrides = {}

local function is_open(pos)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	return def ~= nil and not def.walkable
end

function mesecraft_overrides.unbury(player, tries)
	local pos = vector.round(player:get_pos())
	for y = pos.y, pos.y + 64 do
		local p = vector.new(pos.x, y, pos.z)
		if minetest.get_node(p).name == "ignore" then
			-- Not generated yet; check again shortly.
			if tries > 0 then
				local name = player:get_player_name()
				minetest.after(1, function()
					local again = minetest.get_player_by_name(name)
					if again then mesecraft_overrides.unbury(again, tries - 1) end
				end)
			end
			return
		end
		if is_open(p) and is_open(vector.offset(p, 0, 1, 0)) then
			if y ~= pos.y then
				player:set_pos(p)
			end
			return
		end
	end
end

local function unbury_soon(player)
	local name = player:get_player_name()
	minetest.after(1, function()
		local p = minetest.get_player_by_name(name)
		if p then mesecraft_overrides.unbury(p, 10) end
	end)
end

minetest.register_on_newplayer(unbury_soon)
minetest.register_on_respawnplayer(function(player)
	unbury_soon(player)
end)

-- Loot: magic mirrors and the Book of Portals were hard to come by (issues #16, #17).
if minetest.get_modpath("lootchests") then
	local extra = {}
	if minetest.get_modpath("mesecraft_magic_mirror") then
		extra[#extra + 1] = {"mesecraft_magic_mirror:magic_mirror", 1}
	end
	if minetest.get_modpath("nether") then
		extra[#extra + 1] = {"nether:book_of_portals", 1}
	end
	for _, chest in ipairs({"lootchests_default:stone_chest", "lootchests_default:ocean_chest",
			"geomoria_lootchests:chest"}) do
		if lootchests.loot_table[chest] then
			lootchests.add_to_loot_table(chest, extra)
		end
	end
end

-- World layers: Earth orbit and the asteroid belts get space skies (issue #116). The moon and Mars
-- register their own skies at a higher priority, so those win inside their bands.
if minetest.get_modpath("climate_api") and minetest.get_modpath("other_worlds") then
	local faces = {"sky_pos_y.png", "sky_neg_y.png", "sky_pos_x.png", "sky_neg_x.png", "sky_pos_z.png", "sky_neg_z.png"}
	local function space_sky(textures)
		return {
			sky_data = {type = "skybox", base_color = {r = 0, g = 0, b = 0}, textures = textures, clouds = false},
			sun_data = {visible = true, sunrise_visible = false},
			moon_data = {visible = false},
			star_data = {visible = false},
			priority = 900,
		}
	end
	local red = {}
	for i, face in ipairs(faces) do
		red[i] = face .. "^[colorize:#a02010:90"
	end
	local space_floor = minetest.get_modpath("vacuum") and vacuum.space_height or 1000
	climate_api.register_weather("mesecraft_overrides:space",
		{min_height = space_floor, max_height = otherworlds.settings.space_asteroids.YMAX + 1},
		{["climate_api:skybox"] = space_sky(faces)})
	climate_api.register_weather("mesecraft_overrides:red_asteroids",
		{min_height = otherworlds.settings.redsky_asteroids.YMIN, max_height = otherworlds.settings.redsky_asteroids.YMAX + 1},
		{["climate_api:skybox"] = space_sky(red)})
end
