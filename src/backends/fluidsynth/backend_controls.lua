--- Fluidsynth backend controls for MIDI track management.
-- Provides functions to start, stop, and advance playback
-- by sending TCP messages to a Fluidsynth-compatible server,
-- and a static “help” dump loaded from disk.
-- @module src.backends.fluidsynth.backend_controls

local socket  = require("socket")
local control = love.thread.getChannel("track_control")

-------------------------------------------------------------------------------
-- Static help loader
-------------------------------------------------------------------------------
local helpLines = {}
do
  local path = "src/backends/fluidsynth/fluidsynth_help.txt"
  local raw  = love.filesystem.read(path) or ""
  for line in raw:gmatch("[^\r\n]+") do
    table.insert(helpLines, line)
  end
end

local function getStaticHelp()
  return helpLines
end

-- Persistent TCP connection
local tcp
local last_connect = 0
local reconnect_interval = 1.0  -- seconds

local function ensure_connection(host, port)
  local now = love.timer.getTime()
  if tcp and tcp:send("") then
    return true
  end
  if (now - last_connect) < reconnect_interval then
    return false
  end
  last_connect = now

  if tcp then
    tcp:close()
    tcp = nil
  end

  local new_tcp, err = socket.tcp()
  if not new_tcp then
    print("[midi_controls] Failed to create TCP socket:", err)
    return false
  end
  new_tcp:settimeout(0.5)
  local ok, conn_err = new_tcp:connect(host, port)
  if not ok then
    print("[midi_controls] Connection failed:", conn_err)
    return false
  end

  tcp = new_tcp
  print(string.format("[midi_controls] Connected to %s:%d", host, port))
  return true
end

local function send_command(message, host, port)
  if not ensure_connection(host, port) then
    print("[midi_controls] Cannot send, no connection:", message)
    return
  end
  local ok, err = tcp:send(message .. "\n")
  if not ok then
    print("[midi_controls] Send failed:", err)
    tcp:close()
    tcp = nil
  else
    print(string.format("[midi_controls] Sent `%s`", message))
  end
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
local M = {}

--- Toggle playback state.
-- If currently playing, sends "player_stop"; otherwise sends "player_cont".
function M.togglePlayback(host, port)
  if M._isPlaying == nil then M._isPlaying = true end

  -- Consume flag only once on the first toggle after freeze
  if M._forceContOnNextToggle then
    M._forceContOnNextToggle = false
    send_command("player_cont", host, port)
    M._isPlaying = true
    print("[midi_controls] forced player_cont on unfreeze")
    return
  end

  local cmd = M._isPlaying and "player_stop" or "player_cont"
  send_command(cmd, host, port)
  M._isPlaying = not M._isPlaying
  print("[midi_controls] isPlaying =", M._isPlaying)
end

--- Start playback of the current song (Tab).
-- Sends "player_start" and "player_cont" to ensure playback begins
-- even if the sequencer was previously stopped or the app was frozen.
function M.beginSong(host, port)
  control:push("clear")
  send_command("player_start", host, port)
  send_command("player_cont", host, port)

  M._isPlaying = true
  M._forceContOnNextToggle = false
  print("[midi_controls] start current song")
end

--- Advance to the next song in the playlist (Internal FluidSynth skip).
-- Sends "player_next" after pushing a "clear" control message.
-- Used for Shift+Return to stop MIDI but keep process alive for live feedback.
function M.endSong(host, port)
  control:push("clear")
  send_command("player_stop", host, port)
  send_command("player_next", host, port)

  -- MIDI is now stopped; set state to false so next 'p' or 'Tab' works instantly
  M._isPlaying = false
  M._forceContOnNextToggle = false
  print("[midi_controls] move to next song (TCP stop)")
end

--- Force-kill the process to trigger the Thread to iterate to the next file.
-- Closes the TCP socket first to ensure the OS releases the port.
-- Used for Return to advance the Lua-level playlist.
function M.nextSong(host, port)
  control:push("clear")

  if tcp then
    tcp:close()
    tcp = nil
  end

  local platform = love.thread.getChannel("platform"):peek()
  local backendValue = love.thread.getChannel("backend"):peek()

  if not backendValue then
    print("[midi_controls] Error: Backend name not found in channel yet.")
    return
  end

  local proc = backendValue:match("([^/\\]+)$"):gsub("%.exe$", ""):gsub("%.%w+$", "")

  if platform == "windows" then
    os.execute(string.format('taskkill /IM %s.exe /F /T >NUL 2>&1', proc))
  else
    os.execute(string.format('pkill -9 -f "%s" > /dev/null 2>&1', proc))
  end

  -- New process starts playing automatically
  M._isPlaying = true
  M._forceContOnNextToggle = false
  print(string.format("[midi_controls] OS-killed %s and closed socket", proc))
end

--- Send an arbitrary FluidSynth command.
function M.send_message(message, host, port)
  send_command(message, host, port)
end

--- Retrieve the static help text.
function M.getHelp(host, port)
  return getStaticHelp()
end

return M
