-- backends/udpMidi/track_active_notes_thread.lua
-- Event-driven UDP active-notes tracker (no fixed-rate sleep)
-- Reads 4-byte MIDI packets, updates on each note event,
-- merges with disk file and publishes only when state changes.

local quit_ch     = love.thread.getChannel("quit")
local notes_ch    = love.thread.getChannel("active_notes")
local control_ch  = love.thread.getChannel("track_control")
local socket      = require("socket")
local bit         = require("bit")

-- Disk file for persisting cleared notes
local notesFile = "active_notes.lua"

local function clear_notes_file()
  local f = io.open(notesFile, "w")
  if f then
    f:write("-- Auto-generated active MIDI notes\nreturn {}\n")
    f:close()
  end
end

local function merge_unique(t1, t2)
  local seen, out = {}, {}
  for _, v in ipairs(t1) do
    if not seen[v] then seen[v] = true; table.insert(out, v) end
  end
  for _, v in ipairs(t2) do
    if not seen[v] then seen[v] = true; table.insert(out, v) end
  end
  table.sort(out)
  return out
end

local function publish(live_list)
  local ok, disk = pcall(dofile, notesFile)
  if not (ok and type(disk) == "table") then disk = {} end
  local merged = merge_unique(disk, live_list)
  notes_ch:clear()
  notes_ch:push(merged)
end

local function handle_control()
  while true do
    local cmd = control_ch:pop()
    if not cmd then break end
    if cmd == "clear" then
      ACTIVE = {}
      clear_notes_file()
      notes_ch:clear()
      notes_ch:push({})
    elseif cmd == "quit" then
      quit_ch:push("quit")
    end
  end
end

-- Setup UDP socket
local UDP_PORT = 49160
local udp = assert(socket.udp())
assert(udp:setsockname("*", UDP_PORT))
udp:settimeout(0)

-- Live active-note map
local ACTIVE = {}

-- Initial empty publish
clear_notes_file()
publish({})

-- Main loop: handle control, drain UDP, publish on change
while true do
  handle_control()
  if quit_ch:peek() == "quit" then break end

  -- Drain all pending packets
  local data = udp:receive()
  while data and #data >= 4 do
    local status = data:byte(1)
    local note   = data:byte(2)
    local vel    = data:byte(3)
    local mtype  = bit.band(status, 0xF0)

    local changed = false
    if mtype == 0x90 and vel > 0 then
      if not ACTIVE[note] then ACTIVE[note] = true; changed = true end
    elseif mtype == 0x80 or (mtype == 0x90 and vel == 0) then
      if ACTIVE[note] then ACTIVE[note] = nil; changed = true end
    end

    if changed then
      local snapshot = {}
      for n in pairs(ACTIVE) do snapshot[#snapshot+1] = n end
      publish(snapshot)
    end

    data = udp:receive()
  end

  -- brief yield so we don't busy-loop at 100%
  socket.sleep(0.001)
end
