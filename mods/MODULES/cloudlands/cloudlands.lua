local ALTITUDE               = 200      -- average altitude of islands
local ALTITUDE_AMPLITUDE     = 40       -- rough island altitude variance (plus or minus)
local GENERATE_ORES          = false    -- set to true for island core stone to contain patches of dirt and sand etc.
local LOWLAND_BIOMES         = false or -- If true then determine an island's biome using the biome at altitude "LOWLAND_BIOME_ALTITUDE"
                               minetest.get_modpath("ethereal")   ~= nil -- Ethereal has an alpine biome above altitude 40, so default to lowland biomes
local LOWLAND_BIOME_ALTITUDE = 10       -- Higher than beaches, lower than mountains (See LOWLAND_BIOMES)
local VINE_COVERAGE          = 0.3      -- set to 0 to turn off vines
local REEF_RARITY            = 0.015    -- Chance of a viable island having a reef or atoll
local TREE_RARITY            = 0.08     -- Chance of a viable island having a giant tree growing out of it
local PORTAL_RARITY          = 0.04     -- Chance of a viable island having some ancient portalstone on it (If portals API available and ENABLE_PORTALS is true)
local BIOLUMINESCENCE        = false or -- Allow giant trees variants which have glowing parts
                               minetest.get_modpath("glowtest")   ~= nil or
                               minetest.get_modpath("ethereal")   ~= nil or
                               minetest.get_modpath("glow")       ~= nil or
                               minetest.get_modpath("nsspf")      ~= nil or
                               minetest.get_modpath("nightscape") ~= nil or
                               minetest.get_modpath("moonflower") ~= nil -- a world using any of these mods is OK with bioluminescence
local ENABLE_PORTALS         = true     -- Whether to allow players to build portals to islands. Portals require the Nether mod.
local EDDYFIELD_SIZE         = 1        -- size of the "eddy field-lines" that smaller islands follow
local ISLANDS_SEED           = 1000     -- You only need to change this if you want to try different island layouts without changing the map seed

-- Some lists of known node aliases (any nodes which can't be found won't be used).
local NODENAMES_STONE       = {"mapgen_stone",           "mcl_core:stone",           "default:stone",        "main:stone"}
local NODENAMES_WATER       = {"mapgen_water_source",    "mcl_core:water_source",    "default:water_source", "main:water"}
local NODENAMES_ICE         = {"mapgen_ice",             "mcl_core:ice",             "pedology:ice_white", "default:ice", "main:ice"}
local NODENAMES_GRAVEL      = {"mapgen_gravel",          "mcl_core:gravel",          "default:gravel",       "main:gravel"}
local NODENAMES_GRASS       = {"mapgen_dirt_with_grass", "mcl_core:dirt_with_grass", "default:dirt_with_grass", "main:grass"} -- currently only used with games that don't register biomes, e.g. Hades Revisted
local NODENAMES_DIRT        = {"mapgen_dirt",            "mcl_core:dirt",            "default:dirt",         "main:dirt"}            -- currently only used with games that don't register biomes, e.g. Hades Revisted
local NODENAMES_SILT        = {"mapgen_silt", "default:silt", "aotearoa:silt", "darkage:silt", "mapgen_sand", "mcl_core:sand", "default:sand", "main:sand"} -- silt isn't a thing yet, but perhaps one day it will be. Use sand for the bottom of ponds in the meantime.
local NODENAMES_VINES       = {"mcl_core:vine", "vines:side_end", "ethereal:vine", "main:vine"} -- ethereal vines don't grow, so only select that if there's nothing else.
local NODENAMES_HANGINGVINE = {"vines:vine_end"}
local NODENAMES_HANGINGROOT = {"vines:root_end"}
local NODENAMES_TREEWOOD    = {"mcl_core:tree",   "default:tree",   "mapgen_tree",   "main:tree"}
local NODENAMES_TREELEAVES  = {"mcl_core:leaves", "default:leaves", "mapgen_leaves", "main:leaves"}
local NODENAMES_FRAMEGLASS  = {"xpanes:obsidian_pane_flat", "xpanes:pane_flat", "default:glass", "xpanes:pane_natural_flat", "mcl_core:glass", "walls:window"}
local NODENAMES_WOOD        = {"default:wood", "mcl_core:wood", "main:wood"}

local MODNAME                    = minetest.get_current_modname()
local VINES_REQUIRED_HUMIDITY    = 49
local VINES_REQUIRED_TEMPERATURE = 40
local ICE_REQUIRED_TEMPERATURE   = 8

local DEBUG                  = false -- dev logging
local DEBUG_GEOMETRIC        = false -- turn off noise from island shapes
local DEBUG_SKYTREES         = false -- dev logging

-- OVERDRAW can be set to 1 to cause a y overdraw of one node above the chunk, to avoid creating a dirt "surface"
-- at the top of the chunk that trees mistakenly grow on when the chunk is decorated.
-- However, it looks like that tree problem has been solved by either engine or biome updates, and overdraw causes
-- it's own issues (e.g. nodeId_top not getting set correctly), so I'm leaving overdraw off (i.e. zero) until I
-- notice problems requiring it.
local OVERDRAW = 0

local S = minetest.get_translator(MODNAME)

cloudlands = {} -- API functions can be accessed via this global:
                -- cloudlands.get_island_details(minp, maxp)                   -- returns an array of island-information-tables, y is ignored.
                -- cloudlands.find_nearest_island(x, z, search_radius)         -- returns a single island-information-table, or nil
                -- cloudlands.get_height_at(x, z, [island-information-tables]) -- returns (y, isWater), or nil if no island here

cloudlands.coreTypes = {
  {
    territorySize     = 200,
    coresPerTerritory = 3,
    radiusMax         = 96,
    depthMax          = 50,
    thicknessMax      = 8,
    frequency         = 0.1,
    pondWallBuffer    = 0.03,
    requiresNexus     = true,
    exclusive         = false
  },
  {
    territorySize     = 60,
    coresPerTerritory = 1,
    radiusMax         = 40,
    depthMax          = 40,
    thicknessMax      = 4,
    frequency         = 0.1,
    pondWallBuffer    = 0.06,
    requiresNexus     = false,
    exclusive         = true
  },
  {
    territorySize     = 30,
    coresPerTerritory = 3,
    radiusMax         = 16, -- I feel this and depthMax should be bigger, say 18, and territorySize increased to 34 to match, but I can't change it any more or existing worlds will mismatch along previously emerged chunk boundaries
    depthMax          = 16,
    thicknessMax      = 2,
    frequency         = 0.1,
    pondWallBuffer    = 0.11, -- larger values will make ponds smaller and further from island edges, so it should be as low as you can get it without the ponds leaking over the edge. A small leak-prone island is at (3160, -2360) on seed 1
    requiresNexus     = false,
    exclusive         = true
  }
}

if minetest.get_biome_data == nil then error(MODNAME .. " requires Minetest v5.0 or greater", 0) end

local function fromSettings(settings_name, default_value)
  local result
  if type(default_value) == "number" then
    result = tonumber(minetest.settings:get(settings_name) or default_value)
  elseif type(default_value) == "boolean" then
    result = minetest.settings:get_bool(settings_name, default_value)
  end
  return result
end
-- override any settings with user-specified values before these values are needed
ALTITUDE             = fromSettings(MODNAME .. "_altitude",           ALTITUDE)
ALTITUDE_AMPLITUDE   = fromSettings(MODNAME .. "_altitude_amplitude", ALTITUDE_AMPLITUDE)
GENERATE_ORES        = fromSettings(MODNAME .. "_generate_ores",      GENERATE_ORES)
VINE_COVERAGE        = fromSettings(MODNAME .. "_vine_coverage",      VINE_COVERAGE * 100) / 100
LOWLAND_BIOMES       = fromSettings(MODNAME .. "_use_lowland_biomes", LOWLAND_BIOMES)
TREE_RARITY          = fromSettings(MODNAME .. "_giant_tree_rarety",  TREE_RARITY * 100) / 100
BIOLUMINESCENCE      = fromSettings(MODNAME .. "_bioluminescence",    BIOLUMINESCENCE)
ENABLE_PORTALS       = fromSettings(MODNAME .. "_enable_portals",     ENABLE_PORTALS)

local noiseparams_eddyField = {
	offset      = -1,
	scale       = 2,
	spread      = {x = 350 * EDDYFIELD_SIZE, y = 350 * EDDYFIELD_SIZE, z= 350 * EDDYFIELD_SIZE},
	seed        = ISLANDS_SEED, --WARNING! minetest.get_perlin() will add the server map's seed to this value
	octaves     = 2,
	persistence = 0.7,
	lacunarity  = 2.0,
}
local noiseparams_heightMap = {
	offset      = 0,
	scale       = ALTITUDE_AMPLITUDE,
	spread      = {x = 160, y = 160, z= 160},
	seed        = ISLANDS_SEED, --WARNING! minetest.get_perlin() will add the server map's seed to this value
	octaves     = 3,
	persistence = 0.5,
	lacunarity  = 2.0,
}
local DENSITY_OFFSET = 0.7
local noiseparams_density = {
	offset      = DENSITY_OFFSET,
	scale       = .3,
	spread      = {x = 25, y = 25, z= 25},
	seed        = 1000, --WARNING! minetest.get_perlin() will add the server map's seed to this value
	octaves     = 4,
	persistence = 0.5,
	lacunarity  = 2.0,
}
local SURFACEMAP_OFFSET = 0.5
local noiseparams_surfaceMap = {
	offset      = SURFACEMAP_OFFSET,
	scale       = .5,
	spread      = {x = 40, y = 40, z= 40},
	seed        = ISLANDS_SEED, --WARNING! minetest.get_perlin() will add the server map's seed to this value
	octaves     = 4,
	persistence = 0.5,
	lacunarity  = 2.0,
}
local noiseparams_skyReef = {
	offset      = .3,
	scale       = .9,
	spread      = {x = 3, y = 3, z= 3},
	seed        = 1000,
	octaves     = 2,
	persistence = 0.5,
	lacunarity  = 2.0,
}

local noiseAngle = -15 --degrees to rotate eddyField noise, so that the vertical and horizontal tendencies are off-axis
local ROTATE_COS = math.cos(math.rad(noiseAngle))
local ROTATE_SIN = math.sin(math.rad(noiseAngle))

local noise_eddyField
local noise_heightMap
local noise_density
local noise_surfaceMap
local noise_skyReef

local worldSeed
local nodeId_ignore = minetest.CONTENT_IGNORE
local nodeId_air
local nodeId_stone
local nodeId_grass
local nodeId_dirt
local nodeId_water
local nodeId_ice
local nodeId_silt
local nodeId_gravel
local nodeId_vine
local nodeName_vine
local nodeName_ignore = minetest.get_name_from_content_id(nodeId_ignore)

local REQUIRED_DENSITY = 0.4

local randomNumbers = {} -- array of 0-255 random numbers with values between 0 and 1 (inclusive)
local data          = {} -- reuse the massive VoxelManip memory buffers instead of creating on every on_generate()
local biomes        = {}

-- optional region specified in settings to restrict islands too
local region_restrictions = false
local region_min_x, region_min_z, region_max_x, region_max_z = -32000, -32000, 32000, 32000

-- optional biomes specified in settings to restrict islands too
local limit_to_biomes = nil
local limit_to_biomes_altitude = nil

--[[==============================
           Math functions
    ==============================]]--

-- avoid having to perform table lookups each time a common math function is invoked
local math_min, math_max, math_floor, math_sqrt, math_cos, math_sin, math_abs, math_pow, PI = math.min, math.max, math.floor, math.sqrt, math.cos, math.sin, math.abs, math.pow, math.pi

local function clip(value, minValue, maxValue)
  if value <= minValue then
    return minValue
  elseif value >= maxValue then
    return maxValue
  else
    return value
  end
end

local function round(value)
  return math_floor(0.5 + value)
end

--[[==============================
           Interop functions
    ==============================]]--

local get_heat, get_humidity = minetest.get_heat, minetest.get_humidity

local biomeinfoAvailable = minetest.get_modpath("biomeinfo") ~= nil and minetest.global_exists("biomeinfo")
local isMapgenV6 = minetest.get_mapgen_setting("mg_name") == "v6"
if isMapgenV6 then
  if not biomeinfoAvailable then
    -- The biomeinfo mod by Wuzzy can be found at https://repo.or.cz/minetest_biomeinfo.git
    minetest.log("warning", MODNAME .. " detected mapgen v6: Full mapgen v6 support requires adding the biomeinfo mod.")
  else
    get_heat = function(pos)
      return biomeinfo.get_v6_heat(pos) * 100
    end
    get_humidity = function(pos)
      return biomeinfo.get_v6_humidity(pos) * 100
    end
  end
end

local interop = {}
-- returns the id of the first nodename in the list that resolves to a node id, or nodeId_ignore if not found
interop.find_node_id = function (node_contender_names)
  local result = nodeId_ignore
  for _,contenderName in ipairs(node_contender_names) do

    local nonAliasName = minetest.registered_aliases[contenderName] or contenderName
    if minetest.registered_nodes[nonAliasName] ~= nil then
      result = minetest.get_content_id(nonAliasName)
    end

    --if DEBUG then minetest.log("info", contenderName .. " returned " .. result .. " (" .. minetest.get_name_from_content_id(result) .. ")") end
    if result ~= nodeId_ignore then return result end
  end
  return result
end

-- returns the name of the first nodename in the list that resolves to a node id, or 'ignore' if not found
interop.find_node_name = function (node_contender_names)
  return minetest.get_name_from_content_id(interop.find_node_id(node_contender_names))
end

interop.get_first_element_in_table = function(tbl)
  for k,v in pairs(tbl) do return v end
  return nil
end

-- returns the top-texture name of the first nodename in the list that's a registered node, or nil if not found
interop.find_node_texture = function (node_contender_names)
  local result = nil
  local nodeName = minetest.get_name_from_content_id(interop.find_node_id(node_contender_names))
  if nodeName ~= nil then
    local node = minetest.registered_nodes[nodeName]
    if node ~= nil then
      result = node.tiles
      if type(result) == "table" then result = result["name"] or interop.get_first_element_in_table(result) end -- incase it's not a string
      if type(result) == "table" then result = result["name"] or interop.get_first_element_in_table(result) end -- incase multiple tile definitions
    end
  end
  return result
end

-- returns the node name of the clone node.
interop.register_clone = function(node_name, clone_name)
  local node = minetest.registered_nodes[node_name]
  if node == nil then
    minetest.log("error", "cannot clone " .. node_name)
    return nil
  else
    if clone_name == nil then clone_name = MODNAME .. ":" .. string.gsub(node.name, ":", "_") end
    if minetest.registered_nodes[clone_name] == nil then
      if DEBUG then minetest.log("info", "attempting to register: " .. clone_name) end
      local clone = {}
      for key, value in pairs(node) do clone[key] = value end
      clone.name = clone_name
      minetest.register_node(clone_name, clone)
      --minetest.log("info", clone_name .. " id: " .. minetest.get_content_id(clone_name))
      --minetest.log("info", clone_name .. ": " .. dump(minetest.registered_nodes[clone_name]))
    end
    return clone_name
  end
end

-- converts "modname:nodename" into (modname, nodename), if no colon is found then modname is nil
interop.split_nodename = function(nodeName)
  local result_modname = nil
  local result_nodename = nodeName

  local pos = nodeName:find(':')
  if pos ~= nil then
    result_modname  = nodeName:sub(0, pos - 1)
    result_nodename = nodeName:sub(pos + 1)
  end
  return result_modname, result_nodename
end

-- returns a unique id for the biome, normally this is numeric but with mapgen v6 it can be a string name.
interop.get_biome_key = function(pos)
  if isMapgenV6 and biomeinfoAvailable then
    return biomeinfo.get_v6_biome(pos)
  else
    return minetest.get_biome_data(pos).biome
  end
end

-- returns true if filename is a file that exists.
interop.file_exists = function(filename)
  local f = io.open(filename, "r")
  if f == nil then
    return false
  else
    f:close()
    return true
  end
end

-- returns a written book item (technically an item stack), or nil if no books mod available
interop.write_book = function(title, author, text, description)

  local stackName_writtenBook
  if minetest.get_modpath("mcl_books") then
    stackName_writtenBook = "mcl_books:written_book"
    text = title .. "\n\n" .. text -- MineClone2 books doen't show a title (or author)

  elseif minetest.get_modpath("book") ~= nil then
    stackName_writtenBook = "book:book_written"
    text = "\n\n" .. text -- Crafter books put the text immediately under the title

  elseif minetest.get_modpath("default") ~= nil then
    stackName_writtenBook = "default:book_written"

  else
    return nil
  end

  local book_itemstack = ItemStack(stackName_writtenBook)
  local book_data = {}
  book_data.title = title
  book_data.text  = text
  book_data.owner = author
  book_data.author = author
  book_data.description = description
  book_data.page = 1
  book_data.page_max = 1
  book_data.generation = 0
  book_data["book.book_title"] = title -- Crafter book title
  book_data["book.book_text"]  = text  -- Crafter book text

  book_itemstack:get_meta():from_table({fields = book_data})

  return book_itemstack
end

--[[==============================
              Portals
    ==============================]]--

local addDetail_ancientPortal = nil

