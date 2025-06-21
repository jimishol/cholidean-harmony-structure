local extra = {
  "./MidiModules/?.lua",
  "./Extensions/?.lua",
  "./Extensions/?/?.lua",
  "./src/?.lua",
  "./assets/?.lua"
}
package.path = table.concat(extra, ";") .. ";" .. package.path

-- load core engine
local dream = require("3DreamEngine")
local factory = require("factory")

-- Use a fancy sky
--local sky = require("Extensions/sky")
--dream:setSky(sky.render)

-- Create as sun
local sun = dream:newLight("sun")

local camera = require("src/camera")

function love.load()
    dream:init()
camera:init(dream)
-- dream.camera:resetTransform()
-- dream.camera:translate(0,0,40)




    factory.createBalls(12)
--    factory.createCubes(6, 2.0)

    --creates a light
    light = dream:newLight("point", dream.vec3(3, 2, 1), dream.vec3(1.0, 0.75, 0.2), 50.0)

    --add shadow to light source
    light:addNewShadow()
end

function love.update(dt)

--update custom cameras
	local t = love.timer.getTime() * 0.1


  dream:update()
  for _, b in ipairs(factory.balls) do b:update(dt) end
--  for _, c in ipairs(factory.cubes) do c:update(dt) end
end


function love.draw()
	--prepare for rendering
	dream:prepare()
	--add light
	dream:addLight(light)
	for _, b in ipairs(factory.balls) do b:draw() end
--	for _, c in ipairs(factory.cubes) do c:draw() end
	--render
	dream:present()
end
