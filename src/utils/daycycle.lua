-- src/helpers/daycycle.lua
local constants = require("constants")

local M = {}

--- Compute sky‐time and environment brightness from dayTime (0–24h).
-- @param dayTime   number  current hour, 0–24
-- @return sunFactor number  0–1 for skyExt:setDaytime()
-- @return envBright number  0–constants.maxBrightness for dream:setSky()
function M.computeDaycycle(dayTime)
  -- wrap into [0,24)
  local h = dayTime % 24
  local sunFactor

  if h >= 5 and h <= 21 then
     local angle = math.pi * (h - 5) / 16
     sunFactor = math.sin(angle)
    else
     sunFactor = 0
  end

  local envBright = constants.maxBright * sunFactor

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
