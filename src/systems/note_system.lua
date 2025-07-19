-- src/systems/note_system.lua

local constants = require("src.constants")

-- Single-note abstraction
local Note = {}
Note.__index = Note
function Note:new(idx, name, jointObj)
  return setmetatable({
    index     = idx,      -- 1..12
    name      = name,     -- e.g. "C"
    joint     = jointObj, -- the mesh object for this joint
    active    = false,    -- future MIDI on/off
    midiProps = {},       -- placeholder
  }, Note)
end

-- Manages all 12 Notes + circular shifts
local NoteSystem = {}
NoteSystem.__index = NoteSystem

function NoteSystem:new(scene)
  local self = setmetatable({ scene = scene, notes = {} }, NoteSystem)

  -- Instantiate notes & bind to joint_00..joint_11
  for i, name in ipairs(constants.NOTE_ORDER) do
    local jointID = string.format("joint_%02d", i-1)

    -- find the actual mesh object in scene.joints
    local jointObj
    for _, obj in ipairs(scene.joints) do
      if obj.id == jointID then jointObj = obj; break end
    end

    self.notes[i] = Note:new(i, name, jointObj)
    self:_applyToGeometry(i)
  end

  return self
end

-- Shift all notes by offset (+1 = right, -1 = left)
function NoteSystem:shift(offset)
  local n = #self.notes
  local tmp = {}

  for i, note in ipairs(self.notes) do
    -- compute new slot
    local j = ((i-1 + offset) % n) + 1
    tmp[j] = note
  end
  self.notes = tmp

  -- rebind and reapply
  for i, note in ipairs(self.notes) do
    local jointID = string.format("joint_%02d", i-1)
    for _, obj in ipairs(self.scene.joints) do
      if obj.id == jointID then note.joint = obj; break end
    end
    self:_applyToGeometry(i)
  end
end

-- Propagate note info into matching edge/curve/surface/label objects
function NoteSystem:_applyToGeometry(i)
  local note   = self.notes[i]
  local suffix = string.format("%02d", i-1)
  local targets = {
    "edge_"    .. suffix,
    "curve_"   .. suffix,
    "surface_" .. suffix,
    "label_"   .. suffix,
  }

  for _, name in ipairs(targets) do
    -- search in all lists
    for _, list in ipairs{ self.scene.edges,
                           self.scene.curves,
                           self.scene.surfaces,
                           self.scene.joints } do
      for _, obj in ipairs(list) do
        if obj.id == name then
          obj.noteName  = note.name
          obj.noteIndex = note.index
          obj.active    = note.active
        end
      end
    end
  end
end

return NoteSystem
