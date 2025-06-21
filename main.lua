
local extra = {
  "./MidiModules/?.lua",
  "./extensions/?.lua",
  "./extensions/?/?.lua",
  "./src/?.lua",
  "./assets/?.lua",
}
package.path = table.concat(extra, ";") .. ";" .. package.path

-- 1) Load & init the engine once
local dream = require("3DreamEngine")
dream:init()

-- 2) (Optional) disable SSAO if you really don’t want it
-- dream:init{ ssao = { enable = false } }

-- 3) then load the rest of your game
local factory = require("factory")
local camera  = require("src/camera")

function love.load()
  camera:init(dream)
  factory.createBalls(12)
  -- …
end

function love.update(dt)
  dream:update()
  camera:update(dt)
  for _, b in ipairs(factory.balls) do b:update(dt) end
end

function love.draw()
  dream:prepare()
  camera:draw()
  for _, b in ipairs(factory.balls) do b:draw() end
  dream:present()
end

