-- src/backends/null/backend_controls.lua

local M = {}

-- swallow any “send_message” calls
function M.send_message(topic, host, port)
  -- manual mode: ignore
end

-- no-op playback controls
function M.togglePlayback(host, port) end
function M.beginSong(host, port)    end
function M.nextSong(host, port)     end

return M
