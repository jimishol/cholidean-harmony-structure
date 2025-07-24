-- src/utils/colors.lua
local M = {}
local _dream  -- will hold the engine instance

function M.init(dream)
  _dream = dream
end

function M.getNoteColor(index)
  local hue = (index - 1) / 12.0
  -- now use the stored engine
  return _dream:HSVtoRGB(hue, 1.0, 1.0)
end

return M
