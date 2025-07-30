-- src/input/init.lua

local KeyBindings = require("src.input.key_bindings")

local Input = {}

function Input:init()
  -- MIDI setup later
end

-- ########## TEMP DEBUG DUMPER START (delete later) ##########
local function SafeDump(o, opts, depth)
  opts      = opts or { maxDepth = 3, seen = {} }
  depth     = depth or 0
  local seen = opts.seen

  -- primitives
  if type(o) ~= "table" then
    return tostring(o)
  end

  -- cycle detection
  if seen[o] then
    return "<cycle>"
  end
  seen[o] = true

  -- depth guard
  if depth >= opts.maxDepth then
    return "{ ... }"
  end

  -- iterate
  local indent = string.rep("  ", depth)
  local lines  = { "{\n" }
  for k, v in pairs(o) do
    local key   = tostring(k)
    local value = SafeDump(v, opts, depth + 1)
    table.insert(lines, indent .. "  " .. key .. " = " .. value .. ",\n")
  end
  table.insert(lines, indent .. "}")
  return table.concat(lines)
end

Input.SafeDump = SafeDump

-- ########## TEMP DEBUG DUMPER END ##########

function Input:onKey(key)
  return KeyBindings:actionForKey(key)
end

function Input:onMidi(msgType, channel, number, value)
  return nil  -- MIDI not wired yet
end

return Input
