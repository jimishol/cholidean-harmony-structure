-- main.lua

-- 1) Extend Lua’s search paths
package.path = table.concat({
  "./?.lua",
  "./?/init.lua",
  "./3DreamEngine/?.lua",
  "./3DreamEngine/?/init.lua",
  "./src/?.lua",
  "./src/?/init.lua",
  "./extensions/?.lua",
  "./extensions/?/init.lua",
  "./assets/?.lua",
}, ";") .. ";" .. package.path

-- 2) Require & instantiate 3DreamEngine
local Engine = require("3DreamEngine")
local dream  = (type(Engine) == "function" and Engine() or Engine)

-- 3) Require modules
local labels = require("src.labels")
local scene  = require("scene")
local camera = require("camera")
local Input = require("src.input")
local A     = require("src.input.actions")
-- 4) LOVE2D callbacks

function love.load()
  love.window.setTitle("Cholidean Harmony Structure")
  dream:init()
  scene.load(dream)
  camera:init(dream)
end

function love.update(dt)
  dream:update(dt)
  camera:update(dt)
  scene.update(dt)
end

function love.draw()
  dream:prepare()
  scene.apply()
  scene.draw(dream)
  dream:present()
  scene.apply()
end

function love.keypressed(key)
  local action = Input:onKey(key)
  if not action then return end

  if action == A.QUIT then
    love.event.quit()
    return
  end

  -- 1) scene handles all its rotates/toggles
  if scene.pressedAction and scene.pressedAction(action) then
    if action == A.ROTATE_CW or action == A.ROTATE_CCW then
      scene.updateLabels()
    end
    return
  end

  -- 2) camera handles reset‐view & debug (via our new pressedAction)
  if camera.pressedAction and camera:pressedAction(action) then
    return
  end

  -- 3) (optionally) other systems…
end

function love.resize(w, h)
  dream:init()
end
