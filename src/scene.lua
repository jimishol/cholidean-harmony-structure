-- src/scene.lua
local dream = require("3DreamEngine")
local lfs = love.filesystem
--local skyShader = love.graphics.newShader("shaders/skyShader.frag")
--dream:registerShader(skyShader, "customSky")  -- optional tag if you want to reuse later

local skyExt = require("extensions/sky")
--sun
local sun = dream:newLight("sun")

local scene = {}
scene.joints = {}
scene.edges = {}
scene.curves = {}
scene.surfaces = {}

--local hdrImg = nil
scene.environmentBrightness = require("constants").brightness
local bright = scene.environmentBrightness
hdrImg = love.graphics.newImage("assets/sky/DaySkyHDRI021A_4K.hdr")
dream:setSky(hdrImg, bright)

local function loadCategory(folder, targetTable)
  local basePath = "assets/models/" .. folder .. "/"
  local files = lfs.getDirectoryItems(basePath)

  for _, file in ipairs(files) do
    if file:match("%.obj$") then
      local name = file:match("(.+)%.obj")
      local success, object = pcall(function()
        return dream:loadObject(basePath .. name)
      end)
      if success and object then
        table.insert(targetTable, object)
      else
        print("⚠️ Failed to load " .. folder .. ": " .. name)
      end
    end
  end
end

function scene.load()
--dream:setSky(skyExt.render)
dream:setSky(hdrImg, bright)

sun:addNewShadow()
--  hdrImg:setFilter("linear", "linear")
--  hdrImg:setWrap("clamp", "clamp")
--  dream:setSky(hdrImg,bright, "customSky")

  loadCategory("joints", scene.joints)
  loadCategory("edges", scene.edges)
  loadCategory("curves", scene.curves)
  loadCategory("surfaces", scene.surfaces)
end

function scene.update(dt)

  if love.keyboard.isDown("+") or love.keyboard.isDown("=") then
    bright = math.min(bright + 0.1, 2.5)
  elseif love.keyboard.isDown("-") then
    bright = math.max(bright - 0.1, 0.0)
  end
  skyExt:setDaytime(sun, bright/2.5)
dream:setSky(hdrImg, bright)

-- You can also inspect dream.exposure each frame if you want to display it
end

function scene.draw()

  dream:addLight(sun)
  -- skyShader:send("uSkyTexture", hdrImg)
  -- skyShader:send("uTintColor", {1.0, 0.9, 0.7})
  -- skyShader:send("uBrightness", bright)
  -- skyShader:send("uIsGlossyRay", false)

  for _, obj in ipairs(scene.joints) do
    dream:draw(obj)
  end
  for _, obj in ipairs(scene.edges) do
    dream:draw(obj)
  end
  for _, obj in ipairs(scene.curves) do
    dream:draw(obj)
  end
  for _, obj in ipairs(scene.surfaces) do
    dream:draw(obj)
  end
end

return scene
