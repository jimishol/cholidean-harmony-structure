--- Central backend loader and manager.
-- Detects available backends, issues warnings on fallback,
-- and launches the active‐notes tracking thread.
-- @module src.backends

local M = {}

--- Thread handle for the active‐notes tracker.
-- @field thread Thread or nil
M.thread = nil

--- Name of the selected backend (directory under `src/backends`).
-- @field name string

--- Controls API for the selected backend.
-- Exposes functions like `togglePlayback`, `beginSong`, etc.
-- @field controls table

--- Command‐menu API for the selected backend.
-- Provides in‐game command dispatching.
-- @field commandMenu table

--- Human‐readable warnings aggregated during setup.
-- Populated if an unknown backend is requested or winpty is missing on Windows.
-- @field fallbackMessage string or nil

--- Attempt to require a backend submodule by name, falling back to null.
-- @local
-- @tparam string candidate  Backend directory name (e.g. "fluidsynth")
-- @tparam string name       Module name to load (e.g. "backend_controls")
-- @treturn table            The required module, or the null fallback
local function loadModule(candidate, name)
  local ok, mod = pcall(require, ("src.backends.%s.%s"):format(candidate, name))
  if ok then
    return mod
  end
  -- Fallback to null backend implementation
  return require("src.backends.null." .. name)
end

--- Configure which backend to use (must be called once at startup).
-- Verifies the backend directory exists, checks for winpty on Windows,
-- and loads the corresponding `controls` and `command_menu` modules.
-- Any warnings are concatenated into `M.fallbackMessage`.
-- @tparam string backendName  Name of the desired backend (or empty to use null)
-- @treturn table              The backend manager table (`M`)
function M.setup(backendName)
  local candidate = (backendName or "") ~= "" and backendName or "null"
  local messages  = {}

  -- Unknown backend → fall back to null
  if not love.filesystem.getInfo("src/backends/" .. candidate, "directory") then
    table.insert(messages,
      ("⚠️ Unknown backend '%s', falling back to null"):format(backendName))
    candidate = "null"
  end

  -- Windows‐only check for winpty presence
  if love.system.getOS() == "Windows" then
    local test   = io.popen("where winpty")
    local result = test:read("*a")
    test:close()
    if result == "" then
      table.insert(messages,
        "⚠️ winPTY not found. Real‐time MIDI tracking will not work.")
    end
  end

  if #messages > 0 then
    M.fallbackMessage = table.concat(messages, "\n")
  end

  M.name        = candidate
  M.controls    = loadModule(candidate, "backend_controls")
  M.commandMenu = loadModule(candidate, "command_menu")
  -- thread will be assigned when .start() is called
  M.thread      = nil

  return M
end

--- Start (or restart) the backend’s active‐notes thread.
-- Spawns `track_active_notes_thread.lua` from the selected backend directory
-- and saves the thread handle in `M.thread`.
function M.start()
  local path = ("src/backends/%s/track_active_notes_thread.lua"):format(M.name)
  local th   = love.thread.newThread(path)
  th:start()
  M.thread = th
end

return M
