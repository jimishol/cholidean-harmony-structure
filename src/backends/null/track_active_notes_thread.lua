--- Null backend stub for the active‐notes tracking thread (Channel + file pass-through).
-- Clears active_notes.lua at startup, then reads it from disk and pushes its contents
-- into the "active_notes" channel so note_state.lua can still work in channel mode.

local quit_channel    = love.thread.getChannel("quit")
local backend_channel = love.thread.getChannel("backend")
local port_channel    = love.thread.getChannel("shellPort")
local host_channel    = love.thread.getChannel("shellHost")
local font_channel    = love.thread.getChannel("soundfont")
local songs_channel   = love.thread.getChannel("songs")

-- Channel for active notes
local notesChannel    = love.thread.getChannel("active_notes")

-- clear any startup chatter
backend_channel:pop()
port_channel:pop()
host_channel:pop()
font_channel:pop()
songs_channel:pop()

local timer = require("love.timer")

-- Path to the file we want to pass through
local notesFile = "active_notes.lua"

-- Clear the file at startup so we don't start with stale notes
local function clear_notes_file()
    local f = io.open(notesFile, "w")
    if f then
        f:write("-- Auto‐generated active MIDI notes\nreturn {}\n")
        f:close()
    end
end

-- Function to try reading the file and pushing it to the channel
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
