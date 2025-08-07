-- /src/midi/track_active_notes_thread.lua

local quit_channel = love.thread.getChannel("quit")
local backendChannel = love.thread.getChannel("backend")
local backend     = backendChannel:pop()

local soundfontChannel = love.thread.getChannel("soundfont")
local soundfont = soundfontChannel:pop()
local songsChannel = love.thread.getChannel("songs")
local songList = songsChannel:pop()

local shellPort = love.thread.getChannel("shellPort"):pop()

local cmd = string.format(
  'stdbuf -oL %s -ds ' ..
  '-o audio.period-size=128 ' ..
  '-o audio.periods=32 ' ..
  '-o shell.port=%d %s %s',
  backend,
  shellPort,
  soundfont,
  songList
)

local output_file  = "src/midi/active_notes.lua"
local active_notes = {}

-- Define dump_active *before* calling it
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

local pipe         = assert(io.popen(cmd, "r"))
-- Main loop: consume quit *and* read one line per iteration
while true do

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

  if quit_channel:peek() == "quit" then
    break
  end

end

pipe:close()
