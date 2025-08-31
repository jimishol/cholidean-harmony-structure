--- Active‐notes tracker thread for the Fluidsynth backend.
-- Spawns the Fluidsynth process, listens for MIDI note‐on/off events,
-- maintains a table of currently active notes, and writes them
-- to a Lua file (`active_notes.lua`) for consumption by the main thread.
-- Listens for "clear" to reset the note table and "quit" to exit cleanly.
-- @module src.backends.fluidsynth.track_active_notes_thread

local clearChannel    = love.thread.getChannel("track_control")
local platformChannel = love.thread.getChannel("platform")
local platform        = platformChannel:peek()

local backendChannel   = love.thread.getChannel("backend")
local soundfontChannel = love.thread.getChannel("soundfonts")
local songsChannel     = love.thread.getChannel("songs")

local backend   = backendChannel:peek()
local soundfont = soundfontChannel:peek()
local songList  = songsChannel:peek()
local shellPort = love.thread.getChannel("shellPort"):peek()
local shellHost = love.thread.getChannel("shellHost"):peek()

local output_file  = "active_notes.lua"
local active_notes = {}

--- Dump active notes to disk
-- Writes a sorted list of unique MIDI note keys into `active_notes.lua`.
local function dump_active()
  local set = {}
  for _, note in pairs(active_notes) do
    set[note.key] = true
  end

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

-- initial dump (empty set)
dump_active()

--- Read a VFS file and write it to a real temp file
-- @tparam string vpath  Virtual path inside LÖVE's filesystem
-- @treturn string       OS path to the temporary file
local function dumpToTemp(vpath)
  local data = assert(love.filesystem.read(vpath),
                      "Cannot read virtual asset: "..vpath)
  local tmp  = os.tmpname()
  if package.config:sub(1,1) == "\\" then
    tmp = love.filesystem.getWorkingDirectory() .. tmp
  end
  local basename = vpath:match("[^/]+$")
  local out      = tmp .. "_" .. basename
  local f = assert(io.open(out, "wb"), "Failed to open temp file: "..out)
  f:write(data)
  f:close()
  return out
end

--- Escape an OS path for safe shell invocation
-- @tparam string path  Raw OS file path
-- @treturn string      Quoted/escaped shell path
local function shellEscape(path)
  if platform == "windows" then
    return '"' .. path:gsub('"', '\\"') .. '"'
  else
    local escaped = path:gsub("'", "'\\''")
    return "'" .. escaped .. "'"
  end
end

-- Resolve SoundFont: explicit, root‐dropped, or system default
local sfPathOS
if soundfont and soundfont ~= "" and love.filesystem.getInfo(soundfont, "file") then
  sfPathOS = dumpToTemp(soundfont)
else
  for _, fname in ipairs(love.filesystem.getDirectoryItems("")) do
    if fname:lower():match("%.sf2$") then
      sfPathOS = dumpToTemp(fname)
      break
    end
  end
  -- if still nil, let Fluidsynth load its system default
end

-- Build a list of real OS MIDIs (dumped then escaped)
local songListOS = {}
for token in songList:gmatch("%S+") do
  local vpath = token:gsub("^['\"]*(.-)['\"]*$", "%1")
  if love.filesystem.getInfo(vpath, "file") then
    local realPath = dumpToTemp(vpath)
    table.insert(songListOS, shellEscape(realPath))
  end
end

-- Fallback host
shellHost = (shellHost and shellHost ~= "") and shellHost or "localhost"

-- Construct Fluidsynth command prefix
local prefix
if platform == "windows" then
  local winBackPath = love.thread.getChannel("winBackPath"):peek()
  prefix = string.format(
    '"%s.exe" -d -s -o shell.port=%d',
    winBackPath .. backend,
    shellPort
  )
else
  prefix = string.format(
    'stdbuf -oL %s -ds -o shell.port=%d',
    backend,
    shellPort
  )
end

print(string.format("Binding Fluidsynth shell to %s:%d", shellHost, shellPort))

-- Assemble final command
local cmd = prefix
if sfPathOS then
  cmd = cmd .. " " .. shellEscape(sfPathOS)
end
if #songListOS > 0 then
  cmd = cmd .. " " .. table.concat(songListOS, " ")
end

print(">> Fluidsynth command:", cmd)
local pipe = assert(io.popen(cmd, "r"))

-- Main loop reads control messages and MIDI output lines
while true do
  local cmd = clearChannel:pop()
  if cmd == "clear" then
    active_notes = {}
    dump_active()
  elseif cmd == "quit" then
    break
  end

  local line = pipe:read("*l")
  if not line then break end

  local ch, key = line:match("noteon%s+(%d+)%s+(%d+)%s+%d+")
  if ch then
    active_notes[ch..":"..key] = { channel=tonumber(ch), key=tonumber(key) }
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
