--- OS detection module.
-- Uses LÖVE’s system API to determine the host operating system.
-- @module src.utils.os_detect

local M = {}

--- Returns a normalized platform name.
-- Queries `love.system.getOS()`, lowercases the result,
-- and matches against known substrings.
-- @treturn string
--   "windows" if on any Windows OS  
--   "macos"   if on macOS  
--   "linux"   if on Linux  
--   "unknown" otherwise
function M.getPlatform()
  local raw = love.system.getOS():lower()
  if raw:find("windows") then
    return "windows"
  elseif raw:find("mac") then
    return "macos"
  elseif raw:find("linux") then
    return "linux"
  else
    return "unknown"
  end
end

return M
