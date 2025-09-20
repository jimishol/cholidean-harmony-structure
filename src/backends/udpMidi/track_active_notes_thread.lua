-- UDP-based active-notes tracker (mimics midiport FFI thread)
-- Reads 4-byte MIDI packets over UDP, maintains active note set,
-- merges with disk file, and publishes snapshots ~50 Hz.
-- Exits cleanly on "quit" from the quit channel.

local quit_ch     = love.thread.getChannel("quit")
local notes_ch    = love.thread.getChannel("active_notes")
local control_ch  = love.thread.getChannel("track_control")
local love_timer  = require("love.timer")
local socket      = require("socket")
local bit         = require("bit")

-- Disk file for persisting cleared notes
local notesFile = "active_notes.lua"

-- Clear the notes file so it returns an empty table
local function clear_notes_file()
  local f = io.open(notesFile, "w")
  if f then
    f:write("-- Auto-generated active MIDI notes\nreturn {}\n")
    f:close()
  end
end

-- Merge two lists into a sorted, unique list
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

-- Publish merged disk+live notes to the channel
local function publish_from_file(live_list)
  local ok, disk = pcall(dofile, notesFile)
  if not (ok and type(disk) == "table") then disk = {} end
  local merged = merge_unique(disk, live_list)
  notes_ch:clear()
  notes_ch:push(merged)
end

-- Handle "clear" and "quit" commands
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

-- Live active-note map: note → true
local ACTIVE = {}

-- Initial state: clear file and publish empty list
clear_notes_file()
publish_from_file({})

local last_publish = love_timer.getTime()

-- Main loop: control → receive → publish
while true do
  handle_control()
  if quit_ch:peek() == "quit" then break end

  local data = udp:receive()
  if data and #data >= 4 then
    local status = data:byte(1)
    local note   = data:byte(2)
    local vel    = data:byte(3)

    -- High nibble determines msg type
    local mtype = bit.band(status, 0xF0)
    if mtype == 0x90 and vel > 0 then
      ACTIVE[note] = true
    elseif mtype == 0x80 or (mtype == 0x90 and vel == 0) then
      ACTIVE[note] = nil
    end
  end

  local now = love_timer.getTime()
  if now - last_publish >= 0.02 then
    -- Build sorted live list and publish merged snapshot
    local live = {}
    for n in pairs(ACTIVE) do table.insert(live, n) end
    table.sort(live)
    publish_from_file(live)
    last_publish = now
  end

  love_timer.sleep(0.002)
end