if ENABLE_PORTALS and minetest.get_modpath("nether") ~= nil and minetest.global_exists("nether") and nether.register_portal ~= nil then
  -- The Portals API is available
  -- Register a player-buildable portal to Hallelujah Mountains.


  -- returns a position on the island which is suitable for a portal to be placed, or nil if none can be found
  -- player_name is optional, allowing a player to spawn a remote portal in their own protected areas.
  local function find_potential_portal_location_on_island(island_info, player_name)

    local result = nil

    if island_info ~= nil then
      local searchRadius = island_info.radius * 0.6 -- islands normally don't reach their full radius, and lets not put portals too near the edge
      local coreList = cloudlands.get_island_details(
        {x = island_info.x - searchRadius, z = island_info.z - searchRadius},
        {x = island_info.x + searchRadius, z = island_info.z + searchRadius}
      )

      -- Deterministically sample the island for a low location that isn't water.
      -- Seed the prng so this function always returns the same coords for the island
      local prng = PcgRandom(island_info.x * 65732 + island_info.z * 729 + minetest.get_mapgen_setting("seed") * 3)
      local positions = {}

      for attempt = 1, 15 do -- how many attempts we'll make at finding a good location
        local angle = (prng:next(0, 10000) / 10000) * 2 * PI
        local distance = math_sqrt(prng:next(0, 10000) / 10000) * searchRadius
        if attempt == 1 then distance = 0 end -- Always sample the middle of the island, as it's the safest fallback location
        local x = round(island_info.x + math_cos(angle) * distance)
        local z = round(island_info.z + math_sin(angle) * distance)
        local y, isWater = cloudlands.get_height_at(x, z, coreList)
        if y ~= nil then
          local weight = 0
          if not isWater                          then weight = weight + 1 end -- avoid putting portals in ponds
          if y >= island_info.y + ALTITUDE             then weight = weight + 2 end -- avoid putting portals down the sides of eroded cliffs
          positions[#positions + 1] = {x = x, y = y + 1, z = z, weight = weight}
        end
      end

      -- Order the locations by how good they are
      local compareFn = function(pos_a, pos_b)
        if pos_a.weight > pos_b.weight then return true end
        if pos_a.weight == pos_b.weight and pos_a.y < pos_b.y then return true end -- I can't justify why I think lower positions are better. I'm imagining portals nested in valleys rather than on ridges.
        return false
      end
      table.sort(positions, compareFn)

      -- nether.volume_is_natural() was deprecated in favor of nether.volume_is_natural_and_unprotected()
      local volume_is_natural_and_unprotected = nether.volume_is_natural_and_unprotected or nether.volume_is_natural

      -- Now the locations are sorted by how good they are, find the first/best that doesn't
      -- grief a player build.
      -- Ancient Portalstone has is_ground_content set to true, so we won't have to worry about old/broken
      -- portal frames interfering with the results of nether.volume_is_natural_and_unprotected()
      for _, position in ipairs(positions) do
        -- Unfortunately, at this point we don't know the orientation of the portal, so use worst case
        local minp = {x = position.x - 2, y = position.y,     z = position.z - 2}
        local maxp = {x = position.x + 3, y = position.y + 4, z = position.z + 3}
        if volume_is_natural_and_unprotected(minp, maxp, player_name) then
          result = position
          break
        end
      end
    end

    return result
  end


  -- returns nil if no suitable location could be found, otherwise returns (portal_pos, island_info)
  -- player_name is optional, allowing a player to spawn a remote portal in their own protected areas.
  local function find_nearest_island_location_for_portal(surface_x, surface_z, player_name)

    local result = nil

    local island = cloudlands.find_nearest_island(surface_x, surface_z, 75)
    if island == nil then island = cloudlands.find_nearest_island(surface_x, surface_z, 150) end
    if island == nil then island = cloudlands.find_nearest_island(surface_x, surface_z, 400) end

    if island ~= nil then
      result = find_potential_portal_location_on_island(island, player_name)
    end

    return result, island
  end

  -- Ideally the Nether mod will provide a block obtainable by exploring the Nether which is
  -- earmarked for mods like this one to use for portals, but until this happens I'll create
  -- our own tempory placeholder "portalstone".
  -- The Portals API is currently provided by nether, which depends on default, so we can assume default textures are available
  local portalstone_end = "default_furnace_top.png^(default_ice.png^[opacity:120)^[multiply:#668"  -- this gonna look bad with non-default texturepacks, hopefully Nether mod will provide a real block
  local portalstone_side = "[combine:16x16:0,0=default_furnace_top.png:4,0=default_furnace_top.png:8,0=default_furnace_top.png:12,0=default_furnace_top.png:^(default_ice.png^[opacity:120)^[multiply:#668"
  minetest.register_node("cloudlands:ancient_portalstone", {
    description = S("Ancient Portalstone"),
    tiles = {portalstone_end, portalstone_end, portalstone_side, portalstone_side, portalstone_side, portalstone_side},
    paramtype2 = "facedir",
    sounds = default.node_sound_stone_defaults(),
    groups = {cracky = 1, level = 2},
    on_blast = function() --[[blast proof]] end
  })

  minetest.register_ore({
    ore_type       = "scatter",
    ore            = "cloudlands:ancient_portalstone",
    wherein        = "nether:rack",
    clust_scarcity = 32 * 32 * 32,
    clust_num_ores = 6,
    clust_size     = 3,
    y_max = nether.DEPTH_CEILING or nether.DEPTH,
    y_min = nether.DEPTH_FLOOR   or -32000,
  })

  local _  = {name = "air",                                         prob = 0}
  local A  = {name = "air",                                         prob = 255, force_place = true}
  local PU = {name = "cloudlands:ancient_portalstone", param2 =  0, prob = 255, force_place = true}
  local PW = {name = "cloudlands:ancient_portalstone", param2 = 12, prob = 255, force_place = true}
  local PN = {name = "cloudlands:ancient_portalstone", param2 =  4, prob = 255, force_place = true}
  minetest.register_decoration({
    name = "Ancient broken portal",
    deco_type = "schematic",
    place_on = "nether:rack",
    sidelen = 80,
    fill_ratio = 0.00018,
    biomes = {"nether_caverns"},
    y_max = nether.DEPTH_CEILING or nether.DEPTH,
    y_min = nether.DEPTH_FLOOR   or -32000,
    schematic = {
      size = {x = 4, y = 4, z = 1},
      data = {
          PN, A, PW, PN,
          PU, A,  A, PU,
          A,  _,  _, PU,
          _,  _,  _, PU
      },
      yslice_prob = {
          {ypos = 3, prob = 92},
          {ypos = 1, prob = 30},
      }
    },
    place_offset_y = 1,
    flags = "force_placement,all_floors",
    rotation = "random"
  })

  -- this uses place_schematic() without minetest.after(), so should be called after vm:write_to_map()
  addDetail_ancientPortal = function(core)

    if (core.radius < 8 or PORTAL_RARITY == 0) then return false end -- avoid portals hanging off the side of small islands

    local fastHash = 3
    fastHash = (37 * fastHash) + 9354 -- to keep this probability distinct from reefs and atols
    fastHash = (37 * fastHash) + ISLANDS_SEED
    fastHash = (37 * fastHash) + core.x
    fastHash = (37 * fastHash) + core.z
    fastHash = (37 * fastHash) + math_floor(core.radius)
    fastHash = (37 * fastHash) + math_floor(core.depth)
    if (PORTAL_RARITY * 10000) < math_floor((math_abs(fastHash)) % 10000) then return false end

    local portalPos = find_potential_portal_location_on_island(core, nil)

    if portalPos ~= nil then
      local orientation = (fastHash % 2) * 90
      portalPos.y = portalPos.y - ((core.x + core.z) % 3) -- partially bury some ancient portals

      minetest.place_schematic(
        portalPos,
        {
          size = {x = 4, y = 5, z = 1},
          data = {
              PN, PW, PW, PN,
              PU,  _,  _, PU,
              PU,  _,  _, PU,
              PU,  _,  _, PU,
              PN, PW, PW, PN
          },
        },
        orientation,
        { -- node replacements
          ["default:obsidian"] = "cloudlands:ancient_portalstone",
        },
        true
      )
    end
  end


  nether.register_portal("cloudlands_portal", {
    shape               = nether.PortalShape_Traditional,
    frame_node_name     = "cloudlands:ancient_portalstone",
    wormhole_node_color = 2, -- 2 is blue
    particle_color      = "#77F",
    particle_texture    = {
      name      = "nether_particle_anim1.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 7,
        aspect_h = 7,
        length = 1,
      },
      scale = 1.5
    },
    title = S("Hallelujah Mountains Portal"),
    book_of_portals_pagetext =
      S("Construction requires 14 blocks of ancient portalstone. We have no knowledge of how portalstones were created, the means to craft them are likely lost to time, so our only source has been to scavenge the Nether for the remnants of ancient broken portals. A finished frame is four blocks wide, five blocks high, and stands vertically, like a doorway.") .. "\n\n" ..
      S("The only portal we managed to scavenge enough portalstone to build took us to a land of floating islands. There were hills and forests and even water up there, but the edges are a perilous drop — a depth of which we cannot even begin to plumb."),

    is_within_realm = function(pos)
      -- return true if pos is in the cloudlands
      -- I'm doing this based off height for speed, so it sometimes gets it wrong when the
      -- Hallelujah mountains start reaching the ground.
      if noise_heightMap == nil then cloudlands.init() end
      local largestCoreType  = cloudlands.coreTypes[1] -- the first island type is the biggest/thickest
      local island_bottom = ALTITUDE - (largestCoreType.depthMax * 0.66) + round(noise_heightMap:get_2d({x = pos.x, y = pos.z}))

      return pos.y > math_max(40, island_bottom)
    end,

    find_realm_anchorPos = function(surface_anchorPos, player_name)
      -- Find the nearest island and obtain a suitable surface position on it
      local destination_pos, island = find_nearest_island_location_for_portal(surface_anchorPos.x, surface_anchorPos.z, player_name)

      if island ~= nil then
        -- Allow any existing or player-positioned portal on the island to be linked to
        -- first before resorting to the island's default portal position
        local existing_portal_location, existing_portal_orientation = nether.find_nearest_working_portal(
          "cloudlands_portal",
          {x = island.x, y = 100000, z = island.z}, -- Using 100000 for y to ensure the position is in the cloudlands realm and so find_nearest_working_portal() will only returns island portals.
          island.radius * 0.9,                      -- Islands normally don't reach their full radius. Ensure this distance limit encompasses any location find_nearest_island_location_for_portal() can return.
          0 -- a y_factor of 0 makes the search ignore the altitude of the portals (as long as they are in the Cloudlands realm)
        )
        if existing_portal_location ~= nil then
          return existing_portal_location, existing_portal_orientation
        end
      end

      return destination_pos
    end,

    find_surface_anchorPos = function(realm_anchorPos)
      -- This function isn't needed since find_surface_target_y() will be used by default,
      -- but by implementing it I can look for any existing nearby portals before falling
      -- back to find_surface_target_y.

      -- Using -100000 for y to ensure the position is outside the cloudlands realm and so
      -- find_nearest_working_portal() will only returns ground portals.
      -- a y_factor of 0 makes the search ignore the -100000 altitude of the portals (as
      -- long as they are outside the cloudlands realm)
      local existing_portal_location, existing_portal_orientation =
        nether.find_nearest_working_portal("cloudlands_portal", {x = realm_anchorPos.x, y = -100000, z = realm_anchorPos.z}, 150, 0)

      if existing_portal_location ~= nil then
        return existing_portal_location, existing_portal_orientation
      else
        local y = nether.find_surface_target_y(realm_anchorPos.x, realm_anchorPos.z, "cloudlands_portal")
        return {x = realm_anchorPos.x, y = y, z = realm_anchorPos.z}
      end
    end,

    on_ignite = function(portalDef, anchorPos, orientation)
      -- make some sparks fly on ignition
      local p1, p2 = portalDef.shape:get_p1_and_p2_from_anchorPos(anchorPos, orientation)
      local pos = vector.divide(vector.add(p1, p2), 2)

      local textureName = portalDef.particle_texture
      if type(textureName) == "table" then textureName = textureName.name end

      local velocity
      if orientation == 0 then
        velocity = {x = 0, y = 0, z = 7}
      else
        velocity = {x = 7, y = 0, z = 0}
      end

      local particleSpawnerDef = {
        amount = 180,
        time   = 0.15,
        minpos = {x = pos.x - 1, y = pos.y - 1.5, z = pos.z - 1},
        maxpos = {x = pos.x + 1, y = pos.y + 1.5, z = pos.z + 1},
        minvel = velocity,
        maxvel = velocity,
        minacc = {x =  0, y =  0, z =  0},
        maxacc = {x =  0, y =  0, z =  0},
        minexptime = 0.1,
        maxexptime = 0.5,
        minsize = 0.3 * portalDef.particle_texture_scale,
        maxsize = 0.8 * portalDef.particle_texture_scale,
        collisiondetection = false,
        texture = textureName .. "^[colorize:#99F:alpha",
        animation = portalDef.particle_texture_animation,
        glow = 8
      }

      minetest.add_particlespawner(particleSpawnerDef)

      velocity = vector.multiply(velocity, -1)
      particleSpawnerDef.minvel, particleSpawnerDef.maxvel = velocity, velocity
      minetest.add_particlespawner(particleSpawnerDef)
    end

  })
end

--[[==============================
              SkyTrees
    ==============================]]--

-- If splitting SkyTrees into a seperate mod, perhaps schemlib would be of help - https://forum.minetest.net/viewtopic.php?t=18084


