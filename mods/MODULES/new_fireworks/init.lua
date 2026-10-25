-- VARIABLES
new_fireworks = {}

local variant_list = {
	{colour = "default", figure = "", form = "", desc = ""},
	{colour = "red", figure = "default", form = "", desc = "Red"},
	{colour = "green", figure = "default", form = "", desc = "Green"},
	{colour = "blue", figure = "default", form = "", desc = "Blue"},
	{colour = "yellow", figure = "default", form = "", desc = "Yellow"},
	{colour = "white", figure = "default", form = "", desc = "White"},
	{colour = "red", figure = "ball", form = "", desc = "Red"},
	{colour = "green", figure = "ball", form = "", desc = "Green"},
	{colour = "blue", figure = "ball", form = "", desc = "Blue"},
	{colour = "yellow", figure = "ball", form = "", desc = "Yellow"},
	{colour = "white", figure = "ball", form = "", desc = "White"},
	{colour = "red", figure = "custom", form = "love", desc = "Heart"},
}

local rocket = {
	physical = true, -- Collides with things
  wield_image = "rocket__default.png",
	collisionbox = {0,-0.5,0,0,0.5,0},
	visual = "sprite",
	textures = {"rocket__default.png"},
	timer = 0,
	rocket_firetime = 0,
}

local rdt = {} -- rocket data table

-- FUNCTIONS
local function default_figure(r)
	local tab = {}
	local num = 1
	for x=-r,r,0.02 do
		for y=-r,r,0.02 do
			for z=-r,r,0.02 do
				if x*x+y*y+z*z <= r*r then
					local v = math.random(21,35) -- velocity
					if math.random(1,2) > 1 then
						local xrand = math.random(-5, 5)*0.001
						local yrand = math.random(-5, 5)*0.001
						local zrand = math.random(-5, 5)*0.001
						tab[num] = {x=x+xrand,y=y+yrand,z=z+zrand,v=v}
					end
					num = num + 1
				end
			end
		end
	end
	return tab
end

local function ball_figure(r)
	local tab = {}
	local num = 1
	for x=-r,r,0.01 do
		for y=-r,r,0.01 do
			for z=-r,r,0.01 do
				if x*x+y*y+z*z <= r*r and x*x+y*y+z*z >= (r-0.005)*(r-0.005) then
					if math.random(1,4) > 1 then
						local xrand = math.random(-3, 3)*0.001
						local yrand = math.random(-3, 3)*0.001
						local zrand = math.random(-3, 3)*0.001
						tab[num] = {x=x+xrand,y=y+yrand,z=z+zrand,v=43}
					end
					num = num + 1
				end
			end
		end
	end
	return tab
end

local function custom_figure(form)
	local tab = {}
		if form == "love" then
				tab[1] = {x=0,y=0,z=0,v=60}
				tab[2] = {x=0,y=0,z=-0.02,v=60}
				tab[3] = {x=0.01,y=0,z=-0.03,v=60}
				tab[4] = {x=0.02,y=0,z=-0.04,v=60}
				tab[5] = {x=0.03,y=0,z=-0.04,v=60}
				tab[6] = {x=0.04,y=0,z=-0.03,v=60}
				tab[7] = {x=0.05,y=0,z=-0.02,v=60}
				tab[8] = {x=0.05,y=0,z=-0.01,v=60}
				tab[9] = {x=0.04,y=0,z=0,v=60}
				tab[10] = {x=0.04,y=0,z=0.01,v=60}
				tab[11] = {x=0.03,y=0,z=0.02,v=60}
				tab[12] = {x=0.02,y=0,z=0.03,v=60}
				tab[13] = {x=0.01,y=0,z=0.04,v=60}
				tab[14] = {x=0,y=0,z=0.05,v=60}
				tab[15] = {x=-0.01,y=0,z=0.04,v=60}
				tab[16] = {x=-0.02,y=0,z=0.03,v=60}
				tab[17] = {x=-0.03,y=0,z=0.02,v=60}
				tab[18] = {x=-0.04,y=0,z=0.01,v=60}
				tab[19] = {x=-0.04,y=0,z=0,v=60}
				tab[20] = {x=-0.05,y=0,z=-0.01,v=60}
				tab[21] = {x=-0.05,y=0,z=-0.02,v=60}
				tab[22] = {x=-0.04,y=0,z=-0.03,v=60}
				tab[23] = {x=-0.03,y=0,z=-0.04,v=60}
				tab[24] = {x=-0.02,y=0,z=-0.04,v=60}
				tab[25] = {x=-0.01,y=0,z=-0.03,v=60}
