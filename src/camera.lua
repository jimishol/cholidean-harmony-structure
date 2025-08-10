--- Camera module for the Cholidean harmony structure viewer.
-- Manages camera position, yaw/pitch orientation, movement, tweened resets, and input bindings.
-- @module src.backends.camera

local cons = require("constants")
local A    = require("src.input.actions")

--- Module table
-- @table M
local M = {}

---
-- Sensitivity parameters (private)
-- @section Sensitivity

--- Keyboard rotation sensitivity (radians per second).
-- @local
-- @type number
local keyboard_angle = cons.sensitivity.keyboard_angle or 0.18

--- Mouse rotation sensitivity (radians per pixel).
-- @local
-- @type number
local mouse_angle = cons.sensitivity.mouse_angle or 0.005

--- Current field of view (degrees, clamped ≥1).
-- @local
-- @type number
local current_fov = math.max(cons.fov or 45, 1)

--- Free‐move speed multiplier (units per second).
-- @local
-- @type number
local freeMoveSpeed = cons.sensitivity.free_move or 5.0

---
-- Camera transform state (private)
-- @section TransformState

--- Current camera position.
-- @local
-- @field x number
-- @field y number
-- @field z number
local currentPos = {
  x = cons.initialCameraPosition.x or 0,
  y = cons.initialCameraPosition.y or 0,
  z = cons.initialCameraPosition.z or 5,
}

--- Current yaw (horizontal rotation in radians).
-- @local
-- @type number
local currentYaw = 0

--- Current pitch (vertical rotation in radians).
-- @local
-- @type number
local currentPitch = 0

---
-- Tween/reset orientation state (private)
-- @section TweenState

--- Flag indicating an in‐progress orientation reset.
-- @local
-- @type boolean
local isResettingOrientation = false

--- Timer accumulator for reset lerp.
-- @local
-- @type number
local resetTimer = 0

--- Duration of orientation reset (seconds).
-- @local
-- @type number
local resetDuration = cons.resetDuration or 0.5

--- Starting yaw for tween.
-- @local
-- @type number
local startYaw = 0

--- Starting pitch for tween.
-- @local
-- @type number
local startPitch = 0

--- Target yaw for tween.
-- @local
-- @type number
local targetYaw = 0

--- Target pitch for tween.
-- @local
-- @type number
local targetPitch = 0

---
-- Public view snapshot (updated each frame)
-- @field yaw number Current yaw in radians.
-- @field pitch number Current pitch in radians.
-- @field Pos table Current position {x,y,z}.
-- @field fov number Current FOV in degrees.
M.View = {
  yaw   = currentYaw,
  pitch = currentPitch,
  Pos   = currentPos,
  fov   = current_fov,
}

---
-- Linear interpolation between a and b.
-- @local
-- @param a number Start value.
-- @param b number End value.
-- @param t number Interpolation factor (0–1).
-- @treturn number Interpolated value.
local function lerp(a, b, t)
  return a + (b - a) * t
end

---
-- Spherical‐shortest‐path interpolation of angles.
-- @local
-- @param a number Start angle (radians).
-- @param b number End angle (radians).
-- @param t number Interpolation factor (0–1).
-- @treturn number Interpolated angle.
local function lerpAngle(a, b, t)
  local diff = b - a
  while diff > math.pi  do diff = diff - 2 * math.pi end
  while diff < -math.pi do diff = diff + 2 * math.pi end
  return a + diff * t
end

---
-- Normalize any angle to the range [-π, π].
-- @local
-- @param a number Angle in radians.
-- @treturn number Normalized angle.
local function normalizeAngle(a)
  while a > math.pi  do a = a - 2 * math.pi end
  while a < -math.pi do a = a + 2 * math.pi end
  return a
end

---
-- Compute forward unit vector from current yaw & pitch.
-- @local
-- @treturn number x component.
-- @treturn number y component.
-- @treturn number z component.
local function getForwardVector()
  local cosPitch = math.cos(currentPitch)
  local sinPitch = math.sin(currentPitch)
  local cosYaw   = math.cos(currentYaw)
  local sinYaw   = math.sin(currentYaw)
  return sinYaw * cosPitch,
         sinPitch,
        -cosYaw * cosPitch
end

---
-- Apply current transform to the given camera.
-- @local
-- @param camera Love2D Camera object.
local function updateOrientation(camera)
  camera:resetTransform()
  camera:translate(currentPos.x, currentPos.y, currentPos.z)
  camera:rotateY(currentYaw)
  camera:rotateX(currentPitch)
end

--- Initialize the camera module.
-- Sets starting position/orientation, FOV, and mouse callbacks.
-- @param dream table Dream framework instance containing `dream.camera`.
-- @usage
--   camera:init(dream)
function M:init(dream)
  self.dream = dream
  local init = cons.initialCameraPosition
  currentPos.x, currentPos.y, currentPos.z = init.x, init.y, init.z
  updateOrientation(self.dream.camera)

  -- Aim camera toward origin
  local d = math.sqrt(currentPos.x^2 + currentPos.y^2 + currentPos.z^2)
  if d > 0 then
    local vx, vy, vz = -currentPos.x / d, -currentPos.y / d, -currentPos.z / d
    currentPitch = math.asin(vy)
    currentYaw   = math.atan2(vx, -vz)
  end

  current_fov = current_fov or self.dream.camera:getFov()
  self.dream.camera:setFov(current_fov)

  -- Set up mouse movement handler
  love.mouse.setRelativeMode(false)
  love.mouse.setGrabbed(false)
  love.mousemoved = function(_, _, dx, dy)
    self:mousemoved(dx, dy)
  end
