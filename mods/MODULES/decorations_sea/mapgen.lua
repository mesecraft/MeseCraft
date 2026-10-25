local path = minetest.get_modpath("decorations_sea")

local warm_biomes = {
    "desert_ocean",
    "sandstone_desert_ocean",
    "savanna_shore",
    "savanna_ocean",
    "rainforest_ocean",
    "mesa",
    "mesa_ocean",
    "jumble",
    "jumble_ocean",
    "junglee",
    "junglee_ocean",
    "grove",
    "grove_ocean",
    "mushroom",
    "mushroom_ocean",
    "sandstone",
    "sandstone_ocean",
    "savannah",
    "savannah_ocean",
    "quicksand",
    "fiery",
    "fiery_ocean",
    "sandclay",
    "swamp",
    "swamp_ocean",
    "desert",
}

local temperate_biomes = {
    "grassland",
    "deciduous_forest",
    "grassland_ocean",
    "coniferous_forest_ocean",
    "deciduous_forest_shore",
    "decidious_forest_ocean",
    "cold_desert_ocean",
    "sakura",
    "sakura_ocean",
    "grassy",
    "grassy_ocean",
    "grayness",
    "grayness_ocean",
    "grassytwo",
    "grassytwo_ocean",
    "prairie",
    "prairie_ocean",
    "plains",
    "plains_ocean", 
    "bamboo",
    "clearing",
}

local frozen_biomes = {
    "icesheet_ocean",
    "tundra_beach",
    "tundra_ocean",
    "taiga_ocean",
    "alpine",
    "snowy",
    "snowy_grassland_ocean",
    "glacier",
    "glacier_ocean",
    "frost",
    "frost_ocean",
}

-- The lists above name biomes from several biome mods; keep only the ones registered in this game
-- so the engine doesn't warn about each missing name. An empty list would mean "all biomes", so
-- fall back to the full list in that case.
local function registered_only(biomes)
    local found = {}
    for _, name in ipairs(biomes) do
        if minetest.registered_biomes[name] then
            table.insert(found, name)
        end
    end
    return #found > 0 and found or biomes
end

warm_biomes = registered_only(warm_biomes)
temperate_biomes = registered_only(temperate_biomes)
frozen_biomes = registered_only(frozen_biomes)

local corals = {
    "blue",
    "crimson",
    "green",
    "orange",
    "pink",
    "red",
    "violet",
    "yellow"
}

local function register_coral_decoration(schemname, noisedef, biomes)
    minetest.register_decoration( {
        deco_type = "schematic",
        place_on = "default:sand",
        sidelen = 16,
        noise_params = noisedef,
        biomes = biomes,
        y_min = -32,
        y_max = -4,
        spawn_by = "default:water_source",
        num_spawn_by = 1,
        flags = "force_placement, all_floors",
        schematic = schemname,
        rotation = "random",
        place_offset_y = 0,
    })
end

local function register_tall_grass_decoration(name, hmin, hmax, noisedef, biomes)
    minetest.register_decoration({
        deco_type = "simple",
        place_on = "default:sand",
        sidelen = 16,
        noise_params = noisedef,
        biomes = biomes,
        y_min = -32,
        y_max = -hmax,
        spawn_by = "default:water_source",
        num_spawn_by = 1,
        flags = "force_placement, all_floors",
        decoration = name,
        param2 = hmin*16,
        param2_max = hmax*16,
        place_offset_y = -1,
    })
end

local function register_simple_decoration(name, noisedef, biomes)
    minetest.register_decoration({
        deco_type = "simple",
        place_on = "default:sand",
        sidelen = 16,
        noise_params = noisedef,
        biomes = biomes,
        y_min = -32,
        y_max = -1,
        spawn_by = "default:water_source",
        num_spawn_by = 1,
        flags = "force_placement, all_floors",
        decoration = name,
        param2 = 16,
        place_offset_y = -1,
    })
end

local function register_sand_decoration(name, fill_ratio, ymax, biomes)
    minetest.register_decoration({
        deco_type = "simple",
        place_on = "default:sand",
        sidelen = 16,
        fill_ratio = fill_ratio,
        biomes = biomes,
        y_min = -32,
        y_max = ymax,
        spawn_by = "default:water_source",
        num_spawn_by = 1,
        flags = "force_placement, all_floors",
        decoration = name,
        place_offset_y = -1,
    })
end

local coral_noise = {
    offset = -0.0115,
    scale = 0.024,
    spread = {x = 100, y = 100, z = 100},
    seed = 111,
    octaves = 5,
    persist = 0.6
}

