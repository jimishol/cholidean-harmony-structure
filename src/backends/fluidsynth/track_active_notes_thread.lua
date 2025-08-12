--- Active‐notes tracker thread for the Fluidsynth backend.
-- Spawns the Fluidsynth process, listens for MIDI note‐on/off events,
-- maintains a table of currently active notes, and writes them
-- to a Lua file (`active_notes.lua`) for consumption by the main thread.
-- @module src.backends.fluidsynth.track_active_notes_thread

--- Love Thread channels for control and configuration.
-- @section Channels

--- Channel on which “clear” commands arrive to reset active notes.
-- @local
local clearChannel = love.thread.getChannel("track_control")

--- Channel from the main thread carrying the platform identifier.
-- @local
local platformChannel = love.thread.getChannel("platform")
local platform        = platformChannel:peek()

--- Channels carrying backend executable name, soundfont path, and song list.
-- @local
local backendChannel   = love.thread.getChannel("backend")
local soundfontChannel = love.thread.getChannel("soundfonts")
local songsChannel     = love.thread.getChannel("songs")

--- Retrieve configuration values from their channels.
-- @local
local backend   = backendChannel:peek()
local soundfont = soundfontChannel:peek()
local songList  = songsChannel:peek()
local shellPort = love.thread.getChannel("shellPort"):peek()
local shellHost = love.thread.getChannel("shellHost"):peek()

--- Output file path for the auto‐generated active notes list.
-- @local
local output_file  = "active_notes.lua"

--- Internal table mapping “channel:key” to note info.
-- @local
local active_notes = {}

--- Dump the current set of active notes to `active_notes.lua`.
-- Serializes the unique MIDI key numbers into a sorted Lua array.
-- @local
local function dump_active()
  -- Build a set of unique keys
  local set = {}
  for _, note in pairs(active_notes) do
    set[note.key] = true
  end

  -- Convert set to sorted list
  local list = {}
  for k in pairs(set) do
    table.insert(list, k)
  end
  table.sort(list)

  -- Write out as a Lua module
  local f = assert(io.open(output_file, "w"))
  f:write("-- Auto‐generated active MIDI notes\nreturn {\n")
  for _, n in ipairs(list) do
    f:write(string.format("    %d,\n", n))
  end
  f:write("}\n")
  f:close()
end

-- Immediately clear any stale notes on startup
dump_active()

--- Construct the Fluidsynth launch command, wrapped for platform.
-- On Windows, prefixes with `winpty` to allocate a console.
-- On other systems, uses `stdbuf -oL` for line‐buffered output.
-- @local
local cmd = nil
if platform == "windows" then
  local winBackPathChannel = love.thread.getChannel("winBackPath")
  local winBackPath        = winBackPathChannel:peek()
  local exeString = winBackPath .. backend .. ".exe"
  cmd = string.format(
    'winpty %s -ds ' ..
    '-o audio.period-size=128 ' ..
    '-o audio.periods=32 ' ..
    '-o shell.port=%d %s %s',
    exeString, shellPort, soundfont, songList
  )
else
  cmd = string.format(
    'stdbuf -oL %s -ds ' ..
    '-o audio.period-size=128 ' ..
    '-o audio.periods=32 ' ..
    '-o shell.port=%d %s %s',
    backend, shellPort, soundfont, songList
  )
end

-- Launch Fluidsynth subprocess and capture its stdout
local pipe = assert(io.popen(cmd, "r"))

-- Main event loop: read lines and update active_notes
while true do
  -- Handle explicit “clear” requests
  if clearChannel:pop() == "clear" then
    active_notes = {}
    dump_active()
  end

  -- Read the next line of Fluidsynth output
  local line = pipe:read("*l")
  if not line then
    break
  end

  -- Parse `noteon` events
  local ch, key = line:match("noteon%s+(%d+)%s+(%d+)%s+%d+")
  if ch then
    active_notes[ch .. ":" .. key] = {
      channel = tonumber(ch),
      key     = tonumber(key),
    }
    dump_active()
  else
    -- Parse `noteoff` events
    local ch2, key2 = line:match("noteoff%s+(%d+)%s+(%d+)")
    if ch2 then
      active_notes[ch2 .. ":" .. key2] = nil
      dump_active()
    end
  end
end

pipe:close()
