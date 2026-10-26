-- Portal frames use portal stone, not metal blocks: the arrival portal is built from the frame
-- node, so metal frames could be dug for free metal. Portal stone can't be turned back into metal.
minetest.register_node("mesecraft_mars:portal_stone", {
	description = "Martian Portal Stone",
	tiles = {"default_bronze_block.png^[colorize:#ff7a4a:80"},
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "mesecraft_mars:portal_stone 2",
	recipe = {
		{"default:bronzeblock"},
		{"default:bronzeblock"},
	},
})

-- Portals lit before portal stone existed keep working: swap their frames, keeping the portal metadata.
minetest.register_lbm({
	label = "Convert martian portal frames to portal stone",
	name = "mesecraft_mars:portal_frames_to_portal_stone",
	nodenames = {"default:bronzeblock"},
	run_at_every_load = false,
	action = function(pos, node)
		if minetest.get_meta(pos):get_string("portal_type") == "martian_portal" then
			minetest.swap_node(pos, {name = "mesecraft_mars:portal_stone", param2 = node.param2})
		end
	end,
})

local MARS_LEVEL    = 20900

nether.register_portal("martian_portal", {
		shape               = nether.PortalShape_Circular,
		frame_node_name     = "mesecraft_mars:portal_stone",
		wormhole_node_color = 5, -- 5 is red
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
		title = "Martian Portal",
		book_of_portals_pagetext = [[Requiring 16 Martian Portal Stones (made from bronze blocks), and constructed in the shape of a circle. A finished circle is 7 blocks high, and 7 blocks wide.
This portal is big! Upon setting foot in the portal we found ourselves on a new planet! It was red, with lots of sand across the planet and in the wind. There were giant red mountains. Bring a space suit. We couldn't breathe and had to turn back!]],

		is_within_realm = function(pos) -- return true if pos is inside the Nether
			return pos.y > MARS_LEVEL - 200
		end,

		find_realm_anchorPos = function(surface_anchorPos)
			-- TODO: Once paramat finishes adjusting the floatlands, implement a surface algorithm that finds land
			local destination_pos = {x = surface_anchorPos.x ,y = MARS_LEVEL + 2, z = surface_anchorPos.z}

			-- a y_factor of 0 makes the search ignore the altitude of the portals (as long as they are in the Floatlands)
			local existing_portal_location, existing_portal_orientation = nether.find_nearest_working_portal("martian_portal", destination_pos, 10, 0)
			if existing_portal_location ~= nil then
				return existing_portal_location, existing_portal_orientation
			else
				return destination_pos
			end
		end
	})
