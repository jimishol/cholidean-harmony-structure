
-- src/camera.lua

local cons = require("constants")  -- using your working module require
local M = {}

-- Sensitivity parameters for rotation and translation.
local keyboard_angle = cons.sensitivity.keyboard_angle or 0.18
local mouse_angle    = cons.sensitivity.mouse_angle    or 0.005
local current_fov    = cons.fov or 45
local freeMoveSpeed  = cons.sensitivity.free_move or 5.0

----------------------------------------------------------
-- Fixed camera position (from your constants; updated by translation)
----------------------------------------------------------
local currentPos = {
  x = cons.initialCameraPosition and cons.initialCameraPosition.x or 0,
  y = cons.initialCameraPosition and cons.initialCameraPosition.y or 0,
  z = cons.initialCameraPosition and cons.initialCameraPosition.z or 5
}

----------------------------------------------------------
-- Orientation state (Euler angles in radians)
--
-- We use the following convention so that with zero rotation (yaw=0, pitch=0)
-- the camera’s forward vector becomes (0, 0, -1) (i.e. the cube is visible).
----------------------------------------------------------
local currentYaw   = 0
local currentPitch = 0

----------------------------------------------------------
-- Tweening variables for the orientation reset (space key)
----------------------------------------------------------
local isResettingOrientation = false
local resetTimer = 0
local resetDuration = cons.resetDuration or 0.5

local startYaw, startPitch = 0, 0
local targetYaw, targetPitch = 0, 0

----------------------------------------------------------
-- Helper functions for interpolation.
----------------------------------------------------------
local function lerp(a, b, t)
  return a + (b - a) * t
end

local function lerpAngle(a, b, t)
  local diff = b - a
  while diff > math.pi do diff = diff - 2 * math.pi end
  while diff < -math.pi do diff = diff + 2 * math.pi end
  return a + diff * t
end

----------------------------------------------------------
-- Compute the full forward vector from the current yaw and pitch.
-- With our convention, for yaw=0 and pitch=0:
--    forward = ( sin(0)*cos(0), sin(0), -cos(0)*cos(0) ) = (0, 0, -1)
----------------------------------------------------------
local function getForwardVector()
  local cosPitch = math.cos(currentPitch)
  local sinPitch = math.sin(currentPitch)
  local cosYaw   = math.cos(currentYaw)
  local sinYaw   = math.sin(currentYaw)
  local fx = sinYaw * cosPitch       -- note: for positive yaw, fx will be positive
  local fy = sinPitch
  local fz = -cosYaw * cosPitch
  return fx, fy, fz
end

----------------------------------------------------------
-- Rebuild the camera's transform using the fixed position and the current orientation.
----------------------------------------------------------
local function updateOrientation(camera)
  camera:resetTransform()
  camera:translate(currentPos.x, currentPos.y, currentPos.z)
  camera:rotateY(currentYaw)
  camera:rotateX(currentPitch)
end

----------------------------------------------------------
-- Initialize the camera.
----------------------------------------------------------
function M:init(dream)
  self.dream = dream

  -- Set initial camera transformation using values from constants.
  self.dream.camera:resetTransform()
  local initPos = cons.initialCameraPosition or { x = 0, y = 0, z = 5 }
  currentPos.x, currentPos.y, currentPos.z = initPos.x, initPos.y, initPos.z
  self.dream.camera:translate(currentPos.x, currentPos.y, currentPos.z)
  
  -- Compute the vector from the camera position to the origin.
  local d = math.sqrt(currentPos.x^2 + currentPos.y^2 + currentPos.z^2)
  if d > 0 then
    local vx = -currentPos.x / d
    local vy = -currentPos.y / d
    local vz = -currentPos.z / d
    -- Our desired equations:
    --   sin(pitch) = vy  => currentPitch = asin(vy)
    -- and
    --   currentYaw = atan2(vx, -vz)
    currentPitch = math.asin(vy)
    currentYaw   = math.atan2(vx, -vz)
  else
    currentPitch = 0
    currentYaw = 0
  end
  
  updateOrientation(self.dream.camera)
  
  current_fov = self.dream.camera:getFov() or current_fov
  
  love.mouse.setRelativeMode(false)
  love.mouse.setGrabbed(false)
  
  love.mousemoved = function(_, _, dx, dy)
    self:mousemoved(dx, dy)
  end
  
  love.keypressed = function(key)
    if key == "q" then 
      love.event.quit()
    elseif key == "space" and not isResettingOrientation then
      -- Begin tweening to reset the orientation (this routine remains unchanged)
      isResettingOrientation = true
      resetTimer = 0
      startYaw = currentYaw
      startPitch = currentPitch
      
      local d = math.sqrt(currentPos.x^2 + currentPos.y^2 + currentPos.z^2)
      if d > 0 then
        local fwd = {
          x = -currentPos.x / d,
          y = -currentPos.y / d,
          z = -currentPos.z / d
        }
        targetPitch = math.asin(fwd.y)
        targetYaw   = math.atan2(fwd.x, -fwd.z)
      else
        targetPitch = 0
        targetYaw = 0
      end
    end
  end
