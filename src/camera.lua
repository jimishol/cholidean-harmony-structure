
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

-- how sensitive the RMB orbit is
local RMB_SENS = {
  angle  = 0.005,   -- horizontal drag → orbit speed
  height = 0.05,   -- vertical drag → up/down speed
}

local MMB_ZOOM_SPEED = 0.1    -- tweak this to taste

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

-- 1) toggle relative+grab if RMB or MMB is held
  local anyDown = love.mouse.isDown(2) or love.mouse.isDown(3)
  if anyDown and not love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(true)
    love.mouse.setGrabbed(true)
  elseif not anyDown and love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(false)
    love.mouse.setGrabbed(false)
  end

  -- 2) keyboard fallback orbit & zoom
  if love.keyboard.isDown("left") then
    orbit.angle = orbit.angle - orbit.speed * dt
  elseif love.keyboard.isDown("right") then
    orbit.angle = orbit.angle + orbit.speed * dt
  end
  if love.keyboard.isDown("up") then
    orbit.radius = math.max(2, orbit.radius - 5 * dt)
  elseif love.keyboard.isDown("down") then
    orbit.radius = orbit.radius + 5 * dt
  end

  -- 3) apply orbit to cameraController
  cameraController.x = math.sin(orbit.angle) * orbit.radius
  cameraController.y = orbit.height
  cameraController.z = math.cos(orbit.angle) * orbit.radius
  cameraController:update(dt)
  -- If no manual input detected via keyboard, allow auto orbit.
  -- if not manualInput then
  --   orbit.angle = orbit.angle + orbit.speed * dt
  -- end

  -- Compute new camera position from orbit parameters.
  -- local x = math.sin(orbit.angle) * orbit.radius
  -- local z = math.cos(orbit.angle) * orbit.radius
  -- local y = orbit.height

  -- cameraController.x = x
  -- cameraController.y = y
  -- cameraController.z = z

  cameraController:update(dt)
end

function M:apply()
  -- Apply the updated camera parameters to the 3DreamEngine camera.
  cameraController:setCamera(self.dream.camera)
end

-- This function handles relative mouse movement.
-- It will be called by the global love.mousemoved callback.
function M:mousemoved(dx, dy)
  -- orbit with RMB
  if love.mouse.isDown(2) then
    -- faster rotate:
    orbit.angle  = orbit.angle  + dx * RMB_SENS.angle
    -- faster up/down:
    orbit.height = orbit.height + dy * RMB_SENS.height

  -- forward/back with MMB
  elseif love.mouse.isDown(3) then
    orbit.radius = math.max(2, orbit.radius + dy * MMB_ZOOM_SPEED)
  end
end

return M
