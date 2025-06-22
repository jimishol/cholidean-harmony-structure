-- src/camera.lua

local cons = require("src/constants")  -- load constants
local M = {}

-- Sensitivity settings for free movement.
local freeMoveSpeed  = cons.sensitivity.free_move  or 5.0
local freeMouseSpeed = cons.sensitivity.free_mouse or 0.1
local KEYBOARD_FOV_SPEED = cons.sensitivity.keyboard_fov or 30.0 -- degrees per second
local current_fov = cons.fov or 60

function M:init(dream)
  self.dream = dream
  -- Reset the camera's transformation and set an initial position.
  self.dream.camera:resetTransform()
local pos = cons.initialCameraPosition or { x = 0, y = 0, z = 10 }
self.dream.camera:translate(pos.x, pos.y, pos.z)

  -- Synchronize the current FOV from the camera.
  current_fov = self.dream.camera:getFov() or current_fov

  -- Initially, let the OS control the mouse.
  love.mouse.setRelativeMode(false)
  love.mouse.setGrabbed(false)

  -- Hook mouse movement events.
  love.mousemoved = function(_, _, dx, dy)
    self:mousemoved(dx, dy)
  end

  love.keypressed = function(key)
    if key == "q" then love.event.quit() end
  end
end

function M:update(dt)
  local ctrlDown  = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
  local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

  if ctrlDown then
    -- When Ctrl is held:
    -- Left/right keys do nothing.
    -- Up/down control the FOV ONLY if one (or both) of them is pressed.
    local upPressed = love.keyboard.isDown("up")
    local downPressed = love.keyboard.isDown("down")
    if upPressed then
      current_fov = current_fov - KEYBOARD_FOV_SPEED * dt
    end
    if downPressed then
      current_fov = current_fov + KEYBOARD_FOV_SPEED * dt
    end
    if upPressed or downPressed then
      self.dream.camera:setFov(current_fov)
    end
  else
    -- When Ctrl is NOT held, process free movement.
    local tx, ty, tz = 0, 0, 0

    if shiftDown then
      -- With Shift (and no Ctrl):
      -- Left/right are disabled.
      -- Up/down control local Z with reversed directions:
      if love.keyboard.isDown("up") then
        tz = -1   -- Shift+up results in -local Z translation.
      end
      if love.keyboard.isDown("down") then
        tz = 1    -- Shift+down results in +local Z translation.
      end
    else
      -- With no modifiers:
      -- Left/right control local X (unchanged):
      if love.keyboard.isDown("left") then
        tx = -1
      end
      if love.keyboard.isDown("right") then
        tx = 1
      end
      -- Up/down control local Y with reversed directions:
      if love.keyboard.isDown("up") then
        ty = 1    -- Up arrow produces +local Y.
      end
      if love.keyboard.isDown("down") then
        ty = -1   -- Down arrow produces -local Y.
      end
    end

    -- Normalize translation vector to avoid faster diagonal movement.
    local magnitude = math.sqrt(tx * tx + ty * ty + tz * tz)
    if magnitude > 0 then
      tx, ty, tz = tx / magnitude, ty / magnitude, tz / magnitude
      self.dream.camera:translate(tx * freeMoveSpeed * dt,
                                   ty * freeMoveSpeed * dt,
                                   tz * freeMoveSpeed * dt)
    end
  end

  -- Toggle relative mouse mode only when RMB or MMB are held.
  local usingMouse = love.mouse.isDown(2) or love.mouse.isDown(3)
  if usingMouse and not love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(true)
    love.mouse.setGrabbed(true)
  elseif not usingMouse and love.mouse.getRelativeMode() then
    love.mouse.setRelativeMode(false)
    love.mouse.setGrabbed(false)
  end
end

function M:apply()
  -- In free movement mode, the camera's transform has already been updated.
  -- Nothing further is necessary here.
end

function M:mousemoved(dx, dy)
  if cons.sensitivity.invert_mouse then
    dx = -dx
    dy = -dy
  end

  if love.mouse.isDown(2) then
    -- RMB drag moves along local X and Y.
    -- Reverse the horizontal component (left/right) by using -dx;
    -- keep the vertical component unchanged.
    self.dream.camera:translate( dx * freeMouseSpeed,
                                -dy * freeMouseSpeed,
                                 0)
  elseif love.mouse.isDown(3) then
    -- MMB drag moves along local Z.
    -- Reverse the vertical component by using dy (instead of -dy).
    self.dream.camera:translate(0, 0, dy * freeMouseSpeed)
  end
end

return M
