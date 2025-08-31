--- Active MIDI note state backend.
-- Listens on a TCP socket for incoming note updates from the backend thread,
-- reads a local `active_notes.lua` file, and merges both sources into a unified
-- list of active MIDI notes. Exposes lookup functions for whether a given
-- circle-of-fourths step is active or is the bass (lowest) note.
-- @module backends.note_state

local socket    = require("socket")
local constants = require("src.constants")

local notesFile = "active_notes.lua"

--- Notes from file (written by backend thread).
-- @field notesFromFile table
local notesFromFile = {}

--- Notes received from each TCP client.
-- Keys are client sockets, values are note sets.
-- @field socketNotesByClient table
local socketNotesByClient = {}

--- Merged list of active MIDI notes.
-- @field activeNotes table
local activeNotes = {}

--- Map of active circle-of-fourths steps.
-- Keys are step indices (0–11), values are boolean flags.
-- @field activeSteps table
local activeSteps = {}

--- Smallest MIDI note currently active.
-- @field minNote number
local minNote

--- Ordered pitch class list for circle-of-fourths mapping.
-- @field circleOfFourthsPC table
local circleOfFourthsPC = { 0, 5, 10, 3, 8, 1, 6, 11, 4, 9, 2, 7 }

--- Reverse map from pitch class to fourths index.
-- @field fourthIndex table
local fourthIndex = {}
for i, pc in ipairs(circleOfFourthsPC) do
  fourthIndex[pc] = i - 1
end

--- Reloads notes from `active_notes.lua` if available.
-- @function tryReloadNotes
-- @return boolean success
local function tryReloadNotes()
  local ok, newList = pcall(dofile, notesFile)
  if ok and type(newList) == "table" then
    notesFromFile = newList
    return true
  end
  return false
end

--- Rebuilds merged state from file and socket sources.
-- Updates `activeNotes`, `activeSteps`, and `minNote`.
-- @function rebuildState
local function rebuildState()
  local seen = {}
  activeNotes = {}
  minNote = nil

  for _, note in ipairs(notesFromFile) do
    if not seen[note] then
      table.insert(activeNotes, note)
      seen[note] = true
    end
  end

  for _, notes in pairs(socketNotesByClient) do
    for note in pairs(notes) do
      if not seen[note] then
        table.insert(activeNotes, note)
        seen[note] = true
      end
    end
  end

  activeSteps = {}
  for _, note in ipairs(activeNotes) do
    if not minNote or note < minNote then
      minNote = note
    end
    local pc = note % 12
    local step0 = fourthIndex[pc]
    if step0 then
      activeSteps[step0] = true
    end
  end
end

--- Starts TCP listener and returns polling function.
-- @function startServer
-- @return function poll
local function startServer()
  local server = assert(socket.bind(constants.noteStateHost, constants.noteStatePort))
  server:settimeout(0)

  local clients = {}

  local function poll()
    local newClient = server:accept()
    if newClient then
      newClient:settimeout(0)
      table.insert(clients, newClient)
    end

    for i = #clients, 1, -1 do
      local c = clients[i]
      local line, err = c:receive("*l")
      if line then
        print("Received line from TCP client:", line)
        local newNotes = {}
        for token in line:gmatch("%d+") do
          local note = tonumber(token)
          if note then
            newNotes[note] = true
          end
        end
        socketNotesByClient[c] = next(newNotes) and newNotes or nil
      elseif err == "closed" then
        socketNotesByClient[c] = nil
        table.remove(clients, i)
      end
    end
  end

  return poll
end

local pollServer = startServer()

tryReloadNotes()
rebuildState()

local M = {}

--- Polls TCP socket and reloads file-based notes.
-- Should be called once per frame.
-- @function M.poll
function M.poll()
  tryReloadNotes()
  pollServer()
  rebuildState()
end

--- Returns merged list of active MIDI notes.
-- @function M.getActiveNotes
-- @return table
function M.getActiveNotes()
  return activeNotes
end

--- Checks if a given circle-of-fourths step is active.
-- @function M.isNoteActive
-- @param stepIndex number Step index (1–12)
-- @return boolean
function M.isNoteActive(stepIndex)
  local step0 = (stepIndex - 1) % 12
  return activeSteps[step0] == true
end

--- Checks if a given step is the bass (lowest) active note.
-- @function M.isNoteBass
-- @param stepIndex number Step index (1–12)
-- @return boolean
function M.isNoteBass(stepIndex)
  local step0 = (stepIndex - 1) % 12
  if not activeSteps[step0] then return false end
  local bassPC = minNote % 12
  local bassStep = fourthIndex[bassPC]
  return step0 == bassStep
end

return M
