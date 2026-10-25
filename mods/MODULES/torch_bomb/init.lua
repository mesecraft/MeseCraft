local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local tnt_modpath = minetest.get_modpath("tnt")
local S = minetest.get_translator(modname)

local FakePlayer = dofile(modpath .. "/" .. "class_fakeplayer.lua")
local fakeplayer = FakePlayer.create({x=0,y=0,z=0}, "torch_bomb")

-- Default to enabled when in singleplayer
local enable_tnt = minetest.settings:get_bool("enable_tnt")
if enable_tnt == nil then
	enable_tnt = minetest.is_singleplayer()
end

local grenade_range = tonumber(minetest.settings:get("torch_bomb_grenade_range")) or 25
local bomb_range = tonumber(minetest.settings:get("torch_bomb_range")) or 50
local mega_bomb_range = tonumber(minetest.settings:get("torch_bomb_mega_range")) or 150
local torch_item = minetest.settings:get("torch_bomb_torch_item") or "default:torch"

local enable_rockets = minetest.settings:get_bool("torch_bomb_enable_rockets", true)
local rocket_max_fuse = tonumber(minetest.settings:get("torch_bomb_max_fuse")) or 14 -- 14 seconds at 1 m/s^2 is 98 meters traveled
local default_fuse = rocket_max_fuse/2 -- 7 seconds at 1 m/s^2 is 24.5 meters traveled

local enable_grenade = minetest.settings:get_bool("torch_bomb_enable_grenades", true)

-- 12 torches grenade
local ico1 = {
	vector.new(0.000000,	-1.000000,	0.000000),
	vector.new(0.723600,	-0.447215,	0.525720),
	vector.new(-0.276385,	-0.447215,	0.850640),
	vector.new(-0.894425,	-0.447215,	0.000000),
	vector.new(-0.276385,	-0.447215,	-0.850640),
	vector.new(0.723600,	-0.447215,	-0.525720),
	vector.new(0.276385,	0.447215,	0.850640),
	vector.new(-0.723600,	0.447215,	0.525720),
	vector.new(-0.723600,	0.447215,	-0.525720),
	vector.new(0.276385,	0.447215,	-0.850640),
	vector.new(0.894425,	0.447215,	0.000000),
	vector.new(0.000000,	1.000000,	0.000000),
}
-- Pre-multiply the range into these unit vectors
for i, pos in ipairs(ico1) do
	ico1[i] = vector.multiply(pos, grenade_range)
end

-- 42 torches, 1*bomb_range
local ico2 = {
	vector.new(0.000000,	-1.000000,	0.000000),
	vector.new(0.723607,	-0.447220,	0.525725),
	vector.new(-0.276388,	-0.447220,	0.850649),
	vector.new(-0.894426,	-0.447216,	0.000000),
	vector.new(-0.276388,	-0.447220,	-0.850649),
	vector.new(0.723607,	-0.447220,	-0.525725),
	vector.new(0.276388,	0.447220,	0.850649),
	vector.new(-0.723607,	0.447220,	0.525725),
	vector.new(-0.723607,	0.447220,	-0.525725),
	vector.new(0.276388,	0.447220,	-0.850649),
	vector.new(0.894426,	0.447216,	0.000000),
	vector.new(0.000000,	1.000000,	0.000000),
	vector.new(-0.162456,	-0.850654,	0.499995),
	vector.new(0.425323,	-0.850654,	0.309011),
	vector.new(0.262869,	-0.525738,	0.809012),
	vector.new(0.850648,	-0.525736,	0.000000),
	vector.new(0.425323,	-0.850654,	-0.309011),
	vector.new(-0.525730,	-0.850652,	0.000000),
	vector.new(-0.688189,	-0.525736,	0.499997),
	vector.new(-0.162456,	-0.850654,	-0.499995),
	vector.new(-0.688189,	-0.525736,	-0.499997),
	vector.new(0.262869,	-0.525738,	-0.809012),
	vector.new(0.951058,	0.000000,	0.309013),
	vector.new(0.951058,	0.000000,	-0.309013),
	vector.new(0.000000,	0.000000,	1.000000),
	vector.new(0.587786,	0.000000,	0.809017),
	vector.new(-0.951058,	0.000000,	0.309013),
	vector.new(-0.587786,	0.000000,	0.809017),
	vector.new(-0.587786,	0.000000,	-0.809017),
	vector.new(-0.951058,	0.000000,	-0.309013),
	vector.new(0.587786,	0.000000,	-0.809017),
	vector.new(0.000000,	0.000000,	-1.000000),
	vector.new(0.688189,	0.525736,	0.499997),
	vector.new(-0.262869,	0.525738,	0.809012),
	vector.new(-0.850648,	0.525736,	0.000000),
	vector.new(-0.262869,	0.525738,	-0.809012),
	vector.new(0.688189,	0.525736,	-0.499997),
	vector.new(0.162456,	0.850654,	0.499995),
	vector.new(0.525730,	0.850652,	0.000000),
	vector.new(-0.425323,	0.850654,	0.309011),
	vector.new(-0.425323,	0.850654,	-0.309011),
	vector.new(0.162456,	0.850654,	-0.499995),
}
-- Pre-multiply the range into these unit vectors
for i, pos in ipairs(ico2) do
	ico2[i] = vector.multiply(pos, bomb_range)
