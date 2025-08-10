--- Materials module for recoloring scene geometry based on active notes.
-- Applies ghost/X-ray or solid-emissive materials to surfaces,
-- and recolors joints, edges, curves, and labels accordingly.
-- @module src.materials

local Colors    = require("src.utils.colors")
local constants = require("src.constants")

local M = {}

--- Check if a torus surface at index `idx` should be considered active.
-- Evaluates the C–E, C–B, and E–G note pairs for simultaneous activation.
-- @local
-- @tparam number idx    Surface index (1–12)
-- @tparam table  notes  Array of note tables, each with an `.active` boolean
-- @treturn boolean      True if any required pair is active
local function checkSurfState(idx, notes)

  --- Wrap an integer into the 1–12 range.
  -- @local
  -- @tparam number n Input index
  -- @treturn number  Wrapped index between 1 and 12
  local function wrap12(n)
    return ((n - 1) % 12) + 1
  end

  local C = notes[wrap12(idx + 0)]
  local E = notes[wrap12(idx + 8)]
  local B = notes[wrap12(idx + 7)]
  local G = notes[wrap12(idx + 11)]

  local CE_active = C and C.active and E and E.active
  local CB_active = C and C.active and B and B.active
  local EG_active = E and E.active and G and G.active

  return CE_active or CB_active or EG_active
end

--- Update a surface’s material instance to be ghost/X-ray or solid-emissive.
-- @tparam table   matInst    Material instance (supports `setColor`, `setAlpha`, `setEmission`)
-- @tparam {number,number,number} noteColor RGB triplet `{r, g, b}`
-- @tparam boolean isActive   Whether the surface (note) is active
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

--- Initialize the materials system.
-- Delegates to the Colors module for any setup.
-- @tparam table dream Dream framework instance
function M.init(dream)
  Colors.init(dream)
end

--- Recolor all scene objects according to their note states.
-- Applies materials for joints, edges, curves, labels, and surfaces.
-- @tparam table       scene       Scene containing categories: `joints`, `labels`, `edges`, `curves`, `surfaces`, etc.
-- @tparam table       matLib      Material library (currently unused)
-- @tparam table       noteSystem  Note system with a `.notes` array of note tables
-- @tparam[opt] table  categoryMap Optional map from category name to material key.
--                             Defaults to:
--                             `{ joints="onyx", labels="onyx", edges="metal", curves="metal" }`
function M.assignAll(scene, matLib, noteSystem, categoryMap)
  local map   = categoryMap or {
    joints = "onyx",
    labels = "onyx",
    edges  = "metal",
    curves = "metal",
  }
  local notes = noteSystem.notes

  -- Recolor joints, edges, and curves
  for category, matKey in pairs(map) do
    local items = scene[category]
    if not items then goto continue end

    for idx, obj in ipairs(items) do
      local note = notes[idx]
      if not note then
        error(("No note at index %d in category %q"):format(idx, category))
      end

      -- Skip labels so they keep their original tint
      if category == "labels" then
        goto skip_label
      end

      local matInst = obj._matInst
      if not matInst then
        error("Object in " .. category .. " missing its _matInst")
      end

      local shift = 0
      if category == "curves" then shift = 1
      elseif category == "edges" then shift = 4
      end

      -- Wrap into 1–12
      local useIndex = ((note.index - 1 + shift) % 12) + 1

      -- Apply base color
      local r, g, b = Colors.getNoteColor(useIndex)
      matInst:setColor(r, g, b)

      -- Apply emission
      local levels = constants.emissionLevels[category] or { active = 0, inactive = 0 }
      local factor = note.active and levels.active or levels.inactive
      matInst:setEmission(factor, factor, factor)

      ::skip_label::
    end

    ::continue::
  end

  -- Label meshes (always original tint + emission)
  for i, lbl in ipairs(scene.labels_to_Draw) do
    local mesh = scene.labelModels[lbl.name] or scene.labels[i]
    if mesh and mesh._matInst then
      local inst   = mesh._matInst
      local levels = constants.emissionLevels.labels or { active = 0, inactive = 0 }
      local factor = lbl.active and levels.active or levels.inactive
      inst:setColor(lbl.color[1], lbl.color[2], lbl.color[3])
      inst:setEmission(factor, factor, factor)
    end
  end

  -- Surfaces: ghost/X-ray vs solid-emissive
  for idx, obj in ipairs(scene.surfaces) do
    local note    = noteSystem.notes[idx]
    if not note then
      error(("No note at index %d for surfaces"):format(idx))
    end

    local matInst   = obj._matInst
    local useIndex  = ((note.index - 1) % 12) + 1
    local noteColor = { Colors.getNoteColor(useIndex) }
    local isActive  = checkSurfState(idx, notes)

    M.updateSurfaceMaterial(matInst, noteColor, isActive)
  end
end

return M