if not minetest.global_exists("SkyTrees") then -- If SkyTrees added into other mods, this may have already been defined

  local TREE1_FILE  = 'cloudlands_tree1.mts'
  local TREE2_FILE  = 'cloudlands_tree2.mts'
  local BARK_SUFFIX = '_bark'
  local GLOW_SUFFIX = '_glow'

  SkyTrees = {
    -- Order the trees in this schematicInfo array from the largest island requirements to smallest
    -- The data in each schematicInfo must exactly match what's in the .mts file or things will break
    schematicInfo = {
      {
        filename = TREE1_FILE,
        size   = {x = 81, y = 106, z = 111},
        center = {x = 37, y =  11, z =  73},
        requiredIslandDepth = 20,
        requiredIslandRadius = 40,
        nodesWithConstructor = {
          {x=35, y=69, z=1}, {x=61, y=51, z=2}, {x=36, y=68, z=2}, {x=68, y=48, z=3}, {x=61, y=50, z=4}, {x=71, y=50, z=5}, {x=58, y=52, z=5}, {x=65, y=50, z=9}, {x=72, y=53, z=11}, {x=41, y=67, z=12}, {x=63, y=48, z=13}, {x=69, y=52, z=13}, {x=33, y=66, z=14}, {x=39, y=68, z=15}, {x=72, y=68, z=15}, {x=40, y=67, z=16}, {x=39, y=66, z=17}, {x=68, y=45, z=19}, {x=69, y=44, z=20}, {x=72, y=55, z=20}, {x=66, y=56, z=20}, {x=58, y=66, z=20}, {x=71, y=58, z=21}, {x=68, y=45, z=22}, {x=70, y=51, z=22}, {x=73, y=55, z=22}, {x=36, y=62, z=22}, {x=70, y=67, z=22}, {x=21, y=65, z=23}, {x=22, y=66, z=23}, {x=53, y=66, z=23}, {x=70, y=68, z=23}, {x=73, y=54, z=24}, {x=75, y=57, z=24}, {x=37, y=63, z=24}, {x=7, y=68, z=24}, {x=69, y=56, z=25}, {x=34, y=58, z=25}, {x=66, y=62, z=25}, {x=64, y=66, z=25}, {x=6, y=67, z=25}, {x=3, y=68, z=25}, {x=68, y=56, z=26}, {x=65, y=57, z=26}, {x=61, y=63, z=26}, {x=31, y=59, z=27}, {x=48, y=62, z=27}, {x=50, y=63, z=27}, {x=78, y=65, z=27}, {x=78, y=52, z=28}, {x=68, y=57, z=28}, {x=76, y=57, z=28}, {x=31, y=60, z=28}, {x=15, y=63, z=28}, {x=16, y=63, z=28}, {x=66, y=64, z=28}, {x=60, y=65, z=28}, {x=61, y=76, z=28}, {x=63, y=76, z=28}, {x=69, y=59, z=29}, {x=51, y=65, z=29}, {x=72, y=57, z=30}, {x=20, y=60, z=30}, {x=21, y=61, z=30}, {x=49, y=65, z=30}, {x=52, y=53, z=31}, {x=72, y=57, z=31}, {x=36, y=58, z=31}, {x=63, y=60, z=31}, {x=54, y=63, z=31}, {x=45, y=65, z=31}, {x=79, y=66, z=31}, {x=62, y=70, z=31}, {x=55, y=103, z=31}, {x=52, y=53, z=32}, {x=68, y=60, z=32}, {x=19, y=61, z=32}, {x=53, y=63, z=32}, {x=37, y=64, z=32}, {x=21, y=65, z=32}, {x=56, y=65, z=32}, {x=59, y=71, z=32}, {x=35, y=74, z=32}, {x=23, y=75, z=32}, {x=35, y=58, z=33}, {x=62, y=60, z=33}, {x=18, y=63, z=33}, {x=73, y=67, z=33}, {x=37, y=74, z=33}, {x=65, y=75, z=33}, {x=38, y=2, z=34}, {x=67, y=52, z=34}, {x=71, y=60, z=34}, {x=25, y=63, z=34}, {x=19, y=64, z=34}, {x=32, y=66, z=34}, {x=66, y=72, z=34}, {x=41, y=81, z=34}, {x=45, y=93, z=34}, {x=54, y=99, z=34}, {x=38, y=5, z=35}, {x=68, y=48, z=35}, {x=69, y=51, z=35}, {x=48, y=53, z=35}, {x=37, y=57, z=35}, {x=77, y=58, z=35}, {x=32, y=60, z=35}, {x=20, y=61, z=35}, {x=27, y=61, z=35}, {x=33, y=65, z=35}, {x=58, y=65, z=35}, {x=58, y=72, z=35}, {x=60, y=73, z=35}, {x=30, y=74, z=35}, {x=41, y=74, z=35}, {x=41, y=87, z=35}, {x=22, y=58, z=36}, {x=64, y=58, z=36}, {x=39, y=70, z=36}, {x=36, y=77, z=36}, {x=44, y=83, z=36}, {x=40, y=86, z=36}, {x=35, y=56, z=37}, {x=65, y=59, z=37}, {x=66, y=62, z=37}, {x=62, y=67, z=37}, {x=39, y=68, z=37}, {x=40, y=86, z=37}, {x=53, y=88, z=37}, {x=43, y=97, z=37}, {x=52, y=99, z=37}, {x=37, y=3, z=38}, {x=35, y=55, z=38}, {x=38, y=56, z=38}, {x=25, y=57, z=38}, {x=65, y=57, z=38}, {x=71, y=61, z=38}, {x=33, y=65, z=38}, {x=61, y=65, z=38}, {x=50, y=66, z=38}, {x=38, y=68, z=38}, {x=46, y=97, z=38}, {x=44, y=100, z=38}, {x=51, y=102, z=38}, {x=29, y=42, z=39}, {x=27, y=43, z=39}, {x=70, y=48, z=39}, {x=72, y=52, z=39}, {x=23, y=57, z=39}, {x=26, y=57, z=39}, {x=28, y=58, z=39}, {x=55, y=58, z=39}, {x=73, y=59, z=39}, {x=65, y=65, z=39}, {x=41, y=68, z=39}, {x=42, y=81, z=39}, {x=55, y=88, z=39}, {x=43, y=91, z=39}, {x=45, y=100, z=39}, {x=23, y=57, z=40}, {x=29, y=57, z=40}, {x=76, y=58, z=40}, {x=73, y=59, z=40}, {x=78, y=59, z=40}, {x=31, y=60, z=40}, {x=64, y=64, z=40}, {x=41, y=67, z=40}, {x=42, y=75, z=40}, {x=37, y=78, z=40}, {x=42, y=92, z=40}, {x=51, y=101, z=40}, {x=48, y=105, z=40}, {x=75, y=59, z=41}, {x=55, y=63, z=41}, {x=35, y=68, z=41}, {x=35, y=69, z=41}, {x=35, y=71, z=41}, {x=34, y=42, z=42}, {x=29, y=55, z=42}, {x=50, y=61, z=42}, {x=34, y=65, z=42}, {x=57, y=88, z=42}, {x=48, y=89, z=42}, {x=49, y=89, z=42}, {x=27, y=22, z=43}, {x=26, y=28, z=43}, {x=31, y=46, z=43}, {x=66, y=52, z=43}, {x=49, y=57, z=43}, {x=56, y=57, z=43}, {x=41, y=69, z=43}, {x=36, y=52, z=44}, {x=63, y=54, z=44}, {x=51, y=55, z=44}, {x=57, y=56, z=44}, {x=69, y=57, z=44}, {x=64, y=65, z=44}, {x=55, y=90, z=44}, {x=30, y=42, z=45}, {x=31, y=52, z=45}, {x=51, y=54, z=45}, {x=24, y=57, z=45}, {x=70, y=62, z=45}, {x=39, y=69, z=45}, {x=35, y=80, z=45}, {x=29, y=81, z=45}, {x=44, y=85, z=45}, {x=41, y=86, z=45}, {x=33, y=9, z=46}, {x=28, y=44, z=46}, {x=50, y=54, z=46}, {x=47, y=55, z=46}, {x=45, y=56, z=46}, {x=45, y=58, z=46}, {x=47, y=58, z=46}, {x=30, y=63, z=46}, {x=27, y=81, z=46}, {x=28, y=81, z=46}, {x=40, y=86, z=46}, {x=29, y=16, z=47}, {x=32, y=10, z=48}, {x=66, y=49, z=48}, {x=29, y=52, z=48}, {x=53, y=54, z=48}, {x=55, y=54, z=48}, {x=61, y=58, z=48}, {x=59, y=61, z=48}, {x=50, y=63, z=48}, {x=26, y=82, z=48}, {x=43, y=85, z=48}, {x=48, y=86, z=48}, {x=31, y=19, z=49}, {x=30, y=46, z=49}, {x=63, y=51, z=49}, {x=41, y=53, z=49}, {x=31, y=60, z=49}, {x=67, y=1, z=50}, {x=37, y=8, z=50}, {x=40, y=30, z=50}, {x=43, y=57, z=50}, {x=59, y=57, z=50}, {x=60, y=57, z=50}, {x=29, y=61, z=50}, {x=34, y=63, z=50}, {x=49, y=65, z=50}, {x=65, y=3, z=51}, {x=45, y=29, z=51}, {x=41, y=58, z=51}, {x=42, y=60, z=51}, {x=46, y=64, z=51}, {x=47, y=67, z=51}, {x=52, y=68, z=51}, {x=69, y=51, z=52}, {x=53, y=55, z=52}, {x=45, y=62, z=52}, {x=64, y=2, z=53}, {x=3, y=3, z=53}, {x=10, y=6, z=53}, {x=31, y=14, z=53}, {x=37, y=35, z=53}, {x=43, y=48, z=53}, {x=71, y=50, z=53}, {x=52, y=54, z=53}, {x=43, y=57, z=53}, {x=55, y=57, z=53}, {x=52, y=67, z=53}, {x=48, y=72, z=53}, {x=5, y=1, z=54}, {x=9, y=4, z=54}, {x=62, y=4, z=54}, {x=33, y=8, z=54}, {x=42, y=29, z=54}, {x=42, y=32, z=54}, {x=43, y=34, z=54}, {x=41, y=39, z=54}, {x=41, y=57, z=54}, {x=34, y=61, z=54}, {x=58, y=2, z=55}, {x=59, y=3, z=55}, {x=38, y=7, z=55}, {x=40, y=12, z=55}, {x=38, y=39, z=55}, {x=33, y=46, z=55}, {x=28, y=54, z=55}, {x=29, y=55, z=55}, {x=30, y=57, z=55}, {x=54, y=58, z=55}, {x=52, y=63, z=55}, {x=37, y=7, z=56}, {x=55, y=8, z=56}, {x=33, y=45, z=56}, {x=58, y=0, z=57}, {x=9, y=5, z=57}, {x=34, y=7, z=57}, {x=54, y=8, z=57}, {x=17, y=9, z=57}, {x=32, y=12, z=57}, {x=37, y=39, z=57}, {x=41, y=45, z=57}, {x=31, y=46, z=57}, {x=49, y=50, z=57}, {x=50, y=56, z=57}, {x=46, y=59, z=57}, {x=48, y=66, z=57}, {x=51, y=67, z=57}, {x=15, y=3, z=58}, {x=8, y=10, z=58}, {x=41, y=11, z=58}, {x=40, y=13, z=58}, {x=42, y=45, z=58}, {x=50, y=51, z=58}, {x=20, y=5, z=59}, {x=19, y=7, z=59}, {x=22, y=8, z=59}, {x=23, y=9, z=59}, {x=40, y=13, z=59}, {x=33, y=14, z=59}, {x=42, y=41, z=59}, {x=20, y=6, z=60}, {x=9, y=8, z=60}, {x=46, y=8, z=60}, {x=34, y=39, z=60}, {x=30, y=52, z=60}, {x=43, y=57, z=60}, {x=18, y=5, z=61}, {x=11, y=10, z=61}, {x=36, y=36, z=61}, {x=47, y=55, z=61}, {x=38, y=56, z=61}, {x=61, y=59, z=61}, {x=56, y=60, z=61}, {x=36, y=6, z=62}, {x=55, y=7, z=62}, {x=26, y=10, z=62}, {x=29, y=13, z=62}, {x=46, y=13, z=62}, {x=57, y=60, z=62}, {x=18, y=7, z=63}, {x=30, y=11, z=63}, {x=53, y=13, z=63}, {x=45, y=14, z=63}, {x=36, y=32, z=63}, {x=46, y=41, z=63}, {x=29, y=43, z=63}, {x=29, y=44, z=63}, {x=29, y=46, z=63}, {x=29, y=50, z=63}, {x=30, y=52, z=63}, {x=46, y=54, z=63}, {x=19, y=6, z=64}, {x=54, y=8, z=64}, {x=16, y=11, z=64}, {x=42, y=16, z=64}, {x=36, y=25, z=64}, {x=37, y=27, z=64}, {x=36, y=28, z=64}, {x=37, y=29, z=64}, {x=40, y=33, z=64}, {x=30, y=36, z=64}, {x=43, y=39, z=64}, {x=62, y=61, z=64}, {x=21, y=6, z=65}, {x=24, y=6, z=65}, {x=53, y=10, z=65}, {x=52, y=12, z=65}, {x=27, y=17, z=65}, {x=39, y=17, z=65}, {x=29, y=19, z=65}, {x=32, y=22, z=65}, {x=28, y=42, z=65}, {x=60, y=61, z=65}, {x=24, y=6, z=66}, {x=26, y=6, z=66}, {x=19, y=12, z=66}, {x=28, y=20, z=66}, {x=31, y=26, z=66}, {x=39, y=55, z=66}, {x=42, y=6, z=67}, {x=24, y=7, z=67}, {x=20, y=14, z=67}, {x=41, y=21, z=67}, {x=28, y=22, z=67}, {x=29, y=46, z=67},
          {x=34, y=52, z=67}, {x=45, y=17, z=68}, {x=42, y=25, z=68}, {x=28, y=43, z=68}, {x=46, y=44, z=68}, {x=29, y=7, z=69}, {x=49, y=12, z=69}, {x=29, y=43, z=69}, {x=48, y=9, z=70}, {x=45, y=17, z=70}, {x=36, y=9, z=71}, {x=47, y=10, z=71}, {x=25, y=11, z=71}, {x=45, y=17, z=71}, {x=42, y=46, z=71}, {x=34, y=47, z=71}, {x=35, y=48, z=71}, {x=45, y=10, z=72}, {x=25, y=12, z=72}, {x=45, y=35, z=72}, {x=45, y=43, z=72}, {x=36, y=52, z=72}, {x=39, y=55, z=72}, {x=26, y=19, z=73}, {x=27, y=21, z=73}, {x=26, y=27, z=73}, {x=26, y=29, z=73}, {x=43, y=31, z=73}, {x=28, y=36, z=73}, {x=42, y=41, z=73}, {x=34, y=46, z=73}, {x=39, y=59, z=73}, {x=24, y=9, z=74}, {x=48, y=9, z=74}, {x=35, y=48, z=74}, {x=35, y=51, z=74}, {x=42, y=53, z=74}, {x=33, y=57, z=74}, {x=30, y=60, z=74}, {x=47, y=8, z=75}, {x=22, y=12, z=75}, {x=45, y=18, z=75}, {x=27, y=30, z=75}, {x=45, y=33, z=75}, {x=36, y=49, z=75}, {x=36, y=1, z=76}, {x=45, y=7, z=76}, {x=21, y=14, z=76}, {x=44, y=23, z=76}, {x=29, y=35, z=76}, {x=38, y=40, z=76}, {x=39, y=42, z=76}, {x=33, y=58, z=76}, {x=34, y=1, z=77}, {x=21, y=7, z=77}, {x=18, y=11, z=77}, {x=26, y=23, z=77}, {x=43, y=25, z=77}, {x=41, y=32, z=77}, {x=36, y=41, z=77}, {x=39, y=47, z=77}, {x=35, y=56, z=77}, {x=35, y=1, z=78}, {x=26, y=3, z=78}, {x=34, y=3, z=78}, {x=18, y=9, z=78}, {x=27, y=23, z=78}, {x=51, y=33, z=78}, {x=41, y=37, z=78}, {x=36, y=1, z=79}, {x=25, y=2, z=79}, {x=18, y=8, z=79}, {x=15, y=10, z=79}, {x=14, y=11, z=79}, {x=27, y=23, z=79}, {x=28, y=25, z=79}, {x=45, y=32, z=79}, {x=33, y=34, z=79}, {x=34, y=34, z=79}, {x=37, y=55, z=79}, {x=40, y=62, z=79}, {x=27, y=0, z=80}, {x=31, y=18, z=80}, {x=30, y=26, z=80}, {x=34, y=61, z=80}, {x=20, y=7, z=81}, {x=51, y=7, z=81}, {x=25, y=8, z=81}, {x=53, y=8, z=81}, {x=42, y=10, z=81}, {x=56, y=12, z=81}, {x=21, y=15, z=81}, {x=37, y=28, z=81}, {x=36, y=29, z=81}, {x=37, y=29, z=81}, {x=44, y=35, z=81}, {x=22, y=7, z=82}, {x=26, y=8, z=82}, {x=29, y=8, z=82}, {x=44, y=9, z=82}, {x=42, y=10, z=82}, {x=32, y=13, z=82}, {x=13, y=14, z=82}, {x=29, y=22, z=82}, {x=31, y=25, z=82}, {x=35, y=27, z=82}, {x=27, y=60, z=82}, {x=41, y=64, z=82}, {x=20, y=8, z=83}, {x=57, y=8, z=83}, {x=24, y=9, z=83}, {x=58, y=9, z=83}, {x=36, y=22, z=83}, {x=32, y=24, z=83}, {x=47, y=8, z=84}, {x=56, y=8, z=84}, {x=59, y=11, z=84}, {x=45, y=13, z=84}, {x=58, y=13, z=84}, {x=17, y=14, z=84}, {x=23, y=14, z=84}, {x=56, y=14, z=84}, {x=29, y=19, z=84}, {x=36, y=19, z=84}, {x=27, y=59, z=84}, {x=35, y=6, z=85}, {x=9, y=8, z=85}, {x=41, y=11, z=85}, {x=50, y=13, z=85}, {x=33, y=58, z=85}, {x=34, y=58, z=85}, {x=33, y=7, z=86}, {x=18, y=10, z=86}, {x=9, y=12, z=86}, {x=41, y=12, z=87}, {x=41, y=60, z=87}, {x=9, y=2, z=88}, {x=7, y=5, z=88}, {x=5, y=10, z=88}, {x=41, y=11, z=88}, {x=62, y=11, z=88}, {x=42, y=68, z=88}, {x=37, y=6, z=89}, {x=66, y=8, z=89}, {x=9, y=10, z=89}, {x=19, y=10, z=89}, {x=58, y=12, z=89}, {x=45, y=62, z=89}, {x=7, y=5, z=90}, {x=67, y=5, z=90}, {x=7, y=9, z=90}, {x=31, y=11, z=90}, {x=62, y=11, z=90}, {x=1, y=2, z=91}, {x=5, y=5, z=91}, {x=69, y=5, z=91}, {x=62, y=8, z=91}, {x=58, y=9, z=91}, {x=63, y=10, z=91}, {x=35, y=7, z=92}, {x=62, y=9, z=92}, {x=33, y=13, z=92}, {x=36, y=62, z=92}, {x=37, y=3, z=93}, {x=37, y=6, z=93}, {x=64, y=6, z=93}, {x=32, y=10, z=93}, {x=34, y=14, z=93}, {x=39, y=57, z=93}, {x=41, y=67, z=93}, {x=33, y=9, z=94}, {x=38, y=57, z=94}, {x=41, y=69, z=94}, {x=40, y=1, z=95}, {x=34, y=7, z=97}, {x=33, y=9, z=97}, {x=33, y=10, z=102}, {x=33, y=7, z=105}, {x=35, y=9, z=107}
        }
      },
      {
        filename = TREE2_FILE,
        size   = {x = 62, y = 65, z = 65},
        center = {x = 30, y = 12, z = 36},
        requiredIslandDepth = 16,
        requiredIslandRadius = 24,
        nodesWithConstructor = { {x=35, y=53, z=1}, {x=33, y=59, z=1}, {x=32, y=58, z=3}, {x=31, y=57, z=5}, {x=40, y=58, z=6}, {x=29, y=57, z=7}, {x=39, y=51, z=8}, {x=52, y=53, z=8}, {x=32, y=53, z=9}, {x=25, y=58, z=9}, {x=51, y=51, z=10}, {x=47, y=50, z=11}, {x=50, y=55, z=11}, {x=28, y=57, z=11}, {x=26, y=39, z=12}, {x=30, y=39, z=12}, {x=24, y=40, z=12}, {x=53, y=52, z=12}, {x=29, y=57, z=12}, {x=43, y=59, z=12}, {x=26, y=39, z=13}, {x=36, y=48, z=13}, {x=27, y=39, z=14}, {x=39, y=48, z=14}, {x=33, y=50, z=14}, {x=43, y=50, z=14}, {x=24, y=59, z=14}, {x=41, y=49, z=15}, {x=33, y=12, z=16}, {x=36, y=46, z=16}, {x=50, y=51, z=16}, {x=46, y=57, z=16}, {x=36, y=45, z=17}, {x=27, y=46, z=17}, {x=22, y=48, z=17}, {x=45, y=50, z=17}, {x=31, y=38, z=18}, {x=32, y=38, z=18}, {x=39, y=46, z=18}, {x=51, y=51, z=18}, {x=31, y=11, z=19}, {x=32, y=38, z=19}, {x=39, y=41, z=19}, {x=45, y=57, z=19}, {x=29, y=58, z=19}, {x=28, y=60, z=20}, {x=38, y=40, z=21}, {x=30, y=58, z=21}, {x=31, y=13, z=22}, {x=20, y=41, z=22}, {x=22, y=43, z=22}, {x=20, y=48, z=22}, {x=22, y=39, z=23}, {x=49, y=50, z=23}, {x=52, y=52, z=23}, {x=53, y=53, z=23}, {x=32, y=55, z=23}, {x=36, y=59, z=23}, {x=31, y=60, z=23}, {x=25, y=46, z=24}, {x=40, y=56, z=24}, {x=34, y=58, z=24}, {x=38, y=58, z=24}, {x=32, y=39, z=25}, {x=40, y=46, z=25}, {x=39, y=55, z=25}, {x=36, y=45, z=26}, {x=12, y=7, z=28}, {x=34, y=33, z=28}, {x=31, y=36, z=28}, {x=37, y=41, z=28}, {x=14, y=60, z=28}, {x=19, y=13, z=29}, {x=12, y=43, z=29}, {x=8, y=45, z=29}, {x=31, y=46, z=29}, {x=39, y=47, z=29}, {x=13, y=60, z=29}, {x=22, y=63, z=29}, {x=51, y=9, z=30}, {x=32, y=39, z=30}, {x=33, y=40, z=30}, {x=34, y=44, z=30}, {x=22, y=1, z=31}, {x=24, y=2, z=31}, {x=20, y=7, z=31}, {x=51, y=9, z=31}, {x=16, y=12, z=31}, {x=34, y=27, z=31}, {x=22, y=43, z=31}, {x=27, y=44, z=31}, {x=23, y=51, z=31}, {x=42, y=58, z=31}, {x=9, y=60, z=31}, {x=22, y=5, z=32}, {x=22, y=6, z=32}, {x=50, y=10, z=32}, {x=53, y=11, z=32}, {x=41, y=15, z=32}, {x=43, y=15, z=32}, {x=31, y=21, z=32}, {x=31, y=28, z=32}, {x=12, y=42, z=32}, {x=15, y=42, z=32}, {x=13, y=48, z=32}, {x=37, y=49, z=32}, {x=18, y=59, z=32}, {x=52, y=9, z=33}, {x=40, y=10, z=33}, {x=43, y=10, z=33}, {x=22, y=11, z=33}, {x=27, y=11, z=33}, {x=50, y=11, z=33}, {x=22, y=15, z=33}, {x=36, y=29, z=33}, {x=33, y=37, z=33}, {x=9, y=42, z=33}, {x=14, y=42, z=33}, {x=18, y=43, z=33}, {x=23, y=43, z=33}, {x=33, y=49, z=33}, {x=43, y=53, z=33}, {x=54, y=53, z=33}, {x=31, y=55, z=33}, {x=23, y=58, z=33}, {x=43, y=10, z=34}, {x=44, y=10, z=34}, {x=32, y=12, z=34}, {x=46, y=13, z=34}, {x=28, y=29, z=34}, {x=20, y=42, z=34}, {x=39, y=50, z=34}, {x=51, y=52, z=34}, {x=54, y=52, z=34}, {x=35, y=55, z=34}, {x=51, y=56, z=34}, {x=35, y=5, z=35}, {x=34, y=8, z=35}, {x=33, y=10, z=35}, {x=49, y=10, z=35}, {x=43, y=14, z=35}, {x=36, y=35, z=35}, {x=30, y=47, z=35}, {x=9, y=48, z=35}, {x=39, y=51, z=35}, {x=56, y=52, z=35}, {x=40, y=56, z=35}, {x=13, y=59, z=35}, {x=26, y=62, z=35}, {x=28, y=13, z=36}, {x=38, y=17, z=36}, {x=38, y=20, z=36}, {x=27, y=26, z=36}, {x=38, y=35, z=36}, {x=24, y=39, z=36}, {x=6, y=43, z=36}, {x=13, y=57, z=36}, {x=48, y=7, z=37}, {x=33, y=8, z=37}, {x=50, y=9, z=37}, {x=36, y=11, z=37}, {x=27, y=20, z=37}, {x=27, y=22, z=37}, {x=38, y=24, z=37}, {x=33, y=34, z=37}, {x=9, y=42, z=37}, {x=14, y=42, z=37}, {x=25, y=42, z=37}, {x=53, y=50, z=37}, {x=33, y=53, z=37}, {x=54, y=59, z=37}, {x=28, y=21, z=38}, {x=39, y=34, z=38}, {x=24, y=35, z=38}, {x=8, y=43, z=38}, {x=6, y=47, z=38}, {x=48, y=51, z=38}, {x=61, y=53, z=38}, {x=26, y=57, z=38}, {x=27, y=57, z=38}, {x=32, y=59, z=38}, {x=29, y=62, z=38}, {x=38, y=62, z=38}, {x=33, y=7, z=39}, {x=34, y=9, z=39}, {x=28, y=23, z=39}, {x=34, y=37, z=39}, {x=19, y=42, z=39}, {x=55, y=50, z=39}, {x=47, y=51, z=39}, {x=11, y=54, z=39}, {x=9, y=60, z=39}, {x=33, y=61, z=39}, {x=33, y=4, z=40}, {x=30, y=11, z=40}, {x=39, y=13, z=40}, {x=36, y=23, z=40}, {x=22, y=38, z=40}, {x=54, y=49, z=40}, {x=53, y=50, z=40}, {x=23, y=54, z=40}, {x=28, y=57, z=40}, {x=29, y=57, z=40}, {x=31, y=29, z=41}, {x=27, y=34, z=41}, {x=30, y=37, z=41}, {x=42, y=38, z=41}, {x=12, y=42, z=41}, {x=15, y=42, z=41}, {x=44, y=44, z=41}, {x=28, y=57, z=41}, {x=55, y=57, z=41}, {x=9, y=59, z=41}, {x=30, y=10, z=42}, {x=26, y=15, z=42}, {x=31, y=15, z=42}, {x=34, y=17, z=42}, {x=28, y=36, z=42}, {x=38, y=44, z=42}, {x=42, y=44, z=42}, {x=46, y=44, z=42}, {x=32, y=47, z=42}, {x=52, y=47, z=42}, {x=39, y=55, z=42}, {x=54, y=56, z=42}, {x=34, y=59, z=42}, {x=40, y=11, z=43}, {x=30, y=14, z=43}, {x=28, y=16, z=43}, {x=34, y=31, z=43}, {x=11, y=43, z=43}, {x=14, y=43, z=43}, {x=28, y=47, z=43}, {x=57, y=50, z=43}, {x=61, y=54, z=43}, {x=30, y=58, z=43}, {x=34, y=59, z=43}, {x=7, y=61, z=43}, {x=41, y=10, z=44}, {x=29, y=15, z=44}, {x=36, y=39, z=44}, {x=6, y=43, z=44}, {x=30, y=47, z=44}, {x=57, y=50, z=44}, {x=38, y=10, z=45}, {x=42, y=10, z=45}, {x=11, y=43, z=45}, {x=14, y=43, z=45}, {x=46, y=44, z=45}, {x=32, y=45, z=45}, {x=55, y=45, z=45}, {x=3, y=48, z=45}, {x=31, y=57, z=45}, {x=41, y=3, z=46}, {x=40, y=7, z=46}, {x=28, y=11, z=46}, {x=23, y=13, z=46}, {x=19, y=43, z=46}, {x=24, y=9, z=47}, {x=39, y=9, z=47}, {x=43, y=12, z=47}, {x=5, y=43, z=47}, {x=42, y=43, z=47}, {x=46, y=43, z=47}, {x=24, y=47, z=47}, {x=60, y=52, z=47}, {x=24, y=54, z=47}, {x=37, y=57, z=47}, {x=11, y=60, z=47}, {x=27, y=9, z=48}, {x=27, y=11, z=48}, {x=22, y=14, z=48}, {x=15, y=44, z=48}, {x=51, y=45, z=48}, {x=23, y=49, z=48}, {x=59, y=53, z=48}, {x=9, y=56, z=48}, {x=33, y=59, z=48}, {x=41, y=14, z=49}, {x=8, y=43, z=49}, {x=10, y=43, z=49}, {x=39, y=43, z=49}, {x=34, y=44, z=49}, {x=47, y=44, z=49}, {x=48, y=44, z=49}, {x=24, y=51, z=49}, {x=10, y=55, z=49}, {x=32, y=59, z=49}, {x=20, y=61, z=49}, {x=11, y=63, z=49}, {x=25, y=8, z=50}, {x=22, y=10, z=50}, {x=42, y=14, z=50}, {x=10, y=43, z=50}, {x=43, y=43, z=50}, {x=61, y=46, z=50}, {x=39, y=54, z=50}, {x=24, y=12, z=51}, {x=50, y=44, z=51}, {x=52, y=45, z=51}, {x=54, y=45, z=51}, {x=2, y=46, z=51}, {x=8, y=51, z=51}, {x=7, y=52, z=51}, {x=37, y=58, z=51}, {x=22, y=50, z=52}, {x=25, y=55, z=52}, {x=39, y=58, z=52}, {x=20, y=7, z=53}, {x=40, y=43, z=53}, {x=58, y=45, z=53}, {x=60, y=50, z=53}, {x=22, y=55, z=53}, {x=28, y=56, z=53}, {x=50, y=62, z=53}, {x=54, y=45, z=54}, {x=61, y=46, z=54}, {x=30, y=47, z=54}, {x=30, y=49, z=54}, {x=53, y=53, z=54}, {x=18, y=55, z=54}, {x=51, y=56, z=54}, {x=46, y=62, z=54}, {x=21, y=56, z=55}, {x=24, y=56, z=55}, {x=38, y=61, z=55}, {x=19, y=49, z=56}, {x=46, y=52, z=56}, {x=47, y=53, z=56}, {x=59, y=47, z=57}, {x=26, y=57, z=57}, {x=45, y=43, z=58}, {x=15, y=50, z=58}, {x=11, y=51, z=58}, {x=50, y=44, z=59}, {x=53, y=47, z=59}, {x=43, y=49, z=59}, {x=18, y=50, z=59}, {x=18, y=51, z=60}, {x=38, y=45, z=61}, {x=50, y=47, z=61}, {x=41, y=48, z=61} },
      }
    },
    MODNAME = minetest.get_current_modname() -- don't hardcode incase it's copied into other mods
  }

  -- Must be called during mod load time, as it uses minetest.register_node()
  -- (add an optional dependency for any mod where the tree & leaf textures might be
  -- sourced from, to ensure they are loaded before this is called)
  SkyTrees.init = function()

    SkyTrees.minimumIslandRadius = 100000
    SkyTrees.minimumIslandDepth  = 100000
    SkyTrees.maximumYOffset      = 0
    SkyTrees.maximumHeight       = 0

    SkyTrees.nodeName_sideVines   = interop.find_node_name(NODENAMES_VINES)
    SkyTrees.nodeName_hangingVine = interop.find_node_name(NODENAMES_HANGINGVINE)
    SkyTrees.nodeName_hangingRoot = interop.find_node_name(NODENAMES_HANGINGROOT)

    for i,tree in pairs(SkyTrees.schematicInfo) do
      local fullFilename = minetest.get_modpath(SkyTrees.MODNAME) .. DIR_DELIM .. tree.filename

      if not interop.file_exists(fullFilename) then
        -- remove the schematic from the list
        SkyTrees.schematicInfo[i] = nil
      else
        SkyTrees.minimumIslandRadius = math_min(SkyTrees.minimumIslandRadius, tree.requiredIslandRadius)
        SkyTrees.minimumIslandDepth  = math_min(SkyTrees.minimumIslandDepth,  tree.requiredIslandDepth)
        SkyTrees.maximumYOffset      = math_max(SkyTrees.maximumYOffset,      tree.center.y)
        SkyTrees.maximumHeight       = math_max(SkyTrees.maximumHeight,       tree.size.y)

        tree.theme = {}
        SkyTrees.schematicInfo[tree.filename] = tree -- so schematicInfo of trees can be indexed by name
      end
    end

    local function generate_woodTypes(nodeName_templateWood, overlay, barkoverlay, nodesuffix, description, dropsTemplateWood)

      local trunkNode = minetest.registered_nodes[nodeName_templateWood]
      local newTrunkNode = {}
      for key, value in pairs(trunkNode) do newTrunkNode[key] = value end
      newTrunkNode.name = SkyTrees.MODNAME .. ":" .. nodesuffix
      newTrunkNode.description = description
      if newTrunkNode.paramtype2 == nil then newTrunkNode.paramtype2 = "facedir" end
      if newTrunkNode.on_dig ~= nil and minetest.get_modpath("main") then
        newTrunkNode.on_dig = nil -- Crafter has special trunk auto-digging logic that doesn't make sense for giant trees
      end

      if dropsTemplateWood then
        newTrunkNode.drop = nodeName_templateWood
        if newTrunkNode.groups == nil then newTrunkNode.groups = {} end
        newTrunkNode.groups.not_in_creative_inventory = 1
      else
        newTrunkNode.drop = nil
      end

      local tiles = trunkNode.tiles
      if type(tiles) == "table" then
        newTrunkNode.tiles = {}
        for key, value in pairs(tiles) do newTrunkNode.tiles[key] = value .. overlay end
      else
        newTrunkNode.tiles = tiles .. overlay
      end

      local newBarkNode = {}
      for key, value in pairs(newTrunkNode) do newBarkNode[key] = value end
      newBarkNode.name = newBarkNode.name .. BARK_SUFFIX
      newBarkNode.description = S("Bark of @1", newBarkNode.description)
      -- .drop: leave the bark nodes dropping the trunk wood

      tiles = trunkNode.tiles
      if type(tiles) == "table" then
        newBarkNode.tiles = { tiles[#tiles] .. barkoverlay }
      end

      --minetest.log("info", newTrunkNode.name .. ": " .. dump(newTrunkNode))
      minetest.register_node(newTrunkNode.name, newTrunkNode)
      minetest.register_node(newBarkNode.name,  newBarkNode)
      return newTrunkNode.name
    end

    local function generate_leafTypes(nodeName_templateLeaf, overlay, nodesuffix, description, dropsTemplateLeaf, glowVariantBrightness)

      local leafNode = minetest.registered_nodes[nodeName_templateLeaf]
      local newLeafNode = {}
      for key, value in pairs(leafNode) do newLeafNode[key] = value end
      newLeafNode.name = SkyTrees.MODNAME .. ":" .. nodesuffix
      newLeafNode.description = description
      newLeafNode.sunlight_propagates = true -- soo many leaves they otherwise blot out the sun.
      if dropsTemplateLeaf then
        newLeafNode.drop = nodeName_templateLeaf
        if newLeafNode.groups == nil then newLeafNode.groups = {} end
        newLeafNode.groups.not_in_creative_inventory = 1
      else
        newLeafNode.drop = nil
      end

      local tiles = leafNode.tiles
      if type(tiles) == "table" then
        newLeafNode.tiles = {}
        for key, value in pairs(tiles) do newLeafNode.tiles[key] = value .. overlay end
      else
        newLeafNode.tiles = tiles .. overlay
      end

      minetest.register_node(newLeafNode.name, newLeafNode)

      if glowVariantBrightness ~= nil and glowVariantBrightness > 0 and BIOLUMINESCENCE then
        local glowingLeafNode = {}
        for key, value in pairs(newLeafNode) do glowingLeafNode[key] = value end
        glowingLeafNode.name = newLeafNode.name .. GLOW_SUFFIX
        glowingLeafNode.description = S("Glowing @1", description)
        glowingLeafNode.light_source = glowVariantBrightness
        minetest.register_node(glowingLeafNode.name, glowingLeafNode)
      end

      return newLeafNode.name
    end

    local templateWood = interop.find_node_name(NODENAMES_TREEWOOD)
    if templateWood == 'ignore' then
      SkyTrees.disabled = "Could not find any tree nodes"
      return
    end
    local normalwood = generate_woodTypes(templateWood, "", "", "tree", S("Giant tree"), true)
    local darkwood   = generate_woodTypes(templateWood, "^[colorize:black:205", "^[colorize:black:205", "darkwood", S("Giant Ziricote"), false)
    local deadwood   = generate_woodTypes(templateWood, "^[colorize:#EFE6B9:110", "^[colorize:#E8D0A0:110", "deadbleachedwood", S("Dead bleached wood"), false) -- make use of the bark blocks to introduce some color variance in the tree


    local templateLeaf = interop.find_node_name(NODENAMES_TREELEAVES)
    if templateLeaf == 'ignore' then
      SkyTrees.disabled = "Could not find any treeleaf nodes"
      return
    end
    local greenleaf1       = generate_leafTypes(templateLeaf, "",                      "leaves",   S("Leaves of a giant tree"), true) -- drops templateLeaf because these look close enough to the original leaves that we won't clutter the game & creative-menu with tiny visual variants that other recipes/parts of the game won't know about
    local greenleaf2       = generate_leafTypes(templateLeaf, "^[colorize:#00FF00:16", "leaves2",  S("Leaves of a giant tree"), false)
    local greenleaf3       = generate_leafTypes(templateLeaf, "^[colorize:#90FF60:28", "leaves3",  S("Leaves of a giant tree"), false)

    local whiteblossom1    = generate_leafTypes(templateLeaf, "^[colorize:#fffdfd:alpha", "blossom_white1",    S("Blossom"), false)
    local whiteblossom2    = generate_leafTypes(templateLeaf, "^[colorize:#fff0f0:alpha", "blossom_white2",    S("Blossom"), false)
    local pinkblossom      = generate_leafTypes(templateLeaf, "^[colorize:#FFE3E8:alpha", "blossom_whitepink", S("Blossom"), false, 5)

    local sakurablossom1   = generate_leafTypes(templateLeaf, "^[colorize:#ea327c:alpha", "blossom_red",       S("Sakura blossom"), false, 5)
    local sakurablossom2   = generate_leafTypes(templateLeaf, "^[colorize:#ffc3dd:alpha", "blossom_pink",      S("Sakura blossom"), false)

    local wisteriaBlossom1 = generate_leafTypes(templateLeaf, "^[colorize:#8087ec:alpha", "blossom_wisteria1", S("Wisteria blossom"), false)
    local wisteriaBlossom2 = generate_leafTypes(templateLeaf, "^[colorize:#ccc9ff:alpha", "blossom_wisteria2", S("Wisteria blossom"), false, 7)


    local tree = SkyTrees.schematicInfo[TREE1_FILE]
    if tree ~= nil then

      tree.defaultThemeName = "Green foliage"
      tree.theme[tree.defaultThemeName] = {
        relativeProbability = 5,
        trunk               = normalwood,
        leaves1             = greenleaf1,
        leaves2             = greenleaf2,
        leaves_special      = greenleaf3,
        vineflags           = { leaves = true, hanging_leaves = true },

        init = function(self, position)
          -- if it's hot and humid then add vines
          local viney = get_heat(position) >= VINES_REQUIRED_TEMPERATURE and get_humidity(position) >= VINES_REQUIRED_HUMIDITY

          if viney then
            local flagSeed = position.x * 3 + position.z + ISLANDS_SEED
            self.vineflags.hanging_leaves = (flagSeed % 10) <= 3 or (flagSeed % 10) >= 8
            self.vineflags.leaves         = (flagSeed % 10) <= 5
            self.vineflags.bark           = (flagSeed % 10) <= 2
            self.vineflags.hanging_bark   = (flagSeed % 10) <= 1
          end
        end
      }

      tree.theme["Haunted"] = {
        relativeProbability = 2,
        trunk               = darkwood,
        vineflags           = { hanging_roots = true },
        hasHeart            = false,
        hasSoil             = false,

        init = function(self, position)
          -- 60% of these trees are a hanging roots variant
          self.vineflags.hanging_roots = (position.x * 3 + position.y + position.z + ISLANDS_SEED) % 10 < 60
        end
      }

      tree.theme["Dead"] = {
        relativeProbability = 0, -- 0 because this theme will be chosen based on location, rather than chance.
        trunk = deadwood,
        hasHeart = false
      }

      tree.theme["Sakura"] = {
        relativeProbability = 2,
        trunk               = darkwood,
        leaves1             = sakurablossom2,
        leaves2             = whiteblossom2,
        leaves_special      = sakurablossom1,

        init = function(self, position)
          -- 40% of these trees are a glowing variant
          self.glowing = (position.x * 3 + position.z + ISLANDS_SEED) % 10 <= 3 and BIOLUMINESCENCE
          self.leaves_special = sakurablossom1
          if self.glowing then self.leaves_special = sakurablossom1 .. GLOW_SUFFIX end
        end
      }

    end

    tree = SkyTrees.schematicInfo[TREE2_FILE]
    if tree ~= nil then

      -- copy the green leaves theme from tree1
      tree.defaultThemeName = "Green foliage"
      tree.theme[tree.defaultThemeName] = SkyTrees.schematicInfo[TREE1_FILE].theme["Green foliage"]

      tree.theme["Wisteria"] = {
        relativeProbability = 2.5,
        trunk               = normalwood,
        leaves1             = greenleaf1,
        leaves2             = wisteriaBlossom1,
        leaves_special      = wisteriaBlossom2,
        vineflags           = { leaves = true, hanging_leaves = true, hanging_bark = true },

        init = function(self, position)
          -- 40% of these trees are a glowing variant
          self.glowing = (position.x * 3 + position.z + ISLANDS_SEED) % 10 <= 3 and BIOLUMINESCENCE
          self.leaves_special = wisteriaBlossom2
          if self.glowing then self.leaves_special = wisteriaBlossom2 .. GLOW_SUFFIX end

          -- if it's hot and humid then allow vines on the trunk as well
          self.vineflags.bark = get_heat(position) >= VINES_REQUIRED_TEMPERATURE and get_humidity(position) >= VINES_REQUIRED_HUMIDITY
        end
      }

      tree.theme["Blossom"] = {
        relativeProbability = 1.5,
        trunk               = normalwood,
        leaves1             = whiteblossom1,
        leaves2             = whiteblossom2,
        leaves_special      = normalwood..BARK_SUFFIX,

        init = function(self, position)
          -- 30% of these trees are a glowing variant
          self.glowing = (position.x * 3 + position.z + ISLANDS_SEED) % 10 <= 2 and BIOLUMINESCENCE
          self.leaves_special = normalwood..BARK_SUFFIX
          if self.glowing then self.leaves_special = pinkblossom .. GLOW_SUFFIX end
        end
      }

    end

    -- fill in any omitted fields in the themes with default values
    for _,treeInfo in pairs(SkyTrees.schematicInfo) do
      for _,theme in pairs(treeInfo.theme) do
        if theme.bark                == nil then theme.bark                = theme.trunk .. BARK_SUFFIX end
        if theme.leaves1             == nil then theme.leaves1             = 'ignore'                   end
        if theme.leaves2             == nil then theme.leaves2             = 'ignore'                   end
        if theme.leaves_special      == nil then theme.leaves_special      = theme.leaves1              end

        if theme.vineflags           == nil then theme.vineflags           = {}                         end
        if theme.relativeProbability == nil then theme.relativeProbability = 1.0                        end
        if theme.glowing             == nil then theme.glowing             = false                      end
        if theme.hasSoil             == nil then theme.hasSoil             = true                       end
        if theme.hasHeart            == nil then theme.hasHeart            = true                       end
      end
    end

    -- The heart of the Tree
    -- The difference between a living tree and and a haunted/darkened husk
    --
    -- Ideally trees would slowly fizzlefade to/from the Haunted theme depending on
    -- whether a player steals or restores the heart, meaning a house hollowed out inside
    -- a living tree would need the heart to still be kept inside it, perhaps on its
    -- own pedestal (unless wanting an Addam's Family treehouse).
    local heartwoodTexture = minetest.registered_nodes[templateWood].tiles
    if type(heartwoodTexture) == "table" then heartwoodTexture = heartwoodTexture[1] end
    local heartwoodGlow = minetest.LIGHT_MAX -- plants can grow under the heart of the Tree
    if not BIOLUMINESCENCE then heartwoodGlow = 0 end -- :(
    minetest.register_node(
      SkyTrees.MODNAME .. ":HeartWood",
      {
        tiles = { heartwoodTexture },
        description = S("Heart of the Tree"),
        groups = {oddly_breakable_by_hand = 3, handy = 1},
        _mcl_hardness = 0.4,
        drawtype = "nodebox",
        paramtype = "light",
        light_source = heartwoodGlow, -- plants can grow under the heart of the Tree
        node_box = {
          type = "fixed",
          fixed = {
            --[[ Original heart
            {-0.38, -0.38, -0.38, 0.38, 0.38, 0.38},
            {0.15, 0.15, 0.15, 0.5, 0.5, 0.5},
            {-0.5, 0.15, 0.15, -0.15, 0.5, 0.5},
            {-0.5, 0.15, -0.5, -0.15, 0.5, -0.15},
            {0.15, 0.15, -0.5, 0.5, 0.5, -0.15},
            {0.15, -0.5, -0.5, 0.5, -0.15, -0.15},
            {-0.5, -0.5, -0.5, -0.15, -0.15, -0.15},
            {-0.5, -0.5, 0.15, -0.15, -0.15, 0.5},
            {0.15, -0.5, 0.15, 0.5, -0.15, 0.5}
            ]]

            {-0.38, -0.38, -0.38, 0.38, 0.38, 0.38},
            {-0.5, -0.2, -0.2, 0.5, 0.2, 0.2},
            {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2},
            {-0.2, -0.2, -0.5, 0.2, 0.2, 0.5}
          }
        }
      }
    )
  end

  -- this is hack to work around how place_schematic() never invalidates its cache
  -- a unique schematic filename is generated for each unique theme
  SkyTrees.getMalleatedFilename = function(schematicInfo, themeName)

    -- create a unique id for the theme
    local theme = schematicInfo.theme[themeName]
    local flags = 0
    if theme.glowing                  then flags = flags +   1 end
    if theme.vineflags.leaves         then flags = flags +   2 end
    if theme.vineflags.hanging_leaves then flags = flags +   4 end
    if theme.vineflags.bark           then flags = flags +   8 end
    if theme.vineflags.hanging_bark   then flags = flags +  16 end
    if theme.vineflags.hanging_roots  then flags = flags +  32 end
    if theme.hasSoil                  then flags = flags +  64 end
    if theme.hasHeart                 then flags = flags + 128 end

    local uniqueId = themeName .. flags

    if schematicInfo.malleatedFilenames == nil then schematicInfo.malleatedFilenames = {} end

    if schematicInfo.malleatedFilenames[uniqueId] == nil then

      local malleationCount = 0
      for _ in pairs(schematicInfo.malleatedFilenames) do malleationCount = malleationCount + 1 end

      local malleatedFilename = minetest.get_modpath(SkyTrees.MODNAME) .. DIR_DELIM
      for i = 1, malleationCount do
        malleatedFilename = malleatedFilename .. '.' .. DIR_DELIM -- should work on both Linux and Windows
      end
      malleatedFilename = malleatedFilename .. schematicInfo.filename
      schematicInfo.malleatedFilenames[uniqueId] = malleatedFilename
    end

    --minetest.log("info", "Malleated file name for " .. uniqueId .. " is " .. schematicInfo.malleatedFilenames[uniqueId])
    return schematicInfo.malleatedFilenames[uniqueId]
  end


  -- Returns true if a tree in this location would be dead
  -- (checks for desert)
  SkyTrees.isDead = function(position)
    local heat     = get_heat(position)
    local humidity = get_humidity(position)

    if humidity <= 10 or (humidity <= 20 and heat >= 80) then
      return true
    end

    local biomeId = interop.get_biome_key(position)
    local biome = biomes[biomeId]
    if biome ~= nil and biome.node_top ~= nil then
      local modname, nodename = interop.split_nodename(biome.node_top)
      if string.find(nodename, "sand") or string.find(nodename, "desert") then
        return true
      end
    end
  end


  -- Returns the name of a suitable theme
  -- Picks a theme from the schematicInfo automatically, based on the themes' relativeProbability, and location.
  SkyTrees.selectTheme = function(position, schematicInfo, choiceSeed)

    local deadThemeName = "Dead"

    if schematicInfo.theme[deadThemeName] ~= nil then
      -- Tree is dead and bleached in desert biomes
      if SkyTrees.isDead(position) then
        return deadThemeName
      end
    end

    if choiceSeed == nil then choiceSeed = 0 end
    -- Use a known PRNG implementation
    local prng = PcgRandom(
      position.x           * 65732 +
      position.z           * 729   +
      schematicInfo.size.x * 3     +
      choiceSeed
    )

    local sumProbabilities = 0
    for _,theme in pairs(schematicInfo.theme) do
      sumProbabilities = sumProbabilities + theme.relativeProbability
    end

    local selection = prng:next(0, sumProbabilities * 1000) / 1000
    if DEBUG_SKYTREES then minetest.log("info", "Skytrees x: "..position.x.." y: ".. position.y .. " sumProbabilities: " .. sumProbabilities .. ", selection: " .. selection) end

    sumProbabilities = 0
    for themeName,theme in pairs(schematicInfo.theme) do
      if selection <= sumProbabilities + theme.relativeProbability then
        return themeName
      else
        sumProbabilities = sumProbabilities + theme.relativeProbability
      end
    end

    error(SkyTrees.MODNAME .. " - SkyTrees.selectTheme failed to find a theme", 0)
    return schematicInfo.defaultThemeName
  end


  -- position is a vector {x, y, z}
  -- rotation must be either 0, 90, 180, or 270
  -- schematicInfo must be one of the items in SkyTrees.schematicInfo[]
  -- topsoil [optional] is the biome's "node_top" - the ground node of the region.
  SkyTrees.placeTree = function(position, rotation, schematicInfo, themeName, topsoil)

    if SkyTrees.disabled ~= nil then
      error(SkyTrees.MODNAME .. " - SkyTrees are disabled: " .. SkyTrees.disabled, 0)
      return
    end

    -- returns a new position vector, rotated around (0, 0) to match the schematic rotation (provided the schematic_size is correct!)
    local function rotatePositon(position, schematic_size, rotation)
      local result = vector.new(position)
      if rotation == 90 then
        result.x = position.z
        result.z = schematic_size.x - position.x - 1
      elseif rotation == 180 then
        result.x = schematic_size.x - position.x - 1
        result.z = schematic_size.z - position.z - 1
      elseif rotation == 270 then
        result.x = schematic_size.z - position.z - 1
        result.z = position.x
      end
      return result
    end

    local rotatedCenter = rotatePositon(schematicInfo.center, schematicInfo.size, rotation)
    local treePos = vector.subtract(position, rotatedCenter)

    if themeName == nil then themeName = SkyTrees.selectTheme(position, schematicInfo) end
    local theme = schematicInfo.theme[themeName]
    if theme == nil then error(MODNAME .. ' called SkyTrees.placeTree("' .. schematicInfo.filename .. '") with invalid theme: ' .. themeName, 0) end
    if theme.init ~= nil then theme.init(theme, position) end

    if theme.hasSoil then
      if topsoil == nil then
        topsoil = 'ignore'
        if minetest.get_biome_data == nil then error(SkyTrees.MODNAME .. " requires Minetest v5.0 or greater, or to have minor modifications to support v0.4.x", 0) end
        local treeBiome = biomes[interop.get_biome_key(position)]
        if treeBiome ~= nil and treeBiome.node_top ~= nil then topsoil = treeBiome.node_top end
      end
    else
      topsoil = 'ignore'
    end

    local nodeName_heart = SkyTrees.MODNAME .. ":HeartWood"
    if not theme.hasHeart then nodeName_heart = 'ignore' end

    -- theme.init() may have changed the vineflags, so update the replacement node names
    if theme.vineflags.hanging_leaves  == true and SkyTrees.nodeName_hangingVine == 'ignore' then theme.vineflags.leaves = true end -- if there are no hanging vines then substitute side_vines
    if theme.vineflags.leaves          == true then theme.leaf_vines         = SkyTrees.nodeName_sideVines    else theme.leaf_vines         = 'ignore' end
    if theme.vineflags.bark            == true then theme.bark_vines         = SkyTrees.nodeName_sideVines    else theme.bark_vines         = 'ignore' end
    if theme.vineflags.hanging_leaves  == true then theme.hanging_leaf_vines = SkyTrees.nodeName_hangingVine else theme.hanging_leaf_vines = 'ignore' end
    if theme.vineflags.hanging_bark    == true then theme.hanging_bark_vines = SkyTrees.nodeName_hangingVine else theme.hanging_bark_vines = 'ignore' end
    if theme.vineflags.hanging_roots   == true and SkyTrees.nodeName_hangingRoot ~= 'ignore' then theme.hanging_bark_vines = SkyTrees.nodeName_hangingRoot end

    local replacements = {
      ['treebark\r\n\r\n~~~ Cloudlands_tree mts by Dr.Frankenstone: Amateur Arborist ~~~\r\n\r\n'] = theme.bark, -- because this node name is always replaced, it can double as space for a text header in the file.
      ['default:tree']       = theme.trunk,
      ['default:leaves']     = theme.leaves1,
      ['leaves_alt']         = theme.leaves2,
      ['leaves_special']     = theme.leaves_special,
      ['leaf_vines']         = theme.leaf_vines,
      ['bark_vines']         = theme.bark_vines,
      ['hanging_leaf_vines'] = theme.hanging_leaf_vines,
      ['hanging_bark_vines'] = theme.hanging_bark_vines,
      ['default:dirt']       = topsoil,
      ['heart']              = nodeName_heart
    }

    if minetest.global_exists("schemlib") then
      -- Use schemlib instead minetest.place_schematic(), to avoid bugs in place_schematic()

      local filename = minetest.get_modpath(SkyTrees.MODNAME) .. DIR_DELIM .. schematicInfo.filename
      local plan_obj = schemlib.plan.new()
      plan_obj:read_from_schem_file(filename, replacements)
      plan_obj.data.ground_y = -1 -- prevent read_from_schem_file() from automatically adjusting the height when it encounters dirt in the schematic (SkyTrees sometimes have dirt up in their nooks)
      plan_obj.data.facedir = round(rotation / 90)
      rotatedCenter = plan_obj:get_world_pos(vector.add(vector.multiply(schematicInfo.center, -1), -1), position) -- this function performs the rotation I require, even if it's named/intended for something else.
      plan_obj.data.anchor_pos = rotatedCenter

      if DEBUG_SKYTREES then minetest.log("info", "building tree at " .. dump(position) .. "rotated to " .. dump(treePos) .. "rotatedCenter " .. dump(rotatedCenter) .. ", " .. schematicInfo.filename) end
      plan_obj:set_status("build")

    else -- fall back on minetest.place_schematic()

      local malleatedFilename = SkyTrees.getMalleatedFilename(schematicInfo, themeName)

      if DEBUG_SKYTREES then minetest.log("info", "placing tree at " .. dump(position) .. "rotated to " .. dump(treePos) .. "rotatedCenter " .. dump(rotatedCenter) .. ", " .. schematicInfo.filename) end

      -- Defering minetest.place_schematic() until after the lua emerge seems to reduce the likelyhood of
      -- having it draw the tree with pieces missing.
      minetest.after(
        0.1,
        function(treePos, malleatedFilename, rotation, replacements, schematicInfo)

          minetest.place_schematic(treePos, malleatedFilename, rotation, replacements, true)

          -- minetest.place_schematic() doesn't invoke node constructors, so use set_node() for any nodes requiring construction
          for i, schematicCoords in pairs(schematicInfo.nodesWithConstructor) do
            if rotation ~= 0 then schematicCoords = rotatePositon(schematicCoords, schematicInfo.size, rotation) end
            local nodePos = vector.add(treePos, schematicCoords)
            local nodeToConstruct = minetest.get_node(nodePos)
            if nodeToConstruct.name == "air" or nodeToConstruct.name == nodeName_ignore then
              --this is now normal - e.g. if vines are set to 'ignore' then the nodeToConstruct won't be there.
              --minetest.log("error", "nodesWithConstructor["..i.."] does not match schematic " .. schematicInfo.filename .. " at " .. nodePos.x..","..nodePos.y..","..nodePos.z.." rotation "..rotation)
            else
              minetest.set_node(nodePos, nodeToConstruct)
            end
          end

        end,
        treePos, malleatedFilename, rotation, replacements, schematicInfo
      )

    end
  end

end

SkyTrees.init()


--[[==============================
       Initialization and Mapgen
    ==============================]]--

local function init_mapgen()
  -- invoke get_perlin() here, since it can't be invoked before the environment
  -- is created because it uses the world's seed value.
  noise_eddyField  = minetest.get_perlin(noiseparams_eddyField)
  noise_heightMap  = minetest.get_perlin(noiseparams_heightMap)
  noise_density    = minetest.get_perlin(noiseparams_density)
  noise_surfaceMap = minetest.get_perlin(noiseparams_surfaceMap)
  noise_skyReef    = minetest.get_perlin(noiseparams_skyReef)

  local prng = PcgRandom(122456 + ISLANDS_SEED)
  for i = 0,255 do randomNumbers[i] = prng:next(0, 0x10000) / 0x10000 end

  if isMapgenV6 then
    biomes["Normal"] = {node_top="mapgen_dirt_with_grass", node_filler="mapgen_dirt",        node_stone="mapgen_stone"}
    biomes["Desert"] = {node_top="mapgen_desert_sand",     node_filler="mapgen_desert_sand", node_stone="mapgen_desert_stone"}
    biomes["Jungle"] = {node_top="mapgen_dirt_with_grass", node_filler="mapgen_dirt",        node_stone="mapgen_stone"}
    biomes["Tundra"] = {node_top="mapgen_dirt_with_snow",  node_filler="mapgen_dirt",        node_stone="mapgen_stone"}
    biomes["Taiga"]  = {node_top="mapgen_dirt_with_snow",  node_filler="mapgen_dirt",        node_stone="mapgen_stone"}
  else
    for k,v in pairs(minetest.registered_biomes) do
      biomes[minetest.get_biome_id(k)] = v
    end
  end
  if DEBUG then minetest.log("info", "registered biomes: " .. dump(biomes)) end

  nodeId_air      = minetest.get_content_id("air")

  nodeId_stone    = interop.find_node_id(NODENAMES_STONE)
  nodeId_grass    = interop.find_node_id(NODENAMES_GRASS)
  nodeId_dirt     = interop.find_node_id(NODENAMES_DIRT)
  nodeId_water    = interop.find_node_id(NODENAMES_WATER)
  nodeId_ice      = interop.find_node_id(NODENAMES_ICE)
  nodeId_silt     = interop.find_node_id(NODENAMES_SILT)
  nodeId_gravel   = interop.find_node_id(NODENAMES_GRAVEL)
  nodeId_vine     = interop.find_node_id(NODENAMES_VINES)
  nodeName_vine   = minetest.get_name_from_content_id(nodeId_vine)

  local regionRectStr = minetest.settings:get(MODNAME .. "_limit_rect")
  if type(regionRectStr) == "string" then
    local minXStr, minZStr, maxXStr, maxZStr = string.match(regionRectStr, '(-?[%d%.]+)[,%s]+(-?[%d%.]+)[,%s]+(-?[%d%.]+)[,%s]+(-?[%d%.]+)')
    if minXStr ~= nil then
      local minX, minZ, maxX, maxZ = tonumber(minXStr), tonumber(minZStr), tonumber(maxXStr), tonumber(maxZStr)
      if minX ~= nil and maxX ~= nil and minX < maxX then
        region_min_x, region_max_x = minX, maxX
      end
      if minZ ~= nil and maxZ ~= nil and minZ < maxZ then
        region_min_z, region_max_z = minZ, maxZ
      end
    end
  end

  local limitToBiomesStr = minetest.settings:get(MODNAME .. "_limit_biome")
  if type(limitToBiomesStr) == "string" and string.len(limitToBiomesStr) > 0 then
    limit_to_biomes = limitToBiomesStr:lower()
  end
  limit_to_biomes_altitude = tonumber(minetest.settings:get(MODNAME .. "_limit_biome_altitude"))

  region_restrictions =
    region_min_x > -32000 or region_min_z > -32000
    or region_max_x < 32000 or region_max_z < 32000
    or limit_to_biomes ~= nil
end

-- Updates coreList to include all cores of type coreType within the given bounds
local function addCores(coreList, coreType, x1, z1, x2, z2)

  -- this function is used by the API functions, so may be invoked without our on_generated
  -- being called
  cloudlands.init()

  for z = math_floor(z1 / coreType.territorySize), math_floor(z2 / coreType.territorySize) do
    for x = math_floor(x1 / coreType.territorySize), math_floor(x2 / coreType.territorySize) do

      -- Use a known PRNG implementation, to make life easier for Amidstest
      local prng = PcgRandom(
        x * 8973896 +
        z * 7467838 +
        worldSeed + 8438 + ISLANDS_SEED
      )

      local coresInTerritory = {}

      for i = 1, coreType.coresPerTerritory do
        local coreX = x * coreType.territorySize + prng:next(0, coreType.territorySize - 1)
        local coreZ = z * coreType.territorySize + prng:next(0, coreType.territorySize - 1)

        -- there's strong vertical and horizontal tendency in 2-octave noise,
        -- so rotate it a little to avoid it lining up with the world axis.
        local noiseX = ROTATE_COS * coreX - ROTATE_SIN * coreZ
        local noiseZ = ROTATE_SIN * coreX + ROTATE_COS * coreZ
        local eddyField = noise_eddyField:get_2d({x = noiseX, y = noiseZ})

        if (math_abs(eddyField) < coreType.frequency) then

          local nexusConditionMet = not coreType.requiresNexus
          if not nexusConditionMet then
            -- A 'nexus' is a made up name for a place where the eddyField is flat.
            -- There are often many 'field lines' leading out from a nexus.
            -- Like a saddle in the perlin noise the height "coreType.frequency"
            local eddyField_orthA = noise_eddyField:get_2d({x = noiseX + 2, y = noiseZ})
            local eddyField_orthB = noise_eddyField:get_2d({x = noiseX, y = noiseZ + 2})
            if math_abs(eddyField - eddyField_orthA) + math_abs(eddyField - eddyField_orthB) < 0.02 then
              nexusConditionMet = true
            end
          end

          if nexusConditionMet then
            local radius     = (coreType.radiusMax + prng:next(0, coreType.radiusMax) * 2) / 3 -- give a 33%/66% weighting split between max-radius and random
            local depth      = (coreType.depthMax  + prng:next(0, coreType.depthMax)  * 2) / 2 -- ERROR!! fix this bug! should be dividing by 3. But should not change worldgen now, so adjust depthMax of islands so nothing changes when bug is fixed?
            local thickness  = prng:next(0, coreType.thicknessMax)


            if coreX >= x1 and coreX < x2 and coreZ >= z1 and coreZ < z2 then

              local spaceConditionMet = not coreType.exclusive
              if not spaceConditionMet then
                -- see if any other cores occupy this space, and if so then
                -- either deny the core, or raise it
                spaceConditionMet = true
                local minDistSquared = radius * radius * .7

                for _,core in ipairs(coreList) do
                  if core.type.radiusMax == coreType.radiusMax then
                    -- We've reached the cores of the current type. We can't exclude based on all
                    -- cores of the same type as we can't be sure neighboring territories will have been generated.
                    break
                  end
                  if (core.x - coreX)*(core.x - coreX) + (core.z - coreZ)*(core.z - coreZ) <= minDistSquared + core.radius * core.radius then
                    spaceConditionMet = false
                    break
                  end
                end
                if spaceConditionMet then
                  for _,core in ipairs(coresInTerritory) do
                    -- We can assume all cores of the current type are being generated in this territory,
                    -- so we can exclude the core if it overlaps one already in this territory.
                    if (core.x - coreX)*(core.x - coreX) + (core.z - coreZ)*(core.z - coreZ) <= minDistSquared + core.radius * core.radius then
                      spaceConditionMet = false
                      break
                    end
                  end
                end
              end

              if spaceConditionMet then
                -- all conditions met, we've located a new island core
                --minetest.log("Adding core "..x..","..y..","..z..","..radius)
                local y = round(noise_heightMap:get_2d({x = coreX, y = coreZ}))
                local newCore = {
                  x         = coreX,
                  y         = y,
                  z         = coreZ,
                  radius    = radius,
                  thickness = thickness,
                  depth     = depth,
                  type      = coreType,
                }
                coreList[#coreList + 1] = newCore
                coresInTerritory[#coreList + 1] = newCore
              end

            else
              -- We didn't test coreX,coreZ against x1,z1,x2,z2 immediately and save all
              -- that extra work, as that would break the determinism of the prng calls.
              -- i.e. if the area was approached from a different direction then a
              -- territory might end up with a different list of cores.
              -- TODO: filter earlier but advance prng?
            end
          end
        end
      end
    end
  end
end


-- removes any islands that fall outside region restrictions specified in the options
local function removeUnwantedIslands(coreList)

  local testBiome = limit_to_biomes ~= nil
  local get_biome_name = nil
  if testBiome then
    -- minetest.get_biome_name() was added in March 2018, we'll ignore the
    -- limit_to_biomes option on versions of Minetest that predate this
    get_biome_name = minetest.get_biome_name
    testBiome = get_biome_name ~= nil
    if get_biome_name == nil then
      minetest.log("warning", MODNAME .. " ignoring " .. MODNAME .. "_limit_biome option as Minetest API version too early to support get_biome_name()")
      limit_to_biomes = nil
    end
  end

  for i = #coreList, 1, -1 do
    local core = coreList[i]
    local coreX = core.x
    local coreZ = core.z

    if coreX < region_min_x or coreX > region_max_x or coreZ < region_min_z or coreZ > region_max_z then
      table.remove(coreList, i)

    elseif testBiome then
      local biomeAltitude
      if (limit_to_biomes_altitude == nil) then biomeAltitude = ALTITUDE + core.y else biomeAltitude = limit_to_biomes_altitude end

      local biomeName = get_biome_name(minetest.get_biome_data({x = coreX, y = biomeAltitude, z = coreZ}).biome)
      if not string.match(limit_to_biomes, biomeName:lower()) then
        table.remove(coreList, i)
      end
    end
  end
end


-- gets an array of all cores which may intersect the (minp, maxp) area
-- y is ignored
cloudlands.get_island_details = function(minp, maxp)
  local result = {}

  for _,coreType in pairs(cloudlands.coreTypes) do
    addCores(
      result,
      coreType,
      minp.x - coreType.radiusMax,
      minp.z - coreType.radiusMax,
      maxp.x + coreType.radiusMax,
      maxp.z + coreType.radiusMax
    )
  end

  -- remove islands only after cores have all generated to avoid the restriction
  -- settings from rearranging islands.
  if region_restrictions then removeUnwantedIslands(result) end

  return result
end


cloudlands.find_nearest_island = function(x, z, search_radius)

  local coreList = {}
  for _,coreType in pairs(cloudlands.coreTypes) do
    addCores(
      coreList,
      coreType,
      x - (search_radius + coreType.radiusMax),
      z - (search_radius + coreType.radiusMax),
      x + (search_radius + coreType.radiusMax),
      z + (search_radius + coreType.radiusMax)
    )
  end
  -- remove islands only after cores have all generated to avoid the restriction
  -- settings from rearranging islands.
  if region_restrictions then removeUnwantedIslands(coreList) end

  local result = nil
  for _,core in ipairs(coreList) do
    local distance = math.hypot(core.x - x, core.z - z)
    if distance >= core.radius then
      core.distance = 1 + distance - core.radius
    else
      -- distance is fractional
      core.distance = distance / (core.radius + 1)
    end

    if result == nil or core.distance < result.distance then result = core end
  end

  return result
end


-- coreList can be left as null, but if you wish to sample many heights in a small area
-- then use cloudlands.get_island_details() to get the coreList for that area and save
-- having to recalculate it during each call to get_height_at().
cloudlands.get_height_at = function(x, z, coreList)

  local result, isWater = nil, false

  if coreList == nil then
    local pos = {x = x, z = z}
    coreList = cloudlands.get_island_details(pos, pos)
  end

  for _,core in ipairs(coreList) do

    -- duplicates the code from renderCores() to find surface height
    -- See the renderCores() version for explanatory comments
    local horz_easing
    local distanceSquared = (x - core.x)*(x - core.x) + (z - core.z)*(z - core.z)
    local radiusSquared = core.radius * core.radius

    local noise_weighting = 1
    local shapeType = math_floor(core.depth + core.radius + core.x) % 5
    if shapeType < 2 then -- convex, see renderCores() implementatin for comments
      horz_easing = 1 - distanceSquared / radiusSquared
    elseif shapeType == 2 then -- conical, see renderCores() implementatin for comments
      horz_easing = 1 - math_sqrt(distanceSquared) / core.radius
    else -- concave, see renderCores() implementatin for comments
      local radiusRoot = math_sqrt(core.radius)
      local squared  = 1 - distanceSquared / radiusSquared
      local distance = math_sqrt(distanceSquared)
      local distance_normalized = distance / core.radius
      local root = 1 - math_sqrt(distance) / radiusRoot
      horz_easing = math_min(1, 0.8*distance_normalized*squared + 1.2*(1-distance_normalized)*root)
      noise_weighting = 0.63
    end
    if core.radius + core.depth > 80  then noise_weighting = 0.6  end
    if core.radius + core.depth > 120 then noise_weighting = 0.35 end

    local surfaceNoise = noise_surfaceMap:get_2d({x = x, y = z})
    if DEBUG_GEOMETRIC then surfaceNoise = SURFACEMAP_OFFSET end
    local coreTop = ALTITUDE + core.y
    local surfaceHeight = coreTop + round(surfaceNoise * 3 * (core.thickness + 1) * horz_easing)

    if result == nil or math_max(coreTop, surfaceHeight) > result then

      local coreBottom = math_floor(coreTop - (core.thickness + core.depth))
      local yBottom = coreBottom
      if result ~= nil then yBottom = math_max(yBottom, result + 1) end

      for y = math_max(coreTop, surfaceHeight), yBottom, -1 do
        local vert_easing = math_min(1, (y - coreBottom) / core.depth)

        local densityNoise = noise_density:get_3d({x = x, y = y - coreTop, z = z})
        densityNoise = noise_weighting * densityNoise + (1 - noise_weighting) * DENSITY_OFFSET
        if DEBUG_GEOMETRIC then densityNoise = DENSITY_OFFSET end

        if densityNoise * ((horz_easing + vert_easing) / 2) >= REQUIRED_DENSITY then
          result = y
          isWater = surfaceNoise < 0
          break

          --[[abandoned because do we need to calc the bottom of ponds? It also needs the outer code refactored to work
          if not isWater then
            -- we've found the land height
            break
          else
            -- find the pond bottom, since the water level is already given by (ALTITUDE + island.y)
            local surfaceDensity = densityNoise * ((horz_easing + 1) / 2)
            local onTheEdge = math_sqrt(distanceSquared) + 1 >= core.radius
            if onTheEdge or surfaceDensity > (REQUIRED_DENSITY + core.type.pondWallBuffer) then
              break
            end
          end]]
        end
      end
    end
  end

  return result, isWater
end


local function setCoreBiomeData(core)
  local pos = {x = core.x, y = ALTITUDE + core.y, z = core.z}
  if LOWLAND_BIOMES then pos.y = LOWLAND_BIOME_ALTITUDE end
  core.biomeId     = interop.get_biome_key(pos)
  core.biome       = biomes[core.biomeId]
  core.temperature = get_heat(pos)
  core.humidity    = get_humidity(pos)

  if core.temperature == nil then core.temperature = 50 end
  if core.humidity    == nil then core.humidity    = 50 end

  if core.biome == nil then
    -- Some games don't use the biome list, so come up with some fallbacks
    core.biome = {}
    core.biome.node_top    = minetest.get_name_from_content_id(nodeId_grass)
    core.biome.node_filler = minetest.get_name_from_content_id(nodeId_dirt)
  end

end

local function addDetail_vines(decoration_list, core, data, area, minp, maxp)

  if VINE_COVERAGE > 0 and nodeId_vine ~= nodeId_ignore then

    local y = ALTITUDE + core.y
    if y >= minp.y and y <= maxp.y then
      -- if core.biome is nil then renderCores() never rendered it, which means it
      -- doesn't instersect this draw region.
      if core.biome ~= nil and core.humidity >= VINES_REQUIRED_HUMIDITY and core.temperature >= VINES_REQUIRED_TEMPERATURE then

        local nodeId_top
        local nodeId_filler
        local nodeId_stoneBase
        local nodeId_dust
        if core.biome.node_top    == nil then nodeId_top       = nodeId_stone  else nodeId_top       = minetest.get_content_id(core.biome.node_top)    end
        if core.biome.node_filler == nil then nodeId_filler    = nodeId_stone  else nodeId_filler    = minetest.get_content_id(core.biome.node_filler) end
        if core.biome.node_stone  == nil then nodeId_stoneBase = nodeId_stone  else nodeId_stoneBase = minetest.get_content_id(core.biome.node_stone)  end
        if core.biome.node_dust   == nil then nodeId_dust      = nodeId_stone  else nodeId_dust      = minetest.get_content_id(core.biome.node_dust)   end

        local function isIsland(nodeId)
          return (nodeId == nodeId_filler    or nodeId == nodeId_top
               or nodeId == nodeId_stoneBase or nodeId == nodeId_dust
               or nodeId == nodeId_silt      or nodeId == nodeId_water)
        end

        local function findHighestNodeFace(y, solidIndex, emptyIndex)
          -- return the highest y value (or maxp.y) where solidIndex is part of an island
          -- and emptyIndex is not
          local yOffset = 1
          while y + yOffset <= maxp.y and isIsland(data[solidIndex + yOffset * area.ystride]) and not isIsland(data[emptyIndex + yOffset * area.ystride]) do
            yOffset = yOffset + 1
          end
          return y + yOffset - 1
        end

        local radius = round(core.radius)
        local xCropped = math_min(maxp.x, math_max(minp.x, core.x))
        local zStart = math_max(minp.z, core.z - radius)
        local vi = area:index(xCropped, y, zStart)

        for z = 0, math_min(maxp.z, core.z + radius) - zStart do
          local searchIndex = vi + z * area.zstride
          if isIsland(data[searchIndex]) then

            -- add vines to east face
            if randomNumbers[(zStart + z + y) % 256] <= VINE_COVERAGE then
              for x = xCropped + 1, maxp.x do
                if not isIsland(data[searchIndex + 1]) then
                  local yhighest = findHighestNodeFace(y, searchIndex, searchIndex + 1)
                  decoration_list[#decoration_list + 1] = {pos={x=x, y=yhighest, z= zStart + z}, node={name = nodeName_vine, param2 = 3}}
                  break
                end
                searchIndex = searchIndex + 1
              end
            end
            -- add vines to west face
            if randomNumbers[(zStart + z + y + 128) % 256] <= VINE_COVERAGE then
              searchIndex = vi + z * area.zstride
              for x = xCropped - 1, minp.x, -1 do
                if not isIsland(data[searchIndex - 1]) then
                  local yhighest = findHighestNodeFace(y, searchIndex, searchIndex - 1)
                  decoration_list[#decoration_list + 1] = {pos={x=x, y=yhighest, z= zStart + z}, node={name = nodeName_vine, param2 = 2}}
                  break
                end
                searchIndex = searchIndex - 1
              end
            end
          end
        end

        local zCropped = math_min(maxp.z, math_max(minp.z, core.z))
        local xStart = math_max(minp.x, core.x - radius)
        local zstride = area.zstride
        vi = area:index(xStart, y, zCropped)

        for x = 0, math_min(maxp.x, core.x + radius) - xStart do
          local searchIndex = vi + x
          if isIsland(data[searchIndex]) then

            -- add vines to north face (make it like moss - grows better on the north side)
            if randomNumbers[(xStart + x + y) % 256] <= (VINE_COVERAGE * 1.2) then
              for z = zCropped + 1, maxp.z do
                if not isIsland(data[searchIndex + zstride]) then
                  local yhighest = findHighestNodeFace(y, searchIndex, searchIndex + zstride)
                  decoration_list[#decoration_list + 1] = {pos={x=xStart + x, y=yhighest, z=z}, node={name = nodeName_vine, param2 = 5}}
                  break
                end
                searchIndex = searchIndex + zstride
              end
            end
            -- add vines to south face (make it like moss - grows better on the north side)
            if randomNumbers[(xStart + x + y + 128) % 256] <= (VINE_COVERAGE * 0.8) then
              searchIndex = vi + x
              for z = zCropped - 1, minp.z, -1 do
                if not isIsland(data[searchIndex - zstride]) then
                  local yhighest = findHighestNodeFace(y, searchIndex, searchIndex - zstride)
                  decoration_list[#decoration_list + 1] = {pos={x=xStart + x, y=yhighest, z=z}, node={name = nodeName_vine, param2 = 4}}
                  break
                end
                searchIndex = searchIndex - zstride
              end
            end
          end
        end

      end
    end
  end
end


-- A rare formation of rocks circling or crowning an island
-- returns true if voxels were changed
local function addDetail_skyReef(decoration_list, core, data, area, minp, maxp)

  local coreTop          = ALTITUDE + core.y
  local overdrawTop      = maxp.y + OVERDRAW
  local reefAltitude     = math_floor(coreTop - 1 - core.thickness / 2)
  local reefMaxHeight    = 12
  local reefMaxUnderhang = 4

  if (maxp.y < reefAltitude - reefMaxUnderhang) or (minp.y > reefAltitude + reefMaxHeight) then
    --no reef here
    return false
  end

  local isReef  = core.radius < core.type.radiusMax * 0.4 -- a reef can't extend beyond radiusMax, so needs a small island
  local isAtoll = core.radius > core.type.radiusMax * 0.8
  if not (isReef or isAtoll) then return false end

  local fastHash = 3
  fastHash = (37 * fastHash) + core.x
  fastHash = (37 * fastHash) + core.z
  fastHash = (37 * fastHash) + math_floor(core.radius)
  fastHash = (37 * fastHash) + math_floor(core.depth)
  if ISLANDS_SEED ~= 1000 then fastHash = (37 * fastHash) + ISLANDS_SEED end
  local rarityAdj = 1
  if core.type.requiresNexus and isAtoll then rarityAdj = 4 end -- humongous islands are very rare, and look good as an atoll
  if (REEF_RARITY * rarityAdj * 1000) < math_floor((math_abs(fastHash)) % 1000) then return false end

  local coreX = core.x --save doing a table lookup in the loop
  local coreZ = core.z --save doing a table lookup in the loop

  -- Use a known PRNG implementation
  local prng = PcgRandom(
    coreX * 8973896 +
    coreZ * 7467838 +
    worldSeed + 32564
  )

  local reefUnderhang
  local reefOuterRadius = math_floor(core.type.radiusMax)
  local reefInnerRadius = prng:next(core.type.radiusMax * 0.5, core.type.radiusMax * 0.7)
  local reefWidth       = reefOuterRadius - reefInnerRadius
  local noiseOffset     = 0

  if isReef then
    reefMaxHeight   = round((core.thickness + 4) / 2)
    reefUnderhang   = round(reefMaxHeight / 2)
    noiseOffset     = -0.1
  end
  if isAtoll then
    -- a crown attached to the island
    reefOuterRadius = math_floor(core.radius * 0.8)
    reefWidth       = math_max(4, math_floor(core.radius * 0.15))
    reefInnerRadius = reefOuterRadius - reefWidth
    reefUnderhang   = 0
    if maxp.y < reefAltitude - reefUnderhang then return end -- no atoll here
  end

  local reefHalfWidth           = reefWidth / 2
  local reefMiddleRadius        = (reefInnerRadius + reefOuterRadius) / 2
  local reefOuterRadiusSquared  = reefOuterRadius  * reefOuterRadius
  local reefInnerRadiusSquared  = reefInnerRadius  * reefInnerRadius
  local reefMiddleRadiusSquared = reefMiddleRadius * reefMiddleRadius
  local reefHalfWidthSquared    = reefHalfWidth    * reefHalfWidth

  -- get the biome details for this core
  local nodeId_first
  local nodeId_second
  local nodeId_top
  local nodeId_filler
  if core.biome == nil then setCoreBiomeData(core) end -- We can't assume the core biome has already been resolved, core might not have been big enough to enter the draw region
  if core.biome.node_top    == nil then nodeId_top    = nodeId_stone  else nodeId_top       = minetest.get_content_id(core.biome.node_top)    end
  if core.biome.node_filler == nil then nodeId_filler = nodeId_stone  else nodeId_filler    = minetest.get_content_id(core.biome.node_filler) end
  if core.biome.node_dust   ~= nil then
    nodeId_first  = minetest.get_content_id(core.biome.node_dust)
    nodeId_second = nodeId_top
  else
    nodeId_first  = nodeId_top
    nodeId_second = nodeId_filler
  end

  local zStart  = round(math_max(core.z - reefOuterRadius, minp.z))
  local zStop   = round(math_min(core.z + reefOuterRadius, maxp.z))
  local xStart  = round(math_max(core.x - reefOuterRadius, minp.x))
  local xStop   = round(math_min(core.x + reefOuterRadius, maxp.x))
  local yCenter = math_min(math_max(reefAltitude, minp.y), maxp.y)
  local pos = {}

  local dataBufferIndex = area:index(xStart, yCenter, zStart)
  local vi = -1
  for z = zStart, zStop do
    local zDistSquared = (z - coreZ) * (z - coreZ)
    pos.y = z
    for x = xStart, xStop do
      local distanceSquared = (x - coreX) * (x - coreX) + zDistSquared
      if distanceSquared < reefOuterRadiusSquared and distanceSquared > reefInnerRadiusSquared then
        pos.x = x
        local offsetEase = math_abs(distanceSquared - reefMiddleRadiusSquared) / reefHalfWidthSquared
        local fineNoise = noise_skyReef:get_2d(pos)
        local reefNoise = (noiseOffset* offsetEase) + fineNoise + 0.2 * noise_surfaceMap:get_2d(pos)

        if (reefNoise > 0) then
          local distance = math_sqrt(distanceSquared)
          local ease = 1 - math_abs(distance - reefMiddleRadius) / reefHalfWidth
          local yStart = math_max(math_floor(reefAltitude - ease * fineNoise * reefUnderhang), minp.y)
          local yStop  = math_min(math_floor(reefAltitude + ease * reefNoise * reefMaxHeight), overdrawTop)

          for y = yStart, yStop do
            vi = dataBufferIndex + (y - yCenter) * area.ystride
            if data[vi] == nodeId_air then
              if y == yStop then
                data[vi] = nodeId_first
              elseif y == yStop - 1 then
                data[vi] = nodeId_second
              else
                data[vi] = nodeId_filler
              end
            end
          end
        end
      end
      dataBufferIndex = dataBufferIndex + 1
    end
    dataBufferIndex = dataBufferIndex + area.zstride - (xStop - xStart + 1)
  end

  return vi >= 0
end

-- A rarely occuring giant tree growing from the center of the island
-- returns true if tree was added
local function addDetail_skyTree(decoration_list, core, minp, maxp)

  if (core.radius < SkyTrees.minimumIslandRadius) or (core.depth < SkyTrees.minimumIslandDepth) then
    --no tree here
    return false
  end

  local coreTop          = ALTITUDE + core.y
  local treeAltitude     = math_floor(coreTop + core.thickness)

  if (maxp.y < treeAltitude - SkyTrees.maximumYOffset) or (minp.y > treeAltitude + SkyTrees.maximumHeight) then
    --no tree here
    return false
  elseif SkyTrees.disabled ~= nil then
    -- can't find nodes/textures in this game that are needed to build trees
    return false
  end

  local coreX = core.x --save doing a table lookups
  local coreZ = core.z --save doing a table lookups

  local fastHash = 3
  fastHash = (37 * fastHash) + coreX
  fastHash = (37 * fastHash) + coreZ
  fastHash = (37 * fastHash) + math_floor(core.radius)
  fastHash = (37 * fastHash) + math_floor(core.depth)
  fastHash = (37 * fastHash) + ISLANDS_SEED
  fastHash = (37 * fastHash) + 76276 -- to keep this probability distinct from reefs and atols
  if (TREE_RARITY * 1000) < math_floor((math_abs(fastHash)) % 1000) then return false end

  -- choose a tree that will fit on the island
  local tree

  local skipLargeTree = (fastHash % 10) < 3 -- to allow small trees a chance to spawn on large islands
  if skipLargeTree then
    if SkyTrees.isDead({x = coreX, y = treeAltitude, z = coreZ}) then
      -- small tree currently doesn't have a dead theme, so don't skip the large tree
      skipLargeTree = false
    end
  end


  for i, treeType in pairs(SkyTrees.schematicInfo) do
    if i == 1 and skipLargeTree then
      -- 'continue', to allow small trees a chance to spawn on large islands
    elseif (core.radius >= treeType.requiredIslandRadius) and (core.depth >= treeType.requiredIslandDepth) then
      tree = treeType
      break
    end
  end

  local maxOffsetFromCenter = core.radius - (tree.requiredIslandRadius - 4) -- 4 is an arbitrary number, to allow trees to get closer to the edge

  -- Use a known PRNG implementation
  local prng = PcgRandom(
    coreX * 8973896 +
    coreZ * 7467838 +
    worldSeed + 43786
  )

  local treeAngle = 90 * prng:next(0, 3)
  local treePos = {
    x = coreX + math_floor((prng:next(-maxOffsetFromCenter, maxOffsetFromCenter) + prng:next(-maxOffsetFromCenter, maxOffsetFromCenter)) / 2),
    y = treeAltitude,
    z = coreZ + math_floor((prng:next(-maxOffsetFromCenter, maxOffsetFromCenter) + prng:next(-maxOffsetFromCenter, maxOffsetFromCenter)) / 2)
  }

  if minetest.global_exists("schemlib") then
    -- This check is skipped when not using schemlib, because while redrawing the tree multiple times - every time a chunk it
    -- touches gets emitted - might be slower, it helps work around the bugs in minetest.place_schematic() where large schematics
    -- are spawned incompletely.
    -- The bug in question: https://forum.minetest.net/viewtopic.php?f=6&t=22136
    -- (it isn't an issue if schemlib is used)
    if (maxp.y < treePos.y) or (minp.y > treePos.y) or (maxp.x < treePos.x) or (minp.x > treePos.x) or (maxp.z < treePos.z) or (minp.z > treePos.z) then
      -- Now that we know the exact position of the tree, we know it's spawn point is not in this chunk.
      -- In the interests of only drawing trees once, we only invoke placeTree when the chunk containing treePos is emitted.
      return false
    end
  end

  if tree.theme["Dead"] == nil then
    if SkyTrees.isDead(treePos) then
      -- Trees in this location should be dead, but this tree doesn't have a dead theme, so don't put a tree here
      return false
    end
  end

  if core.biome == nil then setCoreBiomeData(core) end -- We shouldn't assume the core biome has already been resolved, it might be below the emerged chunk and unrendered

  if core.biome.node_top == nil then
    -- solid stone isn't fertile enough for giant trees, and there's a solid stone biome in MT-Game: tundra_highland
    return false
  end

  if DEBUG_SKYTREES then minetest.log("info", "core x: "..coreX.." y: ".. coreZ .. " treePos: " .. treePos.x .. ", y: " .. treePos.y) end

  SkyTrees.placeTree(treePos, treeAngle, tree, nil, core.biome.node_top)
  return true
end


------------------------------------------------------------------------------
--  Secrets section
------------------------------------------------------------------------------

-- We might not need this stand-in cobweb, but unless we go overboard on listing many
-- optional dependencies we won't know whether there's a proper cobweb available to
-- use until after it's too late to register this one.
local nodeName_standinCobweb = MODNAME .. ":cobweb"
minetest.register_node(
  nodeName_standinCobweb,
  {
    tiles = {
      -- [Ab]Use the crack texture to avoid needing to include a cobweb texture
      -- crack_anylength.png is required by the engine, so all games will have it.
      "crack_anylength.png^[verticalframe:5:4^[brighten"
    },
    description = S("Cobweb"),
    groups = {snappy = 3, liquid = 3, flammable = 3, not_in_creative_inventory = 1},
    drawtype = "plantlike",
    walkable = false,
    liquid_viscosity = 8,
    liquidtype = "source",
    liquid_alternative_flowing = nodeName_standinCobweb,
    liquid_alternative_source  = nodeName_standinCobweb,
    liquid_renewable = false,
    liquid_range = 0,
    sunlight_propagates = true,
    paramtype = "light"
  }
)


local nodeName_egg = "secret:fossilized_egg"
local eggTextureBaseName = interop.find_node_texture({"default:jungleleaves", "mcl_core:jungleleaves", "ethereal:frost_leaves", "main:leaves"})

-- [Ab]Use a leaf texture. Originally this was to avoid needing to include an egg texture (extra files) and
-- exposing that the mod contains secrets, however both those reasons are obsolete and the mod could have textures
-- added in future
local eggTextureName = eggTextureBaseName.."^[colorize:#280040E0^[noalpha"

-- Since "secret:fossilized_egg" doesn't use this mod's name for the prefix, we can't assume
-- another mod isn't also using/providing it
if minetest.registered_nodes[nodeName_egg] == nil then

  local fossilSounds = nil
  local nodeName_stone = interop.find_node_name(NODENAMES_STONE)
  if nodeName_stone ~= nodeName_ignore then fossilSounds = minetest.registered_nodes[nodeName_stone].sounds end

  minetest.register_node(
    ":"..nodeName_egg,
    {
      tiles = { eggTextureName },
      description = S("Fossilized Egg"),
      groups = {
        oddly_breakable_by_hand = 3, -- MTG
        handy = 1,                   -- MCL
        stone = 1,                   -- Crafter needs to know the material in order to be breakable by hand
        not_in_creative_inventory = 1
      },
      _mcl_hardness = 0.4,
      sounds = fossilSounds,
      drawtype = "nodebox",
      paramtype = "light",
      node_box = {
        type = "fixed",
        fixed = {
          {-0.066666, -0.5,      -0.066666, 0.066666, 0.5,     0.066666}, -- column1
          {-0.133333, -0.476667, -0.133333, 0.133333, 0.42,    0.133333}, -- column2
          {-0.2,      -0.435,    -0.2,      0.2,      0.31,    0.2     }, -- column3
          {-0.2,      -0.36,     -0.28,     0.2,      0.16667, 0.28    }, -- side1
          {-0.28,     -0.36,     -0.2,      0.28,     0.16667, 0.2     }  -- side2
        }
      }
    }
  )
end

-- Allow the player to craft their egg into an egg in a display case
local nodeName_eggDisplay = nodeName_egg .. "_display"
local nodeName_frameGlass = interop.find_node_name(NODENAMES_FRAMEGLASS)
local woodTexture = interop.find_node_texture(NODENAMES_WOOD)
local frameTexture = nil
if woodTexture ~= nil then
  -- perhaps it's time for cloudlands to contain textures.
  frameTexture = "([combine:16x16:0,0="..woodTexture.."\\^[colorize\\:black\\:170:1,1="..woodTexture.."\\^[colorize\\:#0F0\\:255\\^[resize\\:14x14^[makealpha:0,255,0)"
  --frameTexture = "([combine:16x16:0,0="..woodTexture.."\\^[resize\\:16x16\\^[colorize\\:black\\:170:1,1="..woodTexture.."\\^[colorize\\:#0F0\\:255\\^[resize\\:14x14^[makealpha:0,255,0)"
  --frameTexture = "(("..woodTexture.."^[colorize:black:170)^([combine:16x16:1,1="..woodTexture.."\\^[resize\\:14x14\\^[colorize\\:#0F0\\:255))"
end

-- Since "secret:fossilized_egg_display" doesn't use this mod's name as the prefix, we shouldn't
-- assume another mod isn't also using/providing it.
if frameTexture ~= nil and nodeName_frameGlass ~= nodeName_ignore and minetest.registered_nodes[nodeName_eggDisplay] == nil then
  minetest.register_node(
    ":"..nodeName_eggDisplay,
    {
      tiles = { eggTextureName .. "^" .. frameTexture },
      description = S("Fossil Display"),
      groups = {
        oddly_breakable_by_hand = 3,
        glass = 1, -- Crafter needs to know the material in order to be breakable by hand
        not_in_creative_inventory = 1},
      _mcl_hardness = 0.2,
      drop = "",
      sounds = minetest.registered_nodes[nodeName_frameGlass].sounds,
      drawtype = "nodebox",
      paramtype = "light",
      node_box = {
        type = "fixed",
        fixed = {
          {-0.066666, -0.5,    -0.066666, 0.066666, 0.4375, 0.066666}, -- column1
          {-0.133333, -0.5,    -0.133333, 0.133333, 0.375,  0.133333}, -- column2
          {-0.2,      -0.4375, -0.2,      0.2,      0.285,   0.2     }, -- column3
          {-0.2,      -0.36,   -0.28,     0.2,      0.14,  0.28    }, -- side1
          {-0.28,     -0.36,   -0.2,      0.28,     0.14,  0.2     }, -- side2

          -- corner frame (courtesy of NodeBox Editor Abuse mod)
          {-0.4375, 0.4375, 0.4375, 0.4375, 0.5, 0.5},
          {-0.4375, -0.5, 0.4375, 0.4375, -0.4375, 0.5},
          {-0.5, -0.5, 0.4375, -0.4375, 0.5, 0.5},
          {0.4375, -0.5, 0.4375, 0.5, 0.5, 0.5},
          {-0.5, 0.4375, -0.4375, -0.4375, 0.5, 0.4375},
          {-0.5, -0.5, -0.4375, -0.4375, -0.4375, 0.4375},
          {0.4375, 0.4375, -0.4375, 0.5, 0.5, 0.4375},
          {0.4375, -0.5, -0.4375, 0.5, -0.4375, 0.4375},
          {-0.5, 0.4375, -0.5, 0.5, 0.5, -0.4375},
          {-0.5, -0.5, -0.5, 0.5, -0.4375, -0.4375},
          {0.4375, -0.4375, -0.5, 0.5, 0.4375, -0.4375},
          {-0.5, -0.4375, -0.5, -0.4375, 0.4375, -0.4375}
        }
      },
      after_destruct = function(pos,node)
        minetest.set_node(pos, {name = nodeName_egg, param2 = node.param2})
      end,
    }
  )

  if minetest.get_modpath("xpanes") ~= nil then
    minetest.register_craft({
        output = nodeName_eggDisplay,
        recipe = {
            {"group:stick", "group:pane", "group:stick"},
            {"group:pane",  nodeName_egg, "group:pane"},
            {"group:stick", "group:pane", "group:stick"}
        }
    })
  else
    -- Game doesn't have glass panes, so just use glass
    minetest.register_craft({
      output = nodeName_eggDisplay,
      recipe = {
          {"group:stick",       nodeName_frameGlass, "group:stick"},
          {nodeName_frameGlass, nodeName_egg,        nodeName_frameGlass},
          {"group:stick",       nodeName_frameGlass, "group:stick"}
      }
    })
  end
end

local nodeId_egg        = minetest.get_content_id(nodeName_egg)
local nodeId_airStandIn = minetest.get_content_id(interop.register_clone("air"))

-- defer assigning the following until all mods are loaded
local nodeId_bed_top
local nodeId_bed_bottom
local nodeId_torch
local nodeId_chest
local nodeId_bookshelf
local nodeId_junk
local nodeId_anvil
local nodeId_workbench
local nodeId_cobweb
local nodeName_bookshelf
local isMineCloneBookshelf

local function addDetail_secrets(decoration_list, core, data, area, minp, maxp)

  -- if core.biome is nil then renderCores() never rendered it, which means it
  -- doesn't instersect this draw region.
  if core.biome ~= nil and core.radius > 18 and core.depth > 20  and core.radius + core.depth > 60 then

    local territoryX = math_floor(core.x / core.type.territorySize)
    local territoryZ = math_floor(core.z / core.type.territorySize)
    local isPolarOutpost = (core.temperature <= 5) and (core.x % 3 == 0) and noise_surfaceMap:get_2d({x = core.x, y = core.z - 8}) >= 0 --make sure steps aren't under a pond
    local isAncientBurrow = core.humidity >= 60 and core.temperature >= 50

    -- only allow a checkerboard pattern of territories to help keep the secrets
    -- spread out, rather than bunching up too much with climate
    if ((territoryX + territoryZ) % 2 == 0) and (isPolarOutpost or isAncientBurrow) then

      local burrowRadius = 7
      local burrowHeight = 5
      local burrowDepth = 12
      local burrowFloor = ALTITUDE + core.y - burrowDepth
      local radiusSquared = burrowRadius * burrowRadius

      local function carve(originp, destp, pattern, height, floorId, floorDistance)

        local direction = vector.direction(originp, destp)
        local vineSearchDirection = {}
        if direction.x > 0 then vineSearchDirection.x = -1 else vineSearchDirection.x = 1 end
        if direction.z > 0 then vineSearchDirection.z = -1 else vineSearchDirection.z = 1 end

        local vinePlacements = {}
        local function placeVine(vi, pos, only_place_on_nodeId)
          if data[vi] == nodeId_air then
            local faces = {}
            local facing

            local function vineCanGrowOnIt(node_id)
              return node_id ~= nodeId_air and node_id ~= nodeId_airStandIn and (node_id == only_place_on_nodeId or only_place_on_nodeId == nil)
            end
            if vineCanGrowOnIt(data[vi + vineSearchDirection.x]) and pos.x + vineSearchDirection.x >= minp.x and pos.x + vineSearchDirection.x <= maxp.x then
              if vineSearchDirection.x > 0 then facing = 2 else facing = 3 end
              faces[#faces + 1] = {solid_vi = vi + vineSearchDirection.x, facing = facing}
            end
            if vineCanGrowOnIt(data[vi + vineSearchDirection.z * area.zstride]) and pos.z + vineSearchDirection.z >= minp.z and pos.z + vineSearchDirection.z <= maxp.z then
              if vineSearchDirection.z > 0 then facing = 4 else facing = 5 end
              faces[#faces + 1] = {solid_vi = vi + vineSearchDirection.z * area.zstride, facing = facing}
            end

            local faceInfo = nil
            if #faces == 1 then
              faceInfo = faces[1]
            elseif #faces == 2 then
              local ratio = math.abs(direction.x) / (math.abs(direction.x) + math.abs(direction.z))
              if randomNumbers[(pos.x + pos.y + pos.z) % 256] <= ratio then faceInfo = faces[1] else faceInfo = faces[2] end
            end
            if faceInfo ~= nil
              and (only_place_on_nodeId == nil or only_place_on_nodeId == data[faceInfo.solid_vi])
              and (data[faceInfo.solid_vi] ~= nodeId_airStandIn) then
              -- find the highest y value (or maxp.y) where solid_vi is solid
              -- and vi is not
              local solid_vi = faceInfo.solid_vi
              local yOffset = 1
              while (pos.y + yOffset <= maxp.y + 1)
                    and (data[solid_vi + yOffset * area.ystride] ~= nodeId_air)
                    and (data[vi + yOffset * area.ystride] == nodeId_air)
                    and (only_place_on_nodeId == nil or only_place_on_nodeId == data[solid_vi + yOffset * area.ystride]) do
                yOffset = yOffset + 1
              end

              -- defer final vine placement until all nodes have been carved
              vinePlacements[#vinePlacements + 1] = function(decoration_list)
                -- retest that the vine is still going in air and still attached to a solid node
                local solidNode = data[solid_vi + (yOffset - 1) * area.ystride]
                if solidNode ~= nodeId_airStandIn and solidNode ~= nodeId_air and data[vi] == nodeId_air then
                  decoration_list[#decoration_list + 1] = {pos={x=pos.x, y=pos.y + yOffset - 1, z=pos.z}, node={name = nodeName_vine, param2 = faceInfo.facing}}
                end
              end
            end
          end
        end

        local stampedIndexes = {}
        local function stamp(pos, pattern, height, node_id, isAir_callback)
          local callbackClosures = {}
          local index = -1
          for y = pos.y, pos.y + height - 1 do
            if y >= minp.y and y <= maxp.y then
              if index == -1 then index = area:index(pos.x, y, pos.z) else index = index + area.ystride end
              for _,voxel in ipairs(pattern) do
                local x = pos.x + voxel.x
                local z = pos.z + voxel.z
                if x >= minp.x and x <= maxp.x and z >= minp.z and z <= maxp.z then
                  local vi = index + voxel.x + voxel.z * area.zstride
                  if data[vi] == nodeId_air then
                    if isAir_callback ~= nil then
                      callbackClosures[#callbackClosures + 1] = function() isAir_callback(pos, vi, x, y, z) end
                    end
                  else
                    data[vi] = node_id
                    stampedIndexes[#stampedIndexes + 1] = vi
                  end
                end
              end
            end
          end
          for _,callback in ipairs(callbackClosures) do callback() end
        end

        local function excavate(pos, add_floor, add_vines, add_cobwebs)

          local function onAirNode(stampPos, node_vi, node_x, node_y, node_z)
            if node_y > stampPos.y and node_y + 1 <= maxp.y then
              -- place vines above the entrance, for concealment
              placeVine(node_vi + area.ystride, {x=node_x, y=node_y + 1, z=node_z})
            else
              -- place vines on the floor - perhaps explorers can climb to the burrow
              placeVine(node_vi, {x=node_x, y=node_y, z=node_z}, floorId)
            end
          end

          local onAirNodeCallback = onAirNode
          local fill = nodeId_airStandIn
          if not add_vines or nodeId_vine == nodeId_ignore then onAirNodeCallback = nil end
          if add_cobwebs and nodeId_cobweb ~= nodeId_ignore then fill = nodeId_cobweb end

          stamp(pos, pattern, height, fill, onAirNodeCallback)
          if add_floor and floorId ~= nil then
            stamp({x=pos.x, y=pos.y - 1, z=pos.z}, pattern, 1, floorId, onAirNodeCallback)
          end
        end

        local addVines = core.humidity >= VINES_REQUIRED_HUMIDITY and core.temperature >= VINES_REQUIRED_TEMPERATURE
        if floorDistance == nil then floorDistance = 0 end
        local distance = round(vector.distance(originp, destp))
        local step = vector.divide(vector.subtract(destp, originp), distance)

        local pos    = vector.new(originp)
        local newPos = vector.new(originp)

        excavate(originp, 0 >= floorDistance, false)
        for i = 1, distance do
          newPos.x = newPos.x + step.x
          if round(newPos.x) ~= pos.x then
            pos.x = round(newPos.x)
            excavate(pos, i >= floorDistance, addVines, i <= floorDistance - 1 and i >= floorDistance - 2)
          end
          newPos.y = newPos.y + step.y
          if round(newPos.y) ~= pos.y then
            pos.y = round(newPos.y)
            excavate(pos, i >= floorDistance, addVines, i <= floorDistance - 1 and i >= floorDistance - 2)
          end
          newPos.z = newPos.z + step.z
          if round(newPos.z) ~= pos.z then
            pos.z = round(newPos.z)
            excavate(pos, i >= floorDistance, addVines, i <= floorDistance - 1 and i >= floorDistance - 2)
          end
        end

        -- We only place vines after entire burrow entrance has been carved, to avoid placing
        -- vines on blocks which will later be removed.
        for _,vineFunction in ipairs(vinePlacements) do vineFunction(decoration_list) end

        -- Replace airStandIn with real air.
        -- This two-pass process was neccessary because the vine placing algorithm used
        -- the presense of air to determine if a rock was facing outside and should have a vine.
        -- Single-pass solutions result in vines inside the tunnel (where I'd rather overgrowth spawned)
        for _,stampedIndex in ipairs(stampedIndexes) do
          if data[stampedIndex] == nodeId_airStandIn then
            data[stampedIndex] = nodeId_air
          end
        end

      end

      local function placeNode(x, y, z, node_id)
        if (x >= minp.x and x <= maxp.x and z >= minp.z and z <= maxp.z and y >= minp.y and y <= maxp.y) then
          data[area:index(x, y, z)] = node_id
        end
      end

      local function posInBounds(pos)
        return pos.x >= minp.x and pos.x <= maxp.x and pos.z >= minp.z and pos.z <= maxp.z and pos.y >= minp.y and pos.y <= maxp.y
      end

      local zStart = math_max(core.z - burrowRadius, minp.z)
      local xStart = math_max(core.x - burrowRadius, minp.x)
      local xStop  = math_min(core.x + burrowRadius, maxp.x)
      local yStart = math_max(burrowFloor, minp.y)

      -- dig burrow
      local dataBufferIndex = area:index(xStart, yStart, zStart)
      for z = zStart, math_min(core.z + burrowRadius, maxp.z) do
        for x = xStart, xStop do
          local distanceSquared = (x - core.x)*(x - core.x) + (z - core.z)*(z - core.z)
          if distanceSquared < radiusSquared then
            local horz_easing = 1 - distanceSquared / radiusSquared
            for y = math_max(minp.y, burrowFloor + math_floor(1.4 - horz_easing)), math_min(maxp.y, burrowFloor + 1 + math_min(burrowHeight - 1, math_floor(0.8 + burrowHeight * horz_easing))) do
              data[dataBufferIndex + (y - yStart) * area.ystride] = nodeId_air
            end
          end
          dataBufferIndex = dataBufferIndex + 1
        end
        dataBufferIndex = dataBufferIndex + area.zstride - (xStop - xStart + 1)
      end

      local floorId
      if core.biome.node_top == nil then floorId = nil else floorId = minetest.get_content_id(core.biome.node_top) end

      if isAncientBurrow then
        -- island overlaps can only happen at territory edges when a coreType has exclusive=true, so
        -- angle the burrow entrance toward the center of the terrority to avoid any overlapping islands.
        local territoryCenter = vector.new(
          core.type.territorySize * math.floor(core.x / core.type.territorySize) + math.floor(0.5 + core.type.territorySize / 2),
          burrowFloor,
          core.type.territorySize * math.floor(core.z / core.type.territorySize) + math.floor(0.5 + core.type.territorySize / 2)
        )
        local burrowStart = vector.new(core.x, burrowFloor, core.z)
        local direction = vector.direction(burrowStart, territoryCenter)
        local directionOffsetZ = 4
        if direction.z < 0 then directionOffsetZ = -directionOffsetZ end
        burrowStart.z = burrowStart.z + directionOffsetZ  -- start the burrow enterance off-center
        burrowStart.x = burrowStart.x + 2 -- start the burrow enterance off-center
        direction = vector.direction(burrowStart, territoryCenter)
        if vector.length(direction) == 0 then direction = vector.direction({x=0, y=0, z=0}, {x=2, y=0, z=1}) end

        local path = vector.add(vector.multiply(direction, core.radius), {x=0, y=-4,z=0})
        local floorStartingFrom = 4 + math.floor(0.5 + core.radius * 0.3)

        -- carve burrow entrance
        local pattern = {{x=0,z=0}, {x=-1,z=0}, {x=1,z=0}, {x=0,z=-1}, {x=0,z=1}}
        carve(burrowStart, vector.add(burrowStart, path), pattern, 2, floorId, floorStartingFrom)

        -- place egg in burrow
        local eggX = core.x
        local eggZ = core.z - directionOffsetZ * 0.75 -- move the egg away from where the burrow entrance is carved
        placeNode(eggX, burrowFloor, eggZ, nodeId_egg)
        if nodeId_gravel ~= nodeId_ignore then placeNode(eggX, burrowFloor - 1, eggZ, nodeId_gravel) end
        if nodeId_cobweb ~= nodeId_ignore then
          placeNode(core.x - 6, burrowFloor + 3, core.z - 1, nodeId_cobweb)
          placeNode(core.x + 4, burrowFloor + 4, core.z + 3, nodeId_cobweb)
          placeNode(core.x + 6, burrowFloor + 1, core.z - 3, nodeId_cobweb)
        end

      else
        -- Only attempt this if it can contain beds and a place to store the diary.
        if (nodeId_bookshelf ~= nodeId_ignore or nodeId_chest ~= nodeId_ignore) and nodeId_bed_top ~= nodeId_ignore and nodeId_bed_bottom ~= nodeId_ignore then

          -- carve stairs to the surface
          local stairsStart   = vector.new(core.x - 3, burrowFloor, core.z - 7)
          local stairsbottom  = vector.add(stairsStart, {x=0,y=0,z=1})
          local stairsMiddle1 = vector.add(stairsStart, {x=8,y=8,z=0})
          local stairsMiddle2 = vector.add(stairsMiddle1, {x=0,y=0,z=-1})
          local stairsEnd     = vector.add(stairsMiddle2, {x=-20,y=20,z=0})

          carve(stairsEnd, stairsMiddle2, {{x=0,z=0}}, 3, floorId, 0)
          carve(stairsMiddle1, stairsStart, {{x=0,z=0}}, 2, floorId, 0)
          local pattern = {{x=0,z=0}, {x=1,z=0}, {x=0,z=2}, {x=0,z=1}, {x=1,z=1}}
          carve(stairsbottom, stairsbottom, pattern, 2, floorId, 0)

          -- fill the outpost
          placeNode(core.x + 2, burrowFloor, core.z + 5, nodeId_bed_top)
          placeNode(core.x + 2, burrowFloor, core.z + 4, nodeId_bed_bottom)

          placeNode(core.x + 2, burrowFloor, core.z + 2, nodeId_bed_top)
          placeNode(core.x + 2, burrowFloor, core.z + 1, nodeId_bed_bottom)

          placeNode(core.x + 4, burrowFloor, core.z + 2, nodeId_bed_top)
          placeNode(core.x + 4, burrowFloor, core.z + 1, nodeId_bed_bottom)

          if (nodeId_torch ~= nodeId_ignore) then
            decoration_list[#decoration_list + 1] = {
              pos={x=core.x, y=burrowFloor + 2, z=core.z + 6},
              node={name = minetest.get_name_from_content_id(nodeId_torch), param2 = 4}
            }
          end
          if nodeId_junk      ~= nodeId_ignore then placeNode(core.x - 4, burrowFloor + 1, core.z + 5, nodeId_junk)      end
          if nodeId_anvil     ~= nodeId_ignore then placeNode(core.x - 6, burrowFloor + 1, core.z,     nodeId_anvil)     end
          if nodeId_workbench ~= nodeId_ignore then placeNode(core.x - 5, burrowFloor,     core.z + 2, nodeId_workbench) end
          if nodeId_cobweb    ~= nodeId_ignore then placeNode(core.x + 4, burrowFloor + 4, core.z - 3, nodeId_cobweb)    end

          local bookshelf_pos
          local invBookshelf = nil
          local invChest     = nil
          if nodeId_chest ~= nodeId_ignore then
            local pos = {x = core.x - 3, y = burrowFloor + 1, z = core.z + 6}

            local nodeName_chest = minetest.get_name_from_content_id(nodeId_chest)
            local nodeNameAtPos = minetest.get_node(pos).name
            -- falls back on the nodeNameAtPos:find("chest") check to avoid a race-condition where if the
            -- chest is opened while nearby areas are being generated, the opened chest may be replaced with
            -- a new empty closed one.
            if nodeNameAtPos ~= nodeName_chest and not nodeNameAtPos:find("chest") then minetest.set_node(pos, {name = nodeName_chest}) end

            if posInBounds(pos) then
              data[area:index(pos.x, pos.y, pos.z)] = nodeId_chest
              invChest = minetest.get_inventory({type = "node", pos = pos})
            end
          end
          if nodeId_bookshelf ~= nodeId_ignore then
            local pos = {x = core.x - 2, y = burrowFloor + 1, z = core.z + 6}
            bookshelf_pos = pos

            if minetest.get_node(pos).name ~= nodeName_bookshelf then minetest.set_node(pos, {name = nodeName_bookshelf}) end

            if posInBounds(pos) then
              data[area:index(pos.x, pos.y, pos.z)] = nodeId_bookshelf
              if not isMineCloneBookshelf then -- mineclone bookshelves are decorational and don't contain anything
                invBookshelf = minetest.get_inventory({type = "node", pos = pos})
              end
            end
          end

          if invBookshelf ~= nil or invChest ~= nil then
            -- create diary
            local groundDesc = S("rock")
            if core.biome.node_filler ~= nil then
              local earthNames = string.lower(core.biome.node_filler) .. string.lower(core.biome.node_top)
              if string.match(earthNames, "ice") or string.match(earthNames, "snow") or string.match(earthNames, "frozen") then
                groundDesc = S("ice")
              end
            end

            local book_itemstack = interop.write_book(
              S("Weddell Outpost, November 21"), -- title
              S("Bert Shackleton"),              -- owner/author
              S([[The aerostat is lost.

However, salvage attempts throughout the night managed to
save most provisions before it finally broke apart and fell.

                                     ---====---

This island is highly exposed and the weather did not treat
the tents well. We have enlarged a sheltered crag in the @1,
but it is laborous work and the condition of some of the party
is becoming cause for concern.

Quite a journey is now required, we cannot stay - nobody will
look for us here. McNish is attempting to strengthen the gliders.

                                     ---====---]], groundDesc),
              S("Diary of Bert Shackleton") -- description
            )

            if book_itemstack ~= nil then
              if invBookshelf == nil then
                -- (also testing for nil invBookshelf because it can happen. Weird race condition??)
                if invChest ~= nil then invChest:add_item("main", book_itemstack) end
              else
                -- add the book to the bookshelf and manually trigger update_bookshelf() so its
                -- name will reflect the new contents.
                invBookshelf:add_item("books", book_itemstack)
                local dummyPlayer = {}
                dummyPlayer.get_player_name = function() return "server" end
                minetest.registered_nodes[nodeName_bookshelf].on_metadata_inventory_put(bookshelf_pos, "books", 1, book_itemstack, dummyPlayer)
              end
            end
          end

          if invChest ~= nil then
            -- leave some junk from the expedition in the chest
            local stack
            local function addIfFound(item_aliases, amount)
              for _,name in ipairs(item_aliases) do
                if minetest.registered_items[name] ~= nil then
                  stack = ItemStack(name .. " " .. amount)
                  invChest:add_item("main", stack)
                  break
                end
              end
            end
            addIfFound({"mcl_tools:pick_iron", "default:pick_steel", "main:ironpick"}, 1)
            addIfFound({"binoculars:binoculars"}, 1)
            addIfFound(NODENAMES_WOOD, 10)
            addIfFound({"mcl_torches:torch", "default:torch", "torch:torch"}, 3)
          end

        end
      end
    end
  end
end

local function init_secrets()
  nodeId_bed_top    = interop.find_node_id({"beds:bed_top", "bed:bed_front"})
  nodeId_bed_bottom = interop.find_node_id({"beds:bed_bottom", "bed:bed_back"})
  nodeId_torch      = interop.find_node_id({"mcl_torches:torch_wall", "default:torch_wall", "torch:wall"})
  nodeId_chest      = interop.find_node_id({"chest", "mcl_chests:chest", "default:chest", "utility:chest"})
  nodeId_junk       = interop.find_node_id({"xdecor:barrel", "cottages:barrel", "homedecor:copper_pans", "vessels:steel_bottle", "mcl_flowerpots:flower_pot"})
  nodeId_anvil      = interop.find_node_id({"castle:anvil", "cottages:anvil", "mcl_anvils:anvil", "default:anvil", "main:anvil" }) -- "default:anvil" and "main:anvil" aren't a thing, but perhaps one day.
  nodeId_workbench  = interop.find_node_id({"homedecor:table", "xdecor:workbench", "mcl_crafting_table:crafting_table", "default:table", "random_buildings:bench", "craftingtable:craftingtable"}) -- "default:table" isn't a thing, but perhaps one day.
  nodeId_cobweb     = interop.find_node_id({"mcl_core:cobweb", "xdecor:cobweb", "homedecor:cobweb_plantlike", "default:cobweb", "main:cobweb"})

  local mineCloneBookshelfName = "mcl_books:bookshelf"
  nodeId_bookshelf  = interop.find_node_id({mineCloneBookshelfName, "default:bookshelf"})
  nodeName_bookshelf = minetest.get_name_from_content_id(nodeId_bookshelf)
  isMineCloneBookshelf = nodeName_bookshelf == mineCloneBookshelfName

  if nodeId_cobweb ~= nodeId_ignore then
    -- This game has proper cobwebs, replace any cobwebs this mod may have generated
    -- previously (when a cobweb mod wasn't included) with the proper cobwebs.
    minetest.register_alias(nodeName_standinCobweb, minetest.get_name_from_content_id(nodeId_cobweb))
  elseif minetest.registered_nodes[nodeName_standinCobweb] ~= nil then
    -- use a stand-in cobweb created by this mod
    nodeId_cobweb = minetest.get_content_id(nodeName_standinCobweb)
  end
end
------------------------------------------------------------------------------
-- End of secrets section
------------------------------------------------------------------------------


local function renderCores(cores, minp, maxp, blockseed)

  local voxelsWereManipulated = false

  local vm, emerge_min, emerge_max = minetest.get_mapgen_object("voxelmanip")
  vm:get_data(data)        -- put all nodes except the ground surface in this array
  local area = VoxelArea:new{MinEdge=emerge_min, MaxEdge=emerge_max}
  local overdrawTop = maxp.y + OVERDRAW

  local currentBiomeId = -1
  local nodeId_dust
  local nodeId_top
  local nodeId_filler
  local nodeId_stoneBase
  local nodeId_pondBottom
  local depth_top
  local depth_filler
  local fillerFallsWithGravity
  local floodableDepth

  for z = minp.z, maxp.z do

    local dataBufferIndex = area:index(minp.x, minp.y, z)
    for x = minp.x, maxp.x do
      for _,core in pairs(cores) do
        local coreTop = ALTITUDE + core.y

        local distanceSquared = (x - core.x)*(x - core.x) + (z - core.z)*(z - core.z)
        local radius        = core.radius
        local radiusSquared = radius * radius

        if distanceSquared <= radiusSquared then

          -- get the biome details for this core
          if core.biome == nil then setCoreBiomeData(core) end
          if currentBiomeId ~= core.biomeId then
            if core.biome.node_top      == nil then nodeId_top        = nodeId_stone  else nodeId_top        = minetest.get_content_id(core.biome.node_top)      end
            if core.biome.node_filler   == nil then nodeId_filler     = nodeId_stone  else nodeId_filler     = minetest.get_content_id(core.biome.node_filler)   end
            if core.biome.node_stone    == nil then nodeId_stoneBase  = nodeId_stone  else nodeId_stoneBase  = minetest.get_content_id(core.biome.node_stone)    end
            if core.biome.node_dust     == nil then nodeId_dust       = nodeId_ignore else nodeId_dust       = minetest.get_content_id(core.biome.node_dust)     end
            if core.biome.node_riverbed == nil then nodeId_pondBottom = nodeId_silt   else nodeId_pondBottom = minetest.get_content_id(core.biome.node_riverbed) end

            if core.biome.depth_top    == nil then depth_top    = 1 else depth_top    = core.biome.depth_top    end
            if core.biome.depth_filler == nil then depth_filler = 3 else depth_filler = core.biome.depth_filler end
            fillerFallsWithGravity = core.biome.node_filler ~= nil and minetest.registered_items[core.biome.node_filler].groups.falling_node == 1

            --[[Commented out as unnecessary, as a supporting node will be added, but uncommenting
                this will make the strata transition less noisey.
            if fillerFallsWithGravity then
              -- the filler node is affected by gravity and can fall if unsupported, so keep that layer thinner than
              -- core.thickness when possible.
              --depth_filler = math_min(depth_filler, math_max(1, core.thickness - 1))
            end--]]

            floodableDepth = 0
            if nodeId_top ~= nodeId_stone and minetest.registered_items[core.biome.node_top].floodable then
              -- nodeId_top is a node that water floods through, so we can't have ponds appearing at this depth
              floodableDepth = depth_top
            end

            currentBiomeId = core.biomeId
          end

          -- decide on a shape
          local horz_easing
          local noise_weighting = 1
          local shapeType = math_floor(core.depth + radius + core.x) % 5
          if shapeType < 2 then
            -- convex
            -- squared easing function, e = 1 - x²
            horz_easing = 1 - distanceSquared / radiusSquared
          elseif shapeType == 2 then
            -- conical
            -- linear easing function, e = 1 - x
            horz_easing = 1 - math_sqrt(distanceSquared) / radius
          else
            -- concave
            -- root easing function blended/scaled with square easing function,
            -- x = normalised distance from center of core
            -- a = 1 - x²
            -- b = 1 - √x
            -- e = 0.8*a*x + 1.2*b*(1 - x)

            local radiusRoot = core.radiusRoot
            if radiusRoot == nil then
              radiusRoot = math_sqrt(radius)
              core.radiusRoot = radiusRoot
            end

            local squared  = 1 - distanceSquared / radiusSquared
            local distance = math_sqrt(distanceSquared)
            local distance_normalized = distance / radius
            local root = 1 - math_sqrt(distance) / radiusRoot
            horz_easing = math_min(1, 0.8*distance_normalized*squared + 1.2*(1-distance_normalized)*root)

            -- this seems to be a more delicate shape that gets wiped out by the
            -- density noise, so lower that
            noise_weighting = 0.63
          end
          if radius + core.depth > 80 then
            -- larger islands shapes have a slower easing transition, which leaves large areas
            -- dominated by the density noise, so reduce the density noise when the island is large.
            -- (the numbers here are arbitrary)
            if radius + core.depth > 120 then
              noise_weighting = 0.35
            else
              noise_weighting = math_min(0.6, noise_weighting)
            end
          end

          local surfaceNoise = noise_surfaceMap:get_2d({x = x, y = z})
          if DEBUG_GEOMETRIC then surfaceNoise = SURFACEMAP_OFFSET end
          local surface = round(surfaceNoise * 3 * (core.thickness + 1) * horz_easing) -- if you change this formular then update maxSufaceRise in on_generated()
          local coreBottom = math_floor(coreTop - (core.thickness + core.depth))
          local noisyDepthOfFiller = depth_filler
          if noisyDepthOfFiller >= 3 then noisyDepthOfFiller = noisyDepthOfFiller + math_floor(randomNumbers[(x + z) % 256] * 3) - 1 end

          local yBottom       = math_max(minp.y, coreBottom - 4) -- the -4 is for rare instances when density noise pushes the bottom of the island deeper
          local yBottomIndex  = dataBufferIndex + area.ystride * (yBottom - minp.y) -- equivalent to yBottomIndex = area:index(x, yBottom, z)
          local topBlockIndex = -1
          local bottomBlockIndex = -1
          local vi = yBottomIndex
          local densityNoise  = nil

          for y = yBottom, math_min(overdrawTop, coreTop + surface) do
            local vert_easing = math_min(1, (y - coreBottom) / core.depth)

            -- If you change the densityNoise calculation, remember to similarly update the copy of this calculation in the pond code
            densityNoise = noise_density:get_3d({x = x, y = y - coreTop, z = z}) -- TODO: Optimize this!!
            densityNoise = noise_weighting * densityNoise + (1 - noise_weighting) * DENSITY_OFFSET

            if DEBUG_GEOMETRIC then densityNoise = DENSITY_OFFSET end

            if densityNoise * ((horz_easing + vert_easing) / 2) >= REQUIRED_DENSITY then
              if vi > topBlockIndex then topBlockIndex = vi end
              if bottomBlockIndex < 0 and y > minp.y then bottomBlockIndex = vi end -- if y==minp.y then we don't know for sure this is the lowest block

              if y > coreTop + surface - depth_top and data[vi] == nodeId_air then
                data[vi] = nodeId_top
              elseif y >= coreTop + surface - (depth_top + noisyDepthOfFiller) then
                data[vi] = nodeId_filler
              else
                data[vi] = nodeId_stoneBase
              end
            end
            vi = vi + area.ystride
          end

          -- ensure nodeId_top blocks also cover the rounded sides of islands (which may be lower
          -- than the flat top), then dust the top surface.
          if topBlockIndex >= 0 then
            voxelsWereManipulated = true

            -- we either have the highest block, or overdrawTop - but we don't want to set overdrawTop nodes to nodeId_top
            -- (we will err on the side of caution when we can't distinguish the top of a island's side from overdrawTop)
            if overdrawTop >= coreTop + surface or vi > topBlockIndex + area.ystride then
              if topBlockIndex > yBottomIndex and data[topBlockIndex - area.ystride] ~= nodeId_air and data[topBlockIndex + area.ystride] == nodeId_air then
                -- We only set a block to nodeId_top if there's a block under it "holding it up" as
                -- it's better to leave 1-deep noise as stone/whatever.
                data[topBlockIndex] = nodeId_top
              end
              if nodeId_dust ~= nodeId_ignore and data[topBlockIndex + area.ystride] == nodeId_air then
                -- Delay writing dust to the data buffer until after decoration so avoid preventing tree growth etc
                if core.dustLocations == nil then core.dustLocations = {} end
                core.dustLocations[#core.dustLocations + 1] = topBlockIndex + area.ystride
              end
            end

            if fillerFallsWithGravity and bottomBlockIndex >= 0 and data[bottomBlockIndex] == nodeId_filler then
              -- the bottom node is affected by gravity and can fall if unsupported, put some support in
              data[bottomBlockIndex] = nodeId_stoneBase
            end
          end

          -- add ponds of water, trying to make sure they're not on an edge.
          -- (the only time a pond needs to be rendered when densityNoise is nil (i.e. when there was no land at this x, z),
          -- is when the pond is at minp.y - i.e. the reason no land was rendered is it was below minp.y)
          if surfaceNoise < 0 and (densityNoise ~= nil or (coreTop + surface < minp.y and coreTop >= minp.y)) and nodeId_water ~= nodeId_ignore then
            local pondWallBuffer = core.type.pondWallBuffer
            local pondBottom = nodeId_filler
            local pondWater  = nodeId_water
            if radius > 18 and core.depth > 15 and nodeId_pondBottom ~= nodeId_ignore then
              -- only give ponds a sandbed when islands are large enough for it not to stick out the side or bottom
              pondBottom = nodeId_pondBottom
            end
            if core.temperature <= ICE_REQUIRED_TEMPERATURE and nodeId_ice ~= nodeId_ignore then pondWater = nodeId_ice end

            if densityNoise == nil then
              -- Rare edge case. If the pond is at minp.y, then no land has been rendered, so
              -- densityNoise hasn't been calculated. Calculate it now.
              densityNoise = noise_density:get_3d({x = x, y = minp.y, z = z})
              densityNoise = noise_weighting * densityNoise + (1 - noise_weighting) * DENSITY_OFFSET
              if DEBUG_GEOMETRIC then densityNoise = DENSITY_OFFSET end
            end

            local surfaceDensity = densityNoise * ((horz_easing + 1) / 2)
            local onTheEdge = math_sqrt(distanceSquared) + 1 >= radius
            for y = math_max(minp.y, coreTop + surface), math_min(overdrawTop, coreTop - floodableDepth) do
              if surfaceDensity > REQUIRED_DENSITY then
                vi  = dataBufferIndex + area.ystride * (y - minp.y) -- this is the same as vi = area:index(x, y, z)

                if surfaceDensity > (REQUIRED_DENSITY + pondWallBuffer) and not onTheEdge then
                  data[vi] = pondWater
                  if y > minp.y then data[vi - area.ystride] = pondBottom end
                  --remove any dust above ponds
                  if core.dustLocations ~= nil and core.dustLocations[#core.dustLocations] == vi + area.ystride then core.dustLocations[#core.dustLocations] = nil end
                else
                  -- make sure there are some walls to keep the water in
                  if y == coreTop then
                    data[vi] = nodeId_top -- to let isIsland() know not to put vines here (only seems to be an issue when pond is 2 deep or more)
                  else
                    data[vi] = nodeId_filler
                  end
                end
              end
            end
          end

        end
      end
      dataBufferIndex = dataBufferIndex + 1
    end
  end

  local decorations = {}
  for _,core in ipairs(cores) do
    addDetail_vines(decorations, core, data, area, minp, maxp)
    voxelsWereManipulated = addDetail_skyReef(decorations, core, data, area, minp, maxp) or voxelsWereManipulated
    addDetail_secrets(decorations, core, data, area, minp, maxp)
  end

  if voxelsWereManipulated then

    vm:set_data(data)
    if GENERATE_ORES then minetest.generate_ores(vm) end
    minetest.generate_decorations(vm)

    for _,core in ipairs(cores) do
      addDetail_skyTree(decorations, core, minp, maxp)
    end
    for _,decoration in ipairs(decorations) do
      local nodeAtPos = minetest.get_node(decoration.pos)
      if nodeAtPos.name == "air" or nodeAtPos.name == nodeName_ignore then minetest.set_node(decoration.pos, decoration.node) end
    end

    local dustingInProgress = false
    for _,core in ipairs(cores) do
      if core.dustLocations ~= nil then
        if not dustingInProgress then
          vm:get_data(data)
          dustingInProgress = true
        end

        nodeId_dust = minetest.get_content_id(core.biome.node_dust)
        for _, location in ipairs(core.dustLocations) do
          if data[location] == nodeId_air and data[location - area.ystride] ~= nodeId_air then
            data[location] = nodeId_dust
          end
        end
      end
    end
    if dustingInProgress then vm:set_data(data) end


    -- Lighting is a problem. Two problems really...
    --
    -- Problem 1:
    -- We can't use the usual lua mapgen lighting trick of flags="nolight" e.g.:
    --    minetest.set_mapgen_params({mgname = "singlenode", flags = "nolight"})
    -- (https://forum.minetest.net/viewtopic.php?t=19836)
    --
    -- because the mod is designed to run with other mapgens. So we must set the light
    -- values to zero at islands before calling calc_lighting() to propegate lighting
    -- down from above.
    --
    -- This causes lighting bugs if we zero the whole emerge_min-emerge_max area because
    -- it leaves hard black at the edges of the emerged area (calc_lighting must assume
    -- a value of zero for light outside the region, and be blending that in)
    --
    -- But we can't simply zero only the minp-maxp area instead, because then calc_lighting
    -- reads the daylight values out of the overdraw area and blends those in, cutting
    -- up shadows with lines of daylight along chunk boundaries.
    --
    -- The correct solution is to zero and calculate the whole emerge_min-emerge_max area,
    -- but only write the calculated lighting information from minp-maxp back into the map,
    -- however the API doesn't appear to provide a fast way to do that.
    --
    -- Workaround: zero an area that extends into the overdraw region, but keeps a gap around
    -- the edges to preserve and allow the real light values to propegate in. Then when
    -- calc_lighting is called it will have daylight (or existing values) at the emerge boundary
    -- but not near the chunk boundary. calc_lighting is able to take the edge lighting into
    -- account instead of assuming zero. It's not a perfect solution, but allows shading without
    -- glaringly obvious lighting artifacts, and the minor ill effects should only affect the
    -- islands and be corrected any time lighting is updated.
    --
    --
    -- Problem 2:
    -- We don't want islands to blacken the landscape below them in shadow.
    --
    -- Workaround 1: Instead of zeroing the lighting before propegating from above, set it
    -- to 2, so that shadows are never pitch black. Shadows will still go back to pitch black
    -- though if lighting gets recalculated, e.g. player places a torch then removes it.
    --
    -- Workaround 2: set the bottom of the chunk to full daylight, ensuring that full
    -- daylight is what propegates down below islands. This has the problem of causing a
    -- bright horizontal band of light where islands approach a chunk floor or ceiling,
    -- but Hallelujah Mountains already had that issue due to having propagate_shadow
    -- turned off when calling calc_lighting. This workaround has the same drawback, but
    -- does a much better job of preventing undesired shadows.

    local shadowGap = 1
    local brightMin = {x = emerge_min.x + shadowGap, y = minp.y    , z = emerge_min.z + shadowGap}
    local brightMax = {x = emerge_max.x - shadowGap, y = minp.y + 1, z = emerge_max.z - shadowGap}
    local darkMin   = {x = emerge_min.x + shadowGap, y = minp.y + 1, z = emerge_min.z + shadowGap}
    local darkMax   = {x = emerge_max.x - shadowGap, y = maxp.y    , z = emerge_max.z - shadowGap}

    vm:set_lighting({day=2,  night=0}, darkMin, darkMax)
    vm:calc_lighting()
    vm:set_lighting({day=15, night=0}, brightMin, brightMax)

    vm:write_to_map() -- seems to be unnecessary when other mods that use vm are running

    for _,core in ipairs(cores) do
      -- place any schematics which should be placed after the landscape
      if addDetail_ancientPortal ~= nil then addDetail_ancientPortal(core) end
    end
  end
end


cloudlands.init = function()
  if noise_eddyField == nil then
    init_mapgen()
    init_secrets()
  end
  if noise_eddyField == nil then
    -- See comment in init_mapgen() about when this can be called
    minetest.log("warning", "cloudlands.init() unable to init - was probably invoked before the the environment was created")
  end
end

local function on_generated(minp, maxp, blockseed)

  local memUsageT0
  local osClockT0 = os.clock()
  if DEBUG then memUsageT0 = collectgarbage("count") end

  local largestCoreType  = cloudlands.coreTypes[1] -- the first island type is the biggest/thickest
  local maxCoreThickness = largestCoreType.thicknessMax
  local maxCoreDepth     = largestCoreType.radiusMax * 3 / 2 -- todo: not sure why this is radius based and not maxDepth based??
  local maxSufaceRise    = 3 * (maxCoreThickness + 1)

  if minp.y > ALTITUDE + (ALTITUDE_AMPLITUDE + maxSufaceRise + 10) or   -- the 10 is an arbitrary number because sometimes the noise values exceed their normal range.
     maxp.y < ALTITUDE - (ALTITUDE_AMPLITUDE + maxCoreThickness + maxCoreDepth + 10) then
    -- Hallelujah Mountains don't generate here
    return
  end

  local cores = cloudlands.get_island_details(minp, maxp)

  if DEBUG then
    minetest.log("info", "Cores for on_generated(): " .. #cores)
    for _,core in pairs(cores) do
      minetest.log("core ("..core.x..","..core.y..","..core.z..") r"..core.radius)
    end
  end

  if #cores > 0 then
    -- voxelmanip has mem-leaking issues, avoid creating one if we're not going to need it
    renderCores(cores, minp, maxp, blockseed)

    if DEBUG then
      minetest.log(
        "info",
        MODNAME .. " took "
        .. round((os.clock() - osClockT0) * 1000)
        .. "ms for " .. #cores .. " cores. Uncollected memory delta: "
        .. round(collectgarbage("count") - memUsageT0) .. " KB"
      )
    end
  end
end


minetest.register_on_generated(on_generated)

-- The seed as the deprecated get_mapgen_params().seed returned it: the u64 setting read as a signed int64.
local function get_world_seed()
  local hi, lo = 0, 0 -- base 2^32 halves of the seed, kept exact in doubles
  for digit in minetest.get_mapgen_setting("seed"):gmatch("%d") do
    lo = lo * 10 + tonumber(digit)
    hi = hi * 10 + math.floor(lo / 2^32)
    lo = lo % 2^32
  end
  if hi >= 2^31 then
    if lo == 0 then
      return -((2^32 - hi) * 2^32)
    end
    return -((2^32 - 1 - hi) * 2^32 + (2^32 - lo))
  end
  return hi * 2^32 + lo
end

-- Keep the old signed value so existing worlds generate the same islands.
worldSeed = get_world_seed()
