-- src/midi/note_state.lua

-- Path to the module that holds your active-notes list
local notesFile = "active_notes.lua"

-- Try to require LuaFileSystem for fast mod-time checks
local hasLFS, lfs = pcall(require, "lfs")

-- Cached state
local activeNotes    = {}    -- latest notes list
local lastModTime    = 0     -- last known write time
local activeSteps    = {}    -- step0 → boolean
local minNote        = nil   -- smallest MIDI note

-- Circle-of-fourths reverse map (pc 0–11 → step0 0–11)
local circleOfFourthsPC = {0,5,10,3,8,1,6,11,4,9,2,7}
local fourthIndex = {}
for i, pc in ipairs(circleOfFourthsPC) do
  fourthIndex[pc] = i - 1
end

-- Safely reload `activeNotes` only when the file’s changed on disk
local function tryReloadNotes()
  if hasLFS then
    local attr = lfs.attributes(notesFile, "modification")
    if not attr then
      -- file temporarily missing; skip reload
      return false
    end
    if attr > lastModTime then
      local ok, newList = pcall(dofile, notesFile)
      if ok and type(newList) == "table" then
        activeNotes = newList
        lastModTime = attr
        return true
      end
    end
    return false
  else
    -- fallback: detect presence, then safe `dofile`
    local f = io.open(notesFile)
    if not f then
      return false
    end
    f:close()
    local ok, newList = pcall(dofile, notesFile)
    if ok and type(newList) == "table" then
      activeNotes = newList
      return true
    end
    return false
  end
end

-- Rebuild `activeSteps` and `minNote` when notes actually change
local function rebuildState()
  local changed = tryReloadNotes()
  if not changed then
    -- no update needed
    return
  end

  -- clear previous state
  for k in pairs(activeSteps) do
    activeSteps[k] = nil
  end

  minNote = nil

  -- rebuild from activeNotes
  for _, note in ipairs(activeNotes) do
    -- track minimum
    if (not minNote) or note < minNote then
      minNote = note
    end

    -- map into circle-of-fourths step
    local pc     = note % 12
    local step0  = fourthIndex[pc]
    if step0 then
      activeSteps[step0] = true
    end
  end
end

-- Initialize on load
rebuildState()

local M = {}

-- Raw list
function M.getActiveNotes()
  rebuildState()
  return activeNotes
end

-- 1–12 → 0–11 lookup, constant-time
function M.isNoteActive(stepIndex)
  rebuildState()
  local step0 = (stepIndex - 1) % 12
  return activeSteps[step0] == true
end

function M.isNoteBass(stepIndex)
  rebuildState()
  local step0 = (stepIndex - 1) % 12

  -- must be active
  if not activeSteps[step0] then
    return false
  end

  -- convert minNote (raw MIDI) to its circle-of-fourths slot
  local bassPC   = minNote % 12
  local bassStep = fourthIndex[bassPC]

  return step0 == bassStep
end

return M
