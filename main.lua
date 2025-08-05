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

local constants = require("src.constants")
local backend   = constants.backend

local backendChannel = love.thread.getChannel("backend")
backendChannel:push(backend)

local soundfontChannel = love.thread.getChannel("soundfont")
soundfontChannel:push(constants.soundfont)

local selectedSongs = {
  "assets/Wagner_Ride_of_the_valkyries.mid",
}
local songsChannel = love.thread.getChannel("songs")
local songList = table.concat(selectedSongs, " ")
songsChannel:push(songList)

function love.load()
  love.window.setTitle("Cholidean Harmony Structure")

  -- 4) Load all materials, then init the engine in the callback
  dream:loadMaterialLibrary("assets/materials")
  if platform == "windows" then
    dream:loadMaterialLibrary("assets/materials/materials_dx")
  end

  dream:init()
  Colors.init(dream)

  -- 5) Only now that the engine is initialized and textures are loaded do we load the scene & camera
  scene.load(dream)
  camera:init(dream)

    -- Start the correct thread based on backend
    if backend == "fluidsynth" then
      local thread = love.thread.newThread("src/midi/track_active_notes_thread.lua")
      thread:start()
    elseif backend == "timidity" then
      print("⚠️ Unknown backend type:", backend)
    else
      print("⚠️ Unknown backend type:", backend)
    end
end

function love.update(dt)
  dream:update(dt)
  camera:update(dt)
  scene:update(dt)
end

function love.draw()
  dream:prepare()
  scene.apply()
  scene.draw(dream)
  dream:present()
  scene.apply()
end

function love.keypressed(key)
  local action = Input:onKey(key)
  if not action then return end

  if action == A.QUIT then
    local quit_channel = love.thread.getChannel("quit")
    quit_channel:push("quit")

    if backend == "fluidsynth" then
      if platform == "windows" then
	os.execute('taskkill /IM fluidsynth.exe /F >NUL 2>&1')
      else
	os.execute('pkill -9 fluidsynth > /dev/null 2>&1')
      end
    elseif backend == "other_player" then
      -- Insert "other_player" specific cleanup here if needed
      -- For now, just placeholder logic
    else
      return
    end

    love.event.quit()
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

function love.resize(w, h)
  -- re-initialize to update viewport, projection, etc.
  dream:init()
end
