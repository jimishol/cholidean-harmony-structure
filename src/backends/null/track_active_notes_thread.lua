-- src/backends/null/track_active_notes_thread.lua

-- clear any startup chatter so real backends aren’t confused
local quit_channel    = love.thread.getChannel("quit")
local backend_channel = love.thread.getChannel("backend")
local port_channel    = love.thread.getChannel("shellPort")
local font_channel    = love.thread.getChannel("soundfont")
local songs_channel   = love.thread.getChannel("songs")

backend_channel:pop()
port_channel:pop()
font_channel:pop()
songs_channel:pop()

-- no real processing: just idle until main tells us to quit
local timer = require("love.timer")
while true do
  if quit_channel:peek() == "quit" then
    break
  end
  timer.sleep(1)
end
