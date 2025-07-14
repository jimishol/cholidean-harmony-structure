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

  -- 1) skyExt wants 0 @ 06:00, 0.5 @ 18:00, etc.
  --    shift so 6:00 → 0, then normalize
  local shifted = (h - 6 + 24) % 24
  local sunFactor = shifted / 24

  -- 2) brightness: 0 @ midnight, peak @ noon, back to 0 @ next midnight
  --    sin(π * h/24) does exactly that
  local envBright = constants.maxBright * math.sin(math.pi * h / 24)

  return sunFactor, envBright
end

return M
