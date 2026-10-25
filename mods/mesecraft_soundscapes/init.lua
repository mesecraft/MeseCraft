-- 
local max_frequency_all = 8000 --the larger you make this number the less frequent ALL sounds will happen recommended values between 100-2000.


-- Soundscape configurations
	--for frequencies, use a number between 0 and max_frequency_all
	--for volumes, use a number between 0.0 and 1, the larger the number the louder the sounds
local night_frequency = 85  --crickets
local night_volume = 0.4
local night_frequent_frequency = 160  --owls, wolves, crows
local night_frequent_volume = 0.7
local day_frequency = 70  --misc birds
local day_volume = 0.4 
local day_frequent_frequency = 200  --robin, bluejay, cardinal
local day_frequent_volume = 0.18
local cave_frequency = 6  --about every 5 minutes, scary cave sounds
local cave_volume = 0.9  
local cave_frequent_frequency = 150  --drops of water dripping
local cave_frequent_volume = 0.8
local beach_frequency = 75  --seagulls
local beach_volume = 0.4 
local beach_frequent_frequency = max_frequency_all  --waves
local beach_frequent_volume = 0.3 
local water_frequent_frequency = max_frequency_all  --water sounds
local water_frequent_volume = 0.6
local desert_frequency = 20  --coyote
local desert_volume = 0.6
local desert_frequent_frequency = max_frequency_all  --desertwind
local desert_frequent_volume = 0.6
local swimming_frequent_frequency = 0  --swimming splashes
local swimming_frequent_volume = 0
local water_surface_volume = 0   -- sloshing water
local lava_volume = 1 --lava
local flowing_water_volume = 0.4  --waterfall
local splashing_water_volume = 0.4
local pos, minp, maxp, temp, humid, nodes, height, minheight, grad, yint, desert_in_range, node_at_upper_body


-- Variable declarations
local ambiences
local counter=0
local SOUNDVOLUME = 0.5
local sound_vol = 1
local last_x_pos = 0
local last_y_pos = 0
local last_z_pos = 0
local node_under_feet
local node_at_upper_body
local node_at_lower_body
local node_3_under_feet



-- Soundscape definitions
local night = {
	name = "night",
	handler = {},
	fading = {},
	started = {},
	--on_start = "horned_owl",
	frequency = night_frequency,
	{name="Crickets_At_NightCombo", length=47, gain=night_frequent_volume},
}

local night_frequent = {
	name = "night_frequent",
	handler = {},
	fading = {},
	started = {},
	frequency = night_frequent_frequency,
	{name="horned_owl", length=3, gain=night_volume},
	{name="Wolves_Howling", length=11,  gain=night_volume},
	{name="craw", length=3, gain=night_volume},
}

local day = {
	name = "day",
	handler = {},
	fading = {},
	started = {},
	--on_start = "Best_Cardinal_Bird",
	frequency = day_frequency,
	{name="birdsongnl", length=13, gain=day_frequent_volume},
	{name="bird", length=30, gain=day_frequent_volume},
}

local day_frequent = {
	name = "day_frequent",
	handler = {},
	fading = {},
	started = {},
	frequency = day_frequent_frequency,
	{name="robin2", length=16, gain=day_frequent_volume},
	{name="bluejay", length=18, gain=day_frequent_volume},
	{name="Best_Cardinal_Bird", length=4, gain=day_frequent_volume},
}
--[[local swimming_frequent = {
	handler = {},
	frequency = 0,
	{name="water_swimming_splashing_breath", length=11.5, gain=swimming_frequent_volume},
	{name="water_swimming_splashing", length=9, gain=swimming_frequent_volume}
}]]

