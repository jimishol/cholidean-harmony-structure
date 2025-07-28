-- src/utils/materials.lua
local Colors    = require("src.utils.colors")
local constants = require("src.constants")

local M = {}

-- no change to init()
function M.init(dream)
  Colors.init(dream)
end

-- now we only recolor, never clone
function M.assignAll(scene, matLib, noteSystem, categoryMap)
  local map   = categoryMap or {
    joints   = "onyx",
    labels   = "onyx",    -- we’ll skip recoloring labels below
    edges    = "metal",
    curves   = "metal",
    surfaces = "metal",
  }
  local notes = noteSystem.notes

  for category, matKey in pairs(map) do
    local items = scene[category]
    if not items then goto continue end

    for idx, obj in ipairs(items) do
      local note = notes[idx]
      if not note then
        error(("No note at index %d in category %q"):format(idx, category))
      end

      -- skip labels entirely so they keep their original tint
      if category == "labels" then
        goto skip_label
      end

      local matInst = obj._matInst
      if not matInst then
        error("Object in " .. category .. " missing its _matInst")
      end

      -- recolor
      local r, g, b = Colors.getNoteColor(note.index)
      matInst:setColor(r, g, b)

      -- emission
      if note.active then
        matInst:setEmission(r, g, b)
        local scale = constants.categoryEmission[category] or 1.0
        matInst:setEmissionFactor(constants.activeEmission * scale)
      else
        matInst:setEmission(0, 0, 0)
        matInst:setEmissionFactor(0)
      end

      ::skip_label::
    end

    ::continue::
  end

  for i, lbl in ipairs(scene.activeLabels) do
    local mesh = scene.labelModels[lbl.name] or scene.labels[i]
    if mesh and mesh._matInst then
      local inst = mesh._matInst
      inst:setColor(lbl.color[1], lbl.color[2], lbl.color[3])
      -- optional emission for active labels
      if lbl.active then
        inst:setEmission(lbl.color[1], lbl.color[2], lbl.color[3])
        inst:setEmissionFactor(constants.activeEmission)
      else
        inst:setEmission(0, 0, 0)
        inst:setEmissionFactor(0)
      end
    end
  end
end

return M
