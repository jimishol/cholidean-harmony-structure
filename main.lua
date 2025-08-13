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

local soundfontChannel = love.thread.getChannel("soundfonts")
soundfontChannel:push(constants.soundfonts)

-- ✅ Load backend-neutral playlist
local ok_playlist, playlist = pcall(require, "src.backends.playlist")
backendModules.playlist = ok_playlist and playlist or {
  getSelectedSongs = function() return {} end  -- empty playlist in manual mode
}
local selectedSongs = backendModules.playlist.getSelectedSongs()

local songsChannel = love.thread.getChannel("songs")
local songList = table.concat(selectedSongs, " ")
songsChannel:push(songList)

--- Callback invoked once when the Love2D application loads.
-- Sets up window title, text input, material libraries, engine initialization,
-- scene and camera loading, and starts the backend thread.
-- @function love.load
-- @return nil
function love.load()
  love.window.setTitle("Cholidean Harmony Structure")
  love.keyboard.setTextInput(true)

  -- 4) Load all materials, then init the engine in the callback
    dream:loadMaterialLibrary("assets/materials_gl")

  if platform == "windows" then

    local windowsBackendPathChannel = love.thread.getChannel("winBackPath")
    windowsBackendPathChannel:push(constants.windowsBackendPath)

    local PTYChannel = love.thread.getChannel("PTYcmd")
    PTYChannel:push(constants.winPTYcommand)

  end

  dream:init()
  Colors.init(dream)

  -- 5) Only now that the engine is initialized and textures are loaded do we load the scene & camera
  scene.load(dream, backendModules.commandMenu)
  camera:init(dream)

  -- Start the correct backend thread
  Backend.start()
end

--- Callback invoked every frame to update game state.
-- Updates the rendering engine, camera, and scene logic.
-- @function love.update
-- @tparam number dt Delta time since last frame.
-- @return nil
function love.update(dt)
  dream:update(dt)
  camera:update(dt)
  scene:update(dt)
end

--- Callback invoked every frame to render the scene and overlays.
-- Prepares the 3D engine, draws the scene, then switches to screen-space
-- to render the HUD, debug text, command menu, and fallback messages.
-- @function love.draw
-- @return nil
function love.draw()
  dream:prepare()
  scene.draw(dream)
  dream:present()

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
-- @function love.keypressed
-- @tparam string key Key that was pressed.
-- @tparam string scancode Platform-specific scancode.
-- @return nil
function love.keypressed(key, scancode)
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

  local action = Input:onKey(key)
  if not action then return end

  if action == A.RESTART then
    genericQuit()
    love.event.quit(42)
    return
  end

  if action == A.SHOW_COMMAND_MENU then
    scene.commandMenu:toggle()
    return
  end

  if action == A.QUIT and ctrlDown() then
    genericQuit()
    love.event.quit()
    return
  end

  local backendActions = {
    [A.TOGGLE_PLAYBACK] = "togglePlayback",
    [A.BEGIN_SONG]      = "beginSong",
    [A.NEXT_SONG]       = "nextSong",
  }

  local methodName = backendActions[action]
  if methodName and backendModules.controls[methodName] then
    backendModules.controls[methodName](host, shellPort)
    return
  end

  if scene.pressedAction and scene.pressedAction(action) then
    if action == A.ROTATE_CW or action == A.ROTATE_CCW then
      scene.updateLabels()
    end
    return
  end

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