--	  elseif form == "newforms" then
--			  tab[1] = {x=0,y=0,z=0,v=0} -- your variants forms
		else
			  tab[1] = {x=0,y=0,z=0,v=0}
		end
	return tab
end

--========== Activate fireworks
local function partcl_gen(pos,tab,size_min,size_max,colour)
	for _,i in pairs(tab) do
			minetest.add_particle({
						pos = {x=pos.x,y=pos.y,z=pos.z},
						velocity = {x=i.x*i.v,y=i.y*i.v,z=i.z*i.v},
						acceleration = {x=0, y=-1.5, z=0},
						expirationtime = 3.5,
						size = math.random(size_min, size_max),
						collisiondetection = true,
						vertical = false,
						animation = {type="vertical_frames", aspect_w=9, aspect_h=9, length = 3.5,},
						glow = 30,
						texture = "anim_"..colour.."_star.png",
			})
	end
end

function rocket:on_activate(staticdata)
	self.rdt = rdt
	rdt = {}
	minetest.sound_play("new_fireworks_rocket", {pos=self.object:get_pos(),
											 max_hear_distance = 13,gain = 1,})
	self.rocket_flytime = math.random(13,15)/10
	self.object:set_velocity({x=0, y=9, z=0})
	self.object:set_acceleration({x=math.random(-5,5), y=33, z=math.random(-5,5)})
end

-- Called periodically
function rocket:on_step(dtime)
	self.timer = self.timer + dtime
  self.rocket_firetime = self.rocket_firetime + dtime
  if self.rocket_firetime > 0.1 then
    local pos = self.object:get_pos()
    self.rocket_firetime = 0
    xrand = math.random(-15,15)/10
    zrand = math.random(-15,15)/10
    minetest.add_particle({
          pos = {x=pos.x,y=pos.y-0.4,z=pos.z},
          velocity = {x=xrand,y=-3,z=xrand},
          acceleration = {x=0, y=0, z=0},
          expirationtime = 1.5,
          size = 3,
          collisiondetection = true,
          vertical = false,
          animation = {type="vertical_frames", aspect_w=9, aspect_h=9, length = 1.6,},
          glow = 10,
          texture = "anim_white_star.png",
    })
  end
	if self.timer > self.rocket_flytime then
		if #self.rdt > 0 then
			minetest.sound_play("new_fireworks_bang", {pos=self.object:get_pos(),
													 max_hear_distance = 90,gain = 3,})
			for _,i in pairs(self.rdt) do
				if i.figure == "ball" then partcl_gen(self.object:get_pos(),ball_figure(0.1),4,4,i.color) end
				if i.figure == "default" then partcl_gen(self.object:get_pos(),default_figure(0.1),2,4,i.color) end
				if i.figure == "custom" then partcl_gen(self.object:get_pos(),custom_figure(i.form),7,7,i.color) end
			end
		end
		self.object:remove()
	end
end

-- NODES
for _,i in pairs(variant_list) do
	minetest.register_node("new_fireworks:rocket_"..i.figure.."_"..i.colour, {
		description = i.desc.." "..i.figure.." Rocket",
		drawtype = "airlike",
  	light_source = 5,
		inventory_image = "rocket_"..i.figure.."_"..i.colour..".png",
		wield_image = "rocket__default.png",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		is_ground_content = false,
		groups = {choppy = 3, explody = 1},

		on_construct = function(pos)
			if i.colour ~= "default" then
				rdt = i.rdt or {{color = i.colour, figure = i.figure, form = i.form},}
			end
			local obj = minetest.add_entity(pos, "new_fireworks:rocket")
			minetest.remove_node(pos)
		end,
	})