end

----------------------------------------------------------
-- Update the camera every frame.
----------------------------------------------------------
function M:update(dt)
  if isResettingOrientation then
    resetTimer = resetTimer + dt
    local t = math.min(resetTimer / resetDuration, 1)
    currentYaw   = lerpAngle(startYaw, targetYaw, t)
    currentPitch = lerp(startPitch, targetPitch, t)
    updateOrientation(self.dream.camera)
    if t >= 1 then isResettingOrientation = false end
    return -- Skip further input during tween.
  end

  local ctrlDown  = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
  local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
  
  if ctrlDown then
    -- With CTRL held, up/down adjust the field-of-view.
    local upPressed   = love.keyboard.isDown("up")
    local downPressed = love.keyboard.isDown("down")
    if upPressed then current_fov = current_fov - cons.sensitivity.keyboard_fov * dt end
    if downPressed then current_fov = current_fov + cons.sensitivity.keyboard_fov * dt end
    if upPressed or downPressed then
      self.dream.camera:setFov(current_fov)
    end
    
  elseif shiftDown then
    -- With SHIFT held:
    -- Disable left/right arrow keys.
    -- Up/down moves the camera forward/backward along the complete local forward.
    local move = 0
    if love.keyboard.isDown("up") then move = move + 1 end
    if love.keyboard.isDown("down") then move = move - 1 end
    if move ~= 0 then
      local fx, fy, fz = getForwardVector()  -- use the full forward, including Y
      local dist = freeMoveSpeed * dt * move
      currentPos.x = currentPos.x + fx * dist
      currentPos.y = currentPos.y + fy * dist
      currentPos.z = currentPos.z + fz * dist
      updateOrientation(self.dream.camera)
    end
    
  else
    -- Normal free-look mode: arrow keys adjust view angles.
    if love.keyboard.isDown("left") then
      currentYaw = currentYaw - keyboard_angle * dt
    end
    if love.keyboard.isDown("right") then
      currentYaw = currentYaw + keyboard_angle * dt
    end
    if love.keyboard.isDown("up") then
      currentPitch = currentPitch + keyboard_angle * dt
    end
    if love.keyboard.isDown("down") then
      currentPitch = currentPitch - keyboard_angle * dt
    end
    updateOrientation(self.dream.camera)
  end
  
  local usingMouse = love.mouse.isDown(2) or love.mouse.isDown(3)
  if usingMouse and not love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(true)
    love.mouse.setGrabbed(true)
  elseif not usingMouse and love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(false)
    love.mouse.setGrabbed(false)
  end
end

----------------------------------------------------------
-- Apply camera settings (no extra code is necessary).
----------------------------------------------------------
function M:apply()
  -- The camera's transform is updated in M:update().
end

----------------------------------------------------------
-- Process mouse movement.
----------------------------------------------------------
function M:mousemoved(dx, dy)
  if isResettingOrientation then return end
  if cons.sensitivity.invert_mouse then
    dx = -dx
    dy = -dy
  end

  if love.mouse.isDown(2) then
    -- Right Mouse Button drag adjusts the view angles.
    currentYaw   = currentYaw + dx * mouse_angle
    currentPitch = currentPitch - dy * mouse_angle
    updateOrientation(self.dream.camera)
    
  elseif love.mouse.isDown(3) then
    -- Middle Mouse Button drag moves the camera forward/backward along the complete local forward.
    local fx, fy, fz = getForwardVector()  -- use full vector so vertical component is included
    local moveDist = -dy * freeMoveSpeed * 0.01  -- adjust sensitivity as needed
    currentPos.x = currentPos.x + fx * moveDist
    currentPos.y = currentPos.y + fy * moveDist
    currentPos.z = currentPos.z + fz * moveDist
    updateOrientation(self.dream.camera)
  end
end

return M
