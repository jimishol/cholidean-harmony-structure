-- src/systems/note_system.lua

local constants = require("src.constants")
local backend = constants.backend or "fluidsynth" -- or however you define it

local NoteState

if backend and backend ~= "" then
  NoteState = require("src.backends.note_state")
else
  NoteState = require("src.backends.note_state")  -- fallback to default watcher
end

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

-- default to instant
NoteSystem.noteMode = constants.defaultNoteMode

function NoteSystem:toggleNoteMode()
  if self.noteMode == "instant" then
    self.noteMode = "offset"
  else
    self.noteMode = "instant"
  end
end

function NoteSystem:new(scene)
  local instance = setmetatable({
    scene                  = scene,
    notes                  = {},
    prevActive             = {},
    prevBass               = {},
    deactivationTimers     = {},
    bassDeactivationTimers = {},
    offsetDuration         = constants.offsetDuration or 0.2,
    bassOffsetDuration     = constants.bassOffsetDuration or 0.1,
  }, NoteSystem)

  -- Instantiate notes & initialize prevActive/prevBass
  for i, name in ipairs(constants.NOTE_ORDER) do
    local jointID = string.format("joint_%02d", i-1)
    local jointObj
    for _, obj in ipairs(scene.joints) do
      if obj.id == jointID then
        jointObj = obj
        break
      end
    end

    instance.notes[i]      = Note:new(i, name, jointObj)
    instance.prevActive[i] = false
    instance.prevBass[i]   = false
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
  local changed   = false
  local useOffset = (self.noteMode == "offset")

  for slotIdx, note in ipairs(self.notes) do
    local isActive = NoteState.isNoteActive(note.index)
    local isBass   = NoteState.isNoteBass(note.index)

    if useOffset then
      -- ACTIVE WITH OFFSET
      if     isActive and not self.prevActive[slotIdx] then
        note.active                       = true
        self.deactivationTimers[slotIdx]  = nil
        changed                           = true

      elseif not isActive and self.prevActive[slotIdx] then
        self.deactivationTimers[slotIdx]  = self.offsetDuration
      end

      local tA = self.deactivationTimers[slotIdx]
      if tA then
        tA = tA - dt
        if tA <= 0 then
          note.active                      = false
          self.deactivationTimers[slotIdx] = nil
          changed                          = true
        else
          self.deactivationTimers[slotIdx] = tA
        end
      end

      -- BASS WITH OFFSET
      if     isBass and not self.prevBass[slotIdx] then
        note.isBass                         = true
        self.bassDeactivationTimers[slotIdx] = nil
        changed                             = true

      elseif not isBass and self.prevBass[slotIdx] then
        self.bassDeactivationTimers[slotIdx] = self.bassOffsetDuration
      end

      local tB = self.bassDeactivationTimers[slotIdx]
      if tB then
        tB = tB - dt
        if tB <= 0 then
          note.isBass                         = false
          self.bassDeactivationTimers[slotIdx] = nil
          changed                             = true
        else
          self.bassDeactivationTimers[slotIdx] = tB
        end
      end

    else
      -- INSTANT MODE (no offsets)
      if isActive ~= self.prevActive[slotIdx] then
        note.active = isActive
        changed     = true
      end
      if isBass ~= self.prevBass[slotIdx] then
        note.isBass = isBass
        changed     = true
      end
    end

    -- store for next frame’s diff-check
    self.prevActive[slotIdx] = isActive
    self.prevBass[slotIdx]   = isBass
  end

  return changed
end

return NoteSystem
