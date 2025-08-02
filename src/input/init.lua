-- src/input/init.lua

local KeyBindings = require("src.input.key_bindings")

local Input = {}

function Input:init()
  -- MIDI setup later
end

function Input:onKey(key)
  return KeyBindings:actionForKey(key)
end

function Input:onMidi(msgType, channel, number, value)
  return nil  -- MIDI not wired yet
end

return Input
