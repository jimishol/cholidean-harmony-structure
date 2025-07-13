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
local sceneData, camera
camera = require("camera")
sceneData = require("scene")  -- Loads from src/scene.lua

-- Track last window dimensions for resize logic
local lastW, lastH = love.graphics.getDimensions()

--- LOVE callback: triggered once at application startup.
-- Initializes 3DreamEngine, sets title, loads assets, and sets up camera.
function love.load()
  love.window.setTitle("Cholidean harmony structure")
  dream:init()

  sceneData.load()
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
  sceneData.update(dt)
end

--- LOVE callback: draws each frame.
-- Prepares scene, applies lighting and camera, renders model.
function love.draw()
  dream:prepare()
  camera:apply()
  sceneData.draw()
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