end

-- 162 torches, 3* bomb_range
local ico3 = {
	vector.new(0.000000,	-1.000000,	0.000000), 
	vector.new(0.723607,	-0.447220,	0.525725),
	vector.new(-0.276388,	-0.447220,	0.850649),
	vector.new(-0.894426,	-0.447216,	0.000000),
	vector.new(-0.276388,	-0.447220,	-0.850649),
	vector.new(0.723607,	-0.447220,	-0.525725),
	vector.new(0.276388,	0.447220,	0.850649),
	vector.new(-0.723607,	0.447220,	0.525725),
	vector.new(-0.723607,	0.447220,	-0.525725),
	vector.new(0.276388,	0.447220,	-0.850649),
	vector.new(0.894426,	0.447216,	0.000000),
	vector.new(0.000000,	1.000000,	0.000000),
	vector.new(-0.232822,	-0.657519,	0.716563),
	vector.new(-0.162456,	-0.850654,	0.499995),
	vector.new(-0.077607,	-0.967950,	0.238853),
	vector.new(0.203181,	-0.967950,	0.147618),
	vector.new(0.425323,	-0.850654,	0.309011),
	vector.new(0.609547,	-0.657519,	0.442856),
	vector.new(0.531941,	-0.502302,	0.681712),
	vector.new(0.262869,	-0.525738,	0.809012),
	vector.new(-0.029639,	-0.502302,	0.864184),
	vector.new(0.812729,	-0.502301,	-0.295238),
	vector.new(0.850648,	-0.525736,	0.000000),
	vector.new(0.812729,	-0.502301,	0.295238),
	vector.new(0.203181,	-0.967950,	-0.147618),
	vector.new(0.425323,	-0.850654,	-0.309011),
	vector.new(0.609547,	-0.657519,	-0.442856),
	vector.new(-0.753442,	-0.657515,	0.000000),
	vector.new(-0.525730,	-0.850652,	0.000000),
	vector.new(-0.251147,	-0.967949,	0.000000),
	vector.new(-0.483971,	-0.502302,	0.716565),
	vector.new(-0.688189,	-0.525736,	0.499997),
	vector.new(-0.831051,	-0.502299,	0.238853),
	vector.new(-0.232822,	-0.657519,	-0.716563),
	vector.new(-0.162456,	-0.850654,	-0.499995),
	vector.new(-0.077607,	-0.967950,	-0.238853),
	vector.new(-0.831051,	-0.502299,	-0.238853),
	vector.new(-0.688189,	-0.525736,	-0.499997),
	vector.new(-0.483971,	-0.502302,	-0.716565),
	vector.new(-0.029639,	-0.502302,	-0.864184),
	vector.new(0.262869,	-0.525738,	-0.809012),
	vector.new(0.531941,	-0.502302,	-0.681712),
	vector.new(0.956626,	0.251149,	0.147618),
	vector.new(0.951058,	-0.000000,	0.309013),
	vector.new(0.860698,	-0.251151,	0.442858),
	vector.new(0.860698,	-0.251151,	-0.442858),
	vector.new(0.951058,	0.000000,	-0.309013),
	vector.new(0.956626,	0.251149,	-0.147618),
	vector.new(0.155215,	0.251152,	0.955422),
	vector.new(0.000000,	-0.000000,	1.000000),
	vector.new(-0.155215,	-0.251152,	0.955422),
	vector.new(0.687159,	-0.251152,	0.681715),
	vector.new(0.587786,	0.000000,	0.809017),
	vector.new(0.436007,	0.251152,	0.864188),
	vector.new(-0.860698,	0.251151,	0.442858),
	vector.new(-0.951058,	-0.000000,	0.309013),
	vector.new(-0.956626,	-0.251149,	0.147618),
	vector.new(-0.436007,	-0.251152,	0.864188),
	vector.new(-0.587786,	0.000000,	0.809017),
	vector.new(-0.687159,	0.251152,	0.681715),
	vector.new(-0.687159,	0.251152,	-0.681715),
	vector.new(-0.587786,	-0.000000,	-0.809017),
	vector.new(-0.436007,	-0.251152,	-0.864188),
	vector.new(-0.956626,	-0.251149,	-0.147618),
	vector.new(-0.951058,	0.000000,	-0.309013),
	vector.new(-0.860698,	0.251151,	-0.442858),
	vector.new(0.436007,	0.251152,	-0.864188),
	vector.new(0.587786,	-0.000000,	-0.809017),
	vector.new(0.687159,	-0.251152,	-0.681715),
	vector.new(-0.155215,	-0.251152,	-0.955422),
	vector.new(0.000000,	0.000000,	-1.000000),
	vector.new(0.155215,	0.251152,	-0.955422),
	vector.new(0.831051,	0.502299,	0.238853),
	vector.new(0.688189,	0.525736,	0.499997),
	vector.new(0.483971,	0.502302,	0.716565),
	vector.new(0.029639,	0.502302,	0.864184),
	vector.new(-0.262869,	0.525738,	0.809012),
	vector.new(-0.531941,	0.502302,	0.681712),
	vector.new(-0.812729,	0.502301,	0.295238),
	vector.new(-0.850648,	0.525736,	0.000000),
	vector.new(-0.812729,	0.502301,	-0.295238),
	vector.new(-0.531941,	0.502302,	-0.681712),
	vector.new(-0.262869,	0.525738,	-0.809012),
	vector.new(0.029639,	0.502302,	-0.864184),
	vector.new(0.483971,	0.502302,	-0.716565),
	vector.new(0.688189,	0.525736,	-0.499997),
	vector.new(0.831051,	0.502299,	-0.238853),
	vector.new(0.077607,	0.967950,	0.238853),
	vector.new(0.162456,	0.850654,	0.499995),
	vector.new(0.232822,	0.657519,	0.716563),
	vector.new(0.753442,	0.657515,	0.000000),
	vector.new(0.525730,	0.850652,	0.000000),
	vector.new(0.251147,	0.967949,	0.000000),
	vector.new(-0.203181,	0.967950,	0.147618),
	vector.new(-0.425323,	0.850654,	0.309011),
	vector.new(-0.609547,	0.657519,	0.442856),
	vector.new(-0.203181,	0.967950,	-0.147618),
	vector.new(-0.425323,	0.850654,	-0.309011),
	vector.new(-0.609547,	0.657519,	-0.442856),
	vector.new(0.077607,	0.967950,	-0.238853),
	vector.new(0.162456,	0.850654,	-0.499995),
	vector.new(0.232822,	0.657519,	-0.716563),
	vector.new(0.361800,	0.894429,	-0.262863),
	vector.new(0.638194,	0.723610,	-0.262864),
	vector.new(0.447209,	0.723612,	-0.525728),
	vector.new(-0.138197,	0.894430,	-0.425319),
	vector.new(-0.052790,	0.723612,	-0.688185),
	vector.new(-0.361804,	0.723612,	-0.587778),
	vector.new(-0.447210,	0.894429,	0.000000),
	vector.new(-0.670817,	0.723611,	-0.162457),
	vector.new(-0.670817,	0.723611,	0.162457),
	vector.new(-0.138197,	0.894430,	0.425319),
	vector.new(-0.361804,	0.723612,	0.587778),
	vector.new(-0.052790,	0.723612,	0.688185),
	vector.new(0.361800,	0.894429,	0.262863),
	vector.new(0.447209,	0.723612,	0.525728),
	vector.new(0.638194,	0.723610,	0.262864),
	vector.new(0.861804,	0.276396,	-0.425322),
	vector.new(0.809019,	0.000000,	-0.587782),
	vector.new(0.670821,	0.276397,	-0.688189),
	vector.new(-0.138199,	0.276397,	-0.951055),
	vector.new(-0.309016,	-0.000000,	-0.951057),
	vector.new(-0.447215,	0.276397,	-0.850649),
	vector.new(-0.947213,	0.276396,	-0.162458),
	vector.new(-1.000000,	0.000001,	0.000000),
	vector.new(-0.947213,	0.276397,	0.162458),
	vector.new(-0.447216,	0.276397,	0.850648),
	vector.new(-0.309017,	-0.000001,	0.951056),
	vector.new(-0.138199,	0.276397,	0.951055),
	vector.new(0.670820,	0.276396,	0.688190),
	vector.new(0.809019,	-0.000002,	0.587783),
	vector.new(0.861804,	0.276394,	0.425323),
	vector.new(0.309017,	-0.000000,	-0.951056),
	vector.new(0.447216,	-0.276398,	-0.850648),
	vector.new(0.138199,	-0.276398,	-0.951055),
	vector.new(-0.809018,	-0.000000,	-0.587783),
	vector.new(-0.670819,	-0.276397,	-0.688191),
	vector.new(-0.861803,	-0.276396,	-0.425324),
	vector.new(-0.809018,	0.000000,	0.587783),
	vector.new(-0.861803,	-0.276396,	0.425324),
	vector.new(-0.670819,	-0.276397,	0.688191),
	vector.new(0.309017,	0.000000,	0.951056),
	vector.new(0.138199,	-0.276398,	0.951055),
	vector.new(0.447216,	-0.276398,	0.850648),
	vector.new(1.000000,	0.000000,	0.000000),
	vector.new(0.947213,	-0.276396,	0.162458),
	vector.new(0.947213,	-0.276396,	-0.162458),
	vector.new(0.361803,	-0.723612,	-0.587779),
	vector.new(0.138197,	-0.894429,	-0.425321),
	vector.new(0.052789,	-0.723611,	-0.688186),
	vector.new(-0.447211,	-0.723612,	-0.525727),
	vector.new(-0.361801,	-0.894429,	-0.262863),
	vector.new(-0.638195,	-0.723609,	-0.262863),
	vector.new(-0.638195,	-0.723609,	0.262864),
	vector.new(-0.361801,	-0.894428,	0.262864),
	vector.new(-0.447211,	-0.723610,	0.525729),
	vector.new(0.670817,	-0.723611,	-0.162457),
	vector.new(0.670818,	-0.723610,	0.162458),
	vector.new(0.447211,	-0.894428,	0.000001),
	vector.new(0.052790,	-0.723612,	0.688185),
	vector.new(0.138199,	-0.894429,	0.425321),
	vector.new(0.361805,	-0.723611,	0.587779),
}
-- Pre-multiply the range into these unit vectors
for i, pos in ipairs(ico3) do
	ico3[i] = vector.multiply(pos, mega_bomb_range)
