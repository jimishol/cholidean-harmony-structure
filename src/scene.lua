-- src/scene.lua
local dream = require("3DreamEngine")
local lfs = love.filesystem

local scene = {}
scene.joints = {}

function scene.load()
  local basePath = "assets/models/joints/"
  local files = lfs.getDirectoryItems(basePath)

  for _, file in ipairs(files) do
    if file:match("%.obj$") then
      local name = file:match("(.+)%.obj")  -- Strip extension
      local success, object = pcall(function()
        return dream:loadObject(basePath .. name)
      end)
      if success and object then
        table.insert(scene.joints, object)
      else
        print("⚠️ Failed to load:", name)
      end
    end
  end
end

function scene.draw()
  for _, obj in ipairs(scene.joints) do
    dream:draw(obj)
  end
end

return scene
