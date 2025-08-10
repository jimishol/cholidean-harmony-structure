--- Input key‐to‐action mapping.
-- Defines which keyboard keys trigger which high‐level actions.
--
-- @module src.input.key_bindings
-- @field bindings table Mapping from action constants to lists of Love2D key names.
local A = require("src.input.actions")
local M = {}

M.bindings = {
  [A.QUIT]               = { "q" },
  [A.RESET_VIEW]         = { "space" },
  [A.TOGGLE_DEBUG]       = { "d" },
  [A.TOGGLE_LABELS]      = { "l" },
  [A.TOGGLE_JOINTS]      = { "j" },
  [A.TOGGLE_EDGES]       = { "e" },
  [A.TOGGLE_CURVES]      = { "c" },
  [A.TOGGLE_SURFACES]    = { "s" },
  [A.TOGGLE_TORUS_LIGHTS]= { "b" },
  [A.TOGGLE_NOTE_MODE]   = { "h" },
  [A.RESET_FOV]          = { "f" },
  [A.TOGGLE_PLAYBACK]    = { "p" },
  [A.BEGIN_SONG]         = { "tab" },
  [A.NEXT_SONG]          = { "return" },
  [A.SHOW_COMMAND_MENU]  = { ":" },
  [A.RESTART]            = { "f10" },
}

--- Returns the action constant for a given key or nil.
-- @tparam string key Love2D key name (e.g. "a", "space", "left")
-- @treturn string|nil The mapped action, or nil if unmapped
function M:actionForKey(key)
  local shiftDown = love.keyboard.isDown("lshift", "rshift")
  if shiftDown and key == "left"  then return A.ROTATE_CW  end
  if shiftDown and key == "right" then return A.ROTATE_CCW end

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
