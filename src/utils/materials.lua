-- src/utils/materials.lua

local M = {}

-- Default assignment if no map is passed
local defaultCategoryMap = {
  joints   = "onyx",
  labels   = "onyx",
  edges    = "metal",
  curves   = "metal",
  surfaces = "metal",
}

-- Loads a material library from a map of { key = modulePath, … }
function M.loadLibrary(pathMap)
  local lib = {}
  for key, modulePath in pairs(pathMap) do
    lib[key] = require(modulePath)
  end
  return lib
end

-- Assigns materials based on scene categories → material keys
-- scene:      table with scene.joints, scene.edges, etc.
-- matLib:     table returned by loadLibrary or dream.materialLibrary
-- categoryMap: optional table like { joints="onyx", … }
function M.assignAll(scene, matLib, categoryMap)
  local map = categoryMap or defaultCategoryMap

  for category, matKey in pairs(map) do
    local material = matLib[matKey]
    local items    = scene[category]
    if material and items then
      for _, obj in ipairs(items) do
        obj:setMaterial(material)
      end
    end
  end
end

return M
