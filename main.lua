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
  camera:apply()
  scene.draw(dream)
  labels.draw3D(dream)
  dream:present()
  camera:apply()
end

function love.keypressed(key)
  labels.update(key)
end

function love.resize(w, h)
  dream:init()
end
