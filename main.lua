-- main.lua

-- 1) Extend Lua’s search paths so `require("3DreamEngine")` finds ./3DreamEngine/init.lua
package.path = table.concat({
  "./?.lua",               -- so require("foo") -> ./foo.lua
  "./?/init.lua",          --    and require("foo") -> ./foo/init.lua
  "./3DreamEngine/?.lua",  -- so require("3DreamEngine.bar") -> ./3DreamEngine/bar.lua
  "./3DreamEngine/?/init.lua", -- and require("3DreamEngine") -> ./3DreamEngine/init.lua
  "./src/?.lua",
  "./src/?/init.lua",
  "./extensions/?.lua",
  "./extensions/?/init.lua",
  "./assets/?.lua",
}, ";") .. ";" .. package.path

-- 2) Require & instantiate 3DreamEngine
local Engine = require("3DreamEngine")
local dream  = (type(Engine) == "function" and Engine() or Engine)

-- 3) Pull in your scene & camera modules
local scene  = require("scene")   -- src/scene.lua must return a table with :load, :update, :draw
local camera = require("camera")  -- src/camera.lua must return a table with :init, :update, :apply

-- 4) LOVE2D callbacks

function love.load()
  love.window.setTitle("Cholidean Harmony Structure")
  dream:init()         -- initialize engine (shaders, loader, IBL, etc.)
  scene:load(dream)    -- set up HDR sky + load models
  camera:init(dream)   -- set up camera
end

function love.update(dt)
  dream:update(dt)     -- engine tick
  camera:update(dt)    -- camera logic
  scene:update(dt)     -- exposure tweaks, animations, etc.
end

function love.draw()
  dream:prepare()      -- clears/depth‐prepares, sets up render target
  camera:apply()       -- pushes view/proj matrices
  scene:draw(dream)    -- draws HDRI sky + your meshes
  dream:present()      -- post‐process & swap buffers
end

function love.resize(w, h)
  if dream.resize then dream:resize(w, h) end
end
