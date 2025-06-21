
-- src/camera.lua

local cameraController = require("extensions/utils/cameraController")
local M = {}

-- Orbit parameters for automatic and manual control.
local orbit = {
  angle  = 0,             -- current orbit angle in radians
  radius = 10,            -- distance from the scene center (for zoom)
  height = 3,             -- vertical offset of the camera
  speed  = math.pi / 4,   -- automatic orbit speed (45° per second)
}

function M:init(dream)
  self.dream = dream

  -- Set the initial camera position using the orbit parameters.
  cameraController.x = math.sin(orbit.angle) * orbit.radius
  cameraController.y = orbit.height
  cameraController.z = math.cos(orbit.angle) * orbit.radius

  -- Enable relative mouse mode so that mousemoved() receives relative motion values.
  love.mouse.setRelativeMode(true)

  -- Override LOVE's global mousemoved callback to route events through this module.
  love.mousemoved = function(_, _, x, y)
    self:mousemoved(x, y)
  end
end

function M:update(dt)
  local manualInput = false

  -- Keyboard controls:
  -- Left/Right keys rotate the camera.
  if love.keyboard.isDown("left") then
    orbit.angle = orbit.angle - orbit.speed * dt
    manualInput = true
  elseif love.keyboard.isDown("right") then
    orbit.angle = orbit.angle + orbit.speed * dt
    manualInput = true
  end

  -- Up/Down keys adjust the orbit radius (zoom).
  if love.keyboard.isDown("up") then
    orbit.radius = math.max(2, orbit.radius - 5 * dt)
    manualInput = true
  elseif love.keyboard.isDown("down") then
    orbit.radius = orbit.radius + 5 * dt
    manualInput = true
  end

  -- If no manual input detected via keyboard, allow auto orbit.
  if not manualInput then
    orbit.angle = orbit.angle + orbit.speed * dt
  end

  -- Compute new camera position from orbit parameters.
  local x = math.sin(orbit.angle) * orbit.radius
  local z = math.cos(orbit.angle) * orbit.radius
  local y = orbit.height

  cameraController.x = x
  cameraController.y = y
  cameraController.z = z

  cameraController:update(dt)
end

function M:apply()
  -- Apply the updated camera parameters to the 3DreamEngine camera.
  cameraController:setCamera(self.dream.camera)
end

-- This function handles relative mouse movement.
-- It will be called by the global love.mousemoved callback.
function M:mousemoved(relX, relY)
  -- Only process mouse motion if the right mouse button (button 2) is down.
  if love.mouse.isDown(2) then
    orbit.angle  = orbit.angle  + relX * 0.01   -- Adjust orbit angle based on horizontal movement.
    orbit.height = orbit.height + relY * 0.01   -- Adjust camera height based on vertical movement.
  end
end

return M