end

local function find_target(raycast)
	local next_pointed = raycast:next()
	while next_pointed do
		local under_pos = next_pointed.under
		local under_node = minetest.get_node(under_pos)
		local under_def = minetest.registered_nodes[under_node.name]
		local above_pos = next_pointed.above
		local above_node = minetest.get_node(above_pos)
		local above_def = minetest.registered_nodes[above_node.name]

		if above_def.buildable_to and not under_def.buildable_to then
			return next_pointed
		end
		
		next_pointed  = raycast:next(next_pointed)
	end
end

local torch_def_on_place
minetest.after(0, function()
	torch_def_on_place = minetest.registered_nodes[torch_item].on_place
end)

local function kerblam(pos, placer, dirs, min_range)
	pos = vector.round(pos)
	local targets = {}
	for _, pos2 in ipairs(dirs) do
		local raycast = minetest.raycast(pos, vector.add(pos, pos2), false, true)
		local target_pointed = find_target(raycast)
		if target_pointed then
			if vector.distance(pos, target_pointed.above) > min_range then
				table.insert(targets, target_pointed)
			end
		end
	end

	if not placer then
		placer = fakeplayer
		fakeplayer:update(pos, "torch_bomb")
	end
	
	minetest.log("action", placer:get_player_name() .. " detonated a torch bomb at " ..
		minetest.pos_to_string(pos) .. " and placed " .. #targets .. " torches.")

	for _, target in ipairs(targets) do
		if minetest.get_item_group(minetest.get_node(target.above).name, "torch") == 0 then -- TODO remove this check after culling close-together targets
			torch_def_on_place(ItemStack(torch_item), placer, target)
			local target_pos = target.above
			local dir_back = vector.normalize(vector.subtract(pos, target_pos))
			local vel_back = vector.multiply(dir_back, 10)
			minetest.add_particlespawner({
				amount = math.random(1,6),
				time = 0.1,
				minpos = target_pos,
				maxpos = target_pos,
				minvel = vector.subtract(dir_back, 2),
				maxvel = vector.add(dir_back, 2),
				minacc = {x=0, y=-9, z=0},
				maxacc = {x=0, y=-9, z=0},
				minexptime = 1,
				maxexptime = 2,
				minsize = 1,
				maxsize = 2,
				collisiondetection = true,
				collision_removal = false,
				texture = "torch_bomb_shard.png",
			})
		end
	end	
end

local player_setting_fuse_at = {}

local function rocket_formspec(fuse_length)
	return "formspec_version[2]"..
		"size[4,2]"..
		"label[0.25,0.25;" .. S("Rocket accelerates at 1 m/s^2.\nFuse duration from 1 to @1 seconds:", rocket_max_fuse) .. "]"..
		"field[0.75,1;1,0.5;seconds;;"..fuse_length.."]"..
		"button_exit[2.5,1;0.5,0.5;set;"..S("Set").."]"
end

local function rocket_effects(obj, fuse)
	minetest.add_particlespawner({
		amount = 100*fuse,
		time = fuse,
		minpos = {x=0, y=0, z=0},
		maxpos = {x=0, y=0, z=0},
		minvel = {x=-1, y=-10, z=-1},
		maxvel = {x=1, y=-12, z=1},
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1,
		maxexptime = 1,
		minsize = 3,
		maxsize = 3,
		collisiondetection = true,
		collision_removal = true,
		attached = obj,
		texture = "smoke_puff.png",
		glow = 8
	})
end

if enable_rockets then
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname == "torch_bomb:torch_rocket" then
			local player_name = player:get_player_name()
			local pos = player_setting_fuse_at[player_name]
			local seconds = tonumber(fields.seconds or "")
			
			if not pos or not seconds then
				player_setting_fuse_at[player_name] = nil
				return
			end
			local node = minetest.get_node(pos)
			if minetest.get_item_group(node.name, "torch_bomb_rocket") == 0 then
				player_setting_fuse_at[player_name] = nil
				return
			end
			player_setting_fuse_at[player_name] = nil
			seconds = math.max(math.min(seconds, rocket_max_fuse), 1)
			local meta = minetest.get_meta(pos)
			meta:set_string("fuse", seconds)
		end
	end)
