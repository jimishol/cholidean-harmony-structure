
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

-- Mouse sensitivity parameters.
local MOUSE_SENS = {
  angle  = 0.005,   -- horizontal mouse drag → orbit angle adjustment
  height = 0.05,    -- vertical mouse drag → orbit height adjustment
}
local MOUSE_ZOOM_SPEED = 0.1  -- mouse zoom (MMB vertical drag)

-- Keyboard sensitivity parameters.
local KEYBOARD_SENS = {
  angle  = 0.05,    -- keyboard left/right → orbit angle adjustment
  height = 0.5,     -- keyboard up/down (without shift) → orbit height adjustment
}
local KEYBOARD_ZOOM_SPEED = 1.0  -- keyboard zoom speed (for shift+up/down)

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
  
  -- Override LOVE's keypressed callback: press 'q' to exit.
  love.keypressed = function(key)
    if key == "q" then
      love.event.quit()
    end
  end
end

function M:update(dt)
  -- 1) Toggle relative mode and mouse grabbing if RMB or MMB is held.
  local anyDown = love.mouse.isDown(2) or love.mouse.isDown(3)
  if anyDown and not love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(true)
    love.mouse.setGrabbed(true)
  elseif not anyDown and love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(false)
    love.mouse.setGrabbed(false)
  end

  -- 2) Keyboard fallback for camera control:

  -- 2.1) With Shift held: Up/Down mimic MMB drag for zoom (adjust orbit.radius).
  if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
    if love.keyboard.isDown("up") then
      orbit.radius = math.max(2, orbit.radius - KEYBOARD_ZOOM_SPEED * dt)
    elseif love.keyboard.isDown("down") then
      orbit.radius = orbit.radius + KEYBOARD_ZOOM_SPEED * dt
    end
  
  -- 2.2) No Shift: Up/Down adjust orbit.height, mimicking RMB vertical drag.
  else
    if love.keyboard.isDown("up") then
      orbit.height = orbit.height + KEYBOARD_SENS.height * dt
    elseif love.keyboard.isDown("down") then
      orbit.height = orbit.height - KEYBOARD_SENS.height * dt
    end
  end

  -- 2.3) Left/Right keys adjust orbit.angle only when Shift is NOT held.
  if not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
    if love.keyboard.isDown("left") then
      orbit.angle = orbit.angle - KEYBOARD_SENS.angle * dt
    elseif love.keyboard.isDown("right") then
      orbit.angle = orbit.angle + KEYBOARD_SENS.angle * dt
    end
  end

  -- 3) Apply the updated orbit parameters to cameraController.
  cameraController.x = math.sin(orbit.angle) * orbit.radius
  cameraController.y = orbit.height
  cameraController.z = math.cos(orbit.angle) * orbit.radius
  cameraController:update(dt)
end

function M:apply()
  -- Apply the updated camera parameters to the 3DreamEngine camera.
  cameraController:setCamera(self.dream.camera)
end

-- This function handles relative mouse movement.
-- It will be called by the global love.mousemoved callback.
function M:mousemoved(dx, dy)
  -- With RMB (right mouse button) for orbit controls:
  if love.mouse.isDown(2) then
    orbit.angle  = orbit.angle  + dx * MOUSE_SENS.angle
    orbit.height = orbit.height - dy * MOUSE_SENS.height

  -- With MMB (middle mouse button) for zoom.
  elseif love.mouse.isDown(3) then
    orbit.radius = math.max(2, orbit.radius + dy * MOUSE_ZOOM_SPEED)
  end
end

return M
