nether.register_portal("lunar_portal", {
		shape               = nether.PortalShape_Platform,
		frame_node_name     = "default:steelblock",
		wormhole_node_color = 7, -- 7 is White
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
		title = "Lunar Portal",
		book_of_portals_pagetext = [[Requiring 21 blocks of Steel Blocks, and is constructed in the shape of a 3 × 3 platform with walls, or like a bowl. A finished platform is 2 blocks high, and 5 blocks wide at the widest in both directions.
This portal is different to the others, rather than acting akin to a doorway it appears to the eye more like a small pool of water which can be stepped into. Upon setting foot in the portal we found ourselves staring at Earth from the moon! We couldn't believe the sight it was amazing!]],

		is_within_realm = function(pos) -- return true if pos is on the moon
			return pos.y > mesecraft_lua.miny - 200 and pos.y < mesecraft_lua.maxy + 200
		end,

		find_realm_anchorPos = function(surface_anchorPos)
			local destination_pos = {x = surface_anchorPos.x, z = surface_anchorPos.z}
			destination_pos.y = mesecraft_lua.surface_y(destination_pos.x, destination_pos.z)

			-- a y_factor of 0 makes the search ignore the altitude of the portals (as long as they are in the Floatlands)
			local existing_portal_location, existing_portal_orientation = nether.find_nearest_working_portal("lunar_portal", destination_pos, 10, 0)
			if existing_portal_location ~= nil then
				return existing_portal_location, existing_portal_orientation
			else
				return destination_pos
			end
		end
	})
