local A = require("src.input.actions")

local M = {}
M.bindings = {
  [A.QUIT]         	  = { "q" },
  [A.RESET_VIEW]   	  = { "space" },
-- Show FPS + camera yaw/pitch overlay
  [A.TOGGLE_DEBUG] 	  = { "d" },
  [A.TOGGLE_LABELS]	  = { "l" },
  [A.TOGGLE_JOINTS]   	  = { "j" },
  [A.TOGGLE_EDGES]    	  = { "e" },
  [A.TOGGLE_CURVES]   	  = { "c" },
  [A.TOGGLE_SURFACES] 	  = { "s" },
  [A.TOGGLE_TORUS_LIGHTS] = { "b" },
  [A.TOGGLE_NOTE_MODE]    = { "h" },  -- 🔥 Head/unheard or on/off mode for active status
  [A.RESET_FOV]           = {"f"},
  [A.TOGGLE_PLAYBACK]     = { "p" },
  [A.BEGIN_SONG] 	  = { "tab" },
  [A.NEXT_SONG] 	  = { "return" },
  [A.SHOW_COMMAND_MENU]   = { ":" },
  [A.RESTART] 	          = { "r" },
}

--- Returns the action string for the given key, or nil if none.
function M:actionForKey(key)
  -- 1) Catch Shift + Left/Right
  local shiftDown = love.keyboard.isDown("lshift", "rshift")
  if shiftDown and key == "left" then
    return A.ROTATE_CW
  end
  if shiftDown and key == "right" then
    return A.ROTATE_CCW
  end

  -- 2) Fallback to your normal single-key mappings
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