end

local function register_torch_bomb(name, desc, dirs, min_range, blast_radius, texture)

	local side_texture = "torch_bomb_side_base.png^"..texture

	minetest.register_node("torch_bomb:" .. name, {
		description = desc,
		drawtype = "normal", 
		tiles = {"torch_bomb_top.png", "torch_bomb_bottom.png", side_texture},
		paramtype = "light",
		paramtype2 = "facedir",
		
		groups = {tnt = 1, oddly_breakable_by_hand = 1},
		
		on_punch = function(pos, node, puncher)
			if puncher:get_wielded_item():get_name() == "default:torch" then
				minetest.set_node(pos, {name = "torch_bomb:"..name.."_burning"})
				minetest.get_meta(pos):set_string("torch_bomb_ignitor", puncher:get_player_name())
				minetest.log("action", puncher:get_player_name() .. " ignites " .. node.name .. " at " ..
					minetest.pos_to_string(pos))
			end
		end,
	
		on_ignite = function(pos) -- used by TNT mod
			minetest.set_node(pos, {name = "torch_bomb:"..name.."_burning"})
		end,
	})
	
	minetest.register_node("torch_bomb:"..name.."_burning", {
		description = desc,
		drawtype = "normal",  -- See "Node drawtypes"
		tiles = {{
				name = "torch_bomb_top_burning_animated.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 1,
				}
			},
			"torch_bomb_bottom.png", side_texture},
		groups = {falling_node = 1, not_in_creative_inventory = 1},
		paramtype = "light",
		paramtype2 = "facedir",
		light_source = 6,
		
		on_construct = function(pos)
			if tnt_modpath then
				minetest.sound_play("tnt_ignite", {pos = pos})
			end
			minetest.get_node_timer(pos):start(3)
		end,
		
		on_timer = function(pos, elapsed)
			local ignitor_name = minetest.get_meta(pos):get("torch_bomb_ignitor")
			local puncher
			if ignitor_name then
				puncher = minetest.get_player_by_name(ignitor_name)
			end
			minetest.set_node(pos, {name="air"})
			if tnt_modpath then
				tnt.boom(pos, {radius=blast_radius, damage_radius=blast_radius+3})
			end
			kerblam(pos, puncher, dirs, min_range)
		end,
	})
	
	if not enable_rockets then
		return
	end
	
	local rocket_bottom_texture = "torch_bomb_bottom.png^torch_bomb_rocket_bottom.png"
	local rocket_side_texture = side_texture .. "^torch_bomb_rocket_side.png"
	
	local function entity_detonate(player_name, target)
		--minetest.chat_send_all("entity detonate " .. (player_name or "") .. " " .. minetest.pos_to_string(target))
		local player
		if player_name then
			player = minetest.get_player_by_name(player_name)
		end
		if tnt_modpath then
			tnt.boom(target, {radius=blast_radius, damage_radius=blast_radius+3})
		end
		kerblam(target, player, dirs, min_range)
	end
	
	minetest.register_entity("torch_bomb:"..name.."_rocket_entity", {
		initial_properties = {
			physical = false,
			visual = "cube",
			--visual_size = {x=0.5, y=0.5},
			textures = {"torch_bomb_top.png", rocket_bottom_texture .. "^torch_bomb_rocket_bottom_lit.png",
				rocket_side_texture, rocket_side_texture, rocket_side_texture, rocket_side_texture},
			collisionbox = {0,0,0,0,0,0},
			glow = 8,
		},

		on_activate = function(self, staticdata, dtime_s)
			if staticdata == "detonated" then
				self.object:remove()
			end
		end,
		
		get_staticdata = function(self)
			local target = self.target
			if target then
				-- we're unloading an active rocket, skip ahead to detonation point
				local pos = self.object:get_pos()
				local raycast = minetest.raycast(pos, target, false, true)
				local target_pointed = find_target(raycast)
				if target_pointed then
					target = target_pointed.above
				end
				minetest.after(self.fuse, entity_detonate, self.player_name, target)
				return "detonated"
			end
		end,
		
		on_step = function(self, dtime)
			local object = self.object
			local lastpos = self.lastpos
		
			local pos = object:get_pos()
			local node = minetest.get_node(pos)
			local luaentity = object:get_luaentity()
			local old_fuse = luaentity.fuse or -1
			local new_fuse = old_fuse - dtime
			luaentity.fuse = new_fuse
			if math.floor(old_fuse) ~= math.floor(new_fuse) then
				-- should happen once per second
				minetest.sound_play({name="tnt_gunpowder_burning"}, {
					object = object,
					gain = 1.0,
					max_hear_distance = 32,
				})
			end
	
			if lastpos and (node.name ~= "air" or luaentity.fuse < 0) then
				lastpos = vector.round(lastpos)
				local player_name = luaentity.player_name
				object:remove()
				entity_detonate(player_name, lastpos)
			end
			self.lastpos={x=pos.x, y=pos.y, z=pos.z}
		end,
	})

	minetest.register_node("torch_bomb:"..name.."_rocket", {
		description = S("@1 Rocket", desc),
		drawtype = "normal", 
		tiles = {"torch_bomb_top.png", rocket_bottom_texture, rocket_side_texture},
		paramtype = "light",
		paramtype2 = "facedir",
	
		groups = {tnt = 1, oddly_breakable_by_hand = 1, torch_bomb_rocket = 1},
	
		on_punch = function(pos, node, puncher)
			if puncher:get_wielded_item():get_name() == "default:torch" then
				local fuse = minetest.get_meta(pos):get("fuse")
				minetest.set_node(pos, {name = "torch_bomb:"..name.."_rocket_burning"})
				local meta = minetest.get_meta(pos)
				meta:set_string("torch_bomb_ignitor", puncher:get_player_name())
				meta:set_string("fuse", fuse)
				minetest.log("action", puncher:get_player_name() .. " ignites " .. node.name .. " at " ..
					minetest.pos_to_string(pos))
			end
		end,
	
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			local meta = minetest.get_meta(pos)
			local fuse_length = tonumber(meta:get_string("fuse")) or default_fuse
			local player_name = clicker:get_player_name()
			player_setting_fuse_at[player_name] = pos
			minetest.show_formspec(player_name, "torch_bomb:torch_rocket", rocket_formspec(fuse_length))
		end,

		on_ignite = function(pos) -- used by TNT mod
			local fuse = minetest.get_meta(pos):get("fuse")
			minetest.set_node(pos, {name = "torch_bomb:"..name.."_rocket_burning"})
			minetest.get_meta(pos):set_string("fuse", fuse)
		end,
	})
	
	minetest.register_node("torch_bomb:"..name.."_rocket_burning", {
		description = S("@1 Rocket", desc),
		drawtype = "normal",
		tiles = {{
				name = "torch_bomb_top_burning_animated.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 1,
				}
			},
			rocket_bottom_texture, rocket_side_texture},
		groups = {falling_node = 1, not_in_creative_inventory = 1},
		paramtype = "light",
		paramtype2 = "facedir",
		light_source = 6,
	
		on_construct = function(pos)
			if tnt_modpath then
				minetest.sound_play("tnt_ignite", {pos = pos})
			end
			minetest.get_node_timer(pos):start(3)
		end,
	
		on_timer = function(pos, elapsed)
			local meta = minetest.get_meta(pos)
			local ignitor_name = meta:get("torch_bomb_ignitor")
			local fuse = tonumber(meta:get_string("fuse")) or default_fuse
			minetest.set_node(pos, {name="air"})
	
			local obj = minetest.add_entity(pos, "torch_bomb:"..name.."_rocket_entity")
			obj:set_acceleration({x=0, y=1, z=0})
			local lua_entity = obj:get_luaentity()
			lua_entity.player_name = ignitor_name
			lua_entity.fuse = fuse
			
			local range = 0.5 * fuse * fuse -- s = vi * t + (1/2)*a*t*t
			pos.y = pos.y + range
			lua_entity.target = pos
			rocket_effects(obj, fuse)
		end,
	})
