--- Fluidsynth backend controls for MIDI track management.
-- Provides functions to start, stop, and advance playback
-- by sending TCP messages to a Fluidsynth-compatible server.
-- @module src.backends.fluidsynth.backend_controls

local socket  = require("socket")
local control = love.thread.getChannel("track_control")

--- Send a raw command string over TCP.
-- Connects to the specified host and port, sends the message,
-- and then closes the connection.
-- @local
-- @tparam string message  Command to send (newline will be appended)
-- @tparam string host     Remote host address
-- @tparam number port     Remote TCP port
-- @raise If TCP socket creation fails
local function send_command(message, host, port)
  local external_host = host
  local shellPort     = port

  print(string.format(
    "[midi_controls] Sending `%s` to %s:%d",
    message, external_host, shellPort
  ))

  local tcp, err = socket.tcp()
  assert(tcp, "Failed to create TCP socket: " .. tostring(err))
  tcp:settimeout(0.5)

  local ok, conn_err = tcp:connect(external_host, shellPort)
  if not ok then
    print("[midi_controls] Connection failed:", conn_err)
    return
  end

  tcp:send(message .. "\n")
  tcp:close()
end

local M = {}
local isPlaying = true

--- Toggle playback state.
-- If currently playing, sends "player_stop"; otherwise sends "player_cont".
-- Pushes a "clear" control message prior to sending.
-- @tparam string host  Remote host address
-- @tparam number port  Remote TCP port
-- @usage
--   backend_controls.togglePlayback("127.0.0.1", 5555)
function M.togglePlayback(host, port)
  if isPlaying then
    control:push("clear")
    send_command("player_stop", host, port)
  else
    control:push("clear")
    send_command("player_cont", host, port)
  end

  isPlaying = not isPlaying
  print("[midi_controls] isPlaying =", isPlaying)
end

--- Start playback of the current song.
-- Sends "player_start" after clearing previous controls.
-- @tparam string host  Remote host address
-- @tparam number port  Remote TCP port
-- @usage
--   backend_controls.beginSong("127.0.0.1", 5555)
function M.beginSong(host, port)
  control:push("clear")
  send_command("player_start", host, port)
  print("[midi_controls] start current song")
end

--- Advance to the next song in the playlist.
-- Sends "player_next" after clearing previous controls.
-- @tparam string host  Remote host address
-- @tparam number port  Remote TCP port
-- @usage
--   backend_controls.nextSong("127.0.0.1", 5555)
function M.nextSong(host, port)
  control:push("clear")
  send_command("player_next", host, port)
  print("[midi_controls] move to next song")
end

--- Alias for send_command.
-- Allows sending arbitrary messages directly.
-- @tparam string message  Command to send
-- @tparam string host     Remote host address
-- @tparam number port     Remote TCP port
M.send_message = send_command

return M
