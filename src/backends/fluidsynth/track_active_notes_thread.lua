-- /src/backends/fluidsynth/track_active_notes_thread.lua
local clearChannel = love.thread.getChannel("track_control")

-- Get platform from main thread
local platformChannel = love.thread.getChannel("platform")
local platform = platformChannel:peek()

local backendChannel   = love.thread.getChannel("backend")
local soundfontChannel = love.thread.getChannel("soundfonts")
local songsChannel     = love.thread.getChannel("songs")

local backend   = backendChannel:peek()
local soundfont = soundfontChannel:peek()
local songList  = songsChannel:peek()
local shellPort = love.thread.getChannel("shellPort"):peek()
local shellHost = love.thread.getChannel("shellHost"):peek() -- It is not used by fluidsynth that defaults to "locahost" or 127.0.0.1

-- Construct command based on platform
local cmd
if platform == "windows" then
  cmd = string.format(
    'winpty %s -ds ' ..
    '-o audio.period-size=128 ' ..
    '-o audio.periods=32 ' ..
    '-o shell.port=%d %s %s',
    backend,
    shellPort,
    soundfont,
    songList
  )
else
  cmd = string.format(
    'stdbuf -oL %s -ds ' ..
    '-o audio.period-size=128 ' ..
    '-o audio.periods=32 ' ..
    '-o shell.port=%d %s %s',
    backend,
    shellPort,
    soundfont,
    songList
  )
end

local output_file  = "active_notes.lua"
local active_notes = {}

local function dump_active()
  local set = {}
  for _, note in pairs(active_notes) do set[note.key] = true end

  local list = {}
  for k in pairs(set) do table.insert(list, k) end
  table.sort(list)

  local f = assert(io.open(output_file, "w"))
  f:write("-- Auto‐generated active MIDI notes\nreturn {\n")
  for _, n in ipairs(list) do
    f:write(string.format("    %d,\n", n))
  end
  f:write("}\n")
  f:close()
end

-- Clear on startup
dump_active()

local pipe = assert(io.popen(cmd, "r"))

while true do
-- 2) Handle explicit clear
  if clearChannel:pop() == "clear" then
    active_notes = {}
    dump_active()
  end

  local line = pipe:read("*l")
  if not line then break end

  local ch, key = line:match("noteon%s+(%d+)%s+(%d+)%s+%d+")
  if ch then
    active_notes[ch..":"..key] = { channel = tonumber(ch), key = tonumber(key) }
    dump_active()
  else
    local ch2, key2 = line:match("noteoff%s+(%d+)%s+(%d+)")
    if ch2 then
      active_notes[ch2..":"..key2] = nil
      dump_active()
    end
  end

end

pipe:close()