end

register_torch_bomb("torch_bomb", S("Torch Bomb"), ico2, 5, 1, "torch_bomb_one_torch.png")
register_torch_bomb("mega_torch_bomb", S("Mega Torch Bomb"), ico3, 15, 3, "torch_bomb_three_torches.png")

-----------------------------------------------------------------------------------------------------------------
-- Throwable torch grenade

if enable_grenade then

	local throw_velocity = 20
	local gravity = {x=0, y=-9.81, z=0}
	
	minetest.register_craftitem("torch_bomb:torch_grenade", {
		description = S("Torch Grenade"),
		inventory_image = "torch_bomb_torch_grenade.png",
		on_use = function(itemstack, user, pointed_thing)
			local player_pos = user:get_pos()
			local obj = minetest.add_entity({x = player_pos.x, y = player_pos.y + 1.5, z = player_pos.z}, "torch_bomb:torch_grenade_entity")
			local dir = user:get_look_dir()
			obj:set_velocity(vector.multiply(dir, throw_velocity))
			obj:set_acceleration(gravity)
			obj:set_yaw((user:get_look_horizontal() + math.pi/2)+math.pi)
			local lua_entity = obj:get_luaentity()
			lua_entity.player_name = user:get_player_name()
			
			minetest.sound_play({name="tnt_ignite"},
			{
				object = object,
				gain = 1.0,
				max_hear_distance = 32,
			})
			
			if not minetest.settings:get_bool("creative_mode") and not minetest.check_player_privs(user, "creative") then
				itemstack:set_count(itemstack:get_count() - 1)
			end
			
			return itemstack
		end
	})
	
	minetest.register_entity("torch_bomb:torch_grenade_entity", {
		initial_properties = {
			physical = false,
			visual = "sprite",
			visual_size = {x=0.5, y=0.5},
			textures = {"torch_bomb_torch_grenade.png"},
			collisionbox = {0,0,0,0,0,0},
			glow = 8,
		},
		
		on_activate = function(self, staticdata, dtime_s)
			self.player_name = staticdata
		end,
		get_staticdata = function(self)
			return self.player_name
		end,
		
		on_step = function(self, dtime)
			local object = self.object
			local lastpos = self.lastpos
		
			local pos = object:get_pos()
			local node = minetest.get_node(pos)
	
			if lastpos ~= nil and node.name ~= "air" then
				lastpos = vector.round(lastpos)
				local luaentity = object:get_luaentity()
				local player_name = luaentity.player_name
				local player
				if player_name then
					player = minetest.get_player_by_name(player_name)
				end
				object:remove()
				if tnt_modpath then
					tnt.boom(lastpos, {radius=1, damage_radius=2})
				end
				kerblam(lastpos, player, ico1, 2)
			end
			self.lastpos={x=pos.x, y=pos.y, z=pos.z}
		end,
	})
