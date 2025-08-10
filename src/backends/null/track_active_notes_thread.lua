--- Null backend stub for the active‐notes tracking thread.
-- Clears any initial channel data so real backends aren’t confused,
-- then idles until the main thread signals it to quit.
-- @module src.backends.null.track_active_notes_thread

--- Channel on which a “quit” signal is sent by the main thread.
-- @local quit_channel love.thread.Channel
local quit_channel    = love.thread.getChannel("quit")

--- Incoming backend identifier channel (cleared and ignored).
-- @local backend_channel love.thread.Channel
local backend_channel = love.thread.getChannel("backend")

--- Incoming shellPort channel (cleared and ignored).
-- @local port_channel love.thread.Channel
local port_channel    = love.thread.getChannel("shellPort")

--- Incoming shellHost channel (cleared and ignored).
-- @local host_channel love.thread.Channel
local host_channel    = love.thread.getChannel("shellHost")

--- Incoming soundfont channel (cleared and ignored).
-- @local font_channel love.thread.Channel
local font_channel    = love.thread.getChannel("soundfont")

--- Incoming songs list channel (cleared and ignored).
-- @local songs_channel love.thread.Channel
local songs_channel   = love.thread.getChannel("songs")

-- clear any startup chatter so real backends aren’t confused
backend_channel:pop()
port_channel:pop()
host_channel:pop()
font_channel:pop()
songs_channel:pop()

--- Love timer module for sleeping in the idle loop.
-- @local timer love.timer
local timer = require("love.timer")

-- Idle loop: sleeps until the main thread pushes “quit” onto quit_channel.
while true do
  if quit_channel:peek() == "quit" then
    break
  end
  timer.sleep(1)
end
