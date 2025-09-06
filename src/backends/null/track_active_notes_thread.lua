--- Null backend stub for the active‐notes tracking thread (Channel + file pass-through).
-- Clears `active_notes.lua` at startup, then reads it from disk and pushes its contents
-- into the `"active_notes"` channel so `note_state.lua` can still work in channel mode.
-- This backend is used when no real MIDI backend is active.
-- @module src.backends.null.track_active_notes_thread

--- Channel on which a “quit” signal is sent by the main thread.
-- @local
local quit_channel    = love.thread.getChannel("quit")

--- Incoming backend identifier channel (cleared and ignored).
-- @local
local backend_channel = love.thread.getChannel("backend")

--- Incoming midiPort channel (cleared and ignored).
-- @local
local midi_port_channel = love.thread.getChannel("midiPortChannel")

--- Incoming shellPort channel (cleared and ignored).
-- @local
local port_channel    = love.thread.getChannel("shellPort")

--- Incoming shellHost channel (cleared and ignored).
-- @local
local host_channel    = love.thread.getChannel("shellHost")

--- Incoming soundfont channel (cleared and ignored).
-- @local
local font_channel    = love.thread.getChannel("soundfont")

--- Incoming songs list channel (cleared and ignored).
-- @local
local songs_channel   = love.thread.getChannel("songs")

--- Channel for publishing active notes to the main thread.
-- @local
local notesChannel    = love.thread.getChannel("active_notes")

-- clear any startup chatter so real backends aren’t confused
backend_channel:pop()
midi_port_channel:pop()
port_channel:pop()
host_channel:pop()
font_channel:pop()
songs_channel:pop()

--- Love timer module for sleeping in the idle loop.
-- @local
local timer = require("love.timer")

--- Path to the file we want to pass through.
-- @local
local notesFile = "active_notes.lua"

--- Clear the file at startup so we don't start with stale notes.
-- Writes an empty table to `active_notes.lua`.
-- @local
local function clear_notes_file()
    local f = io.open(notesFile, "w")
    if f then
        f:write("-- Auto‐generated active MIDI notes\nreturn {}\n")
        f:close()
    end
end

--- Attempt to read `active_notes.lua` and push its contents to the channel.
-- If the file is missing or invalid, pushes an empty list instead.
-- @local
local function publish_from_file()
    local ok, data = pcall(dofile, notesFile)
    if ok and type(data) == "table" then
        notesChannel:clear()
        notesChannel:push(data)
    else
        -- If file missing or invalid, push empty list
        notesChannel:clear()
        notesChannel:push({})
    end
end

-- Clear file and publish empty list immediately
clear_notes_file()
publish_from_file()

-- Idle loop: refresh from file until quit
while true do
    if quit_channel:peek() == "quit" then
        break
    end
    publish_from_file()
    timer.sleep(0.05) -- refresh every 50ms
end
