-- Active MIDI note state backend (Channel version)
-- Reads the latest active notes snapshot from a shared thread channel ("active_notes"),
-- caches its list of MIDI notes, and exposes lookup functions.

local notesChannel = love.thread.getChannel("active_notes")

local activeNotes = {}
local activeSteps = {}
local minNote

local circleOfFourthsPC = { 0, 5, 10, 3, 8, 1, 6, 11, 4, 9, 2, 7 }
local fourthIndex = {}
for i, pc in ipairs(circleOfFourthsPC) do
  fourthIndex[pc] = i - 1
end

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

reloadFromChannel()

local M = {}

function M.getActiveNotes()
  reloadFromChannel()
  return activeNotes
end

function M.isNoteActive(stepIndex)
  reloadFromChannel()
  local step0 = (stepIndex - 1) % 12
  return activeSteps[step0] == true
end

function M.isNoteBass(stepIndex)
  reloadFromChannel()
  local step0 = (stepIndex - 1) % 12
  if not activeSteps[step0] then return false end
  local bassPC   = minNote % 12
  local bassStep = fourthIndex[bassPC]
  return step0 == bassStep
end

return M
