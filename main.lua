--- Main module for the Cholidean Harmony Structure application.
-- Extends Lua search paths, instantiates and initializes 3DreamEngine,
-- loads application modules, and defines Love2D callbacks.
-- @module main

-- 1) Extend Lua’s search paths
package.path = table.concat({
  "./?.lua",
  "./?/init.lua",
  "./3DreamEngine/?.lua",
  "./3DreamEngine/?/init.lua",
  "./src/?.lua",
  "./src/utils/?.lua",
  "./src/?/init.lua",
  "./extensions/?.lua",
  "./extensions/?/init.lua",
  "./assets/?.lua",
}, ";") .. ";" .. package.path

-- 2) Require & instantiate 3DreamEngine
local Engine = require("3DreamEngine")
local dream  = (type(Engine) == "function" and Engine() or Engine)
local FREEZE = false
local freezeCanvas = nil
local forceContOnNextToggle = false
local baseTitle = ""
local baseTitleShort = ""
local currentSongName = "" -- New: Remember the last song name received

-- 3) Require your modules
local scene  = require("scene")
local camera = require("camera")
local Input  = require("src.input")
local A      = require("src.input.actions")
local Colors = require("src.utils.colors")

local os_detect = require("os_detect")
local platform = os_detect.getPlatform()
local platformChannel = love.thread.getChannel("platform")
platformChannel:push(platform)

local constants = require("src.constants")
local backend   = constants.backend

-- Initialize the centralized backend loader
local Backend = require("src.backends")
Backend.setup(backend)

local backendModules = {
  noteState   = require("src.backends.note_state"),
  controls    = Backend.controls,
  commandMenu = Backend.commandMenu,
}

local backendChannel = love.thread.getChannel("backend")
backendChannel:push(backend)

local shellHostChannel = love.thread.getChannel("shellHost")
local host = constants.shellHost
shellHostChannel:push(host)

local shellPortChannel = love.thread.getChannel("shellPort")
local shellPort = constants.shellPort
shellPortChannel:push(shellPort)

local midiPortChannel = love.thread.getChannel("midiPort")
local midiPort = constants.DEFAULT_MIDI_PORT
midiPortChannel:push(midiPort)

local soundfontChannel = love.thread.getChannel("soundfonts")
soundfontChannel:push(constants.soundfonts)

local playlist = require("src.backends.playlist")
backendModules.playlist = playlist

-- Now it’s safe to require and use the playlist backend:
local playlist = require("src.backends.playlist")
backendModules.playlist = playlist
local playlist      = require("src.backends.playlist")
local selectedSongs = playlist.getSelectedSongs()

