-- src/helpers/daycycle.lua
local constants = require("constants")

local M = {}

--- Compute sky‐time and environment brightness from dayTime (0–24h).
-- @param dayTime   number  current hour, 0–24
-- @return sunFactor number  0–1 for skyExt:setDaytime()
-- @return envBright number  0–constants.maxBrightness for dream:setSky()
function M.computeDaycycle(dayTime)
  -- wrap into [0,24)
  local h = ((dayTime - 6) % 24 + 24) % 24
  local sunFactor = h/24
  local envBright

  local t = (dayTime % 24 + 24) % 24
    if t >= 4 and t <= 20 then
	envBright = constants.maxBright * math.sin( math.pi / 4 * ( t / 4 - 1) )
      else
	envBright = constants.maxNightBright * math.sin( math.pi / 2 * (4 - math.min(t, 24 - t)) / 4 )
    end

  return sunFactor, envBright
end

--- Format dayTime float to HH:MM string
-- @param dayTime number in 24h float format
-- @return timeStr string like "09:05"
function M.formatTime(dayTime)
  local h24 = (dayTime % 24 + 24) % 24
  local hours = math.floor(h24)
  local minutes = math.floor((h24 - hours) * 60)
  return string.format("%02d:%02d", hours, minutes)
end

return M