local cave = {
	name = "cave",
	handler = {},
	fading = {},
	started = {},
	frequency = cave_frequency,
	{name="cave_scary_1", length=10, gain=cave_volume},
	{name="cave_scary_2", length=21, gain=cave_volume},
	{name="cave_scary_3", length=5, gain=cave_volume},
	{name="cave_scary_4", length=9, gain=cave_volume},
	{name="cave_scary_5", length=6, gain=cave_volume},
	{name="cave_scary_6", length=31, gain=cave_volume},
	{name="cave_scary_7", length=11, gain=cave_volume},
	{name="cave_scary_8", length=11, gain=cave_volume},
	{name="cave_scary_9", length=6, gain=cave_volume},
	{name="cave_scary_10", length=17, gain=cave_volume},
	{name="cave_scary_11", length=51, gain=cave_volume},
	{name="cave_scary_12", length=18, gain=cave_volume},
	{name="cave_scary_13", length=34, gain=cave_volume},
	{name="cave_scary_14", length=7, gain=cave_volume},
	{name="cave_scary_15", length=6, gain=cave_volume},
	{name="cave_scary_16", length=5, gain=cave_volume},
	{name="cave_scary_17", length=8, gain=cave_volume},
	{name="cave_scary_18", length=7, gain=cave_volume},
	{name="cave_scary_19", length=7, gain=cave_volume},
	{name="cave_scary_20", length=13, gain=cave_volume},
	{name="cave_scary_21", length=20, gain=cave_volume},
	{name="cave_scary_22", length=6, gain=cave_volume},
}

local cave_frequent = {
	name = "cave_frequent",
	handler = {},
	fading = {},
	started = {},
	frequency = cave_frequent_frequency,
	{name="drippingwater_drip_a", length=2, gain=cave_frequent_volume},
	{name="drippingwater_drip_b", length=2, gain=cave_frequent_volume},
	{name="drippingwater_drip_c", length=2, gain=cave_frequent_volume},
	{name="Single_Water_Droplet", length=3, gain=cave_frequent_volume},
	{name="Spooky_Water_Drops", length=7, gain=cave_frequent_volume},
	{name="cave_dust_fall", length=3, gain=cave_frequent_volume},
	{name="cave_crumble_2", length=3, gain=cave_frequent_volume},
	{name="cave_crumble_10", length=2, gain=cave_frequent_volume},
	{name="cave_crumble_12", length=2, gain=cave_frequent_volume},
}

local beach = {
	name = "beach",
	handler = {},
	fading = {},
	started = {},
	frequency = beach_frequency,
	{name="seagull", length=19.5, gain=beach_volume}
}

local beach_frequent = {
	name = "beach_frequent",
	handler = {},
	fading = {},
	started = {},
	frequency = beach_frequent_frequency,
	{name="ambience_soundscape_beach", length=170, gain=beach_frequent_volume}
}

local desert = {
	name = "desert",
	handler = {},
	fading = {},
	started = {},
	frequency = desert_frequency,
	{name="coyote2", length=2.5, gain=desert_volume},
	{name="RattleSnake", length=8, gain=desert_volume}
}

local desert_frequent = {
	name = "desert_frequent",
	handler = {},
	fading = {},
	started = {},
	frequency = desert_frequent_frequency,
	{name="DesertMonolithMed", length=34.5, gain=desert_frequent_volume}
}
--[[
local flying = {
	handler = {},
	frequency = 8000,
	on_start = "nothing_yet",
	on_stop = "nothing_yet",
	{name="ComboWind", length=17,  gain=1}
}

local water = {
	handler = {},
	frequency = 0,--dolphins dont fit into small lakes
	{name="dolphins", length=6, gain=1},
	{name="dolphins_screaming", length=16.5, gain=1}
}
]]
local water_frequent = {
	name = "water_frequent",
	handler = {},
	fading = {},
	started = {},
	gain = water_frequent_volume,
	frequency = water_frequent_frequency,
	on_stop = "drowning_gasp",
	--on_start = "Splash",
	{name="scuba1bubbles", length=11, gain=water_frequent_volume},
	{name="scuba1calm", length=10, gain=water_frequent_volume},  --not sure why but sometimes I get errors when setting gain=water_frequent_volume here.
	{name="scuba1calm2", length=8.5, gain=water_frequent_volume},
	{name="scuba1interestingbubbles", length=11, gain=water_frequent_volume},
	{name="scuba1tubulentbubbles", length=10.5, gain=water_frequent_volume}
}
--[[
local water_surface = {
	handler = {},
	frequency = max_frequency_all,
	{name="lake_waves_2_calm", length=9.5, gain=water_surface_volume},
	{name="lake_waves_2_variety", length=13.1, gain=water_surface_volume}
}
local splashing_water = {
	handler = {},
	frequency = 0,
	{name="Splash_disabled_too_buggy", length=1.22, gain=splashing_water_volume}
}

local flowing_water = {
	handler = {},
	frequency = 0,
	{name="small_waterfall_disabled_too_buggy", length=14, gain=flowing_water_volume}
}
local flowing_water2 = {
	handler = {},
	frequency = 0,
	{name="small_waterfall_disabled_too_buggy", length=11, gain=flowing_water_volume}
}]]

