local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_alias("castle:workbench", "crafting_bench:workbench")

local usage_help = S("The inventory on the left is for raw materials, the inventory on the right holds finished products. The crafting grid in the center defines what recipe this workbench will make use of; place raw materials into it in the crafting pattern corresponding to what you want to build.")

local has_hopper = minetest.get_modpath("hopper") and hopper ~= nil and hopper.add_container ~= nil

if has_hopper then
  usage_help = usage_help .. "\n\n" .. S("This workbench is compatible with hoppers. Hoppers will insert into the raw material inventory and remove items from the finished goods inventory.")
end


local crafting_rate = minetest.settings:get("crafting_bench_crafting_rate")
if crafting_rate == nil then crafting_rate = 5 end

local allow_metadata_inventory_put = function(pos, listname, index, stack, player)
  if minetest.is_protected(pos, player:get_player_name()) then
    return 0
  end
  if listname == 'rec' then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_stack(listname, index, ItemStack(stack:get_name()))
    return 0
  end
  return stack:get_count()
end

local allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
  if minetest.is_protected(pos, player:get_player_name()) then
    return 0
  end
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local stack = inv:get_stack(from_list, from_index)
  if from_list == 'rec' and to_list == 'rec' then
    local to_stack = inv:get_stack(to_list, to_index)
    if to_stack:is_empty() then
      return 1
    else
      inv:set_stack(from_list, from_index, ItemStack(to_stack:get_name()))
      -- falls through and returns 0 after fixing 'to'
    end
  end
  if to_list == 'rec' then
    inv:set_stack(to_list, to_index, ItemStack(stack:get_name()))
    return 0
  end
  if from_list == 'rec' then
    inv:set_stack(from_list, from_index, ItemStack(""))
    return 0
  end
  return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local allow_metadata_inventory_take = function(pos, listname, index, stack, player)
  if minetest.is_protected(pos, player:get_player_name()) then
    return 0
  end
  if listname == 'rec' then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_stack(listname, index, ItemStack(""))
    return 0
  end
  return stack:get_count()
end

minetest.register_node("crafting_bench:workbench",{
    description = S("Autocrafting Workbench"),
    _doc_items_longdesc = S("A workbench that does work for you. Set a crafting recipe and provide raw materials and items will magically craft themselves once every @1 seconds.", crafting_rate),
    _doc_items_usagehelp = usage_help,
    tiles = {
      "crafting_bench_workbench_top.png",
      "crafting_bench_workbench_bottom.png",
      "crafting_bench_workbench_side.png",
      "crafting_bench_workbench_side.png",
      "crafting_bench_workbench_back.png",
      "crafting_bench_workbench_front.png"
    },
    paramtype2 = "facedir",
    paramtype = "light",
    groups = {choppy=2, oddly_breakable_by_hand=2, flammable=2},
    sounds = default.node_sound_wood_defaults(),
    drawtype = "normal",
    on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      meta:set_string( 'formspec',
        'size[10,10;]' ..
        default.gui_bg ..
        default.gui_bg_img ..
        default.gui_slots ..
        'label[1,0;'..S('Source Material')..']' ..
        'list[context;src;1,1;2,4;]' ..
        'label[4,0;'..S('Recipe to Use')..']' ..
        'list[context;rec;4,1;3,3;]' ..
        'label[7.5,0;'..S('Craft Output')..']' ..
        'list[context;dst;8,1;1,4;]' ..
        'list[current_player;main;1,6;8,4;]' ..
        'listring[context;dst]' ..
        'listring[current_player;main]' ..
        'listring[context;src]' ..
        'listring[current_player;main]' ..
        'listring[context;rec]' ..
        'listring[current_player;main]' )
      meta:set_string('infotext', S('Workbench'))
      local inv = meta:get_inventory()
      inv:set_size('src', 2 * 4)
      inv:set_size('rec', 3 * 3)
      inv:set_size('dst', 1 * 4)
    end,
    can_dig = function(pos,player)
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory()
      return inv:is_empty('src') and inv:is_empty('dst')
    end,
    on_blast = function(pos)
      local drops = {}
      default.get_inventory_drops(pos, 'src', drops)
      default.get_inventory_drops(pos, 'dst', drops)
      table.insert(drops, 'crafting_bench:workbench')
      minetest.remove_node(pos)
      return drops
    end,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
  })
local get_recipe = function(inv)
  local needed = inv:get_list('rec')
  local totalneed = {}

  local result, leftover = minetest.get_craft_result({
      method = 'normal',
      width = 3,
      items = needed
    })

  if result.item:is_empty() then
    result = nil
  else
    leftover = leftover or {}
    for _, item in ipairs(result.replacements) do
      table.insert(leftover, item)
    end
    result = result.item
    for _, item in ipairs( needed ) do
      if item ~= nil and not item:is_empty() and not inv:contains_item( 'src', item ) then
        result = nil
        break
      end
      if item ~= nil and not item:is_empty() then
        local itemname = item:get_name()
        totalneed[itemname] = (totalneed[itemname] or 0) + 1
      end
    end
    for name, number in pairs( totalneed ) do
      local totallist = inv:get_list( 'src' )
      for i, srcitem in pairs( totallist ) do
        if srcitem:get_name() == name then
          local taken = srcitem:take_item( number )
          number = number - taken:get_count()
          totallist[i] = srcitem
        end
        if number <= 0 then
          break
        end
      end
      if number > 0 then
        result = nil
        break
      end
    end
  end

  return needed, leftover, result
end

minetest.register_abm( {
    nodenames = { 'crafting_bench:workbench' },
    interval = crafting_rate,
    chance = 1,
    action = function (pos, node)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      if not inv:is_empty('src') and not inv:is_empty('rec') then
        -- Check for a valid recipe and sufficient resources to craft it
        local needed, replacements, result = get_recipe(inv)
        replacements = replacements and replacements.items or replacements
        if result ~= nil and inv:room_for_item('dst', result) then
          inv:add_item('dst', result)
          for i, item in pairs(needed) do
            local replacement = replacements[i]
            if item and not item:is_empty() then
              inv:remove_item('src', ItemStack(item))
              -- add identical replacements to src
              if replacement and not replacement:is_empty() and replacement:get_name() == item:get_name() then
                inv:add_item('src', replacement)
                replacements[i] = nil
              end
            end
          end
          -- other replacements add to dst
          for _, item in pairs(replacements) do
            inv:add_item('dst', item)
          end
        end
      end
    end,
    } )

minetest.register_craft({
    output = "crafting_bench:workbench",
    recipe = {
      {"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
      {"group:wood", "group:wood","default:steel_ingot"},
      {"default:mese_crystal", "default:mese_crystal","default:steel_ingot"},
    }
  })

-- Hopper compatibility
if has_hopper then
  hopper:add_container({
      {"top", "crafting_bench:workbench", "dst"},
      {"side", "crafting_bench:workbench", "src"},
      {"bottom", "crafting_bench:workbench", "src"},
    })
end
