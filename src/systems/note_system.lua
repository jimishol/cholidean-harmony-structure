--- Manages a 12-note system, syncing MIDI‐driven note activation to joint visuals.
-- Supports circular shifts, and both “instant” and “offset” activation modes.
-- Also computes and caches fundamental root information from active MIDI notes.
-- @module src.systems.note_system
--
local constants   = require("src.constants")
local backend     = constants.backend or "fluidsynth"

-- select the appropriate note‐state backend
local NoteState   = require("src.backends.note_state")
-- fundamental root finder
local Fundamental = require("src.systems.fountamental")

--- Single‐note abstraction, tracking its slot, name, visual joint, and state.
-- @type Note
-- @field index      number   Slot index 1–12 on the circle of fourths
-- @field name       string   Note name (e.g. "C", "F#", etc.)
-- @field joint      table    The mesh object representing this joint in the scene
-- @field active     boolean  Whether the note is currently active
-- @field isBass     boolean  Whether the note is currently the bass (lowest) note
-- @field isTopVoice boolean  Whether the note is currently the top voice (highest) note (respects general offset)
-- @field midiProps  table    Placeholder for future MIDI properties
local Note = {}
Note.__index = Note

--- Construct a new Note object.
-- @function Note:new
-- @tparam number idx Slot index 1–12
-- @tparam string name Note name
-- @tparam table jointObj Mesh object for this joint
-- @treturn Note
function Note:new(idx, name, jointObj)
  return setmetatable({
    index      = idx,
    name       = name,
    joint      = jointObj,
    active     = false,
    isBass     = false,
    isTopVoice = false,
    midiProps  = {},
  }, Note)
end

--- The main note system, managing 12 Note instances and their state.
-- @type NoteSystem
local NoteSystem = {}
NoteSystem.__index = NoteSystem

-- default mode
NoteSystem.noteMode = constants.defaultNoteMode

--- Toggle between "instant" and "offset" note modes.
-- @function NoteSystem:toggleNoteMode
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
-- @function NoteSystem:new
-- @tparam table scene Scene containing `scene.joints`
-- @treturn NoteSystem
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
    fundamentalInfo        = { hasFundamental=false, fundamental=nil, y=1 },
  }, NoteSystem)

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
-- @function NoteSystem:shift
-- @tparam number offset Number of slots to shift
-- @treturn nil
function NoteSystem:shift(offset)
  local n = #self.notes
  local tmp = {}
  for i, note in ipairs(self.notes) do
    local j = ((i - 1 + offset) % n) + 1
    tmp[j] = note
  end
  self.notes = tmp

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

--- Update note, bass, and topVoice states based on MIDI input.
-- In “offset” mode, uses timers to delay deactivation for notes.
-- Bass uses its own offset duration. TopVoice respects the general offset (no separate timer).
-- Also computes fundamental info from current active notes.
-- @function NoteSystem:update
-- @tparam number dt Delta time in seconds since last frame
-- @treturn boolean True if any note, bass, or topVoice state changed
function NoteSystem:update(dt)
  local changed   = false
  local useOffset = (self.noteMode == "offset")

  for slotIdx, note in ipairs(self.notes) do
    local isActive   = NoteState.isNoteActive(note.index)
    local isBass     = NoteState.isNoteBass(note.index)
    local isTopVoice = false
    if constants.topVoice then
      isTopVoice = NoteState.isNoteHighest and NoteState.isNoteHighest(note.index) or false
    end

    if useOffset then
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

      -- topVoice respects general offset: only active notes (including offset-linger) can be topVoice
      local newTop = note.active and isTopVoice or false
      if note.isTopVoice ~= newTop then
        note.isTopVoice = newTop
        changed = true
      end

    else
      if isActive ~= self.prevActive[slotIdx] then
        note.active = isActive
        changed = true
      end
      if isBass ~= self.prevBass[slotIdx] then
        note.isBass = isBass
        changed = true
      end
      -- TopVoice only if the note is currently active
      local newTop = isActive and isTopVoice or false
      if note.isTopVoice ~= newTop then
        note.isTopVoice = newTop
        changed = true
      end
    end

    self.prevActive[slotIdx] = isActive
    self.prevBass[slotIdx]   = isBass
  end

  local raw = NoteState.getActiveNotes and NoteState.getActiveNotes() or {}
  local activeMidiNotes = {}
  for k,v in pairs(raw) do
    if type(k) == "number" and v == true then
      activeMidiNotes[#activeMidiNotes+1] = k
    elseif type(v) == "number" then
      activeMidiNotes[#activeMidiNotes+1] = v
    end
  end
  table.sort(activeMidiNotes)

  local fInfo = Fundamental.G_noez_from_midi(activeMidiNotes)
  self.fundamentalInfo = {
    hasFundamental = fInfo.has_fundamental,
    fundamental    = fInfo.fundamental,
    y              = fInfo.y,
  }

  return changed
end

--- Accessor for fundamental info.
-- @function NoteSystem:getFundamentalInfo
-- @treturn table {hasFundamental, fundamental, y}
function NoteSystem:getFundamentalInfo()
  return self.fundamentalInfo
end

return NoteSystem