-- If empty, push "" so Fluidsynth sees no MIDI args.
-- If non-empty, join with spaces.
local songList = (#selectedSongs > 0)
  and table.concat(selectedSongs, "|")
  or ""

-- Exclude percussion channels
local excludeChannelsChannel = love.thread.getChannel("excludeChannels")
excludeChannelsChannel:push(constants.excludeChannels or {})

love.thread.getChannel("songs"):push(songList)
-- -- ✅ Load backend-neutral playlist
-- local ok_playlist, playlist = pcall(require, "src.backends.playlist")
-- backendModules.playlist = ok_playlist and playlist or {
--   getSelectedSongs = function() return {} end  -- empty playlist in manual mode
-- }
-- local selectedSongs = backendModules.playlist.getSelectedSongs()
--
-- local songsChannel = love.thread.getChannel("songs")
-- local songList = table.concat(selectedSongs, " ")
-- songsChannel:push(songList)

--- Callback invoked once when the Love2D application loads.
-- Sets up window title, text input, material libraries, engine initialization,
-- scene and camera loading, and starts the backend thread.
-- @function love.load
-- @return nil
function love.load()
  -- 1. Get the full name from conf.lua ("Cholidean harmony structure")
  local conf_title = love.window.getTitle() or "Cholidean harmony structure"
  -- 2. Create the Full version: "Cholidean harmony structure [fluidsynth]"
  baseTitleFull = conf_title .. " [" .. tostring(backend) .. "]"
  -- 3. Create the Short version: "Cholidean [fluidsynth]"
  -- This pattern grabs the first word before the space
  local firstWord = conf_title:match("^(%S+)") or "Cholidean"
  baseTitleShort = firstWord .. " [" .. tostring(backend) .. "]"
  -- 4. Set initial title to the Full version
  love.window.setTitle(baseTitleFull)

  love.keyboard.setTextInput(true)

  -- 5. Load all materials, then init the engine in the callback
    dream:loadMaterialLibrary("assets/materials_gl")

  if platform == "windows" then

    local windowsBackendPathChannel = love.thread.getChannel("winBackPath")
    windowsBackendPathChannel:push(constants.windowsBackendPath)

  end

  dream:init()
  Colors.init(dream)

  -- 6. Only now that the engine is initialized and textures are loaded do we load the scene & camera
  scene.load(dream, backendModules.commandMenu)
  camera:init(dream)

  -- Start the correct backend thread
  Backend.start()
end

local silenceTimer = 0
local allowAdvance = true -- The "Teacher Mode" toggle for fluidsynth backend

function love.update(dt)
  -- 1. Check for a new song name
  local nameChan = love.thread.getChannel("current_song_name")
  local newName = nameChan:pop()

  if newName then
    currentSongName = newName -- Remember this name!
    love.window.setTitle(currentSongName .. " | " .. baseTitleShort)
  end

  -- 2. Auto-Advance Logic
  if not FREEZE and allowAdvance then
    local anyActive = false
    -- Check the noteSystem state already processed by scene.lua
    for i = 1, 12 do
      if scene.noteSystem.notes[i].active then
        anyActive = true
        break
      end
    end

    if not anyActive then
      silenceTimer = silenceTimer + dt
      if silenceTimer > constants.auto_advance_timeout then
        print("[Auto-Advance] Silence detected. Advancing...")
        backendModules.controls.nextSong(host, shellPort)
        silenceTimer = 0 
      end
    else
      silenceTimer = 0 -- Reset if teacher or MIDI plays
    end
  else
    silenceTimer = 0 -- Reset if Frozen or in Teacher Mode
  end

  -- 3. Standard Engine Updates
  if FREEZE then return end
  dream:update(dt)
  camera:update(dt)
  scene:update(dt)
end

--- Callback invoked every frame to render the scene and overlays.
-- Prepares the 3D engine, draws the scene, then switches to screen-space
-- to render the HUD, debug text, command menu, and fallback messages.
-- Also shows a visual indicator when Freeze Mode is active.
-- @function love.draw
-- @return nil
function love.draw()
  -- ============================
  -- FREEZE MODE: draw frozen 3D frame + live HUD/debug
  -- ============================
  if FREEZE and freezeCanvas then
      -- Draw the frozen 3D frame
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(freezeCanvas, 0, 0)

      -- Draw HUD/debug overlays (dynamic)
      love.graphics.push()
      love.graphics.origin()
      love.graphics.setColor(1, 1, 1, 1)

      scene.apply()

      if scene.commandMenu.visible then
        scene.commandMenu:draw(10, 120)
      end

      if Backend.fallbackMessage then
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.print(Backend.fallbackMessage, 10, 10)
      end

      love.graphics.pop()

      -- Draw FREEZE MODE overlay
      local w, h = love.graphics.getDimensions()

      love.graphics.setColor(1, 0.2, 0.2, 1)
      local text = "Power-Saving Pause"
      local margin = 20
      local font = love.graphics.getFont()
      local tw = font:getWidth(text)
      love.graphics.print(text, w - tw - margin, 20)

      return
  end

  -- ============================
  -- NORMAL RENDERING
  -- ============================

  -- 3D scene rendering
  dream:prepare()
  scene.draw(dream)
  dream:present()

  -- Screen-space overlays (HUD, menus, messages)
  love.graphics.push()
  love.graphics.origin()
  love.graphics.setColor(1, 1, 1, 1)

  scene.apply()

  if scene.commandMenu.visible then
    scene.commandMenu:draw(10, 120)
  end

  if Backend.fallbackMessage then
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.print(Backend.fallbackMessage, 10, 10)
  end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.pop()
end

--- Terminates the external backend process if one was launched.
-- Extracts the base name of the backend command and issues a platform-specific kill.
-- @local
-- @function genericQuit
-- @return nil
local function genericQuit()
  if backend ~= "null" then
    local proc = backend:match("([^/\\]+)$"):gsub("%.%w+$", "")

    if platform == "windows" then
      os.execute(string.format(
        'taskkill /IM %s.exe /F >NUL 2>&1',
        proc
      ))
    else
      os.execute(string.format(
        'pkill -9 -f "%s" > /dev/null 2>&1',
        proc
      ))
    end
  end
end

--- Checks if either Control key is currently pressed.
-- @local
-- @function ctrlDown
-- @treturn boolean true if left or right control key is down.
local function ctrlDown()
  return love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
end

--- Callback to handle keypress events.
-- Processes command menu input, internal actions, and dispatches backend controls.
-- Also toggles Freeze Mode when playback is toggled.
-- @function love.keypressed
-- @tparam string key Key that was pressed.
-- @tparam string scancode Platform-specific scancode.
-- @return nil
function love.keypressed(key, scancode)
  -- Command menu handling
  if scene.commandMenu.visible then
    local topic = scene.commandMenu:keypressed(key, scancode)

    if topic then
      if backendModules.controls.send_message then
        backendModules.controls.send_message(topic, host, shellPort)
        scene.commandMenu.visible = backendModules.controls.visible or false
      else
        print("⚠️ No backend available to send message: " .. topic)
        scene.commandMenu.visible = false
      end
    end

    return
  end

  -- Map key to action
  local action = Input:onKey(key)
  if not action then return end

  -- Restart application
  if action == A.RESTART then
    genericQuit()
    love.event.quit(42)
    return
  end

  -- Toggle command menu
  if action == A.SHOW_COMMAND_MENU then
    scene.commandMenu:toggle()
    return
  end

  -- Quit application
  if action == A.QUIT and ctrlDown() then
    genericQuit()
    love.event.quit()
    return
  end

  -- Backend action dispatch table
  local backendActions = {
    [A.TOGGLE_PLAYBACK] = "togglePlayback",
    [A.BEGIN_SONG]      = "beginSong",
    [A.END_SONG]       = "endSong",
    [A.NEXT_SONG]       = "nextSong",
  }

  -- In love.keypressed, backend action block:
  local methodName = backendActions[action]
  if methodName and backendModules.controls[methodName] then

      -- 1. FORBID Shift+Return (Teacher Mode) during Freeze
      if action == A.END_SONG and FREEZE then
        return 
      end

      -- 2. Execute the backend command (beginSong now sends start + cont)
      backendModules.controls[methodName](host, shellPort)

-- 3. Update Auto-Advance Allowance and Window Title
      if action == A.BEGIN_SONG or action == A.NEXT_SONG then
        allowAdvance = true
        silenceTimer = 0

        -- If Tab (BEGIN_SONG), restore the short title immediately using cached name
        if action == A.BEGIN_SONG and currentSongName ~= "" then
          love.window.setTitle(currentSongName .. " | " .. baseTitleShort)
        end

      elseif action == A.END_SONG then
        allowAdvance = false
        silenceTimer = 0
        -- Restore full title for Teacher Mode
        love.window.setTitle(baseTitleFull)
        print("[Main] Teacher Mode: Restored full title.")
      end

      -- 4. Handle Playback Toggling (Freeze Mode)
      if action == A.TOGGLE_PLAYBACK then
        if not FREEZE then
          forceContOnNextToggle = true
          backendModules.controls._forceContOnNextToggle = true
        end
        FREEZE = not FREEZE

        if FREEZE then
          local w, h = love.graphics.getDimensions()
          freezeCanvas = love.graphics.newCanvas(w, h)
          freezeCanvas:renderTo(function()
            dream:prepare()
            scene.draw(dream)
            dream:present()
            if Backend.fallbackMessage then
              love.graphics.setColor(1, 0.8, 0)
              love.graphics.print(Backend.fallbackMessage, 10, 10)
            end
          end)
        end

      -- 5. Handle Song Changes (Unfreeze visuals)
      elseif action == A.NEXT_SONG or action == A.BEGIN_SONG then
        if FREEZE then
          FREEZE = false
          -- Clear the backend's "force continue" flag since beginSong already handled it
          backendModules.controls._forceContOnNextToggle = false
        end
      end
    end

  -- Scene-level actions
  if scene.pressedAction and scene.pressedAction(action) then
    if action == A.ROTATE_CW or action == A.ROTATE_CCW then
      scene.updateLabels()
    end
    return
  end

  -- Camera-level actions
  if camera.pressedAction and camera:pressedAction(action) then
    return
  end
end

--- Callback to handle text input events for the command menu.
-- Opens the menu on colon keystroke or forwards text to the menu when visible.
-- @function love.textinput
-- @tparam string t Text input character.
-- @return nil
function love.textinput(t)
  if t == ":" and not scene.commandMenu.visible then
    scene.commandMenu:toggle()
    return
  end

  if scene.commandMenu.visible then
    scene.commandMenu:textinput(t)
    return
  end
end

--- Callback invoked when the window is resized.
-- Re-initializes the 3D engine to update viewport and projection.
-- @function love.resize
-- @tparam number w New window width.
-- @tparam number h New window height.
-- @return nil
function love.resize(w, h)
  dream:init()
end

--- Forward mouse wheel to command menu for scrolling help
function love.wheelmoved(x, y)
  if scene.commandMenu.visible then
    scene.commandMenu:wheelmoved(x, y)
  end
end
