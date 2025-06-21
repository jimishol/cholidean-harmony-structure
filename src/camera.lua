
-- src/camera.lua

-- We use the cameraController module provided by 3DreamEngine
local cameraController = require("extensions/utils/cameraController")
local M = {}

-- Orbit parameters for an automatic, continuously orbiting camera.
local orbit = {
  angle  = 0,             -- current orbit angle in radians
  radius = 10,            -- distance from the scene center (adjust for zoom)
  height = 3,             -- vertical offset of the camera
  speed  = math.pi / 4,   -- orbit rotation speed (45° per second)
}

-- Initialize the camera controller.
function M:init(dream)
  self.dream = dream
  
  -- Set an initial position for the camera using the orbit parameters.
  cameraController.x = math.sin(orbit.angle) * orbit.radius
  cameraController.y = orbit.height
  cameraController.z = math.cos(orbit.angle) * orbit.radius
end

-- Update the orbit camera position.
function M:update(dt)
  -- Increment the orbit angle over time.
  orbit.angle = orbit.angle + orbit.speed * dt
  
  -- Compute new camera position along a circular orbit.
  local x = math.sin(orbit.angle) * orbit.radius
  local z = math.cos(orbit.angle) * orbit.radius
  local y = orbit.height
  
  -- Update the built-in cameraController's position parameters.
  cameraController.x = x
  cameraController.y = y
  cameraController.z = z
  
  -- (Optional) the cameraController may use dt to update internal smoothing or inertia.
  cameraController:update(dt)
end

-- Apply the updated camera settings to the engine's camera.
function M:apply()
  cameraController:setCamera(self.dream.camera)
end

return M
