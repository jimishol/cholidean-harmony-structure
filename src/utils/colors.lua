-- src/utils/colors.lua
local M = {}
local _dream

-- Perceptually uniform 12-step HSV palette derived from HSLuv (L=50)
-- h is hue in [0..1], s and v in [0..1]
local PALETTE = {
  { h =   0.0000, s = 0.7245, v = 0.9656 },  -- C   (  0°)
  { h =   0.0833, s = 0.7984, v = 0.9683 },  -- F   ( 30°)
  { h =   0.1667, s = 0.7979, v = 0.9671 },  -- Bb  ( 60°)
  { h =   0.2500, s = 0.7979, v = 0.9671 },  -- Eb  ( 90°)
  { h =   0.3333, s = 0.7245, v = 0.9656 },  -- Ab  (120°)
  { h =   0.4167, s = 0.7097, v = 0.9671 },  -- Db  (150°)
  { h =   0.5000, s = 0.7231, v = 0.9673 },  -- Gb  (180°)
  { h =   0.5833, s = 0.7979, v = 0.9671 },  -- B   (210°)
  { h =   0.6667, s = 0.7979, v = 0.9671 },  -- E   (240°)
  { h =   0.7500, s = 0.7979, v = 0.9671 },  -- A   (270°)
  { h =   0.8333, s = 0.7232, v = 0.9673 },  -- D   (300°)
  { h =   0.9167, s = 0.7979, v = 0.9671 },  -- G   (330°)
}

function M.init(dream)
  _dream = dream
end

function M.getNoteColor(index)
  -- wrap index into 1..12
  local i = ((index - 1) % #PALETTE) + 1
  local c = PALETTE[i]
  -- returns r,g,b or {r,g,b} depending on your _dream:HSVtoRGB
  return _dream:HSVtoRGB(c.h, c.s, c.v)
end

return M
