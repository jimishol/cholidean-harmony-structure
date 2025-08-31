--- Null backend stub for the active‐notes tracking thread.
-- Clears any initial channel data so real backends aren’t confused,
-- then idles until the main thread signals it to quit.
-- @module src.backends.null.track_active_notes_thread

--- Names of all channels used by the backend thread.
-- @local channel_names string[]
local channel_names = {
  "quit",
  "backend",
  "shellPort",
  "shellHost",
  "soundfont",
  "songs",
}

--- Mapping from channel name to Love2D channel object.
-- @local channels table<string, love.thread.Channel>
local channels = {}
for _, name in ipairs(channel_names) do
  channels[name] = love.thread.getChannel(name)
end

-- Clear any startup chatter so real backends aren’t confused.
-- We skip the "quit" channel here, since we want to block on it explicitly.
for name, ch in pairs(channels) do
  if name ~= "quit" then
    ch:pop()
  end
end

--- Love2D timer module for yielding within the thread.
-- @local timer love.timer
local timer = require("love.timer")

--- Block until the main thread sends a shutdown signal.
-- Accepts either "quit" or "stop" as valid exit commands.
-- Consumes that message and then allows the thread to terminate.
-- @return string the shutdown signal received
local signal = channels.quit:demand()

-- If any other message got sent, we still exit cleanly.
-- Thread ends as soon as this script finishes.