local lava = {
	name = "lava",
	handler = {},
	fading = {},
	started = {},
	gain = lava_volume,
	frequency = max_frequency_all,
	{name="earth01a", length=20, gain=lava_volume}
}
local lava2 = {
	name = "lava2",
	handler = {},
	fading = {},
	started = {},
	gain = lava_volume,
	frequency = max_frequency_all,
	{name="earth01a", length=15, gain=lava_volume}
}

-- Function to check if it is daytime.
local is_daytime = function()
	return (minetest.get_timeofday() > 0.2 and  minetest.get_timeofday() < 0.8)
end

-- Function to get the nodes that are within a range
local nodes_in_range = function(pos, search_distance, node_name)
	minp = {x=pos.x-search_distance,y=pos.y-search_distance, z=pos.z-search_distance}
	maxp = {x=pos.x+search_distance,y=pos.y+search_distance, z=pos.z+search_distance}
	nodes = minetest.find_nodes_in_area(minp, maxp, node_name)
	--minetest.chat_send_all("Found (" .. node_name .. ": " .. #nodes .. ")")
	return #nodes
end

-- Function to find the nodes in an area.
local nodes_in_coords = function(minp, maxp, node_name)
	nodes = minetest.find_nodes_in_area(minp, maxp, node_name)
	--minetest.chat_send_all("Found (" .. node_name .. ": " .. #nodes .. ")")
	return #nodes
end

-- Function to determine if there are at least this many nodes in a grid area.
local atleast_nodes_in_grid = function(minp, maxp, node_name, threshold)
	height = maxp.y
	minheight = minp.y
	local totalnodes = 0
	local nodes
	while height >= minheight do
		minp.y = height
		maxp.y = height
		nodes = minetest.find_nodes_in_area(minp, maxp, node_name)
		height = height - 1
		if #nodes >= threshold then
			return true
		end
		totalnodes = totalnodes + #nodes
		if totalnodes >= threshold then
			return true
		end
		
	end
	return false
end


local humidmap = nil
local tempmap = nil

-- Function to determine the node light level in a postision.
local function is_skylit(pos)
	return (minetest.get_node_light(pos, 0.5) ~= minetest.get_node_light(pos, 0))
end

-- Function to get the ambience of a player.
local get_ambience = function(player)
	--[[local player_is_climbing = false
	local player_is_descending = false
	local player_is_moving_horiz = false
	local standing_in_water = false]]
	local pos = player:get_pos()
	local skylit = is_skylit(pos)
	node_at_upper_body = minetest.registered_nodes[minetest.get_node(vector.add(pos, {x=0,y=1.2,z=0})).name]
	
	
	--Thanks/credit to the snowdrift mod for these calculations.
	humidmap = humidmap or minetest.get_perlin({
		offset = 50,
		scale = 50,
		spread = {x = 1000, y = 1000, z = 1000},
		seed = 842,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2.0,
		flags = "defaults"
	})
	
	tempmap = tempmap or minetest.get_perlin({
		offset = 50,
		scale = 50,
		spread = {x = 1000, y = 1000, z = 1000},
		seed = 5349,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2.0,
		flags = "defaults"
	})
	temp = tempmap:get_2d({x = math.floor(pos.x+0.5), y = math.floor(pos.z+0.5)}) - pos.y*(20 / 90)
	humid = humidmap:get_2d({x = math.floor(pos.x+0.5), y = math.floor(pos.z+0.5)})
	
	if node_at_upper_body and node_at_upper_body.liquidtype ~= "none" then
		if music then
			return {water_frequent=water_frequent, music=music}
		else
			return {water_frequent=water_frequent}
		end
	end

	if nodes_in_range(pos, 7, "default:lava_flowing")>5 or nodes_in_range(pos, 7, "default:lava_source")>5 or
		nodes_in_range(pos, 7, "dfcaverns:mantle_flowing")>5 or nodes_in_range(pos, 7, "dfcaverns:mantle_source")>5
	then
		if music then
			return {lava=lava, music=music}		
		else
			return {lava=lava}
		end
	end


	--if we are near sea level and there is lots of water around the area
	if pos.y > -10 and pos.y < 32 and atleast_nodes_in_grid({x=pos.x-21, y=-10, z=pos.z-21}, {x=pos.x+21, y=1, z=pos.z+21}, "default:water_source", 140 ) then
		if temp > 30 then --Frozen = no seagulls
			if music then
				return {beach=beach, beach_frequent=beach_frequent, music=music}
			else
				return {beach=beach, beach_frequent=beach_frequent}
			end
		else 
			if music then
				return {beach_frequent=beach_frequent, music=music}
			else
				return {beach_frequent=beach_frequent}
			end
		end
	end
	--[[if standing_in_water then
		if music then
			return {water_surface=water_surface, music=music}
		else
			return {water_surface}
		end	
	end]]
	grad = 14 / 95
	yint = 1496 / 95
	desert_in_range = pos.y > -32 and humid - grad * temp < yint
	
	
	if desert_in_range then
		if music then
			return {desert=desert, desert_frequent=desert_frequent, music=music}
		else
			return {desert=desert, desert_frequent=desert_frequent}
		end
	end	


	if pos.y > 128 and pos.y < 1000 and skylit then -- Play desert wind at really high altitude for an icy wind effect
		if music then
			return {desert_frequent=desert_frequent, music=music}
		else
			return {desert_frequent=desert_frequent}
		end
	end	
	
	if player:get_pos().y < 0 and not skylit then
		if music then
			return {cave=cave, cave_frequent=cave_frequent, music=music}
		else
			return {cave=cave, cave_frequent=cave_frequent}
		end
	end
	
	if skylit 
		and temp > 30
	then
		if is_daytime()	then
			if music then
				return {day=day, day_frequent=day_frequent, music=music}
			else
				return {day=day, day_frequent=day_frequent}
			end
		else
			if music then
				return {night=night, night_frequent=night_frequent, music=music}
			else
				return {night=night, night_frequent=night_frequent}
			end
		end
	end
	if music then
		return {music=music}
	else
		return {}
	end
end

-- start playing the sound, set the handler and delete the handler after sound is played
local play_sound = function(player, list, number, is_music)
	local ambience_player_name = player:get_player_name()
	if list.handler[ambience_player_name] == nil then
		local gain = 1.0
		if list[number].gain ~= nil then
			if is_music then 				
				gain = list[number].gain*MUSICVOLUME
				--minetest.chat_send_all("gain music: " .. gain )
			else
				gain = list[number].gain*SOUNDVOLUME 
				--minetest.chat_send_all("gain sound: " .. gain )
			end
		end
		local handler = minetest.sound_play(list[number].name, {to_player=ambience_player_name, gain=gain})
		if handler ~= nil then
			list.handler[ambience_player_name] = handler
			minetest.after(list[number].length, function(args)
				local list = args[1]
				local ambience_player_name = args[2]
				if list.handler[ambience_player_name] ~= nil then
					minetest.sound_stop(list.handler[ambience_player_name])
					list.handler[ambience_player_name] = nil
				end
			end, {list, ambience_player_name})
		end
	end
end


local fade_out_sound = function(list, name)
	if not list.fading[name] then
		list.fading[name] = list[1].gain
		if list.on_stop ~= nil then
			minetest.sound_play(list.on_stop, {to_player=name,gain=SOUNDVOLUME})
		end
	elseif list.fading[name] > 0 then
		list.fading[name] = list.fading[name] - (list[1].gain/4)
		--minetest.chat_send_all("fading "..list.name.." "..list.fading[name])
		minetest.sound_fade(list.handler[name], -(list[1].gain/8), math.max(0, list.fading[name]))
		if list.fading[name] <= 0 then
			minetest.after(0.25, function(list, name)
				--minetest.chat_send_all("stopping "..list.name.." "..(list.fading[name] or "nil"))
				if list.handler[name] then
					minetest.sound_stop(list.handler[name])
				end
				list.handler[name] = nil
				list.fading[name] = nil
			end, list, name)
		end
	end
end

minetest.register_on_leaveplayer(function(player)
	local ambience_player_name = player:get_player_name()
	local lists = {
		cave, 
		cave_frequent, 
		beach, 
		beach_frequent, 
		desert, 
		desert_frequent, 
		night, 
		night_frequent, 
		day, 
		day_frequent, 
		lava, 
		lava2, 
		water_frequent
	}
	for _,list in pairs(lists) do
		if list.handler[ambience_player_name] ~= nil then
			list.handler[ambience_player_name] = nil
		end
		if list.fading[ambience_player_name] ~= nil then
			list.fading[ambience_player_name] = nil
		end
	end
end)

-- Function to stop all sounds that are not in still_playing
local stop_sound = function(still_playing, player, dtime)
	local ambience_player_name = player:get_player_name()
	local lists = {
		cave, 
		cave_frequent, 
		beach, 
		beach_frequent, 
		desert, 
		desert_frequent, 
		night, 
		night_frequent, 
		day, 
		day_frequent, 
		lava, 
		lava2, 
		water_frequent
	}
	for _,list in pairs(lists) do
		if still_playing[list.name] == nil then
			if list.handler[ambience_player_name] ~= nil then
				fade_out_sound(list, ambience_player_name, dtime)
			end
			list.started[ambience_player_name] = nil
		elseif list.handler[ambience_player_name] and list.fading[ambience_player_name] --Un-fade the sound if it started to fade out for some reason
			and list.fading[ambience_player_name] > 0 --Don't rescue sounds that are too far gone
		then
			minetest.sound_fade(list.handler[ambience_player_name], (list[1].gain/4), list[1].gain)
			list.fading[ambience_player_name] = nil
		end
	end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer+dtime
	if timer < 0.5 then
		return
	end
	timer = 0

	for _,player in ipairs(minetest.get_connected_players()) do
		ambiences = get_ambience(player)
		for _,ambience in pairs(ambiences) do
			if (ambience.on_start ~= nil) and not ambience.started[player:get_player_name()] then
				minetest.sound_play(ambience.on_start, {to_player=player:get_player_name(),gain=SOUNDVOLUME})
				ambience.started[player:get_player_name()] = true
			end
		end
		stop_sound(ambiences, player)
		for _,ambience in pairs(ambiences) do
			if math.random(1, max_frequency_all) <= ambience.frequency then			
				local is_music =false
				if ambience.is_music ~= nil then
					is_music = true
				end
				play_sound(player, ambience, math.random(1, #ambience),is_music)
			end
		end
	end
end
)
minetest.register_chatcommand("soundscapes", {
	params = "<soundscapes>",
	description = "set volume of soundscapes, default 0.5 normal volume.",
	privs = {server=true},
	func = function(name, param)
		SOUNDVOLUME = param
		minetest.chat_send_player(name, "Soundscape volume set.")
	end,
})
