-- src/backends/init.lua

local M = {}

-- try requiring src.backends.<candidate>.<name>,
-- else fall back to src.backends.null.<name>
local function loadModule(candidate, name)
  local path = ("src.backends.%s.%s"):format(candidate, name)
  local ok, mod = pcall(require, path)
  if ok and mod then
    return mod
  end
  return require("src.backends.null." .. name)
end

-- call this once from main.lua to get all backend-specific modules
function M.setup(backendName)
  -- empty or missing folder → "null"
  local candidate = (backendName and backendName ~= "") and backendName or "null"
  if not love.filesystem.getInfo("src/backends/" .. candidate, "directory") then
    print(("⚠️  Unknown backend '%s', falling back to null"):format(tostring(backendName)))
    candidate = "null"
  end

  M.controls    = loadModule(candidate, "backend_controls")
  M.commandMenu = loadModule(candidate, "command_menu")
end

-- spawns the active_notes watcher thread (real or stub)
function M.start(backendName)
  local candidate = (backendName and backendName ~= "") and backendName or "null"
  if not love.filesystem.getInfo("src/backends/" .. candidate, "directory") then
    candidate = "null"
  end

  local thread_file = ("src/backends/%s/track_active_notes_thread.lua"):format(candidate)
  local thread      = love.thread.newThread(thread_file)
  thread:start()
end

return M
