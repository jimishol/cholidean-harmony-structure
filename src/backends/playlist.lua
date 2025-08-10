--- Playlist backend for retrieving user‐selected MIDI files.
-- @module backends.playlist

local M = {}

--- Default fallback song when playlist is missing or invalid.
-- @local
local defaultSong = "assets/Wagner_Ride_of_the_valkyries.mid"

--- Escape literal spaces in a path for shell compatibility.
-- @local
-- @param path string The file path to escape.
-- @treturn string The path with spaces escaped.
local function escapeSpaces(path)
  return path:gsub(" ", "\\ ")
end

--- Retrieve and process the playlist from 'play.list'.
--
-- Attempts to read 'play.list' from the filesystem, trims whitespace,
-- ignores comments (lines starting with '#'), blank lines, and trailing commas.
-- Then decides on playlist output based on file presence and validity:
--
-- 1. Missing file: returns a table containing only the default song.
-- 2. Existing file but no valid entries: returns an empty table.
-- 3. Any non-existent path in user entries: falls back to the default song.
-- 4. Otherwise: returns all valid user paths, with spaces escaped.
--
-- @treturn string[] A list of shell-escaped song paths.
function M.getSelectedSongs()
  -- 1) Attempt to read play.list
  local info     = love.filesystem.getInfo("play.list")
  local rawLines = {}

  if info then
    local contents = love.filesystem.read("play.list")
    if contents then
      for line in contents:gmatch("[^\r\n]+") do
        -- trim whitespace
        local trimmed = line:match("^%s*(.-)%s*$")
        -- skip blank lines, comments, trailing commas
        if trimmed ~= "" and not trimmed:find("^#") then
          trimmed = trimmed:gsub(",%s*$", "")
          rawLines[#rawLines + 1] = trimmed
        end
      end
    end
  end

  -- 2) Decide on fallback vs. user list vs. empty
  if not info then
    -- file missing → one default song
    rawLines = { defaultSong }
  elseif #rawLines == 0 then
    -- file exists but no valid entries → empty playlist OK
    return {}
  else
    -- file has entries → ensure they all exist, otherwise fallback
    for _, path in ipairs(rawLines) do
      if not love.filesystem.getInfo(path) then
        rawLines = { defaultSong }
        break
      end
    end
  end

  -- 3) Escape spaces and return
  local escaped = {}
  for _, path in ipairs(rawLines) do
    escaped[#escaped + 1] = escapeSpaces(path)
  end

  return escaped
end

return M
