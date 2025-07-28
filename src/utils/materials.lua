-- src/utils/materials.lua
local Colors    = require("src.utils.colors")
local constants = require("src.constants")

local M = {}

local defaultCategoryMap = {
  joints   = "onyx",
  labels   = "onyx",
  edges    = "metal",
  curves   = "metal",
  surfaces = "metal",
}

function M.init(dream)
  Colors.init(dream)
end

-- scene        = table with category arrays (scene.joints, scene.edges, …)
-- matLib       = dream.materialLibrary
-- noteSystem   = your NoteSystem instance (holds .notes[])
-- categoryMap  = optional override map
function M.assignAll(scene, matLib, noteSystem, categoryMap)
  assert(noteSystem, "NoteSystem is required for materials.assignAll()")

  local map   = categoryMap or defaultCategoryMap
  local notes = noteSystem.notes

  for category, matKey in pairs(map) do
    local baseMat = matLib[matKey]
    local items   = scene[category]
    if not baseMat or not items then goto continue end

    for idx, obj in ipairs(items) do
      local note = notes[idx]
      if not note then
        error(("No note at index %d in category %q"):format(idx, category))
      end

      -- clone the shared material
      local matInst = baseMat:clone()

      -- destructure RGB from HSVtoRGB
      local r, g, b = Colors.getNoteColor(note.index)

      -- apply tint
      matInst:setColor(r, g, b)

      -- apply emission only if active
      if note.active then
        matInst:setEmission(r, g, b)
        local scale = constants.categoryEmission[category] or 1.0
        matInst:setEmissionFactor(constants.activeEmission * scale)
      else
        matInst:setEmission(0, 0, 0)
        matInst:setEmissionFactor(0)
      end

      -- assign the material
      if obj.setMaterial then
        obj:setMaterial(matInst)
      elseif obj.geometry and obj.geometry.setMaterial then
        obj.geometry:setMaterial(0, matInst)
      else
        error("Cannot set material on object in category "..category)
      end
    end

    ::continue::
  end
end

return M
