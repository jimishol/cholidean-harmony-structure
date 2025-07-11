local dream = require("3DreamEngine")
local lfs = love.filesystem

local scene = {}
scene.joints = {}

function scene.load()
  -- List files inside joints folder
  local files = love.filesystem.getDirectoryItems("assets/models/joints")

  for _, file in ipairs(files) do
    if file:match("%.obj$") then
      local path = "assets/models/joints/" .. file
      local name = file:match("(.+)%.obj")  -- strip '.obj' extension
      local object = dream:loadObject(path, name)
      table.insert(scene.joints, object)
    end
  end
end

function scene.draw()
  for _, obj in ipairs(scene.joints) do
    dream:draw(obj)
  end
end

return scene
