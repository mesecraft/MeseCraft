
local path = minetest.get_modpath("mobs")

-- Peaceful player privilege
minetest.register_privilege("peaceful_player", {
	description = "Prevents Mobs Redo mobs from attacking player",
	give_to_singleplayer = false
})

-- Mob API
dofile(path .. "/api.lua")

-- Near-player spawning (MeseCraft: replaces the per-mob spawn ABMs)
dofile(path .. "/spawning.lua")

-- Rideable Mobs
dofile(path .. "/mount.lua")

-- Mob Items
dofile(path .. "/crafts.lua")

-- Mob Spawner
dofile(path .. "/spawner.lua")

print("[MOD] Mobs Redo loaded")