end

minetest.register_entity("new_fireworks:rocket", rocket)

-- CRAFTITEM
-- Base Rocket
minetest.register_craft({
        output = "new_fireworks:rocket__default",
        recipe = {
                {"default:paper", "default:paper", "default:paper"},
                {"default:paper", "tnt:gunpowder", "default:paper"},
                {"tnt:gunpowder", "default:stick", "tnt:gunpowder"}
        }
})
-- Ball Rocket
minetest.register_craft({
	output = "new_fireworks:rocket_default_red",
	recipe = {
		{"", "dye:red", ""},
		{"dye:red", "new_fireworks:rocket__default", "dye:red"},
		{"", "dye:red", ""}
	}
})
minetest.register_craft({
        output = "new_fireworks:rocket_default_green",   
        recipe = {
                {"", "dye:green", ""},
                {"dye:green", "new_fireworks:rocket__default", "dye:green"},
                {"", "dye:green", ""}
        }
})
minetest.register_craft({
        output = "new_fireworks:rocket_default_blue",   
        recipe = {
                {"", "dye:blue", ""},
                {"dye:blue", "new_fireworks:rocket__default", "dye:blue"},
                {"", "dye:blue", ""}
        }
})
minetest.register_craft({
        output = "new_fireworks:rocket_default_yellow",   
        recipe = {
                {"", "dye:yellow", ""},
                {"dye:yellow", "new_fireworks:rocket__default", "dye:yellow"},
                {"", "dye:yellow", ""}
        }
})
minetest.register_craft({
        output = "new_fireworks:rocket_default_white",   
        recipe = {
                {"", "dye:white", ""},
                {"dye:white", "new_fireworks:rocket__default", "dye:white"},
                {"", "dye:white", ""}
        }
})
-- Standard Ball Rockets
-- red, green, blue, yellow, white
minetest.register_craft({
        output = "new_fireworks:rocket_ball_red",
        recipe = {
                {"dye:red", "dye:red", "dye:red"},
                {"dye:red", "new_fireworks:rocket__default", "dye:red"},
                {"dye:red", "dye:red", "dye:red"}
        }
})
minetest.register_craft({
        output = "new_fireworks:rocket_ball_green",
        recipe = {
                {"dye:green", "dye:green", "dye:green"},
                {"dye:green", "new_fireworks:rocket__default", "dye:green"},
                {"dye:green", "dye:green", "dye:green"}
        }
})
minetest.register_craft({
        output = "new_fireworks:rocket_ball_blue",
        recipe = {
                {"dye:blue", "dye:blue", "dye:blue"},
                {"dye:blue", "new_fireworks:rocket__default", "dye:blue"},
                {"dye:blue", "dye:blue", "dye:blue"}
        }
})
minetest.register_craft({
        output = "new_fireworks:rocket_ball_yellow",
        recipe = {
                {"dye:yellow", "dye:yellow", "dye:yellow"},
                {"dye:yellow", "new_fireworks:rocket__default", "dye:yellow"},
                {"dye:yellow", "dye:yellow", "dye:yellow"}
        }
})
minetest.register_craft({
        output = "new_fireworks:rocket_ball_white",
        recipe = {
                {"dye:white", "dye:white", "dye:white"},
                {"dye:white", "new_fireworks:rocket__default", "dye:white"},
                {"dye:white", "dye:white", "dye:white"}
        }
})
-- Love Custom
minetest.register_craft({
        output = "new_fireworks:rocket_custom_red",
        recipe = {
                {"dye:red", "", "dye:red"},
                {"", "new_fireworks:rocket__default", ""},
                {"dye:red", "", "dye:red"}
        }
})
