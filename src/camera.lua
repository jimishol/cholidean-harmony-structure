-- src/camera.lua

local cameraController = require("extensions/utils/cameraController")
local cons = require("src/constants")  -- load constants
local M = {}

-- Orbit parameters for automatic and manual control.
local orbit = {
  angle  = cons.orbit.initial_angle,   -- current orbit angle in radians.
  radius = cons.distance,              -- distance from the scene center (for zoom) is now M.distance.
  height = cons.orbit.initial_height,   -- vertical offset of the camera.
  speed  = cons.orbit.orbit_speed,       -- automatic orbit speed.
}

-- Mouse sensitivity parameters.
local MOUSE_SENS = {
  angle  = cons.sensitivity.mouse_angle,  -- horizontal mouse drag sensitivity.
  height = cons.sensitivity.mouse_height,   -- vertical mouse drag sensitivity.
}
local MOUSE_ZOOM_SPEED = cons.sensitivity.mouse_zoom  -- mouse zoom speed (MMB vertical drag).

-- Keyboard sensitivity parameters.
local KEYBOARD_SENS = {
  angle  = cons.sensitivity.keyboard_angle, -- keyboard left/right sensitivity for orbit angle.
  height = cons.sensitivity.keyboard_height,  -- keyboard up/down sensitivity for orbit height.
}
local KEYBOARD_ZOOM_SPEED = cons.sensitivity.keyboard_zoom  -- keyboard zoom speed (when Shift is held).

-- Additional keyboard sensitivity for FOV adjustments.
local KEYBOARD_FOV_SPEED = cons.sensitivity.keyboard_fov  -- degrees per second adjustment.

-- Holds the current FOV; starts at the value defined in constants (in degrees).
local current_fov = cons.fov

function M:init(dream)
  self.dream = dream
  -- Set the initial camera position using the orbit parameters.
  cameraController.x = math.sin(orbit.angle) * orbit.radius
  cameraController.y = orbit.height
  cameraController.z = math.cos(orbit.angle) * orbit.radius

  -- Enable relative mouse mode.
  love.mouse.setRelativeMode(true)
  
  -- Route mouse movement events.
  love.mousemoved = function(_, _, x, y)
    self:mousemoved(x, y)
  end
  
  -- Define keypressed action: 'q' quits.
  love.keypressed = function(key)
    if key == "q" then
      love.event.quit()
    end
  end
end

function M:update(dt)
  -- Toggle relative mouse mode and grabbing if RMB or MMB is held.
  local anyDown = love.mouse.isDown(2) or love.mouse.isDown(3)
  if anyDown and not love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(true)
    love.mouse.setGrabbed(true)
  elseif not anyDown and love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(false)
    love.mouse.setGrabbed(false)
  end

  local ctrlDown = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
  local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

  -- Up/Down keys: disable if Ctrl is held.
  if not ctrlDown then
    if shiftDown then
      -- With Shift: Up/Down adjust orbit.radius (zoom).
      if love.keyboard.isDown("up") then
        orbit.radius = math.max(2, orbit.radius - KEYBOARD_ZOOM_SPEED * dt)
      elseif love.keyboard.isDown("down") then
        orbit.radius = orbit.radius + KEYBOARD_ZOOM_SPEED * dt
      end
    else
      -- Without Shift: Up/Down adjust orbit.height (vertical movement).
      if love.keyboard.isDown("up") then
        orbit.height = orbit.height + KEYBOARD_SENS.height * dt
      elseif love.keyboard.isDown("down") then
        orbit.height = orbit.height - KEYBOARD_SENS.height * dt
      end
    end
  end

  -- Left/Right keys: disable if Shift is held.
  if not shiftDown then
    if ctrlDown then
      -- With Control: Left/Right adjust the field of view.
      if love.keyboard.isDown("left") then
        current_fov = math.max(15, current_fov - KEYBOARD_FOV_SPEED * dt)
      elseif love.keyboard.isDown("right") then
        current_fov = current_fov + KEYBOARD_FOV_SPEED * dt
      end
    else
      -- Without Control: Left/Right adjust orbit.angle (horizontal rotation).
      if love.keyboard.isDown("left") then
        orbit.angle = orbit.angle - KEYBOARD_SENS.angle * dt
      elseif love.keyboard.isDown("right") then
        orbit.angle = orbit.angle + KEYBOARD_SENS.angle * dt
      end
    end
  end

  -- Update the camera controller with the modified orbit parameters.
  cameraController.x = math.sin(orbit.angle) * orbit.radius
  cameraController.y = orbit.height
  cameraController.z = math.cos(orbit.angle) * orbit.radius
  cameraController:update(dt)
end

function M:apply()
  -- Apply the updated orbit parameters to the 3DreamEngine camera.
  cameraController:setCamera(self.dream.camera)
  -- Set the Field of View using current_fov (in degrees).
  self.dream.camera:setFov(current_fov)
end

function M:mousemoved(dx, dy)
  -- Revert mouse movement if invert_mouse is enabled.
  if cons.sensitivity.invert_mouse then
    dx = -dx
    dy = -dy
  end
  -- With RMB for orbit controls:
  if love.mouse.isDown(2) then
    orbit.angle  = orbit.angle  + dx * MOUSE_SENS.angle
    orbit.height = orbit.height - dy * MOUSE_SENS.height
  -- With MMB for zoom:
  elseif love.mouse.isDown(3) then
    orbit.radius = math.max(2, orbit.radius + dy * MOUSE_ZOOM_SPEED)
  end
end

return M
