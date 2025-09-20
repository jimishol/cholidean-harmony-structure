-- backends/udpMidi/track_active_notes_thread.lua
-- Hybrid event-driven live updates + midiport-style 50 Hz merge
-- Adds UDP-flush on Clear so cleared list stays empty

local quit_ch     = love.thread.getChannel("quit")
local notes_ch    = love.thread.getChannel("active_notes")
local control_ch  = love.thread.getChannel("track_control")

local socket      = require "socket"
local fs          = require "love.filesystem"
local bit         = require "bit"

local notesFile      = "active_notes.lua"
local mergeInterval  = 0.02   -- 50 Hz merge
local lastMerge      = socket.gettime()

-- persistent on-disk and live states
local diskState = {}
local liveState = {}

-- clear the disk file to empty table
local function clear_notes_file()
  local f = io.open(notesFile, "w")
  if f then
    f:write("-- Auto-generated active MIDI notes\nreturn {}\n")
    f:close()
  end
end

-- reload diskState once per merge
local function reload_disk()
  local ok, data = pcall(dofile, notesFile)
  diskState = (ok and type(data)=="table") and data or {}
end

-- unique-merge two arrays and sort
local function merge_unique(a, b)
  local seen, out = {}, {}
  for _, v in ipairs(a) do
    if not seen[v] then seen[v] = true; out[#out+1] = v end
  end
  for _, v in ipairs(b) do
    if not seen[v] then seen[v] = true; out[#out+1] = v end
  end
  table.sort(out)
  return out
end

-- publish only liveState (fast path)
local function publish_live(snapshots)
  notes_ch:clear()
  notes_ch:push(snapshots)
end

-- publish merged diskState+liveState (slow path)
local function publish_merged(snapshots)
  local merged = merge_unique(diskState, snapshots)
  notes_ch:clear()
  notes_ch:push(merged)
end

-- UDP setup (nonblocking)
local udp = assert(socket.udp())
assert(udp:setsockname("*", 49160))
udp:settimeout(0)

-- handle clear/quit from main thread, with UDP flush on Clear
local function handle_control()
  while true do
    local cmd = control_ch:pop()
    if not cmd then break end

    if cmd == "clear" then
      -- reset both states
      liveState = {}
      diskState = {}

      -- flush any pending UDP packets so they don't refill liveState
      repeat
        local _ = udp:receive()
      until not _

      clear_notes_file()
      publish_merged({})

    elseif cmd == "quit" then
      quit_ch:push("quit")
    end
  end
end

-- initialize disk file and state
clear_notes_file()
reload_disk()
publish_merged({})

while true do
  handle_control()
  if quit_ch:peek() == "quit" then break end

  -- FAST PATH: drain UDP events, update liveState, publish live-only
  local data = udp:receive()
  while data and #data >= 3 do
    local s, n, v = data:byte(1,3)
    local t       = bit.band(s, 0xF0)
    local changed = false

    if t == 0x90 and v > 0 then
      if not liveState[n] then liveState[n] = true; changed = true end
    elseif t == 0x80 or (t == 0x90 and v == 0) then
      if liveState[n] then liveState[n] = nil; changed = true end
    end

    if changed then
      local snap = {}
      for note in pairs(liveState) do snap[#snap+1] = note end
      publish_live(snap)
    end

    data = udp:receive()
  end

  -- SLOW PATH: every mergeInterval, reload disk & publish merged
  local now = socket.gettime()
  if now - lastMerge >= mergeInterval then
    reload_disk()
    local snap = {}
    for note in pairs(liveState) do snap[#snap+1] = note end
    publish_merged(snap)
    lastMerge = now
  end

  -- tiny yield so we don't spin 100%
  socket.sleep(0.001)
end
