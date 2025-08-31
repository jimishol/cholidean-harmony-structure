--- Null backend stub for the active-notes tracking thread.
-- Clears any initial channel data so real backends aren’t confused,
-- then sends the contents of `active_notes.lua` over TCP to a listening server,
-- and idles until the main thread signals it to quit.
-- @module src.backends.null.track_active_notes_thread

local socket = require("socket")
local timer  = require("love.timer")

--- List of channel names used by the backend thread.
-- These are cleared at startup to avoid residual data.
-- @type table
local channel_names = {
  "quit",
  "backend",
  "shellPort",
  "shellHost",
  "soundfont",
  "songs",
  "noteStateHost",
  "noteStatePort",
}

--- Map of channel names to Love2D thread channel objects.
-- Used to communicate with the main thread.
-- @type table
local channels = {}
for _, name in ipairs(channel_names) do
  channels[name] = love.thread.getChannel(name)
end

-- Clear any startup chatter from channels except "quit".
-- Ensures the thread starts cleanly without leftover messages.
for name, ch in pairs(channels) do
  if name ~= "quit" then
    ch:pop()
  end
end

-- Get TCP host and port from channels (sent by main thread)
local host = channels.noteStateHost:peek() or "localhost"
local port = tonumber(channels.noteStatePort:peek()) or 9810

--- TCP connection to the note-state server.
-- Uses host/port passed via thread channels.
-- @type socket.tcp
local client = assert(socket.tcp())
client:settimeout(0)
client:connect(host, port)

--- Sends the contents of `active_notes.lua` to the TCP server.
-- Parses the file and sends a comma-separated list of MIDI notes.
-- @local
local function sendActiveNotes()
  local ok, notes = pcall(dofile, "active_notes.lua")
  if ok and type(notes) == "table" then
    local payload = table.concat(notes, ",")
    client:send(payload .. "\n")
  end
end

-- Send once at startup (initial state)
sendActiveNotes()

--- Waits for shutdown signal from the main thread.
-- Accepts either "quit" or "stop" as valid exit commands.
-- @return string Shutdown signal received
local function waitForShutdown()
  while true do
    local signal = channels.quit:peek()
    if signal == "quit" or signal == "stop" then
      channels.quit:pop()
      return signal
    end
    timer.sleep(0.5)
    sendActiveNotes()
  end
end

-- Block until shutdown
waitForShutdown()

-- Close TCP connection
client:close()
