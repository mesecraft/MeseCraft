-- Author: Astrobe
-- Animated smoke texture courtesy of Texmex.
-- Version: 0.6
-- License for code: LGPL 2.1
-- License for textures: CC--BY-SA 4.0
--
-- Dokimi's self-organizing systems with its ever-expanding poison gas inspired this less deadly smoke mod.

smoke= {}

-- Library parameters
local ITVL=1 -- how fast smoke moves, in seconds. Smoke is generate at twice this period (so half slower than the smoke moves).
local PERSIST=0.91 -- the chance smokes has *not* to dissipate.
-- This is a very sensitive parameter: in terms of average smoke column average half-height, 0.95 -> 14, 0.93 -> 10 but 0.80 -> 5
local PERSIST_S=0.96 -- same parameter for smog
local TRANSPARENCY= "blend" -- "blend" or "opaque". MeseCraft uses translucent smoke (issue #12); blending can glitch slightly where smoke touches liquids
local WIND=0.05 -- Chance for a smoke node to move horizontally instead of going up

local SMOKE_DPS=nil -- use it to define the amount of damage per second of smoke nodes.
local SMOKE_OPACITY= 120 -- opacity when inside of smoke nodes

local SMOG_DPS=nil -- use it to define the amount of damage per second of smoke nodes.
local SMOG_OPACITY= 120 -- opacity when inside of smoke nodes


local locations = {
	1, 0,  -1, 0,  0, 1,  0, -1,
	1, 0,  -1, 0,  0, 1,  0, -1,
}

local sb={name="smoke:block", param2=0} -- avoid building that table each time our wannabe fast function is executed.
local sh={name="smoke:smog"}
local ab={name="air"}


-- This function does everything it can to be as fast as possible, all while randomzing the movement of the nodes.
-- The "locations" aboves are pairs of x,z coordinates for the four horizontal neighbors (no diagonals),
-- repeated two times.
-- spread_smoke picks at random a starting pair in this array. It adds the offsets to the coordinates,
-- check if the node there is air, and if not subtracts the current offsets and adds the next ones in one go.
-- This gives 4 different check orders out of the 4! = 24 possible in theory. Of course one could write down all 24 orders in an array...

local random=math.random

local function spread_smoke(pos)
	local p={x=pos.x, y=pos.y+1, z=pos.z}
	local gn=minetest.get_node
	local r=random(0, 3)*2+1
	local rr=random()
	local loc=locations

	repeat
		if gn(p).name=="air" and rr>WIND then break end
		if gn(p).name=="ignore" then minetest.swap_node(pos, ab) return false end -- we don't want wandering smoke nodes at the mapblock limit in the sky.
		p.y=p.y-1
		p.x=p.x+loc[r]
		p.z=p.z+loc[r+1]
		if gn(p).name=="air" then break end
		p.x=p.x-loc[r]+loc[r+2]
		p.z=p.z-loc[r+1]+loc[r+3]
		if gn(p).name=="air" then break end
		p.x=p.x-loc[r+2]+loc[r+4]
		p.z=p.z-loc[r+3]+loc[r+5]
		if gn(p).name=="air" then break end
		p.x=p.x-loc[r+4]+loc[r+6]
		p.z=p.z-loc[r+5]+loc[r+7]
		if gn(p).name=="air" then break end
		p.x=p.x-loc[r+6]
		p.z=p.z-loc[r+7]
		p.y=p.y-1
		if gn(p).name=="air" then break end
		-- trapped; retry later
		minetest.get_node_timer(pos):start(ITVL*2)
		return false
	until true -- never loop; all we wanted is a freaking Goto.

	--if rr<(PERSIST-p.y/1000) then
	if rr<PERSIST then
		sb.param2=random(0,5)
		minetest.set_node(p, sb)
	end
	minetest.swap_node(pos, ab)
	return false
end

minetest.register_node('smoke:block', {
	description = 'Smoke',
	drawtype = "glasslike",
	waving = 1,
	tiles = {{
		name = "smoke.png^[opacity:140",
		--backface_culling=false, -- it seems to mitigate a bit visual glitches when transparency is enabled.
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 6,
		},
	}},
	inventory_image = "smoke.png^[verticalframe:16:1",
	wield_image =  "smoke.png^[verticalframe:16:1",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha=TRANSPARENCY,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable=true,
	damage_per_second = SMOKE_DPS,
	drowning=1,
	post_effect_color = {a = SMOKE_OPACITY, r = 177, g = 177, b = 177},
	drop="",

	on_timer=spread_smoke,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(ITVL+random())
	end
	})

function smoke.add(pos)
	minetest.set_node(pos, sb)
