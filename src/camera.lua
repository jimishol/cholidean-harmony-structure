-- don’t re-require 3DreamEngine.init!
-- instead expect main.lua to pass you the one-and-only `dream` instance
local cameraController = require("extensions/utils/cameraController")
local scene            -- you’ll load your scene here
local sun

local M = {}

function M:init(dream)
  -- stash the engine
  self.dream = dream

  -- set up fog / sky / sun only once, here
  dream:setFogHeight(0.0, 150.0)

  local sky = require("extensions/sky")
  dream:setSky(sky.render)

  sun = dream:newLight("sun")
  sun:addNewShadow()

  dream:loadMaterialLibrary("examples/firstpersongame/materials")
  scene = dream:loadObject    ("examples/firstpersongame/objects/scene")

  cameraController.x =  8
  cameraController.y = 10
  cameraController.z =  2
end

function M:update(dt)
  cameraController:update(dt)
  -- animate time/weather if you want …
end

function M:draw()
  local dream = self.dream

  cameraController:setCamera(dream.camera)

  dream:addLight(sun)
  if love.mouse.isDown(1) then
    dream:addNewLight("point",
      dream.camera.pos + dream.camera.normal,
      dream.vec3(1.0, 0.75, 0.1),
      5.0 + love.math.noise(love.timer.getTime()*2)
    )
  end

  dream:draw(scene)
end

return M