end

----------------------------------------------------------------------
-- Crafting

if enable_tnt and tnt_modpath then
	minetest.register_craft({
		output = "torch_bomb:torch_grenade",
		recipe = {
			{'default:coalblock'},
			{'group:wood'},
			{'tnt:tnt_stick'},
		},
	})

	minetest.register_craft({
		output = "torch_bomb:torch_bomb",
		recipe = {
			{'default:coalblock', 'default:coalblock', 'default:coalblock'},
			{'group:wood', 'group:wood', 'group:wood'},
			{'tnt:tnt_stick', 'tnt:tnt_stick', 'tnt:tnt_stick'},
		},
	})
	
	minetest.register_craft({
		type = "shapeless",
		output = "torch_bomb:mega_torch_bomb",
		recipe = {"torch_bomb:torch_bomb", "torch_bomb:torch_bomb", "torch_bomb:torch_bomb"},
	})
	
	minetest.register_craft({
		type = "shapeless",
		output = "torch_bomb:torch_bomb 3",
		recipe = {"torch_bomb:mega_torch_bomb"},
	})
	
	if enable_grenade then

		minetest.register_craft({
			type = "shapeless",
			output = "torch_bomb:torch_bomb",
			recipe = {"torch_bomb:torch_grenade", "torch_bomb:torch_grenade", "torch_bomb:torch_grenade"},
		})
	
		minetest.register_craft({
			type = "shapeless",
			output = "torch_bomb:torch_grenade 3",
			recipe = {"torch_bomb:torch_bomb"},
		})
	end
	
	if enable_rockets then
		minetest.register_craft({
			type = "shapeless",
			output = "torch_bomb:torch_bomb_rocket",
			recipe = {"torch_bomb:torch_bomb", "tnt:tnt"},
		})

		minetest.register_craft({
			type = "shapeless",
			output = "torch_bomb:mega_torch_bomb_rocket",
			recipe = {"torch_bomb:mega_torch_bomb", "tnt:tnt"},
		})	
	end
end
