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

-- 3) Require your modules
local scene  = require("scene")
local camera = require("camera")
local Input  = require("src.input")
local A      = require("src.input.actions")

function love.load()
  love.window.setTitle("Cholidean Harmony Structure")

  -- 4) Load all materials, then init the engine in the callback
  dream:loadMaterialLibrary("assets/materials")
  dream:setAutoExposure(true)
  dream:init()

    -- 5) Only now that the engine is initialized and textures are loaded do we load the scene & camera
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

  if scene.pressedAction and scene.pressedAction(action) then
    if action == A.ROTATE_CW or action == A.ROTATE_CCW then
      scene.updateLabels()
    end
    return
  end

  if camera.pressedAction and camera:pressedAction(action) then
    return
  end
end

function love.resize(w, h)
  -- re-initialize to update viewport, projection, etc.
  dream:init()
end
