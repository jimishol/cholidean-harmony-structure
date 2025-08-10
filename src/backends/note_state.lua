--- Active MIDI note state backend.
-- Reads a user‐maintained `active_notes.lua` file, caches its list of MIDI notes,
-- and exposes lookup functions for whether a given circle‐of‐fourths step is active
-- or is the bass (lowest) note.
--
-- @module backends.note_state
--
-- @field notesFile      string   Path to the active‐notes file (always `"active_notes.lua"`).
-- @field activeNotes    int[]    Latest list of raw MIDI notes loaded from `notesFile`.
-- @field activeSteps    boolean[] Map of circle‐of‐fourths step (0–11) → active flag.
-- @field minNote        int      Smallest MIDI note number seen in `activeNotes`.
-- @field circleOfFourthsPC int[] Map of pitch class (0–11) → circle‐of‐fourths step0 (0–11).
-- @field fourthIndex    int[]    Reverse mapping of `circleOfFourthsPC` for fast lookup.
--
-- @usage
-- local note_state = require("backends.note_state")
-- local raw = note_state.getActiveNotes()
-- local isActive = note_state.isNoteActive(5)
-- local isBass   = note_state.isNoteBass(5)
--

-- Path to the module that holds your active‐notes list
local notesFile = "active_notes.lua"

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

--- Attempt to reload the active notes list from file.
-- Executes `active_notes.lua` and expects it to return a table of integers.
-- On failure (file missing, syntax error, or bad return), leaves `activeNotes` untouched.
-- @local
-- @treturn boolean True if the file was loaded successfully.
local function tryReloadNotes()
  local f = io.open(notesFile)
  if not f then return false end
  f:close()

  local ok, newList = pcall(dofile, notesFile)
  if ok and type(newList) == "table" then
    activeNotes = newList
    return true
  end
  return false
end

--- Rebuild `activeSteps` and `minNote` when `active_notes.lua` changes.
-- Clears the old maps, finds the smallest MIDI note, converts each note’s
-- pitch class to a circle‐of‐fourths index, and marks that step active.
-- @local
local function rebuildState()
  if not tryReloadNotes() then
    return
  end

  -- reset
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

-- initialize on module load
rebuildState()

local M = {}

--- Returns the raw list of active MIDI notes.
-- Re‐reads the file if it’s been modified.
-- @treturn int[] list of MIDI note numbers
function M.getActiveNotes()
  rebuildState()
  return activeNotes
end

--- Check if a given circle‐of‐fourths step is active.
-- @tparam int stepIndex 1–12 (will be converted internally to 0–11)
-- @treturn boolean true if that step is set in `activeSteps`
function M.isNoteActive(stepIndex)
  rebuildState()
  local step0 = (stepIndex - 1) % 12
  return activeSteps[step0] == true
end

--- Check if a given step is the bass (lowest) active note.
-- Compares against the circle‐of‐fourths index of `minNote`.
-- @tparam int stepIndex 1–12 (converted internally to 0–11)
-- @treturn boolean true if that step equals the bass step
function M.isNoteBass(stepIndex)
  rebuildState()
  local step0 = (stepIndex - 1) % 12
  if not activeSteps[step0] then return false end

  local bassPC   = minNote % 12
  local bassStep = fourthIndex[bassPC]
  return step0 == bassStep
end

return M
