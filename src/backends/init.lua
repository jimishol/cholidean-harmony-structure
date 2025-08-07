-- src/backends/init.lua
local M = {}

local function loadModule(candidate, name)
  local ok, mod = pcall(require, ("src.backends.%s.%s"):format(candidate, name))
  return (ok and mod) or require("src.backends.null." .. name)
end

function M.setup(backendName)
  local candidate = (backendName or "") ~= "" and backendName or "null"

  -- <— INSERT: capture fallback message
  if not love.filesystem.getInfo("src/backends/" .. candidate, "directory") then
    M.fallbackMessage = ("⚠️ Unknown backend '%s', falling back to null"):format(backendName)
    candidate = "null"
  end

  M.name        = candidate
  M.controls    = loadModule(candidate, "backend_controls")
  M.commandMenu = loadModule(candidate, "command_menu")

  return M
end

function M.start()
  local thread = love.thread.newThread(("src/backends/%s/track_active_notes_thread.lua"):format(M.name))
  thread:start()
end

return M
