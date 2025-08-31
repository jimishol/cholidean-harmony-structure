--- Active-notes tracker thread for the Fluidsynth backend.
-- Spawns the Fluidsynth process, listens for MIDI note-on/off events,
-- maintains a table of currently active notes, and sends them
-- over TCP to the note-state server. Listens for "clear" to reset
-- the note table and "quit" to exit cleanly.
-- @module src.backends.fluidsynth.track_active_notes_thread

local socket = require("socket")
local timer  = require("love.timer")

local clearChannel    = love.thread.getChannel("track_control")
local platformChannel = love.thread.getChannel("platform")
local backendChannel  = love.thread.getChannel("backend")
local soundfontChannel = love.thread.getChannel("soundfonts")
local songsChannel     = love.thread.getChannel("songs")

local platform   = platformChannel:peek()
local backend    = backendChannel:peek()
local soundfont  = soundfontChannel:peek()
local songList   = songsChannel:peek()
local shellPort  = love.thread.getChannel("shellPort"):peek()
local shellHost  = love.thread.getChannel("shellHost"):peek()

local noteStateHost = love.thread.getChannel("noteStateHost"):peek() or "localhost"
local noteStatePort = tonumber(love.thread.getChannel("noteStatePort"):peek()) or 9810

local active_notes = {}

local client = assert(socket.tcp())
client:settimeout(0)
client:connect(noteStateHost, noteStatePort)
print("Connected to note-state server:", noteStateHost, noteStatePort)

--- Sends the current set of active notes to the TCP server.
-- Converts the internal note table to a comma-separated list.
-- @local
local function send_active()
  local set = {}
  for _, note in pairs(active_notes) do
    set[note.key] = true
  end

  local list = {}
  for k in pairs(set) do table.insert(list, k) end
  table.sort(list)

  local payload = table.concat(list, ",")
  client:send(payload .. "\n")
end

--- Reads a virtual file and writes it to a temporary OS file.
-- Used for SoundFont and MIDI asset preparation.
-- @param vpath string Virtual path inside LÖVE filesystem
-- @return string OS path to the dumped file
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

--- Escapes an OS path for safe shell usage.
-- @param path string Raw path
-- @return string Escaped shell-safe path
local function shellEscape(path)
  if platform == "windows" then
    return '"' .. path:gsub('"', '\\"') .. '"'
  else
    local escaped = path:gsub("'", "'\\''")
    return "'" .. escaped .. "'"
  end
end

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

local songListOS = {}
for token in songList:gmatch("%S+") do
  local vpath = token:gsub("^['\"]*(.-)['\"]*$", "%1")
  if love.filesystem.getInfo(vpath, "file") then
    local realPath = dumpToTemp(vpath)
    table.insert(songListOS, shellEscape(realPath))
  end
end

shellHost = (shellHost and shellHost ~= "") and shellHost or "localhost"

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
  local cmd = clearChannel:pop()
  if cmd == "clear" then
    active_notes = {}
    send_active()
  elseif cmd == "quit" then
    break
  end

  local line = pipe:read("*l")
  if not line then break end

  local ch, key = line:match("noteon%s+(%d+)%s+(%d+)%s+%d+")
  if ch then
    active_notes[ch..":"..key] = { channel=tonumber(ch), key=tonumber(key) }
    send_active()
  else
    local ch2, key2 = line:match("noteoff%s+(%d+)%s+(%d+)")
    if ch2 then
      active_notes[ch2..":"..key2] = nil
      send_active()
    end
  end
end

client:send("\n")
client:close()
pipe:close()
