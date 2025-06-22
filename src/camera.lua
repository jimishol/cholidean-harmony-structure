
-- src/camera.lua

local cons = require("constants")  -- using your working module require
local M = {}

-- Sensitivity parameters for rotation and translation.
local keyboard_angle = cons.sensitivity.keyboard_angle or 0.18
local mouse_angle    = cons.sensitivity.mouse_angle    or 0.005
local current_fov    = cons.fov or 45
local freeMoveSpeed  = cons.sensitivity.free_move or 5.0

----------------------------------------------------------
-- Camera’s current position (updated by translation)
--
-- We preserve the user’s adjustments (pan, free-move, etc.) so that
-- pressing space only updates the orientation.
----------------------------------------------------------
local currentPos = {
  x = cons.initialCameraPosition and cons.initialCameraPosition.x or 0,
  y = cons.initialCameraPosition and cons.initialCameraPosition.y or 0,
  z = cons.initialCameraPosition and cons.initialCameraPosition.z or 5
}

----------------------------------------------------------
-- Orientation state (Euler angles in radians)
--
-- With zero rotation (yaw=0, pitch=0) the camera’s forward vector is (0, 0, -1)
-- ensuring that (0,0,0) would be visible.
----------------------------------------------------------
local currentYaw   = 0
local currentPitch = 0

----------------------------------------------------------
-- Tweening variables for the orientation reset (triggered by <space>).
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
-- Helper function: normalizes any angle to the range [-pi, pi].
----------------------------------------------------------
local function normalizeAngle(a)
  while a > math.pi do a = a - 2 * math.pi end
  while a < -math.pi do a = a + 2 * math.pi end
  return a
end

----------------------------------------------------------
-- Compute the full forward vector based on the current yaw and pitch.
----------------------------------------------------------
local function getForwardVector()
  local cosPitch = math.cos(currentPitch)
  local sinPitch = math.sin(currentPitch)
  local cosYaw   = math.cos(currentYaw)
  local sinYaw   = math.sin(currentYaw)
  local fx = sinYaw * cosPitch       -- for positive yaw, fx is positive
  local fy = sinPitch
  local fz = -cosYaw * cosPitch
  return fx, fy, fz
end

----------------------------------------------------------
-- Rebuild the camera's transform using its current position and orientation.
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

  -- Set initial camera transformation based on constants.
  self.dream.camera:resetTransform()
  local initPos = cons.initialCameraPosition or { x = 0, y = 0, z = 5 }
  currentPos.x, currentPos.y, currentPos.z = initPos.x, initPos.y, initPos.z
  self.dream.camera:translate(currentPos.x, currentPos.y, currentPos.z)
  
  -- Compute the orientation so that (0,0,0) is centered.
  local d = math.sqrt(currentPos.x^2 + currentPos.y^2 + currentPos.z^2)
  if d > 0 then
    local vx = -currentPos.x / d
    local vy = -currentPos.y / d
    local vz = -currentPos.z / d
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
      -- Compute the ideal view direction from the camera's current position to (0,0,0)
      local d = math.sqrt(currentPos.x^2 + currentPos.y^2 + currentPos.z^2)
      local computedPitch, computedYaw = 0, 0
      if d > 0 then
        local vx = -currentPos.x / d
        local vy = -currentPos.y / d
        local vz = -currentPos.z / d
        computedPitch = math.asin(vy)
        computedYaw   = math.atan2(vx, -vz)
      end
      
      -- Normalize angles so that tweening is smooth.
      startYaw = normalizeAngle(currentYaw)
      targetYaw = normalizeAngle(computedYaw)
      startPitch = currentPitch
      targetPitch = computedPitch
      
      isResettingOrientation = true
      resetTimer = 0
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
    return -- Skip further input during tweening.
  end

  local ctrlDown  = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
  local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
  
  if ctrlDown then
    -- With CTRL held, adjust the field-of-view.
    local upPressed   = love.keyboard.isDown("up")
    local downPressed = love.keyboard.isDown("down")
    if upPressed then current_fov = current_fov - cons.sensitivity.keyboard_fov * dt end
    if downPressed then current_fov = current_fov + cons.sensitivity.keyboard_fov * dt end
    if upPressed or downPressed then
      self.dream.camera:setFov(current_fov)
    end
  elseif shiftDown then
    -- With SHIFT held, move the camera forward/backward along its full local forward.
    local move = 0
    if love.keyboard.isDown("up") then move = move + 1 end
    if love.keyboard.isDown("down") then move = move - 1 end
    if move ~= 0 then
      local fx, fy, fz = getForwardVector()  -- include vertical component
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
  -- The camera's transform is continuously updated in M:update().
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
    -- Right Mouse Button: adjust view angles.
    currentYaw   = currentYaw + dx * mouse_angle
    currentPitch = currentPitch - dy * mouse_angle
    updateOrientation(self.dream.camera)
    
  elseif love.mouse.isDown(3) then
    -- Middle Mouse Button: move the camera forward/backward along its full forward vector.
    local fx, fy, fz = getForwardVector()  -- include vertical component
    local moveDist = -dy * freeMoveSpeed * 0.01  -- adjust sensitivity as needed
    currentPos.x = currentPos.x + fx * moveDist
    currentPos.y = currentPos.y + fy * moveDist
    currentPos.z = currentPos.z + fz * moveDist
    updateOrientation(self.dream.camera)
  end
end

return M
