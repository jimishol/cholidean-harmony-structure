--- Daycycle helper module.
-- Calculates the sky‐time factor and environment brightness from a 24h clock,
-- and provides a formatter for human‐readable HH:MM strings.
-- @module src.helpers.daycycle

local constants = require("constants")

local M = {}

--- Compute sky‐time and environment brightness from a dayTime value.
-- Wraps any 24h‐based `dayTime` into:
--   1. a `sunFactor` in [0..1] suitable for `skyExt:setDaytime()`
--   2. an `envBright` in [0..constants.maxBrightness] (day) or up to
--      constants.maxNightBright (night) for `dream:setSky()`
-- @tparam number dayTime Current time in hours (can be outside 0–24; will wrap)
-- @treturn number sunFactor Normalized sun position factor (0–1)
-- @treturn number envBright Computed environment brightness
function M.computeDaycycle(dayTime)
  -- wrap into [0,24)
  local h = ((dayTime - 6) % 24 + 24) % 24
  local sunFactor = h / 24
  local envBright

  local t = ((dayTime % 24) + 24) % 24
  if t >= 4 and t <= 20 then
    envBright = constants.maxBright *
      math.sin(math.pi / 4 * (t / 4 - 1))
  else
    envBright = constants.maxNightBright *
      math.sin(math.pi / 2 * (4 - math.min(t, 24 - t)) / 4)
  end

  return sunFactor, envBright
end

--- Format a floating‐point hour into an HH:MM string.
-- @tparam number dayTime Time in hours (float; wraps into 0–24)
-- @treturn string timeStr Formatted time string, zero-padded (e.g. "09:05")
function M.formatTime(dayTime)
  local h24 = ((dayTime % 24) + 24) % 24
  local hours = math.floor(h24)
  local minutes = math.floor((h24 - hours) * 60)
  return string.format("%02d:%02d", hours, minutes)
end

return M
