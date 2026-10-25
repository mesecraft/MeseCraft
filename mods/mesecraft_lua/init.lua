mesecraft_lua = {
	miny = tonumber(minetest.settings:get("mesecraft_lua.miny")) or 3000,
	maxy = tonumber(minetest.settings:get("mesecraft_lua.maxy")) or 3300,
	maxsolidy = tonumber(minetest.settings:get("mesecraft_lua.maxsolidy")) or 3200
}


local modpath = minetest.get_modpath("mesecraft_lua")

dofile(modpath.."/stone.lua")
dofile(modpath.."/ores.lua")
dofile(modpath.."/mapgen.lua")
dofile(modpath.."/skybox.lua")

-- Nether mod check for portal API for moon portals.
local has_nether_mod = minetest.get_modpath("nether")
if has_nether_mod then
	dofile(modpath.."/nether_portal.lua")
end