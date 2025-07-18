-- src/input/key_bindings.lua

local A = require("src.input.actions")

--- Maps concrete key presses to high‐level actions.
local M = {}

M.bindings = {
  [A.QUIT]         = { "q" },
  [A.RESET_VIEW]   = { "space" },
  [A.TOGGLE_DEBUG] = { "d" },
  [A.TOGGLE_LABELS]= { "l" },
  [A.TOGGLE_JOINTS]   = { "j" },
  [A.TOGGLE_EDGES]    = { "e" },
  [A.TOGGLE_CURVES]   = { "c" },
  [A.TOGGLE_SURFACES] = { "s" },
}

--- Returns the action string for the given key, or nil if none.
function M:actionForKey(key)
  for action, keys in pairs(self.bindings) do
    for _, k in ipairs(keys) do
      if k == key then
        return action
      end
    end
  end
  return nil
end

return M