local single_coral_noise = {
    offset = 0.01,
    scale = 0.024,
    spread = {x = 100, y = 100, z = 100},
    seed = 111,
    octaves = 5,
    persist = 0.6
}

local sea_pickle_noise = {
    offset = 0.005,
    scale = 0.024,
    spread = {x = 100, y = 100, z = 100},
    seed = 111,
    octaves = 5,
    persist = 0.6
}

local grass_noise = {
    offset = 0.025,
    scale = 0.024,
    spread = {x = 100, y = 100, z = 100},
    seed = 1411,
    octaves = 5,
    persist = 0.6
}

local sparce_grass_noise = {
    offset = 0.015,
    scale = 0.024,
    spread = {x = 100, y = 100, z = 100},
    seed = 1411,
    octaves = 5,
    persist = 0.6
}

local short_grass_noise = {
    offset = 0.075,
    scale = 0.024,
    spread = {x = 100, y = 100, z = 100},
    seed = 25225,
    octaves = 5,
    persist = 0.6
}

local sand_decorations_list = {
    {"decorations_sea:seashell_01_node", 0.01, 1, warm_biomes},
    {"decorations_sea:seashell_02_node", 0.01, 1, warm_biomes},
    {"decorations_sea:seashell_03_node", 0.01, 1, warm_biomes},
    {"decorations_sea:starfish_01_node", 0.005, 1, warm_biomes},
    {"decorations_sea:starfish_02_node", 0.005, 1, warm_biomes},
    {"decorations_sea:seashell_01_node", 0.002, 1, temperate_biomes},
    {"decorations_sea:seashell_02_node", 0.002, 1, temperate_biomes},
    {"decorations_sea:seashell_03_node", 0.002, 1, temperate_biomes},
}

local tall_grass_list = {
    {"decorations_sea:seagrass_01", 4, 7, sparce_grass_noise, frozen_biomes},
    {"decorations_sea:seagrass_01", 3, 4, sparce_grass_noise, frozen_biomes},
    {"decorations_sea:seagrass_01", 2, 2, sparce_grass_noise, frozen_biomes},
    {"decorations_sea:seagrass_02", 4, 7, grass_noise, warm_biomes},
    {"decorations_sea:seagrass_02", 3, 4, grass_noise, warm_biomes},
    {"decorations_sea:seagrass_02", 2, 2, grass_noise, warm_biomes},
    {"decorations_sea:seagrass_03", 4, 7, grass_noise, temperate_biomes},
    {"decorations_sea:seagrass_03", 3, 4, grass_noise, temperate_biomes},
    {"decorations_sea:seagrass_03", 2, 2, grass_noise, temperate_biomes},
    {"decorations_sea:seagrass_03", 4, 7, grass_noise, warm_biomes},
    {"decorations_sea:seagrass_03", 3, 4, grass_noise, warm_biomes},
    {"decorations_sea:seagrass_03", 2, 2, grass_noise, warm_biomes},
}

local simple_decoration_list = {
    {"decorations_sea:seagrass_01", sparce_grass_noise, frozen_biomes},
    {"decorations_sea:seagrass_02", grass_noise, warm_biomes},
    {"decorations_sea:seagrass_03", grass_noise, temperate_biomes},
    {"decorations_sea:seagrass_03", grass_noise, warm_biomes},
    {"decorations_sea:seagrass_04", short_grass_noise},
    {"decorations_sea:seagrass_05", short_grass_noise, warm_biomes},
    {"decorations_sea:seagrass_06", short_grass_noise, warm_biomes},
    {"decorations_sea:coral_plantlike_01", single_coral_noise, warm_biomes},
    {"decorations_sea:coral_plantlike_02", single_coral_noise, warm_biomes},
    {"decorations_sea:coral_plantlike_03", single_coral_noise, warm_biomes},
    {"decorations_sea:coral_plantlike_04", single_coral_noise, warm_biomes},
    {"decorations_sea:coral_plantlike_05", single_coral_noise, warm_biomes},
    {"decorations_sea:sea_pickle", sea_pickle_noise, warm_biomes},
}

for _,v in pairs(corals) do
    for i = 1, 3 do
        local schem_path = path .. "/schematics/coral_" .. v .. "_0" .. i .. ".mts"
        register_coral_decoration(schem_path, coral_noise, warm_biomes)
    end
end

for _,v in pairs(simple_decoration_list) do
    register_simple_decoration(v[1], v[2], v[3])
end

for _,v in pairs(tall_grass_list) do
    register_tall_grass_decoration(v[1], v[2], v[3], v[4], v[5])
end

for _,v in pairs(sand_decorations_list) do
    register_sand_decoration(v[1], v[2], v[3], v[4], v[5])
end
