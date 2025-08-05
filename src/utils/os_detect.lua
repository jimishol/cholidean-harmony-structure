-- os_detect.lua
local M = {}

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
