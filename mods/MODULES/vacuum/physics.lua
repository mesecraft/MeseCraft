local has_monitoring = minetest.get_modpath("monitoring")
local has_technic = minetest.get_modpath("technic")
local has_mesecons_random = minetest.get_modpath("mesecons_random")

local MP = minetest.get_modpath("vacuum")
local throttle = dofile(MP .. "/util/throttle.lua")

local metric_space_vacuum_abm
local metric_space_vacuum_leak_abm

if has_monitoring then
  metric_space_vacuum_abm = monitoring.counter("vacuum_abm_count", "number of space vacuum abm calls")
  metric_space_vacuum_leak_abm = monitoring.counter("vacuum_abm_leak_count", "number of space vacuum leak abm calls")
end

-- air leaking nodes
local leaky_nodes = {
	"group:door",
	"group:soil",
	"group:pipe", "group:tube"
}

if has_mesecons_random then
  table.insert(leaky_nodes, "mesecons_random:ghoststone_active")
end

if has_technic then
  table.insert(leaky_nodes, "technic:lv_cable")
  table.insert(leaky_nodes, "technic:mv_cable")
  table.insert(leaky_nodes, "technic:hv_cable")
end


local near_powered_airpump = function(pos)
	local pos1 = vector.subtract(pos, {x=vacuum.air_pump_range, y=vacuum.air_pump_range, z=vacuum.air_pump_range})
	local pos2 = vector.add(pos, {x=vacuum.air_pump_range, y=vacuum.air_pump_range, z=vacuum.air_pump_range})

	local nodes = minetest.find_nodes_in_area(pos1, pos2, {"vacuum:airpump"})
	for _,node in ipairs(nodes) do
		local meta = minetest.get_meta(node)
		if vacuum.airpump_active(meta) then
			return true
		end
	end

	return false
end



-- vacuum/air propagation
minetest.register_abm({
  label = "space vacuum",
  -- MeseCraft: only runs in space, so let the engine skip everything below it.
  min_y = vacuum.space_height - 40,
	nodenames = {"air"},
	neighbors = {"vacuum:vacuum"},
	interval = 1,
	chance = 1,
	action = throttle(1000, function(pos)

		if metric_space_vacuum_abm ~= nil then metric_space_vacuum_abm.inc() end

		if vacuum.no_vacuum_abm(pos) then
			return
		end

		if not vacuum.is_pos_in_space(pos) or near_powered_airpump(pos) then
			-- on earth or near a powered airpump
			local node = minetest.find_node_near(pos, 1, {"vacuum:vacuum"})

			if node ~= nil then
				minetest.set_node(node, {name = "air"})
			end
		else
			-- in space, evacuate air
			minetest.set_node(pos, {name = "vacuum:vacuum"})
		end
	end)
})

-- weird behaving nodes in vacuum
local drop_nodes = {
	"default:torch",
	"default:torch_wall",
	"default:torch_ceiling",
	"default:ladder_wood",
	"default:ladder_steel",
	"default:dry_shrub",
	"default:papyrus",
	"default:cactus",
	"group:wool",
	"group:wood",
	"group:tree",
	-- "group:mesecon", TODO: add hardcore setting for that one
	-- TODO: maybe: group:dig_immediate
}

-- special drop cases
local get_drop_name = function(name)
	if name == "default:torch_wall" or name == "default:torch_ceiling" then
		return "default:torch"
	else
		return name
	end
end

-- weird nodes in vacuum
minetest.register_abm({
        label = "space drop nodes",
        -- MeseCraft: only runs in space, so let the engine skip everything below it.
        min_y = vacuum.space_height + 1,
	nodenames = drop_nodes,
	neighbors = {"vacuum:vacuum"},
	interval = 1,
	chance = 1,
	action = throttle(100, function(pos)

		if not vacuum.is_pos_in_space(pos) or near_powered_airpump(pos) then
			return
		end

		local node = minetest.get_node(pos)
		minetest.set_node(pos, {name = "vacuum:vacuum"})

		local dropname = get_drop_name(node.name)
		if dropname then
			minetest.add_item(pos, {name = dropname})
		end
	end)
})

-- various dirts in vacuum
minetest.register_abm({
        label = "space vacuum soil dry",
        -- MeseCraft: only runs in space, so let the engine skip everything below it.
        min_y = vacuum.space_height + 1,
	nodenames = {
		"default:dirt",
		"default:dirt_with_grass",
		"default:dirt_with_snow",
		"default:dirt_with_dry_grass",
		"default:dirt_with_grass_footsteps",
		"default:dirt_with_rainforest_litter",
		"default:dirt_with_coniferous_litter"
	},
	neighbors = {"vacuum:vacuum"},
	interval = 1,
	chance = 1,
	action = throttle(100, function(pos)
		minetest.set_node(pos, {name = "default:gravel"})
	end)
})

-- plants in vacuum
minetest.register_abm({
        label = "space vacuum plants",
        -- MeseCraft: only runs in space, so let the engine skip everything below it.
        min_y = vacuum.space_height + 1,
	nodenames = {
		"group:sapling",
		"group:plant",
		"group:flora",
		"group:flower",
		"group:leafdecay",
		"ethereal:banana", -- ethereal compat
		"ethereal:orange",
		"ethereal:strawberry"
	},
	neighbors = {"vacuum:vacuum"},
	interval = 1,
	chance = 1,
	action = throttle(100, function(pos)
		minetest.set_node(pos, {name = "default:dry_shrub"})
	end)
})



-- sublimate nodes in vacuum
minetest.register_abm({
        label = "space vacuum sublimate",
        -- MeseCraft: only runs in space, so let the engine skip everything below it.
        min_y = vacuum.space_height + 1,
	nodenames = {"group:snowy", "group:leaves", "group:water"},
	neighbors = {"vacuum:vacuum"},
	interval = 1,
	chance = 1,
	action = throttle(100, function(pos)
		if not vacuum.is_pos_in_space(pos) or near_powered_airpump(pos) then
			return
		end

		minetest.set_node(pos, {name = "vacuum:vacuum"})
	end)
})



-- depressurize through leaky nodes
minetest.register_abm({
        label = "space vacuum depressurize",
        -- MeseCraft: only runs in space, so let the engine skip everything below it.
        min_y = vacuum.space_height + 1,
	nodenames = leaky_nodes,
	neighbors = {"vacuum:vacuum"},
	interval = 2,
	chance = 2,
	action = throttle(250, function(pos)
		if metric_space_vacuum_leak_abm ~= nil then metric_space_vacuum_leak_abm.inc() end

		if not vacuum.is_pos_in_space(pos) or near_powered_airpump(pos) then
			-- on earth: TODO: replace vacuum with air
			return
		else
			local node = minetest.get_node(pos)

			if node.name == "pipeworks:entry_panel_empty" or node.name == "pipeworks:entry_panel_loaded" then
				-- air thight pipes
				return
			end

			if node.name == "vacuum:airpump" then
				-- pump is airthight
				return
			end

			-- TODO check n nodes down (multiple simple door airlock hack)
			-- in space: replace air with vacuum
			local surrounding_node = minetest.find_node_near(pos, 1, {"air"})

			if surrounding_node ~= nil then
			        if vacuum.debug then
					-- debug mode, set
					minetest.set_node(surrounding_node, {name = "default:cobble"})
				else
					-- normal case
					minetest.set_node(surrounding_node, {name = "vacuum:vacuum"})
				end
			end
		end
	end)
})
