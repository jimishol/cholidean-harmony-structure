--- Color utilities module.
-- Provides a perceptually uniform 12-step HSV palette (derived from HSLuv with L=50)
-- for mapping 12 note indices around the circle of fourths to RGB.
-- Requires a “dream” object exposing an `HSVtoRGB(h, s, v)` method.
-- @module src.utils.colors

local M = {}
local _dream

--- Perceptually uniform 12-step HSV palette derived from HSLuv (L=50).
-- Each entry has fields `h`, `s`, and `v` in the range [0..1].  
-- The sequence follows the circle of fourths starting at C (0°) and stepping by 30°.
-- @local
-- @table PALETTE
-- @field[1]  table {h=0.0000, s=0.7245, v=0.9656}   C   (  0°)
-- @field[2]  table {h=0.0833, s=0.7984, v=0.9683}   F   ( 30°)
-- @field[3]  table {h=0.1667, s=0.7979, v=0.9671}   Bb  ( 60°)
-- @field[4]  table {h=0.2500, s=0.7979, v=0.9671}   Eb  ( 90°)
-- @field[5]  table {h=0.3333, s=0.7245, v=0.9656}   Ab  (120°)
-- @field[6]  table {h=0.4167, s=0.7097, v=0.9671}   Db  (150°)
-- @field[7]  table {h=0.5000, s=0.7231, v=0.9673}   Gb  (180°)
-- @field[8]  table {h=0.5833, s=0.7979, v=0.9671}   B   (210°)
-- @field[9]  table {h=0.6667, s=0.7979, v=0.9671}   E   (240°)
-- @field[10] table {h=0.7500, s=0.7979, v=0.9671}   A   (270°)
-- @field[11] table {h=0.8333, s=0.7232, v=0.9673}   D   (300°)
-- @field[12] table {h=0.9167, s=0.7979, v=0.9671}   G   (330°)
local PALETTE = {
  { h =   0.0000, s = 0.7245, v = 0.9656 },
  { h =   0.0833, s = 0.7984, v = 0.9683 },
  { h =   0.1667, s = 0.7979, v = 0.9671 },
  { h =   0.2500, s = 0.7979, v = 0.9671 },
  { h =   0.3333, s = 0.7245, v = 0.9656 },
  { h =   0.4167, s = 0.7097, v = 0.9671 },
  { h =   0.5000, s = 0.7231, v = 0.9673 },
  { h =   0.5833, s = 0.7979, v = 0.9671 },
  { h =   0.6667, s = 0.7979, v = 0.9671 },
  { h =   0.7500, s = 0.7979, v = 0.9671 },
  { h =   0.8333, s = 0.7232, v = 0.9673 },
  { h =   0.9167, s = 0.7979, v = 0.9671 },
}

--- Initialize the color module with a Dream instance.
-- The Dream instance must implement `HSVtoRGB(h, s, v)` which returns
-- either three numeric values (r, g, b) or a table `{r, g, b}`.
-- @tparam table dream Object providing `HSVtoRGB(h, s, v)`
-- @treturn nil
function M.init(dream)
  _dream = dream
end

--- Get the RGB color corresponding to a note index.
-- Wraps the index into the range 1..12, looks up the HSV entry,
-- and converts it to RGB via the Dream instance.
-- @tparam number index 1-based note index (any integer, wraps modulo 12)
-- @treturn number r Red channel in [0..1]
-- @treturn number g Green channel in [0..1]
-- @treturn number b Blue channel in [0..1]
-- or @treturn table rgb Table with keys `r`,`g`,`b` if Dream returns a table.
function M.getNoteColor(index)
  local i = ((index - 1) % #PALETTE) + 1
  local c = PALETTE[i]
  return _dream:HSVtoRGB(c.h, c.s, c.v)
end

return M
