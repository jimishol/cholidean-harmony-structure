local dream = require("3DreamEngine")

local M = {}

function M.getNoteColor(index)
  local hue = (index - 1) / 12.0
  return dream:HSVtoRGB(hue, 1.0, 1.0)
end

return M
