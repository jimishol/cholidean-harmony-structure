
-- src/camera.lua

local cameraController = require("extensions/utils/cameraController")
local M = {}

local orbit = {
  angle  = 0,             -- current orbit angle in radians
  radius = 10,            -- distance from the center (for zoom)
  height = 3,             -- vertical offset
  speed  = math.pi / 4,   -- orbit speed (radians per second)
}

function M:init(dream)
  self.dream = dream
  -- Set initial position
  cameraController.x = math.sin(orbit.angle) * orbit.radius
  cameraController.y = orbit.height
  cameraController.z = math.cos(orbit.angle) * orbit.radius
end

function M:update(dt)
  -- Update orbit angle
  orbit.angle = orbit.angle + orbit.speed * dt
  
  -- Calculate updated camera position
  local x = math.sin(orbit.angle) * orbit.radius
  local z = math.cos(orbit.angle) * orbit.radius
  local y = orbit.height
  
  cameraController.x = x
  cameraController.y = y
  cameraController.z = z
  
  -- Call the built-in update to handle smoothing and internal logic.
  cameraController:update(dt)
end

function M:apply()
  cameraController:setCamera(self.dream.camera)
end

return M
