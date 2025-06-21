
-- main.lua

-- Extend package search paths so that modules and assets are found.
local extra = {
  "./MidiModules/?.lua",
  "./extensions/?.lua",
  "./extensions/?/?.lua",
  "./src/?.lua",
  "./assets/?.lua",
  "./examples/blacksmith/?.lua",  -- for Blacksmith demo assets
}
package.path = table.concat(extra, ";") .. ";" .. package.path

local dream = require("3DreamEngine")
local scene, sun, camera  -- we'll store the scene, the sun light, and our camera module here
camera = require("src/camera")

function love.load()
  love.window.setTitle("Cholidean harmony structure")
  
  -- Initialize the engine, letting it pick up the window dimensions from conf.lua.
  dream:init()
  
  -- (Optional) Set a sky using the built-in sky renderer.
  local sky = require("extensions/sky")
  dream:setSky(sky.render)
  
  -- Load the scene (the single object) from the Blacksmith example.
  scene = dream:loadObject("assets/sphere64")
  
  -- Create a sun light and enable shadow casting.
  sun = dream:newLight("sun")
  sun:addNewShadow()
  
  -- Require and initialize our custom orbiting camera.
  camera:init(dream)
end

function love.update(dt)
  -- Update the engine’s internal logic.
  dream:update()
  
  -- Update our custom orbit camera.
  camera:update(dt)
end

function love.draw()
  -- Prepare the frame, which clears buffers, sets up render targets, etc.
  dream:prepare()
  
  -- Apply our camera controller’s settings to the engine’s camera.
  camera:apply()
  
  -- Add our light so that the scene is illuminated.
  dream:addLight(sun)
  
  -- Draw the loaded scene.
  dream:draw(scene)
  
  -- Present the final rendered frame on screen.
  dream:present()
end

-- Optional: handle window resizing.
function love.resize(w, h)
  if dream.resize then
    dream:resize(w, h)
  else
    print("Window resized to", w, h)
  end
end
