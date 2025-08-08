-- src/backends/playlist.lua
local M = {}

-- The one guaranteed fallback
local defaultSong = "assets/Wagner_Ride_of_the_valkyries.mid"

-- Escape literal spaces for shell compatibility
local function escapeSpaces(path)
  return path:gsub(" ", "\\ ")
end

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
