--- Input event handling module.
-- Initializes input, handles keyboard and MIDI events,
-- and delegates them to the appropriate action mappers.
-- @module src.input.init

local KeyBindings = require("src.input.key_bindings")

local Input = {}

--- Initialize the input subsystem.
-- Sets up MIDI devices and any other input resources.
-- Currently a no‐op; MIDI setup to be added later.
-- @treturn nil
function Input:init()
  -- MIDI setup later
end

--- Process a key press event.
-- Delegates to KeyBindings to map a key to an action.
-- @tparam string key The key that was pressed.
-- @treturn any The action corresponding to the key, or nil if unmapped.
function Input:onKey(key)
  return KeyBindings:actionForKey(key)
end

--- Process a MIDI message.
-- Currently unimplemented; always returns nil.
-- @tparam string msgType The MIDI message type (e.g. "note_on", "control_change").
-- @tparam number channel The MIDI channel (1–16).
-- @tparam number number The MIDI note or controller number.
-- @tparam number value The velocity or controller value.
-- @treturn nil
function Input:onMidi(msgType, channel, number, value)
  return nil  -- MIDI not wired yet
end

return Input
