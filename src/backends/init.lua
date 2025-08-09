-- src/backends/init.lua
local M = {}
M.thread = nil

local function loadModule(candidate, name)
  local ok, mod = pcall(require, ("src.backends.%s.%s"):format(candidate, name))
  return (ok and mod) or require("src.backends.null." .. name)
end

--- Configure which backend to use (must be called once at startup)
-- @param backendName string
function M.setup(backendName)
  local candidate = (backendName or "") ~= "" and backendName or "null"
  local messages  = {}

  -- Unknown backend → fall back to null
  if not love.filesystem.getInfo("src/backends/" .. candidate, "directory") then
    table.insert(messages,
      ("⚠️ Unknown backend '%s', falling back to null"):format(backendName))
    candidate = "null"
  end

  -- Windows-only check for winpty
  if love.system.getOS() == "Windows" then
    local test   = io.popen("where winpty")
    local result = test:read("*a")
    test:close()
    if result == "" then
      table.insert(messages,
        "⚠️ winPTY not found. Real-time MIDI tracking will not work.")
    end
  end

  if #messages > 0 then
    M.fallbackMessage = table.concat(messages, "\n")
  end

  M.name        = candidate
  M.controls    = loadModule(candidate, "backend_controls")
  M.commandMenu = loadModule(candidate, "command_menu")
  M.thread      = nil  -- placeholder for our thread handle
  return M
end

--- Start (or restart) the backend’s active-notes thread
function M.start()

  local path = ("src/backends/%s/track_active_notes_thread.lua")
               :format(M.name)

  local th = love.thread.newThread(path)
  th:start()
  M.thread = th
end

return M
