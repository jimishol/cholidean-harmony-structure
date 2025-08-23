--- Playlist backend for retrieving MIDI files from 'midi_files' directory.
-- Assumes the folder always exists (main.lua bootstraps it).
-- @module src.backends.playlist

local M = {}

--- Escape a path for safe shell execution.
-- Wraps spaces and quotes appropriately per platform.
-- @local
-- @param path string The file path to escape.
-- @treturn string The safely quoted path.
local function escapeSpaces(path)
  local osDetect = require("src.utils.os_detect")
  local platform = osDetect.getPlatform()

  if platform == "windows" then
    -- On Windows, escape spaces
    return path:gsub(" ", "\\ ")
  else
    -- On POSIX, wrap in single‐quotes and escape any internal single‐quotes
    local esc = path:gsub("'", "'\"'\"'")
    return "'" .. esc .. "'"
  end
end

--- Retrieve and process MIDI files from 'midi_files' directory.
-- @treturn string[] Shell-escaped list of all `.mid` files in the folder.
function M.getSelectedSongs()
  local folder     = "midi_files"
  local items      = love.filesystem.getDirectoryItems(folder)
  local midiFiles  = {}

  for _, filename in ipairs(items) do
    if filename:lower():match("%.mid$") then
      local fullPath = folder .. "/" .. filename
      midiFiles[#midiFiles + 1] = escapeSpaces(fullPath)
    end
  end

  return midiFiles
end

return M
