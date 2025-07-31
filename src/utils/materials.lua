-- src/utils/materials.lua
local Colors    = require("src.utils.colors")
local constants = require("src.constants")

local M = {}

--- Update one surface’s material to ghost/X-ray or solid-emissive
function M.updateSurfaceMaterial(matInst, noteColor, isActive)
  local r, g, b = noteColor[1], noteColor[2], noteColor[3]
  if isActive then
    matInst:setColor(r, g, b, 1.0)
    local f = constants.emissionLevels.surfaces.active
    matInst:setEmission(f, f, f)
  else
    matInst:setAlpha()
    matInst:setColor(r, g, b, constants.surfAlpha)
    local f = constants.emissionLevels.surfaces.inactive
    matInst:setEmission(f, f, f)
  end
end

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

      -- determine how many steps to shift in the 12-tone circle
      local shift = 0
      if category == "curves" then
        shift = 1    -- curves get next tone
      elseif category == "edges" then
        shift = 4    -- edges jump +4 tones
      end

      -- wrap around 1..12
      local useIndex = ((note.index - 1 + shift) % 12) + 1

      -- recolor using the shifted index
      local r, g, b = Colors.getNoteColor(useIndex)
      matInst:setColor(r, g, b)

      -- emission: always set the note’s color, let the factor dial the glow
      local levels = constants.emissionLevels[category] or { active = 0, inactive = 0 }
      local factor = note.active and levels.active or levels.inactive

      matInst:setEmission(factor, factor, factor)

      ::skip_label::
    end

    ::continue::
  end

  for i, lbl in ipairs(scene.activeLabels) do
    local mesh = scene.labelModels[lbl.name] or scene.labels[i]
    if mesh and mesh._matInst then
      local inst = mesh._matInst
      inst:setColor(lbl.color[1], lbl.color[2], lbl.color[3])

      -- emission for labels: always use the label hue + its factor
      local levels = constants.emissionLevels.labels or { active = 0, inactive = 0 }
      local factor = lbl.active and levels.active or levels.inactive

      inst:setEmission(factor, factor, factor)
    end
  end

  -- now handle surfaces with our ghost/X-ray helper
  for idx, obj in ipairs(scene.surfaces) do
    local note     = noteSystem.notes[idx]
    if not note then
      error(("No note at index %d for surfaces"):format(idx))
    end

    local matInst   = obj._matInst
    local shift     = 0            -- surfaces don’t shift hue
    local useIndex  = ((note.index - 1 + shift) % 12) + 1
    local noteColor = { Colors.getNoteColor(useIndex) }
    local isActive  = note.active

    -- ghost ↔ solid-emissive
    M.updateSurfaceMaterial(matInst, noteColor, isActive)
  end

end

return M
