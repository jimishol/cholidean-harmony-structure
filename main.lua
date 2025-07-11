
--- Entry point for the Cholidean Harmony Structure viewer.
-- Initializes 3DreamEngine, sets up scene, camera, lighting, and rendering flow.
-- @module main

-- Extend package search paths for custom modules and assets
local extra = {
  "./MidiModules/?.lua",
  "./extensions/?.lua",
  "./extensions/?/?.lua",
  "./src/?.lua",
  "./assets/?.lua",
  "./materials/?.lua"
--  "./examples/blacksmith/?.lua",  -- for Blacksmith demo assets
}
package.path = table.concat(extra, ";") .. ";" .. package.path

local dream = require("3DreamEngine")
local scene, sun, camera
camera = require("camera")

-- Track last window dimensions for resize logic
local lastW, lastH = love.graphics.getDimensions()

--- LOVE callback: triggered once at application startup.
-- Initializes 3DreamEngine, sets title, loads assets, and sets up camera.
function love.load()
  love.window.setTitle("Cholidean harmony structure")

  dream:init()

  -- Set optional sky renderer
  local sky = require("extensions/sky")
  dream:setSky(sky.render)

  -- Load the cholidean structure scene
  scene = dream:loadObject("assets/models/cholideanScene")

  -- Create and configure sun light
  sun = dream:newLight("sun")
  sun:addNewShadow()

  -- Initialize camera controller
  camera:init(dream)
end

--- LOVE callback: updates every frame.
-- Handles window resizing, engine updates, and camera logic.
-- @param dt Delta time (in seconds)
function love.update(dt)
  local w, h = love.graphics.getDimensions()
  if w ~= lastW or h ~= lastH then
    lastW, lastH = w, h
    if dream.resize then
      dream:resize(w, h)
    end
  end

  dream:update()
  camera:update(dt)
end

--- LOVE callback: draws each frame.
-- Prepares scene, applies lighting and camera, renders model.
function love.draw()
  dream:prepare()
  camera:apply()
  dream:addLight(sun)
  dream:draw(scene)
  dream:present()
end

--- LOVE callback: handles manual window resizing.
-- @param w New window width
-- @param h New window height
function love.resize(w, h)
  if dream.resize then
    dream:resize(w, h)
  else
    print("Window resized to", w, h)
  end
end
