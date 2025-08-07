-- src/midi/playlist.lua

local M = {}

-- Original list with readable paths
local rawSongs = {
  "assets/Wagner_Ride_of_the_valkyries.mid",
  "assets/Ob La Di Ob La Da by Lennon McCartney.mid",
  "assets/Opus 165 III malaguena by Isaac Albeniz.mid",
}

-- Escape literal spaces for shell compatibility
local function escapeSpaces(path)
  return path:gsub("([ ])", "\\%1")
end

-- Public function to return escaped paths
function M.getSelectedSongs()
  local escaped = {}
  for _, path in ipairs(rawSongs) do
    escaped[#escaped + 1] = escapeSpaces(path)  -- Correct way to insert at the end
  end
  return escaped
end

return M
