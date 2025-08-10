--- Manages a 12-note system, syncing MIDI‐driven note activation to joint visuals.
-- Supports circular shifts, and both “instant” and “offset” activation modes.
-- @module src.systems.note_system

local constants = require("src.constants")
local backend = constants.backend or "fluidsynth"

-- select the appropriate note‐state backend
local NoteState = require("src.backends.note_state")

--- Single‐note abstraction, tracking its slot, name, visual joint, and state.
-- @type Note
-- @field index     number   Slot index 1–12 on the circle of fourths
-- @field name      string   Note name (e.g. "C", "F#", etc.)
-- @field joint     table    The mesh object representing this joint in the scene
-- @field active    boolean  Whether the note is currently active
-- @field isBass    boolean  Whether the note is currently the bass (lowest) note
-- @field midiProps table    Placeholder for future MIDI properties
local Note = {}
Note.__index = Note

--- Construct a new Note object.
-- @tparam number idx     Slot index 1–12
-- @tparam string name    Note name
-- @tparam table jointObj Mesh object for this joint
-- @treturn Note
function Note:new(idx, name, jointObj)
  return setmetatable({
    index     = idx,
    name      = name,
    joint     = jointObj,
    active    = false,
    isBass    = false,
    midiProps = {},
  }, Note)
end

--- The main note system, managing 12 Note instances and their state.
-- @type NoteSystem
-- @field noteMode              string   "instant" or "offset"
-- @field offsetDuration        number   Delay in seconds for note‐off in offset mode
-- @field bassOffsetDuration    number   Delay in seconds for bass note‐off in offset mode

local NoteSystem = {}
NoteSystem.__index = NoteSystem

-- default mode
NoteSystem.noteMode = constants.defaultNoteMode

--- Toggle between "instant" and "offset" note modes.
-- @treturn nil
function NoteSystem:toggleNoteMode()
  if self.noteMode == "instant" then
    self.noteMode = "offset"
  else
    self.noteMode = "instant"
  end
end

--- Create a new NoteSystem bound to a scene.
-- Initializes 12 Note objects and their previous‐state tables.
-- @tparam table scene  Scene containing `scene.joints`
-- @treturn NoteSystem
function NoteSystem:new(scene)
  local instance = setmetatable({
    scene                  = scene,
    notes                  = {},  -- Note[]
    prevActive             = {},  -- boolean[]
    prevBass               = {},  -- boolean[]
    deactivationTimers     = {},  -- number[]
    bassDeactivationTimers = {},  -- number[]
    offsetDuration         = constants.offsetDuration or 0.2,
    bassOffsetDuration     = constants.bassOffsetDuration or 0.1,
  }, NoteSystem)

  -- instantiate Note objects and defaults
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

--- Shift all note slots by a given offset.
-- Positive values rotate slots right; negative rotate left.
-- Rebinds each Note to the correct joint object afterward.
-- @tparam number offset  Number of slots to shift
-- @treturn nil
function NoteSystem:shift(offset)
  local n = #self.notes
  local tmp = {}

  for i, note in ipairs(self.notes) do
    local j = ((i - 1 + offset) % n) + 1
    tmp[j] = note
  end
  self.notes = tmp

  -- rebind joints after shift
  for i, note in ipairs(self.notes) do
    local jointID = string.format("joint_%02d", i-1)
    for _, obj in ipairs(self.scene.joints) do
      if obj.id == jointID then
        note.joint = obj
        break
      end
    end
  end
end

--- Update note and bass states based on MIDI input.
-- In “offset” mode, uses timers to delay deactivation.
-- In “instant” mode, applies state changes immediately.
-- @tparam number dt  Delta time in seconds since last frame
-- @treturn boolean True if any note or bass state changed
function NoteSystem:update(dt)
  local changed   = false
  local useOffset = (self.noteMode == "offset")

  for slotIdx, note in ipairs(self.notes) do
    local isActive = NoteState.isNoteActive(note.index)
    local isBass   = NoteState.isNoteBass(note.index)

    if useOffset then
      -- handle activation with offset
      if     isActive and not self.prevActive[slotIdx] then
        note.active = true
        self.deactivationTimers[slotIdx] = nil
        changed = true
      elseif not isActive and self.prevActive[slotIdx] then
        self.deactivationTimers[slotIdx] = self.offsetDuration
      end

      local tA = self.deactivationTimers[slotIdx]
      if tA then
        tA = tA - dt
        if tA <= 0 then
          note.active = false
          self.deactivationTimers[slotIdx] = nil
          changed = true
        else
          self.deactivationTimers[slotIdx] = tA
        end
      end

      -- handle bass with offset
      if     isBass and not self.prevBass[slotIdx] then
        note.isBass = true
        self.bassDeactivationTimers[slotIdx] = nil
        changed = true
      elseif not isBass and self.prevBass[slotIdx] then
        self.bassDeactivationTimers[slotIdx] = self.bassOffsetDuration
      end

      local tB = self.bassDeactivationTimers[slotIdx]
      if tB then
        tB = tB - dt
        if tB <= 0 then
          note.isBass = false
          self.bassDeactivationTimers[slotIdx] = nil
          changed = true
        else
          self.bassDeactivationTimers[slotIdx] = tB
        end
      end

    else
      -- instant mode: apply immediately
      if isActive ~= self.prevActive[slotIdx] then
        note.active = isActive
        changed = true
      end
      if isBass ~= self.prevBass[slotIdx] then
        note.isBass = isBass
        changed = true
      end
    end

    -- record for next update
    self.prevActive[slotIdx] = isActive
    self.prevBass[slotIdx]   = isBass
  end

  return changed
end

return NoteSystem
