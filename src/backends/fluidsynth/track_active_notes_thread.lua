--- Active‐notes tracker thread for the Fluidsynth backend.
-- Spawns the Fluidsynth process, listens for MIDI note‐on/off events,
-- maintains a table of currently active notes, and writes them
-- to a Lua file (`active_notes.lua`) for consumption by the main thread.
-- @module src.backends.fluidsynth.track_active_notes_thread

local clearChannel    = love.thread.getChannel("track_control")
local platformChannel = love.thread.getChannel("platform")
local platform        = platformChannel:peek()

local backendChannel   = love.thread.getChannel("backend")
local soundfontChannel = love.thread.getChannel("soundfonts")
local songsChannel     = love.thread.getChannel("songs")

local backend   = backendChannel:peek()
local soundfont = soundfontChannel:peek()   -- may be nil or "" for system default
local songList  = songsChannel:peek()       -- space-separated VFS paths
local shellPort = love.thread.getChannel("shellPort"):peek()
local shellHost = love.thread.getChannel("shellHost"):peek()

local output_file = "active_notes.lua"
local active_notes = {}

-- Dump active notes to disk
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

dump_active()

-- read a VFS file and write it to a real temp file
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

-- shell-escape an OS path
local function shellEscape(path)
  if platform == "windows" then
    -- wrap in double-quotes
    return '"' .. path:gsub('"', '\\"') .. '"'
  else
    -- wrap in single-quotes, escape internal single-quotes
    local escaped = path:gsub("'", "'\\''")
    return "'" .. escaped .. "'"
  end
end

-- Resolve SoundFont: explicit, root-dropped, or system default
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
  -- if still nil, omit and let Fluidsynth load its system default
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
-- (optional) fallback:
-- if #songListOS == 0 then
--   table.insert(songListOS,
--     shellEscape(dumpToTemp("assets/Beethoven_Fur_Elise.mid"))
--   )
-- end

-- Fallback if no host is set
shellHost = (shellHost and shellHost ~= "") and shellHost or "localhost"

-- Construct the executable + options prefix
local prefix
if platform == "windows" then
  local winBackPath = love.thread.getChannel("winBackPath"):peek()
  -- Wrap backend path, and pass host:port as a single string if needed
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

-- If you want to expose host info for logging or for a wrapper command:
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

while true do
  if clearChannel:pop() == "clear" then
    active_notes = {}
    dump_active()
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