end

--- Update the camera each frame.
-- Handles orientation resets, FOV changes, panning, rotation, and mouse/grab toggles.
-- @param dt number Delta time since last update.
-- @usage
--   camera:update(dt)
function M:update(dt)
  -- Tween reset logic
  if isResettingOrientation then
    resetTimer = resetTimer + dt
    local t = math.min(resetTimer / resetDuration, 1)
    currentYaw   = lerpAngle(startYaw,  targetYaw,  t)
    currentPitch = lerp(     startPitch, targetPitch, t)
    updateOrientation(self.dream.camera)
    if t >= 1 then isResettingOrientation = false end
    return
  end

  local ctrl  = love.keyboard.isDown("lctrl", "rctrl")
  local shift = love.keyboard.isDown("lshift","rshift")

  if ctrl then
    -- Zoom in/out with up/down arrows
    local up   = love.keyboard.isDown("up")
    local down = love.keyboard.isDown("down")
    if up   then current_fov = math.max(current_fov - cons.sensitivity.keyboard_fov * dt, 1) end
    if down then current_fov = current_fov + cons.sensitivity.keyboard_fov * dt end
    if up or down then self.dream.camera:setFov(current_fov) end

  elseif shift then
    -- Free‐move forward/back
    local move = (love.keyboard.isDown("up")   and 1 or 0)
               - (love.keyboard.isDown("down") and 1 or 0)
    if move ~= 0 then
      local fx, fy, fz = getForwardVector()
      local dist = freeMoveSpeed * dt * move
      currentPos.x = currentPos.x + fx * dist
      currentPos.y = currentPos.y + fy * dist
      currentPos.z = currentPos.z + fz * dist
      updateOrientation(self.dream.camera)
    end

  else
    -- Orbit rotation with arrow keys
    if love.keyboard.isDown("left")  then currentYaw   = currentYaw   - keyboard_angle * dt end
    if love.keyboard.isDown("right") then currentYaw   = currentYaw   + keyboard_angle * dt end
    if love.keyboard.isDown("up")    then currentPitch = currentPitch + keyboard_angle * dt end
    if love.keyboard.isDown("down")  then currentPitch = currentPitch - keyboard_angle * dt end
    updateOrientation(self.dream.camera)
  end

  -- Mouse button → enable relative mode and grab
  local usingMouse = love.mouse.isDown(2, 3)
  if usingMouse and not love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(true)
    love.mouse.setGrabbed(true)
  elseif not usingMouse and love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(false)
    love.mouse.setGrabbed(false)
  end

  -- Update public view snapshot
  M.View.yaw   = currentYaw
  M.View.pitch = currentPitch
  M.View.Pos   = currentPos
  M.View.fov   = current_fov
end

--- Handle mouse‐drag movements.
-- Right‐button rotates, middle‐button pans along view direction.
-- @param dx number Mouse movement in x (pixels).
-- @param dy number Mouse movement in y (pixels).
-- @usage
--   camera:mousemoved(dx, dy)
function M:mousemoved(dx, dy)
  if isResettingOrientation then return end
  if cons.sensitivity.invert_mouse then
    dx, dy = -dx, -dy
  end

  if love.mouse.isDown(2) then
    -- Rotate view
    currentYaw   = currentYaw   + dx * mouse_angle
    currentPitch = currentPitch - dy * mouse_angle
    updateOrientation(self.dream.camera)

  elseif love.mouse.isDown(3) then
    -- Pan forward/back
    local fx, fy, fz = getForwardVector()
    local dist = -dy * freeMoveSpeed * 0.01
    currentPos.x = currentPos.x + fx * dist
    currentPos.y = currentPos.y + fy * dist
    currentPos.z = currentPos.z + fz * dist
    updateOrientation(self.dream.camera)
  end
end

--- Handle action bindings (reset view or FOV).
-- @param action string Action constant (from `src.input.actions`).
-- @treturn boolean True if the action was handled.
-- @usage
--   if camera:pressedAction(A.RESET_VIEW) then …
function M:pressedAction(action)
  if action == A.RESET_VIEW and not isResettingOrientation then
    -- Compute target orientation looking at origin
    local d = math.sqrt(currentPos.x^2 + currentPos.y^2 + currentPos.z^2)
    local computedPitch, computedYaw = 0, 0
    if d > 0 then
      local vx, vy, vz = -currentPos.x / d, -currentPos.y / d, -currentPos.z / d
      computedPitch = math.asin(vy)
      computedYaw   = math.atan2(vx, -vz)
    end
    startYaw, startPitch = normalizeAngle(currentYaw), currentPitch
    targetYaw, targetPitch = normalizeAngle(computedYaw), computedPitch
    isResettingOrientation = true
    resetTimer = 0
    return true

  elseif action == A.RESET_FOV then
    current_fov = cons.fov
    self.dream.camera:setFov(current_fov)
    return true
  end

  return false
end

return M
