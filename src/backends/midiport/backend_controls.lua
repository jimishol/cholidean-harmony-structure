--- Provides TCP-based control interface for the midiport backend.
-- Implements non-blocking connect/reconnect and line-oriented command framing.
-- @module src.backends.midiport.backend_controls

local socket = require("socket")

--- BackendControls class.
-- @type BackendControls
local M      = {}
M.__index    = M

--- Constructor.
-- Called by scene.lua as:
--     backends.controls = require(...).new()
-- @treturn BackendControls
function M.new()
  return setmetatable({}, M)
end

-- Internal state for a persistent TCP connection
local tcp               = nil
local last_connect_try  = 0
local reconnect_interval= 1.0  -- seconds
local getTime           = socket.gettime

--- Ensure there is an open nonblocking TCP socket to <host,port>.
-- Throttles reconnect attempts to once per `reconnect_interval`.
-- @local
-- @tparam string host  Remote host address
-- @tparam number port  Remote TCP port
-- @treturn boolean     True if `tcp` is ready, false otherwise
local function ensure_connection(host, port)
  local now = getTime()
  if tcp then return true end
  if now - last_connect_try < reconnect_interval then
    return false
  end
  last_connect_try = now

  local s, err = socket.tcp()
  if not s then
    print("[midiport] socket.tcp failed:", err)
    return false
  end

  s:settimeout(1)
  local ok, conn_err = s:connect(host, port)
  if not ok then
    print("[midiport] connect failed:", conn_err)
    s:close()
    return false
  end

  s:settimeout(0)  -- nonblocking from here on
  tcp = s
  print(string.format("[midiport] control TCP connected to %s:%d", host, port))
  return true
end

--- Send a single line (with CRLF) to the MIDI-port server.
-- Implements the exact API that `main.lua` expects.
-- @tparam string message  Raw command (e.g. "gain 0.8")
-- @tparam string host     TCP host (e.g. "localhost")
-- @tparam number port     TCP port (e.g. 9800)
-- @treturn boolean        True on success, false on failure
function M.send_message(message, host, port)
  if not ensure_connection(host, port) then
    return false
  end

  local ok, err = tcp:send(message .. "\r\n")
  if not ok then
    print("[midiport] send failed:", err)
    tcp:close()
    tcp = nil
    return false
  end
  return true
end

--- Close the control TCP socket, if open.
-- @treturn boolean  Always returns true
function M.disconnect()
  if tcp then
    tcp:close()
    tcp = nil
    print("[midiport] control TCP disconnected")
  end
  return true
end

return M
