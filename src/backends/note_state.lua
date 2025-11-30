--- Active MIDI note state backend (Channel version)
--- Reads the latest active notes snapshot from a shared thread channel ("active_notes"),
--- caches its list of MIDI notes, and exposes lookup functions.
--- @module src.backends.note_state

--- Module table returned by this file.
--- @table note_state
--- @field getActiveNotes function Returns the raw list of active MIDI notes
--- @field isNoteActive function Check if a given circle-of-fourths step is active
--- @field isNoteBass function Check if a given step is the bass (lowest) active note
--- @field isNoteHighest function Check if a given step is the highest active pitch's step
local M = {}

local notesChannel = love.thread.getChannel("active_notes")

-- Cached raw list of active MIDI notes
local activeNotes = {}

-- Cached map of active circle‐of‐fourths steps → boolean
local activeSteps = {}

-- Cached smallest MIDI note number seen
local minNote

-- Circle‐of‐fourths reverse map (pc 0–11 → step0 0–11)
local circleOfFourthsPC = { 0, 5, 10, 3, 8, 1, 6, 11, 4, 9, 2, 7 }

-- Reverse lookup table (pc → step0)
local fourthIndex = {}
for i, pc in ipairs(circleOfFourthsPC) do
  fourthIndex[pc] = i - 1
end

-- Reload from the "active_notes" channel and rebuild activeSteps and minNote
local function reloadFromChannel()
  local newList = notesChannel:peek()
  if type(newList) == "table" then
    activeNotes = newList
  end

  for k in pairs(activeSteps) do activeSteps[k] = nil end
  minNote = nil

  for _, note in ipairs(activeNotes) do
    if not minNote or note < minNote then
      minNote = note
    end
    local pc    = note % 12
    local step0 = fourthIndex[pc]
    if step0 then
      activeSteps[step0] = true
    end
  end
end

-- Initialize state on module load
reloadFromChannel()

--- Returns the raw list of active MIDI notes.
--- Reloads the channel snapshot before returning.
--- @treturn table list of MIDI note numbers (array of integers)
function M.getActiveNotes()
  reloadFromChannel()
  return activeNotes
end

--- Check if a given circle-of-fourths step is active.
--- The function accepts a 1–12 step index and maps it to internal 0–11 step0.
--- @tparam number stepIndex Circle-of-fourths step index (1–12)
--- @treturn boolean true if the step is currently active
function M.isNoteActive(stepIndex)
  reloadFromChannel()
  local step0 = (stepIndex - 1) % 12
  return activeSteps[step0] == true
end

--- Check if a given step is the bass (lowest) active note.
--- Returns false if the step is not active or if there are no active notes.
--- @tparam number stepIndex Circle-of-fourths step index (1–12)
--- @treturn boolean true if the step corresponds to the lowest active MIDI note
function M.isNoteBass(stepIndex)
  reloadFromChannel()
  local step0 = (stepIndex - 1) % 12
  if not activeSteps[step0] then return false end
  local bassPC   = minNote % 12
  local bassStep = fourthIndex[bassPC]
  return step0 == bassStep
end

--- Return true if the given stepIndex (1–12) is the highest active pitch's step.
--- Mirrors the bass checker but for the highest MIDI note.
--- @tparam number stepIndex Circle-of-fourths step index (1–12)
--- @treturn boolean true if the step corresponds to the highest active MIDI note
function M.isNoteHighest(stepIndex)
  local active = M.getActiveNotes()
  if not active or #active == 0 then
    return false
  end

  -- Find the highest MIDI note number
  local highestNote = active[1]
  for i = 2, #active do
    if active[i] > highestNote then
      highestNote = active[i]
    end
  end

  -- Map MIDI note -> pitch class -> circle-of-fourths step
  local pc = highestNote % 12
  local highestStep = fourthIndex[pc]

  local step0 = (stepIndex - 1) % 12
  return step0 == highestStep
end

return M
