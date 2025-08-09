--src/backends/fluidsynth/midi_controls.lua
local socket = require("socket")

local function send_command(message, host, port)
  local external_host = host
  local shellPort     = port

  print(string.format(
    "[midi_controls] Sending `%s` to %s:%d",
    message, external_host, shellPort
  ))

  local tcp, err = socket.tcp()
  assert(tcp, "Failed to create TCP socket: "..tostring(err))
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

function M.togglePlayback(host, port)
  if     isPlaying then send_command("player_stop", host, port)
  else               send_command("player_cont", host, port)
  end

  isPlaying = not isPlaying
  print("[midi_controls] isPlaying =", isPlaying)
end

function  M.beginSong(host, port)
  send_command("reset", host, port)
  send_command("player_start", host, port)
  print("[midi_controls] start current song")
end

function  M.nextSong(host, port)
  send_command("reset", host, port)
  send_command("player_next", host, port)
  print("[midi_controls] move to next song")
end

M.send_message = send_command

return M
