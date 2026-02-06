-- backends/udpMidi/track_active_notes_thread.lua

local quit_ch    = love.thread.getChannel("quit")
local notes_ch   = love.thread.getChannel("active_notes")
local control_ch = love.thread.getChannel("track_control")
local excludeChannel = love.thread.getChannel("excludeChannels")
local exclude = excludeChannel:peek() or {}

local socket     = require "socket"
local bit        = require "bit"

-- Config
local notesFile     = "active_notes.lua"
local mergeInterval = 0.016   -- 16 ms tick
local fastWindow    = 0.005   -- 5 ms fast-path poll

-- State
local lastMerge = socket.gettime()
local diskState = {}
local liveState = {}

-- Helpers

local function clear_notes_file()
  local f = io.open(notesFile, "w")
  if f then
    f:write("-- Auto-generated active MIDI notes\nreturn {}\n")
    f:close()
  end
end

local function reload_disk()
  local ok, data = pcall(dofile, notesFile)
  diskState = (ok and type(data)=="table") and data or {}
end

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

local function publish_live(snap)
  notes_ch:clear()
  notes_ch:push(snap)
end

local function publish_merged(snap)
  notes_ch:clear()
  notes_ch:push(merge_unique(diskState, snap))
end

-- UDP setup (bind to all interfaces for cross-platform)
local udp = assert(socket.udp())
assert(udp:setsockname("0.0.0.0", 49160), "UDP bind failed")
udp:settimeout(0)  -- needed for select()

-- Initial disk file + merged snapshot
clear_notes_file()
reload_disk()
publish_merged({})

-- Main loop
while true do
  -- 1) Immediate control commands
  local cmd = control_ch:pop()
  if cmd == "clear" then
    liveState, diskState = {}, {}
    repeat until not udp:receive()  -- flush stray packets
    clear_notes_file()
    publish_merged({})
  elseif cmd == "quit" then
    quit_ch:push("quit")
    break
  end

  -- 2) FAST-PATH: catch any incoming UDP in a short window
  local ready = socket.select({udp}, nil, fastWindow)
  if #ready > 0 then
    local changed = false
    local pkt = udp:receive()
    while pkt do
    local status, note, vel = pkt:byte(1,3)
    local ch = bit.band(status, 0x0F)
    local shouldExclude = false
    for _, v in ipairs(exclude) do
      if ch == v then shouldExclude = true; break end
    end
    if not shouldExclude then
      local typ = bit.band(status, 0xF0)
      if typ == 0x90 and vel > 0 then
        if not liveState[note] then liveState[note] = true; changed = true end
      elseif typ == 0x80 or (typ == 0x90 and vel == 0) then
        if liveState[note] then liveState[note] = nil; changed = true end
      end
    end
      pkt = udp:receive()
    end

    if changed then
      local snap = {}
      for n in pairs(liveState) do snap[#snap+1] = n end
      publish_live(snap)
    end
  end

  -- 3) Wait out the remainder of the 16 ms tick
  local now     = socket.gettime()
  local toMerge = mergeInterval - (now - lastMerge)
  if toMerge > 0 then
    socket.select({udp}, nil, toMerge)
  end

  -- 4) SLOW-PATH merge on tick
  now = socket.gettime()
  if now - lastMerge >= mergeInterval then
    reload_disk()
    local snap = {}
    for n in pairs(liveState) do snap[#snap+1] = n end
    publish_merged(snap)
    lastMerge = now
  end
end
