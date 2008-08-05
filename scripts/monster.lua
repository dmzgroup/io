
local function update_object_position (self, handle, attr, value)
   if not self.goingHome and (handle ~= self.m) and
         (dmz.object_type.new ("monster") ~= dmz.object.type (handle))
         and (dmz.object_type.new ("missile") ~= dmz.object.type (handle))
         then
      if not self.targetHandle then
         self.targetHandle = handle
         self.target = value
      elseif self.targetHandle == handle then self.target = value
      else
         local cpos = dmz.object.position (self.m)
         if cpos then
            if (cpos - value):magnitude () < (cpos - self.target):magnitude () then
               self.targetHandle = handle
               self.target = value
            end
         end
      end
   end
end

local function destroy_object (self, handle)
   if self.targetHandle == handle then
      self.targetHandle = nil
      self.target = self.startPos
      self.goingHome = true
   end
end

local Forward = dmz.vector.new {0.0, 0.0, -1.0}
local Right = dmz.vector.new {1.0, 0.0, 0.0}
local Up = dmz.vector.new {0.0, 1.0, 0.0}

local function rotate (time, orig, target)
   local diff = target - orig
   if diff > dmz.math.Pi then diff = diff - dmz.math.TwoPi
   elseif diff < -dmz.math.Pi then diff = diff + dmz.math.TwoPi
   end
   local max = time * dmz.math.Pi
   if math.abs (diff) > max then
      if diff > 0 then target = orig + max
      else target = orig - max
      end
   end
   return target
end

local function new_ori (self, time, origOri, targetVec)
   local result = dmz.matrix.new ()
   local hvec = dmz.vector.new (targetVec)
   hvec:set_y (0.0)
   hvec = hvec:normalize ()
   local heading = Forward:get_angle (hvec)
   local hcross = Forward:cross (hvec):normalize ()
   if hcross:get_y () > 0.0 then
      heading = dmz.math.TwoPi - heading
   end
   if heading > dmz.math.Pi then heading = heading - dmz.math.TwoPi
   elseif heading < -dmz.math.Pi then heading = heading + dmz.math.TwoPi
   end
   local pitch = targetVec:get_angle (hvec)
   local pcross = targetVec:cross (hvec):normalize ()
   local ncross = hvec:cross (pcross)
   if ncross:get_y () > 0.0 then
      pitch = dmz.math.TwoPi - pitch
   end
   if self.heading then heading = rotate (time, self.heading, heading) end
   self.heading = heading
   if self.pitch then pitch = rotate (time, self.pitch, pitch) end
   self.pitch = pitch
   local pm = dmz.matrix.new ():from_axis_and_angle (Right, pitch)
   result = result:from_axis_and_angle (Up, heading);
   result = pm * result
   return result;
end

local function update_time_slice (self, time)
   if self.target then
      local max = time * 33
      local cpos = dmz.object.position (self.m)
      if cpos then
         local offset = self.target - cpos
         local d = offset:magnitude ()
         local distance = d
         offset = offset:normalize ()
         if d > max then d = max end
         cpos = (offset * d) + cpos
         dmz.object.position (self.m, nil, cpos)
         if not dmz.math.is_zero (distance, 1.0) then
            dmz.object.orientation (self.m, nil, new_ori (self, time, nil, offset))
         else
            self.target = self.startPos
            if self.goingHome then self.goingHome = false
            else
               self.goingHome = true
               if self.targetHandle then
                  local tvel = dmz.object.velocity (self.targetHandle)
                  local tpos = dmz.object.position (self.targetHandle)
                  if tvel and tpos then
                     tpos:set_y (tpos:get_y () + 1.0)
                     tvel:set_y (tvel:get_y () + 20.0)
                     dmz.object.position (self.targetHandle, nil, tpos)
                     dmz.object.velocity (self.targetHandle, nil, tvel)
                  end
               end
            end
            self.targetHandle = nil
         end
         if not dmz.math.is_zero (time) then
            local vel = offset * (d /  time)
            dmz.object.velocity (self.m, nil, vel)
         end
      end
   end
end

local function start_plugin (self) 
   self.tickHandle = self.tick:create (update_time_slice, self, self.name)

   self.m = dmz.object.create ("monster")
   dmz.object.position (self.m, nil, self.startPos)
   dmz.object.orientation (self.m, nil, self.startOri)
   dmz.object.activate (self.m)
   dmz.object.set_temporary (self.m)

   local cb = {
      update_object_position = update_object_position,
      destroy_object = destroy_object,
    }
   self.obs:register (nil, cb, self)
end

function new (config, name)
   local self = {
      name = name,
      goingHome = false,
      start_plugin = start_plugin,
      obs = dmz.object_observer.new (),
      tick = dmz.time_slice.new (),
      log = dmz.log.new ("lua." .. name),
      startPos = config:lookup_vector ("start.position", {-187.36, -22.85, -530.72}),
      startOri = config:lookup_matrix ("start.orientation", {
         -0.977021, 0.000000, 0.213142,
         0.000000, 1.000000, -0.000000,
         -0.213142, 0.000000, -0.977021,
      })
   }

   self.log:info ("Creating plugin:", name)

   return self
end
