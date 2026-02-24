--- Active‐notes tracker thread for the Fluidsynth backend (Iteration version).
-- Spawns Fluidsynth processes one by one, listens for MIDI note‐on/off events,
-- maintains a table of currently active notes, and publishes them
-- to a shared thread channel (`"active_notes"`) for consumption by the main thread.
-- @module src.backends.fluidsynth.track_active_notes_thread

local socket = require("socket")

--- Incoming midiPort channel (cleared and ignored in fluidsynth backend)
-- @local
local midi_port_channel = love.thread.getChannel("midiPort")
midi_port_channel:pop()

--- Channel for receiving "clear" commands from the main thread.
-- @local
local clearChannel    = love.thread.getChannel("track_control")

--- Channel providing the current platform name (e.g. "windows", "linux").
-- @local
local platformChannel = love.thread.getChannel("platform")
local platform        = platformChannel:peek()

--- Channel providing the backend executable name/path.
-- @local
local backendChannel   = love.thread.getChannel("backend")

--- Channel providing the percussion excluded midi channels.
-- @local
local excludeChannel = love.thread.getChannel("excludeChannels")

--- Channel providing the selected SoundFont path (may be nil or empty).
-- @local
local soundfontChannel = love.thread.getChannel("soundfonts")

--- Channel providing the list of songs to play (pipe‐separated VFS paths).
-- @local
local songsChannel     = love.thread.getChannel("songs")

local backend   = backendChannel:peek()
local soundfont = soundfontChannel:peek()
local songList  = songsChannel:peek()
local shellPort = love.thread.getChannel("shellPort"):peek()

--- Channel for publishing the current active notes list to the main thread.
-- @local
local notesChannel = love.thread.getChannel("active_notes")

--- Table of currently active notes, keyed by "channel:key" string.
-- Each value is a table with `channel` and `key` fields.
-- @local
local active_notes = {}

--- Publish the current active notes to the `"active_notes"` channel.
-- Deduplicates by note key, sorts ascending, clears the channel, and pushes the list.
-- @local
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

--- Robust check: Try to bind to the port.
-- If we can bind, the port is truly free for FluidSynth to use.
-- @tparam number port The TCP port to check
-- @treturn boolean True if port is free
local function waitForPortFree(port)
  local max_attempts = 50
  for i = 1, max_attempts do
    local s = socket.tcp()
    s:settimeout(0)
    -- Try to bind to the port. If this succeeds, the port is available.
    local ok, err = s:bind("127.0.0.1", port)
    s:close()

    if ok then
      return true
    end
    -- Port is still busy (TIME_WAIT), wait 100ms
    socket.sleep(0.1)
  end
  return false
end

--- Read a VFS file and write it to a real temporary file.
-- @tparam string vpath Virtual filesystem path
-- @treturn string OS path to the temporary file
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

--- Shell‐escape an OS path for safe command‐line usage.
-- @tparam string path OS path
-- @treturn string Escaped path
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
end

-- Build a list of real OS MIDIs (dumped then escaped)
local songTableOS = {}
for token in songList:gmatch("[^|]+") do
  local trimmed = token:match("^%s*(.-)%s*$")  -- trim surrounding spaces
  local vpath = trimmed:gsub("^['\"]*(.-)['\"]*$", "%1")  -- strip quotes like current code
  if love.filesystem.getInfo(vpath, "file") then
    local realPath = dumpToTemp(vpath)
    table.insert(songTableOS, shellEscape(realPath))
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
elseif platform == "macos" then
  -- macOS: requires coreutils (brew install coreutils) to get gstdbuf
  prefix = string.format('gstdbuf -oL %s -d -s -o shell.port=%d', backend, shellPort)
else
  prefix = string.format(
    'stdbuf -oL %s -d -s -o shell.port=%d',
    backend, shellPort
  )
end

local sfArg = sfPathOS and (" " .. shellEscape(sfPathOS)) or ""

-------------------------------------------------------------------------------
-- Main Iteration Loop
-------------------------------------------------------------------------------
local currentIndex = 1

while true do
  local currentSong = songTableOS[currentIndex]

  if currentSong then
    -- 1. Ensure the port is free from the previous process
    print(">> Checking port " .. shellPort .. " availability...")
    waitForPortFree(shellPort)
    socket.sleep(0.2) -- Small cushion for OS kernel

    -- 2. Assemble final command for the SINGLE current song
    local cmd = prefix .. sfArg .. " " .. currentSong
    print(">> Fluidsynth starting song [" .. currentIndex .. "]: " .. cmd)

    local pipe = assert(io.popen(cmd, "r"))
    local exclude = excludeChannel:peek() or {}

    -- Reset active notes for the new song start
    active_notes = {}
    publish_active()

    -- 3. Inner event loop: listens for clear commands and note events
    while true do
      if clearChannel:pop() == "clear" then
        active_notes = {}
        publish_active()
      end

      local line = pipe:read("*l")
      if not line then
        -- Process was killed or finished
        break
      end

      -- Note Parsing Logic (Untouched)
      local ch, key = line:match("noteon%s+(%d+)%s+(%d+)%s+%d+")
      if ch then
        local chNum = tonumber(ch)
        local shouldExclude = false
        for _, v in ipairs(exclude) do
          if chNum == v then shouldExclude = true; break end
        end
        if not shouldExclude then
          active_notes[ch..":"..key] = { channel=chNum, key=tonumber(key) }
          publish_active()
        end
      else
        local ch2, key2 = line:match("noteoff%s+(%d+)%s+(%d+)")
        if ch2 then
          -- Always allow noteoff to remove the note
          active_notes[ch2..":"..key2] = nil
          publish_active()
        end
      end
    end

    -- 4. Cleanup after process dies
    pipe:close()
    print(">> Song process ended. Advancing index...")

    currentIndex = currentIndex + 1
    active_notes = {}
    publish_active()

  else
    -- End of playlist: Wait for a "clear" signal (e.g. Restart) to reset
    local msg = clearChannel:demand()
    if msg == "clear" then
      currentIndex = 1
      active_notes = {}
      publish_active()
    end
  end
end
