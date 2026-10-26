-- initialize API interface
local api = {}

-- define various standard effect cycle lengths
api.SHORT_CYCLE		=	0		-- for particles and fast animations (use GSCYCLE)
api.DEFAULT_CYCLE	=	2.0	-- for most effect types
api.LONG_CYCLE		=	5.0	-- for ressource intensive tasks or timed effects

-- register new weather presets (like rain)
-- @param name <string> Unique preset name, ideally prefixed
-- @param conditions <table> A collection of required influences
-- @param effects <table> A <table> containing all applied effects as keys and parameters as values
function api.register_weather(name, conditions, effects)
	climate_mod.weathers[name] = {
		conditions = conditions,
		effects = effects,
		active_players = {}
	}
end

-- register new weather effects (like particles)
-- @param name <string> Unique effect name, ideally prefixed
-- @param handler <function> A function to be called when the effect is active
-- @param htype <string: start|tick|stop>  Determines when the function is called
function api.register_effect(name, handler, htype)
	-- check for valid handler types
	if htype ~= "start" and htype ~= "tick" and htype ~= "stop" then
		minetest.log("warning", "[Climate API] Effect " .. dump(name) .. " uses invalid callback type: " .. dump(htype))
		return
	end
	-- create effect handler registry if not existent yet
	if type(climate_mod.effects[name]) == "nil" then
		climate_mod.effects[name] = { start = {}, tick = {}, stop = {} }
		climate_mod.cycles[name] = { timespan = api.DEFAULT_CYCLE, timer = 0 }
	end
	-- store effect handler
	table.insert(climate_mod.effects[name][htype], handler)
end

-- set cycle length of given effect
-- @param name <string> Name of the affected effect
-- @param cycle <number> Duration between function calls
function api.set_effect_cycle(name, cycle)
	climate_mod.cycles[name].timespan = cycle
end

-- register new environment influence that is independent of position
-- @param name <string> Unique influence name
-- @param func <function> Returns current influence value for entire world
function api.register_global_influence(name, func)
	climate_mod.global_influences[name] = func
end

-- register new environment influence based on position
-- @param name <string> Unique influence name
-- @param func <function> Returns current influence value for given position
function api.register_influence(name, func)
	climate_mod.influences[name] = func
end

-- register new Active Block Modifier dependent on weather status
-- Uses same config as Minetest.register_abm() but also adds
-- conditions similiar to weather presets and provides local environment
-- to action event handler as third parameter.
-- @param config <table> ABM configuration with additional information
function api.register_abm(config)
	if not climate_mod.settings.block_updates then return end

	local conditions = config.conditions
	local action = config.action
	local pos_override = config.pos_override

	-- override action handler to inject weather status
	local override = function(pos, node)
		if type(pos_override) == "function" then
			pos = pos_override(pos)
			node = minetest.get_node(pos)
		end

		-- get environment influences for current position
		local env = climate_mod.trigger.get_position_environment(pos)

		if conditions == nil then
			return action(pos, node, env)
		end

		-- check if all conditions are met
		for condition, goal in pairs(conditions) do
			local is_applicable = climate_mod.trigger.test_condition(condition, env, goal)
			if not is_applicable then return end
		end
		return action(pos, node, env)
	end

	-- MeseCraft: pass height conditions to the engine so it skips map blocks outside them
	-- (small margin for pos_override; the exact check still runs in the action).
	if conditions and conditions.min_height and config.min_y == nil then
		config.min_y = conditions.min_height - 2
	end
	if conditions and conditions.max_height and config.max_y == nil then
		config.max_y = conditions.max_height + 2
	end

	-- register overridden abm setup
	config.conditions = nil
	config.action = override
	minetest.register_abm(config)
end

-- return supplied API endpoint
return api
