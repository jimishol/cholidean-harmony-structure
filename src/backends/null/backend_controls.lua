--- Null backend controls (manual mode).
-- Provides no-op implementations for playback control and message sending.
-- Useful when no real backend is attached.
-- @module src.backends.null.backend_controls

local M = {}

--- Ignore any send_message calls.
-- In manual mode, messages are not sent.
-- @tparam string topic  Command topic
-- @tparam string host   Host address (ignored)
-- @tparam number port   Port number (ignored)
function M.send_message(topic, host, port)
  -- manual mode: ignore
end

--- No-op togglePlayback.
-- Does nothing in null backend.
-- @tparam string host   Host address (ignored)
-- @tparam number port   Port number (ignored)
function M.togglePlayback(host, port) end

--- No-op beginSong.
-- Does nothing in null backend.
-- @tparam string host   Host address (ignored)
-- @tparam number port   Port number (ignored)
function M.beginSong(host, port) end

--- No-op nextSong.
-- Does nothing in null backend.
-- @tparam string host   Host address (ignored)
-- @tparam number port   Port number (ignored)
function M.nextSong(host, port) end

return M
