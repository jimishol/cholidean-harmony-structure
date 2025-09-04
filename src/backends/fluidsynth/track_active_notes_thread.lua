--- Active‐notes tracker thread for the Fluidsynth backend (Channel version).
-- Spawns the Fluidsynth process, listens for MIDI note‐on/off events,
-- maintains a table of currently active notes, and publishes them
-- to a shared thread channel ("active_notes") for consumption by the main thread.

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

-- NEW: channel for publishing active notes
local notesChannel = love.thread.getChannel("active_notes")

local active_notes = {}

-- Publish active notes to channel (instead of writing to disk)
local function publish_active()
  local set = {}
  for _, note in pairs(active_notes) do
    set[note.key] = true
  end

  local list = {}
  for k in pairs(set) do table.insert(list, k) end
  table.sort(list)

  -- Clear old snapshot so peek() always sees the latest
  notesChannel:clear()
  notesChannel:push(list)
end

-- Initial publish (empty list)
publish_active()

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
    return '"' .. path:gsub('"', '\\"') .. '"'
  else
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

-- Construct the executable + options prefix
local prefix
if platform == "windows" then
  local winBackPath = love.thread.getChannel("winBackPath"):peek()
  prefix = string.format(
    '"%s.exe" -d -s -o shell.port=%d',
     winBackPath .. backend, shellPort
  )
else
  prefix = string.format(
    'stdbuf -oL %s -ds -o shell.port=%d',
    backend, shellPort
  )
end

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
    publish_active()
  end

  local line = pipe:read("*l")
  if not line then break end

  local ch, key = line:match("noteon%s+(%d+)%s+(%d+)%s+%d+")
  if ch then
    active_notes[ch..":"..key] = { channel=tonumber(ch), key=tonumber(key) }
    publish_active()
  else
    local ch2, key2 = line:match("noteoff%s+(%d+)%s+(%d+)")
    if ch2 then
      active_notes[ch2..":"..key2] = nil
      publish_active()
    end
  end
end

pipe:close()
