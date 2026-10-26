afk = {}
-- Interval between movement checks (in seconds).
local INTERVAL = 5

-- Minimum distance to move to register as not AFK (in blocks).
local MINDIST = 1

-- If player does not move within this time, 'sit' player (in seconds) and label them as afk.
local TIMEOUT = 300

local time_afk = {} -- a table indexed by plname that indicates the approximate time since last moved
local last_pos = {} -- a table of position vectors that are indexed by plname
local chat_afk = {} -- a table of booleans indexed by plname that indicate if players are afk, used to indicate if we have placed a chat message that indicates them as afk
local chat_noafk = {} -- a table of booleans indexed by plname that indicate if players are not afk
afk.afk_count = 0
local beds_path = minetest.get_modpath("beds")
local attached_before_afk = {}
-- Function to check if the player is afk.

local function check_moved()
   for _, p in ipairs(minetest.get_connected_players()) do
      local plname = p:get_player_name()
      local in_bed = false
      if beds_path then
         if beds.player[plname] then
            in_bed = true
         end
      end
      local pos = p:get_pos()
      local sit = false -- for now, assume that they are not afk. Well change that if we need to later on in this function
      -- (below) if the player is not registered on the afk and no afk list, add them with them not being afk
      if chat_noafk[plname] == nil then
         attached_before_afk[plname] = default.player_attached[plname]
         chat_afk[plname] = false
         chat_noafk[plname] = true
      end
      -- if the plname index can be found  on the last_pos table then: (the plname index would not be found if they joined since the last interval afk check... we'll get them next time around bc of setting thire name o the table)
      if last_pos[plname] then
         --get the distance between their current position and their last postion, d is distance
         local d = vector.distance(last_pos[plname], pos)
         -- print("Player: "..plname..", Dist: "..d)
         if d < MINDIST then -- if d is less than minimum distance then
            time_afk[plname] = (time_afk[plname] or 0) + INTERVAL -- add the checking interval to the player's time afk (eg not moved) number
            --(below)and if the time not moved (time_afk at index plname) is more than the timeout time then sit them and post afk message to chat if we haven't already
            if time_afk[plname] >= TIMEOUT then --if we've reached timeout on the afk time table or are beyond that timeout then
               default.player_set_animation(p, "sit") -- make sure that the player is sitting
               sit = true --indicate that the player is sitting and that we have caused the sitting, for this iteration (used to keep player's animation as lay if they are dead)
               chat_noafk[plname] = false --take them off the list of players that are not afk
               if chat_afk[plname] == false then  -- so they ARE afk after the timeout, but if they are not on the list of players that we have given an afk chat message about, then give the chat message now, and then indicate that we have given an afk message about them, so that we don't do it again.
                  minetest.chat_send_all("*** "..plname.." is AFK.") -- changed the number of stars to differentiate it from user-generated messages
                  chat_afk[plname] = true
                  attached_before_afk[plname] = default.player_attached[plname] -- for first time afk, the attached state has not been messed with yet by this mod. Save its state now to know whether to unattach the player when they come back
                  afk.afk_count = afk.afk_count + 1
               end
               default.player_attached[plname] = true --I switched this in its order to be after the test for first time afk, so we could determine the original attached state
            end
         else -- oh, wait, if they have moved more than the minumum distance, then reset their afk time
            time_afk[plname] = 0
         end
      end
      if not sit then --if we have not made them sit this iteration then
         last_pos[plname] = pos --set their last postion indicator to their current position for next iteration so we can detect movement
         chat_afk[plname] = false --make sure we know that they are not afk for future reference
         -- If a player returns and the status changes, we print a message to chat.
         if chat_noafk[plname] == false then --if we didn't make them sit this iteration, its bc they are active. If their index on the not_afk list says that they ARE afk, then we haven't updated that info. SO,
            minetest.chat_send_all("*** "..plname.." came back from AFK.") --let everyone know
            afk.afk_count = afk.afk_count - 1
            chat_noafk[plname] = true --and update their status
            if not(attached_before_afk[plname]) then -- only change animation and attached state to false IF they were not attached before they went afk. Let other mods handle setting them to not attached if they caused it
               default.player_attached[plname] = false -- let the server know that they are not attached anymore - the server will stand them up.
               default.player_set_animation(p, "stand") -- and make them stand up. I moved this from where it was setting the stand animation every check, to where it sets it only when coming back from afk
            end
         end
      end
   -- If players are dead and AFK or if they are in bed, keep their model in the lay position, not sit. Spawn particles
      if (p:get_hp() == 0 or in_bed) and sit then --if they are dead or are lying in bed and would otherwise be sitting bc of afk, revoke the sit anim command, instead set it to lay
         default.player_set_animation(p, "lay")
         if p:get_hp() == 0 then
            --spawn fly and stink particles here if they are afk and dead
            minetest.add_particlespawner({
               amount = 15,
               time = INTERVAL,
               minpos = {x=pos.x -.8 , y=pos.y + .1, z=pos.z -.8},
               maxpos = {x=pos.x +.8 , y=pos.y + 1, z=pos.z +.8},
               minvel = {x=0, y=0, z=0},
               maxvel = {x=-.1, y=-.1, z=-0.1},
               minacc = {x=0, y=0, z=0},
               maxacc = {x=0, y=0, z=0},
               minexptime = INTERVAL- .5*INTERVAL,
               maxexptime = INTERVAL,
               minsize = 4,
               maxsize = 4,
               collisiondetection = true,
               vertical = false,
               texture = "flies.png",
               animation = {
                  type = "vertical_frames",
                  aspect_w = 16,
                  -- ^ specify width of a frame in pixels
                  aspect_h = 16,
                  -- ^ specify height of a frame in pixels
                  length = .2,
                  -- ^ specify full loop length
                  },
            })
         end
      end
      if (sit and not(p:get_hp() == 0)) or (in_bed and (not(p:get_hp() == 0))) then-- if they are afk and not dead  then
         -- spawn zzz particles here
          local bed_offset = 0
         if in_bed then
            bed_offset = -1
         end
         minetest.add_particlespawner({
            amount = 5,
            time = INTERVAL,
            minpos = {x=pos.x -.4 , y=pos.y + 1.2 + bed_offset, z=pos.z -.4},
            maxpos = {x=pos.x +.4 , y=pos.y + 1.5 + bed_offset, z=pos.z +.4},
            minvel = {x=0, y=.1, z=0},
            maxvel = {x=0.1, y=.3, z=0.1},
            minacc = {x=0, y=.1, z=0},
            maxacc = {x=0.01, y=.3, z=0.01},
            minexptime = INTERVAL- .5*INTERVAL,
            maxexptime = INTERVAL,
            minsize = 1,
            maxsize = 5,
            collisiondetection = true,
            vertical = false,
            texture = "afk_z_anim.png",
            animation = {

             type = "vertical_frames",
             aspect_w = 16,
             -- ^ specify width of a frame in pixels
             aspect_h = 16,
             -- ^ specify height of a frame in pixels
             length = INTERVAL,
             -- ^ specify full loop length
               },
         })
      end
   end

   minetest.after(INTERVAL, check_moved)
end

minetest.after(INTERVAL, check_moved)

minetest.register_on_leaveplayer(function(player) -- clean things up
   --If player is AFK the count should be lowered!!!!!!!!!!!!!!!!!
   local plname = player:get_player_name()
   if chat_afk[plname] then
      afk.afk_count = afk.afk_count - 1
   end
   time_afk[plname] = nil
   last_pos[plname] = nil
   chat_afk[plname] = nil
   chat_noafk[plname] = nil
   attached_before_afk[plname] = nil
end)