end

-- "Smog" is a second type of smoke that prefers to float or go down.

local function spread_smog(pos)
	local p={x=pos.x, y=pos.y, z=pos.z}
	local gn=minetest.get_node
	local r=random(0, 3)*2+1
	local loc=locations

	repeat
		p.x=p.x+loc[r]
		p.z=p.z+loc[r+1]
		if gn(p).name=="air" then break end
		p.x=p.x-loc[r]+loc[r+2]
		p.z=p.z-loc[r+1]+loc[r+3]
		if gn(p).name=="air" then break end
		p.x=p.x-loc[r+2]+loc[r+4]
		p.z=p.z-loc[r+3]+loc[r+5]
		if gn(p).name=="air" then break end
		p.x=p.x-loc[r+4]+loc[r+6]
		p.z=p.z-loc[r+5]+loc[r+7]
		if gn(p).name=="air" then break end
		p.x=p.x-loc[r+6]
		p.z=p.z-loc[r+7]
		-- down
		p.y=p.y-1
		if gn(p).name=="air" then break end
		p.y=p.y+2
		-- up
		if gn(p).name=="air" then break end
		p.y=p.y-1
		-- trapped; retry later
		minetest.get_node_timer(pos):start(ITVL*2)
		return false
	until true -- never loop; all we wanted is a freaking Goto.

	if random()<PERSIST_S then
		minetest.set_node(p, sh)
	end
	minetest.swap_node(pos, ab)
	return false
end

minetest.register_node('smoke:smog', {
	description = 'Smog',
	tiles = {{
		name = "(smoke.png^gui_hb_bg.png)^[opacity:140",
		--backface_culling=false,
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 6,
		},
	}},
	inventory_image = "smoke.png^[verticalframe:16:1^gui_hb_bg.png",
	wield_image =  "smoke.png^[verticalframe:16:1^gui_hb_bg.png",
	drawtype = "glasslike",
	paramtype = "light",
	use_texture_alpha=TRANSPARENCY,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable=true,
	damage_per_second = SMOG_DPS ,
	drowning=1,
	post_effect_color = {a = SMOG_OPACITY, r = 177, g = 177, b = 177},
	drop="",

	on_timer=spread_smog,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(ITVL)
	end
	})

function smoke.add_smog(pos, jitters)
	minetest.set_node(pos, {name="smoke:smog"})
	jitters=jitters or random()
	minetest.get_node_timer(pos):start(ITVL+jitters)
end

-- API DOC
-- =======
--
-- smoke.add(pos)
-- smoke.add_smog(pos, jitters)
--
-- These functions add smoke or smog at a given position.
-- normal smoke, "light" smoke will go up whenever it can
-- while smog, tends to wander horizontally or go down. It only goes up when there's nowhere else to go.
--
-- The "jitters" parameter is optional; it introduces a delay on the first node update.
-- If not given, the functions will apply a random delay up to one second. This is intended
-- to smooth out performance in case the smoke is generated by a periodic process such as an ABM.
-- In this case, because the smoke nodes are updated at a fix time interval (using timers), you may
-- end up with CPU consumption "spikes" because all smoke nodes change position at the same time.
--
-- The functions do not check that the node at pos is air, nor do they care about protections.
--
-- APPLICATION
-- ===========
--
-- * creates an ABM that adds smoke on top of nodes belonging to the "smokey" group
-- * smoke generation rate is 1/g, where g is the value for the smokey group
-- * adds active furnaces, fire and lava flows to this group

if true then -- change to "false" if you want to do your own thing
	minetest.register_abm{
		label="Smoke",
		nodenames= {"group:smokey"},
		neighbors={"air"},
		interval=4,
		chance=1,
		action=function(pos)
			local p=minetest.find_node_near(pos, 1, "air") -- note that it happens that this function will try the node above first, but no statement about that in the docs.
			if p and random(1, minetest.get_item_group(minetest.get_node(pos).name, "smokey"))==1 then
				smoke.add(p)
			end
		end
	}

	function smoke.add_source(name, rate)
		local g=table.copy(minetest.registered_nodes[name].groups)
		g.smokey=rate
		minetest.override_item(name, { groups=g })
	end

	smoke.add_source("default:furnace_active", 1)
	smoke.add_source("fire:basic_flame", 2)
--	smoke.add_source("default:lava_flowing", 32)
	smoke.add_source("default:lava_source", 32)
	smoke.add_source("fire:permanent_flame", 2)
	smoke.add_source("default:torch", 4)
	smoke.add_source("default:torch_wall", 4)
	smoke.add_source("default:torch_ceiling", 4)
end
