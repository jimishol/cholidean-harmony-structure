--- Camera module for Cholidean harmony structure viewer.
-- Handles position, yaw/pitch orientation, movement, tween resets, and input bindings.
-- @module camera

local cons = require("constants")
local M = {}

local showDebug = false

-- Sensitivity parameters pulled from constants
local keyboard_angle = cons.sensitivity.keyboard_angle or 0.18
local mouse_angle    = cons.sensitivity.mouse_angle    or 0.005
local current_fov    = cons.fov or 45
local freeMoveSpeed  = cons.sensitivity.free_move or 5.0

-- Camera position in world space
local currentPos = {
  x = cons.initialCameraPosition.x or 0,
  y = cons.initialCameraPosition.y or 0,
  z = cons.initialCameraPosition.z or 5
}

-- Current orientation in Euler angles (radians)
local currentYaw, currentPitch = 0, 0

-- Tweening state for orientation reset
local isResettingOrientation = false
local resetTimer = 0
local resetDuration = cons.resetDuration or 0.5
local startYaw, startPitch = 0, 0
local targetYaw, targetPitch = 0, 0

--- Linearly interpolate between two scalar values
-- @param a Start value
-- @param b End value
-- @param t Blend factor between 0 and 1
-- @return Interpolated value
local function lerp(a, b, t)
  return a + (b - a) * t
end

--- Interpolate angle with wrapping over π
-- @param a Start angle (radians)
-- @param b End angle (radians)
-- @param t Blend factor
-- @return Wrapped angle
local function lerpAngle(a, b, t)
  local diff = b - a
  while diff > math.pi do diff = diff - 2 * math.pi end
  while diff < -math.pi do diff = diff + 2 * math.pi end
  return a + diff * t
end

--- Normalize angle to range [-π, π]
-- @param a Angle in radians
-- @return Normalized angle
local function normalizeAngle(a)
  while a > math.pi do a = a - 2 * math.pi end
  while a < -math.pi do a = a + 2 * math.pi end
  return a
end

--- Compute forward vector from current yaw/pitch
-- @return x, y, z components of forward direction
local function getForwardVector()
  local cosPitch = math.cos(currentPitch)
  local sinPitch = math.sin(currentPitch)
  local cosYaw   = math.cos(currentYaw)
  local sinYaw   = math.sin(currentYaw)
  return sinYaw * cosPitch, sinPitch, -cosYaw * cosPitch
end

--- Apply camera transform based on current position and angles
-- @param camera DreamEngine camera object
local function updateOrientation(camera)
  camera:resetTransform()
  camera:translate(currentPos.x, currentPos.y, currentPos.z)
  camera:rotateY(currentYaw)
  camera:rotateX(currentPitch)
end

--- Initialize camera module and bind input events
-- Computes initial orientation based on position and sets FOV
-- @param dream DreamEngine context
function M:init(dream)
  self.dream = dream
  local init = cons.initialCameraPosition
  currentPos.x, currentPos.y, currentPos.z = init.x, init.y, init.z
  updateOrientation(self.dream.camera)

  local d = math.sqrt(currentPos.x^2 + currentPos.y^2 + currentPos.z^2)
  if d > 0 then
    local vx = -currentPos.x / d
    local vy = -currentPos.y / d
    local vz = -currentPos.z / d
    currentPitch = math.asin(vy)
    currentYaw   = math.atan2(vx, -vz)
  end

  current_fov = current_fov or self.dream.camera:getFov()
  self.dream.camera:setFov(current_fov)

  love.mouse.setRelativeMode(false)
  love.mouse.setGrabbed(false)

  love.mousemoved = function(_, _, dx, dy)
    self:mousemoved(dx, dy)
  end

  love.keypressed = function(key)
    if key == "q" then
      love.event.quit()
    elseif key == "space" and not isResettingOrientation then
      local d = math.sqrt(currentPos.x^2 + currentPos.y^2 + currentPos.z^2)
      local computedPitch, computedYaw = 0, 0
      if d > 0 then
        local vx = -currentPos.x / d
        local vy = -currentPos.y / d
        local vz = -currentPos.z / d
        computedPitch = math.asin(vy)
        computedYaw   = math.atan2(vx, -vz)
      end
      startYaw = normalizeAngle(currentYaw)
      targetYaw = normalizeAngle(computedYaw)
      startPitch = currentPitch
      targetPitch = computedPitch
      isResettingOrientation = true
      resetTimer = 0
    elseif key == "d" then
      showDebug = not showDebug
    end
  end
end

--- Update camera each frame
-- Handles tweening, keyboard controls, and mouse state logic
-- @param dt Delta time (seconds)
function M:update(dt)
  if isResettingOrientation then
    resetTimer = resetTimer + dt
    local t = math.min(resetTimer / resetDuration, 1)
    currentYaw   = lerpAngle(startYaw, targetYaw, t)
    currentPitch = lerp(startPitch, targetPitch, t)
    updateOrientation(self.dream.camera)
    if t >= 1 then isResettingOrientation = false end
    return
  end

  local ctrlDown  = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
  local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

  if ctrlDown then
    local up = love.keyboard.isDown("up")
    local down = love.keyboard.isDown("down")
    if up then current_fov = current_fov - cons.sensitivity.keyboard_fov * dt end
    if down then current_fov = current_fov + cons.sensitivity.keyboard_fov * dt end
    if up or down then self.dream.camera:setFov(current_fov) end

  elseif shiftDown then
    local move = 0
    if love.keyboard.isDown("up") then move = move + 1 end
    if love.keyboard.isDown("down") then move = move - 1 end
    if move ~= 0 then
      local fx, fy, fz = getForwardVector()
      local dist = freeMoveSpeed * dt * move
      currentPos.x = currentPos.x + fx * dist
      currentPos.y = currentPos.y + fy * dist
      currentPos.z = currentPos.z + fz * dist
      updateOrientation(self.dream.camera)
    end

  else
    if love.keyboard.isDown("left") then currentYaw = currentYaw - keyboard_angle * dt end
    if love.keyboard.isDown("right") then currentYaw = currentYaw + keyboard_angle * dt end
    if love.keyboard.isDown("up") then currentPitch = currentPitch + keyboard_angle * dt end
    if love.keyboard.isDown("down") then currentPitch = currentPitch - keyboard_angle * dt end
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

--- Apply camera state (called during draw phase)
function M:apply()
    if not showDebug then return end

    local debugLabels = require("tests.test_labels")
    debugLabels(self.dream)
    -- Draw FPS
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)

    -- Draw camera position
    love.graphics.print(string.format("Camera Pos: (%.2f, %.2f, %.2f)", currentPos.x, currentPos.y, currentPos.z), 10, 30)
end

--- Handle mouse movement for view rotation or camera motion
-- @param dx Mouse delta X
-- @param dy Mouse delta Y
function M:mousemoved(dx, dy)
  if isResettingOrientation then return end
  if cons.sensitivity.invert_mouse then
    dx = -dx
    dy = -dy
  end

  if love.mouse.isDown(2) then
    currentYaw   = currentYaw + dx * mouse_angle
    currentPitch = currentPitch - dy * mouse_angle
    updateOrientation(self.dream.camera)

  elseif love.mouse.isDown(3) then
    local fx, fy, fz = getForwardVector()
    local dist = -dy * freeMoveSpeed * 0.01
    currentPos.x = currentPos.x + fx * dist
    currentPos.y = currentPos.y + fy * dist
    currentPos.z = currentPos.z + fz * dist
    updateOrientation(self.dream.camera)
  end
end

return M
