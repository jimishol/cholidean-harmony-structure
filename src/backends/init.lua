-- src/backends/init.lua
local M = {}

local function loadModule(candidate, name)
  local ok, mod = pcall(require, ("src.backends.%s.%s"):format(candidate, name))
  return (ok and mod) or require("src.backends.null." .. name)
end

function M.setup(backendName)
  local candidate = (backendName or "") ~= "" and backendName or "null"

  local messages = {}

  -- 1) Check for unknown backend
  if not love.filesystem.getInfo("src/backends/" .. candidate, "directory") then
    table.insert(messages, ("⚠️ Unknown backend '%s', falling back to null"):format(backendName))
    candidate = "null"
  end

  -- 2) Check for winPTY on Windows
  if love.system.getOS() == "Windows" then
    local test = io.popen("where winpty")
    local result = test:read("*a")
    test:close()
    if result == "" then
      table.insert(messages, "⚠️ winPTY not found. Real-time MIDI tracking will not work.")
    end
  end

  -- 3) Combine messages if any
  if #messages > 0 then
    M.fallbackMessage = table.concat(messages, "\n")
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
