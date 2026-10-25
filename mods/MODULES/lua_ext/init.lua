if lua_ext == nil then
    lua_ext = {}
    lua_ext.doc = {}
end

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath.."/llist.lua")

-- swap the nodes at positions pos1 and pos2, including metadata
function lua_ext.fullswap(pos1, pos2)
    local node1 = minetest.get_node(pos1)
    local node2 = minetest.get_node(pos2)
    local meta1 = minetest.get_meta(pos1)
    local meta2 = minetest.get_meta(pos2)
    local table1 = meta1:to_table()
    local table2 = meta2:to_table()
    
    minetest.set_node(pos1, node2)
    meta1 = minetest.get_meta(pos1)
    meta1:from_table(table2)
    minetest.set_node(pos2, node1)
    meta2 = minetest.get_meta(pos2)
    meta2:from_table(table1)
end
