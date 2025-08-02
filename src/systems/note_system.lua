-- src/systems/note_system.lua

local constants = require("src.constants")
local NoteState = require("midi.note_state")

-- Single-note abstraction
local Note = {}
Note.__index = Note
function Note:new(idx, name, jointObj)
  return setmetatable({
    index     = idx,      -- 1..12
    name      = name,     -- e.g. "C"
    joint     = jointObj, -- the mesh object for this joint
    active    = false,    -- future MIDI on/off
    isBass    = false,
    midiProps = {},       -- placeholder
  }, Note)
end

-- Manages all 12 Notes + circular shifts
local NoteSystem = {}
NoteSystem.__index = NoteSystem

function NoteSystem:new(scene)
  local instance = setmetatable({ scene = scene, notes = {} }, NoteSystem)

  -- Instantiate notes & bind to joint_00..joint_11
  for i, name in ipairs(constants.NOTE_ORDER) do
    local jointID = string.format("joint_%02d", i-1)

    -- find the actual mesh object in scene.joints
    local jointObj
    for _, obj in ipairs(scene.joints) do
      if obj.id == jointID then jointObj = obj; break end
    end

    instance.notes[i] = Note:new(i, name, jointObj)
  end

  instance.prevActive = {}
  for i = 1, #instance.notes do
    instance.prevActive[i] = false
  end

  return instance
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
  end
end

function NoteSystem:update(dt)
  local changed = false

  for slotIdx, note in ipairs(self.notes) do
    -- Query both active and bass flags
    local isActive = NoteState.isNoteActive(note.index)
    local isBass   = NoteState.isNoteBass(note.index)

    -- Detect any on/off transition
    if isActive ~= self.prevActive[slotIdx] then
      changed = true
    end

    -- Store for next frame’s diff check
    self.prevActive[slotIdx] = isActive

    -- Update your note object
    note.active = isActive
    note.isBass = isBass

    -- Debug
    print(string.format(
      "Note %s : active=%s, isBass=%s",
      note.name,
      tostring(note.active),
      tostring(note.isBass)
    ))
  end

  return changed
end

return NoteSystem
