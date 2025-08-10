-- main.lua

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
shellHostChannel:push(shellHost)

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

function love.load()
  love.window.setTitle("Cholidean Harmony Structure")
  love.keyboard.setTextInput(true)

  -- 4) Load all materials, then init the engine in the callback
  dream:loadMaterialLibrary("assets/materials")
  if platform == "windows" then
    dream:loadMaterialLibrary("assets/materials/materials_dx")
  end

  dream:init()
  Colors.init(dream)

  -- 5) Only now that the engine is initialized and textures are loaded do we load the scene & camera
  scene.load(dream, backendModules.commandMenu)
  camera:init(dream)

  -- Start the correct backend thread
  Backend.start()
end

function love.update(dt)
  dream:update(dt)
  camera:update(dt)
  scene:update(dt)
end

function love.draw()
  dream:prepare()
  scene.draw(dream)
  dream:present()

  -- 2) Reset to screen‐space for HUD & overlays
  love.graphics.push()
  love.graphics.origin()
  love.graphics.setColor(1, 1, 1, 1)

  -- 2.A) Re–draw debug text (since we only wanted it in screen‐space)
  scene.apply()

  -- draw your command‐menu on top of the scene
  if scene.commandMenu.visible then
    scene.commandMenu:draw(10,120)
  end

  if Backend.fallbackMessage then
    love.graphics.setColor(1, 0.8, 0)      -- amber
    love.graphics.print(Backend.fallbackMessage, 10, 10)
  end

  love.graphics.pop()
end

local function genericQuit()
    -- if we actually launched something, kill it
    if backend ~= "null" then
      -- extract just the base name, remove any extension
      local proc = backend:match("([^/\\]+)$"):gsub("%.%w+$", "")

      if platform == "windows" then
	-- force-kill the .exe
	os.execute(string.format(
	  'taskkill /IM %s.exe /F >NUL 2>&1',
	  proc
	))
      else
	-- SIGKILL by name (matches scripts or binaries)
	os.execute(string.format(
	  'pkill -9 -f "%s" > /dev/null 2>&1',
	  proc
	))
      end
    end
end

local backendCtl = backendModules.controls or {}

local function ctrlDown()
  return love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
end

function love.keypressed(key, scancode)

  if scene.commandMenu.visible then
    local topic = scene.commandMenu:keypressed(key, scancode)

    if topic then
      if backendCtl.send_message then
        backendCtl.send_message(topic, host, shellPort)
        scene.commandMenu.visible = backendCtl.visible or false
      else
        print("⚠️ No backend available to send message: " .. topic)
        scene.commandMenu.visible = false  -- fallback: hide menu
      end
    end

    return
  end

  -- 2) When menu is closed, fall back to your normal keybindings
  local action = Input:onKey(key)
  if not action then
    return
  end

  if action == A.RESTART then
    genericQuit()
    love.event.quit(42)
    return
  end

  -- 3) Toggle the menu on your SHOW_COMMAND_MENU action
  if action == A.SHOW_COMMAND_MENU then
    scene.commandMenu:toggle()
    return
  end

  -- 4) Handle all your existing actions exactly as before
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
  if methodName and backendCtl[methodName] then
    backendCtl[methodName](host, shellPort)
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

-- 2) Handle text input when the menu is open
function love.textinput(t)
  -- 1) When menu is hidden, open on colon keystroke
  if t == ":" and not scene.commandMenu.visible then
    scene.commandMenu:toggle()
    return
  end

  -- 2) When menu is open, feed text into it
  if scene.commandMenu.visible then
    scene.commandMenu:textinput(t)
    return
  end

  -- 3) Otherwise ignore or dispatch to other systems
end

function love.resize(w, h)
  -- re-initialize to update viewport, projection, etc.
  dream:init()
end
